package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0195Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

/**
 * 평가진행현황
 * EV0195_Controller.java
 * @author Administrator
 *
 */
@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0195Controller extends BaseController {

	@Autowired
	private EV0195Service EV0195_service;

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	FileAttachService fileAttachService;

//	////    EV0195    //////
	@RequestMapping(value = "/EV0195/view")
	public String EV0195(EverHttpRequest req,  EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();

		form.put("REQ_START_DATE", EverDate.addDays(-7));
		form.put("REQ_END_DATE"    , EverDate.getDate());

		req.setAttribute("autoSearchFlag", req.getParamDataMap().get("autoSearchFlag"));
		req.setAttribute("form", form);

		return "/evermp/buyer/eval/EV0195";
	}

	@RequestMapping(value = "/EV0195/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

//		param.put("REQ_START_DATE", EverDate.getGmtFromDate(param.get("REQ_START_DATE").toString(), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
//		param.put("REQ_END_DATE"	, EverDate.getGmtToDate(param.get("REQ_END_DATE").toString(), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));


		resp.setGridObject("grid", EV0195_service.doSearch(param));

		resp.setResponseCode("true");
	}


	@RequestMapping(value = "/EV0195/doComplete")
	public void doComplete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> grid = req.getGridData("grid");

		String msg = EV0195_service.doComplete(grid);

		resp.setResponseMessage(msg);

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0195/doCancel")
	public void doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> grid = req.getGridData("grid");

		String msg = EV0195_service.doCancel(grid);

		resp.setResponseMessage(msg);

		resp.setResponseCode("true");
	}



}