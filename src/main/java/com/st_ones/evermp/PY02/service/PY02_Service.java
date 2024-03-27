package com.st_ones.evermp.PY02.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.PY02.PY02_Mapper;
import com.st_ones.evermp.TX01.TX01_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Service(value = "py02_Service")
public class PY02_Service extends BaseService {

    @Autowired private QueryGenService queryGenService;
    @Autowired private DocNumService docNumService;
    @Autowired private EverMailService everMailService;
    @Autowired private EverSmsService everSmsService;
    @Autowired PY02_Mapper py02_Mapper;
    @Autowired MessageService msg;

    /** ******************************************************************************************
     * 운영사 > 정산관리 > 매입정산 > 매입정산현황
     */
    public List<Map<String, Object>> py02010_doSearch(Map<String, String> param) throws Exception {
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            param = getQueryParam(param, "UPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
            param = getQueryParam(param, "UPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return py02_Mapper.py02010_doSearch(param);
    }

    /** ******************************************************************************************
     * 운영사 > 정산관리 > 매입정산 > 매입현황
     */
    public List<Map<String, Object>> py02020_doSearch(Map<String, String> param) throws Exception {
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            param = getQueryParam(param, "UPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
            param = getQueryParam(param, "UPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
        }

        return py02_Mapper.py02020_doSearch(param);
    }

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입마감대상
     */
    public List<Map<String, Object>> py02030_doSearch(Map<String, String> param) {
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
            param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
            param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
            param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return py02_Mapper.py02030_doSearch(param);
    }
    @Autowired TX01_Mapper tx01_mapper;
    // 매입마감 확정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py02030_doSaveConfirm(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String multiCd = "003";


    	Map<String,String> param = new HashMap<String,String>();
    	param.put("TYPE","P");
    	param.put("CLOSE_YEAR",form.get("CLOSE_DATE").substring(0,4));
    	param.put("CLOSE_MONTH",form.get("CLOSE_DATE").substring(4,6));
    	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
    	if (!"0".equals(chk)) {
    		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
    	}


        String CLOSING_NO = docNumService.getDocNumber("CAP"); //매입번호 채번



        for(Map<String, Object> gridData : gridList) {

        	if(  py02_Mapper.chkCloseAP(gridData) !=0) {
        		throw new Exception(msg.getMessageByScreenId("PY02_030", "016"));
        	}

            gridData.put("CLOSING_NO", CLOSING_NO);
            gridData.put("CLOSING_YEAR_MONTH", form.get("CLOSE_MONTH"));
//                gridData.put("CLOSING_CNT", form.get("CLOSE_CNT"));
            gridData.put("CLOSING_CNT", "9");
            gridData.put("DOC_TYPE", "UI");
            gridData.put("RMK", form.get("RMK"));
            gridData.put("CLOSE_DATE", form.get("CLOSE_DATE"));

            py02_Mapper.py02030_doSaveConfirmAPAR(gridData);
            py02_Mapper.py02030_doSaveConfirmGRDT(gridData);
        }


        return msg.getMessageByScreenId("PY02_030", multiCd);
    }

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입마감 현황
     */
    public List<Map<String, Object>> py02040_doSearch(Map<String, String> param) {
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
            param = getQueryParam(param, "YPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
            param = getQueryParam(param, "YPODT.ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_03");
            param = getQueryParam(param, "YPODT.CUST_ITEM_CD", param.get("ITEM_DESC"), "ITEM_DESC_04");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
        }

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param = getQueryParam(param, "YPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return py02_Mapper.py02040_doSearch(param);
    }

    // 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py02040_doDelete(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            if(py02_Mapper.chkTaxCreAP(gridData) !=0 ) {
        		throw new Exception(msg.getMessageByScreenId("PY02_040", "033"));
            }

        	py02_Mapper.py02040_doDeleteAPAR(gridData);

            py02_Mapper.py02040_doDeleteGRDT(gridData);
        }

        //if(1==1) throw new Exception("=========================================================");
        return msg.getMessageByScreenId("PY02_040", "006");
    }


