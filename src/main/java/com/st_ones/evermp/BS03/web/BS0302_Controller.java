package com.st_ones.evermp.BS03.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS03.service.BS0302_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BS03/BS0302")
public class BS0302_Controller extends BaseController {

    @Autowired
    BS0302_Service bs0302Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 승인관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_004/view")
    public String BS03_004(EverHttpRequest req) throws Exception {
        return "/evermp/BS03/BS03_004";
    }

    //승인관리조회
    @RequestMapping(value="/bs03004_doSearch")
    public void bs03004_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0302Service.bs03004_doSearch(param));


    }

    /** ****************************************************************************************************************
     * 사용자조회
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_005/view")
    public String BS03_005(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS03/BS03_005";
    }

    //사용자조회
    @RequestMapping(value="/bs03005_doSearch")
    public void bs03005_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0302Service.bs03005_doSearch(param));
    }

    //사용자수정
    @RequestMapping(value="/bs03005_doUpdate")
    public void bs03005_doUpdate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0302Service.bs03005_doUpdate(gridList);

        resp.setResponseMessage(returnMsg);
    }

    //사용자 삭제
    @RequestMapping(value="/bs03005_doDelete")
    public void bs03005_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0302Service.bs03005_doDelete(gridList);
        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 사용자상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_006/view")
    public String BS03_006(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();
        String userId = EverString.nullToEmptyString(req.getParameter("USER_ID"));
        // 시스템 관리자, 고객 및 공급사 담당자, 관리자
        boolean havePermission = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("B100") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100");
        req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));
        if(!userId.equals("")) {
            param.put("USER_ID", userId);
            formData = bs0302Service.bs03005_doSearchInfo(param);
            if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
                havePermission = true;
            }
        }
        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));
        req.setAttribute("havePermission", havePermission);
        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);
        return "/evermp/BS03/BS03_006";
    }


    @RequestMapping(value = "/BS03_006_1/view")
    public String BS03_006_1(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();
        String userId = EverString.nullToEmptyString(req.getParameter("USER_ID"));
        // 시스템 관리자, 고객 및 공급사 담당자, 관리자
        boolean havePermission = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("B100") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100");
        req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));
        if(!userId.equals("")) {
            param.put("USER_ID", userId);
            formData = bs0302Service.bs03005_doSearchInfo(param);
            if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
                havePermission = true;
            }
        }
        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));
        req.setAttribute("havePermission", havePermission);
        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);
        return "/evermp/BS03/BS03_006_1";
    }

















    //사용자수정
    @RequestMapping(value="/bs03006_doSave")
    public void bs03006_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	String returnMsg = bs0302Service.bs03006_doSave(req.getFormData());

    	resp.setResponseMessage(returnMsg);
    }

    //사용자 아이디중복체크
    @RequestMapping(value="/bs01002_doCheckUserId")
    public void bs01002_doCheckUserId(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setParameter("POSSIBLE_FLAG", bs0302Service.bs01002_doCheckUserId(req.getFormData()));
    }


    @RequestMapping(value="/bs01002_doCheckIrsNo")
    public void bs01002_doCheckIrsNo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setParameter("POSSIBLE_FLAG", bs0302Service.bs01002_doCheckIrsNo(req.getFormData()));
    }


}