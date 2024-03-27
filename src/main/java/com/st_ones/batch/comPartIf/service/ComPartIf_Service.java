package com.st_ones.batch.comPartIf.service;

import com.st_ones.batch.comPartIf.ComPartIf_Mapper;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "ComPartIf_Service")
public class ComPartIf_Service {

    @Autowired private MessageService msg;
    @Autowired private ComPartIf_Mapper comPartIf_mapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ComPlantIf(Map<String, String> param1) throws Exception {
    	
        List<Map<String, Object>> list = comPartIf_mapper.getComPartList();
        for (Map<String, Object> data : list) {
        	comPartIf_mapper.setComPartOGDP(data);
        	comPartIf_mapper.doUpdateIfResultPart(data);
        }
        
        return "[고객사 파트(팀)정보: " + (list==null?0:list.size()) + "건] " + msg.getMessage("0001");
    }

}
