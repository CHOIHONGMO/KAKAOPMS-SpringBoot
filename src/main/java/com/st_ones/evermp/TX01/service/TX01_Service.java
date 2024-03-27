package com.st_ones.evermp.TX01.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.interceptor.SessionInterceptor;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.KISA_SEED_CBC;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.DZ.DZ_Mapper;
import com.st_ones.evermp.PY01.PY01_Mapper;
import com.st_ones.evermp.PY02.PY02_Mapper;
import com.st_ones.evermp.TX01.TX01_Mapper;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.apache.xmlbeans.impl.util.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.UnsupportedEncodingException;
import java.net.InetAddress;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "tx01_Service")
public class TX01_Service extends BaseService {

    @Autowired private QueryGenService queryGenService;
    @Autowired private DocNumService docNumService;
    @Autowired TX01_Mapper tx01_mapper;
    @Autowired PY01_Mapper py01_mapper;
    @Autowired PY02_Mapper py02_mapper;
    @Autowired DZ_Mapper dz_mapper;
    @Autowired MessageService msg;

    private Logger logger = LoggerFactory.getLogger(SessionInterceptor.class);
    private static final String DEFAULT_IV = "unipostetaxserver"; // CBC 대칭키 (고정키값)
    private static byte bszIV[] = DEFAULT_IV.getBytes();
    private static String AID_DEV = "z1";
    private static String AID_PROD = "y5";
    private static final String COM_REGNO = "8878600376";
    private static final String ENVKEY = "8878600376060100";

    /**
     * 운영사 > 정산관리 > 매출정산 > 매출세금계산서 현황
     */
    public List<Map<String, Object>> tx01010_doSearch(Map<String, String> param) throws Exception {
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

        return tx01_mapper.tx01010_doSearch(param);
    }

    public List<Map<String, Object>> tx01010_doSearchTTID(Map<String, String> param) throws Exception {
        return tx01_mapper.tx01010_doSearchTTID(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx01010_doUpdateTTID(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            tx01_mapper.tx01010_doUpdateTTID(gridData);
            tx01_mapper.tx01010_doUpdateTTID_TTIH(gridData);
        }
    }

    public String tx01010_doSearchBILLSTAT(Map<String, String> param) throws Exception {
        return tx01_mapper.tx01010_doSearchBILLSTAT(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx01010_doSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            gridData.put("SAVE_YN", "Y");
            tx01_mapper.tx01010_doSaveTTIH(gridData);
        }

        return msg.getMessageByScreenId("TX01_010", "016");
    }

    // 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx01010_doTaxCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> mapCHK;
        String BILLSTAT;

        for(Map<String, Object> data : gridList) {
            // 아래 주석 풀것

            //mapCHK = tx01_Mapper.tx01010_doSendBillSELECT_BILL_STAT_CHK(data);
            //BILLSTAT = String.valueOf(mapCHK.get("BILLSTAT"));
            BILLSTAT = "D";

            if("D".equals(BILLSTAT)) {
                tx01_mapper.tx01010_doTaxCancelTTIH_AP(data);
                tx01_mapper.tx01010_doTaxCancelTTID_AP(data);
                data.put("MGRNO",data.get("TAX_NUM"));
//                tx01_mapper.delSLHD(data);
//            	tx01_mapper.delSLDT(data);

            } else {
                throw new Exception(msg.getMessageByScreenId("TX01_010", "034"));
            }

            tx01_mapper.tx01010_doTaxCancelAPAR(data);
        }

        return msg.getMessageByScreenId("TX01_010", "003");
    }

    // 병합
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx01010_doSaveMerge(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        String TAX_NUM = "";

        for(Map<String, Object> data : gridList) {
            tx01_mapper.tx01010_doTaxCancelTTIH_AP(data);
            tx01_mapper.tx01010_doTaxCancelTTID_AP(data);

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

        List<Map<String, Object>> list = py01_mapper.py01020_doSearch(form);

        for(Map<String, Object> data : list) {
            data.put("IN_KEY", IN_KEY);

            py01_mapper.py01020_doTaxCreateINSERT_TTIT(data);
        }

        String TAX_NUM_CHK = py01_mapper.py01020_doTaxCreateSELECT_TAX_CHK(form);

        if("0".equals(TAX_NUM_CHK)) {
            form.put("IN_OUT_TYPE", "OUT");
            form.put("SELL_TAX_TYPE", "100");
            List<Map<String, Object>> listH_OUT = py01_mapper.py01020_doTaxCreateSELECT_TAX(form);

            for(Map<String, Object> dataH : listH_OUT) {
                String NEW_TAX_NUM = docNumService.getDocNumber("GTAX");

                dataH.put("TAX_NUM", NEW_TAX_NUM);
                dataH.put("IN_OUT_TYPE", "OUT");
                dataH.put("SALES_TYPE", "S");        // 매출매입구분 - S:매출, P:매입
                dataH.put("RQ_RE_TYPE", "2");        // 청구영수구분 - 2:청구, 1:영수

                py01_mapper.py01020_doTaxCreateOUT_INSERT_TTIH(dataH);

                List<Map<String, Object>> listD = py01_mapper.py01020_doTaxCreateSELECT_TTID(dataH);

                for (Map<String, Object> dataD : listD) {
                    py01_mapper.py01020_doTaxCreateINSERT_TTID(dataD);
                    py01_mapper.py01020_doTaxCreateUPDATE_APAR(dataD);
                }
            }
        } else {
            throw new Exception(msg.getMessageByScreenId("TX01_010", "058"));
        }

        return msg.getMessageByScreenId("TX01_010", "055");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx01010_doSaveDeposit(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> data : gridList) {
            tx01_mapper.tx01010_doSaveDepositTTIH(data);
        }

        return msg.getMessageByScreenId("TX01_010", "016");
    }

    // 전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doUniPostTrans(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        Map<String, Object> mapSum = new HashMap<String, Object>();
        String BILL_CHK_YN = "N";
        String multiCd;
        String TEST_YN;
        String TEST_EMAIL;
        boolean isDevelopmentMode;
        boolean isAmtCompare = true;
        String BILLSEQ;

        for(Map<String, Object> data : gridList) {
            tx01_mapper.tx01010_doSaveTTIH(data);
        }

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");
//
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

            BILLSEQ = docNumService.getDocNumber("UPTAX");
            data.put("BILLSEQ", BILLSEQ);

            Map<String, Object> mapTTID = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);

            try {
                receivebill(data, mapTTID, cnt, mapRtn, "P");
            } catch (Exception e) {
                throw new Exception(e);
            }
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "023";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doSendBillTrans(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        Map<String, Object> mapSum = new HashMap<String, Object>();
        String BILL_CHK_YN = "N";
        String multiCd;
        String TEST_YN;
        String TEST_EMAIL;
        boolean isDevelopmentMode;
        boolean isAmtCompare = true;
        String BILLSEQ;

        for(Map<String, Object> data : gridList) {
            tx01_mapper.tx01010_doSaveTTIH(data);
        }

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");

        for(Map<String, Object> data : gridList) {	// 샌드빌로 인터페이스 시킴, 링크테이블
            mapSum = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUMAMT(data);
            float SUP_AMT = Float.valueOf(String.valueOf(mapSum.get("SUP_AMT")));
            float TAX_AMT = Float.valueOf(String.valueOf(mapSum.get("TAX_AMT")));

            if(TAX_AMT != Float.valueOf(String.valueOf(data.get("TAX_AMT")))) {
                throw new Exception(String.valueOf(data.get("TAX_NUM")));
            }

            BILLSEQ = docNumService.getDocNumber("SBTAX");

            data.put("BILLSEQ", BILLSEQ);
            data.put("E_BILL_ASP_STAT_TYPE", "N");

            tx01_mapper.tx01010_doSaveUPDATE_TTIH(data);

            if(isDevelopmentMode){
                data.put("SUSER_EMAIL", TEST_EMAIL);
                data.put("RUSER_EMAIL", TEST_EMAIL);
                data.put("TEST_YN", "Y");
            } else {
                data.put("TEST_YN", "N");
            }

            data.put("SVENDERNO", data.get("SIRS_NUM"));
            data.put("RVENDERNO", data.get("RIRS_NUM"));
            data.put("SUPMONEY", data.get("SUP_AMT"));
            data.put("TAXMONEY", data.get("TAX_AMT"));
            data.put("TAXRATE", data.get("VAT_CD"));
            data.put("GUBUN", data.get("RQ_RE_TYPE"));
            data.put("BIGO", data.get("REMAKR"));
            data.put("BILLTYPE", data.get("TAX_SEND_TYPE"));

            data.put("SCOMPANY", data.get("SCOM_NM"));
            data.put("SCEONAME", data.get("SCEO_NM"));
            data.put("SUPTAE", data.get("SBUSINESS_TYPE"));
            data.put("SUPJONG", data.get("SINDUSTRY_TYPE"));
            data.put("SADDRESS", data.get("SADDR1"));
            data.put("SADDRESS2", data.get("SADDR2"));
            data.put("SUSER", data.get("SUSER_NM"));
            data.put("SDIVISION", data.get("SUSER_DEPT_NM"));
            data.put("STELNO", data.get("SUSER_TEL_NO"));
            data.put("SEMAIL", data.get("SUSER_EMAIL"));
            data.put("SREG_ID", data.get("SSUB_IRS_NUM"));

            data.put("RCOMPANY", data.get("RCOM_NM"));
            data.put("RCEONAME", data.get("RCEO_NM"));
            data.put("RUPTAE", data.get("RBUSINESS_TYPE"));
            data.put("RUPJONG", data.get("RINDUSTRY_TYPE"));
            data.put("RADDRESS", data.get("RADDR1"));
            data.put("RADDRESS2", data.get("RADDR2"));
            data.put("RUSER", data.get("RUSER_NM"));
            data.put("RDIVISION", data.get("RUSER_DEPT_NM"));
            data.put("RTELNO", data.get("RUSER_TEL_NO"));
            data.put("REMAIL", data.get("RUSER_EMAIL"));
            data.put("RREG_ID", data.get("RSUB_IRS_NUM"));

            data.put("REVERSEYN", data.get("TAX_SEND_TYPE"));
            data.put("SENDID", data.get("SUSER_ID_ASP"));
            data.put("RECVID", data.get("RUSER_ID_ASP"));

            tx01_mapper.tx01010_doSendBillTransINSERT_BILL_TRANS(data);

            Map<String, Object> mapTTID = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);
            tx01_mapper.tx01010_doSendBillTransINSERT_BILL_TRANS_ITEM(mapTTID);
        }

