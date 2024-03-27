package com.st_ones.batch.grIF.service;

import com.st_ones.batch.grIF.GRIF_Mapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;


@Service(value = "GRIF_Service")
public class GRIF_Service {

    @Autowired private MessageService msg;
    @Autowired private GRIF_Mapper grif_mapper;
    @Autowired private DocNumService docNumService;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String GRIF(Map<String, String> param) throws Exception {
    	
        String PROGRESS_CD = "";
        String GR_COMPLETE_FLAG = "0";
        
        // 1. DGNS 입고요청 : IF_FLAG = 2 -> 3
        param.put("IF_FLAG", "2");
        List<Map<String, Object>> reqList = grif_mapper.GRIF_SELECT_IF_GRDT(param);
        if (reqList != null && reqList.size() > 0) {
        	
	        for (Map<String, Object> data : reqList) {
	            if( "Y".equals(data.get("INSERT_YN")) ) {
	                String GR_NO = docNumService.getDocNumber("GR");	// 입고번호
	                
	                data.put("GR_NO", GR_NO);
	                data.put("GR_SEQ", data.get("IF_GR_SEQ"));
	                data.put("PR_TYPE", "G");	// 구매유형: 일반(G)
	                
	                grif_mapper.GRIF_INSERT_GRDT(data);		// 입고정보
	                grif_mapper.GRIF_UPDATE_UIVDT(data);	// 대행사 납품
	                grif_mapper.GRIF_UPDATE_YIVDT(data);	// 공급사 납품
	                
	                float CPO_QTY = Float.parseFloat(String.valueOf(data.get("CPO_QTY")));	// 주문수량
	                float GR_QTY  = Float.parseFloat(String.valueOf(data.get("GR_QTY")));	// 입고수량
	                float TOT_GR_QTY = grif_mapper.GRIF_SELECT_TOT_GR_QTY(data);			// 총입고수량
	                
	                if((TOT_GR_QTY + GR_QTY) >= CPO_QTY) {
	                    PROGRESS_CD = "6300"; // 입고완료
	                    GR_COMPLETE_FLAG = "1";
	                } else {
	                    PROGRESS_CD = "6120"; // 납품중(=부분입고)
	                }
	                
	                data.put("PROGRESS_CD", PROGRESS_CD);
	                data.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);
	                
	                grif_mapper.GRIF_UPDATE_YPODT(data);	// 공급사 발주
	                grif_mapper.GRIF_UPDATE_UPODT(data);	// 고객사 주문
	            }
	            else {
	            	data.put("MP_RESULT_MSG", "이미 입고 되었습니다.");
	            }
	            
	            data.put("IF_STATUS", "3");
	            grif_mapper.GRIF_UPDATE_IFGRDT(data);
	        }
        }
        
