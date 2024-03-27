package com.st_ones.evermp.PY01.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.PY01.PY01_Mapper;
import com.st_ones.evermp.TX01.TX01_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "py01_Service")
public class PY01_Service extends BaseService {

    @Autowired private QueryGenService queryGenService;
    @Autowired private DocNumService docNumService;
    @Autowired private EverMailService everMailService;
    @Autowired PY01_Mapper py01_Mapper;
    @Autowired MessageService msg;
    @Autowired TX01_Mapper tx01_mapper;
    /**
     * 운영사 > 정산관리 > 매출정산 > 마감대상
     */
    public List<Map<String, Object>> py01010_doSearch(Map<String, String> param) {
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

        return py01_Mapper.py01010_doSearch(param);
    }

    /**
     * 매출마감 확정
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py01010_doSaveConfirm(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {



    	Map<String,String> param = new HashMap<String,String>();
    	param.put("TYPE","S");
    	param.put("CLOSE_YEAR",form.get("CLOSE_DATE").substring(0,4));
    	param.put("CLOSE_MONTH",form.get("CLOSE_DATE").substring(4,6));
    	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
    	if (!"0".equals(chk)) {
    		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
    	}

        UserInfo userInfo = UserInfoManager.getUserInfo();
        String multiCd = "003";

        String CLOSING_NO = docNumService.getDocNumber("CAR"); // 매출마감채번

        for(Map<String, Object> gridData : gridList) {
        	if(  py01_Mapper.chkCloseAR(gridData) !=0) {
        		throw new Exception(msg.getMessageByScreenId("PY01_010", "018"));
        	}


            gridData.put("CLOSING_NO", CLOSING_NO);
            gridData.put("CLOSING_YEAR_MONTH", form.get("CLOSE_MONTH"));
//                gridData.put("CLOSING_CNT", form.get("CLOSE_CNT"));
            gridData.put("CLOSING_CNT", "9");
            gridData.put("DOC_TYPE", "UI");


            gridData.put("RMK", form.get("RMK"));
            gridData.put("CLOSE_DATE", form.get("CLOSE_DATE"));


            py01_Mapper.py01010_doSaveConfirmAPAR(gridData);
            py01_Mapper.py01010_doSaveConfirmGRDT(gridData);
        }


        return msg.getMessageByScreenId("PY01_010", multiCd);
    }

    /**
     * 운영사 > 정산관리 > 매출정산 > 매출마감현황
     */
    public List<Map<String, Object>> py01020_doSearch(Map<String, String> param) {
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

        return py01_Mapper.py01020_doSearch(param);
    }

    // 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py01020_doSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            py01_Mapper.py01020_UPDATE_APAR(gridData);
        }

        return msg.getMessageByScreenId("PY01_020", "022");
    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doResultInfoSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            py01_Mapper.resultInfoSave(gridData);
        }

        return msg.getMessageByScreenId("PY01_020", "022");
    }



    // 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py01020_doDelete(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> gridData : gridList) {

            if(py01_Mapper.chkTaxCreAR(gridData) !=0 ) {
        		throw new Exception(msg.getMessageByScreenId("PY01_020", "034"));
            }



            py01_Mapper.py01020_doDeleteAPAR(gridData);
            py01_Mapper.py01020_doDeleteGRDT(gridData);
        }

        return msg.getMessageByScreenId("PY01_020", "006");
    }

    // 매출확정(대행)
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py01020_doConfirm(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            py01_Mapper.py01020_doConfirmAPAR(gridData);
            py01_Mapper.py01020_UPDATE_APAR(gridData);
        }

        return msg.getMessageByScreenId("PY01_020", "017");
    }

    // 매출확정취소(대행)
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py01020_doConfirmCancle(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            py01_Mapper.py01020_doConfirmCancleAPAR(gridData);
            py01_Mapper.py01020_UPDATE_APAR(gridData);
        }

        return msg.getMessageByScreenId("PY01_020", "027");
    }

    // 매출계산서 생성
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String py01020_doTaxCreate(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {


    	Map<String,String> param = new HashMap<String,String>();
    	param.put("TYPE","S");
    	param.put("CLOSE_YEAR",form.get("CLOSE_YEAR"));
    	param.put("CLOSE_MONTH",form.get("CLOSE_MONTH"));
    	String chk = tx01_mapper.tx01020_doSalesCloseCUCLCHK(param);
    	if (!"0".equals(chk)) {
    		throw new Exception(msg.getMessageByScreenId("TX01_020", "017"));
    	}



    	UserInfo userInfo = UserInfoManager.getUserInfo();
        String IN_KEY =userInfo.getUserId() + EverDate.getDate() + EverDate.getTime();
        String multiCd = "010";

        form.put("CLOSE_MONTH", form.get("CLOSE_YEAR") + form.get("CLOSE_MONTH"));

        for(Map<String, Object> gridData : gridList) {
            gridData.put("IN_KEY", IN_KEY);

            py01_Mapper.py01020_doTaxCreateINSERT_TTIT(gridData);
            py01_Mapper.py01020_UPDATE_APAR(gridData);
        }

        form.put("IN_KEY", IN_KEY);
        String TAX_NUM_CHK = py01_Mapper.py01020_doTaxCreateSELECT_TAX_CHK(form);

        if("0".equals(TAX_NUM_CHK)) {
            form.put("IN_OUT_TYPE", "OUT");
            List<Map<String, Object>> listH_OUT = py01_Mapper.py01020_doTaxCreateSELECT_TAX(form);

            for(Map<String, Object> dataH : listH_OUT) {
                String TAX_NUM = docNumService.getDocNumber("GTAX");
                dataH.put("TAX_NUM", TAX_NUM);
                dataH.put("IN_OUT_TYPE", "OUT");
                dataH.put("SALES_TYPE", "S");        // 매출매입구분 - S:매출, P:매입
//				dataH.put("TAX_SEND_TYPE", "100");    // 계산서발행방식 - 100:정발행, 200:역발행
                dataH.put("RQ_RE_TYPE", "2");        // 청구영수구분 - 2:청구, 1:영수
				dataH.put("ISSUE_DATE", form.get("ISSUE_DATE"));	// yyyy-mm-dd
//				dataH.put("E_BILL_ASP_TYPE", "0");        // 세금계산서ASP구분 - 0:SendBill, 1:외부

                py01_Mapper.py01020_doTaxCreateOUT_INSERT_TTIH(dataH);

                List<Map<String, Object>> listD = py01_Mapper.py01020_doTaxCreateSELECT_TTID(dataH);

                for (Map<String, Object> dataD : listD) {
                    py01_Mapper.py01020_doTaxCreateINSERT_TTID(dataD);
                    if(py01_Mapper.chkTaxCreAR(dataD) !=0 ) {
                    		throw new Exception(msg.getMessageByScreenId("PY01_020", "033"));
                    }
                    py01_Mapper.py01020_doTaxCreateUPDATE_APAR(dataD);
                }
            }
        } else {
            multiCd = "011";
        }

        py01_Mapper.py01020_doTaxCreateDELETE_TTIT(form);

        return msg.getMessageByScreenId("PY01_020", multiCd);
    }

    /**
     * 입력값의 유사어를 찾아서 like로 묶어서 리턴
     * @param param 파라메터
     * @param COL_NM 컬럼명
     * @param COL_VAL 컬럼값
     * @param key 바인딩명
     * @return map
     */
    public Map<String,String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
        param.put("COL_NM", COL_NM);
        param.put("COL_VAL", COL_VAL);

        param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

        return param;
    }
}
