package com.st_ones.evermp.SY02.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SY02.service.SY0201_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/SY02/SY0201")
public class SY0201_Controller extends BaseController {

    @Autowired
    SY0201_Service sy0201Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 휴일관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/SY02_001/view")
    public String SY02_001(EverHttpRequest req) throws Exception {
        return "/evermp/SY02/SY02_001";
    }

    @RequestMapping(value = "/sy02001_doSearch")
    public void sy02001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sy0201Service.sy02001_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/sy02001_doSave")
    public void sy02001_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("grid");

        Map<String, String> rtnMap = sy0201Service.sy02001_doSave(gridDatas);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/sy02001_doDelete")
    public void sy02001_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("grid");

        String returnMsg = sy0201Service.sy02001_doDelete(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    @RequestMapping(value = "/sy02001_doSearchTx")
    public void sy02001_doSearchTx(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridTx", sy0201Service.sy02001_doSearchTx(req.getFormData()));
    }

    @RequestMapping(value = "/sy02001_doSaveTx")
    public void sy02001_doSaveTx(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("gridTx");

        Map<String, String> rtnMap = sy0201Service.sy02001_doSaveTx(gridDatas);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/sy02001_doDeleteTx")
    public void sy02001_doDeleteTx(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("gridTx");

        String returnMsg = sy0201Service.sy02001_doDeleteTx(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

}