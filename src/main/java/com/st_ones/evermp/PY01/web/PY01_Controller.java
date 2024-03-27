package com.st_ones.evermp.PY01.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:15
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.PY01.service.PY01_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/PY01")
public class PY01_Controller extends BaseController {

    @Autowired private PY01_Service py01_Service;
    @Autowired CommonComboService commonComboService;

    /**
     * 운영사 > 정산관리 > 매출정산 > 마감대상
     */
    @RequestMapping(value="/PY01_010/view")
    public String PY01_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("END_DATE", EverDate.getLastDayofMonth( EverDate.getShortDateString().substring(0,6)  ) );
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));

        return "/evermp/PY01/PY01_010";
    }

    @RequestMapping(value = "/py01010_doSearch")
    public void py01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", py01_Service.py01010_doSearch(req.getFormData()));
    }

    // 매출마감 확정
    @RequestMapping(value = "/py01010_doSaveConfirm")
    public void py01010_doSaveConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.py01010_doSaveConfirm(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    /**
     * 운영사 > 정산관리 > 매출정산 > 매출마감 현황
     */
    @RequestMapping(value="/PY01_020/view")
    public String PY01_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.getMonth());
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));

        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));

        req.setAttribute("END_DATE", EverDate.getLastDayofMonth( EverDate.getShortDateString().substring(0,6)  ) );



        return "/evermp/PY01/PY01_020";
    }

    @RequestMapping(value = "/py01020_doSearch")
    public void py01020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", py01_Service.py01020_doSearch(req.getFormData()));
    }

    // 저장
    @RequestMapping(value = "/py01020_doSave")
    public void py01020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.py01020_doSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }




    // 저장
    @RequestMapping(value = "/doResultInfoSave")
    public void doResultInfoSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.doResultInfoSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }















    // 삭제
    @RequestMapping(value = "/py01020_doDelete")
    public void py01020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.py01020_doDelete(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 매출확정(대행)
    @RequestMapping(value = "/py01020_doConfirm")
    public void py01020_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.py01020_doConfirm(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 매출확정취소(대행)
    @RequestMapping(value = "/py01020_doConfirmCancle")
    public void py01020_doConfirmCancle(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.py01020_doConfirmCancle(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 매출계산서 생성
    @RequestMapping(value = "/py01020_doTaxCreate")
    public void py01020_doTaxCreate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py01_Service.py01020_doTaxCreate(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }
}