        multiCd = "023";

        mapRtn.put("msgCode", multiCd);
        mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));

        return mapRtn;
    }

    // 취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doUniPostCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
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

                    callHttpXml(url, bodyText, "DR", data, mapRtn);
                } catch (Exception e) {
                    throw new Exception(e);
                }
            } else if("Y".equals(data.get("BILL_STAT_TYPE"))) {
                cnt++;

                String BILLSEQ = docNumService.getDocNumber("UPTAX");
                data.put("BILLSEQ", BILLSEQ);

                Map<String, Object> mapTTID = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);

                try {
                    receivebill(data, mapTTID, cnt, mapRtn, "C");
                } catch (Exception e) {
                    throw new Exception(e);
                }
            }
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "036";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doSendBillCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, String> mapCHK;
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String BILL_STAT_TYPE;
        String BILLSTAT;
        String multiCd;

        for(Map<String, Object> data : gridList) {
            BILL_STAT_TYPE = String.valueOf(data.get("BILL_STAT_TYPE"));

            data.put("BILLSEQ", data.get("TAX_BILLSEQ"));

            mapCHK = tx01_mapper.tx01010_doSendBillCancelSELECT_BILL_CHK(data);

            BILLSTAT = mapCHK.get("BILLSTAT");

            if("".equals(BILLSTAT) || BILLSTAT == null || "2".equals(BILLSTAT) || "4".equals(BILLSTAT) || "0".equals(BILLSTAT) || "5".equals(BILLSTAT)) {
                tx01_mapper.tx01010_doSendBillCancelUPDATE_TTIH(data);

                data.put("CMD_DIV", "6");

                tx01_mapper.tx01010_doSendBillCancelINSERT_BILL_MNGMT_ORDR(data);

                if("E".equals(BILL_STAT_TYPE)) {
                    tx01_mapper.tx01010_doSendBillCancelDELETE_BILL_LOG(data);
                }
            } else {
                throw new Exception(String.valueOf(data.get("TAX_NUM")));
            }
        }

        multiCd = "036";

        mapRtn.put("msgCode", multiCd);
        mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));

        return mapRtn;
    }

    // 재전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doUniPostReSend(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, String> mapCHK;
        Map<String, Object> mapSum;
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String BILL_STAT_TYPE;
        String BILLSTAT;
        String multiCd;
        String TEST_EMAIL;
        boolean isDevelopmentMode;

