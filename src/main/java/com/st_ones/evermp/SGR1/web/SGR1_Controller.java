package com.st_ones.evermp.SGR1.web;

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
import com.st_ones.evermp.SGR1.service.SGR1_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "/evermp/SGR1")
public class SGR1_Controller extends BaseController {

	@Autowired private SGR1_Service sgr1_Service;
	
	@Autowired private MessageService msg;
    
    /** ******************************************************************************************
     * 공급사 > 입고관리 > 입고관리 > 미입고현황
     * @param req
     * @return String
     * @throws Exception
     */
	@RequestMapping(value="/SGR1_010/view")
	public String SGR1_010(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
        
		return "/evermp/SGR1/SGR1_010";
	}

	@RequestMapping(value = "/sgr1010_doSearch")
	public void sgr1010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", sgr1_Service.sgr1010_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
	 * 공급사 > 입고관리 > 입고관리 > 입고현황
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/SGR1_020/view")
	public String SGR1_020(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());

		return "/evermp/SGR1/SGR1_020";
	}

	@RequestMapping(value = "/sgr1020_doSearch")
	public void sgr1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", sgr1_Service.sgr1020_doSearch(req.getFormData()));
	}
}
