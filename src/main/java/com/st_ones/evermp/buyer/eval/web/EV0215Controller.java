package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0215Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0215Controller extends BaseController{
	@Autowired EV0215Service EV0215_service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0215/view")
	public String SRM_260(EverHttpRequest req, EverHttpResponse resp) {
		Map<String, String>form = new HashMap<String, String>();
		req.setAttribute("form", form);
		return "/evermp/buyer/eval/EV0215";
	}


	/**
	 * doSearch
	 *
	 * @param req request
	 * @return void
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0215/doImportSrm")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

		//param.put("START_DATE", EverDate.getGmtFromDate(param.get("START_DATE"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		//param.put("COSE_DATE", EverDate.getGmtToDate(param.get("CLOSE_DATE"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("CLOSE_DATE", EverDate.getGmtFromDate(param.get("CLOSE_DATE"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridObject("grid", EV0215_service.doImportSrm(param));
		resp.setResponseCode("true");

	}

	// 일괄평가생성
	@RequestMapping(value="/srm215_doEvalAll")
	public void srm215_doEvalAll(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> grid = req.getGridData("grid");

		Map<String, String> map = EV0215_service.srm215_doEvalAll(param, grid);

		resp.setResponseMessage(map.get("MSG"));
		resp.setResponseCode("true");
	}
}