//        // 개발사이트 (상태정검)  (https 사용 , 포트 47543)
//        String url = "https://unidev.unipost.co.kr:47543/mbill-etaxr-server/api/rest/v3/searchStatus";
//        // etax-server 호출시 사용되는 Authorization값(username:password)
//        //요청데이터
//        String bodyText = "{\n" +
//                "    \"aid\" : \""+AID+"\",\n" +
//                "    \"exd_ids\":[\"202009031127447866416551\"],\n" +
//                "    \"inv_sign\" : \"\"\n" +
//                "}";
//         api 호출
//        callHttpXml(url, bodyText, "", null, mapRtn);

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");

        int cnt = 0;
        for(Map<String, Object> data : gridList) {
            cnt++;
//            mapSum = tx01_Mapper.tx01010_doSendBillTransSELECT_TTID_SUMAMT(data);

//            float SUP_AMT = Float.parseFloat(String.valueOf(mapSum.get("SUP_AMT")));
//            float TAX_AMT = Float.parseFloat(String.valueOf(mapSum.get("TAX_AMT")));

//            if(TAX_AMT != Float.parseFloat(String.valueOf(data.get("TAX_AMT")))) {
//                throw new Exception(String.valueOf(data.get("TAX_NUM") + ":T"));
//            }

            BILL_STAT_TYPE = String.valueOf(data.get("BILL_STAT_TYPE"));

            if(isDevelopmentMode){
                data.put("SUSER_EMAIL", TEST_EMAIL);
                data.put("RUSER_EMAIL", TEST_EMAIL);
                data.put("TEST_YN", "Y");
            } else {
                data.put("TEST_YN", "N");
            }

            data.put("BILLSEQ", data.get("TAX_BILLSEQ"));

//            mapCHK = tx01_Mapper.tx01010_doSendBillCancelSELECT_BILL_CHK(data);

//            BILLSTAT = mapCHK.get("BILLSTAT");

//            if("".equals(BILLSTAT) || BILLSTAT == null || "2".equals(BILLSTAT) || "4".equals(BILLSTAT) || "0".equals(BILLSTAT) || "5".equals(BILLSTAT)) {
//                tx01_Mapper.tx01010_doSaveTTIH(data);

//                data.put("TAXMONEY", data.get("TAX_AMT"));
//                data.put("SENDID", data.get("SUSER_ID_ASP"));
//                data.put("RECVID", data.get("RUSER_ID_ASP"));
//                data.put("DT", data.get("ISSUE_DATE"));
//                data.put("BIGO", data.get("REMAKR"));

//                tx01_Mapper.tx01010_doSendBillReSendUPDATE_BILL_TRANS(data);

//                Map<String, Object> mapTTID = tx01_Mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);
//                tx01_Mapper.tx01010_doSendBillReSendUPDATE_BILL_TRANS_ITEM(mapTTID);

//                if("E".equals(BILL_STAT_TYPE)) {
//                    tx01_Mapper.tx01010_doSendBillCancelDELETE_BILL_LOG(data);
//                } else {
//                    tx01_Mapper.tx01010_doSendBillReSendBILL_STAT(data);
//                }


//            } else {
//                throw new Exception(String.valueOf(data.get("TAX_NUM") + ":S"));
//            }

            Map<String, Object> mapTTID = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);

            receivebill(data, mapTTID, cnt, mapRtn, "R");

        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "040";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    // 재전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doSendBillReSend(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, String> mapCHK;
        Map<String, Object> mapSum;
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String BILL_STAT_TYPE;
        String BILLSTAT;
        String multiCd;

        for(Map<String, Object> data : gridList) {
            mapSum = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUMAMT(data);
            float SUP_AMT = Float.valueOf(String.valueOf(mapSum.get("SUP_AMT")));
            float TAX_AMT = Float.valueOf(String.valueOf(mapSum.get("TAX_AMT")));

            if(TAX_AMT != Float.valueOf(String.valueOf(data.get("TAX_AMT")))) {
                throw new Exception(String.valueOf(data.get("TAX_NUM") + ":T"));
            }

            BILL_STAT_TYPE = String.valueOf(data.get("BILL_STAT_TYPE"));

            data.put("BILLSEQ", data.get("TAX_BILLSEQ"));

            mapCHK = tx01_mapper.tx01010_doSendBillCancelSELECT_BILL_CHK(data);

            BILLSTAT = mapCHK.get("BILLSTAT");

            if("".equals(BILLSTAT) || BILLSTAT == null || "2".equals(BILLSTAT) || "4".equals(BILLSTAT) || "0".equals(BILLSTAT) || "5".equals(BILLSTAT)) {
                tx01_mapper.tx01010_doSaveTTIH(data);

                data.put("TAXMONEY", data.get("TAX_AMT"));
                data.put("SENDID", data.get("SUSER_ID_ASP"));
                data.put("RECVID", data.get("RUSER_ID_ASP"));
                data.put("DT", data.get("ISSUE_DATE"));
                data.put("BIGO", data.get("REMAKR"));

                tx01_mapper.tx01010_doSendBillReSendUPDATE_BILL_TRANS(data);

                Map<String, Object> mapTTID = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUM(data);
                tx01_mapper.tx01010_doSendBillReSendUPDATE_BILL_TRANS_ITEM(mapTTID);

                if("E".equals(BILL_STAT_TYPE)) {
                    tx01_mapper.tx01010_doSendBillCancelDELETE_BILL_LOG(data);
                } else {
                    tx01_mapper.tx01010_doSendBillReSendBILL_STAT(data);
                }
            } else {
                throw new Exception(String.valueOf(data.get("TAX_NUM") + ":S"));
            }
        }

        multiCd = "040";

        mapRtn.put("msgCode", multiCd);
        mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));

        return mapRtn;
    }

    // 메일 재전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01010_doUniPostMailReSend(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        String multiCd;
        String TEST_EMAIL;
        boolean isDevelopmentMode;
        String BILLSEQ;
        String url;
        String bodyText;
        String AID;

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        TEST_EMAIL = PropertiesManager.getString("eversrm.system.mailreceiverMail");

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
            String receiver = EverString.nullToEmptyString(data.get("RUSER_EMAIL"));

            try {
                //요청데이터
                bodyText = "{\n" +
                        "  \"aid\":\""+AID+"\",\n" +
                        "  \"exd_id\": \""+exd_id+"\",\n" +
                        "  \"inv_sign\":\""+inv_sign+"\",\n" +
                        "  \"receiver\":\""+receiver+"\"\n" +
                        "}　\n";
//         api 호출
                callHttpXml(url, bodyText, "", null, mapRtn);
            } catch (Exception e) {
                throw new Exception(e);
            }
        }

        if(!"".equals(mapRtn.get("RESULT")) && null == mapRtn.get("RESULT")) {
            multiCd = "050";

            mapRtn.put("msgCode", multiCd);
            mapRtn.put("msgName", msg.getMessageByScreenId("TX01_010", multiCd));
        } else {
            mapRtn.put("msgCode", "ERR");
        }

        return mapRtn;
    }

    // 매출회계세금계산서 목록, 조회
    public List<Map<String, Object>> tx01020_doSearch(Map<String, String> param) throws Exception {
        String TR_CD;

        List<Map<String, Object>> list = tx01_mapper.tx01020_doSearch(param);

//        for(Map<String, Object> data : list) {
//            if("".equals(data.get("TR_CD")) || data.get("TR_CD") == null) {
//                TR_CD = dz_mapper.tx01020_search_TR_CD(data);
//                data.put("TR_CD", TR_CD);
//            }
//        }

        return list;
    }





    public List<Map<String, Object>> tx01020_detail(Map<String, String> param) throws Exception {
        List<Map<String, Object>> list = tx01_mapper.tx01020_detail(param);

        return list;
    }











    // 회계검증
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx01020_doAccV(List<Map<String, Object>> gridData) {
        for (Map<String, Object> grid : gridData) {
            tx01_mapper.tx01020_doAccV(grid);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx01020_doAccV_Cancel(List<Map<String, Object>> gridData) {
        for (Map<String, Object> grid : gridData) {
            tx01_mapper.tx01020_doAccV_Cancel(grid);
        }
    }

    // 회계확정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx01020_doAccC(List<Map<String, Object>> gridData) {
        for (Map<String, Object> grid : gridData) {
            tx01_mapper.tx01020_doAccC(grid);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx01020_doAccC_Cancel(List<Map<String, Object>> gridData) {
        for (Map<String, Object> grid : gridData) {
            tx01_mapper.tx01020_doAccC_Cancel(grid);
        }
    }



    // 월 매출/매입 마감종료
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void tx01020_doSalesClose(Map<String, String> param) throws Exception {

    	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
    	if (!"0".equals(chk)) {
    		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
    	}

        tx01_mapper.tx01020_doSalesCloseCUCL(param);

//        for (Map<String, Object> grid : gridData) {
//            tx01_mapper.tx01020_doSalesClose(grid);
//        }
    }

    /** ******************************************************************************************
     * 운영사 > 정산관리 > 매출정산 > 전표이관
     * @param param
     * @return List
     * @throws Exception
     */
    public List<Map<String, Object>> tx01011_doSearch(Map<String, String> param) throws Exception {
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

        return tx01_mapper.tx01011_doSearch(param);
    }

    public List<Map<String, Object>> tx01011_doSearchTTID(Map<String, String> param) throws Exception {

        return tx01_mapper.tx01011_doSearchTTID(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx01011_doSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            tx01_mapper.tx01010_doSaveTTIH(gridData);
        }

        return msg.getMessageByScreenId("TX01_011", "016");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, Object> tx01011_doSlipTrans(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        Map<String, Object> mapRtn = new HashMap<String, Object>();
        Map<String, Object> mapSum = new HashMap<String, Object>();
        Map<String, Object> mapCHK;
        String TAX_CHK_YN = "N";
        Map<String, Object> mapCUST;
        String CSTCO_YN = "N";
        String multiCd;

        for(Map<String, Object> data : gridList) {
            if("N".equals(TAX_CHK_YN)) {
                TAX_CHK_YN = tx01_mapper.tx01011_doSlipTransSELECT_TAX_CHK(data);
                mapRtn.put("CHK_TAX_NUM", data.get("TAX_NUM"));
            }

            if("N".equals(CSTCO_YN)) {
                mapCUST = tx01_mapper.tx01011_doSlipTransSELECT_CUST_CHK(data);

                if("".equals(mapCUST.get("CSTCO"))) {
                    CSTCO_YN = "Y";
                    mapRtn.put("CSTCO_TAX_NUM", mapCUST.get("TAX_NUM"));
                    mapRtn.put("CSTCO_SALES_TYPE", mapCUST.get("SALES_TYPE"));
                } else {
                    data.put("CSTCO", mapCUST.get("CSTCO"));
                    data.put("IN_ORDER", mapCUST.get("IN_ORDER"));
                }
            }
        }

        if("N".equals(CSTCO_YN)) {
            if("N".equals(TAX_CHK_YN)) {
                for(Map<String, Object> data : gridList) {
                    if("1".equals(data.get("E_BILL_ASP_TYPE"))) {
                        tx01_mapper.tx01010_doSaveTTIH(data);
                    }
                }

                for(Map<String, Object> data : gridList) {
                    String CUST_CD = String.valueOf(data.get("RCOM_CODE"));
                    String CUST_NM = String.valueOf(data.get("RCOM_NM"));
                    String VENDOR_CD = String.valueOf(data.get("SCOM_CODE"));
                    String VENDOR_NM = String.valueOf(data.get("SCOM_NM"));

                    float SUP_AMT = Float.valueOf(String.valueOf(data.get("SUP_AMT")));
                    float TAX_AMT = Float.valueOf(String.valueOf(data.get("TAX_AMT")));

                    data.put("TRANS_YN", "N");
                    tx01_mapper.tx01011_doSaveUPDATE_TTIH(data);

                    if("S".equals(data.get("SALES_TYPE"))) {
                        param.put("CUST_CD", CUST_CD);
                        String CUST_YN = tx01_mapper.tx01011_doSlipTransSELECT_CUST(param);

                        if("Y".equals(CUST_YN)) {	// IF_MROINCLO 내부전표로 전송, TTIH 업데이트
                            if("1".equals(data.get("E_BILL_ASP_TYPE"))) {
                                mapSum = tx01_mapper.tx01010_doSendBillTransSELECT_TTID_SUMAMT(data);

                                float TAX_SUM_AMT = Float.valueOf(String.valueOf(mapSum.get("TAX_AMT")));

                                if(TAX_SUM_AMT != Float.valueOf(String.valueOf(data.get("TAX_AMT")))) {
                                    throw new Exception(String.valueOf(data.get("TAX_NUM")));
                                }
                            }

                            List<Map<String, Object>> list = tx01_mapper.tx01011_doSlipTransSELECT_TTID(data);

                            for(Map<String, Object> dataTTID : list) {
                                dataTTID.put("ACCO", "");
                                dataTTID.put("TACO", "221");
                                dataTTID.put("RKNA", String.valueOf(dataTTID.get("DPTCO_NM")) + " " + String.valueOf(dataTTID.get("ITEM_DESC")) + " 구입");
//								dataTTID.put("CSTCO", data.get("CSTCO"));
                                dataTTID.put("ISSUE_DATE", data.get("ISSUE_DATE"));
                                tx01_mapper.tx01011_doSlipTransINSERT_IF_MROINCLO(dataTTID);
                            }
                        } else {	// IF_MROOUTCLO 외부전표로 전송, TTIH 업데이트
                            data.put("ACCO", "015");
                            data.put("TACO", "700");
                            data.put("RKNA", CUST_NM + " 상품 외상매출금");
                            data.put("DPTCO", "2150");
                            data.put("AMT", SUP_AMT + TAX_AMT);
                            data.put("RCVER", CUST_NM);
                            tx01_mapper.tx01011_doSlipTransINSERT_IF_MROOUTCLO(data);
                            data.put("ACCO", "603");
                            data.put("TACO", "015");
                            data.put("RKNA", CUST_NM + " 상품 매출");
                            data.put("DPTCO", "2150");
                            data.put("AMT", SUP_AMT);
                            data.put("RCVER", CUST_NM);
                            tx01_mapper.tx01011_doSlipTransINSERT_IF_MROOUTCLO(data);
                            data.put("ACCO", "230");
                            data.put("TACO", "015");
                            data.put("RKNA", CUST_NM + "상품 매출 VAT");
                            data.put("DPTCO", "2100");
                            data.put("AMT", TAX_AMT);
                            data.put("RCVER", CUST_NM);
                            tx01_mapper.tx01011_doSlipTransINSERT_IF_MROOUTCLO(data);
                        }
                    } else if("P".equals(data.get("SALES_TYPE"))) {	// IF_MROOUTCLO 외부전표로 전송, TTIH 업데이트
                        if("N".equals(data.get("IN_ORDER"))) {
                            data.put("ACCO", "202");
                            data.put("TACO", "700");
                            data.put("RKNA", VENDOR_NM + " 상품 외상매입금");
                            data.put("DPTCO", "2150");
                            data.put("AMT", SUP_AMT + TAX_AMT);
                            data.put("RCVER", VENDOR_NM);
                            tx01_mapper.tx01011_doSlipTransINSERT_IF_MROOUTCLO(data);
                            data.put("ACCO", "065");
                            data.put("TACO", "202");
                            data.put("RKNA", VENDOR_NM + " 상품 매입");
                            data.put("DPTCO", "2150");
                            data.put("AMT", SUP_AMT);
                            data.put("RCVER", VENDOR_NM);
                            tx01_mapper.tx01011_doSlipTransINSERT_IF_MROOUTCLO(data);
                            data.put("ACCO", "800");
                            data.put("TACO", "202");
                            data.put("RKNA", VENDOR_NM + " 상품 매입 VAT");
                            data.put("DPTCO", "2100");
                            data.put("AMT", TAX_AMT);
                            data.put("RCVER", VENDOR_NM);
                            tx01_mapper.tx01011_doSlipTransINSERT_IF_MROOUTCLO(data);
                        } else {

                        }

                    }
                }

                multiCd = "006";
            } else {
                multiCd = "004";
            }
        } else {
            multiCd = "031";
        }

        mapRtn.put("msgCode", multiCd);
        mapRtn.put("msgName", msg.getMessageByScreenId("TX01_011", multiCd));

        return mapRtn;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String tx01011_doSlipTransCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();

        for(Map<String, Object> data : gridList) {
            data.put("TRANS_YN", "");
            tx01_mapper.tx01011_doSaveUPDATE_TTIH(data);

            if("S".equals(data.get("SALES_TYPE"))) {
                param.put("CUST_CD", data.get("RCOM_CODE"));
                String CUST_YN = tx01_mapper.tx01011_doSlipTransSELECT_CUST(param);

                if("Y".equals(CUST_YN)) {	// IF_MROINCLO 내부전표 삭제, TTIH 업데이트
                    tx01_mapper.tx01011_doSlipTransDELETE_IF_MROINCLO(data);
                } else {	// IF_MROOUTCLO 외부전표 삭제, TTIH 업데이트
                    tx01_mapper.tx01011_doSlipTransDELETE_IF_MROOUTCLO(data);
                }
            } else if("P".equals(data.get("SALES_TYPE"))) {	// IF_MROOUTCLO 외부전표 삭제, TTIH 업데이트
                tx01_mapper.tx01011_doSlipTransDELETE_IF_MROOUTCLO(data);
            }
        }

        return msg.getMessageByScreenId("TX01_011", "026");
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

    public void receivebill(Map<String, Object> data, Map<String, Object> item, int cnt, Map<String, Object> mapRtn, String t) throws Exception {
        String url;
        String AID;
        boolean isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");

        if(isDevelopmentMode){
            url = PropertiesManager.getString("unipost.tax.site.dev") + "/api/rest/v3/receivebill";
            AID = AID_DEV;
        } else {
            url = PropertiesManager.getString("unipost.tax.site.prod") + "/api/rest/v3/receivebill";
            AID = AID_PROD;
        }

        String inv_seq = EverDate.getDate() + data.get("BILLSEQ");    // string 		24	*	고객사 관리번호(년월일+숫자16)
        if("R".equals(t)) {
            inv_seq = EverString.nullToEmptyString(data.get("BILLSEQ"));
        }

        String exd_refdoc_id = "1";  // string 		24	　	사업자 관리번호

        String tid_issuedatetime = EverString.ignoreSeparator(EverString.nullToEmptyString(data.get("ISSUE_DATE")), "-");  // string 		8	*	세금계산서 작성일자(YYYYMMDD)
        if("C".equals(t)) {
            String[] temp = EverString.nullToEmptyString(data.get("ISSUE_DATE")).split("-");
            String mm = EverDate.getMonth();
            String dd = EverDate.getDay();

            if(!mm.equals(temp[1])) {
                if(Integer.valueOf(dd) > 10 ) {
                    tid_issuedatetime = EverDate.getDate();
                    data.put("ISSUE_DATE", EverDate.getDate());
                }
            }
        }

        String tid_typecode = "0101";   // string 		4	*	세금계산서 종류(별첨참고), 0101: 일반 세금계산서
        if("R".equals(t)) {
            tid_typecode = "0201";
        }
        String tid_purposecode = "02";    // string 		2	*	세금계산서의 영수/청구 구분 지시자(별첨참고), 02:청구

        String tid_amendcode = "";  // string 		2	　	세금계산서 수정 사유 코드(별첨참고)
        if("R".equals(t)) {
            tid_amendcode = "01";
        }
        String tid_originalissueid = "";    // string 		24	　	원 승인번호
        String tid_desc0 = EverString.nullToEmptyString(data.get("RSUB_IRS_NUM"));  // string 		300	　	비고0, 종사업장코드
        String tid_desc1 = EverString.nullToEmptyString(data.get("REMAKR"));  // string 		300	　	비고1
        String tid_desc2 = "";  // string 		300	　	비고2
        String tid_refimpdoc_id = "";   // string 		15	　	수입 신고서 번호
        String tid_refimpdoc_itemquantity = "0"; // number 		6	　	수입총건
        String tid_refimpdoc_accept_sdate = ""; // string 		8	　	일괄발급 시작일자(YYYYMMDD)
        String tid_refimpdoc_accept_edate = ""; // string 		8	　	일괄발급 종료일자(YYYYMMDD)

        String tit_alice_specorg_biztypecode = "01";  // string 		2	　	공급자 사업자등록번호 구분코드, 01: 사업자등록번호
        String tit_alice_id = EverString.nullToEmptyString(data.get("SIRS_NUM"));   // string 		10	*	공급자 사업자등록번호
        String tit_alice_specorg_taxregid = ""; // string 		4	　	공급자 종사업장 식별코드
        String tit_alice_name = EverString.nullToEmptyString(data.get("SCOM_NM")); // string 	tit_alice_name	400	*	공급자 사업자명
        String tit_alice_specperson_name = EverString.nullToEmptyString(data.get("SCEO_NM"));  // string 		200	*	공급자 대표자명
        String tit_alice_specaddr_lineone = EverString.nullToEmptyString(data.get("SADDR1") + ", " + data.get("SADDR2")); // string 		600	　	공급자 주소1
        String tit_alice_typecode = EverString.nullToEmptyString(data.get("SBUSINESS_TYPE")); // string 		200	　	공급자 업태
        String tit_alice_classcode = EverString.nullToEmptyString(data.get("SINDUSTRY_TYPE"));    // string 		200	　	공급자 업종
        String tit_alice_defcont_deptname = EverString.nullToEmptyString(data.get("SUSER_DEPT_NM")); // string 		200	　	공급자 담당부서
        String tit_alice_defcont_personname = EverString.nullToEmptyString(data.get("SUSER_NM"));   // string 		200	　	공급자 담당자명
        String tit_alice_defcont_telcomm = EverString.nullToEmptyString(data.get("SUSER_TEL_NO"));  // string 		40	　	공급자 담당자 전화번호
        String tit_alice_defcont_uricomm = EverString.nullToEmptyString(data.get("SUSER_EMAIL"));  // string 		200	　	공급자 담당자 이메일
        String tit_alice_defcont_cellphone = "";    // string 		40	　	공급자 담당자 핸드폰 번호

        String tit_bob_specorg_biztypecode = "01";    // string 		2	*	공급받는자 사업자등록번호 구분코드(별첨참고), 01: 사업자등록번호
        String tit_bob_id = EverString.nullToEmptyString(data.get("RIRS_NUM")); // string 		13	*	공급받는자 사업자등록번호(별첨참고)
        String tit_bob_specorg_taxregid = "";   // string 		4	　	공급받는자 종사업장 식별코드
        String tit_bob_name = EverString.nullToEmptyString(data.get("RCOM_NM"));   // string 		400	*	공급받는자 사업자명
        String tit_bob_specperson_name = EverString.nullToEmptyString(data.get("RCEO_NM"));    // string 		200	*	공급받는자 대표자명
        String tit_bob_specaddr_lineone = EverString.nullToEmptyString(data.get("RADDR1") + ", " + data.get("RADDR2"));   // string 		600	　	공급받는자 주소
        String tit_bob_typecode = EverString.nullToEmptyString(data.get("RBUSINESS_TYPE"));   // string 		200	　	공급받는자 업태
        String tit_bob_classcode = EverString.nullToEmptyString(data.get("RINDUSTRY_TYPE"));  // string 		200	　	공급받는자 업종
        String tit_bob_1stdefcont_deptname =EverString.nullToEmptyString(data.get("RUSER_DEPT_NM"));    // string 		200	　	공급받는자 1st 담당부서
        String tit_bob_1stdefcont_personname = EverString.nullToEmptyString(data.get("RUSER_NM"));  // string 		200	　	공급받는자 1st 담당자명
        String tit_bob_1stdefcont_telcomm = EverString.nullToEmptyString(data.get("RUSER_TEL_NO")); // string 		40	　	공급받는자 1st 담당자 전화번호
        String tit_bob_1stdefcont_uricomm = EverString.nullToEmptyString(data.get("RUSER_EMAIL"));; // string 		200	　	공급받는자 1st 담당자 이메일
        String tit_bob_1stdefcont_cellphone = "";   // string 		40	　	공급받는자 1st 담당자 핸드폰번호
        String tit_bob_2nddefcont_deptname = "";    // string 		200	　	공급받는자 2nd 담당부서
        String tit_bob_2nddefcont_personname = "";  // string 		200	　	공급받는자 2nd 담당자명
        String tit_bob_2nddefcont_telcomm = ""; // string 		40	　	공급받는자 2nd 담당자 전화번호
        String tit_bob_2nddefcont_uricomm = ""; //string 		200	　	공급받는자 2nd 담당자 이메일
        String tit_bob_2nddefcont_cellphone = "";   //string 		40	　	공급받는자 2nd 담당자 핸드폰번호

        String tit_specsum_chargeamount = EverMath.EverNumberType(String.valueOf(data.get("SUP_AMT")), "######"); // number 		18	*	공급가액 합계
        if("C".equals(t)) {
            tit_specsum_chargeamount = EverMath.EverNumberType(String.valueOf(Double.parseDouble(String.valueOf(data.get("SUP_AMT"))) * -1), "######");
        }
        String tit_specsum_taxamount = EverMath.EverNumberType(String.valueOf(data.get("TAX_AMT")), "######");    // number 		18	　	세액 합계
        if("C".equals(t)) {
            tit_specsum_taxamount = EverMath.EverNumberType(String.valueOf(Double.parseDouble(String.valueOf(data.get("TAX_AMT"))) * -1), "######");
        }

        double tot = Double.parseDouble(String.valueOf(data.get("SUP_AMT"))) + Double.parseDouble(String.valueOf(data.get("TAX_AMT")));

        if("C".equals(t)) {
            tot = (Double.parseDouble(String.valueOf(data.get("SUP_AMT"))) + Double.parseDouble(String.valueOf(data.get("TAX_AMT")))) * -1;
        }
        String tit_specsum_grandamount = EverMath.EverNumberType(tot, "######");    // number 		18	*	총액=공급가액+세액
        String inv_sign = "100".equals(EverString.nullToEmptyString(data.get("TAX_SEND_TYPE")))?"":"X";   // string 		1	*	매출매입 구분(정/역)(별첨참고), 공백: 정발행, X: 역매입
        String reg_date = EverDate.getDate();

        int tii_seqnumeric = 1; // number  	 	2	*	일련번호
        String tii_purchaseexpirydatetime = EverString.ignoreSeparator(EverString.nullToEmptyString(data.get("ISSUE_DATE")), "-"); // string 	 	8	*	공급년월일(YYYYMMDD)
        String tii_nametext = EverString.replace(EverString.nullToEmptyString(data.get("SUBJECT_ITEM_NM")), "\"", "\\\"");   // string 	   	200	　	품목명
        String tii_informationtext = "";    // string 	    	120	　	규격
        String tii_chargeableunitquantity = "null"; // number  	 	12,2	　	수량(소수점 2자리까지 허용)
        String tii_unitprice_unitamount = "null"; // number  	   	18,2	　	단가(소수점 2자리까지 허용)

        item.put("SUP", data.get("SUP_AMT"));
        item.put("TAX", data.get("TAX_AMT"));

        String tii_invoiceamount = EverMath.EverNumberType(String.valueOf(item.get("SUP")), "######");    // number  	  	18	　	공급가액
        String tii_totaltax_calcamount = EverMath.EverNumberType(String.valueOf(item.get("TAX")), "######");  // number  	    	18	　	세액
        if("C".equals(t)) {
            tii_invoiceamount = EverMath.EverNumberType(String.valueOf(Double.parseDouble(String.valueOf(item.get("SUP"))) * -1), "######");
            tii_totaltax_calcamount = EverMath.EverNumberType(String.valueOf(Double.parseDouble(String.valueOf(item.get("TAX"))) * -1), "######");
        }
        String tii_descriptiontext = "";    // string 	    	200	　	비고

        String bodyText = "[\n" +
                "  {\n" +
                "    \"aid\": \""+AID+"\",\n" +
                "    \"exd_id\": \"\",\n" +
                "    \"exd_refdoc_id\": \"\",\n" +
                "    \"exd_issuedatetime\": null,\n" +
                "    \"exd_issuedatetime_format\": null,\n" +
                "    \"tid_issueid\": \"\",\n" +
                "    \"tid_issuedatetime\": \""+tid_issuedatetime+"\",\n" +
                "    \"tid_issuedatetime_format\": null,\n" +
                "    \"tid_typecode\": \""+tid_typecode+"\",\n" +
                "    \"tid_typecode_desc\": null,\n" +
                "    \"tid_purposecode\": \""+tid_purposecode+"\",\n" +
                "    \"tid_purposecode_desc\": null,\n" +
                "    \"tid_amendcode\": \""+tid_amendcode+"\",\n" +
                "    \"tid_amendcode_desc\": null,\n" +
                "    \"tid_originalissueid\": \"\",\n" +
                "    \"tid_desc0\": \""+tid_desc0+"\",\n" +
                "    \"tid_desc1\": \""+tid_desc1+"\",\n" +
                "    \"tid_desc2\": \""+tid_desc2+"\",\n" +
                "    \"tid_refimpdoc_id\": \"\",\n" +
                "    \"tid_refimpdoc_itemquantity\": "+tid_refimpdoc_itemquantity+",\n" +
                "    \"tid_refimpdoc_accept_sdate\": \"\",\n" +
                "    \"tid_refimpdoc_accept_edate\": \"\",\n" +
                "    \"tit_alice_specorg_biztypecode\": \""+tit_alice_specorg_biztypecode+"\",\n" +
                "    \"tit_alice_id\": \""+tit_alice_id+"\",\n" +
                "    \"tit_alice_specorg_taxregid\": \"\",\n" +
                "    \"tit_alice_name\": \""+tit_alice_name+"\",\n" +
                "    \"tit_alice_specperson_name\": \""+tit_alice_specperson_name+"\",\n" +
                "    \"tit_alice_specaddr_lineone\": \""+tit_alice_specaddr_lineone+"\",\n" +
                "    \"tit_alice_typecode\": \""+tit_alice_typecode+"\",\n" +
                "    \"tit_alice_classcode\": \""+tit_alice_classcode+"\",\n" +
                "    \"tit_alice_defcont_deptname\": \""+tit_alice_defcont_deptname+"\",\n" +
                "    \"tit_alice_defcont_personname\": \""+tit_alice_defcont_personname+"\",\n" +
                "    \"tit_alice_defcont_telcomm\": \""+tit_alice_defcont_telcomm+"\",\n" +
                "    \"tit_alice_defcont_uricomm\": \""+tit_alice_defcont_uricomm+"\",\n" +
                "    \"tit_alice_defcont_cellphone\": null,\n" +
                "    \"tit_bob_specorg_biztypecode\": \""+tit_bob_specorg_biztypecode+"\",\n" +
                "    \"tit_bob_id\": \""+tit_bob_id+"\",\n" +
                "    \"tit_bob_specorg_taxregid\": null,\n" +
                "    \"tit_bob_name\": \""+tit_bob_name+"\",\n" +
                "    \"tit_bob_specperson_name\": \""+tit_bob_specperson_name+"\",\n" +
                "    \"tit_bob_specaddr_lineone\": \""+tit_bob_specaddr_lineone+"\",\n" +
                "    \"tit_bob_typecode\": \""+tit_bob_typecode+"\",\n" +
                "    \"tit_bob_classcode\": \""+tit_bob_classcode+"\",\n" +
                "    \"tit_bob_1stdefcont_deptname\": \""+tit_bob_1stdefcont_deptname+"\",\n" +
                "    \"tit_bob_1stdefcont_personname\": \""+tit_bob_1stdefcont_personname+"\",\n" +
                "    \"tit_bob_1stdefcont_telcomm\": \""+tit_bob_1stdefcont_telcomm+"\",\n" +
                "    \"tit_bob_1stdefcont_uricomm\": \""+tit_bob_1stdefcont_uricomm+"\",\n" +
                "    \"tit_bob_1stdefcont_cellphone\": null,\n" +
                "    \"tit_bob_2nddefcont_deptname\": \"\",\n" +
                "    \"tit_bob_2nddefcont_personname\": \"\",\n" +
                "    \"tit_bob_2nddefcont_telcomm\": \"\",\n" +
                "    \"tit_bob_2nddefcont_uricomm\": \"\",\n" +
                "    \"tit_bob_2nddefcont_cellphone\": null,\n" +
                "    \"tit_broker_specorg_biztypecode\": \"\",\n" +
                "    \"tit_broker_id\": \"\",\n" +
                "    \"tit_broker_specorg_taxregid\": \"\",\n" +
                "    \"tit_broker_name\": \"\",\n" +
                "    \"tit_broker_specperson_name\": \"\",\n" +
                "    \"tit_broker_specaddr_lineone\": \"\",\n" +
                "    \"tit_broker_typecode\": \"\",\n" +
                "    \"tit_broker_classcode\": \"\",\n" +
                "    \"tit_broker_defcont_deptname\": \"\",\n" +
                "    \"tit_broker_defcont_personname\": \"\",\n" +
                "    \"tit_broker_defcont_telcomm\": \"\",\n" +
                "    \"tit_broker_defcont_uricomm\": \"\",\n" +
                "    \"tit_broker_defcont_cellphone\": null,\n" +
                "    \"tit_specpay_paidamount10\": null,\n" +
                "    \"tit_specpay_paidamount20\": null,\n" +
                "    \"tit_specpay_paidamount30\": null,\n" +
                "    \"tit_specpay_paidamount40\": null,\n" +
                "    \"tit_specpay_paidamount10_format\": null,\n" +
                "    \"tit_specpay_paidamount20_format\": null,\n" +
                "    \"tit_specpay_paidamount30_format\": null,\n" +
                "    \"tit_specpay_paidamount40_format\": null,\n" +
                "    \"tit_specsum_chargeamount\": "+tit_specsum_chargeamount+",\n" +
                "    \"tit_specsum_taxamount\": "+tit_specsum_taxamount+",\n" +
                "    \"tit_specsum_grandamount\": "+tit_specsum_grandamount+",\n" +
                "    \"tit_specsum_chargeamount_format\": null,\n" +
                "    \"tit_specsum_taxamount_format\": null,\n" +
                "    \"tit_specsum_grandamount_format\": null,\n" +
                "    \"biz_tocharlesconfirmstatus\": \"N\",\n" +
                "    \"inv_sign\": \""+inv_sign+"\",\n" +
                "    \"mbill_send_status\": \"W\",\n" +
                "    \"erp_sync_yn\": \"W\",\n" +
                "    \"prt_yn\": null,\n" +
                "    \"prt_yn_desc\": null,\n" +
                "    \"inv_seq\": \""+inv_seq+"\",\n" +
                "    \"view_date\": null,\n" +
                "    \"reg_date\": "+reg_date+",\n" +
                "    \"table_alias\": null,\n" +
                "    \"biz_tocharlesconfirmstatus_desc\": null,\n" +
                "    \"tAliceItemList\": [\n" +
                "      {\n" +
                "        \"offset\": null,\n" +
                "        \"limit\": null,\n" +
                "        \"aid\": \""+AID+"\",\n" +
                "        \"exd_id\": \"\",\n" +
                "        \"tii_seqnumeric\": "+tii_seqnumeric+",\n" +
                "        \"tii_purchaseexpirydatetime\": \""+tii_purchaseexpirydatetime+"\",\n" +
                "        \"tii_purchaseexpirydatetime_format\": null,\n" +
                "        \"tii_purchaseexpirydatetime_format_month\": null,\n" +
                "        \"tii_purchaseexpirydatetime_format_day\": null,\n" +
                "        \"tii_nametext\": \""+tii_nametext+"\",\n" +
                "        \"tii_informationtext\": \""+tii_informationtext+"\",\n" +
                "        \"tii_chargeableunitquantity\": "+tii_chargeableunitquantity+",\n" +
                "        \"tii_chargeableunitquantity_format\": null,\n" +
                "        \"tii_chargeableunittext\": \"\",\n" +
                "        \"tii_unitprice_unitamount\": "+tii_unitprice_unitamount+",\n" +
                "        \"tii_unitprice_unitamount_format\": null,\n" +
                "        \"tii_invoiceamount\": "+tii_invoiceamount+",\n" +
                "        \"tii_invoiceamount_format\": null,\n" +
                "        \"tii_totaltax_calcamount\": "+tii_totaltax_calcamount+",\n" +
                "        \"tii_totaltax_calcamount_format\": null,\n" +
                "        \"tii_descriptiontext\": \""+tii_descriptiontext+"\"\n" +
                "      }\n" +
                "    ],\n" +
                "    \"tAliceFileList\": null,\n" +
                "    \"tAliceDSig\": null,\n" +
                "    \"tAliceStat\": null\n" +
                "  }\n" +
                "]\n";

        callHttpXml(url, bodyText, t, data, mapRtn);
    }

    public void callHttpXml(String url, String bodyText, String t, Map<String, Object> data, Map<String, Object> mapRtn) throws Exception {
        boolean isDevelopmentMode;
        String AID;

        isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag");

        if(isDevelopmentMode){
            AID = AID_DEV;
        } else {
            AID = AID_PROD;
        }

//        try {
        HttpClientBuilder builder = HttpClients.custom();
        builder.disableRedirectHandling();
        HttpClient client = builder.build();

        String password_Enc = getEncValue(ENVKEY, "ETAX-SERVER-" + COM_REGNO);
        String userName_Enc = getEncValue(ENVKEY, COM_REGNO);

        // Basic Authentication header value
        String baHeader = userName_Enc + ":" + password_Enc;
        baHeader = new String(Base64.encode(baHeader.getBytes()), "utf-8");

        // execute request
        HttpPost request = new HttpPost(url);
        request.setHeader("AID", AID);
        request.setHeader("COM_REGNO", COM_REGNO);
        request.setHeader("Authorization", "Basic " + baHeader);

        System.out.println("** Calling : " + url);
        System.out.println("** Header AID: " + AID);
        System.out.println("** Header COM_REGNO: " + COM_REGNO);
        System.out.println("** Authorization: " + baHeader);
        System.out.println("** RequestMessage ::: " + bodyText);

        StringEntity input = new StringEntity(bodyText, "utf-8");
        input.setContentType("application/json; charset=UTF-8");
        request.setEntity(input);

        // response
        HttpResponse response = client.execute(request);
        int httpRespCode = response.getStatusLine().getStatusCode();
        System.out.println("Response code is: " + httpRespCode);

        if (httpRespCode == 401) { // 인증 오류
            System.out.println("API access was denied: you are not authorized");
        }else if (httpRespCode == 200){ // 인증 성공
            String strResult = EntityUtils.toString(response.getEntity(), "UTF-8");

            System.out.println("ResponseMessage ::: " + strResult);

            if("P".equals(t) || "C".equals(t)) {  // 전송, 마이너스 전송
                List list = new ObjectMapper().readValue(strResult, List.class);
                Map map = (Map) list.get(0);
                boolean success = (boolean) map.get("success");
                String EXD_ID = (String) map.get("exd_id");
                String INV_SEQ = (String) map.get("inv_seq");

//                    data.put("BILLSEQ", EXD_ID);
                data.put("BILLSEQ", INV_SEQ);

                String E_BILL_ASP_STAT_TYPE;

                if(success) {
                    Map tAliceEntry = (Map) map.get("tAliceEntry");
                    String inv_sign = (String) tAliceEntry.get("inv_sign");
                    String exd_id = (String) tAliceEntry.get("exd_id");
                    String tid_issueid = (String) tAliceEntry.get("tid_issueid");

                    if("X".equals(inv_sign)) {
//                            E_BILL_ASP_STAT_TYPE = (String) tAliceEntry.get("biz_tocharlesconfirmstatus");
                        E_BILL_ASP_STAT_TYPE = "NN";
                    } else {
                        E_BILL_ASP_STAT_TYPE = (String) tAliceEntry.get("biz_tocharlesconfirmstatus");

                        if("N".equals(E_BILL_ASP_STAT_TYPE)) {
                            E_BILL_ASP_STAT_TYPE = "NN";
                        } else if("Y".equals(E_BILL_ASP_STAT_TYPE)) {
                            E_BILL_ASP_STAT_TYPE = "YY";

                            Map tAliceDSig = (Map) tAliceEntry.get("tAliceDSig");

                            String sendStatus = (String) tAliceDSig.get("biz_tocharlesconfirmstatus");

                            if(!"".equals(sendStatus) && sendStatus != null) {
                                E_BILL_ASP_STAT_TYPE = sendStatus;
                            }
                        }
                    }

                    data.put("E_BILL_ASP_STAT_TYPE", E_BILL_ASP_STAT_TYPE);
                    data.put("TAX_EXD_ID", exd_id);
                    data.put("TAX_ISSUE_ID", tid_issueid);

                    if("P".equals(t)) {
                        tx01_mapper.tx01010_doSaveUPDATE_TTIH(data);
                    } else {
                        tx01_mapper.tx01010_doTaxCancelTTIH_AP(data);
                        tx01_mapper.tx01010_doTaxCancelTTID_AP(data);
                        tx01_mapper.tx01010_doTaxCancelAPAR(data);

                        String TAX_NUM = docNumService.getDocNumber("GTAX");
                        String tit_specsum_chargeamount = String.valueOf(tAliceEntry.get("tit_specsum_chargeamount"));
                        String tit_specsum_taxamount = String.valueOf(tAliceEntry.get("tit_specsum_taxamount"));

                        data.put("TAX_NUM", TAX_NUM);
                        data.put("TAX_BILLSEQ", data.get("BILLSEQ"));
                        data.put("CLOSING_NO", data.get("CLOSING_NO"));
                        data.put("CLOSING_SEQ", data.get("CLOSING_SEQ"));


                        if("X".equals(inv_sign)) {
                            data.put("IN_SCOM_CODE", data.get("SCOM_CODE"));
                            data.put("IN_SCOM_CODE", data.get("SCOM_CODE"));
                            data.put("IN_SIRS_NUM", data.get("SIRS_NUM"));
                            data.put("IN_SCOM_NM", data.get("SCOM_NM"));
                            data.put("IN_SCEO_NM", data.get("SCEO_NM"));
                            data.put("IN_SBUSINESS_TYPE", data.get("SBUSINESS_TYPE"));
                            data.put("IN_SINDUSTRY_TYPE", data.get("SINDUSTRY_TYPE"));
                            data.put("IN_SADDR1", data.get("SADDR1"));
                            data.put("IN_SADDR2", data.get("SADDR2"));
                            data.put("IN_SUSER_ID", data.get("SUSER_ID"));
                            data.put("IN_SUSER_ID_ASP", data.get("SUSER_ID_ASP"));
                            data.put("IN_SUSER_NM", data.get("SUSER_NM"));
                            data.put("IN_SUSER_DEPT_NM", data.get("SUSER_DEPT_NM"));
                            data.put("IN_SUSER_TEL_NO", data.get("SUSER_TEL_NO"));
                            data.put("IN_SUSER_EMAIL", data.get("SUSER_EMAIL"));
                            data.put("IN_SSUB_IRS_NUM", data.get("SSUB_IRS_NUM"));

                            data.put("IN_RCOM_CODE", data.get("RCOM_CODE"));
                            data.put("IN_RCOM_CODE", data.get("RCOM_CODE"));
                            data.put("IN_RIRS_NUM", data.get("RIRS_NUM"));
                            data.put("IN_RCOM_NM", data.get("RCOM_NM"));
                            data.put("IN_RCEO_NM", data.get("RCEO_NM"));
                            data.put("IN_RBUSINESS_TYPE", data.get("RBUSINESS_TYPE"));
                            data.put("IN_RINDUSTRY_TYPE", data.get("RINDUSTRY_TYPE"));
                            data.put("IN_RADDR1", data.get("RADDR1"));
                            data.put("IN_RADDR2", data.get("RADDR2"));
                            data.put("IN_RUSER_ID", data.get("RUSER_ID"));
                            data.put("IN_RUSER_ID_ASP", data.get("RUSER_ID_ASP"));
                            data.put("IN_RUSER_NM", data.get("RUSER_NM"));
                            data.put("IN_RUSER_DEPT_NM", data.get("RUSER_DEPT_NM"));
                            data.put("IN_RUSER_TEL_NO", data.get("RUSER_TEL_NO"));
                            data.put("IN_RUSER_EMAIL", data.get("RUSER_EMAIL"));
                            data.put("IN_RSUB_IRS_NUM", data.get("RSUB_IRS_NUM"));

                            data.put("IN_OUT_TYPE", "IN");
                            data.put("SALES_TYPE", "P");		// 매출매입구분 - S:매출, P:매입
                            data.put("RQ_RE_TYPE", "2");		// 청구영수구분 - 2:청구, 1:영수
                            data.put("IN_SUP_AMT", tit_specsum_chargeamount);
                            data.put("IN_TAX_AMT", tit_specsum_taxamount);

                            py02_mapper.py02040_doTaxCreateIN_INSERT_TTIH(data);
                        } else {
                            data.put("OUT_SCOM_CODE", data.get("SCOM_CODE"));
                            data.put("OUT_SCOM_CODE", data.get("SCOM_CODE"));
                            data.put("OUT_SIRS_NUM", data.get("SIRS_NUM"));
                            data.put("OUT_SCOM_NM", data.get("SCOM_NM"));
                            data.put("OUT_SCEO_NM", data.get("SCEO_NM"));
                            data.put("OUT_SBUSINESS_TYPE", data.get("SBUSINESS_TYPE"));
                            data.put("OUT_SINDUSTRY_TYPE", data.get("SINDUSTRY_TYPE"));
                            data.put("OUT_SADDR1", data.get("SADDR1"));
                            data.put("OUT_SADDR2", data.get("SADDR2"));
                            data.put("OUT_SUSER_ID", data.get("SUSER_ID"));
                            data.put("OUT_SUSER_ID_ASP", data.get("SUSER_ID_ASP"));
                            data.put("OUT_SUSER_NM", data.get("SUSER_NM"));
                            data.put("OUT_SUSER_DEPT_NM", data.get("SUSER_DEPT_NM"));
                            data.put("OUT_SUSER_TEL_NO", data.get("SUSER_TEL_NO"));
                            data.put("OUT_SUSER_EMAIL", data.get("SUSER_EMAIL"));
                            data.put("OUT_SSUB_IRS_NUM", data.get("SSUB_IRS_NUM"));

                            data.put("OUT_RCOM_CODE", data.get("RCOM_CODE"));
                            data.put("OUT_RCOM_CODE", data.get("RCOM_CODE"));
                            data.put("OUT_RIRS_NUM", data.get("RIRS_NUM"));
                            data.put("OUT_RCOM_NM", data.get("RCOM_NM"));
                            data.put("OUT_RCEO_NM", data.get("RCEO_NM"));
                            data.put("OUT_RBUSINESS_TYPE", data.get("RBUSINESS_TYPE"));
                            data.put("OUT_RINDUSTRY_TYPE", data.get("RINDUSTRY_TYPE"));
                            data.put("OUT_RADDR1", data.get("RADDR1"));
                            data.put("OUT_RADDR2", data.get("RADDR2"));
                            data.put("OUT_RUSER_ID", data.get("RUSER_ID"));
                            data.put("OUT_RUSER_ID_ASP", data.get("RUSER_ID_ASP"));
                            data.put("OUT_RUSER_NM", data.get("RUSER_NM"));
                            data.put("OUT_RUSER_DEPT_NM", data.get("RUSER_DEPT_NM"));
                            data.put("OUT_RUSER_TEL_NO", data.get("RUSER_TEL_NO"));
                            data.put("OUT_RUSER_EMAIL", data.get("RUSER_EMAIL"));
                            data.put("OUT_RSUB_IRS_NUM", data.get("RSUB_IRS_NUM"));

                            data.put("IN_OUT_TYPE", "OUT");
                            data.put("SALES_TYPE", "S");        // 매출매입구분 - S:매출, P:매입
                            data.put("RQ_RE_TYPE", "2");        // 청구영수구분 - 2:청구, 1:영수
                            data.put("OUT_SUP_AMT", tit_specsum_chargeamount);
                            data.put("OUT_TAX_AMT", tit_specsum_taxamount);

                            py01_mapper.py01020_doTaxCreateOUT_INSERT_TTIH(data);
                        }
                    }
                } else {
                    mapRtn.put("RESULT", strResult);
                }
            } else if("R".equals(t)) {  // 재전송
                List list = new ObjectMapper().readValue(strResult, List.class);
                Map map = (Map) list.get(0);
                boolean success = (boolean) map.get("success");
                String EXD_ID = (String) map.get("exd_id");
                String INV_SEQ = (String) map.get("inv_seq");

                String E_BILL_ASP_STAT_TYPE;

                if(success) {
                    Map tAliceEntry = (Map) map.get("tAliceEntry");
                    String inv_sign = (String) tAliceEntry.get("inv_sign");
                    String exd_id = (String) tAliceEntry.get("exd_id");

                    if("X".equals(inv_sign)) {
//                            E_BILL_ASP_STAT_TYPE = (String) tAliceEntry.get("biz_tocharlesconfirmstatus");
                        E_BILL_ASP_STAT_TYPE = "NN";
                    } else {
                        E_BILL_ASP_STAT_TYPE = (String) tAliceEntry.get("biz_tocharlesconfirmstatus");

                        if("N".equals(E_BILL_ASP_STAT_TYPE)) {
                            E_BILL_ASP_STAT_TYPE = "NN";
                        } else if("Y".equals(E_BILL_ASP_STAT_TYPE)) {
                            E_BILL_ASP_STAT_TYPE = "YY";

                            Map tAliceDSig = (Map) tAliceEntry.get("tAliceDSig");

                            String sendStatus = (String) tAliceDSig.get("biz_tocharlesconfirmstatus");

                            if(!"".equals(sendStatus) && sendStatus != null) {
                                E_BILL_ASP_STAT_TYPE = sendStatus;
                            }
                        }
                    }

                    tx01_mapper.tx01010_doSaveTTIH(data);

//                        data.put("BILLSEQ", EXD_ID);
                    data.put("BILLSEQ", INV_SEQ);
                    data.put("E_BILL_ASP_STAT_TYPE", E_BILL_ASP_STAT_TYPE);
                    data.put("TAX_EXD_ID", exd_id);

                    tx01_mapper.tx01010_doSaveUPDATE_TTIH(data);
                } else {
                    mapRtn.put("RESULT", strResult);
                }
            } else if("DR".equals(t)) {  // 역발행, 미승인 취소
                List list = new ObjectMapper().readValue(strResult, List.class);
                Map map = (Map) list.get(0);
                boolean success = (boolean) map.get("success");
                String EXD_ID = (String) map.get("exd_id");
                String INV_SEQ = (String) map.get("inv_seq");

                String E_BILL_ASP_STAT_TYPE;

                if(success) {
                    Map tAliceEntry = (Map) map.get("tAliceEntry");
                    String inv_sign = (String) tAliceEntry.get("inv_sign");
                    String exd_id = (String) tAliceEntry.get("exd_id");
                    String tid_issueid = (String) tAliceEntry.get("tid_issueid");

//                        if("X".equals(inv_sign)) {
//                            E_BILL_ASP_STAT_TYPE = (String) tAliceEntry.get("biz_tocharlesconfirmstatus");
//                        } else {
//                            E_BILL_ASP_STAT_TYPE = (String) tAliceEntry.get("biz_tocharlesconfirmstatus");
//
//                            if("N".equals(E_BILL_ASP_STAT_TYPE)) {
//                                E_BILL_ASP_STAT_TYPE = "NN";
//                            } else if("Y".equals(E_BILL_ASP_STAT_TYPE)) {
//                                E_BILL_ASP_STAT_TYPE = "YY";
//
//                                Map tAliceDSig = (Map) tAliceEntry.get("tAliceDSig");
//
//                                String sendStatus = (String) tAliceDSig.get("biz_tocharlesconfirmstatus");
//
//                                if(!"".equals(sendStatus) && sendStatus != null) {
//                                    E_BILL_ASP_STAT_TYPE = sendStatus;
//                                }
//                            }
//                        }
                    E_BILL_ASP_STAT_TYPE = "DR";

//                        tx01_Mapper.tx01010_doSaveTTIH(data);

//                        data.put("BILLSEQ", EXD_ID);
                    data.put("BILLSEQ", INV_SEQ);
                    data.put("E_BILL_ASP_STAT_TYPE", E_BILL_ASP_STAT_TYPE);
                    data.put("E_BILL_ASP_STAT_DESC", data.get("TAX_CANCEL_REASON"));
                    data.put("TAX_EXD_ID", exd_id);
                    data.put("TAX_ISSUE_ID", tid_issueid);

                    tx01_mapper.tx01010_doSaveUPDATE_TTIH(data);
                } else {
                    mapRtn.put("RESULT", strResult);
                }
            } else if("S".equals(t)) {  // 상태조회
                Map map = new ObjectMapper().readValue(strResult, Map.class);

                boolean success = (boolean) map.get("success");
                String message = (String) map.get("message");

                mapRtn.put("success", success);
                mapRtn.put("message", message);

                if(success) {
                    List list = (List) map.get("tAliceEntrys");

                    mapRtn.put("RESULT", list);
                } else {
                    mapRtn.put("RESULT", strResult);
                }
            } else {    // 유니포스트 서버 전송 상태 확인
                Map map = new ObjectMapper().readValue(strResult, Map.class);
                boolean success = (boolean) map.get("success");

                if(!success) {
                    mapRtn.put("RESULT", strResult);
//                        throw new Exception(strResult);
                }
            }
        }else {
            System.out.println("Unexpected return code: " + httpRespCode);
        }
//        }catch (Exception e) {
//            System.out.println("Could not execute API call, reason: " + e.getMessage());
//        }
    }

    public byte[] encrypt(String key, String str) {
        byte[] enc = null;
        try {
            String CHARSET = "utf-8";
            enc = KISA_SEED_CBC.SEED_CBC_Encrypt(key.getBytes(), bszIV, str.getBytes(CHARSET), 0, str.getBytes(CHARSET).length);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return Base64.encode(enc);
    }

    public String getEncValue(String envKey, String plainText) throws UnsupportedEncodingException {
        return new String(encrypt(envKey, plainText), "utf-8") ;
    }















    // 월 매출/매입 마감종료
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String chkClose(Map<String, String> param) throws Exception {
    	return tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
    }






    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doSalesCloseCancel(Map<String, String> param) throws Exception {

//    	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
//    	if (!"0".equals(chk)) {
//    		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
//    	}

        tx01_mapper.doSalesCloseCancel(param);

    }

















    public void closeYnChkP(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {
        for (Map<String, Object> grid : gridData) {
        	Map<String,String> param = new HashMap<String,String>();
        	param.put("TYPE","P");
        	param.put("CLOSE_YEAR",String.valueOf(grid.get("RECIEPT_DATE")).substring(0,4));
        	param.put("CLOSE_MONTH",String.valueOf(grid.get("RECIEPT_DATE")).substring(4,6));
        	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
        	if (!"0".equals(chk)) {
        		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
        	}
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String AP_GO_INS(Map<String, String> formData, Map<String, Object> grid) throws Exception {
    	InetAddress inet = InetAddress.getLocalHost();
    	String IP = inet.getHostAddress();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String regUserId=userInfo.getUserId();
        boolean isDevServer = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        if(isDevServer) {
            //regUserId="725617";
        }

    	grid.put("DOCNO"     , grid.get("AP_NO"));
        grid.put("DOCSTAT"   , "POST");
        //증빙일(세금계산서일자)
        grid.put("BLDAT"     , grid.get("RECIEPT_DATE"));
        grid.put("ETAXNO"    , grid.get("SAP_TAX_NO"));

        grid.put("SNUSER"    , regUserId);
        grid.put("VENDOR_NAME_LOC"    , grid.get("VENDOR_NAME"));
        grid.put("AGENT_NAME_LOC"     , grid.get("CUST_NM"));
        grid.put("IRS_NO"    , String.valueOf(grid.get("AGENT_IRS_NO")).replaceAll("-", ""));
        grid.put("KNDNR_IRS_NO"    , String.valueOf(grid.get("AGENT_IRS_NO")).replaceAll("-", ""));
        grid.put("SGTXT"     , grid.get("SLIP_NM"));
        grid.put("FISCAL_YEAR"     , grid.get("SAP_YEAR"));
        grid.put("BELNR"     , grid.get("SAP_NO"));
        grid.put("PRICE_AMT"  , grid.get("PRICE_TOTAL"));
        grid.put("SUM_AMT"    , grid.get("TAX_TOTAL"));
        grid.put("CUST_TEL_NO"    , String.valueOf(grid.get("CUST_TEL_NO")).replaceAll("-", ""));
        grid.put("FWBAS"    , "0");


		if("T1".equals(grid.get("TAX_TYPE"))) {
	        grid.put("TAX_TYPE"  , "DA12");
		} else if("Z1".equals(grid.get("TAX_TYPE"))) { // 영세
	        grid.put("TAX_TYPE"  , "DA21");
		} else {
	        grid.put("TAX_TYPE"  , "DB31");
		}


        grid.put("ZFBDT"    , EverDate.addDateMonth(String.valueOf(grid.get("RECIEPT_DATE")),1).substring(0,6)+"15");
        grid.put("DOCSEQ",tx01_mapper.getDocSeq(grid));

        tx01_mapper.delSLHD(grid);
    	tx01_mapper.delSLDT(grid);
        tx01_mapper.saveSLHD_AP(grid);
    	tx01_mapper.saveSLDT_AP(grid);

    	List<Map<String, Object>> dgnsSendList = tx01_mapper.getSapList_AP(grid);
    	int k = 0;
    	String seqId = tx01_mapper.getSeqId_AP(null);


		Map<String,String> vendorInfo = tx01_mapper.getVendorInfo(grid);

    	for(Map<String,Object> dgns : dgnsSendList) {
    		dgns.put("SEQ_ID",seqId);
        	dgns.put("NEW_USER_ID",regUserId);
        	dgns.put("IP",IP);
    		dgns.put("BANK_ACCOUNT_NO","");
    		dgns.put("BANK_CODE","");
    		dgns.put("CUST_EMAIL_ADDR",grid.get("CUST_EMAIL_ADDR"));
    		dgns.put("CUST_TEL_NO",grid.get("CUST_TEL_NO"));
    		dgns.put("SLIP_NM_H",grid.get("SLIP_NM_H"));


    		dgns.put("BUDAT",grid.get("RECIEPT_DATE")); // 전기일

    		dgns.put("WW050", grid.get("WW050"));


    		// 반품일 경우 은행 계좌를 던지지 않는다.
    		if("N".equals(dgns.get("BAMPUM_YN"))) {
        		dgns.put("BANK_CODE",vendorInfo.get("PAY_BANK_CD"));
        		dgns.put("BANK_ACCOUNT_NO",vendorInfo.get("PAY_ACCOUNT_NO"));
        		dgns.put("DPSTR_USER_NM",vendorInfo.get("PAY_ACCOUNT_USER_NM"));
    		}


    		dgns.put("ESRO_TXIV_EDID",grid.get("TAX_ASP_BILLSEQ")); // 매입의 경우 매입세금계산서가 자동발급(국세청 이세로) 승인번호를 설정한다. 직접입력
    		dgns.put("EXEC_REQS_YMD",grid.get("EXEC_REQS_YMD")); // 지급요청일

            if(isDevServer) {
        		// 테스트 떄문에 강제로 사업자 코드 셋팅 매입 업체
//           	dgns.put("XREF3","6048137031");   // 사업자번호
//        		dgns.put("BANK_CODE"      ,"003");
//        		dgns.put("BANK_ACCOUNT_NO","030-093995-01-034");
//        		dgns.put("DPSTR_USER_NM"  ,"(주)케이디에스 디앤티");
//        		dgns.put("ESRO_TXIV_EDID"      ,"20221020410000080000ouc7f"); //매입의 경우 매입세금계산서가 자동발급(국세청 이세로) 승인번호를 설정한다. 직접입력
            }
    		if (k==0) {
        		tx01_mapper.saveAccSlipDocuMst_AP(dgns);
        		k = 1;
    		}
    		System.err.println("===================dgns.get(\"SHKZG\")==="+dgns.get("SHKZG"));
    		if(dgns.get("SHKZG").equals("S")){
    			dgns.put("NEW_SHKZG","D");
       		}else{
    			dgns.put("NEW_SHKZG","C");
       		}

    		tx01_mapper.saveAccSlipDocuDtl_AP(dgns);
    	}

    	return seqId;
    }



    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void AP_GO_CALL(String seqId,Map<String, String> formData, Map<String, Object> grid) throws Exception {
    	InetAddress inet = InetAddress.getLocalHost();
    	String IP = inet.getHostAddress();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String regUserId=userInfo.getUserId();
        boolean isDevServer = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        if(isDevServer) {
            //regUserId="725617";
        }

    	Map<String,Object> callMap = new HashMap<String,Object>();

    	callMap.put("SEQ_ID",seqId);
    	callMap.put("NEW_USER_ID",regUserId);
    	callMap.put("IP",IP);

    	tx01_mapper.callPkgAccautochitcrt(callMap);
    	System.err.println("==================================AR_GO_CALL=====result="+callMap);
    	/*
    	 * ERR_MSG=0001
    	 * ERR_CODE=0 성공 , ERR_CODE=-2 실패
    	*/

    	if (Integer.parseInt(String.valueOf(callMap.get("ERR_CODE"))) >= 0) {
        	grid.put("STATUS","S");
        	grid.put("SEQ_ID",callMap.get("SEQ_ID"));
        	grid.put("BELNR",callMap.get("ERR_MSG"));
    	} else {
        	grid.put("STATUS","E");
        	grid.put("SEQ_ID","");
        	grid.put("BELNR","");
    	}

    	grid.put("MESSAGE",callMap.get("ERR_MSG"));
    	// 연계 상태 저장
    	tx01_mapper.updateSlhd(grid);

    }




















    public void chkDgnsSend(Map<String, Object> gridData) throws Exception {
    	int chk = tx01_mapper.chkDgnsSend(gridData);
    	if (chk!=0) {
    		throw new Exception(msg.getMessageByScreenId("TX01_020", "020"));
    	}
    }




    public void closeYnChkS(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {
        for (Map<String, Object> grid : gridData) {
        	Map<String,String> param = new HashMap<String,String>();
        	param.put("TYPE","S");
        	param.put("CLOSE_YEAR",String.valueOf(grid.get("BUDAT")).substring(0,4));
        	param.put("CLOSE_MONTH",String.valueOf(grid.get("BUDAT")).substring(4,6));
        	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
        	if (!"0".equals(chk)) {
        		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
        	}
        }
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String AR_GO_INS(Map<String, String> formData, Map<String, Object> grid) throws Exception {
    	InetAddress inet = InetAddress.getLocalHost();
    	String IP = inet.getHostAddress();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String regUserId=userInfo.getUserId();
        boolean isDevServer = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        if(isDevServer) {
            //regUserId="725617";
        }
        grid.put("DOCNO"     , grid.get("AR_NO"));
        grid.put("DOCSTAT"   , "POST");
        //증빙일(세금계산서일자)
        grid.put("BLDAT"     , grid.get("BUDAT"));
        grid.put("ETAXNO"    , grid.get("SAP_TAX_NO"));

        grid.put("SNUSER"    , regUserId);
        grid.put("VENDOR_NAME_LOC"    , grid.get("VENDOR_NAME"));
        grid.put("AGENT_NAME_LOC"     , grid.get("AGENT_NAME"));




        grid.put("KNDNR_IRS_NO"    , String.valueOf(grid.get("AGENT_IRS_NO")).replaceAll("-", ""));

        grid.put("IRS_NO"    , String.valueOf(grid.get("AGENT_IRS_NO")).replaceAll("-", ""));

        grid.put("SGTXT"     , grid.get("SLIP_NM"));
        grid.put("FISCAL_YEAR"     , grid.get("SAP_YEAR"));
        grid.put("BELNR"     , grid.get("SAP_NO"));
        grid.put("PRICE_AMT"  , grid.get("PRICE_TOTAL"));
        grid.put("SUM_AMT"    , grid.get("TAX_TOTAL"));
        grid.put("CUST_TEL_NO"    , String.valueOf(grid.get("CUST_TEL_NO")).replaceAll("-", ""));
        grid.put("FWBAS"    , "0");


        Map<String,String> infoData = tx01_mapper.getCustInfo(grid);

        grid.put("GROUP_COMPANY_CODE"  , infoData.get("GROUP_COMPANY_CODE"));
        //grid.put("WW050"  , infoData.get("RELATION_COMPANY_TYPE"));
        grid.put("TAX_TYPE"  , infoData.get("TAX_TYPE"));


        grid.put("ZFBDT"    , EverDate.addDateMonth(String.valueOf(grid.get("BUDAT")),1).substring(0,6)+"15");
        grid.put("DOCSEQ",tx01_mapper.getDocSeq(grid));
        //SLIP_DRCR_IND 차변='D', 대변='C'로 값을 넘겨줍니다
        tx01_mapper.delSLHD(grid);
    	tx01_mapper.delSLDT(grid);
        tx01_mapper.saveSLHD(grid);
    	tx01_mapper.saveSLDT(grid);

    	List<Map<String, Object>> dgnsSendList = tx01_mapper.getSapList(grid);
    	int k = 0;
    	String seqId = tx01_mapper.getSeqId(null);

    	for(Map<String,Object> dgns : dgnsSendList) {
    		dgns.put("SEQ_ID",seqId);
        	dgns.put("NEW_USER_ID",regUserId);
        	dgns.put("IP",IP);
    		dgns.put("BANK_ACCOUNT_NO","");
    		dgns.put("BANK_CODE","");
    		dgns.put("CUST_EMAIL_ADDR",grid.get("CUST_EMAIL_ADDR"));
    		dgns.put("CUST_TEL_NO",grid.get("CUST_TEL_NO"));
    		dgns.put("SLIP_NM_H",grid.get("SLIP_NM_H"));

            if(isDevServer) {
           		//=====================================================================================================================================================================================
        		// 테스트 떄문에 강제로 사업자 코드 셋팅
           		//dgns.put("XREF3","2238108341");
           		//=====================================================================================================================================================================================
            }

    		if (k==0) {
        		tx01_mapper.saveAccSlipDocuMst(dgns);
        		k = 1;
    		}


    		System.err.println("===================dgns.get(\"SHKZG\")==="+dgns.get("SHKZG"));
    		if(dgns.get("SHKZG").equals("S")){
    			dgns.put("NEW_SHKZG","D");
       		}else{
    			dgns.put("NEW_SHKZG","C");
       		}

    		tx01_mapper.saveAccSlipDocuDtl(dgns);
    	}
    	return seqId;
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void AR_GO_CALL(String seqId,Map<String, String> formData, Map<String, Object> grid) throws Exception {
    	InetAddress inet = InetAddress.getLocalHost();
    	String IP = inet.getHostAddress();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String regUserId=userInfo.getUserId();
        boolean isDevServer = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
        if(isDevServer) {
            //regUserId="725617";
        }

    	Map<String,Object> callMap = new HashMap<String,Object>();

    	callMap.put("SEQ_ID",seqId);
    	callMap.put("NEW_USER_ID",regUserId);
    	callMap.put("IP",IP);

		/*
		 * ERR_MSG=0001
		 * ERR_CODE=0 성공 , ERR_CODE=-2 실패
		*/
    	tx01_mapper.callPkgAccautochitcrt(callMap);
    	System.err.println("====================================================================AR_GO_CALL==========callMap="+callMap);

    	if (callMap.get("ERR_CODE") != null && !"".equals(callMap.get("ERR_CODE")) && Integer.parseInt(String.valueOf(callMap.get("ERR_CODE"))) >= 0) {
        	grid.put("STATUS", "S");
        	grid.put("SEQ_ID", EverString.nullToEmptyString(callMap.get("SEQ_ID")));
        	grid.put("BELNR", EverString.nullToEmptyString(callMap.get("ERR_MSG")));
    	} else {
        	grid.put("STATUS", "E");
        	grid.put("SEQ_ID", "");
        	grid.put("BELNR", "");
    	}

    	grid.put("MESSAGE",callMap.get("ERR_MSG"));
    	// 연계 상태 저장
    	tx01_mapper.updateSlhd(grid);
    }






}
