package com.st_ones.evermp.buyer.cont.service;

import com.ktnet.license.LicenseVerifyUtil;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.ContStringUtil;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EnumerationNotFoundException;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.CT0300Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import net.htmlparser.jericho.FormControl;
import net.htmlparser.jericho.OutputDocument;
import net.htmlparser.jericho.Source;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang.time.DateUtils;
import org.apache.commons.lang3.StringUtils;
import org.joda.time.Days;
import org.joda.time.LocalDate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import tradesign.crypto.provider.JeTS;
import tradesign.pki.pkix.SignedData;
import tradesign.pki.pkix.X509Certificate;
import tradesign.pki.util.JetsUtil;

import java.io.*;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.NoSuchAlgorithmException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service(value = "CT0300Service")
public class CT0300Service  extends BaseService {

	@Autowired MessageService msg;
	@Autowired LargeTextService largeTextService;

	@Autowired private DocNumService docNumService;
	@Autowired private CT0300Mapper ct0300mapper;
    @Autowired private BAPM_Service approvalService;
    @Autowired private EverMailService everMailService;
    @Autowired private makeHtmlService makehtmlservice;
    @Autowired private EApprovalService eApprovalService;
    
    private static final String MAIN_FORM_SQ = "0";
    private static Logger logger = LoggerFactory.getLogger(CT0300Service.class);

