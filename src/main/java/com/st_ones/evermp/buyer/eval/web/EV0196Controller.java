package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0196Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

/**
 * 평가진행현황
 * SRM_195_Controller.java
 * @author Administrator
 *
 */
@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0196Controller extends BaseController {

	@Autowired
	private EV0196Service EV0196_service;

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	FileAttachService fileAttachService;

//	////    SRM_195    //////
	@RequestMapping(value = "/EV0196/view")
	public String EV0196(EverHttpRequest req,  EverHttpResponse resp) throws Exception {
		//req.setAttribute("result_enter_cd", commonComboService.getCodeComboAsJson("M123"));

		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();
		param.put("EV_NUM"			, req.getParameter("EV_NUM"));
		param.put("EV_TPL_NUM"		, req.getParameter("EV_TPL_NUM"));
		param.put("VENDOR_CD"		, req.getParameter("VENDOR_CD"));
		param.put("VENDOR_NM"		, req.getParameter("VENDOR_NM"));
		param.put("EV_USER_ID"		, req.getParameter("EV_USER_ID"));
		param.put("EV_USER_NM"	, req.getParameter("EV_USER_NM"));

		req.setAttribute("form"	, EV0196_service.doSearchEvvu(param));

		return "/evermp/buyer/eval/EV0196";
	}

	@RequestMapping(value = "/EV0196/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		Map<String, Object> form = new java.util.HashMap<String,Object>();
		form.put("ev_type"			,	EV0196_service.doSearchType(param));
		form.put("ev_subject"	,	EV0196_service.doSearchSubject(param));
		form.put("ev_item"			,	EV0196_service.doSearch(param));
		form.put("evvu"				,	EV0196_service.doSearchEvvu(param));


		resp.setParameter("form2", EverConverter.getJsonString(form));

		resp.setResponseCode("true");
	}


	@RequestMapping(value = "/srm196_doSave")
	public void srm196_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		String msg = EV0196_service.srm196_doSave(param);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0196_PRT/view")
	public String EV0196_PRT(EverHttpRequest req,  EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getParamDataMap();
		Map<String, Object> form = new java.util.HashMap<String,Object>();

		form.put("ev_type", EV0196_service.doSearchType(param));
		form.put("ev_subject", EV0196_service.doSearchSubject(param));
		form.put("EVVM", EV0196_service.srm196prt_searchEVVM(param));

		req.setAttribute("form2", EverConverter.getJsonString(form));

		return "/evermp/buyer/eval/EV0196_PRT";
	}
}