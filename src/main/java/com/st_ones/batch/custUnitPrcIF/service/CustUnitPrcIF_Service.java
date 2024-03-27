package com.st_ones.batch.custUnitPrcIF.service;

import com.st_ones.batch.custUnitPrcIF.CustUnitPrcIF_Mapper;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "CustUnitPrcIF_Service")
public class CustUnitPrcIF_Service {

    @Autowired private MessageService msg;
    @Autowired private CustUnitPrcIF_Mapper custUnitPrcIF_Mapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
	public String CustUnitPrcIF(HashMap<String, String> hashMap) throws Exception {
    	
    	List<Map<String, Object>> reqList = custUnitPrcIF_Mapper.getIfSendList();
    	for (Map<String, Object> data : reqList) {
    		// 매입단가가 유효한 경우에만 단가 i/f 인설트
    		custUnitPrcIF_Mapper.insCustUinfo(data);
    		
    		//판매단가 DGNS I/F 여부 세팅(ERP_IF_SEND_FLAG)
    		custUnitPrcIF_Mapper.updateDgnsIfFlag(data);
    	}
    	
		return "[고객사 판가정보 I/F: " + (reqList==null?0:reqList.size()) + "건] " + msg.getMessage("0001");
	}

}

