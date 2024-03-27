package com.st_ones.batch.cpoIF.service;

import com.st_ones.batch.cpoIF.CPOIF_Mapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "CPOIF_Service")
public class CPOIF_Service {

    @Autowired private MessageService msg;
    @Autowired private CPOIF_Mapper cpoif_mapper;
    @Autowired private DocNumService docNumService;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String CPOIF(Map<String, String> param1) throws Exception {
        
    	Map<String, String> param = new HashMap<String, String>();
    	
        int CPO_SEQ = 0;
        String IF_CPO_NO = "";
        String IF_REQ_USER_ID = "";
        String CPO_NO = "";
        
        int failCnt = 0;
        String failPoNo = "";
        // 1. I/F 대상목록 가져오기
        List<Map<String, Object>> list = cpoif_mapper.CPOIF_SELECT_IF_PODT();
        for (Map<String, Object> data : list) {
        	
        	String changeFlag = EverString.nullToEmptyString(data.get("CHANGE_FLAG")); // Y:반품 else 주문
        	String itemCd = EverString.nullToEmptyString(data.get("ITEM_CD"));
            if (!"".equals(itemCd)) {
                param.put("BUYER_CD", EverString.nullToEmptyString(data.get("COMPANY_CODE")));			// 고객사코드
                param.put("PLANT_CD", EverString.nullToEmptyString(data.get("DIVISION_CODE")));			// 고객사 사업장코드
                param.put("REQ_DIVISION_CD", EverString.nullToEmptyString(data.get("PLANT_CODE")));		// 주문 사업장
                param.put("REQ_DEPT_CD", EverString.nullToEmptyString(data.get("ORDER_USER_DEPT")));	// 주문 부서
                param.put("ITEM_CD" , itemCd);		// 표준품목코드
                param.put("CUBL_SEQ", (data.get("CUBL_SEQ")==null?"":String.valueOf(data.get("CUBL_SEQ"))));	// 청구지번호
                param.put("CSDM_SEQ", (data.get("CSDM_SEQ")==null?"":String.valueOf(data.get("CSDM_SEQ"))));	// 배송지번호
                
                // 2. 사용자 배송지지정보 가져오기(29(민지)인 경우 STOCOGDP의 ADDR(기본주소))
                if(EverString.nullToEmptyString(data.get("COMPANY_CODE")).equals("29")) {
	                Map<String, Object> csdmMap = cpoif_mapper.getUserCSDM(param);
	                if (csdmMap != null && csdmMap.size() > 0) {
	                	data.put("DELY_ZIP_CD", csdmMap.get("CSDM_DELY_ZIP_CD"));
	                	data.put("DELY_ADDR_1", csdmMap.get("CSDM_DELY_ADDR_1"));
	                	data.put("DELY_ADDR_2", csdmMap.get("CSDM_DELY_ADDR_2"));
	                }
                }
                
                // 3. 고객사 청구지정보 가져오기
                Map<String, Object> cublMap = cpoif_mapper.getCustCUBL(param);
                if (cublMap != null && cublMap.size() > 0) {
                	data.putAll(cublMap);
                }
                
                // 4. 품목 및 단가정보 가져오기
                Map<String, Object> map = cpoif_mapper.doGetItemInfo(param);
	            if (map != null && map.size() > 0) {
	            	data.putAll(map);
	                
	                if (!IF_CPO_NO.equals(data.get("PO_NO"))) {
	                    IF_CPO_NO = EverString.nullToEmptyString(data.get("PO_NO"));
	                    IF_REQ_USER_ID = EverString.defaultIfEmpty(String.valueOf(data.get("DELY_TO_ID")), data.get("DELY_TO_ID").toString());
	                    CPO_SEQ = 1;
	                } else {
	                	CPO_SEQ++;
	                    if (!IF_REQ_USER_ID.equals(data.get("REQ_USER_NM"))) {
	                        IF_CPO_NO = EverString.nullToEmptyString(data.get("IF_CPO_NO"));
	                        IF_REQ_USER_ID = EverString.defaultIfEmpty(String.valueOf(data.get("DELY_TO_ID")), data.get("DELY_TO_ID").toString());
	                        CPO_SEQ = 1;
	                    }
	                }
	                
	                if(CPO_SEQ == 1) {
	                    if( "Y".equals(changeFlag) ) { // 반품주문
		                    CPO_NO = docNumService.getDocNumber("TB");
	                    } else {
		                    CPO_NO = docNumService.getDocNumber("CPO");
	                    }
	                    data.put("CPO_NO", CPO_NO);
	                    
	                    // 주문 Header 등록
	                    cpoif_mapper.CPOIF_INSERT_UPOHD(data);
	                    
	                    // 주문 Header 인터페이스 결과 등록
	                    cpoif_mapper.CPOIF_UPDATE_IFPOHD(data);
	                } else {
	                    data.put("CPO_NO", CPO_NO);
	                }
	                
	                // 주문 품목정보 등록
	                data.put("CPO_SEQ", CPO_SEQ);
	                cpoif_mapper.CPOIF_INSERT_UPODT(data);
	                
	                // 주문 품목 인터페이스 결과 등록
	                cpoif_mapper.CPOIF_UPDATE_IFPODT(data);
	            } else {
	            	failCnt++;
	            	failPoNo += ((failPoNo!="") ? "," : "") + data.get("PO_NO")+data.get("PO_SEQ");
	            }
            } else {
            	failCnt++;
            	failPoNo += ((failPoNo!="") ? "," : "") + data.get("PO_NO")+data.get("PO_SEQ");
            }
        }
        
        return "[고객사 주문정보: " + (list==null?0:list.size()) + "건], [품목 및 단가 없음: " + failCnt + "건] (" + failPoNo + ") " + msg.getMessage("0001");
    }

}
