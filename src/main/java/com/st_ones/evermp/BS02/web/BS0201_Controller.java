package com.st_ones.evermp.BS02.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS02.service.BS0201_Service;
import com.st_ones.evermp.SY01.service.SY0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BS02/BS0201")
public class BS0201_Controller extends BaseController {

    @Autowired
    BS0201_Service bs0201Service;

    @Autowired
    SY0101_Service sy0101Service;

    @Autowired
    private CommonComboService comboService;

    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 예산관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS02_001/view")
    public String BS02_001(EverHttpRequest req) throws Exception {
        req.setAttribute("yyyymmTo", EverDate.getYear()+EverDate.getMonth());
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS02/BS02_001";
    }

    //예산마감조회
    @RequestMapping(value="/isBudgetCloseFlag")
    public void isBudgetCloseFlag(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
        resp.setParameter("isBudgetCloseFlag", bs0201Service.isBudgetCloseFlag(param));
    }

    //부서조회
    @RequestMapping(value="/bs02001_doSearchDept")
    public void bs02001_doSearchDept(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> list = bs0201Service.doSelect_budgetDeptTree(param);
		/*for(int i =0; i < list.size(); i++) {
	        for(Entry<String, Object> elem : list.get(i).entrySet()){
	            System.out.println(">>>>> 키 : " + elem.getKey() + ",값 : " + elem.getValue());
	        }
		}*/

        resp.setParameter("treeData", EverConverter.getJsonString(list));
    }

    //예산조회
    @RequestMapping(value="/bs02001_doSearch")
    public void bs02001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0201Service.bs02001_doSearch(param));
    }

    //예산저장
    @RequestMapping(value="/bs02001_doSave")
    public void bs02001_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0201Service.bs02001_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    //예산삭제
    @RequestMapping(value="/bs02001_doDelete")
    public void bs02001_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0201Service.bs02001_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    /**
     * 고객사별 사업부콤보조회
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/_getParentDeptOption")
    public void getParentDeptOption(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());
        param.put("custCd",req.getFormData().get("CUST_CD"));
        resp.setParameter("parentDeptCdOptions", comboService.getCodeComboAsJson2("CB0053", param));
    }

    /**
     * 고객사_사업부별 부서 콤보조회
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/_getDeptOption")
    public void getDeptOption(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = reqParamMapToStringMap(req.getParameterMap());
        param.put("custCd",req.getFormData().get("CUST_CD"));
        param.put("parentDeptCd",req.getFormData().get("PARENT_DEPT_CD"));
        resp.setParameter("deptCdOptions", comboService.getCodeComboAsJson2("CB0054", param));
    }



    /** ****************************************************************************************************************
     * 게정관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS02_002/view")
    public String BS02_002(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        // 고객사 운영사 관리자 사용메뉴
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS02/BS02_002";
    }

    //계정조회
    @RequestMapping(value="/bs02002_doSearch")
    public void bs02002_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0201Service.bs02002_doSearch(param));

    }

    //계정저장
    @RequestMapping(value="/bs02002_doSave")
    public void bs02002_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0201Service.bs02002_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }


    //계정삭제
    @RequestMapping(value="/bs02002_doDelete")
    public void bs02002_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0201Service.bs02002_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }
}