package com.st_ones.evermp.OD03.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:15
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.OD03.service.OD03_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/OD03")
public class OD03_Controller extends BaseController {

	@Autowired private OD03_Service od03_Service;
	@Autowired private DocNumService docNumService;
	@Autowired private MessageService msg;
	@Autowired private CommonComboService commonComboService;

    /** ******************************************************************************************
     * 운영사 > 주문관리 > 입고현황 > 미입고현황
     * @param req
     * @return String
     * @throws Exception
     */
	@RequestMapping(value="/OD03_010/view")
	public String OD03_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("form", req.getParamDataMap());

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));

		return "/evermp/OD03/OD03_010";
	}

	@RequestMapping(value = "/od03010_doSearch")
	public void od03010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", od03_Service.od03010_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/od03010_doGrSave")
	public void od03010_doGrSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");

		String GR_NO = docNumService.getDocNumber("GR");
		String MMRS = req.getParameter("MMRS");


		for(Map<String, Object> gridData : gridList) {
			gridData.put("GR_NO", GR_NO);
			form.put("MMRS",MMRS);

			od03_Service.od03010_doGrSave(gridData, form);
		}

		String rtnMsg = msg.getMessageByScreenId("OD03_010", "005");
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
	 * 운영사 > 주문관리 > 입고현황 > 입고현황
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/OD03_020/view")
	public String OD03_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));

		return "/evermp/OD03/OD03_020";
	}

	@RequestMapping(value = "/od03020_doSearch")
	public void od03020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", od03_Service.od03020_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/od03020_doGrCancel")
	public void od03020_doGrCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String MMRS = req.getParameter("MMRS");
		form.put("MMRS",MMRS);

		String rtnMsg = od03_Service.od03020_doGrCancel(gridList, form);

		resp.setResponseMessage(rtnMsg);
	}
	/** ******************************************************************************************
	 * 재고관리 > 재고입고관리 > 물류센터 입고대상목록 (OD03_030)
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/OD03_030/view")
	public String OD03_030(EverHttpRequest req) throws Exception {
		 UserInfo userInfo = UserInfoManager.getUserInfo();
	        if(!"C".equals(userInfo.getUserType())) {
	        	return "/eversrm/noSuperAuth";
	        }

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

		return "/evermp/OD03/OD03_030";
	}
	//조회
	@RequestMapping(value = "/od03030_doSearch")
	public void od03030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", od03_Service.od03030_doSearch(req.getFormData()));
	}
    //납품서수정
    @RequestMapping(value = "/od03030_doSave")
	public void od03030_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od03_Service.od03030_doSave(gridList);

        resp.setResponseMessage(returnMsg);
	}
 // 납품서 삭제
 	@RequestMapping(value = "/od03030_doDelete")
 	public void od02020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
 		List<Map<String, Object>> gridList = req.getGridData("grid");
 		String returnMsg = od03_Service.od03030_doDelete(gridList);

         resp.setResponseMessage(returnMsg);
 	}



	/** ******************************************************************************************
	 * 재고관리 > 재고입고관리 > 물류센터 입고현황 (OD03_040)
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/OD03_040/view")
	public String OD03_040(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
	       if(!"C".equals(userInfo.getUserType())) {
	        return "/eversrm/noSuperAuth";
	        }

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		Map<String, String> param = new HashMap<>();
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

		return "/evermp/OD03/OD03_040";


	}
	@RequestMapping(value = "/od03040_doSearch")
	public void od03040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", od03_Service.od03040_doSearch(req.getFormData()));
	}





}
