package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0045Service;
import com.st_ones.evermp.buyer.eval.service.EV0220Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 등록평가
 * EV0045_Controller.java
 * @author Administrator
 *
 */
@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0045Controller extends BaseController {

	@Autowired private EV0045Service EV0045_service;
	@Autowired private EV0220Service srm_220_service;
	@Autowired private CommonComboService commonComboService;
	@Autowired FileAttachService fileAttachService;

	// 등록평가
	@RequestMapping(value = "/EV0045/view")
	public String EV0045(EverHttpRequest req,  EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getParamDataMap();

		Map<String, Object> formData = EV0045_service.srm045_doSearch(form);

		if( form.get("EV_NUM") != null && !"".equals(form.get("EV_NUM")) ) {
			req.setAttribute("form", formData);
		} else {
			List<Map<String, Object>> list = EV0045_service.srm045_doSearchEVTM(form);

			if(list != null && list.size() > 0) {
				form.put("SCRE_EV_TPL_NUM", EverString.nullToEmptyString(list.get(0).get("EV_TPL_NUM")));
				form.put("SITE_EV_TPL_NUM", EverString.nullToEmptyString(list.get(0).get("EV_TPL_NUM")));
				form.put("EV_TPL_SUBJECT", EverString.nullToEmptyString(list.get(0).get("EV_TPL_SUBJECT")));
			}

			req.setAttribute("form", form);
		}

		return "/evermp/buyer/eval/EV0045";
	}

	@RequestMapping(value = "/EV0045/doSearch")
	public void srm045_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		Map<String, Object> form = EV0045_service.srm045_doSearch(param);

		resp.setParameter("form", EverConverter.getJsonString(form));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0045/doSearchSg")
	public void doSearchSg(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		resp.setGridObject("gridSg", EV0045_service.doSearchSg(param));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0045/doSearchUs")
	public void doSearchUs(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		resp.setGridObject("gridUs", EV0045_service.doSearchUs(param));

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/srm045_doSave")
	public void srm045_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridUs = req.getGridData("gridUs");

		String[] msg = EV0045_service.srm045_doSave(param, gridUs);

		resp.setResponseMessage(msg[1]);
		resp.setParameter("EV_NUM", msg[0]);

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0045/doDelete")
	public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridUs = req.getGridData("gridUs");

		String[] msg = EV0045_service.doDelete(param, gridUs);

		resp.setResponseMessage(msg[1]);
		resp.setParameter("EV_NUM", msg[0]);

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/srm045_doRequest")
	public void srm045_doRequest(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridUs = req.getGridData("gridUs");

		List<Map<String, Object>> grid = new ArrayList<>();
		Map<String, Object> map = new HashMap<>();
		map.put("EV_NUM", form.get("EV_NUM"));
		grid.add(0, map);

		String[] msg = EV0045_service.srm045_doRequest(form, gridUs);

		form.put("MENU_ID", "EV0045");

		String[] msg1 = srm_220_service.doExecute(form, grid);

		resp.setResponseMessage(msg[1]);
		resp.setParameter("EV_NUM", msg[0]);

		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/srm045_doCancel")
	public void srm045_doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridUs = req.getGridData("gridUs");

		String[] msg = EV0045_service.srm045_doCancel(param, gridUs);

		resp.setResponseMessage(msg[1]);
		resp.setParameter("EV_NUM", msg[0]);

		resp.setResponseCode("true");
	}



}