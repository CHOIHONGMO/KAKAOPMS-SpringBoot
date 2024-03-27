package com.st_ones.evermp.IM04.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 07 kkj
 */

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM04.service.IM0403_Service;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM04/IM0403")
public class IM0403_Controller extends BaseController {

	@Autowired IM0403_Service im0403_Service;

	@Autowired CommonComboService commonComboService;

	@Autowired FileAttachService fileAttachService;

	@Autowired LargeTextService largeTextService;

	@Autowired protected MessageService msg;

	/** ****************************************************************************************************************
	 * 품목분류(판촉)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/IM04_010/view")
	public String IM04_010(EverHttpRequest req) throws Exception {
		req.setAttribute("keyRule", PropertiesManager.getString("eversrm.item.type.management.rule"));
		return "/evermp/IM04/IM04_010";
	}

	@RequestMapping(value = "/IM04_010/im04010_selectItemClass")
	public void selectItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> result = im0403_Service.selectItemClass(param);

		resp.setGridObject("grid1", result);

		ObjectMapper om = new ObjectMapper();
		String jsonStr = om.writeValueAsString(result);
		resp.setParameter("refItemList", jsonStr);
		resp.setResponseCode("true");
	}


	//하위 판촉품목조회
	@RequestMapping(value = "/IM04_010/im04010_selectChildClass")
	public void selectChildClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		String itemClassType = param.get("ITEM_CLS_TYPE_CLICKED");
		if (itemClassType.equals("C1")) {
			resp.setGridObject("grid2", im0403_Service.selectChildClass(param));
		} else if (itemClassType.equals("C2")) {
			resp.setGridObject("grid3", im0403_Service.selectChildClass(param));
		}

		resp.setResponseCode("true");
	}


	//판촉품목분류 저장
	@RequestMapping(value = "/IM04_010/im04010_saveItemClass")
	public void saveItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = new ArrayList<Map<String, Object>>();

		String classToSave = req.getParameter("CLASS_TO_SAVE");
		if (classToSave.equals("C1")) {
			gridData = req.getGridData("grid1");
		} else if (classToSave.equals("C2")) {
			gridData = req.getGridData("grid2");
		} else if (classToSave.equals("C3")) {
			gridData = req.getGridData("grid3");
		}

		String message = im0403_Service.saveItemClass(gridData);
		resp.setResponseMessage(message);
		resp.setResponseCode("true");
	}


	//판촉품목분류 삭제
	@RequestMapping(value = "/IM04_010/im04010_deleteItemClass")
	public void deleteItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = new ArrayList<Map<String, Object>>();

		String classToDelete = req.getParameter("CLASS_TO_DELETE");
		if (classToDelete.equals("C1")) {
			gridData = req.getGridData("grid1");
		} else if (classToDelete.equals("C2")) {
			gridData = req.getGridData("grid2");
		} else if (classToDelete.equals("C3")) {
			gridData = req.getGridData("grid3");
		}

		String message = im0403_Service.deleteItemClass(gridData);
		resp.setResponseMessage(message);
		resp.setResponseCode("true");
	}



	/** ****************************************************************************************************************
	 * 판촉 품목분류팝업
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/IM04_011/view")
	public String IM04_011(EverHttpRequest req) throws Exception {

		Map<String, String> param = req.getFormData();

		String businessType = req.getParameter("businessType");
		if(StringUtils.isNotEmpty(businessType)) {
			param.put("businessType", businessType);
		}
		List<Map<String, Object>> list = im0403_Service.doSearchPTItemClassPopup_TREE(param);
		req.setAttribute("treeData", new ObjectMapper().writeValueAsString(list));
		req.setAttribute("refItemType", commonComboService.getCodeComboAsJson("M041"));
		return "/evermp/IM04/IM04_011";
	}

	@RequestMapping(value = "/IM04_011/doSearch")
	public void doSearchItemClassPopup(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		String businessType = req.getParameter("businessType");
		if(StringUtils.isNotEmpty(businessType)) {
			param.put("businessType", businessType);
		}
		List<Map<String,Object>> treeData = im0403_Service.doSearchPTItemClassPopup_TREE(param);
		resp.setParameter("treeData", EverConverter.getJsonString(treeData));
	}
}
