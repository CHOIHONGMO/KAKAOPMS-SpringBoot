package com.st_ones.evermp.SSO1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SSO1.service.SSO1_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 8 오후 5:27
 */

@Controller
@RequestMapping(value = "/evermp/SSO1")
public class SSO1_Controller extends BaseController {

	@Autowired CommonComboService commonComboService;

    @Autowired FileAttachService fileAttachService;

    @Autowired CommonComboService comboService;

    @Autowired SSO1_Service sso1_Service;

    /** *****************
     * 견적관리
     * ******************/
    @RequestMapping(value = "/SSO1_010/view")
    public String SSO1_010_View(EverHttpRequest req) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("BUYER_CD", PropertiesManager.getString("eversrm.default.company.code"));

        req.setAttribute("ctrlUserIdOptions", commonComboService.getCodesAsJson("CB0066", param));
        req.setAttribute("progressCdOptions", commonComboService.getCodesAsJson("CB0068", param));
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));
        return "/evermp/SSO1/SSO1_010";
    }

    @RequestMapping(value = "/sso1010_doSearchT")
    public void sso1010_doSearchT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridT", sso1_Service.sso1010_doSearchT(req.getFormData()));
    }

    @RequestMapping(value = "/sso1010_doSearchB")
    public void sso1010_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
        param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));
        param.put("VENDOR_CD", userInfo.getCompanyCd());
        resp.setGridObject("gridB", sso1_Service.sso1010_doSearchB(param));
    }

    @RequestMapping(value = "/sso1010_doSend")
    public void sso1010_doSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("firstSendFlag", EverString.nullToEmptyString(req.getParameter("firstSendFlag")));
        param.put("giveUpFlag", EverString.nullToEmptyString(req.getParameter("giveUpFlag")));
        param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
        param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));
        param.put("QTA_NUM", EverString.nullToEmptyString(req.getParameter("QTA_NUM")));
        param.put("IP_ADDR", getClientIpAddress(req));

        String msg = sso1_Service.sso1010_doSend(param, req.getGridData("gridB"));
        resp.setResponseMessage(msg);
    }

    /** *****************
     * 납품지역 선택
     * ******************/
    @RequestMapping(value = "/SSO1_011/view")
    public String SSO1_011_View(EverHttpRequest req) throws Exception {
        req.setAttribute("regionList", comboService.getCodeCombo("MP005"));
        return "/evermp/SSO1/SSO1_011";
    }

    /** *****************
     * 계약현황
     * ******************/
    @RequestMapping(value = "/SSO1_020/view")
    public String SSO1_020_View(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("COMPANY_CD", userInfo.getManageCd());
        req.setAttribute("ctrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -3));
        req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));
        return "/evermp/SSO1/SSO1_020";
    }

    @RequestMapping(value = "/sso1020_doSearch")
    public void sso1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sso1_Service.sso1020_doSearch(req.getFormData()));
    }

    public String getClientIpAddress(EverHttpRequest req) {

        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = req.getRemoteAddr();
        }
        if (EverString.nullToEmptyString(ip).trim().length() <= 0) {
            ip = req.getRemoteAddr();
        }
        return EverString.nullToEmptyString(ip);
    }

}