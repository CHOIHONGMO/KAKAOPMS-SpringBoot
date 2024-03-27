package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0240Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0241Controller extends BaseController{

	@Autowired
	private EV0240Service EV0240_service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0241/view")
	public String EV0241(EverHttpRequest req, EverHttpResponse resp) {
		Map<String, String> form = req.getFormData();
		form.put("REG_DATE_FROM"	, EverDate.addDays(-30));
		form.put("REG_DATE_TO"    	, EverDate.getDate());

		req.setAttribute("autoSearchFlag", req.getParamDataMap().get("autoSearchFlag"));
		req.setAttribute("form", form);

		return "/evermp/buyer/eval/EV0241";
	}

	/**
	 * Do search.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value = "/EV0241/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

		param.put("REG_DATE_FROM"	, EverDate.getGmtFromDate	(param.get("REG_DATE_FROM"	), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("REG_DATE_TO"		, EverDate.getGmtToDate		(param.get("REG_DATE_TO"	), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridObject("grid", EV0240_service.doSearch(param));

		resp.setResponseCode("true");
	}

	/**
	 * doComplete
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value = "/EV0241/doComplete")
	public void doComplete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> grid = req.getGridData("grid");

		String completeFlag = EV0240_service.doCheckCompleteFlag(grid);
		resp.setParameter("completeFlag", completeFlag);

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0241/allUserComplete")
	public void allUserComplete(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> grid = req.getGridData("grid");

		//EV0240_service.doComplete(grid);

		String msg = EV0240_service.doComplete(grid);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * doIndivisualComplete
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value = "/EV0241/doIndivisualComplete")
	public void doIndivisualComplete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> grid = req.getGridData("grid");

		String vendorList = EV0240_service.doIndivisualComplete(grid);
		resp.setParameter("vendorList", vendorList);
		resp.setResponseCode("true");
	}



	/**
	 * doCancel
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value = "/EV0241/doCancel")
	public void doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> grid = req.getGridData("grid");
		String msg = EV0240_service.doCancel(grid);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}


}
