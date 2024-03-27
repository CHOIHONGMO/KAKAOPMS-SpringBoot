package com.st_ones.evermp.SAP1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:15
 */

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SAP1.service.SAP1_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "/evermp/SAP1")
public class SAP1_Controller extends BaseController {

	@Autowired private SAP1_Service sap1_Service;
	
	@Autowired private MessageService msg;
    
    /** ******************************************************************************************
     * 공급사 > 정산관리 > 정산관리 > 마감현황(품목별)
     * @param req
     * @return String
     * @throws Exception
     */
	@RequestMapping(value="/SAP1_010/view")
	public String SAP1_010(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		req.setAttribute("CLOSING_YEAR_MONTH", EverDate.getYear() + EverDate.getMonth());

		return "/evermp/SAP1/SAP1_010";
	}

	@RequestMapping(value = "/sap1010_doSearch")
	public void sap1010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", sap1_Service.sap1010_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 공급사 > 정산관리 > 정산관리 > 마감현황(고객사별)
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/SAP1_020/view")
	public String SAP1_020(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		req.setAttribute("CLOSING_YEAR_MONTH", EverDate.getYear() + EverDate.getMonth());

		return "/evermp/SAP1/SAP1_020";
	}

	@RequestMapping(value = "/sap1020_doSearch")
	public void sap1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", sap1_Service.sap1020_doSearch(req.getFormData()));
	}

}
