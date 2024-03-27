package com.st_ones.common.serverpush.reverseajax;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.message.service.MessageService;
import org.directwebremoting.Browser;
import org.directwebremoting.ScriptSessions;
import org.directwebremoting.annotations.RemoteProxy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RemoteProxy
public class EverAlarm {

	@Autowired private MessageService msg;

	final static String ALL = "ALL";
	final static String BUYER = "BUYER";
	final static String SUPPLIER = "SUPPLIER";

	final static String USER = "USER";
	final static String COMPANY = "COMPANY";
	Logger logger = LoggerFactory.getLogger(this.getClass());

	public void noticeAlarm(Map<String, String> map) throws Exception {
		String userType = map.get("USER_TYPE");
		String alarmType = null;
		if (userType.equals("USNA")) {
			alarmType = ALL;
		} else if (userType.equals("USNI")) {
			alarmType = BUYER;
		} else if (userType.equals("USNE")) {
			alarmType = SUPPLIER;
		} else if (userType.equals("USXX")) {
			alarmType = SUPPLIER;
		}
		else {


		}
		
		pushData("noticeAlarm", alarmType, map, msg.getMessageForService(this, "NOTICE_REGIST"), null);
	}

	public void approvedRFQAlarmSepcifiedCompany(Map<String, String> map, List<String> receiverList) throws Exception {
		pushData("approvedRFQAlarm", COMPANY, map, String.format(msg.getMessageForService(this, "APPROVED_RFQ_ALARM"), map.get("RFX_NO"), map.get("RFQ_START_DATE")), receiverList);
	}

	public void approvedRFQAlarmAllSupplier(Map<String, String> map) throws Exception {
		pushData("approvedRFQAlarm", SUPPLIER, map, String.format(msg.getMessageForService(this, "APPROVED_RFQ_ALARM"), map.get("RFX_NO"), map.get("RFQ_START_DATE")), null);
	}

	public void letterAlarm(List<String> receiveList) throws Exception {
		pushData("letterAlarm", USER, null, "새로운 편지가 도착했습니다.", receiveList);
	}

	public void pushData(final String alarmName, final String userType, Map<String, String> map, final String message, List<String> receiverList) throws Exception {

		Map<String, String> tmpMap = map;
		List<String> recvList = receiverList;
		
		if (tmpMap == null) {
			tmpMap = new HashMap<String, String>();
		}
		if (recvList == null) {
			recvList = new ArrayList<String>();
		}

		final String dataString = new ObjectMapper().writeValueAsString(tmpMap);
		final String receiverListString = new ObjectMapper().writeValueAsString(recvList);
		Browser.withAllSessions( new Runnable() {
			public void run() {
				ScriptSessions.addFunctionCall("everAlarm.alarmCallBack", alarmName, userType, dataString, message, receiverListString);
			}
		});
	}
}
