package com.st_ones.evermp.TX02.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */


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
import com.st_ones.evermp.DZ.DZ_Mapper;
import com.st_ones.evermp.PY02.PY02_Mapper;
import com.st_ones.evermp.TX01.TX01_Mapper;
import com.st_ones.evermp.TX01.service.TX01_Service;
import com.st_ones.evermp.TX02.TX0201_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


@Service(value = "tx02_Service")
public class TX0201_Service extends BaseService {

    @Autowired private DocNumService docNumService;
    @Autowired private MessageService msg;
    @Autowired private TX0201_Mapper tx0201Mapper;
    @Autowired private QueryGenService queryGenService;
    @Autowired private TX01_Service tx01_Service;
    @Autowired TX01_Mapper tx01_Mapper;
    @Autowired DZ_Mapper dz_mapper;
    @Autowired PY02_Mapper py02_mapper;
    @Autowired TX01_Mapper tx01_mapper;
    @Autowired private EverMailService everMailService;
    @Autowired private EverSmsService everSmsService;
    @Autowired PY02_Mapper py02_Mapper;

    private static final String AID_DEV = "z1";
    private static final String AID_PROD = "y5";

    /**
     * sendbill 사용자 조회
     */

    public List<Map<String, Object>> tx02010_doSearch(Map<String, String> param) throws Exception {
        return tx0201Mapper.tx02010_doSearch(param);
    }

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입세금계산서 현황
     */
    public List<Map<String, Object>> tx02020_doSearch(Map<String, String> param) throws Exception {
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

        return tx0201Mapper.tx02020_doSearch(param);
    }

    public List<Map<String, Object>> tx02020_doSearchTTID(Map<String, String> param) throws Exception {
        return tx0201Mapper.tx02020_doSearchTTID(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx02020_doUpdateTTID(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            tx0201Mapper.tx02020_doUpdateTTID(gridData);
            tx0201Mapper.tx02020_doUpdateTTID_TTIH(gridData);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx02020_doSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            gridData.put("SAVE_YN", "Y");
            tx0201Mapper.tx02020_doSaveTTIH(gridData);
        }

        return msg.getMessageByScreenId("TX02_020", "016");
    }

    // 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx02020_doTaxCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> mapCHK;
        String BILLSTAT;

        for(Map<String, Object> data : gridList) {
            // 아래 주석 풀것

            //mapCHK = tx01_Mapper.tx01010_doSendBillSELECT_BILL_STAT_CHK(data);
            //BILLSTAT = String.valueOf(mapCHK.get("BILLSTAT"));
            BILLSTAT = "D";

            if("D".equals(BILLSTAT)) {
                tx0201Mapper.tx02020_doTaxCancelTTIH_AR(data);
                tx0201Mapper.tx02020_doTaxCancelTTID_AR(data);

                data.put("MGRNO",data.get("TAX_NUM"));
//              tx01_mapper.delSLHD(data);
//            	tx01_mapper.delSLDT(data);

            } else {
                throw new Exception(msg.getMessageByScreenId("TX01_010", "034"));
            }

            tx0201Mapper.tx02020_doTaxCancelAPAR(data);
        }

        return msg.getMessageByScreenId("TX02_020", "003");
    }

