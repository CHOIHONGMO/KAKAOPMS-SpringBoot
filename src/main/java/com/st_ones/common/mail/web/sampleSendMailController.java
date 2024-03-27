package com.st_ones.common.mail.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/common/mail")
public class sampleSendMailController extends BaseController {

	@RequestMapping(value = "/sampleSendMail/view")
	public String sampleWiseConfig(EverHttpRequest req) {

		UserInfo baseInfo = UserInfoManager.getUserInfo();

		if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		req.setAttribute("mailSmtpServer",PropertiesManager.getString("eversrm.system.mailSmtpServer", ""));
		req.setAttribute("mailSmtpPort",PropertiesManager.getString("eversrm.system.mailSmtpPort", ""));
		req.setAttribute("mailSmtpEncodingSet",PropertiesManager.getString("eversrm.system.mailSmtpEncodingSet", ""));
		req.setAttribute("mailSmtpAuthenticationFlag",PropertiesManager.getString("eversrm.system.mailSmtpAuthenticationFlag", ""));
		req.setAttribute("mailSenderName",PropertiesManager.getString("eversrm.system.mailSenderName", ""));
		req.setAttribute("mailSenderMail",PropertiesManager.getString("eversrm.system.mailSenderMail", ""));
		req.setAttribute("mailSenderCompanyName",PropertiesManager.getString("eversrm.system.mailSenderCompanyName", ""));
		req.setAttribute("mailSmtpUser",PropertiesManager.getString("eversrm.system.mailSmtpUser", ""));
		req.setAttribute("mailSmtpPassword",PropertiesManager.getString("eversrm.system.mailSmtpPassword", ""));
		req.setAttribute("mailSendFlag",PropertiesManager.getString("eversrm.system.mailSendFlag", ""));
		return "/common/mail/sampleSendMail";
	}

	@Autowired
	private MailTemplate mt;

	@Autowired
	private EverMailService wms;

	@RequestMapping(value = "/doSend")
	public void doSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> paramdata = req.getFormData();
		paramdata.put("CONTENTS","");//mt.getMailTemplate("", paramdata.get("SUBJECT"), paramdata.get("CONTENTS"), PropertiesManager.getString("eversrm.system.mailSenderCompanyName", "St-Ones Co, Ltd."), ""));
		wms.sendMail(paramdata);
		resp.setResponseMessage("전송되었습니다.");
	}

	@SuppressWarnings("rawtypes")
	@RequestMapping(value = "/doSendAll")
	public void doSendAll(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> paramdata = req.getFormData();
		paramdata.put("CONTENTS","");//mt.getMailTemplate("", paramdata.get("SUBJECT"), paramdata.get("CONTENTS"), PropertiesManager.getString("eversrm.system.mailSenderCompanyName", "St-Ones Co, Ltd."), ""));
		List<Map<String, String>> results = null;
		for(Map<String, String> result : results) {
			if(result.get("MAIL_FLAG").equals("1")) {
				paramdata.put("RECEIVER_EMAIL",   result.get("RECV_EMAIL"));
				paramdata.put("RECEIVER_NM",      result.get("RECV_NAME"));
				wms.sendMail(paramdata);
			}
		}
		resp.setResponseCode("true");
		resp.setResponseMessage("전송되었습니다.");
	}

}
