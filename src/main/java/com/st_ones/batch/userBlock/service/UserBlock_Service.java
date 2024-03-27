package com.st_ones.batch.userBlock.service;

import com.st_ones.batch.userBlock.UserBlock_Mapper;
import com.st_ones.common.message.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "userBlock_Service")
public class UserBlock_Service {

    @Autowired private MessageService msg;
    @Autowired private UserBlock_Mapper userBlockMapper;
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String setUserBlock(Map<String, String> param) throws Exception {
    	
        List<Map<String, Object>> listData = userBlockMapper.doSelectBlockList(param);
        for (Map<String, Object> rowData : listData) {
        	
            String userType = String.valueOf(rowData.get("USER_TYPE"));
            if(userType.equals("U")) {
                userBlockMapper.setUserBlockU(rowData);
            } else {
                rowData.put("BLOCK_REASON", "1년간 시스템 미사용으로 강제 Block");
                userBlockMapper.setUserBlockC(rowData);
            }
        }
        return "[1년 미접속 사용자 Block: " + (listData==null?0:listData.size()) + "건] " + msg.getMessage("0001");
    }
}
