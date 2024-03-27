package com.st_ones.evermp.BNM1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

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
import com.st_ones.evermp.BNM1.service.BNM101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BNM1/BNM101")
public class BNM101_Controller extends BaseController {

    @Autowired private BNM101_Service bnm1_Service;

    @Autowired private CommonComboService commonComboService;

    @Autowired private FileAttachService fileAttachService;

    /** ****************************************************************************************************************
     * 신규상품 > 신규상품요청 > 신규상품 요청 (BNM1_010)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_010/view")
    public String BNM1_010(EverHttpRequest req) throws Exception {
    	
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	if(!"B".equals(userInfo.getUserType())) {
    	    return "/eversrm/noSuperAuth";
    	}
    	
        req.setAttribute("today", EverDate.getDate());
        return "/evermp/BNM1/BNM1_010";
    }

    // 신규상품 > 신규상품요청 > 신규상품 요청 (BNM1_010) : 일괄요청
	@RequestMapping(value = "/bnm1010_doSave")
	public void bnm1010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bnm1_Service.bnm1010_doSave(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	/** ****************************************************************************************************************
     * 신규등록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_011/view")
    public String BNM1_011(EverHttpRequest req) throws Exception {

    	String custCd = EverString.nullToEmptyString(req.getParameter("CUST_CD"));
		String itemReqNo = EverString.nullToEmptyString(req.getParameter("ITEM_REQ_NO"));
		String itemReqSeq = EverString.nullToEmptyString(req.getParameter("ITEM_REQ_SEQ"));

		Map<String, String> param = new HashMap<String, String>();
		Map<String, Object> formData = new HashMap<String, Object>();

		if(!custCd.equals("") && !itemReqNo.equals("") && !itemReqSeq.equals("")) {
			param.put("CUST_CD", custCd);
			param.put("ITEM_REQ_NO", itemReqNo);
			param.put("ITEM_REQ_SEQ", itemReqSeq);
			formData = bnm1_Service.bnm1011_doSearchForm(param);
			req.setAttribute("formData", formData);
		}
        return "/evermp/BNM1/BNM1_011";
    }

    @RequestMapping(value = "/bnm1011_doSave")
	public void bnm1011_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bnm1_Service.bnm1011_doSave(req.getFormData());
		resp.setResponseMessage(rtnMsg);
	}

	/** ****************************************************************************************************************
     * 주문정보
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_020/view")
    public String BNM1_020(EverHttpRequest req) throws Exception {
        return "/evermp/BNM1/BNM1_020";
    }

    /** ****************************************************************************************************************
     * 신규품목처리현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_030/view")
    public String BNM1_030(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	if(!"B".equals(userInfo.getUserType())) {
    		return "/eversrm/noSuperAuth";
    	}

        boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);

        Map<String, String> comboBoxParam = new HashMap<String, String>();
        comboBoxParam.put("custCd", userInfo.getCompanyCd());
        req.setAttribute("divisionCdOptions", commonComboService.getCodesAsJson("CB0053", comboBoxParam));
        req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));
        
    	return "/evermp/BNM1/BNM1_030";
    }

    // 신규상품 > 신규상품요청 > 신규상품 견적의뢰 (BNM1_030)
    @RequestMapping(value="/BNM1_030/doSearch")
    public void BNM1_030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
    	param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
        resp.setGridObject("grid", bnm1_Service.bnm1030_doSearch(param));
    }

    @RequestMapping(value = "/bnm1032_doAddCart")
    public void bnm1032_doAddCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bnm1_Service.bnm1032_doAddCart(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    // 신규상품 > 신규상품요청 > 신규상품 견적의뢰 (BNM1_030) : 승인
    @RequestMapping(value = "/bnm1030_doConfirm")
    public void bnm1030_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bnm1_Service.bnm1030_doConfirm(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    // 신규상품 > 신규상품요청 > 신규상품 견적의뢰 (BNM1_030) : 반려
    @RequestMapping(value = "/bnm1030_doRejectExec")
    public void bnm1030_doRejectExec(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bnm1_Service.bnm1030_doRejectExec(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    /** ****************************************************************************************************************
     * 신규상품요청현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_040/view")
    public String BNM1_040(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	if(!"B".equals(userInfo.getUserType())) {
   	       	return "/eversrm/noSuperAuth";
   	    }
        
    	boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);
        
        req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());

    	return "/evermp/BNM1/BNM1_040";
    }

    @RequestMapping(value="/BNM1_040/doSearch")
    public void BNM1_040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
    	param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
    	param.put("PLANT_CD", EverString.nullToEmptyString(req.getParameter("PLANT_CD")));
        resp.setGridObject("grid", bnm1_Service.bnm1040_doSearch(param));
    }

    /** ****************************************************************************************************************
     * 견적합의
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_031/view")
    public String BNM1_031(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	if(!"B".equals(userInfo.getUserType())) {
  	       	return "/eversrm/noSuperAuth";
  	    }

        boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);

        Map<String, String> comboBoxParam = new HashMap<String, String>();
        comboBoxParam.put("custCd", userInfo.getCompanyCd());
        req.setAttribute("divisionCdOptions", commonComboService.getCodesAsJson("CB0053", comboBoxParam));
        req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));


    	return "/evermp/BNM1/BNM1_031";
    }

    @RequestMapping(value="/BNM1_031/doSearch")
    public void BNM1_031_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
    	param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
    	param.put("PLANT_CD", EverString.nullToEmptyString(req.getParameter("PLANT_CD")));
        resp.setGridObject("grid", bnm1_Service.bnm1031_doSearch(param));
    }

    @RequestMapping(value = "/bnm1031_doConfirm")
    public void bnm1031_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bnm1_Service.bnm1031_doConfirm(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bnm1031_doRejectExec")
    public void bnm1031_doRejectExec(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bnm1_Service.bnm1031_doRejectExec(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    /** ****************************************************************************************************************
     * 상품등록 완료현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BNM1_032/view")
    public String BNM1_032(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
	    if(!"B".equals(userInfo.getUserType())) {
	    	return "/eversrm/noSuperAuth";
	    }

        boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);

        Map<String, String> comboBoxParam = new HashMap<String, String>();
        comboBoxParam.put("custCd", userInfo.getCompanyCd());
        req.setAttribute("divisionCdOptions", commonComboService.getCodesAsJson("CB0053", comboBoxParam));
        req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));


    	return "/evermp/BNM1/BNM1_032";
    }

    @RequestMapping(value="/BNM1_032/doSearch")
    public void BNM1_032_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
    	param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
    	param.put("PLANT_CD", EverString.nullToEmptyString(req.getParameter("PLANT_CD")));
        resp.setGridObject("grid", bnm1_Service.bnm1032_doSearch(param));
    }

}