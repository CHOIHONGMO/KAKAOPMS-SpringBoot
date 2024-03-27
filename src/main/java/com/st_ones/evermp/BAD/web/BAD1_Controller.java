package com.st_ones.evermp.BAD.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BAD.service.BAD1_Service;
import com.st_ones.evermp.BS01.service.BS0101_Service;
import com.st_ones.evermp.BS02.service.BS0201_Service;
import com.st_ones.evermp.SY01.service.SY0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BAD/BAD1")
public class BAD1_Controller extends BaseController {

    @Autowired
    BAD1_Service bad1Service;

    @Autowired
    SY0101_Service sy0101Service;

    @Autowired
    BS0201_Service bs0201Service;

    @Autowired
    BS0101_Service bs0101Service;

    @Autowired
    private CommonComboService comboService;

    @Autowired
    FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 고객사 사용자관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD1_020/view")
    public String BAD1_020(EverHttpRequest req) throws Exception {
    	// 고객사 관리자 사용메뉴
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	  if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BAD/BAD1_020";
    }

    // 사용자조회
    @RequestMapping(value="/bad1020_doSearch")
    public void bad1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bad1Service.bad1020_doSearch(param));
    }

    // 사용자 등록
    @RequestMapping(value="/bad1020_doSave")
    public void bad1020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1020_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    // 사용자 삭제
    @RequestMapping(value="/bad1020_doDelete")
    public void bad1020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1020_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 고객사 사용자 상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD1_021/view")
    public String BAD1_021(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();

        String userId = EverString.nullToEmptyString(req.getParameter("USER_ID"));
        boolean havePermission = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1");

        if( !userId.equals("") ) {
            param.put("USER_ID", userId);
            formData = bad1Service.bad1021_doSearch(param);
            if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
                havePermission = true;
            }
        } else {
        	formData.put("SMS_FLAG", "1");
        	formData.put("MAIL_FLAG", "1");
        	formData.put("BUDGET_FLAG", "0");
        	formData.put("GR_FLAG", "0");
        	formData.put("FINANCIAL_FLAG", "0");
        	formData.put("MY_SITE_FLAG", "0");
        }

        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));

        req.setAttribute("havePermission", havePermission);
        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);

        return "/evermp/BAD/BAD1_021";
    }

    //사용자 등록 및 수정
    @RequestMapping(value="/bad1021_doSave")
    public void bad1021_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> rtnMap = bad1Service.bad1021_doSave(req.getFormData());

    	resp.setResponseMessage(rtnMap.get("rtnMsg"));
    	resp.setParameter("USER_ID", rtnMap.get("USER_ID"));
    }

    //사용자 아이디중복체크
    @RequestMapping(value="/bad1021_doCheckUserId")
    public void bad1021_doCheckUserId(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setParameter("POSSIBLE_FLAG", bad1Service.bad1021_doCheckUserId(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 고객사 예산관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD1_040/view")
    public String BAD1_040(EverHttpRequest req) throws Exception {
    	// 고객사 관리자 사용메뉴
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	  if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("yyyymmTo", EverDate.getYear()+EverDate.getMonth());
        return "/evermp/BAD/BAD1_040";
    }

    //예산마감조회
    @RequestMapping(value="/isBudgetCloseFlag")
    public void isBudgetCloseFlag(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
        resp.setParameter("isBudgetCloseFlag", bs0201Service.isBudgetCloseFlag(param));
    }

    //부서조회
    @RequestMapping(value="/bad1040_doSearchDept")
    public void bad1040_doSearchDept(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> list = sy0101Service.sy01001_doSelect_deptTree(param);
        resp.setParameter("treeData", EverConverter.getJsonString(list));
    }

    //예산조회
    @RequestMapping(value="/bad1040_doSearch")
    public void bad1040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bad1Service.bad1040_doSearch(param));
    }

    //예산저장
    @RequestMapping(value="/bad1040_doSave")
    public void bad1040_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1040_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    //예산삭제
    @RequestMapping(value="/bad1040_doDelete")
    public void bad1040_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1040_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 고객사 계정관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD1_050/view")
    public String BAD1_050(EverHttpRequest req) throws Exception {
        return "/evermp/BAD/BAD1_050";
    }

    // 계정조회
    @RequestMapping(value="/bad1050_doSearch")
    public void bad1050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bad1Service.bad1050_doSearch(param));
    }

    // 계정저장
    @RequestMapping(value="/bad1050_doSave")
    public void bad1050_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1050_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    // 계정삭제
    @RequestMapping(value="/bad1050_doDelete")
    public void bad1050_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1050_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 고객사 상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD1_060/view")
    public String BAD1_060(EverHttpRequest req) throws Exception {
        
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        
        Map<String, String> formData = new HashMap<String, String>(); // 고객사정보
        Map<String, String> mngUser  = new HashMap<String, String>(); // 고객사담당자정보
        Map<String, String> param = new HashMap<String, String>();

        String custCd = userInfo.getCompanyCd();
        param.put("CUST_CD", custCd);
        formData = bs0101Service.bs01002_doSearchInfo(param);
        mngUser  = bs0101Service.bs01002_doSearchUser(param);

        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));

        req.setAttribute("regionCd", comboService.getCodeCombo("MP005"));
        req.setAttribute("dealType", comboService.getCodeCombo("MP042"));
        req.setAttribute("deliberyType", comboService.getCodeCombo("MP041"));

        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);
        req.setAttribute("mngUser", mngUser);

        return "/evermp/BAD/BAD1_060";
    }

    @RequestMapping(value = "/bad1060_checkDupCustUser")
	public void bad1060_checkDupCustUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setParameter("USER_POSSIBLE_FLAG", bs0101Service.bs01002_checkDupCustUser(req.getFormData()));
	}

    //고객사 저장
    @RequestMapping(value = "/bad1060_doSave")
    public void bad1060_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> paramMap = req.getFormData();
        Map<String, Object> formData = new HashMap<String, Object>();
        formData.putAll(paramMap);

        List<Map<String, Object>> gridDatas = null;
        Map<String, String> rtnMap = bs0101Service.bs01002_doSave(formData, gridDatas);

        resp.setResponseMessage(rtnMap.get("rtnMsg"));
        resp.setParameter("CUST_CD", rtnMap.get("CUST_CD"));
    }


    /** ****************************************************************************************************************
     * 품목별계정지정
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD1_030/view")
    public String BAD1_030(EverHttpRequest req) throws Exception {
    	// 고객사 관리자 사용메뉴
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	  if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BAD/BAD1_030";
    }

    @RequestMapping(value = "/bad1030_doSearch")
    public void bad1030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setGridObject("grid", bad1Service.bad1030_doSearch(req.getFormData()));
    }

    @RequestMapping(value="/bad1030_doSave")
    public void bad1030_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1030_doSave(gridList);
        resp.setResponseMessage(returnMsg);
    }

    @RequestMapping(value="/bad1030_doDelete")
    public void bad1030_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bad1Service.bad1030_doDelete(gridList);
        resp.setResponseMessage(returnMsg);
    }

    /** ****************************************************************************************************************
     * 부서별실적분석
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD2_010/view")
    public String BAD2_010(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());

		req.setAttribute("CPO_START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("CPO_END_DATE", EverDate.getDate());

        return "/evermp/BAD/BAD2_010";
    }

    @RequestMapping(value = "/bad2010_doSearch")
    public void bad2010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setGridObject("grid", bad1Service.bad2010_doSearch(req.getFormData()));
    }


    /** ****************************************************************************************************************
     * 주문번호별실적분석
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD2_020/view")
    public String BAD2_020(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());

		req.setAttribute("CPO_START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("CPO_END_DATE", EverDate.getDate());

        return "/evermp/BAD/BAD2_020";
    }

    @RequestMapping(value = "/bad2020_doSearch")
    public void bad2020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setGridObject("grid", bad1Service.bad2020_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 품목별실적분석
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BAD2_030/view")
    public String BAD2_030(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());

		req.setAttribute("CPO_START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("CPO_END_DATE", EverDate.getDate());

        return "/evermp/BAD/BAD2_030";
    }

    @RequestMapping(value = "/bad2030_doSearch")
    public void bad2030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setGridObject("grid", bad1Service.bad2030_doSearch(req.getFormData()));
    }

    /** *****************
     * 관리자 > 배송지 현황
     * ******************/
    @RequestMapping(value = "/BAD1_070/view")
    public String BAD1_070(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BAD/BAD1_070";
    }

    @RequestMapping(value="/bad1070_doSearchD")
    public void bad1070_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bad1Service.bad1070_doSearchD(param));
    }

    @RequestMapping(value = "/bad1070_doSaveDT")
    public void bad1070_doSaveDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bad1Service.bad1070_doSaveDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bad1070_doDeleteDT")
    public void bad1070_doDeleteDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bad1Service.bad1070_doDeleteDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 관리자 > 청구지 현황
     * ******************/
    @RequestMapping(value = "/BAD1_080/view")
    public String BAD1_080(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BAD/BAD1_080";
    }

    @RequestMapping(value="/bad1080_doSearchD")
    public void bad1080_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bad1Service.bad1080_doSearchD(param));
    }


}