    // 병합
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx02020_doSaveMerge(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        String TAX_NUM = "";

        for(Map<String, Object> data : gridList) {
            tx0201Mapper.tx02020_doTaxCancelTTIH_AR(data);
            tx0201Mapper.tx02020_doTaxCancelTTID_AR(data);

            if("".equals(TAX_NUM)) {
                TAX_NUM = "'" + data.get("TAX_NUM") + "'";
            } else {
                TAX_NUM += ",'" + data.get("TAX_NUM") + "'";
            }
        }

        UserInfo userInfo = UserInfoManager.getUserInfo();
        String IN_KEY =userInfo.getUserId() + EverDate.getDate() + EverDate.getTime();

        form.put("IN_KEY", IN_KEY);
        form.put("TAX_NUM", TAX_NUM);

        List<Map<String, Object>> list = py02_mapper.py02040_doSearch(form);

        for(Map<String, Object> data : list) {
            data.put("IN_KEY", IN_KEY);

            py02_mapper.py02040_doTaxCreateINSERT_TTIT(data);
        }

        String TAX_NUM_CHK = py02_mapper.py02040_doTaxCreateSELECT_TAX_CHK(form);

        if("0".equals(TAX_NUM_CHK)) {
            form.put("IN_OUT_TYPE", "IN");
            form.put("SELL_TAX_TYPE", "100");
            List<Map<String, Object>> listH_OUT = py02_mapper.py02040_doTaxCreateSELECT_TAX(form);

            for(Map<String, Object> dataH : listH_OUT) {
                String NEW_TAX_NUM = docNumService.getDocNumber("GTAX");

                dataH.put("TAX_NUM", NEW_TAX_NUM);
                dataH.put("IN_OUT_TYPE", "IN");
                dataH.put("SALES_TYPE", "P");        // 매출매입구분 - S:매출, P:매입
                dataH.put("RQ_RE_TYPE", "2");        // 청구영수구분 - 2:청구, 1:영수

                py02_mapper.py02040_doTaxCreateIN_INSERT_TTIH(dataH);

                List<Map<String, Object>> listD = py02_mapper.py02040_doTaxCreateSELECT_TTID(dataH);

                for (Map<String, Object> dataD : listD) {
                    py02_mapper.py02040_doTaxCreateINSERT_TTID(dataD);
                    py02_mapper.py02040_doTaxCreateUPDATE_APAR(dataD);
                }
            }
        } else {
            throw new Exception(msg.getMessageByScreenId("TX02_020", "058"));
        }

        return msg.getMessageByScreenId("TX02_020", "055");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx02020_doSavePayment(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> data : gridList) {
            tx0201Mapper.tx02020_doSavePaymentTTIH(data);
        }

        return msg.getMessageByScreenId("TX02_020", "016");
    }

    // 전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx02020_doUniPostTrans(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> mapRtn = new HashMap<>();
        String multiCd;
        String TEST_EMAIL;
        boolean isDevelopmentMode;
        String BILLSEQ;

//        // 개발사이트 (상태정검)  (https 사용 , 포트 47543)
//        String url = "https://unidev.unipost.co.kr:47543/mbill-etaxr-server/api/rest/v3/searchStatus";
//        // etax-server 호출시 사용되는 Authorization값(username:password)
//        //요청데이터
//        String bodyText = "{\n" +
//                "    \"aid\" : \"z1\",\n" +
//                "    \"exd_ids\":[\"202009031127447866416551\"],\n" +
//                "    \"inv_sign\" : \"\"\n" +
//                "}";
////         api 호출
//        tx01_Service.callHttpXml(url, bodyText, "", null, mapRtn);

        for(Map<String, Object> data : gridList) {
            tx01_Mapper.tx01010_doSaveTTIH(data);
        }

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");
//
        int cnt = 0;
        for(Map<String, Object> data : gridList) {
            cnt++;

            BILLSEQ = docNumService.getDocNumber("UPTAX");
            data.put("BILLSEQ", BILLSEQ);

            if(isDevelopmentMode){
                data.put("SUSER_EMAIL", TEST_EMAIL);
                data.put("RUSER_EMAIL", TEST_EMAIL);
                data.put("TEST_YN", "Y");
            } else {
                data.put("TEST_YN", "N");
            }

            Map<String, Object> mapTTID = tx01_Mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);

            try {
                tx01_Service.receivebill(data, mapTTID, cnt, mapRtn, "P");
            } catch (Exception e) {
                throw new Exception(e);
            }
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "023";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX02_020", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    // 재전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx02020_doUniPostReSend(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String multiCd;
        String TEST_EMAIL;
        boolean isDevelopmentMode;

        // 개발사이트 (상태정검)  (https 사용 , 포트 47543)
//        String url = "https://unidev.unipost.co.kr:47543/mbill-etaxr-server/api/rest/v3/searchStatus";
//        //요청데이터
//        String bodyText = "{\n" +
//                "    \"aid\" : \"z1\",\n" +
//                "    \"exd_ids\":[\"202009031127447866416551\"],\n" +
//                "    \"inv_sign\" : \"\"\n" +
//                "}";
////         api 호출
//        tx01_Service.callHttpXml(url, bodyText, "", null, mapRtn);

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");

        int cnt = 0;
        for(Map<String, Object> data : gridList) {
            cnt++;

            if(isDevelopmentMode){
                data.put("SUSER_EMAIL", TEST_EMAIL);
                data.put("RUSER_EMAIL", TEST_EMAIL);
                data.put("TEST_YN", "Y");
            } else {
                data.put("TEST_YN", "N");
            }

            data.put("BILLSEQ", data.get("TAX_BILLSEQ"));

            Map<String, Object> mapTTID = tx01_Mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);

