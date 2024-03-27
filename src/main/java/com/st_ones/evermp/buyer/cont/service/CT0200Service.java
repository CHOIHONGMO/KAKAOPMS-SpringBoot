package com.st_ones.evermp.buyer.cont.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.ContStringUtil;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.CT0200Mapper;
import com.st_ones.evermp.buyer.cont.CT0300Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import net.htmlparser.jericho.FormControl;
import net.htmlparser.jericho.OutputDocument;
import net.htmlparser.jericho.Source;
import org.apache.commons.lang3.StringUtils;
import org.joda.time.Days;
import org.joda.time.LocalDate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import tradesign.crypto.provider.JeTS;
import tradesign.pki.pkix.SignedData;
import tradesign.pki.pkix.X509Certificate;
import tradesign.pki.util.JetsUtil;

import java.io.File;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@Service(value = "CT0200Service")
public class CT0200Service  extends BaseService {

	@Autowired MessageService msg;
	@Autowired LargeTextService largeTextService;
	@Autowired private DocNumService docNumService;
	@Autowired private CT0200Mapper ct0200mapper;
	@Autowired private CT0300Mapper ct0300mapper;


    @Autowired private BAPM_Service approvalService;

    private static final String MAIN_FORM_SQ = "0";

    /**
     * 일괄계약서 정보 조회
     * @param req
     * @param resp
     * @param parameterMap
     */
    public Map<String, String> ecob0040_getBundleContractInfo(Map<String, String> param) {
        Map<String, String> formData = ct0200mapper.ecob0040_getBundleContractInfo(param);

        String resultContractForm = "";
        if(formData != null) {
            String progressCd = formData.get("PROGRESS_CD");
            String signStatus = formData.get("SIGN_STATUS2");
            String contractForm = formData.get("CONTRACT_TEXT");
            // 수정불가상태
            if (!(progressCd.equals("") || progressCd.equals(Code.CONT_TEMP_SAVE) || progressCd.equals(Code.CONT_SUPPLY_REJECT)
                    || (progressCd.equals(Code.M135_4240) && (StringUtils.equals(signStatus, Code.M020_R) || StringUtils.equals(signStatus, Code.M020_C)))
            )) {
                resultContractForm = ContStringUtil.getHtmlContents(contractForm, true);

            } else {
                resultContractForm = contractForm;
            }
            formData.put("formContents", resultContractForm);
        }
        if(param.get("resumeFlag").equals("true")) {
        	formData.put("NEW_CONT_CNT", ct0300mapper.getMaxContCnt(formData.get("CONT_NUM")));
        	formData.remove("M_ATT_FILE_NUM");
        	formData.remove("ATT_FILE_NUM");

        	formData.remove("APP_DOC_NUM");
        	formData.remove("APP_DOC_CNT");

        }
        return formData;
    }

    public List<Map<String, Object>> ecob0040_doSearchAdditionalForm(Map<String, String> param) {
        return ct0200mapper.ecob0040_doSearchAdditionalForm(param);
    }

    public List<Map<String, Object>> basicContSearch(Map<String, String> param) {

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





        return ct0200mapper.basicContSearch(fParam);
    }




