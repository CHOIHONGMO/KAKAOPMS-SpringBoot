package com.st_ones.batch.itemIF.service;

import com.st_ones.batch.itemIF.ITEMIF_Mapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "ITEMIF_Service")
public class ITEMIF_Service {

    @Autowired private MessageService msg;
    @Autowired private ITEMIF_Mapper itemif_mapper;
    @Autowired private DocNumService docNumService;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ITEMIF(Map<String, String> param1) throws Exception {
        
    	// 신규품목 등록요청
        List<Map<String, Object>> list = itemif_mapper.getNewItemList();
        for (Map<String, Object> data : list) {
    		if ("".equals(data.get("MRO_PR_NO")) || data.get("MRO_PR_NO") == null) {
    			String docNum = docNumService.getDocNumber("RE"); // 신규품목등록요청
    			data.put("ITEM_REQ_NO", docNum);
    		}
    		
        	itemif_mapper.setNewItemNWRQ(data);
        	itemif_mapper.doUpdateIfResultPRHD_IF(data);
        	itemif_mapper.doUpdateIfResultPRDT_IF(data);
        }
        
        // DGNS I/F 신규 상품은 MRO견적합의요청(IF_FLAG=2), DGNS견적합의완료(IF_FLAG=4)
        // DGNS에서 고객사 견적서 합의완료(4 -> 5로 변경)
        List<Map<String, Object>> cList = itemif_mapper.getItemConfirmList();
        for (Map<String, Object> cData : cList) {
        	// 신규상품 요청(STOUNWRQ)의 진행상태 : 500(견적합의)
        	itemif_mapper.doUpdateItemConfirmNWRQ(cData);
        	
        	// 견적품목(STOCRQDT)의 진행상태 : 600(계약완료), 견적헤더(STOCRQHD)의 진행상태 : 전체품목 600 => 600
        	itemif_mapper.doUpdateItemConfirmRQDT(cData);
        	itemif_mapper.doUpdateItemConfirmRQHD(cData);
        	
        	// 견적서 합의 완료 : MRO 반영 결과 UPDATE(4 -> 5로 변경)
        	itemif_mapper.doUpdateItemConfirmPRHD_IF(cData);
        	itemif_mapper.doUpdateItemConfirmPRDT_IF(cData);
        }
        
        return "[신규품목등록요청: " + (list==null?0:list.size()) + "건, 고객사 견적합의: " + (cList==null?0:cList.size()) + "건] " + msg.getMessage("0001");
    }

}
