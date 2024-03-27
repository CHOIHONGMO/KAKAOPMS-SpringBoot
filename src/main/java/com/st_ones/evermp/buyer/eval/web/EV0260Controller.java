package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0260Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0260Controller extends BaseController{
	@Autowired EV0260Service EV0260_service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0260/view")
	public String EV0260(EverHttpRequest req, EverHttpResponse resp) {
		Map<String, String>form = new HashMap<String, String>();
		form.put("REG_DATE_FROM",EverDate.addMonths(-1));
		form.put("REG_DATE_TO",EverDate.getDate());
		req.setAttribute("form", form);
		return "/evermp/buyer/eval/EV0260";
	}

	/**
	 * Do search.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0260/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{

		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

//		param.put("REG_DATE_FROM"	, EverDate.getGmtFromDate(param.get("REG_DATE_FROM"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("REG_DATE_TO"		, EverDate.getGmtToDate	 (param.get("REG_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridColStyle("grid", "FINAL_SCORE", "background-color", "#FFFF99");
		resp.setGridObject("grid", EV0260_service.doSearch(param));
		resp.setResponseCode("true");
	}

	/**
	 * Do save.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0260/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");
		String msg = EV0260_service.doSave(gridDatas);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
}
