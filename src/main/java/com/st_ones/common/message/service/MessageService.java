package com.st_ones.common.message.service;

import com.st_ones.common.cache.data.MessageCache;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.service.BaseService;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
 * @File Name : MessageService.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "msg")
public class MessageService extends BaseService {

	/* @formatter:off */
	@Autowired private MessageCache messageCache;
	/* @formatter:on */

	Logger logger = LoggerFactory.getLogger(this.getClass());
	public List<Map<String, String>> getCommonMsg() throws Exception {

		String screenId = "MESSAGE";
		List<Map<String, String>> messages = messageCache.getData(screenId, UserInfoManager.getUserInfo().getLangCd());
		for (Map<String, String> map : messages) {
			map.put("MULTI_CD", map.get("MULTI_CD").replace("MESSAGE_", "M"));
		}
		return messages;
	}

    /**
     *
     * @param msgNo <br/>
     *              0011: 등록하시겠습니까? -> 0015: 성공적으로 등록되었습니다.<br/>
     *              0012: 수정하시겠습니까? -> 0016: 성공적으로 수정되었습니다.<br/>
     *              0013: 삭제하시겠습니까? -> 0017: 성공적으로 삭제되었습니다.<br/>
     *              0021: 저장하시겠습니까? -> 0031: 성공적으로 저장되었습니다.<br/>
     *              0037: 권한이 없습니다.<br/>
     *
     *              0109: 결재가 진행 중 혹은 완료된 상태라서 결재상신하실 수 없습니다.
     *              0100: 상신하시겠습니까? -> 0023: 결재상신되었습니다.
     *              0025: 승인하시겠습니까? -> 0057: 승인이 완료되었습니다.<br/>
     *              0022: 반려하시겠습니까? -> 0058: 반려처리 되었습니다.<br/>
     *              0024: 취소하시겠습니까? -> 0061: 취소되었습니다.<br/>

     * @return
     * @throws UserInfoNotFoundException
     */
	public String getMessage(String msgNo) throws Exception {
		List<Map<String, String>> commonMsg = getCommonMsg();
		for (Map<String, String> map : commonMsg) {
			if (map.get("MULTI_CD").equals("M" + msgNo)) {
				return map.get("MULTI_CONTENTS");
			}
		}

		logger.info("COMMON MESSAGE NOT EXIST - msgNo : " + msgNo);
		return null;
	}

	/**
	 * 식별이 가능하도록 정의된 열거형 타입의 메시지로 지정해서 조회해올 수 있는 메소드
	 * @param messageType
	 * @return
	 * @throws UserInfoNotFoundException
	 */
	public String getMessage(MessageType messageType) throws Exception {
		return this.getMessage(messageType.getCode());
	}

	public String getMessage(String msgNo, String code) throws Exception {
		String message = getMessage(msgNo);
		return message.replace("@", code);
	}

	public String getMessage(String msgNo, String GateCd, String langCd) throws Exception {
		messageCache.createTempSession(GateCd, langCd);
		String message = getMessage(msgNo);
		return message;
	}

	public String getMessage(String msgNo, String code, String GateCd, String langCd) throws Exception {
		messageCache.createTempSession(GateCd, langCd);
		String message = getMessage(msgNo);
		return message.replace("@", code);
	}

	public String getMessage(String msgNo, String[] code) throws Exception {
		String message = getMessage(msgNo);
		for(int i = 0 ; i < code.length ; i++)
			message = message.replaceFirst("@", code[i]);
		
		return message;
	}
	
	public String getMessageForService(Object clazz, String messageCd) throws Exception {
		String screenId = clazz.getClass().getSimpleName();
		String messageByScreenId = getMessageByScreenId(screenId, messageCd);
		if(messageByScreenId == null){
			logger.error(String.format("Message Does Not Exist. ScreenId: %s, messageCd: %s", screenId,messageCd));
		}
		return messageByScreenId;
	}

	public String getMessageByScreenId(String screenId, String multiCd) throws Exception {
		String langCd  = UserInfoManager.getUserInfo().getLangCd();
		return messageCache.getData(screenId, langCd, multiCd);
	}
	
	/**
	 * MULTI_CD, MULTI_CONTENTS
	 * @param screenId
	 * @param logging 
	 * @return
	 * @throws UserInfoNotFoundException
	 */
	public List<Map<String, String>> getMessagesByScreenId(String screenId, boolean logging) throws Exception {
		List<Map<String, String>> messages = null;
		String langCd = UserInfoManager.getUserInfo().getLangCd();
		messages = messageCache.getData(screenId, langCd);
		if(screenId.equals("MESSAGE")){
			for (Map<String, String> map : messages) {
				map.put("MULTI_CD", map.get("MULTI_CD").replace("MESSAGE_", "M"));
			}
		}
		return messages;
	}

	public String getCommonMsgByCode(String multiCd) throws Exception {
		return getMessageByScreenId("MESSAGE", multiCd);
	}
	
	public void setCommonMessage(HttpSession httpSession) throws Exception {

		List<Map<String, String>> msgResults = getCommonMsg();
		Map<String, String> msg = new HashMap<String, String>();
		for (Map<String, String> msgResult : msgResults) {
			String value = msgResult.get("MULTI_CONTENTS");
			value = value.replace("'", "’");
			value = value.replace("\"", "＂");
			msg.put(msgResult.get("MULTI_CD"), value);
		}
		httpSession.setAttribute("msg", msg);
	}
}