            tx01_Service.receivebill(data, mapTTID, cnt, mapRtn, "R");
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "040";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX02_020", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    // 취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx02020_doUniPostCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, String> mapCHK;
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String BILL_STAT_TYPE;
        String BILLSTAT;
        String multiCd;
        String TEST_EMAIL;
        boolean isDevelopmentMode;
        String url;
        String bodyText;
        String AID;

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");

        if(isDevelopmentMode){
            url = PropertiesManager.getString("unipost.tax.site.dev") + "/api/rest/v3/receivestate";
            AID = AID_DEV;
        } else {
            url = PropertiesManager.getString("unipost.tax.site.prod") + "/api/rest/v3/receivestate";
            AID = AID_PROD;
        }

        int cnt = 0;
        for(Map<String, Object> data : gridList) {
            if(isDevelopmentMode){
                data.put("SUSER_EMAIL", TEST_EMAIL);
                data.put("RUSER_EMAIL", TEST_EMAIL);
                data.put("TEST_YN", "Y");
            } else {
                data.put("TEST_YN", "N");
            }

            if("NN".equals(data.get("BILL_STAT_TYPE"))) {
                data.put("BILLSEQ", data.get("TAX_BILLSEQ"));

                String exd_id = EverString.nullToEmptyString(data.get("TAX_EXD_ID"));
                String inv_sign = "100".equals(EverString.nullToEmptyString(data.get("TAX_SEND_TYPE")))?"":"X";
                String biz_tocharlesconfirmstatus = "DR";
                String reason = EverString.nullToEmptyString(data.get("TAX_CANCEL_REASON"));

                try {
                    bodyText = "[\n" +
                            "{\n" +
                            "  \"aid\":\""+AID+"\",\n" +
                            "  \"exd_id\": \""+exd_id+"\",\n" +
                            "  \"inv_sign\":\""+inv_sign+"\",\n" +
                            "  \"biz_tocharlesconfirmstatus\":\""+biz_tocharlesconfirmstatus+"\",\n" +
                            "  \"reason\":\""+reason+"\"\n" +
                            "}\n" +
                            "]\n";

                    tx01_Service.callHttpXml(url, bodyText, "DR", data, mapRtn);
                } catch (Exception e) {
                    throw new Exception(e);
                }
            } else if("Y".equals(data.get("BILL_STAT_TYPE"))) {
                cnt++;

                String BILLSEQ = docNumService.getDocNumber("UPTAX");
                data.put("BILLSEQ", BILLSEQ);

                Map<String, Object> mapTTID = tx01_Mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);

                try {
                    tx01_Service.receivebill(data, mapTTID, cnt, mapRtn, "C");
                } catch (Exception e) {
                    throw new Exception(e);
                }
            }
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "036";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX02_020", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    // 메일 재전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx02020_doUniPostMailReSend(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String multiCd;
        String TEST_EMAIL;
        boolean isDevelopmentMode;
        String BILLSEQ;
        String url;
        String bodyText;
        String AID;

//        // 개발사이트 (상태정검)  (https 사용 , 포트 47543)
//        String url = "https://unidev.unipost.co.kr:47543/mbill-etaxr-server/api/rest/v3/searchStatus";
//        //요청데이터
//        String bodyText = "{\n" +
//                "    \"aid\" : \""+AID+"\",\n" +
//                "    \"exd_ids\":[\"202009031127447866416551\"],\n" +
//                "    \"inv_sign\" : \"\"\n" +
//                "}";
////         api 호출
//        tx01_Service.callHttpXml(url, bodyText, "", null, mapRtn);

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");
//
        if(isDevelopmentMode){
            url = PropertiesManager.getString("unipost.tax.site.dev") + "/api/rest/v3/receiveMail";
            AID = AID_DEV;
        } else {
            url = PropertiesManager.getString("unipost.tax.site.prod") + "/api/rest/v3/receiveMail";
            AID = AID_PROD;
        }

