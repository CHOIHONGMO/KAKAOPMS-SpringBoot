package com.st_ones.evermp.BGA1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:15
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BGA1.service.BGA1_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BGA1")
public class BGA1_Controller extends BaseController {

	@Autowired private BGA1_Service bga1_Service;
	@Autowired private DocNumService docNumService;
	@Autowired private MessageService msg;
	@Autowired CommonComboService commonComboService;

    /** ******************************************************************************************
     * 고객사 > 입고/정산 > 입고/정산관리 > 미입고관리
     * @param req
     * @return String
     * @throws Exception
     */
	@RequestMapping(value="/BGA1_010/view")
	public String BGA1_010(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	    return "/eversrm/noSuperAuth";
	  	}

		boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
		boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
		req.setAttribute("superUserFlag", superUserFlag);
		req.setAttribute("havePermission", havePermission);

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());

		req.setAttribute("GR_FLAG_D", !("1".equals(userInfo.getGrFlag())||"1".equals(userInfo.getMngYn())));
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));

		return "/evermp/BGA1/BGA1_010";
	}

	// 입고/정산 > 입고관리 > 입고대상 조회 (BGA1_010)
	@RequestMapping(value = "/bga1010_doSearch")
	public void bga1010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bga1_Service.bga1010_doSearch(req.getFormData()));
	}

	// 입고처리 : 입고/정산 > 입고관리 > 입고대상 조회 (BGA1_010)
	@RequestMapping(value = "/bga1010_doGrSave")
	public void bga1010_doGrSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		String GR_NO = docNumService.getDocNumber("GR");
		for (Map<String, Object> gridData : gridList) {
			gridData.put("GR_NO", GR_NO);
			bga1_Service.bga1010_doGrSave(gridData, form);
		}

		String rtnMsg = msg.getMessageByScreenId("BGA1_010", "005");
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 입고관리
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/BGA1_030/view")
	public String BGA1_030(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	    return "/eversrm/noSuperAuth";
	  	}

		boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
		boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
		req.setAttribute("superUserFlag", superUserFlag);
		req.setAttribute("havePermission", havePermission);

		String str = bga1_Service.bga1030_SELECT_CODD();

		req.setAttribute("GRID_EXCEL", str);
		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("GR_FLAG_D", !("1".equals(userInfo.getGrFlag())||"1".equals(userInfo.getMngYn())));
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));

		return "/evermp/BGA1/BGA1_030";
	}

	@RequestMapping(value = "/bga1030_doSearch")
	public void bga1030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();

		resp.setGridObject("grid", bga1_Service.bga1030_doSearch(form));
	}

	@RequestMapping(value = "/bga1030_doSearchExcel")
	public void bga1030_doSearchExcel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();

		resp.setGridObject(form.get("GRID_EXCEL"), bga1_Service.bga1030_doSearchEXCEL(form));
	}

	@RequestMapping(value = "/bga1030_doGrCancel")
	public void bga1030_doGrCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		String rtnMsg = bga1_Service.bga1030_doGrCancel(gridList, form);

		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 매입확정
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/BGA1_040/view")
	public String BGA1_040(EverHttpRequest req) throws Exception {

		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		String str = bga1_Service.bga1030_SELECT_CODD();

		req.setAttribute("GRID_EXCEL", str);
		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("FINANCIAL_FLAG_D", !("1".equals(userInfo.getFinancialFlag())||"1".equals(userInfo.getMngYn())));

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "T100");

		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

		return "/evermp/BGA1/BGA1_040";
	}

	@RequestMapping(value = "/bga1040_doSearch")
	public void bga1040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bga1_Service.bga1040_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/bga1040_doConfirm")
	public void bga1040_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		String rtnMsg = bga1_Service.bga1040_doConfirm(gridList, form);

		resp.setResponseMessage(rtnMsg);
	}

	@RequestMapping(value = "/bga1040_doCancel")
	public void bga1040_doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		String rtnMsg = bga1_Service.bga1040_doCancel(gridList, form);

		resp.setResponseMessage(rtnMsg);
	}

	@RequestMapping(value = "/bga1040_doSearchExcel")
	public void bga1040_doSearchExcel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();

		resp.setGridObject(form.get("GRID_EXCEL"), bga1_Service.bga1040_doSearchEXCEL(form));
	}

	/** ******************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 정산현황
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/BGA1_050/view")
	public String BGA1_050(EverHttpRequest req) throws Exception {

		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	       return "/eversrm/noSuperAuth";
	  	      }

		boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
		boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
		req.setAttribute("superUserFlag", superUserFlag);
		req.setAttribute("havePermission", havePermission);

		req.setAttribute("GR_MONTH_DATE", EverDate.getYear() + EverDate.getMonth());
		req.setAttribute("GR_USER_ID", userInfo.getUserId());
		req.setAttribute("GR_USER_NM", userInfo.getUserNm());
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.addMonths(0).substring(4, 6));

		return "/evermp/BGA1/BGA1_050";
	}

	@RequestMapping(value = "/bga1050_doSearch")
	public void bga1050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bga1_Service.bga1050_doSearch(req.getFormData()));
	}

	@RequestMapping(value="/BGA1_060/view")
	public String BGA1_060(EverHttpRequest req) throws Exception {
		
		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
	  	    return "/eversrm/noSuperAuth";
	  	}

		boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
		boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
		req.setAttribute("superUserFlag", superUserFlag);
		req.setAttribute("havePermission", havePermission);

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());

		req.setAttribute("GR_FLAG_D", !("1".equals(userInfo.getGrFlag())||"1".equals(userInfo.getMngYn())));
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));


		return "/evermp/BGA1/BGA1_060";
	}

	@RequestMapping(value = "/bga1060_doSearch")
	public void bga1060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bga1_Service.bga1060_doSearch(req.getFormData()));
	}

	// 표준납기 메일발송
    @RequestMapping(value = "/doAlarmInvoiceDelay")
    public void doAlarmInvoiceDelay(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bga1_Service.doAlarmInvoiceDelay(gridList);
        resp.setResponseMessage(returnMsg);
    }
}
