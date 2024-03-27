package com.st_ones.batch.bdOpen.service;

import com.st_ones.batch.bdOpen.BdOpen_Mapper;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverString;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "BdOpen_Service")
public class BdOpen_Service {

    @Autowired private MessageService msg;
	@Autowired private BdOpen_Mapper bdopenMapper;
    @Autowired private EverSmsService everSmsService;


	public String sendSmsBdOpen(HashMap<String, String> hashMap) throws Exception {

    	List<Map<String, Object>> reqList = bdopenMapper.getBdOpenTargetList();
    	for (Map<String, Object> data : reqList) {

            if( !EverString.nullToEmptyString(data.get("RECV_CELL_NUM")).equals("") ){
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("CONTENTS", "[대명소노시즌] 입찰번호" + EverString.nullToEmptyString(data.get("RFX_NUM")) +" 입찰을 개찰해 주세요.");
                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(data.get("RECV_USER_ID"))); // 받는 사용자ID
                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(data.get("RECV_USER_NM"))); // 받는사람
                sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(data.get("RECV_CELL_NUM"))); // 받는 사람 전화번호
                sdata.put("REF_NUM", ""); // 참조번호
                sdata.put("REF_MODULE_CD", "RFQ"); // 참조모듈
				// SMS 전송
				everSmsService.sendSms(sdata);
				sdata.clear();
            }


    	}

		return "[입찰 개찰요청 SMS : " + (reqList==null?0:reqList.size()) + "건] " + msg.getMessage("0001");
	}
}
