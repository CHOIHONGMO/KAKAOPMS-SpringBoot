package com.st_ones.evermp.BYM1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BYM1.server.BYM101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BYM1")
public class BYM101_Controller extends BaseController {

    @Autowired
    BYM101_Service bym1_Service;

    @Autowired
    CommonComboService commonComboService;

    @Autowired
    FileAttachService fileAttachService;

    /** *****************
     * My Page > 고객의소리
     * ******************/
    @RequestMapping(value = "/BYM1_060/view")
    public String BYM1_060(EverHttpRequest req) throws Exception {
        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("END_DATE", EverDate.getDate());
        return "/evermp/BYM1/BYM1_060";
    }

    @RequestMapping(value="/BYM1_060/bym1060_doSearch")
    public void bym1060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        UserInfo userInfo = UserInfoManager.getUserInfo();

        String REQ_COM_CD = userInfo.getCompanyCd();

        param.put("REQ_COM_CD", REQ_COM_CD);

        resp.setGridObject("grid", bym1_Service.bym1060_doSearch(param));
    }

	@RequestMapping(value = "/BYM1_060/bym1060_doSatisSave")
	public void bym1060_doSatisSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bym1_Service.bym1060_doSatisSave(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

    /** *****************
     * My Page > 고객의소리 > 고객의소리 등록/수정 팝업
     * ******************/
    @RequestMapping(value = "/BYM1_061/view")
    public String BYM1_061(EverHttpRequest req) throws Exception {
        Map<String, String> inParam = req.getParamDataMap();
        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();

        UserInfo userInfo = UserInfoManager.getUserInfo();

        String VC_NO = inParam.get("VC_NO");
        String REQ_COM_TEXT = "";
        String REQ_COMPANY_NM ="";
        String REQ_INFO_TEXT = "";
        String REQ_DATE = "";
        String REQ_INFO_DEPT_TEXT = "";
        String PH_DATE = "";
        String USER_TYPE = userInfo.getUserType();
        String REQ_COM_CD = "";
        String REQ_COM_TYPE = "";
        String USER_ID = userInfo.getUserId();
        String USER_EQ = "";
        String USER_DS_EQ = "";

        if(!"".equals(VC_NO) && null != VC_NO) {
            list = bym1_Service.bym1060_doSearch(inParam);
            Map<String, Object> data = list.get(0);

            REQ_COM_TEXT = data.get("REQ_COM_CD") + " / " + data.get("REQ_COM_NM");
            REQ_COMPANY_NM = String.valueOf(data.get("REQ_COM_NM"));
            REQ_INFO_TEXT = data.get("REQ_USER_NM") + " / " + data.get("REQ_DATE");
            REQ_INFO_DEPT_TEXT = String.valueOf(data.get("DEPT_NM"));
            PH_DATE = String.valueOf(data.get("PH_DATE"));

            if(USER_ID.equals(data.get("REQ_USER_ID"))) {
                USER_EQ = "Y";
            } else {
                USER_EQ = "N";
            }

            if(USER_ID.equals(data.get("DS_USER_ID"))) {
                USER_DS_EQ = "Y";
            } else {
                USER_DS_EQ = "N";
            }

            req.setAttribute("DATA", data);

        } else {
            REQ_COM_TEXT = userInfo.getCompanyCd() + " / " + userInfo.getCompanyNm();
            REQ_COMPANY_NM = userInfo.getCompanyNm();
            REQ_INFO_TEXT = userInfo.getUserNm() + " / " + EverDate.getFormatString("yyyy-MM-dd HH:mm");
            REQ_DATE = EverDate.getFormatString("yyyy-MM-dd");
            REQ_INFO_DEPT_TEXT = userInfo.getDeptNm();
            PH_DATE = EverDate.getDate();

            REQ_COM_CD = userInfo.getCompanyCd();
        }

        req.setAttribute("VC_NO", VC_NO);
        req.setAttribute("REQ_COM_TEXT", REQ_COM_TEXT);
        req.setAttribute("REQ_COMPANY_NM", REQ_COMPANY_NM);
        req.setAttribute("REQ_INFO_TEXT", REQ_INFO_TEXT);
        req.setAttribute("REQ_INFO_DEPT_TEXT", REQ_INFO_DEPT_TEXT);
        req.setAttribute("REQ_DATE", REQ_DATE);
        req.setAttribute("PH_DATE", PH_DATE);

        req.setAttribute("USER_EQ", USER_EQ);
        req.setAttribute("USER_DS_EQ", USER_DS_EQ);

        if("B".equals(USER_TYPE)) {
            REQ_COM_TYPE = "100";
        } else if("S".equals(USER_TYPE)) {
            REQ_COM_TYPE = "200";
        }

        req.setAttribute("USER_TYPE", USER_TYPE);
        req.setAttribute("REQ_COM_CD", REQ_COM_CD);
        req.setAttribute("REQ_COM_TYPE", REQ_COM_TYPE);
        req.setAttribute("CTRL_CD", userInfo.getCtrlCd());

        req.setAttribute("callbackFunction", inParam.get("callbackFunction"));

        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","BASIC");

        req.setAttribute("DS_USER_ID_Options", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/BYM1/BYM1_061";
    }

    @RequestMapping(value = "/BYM1_061/bym1061_doSave")
    public void bym1061_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> inParam = req.getFormData();

        inParam.put("EXC_TYPE", "S");
        String rtnMsg = bym1_Service.bym1061_doSave(inParam);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/BYM1_061/bym1061_doUpdate")
    public void bym1061_doUpdate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> inParam = req.getFormData();

        inParam.put("EXC_TYPE", "U");
        String rtnMsg = bym1_Service.bym1061_doSave(inParam);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/BYM1_061/bym1061_doDelete")
    public void bym1061_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> inParam = req.getFormData();

        String rtnMsg = bym1_Service.bym1061_doDelete(inParam);

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 사용자정보 팝업
     * ******************/
    @RequestMapping(value = "/BYM1_062/view")
    public String BYM1_062(EverHttpRequest req) throws Exception {
        Map<String, String> inParam = req.getParamDataMap();
        List<Map<String, Object>> list = bym1_Service.bym1062_doSearch(inParam);

        Map<String, Object> data = list.get(0);

        req.setAttribute("DATA", data);

        return "/evermp/BYM1/BYM1_062";
    }

    /** *****************
     * My Page > 관심품목관리
     * ******************/
    @RequestMapping(value = "/BYM1_020/view")
    public String BYM1_020(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	       return "/eversrm/noSuperAuth";
	  	      }
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BYM1/BYM1_020";
    }

    @RequestMapping(value="/BYM1_020/bym1020_doSearch")
    public void bym1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bym1_Service.bym1020_doSearch(param));
    }

    @RequestMapping(value="/BYM1_020/bym1020_doSearchD")
    public void bym1020_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bym1_Service.bym1020_doSearchD(param));
    }

    @RequestMapping(value = "/BYM1_020/bym1020_doSave")
    public void bym1002_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bym1_Service.bym1002_doSave(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/BYM1_020/bym1020_doDelete")
    public void bym1020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bym1_Service.bym1020_doDelete(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/BYM1_020/bym1020_doAddCart")
    public void bym1020_doAddCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("gridD");
        for(Map<String, Object> gridData : gridDatas) {
            gridData.put("CART_QT", gridData.get("MOQ_QTY"));
        }

        String rtnMsg = bym1_Service.bym1020_doAddCart(gridDatas);
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/BYM1_020/bym1020_doDeleteCart")
    public void bym1020_doDeleteCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bym1_Service.bym1020_doDeleteCart(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }
}