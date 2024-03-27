package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0220Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0220Controller extends BaseController {

	@Autowired private EV0220Service EV0220_service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0220/view")
	public String EV0220(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		Map<String, String>form = new HashMap<String, String>();
		form.put("REG_DATE_FROM",EverDate.addMonths(-1));
		form.put("REG_DATE_TO"	,EverDate.getDate());
		req.setAttribute("form", form);

		return "/evermp/buyer/eval/EV0220";
	}

	/**
	 * doSearch
	 *
	 * @param req request
	 * @return void
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0220/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

		param.put("REG_DATE_FROM"	, EverDate.getGmtFromDate	(param.get("REG_DATE_FROM"	), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("REG_DATE_TO"		, EverDate.getGmtToDate		(param.get("REG_DATE_TO"	), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridObject("grid", EV0220_service.doSearch(param));
		resp.setResponseCode("true");

	}

	/**
	 * doExecute.
	 *
	 * @param req request
	 * @return void
	 * @throws Exception the exception
     */
	@RequestMapping(value = "/EV0220/doExecute")
	public void doExecute(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String,String> form = req.getFormData();
		form.put("FAIL_BASE"		, req.getParameter("FAIL_BASE"));
		form.put("FAILCLAIM_BASE"	, req.getParameter("FAILCLAIM_BASE"));
		List<Map<String, Object>> grid = req.getGridData("grid");

		String[] msg = EV0220_service.doExecute(form, grid);

		resp.setResponseMessage(msg[0]);
		resp.setParameter("msg2", msg[1]);

		resp.setResponseCode("true");
	}






	@RequestMapping(value="/EV0221/view")
	public String EV0221(EverHttpRequest req, EverHttpResponse resp) {
		Map<String, String>form = new HashMap<String, String>();
		form.put("REG_DATE_FROM",EverDate.addMonths(-1));
		form.put("REG_DATE_TO"	,EverDate.getDate());
		req.setAttribute("form", form);

		return "/evermp/buyer/eval/EV0221";
	}
	@RequestMapping(value="/EV0221/doSearch")
	public void doSearchEsgGubun(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", EV0220_service.doSearchEsgGubun(param));
		resp.setResponseCode("true");

	}

	@RequestMapping(value = "/EV0221/doSave")
	public void doEsgGuganSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String,String> form = req.getFormData();
		List<Map<String, Object>> grid = req.getGridData("grid");

		String[] msg = EV0220_service.doEsgGuganSave(form, grid);

		resp.setResponseMessage(msg[0]);
		resp.setParameter("msg2", msg[1]);

		resp.setResponseCode("true");
	}


}
