package com.st_ones.batch.grRequestDelaySms.service;

import com.st_ones.batch.grRequestDelaySms.GrRequestDelaySmsMapper;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "grRequestDelaySmsService")
public class GrRequestDelaySmsService {

	@Autowired private MessageService msg;
	@Autowired private GrRequestDelaySmsMapper grRequestDelaySmsMapper;
	@Autowired private EverSmsService everSmsService;
	
	@AuthorityIgnore
	public String doGrRequestDelaySms(Map<String, String> param) throws Exception {

        List<Map<String, Object>> list = grRequestDelaySmsMapper.doGrRequestDelaySmsSELECT(param);
        for( Map<String, Object> data : list ){
        	
        	// 납품완료 이후 3일이 지난후에도 미입고건에 대해 입고등록 요청 Mail [고객사]
            if(data.get("CELL_NUM") != null && !EverString.nullToEmptyString(data.get("CELL_NUM")).equals("")){

                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(data.get("USER_ID"))); // 받는 사용자ID
                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(data.get("USER_NM"))); // 받는사람
                sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(data.get("CELL_NUM"))); // 받는 사람 전화번호
                sdata.put("REF_NUM", ""); // 참조번호
                sdata.put("REF_MODULE_CD", "GM"); // 참조모듈

                String CNT = EverString.nullToEmptyString(String.valueOf(data.get("CPO_NO_CNT")));
                if("1".equals(CNT)) {
                    sdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(data.get("USER_NM")) + "님. " +
                            "주문하신(" + EverString.nullToEmptyString(data.get("CPO_NO")) + ")건의 입고등록을 요청합니다."); // 전송내용
                } else {
                    sdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(data.get("USER_NM")) + "님. " +
                            "주문하신(" + EverString.nullToEmptyString(data.get("CPO_NO")) + "외 " + CNT + ")건의 입고등록을 요청합니다."); // 전송내용
                }
                everSmsService.sendSms(sdata);
            }
        }
        return msg.getMessage("0001");
	}

}
