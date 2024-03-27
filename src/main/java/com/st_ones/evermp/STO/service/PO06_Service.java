package com.st_ones.evermp.STO.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.evermp.STO.PO06_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "PO06_Service")
public class PO06_Service {
    @Autowired
    private PO06_Mapper po06Mapper;
    @Autowired
    private QueryGenService queryGenService;
    @Autowired DocNumService  docNumService;  // 문서번호채번
    @Autowired EApprovalService approvalService;
    @Autowired LargeTextService largeTextService;
    @Autowired MessageService msg;

    /** ******************************************************************************************
     **  재고관리 > 재고발주 > (재고,VMI)발주 처리 (PO0610)
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> po0610_doSearch(Map<String, String> formData) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "B.ITEM_DESC||B.ITEM_SPEC");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
    	return po06Mapper.po0610_doSearch(formData);
	}


    /** ******************************************************************************************
     **  재고관리 > 재고발주 > VMI재고보충 현황 (PO0620)
     */
    public List<Map<String, Object>> PO0620_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "UPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_CD");
            param.put("COL_VAL", param.get("MAKER_CD"));
            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_NM");
            param.put("COL_VAL", param.get("MAKER_NM"));
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
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

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));


        return po06Mapper.PO0620_doSearch(fParam);
    }

    // 주문하기
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String spo0601_doSave(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {
        String pMod = EverString.nullToEmptyString(param.get("pMod"));

        String CPONO = "";
        String SIGN_STATUS  = "E"; // 결재상태

        int cpoSeq = 1;
        CPONO = docNumService.getDocNumber("CPO");

        for( Map<String, Object> gridData : gridList ){
        	String prType = gridData.get("PR_TYPE").toString();  // G : 일반구매 , C : 시행구매
        	String PO_NO = docNumService.getDocNumber("PO");
        	String prSubject = "[업체보충신청]"+gridData.get("PR_SUBJECT").toString();
            // 주문하기
            if( "Order".equals(pMod) ) {
            	gridData.put("PR_SUBJECT",  prSubject);
            	gridData.put("CPO_NO",  CPONO);
            	gridData.put("PR_TYPE",  prType);
            	gridData.put("PO_NO",   PO_NO);
            	gridData.put("SIGN_STATUS",   SIGN_STATUS);
            	gridData.put("CUST_CD", param.get("CUST_CD"));
            	gridData.put("PROGRESS_CD", "5100"); // 발주대기
            	gridData.put("CPO_SEQ", cpoSeq);
               if( cpoSeq == 1 ){
               po06Mapper.doInsertUPOHD(gridData);
            	 }
               po06Mapper.doInsertUPODT(gridData);
               po06Mapper.doInsertYPOHD(gridData);
               po06Mapper.doInsertYPODT(gridData);

				 cpoSeq++;
            }
        }
        return msg.getMessageByScreenId("PO0550", "0038");
    }


}