        int cnt = 0;
        for(Map<String, Object> data : gridList) {
            cnt++;

            if(isDevelopmentMode){
                data.put("SUSER_EMAIL", TEST_EMAIL);
                data.put("RUSER_EMAIL", TEST_EMAIL);
                data.put("TEST_YN", "Y");
            } else {
                data.put("TEST_YN", "N");
            }

            data.put("BILLSEQ", data.get("TAX_BILLSEQ"));

            String exd_id = EverString.nullToEmptyString(data.get("TAX_EXD_ID"));
            String inv_sign = "100".equals(EverString.nullToEmptyString(data.get("TAX_SEND_TYPE")))?"":"X";
            String receiver = EverString.nullToEmptyString(data.get("SUSER_EMAIL"));

            try {
                //요청데이터
                bodyText = "{\n" +
                        "  \"aid\":\""+AID+"\",\n" +
                        "  \"exd_id\": \""+exd_id+"\",\n" +
                        "  \"inv_sign\":\""+inv_sign+"\",\n" +
                        "  \"receiver\":\""+receiver+"\"\n" +
                        "}　\n";
//         api 호출
                tx01_Service.callHttpXml(url, bodyText, "", null, mapRtn);
            } catch (Exception e) {
                throw new Exception(e);
            }
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "050";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX02_020", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doAlarmInvoiceDelay(List<Map<String, Object>> gridList) throws Exception {
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

    	Map<String, Object> mailTargetList = new HashMap<String,Object>();
        for (Map<String, Object> gridData : gridList) {
            String vendorCd = String.valueOf(gridData.get("SCOM_CODE"));
            if (mailTargetList.containsKey(vendorCd)) {
            	mailTargetList.put(vendorCd, mailTargetList.get(vendorCd));
            } else {
            	mailTargetList.put(vendorCd,"*");
            }

        }

		Iterator<String> iterator = mailTargetList.keySet().iterator();
		while (iterator.hasNext()) {
			String vendorCd = iterator.next();
			   Map<String,Object> param = new HashMap<String,Object>();
			   param.put("VENDOR_CD",vendorCd);

		       List<Map<String, Object>> rowDataList = tx0201Mapper.getInvoiceDelayItemList(param);

		       for( Map<String, Object> rowData : rowDataList ) {

		            // 공급사 품목담당자에게 mail 발송하기
		            fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		            fileContents = EverString.replace(fileContents, "$CURRENT_DATE$", EverString.nullToEmptyString(rowData.get("CUR_DATE")));    // 현재일자
		            fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(rowData.get("VENDOR_USER_NM")));    // 메일 수신자
		            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

		            String CONTENTS = "당월 세금계산서 발행 대상 확인 후 발행바랍니다.";
		            fileContents = EverString.replace(fileContents, "$CONTENTS$", CONTENTS);
		            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
		            fileContents = EverString.rePreventSqlInjection(fileContents);

		            Map<String, String> mdata = new HashMap<String, String>();
		            mdata.put("SUBJECT", "[대명소노시즌] 당월 세금계산서 발행 대상이 확정되었습니다.");
		            mdata.put("CONTENTS_TEMPLATE", fileContents);
		            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VENDOR_USER_ID")));
		            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VENDOR_USER_NM")));
		            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(rowData.get("VENDOR_USER_EMAIL")));
		            mdata.put("REF_MODULE_CD", "PO"); // 참조모듈
		            // SMS 발송
		            everMailService.sendMail(mdata);
		            mdata.clear();

		            Map<String, String> sdata = new HashMap<String, String>();
		            sdata.put("SUBJECT","[대명소노시즌] 당월 세금계산서 발행 대상이 확정되었습니다.");
		            sdata.put("CONTENTS", "[대명소노시즌] 당월 세금계산서 발행 대상 확인 후 발행바랍니다."); // 전송내용
		            sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VENDOR_USER_ID")));
		            sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VENDOR_USER_NM")));
		            sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(rowData.get("VENDOR_CELL_NUM")));
		            sdata.put("REF_MODULE_CD", "PO"); // 참조모듈
		            // SMS발송
		            everSmsService.sendSms(sdata);
		            mdata.clear();
		        }




		}



        return msg.getMessage("0001");
    }

    // 매출회계세금계산서 목록, 조회
    public List<Map<String, Object>> tx02030_doSearch(Map<String, String> param) throws Exception {
        String TR_CD;

        List<Map<String, Object>> list = tx0201Mapper.tx02030_doSearch(param);

        for(Map<String, Object> data : list) {
            if("".equals(data.get("TR_CD")) || data.get("TR_CD") == null) {
                //TR_CD = dz_mapper.tx01020_search_TR_CD(data);

                //data.put("TR_CD", TR_CD);
            }
        }

        return list;
    }

    /**
     * 입력값의 유사어를 찾아서 like로 묶어서 리턴
     * @param param 파라메터
     * @param COL_NM 컬럼명
     * @param COL_VAL 컬럼값
     * @param key 바인딩명
     * @return map
     */
    private Map<String,String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
        param.put("COL_NM", COL_NM);
        param.put("COL_VAL", COL_VAL);

        param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

        return param;
    }

}
