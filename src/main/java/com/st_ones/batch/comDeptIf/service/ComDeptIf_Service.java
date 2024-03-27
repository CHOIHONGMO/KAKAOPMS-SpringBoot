package com.st_ones.batch.comDeptIf.service;

import com.st_ones.batch.comDeptIf.ComDeptIf_Mapper;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "ComDeptIf_Service")
public class ComDeptIf_Service {

    @Autowired private MessageService msg;
    @Autowired private ComDeptIf_Mapper comDeptIf_mapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ComDeptIf(Map<String, String> param1) throws Exception {
    	
        List<Map<String, Object>> list = comDeptIf_mapper.getComDeptList();
        for (Map<String, Object> data : list) {
        	comDeptIf_mapper.setComDeptOGDP(data);
        	comDeptIf_mapper.doUpdateIfResultDept(data);
        }
        
        return "[고객사 부서정보: " + (list==null?0:list.size()) + "건] " + msg.getMessage("0001");
    }

}
