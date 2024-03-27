package com.st_ones.common.sms;

import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public interface EverSmsMapper {
	
	// SMS 전송항번 가져오기
    String getSmsSq(Map<String, String> param);
    
    // SMS 전송이력 저장
    void doSendSms(Map<String, String> param);
    
}