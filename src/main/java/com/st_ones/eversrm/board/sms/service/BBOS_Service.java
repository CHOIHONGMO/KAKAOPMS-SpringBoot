
package com.st_ones.eversrm.board.sms.service;


import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.mail.web.MailTemplate;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.board.sms.BBOS_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BBOS_Service.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "bbos_Service")
public class BBOS_Service extends BaseService {

	@Autowired private MessageService msg;
	@Autowired private MailTemplate mt;
	@Autowired private EverMailService everMailService;
	@Autowired private EverSmsService everSmsService;
	@Autowired private BBOS_Mapper bbos_Mapper;
	@Autowired LargeTextService largeTextService;

	public List<Map<String, Object>> selectUserSearch(Map<String, String> param) {

		UserInfo baseInfo = UserInfoManager.getUserInfoImpl();
		String userType = baseInfo.getUserType();

		List<Map<String, Object>> resultList = new ArrayList<Map<String, Object>>();

		if ("S".equals(userType))
			resultList = bbos_Mapper.selectUserSearchB(param);
		else if ("B".equals(userType))
			resultList = bbos_Mapper.selectUserSearchS(param);

		return resultList;
	}
	
	/**
	 * System > Mail/SMS > Mail/SMS 전송 (BSN_040)
	 * @param formData
	 * @param gridData
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSendSms(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {
		
		String contents = EverString.nullToEmptyString(formData.get("CAPTION_SMS"));
		for(Map<String, Object> data : gridData) {
			if (data.get("RECV_TEL_NUM") != null && data.get("RECV_TEL_NUM") != "") {
				Map<String, String> map = new HashMap<String, String>();
				map.put("CONTENTS",  "[대명소노시즌] " + contents);
				map.put("RECV_USER_ID", EverString.nullToEmptyString(data.get("RECV_USER_ID")));
				map.put("DIRECT_USER_NM", EverString.nullToEmptyString(data.get("RECV_USER_NM")));
				map.put("DIRECT_CELL_NUM", EverString.nullToEmptyString(data.get("RECV_TEL_NUM")));
				map.put("REF_MODULE_CD", "BBOS");	//참조모듈
				map.put("BUYER_CD", PropertiesManager.getString("eversrm.default.company.code"));
				// SMS 발송
				everSmsService.sendSms(map);
				map.clear();
			}
		}
		return msg.getMessage("0001");
	}
	
	/**
	 * System > Mail/SMS > Mail/SMS 전송 (BSN_040)
	 * @param formData
	 * @param gridData
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSendMsg(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {

		//메일보내는 사용자만큼 for문을 돌면서 메일을 전송한다.
		for(Map<String, Object> data : gridData) {
			if (data.get("RECV_EMAIL") != null && data.get("RECV_EMAIL") != "") {
				Map<String,String> mdata = new HashMap<String, String>();
				mdata.put("SUBJECT", formData.get("SUBJECT"));			//제목******(필수)
				mdata.put("CONTENTS_TEMPLATE", mt.getMailTemplate("", formData.get("SUBJECT"), formData.get("CAPTION_MSG"), "", ""));
				mdata.put("RECV_USER_ID", EverString.nullToEmptyString(data.get("RECV_USER_ID")));
				mdata.put("DIRECT_USER_NM", EverString.nullToEmptyString(data.get("RECV_USER_NM")));
				mdata.put("DIRECT_TARGET", EverString.nullToEmptyString(data.get("RECV_EMAIL")));
				mdata.put("REF_NUM", "");
	            mdata.put("REF_MODULE_CD", "BBOS"); // 참조모듈	
	            // 메일전송.
				everMailService.sendMail(mdata);
				mdata.clear();
			}
		}
		return msg.getMessage("0001");
	}

	public List<Map<String, Object>> selectSmsMessageSendingHistory(Map<String, String> param) throws Exception {
		return bbos_Mapper.selectSmsMessageSendingHistory(param);
	}

	public Map<String, String> getSmsContent(Map<String, String> param) throws Exception {
		Map<String, String> params = bbos_Mapper.getSmsContent(param);
		params.put("CONTENTS", params.get("CONTENTS"));
		return params;
	}

	public Map<String, String> getMessageInfo(Map<String, String> param) throws Exception {

		Map<String, String> params = bbos_Mapper.getMessageInfo(param);
		String textNum = params.get("MSG_TEXT_NUM");
		String subject = params.get("SUBJECT");
		String splitString = largeTextService.selectLargeText(textNum);
		params.put("CONTENTS", splitString);
		params.put("subject", subject);
		return params;

	}

}