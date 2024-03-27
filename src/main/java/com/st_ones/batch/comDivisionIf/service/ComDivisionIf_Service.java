package com.st_ones.batch.comDivisionIf.service;

import com.st_ones.batch.comDivisionIf.ComDivisionIf_Mapper;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "ComDivisionIf_Service")
public class ComDivisionIf_Service {

    @Autowired private MessageService msg;
    @Autowired private ComDivisionIf_Mapper comDivisionIf_mapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ComDivisionIf(Map<String, String> param1) throws Exception {
    	
        List<Map<String, Object>> list = comDivisionIf_mapper.getComDivisionList();
        for (Map<String, Object> data : list) {
        	comDivisionIf_mapper.setComDivisionOGDP(data);
        	comDivisionIf_mapper.doUpdateIfResultDivision(data);
        }
        
        return "[고객사 사업부정보: " + (list==null?0:list.size()) + "건] " + msg.getMessage("0001");
    }

}
