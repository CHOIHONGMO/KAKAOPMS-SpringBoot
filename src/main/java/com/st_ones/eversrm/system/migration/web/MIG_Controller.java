package com.st_ones.eversrm.system.migration.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 23 오전 8:42
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.migration.service.MIG_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/system/migration")
public class MIG_Controller extends BaseController {

	@Autowired
	private MIG_Service mig_Service;

	@Autowired
	private CommonComboService commonComboService;
	
	/**
	 * [미사용] 마이그레이션
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/MIG_010/view")
	public String MIG_010(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		return "/eversrm/system/migration/MIG_010";
	}

	@RequestMapping(value = "/mig010_doSearch")
	public void mig010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		resp.setGridObject("grid", mig_Service.mig010_doSearch(formData));
	}

	@RequestMapping(value = "/mig010_doSave")
	public void mig010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String returnMsg = mig_Service.mig010_doSave(gridDatas);
		resp.setResponseMessage(returnMsg);
	}

}