    public List<Map<String, Object>> getItemUnitPrcList(Map<String, String> formData) {
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("BUYER_CD").split(",")));
        }
        return ct0300mapper.getItemUnitPrcList(paramObj);
    }

    public List<Map<String, Object>> getValidTargetContList(Map<String, String> formData) {
        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("BUYER_CD").split(",")));
        }
        return ct0300mapper.getValidTargetContList(paramObj);
    }

    public List<Map<String, Object>> ecoa0040_doSearch(Map<String, String> formData) {

        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("PUR_ORG_CD"))) {
            paramObj.put("PUR_ORG_CD_LIST", Arrays.asList(formData.get("PUR_ORG_CD").split(",")));
        }
        return ct0300mapper.ecoa0040_doSearch(paramObj);
    }

    public List<Map<String, Object>> ecoa0041_doSearch(Map<String, String> param) {
        return ct0300mapper.ecoa0041_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecoa0041_doMappingCont(Map<String, String> dataForm, List<Map<String, Object>> gridDatas) throws Exception {

        String selVendorCd = dataForm.get("selVendorCd");
        String selPurcContNum = dataForm.get("selPurcContNum");
        String[] selPurcContArgs = selPurcContNum.split(",");

        if(selPurcContArgs.length > 0) {
            for (int i = 0; i < selPurcContArgs.length; i++) {
                Map<String, Object> gridData = gridDatas.get(0);
                gridData.put("PURC_CONT_NUM", selPurcContArgs[i]);
                ct0300mapper.doUpdateMIGY(gridData);
            }
        }
        return msg.getMessageByScreenId("ECOA0041", "002");
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ecoa0040_doCopyErpCont(List<Map<String, Object>> erpDatas) throws Exception {

        String rtnCd = "S";

        try {
            for (Map<String, Object> erpData : erpDatas) {

                Map<String, Object> migy = (Map<String, Object>) erpData.get("contGY");
                // 개발인 경우, irsNum를 "1234567890"으로 강제 변경
                if (PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
                    migy.put("IRS_NUM", "1234567890");
                }

                String contNum    = "";
                String progressCd = "";
                String ifSq       = "0";
                String nextIfSq   = "";
                Map<String, Object> existData = ct0300mapper.checkExistContData(erpData);

                if (existData == null) {
                	ifSq = "1";
                } else {
                	contNum    = EverString.nullToEmptyString(existData.get("CONT_NUM"));
                	progressCd = EverString.nullToEmptyString(existData.get("PROGRESS_CD"));
                	ifSq       = EverString.nullToEmptyString(String.valueOf(existData.get("IF_SQ")));
                	nextIfSq   = EverString.nullToEmptyString(String.valueOf(existData.get("NEXT_IF_SQ")));
                }

                // 계약이 진행중인 경우 Skip
                if (!"".equals(progressCd) && 4200 <= Integer.parseInt(progressCd) && Integer.parseInt(progressCd) < 4300) {
                	continue;
                }

                if ("4300".equals(progressCd)) {
                    migy.put("IF_SQ", nextIfSq);
                } else {
                    migy.put("IF_SQ", ifSq);
                }

                // TGYSMIGY ERP 계약
                ct0300mapper.doMergeErpContGY(migy);


                // TGYSMISW ERP 계약사업, TGYSMIGI ERP 계약기일
                if ("".equals(contNum)) {
                    ct0300mapper.doDeleteErpContSW(migy);
                    ct0300mapper.doDeleteErpContGI(migy);
                }

                // TGYSMISW ERP 계약사업
                List<Map<String, Object>> misws = (List<Map<String, Object>>) erpData.get("contSW");
                for (Map<String, Object> misw : misws) {
                    misw.put("IF_SQ", migy.get("IF_SQ"));

                    ct0300mapper.doCopyErpContSW(misw);
                }

                // TGYSMIGI ERP 계약기일
                List<Map<String, Object>> migis = (List<Map<String, Object>>) erpData.get("contGI");
                for (Map<String, Object> migi : migis) {
                    migi.put("IF_SQ", migy.get("IF_SQ"));
                    ct0300mapper.doCopyErpContGI(migi);
                }

            }
        } catch(Exception e) {
            e.printStackTrace();
            rtnCd = "E";
        } finally {
            rtnCd = (rtnCd == null || rtnCd.equals("") || !rtnCd.equals("S")) ? "E" : "S";
        }
        return rtnCd;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecoa0040_doExcept(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {

            int ecdtCnt = ct0300mapper.getEcdtCntByRfxnum(rowData);
            if(ecdtCnt == 0){
                ct0300mapper.doExcept(rowData);
                ct0300mapper.doExceptRqdt(rowData);
                ct0300mapper.doExceptDt(rowData);
            }else{
                throw new Exception(msg.getMessageByScreenId("CT0310","010"));
            }

        }

        return msg.getMessage("0001");
    }

    /**
     * 조회한 서식을 화면에 입력한 데이터로 치환한 후 리턴합니다.
     *
     * @param req
     * @param resp
     * @param paramMap
     * @throws Exception
     */
    public String getFormWithManualContractInfo(EverHttpRequest req, EverHttpResponse resp, Map<String, String> paramMap) throws Exception {

        String resultContractForm = "";
        String contNum   = paramMap.get("contNum");
        String contCnt   = paramMap.get("contCnt");
        String appDocNum = paramMap.get("appDocNum");
        String appDocCnt = paramMap.get("appDocCnt");

        // 화면에서 넘어온 서식 데이터 (입력폼에 입력된 값을 유지하기 위해 화면에서 받아옴)
        String contractForm     = req.getParameter("formContents");
        String isUpdatedFormNum = req.getParameter("isUpdatedFormNum");         // 서식번호가 바뀌었는지 여부
        String selectedFormNum  = req.getParameter("selectedFormNum");          // 화면에서 넘어온 서식번호
        String aparType = "";


        boolean reloadFlag = false;
        if(!StringUtils.isEmpty(req.getParameter("APAR_TYPE"))) {
        	aparType=req.getParameter("APAR_TYPE");
        }
        // 화면에서 받은 서식이 없거나 서식을 변경했으면 DB에서 서식을 조회한다.
        // if(StringUtils.isEmpty(contractForm) || StringUtils.equals(isUpdatedFormNum, "true")) {
        if(StringUtils.isEmpty(contractForm)) {
            if(selectedFormNum != null) {
                Map<String, String> formContents = ct0300mapper.getFormContents(selectedFormNum);
                contractForm = formContents.get("FORM_TEXT");
            }
        }

        resultContractForm = contractForm;

        Map<String, String> vendorInformation = new HashMap<String, String>();
        Map<String, String> buyerInformation  = new HashMap<String, String>();
        if(aparType.equals("S")) {
        	vendorInformation = ct0300mapper.getVendorCustInformation(paramMap);
        	buyerInformation  = ct0300mapper.getBuyerCustInformation(paramMap);

        }else {
        	vendorInformation = ct0300mapper.getVendorInformation(paramMap);
        	buyerInformation  = ct0300mapper.getBuyerInformation(null);

        }

        if ((StringUtils.isNotEmpty(contNum) && StringUtils.isNotEmpty(contCnt)) || StringUtils.isNotEmpty(appDocNum) && StringUtils.isNotEmpty(appDocCnt)) {

            paramMap.put("CONT_NUM", contNum);
            paramMap.put("CONT_CNT", contCnt);
            paramMap.put("APP_DOC_NUM", appDocNum);
            paramMap.put("APP_DOC_CNT", appDocCnt);
            if(StringUtils.isNotEmpty(appDocNum) && StringUtils.isNotEmpty(appDocCnt)) {
                // 결재번호를 받았을 경우, DOC_TYPE에 따라 APP_DOC_NUM 또는 APP_DOC_NUM2를 사용해야 한다.
                paramMap.put("APP_DOC_TYPE", ct0300mapper.getAppDocType(paramMap));
            }

            Map<String, String> contInfo = ct0300mapper.getContractInformation(paramMap);

            String progressCd = contInfo.get("PROGRESS_CD");
            String signStatus = contInfo.get("SIGN_STATUS");
            String signStatus2 = contInfo.get("SIGN_STATUS2");

            // resumeFlag = 'true'이면 변경계약서 작성이므로 진행상태와 결재상태값을 초기화한다.
            if(paramMap.get("resumeFlag").equals("true")) {
                progressCd = Code.CONT_TEMP_SAVE;
                contInfo.put("PROGRESS_CD", progressCd);
                signStatus = Code.M020_T;
                contInfo.put("SIGN_STATUS", signStatus);
                signStatus2 = Code.M020_T;
                contInfo.put("SIGN_STATUS2", signStatus2);
            }

            if (Code.CONT_TEMP_SAVE.equals(progressCd)) {
                contractForm = contInfo.get("ORI_CONTRACT_TEXT");
            } else {
                contractForm = contInfo.get("CONTRACT_TEXT");
            }

            // 수정불가상태
            if( !(progressCd.equals("") || progressCd.equals(Code.CONT_TEMP_SAVE) || progressCd.equals(Code.CONT_SUPPLY_REJECT)
                || (progressCd.equals(Code.M135_4203) && (StringUtils.equals(signStatus, Code.M020_R) || StringUtils.equals(signStatus, Code.M020_C)))
                || (progressCd.equals(Code.M135_4240) && (StringUtils.equals(signStatus2, Code.M020_R) || StringUtils.equals(signStatus2, Code.M020_C)))
                )) {
                resultContractForm = ContStringUtil.getHtmlContents(contractForm, true);
            } else {
                resultContractForm = contractForm;
            }
            contInfo.put("formContents", resultContractForm);
            contInfo.put("oriFormContents", contInfo.get("ORI_CONTRACT_TEXT"));
            paramMap.putAll(contInfo);
        }
        else {
        	Map<String, String> cnvdData = ct0300mapper.getCndtCnvdInfo(paramMap);
        	if (cnvdData!=null) {
                paramMap.putAll(cnvdData);
        	}
    		paramMap.put("SHIPPER_TYPE",req.getParameter("SHIPPER_TYPE"));
        }

        if(resultContractForm != null) {
            resultContractForm = getReplacedContentsWithInformation(resultContractForm, buyerInformation, vendorInformation, paramMap);
            resultContractForm = resultContractForm.replaceAll("&#37[;]", "%");
            resultContractForm = resultContractForm.replaceAll("&#39[;]", "'");
        }

        paramMap.put("formContents", resultContractForm);
        paramMap.put("oriFormContents", resultContractForm);

        // resumeFlag = 'true'이면 변경계약서 작성이므로 해당 차수의 계약내용을 보여준 후, 차수를 MAX + 1 한다.
        if(paramMap.get("resumeFlag").equals("true")) {
            paramMap.put("NEW_CONT_CNT", ct0300mapper.getMaxContCnt(paramMap.get("CONT_NUM")));
            paramMap.remove("M_ATT_FILE_NUM");
            paramMap.remove("ATT_FILE_NUM");
            paramMap.remove("CONT_ATT_FILE_NUM");
            paramMap.remove("ADV_ATT_FILE_NUM");
            paramMap.remove("WARR_ATT_FILE_NUM");
        }

        if(StringUtils.isEmpty(contNum)) {
        	if (vendorInformation!=null) {
            	paramMap.put("VENDOR_PIC_USER_NM", vendorInformation.get("VENDOR_PIC_USER_NM"));
            	paramMap.put("VENDOR_PIC_USER_EMAIL", vendorInformation.get("VENDOR_PIC_EMAIL"));
            	paramMap.put("VENDOR_PIC_CELL_NUM", vendorInformation.get("VENDOR_PIC_CELL_NUM"));
            	paramMap.put("VENDOR_NM", vendorInformation.get("VENDOR_NM"));
            	paramMap.put("VENDOR_CD", vendorInformation.get("VENDOR_CD"));
            	paramMap.put("BELONG_DIVISION_NM", vendorInformation.get("BELONG_DIVISION_NM"));
            	paramMap.put("BELONG_DIVISION_CD", vendorInformation.get("BELONG_DIVISION_CD"));
            	paramMap.put("BELONG_DEPT_NM", vendorInformation.get("BELONG_DEPT_NM"));
            	paramMap.put("BELONG_DEPT_CD", vendorInformation.get("BELONG_DEPT_CD"));
        	}

        	if("C".equals(paramMap.get("openFormType"))) {
        		paramMap.put("VENDOR_TEST_REQ_YN","0");
        		paramMap.put("VENDOR_EDIT_FLAG","1");
        	}
        }

        req.setAttribute("form", paramMap);
        return resultContractForm;
    }

    public Map<String, String> getFormContractInfoForERP(EverHttpRequest req, EverHttpResponse resp, Map<String, String> paramMap) throws Exception {

        String resultContractForm = "";
        Map<String, String> contInfo = new HashMap<String, String>();
        String contNum = paramMap.get("contNum");
        String contCnt = paramMap.get("contCnt");

        // 화면에서 넘어온 서식 데이터 (입력폼에 입력된 값을 유지하기 위해 화면에서 받아옴)
        String contractForm = req.getParameter("formContents");
        String isUpdatedFormNum = req.getParameter("isUpdatedFormNum");         // 서식번호가 바뀌었는지 여부
        String selectedFormNum = req.getParameter("selectedFormNum");           // 화면에서 넘어온 서식번호

        // 화면에서 받은 서식이 없거나 서식을 변경했으면 DB에서 서식을 조회한다.
        if(StringUtils.isEmpty(contractForm) || StringUtils.equals(isUpdatedFormNum, "true")) {
            if(selectedFormNum != null) {
                Map<String, String> formContents = ct0300mapper.getFormContents(selectedFormNum);
                contractForm = formContents.get("FORM_TEXT");
            }
        }

        if ((StringUtils.isNotEmpty(contNum) && StringUtils.isNotEmpty(contCnt))) {

            paramMap.put("CONT_NUM", contNum);
            paramMap.put("CONT_CNT", contCnt);

            contInfo = ct0300mapper.getContractInformation(paramMap);
            contInfo.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
            contInfo.put("formContents", contInfo.get("CONTRACT_TEXT"));
            contInfo.put("oriFormContents", contInfo.get("ORI_CONTRACT_TEXT"));
            contInfo.put("APP_DOC_NUM", null);
            contInfo.put("APP_DOC_CNT", null);
            contInfo.put("SIGN_STATUS", null);
            contInfo.put("APP_DOC_NUM2", null);
            contInfo.put("APP_DOC_CNT2", null);
            contInfo.put("SIGN_STATUS2", null);
            contInfo.put("CONT_GUAR_TYPE", null);
            contInfo.put("CONT_GUAR_TYPE_LOC", null);
            contInfo.put("CONT_GUAR_PERCENT", null);
            contInfo.put("CONT_GUAR_AMT", null);
            contInfo.put("CONT_VAT_TYPE", null);
            contInfo.put("CONT_VAT_TYPE_LOC", null);
            contInfo.put("ADV_GUAR_TYPE", null);
            contInfo.put("ADV_GUAR_TYPE_LOC", null);
            contInfo.put("ADV_GUAR_PERCENT", null);
            contInfo.put("ADV_GUAR_AMT", null);
            contInfo.put("ADV_VAT_TYPE", null);
            contInfo.put("ADV_VAT_TYPE_LOC", null);
            contInfo.put("WARR_GUAR_TYPE", null);
            contInfo.put("WARR_GUAR_TYPE_LOC", null);
            contInfo.put("WARR_GUAR_PERCENT", null);
            contInfo.put("WARR_GUAR_AMT", null);
            contInfo.put("WARR_VAT_TYPE", null);
            contInfo.put("WARR_VAT_TYPE_LOC", null);

            contInfo.put("SHIPPER_TYPE", req.getParameter("SHIPPER_TYPE"));
//            contInfo.put("LOC_BUYER_CD", req.getParameter("LOC_BUYER_CD"));
            contInfo.put("EXEC_NUM", req.getParameter("EXEC_NUM"));
            contInfo.put("EXEC_CNT", req.getParameter("EXEC_CNT"));
        }

        // 변경계약서 작성이므로 해당 차수의 계약내용을 보여준 후, 차수를 MAX + 1 한다.
        contInfo.put("NEW_CONT_CNT", ct0300mapper.getMaxContCnt(paramMap.get("CONT_NUM")));
        contInfo.put("resumeFlag", "true"); // 변경계약여부
        return contInfo;
    }

    public Map<String, String> getFormDataFromERP(EverHttpRequest req) throws Exception {

        Map<String, String> formDataFromERP = new HashMap<String,String>();

    	formDataFromERP.put("PROGRESS_CD", null);
        formDataFromERP.put("SIGN_STATUS", null);
        formDataFromERP.put("SIGN_STATUS2", null);
        return formDataFromERP;
    }


    public List<Map<String, Object>> doSearchContItem(Map<String, String> param) {
    	List<Map<String, Object>>  contItem = null;

    	if(param.get("EXEC_NUM")!=null && !"".equals(param.get("EXEC_NUM"))) {
        	contItem = ct0300mapper.doSearchRfqItem(param);
    	} else if(param.get("PR_NUM_SQ")!=null && !"".equals(param.get("PR_NUM_SQ"))) {

            Map<String, Object> paramObj = (Map) param;
            if(EverString.isNotEmpty(param.get("PR_NUM_SQ"))) {
                paramObj.put("PR_NUM_SQ_LIST", Arrays.asList(param.get("PR_NUM_SQ").split(",")));
            }
        	contItem = ct0300mapper.doSearchPrItem(paramObj);
    	} else {
        	contItem = ct0300mapper.doSearchContItem(param);
    	}

    	return contItem;
    }


    public List<Map<String, Object>> doSearchEcpy(Map<String, String> param) {
    	List<Map<String, Object>>  contItem = null;

    	if(param.get("EXEC_NUM")!=null && !"".equals(param.get("EXEC_NUM"))) {
        	contItem = ct0300mapper.getCndtCnpyList(param);
    	} else if(param.get("PR_NUM_SQ")!=null && !"".equals(param.get("PR_NUM_SQ"))) {

            Map<String, Object> paramObj = (Map) param;
            if(EverString.isNotEmpty(param.get("PR_NUM_SQ"))) {
                paramObj.put("PR_NUM_SQ_LIST", Arrays.asList(param.get("PR_NUM_SQ").split(",")));
            }
        	contItem = ct0300mapper.doSearchPrItem(paramObj);
    	} else {
        	contItem = ct0300mapper.ecob0050_doSearchPayInfo(param);
    	}

    	return contItem;
    }

    public List<Map<String, Object>> doSearchAdditionalForm(Map<String, String> param) {

        String appDocNum = EverString.nullToEmptyString(param.get("appDocNum"));
        String appDocCnt = EverString.nullToEmptyString(param.get("appDocCnt"));
        if (StringUtils.isNotEmpty(appDocNum) && StringUtils.isNotEmpty(appDocCnt)) {
            param.put("APP_DOC_NUM", appDocNum);
            param.put("APP_DOC_CNT", appDocCnt);
            // 결재번호를 받았을 경우, DOC_TYPE에 따라 APP_DOC_NUM 또는 APP_DOC_NUM2를 사용해야 한다.
            param.put("APP_DOC_TYPE", ct0300mapper.getAppDocType(param));
        } else {
            param.put("APP_DOC_NUM", null);
            param.put("APP_DOC_CNT", null);
        }

        Map<String, String> contractInformation = ct0300mapper.getContractInformation(param);
        List<Map<String, Object>> additionalFormList = ct0300mapper.doSearchAdditionalForm(param);

        for (Map<String, Object> map : additionalFormList) {

            String contents = String.valueOf(map.get("CONTRACT_TEXT"));
            Map<String, String> dataMap = this.getBaseDataForm();
            dataMap.putAll(param);

            String progressCd = contractInformation.get("PROGRESS_CD");
            String sign_status = contractInformation.get("SIGN_STATUS");
            String sign_status2 = contractInformation.get("SIGN_STATUS2");

            // resumeFlag = 'true'이면 변경계약서 작성이므로 진행상태와 결재상태값을 초기화한다.
            if(param.get("resumeFlag").equals("true")) {
                progressCd = Code.CONT_TEMP_SAVE;
                contractInformation.put("PROGRESS_CD", progressCd);
                sign_status = Code.M020_T;
                contractInformation.put("SIGN_STATUS", sign_status);
                sign_status2 = Code.M020_T;
                contractInformation.put("SIGN_STATUS2", sign_status2);
            }

            if( !(progressCd.equals("") || progressCd.equals(Code.CONT_TEMP_SAVE) || progressCd.equals(Code.CONT_SUPPLY_REJECT)
            	  || (progressCd.equals(Code.M135_4203) && (sign_status.equals(Code.M020_R) || sign_status.equals(Code.M020_C)))
            	  || (progressCd.equals(Code.M135_4240) && (sign_status2.equals(Code.M020_R) || sign_status2.equals(Code.M020_C)))
            )) {
                contents = ContStringUtil.getHtmlContents(contents, true);
            } else {
                // 파트너사에서 반려를 했을 경우, 다시 부서식을 수정해야 하기 때문에 원본 서식을 불러온다.
                // contents = String.valueOf(map.get("ORI_CONTRACT_TEXT"));
                contents = ContStringUtil.getHtmlContents(String.valueOf(map.get("ORI_CONTRACT_TEXT")), false);
            }

            map.put("ADDITIONAL_CONTENTS", contents);
        }
        return additionalFormList;
    }

    public List<Map<String, Object>> doSearchAdditionalFormForERP(Map<String, String> param) {

        List<Map<String, Object>> additionalFormList = ct0300mapper.doSearchAdditionalForm(param);

        for (Map<String, Object> map : additionalFormList) {
            String contents = String.valueOf(map.get("CONTRACT_TEXT")); // Contract form no.
            contents = ContStringUtil.getHtmlContents(contents, true);
            map.put("ADDITIONAL_CONTENTS", contents);
        }
        return additionalFormList;
    }

    private Map<String, String> getBaseDataForm() {

        Map<String, String> dataFormMap = new HashMap<String, String>();
        dataFormMap.put("CONT_USER_ID", UserInfoManager.getUserInfo().getUserId());
        dataFormMap.put("CONT_USER_NM", UserInfoManager.getUserInfo().getUserNm());
        dataFormMap.put("BUYER_CD", UserInfoManager.getUserInfo().getCompanyCd());
        dataFormMap.put("BUYER_NM", UserInfoManager.getUserInfo().getCompanyNm());
        dataFormMap.put("CONT_DATE", EverDate.getDate());

        return dataFormMap;
    }

    /**
     * 계약서 서식을 넘겨받은 정보로 내용을 치환하여 리턴
     *
     * @param contents          대상데이터(서식)
     * @param buyerInformation  조회한 구매사 정보
     * @param vendorInformation 조회한 협력회사 정보
     * @param formData          화면의 입력폼
     * @return
     * @throws ParseException
     * @throws UserInfoNotFoundException
     */
    public String getReplacedContentsWithInformation(String contents, Map<String, String> buyerInformation, Map<String, String> vendorInformation, Map<String, String> formData) throws ParseException {

        Source source = new Source(contents.replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
        OutputDocument outputDocument = new OutputDocument(source);
        System.out.println("adssadasdsa");
        List<FormControl> formControls = source.getFormControls();
        for (FormControl formControl : formControls) {

            String name = formControl.getName();
            if (EverString.isNotEmpty(name)) {

                /* 서식선택 팝업에서 입력한 정보들과 동일한 이름들이 있는 지 체크 후 치환 */
                if (formData.containsKey(name)) {
                    formControl.setValue(EverString.defaultIfEmpty(String.valueOf(formData.get(name)), ""));
                    ContStringUtil.makeupFormValue(formControl);
                }


                if (name.equals("SUPPLY_AMT_KR")) {
                    if(formData.get("SUPPLY_AMT") != null && !"".equals(String.valueOf(formData.get("SUPPLY_AMT"))) && !"null".equals(String.valueOf(formData.get("SUPPLY_AMT")))) {
                        formControl.setValue(ContStringUtil.numberToKorean(String.valueOf(formData.get("SUPPLY_AMT"))));
                    }
                }
                if (name.equals("VAT_AMT_KR")) {
                    if(formData.get("VAT_AMT") != null && !"".equals(String.valueOf(formData.get("VAT_AMT"))) && !"null".equals(String.valueOf(formData.get("VAT_AMT")))) {
                        formControl.setValue(ContStringUtil.numberToKorean(String.valueOf(formData.get("VAT_AMT"))));
                    }
                }
                if (name.equals("VAT_TYPE_KR")) {
                	String vatTypeKr = "";
                	if("0".equals(formData.get("VAT_TYPE"))) {
                		vatTypeKr = "부가세 별도";
                	}
                	if("1".equals(formData.get("VAT_TYPE"))) {
                		vatTypeKr = "부가세 포함";
                	}
                	if("2".equals(formData.get("VAT_TYPE"))) {
                		vatTypeKr = "비과세";
                	}
                    formControl.setValue(vatTypeKr);
                }

                /* 계약금액(한글)일 경우 한글로 숫자를 표기하도록 치환 */
                if (name.equals("CONT_AMT_KR")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {
                        formControl.setValue(ContStringUtil.numberToKorean(String.valueOf(formData.get("CONT_AMT"))));
                    }
                }

                if (name.equals("CONT_AMT_KR")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {
                        formControl.setValue(ContStringUtil.numberToKorean(String.valueOf(formData.get("CONT_AMT"))));
                    }
                }

                if (name.equals("CONT_AMT_KR")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {
                        formControl.setValue(ContStringUtil.numberToKorean(String.valueOf(formData.get("CONT_AMT"))));
                    }
                }

                if (name.equals("CONT_AMT_KR_VAT")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("VAT_TYPE"));
                        String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                        BigDecimal contAmtBD = new BigDecimal(String.valueOf(formData.get("CONT_AMT")));
                        String contAmt = contAmtBD.toString().replace(".00", "");

                        formControl.setValue("金 " + ContStringUtil.numberToKorean(contAmt) + "원整(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###") + "), " + vatTypeLoc);
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("CONT_AMT_KR_NUM")) {
                    if(formData.get("CONT_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_AMT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("VAT_TYPE"));
                        String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                        String contAmt = String.valueOf(formData.get("CONT_AMT"));
                        formControl.setValue("금 " + ContStringUtil.numberToKorean(contAmt) + "원정(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###") + "), " + vatTypeLoc);
                    } else { formControl.setValue(""); }
                }
                if (name.equals("VAT_AMT_KR_NUM")) {
                    if(formData.get("VAT_AMT") != null && !"0".equals(String.valueOf(formData.get("VAT_AMT"))) && !"".equals(String.valueOf(formData.get("VAT_AMT"))) && !"null".equals(String.valueOf(formData.get("VAT_AMT")))) {
                        BigDecimal vatAmtBD = new BigDecimal(String.valueOf(formData.get("VAT_AMT")));
                        String vatAmt = vatAmtBD.toString().replace(".00", "").replace(".0", "");
                        formControl.setValue("금 " + ContStringUtil.numberToKorean(vatAmt) + "원정(￦" + EverMath.EverNumberType(String.valueOf(formData.get("VAT_AMT")), "###,###") + ")");
                    } else { formControl.setValue(""); }
                }
                if (name.equals("CONT_VAT_KR")) {
                    if(formData.get("VAT_TYPE") != null && !"".equals(String.valueOf(formData.get("VAT_TYPE"))) && !"null".equals(String.valueOf(formData.get("VAT_TYPE")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("VAT_TYPE"));
                        String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        formControl.setValue(vatTypeLoc);
                    } else {
                        formControl.setValue("");
                    }
                }

                /* 계약보증(한글)일 경우 한글로 숫자를 표기하도록 치환 */
                if (name.equals("TOT_GUAR_AMT_KR_VAT")) {
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M100");
                        cParam.put("CODE", formData.get("CONT_VAT_TYPE"));
                        String contVatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                        BigDecimal contGuarAmtBD = new BigDecimal(String.valueOf(formData.get("CONT_GUAR_AMT")));
                        String contGuarAmt = contGuarAmtBD.toString().replace(".00", "");
                        formControl.setValue("金 " + ContStringUtil.numberToKorean(contGuarAmt) + "원整(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + "), " + contVatTypeLoc);
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("ADV_GUAR_AMT_INFO")) {
                    if(formData.get("ADV_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("ADV_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("ADV_GUAR_AMT")))
                            && formData.get("ADV_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("ADV_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("ADV_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("ADV_GUAR_PERCENT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M217");
                        cParam.put("CODE", formData.get("ADV_GUAR_TYPE"));
                        String advGuarTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        if(EverString.nullToEmptyString(formData.get("ADV_GUAR_TYPE")).equals("") || EverString.nullToEmptyString(formData.get("ADV_GUAR_TYPE")).equals("EX")) {
                            advGuarTypeLoc = "해당사항 없음";
                        }

                        formControl.setValue("금 " + EverMath.EverNumberType(String.valueOf(formData.get("ADV_GUAR_AMT")), "###,###") + "원정(" + advGuarTypeLoc + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("CONT_GUAR_AMT_INFO")) {
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))
                            && formData.get("CONT_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_PERCENT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M217");
                        cParam.put("CODE", formData.get("CONT_GUAR_TYPE"));
                        String contGuarTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        if(EverString.nullToEmptyString(formData.get("CONT_GUAR_TYPE")).equals("") || EverString.nullToEmptyString(formData.get("CONT_GUAR_TYPE")).equals("EX")) {
                            contGuarTypeLoc = "해당사항 없음";
                        }

                        formControl.setValue("금 " + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + "원정(" + contGuarTypeLoc + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("CONT_GUAR_AMT_KR")) {
                    if(formData.get("CONT_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {
                        String contGuarAmt = String.valueOf(formData.get("CONT_GUAR_AMT"));
                        formControl.setValue("금 " + ContStringUtil.numberToKorean(contGuarAmt) + "원정(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("WARR_GUAR_AMT_INFO")) {
                    if(formData.get("WARR_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_AMT")))
                            && formData.get("WARR_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT")))) {

                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M217");
                        cParam.put("CODE", formData.get("WARR_GUAR_TYPE"));
                        String warrGuarTypeLoc = ct0300mapper.getCodeDesc(cParam);
                        if(EverString.nullToEmptyString(formData.get("WARR_GUAR_TYPE")).equals("") || EverString.nullToEmptyString(formData.get("WARR_GUAR_TYPE")).equals("EX")) {
                            warrGuarTypeLoc = "해당사항 없음";
                        }

                        formControl.setValue("금 " + EverMath.EverNumberType(String.valueOf(formData.get("WARR_GUAR_AMT")), "###,###") + "원정(" + warrGuarTypeLoc + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("WARR_GUAR_AMT_KR")) {
                    if(formData.get("WARR_GUAR_AMT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_AMT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_AMT")))) {
                        String warrGuarAmt = String.valueOf(formData.get("WARR_GUAR_AMT"));
                        formControl.setValue("금 " + ContStringUtil.numberToKorean(warrGuarAmt) + "원정(￦" + EverMath.EverNumberType(String.valueOf(formData.get("WARR_GUAR_AMT")), "###,###") + ")");
                    } else { formControl.setValue("해당사항 없음"); }
                }
                if (name.equals("WARR_GUAR_PERCENT_INFO")) {
                    if(formData.get("WARR_GUAR_PERCENT") != null && !"".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"null".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT"))) && !"0".equals(String.valueOf(formData.get("WARR_GUAR_PERCENT")))) {
                        formControl.setValue("계약금액의 (" + EverMath.EverNumberType(String.valueOf(formData.get("WARR_GUAR_PERCENT")), "###,###.###") + ")％");
                    } else { formControl.setValue("해당사항 없음"); }
                }

                /* 지연 배상금 률을 표기하도록 치환 */
                if (name.equals("DELAY_INFO")) {
                    if(formData.get("DELAY_RMK") != null && !String.valueOf(formData.get("DELAY_RMK")).equals("") && formData.get("DELAY_DENO_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_DENO_RATE"))) && formData.get("DELAY_NUME_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_NUME_RATE")))) {
                        formControl.setValue(formData.get("DELAY_RMK") + " " + EverMath.EverNumberType(String.valueOf(formData.get("DELAY_DENO_RATE")), "###,###") + "분의 " + EverMath.EverNumberType(String.valueOf(formData.get("DELAY_NUME_RATE")), "###,###.##"));
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("DELAY_RATE_INFO")) {
                    if(formData.get("DELAY_NUME_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_NUME_RATE"))) && formData.get("DELAY_DENO_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_DENO_RATE"))) && !"0".equals(String.valueOf(formData.get("DELAY_DENO_RATE")))) {
                        BigDecimal delayNumeRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_NUME_RATE")));
                        String delayNumeRate = delayNumeRateBD.toString().replace(".00", "");
                        BigDecimal delayDenoRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_DENO_RATE")));
                        String delayDenoRate = delayDenoRateBD.toString().replace(".00", "");
                        formControl.setValue(formData.get("DELAY_RMK") + " " + EverMath.EverNumberType(delayNumeRate, "###,###.##") + " / " + EverMath.EverNumberType(delayDenoRate, "###,###.##"));
                    } else {
                        formControl.setValue("");
                    }
                }
                if (name.equals("DELAY_RATE_CAL")) {
                    if(formData.get("DELAY_NUME_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_NUME_RATE"))) && formData.get("DELAY_DENO_RATE") != null && !"".equals(String.valueOf(formData.get("DELAY_DENO_RATE")))) {
                        BigDecimal delayNumeRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_NUME_RATE")));
                        double delayNumeRate = Double.parseDouble(delayNumeRateBD.toString().replace(".00", ""));
                        BigDecimal delayDenoRateBD = new BigDecimal(String.valueOf(formData.get("DELAY_DENO_RATE")));
                        double delayDenoRate = Double.parseDouble(delayDenoRateBD.toString().replace(".00", ""));
                        double calDelayRate = delayNumeRate / delayDenoRate;
                        formControl.setValue(EverMath.EverNumberType(String.valueOf(calDelayRate), "###,###.####"));
                    } else {
                        formControl.setValue("");
                    }
                }

                /* 대금지급조건을 표기하도록 치환 */
                if (name.equals("PAY_METHOD")) {
                    if(formData.get("PAY_METHOD") != null && !String.valueOf(formData.get("PAY_METHOD")).equals("")) {
                        Map<String, String> cParam = new HashMap<String, String>();
                        cParam.put("CODE_TYPE", "M018");
                        cParam.put("CODE", formData.get("PAY_METHOD"));
                        String payMethodLoc = ct0300mapper.getCodeDesc(cParam);
                        formControl.setValue(payMethodLoc);
                    } else {
                        formControl.setValue("");
                    }
                }

                /* 계약이행보증증권의 내용을 표기하도록 치환 */
                if (name.equals("CONT_GUAR_TYPE")) {
                    if(formData.get("CONT_GUAR_AMT") == null || "".equals(String.valueOf(formData.get("CONT_GUAR_AMT"))) || "0".equals(String.valueOf(formData.get("CONT_GUAR_AMT")))) {
                        formControl.setValue("");
                    } else {
                        if (formData.get("CONT_GUAR_TYPE") != null && !String.valueOf(formData.get("CONT_GUAR_TYPE")).equals("")) {
                            Map<String, String> cParam = new HashMap<String, String>();
                            cParam.put("CODE_TYPE", "M217");
                            cParam.put("CODE", formData.get("CONT_GUAR_TYPE"));
                            String contGuarType = ct0300mapper.getCodeDesc(cParam);
                            formControl.setValue(contGuarType);
                        } else {
                            formControl.setValue("");
                        }
                    }
                }

                /* 구매사 정보와 동일한 이름이 있으면 치환 */
                if (buyerInformation != null) {
                    if (buyerInformation.containsKey(name)) {
                        formControl.setValue(EverString.defaultIfEmpty(buyerInformation.get(name), ""));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }
                if (vendorInformation != null) {
                    if (vendorInformation.containsKey(name)) {
                        formControl.setValue(EverString.defaultIfEmpty(vendorInformation.get(name), ""));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }
                if (name.equals("CONT_LAST_DAYS")) {
                    if(StringUtils.isNotEmpty(formData.get("CONT_START_DATE")) && StringUtils.isNotEmpty(formData.get("CONT_END_DATE"))) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                        Date contStartDate = sdf.parse(formData.get("CONT_START_DATE"));
                        Date contEndDate = sdf.parse(formData.get("CONT_END_DATE"));
                        formControl.setValue(ContStringUtil.toPositionalNumber(String.valueOf(Days.daysBetween(new LocalDate(contStartDate), new LocalDate(contEndDate)).getDays()+1 )));
                        ContStringUtil.makeupFormValue(formControl);
                    }
                }
            }
            /* 각각의 formControl에 setValue() 한 결과가 적용되기 위한 필수코드입니다. */
            outputDocument.replace(formControl);
        }
        return outputDocument.toString();
    }

    /**
     * 계약서 저장
     *
     * @param formData
     * @param gridDataM
     * @param gridDataA
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> doSaveContract(Map<String, String> formData, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridItem, List<Map<String, Object>> gridDataP) throws Exception {

        String preProgressCd = EverString.nullToEmptyString(formData.get("PROGRESS_CD"));

        formData.put("PRE_PROGRESS_CD", preProgressCd);
        formData.put("FORM_NUM", (String) gridDataM.get(0).get("FORM_NUM"));

        formData.put("CONTRACT_FORM_TYPE", String.valueOf(gridDataM.get(0).get("CONTRACT_FORM_TYPE")));


        String deptFlag = (String) gridDataM.get(0).get("DEPT_FLAG"); // 주소속부서지정유무 (이 값이 1(Y)이면 form의 부서코드값을 넣어주고, 0(N)이면 세션의 부서코드를 넣어준다.
        boolean legalTeamFlag = StringUtils.equals((String) gridDataM.get(0).get("EXAM_FLAG"), "1"); // 법무팀 검토 여부
        boolean approvalFlag = StringUtils.equals((String) gridDataM.get(0).get("APPROVAL_FLAG"), "1"); // 체결기안 여부

//        // 주소속부서지정이 Y가 아니면 세션의 부서코드를 넣어준다.
//        if (!StringUtils.equals(deptFlag, Code.M008_1)) {
//            UserInfo userInfo = UserInfoManager.getUserInfo();
//            formData.put("BELONG_DEPT_CD", userInfo.getDeptCd());
//        }

        if (StringUtils.isEmpty(formData.get("CONT_NUM")) && StringUtils.isEmpty(formData.get("CONT_CNT"))) {

            // 계약번호가 없으면 저장이 안된 상태이므로 INSERT 처리
            formData.put("CONT_NUM", docNumService.getDocNumber("EC"));
            formData.put("CONT_CNT", "1");
            formData.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
            formData.put("CONT_DEPT_CD", UserInfoManager.getUserInfo().getDeptCd());
            formData.put("PAY_METHOD", formData.get("PAY_METHOD"));
            ct0300mapper.doInsertECCT(formData);

            formData.put("FORM_SQ", MAIN_FORM_SQ);

            // ntext 컬럼으로 변경 ('18.4.10) -> 일괄계약 시 퍼포먼스 저하되기 때문
            String mainContractContents = ContStringUtil.replaceUserNotEditableForms(formData.get("mainContractContents").replaceAll("&quot;", "\"").replaceAll("&#37;", "%"), formData);
            formData.put("CONTRACT_TEXT", mainContractContents);
            formData.put("ORI_CONTRACT_TEXT", ContStringUtil.replaceUserNotEditableForms(formData.get("oriMainContractContents").replaceAll("&quot;", "\"").replaceAll("&#37;", "%"), formData));
            ct0300mapper.doInsertECRL(formData);

        } else {

            // 변경계약서 작성이므로 INSERT 처리
            if (StringUtils.isNotEmpty(formData.get("NEW_CONT_CNT"))) {

            	formData.put("OLD_CONT_CNT", formData.get("CONT_CNT"));
                formData.put("CONT_CNT", formData.get("NEW_CONT_CNT"));
                formData.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
                formData.put("CONT_DEPT_CD", UserInfoManager.getUserInfo().getDeptCd());
                //기존품의 delflag 숨김처리
                ct0300mapper.oldContDelChange(formData);
                ct0300mapper.doInsertECCT(formData);

                formData.put("FORM_SQ", MAIN_FORM_SQ);

                // ntext 컬럼으로 변경 ('18.4.10) -> 일괄계약 시 퍼포먼스 저하되기 때문
                String mainContractContents = ContStringUtil.replaceUserNotEditableForms(formData.get("mainContractContents").replaceAll("&quot;", "\"").replaceAll("&#37;", "%"), formData);
                formData.put("CONTRACT_TEXT", mainContractContents);
                formData.put("ORI_CONTRACT_TEXT", ContStringUtil.replaceUserNotEditableForms(formData.get("oriMainContractContents").replaceAll("&quot;", "\"").replaceAll("&#37;", "%"), formData));
                ct0300mapper.doInsertECRL(formData);

            } else {

            	formData.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
            	formData.put("PAY_METHOD", formData.get("PAY_METHOD"));
                ct0300mapper.doUpdateECCT(formData);

                formData.put("FORM_SQ", MAIN_FORM_SQ);

                // ntext 컬럼으로 변경 ('18.4.10) -> 일괄계약 시 퍼포먼스 저하되기 때문
                String mainContractContents = ContStringUtil.replaceUserNotEditableForms(formData.get("mainContractContents").replaceAll("&quot;", "\"").replaceAll("&#37;", "%"), formData);
                String oriContractContents  = ContStringUtil.replaceUserNotEditableForms(formData.get("oriMainContractContents").replaceAll("&quot;", "\"").replaceAll("&#37;", "%"), formData);

                formData.put("CONTRACT_TEXT",     mainContractContents);
                formData.put("ORI_CONTRACT_TEXT", oriContractContents);

            	ct0300mapper.doUpdateECRL(formData);

                // 주계약서를 제외한 부서식은 저장 후에 선택을 뺄 수도 있으므로 기존 데이터를 삭제하고 다시 넣는다.
                ct0300mapper.doDeleteAddECRL(formData);
            }
        }

        // 부서식 저장
        for (int i = 0; i < gridDataA.size(); i++) {

            Map<String, Object> datum = gridDataA.get(i);
            datum.put("CONT_NUM", formData.get("CONT_NUM"));
            datum.put("CONT_CNT", formData.get("CONT_CNT"));
            datum.put("FORM_SQ", datum.get("REL_FORM_SQ"));

            // ntext 컬럼으로 변경 ('18.4.10) -> 일괄계약 시 퍼포먼스 저하되기 때문
            String formContents = (String)datum.get("FORM_CONTENTS");

            Source source = new Source(formContents.replaceAll("&lt;", "<").replaceAll("&gt;", ">"));
            OutputDocument outputDocument = new OutputDocument(source);

            List<FormControl> formControls = source.getFormControls();
            for (FormControl formControl : formControls) {

                String name = formControl.getName();
                if (EverString.isNotEmpty(name)) {

                    /* 서식선택 팝업에서 입력한 정보들과 동일한 이름들이 있는 지 체크 후 치환 */
                    if (formData.containsKey(name)) {
                        if(!name.equals("PAY_RMK")) {
                            formControl.setValue(EverString.defaultIfEmpty(String.valueOf(formData.get(name)), ""));
                            ContStringUtil.makeupFormValue(formControl);
                        }
                    }

                    /* SI용역 구매계약 특수사항의 계약금 정보 치환 */
                    if (name.equals("SI_CONT_AMT_NUM")) {
                        if(formData.get("CONT_AMT") != null && !String.valueOf(formData.get("CONT_AMT")).equals("")) {
                            formControl.setValue(EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###"));
                        } else {
                            formControl.setValue("");
                        }
                    }
                    if (name.equals("SI_CONT_AMT_VAT")) {
                        if(formData.get("VAT_TYPE") != null && !String.valueOf(formData.get("VAT_TYPE")).equals("")) {
                            Map<String, String> cParam = new HashMap<String, String>();
                            cParam.put("CODE_TYPE", "M100");
                            cParam.put("CODE", formData.get("VAT_TYPE"));
                            String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);
                            formControl.setValue(vatTypeLoc);
                        } else {
                            formControl.setValue("");
                        }
                    }

                    /* 계약금액(한글)일 경우 한글로 숫자를 표기하도록 치환 */
                    if (name.equals("CONT_AMT_KR")) {
                        if(StringUtils.isNotEmpty(formData.get("CONT_AMT"))) {
                            formControl.setValue(ContStringUtil.numberToKorean(String.valueOf(formData.get("CONT_AMT"))));
                        }
                    }
                    if (name.equals("CONT_AMT_KR_VAT")) {
                        if(formData.get("CONT_AMT") != null && !String.valueOf(formData.get("CONT_AMT")).equals("")) {

                            Map<String, String> cParam = new HashMap<String, String>();
                            cParam.put("CODE_TYPE", "M100");
                            cParam.put("CODE", formData.get("VAT_TYPE"));
                            String vatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                            BigDecimal contAmtBD = new BigDecimal(String.valueOf(formData.get("CONT_AMT")));
                            String contAmt = contAmtBD.toString().replace(".00", "");
                            formControl.setValue("金 " + ContStringUtil.numberToKorean(contAmt) + "원整(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_AMT")), "###,###") + "), " + vatTypeLoc);
                        } else {
                            formControl.setValue("");
                        }
                    }

                    /* 계약보증(한글)일 경우 한글로 숫자를 표기하도록 치환 */
                    if (name.equals("TOT_GUAR_AMT_KR_VAT")) {
                        if(formData.get("CONT_GUAR_AMT") != null && !String.valueOf(formData.get("CONT_GUAR_AMT")).equals("") && !String.valueOf(formData.get("CONT_GUAR_AMT")).equals("0")) {

                            Map<String, String> cParam = new HashMap<String, String>();
                            cParam.put("CODE_TYPE", "M100");
                            cParam.put("CODE", formData.get("CONT_VAT_TYPE"));
                            String contVatTypeLoc = ct0300mapper.getCodeDesc(cParam);

                            BigDecimal contGuarAmtBD = new BigDecimal(String.valueOf(formData.get("CONT_GUAR_AMT")));
                            String contGuarAmt = contGuarAmtBD.toString().replace(".00", "");
                            formControl.setValue("金 " + ContStringUtil.numberToKorean(contGuarAmt) + "원整(￦" + EverMath.EverNumberType(String.valueOf(formData.get("CONT_GUAR_AMT")), "###,###") + "), " + contVatTypeLoc);
                        } else {
                            formControl.setValue("");
                        }
                    }

                    /* 지연 배상금 률을 표기하도록 치환 */
                    if (name.equals("DELAY_INFO")) {
                        if(formData.get("DELAY_RMK") != null && !String.valueOf(formData.get("DELAY_RMK")).equals("") && formData.get("DELAY_DENO_RATE") != null && !String.valueOf(formData.get("DELAY_DENO_RATE")).equals("") && formData.get("DELAY_NUME_RATE") != null && !String.valueOf(formData.get("DELAY_NUME_RATE")).equals("")) {
                            formControl.setValue(formData.get("DELAY_RMK") + " " + EverMath.EverNumberType(String.valueOf(formData.get("DELAY_DENO_RATE")), "###,###") + "분의 " + EverMath.EverNumberType(String.valueOf(formData.get("DELAY_NUME_RATE")), "###,###.##"));
                        } else {
                            formControl.setValue("");
                        }
                    }

                    /* 대금지급조건을 표기하도록 치환 */
                    if (name.equals("PAY_METHOD")) {
                        if(formData.get("PAY_METHOD") != null && !String.valueOf(formData.get("PAY_METHOD")).equals("")) {
                            Map<String, String> cParam = new HashMap<String, String>();
                            cParam.put("CODE_TYPE", "M018");
                            cParam.put("CODE", formData.get("PAY_METHOD"));
                            String payMethodLoc = ct0300mapper.getCodeDesc(cParam);
                            formControl.setValue(payMethodLoc);
                        } else {
                            formControl.setValue("");
                        }
                    }

                    /* 계약이행보증증권의 내용을 표기하도록 치환 */
                    if (name.equals("CONT_GUAR_TYPE")) {
                        if(formData.get("CONT_GUAR_AMT") == null || String.valueOf(formData.get("CONT_GUAR_AMT")).equals("") || String.valueOf(formData.get("CONT_GUAR_AMT")).equals("0")) {
                            formControl.setValue("");
                        } else {
                            if (formData.get("CONT_GUAR_TYPE") != null && !String.valueOf(formData.get("CONT_GUAR_TYPE")).equals("")) {
                                Map<String, String> cParam = new HashMap<String, String>();
                                cParam.put("CODE_TYPE", "M217");
                                cParam.put("CODE", formData.get("CONT_GUAR_TYPE"));
                                String contGuarType = ct0300mapper.getCodeDesc(cParam);
                                formControl.setValue(contGuarType);
                            } else {
                                formControl.setValue("");
                            }
                        }
                    }
                    if (name.equals("CONT_LAST_DAYS")) {
                        if(StringUtils.isNotEmpty(formData.get("CONT_START_DATE")) && StringUtils.isNotEmpty(formData.get("CONT_END_DATE"))) {
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                            Date contStartDate = sdf.parse(formData.get("CONT_START_DATE"));
                            Date contEndDate = sdf.parse(formData.get("CONT_END_DATE"));
                            formControl.setValue(ContStringUtil.toPositionalNumber(String.valueOf(Days.daysBetween(new LocalDate(contStartDate), new LocalDate(contEndDate)).getDays()+1 )));
                            ContStringUtil.makeupFormValue(formControl);
                        }
                    }
                }
                /* 각각의 formControl에 setValue() 한 결과가 적용되기 위한 필수코드입니다. */
                outputDocument.replace(formControl);
            }
            String formContentsSetValue = outputDocument.toString();

            String addContractText = ContStringUtil.replaceUserNotEditableForms(formContentsSetValue, formData);
            datum.put("CONTRACT_TEXT", addContractText);

            // 파트너사에서 반려를 했을 경우와 같이 부서식을 다시 수정을 하기 위해 original Contract Text를 따로 저장한다.
            if ("4200".equals(preProgressCd) || "4220".equals(preProgressCd) || "4230".equals(preProgressCd)) {
                String oriContractText = (String) ((datum.get("ORI_CONTRACT_TEXT") == null || "".equals(EverString.nullToEmptyString(datum.get("ORI_CONTRACT_TEXT"))) ||
						"null".equals(EverString.nullToEmptyString(datum.get("ORI_CONTRACT_TEXT"))) ||
						EverString.nullToEmptyString(datum.get("ORI_CONTRACT_TEXT")).equals("null")) ? datum.get("FORM_CONTENTS") : datum.get("ORI_CONTRACT_TEXT"));
                datum.put("ORI_CONTRACT_TEXT", ContStringUtil.replaceTextareaValue(oriContractText));
            } else {
                datum.put("ORI_CONTRACT_TEXT", addContractText);
            }

            ct0300mapper.doInsertAddECRL(datum);
        }


        //계약 자재정보 gridItem
        ct0300mapper.delEcdt(formData);
      for (int i = 0; i < gridItem.size(); i++) {
	      Map<String, Object> datum = gridItem.get(i);
//          datum.put("BUYER_CD", formData.get("BUYER_CD"));
          datum.put("CONT_NUM", formData.get("CONT_NUM"));
          datum.put("CONT_CNT", formData.get("CONT_CNT"));
          ct0300mapper.insEcdt(datum);
      }




        // 협력업체 첨부파일목록 저장