    /**
     * 화면에서 엑셀업로드로 받은 협력회사 코드로 협력회사 정보를 모두 조회한다.
     *
     * @param gridVData
     * @return
     */
    public List<Map<String, Object>> becm080_getVendorListForBundleContract(List<Map<String, Object>> gridVData) {
         Map<String, String> param = new HashMap<>();
		Map<String, Object> fParam = new HashMap<>(param);

		String vendorCodeList = "";
        for (Map<String, Object> gridVDatum : gridVData) {
            vendorCodeList = vendorCodeList + (String) gridVDatum.get("VENDOR_CD") + ",";
        }
        if(vendorCodeList.length() > 0) {
            vendorCodeList = vendorCodeList.substring(0, vendorCodeList.length() - 1);
            fParam.put("VENDOR_CD_LIST", Arrays.asList(vendorCodeList.split(",")));
            fParam.put("VENDOR_CD", vendorCodeList);
        }

        List<Map<String, Object>> vendorList = ct0200mapper.becm080_getVendorListForBundleContract(fParam);
        for (Map<String, Object> vendorData : vendorList) {
            String dbVendorCd = (String) vendorData.get("VENDOR_CD");
            String dbVendorPicUserNm = (String) vendorData.get("VENDOR_PIC_USER_NM");
            for (Map<String, Object> gridVDatum : gridVData) {
                if(dbVendorCd.equals((String) gridVDatum.get("VENDOR_CD"))) {
                    if(gridVDatum.get("VENDOR_PIC_USER_NM") != null && !EverString.isEmpty((String) gridVDatum.get("VENDOR_PIC_USER_NM"))) {
                        vendorData.put("VENDOR_PIC_USER_NM", gridVDatum.get("VENDOR_PIC_USER_NM"));
                    }
                    if(gridVDatum.get("VENDOR_PIC_USER_NM") != null && !EverString.isEmpty((String) gridVDatum.get("VENDOR_PIC_USER_NM"))) {
                        vendorData.put("VENDOR_PIC_USER_NM", gridVDatum.get("VENDOR_PIC_USER_NM"));
                    }
                    if(gridVDatum.get("VENDOR_PIC_USER_EMAIL") != null && !EverString.isEmpty((String) gridVDatum.get("VENDOR_PIC_USER_EMAIL"))) {
                        vendorData.put("VENDOR_PIC_USER_EMAIL", gridVDatum.get("VENDOR_PIC_USER_EMAIL"));
                    }
                }
            }
        }

        /*
        for (Map<String, Object> v : vendorList) {
            if(StringUtils.isEmpty((String)v.get("BELONG_DEPT_CD"))) {

                // 조회된 주소속부서 코드가 없을 때 그리드데이터에 업로드된 주소속부서명이 있는지 확인 후 있으면 부서코드 조회
                for (Map<String, Object> gridVDatum : gridVData) {

                    String vendorCd = StringUtils.trim((String)v.get("VENDOR_CD"));
                    String vendorCd2 = StringUtils.trim((String)gridVDatum.get("VENDOR_CD"));
                    if(StringUtils.equals(vendorCd, vendorCd2)) {

                        String gridBelongDeptNm = (String)gridVDatum.get("BELONG_DEPT_NM");
                        if(StringUtils.isNotEmpty(gridBelongDeptNm)) {
                            String belongDeptCode = ct0200mapper.becm080_getDeptCodeByDeptName(gridBelongDeptNm);
                            if(StringUtils.isEmpty(belongDeptCode)) {
                                v.put("BELONG_DEPT_CD", "");
                                v.put("BELONG_DEPT_NM", "");
                            } else {
                                v.put("BELONG_DEPT_CD", belongDeptCode);
                                v.put("BELONG_DEPT_NM", gridBelongDeptNm);
                            }
                        }

                        break;
                    }
                }
            }
        }
        */
        return vendorList;
    }


    /**
     * 일괄계약서 저장
     * @param formData  화면의 폼데이터
     * @param gridDataM 주서식 그리드 데이터
     * @param gridDataA 부서식 그리드 데이터
     * @param gridDataV 협력회사 그리드 데이터
     * @return
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> ecob0040_doSaveBundleContract(Map<String, String> formData, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridDataV) throws Exception {
        return processBundleContract(Code.CONT_TEMP_SAVE, formData, gridDataM, gridDataA, gridDataV);
    }

    /**
     * 일괄계약서의 저장 또는 전송처리 (상태 빼고는 저장과 전송의 처리가 동일 -> 메일 처리는 생각)
     * @param progressCd 진행상태만 다르게 넣어줌
     * @param formData
     * @param gridDataM
     * @param gridDataA
     * @param gridDataV
     * @return
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> processBundleContract(String progressCd, Map<String, String> formData, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridDataV) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();

        formData.put("FORM_NUM", (String) gridDataM.get(0).get("FORM_NUM"));
        formData.put("CONTRACT_FORM_TYPE", String.valueOf(gridDataM.get(0).get("CONTRACT_FORM_TYPE")));

        // 주소속부서지정유무 (이 값이 1(Y)이면 해당 협력회사 영업사원의 부서코드값을 넣어주고, 0(N)이면 세션의 부서코드를 넣어준다.
        boolean shouldPutBizUserDept = String.valueOf(gridDataM.get(0).get("DEPT_FLAG")).equalsIgnoreCase(Code.M008_1);
        if (!shouldPutBizUserDept) {
            formData.put("BELONG_DEPT_CD", UserInfoManager.getUserInfo().getDeptCd());
        }

        // 일괄계약번호가 없으면 채번
        if (StringUtils.isEmpty(formData.get("BUNDLE_NUM"))) {
            formData.put("BUNDLE_NUM", docNumService.getDocNumber("BC"));
        }

        /* 구매사의 정보를 조회 */
        Map<String, String> buyerInformation = ct0300mapper.getBuyerInformation(null);

