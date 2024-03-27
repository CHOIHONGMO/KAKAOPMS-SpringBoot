package com.st_ones.evermp.SIT1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SIT1.service.SIT101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/SIT1/SIT101")
public class SIT101_Controller extends BaseController {

    @Autowired
    SIT101_Service sit1_Service;

    @Autowired
    CommonComboService commonComboService;

    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 신규품목요청
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/SIT1_021/view")
    public String SIT1_021(EverHttpRequest req) throws Exception {
        req.setAttribute("today", EverDate.getDate());
        return "/evermp/SIT1/SIT1_021";
    }
    
    @RequestMapping(value="/SIT1_021/doSearch")
    public void sit1021_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
    	param.put("VENDOR_CD", EverString.nullToEmptyString(req.getParameter("VENDOR_CD")));

        resp.setGridObject("grid", sit1_Service.sit1021_doSearch(param));
    }
    
	@RequestMapping(value = "/SIT1_021/doSave")
	public void sit1021_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String progressCd = EverString.nullToEmptyString(req.getParameter("PROGRESS_CD"));
		Map<String, String> param = new HashMap<String, String>();
		param.put("PROGRESS_CD", progressCd);
		
		List<Map<String, Object>> gridDatas = req.getGridData("grid");
		String rtnMsg = sit1_Service.sit1021_doSave(param, gridDatas);
		
		resp.setResponseMessage(rtnMsg);
	}
	
	@RequestMapping(value = "/SIT1_021/doDelete")
	public void sit1021_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = sit1_Service.sit1021_doDelete(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

    /** ****************************************************************************************************************
     * 신규품목처리현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/SIT1_020/view")
    public String SIT1_020(EverHttpRequest req) throws Exception {
    	req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());
        
    	return "/evermp/SIT1/SIT1_020";
    }

    @RequestMapping(value="/SIT1_020/doSearch")
    public void sit1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
    	param.put("VENDOR_CD", EverString.nullToEmptyString(req.getParameter("VENDOR_CD")));

        resp.setGridObject("grid", sit1_Service.sit1020_doSearch(param));
    }
    
    @RequestMapping(value = "/SIT1_020/doCancel")
	public void sit1020_doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = sit1_Service.sit1020_doCancel(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

}