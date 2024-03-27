package com.st_ones.eversrm.board.sms.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.board.sms.service.BBOS_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : BBOS_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/basic/message")
public class BBOS_Controller extends BaseController {

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	private BBOS_Service bbos_Service;

	@Autowired
	LargeTextService largeTextService;

	@Autowired
	EverSmsService everSmsService;
	@Autowired
	EverMailService everMailService;

	@RequestMapping(value = "/BSN_070/view")
	public String smsMessageSendingHistory(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		req.setAttribute("fromDate", EverDate.getDate());
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("refSendType", commonComboService.getCodeComboAsJson("M033"));
		req.setAttribute("refSendResult", commonComboService.getCodeComboAsJson("M034"));

		return "/eversrm/basic/message/BSN_070";
	}

	@RequestMapping(value = "/BSN_070/doSearch")
	public void selectsmsMessageSendingHistory(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		param.put("startDate", EverDate.getGmtFromDate(param.get("startDate"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("endDate", EverDate.getGmtToDate(param.get("endDate"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		resp.setGridObject("grid", bbos_Service.selectSmsMessageSendingHistory(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/sendContentPopup/doSelectContent")
	public void doSelectContent(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> paramMap = req.getFormData();
		String sendType = paramMap.get("sendType");

		if (sendType.equals("M")) {
			req.setAttribute("form", bbos_Service.getMessageInfo(paramMap));
			resp.setResponseCode("true");

		} else if (sendType.equals("S")) {

			req.setAttribute("form", bbos_Service.getSmsContent(paramMap));
			resp.setResponseCode("true");
		}
	}

	@RequestMapping(value = "/recipientAppointment/view")
	public String recipientAppointment() throws Exception {
		return "/eversrm/basic/message/recipientAppointment";
	}

	@RequestMapping(value = "/BSN_080/view")
	public String BSN_080(EverHttpRequest req) throws Exception {
		Map<String, String> paramMap = req.getFormData();
		String sendType = paramMap.get("sendType");
		String sendId = paramMap.get("sendId");
		if (sendType == null) {
			paramMap.put("sendType", req.getParameter("sendType"));
			sendType = req.getParameter("sendType");
		}
		if (sendId == null) {
			paramMap.put("sendId", req.getParameter("sendId"));
			sendId = req.getParameter("sendId");
		}


		if (sendType.equals("M")) {

			paramMap.put("recEmail", req.getParameter("recEmail"));
			paramMap.put("sendEmail", req.getParameter("sendEmail"));

			Map<String, String> formData = bbos_Service.getMessageInfo(paramMap);

			String textNum = formData.get("MSG_TEXT_NUM");
			// 내용 불러오기
			String splitString = largeTextService.selectMailContents(textNum);
			formData.put("CONTENTS", splitString);

			req.setAttribute("form", formData);

		} else if (sendType.equals("S")) {

			req.setAttribute("form", bbos_Service.getSmsContent(paramMap));
		}
		return "/eversrm/basic/message/BSN_080";
	}

	@RequestMapping(value = "/selectUserSearch")
	public void selectUserSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		req.setAttribute("gridData", bbos_Service.selectUserSearch(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_040/view")
	public String companySmsMessageSend() throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		return "/eversrm/basic/message/BSN_040";
	}

	@RequestMapping(value = "/BSN_040/doSendSms")
	public void doSendSms(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("gridSms");
		String msg = bbos_Service.doSendSms(param, gridData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_040/doSendMsg")
	public void doSendMsg(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("gridMsg");
		String msg = bbos_Service.doSendMsg(param, gridData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
}