        String  orgMAttFileNum = formData.get("M_ATT_FILE_NUM");
        String  orgAttFileNum   = formData.get("ATT_FILE_NUM");
        for (Map<String, Object> vendorDatum : gridDataV) {
            /* 협력회사의 정보를 조회 */
            Map<String, String> vendorInformation = ct0300mapper.getVendorInformation(formData);
            if (shouldPutBizUserDept) {
                if(StringUtils.isEmpty((String)vendorDatum.get("BELONG_DEPT_CD"))) {
                    //throw new Exception("["+vendorDatum.get("VENDOR_CD")+"] 협력회사의 주소속부서가 존재하지 않습니다.");
                }

                formData.put("CONT_DEPT_CD", (String)vendorDatum.get("BELONG_DEPT_CD"));        // 주소속부서를 계약부서 필드에 넣는다.
                formData.put("BELONG_DEPT_CD", (String)vendorDatum.get("BELONG_DEPT_CD"));      // 관리부서 -> 필요없는 것 같은..
            } else {
                formData.put("CONT_DEPT_CD", userInfo.getDeptCd());
                formData.put("BELONG_DEPT_CD", userInfo.getDeptCd());
            }
            /* 계약서 서식에서 입력폼의 내용을 협력회사마다 다르게 처리해준다. */
            String resultContractForm = getReplacedContentsWithInformation(formData.get("mainContractContents"), formData, buyerInformation, vendorInformation);
            formData.put("PROGRESS_CD", progressCd);
            formData.put("FORM_SQ", MAIN_FORM_SQ);


            /* PK가 없으면 insert 한다. */
            if (StringUtils.isEmpty((String) vendorDatum.get("CONT_NUM")) && StringUtils.isEmpty((String) vendorDatum.get("CONT_CNT"))) {
            	String contNum = docNumService.getDocNumber("EC");

                formData.put("CONT_NUM", contNum);
                formData.put("CONT_CNT", "1");
                formData.put("VENDOR_CD", (String) vendorDatum.get("VENDOR_CD"));
                formData.put("VENDOR_PIC_USER_NM", (String) vendorDatum.get("VENDOR_PIC_USER_NM"));
                formData.put("VENDOR_PIC_USER_EMAIL", (String) vendorDatum.get("VENDOR_PIC_USER_EMAIL"));

                formData.put("VENDOR_PIC_CELL_NUM", (String) vendorDatum.get("VENDOR_PIC_CELL_NUM"));



                formData.put("M_ATT_FILE_NUM", "M"+contNum);
                formData.put("ATT_FILE_NUM",  "A"+contNum);

                formData.put("FUUID",orgMAttFileNum);
                formData.put("NEW_FUUID","M"+contNum);
                ct0200mapper.syncFileAttach(formData);

                formData.put("FUUID",orgAttFileNum);
                formData.put("NEW_FUUID","A"+contNum);
                ct0200mapper.syncFileAttach(formData);


                formData.put("CONT_DATE", (progressCd.equals("4210") ? EverDate.getDate() : formData.get("CONT_DATE")));
                ct0300mapper.doInsertECCT(formData);
                formData.put("CONTRACT_TEXT", resultContractForm);
                ct0300mapper.doInsertECRL(formData);
            } else if (StringUtils.isNotEmpty(formData.get("NEW_CONT_CNT"))) {

                formData.put("CONT_NUM", (String) vendorDatum.get("CONT_NUM"));
                formData.put("CONT_CNT", formData.get("NEW_CONT_CNT"));
                formData.put("VENDOR_CD", (String) vendorDatum.get("VENDOR_CD"));
                formData.put("VENDOR_PIC_USER_NM", (String) vendorDatum.get("VENDOR_PIC_USER_NM"));
                formData.put("VENDOR_PIC_USER_EMAIL", (String) vendorDatum.get("VENDOR_PIC_USER_EMAIL"));

                formData.put("VENDOR_PIC_CELL_NUM", (String) vendorDatum.get("VENDOR_PIC_CELL_NUM"));


                formData.put("CONT_DATE", (progressCd.equals("4210") ? EverDate.getDate() : formData.get("CONT_DATE")));
                ct0300mapper.doInsertECCT(formData);

                formData.put("CONTRACT_TEXT", resultContractForm);
                ct0300mapper.doInsertECRL(formData);



            } else {

                formData.put("CONT_NUM", (String) vendorDatum.get("CONT_NUM"));
                formData.put("CONT_CNT", (String) vendorDatum.get("CONT_CNT"));
                formData.put("VENDOR_CD", (String) vendorDatum.get("VENDOR_CD"));
                formData.put("VENDOR_PIC_USER_NM", (String) vendorDatum.get("VENDOR_PIC_USER_NM"));
                formData.put("VENDOR_PIC_USER_EMAIL", (String) vendorDatum.get("VENDOR_PIC_USER_EMAIL"));
                formData.put("VENDOR_PIC_CELL_NUM", (String) vendorDatum.get("VENDOR_PIC_CELL_NUM"));
                formData.put("CONT_DATE", (progressCd.equals("4210") ? EverDate.getDate() : formData.get("CONT_DATE")));
                ct0300mapper.doUpdateECCT(formData);

                formData.put("CONTRACT_TEXT", resultContractForm);
                ct0300mapper.doUpdateECRL(formData);

                // 주계약서를 제외한 부서식은 저장 후에 선택을 뺄 수도 있으므로 기존 데이터를 삭제하고 다시 넣는다.
                ct0300mapper.doDeleteAddECRL(formData);
            }












            // 부서식 처리
            for (int i = 0; i < gridDataA.size(); i++) {

                Map<String, Object> datum = gridDataA.get(i);
                datum.put("CONT_NUM", formData.get("CONT_NUM"));
                datum.put("CONT_CNT", formData.get("CONT_CNT"));
                datum.put("FORM_SQ", datum.get("REL_FORM_SQ"));

                // 부서식의 입력폼도 치환한다.
                String subFormContents = getReplacedContentsWithInformation((String) datum.get("FORM_CONTENTS"), formData, buyerInformation, vendorInformation);
                datum.put("CONTRACT_TEXT", subFormContents);
                ct0300mapper.doInsertAddECRL(datum);
            }



        }

//if(1==1) throw new Exception("======================================");

