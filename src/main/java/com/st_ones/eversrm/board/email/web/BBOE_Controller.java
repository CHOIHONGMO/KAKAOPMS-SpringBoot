package com.st_ones.eversrm.board.email.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.board.email.service.BBOE_Service;
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
 * @File Name : BBOE_Controller.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Controller
@RequestMapping(value = "/eversrm/board/email")
public class BBOE_Controller extends BaseController {

	@Autowired
	private BBOE_Service bboe_Service;

	@Autowired
	LargeTextService largeTextService;

	@RequestMapping(value = "/BSN_090/view")
	public String writeLetter(EverHttpRequest req) throws Exception {
		req.setAttribute("havePermission", "true");
			
		return "/eversrm/basic/email/BSN_090";
	}

	@RequestMapping(value = "/BSN_090/doSendLetter")
	public void doSendLetter(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		String msg = bboe_Service.doSendLetter(param);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_110/view")
	public String inBox(EverHttpRequest req) throws Exception {
		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/eversrm/basic/email/BSN_110";
	}

	@RequestMapping(value = "/BSN_110/doSearch")
	public void doSearchInbox(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param =req.getFormData();
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		param.put("addDateFrom", EverDate.getGmtFromDate(param.get("addDateFrom"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("addDateTo", EverDate.getGmtToDate(param.get("addDateTo"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		
		
		resp.setGridObject("grid", bboe_Service.doSearchInbox(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_110/doDelete")
	public void doDeleteInbox(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bboe_Service.doDeleteInbox(gridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_120/view")
	public String outBox(EverHttpRequest req) throws Exception {
		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/eversrm/basic/email/BSN_120";
	}

	@RequestMapping(value = "/BSN_120/doSearch")
	public void doSearchOutbox(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		
		
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		param.put("addDateFrom", EverDate.getGmtFromDate(param.get("addDateFrom"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("addDateTo", EverDate.getGmtToDate(param.get("addDateTo"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		
		
		
		
		
		
		
		resp.setGridObject("grid", bboe_Service.doSearchOutbox(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_120/doDelete")
	public void doDeleteOutbox(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bboe_Service.doDeleteOutbox(gridData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSN_130/view")
	public String popupLetter(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		
		if (param.get("MSG_NUM") == null || "".equals(param.get("MSG_NUM")   )) {
			param.put("GATE_CD", req.getParameter("GATE_CD"));
			param.put("MSG_NUM", req.getParameter("MSG_NUM"));
		}
		
		Map<String, Object> lParam = bboe_Service.doSelectPopupLetter(param);

		String splitString = largeTextService.selectLargeText((String)lParam.get("MAIL_TEXT_NUM"));
//		BaseInfo baseInfo = UserInfoManager.getUserInfoImpl();

		//if (String.valueOf(lParam.get("READ_USER_CNT")).equals("1") && !String.valueOf(lParam.get("REG_USER_ID")).equals(baseInfo.getUserId())) {
			bboe_Service.doUpdateReceiveDate(param);
		//}

		resp.setParameter("contents", splitString);
		
		lParam.put("CONTENT", splitString);
		req.setAttribute("formData", lParam);
		resp.setResponseCode("true");
		return "/eversrm/basic/email/BSN_130";
	}

}