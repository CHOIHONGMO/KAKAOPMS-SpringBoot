package com.st_ones.evermp.BOD1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 18 오전 7:31
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BOD1.service.BOD101_Service;
import com.st_ones.evermp.BYM1.server.BYM101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BOD1/BOD101")
public class BOD101_Controller extends BaseController {

	@Autowired private BOD101_Service bod101Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;


	@Autowired BYM101_Service bym1_Service;

	/** ******************************************************************************************
     * 주문
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BOD1_010/view")
	public String BOD1_010(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
  	       return "/eversrm/noSuperAuth";
  	    }
		return "/evermp/BOD1/BOD1_010";
	}

	@RequestMapping(value = "/bod1010_doSearch")
	public void bod1010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String gridType = EverString.nullToEmptyString(req.getParameter("gridType"));
		List<Map<String, Object>> rtnList = null;
		if (gridType.equals("I")) {
			rtnList = bod101Service.bod1010_doSearch(req.getFormData(), gridType);
			resp.setGridObject("gridImg", rtnList);
		} else {
			rtnList = bod101Service.bod1010_doSearch(req.getFormData(), gridType);
			resp.setGridObject("grid", rtnList);
		}
	}

	@RequestMapping(value = "/bod1010_doCart")
	public void bod1010_doCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bym1_Service.bym1020_doAddCart(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	@RequestMapping(value = "/bod1010_IMG_doCart")
	public void bod1010_IMG_doCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bym1_Service.bym1020_doAddCart(req.getGridData("gridImg"));
		resp.setResponseMessage(rtnMsg);
	}
}