        return formData;
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

        List<FormControl> formControls = source.getFormControls();
        for (FormControl formControl : formControls) {

            String name = formControl.getName();
            if (EverString.isNotEmpty(name)) {

                /* 서식선택 팝업에서 입력한 정보들과 동일한 이름들이 있는 지 체크 후 치환 */
                if (formData.containsKey(name)) {
                    formControl.setValue(EverString.defaultIfEmpty(String.valueOf(formData.get(name)), ""));
                    ContStringUtil.makeupFormValue(formControl);
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
     * 일괄계약으로 저장한 협력회사 상세목록 조회
     * @param bundleNum
     * @return
     */
    public List<Map<String, Object>> ecob0040_getSavedVendorListForBundleContract(Map<String, String> param) {
        return ct0200mapper.ecob0040_getSavedVendorListForBundleContract(param);
    }

    // 일괄계약서 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecob0040_doDeleteBundleContract(Map<String, String> dataForm) throws Exception {

        if (dataForm != null) {

            List<Map<String, String>> contInfos = ct0200mapper.ecob0040_getBundleContInfo(dataForm);
            for(Map<String, String> contInfo : contInfos) {
                String progressCd = (String) contInfo.get("PROGRESS_CD");
                String signStatus2 = (String) contInfo.get("SIGN_STATUS2");
                if (!(progressCd.equals(Code.CONT_TEMP_SAVE) || progressCd.equals(Code.CONT_SUPPLY_REJECT)
                        || (progressCd.equals(Code.M135_4240) && (EverString.nullToEmptyString(signStatus2).equals(Code.M020_R) || EverString.nullToEmptyString(signStatus2).equals(Code.M020_C))))) {
                    throw new Exception("계약서를 삭제할 수 없는 상태입니다.\n진행상태를 다시 확인해주세요.");
                }
                ct0300mapper.doDeleteECCT(contInfo);
                ct0300mapper.doDeleteECRL(contInfo);
            }
        }
        return msg.getMessage("0017");
    }

    /**
     * 일괄계약서 전송
     * @param formData  화면의 폼데이터
     * @param gridDataM 주서식 그리드 데이터
     * @param gridDataA 부서식 그리드 데이터
     * @param gridDataV 협력회사 그리드 데이터
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecob0040_doSendBundleContract(Map<String, String> formData, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridDataV) throws Exception {
        //processBundleContract(Code.M135_4210, formData, gridDataM, gridDataA, gridDataV);
        processBundleContract(Code.CONT_TEMP_SAVE, formData, gridDataM, gridDataA, gridDataV);
        return msg.getMessageByScreenId("ECOB0040", "0002");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecob0040_doReqSign(Map<String, String> dataForm, List<Map<String, Object>> gridDataM, List<Map<String, Object>> gridDataA, List<Map<String, Object>> gridDataV) throws Exception {
        processBundleContract(Code.CONT_TEMP_SAVE, dataForm, gridDataM, gridDataA, gridDataV);

        if (StringUtils.isNotEmpty(dataForm.get("NEW_CONT_CNT"))) {
        	dataForm.put("CONT_CNT", dataForm.get("NEW_CONT_CNT"));
        }

        Map<String, String> sParam = new HashMap<String, String>();
        sParam.put("APP_DOC_NUM", dataForm.get("APP_DOC_NUM"));
        sParam.put("APP_DOC_CNT", dataForm.get("APP_DOC_CNT"));
        String oldSignStatus = EverString.nullToEmptyString(ct0300mapper.getOldSignStatus(sParam));

        Map<String, String> nDataForm = new HashMap<String, String>();
        nDataForm.putAll(dataForm);

        String signStatus = nDataForm.get("SIGN_STATUS");
        String appDocCnt = nDataForm.get("APP_DOC_CNT");
        if(signStatus.equals("P")) {
            if (EverString.isEmpty(dataForm.get("APP_DOC_NUM"))) {
                String nAppDocNum = docNumService.getDocNumber("AP");
                nDataForm.put("APP_DOC_NUM", nAppDocNum);
                nDataForm.put("APP_DOC_NUM2", nAppDocNum);
            } else {
                nDataForm.put("APP_DOC_NUM", dataForm.get("APP_DOC_NUM"));
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
            nDataForm.put("SIGN_STATUS", "P");
            nDataForm.put("DOC_TYPE", "CONT2");
            approvalService.doApprovalProcess(nDataForm, dataForm.get("approvalFormData"), dataForm.get("approvalGridData"));
        }

        for(Map<String, Object> vendorData : gridDataV) {
//            nDataForm.put("PROGRESS_CD", Code.M135_4240); // 계약체결 기안
//            nDataForm.put("SIGN_STATUS", null);
//            nDataForm.put("SIGN_STATUS2", Code.M020_P);
            nDataForm.put("CONT_NUM", dataForm.get("CONT_NUM"));
            nDataForm.put("CONT_CNT", dataForm.get("CONT_CNT"));

            dataForm.put("PROGRESS_CD", Code.CONT_TEMP_SAVE);
            dataForm.put("SIGN_STATUS", Code.M020_P);


            ct0300mapper.doUpdateECCT4NotesIF(nDataForm);
        }

        return (signStatus.equals("P") ? msg.getMessage("0023") : msg.getMessage("0031"));
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void ecob0040_doSignContractXXXXXXXXXXX(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();

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

        try {
        	String buyerCd = formData.get("BUYER_CD");
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
        String userDn = certDn[0];  // 필요하면 저장한다.

        // 서명된 값을 서명테이블에 저장
        //formData.put("SIGN_ID", "KDS");
        formData.put("SIGN_VALUE", serverSignedContents);
        ct0300mapper.doDeleteECSV(formData);
        ct0300mapper.doInsertECSV(formData);

        // 계약체결완료로 상태 변경
        formData.put("PROGRESS_CD", Code.CONT_COMPLETE);
        ct0300mapper.doUpdateStatusOfECCT(formData);

        resp.setResponseMessage(msg.getMessageByScreenId("ECOB0040", "0007"));
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
        map.put("CONT_CNT", contInfo.get("CONT_CNT"));
        contInfo = ct0300mapper.getContractInformation(map);

        // 클라이언트 툴킷으로 서명 시 주계약서, 부서식의 서명값을 한번의 인증서 서명으로 각각 받아올 수 없고
        // 각각 서명을 해야 서명값을 받아올 수 있기 때문에
        // 서버에서도 주계약서와 부서식의 내용을 하나로 합쳐서 한번에 서명하는 방식으로 처리한다.



        String serverSignedContents = "Test Server SignedContents";
        // 서명된 값을 서명테이블에 저장
        contInfo.put("SIGN_VALUE", serverSignedContents);
        ct0300mapper.doInsertECSV(contInfo);

        // 계약체결완료로 상태 변경
        map.put("SIGN_STATUS2", "E");
        map.put("PROGRESS_CD", Code.CONT_SUPPLY_READY);
        ct0300mapper.updateSignStatusCont(map);

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






























}
