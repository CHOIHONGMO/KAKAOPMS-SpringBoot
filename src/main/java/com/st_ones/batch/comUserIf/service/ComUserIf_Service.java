package com.st_ones.batch.comUserIf.service;

import com.st_ones.batch.comUserIf.ComUserIf_Mapper;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "ComUserIf_Service")
public class ComUserIf_Service {

    @Autowired private MessageService msg;
    @Autowired private ComUserIf_Mapper comUserIf_mapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String ComUserIf(Map<String, String> param) throws Exception {
    	
    	String agentCd = PropertiesManager.getString("eversrm.default.company.code");
        List<Map<String, Object>> list = comUserIf_mapper.getComUserList();
        for (Map<String, Object> data : list) {
        	// 비밀번호 암호화
        	if( data.get("PASSWORD") != null && !"".equals(data.get("PASSWORD")) ) {
        		data.put("PASSWORD", EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(data.get("PASSWORD"))));
        	} else {
        		data.put("PASSWORD", EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(data.get("USER_ID"))));
        	}
    		
        	// 26(㈜대명소노시즌) : 운영사로 등록(stocuser)
        	// 고객사 : PF0131, 운영사 : PF0112
        	if( "26".equals(data.get("COMPANY_CODE")) ) {
        		// 1. 운영사인 경우 : 기존 고객사 삭제 후 운영사 등록
        		comUserIf_mapper.delComUserCVUR(data); 	// 고객사 사용자 삭제
            	
            	// 2. 운영사 사용자 등록
        		data.put("COMPANY_CODE", agentCd);		// 운영사 사용자 등록(26 => 2518)
            	comUserIf_mapper.setComUserUSER(data);	// 운영사 사용자 (stocuser)
            	comUserIf_mapper.setComUserBACP(data); 	// 직무권한 등록
        		data.put("AUTH_CD", "PF0112");
        	} else {
        		// 1. 고객사인 경우 : 기존 운영사 삭제 후 고객사 등록
        		comUserIf_mapper.delComUserUSER(data); 	// 운영사 사용자 삭제
            	
            	// 2. 고객사 사용자 등록
            	comUserIf_mapper.setComUserCVUR(data);
        		data.put("AUTH_CD", "PF0131");
        	}
        	comUserIf_mapper.setComUserUSAP(data); 		// 메뉴권한 등록
        	comUserIf_mapper.doUpdateIfResultUser(data);
        }
        
        return "[고객사 사용자정보: " + (list==null?0:list.size()) + "건] " + msg.getMessage("0001");
    }

}
