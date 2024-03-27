package com.st_ones.evermp.IM03.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM03.service.IM0304_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM03/IM0304")
public class IM0304_Controller extends BaseController {

    @Autowired
    IM0304_Service im0304Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;

    /** ****************************************************************************************************************
     * 품목속성등록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_011/view")
    public String IM03_011(EverHttpRequest req) throws Exception {
        return "/evermp/IM03/IM03_011";
    }

    @RequestMapping(value = "/IM03_011/im03011_doSearch")
    public void im03011_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0304Service.im03011_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 품목 납품지역
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_012/view")
    public String IM03_012(EverHttpRequest req) throws Exception {

        req.setAttribute("regionCd", commonComboService.getCodeCombo("MP005"));
        return "/evermp/IM03/IM03_012";
    }

    /** ****************************************************************************************************************
     * 품목 단가적용대상
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_013/view")
    public String IM03_013(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        return "/evermp/IM03/IM03_013";
    }
    
    /** ****************************************************************************************************************
     * 품목관리 > 품목표준화 > 신규품목 재요청 승인(IM03_040) 미사용
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_040/view")
    public String IM03_040(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	
    	Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","C100");    //표준화담당
        req.setAttribute("cmsUserOptions", commonComboService.getCodesAsJson("CB0064", param));
        
        req.setAttribute("oneMonthAgo", EverDate.addMonths(-3));
        req.setAttribute("today", EverDate.getDate());
        
        return "/evermp/IM03/IM03_040";
    }

    @RequestMapping(value = "/IM03_040/doSearch")
    public void im03040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", im0304Service.im03040_doSearch(param));
    }
    
    @RequestMapping(value = "/IM03_040/doConfirm")
	public void im03040_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = im0304Service.im03040_doConfirm(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}
    
    @RequestMapping(value = "/IM03_040/doReject")
	public void im03040_doReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = im0304Service.im03040_doReject(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}
    
}