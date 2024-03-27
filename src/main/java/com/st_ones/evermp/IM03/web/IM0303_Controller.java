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
import com.st_ones.evermp.IM03.service.IM0303_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM03/IM0303")
public class IM0303_Controller extends BaseController {

    @Autowired
    IM0303_Service im0303Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;

    /** ****************************************************************************************************************
     * 신규품목처리현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_031/view")
    public String IM03_031(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();

    	req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

    	return "/evermp/IM03/IM03_031";
    }

    @RequestMapping(value="/IM03_031/doSearch")
    public void im03031_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", im0303Service.im03031_doSearch(param));
    }

    @RequestMapping(value = "/IM03_031/doAcpt")
	public void im03031_doAcpt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = im0303Service.im03031_doAcpt(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

    @RequestMapping(value = "/IM03_031/doReject")
	public void im03031_doReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = im0303Service.im03031_doReject(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	@RequestMapping(value = "/IM03_031/doDelete")
    public void im03031_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = im0303Service.im03031_doDelete(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    /** ****************************************************************************************************************
     * 계약현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_040/view")
    public String IM01_040(EverHttpRequest req) throws Exception {


        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
        req.setAttribute("form", req.getParamDataMap());

        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("nowDate", EverDate.getDate());
        req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/IM01/IM01_040";
    }

    @RequestMapping(value = "/im01040_doSearch")
    public void im01040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {



        resp.setGridObject("grid", im0303Service.im01040_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/im01040_doSendRFQ")
    public void im01040_doSendRFQ(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String msg = im0303Service.im01040_doSendRFQ(req.getFormData(), req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    /** ****************************************************************************************************************
     * 입고 내역 및 실적, 판매가 이력 확인 Popup
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_042/view")
    public String IM01_042(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_042";
    }

    @RequestMapping(value = "/im01042_doSearch")
    public void im01042_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0303Service.im01042_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 공급사변경
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_041/view")
    public String IM01_041(EverHttpRequest req) throws Exception {
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("todayTime", EverDate.getTime());
        return "/evermp/IM01/IM01_041";
    }

    @RequestMapping(value = "/im01041_doChangeVendor")
    public void im01041_doChangeVendor(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String msg = im0303Service.im01041_doChangeVendor(req.getFormData(), req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

}