//        ct0300mapper.doDeleteECAT(formData);
//        for (int i = 0; i < gridDataS.size(); i++) {
//            Map<String, Object> datum = gridDataS.get(i);
//            if(EverString.nullToEmptyString(datum.get("SELECTED")).equals("1")) {
//                datum.put("CONT_NUM", formData.get("CONT_NUM"));
//                datum.put("CONT_CNT", formData.get("CONT_CNT"));
//                ct0300mapper.doInsertECAT(datum);
//            }
//        }



        // 대금지급정보 저장
        String vendorCd=formData.get("APAR_TYPE").equals("S") ? formData.get("PR_BUYER_CD") : formData.get("VENDOR_CD");
        formData.put("VENDOR_CD",vendorCd);
        ct0300mapper.doDeleteECPY(formData);
        for (int i = 0; i < gridDataP.size(); i++) {
            Map<String, Object> datum = gridDataP.get(i);
            datum.put("CONT_NUM", formData.get("CONT_NUM"));
            datum.put("CONT_CNT", formData.get("CONT_CNT"));

            datum.put("VENDOR_CD",vendorCd);
            ct0300mapper.doInsertECPY(datum);
        }

        makehtmlservice.doMakePDF(formData);
        return formData;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> becm030_doReqLegalTeam(Map<String, String> dataForm, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridItem, List<Map<String, Object>> gridDataP) throws Exception {

        Map<String, String> formData = doSaveContract(dataForm, gridDataM, gridDataA, gridItem, gridDataP);

        String oldSignStatus = EverString.nullToEmptyString(ct0300mapper.getOldSignStatus(dataForm));
        String signStatus = dataForm.get("SIGN_STATUS");
        String appDocCnt = dataForm.get("APP_DOC_CNT");
        if(signStatus.equals("P")) {

        	if(!"".equals(dataForm.get("approvalFormData")) && !"".equals(dataForm.get("approvalGridData"))) {
                if (EverString.isEmpty(dataForm.get("APP_DOC_NUM"))) {
                    dataForm.put("APP_DOC_NUM", docNumService.getDocNumber("AP"));
                }
                if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0") || appDocCnt.equals("null")) {
                    appDocCnt = "1";
                } else {
                    // 이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수 + 1
                    if (oldSignStatus.equals("E") || oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                        appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                    }
                }
                dataForm.put("APP_DOC_CNT", appDocCnt);
                dataForm.put("DOC_TYPE", "EC");
                // 기존 Back-Up
                //부서식 추가시 XSS 치환되어버림. 바꾼담 HTML 인설트
                String approvalFormData = dataForm.get("approvalFormData").replaceAll("&quot;", "\"");
                String approvalGridData = dataForm.get("approvalGridData").replaceAll("&quot;", "\"");
                approvalService.doApprovalProcess(dataForm, approvalFormData, approvalGridData);
        	}
        }

        dataForm.put("PROGRESS_CD", Code.CONT_TEMP_SAVE); // 법무팀 검토
        dataForm.put("SIGN_STATUS", Code.M020_P);
        ct0300mapper.doUpdateECCT4NotesIF(dataForm);

        formData.put("rtnMsg", (signStatus.equals("P") ? msg.getMessage("0057") : msg.getMessage("0031")));
        
        // 결재상신시 계약서 PDF 생성
        makehtmlservice.doMakePDF(formData);
        
        return formData;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> becm030_doReqSign(Map<String, String> dataForm, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridItem, List<Map<String, Object>> gridDataP) throws Exception {

        Map<String, String> sParam = new HashMap<String, String>();
        sParam.put("APP_DOC_NUM", dataForm.get("APP_DOC_NUM2"));
        sParam.put("APP_DOC_CNT", dataForm.get("APP_DOC_CNT2"));
        String oldSignStatus = EverString.nullToEmptyString(ct0300mapper.getOldSignStatus(sParam));

        Map<String, String> nDataForm = new HashMap<String, String>();
        nDataForm.putAll(dataForm);

        String signStatus = nDataForm.get("SIGN_STATUS2");
        String appDocCnt = nDataForm.get("APP_DOC_CNT2");
        if(signStatus.equals("P")) {
            if (EverString.isEmpty(dataForm.get("APP_DOC_NUM2"))) {
                String nAppDocNum = docNumService.getDocNumber("AP");
                nDataForm.put("APP_DOC_NUM", nAppDocNum);
                nDataForm.put("APP_DOC_NUM2", nAppDocNum);
            } else {
                nDataForm.put("APP_DOC_NUM", dataForm.get("APP_DOC_NUM2"));
                nDataForm.put("APP_DOC_NUM2", dataForm.get("APP_DOC_NUM2"));
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0") || appDocCnt.equals("null")) {
                appDocCnt = "1";
            } else {
                // 이전의 SIGN_STATUS가 반려(R), 결재취소(C)이면 결재차수 = 결재차수 + 1
                if (oldSignStatus.equals("E") || oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }
            nDataForm.put("APP_DOC_CNT", appDocCnt);
            nDataForm.put("APP_DOC_CNT2", appDocCnt);
            nDataForm.put("DOC_TYPE", "CONT");
            nDataForm.put("SIGN_STATUS", "P");
            // 기존 Back-Up
            approvalService.doApprovalProcess(nDataForm, dataForm.get("approvalFormData"), dataForm.get("approvalGridData"));
        }

//        nDataForm.put("PROGRESS_CD", Code.M135_4240); // 계약체결 기안
//        nDataForm.put("SIGN_STATUS", null);
//        nDataForm.put("SIGN_STATUS2", Code.M020_P);

        dataForm.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
        dataForm.put("SIGN_STATUS", Code.M020_P);


        ct0300mapper.doUpdateECCT4NotesIF(nDataForm);

        nDataForm.put("rtnMsg", (signStatus.equals("P") ? msg.getMessage("0023") : msg.getMessage("0031")));
        return nDataForm;
    }

    /**
     * 협력회사에 계약서 전송
     * @param formData
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doSendContract(Map<String, String> formData) throws Exception {

        formData.put("PROGRESS_CD", Code.M135_4205); // 계약서 최종확인(PDF 생성) 후, 협력서 서명대기
        ct0300mapper.doUpdateStatusOfECCT(formData);

        Map<String, String> contractInformation = ct0300mapper.getContractInformation(formData);
        if(StringUtils.isNotEmpty(contractInformation.get("VENDOR_PIC_USER_EMAIL"))) {

            // 세션 유저 정보
            UserInfo baseInfo = UserInfoManager.getUserInfo();
            String contDesc = contractInformation.get("CONT_DESC");
            String subject = "[전자계약시스템] " + contDesc + " 서명요청";
            String contNum = contractInformation.get("CONT_NUM");
            String contentsText = "" +
                    "안녕하세요, " + contractInformation.get("VENDOR_NM") + " " + contractInformation.get("VENDOR_PIC_USER_NM") + " 님<br><br>"+
                    "[" + contDesc + "] (계약번호: " + contNum + ") 계약서의 서명이 요청되었습니다.<br>당사 전자계약시스템에서 확인해주시기 바랍니다.<br><br>감사합니다.<br>";



        }
    }

    /**
     * 첨부파일 정보를 계약서에 첨부하기 위한 메소드
     * @param paramMap
     * @return
     * @throws IOException
     */
    public String getOttogiFileInformation(Map<String, String> paramMap) throws Exception {
        StringBuilder sb = new StringBuilder();
        List<Map<String, Object>> ottogiFileInformation = ct0300mapper.getOttogiFileInformation(paramMap);

        if(ottogiFileInformation.size()==0) {
        	return "";
        }

        if(ottogiFileInformation != null && ottogiFileInformation.size() > 0) {
            sb.append("<style type=\"text/css\">")
                .append(" table.econtAttach {width:100%;border-collapse:collapse;border-spacing:0;width:100%;border-left:1px solid #ccc;border-bottom:1px solid #ccc;padding:2px;} ")
                .append(" .econtAttach th {font-size:13px;font-weight:bold;text-align:center;color:#333;border-top:1px solid #ccc;border-right:1px solid #ccc;font-family:'굴림'}")
                .append(" .econtAttach td {font-size:12px;text-align:left;color:#333;border-top:1px solid #ccc;border-right:1px solid #ccc;font-family:'굴림'}")
                .append("</style>")
                .append("<br><br><table class=\"econtAttach\"><tr><th>순서</th><th>첨부파일명</th><th>파일크기</th><th>MD5 Checksum</th></tr><tr>");

            int seqNumber = 1;
            for (Map<String, Object> datum : ottogiFileInformation) {

                String fullPath = (String) datum.get("FULL_PATH");
                File file = new File(fullPath);
                if (file.exists()) {
                    FileInputStream fis = new FileInputStream(file);
                    String md5 = EverFile.fileToHash(file);
                    sb.append("<tr>")
                            .append("<td style=\"text-align: center;\">").append(seqNumber++).append("</td>")
                            .append("<td>").append(datum.get("REAL_FILE_NM")).append("</td>")
                            .append("<td style=\"text-align: right;\">").append(ContStringUtil.toPositionalNumber(String.valueOf(datum.get("FILE_SIZE")))).append("</td>")
                            .append("<td>").append(md5).append("</td>")
                            .append("</tr>");
                }
            }
            sb.append("</tr></table>");
        }
        return sb.toString();
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteContract(Map<String, String> dataForm) throws Exception {

        if (dataForm != null) {

            Map<String, String> contractInformation = ct0300mapper.getContractInformation(dataForm);
            /*
            if(!(contractInformation.get("PROGRESS_CD").equals(Code.CONT_TEMP_SAVE) || contractInformation.get("PROGRESS_CD").equals(Code.M135_4220)
               || (contractInformation.get("PROGRESS_CD").equals(Code.M135_4203) && (EverString.nullToEmptyString(contractInformation.get("SIGN_STATUS")).equals(Code.M020_R) || EverString.nullToEmptyString(contractInformation.get("SIGN_STATUS")).equals(Code.M020_C)))
               || (contractInformation.get("PROGRESS_CD").equals(Code.M135_4240) && (EverString.nullToEmptyString(contractInformation.get("SIGN_STATUS2")).equals(Code.M020_R) || EverString.nullToEmptyString(contractInformation.get("SIGN_STATUS2")).equals(Code.M020_C))))) {
                throw new Exception("계약서를 삭제할 수 없는 상태입니다.\n진행상태를 다시 확인해주세요.");
            }
            */
            ct0300mapper.doDeleteECCT(dataForm);
            ct0300mapper.doDeleteECDT(dataForm);
            ct0300mapper.doDeleteECRL(dataForm);

        }
        return msg.getMessage("0017");
    }

    /**
     * 계약서 전자서명 (서버인증서)
     *
     * @param param
     * @param resp
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void signContract(Map<String, String> param, EverHttpResponse resp) throws Exception {

//        Map<String, String> formData = req.getFormData();
        Map<String, String> formData = ct0300mapper.getContractInformation(param);
        UserInfo userInfo = UserInfoManager.getUserInfo();

        // 클라이언트 툴킷으로 서명 시 주계약서, 부서식의 서명값을 한번의 인증서 서명으로 각각 받아올 수 없고
        // 각각 서명을 해야 서명값을 받아올 수 있기 때문에
        // 서버에서도 주계약서와 부서식의 내용을 하나로 합쳐서 한번에 서명하는 방식으로 처리한다.
//        StringBuilder allContents = new StringBuilder();
//        List<Map<String, String>> getContractAllContents = ct0300mapper.getContractAllContents(formData);
//        for (Map<String, String> cctn : getContractAllContents) {
//            allContents.append(cctn.get("CONTRACT_TEXT"));
//        }
        StringBuffer allContents = new StringBuffer();
        String filePath = PropertiesManager.getString("html.output.path")+formData.get("CONT_NUM")+"@"+formData.get("CONT_CNT")+".html";
        System.err.println("============filePath="+filePath);
        File htmlFile = new File(filePath);
        Path path = Paths.get(filePath);

        if(!htmlFile.isFile()) {
        	throw new Exception("Sign File Not Exists!!!");
        }
        if(Files.size(path) == 0 ) {
        	throw new Exception("Sign File Not Exists!!!");
        }
        String filehash = EverFile.fileToHash( htmlFile );
        allContents.append(filehash);




//100	대명소노(주)


    	String locBuyerCd = userInfo.getGateCd();
    	byte[] serverSignCert = null;
    	byte[] serverSignPriKey = null;
        String serverSignKeyPassword = null;
        System.out.println("_-----------------------------------------------------------");
        System.out.println(PropertiesManager.getString("net.tradesign.properties.path"));
        System.out.println("_-----------------------------------------------------------");
        try {
            JeTS.installProvider(PropertiesManager.getString("net.tradesign.properties.path"));

         } catch(Exception e) {
            getLog().error(e.getMessage(), e);
            throw new Exception("서버인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
        }
        if(locBuyerCd==null || "".equals(locBuyerCd)) {
            throw new Exception("서명 BUYER_CD가 존재하지 않습니다.");
        }



    	if ("100".equals(locBuyerCd)) {//100	대명소노(주)
    		serverSignCert = JeTS.getServerSignCert(0);
            serverSignPriKey = JeTS.getServerSignPriKey(0);
            serverSignKeyPassword = JeTS.getServerSignKeyPassword(0);
        }
        SignedData sd = new SignedData(allContents.toString().getBytes("euc-kr"), true);



        System.err.println("==============================serverSignCert="+serverSignCert);
        System.err.println("==============================serverSignPriKey="+serverSignPriKey);
        System.err.println("==============================serverSignKeyPassword="+serverSignKeyPassword);
        sd.setsignCert(serverSignCert, serverSignPriKey, serverSignKeyPassword);
        byte[] signedString = sd.sign();
        X509Certificate[] certs = sd.verify();



		// 유효기간 시작시각(Validity notBefore) 추출
		Date notBefore = certs[0].getNotBefore();
		if (notBefore != null) {
			System.out.println("유효기간 시작시각: " + notBefore);
		} else {
            throw new Exception("서버인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
		}
		// 유효기간 종료시각(Validity notAfter) 추출
		Date notAfter = certs[0].getNotAfter();
		if (notAfter != null) {
			System.out.println("유효기간 종료시각: " + notAfter);
		} else {
            throw new Exception("서버인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
		}
		System.err.println("===============================notBefore="+notBefore);
		System.err.println("===============================notAfter="+notAfter);



		String expireMessage = null;
		LicenseVerifyUtil.verifyTime(notBefore, notAfter);
		long validToDate = Long.parseLong(DateFormatUtils.format(DateUtils.addDays(notAfter, -14), "yyyyMMddHHmmss"));
		long validToDate2 = Long.parseLong(DateFormatUtils.format(DateUtils.addDays(notAfter, 0), "yyyyMMddHHmmss"));
		long currentDate = Long.parseLong(DateFormatUtils.format(new Date(), "yyyyMMddHHmmss"));
		if(currentDate > validToDate) {
			expireMessage = "서버용 인증서의 만료기한이 얼마남지 않았습니다.\n(만료일자: "+notAfter+")\n관리자에게 문의해 주시기 바랍니다.";
		}

		if(currentDate > validToDate2) {
			throw new Exception("서버인증서 유효기간이 만료되었습니다.\n관리자에게 문의해주시기 바랍니다.");
		}


        String[] certDn = new String[certs.length];
        for (int i = 0; i < certs.length; i++) {
            certDn[i] = certs[i].getSubjectDNStr();
        }
        String serverSignedContents = new String(JetsUtil.encodeBase64(signedString), "euc-kr");
        String userDn = certDn[0];  // 필요하면 저장한다.



        formData.put("SIGN_VALUE", serverSignedContents);

        //매출계약서일때 동시 서명 인설트.
        if(formData.get("APAR_TYPE").equals("S")) {
        	ct0300mapper.doDeleteECSV(formData);
        	//운영사 인설트
        	formData.put("USER_TYPE","C");
        	formData.put("SIGN_ID",formData.get("VENDOR_CD"));
        	ct0300mapper.doInsertECSV(formData);
        	//고객사인설트
        	formData.put("USER_TYPE","B");
        	formData.put("SIGN_ID",formData.get("PR_BUYER_CD"));
        	ct0300mapper.doInsertECSV(formData);
        }else {
        	formData.put("USER_TYPE","C");
        	formData.put("SIGN_ID",formData.get("PR_BUYER_CD"));
        	ct0300mapper.doInsertECSV(formData);
        }

        // 계약체결완료로 상태 변경
        formData.put("PROGRESS_CD", Code.CONT_COMPLETE);
        ct0300mapper.doUpdateStatusOfECCT(formData);

        if (expireMessage!=null) {
            resp.setResponseMessage(expireMessage);    //계약서에 서명하셨습니다.
        } else {
            resp.setResponseMessage(msg.getMessageByScreenId("CT0320", "0002"));    //계약서에 서명하셨습니다.
        }

        //워터마크
        formData.put("SIGN_FLAG","S");
        makehtmlservice.doMakePDF(formData);

//        if("03".equals(formData.get("CONTRACT_FORM_TYPE"))) {// 단가계약만 단가 생성
//        	ct0300mapper.insStocInfo(formData);
//        }
        if("1".equals(formData.get("VENDOR_TEST_REQ_YN"))) {//발주여부가 1인경우에만 발주생성
            String poNum = docNumService.getDocNumber("PO");
            formData.put("PO_NUM",poNum);
            ct0300mapper.createPohd(formData);
            ct0300mapper.createPodt(formData);
            ct0300mapper.createPopy(formData);
        }

        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CONT_TemplateFileName");

        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");

		String maintainUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { maintainUrl = "https://"; }
		else { maintainUrl = "http://"; }
		if ("80".equals(domainPort)) {
			maintainUrl += domainNm;
		} else {
			maintainUrl += domainNm + ":" + domainPort;
		}
		maintainUrl += contextNm;

		if(formData.get("APAR_TYPE").equals("P")) {
			Map<String,String> vendorData = ct0300mapper.getMailInfo(formData);
			String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
	        fileContents = EverString.replace(fileContents, "$VENDOR_NM$", vendorData.get("VENDOR_NM")); // 공급사명
	        fileContents = EverString.replace(fileContents, "$CONT_NUM_CNT$", vendorData.get("CONT_NUM")); // 견적의뢰번호/차수
	        fileContents = EverString.replace(fileContents, "$CONTENTS$", "계약서 서명이 완료되었습니다. 보증보험 신청 후 등록바랍니다."); // 견적의뢰번호/차수
			Map<String, String> mdata = new HashMap<String, String>();
			mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 계약 서명이 완료되었습니다.");
	        mdata.put("CONTENTS_TEMPLATE", fileContents);
	        mdata.put("SEND_USER_ID", vendorData.get("SEND_USER_ID"));
	        mdata.put("SEND_USER_NM", vendorData.get("SEND_USER_NM"));
	        mdata.put("SEND_EMAIL", vendorData.get("SEND_EMAIL"));
	        mdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID"));
	        mdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM"));
	        mdata.put("RECV_EMAIL", vendorData.get("RECV_EMAIL"));
	        mdata.put("EMAIL_TO", vendorData.get("RECV_EMAIL"));
	        mdata.put("REF_NUM", vendorData.get("CONT_NUM"));
	        mdata.put("REF_MODULE_CD","CONT"); // 참조모듈
	        // 메일전송.
	        everMailService.goSendMail(mdata);
		}


    }






    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> doFinishContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        Map<String, String> contractInformation = ct0300mapper.getContractInformation(formData);

        // 수기계약일때만 계약완료 가능하도록 체크
        if(!contractInformation.get("MANUAL_CONT_FLAG").equals(Code.M008_1)) {
            throw new Exception("수기계약만 계약완료 처리할 수 있습니다.");
        }

        formData.put("PROGRESS_CD", Code.CONT_COMPLETE);
        ct0300mapper.doUpdateStatusOfECCT(formData);

        resp.setResponseMessage(msg.getMessageByScreenId("CT0320", "0021"));

        return formData;
    }

    // ERP Temp Table에 계약번호/차수 반영
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doUpdateContNumToERP(Map<String, String> dataForm) throws Exception {
        ct0300mapper.doUpdateContNumToERP(dataForm);
    }

    // 법무팀 검토
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApprovalExam(String docNum, String docCnt) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
        Map<String, String> contInfo = ct0300mapper.getApprovalContInfoExam(map);
        map.put("CONT_NUM", contInfo.get("CONT_NUM"));
        map.put("CONT_CNT", String.valueOf(contInfo.get("CONT_CNT")));

        map.put("SIGN_STATUS", "E");

        if("1".equals(contInfo.get("MANUAL_CONT_FLAG"))) {
            map.put("PROGRESS_CD", Code.CONT_COMPLETE); // 수기 계약일 경우 계약 완료
        } else {
            map.put("PROGRESS_CD", Code.CONT_SUPPLY_READY); // 협력사 서명 대기
        }

        ct0300mapper.updateSignStatusExam(map);

        return msg.getMessage("0057");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rejectApprovalExam(String docNum, String docCnt) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
        Map<String, String> contInfo = ct0300mapper.getApprovalContInfoExam(map);
        map.put("CONT_NUM", contInfo.get("CONT_NUM"));
        map.put("CONT_CNT", String.valueOf(contInfo.get("CONT_CNT")));

        map.put("SIGN_STATUS", "R");
        map.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
        ct0300mapper.updateSignStatusExam(map);

        return msg.getMessage("0058");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelApprovalExam(String docNum, String docCnt) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
        Map<String, String> contInfo = ct0300mapper.getApprovalContInfoExam(map);
        map.put("CONT_NUM", contInfo.get("CONT_NUM"));
        map.put("CONT_CNT", String.valueOf(contInfo.get("CONT_CNT")));

        map.put("SIGN_STATUS", "C");
        map.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
        ct0300mapper.updateSignStatusExam(map);

        return msg.getMessage("0061");
    }

    // 계약 체결기안
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApprovalCont(String docNum, String docCnt) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM2", docNum);
        map.put("APP_DOC_CNT2", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
        Map<String, String> contInfo = ct0300mapper.getApprovalContInfoCont(map);
        map.put("CONT_NUM", contInfo.get("CONT_NUM"));
        map.put("CONT_CNT", String.valueOf(contInfo.get("CONT_CNT")));
        contInfo = ct0300mapper.getContractInformation(map);

        // 클라이언트 툴킷으로 서명 시 주계약서, 부서식의 서명값을 한번의 인증서 서명으로 각각 받아올 수 없고
        // 각각 서명을 해야 서명값을 받아올 수 있기 때문에
        // 서버에서도 주계약서와 부서식의 내용을 하나로 합쳐서 한번에 서명하는 방식으로 처리한다.
        StringBuilder allContents = new StringBuilder();
        List<Map<String, String>> getContractAllContents = ct0300mapper.getContractAllContents(contInfo);
        for (Map<String, String> cctn : getContractAllContents) {
            allContents.append(cctn.get("CONTRACT_TEXT"));
        }

        try {
            String buyerCd = contInfo.get("BUYER_CD");
            JeTS.installProvider(PropertiesManager.getString("net.tradesign.properties.path"));
        } catch(Exception e) {
            getLog().error(e.getMessage(), e);
            throw new Exception("서버인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
        }

        SignedData sd = new SignedData(allContents.toString().getBytes("euc-kr"), true);
        sd.setsignCert(JeTS.getServerSignCert(0), JeTS.getServerSignPriKey(0), JeTS.getServerSignKeyPassword(0));

        byte[] signedString = sd.sign();
        X509Certificate[] certs = sd.verify();

        String[] certDn = new String[certs.length];
        for (int i = 0; i < certs.length; i++) {
            certDn[i] = certs[i].getSubjectDNStr();
        }

        String serverSignedContents = new String(JetsUtil.encodeBase64(signedString), "UTF-8");
        String userDn = certDn[0]; // 필요하면 저장한다.

        // 서명된 값을 서명테이블에 저장
        contInfo.put("SIGN_ID", "samyang");
        contInfo.put("SIGN_VALUE", serverSignedContents);
        ct0300mapper.doDeleteECSV(contInfo);
        ct0300mapper.doInsertECSV(contInfo);

        // 계약체결완료로 상태 변경
        map.put("SIGN_STATUS2", "E");
        map.put("PROGRESS_CD", Code.CONT_COMPLETE);
        ct0300mapper.updateSignStatusCont(map);

        // 파트너사에 메일발송
        //Map<String, String> contractInformation = ct0300mapper.getContractInformation(map);

        // Image Server로 파일전송
        //sendFileToImageServer(map.get("CONT_NUM"), map.get("CONT_CNT"));

        return msg.getMessage("0057");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rejectApprovalCont(String docNum, String docCnt) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM2", docNum);
        map.put("APP_DOC_CNT2", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
        Map<String, String> contInfo = ct0300mapper.getApprovalContInfoCont(map);
        map.put("CONT_NUM", contInfo.get("CONT_NUM"));
        map.put("CONT_CNT", contInfo.get("CONT_CNT"));

        map.put("SIGN_STATUS2", "R");
        map.put("PROGRESS_CD", Code.M135_4240); // 계약체결기안
        ct0300mapper.updateSignStatusCont(map);

        return msg.getMessage("0058");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelApprovalCont(String docNum, String docCnt) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM2", docNum);
        map.put("APP_DOC_CNT2", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
        Map<String, String> contInfo = ct0300mapper.getApprovalContInfoCont(map);
        map.put("CONT_NUM", contInfo.get("CONT_NUM"));
        map.put("CONT_CNT", contInfo.get("CONT_CNT"));

        map.put("SIGN_STATUS2", "C");
        map.put("PROGRESS_CD", Code.M135_4240); // 계약체결기안
        ct0300mapper.updateSignStatusCont(map);

        return msg.getMessage("0061");
    }

    public String sendFileToImageServer(String contNum, String contCnt) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("CONT_NUM", contNum);
        param.put("CONT_CNT", contCnt);

        String pdfPath = PropertiesManager.getString("imageServer.pdf.path");
        String pdfFileNm = contNum + "@" + contCnt + ".pdf";
        String zipFileFolder = PropertiesManager.getString("imageServer.zipOut.path");
        String zipFile = zipFileFolder + contNum + "@" + contCnt + ".zip";
        String elementId = "";

        // 계약서 첨부파일 압축하기
        ZipOutputStream zipOut = null;
        FileOutputStream fos = null;

        try {

            fos = new FileOutputStream(zipFile);
            zipOut = new ZipOutputStream(fos);

            // 해당 계약번호에 있는 모든 첨부파일의 정보를 가져와 zip 파일에 포함시킨다.
            List<Map<String, String>> fileList = ct0300mapper.getContFileList(param);
            for(int i = 0; i < fileList.size(); i++) {
                Map<String, String> data = fileList.get(i);
                if(data != null && data.get("FILE_NM") != null) {
                    File fileToZip = new File(data.get("FILE_PATH") + "/" + data.get("FILE_NM") + "." + data.get("FILE_EXTENSION"));
                    logger.info(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fileToZip : " + fileToZip);
                    if (fileToZip.exists()) {
                        FileInputStream fis = null;
                        try {
                            fis = new FileInputStream(fileToZip);
                            ZipEntry zipEntry = new ZipEntry(data.get("REAL_FILE_NM"));
                            zipOut.putNextEntry(zipEntry);
                            byte[] bytes = new byte[1024];
                            int length;
                            while ((length = fis.read(bytes)) >= 0) {
                                zipOut.write(bytes, 0, length);
                            }
                        } catch (Exception e) {
                            logger.error(e.getMessage());
                        } finally {
                            fis.close();
                        }
                    }
                }
            }

            // 해당 계약서의 PDF 파일도 zip 파일에 포함시킨다.
            File fileToZip = new File(pdfPath + pdfFileNm);
            logger.info(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fileToZip : " + fileToZip);
            if (fileToZip.exists()) {
                FileInputStream fis = null;
                try {
                    fis = new FileInputStream(fileToZip);
                    ZipEntry zipEntry = new ZipEntry(pdfFileNm);
                    zipOut.putNextEntry(zipEntry);
                    byte[] bytes = new byte[1024];
                    int length;
                    while ((length = fis.read(bytes)) >= 0) {
                        zipOut.write(bytes, 0, length);
                    }
                } catch (Exception e) {
                    logger.error(e.getMessage());
                } finally {
                    fis.close();
                }
            }

        } catch (Exception e) {
            logger.error(e.getMessage());
            throw e;
        } finally {
            zipOut.close();
            fos.close();
        }

        return elementId;
    }



    /**
     * 계약서 현황 조회
     *
     * @param param
     * @return
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public List<Map<String, Object>> ecoa0020_doSearch(Map<String, String> param) throws NoSuchAlgorithmException, EnumerationNotFoundException, UnsupportedEncodingException {

        if(EverString.nullToEmptyString(param.get("DATE_TYPE")).equals("01")) {
            param.put("receptDateFrom", param.get("REG_DATE_FROM"));
            param.put("receptDateTo", param.get("REG_DATE_TO"));
        } if(EverString.nullToEmptyString(param.get("DATE_TYPE")).equals("02")) {
            param.put("contEndDateFrom", param.get("REG_DATE_FROM"));
            param.put("contEndDateTo", param.get("REG_DATE_TO"));
        } else {
            param.put("contDateFrom", param.get("REG_DATE_FROM"));
            param.put("contDateTo", param.get("REG_DATE_TO"));
        }

		Map<String, Object> fParam = new HashMap<>(param);


        if(EverString.isNotEmpty(param.get("PROGRESS_CD"))) {
        	fParam.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));
        }





        return ct0300mapper.ecoa0020_doSearch(fParam);
    }

    // 담당자 변경
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ECOA0020_doChangeContUser(String contUserId, List<Map<String, Object>> gridData)  throws Exception  {

        for (Map<String, Object> rowData : gridData) {
            rowData.put("CONT_USER_ID", contUserId);
            ct0300mapper.ECOA0020_doChangeContUser(rowData);
        }
        return msg.getMessageByScreenId("CT0330", "0013");
    }

    // 계약서 복사
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> ECOA0020_doCopy(List<Map<String, Object>> gridData) throws Exception {

        String newContNum = docNumService.getDocNumber("EC");
        String newContCnt = "1";

        for (Map<String, Object> rowData : gridData) {

            rowData.put("NEW_CONT_NUM", newContNum);
            rowData.put("NEW_CONT_CNT", newContCnt);
            rowData.put("PROGRESS_CD", "4200");

            ct0300mapper.ecoa0020_doCopyECCT(rowData);
            ct0300mapper.ecoa0020_doCopyECRL(rowData);
            ct0300mapper.ecoa0020_doCopyECAT(rowData);
            ct0300mapper.ecoa0020_doCopyECPY(rowData);
        }

        Map<String, String> rtnMap = new HashMap<String, String>();
        rtnMap.put("newContNum", newContNum);
        rtnMap.put("newContCnt", newContCnt);
        rtnMap.put("rtnMsg", msg.getMessageByScreenId("CT0330", "0017"));
        return rtnMap;
    }

    // 결재 승인/반려 계약해지
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ECOA0020_doCancelRemoveCont2 (String docNum, String docCnt, String signStatus) throws Exception {
    	 Map<String, String> map = new HashMap<String, String>();
         map.put("APP_DOC_NUM2", docNum);
         map.put("APP_DOC_CNT2", docCnt);

        // 결재번호에 해당하는 구매요청번호 가져오기
         map = ct0300mapper.getApprovalContInfoCont(map);
         map.put("SIGN_STATUS2", signStatus);
         if(signStatus.equals("E")) {
        	 ct0300mapper.cancelContItem(map);
         }
         ct0300mapper.ecoa0020_doCancelRemoveCont(map);

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }



    // ERP 매핑삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ECOA0020_doDelMapping(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {
            int purcCnt = ct0300mapper.ecoa0020_getPurcCnt(rowData);
            if(purcCnt < 1) {
                throw new NoResultException(msg.getMessageByScreenId("CT0330", "0028"));
            }
            ct0300mapper.ecoa0020_doDelMapping(rowData);
        }
        return msg.getMessageByScreenId("CT0330", "0030");
    }

    // 계약서 보증첨부 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BECM_050_doSave(List<Map<String, Object>> gridData) {
        for (Map<String, Object> rowData : gridData) {
            ct0300mapper.BECM_050_doSave(rowData);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void saveETcInfo(List<Map<String, Object>> gridData) {
        for (Map<String, Object> rowData : gridData) {
            ct0300mapper.saveETcInfo(rowData);
        }
    }




    // 계약서 추가첨부 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void BECM_050_doAttSave(List<Map<String, Object>> gridData) {

        for (Map<String, Object> rowData : gridData) {

            //수기계약일경우 계약상태 체결계약완료 상태로 업데이트
            if(rowData.get("MANUAL_CONT_FLAG").equals(Code.M008_1)){

                //법무팀 검토여부 && 체결기안 검토여부
                if(rowData.get("EXAM_FLAG").equals(Code.M008_1) && rowData.get("APPROVAL_FLAG").equals(Code.M008_1)){
                    if(rowData.get("SIGN_STATUS").equals("E") && rowData.get("SIGN_STATUS2").equals("E")){
                        rowData.put("ATT_PROGRESS_CD", Code.CONT_COMPLETE);
                    }
                }else if(rowData.get("EXAM_FLAG").equals(Code.M008_0) && rowData.get("APPROVAL_FLAG").equals(Code.M008_1)){
                    if(rowData.get("SIGN_STATUS2").equals("E")){
                        rowData.put("ATT_PROGRESS_CD", Code.CONT_COMPLETE);
                    }
                }else if(rowData.get("EXAM_FLAG").equals(Code.M008_1) && rowData.get("APPROVAL_FLAG").equals(Code.M008_0)){
                    if(rowData.get("SIGN_STATUS").equals("E")){
                        rowData.put("ATT_PROGRESS_CD", Code.CONT_COMPLETE);
                    }
                }else{
                    rowData.put("ATT_PROGRESS_CD", Code.CONT_COMPLETE);
                }
            }
            ct0300mapper.BECM_050_doAttSave(rowData);
        }
    }

    // 계약서 추가파일 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void ECOA0020_doAddFileSave(List<Map<String, Object>> gridData) {
        for (Map<String, Object> rowData : gridData) {
            ct0300mapper.ECOA0020_doAddFileSave(rowData);
        }
    }








    public List<Map<String, Object>> etcContSearch(Map<String, String> param) {

        if(EverString.nullToEmptyString(param.get("DATE_TYPE")).equals("01")) {
            param.put("contDateFrom", param.get("REG_DATE_FROM"));
            param.put("contDateTo", param.get("REG_DATE_TO"));
        } else {
            param.put("contEndDateFrom", param.get("REG_DATE_FROM"));
            param.put("contEndDateTo", param.get("REG_DATE_TO"));
        }

		Map<String, Object> fParam = new HashMap<>(param);
        Map<String, Object> fParamAll = new HashMap<String, Object>(param);
        List<Map<String, Object>> search_form_list = new ArrayList<>();

        if(EverString.isNotEmpty(param.get("PROGRESS_CD"))) {
        	fParamAll.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));
        }
        if(EverString.isNotEmpty(param.get("PUR_ORG_CD"))) {
        	fParamAll.put("PUR_ORG_CD_LIST", Arrays.asList(param.get("PUR_ORG_CD").split(",")));
        }

        search_form_list.add(fParamAll);
        fParam.put("SEARCH_FORM_LIST", search_form_list);





        return ct0300mapper.etcContSearch(fParam);
    }













    public List<Map<String, Object>> getContReadyList(Map<String, String> formData) {

        Map<String, Object> paramObj = (Map) formData;
        if(EverString.isNotEmpty(formData.get("BUYER_CD"))) {
            paramObj.put("BUYER_CD_LIST", Arrays.asList(formData.get("BUYER_CD").split(",")));
        }


        return ct0300mapper.getContReadyList(paramObj);
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doExecClose(List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {
        	if(rowData.get("APAR_TYPE").equals("S")) {
        		rowData.put("VENDOR_CD",rowData.get("PR_BUYER_CD"));
        	}
            ct0300mapper.execClose(rowData);
        }

        return msg.getMessage("0001");
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String setSignAgreeReject(Map<String, String> dataForm) throws Exception {
        ct0300mapper.setSignAgreeReject(dataForm);

        String message = "";
        if("E".equals(dataForm.get("SIGN_STATUS"))) {
        	message = msg.getMessage("0057");

            Map<String, String> contInfo = ct0300mapper.getApprovalContInfoExam(dataForm);

            if(!"1".equals(contInfo.get("MANUAL_CONT_FLAG"))) { // 수기계약이면 보내지 않는다.
	            StringBuffer contentEmail = new StringBuffer();
	            contentEmail.append("안녕하세요.\n");
	            contentEmail.append("삼양 [전자구매시스템]에 <span style=\"font-weight:700;color:red;\">전자계약</span>이 접수되었습니다.\n");

                StringBuffer sendorInfo = new StringBuffer();
                sendorInfo.append("요청 담당자 : ").append(contInfo.get("CTRL_USER_NM")).append(" ").append(contInfo.get("CTRL_USER_POSITION"));
                sendorInfo.append(" (").append(contInfo.get("CTRL_USER_TEL")).append(" / ").append(contInfo.get("CTRL_USER_CELL")).append(")\n");
                sendorInfo.append("요청 담당자 이메일 주소 : ").append(contInfo.get("CTRL_USER_EMAIL"));

	            String subject = "[삼양식품 통합구매시스템] 전자서명이 필요한 계약을 확인해주세요";
	            String contents = contentEmail.toString();
	            String companyNm = "삼양";
	            String destUrl = "";
	            String emailContents = "";

	            Map<String,String> receiveUser = new HashMap<>();
	            receiveUser.put("VENDOR_CD", contInfo.get("VENDOR_CD"));
	            receiveUser.put("SUBJECT", subject);
	            receiveUser.put("DIRECT_TARGET", contInfo.get("VENDOR_PIC_USER_EMAIL"));
	            receiveUser.put("DIRECT_USER_NM", contInfo.get("VENDOR_PIC_USER_NM"));
	            receiveUser.put("DIRECT_CELL_NUM", contInfo.get("VENDOR_PIC_CELL_NUM"));
	            receiveUser.put("CONTENTS_TEMPLATE", emailContents);

	            //if (PropertiesManager.getBoolean("eversrm.system.mail.send.flag")) {
	            //	everMailService.sendMessage(receiveUser);
	            //}
            }
        } else {
        	message = msg.getMessage("0058");
        }

        return message;
    }
    /**
     * 계약 결재 승인 이후 프로세스
     * @param docNum
     * @param docCnt
     * @param signStatus
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval( String docNum, String docCnt, String signStatus) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);

       // 결재번호에 해당하는 구매요청번호 가져오기
        map = ct0300mapper.getApprovalContInfoCont(map);
        map.put("SIGN_STATUS", signStatus);
        map.put("APPROVAL_FLAG", "FG");
        if(signStatus.equals("E")){ //승인
           if(map.get("MANUAL_CONT_FLAG").equals("1")) {
        	   map.put("PROGRESS_CD", "4220"); // 수기 계약일 경우 계약 내부결재
           }else {
	    	   if(map.get("APAR_TYPE").equals("S")){
	         	  map.put("PROGRESS_CD","4220");

	           }else {
	         	  map.put("PROGRESS_CD","4200");
	         	  sendEmail(map);
	           }
           }

           ct0300mapper.updateSignStatusCont(map);
        } else if(signStatus.equals("R")){ 	//반려
            map.put("PROGRESS_CD","4210");
            ct0300mapper.updateSignStatusCont(map);
        } else if(signStatus.equals("C")){	//취소
            map.put("PROGRESS_CD","4210");
            ct0300mapper.updateSignStatusCont(map);
        }

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }

	public Map<String, String> getVendorCustInformation(EverHttpRequest req, EverHttpResponse resp) {
		Map<String, String> paramMap = new HashMap<String, String>();
		paramMap.put("CTRL_USER_ID",req.getParameter("CTRL_USER_ID"));
		// TODO Auto-generated method stub
		return ct0300mapper.getVendorCustInformation(paramMap);
	}
	/**
	 *  업체 전송 후 메일, sms 발송
	 * @param rqhdData
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void sendEmail(Map<String, String> rqhdData) throws Exception {
		// E-Mail, SMS 발송
        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CONT_TemplateFileName");

        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");

		String maintainUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { maintainUrl = "https://"; }
		else { maintainUrl = "http://"; }
		if ("80".equals(domainPort)) {
			maintainUrl += domainNm;
		} else {
			maintainUrl += domainNm + ":" + domainPort;
		}
		maintainUrl += contextNm;

		Map<String,String> vendorData = ct0300mapper.getMailInfo(rqhdData);
		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        fileContents = EverString.replace(fileContents, "$VENDOR_NM$", vendorData.get("VENDOR_NM")); // 공급사명
        fileContents = EverString.replace(fileContents, "$CONT_NUM_CNT$", vendorData.get("CONT_NUM")); // 견적의뢰번호/차수
        fileContents = EverString.replace(fileContents, "$CONTENTS$", "해당 내용 확인 후 전자서명 바랍니다."); // 견적의뢰번호/차수
		Map<String, String> mdata = new HashMap<String, String>();
		mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 귀사에 계약서명 요청 드립니다.");
        mdata.put("CONTENTS_TEMPLATE", fileContents);
        mdata.put("SEND_USER_ID", vendorData.get("SEND_USER_ID"));
        mdata.put("SEND_USER_NM", vendorData.get("SEND_USER_NM"));
        mdata.put("SEND_EMAIL", vendorData.get("SEND_EMAIL"));
        mdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID"));
        mdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM"));
        mdata.put("RECV_EMAIL", vendorData.get("RECV_EMAIL"));
        mdata.put("EMAIL_TO", vendorData.get("RECV_EMAIL"));
        mdata.put("REF_NUM", vendorData.get("CONT_NUM"));
        mdata.put("REF_MODULE_CD","CONT"); // 참조모듈
        // 메일전송.
        everMailService.goSendMail(mdata);

	}
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void ECOA0020_doCancelCont(Map<String, String> formData,List<Map<String, Object>> gridData) throws Exception {
		Map<String, Object> gridInfo = gridData.get(0);
        String appDocNum = EverString.nullToEmptyString(gridInfo.get("APP_DOC_NUM2"));
        String appDocCnt = EverString.nullToEmptyString(gridInfo.get("APP_DOC_CNT2"));
        formData.put("CONT_NUM",String.valueOf(gridInfo.get("CONT_NUM")));
        formData.put("CONT_CNT",String.valueOf(gridInfo.get("CONT_CNT")));
        String oldSignStatus = EverString.nullToEmptyString(ct0300mapper.getSignStatus(formData));
        formData.put("APP_DOC_NUM", appDocNum);
        if(EverString.isEmpty(appDocCnt)){
        	appDocNum = docNumService.getDocNumber("AP");
            formData.put("APP_DOC_NUM", appDocNum);
        }
        if(EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")){
            appDocCnt = "1";
        }else{
            if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
            }
        }
        formData.put("APP_DOC_CNT", appDocCnt);
        formData.put("SIGN_STATUS", "P");
        formData.put("DOC_TYPE", "CC");

        eApprovalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        ct0300mapper.updateSignStatus(formData);

	}
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSendCancle(Map<String, String> param) throws Exception {
		int check =ct0300mapper.getSendCancelCheck(param);
		String meg = "";
		if(check==0) {
			//상태값 바뀌어 처리불가.
			meg = msg.getMessageByScreenId("CT0320", "0032");
		}else {
			param.put("SIGN_STATUS","T");
			param.put("PROGRESS_CD","4110");
			ct0300mapper.updateSignStatusExam(param);
			meg =msg.getMessageByScreenId("CT0320", "0033");
		}

		return meg ;
	}


}