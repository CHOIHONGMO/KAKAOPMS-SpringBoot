package com.st_ones.evermp.IM04.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 22 chm
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM04.service.IM0402_Service;
import com.st_ones.evermp.IM04.service.IM0407_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM04/IM0407")
public class IM0407_Controller extends BaseController {

	@Autowired IM0407_Service im0407_Service;

	@Autowired IM0402_Service im0402_Service;

	@Autowired CommonComboService commonComboService;

	@Autowired FileAttachService fileAttachService;

	@Autowired LargeTextService largeTextService;

	@Autowired protected MessageService msg;

	@RequestMapping(value = "/IM04_007/view")
	public String IM04_007(EverHttpRequest req) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("ITEM_CLS1", req.getParameter("ITEM_CLS1")); // 대분류
		param.put("ITEM_CLS2", req.getParameter("ITEM_CLS2")); // 중분류
		param.put("ITEM_CLS3", req.getParameter("ITEM_CLS3")); // 소분류
		param.put("ITEM_CLS4", req.getParameter("ITEM_CLS4")); // 세분류
		param.put("ITEM_PATH_NM", req.getParameter("ITEM_PATH_NM")); // 세분류명
		req.setAttribute("param", param);

		return "/evermp/IM04/IM04_007";
	}

	@RequestMapping(value = "/IM04_008/view")
	public String IM04_008(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		return "/evermp/IM04/IM04_008";
	}

	@RequestMapping(value = "/doSearchTree")
	public void doSearchTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		BaseInfo baseInfo = (BaseInfo)req.getSession().getAttribute("ses");
		formData.put("CUST_CD", baseInfo.getCompanyCd());

		List<Map<String, Object>> list = im0402_Service.doSearchItemClassPopup_TREE(formData);
		resp.setParameter("treeData", EverConverter.getJsonString(list));
	}

	/**
	 * 분류별 속성 조회 (IM04_007/IM04_008)
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/doSearch")
	public void doSearchCAAT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", im0407_Service.doSearchCAAT(param));
		resp.setResponseCode("true");
	}

	/**
	 * 분류별 속성 등록 (IM04_007/IM04_008)
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/doSave")
	public void doSaveCAAT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");

		String message = im0407_Service.doSaveCAAT(formData, gridData);
        resp.setResponseMessage(message);
        resp.setResponseCode("true");

	}

	/**
	 * 분류별 속성 삭제 (IM04_007/IM04_008)
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/doDelete")
	public void doDeleteCAAT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");

		String message = im0407_Service.doDeleteCAAT(formData, gridData);
        resp.setResponseMessage(message);
        resp.setResponseCode("true");
	}

	/**
	 * 속성조회 팝업
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/IM04_008P/view")
	public String IM04_008P(EverHttpRequest req) throws Exception {
		return "/evermp/IM04/IM04_008P";
	}

	/**
	 * 속성항목 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/doSearchCommonCode")
	public void doSearchCommonCode(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("CODE_TYPE", "MP025");
		resp.setGridObject("grid", im0407_Service.doSearchCommonCode(param));
		resp.setResponseCode("true");
	}

}
