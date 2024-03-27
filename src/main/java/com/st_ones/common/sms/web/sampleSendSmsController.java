package com.st_ones.common.sms.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
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
 * @File Name : BAPM_Service.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */


@Controller
@RequestMapping(value = "/common/sms")
public class sampleSendSmsController extends BaseController {

	@Autowired
	private EverSmsService wiseSmsService;

	@RequestMapping(value = "/sampleSendSms/view")
	public String sampleWiseConfig() throws Exception {
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		return "/common/sms/sampleSendSms";
	}

	@SuppressWarnings("rawtypes")
	@RequestMapping(value = "/doSend")
	public void doSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("toFlag", req.getParameter("toFlag"));

		if(req.getParameter("toFlag").equals("S")) { // 입력한 번호로만 SMS 전송.
			wiseSmsService.sendSms(param);
		} else {
			List<Map<String, String>> results = null;
			for(Map result : results) {
				if(result.get("SMS_FLAG").equals("1")) {
					param.put("RECV_TEL_NO", (String) result.get("RECV_TEL_NO"));
					param.put("RECV_USER_NAME", (String) result.get("RECV_NAME"));
					wiseSmsService.sendSms(param);
				}
			}
		}
		resp.setResponseMessage("전송되었습니다.");
	}
}