    // 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py2040_doSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
        	py02_Mapper.py2040_UPDATE_APAR(gridData);
        }

        return msg.getMessageByScreenId("PY02_040", "023");
    }

    // 매입계산서 생성
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py02040_doTaxCreate(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String IN_KEY =userInfo.getUserId() + EverDate.getDate() + EverDate.getTime();
        String multiCd = "010";


    	Map<String,String> param = new HashMap<String,String>();
    	param.put("TYPE","P");
    	param.put("CLOSE_YEAR",form.get("CLOSE_YEAR"));
    	param.put("CLOSE_MONTH",form.get("CLOSE_MONTH"));
    	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
    	if (!"0".equals(chk)) {
    		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
    	}


        for(Map<String, Object> gridData : gridList) {
            gridData.put("IN_KEY", IN_KEY);

            py02_Mapper.py02040_doTaxCreateINSERT_TTIT(gridData);
        }

        form.put("IN_KEY", IN_KEY);
        String TAX_NUM_CHK = py02_Mapper.py02040_doTaxCreateSELECT_TAX_CHK(form);

        if("0".equals(TAX_NUM_CHK)) {

            form.put("IN_OUT_TYPE", "IN");
            List<Map<String, Object>> listH_IN = py02_Mapper.py02040_doTaxCreateSELECT_TAX(form);

            for(Map<String, Object> dataH : listH_IN) {
                String TAX_NUM = docNumService.getDocNumber("GTAX");
                dataH.put("TAX_NUM", TAX_NUM);
                dataH.put("IN_OUT_TYPE", "IN");
                dataH.put("SALES_TYPE", "P");		// 매출매입구분 - S:매출, P:매입
                dataH.put("RQ_RE_TYPE", "2");		// 청구영수구분 - 2:청구, 1:영수
                dataH.put("ISSUE_DATE", form.get("ISSUE_DATE"));	// yyyy-mm-dd

                py02_Mapper.py02040_doTaxCreateIN_INSERT_TTIH(dataH);

                List<Map<String, Object>> listD = py02_Mapper.py02040_doTaxCreateSELECT_TTID(dataH);

                for (Map<String, Object> dataD : listD) {
                    py02_Mapper.py02040_doTaxCreateINSERT_TTID(dataD);
                    if(py02_Mapper.chkTaxCreAP(dataD) !=0 ) {
                		throw new Exception(msg.getMessageByScreenId("PY02_040", "032"));
                    }
                    py02_Mapper.py02040_doTaxCreateUPDATE_APAR(dataD);
                }
            }
        } else {
            multiCd = "011";
        }

            //py02_Mapper.py02040_doTaxCreateDELETE_TTIT(form);
        //if(1==1) throw new Exception("=========================================");
        return msg.getMessageByScreenId("PY02_040", multiCd);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doAlarmInvoiceDelay(List<Map<String, Object>> gridList) throws Exception {
        Map<String, Object> mailTargetList = new HashMap<String,Object>();
        for (Map<String, Object> gridData : gridList) {
            String vendorCd = String.valueOf(gridData.get("VENDOR_CD"));
            String poNo = String.valueOf(gridData.get("PO_NO"));

            if (mailTargetList.containsKey(vendorCd)) {
                mailTargetList.put(vendorCd, mailTargetList.get(vendorCd) + "," + poNo);
            } else {
                mailTargetList.put(vendorCd,poNo);
            }
        }
        sendEmail(mailTargetList);
        return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void sendEmail(Map<String, Object> rqhdData) throws Exception {
        // E-Mail, SMS 발송
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");

        String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
        String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
        String contextNm  = PropertiesManager.getString("eversrm.system.contextName");

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

        String fileContents   = "";

        Iterator<String> iterator = rqhdData.keySet().iterator();
        while (iterator.hasNext()) {
            String vendorCd = iterator.next();
            String poNo = String.valueOf(rqhdData.get(vendorCd));

            Map<String,Object> param = new HashMap<String,Object>();
            param.put("VENDOR_CD", vendorCd);
            param.put("PO_NO", poNo);

            List<Map<String, String>> vendorList = py02_Mapper.getInvoiceDelayItemList(param);

            for(Map<String, String> vendorData : vendorList) {
                fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
                fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(vendorData.get("VENDOR_USER_NM")));    // 메일 수신자
                fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

                String CONTENTS = "당월 마감이 확정되었습니다. </br> 시스템에서 확인하시길 바랍니다.";
                fileContents = EverString.replace(fileContents, "$CONTENTS$", CONTENTS);
                fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
                fileContents = EverString.rePreventSqlInjection(fileContents);

                    Map<String, String> mdata = new HashMap<String, String>();
                    mdata.put("SUBJECT", "[대명소노시즌] 당월 마감이 확정되었습니다.");
                    mdata.put("CONTENTS_TEMPLATE", fileContents);
                    mdata.put("RECV_USER_ID", EverString.nullToEmptyString(vendorData.get("VENDOR_USER_ID")));
                    mdata.put("RECV_USER_NM", EverString.nullToEmptyString(vendorData.get("VENDOR_USER_NM")));
                    mdata.put("RECV_EMAIL", EverString.nullToEmptyString(vendorData.get("VENDOR_USER_EMAIL")));
                    mdata.put("REF_MODULE_CD", "PO"); // 참조모듈
                    // 메일전송.
                    everMailService.sendMail(mdata);
                    mdata.clear();

                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("SUBJECT","[대명소노시즌] 당월 마감이 확정되었습니다.");
                    sdata.put("CONTENTS", "[대명소노시즌] 당월 마감이 확정되었습니다. 시스템에서 확인바랍니다."); // 전송내용
                    sdata.put("RECV_USER_ID", EverString.nullToEmptyString(vendorData.get("VENDOR_USER_ID")));
                    sdata.put("RECV_USER_NM", EverString.nullToEmptyString(vendorData.get("VENDOR_USER_NM")));
                    sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(vendorData.get("VENDOR_CELL_NUM")));
                    sdata.put("REF_MODULE_CD", "PO"); // 참조모듈
                    // SMS 전송.
                    everSmsService.sendSms(sdata);
                    sdata.clear();
            }
        }
    }

    public Map<String,String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
        param.put("COL_NM", COL_NM);
        param.put("COL_VAL", COL_VAL);

        param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

        return param;
    }

}
