package com.st_ones.eversrm.basic.user.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.basic.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.*;

@Controller
@RequestMapping(value = "/eversrm/basic/user")
public class UserController extends BaseController {

	@Autowired
	private UserService userService;

	@Autowired
	private CommonComboService commonComboService;

//	@Autowired
//	private MessageService msg;

	@RequestMapping(value = "/userWorkHistory/view")
	public String userWorkHistory(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refJobType", commonComboService.getCodeComboAsJson("M022"));
		req.setAttribute("refSearchType", commonComboService.getCodeComboAsJson("M131"));
		req.setAttribute("refUserType", commonComboService.getCodeComboAsJson("M006"));
		req.setAttribute("fromDate", EverDate.getDate());
		req.setAttribute("toDate", EverDate.getDate());

		return "/eversrm/basic/user/userWorkHistory";
	}

	@RequestMapping(value = "/doSearchUserWorkHistory")
	public void doSearchUserWorkHistory(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("ADD_DATE_FROM", EverDate.getGmtFromDate(param.get("ADD_DATE_FROM"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("ADD_DATE_TO", EverDate.getGmtToDate(param.get("ADD_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		resp.setGridObject("grid1", userService.doSearchUserWorkHistory(param));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BADU_060/view")
	public String BADU_060(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		req.setAttribute("refJobType", commonComboService.getCodeComboAsJson("M022"));
		req.setAttribute("refSearchType", commonComboService.getCodeComboAsJson("M131"));
		req.setAttribute("refUserType", commonComboService.getCodeComboAsJson("M006"));
		req.setAttribute("fromDate", EverDate.getDate());
		req.setAttribute("toDate", EverDate.getDate());

		return "/eversrm/basic/user/BADU_060";
	}

	@RequestMapping(value = "/badu060_doSearch")
	public void badu060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("ADD_DATE_FROM", EverDate.getGmtFromDate(param.get("ADD_DATE_FROM"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("ADD_DATE_TO", EverDate.getGmtToDate(param.get("ADD_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridObject("grid1", userService.badu060_doSearch(param));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BADU_070/view")
	public String BADU_070(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		req.setAttribute("refJobType", commonComboService.getCodeComboAsJson("CB0092"));
		req.setAttribute("refSearchType", commonComboService.getCodeComboAsJson("M131"));
		req.setAttribute("refUserType", commonComboService.getCodeComboAsJson("M006"));
		req.setAttribute("fromDate", EverDate.getDate());
		req.setAttribute("toDate", EverDate.getDate());

		return "/eversrm/basic/user/BADU_070";
	}

	@RequestMapping(value = "/badu070_doSearch")
	public void badu070_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
//		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("ADD_DATE_FROM", EverDate.getGmtFromDate(param.get("ADD_DATE_FROM"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("ADD_DATE_TO", EverDate.getGmtToDate(param.get("ADD_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridObject("grid1", userService.badu070_doSearch(param));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/userMultiSearch/view")
	public String userMultiSearch(EverHttpRequest req) throws Exception {
		return "/eversrm/basic/user/userMultiSearch";
	}

	@RequestMapping(value = "/userMultiSearch/doSearchL")
	public void doSearchUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("USER_IDS", "");
    	resp.setGridObject("gridL", userService.doSearchUserMulti(converMap(param)));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/userMultiSearch/doSearchR")
	public void doSearchR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("USER_IDS", req.getParameter("USER_IDS"));
    	resp.setGridObject("gridR", userService.doSearchUserMulti(converMap(param)));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/userMultiSearch/doSendR")
	public void doSendR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridLDatas = req.getGridData("gridL");
		List<Map<String, Object>> gridRDatas = req.getGridData("gridR");

		List<Map<String, Object>> sendList = req.getGridData("gridR");

		for (Map<String, Object> gridLData : gridLDatas) {
			String user_id = (String)gridLData.get("USER_ID");

			boolean exists_flag = false;
			for (Map<String, Object> gridRData : gridRDatas) {
				if (user_id.equals(gridRData.get("USER_ID"))) {
					exists_flag = true;
					break;
				}
			}

			if (exists_flag) continue;
			/*
			Map<String, Object> sendData = new HashMap<String, Object>();
			sendData.put("USER_ID", user_id);
			sendData.put("USER_NM", (String)gridLData.get("USER_NM"));
			sendData.put("DEPT_NM", (String)gridLData.get("DEPT_NM"));
			sendData.put("POSITION_NM", (String)gridLData.get("POSITION_NM"));
			sendList.add(sendData);
			 */
			sendList.add(gridLData);
		}

    	resp.setGridObject("gridR", sendList);
		resp.setResponseCode("true");
	}

	@SuppressWarnings("rawtypes")
	public Map<String,Object> converMap(Map<String,String> mmm) {
		Map<String,Object> returnMap = new HashMap<String,Object>();

		Set set = mmm.keySet();
		Iterator iter = set.iterator();

		while(iter.hasNext()) {
			String key = iter.next().toString();
			returnMap.put(key, mmm.get(key));
		}
		return returnMap;
	}
}