        // 2. DGNS 입고확정 : IF_FLAG = 8 -> 9
        // 입고 확정은 입고 처리 후 발주 종결
        param.put("IF_FLAG", "8");
        List<Map<String, Object>> grCompList = grif_mapper.GRIF_SELECT_IF_GRDT(param);
        if (grCompList != null && grCompList.size() > 0) {
        	
	        for (Map<String, Object> data : grCompList) {
	            if( "Y".equals(data.get("INSERT_YN")) ) {
	            	String GR_NO = docNumService.getDocNumber("GR");	// 입고번호
	            	
	            	data.put("GR_NO", GR_NO);
	                data.put("GR_SEQ", data.get("IF_GR_SEQ"));
	                data.put("PR_TYPE", "G");	// 구매유형: 일반(G)
	                
	                grif_mapper.GRIF_INSERT_GRDT(data);	// 입고데이터 생성
	                grif_mapper.GRIF_UPDATE_UIVDT(data);// 운영사 납품서 입고수량 변경
	                grif_mapper.GRIF_UPDATE_YIVDT(data);// 공급사 납품서 입고수량 번경
	                
	                // 입고완료 및 발주종결 이후 미입고 납품서는 삭제 처리함
	                //grif_mapper.GRIF_DELETE_UIVDT(data);// 운영사 미입고 납품서 삭제
	                //grif_mapper.GRIF_DELETE_YIVDT(data);// 공급사 미입고 납품서 삭제
	                
	                PROGRESS_CD = "6300"; // 입고완료
	                GR_COMPLETE_FLAG = "1";
	                
	                data.put("PROGRESS_CD", PROGRESS_CD);
	                data.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);
	                
	                grif_mapper.GRIF_UPDATE_YPODT(data);
	                grif_mapper.GRIF_UPDATE_UPODT(data);
	            }
	            else {
	            	data.put("MP_RESULT_MSG", "이미 입고 되었습니다.");
	            }
	            
	            data.put("IF_STATUS", "9");
	            grif_mapper.GRIF_UPDATE_IFGRDT(data);
	        }
        }
        
        // 3. DGNS 입고취소 : IF_FLAG = 6 -> 7
        param.put("IF_FLAG", "6");
        List<Map<String, Object>> cancelList = grif_mapper.GRIF_SELECT_IF_GRDT(param);
        if (cancelList != null && cancelList.size() > 0) {
        	
            for (Map<String, Object> data : cancelList) {
                grif_mapper.GRIF_CANCEL_GRDT(data);
                grif_mapper.GRIF_CANCEL_UIVDT(data);
                grif_mapper.GRIF_CANCEL_YIVDT(data);
                
                data.put("PROGRESS_CD", "6120");	// 납품중
                data.put("GR_COMPLETE_FLAG", "0");	// 입고완료여부
                
                grif_mapper.GRIF_UPDATE_YPODT(data);
                grif_mapper.GRIF_UPDATE_UPODT(data);
                
                // IF 테이블 결과값 UPDATE
                data.put("IF_STATUS", "7");
                grif_mapper.GRIF_UPDATE_IFGRDT(data);
            }
        }
        
        // 4. DGNS 반품요청 : IF_FLAG = 4 -> 5
        param.put("IF_FLAG", "4");
        List<Map<String, Object>> returnList = grif_mapper.GRIF_SELECT_IF_GRDT(param);
        if (returnList != null && returnList.size() > 0) {
        	
            for (Map<String, Object> data : returnList) {
                if( "Y".equals(data.get("INSERT_YN")) ) {
                    String GR_NO = docNumService.getDocNumber("GR");
                    
                    data.put("GR_NO", GR_NO);
                    data.put("GR_SEQ", data.get("IF_GR_SEQ"));
                    data.put("PR_TYPE", "R");	// 구매유형: 반품(R)
                    
                    grif_mapper.GRIF_INSERT_GRDT(data);
                    grif_mapper.GRIF_UPDATE_UIVDT(data);
                    grif_mapper.GRIF_UPDATE_YIVDT(data);

                    float CPO_QTY = Float.parseFloat(String.valueOf(data.get("CPO_QTY")));
                    float GR_QTY  = Float.parseFloat(String.valueOf(data.get("GR_QTY")));
                    float TOT_GR_QTY = grif_mapper.GRIF_SELECT_TOT_GR_QTY(data);
                    
                    if((TOT_GR_QTY + GR_QTY) >= CPO_QTY) {
                        PROGRESS_CD = "6300"; // 반품완료
                        GR_COMPLETE_FLAG = "1";
                    } else {
                        PROGRESS_CD = "6120"; // 반품 납품중(=부분입고)
                    }
                    
                    data.put("PROGRESS_CD", PROGRESS_CD);
                    data.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);
                    
                    grif_mapper.GRIF_UPDATE_YPODT(data);
                    grif_mapper.GRIF_UPDATE_UPODT(data);
                }
                else {
                	data.put("MP_RESULT_MSG", "이미 반품 되었습니다.");
                }
                
                data.put("IF_STATUS", "5");
                grif_mapper.GRIF_UPDATE_IFGRDT(data);
            }
        }
        
        // 5. DGNS 반품확정 : IF_FLAG = 10 -> 11
        // 반품 확정은 반품 처리 후 발주 종결
        param.put("IF_FLAG", "10");
        List<Map<String, Object>> reCompList = grif_mapper.GRIF_SELECT_IF_GRDT(param);
        if (reCompList != null && reCompList.size() > 0) {
        	
            for (Map<String, Object> data : reCompList) {
                if( "Y".equals(data.get("INSERT_YN")) ) {
                	String GR_NO = docNumService.getDocNumber("GR");	// 입고번호
                	
                	data.put("GR_NO", GR_NO);
                    data.put("GR_SEQ", data.get("IF_GR_SEQ"));
                    data.put("PR_TYPE", "G");	// 구매유형: 일반(G)
                    
                    grif_mapper.GRIF_INSERT_GRDT(data);
                    grif_mapper.GRIF_UPDATE_UIVDT(data);
                    grif_mapper.GRIF_UPDATE_YIVDT(data);
                    
                    // 입고완료 및 발주종결 이후 미입고 납품서는 삭제 처리함
	                //grif_mapper.GRIF_DELETE_UIVDT(data);// 운영사 미입고 납품서 삭제
	                //grif_mapper.GRIF_DELETE_YIVDT(data);// 공급사 미입고 납품서 삭제
	                
                    PROGRESS_CD = "6300"; 	// 반품완료
                    GR_COMPLETE_FLAG = "1";	// 반품완료
                    
                    data.put("PROGRESS_CD", PROGRESS_CD);
                    data.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);
                    
                    grif_mapper.GRIF_UPDATE_YPODT(data);
                    grif_mapper.GRIF_UPDATE_UPODT(data);
                }
                else {
                	data.put("MP_RESULT_MSG", "이미 반품입고 되었습니다.");
                }
                
                data.put("IF_STATUS", "9");
                grif_mapper.GRIF_UPDATE_IFGRDT(data);
            }
        }
        
        return "[입고요청(2): " + (reqList==null?0:reqList.size()) + "건, 입고확정(8): " + (grCompList==null?0:grCompList.size()) + "건, 입고취소(6): " + (cancelList==null?0:cancelList.size()) + "건, 반품요청(4): " + (returnList==null?0:returnList.size()) + "건], 반품완료(10): " + (reCompList==null?0:reCompList.size()) + "건] " + msg.getMessage("0001");
    }

}
