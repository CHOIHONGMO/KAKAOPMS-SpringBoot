package com.st_ones.common.sms.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.common.mail.EverMailMapper;
import com.st_ones.common.sms.EverSmsMapper;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : EverSmsMapper.java
 * @author  c
 * @date 2013. 12. 01.
 * @version 1.0
 * @see
 */
@Service(value = "everSmsService")
public class EverSmsService extends BaseService {

	@Autowired EverSmsMapper everSmsMapper;
	@Autowired EverMailMapper everMailMapper;
	@Autowired private RealtimeIF_Mapper realtimeif_mapper; // 실시간 IF는 공통으로 처리

	public void sendSms(Map<String, String> param) throws Exception {

		String contents = EverString.nullToEmptyString(param.get("CONTENTS"));

		// SMS 내용을 80 Byte 이하로 자른다.
		ArrayList<String> list = EverString.chopSplitString(contents, 80);

		// 80bite 이하로만
		for (int i = 0; i < list.size(); i++) {

			// 직접 전송
			if( EverString.isNotEmpty(param.get("DIRECT_CELL_NUM")) ) {
				param.put("DIRECT_FLAG", "1");
			}

			// 수신자ID를 기준으로 헨드폰번호 가져오기
			Map<String,String> smsMap = everMailMapper.getReceiverMailAddress(param);
			if (smsMap != null) {
				param.putAll(smsMap);
			}

			System.out.println("====>SEND_USER_ID: " + param.get("SEND_USER_ID") + ", SEND_USER_NM: " + param.get("SEND_USER_NM") + ", SEND_TEL_NUM: " + param.get("SEND_TEL_NUM"));
			System.out.println("====>RECV_USER_ID: " + param.get("RECV_USER_ID") + ", RECV_USER_NM: " + param.get("RECV_USER_NM") + ", RECV_TEL_NUM: " + param.get("RECV_TEL_NUM"));

			if (param.get("SEND_USER_NM") == null) { param.put("SEND_USER_NM", "SYSTEM"); }
			if (param.get("SEND_USER_ID") == null) { param.put("SEND_USER_ID", PropertiesManager.getString("eversrm.userId.default")); }

			if(list.size() > 1) {
				param.put("SERVICE_TYPE", "3");	// 장문
			} else {
				param.put("SERVICE_TYPE", "0");	// 단문
			}

			param.put("CONTENTS", param.get("CONTENTS"));

			// 개발서버 또는 발신번호 없을때
			boolean isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag") ;
			if(isDevelopmentMode || EverString.isEmpty(param.get("SEND_TEL_NUM"))){
				param.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
			}
			// 개발서버 또는 수신번호 없을때 또는 전송유형이 test일때
			if(isDevelopmentMode || EverString.isEmpty(param.get("RECV_TEL_NUM")) || PropertiesManager.getString("eversrm.system.sms.send.type").equals("test")){
				param.put("RECV_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.test.receive.telNo"));
			}

			String sendTelNum = param.get("SEND_TEL_NUM");
			String recvTelNum = param.get("RECV_TEL_NUM");
			if(EverString.nullToEmptyString(sendTelNum).trim().length() <= 0) {
				break;
			}
			if(EverString.nullToEmptyString(recvTelNum).trim().length() <= 0) {
				break;
			}

			recvTelNum = Pattern.compile("[^0-9.]").matcher(recvTelNum).replaceAll("");
			param.put("SEND_TEL_NUM", sendTelNum);
			param.put("RECV_TEL_NUM", makePhoneNumber(recvTelNum));

			if(PropertiesManager.getBoolean("eversrm.system.sms.send.flag")) {
				String mailSq = everSmsMapper.getSmsSq(param);
				param.put("SMS_SQ", mailSq);
				// 실제 SMS전송 테이블에 INSERT
				realtimeif_mapper.insertRealSms(param);

				// SMS 전송이력
				everSmsMapper.doSendSms(param);

			}

			// SMS를 1번 보내고 나간다.
			break;
		}
	}

	public static String makePhoneNumber(String phoneNoStr) {

		String regEx = "(010|011|016|017|018?019)(.+)(.{4})";
		if(!Pattern.matches(regEx, phoneNoStr)) return null;
		return phoneNoStr.replaceAll(regEx, "$1-$2-$3");

	}
}