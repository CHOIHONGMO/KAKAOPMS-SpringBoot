package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0197Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/buyer/eval")
public class EV0197Controller extends BaseController{
	@Autowired EV0197Service EV0197_service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0197/view")
	public String EV0197(EverHttpRequest req, EverHttpResponse resp) {
		Map<String, String>form = new HashMap<String, String>();
		form.put("REQ_START_DATE"	,EverDate.addMonths(-1));
		form.put("REQ_END_DATE"		,EverDate.getDate());
		req.setAttribute("form", form);
		return "/evermp/buyer/eval/EV0197";
	}

	/**
	 * doSearch
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();
		UserInfo baseInfo = UserInfoManager.getUserInfo();
//		param.put("REQ_START_DATE"	, EverDate.getGmtFromDate	(param.get("REQ_START_DATE"	), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("REQ_END_DATE"	, EverDate.getGmtToDate		(param.get("REQ_END_DATE"	), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridObject("grid", EV0197_service.doSearch(param));
		resp.setResponseCode("true");
	}

	/**
	 * doConfirm
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doConfirm")
	public void doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String msg = EV0197_service.doConfirm(gridDatas);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * doCancle
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doCancle")
	public void doCancle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String msg = EV0197_service.doCancle(gridDatas);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * doReEval
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doReEval")
	public void doReEval(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String msg = EV0197_service.doReEval(gridDatas);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * doInconsist
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doInconsist")
	public void doInconsist(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String msg = EV0197_service.doInconsist(gridDatas);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * doRequest
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doRequest")
	public void doRequest(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		Map<String, String> result = EV0197_service.doRequest(req.getFormData(), gridDatas);

        resp.setResponseCode("true");
        resp.setResponseMessage(result.get("message"));
        resp.setParameter("legacy_key", result.get("legacy_key"));
	}

	/**
	 * doImprove
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0197/doImprove")
	public void doImprove(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String msg = EV0197_service.doImprove(gridDatas);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}





}
