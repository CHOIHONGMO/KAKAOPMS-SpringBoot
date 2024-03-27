package com.st_ones.evermp.RQ01.web;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import com.st_ones.evermp.RQ01.service.RQ0101_Service;
import com.st_ones.evermp.RQ01.service.RQ0102_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 *
 * @LastModified 18. 8. 8 오후 5:27
 */

@Controller
@RequestMapping(value = "/evermp/RQ01/RQ0102")
public class RQ0102_Controller extends BaseController {

	@Autowired
	CommonComboService commonComboService;

	@Autowired
	FileAttachService fileAttachService;

	@Autowired
	CommonComboService comboService;

	@Autowired
	RQ0101_Service rq0101_Service;

	@Autowired
	RQ0102_Service rq0102_Service;

	/**
	 * ***************** 견적비교
	 ******************/
	@RequestMapping(value = "/RQ01_020/view")
	public String RQ01_020_View(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
		param.put("COMPANY_CD", userInfo.getManageCd());

		req.setAttribute("ctrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -3));
		req.setAttribute("SFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));
		req.setAttribute("custCdOptions", commonComboService.getCodesAsJson("CB0060", new HashMap<String, String>()));
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));
		req.setAttribute("dashBoardFlag", EverString.defaultIfEmpty(req.getParamDataMap().get("dashBoardFlag"),""));
		return "/evermp/RQ01/RQ01_020";
	}

	@RequestMapping(value = "/rq01020_doSearchT")
	public void rq01020_doSearchT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridT", rq0102_Service.rq01020_doSearchT(req.getFormData()));
	}

	@RequestMapping(value = "/rq01020_doSearchB")
	public void rq01020_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("RFQ_NUM",  EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
		param.put("RFQ_CNT",  EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));
		// 2022.10.18 추가
		// 소싱관리 > 신규소싱 > 견적서 합의현황 (RQ01_026)
		param.put("EXEC_NUM", EverString.nullToEmptyString(req.getParameter("EXEC_NUM")));
		resp.setGridObject("gridB", rq0102_Service.rq01020_doSearchB(param));
	}
	@RequestMapping(value = "/rq01020_doQtOpen")
	public void doQtOpen(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("gridB");
		resp.setResponseMessage(rq0102_Service.saveQtaOpen(gridData));
	}

	// 견적 마감
	@RequestMapping(value = "/rq01020_doClosing")
	public void rq01020_doClosing(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String msg = rq0102_Service.rq01020_doClosing(req.getGridData("gridT"));
		resp.setResponseMessage(msg);
	}

	// 견적 취소
	@RequestMapping(value = "/rq01020_doDelete")
	public void rq01020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String moveReason = EverString.nullToEmptyString(req.getParameter("MOVE_REASON"));
		String msg = rq0102_Service.rq01020_doDelete(moveReason, req.getGridData("gridT"));
		resp.setResponseMessage(msg);
	}

	// 유찰
	@RequestMapping(value = "/rq01020_doFailRFQ")
	public void rq01020_doFailRFQ(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String moveReason = EverString.nullToEmptyString(req.getParameter("MOVE_REASON"));
		String msg = rq0102_Service.rq01020_doFailRFQ(moveReason, req.getGridData("gridT"));
		resp.setResponseMessage(msg);
	}

	// 공급사 선정
	@RequestMapping(value = "/rq01020_doChoiceVendor")
	public void rq01020_doChoiceVendor(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rfqNum = EverString.nullToEmptyString(req.getParameter("RFQ_NUM"));
		String rfqCnt = EverString.nullToEmptyString(req.getParameter("RFQ_CNT"));
		String partSettleFlag = EverString.nullToEmptyString(req.getParameter("partSettleFlag"));
		String msg = rq0102_Service.rq01020_doChoiceVendor(rfqNum, rfqCnt, partSettleFlag, req.getGridData("gridB"));
		resp.setResponseMessage(msg);
	}


	// 공급사 선정 취소
	@RequestMapping(value = "/rq01020_doChoiceCancel")
	public void rq01020_doChoiceCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rfqNum = EverString.nullToEmptyString(req.getParameter("RFQ_NUM"));
		String rfqCnt = EverString.nullToEmptyString(req.getParameter("RFQ_CNT"));
		String partSettleFlag = EverString.nullToEmptyString(req.getParameter("partSettleFlag"));
		String msg = rq0102_Service.rq01020_doChoiceCancel(rfqNum, rfqCnt, partSettleFlag, req.getGridData("gridB"));
		resp.setResponseMessage(msg);
	}











	@RequestMapping(value = "/rq01020_doSearchOzParam")
	public void rq01020_doSearchOzParam(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		param.put("searchParam", EverString.nullToEmptyString(req.getParameter("searchParam")));

		List<Map<String, String>> jsonList = rq0102_Service.rq01020_doSearchOzParam(param);
		resp.setParameter("ozParam", new ObjectMapper().writeValueAsString(jsonList));
	}

	/**
	 * ***************** 마감일변경
	 ******************/
	@RequestMapping(value = "/RQ01_021/view")
	public String RQ01_021_View(EverHttpRequest req) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
		param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));
		req.setAttribute("closeDate", rq0102_Service.getCloseDate(param));
		req.setAttribute("today", EverDate.getDate());
		req.setAttribute("todayTime", EverDate.getTime());
		return "/evermp/RQ01/RQ01_021";
	}

	@RequestMapping(value = "/rq01021_doChangeDeadLine")
	public void rq01021_doChangeDeadLine(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String msg = rq0102_Service.rq01021_doChangeDeadLine(req.getFormData());
		resp.setResponseMessage(msg);
	}

	/**
	 * ***************** 견적서 입력 (운영사)
	 ******************/
	@RequestMapping(value = "/RQ01_022/view")
	public String RQ01_022_View(EverHttpRequest req) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
		param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));
		req.setAttribute("vendorListOptions", commonComboService.getCodesAsJson("CB0114", param));

		List<Map> vendorList = commonComboService.getCodes("CB0114", param);
		req.setAttribute("vendorCnt", vendorList.size());
		return "/evermp/RQ01/RQ01_022";
	}

	@RequestMapping(value = "rq01022_getVendorUsers")
	public void rq01022_getVendorUsers(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", UserInfoManager.getUserInfo().getGateCd());
		param.put("VENDOR_CD", EverString.nullToEmptyString(req.getParameter("vendorCd")));
		resp.setParameter("vendorUserOptions", commonComboService.getCodesAsJson("CB0096", param));
	}

	@RequestMapping(value = "/rq01022_doSearch")
	public void rq01022_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", rq0102_Service.rq01022_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/rq01022_doSave")
	public void rq01022_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		formData.put("firstSendFlag", EverString.nullToEmptyString(req.getParameter("firstSendFlag")));
		formData.put("QTA_NUM", EverString.nullToEmptyString(req.getParameter("QTA_NUM")));
		formData.put("IP_ADDR", getClientIpAddress(req));

		List<Map<String, Object>> gridDatas = req.getGridData("grid");

		String msg = rq0102_Service.rq01022_doSave(formData, gridDatas);
		resp.setResponseMessage(msg);
	}

	/**
	 ****************** 계약품의
	 ******************/
	@RequestMapping(value = "/RQ01_023/view")
	public String RQ01_023_View(EverHttpRequest req) throws Exception {

		Map<String, String> formData = new HashMap<String, String>();
		Map<String, String> param = new HashMap<String, String>();
		UserInfo userInfo = UserInfoManager.getUserInfo();
		boolean havePermission = false;

		String rfqNum  = EverString.nullToEmptyString(req.getParameter("RFQ_NUM"));
		String rfqCnt  = EverString.nullToEmptyString(req.getParameter("RFQ_CNT"));
		String execNum = EverString.nullToEmptyString(req.getParameter("EXEC_NUM"));
		String appDocNum = EverString.nullToEmptyString(req.getParameter("APP_DOC_NUM"));
		String appDocCnt = EverString.nullToEmptyString(req.getParameter("APP_DOC_CNT"));
		String searchType= EverString.nullToEmptyString(req.getParameter("SEARCH_TYPE"));

		/**
		 * searchType
		 * 계약 품의서 작성시 "품목정보"를 가져오는 기준에 대한 구분
		 * RFQ : 견적정보 (STOCRQHD, STOCRQDT)의 품목정보를 조회
		 * CN  : 품의정보 (STOCCNHD, STOCCNDT)의 품목정보를 조회
		 * APP : 결재정보 (STOCSCTM)의 APP_DOC_NUM/CNT를 기준으로 품목정보를 조회
		 */
		// 견적의 품목정보를 조회
		if (!rfqNum.equals("") && !rfqCnt.equals("")) {
			param.put("RFQ_NUM", rfqNum);
			param.put("RFQ_CNT", rfqCnt);
			param.put("SEARCH_TYPE", (!searchType.equals("") ? searchType : "RFQ"));
			searchType = (!searchType.equals("") ? searchType : "RFQ");
		}

		// 계약품의의 품목정보를 조회
		if (!execNum.equals("")) {
			param.put("EXEC_NUM", execNum);
			param.put("SEARCH_TYPE", "CN");
			searchType = "CN";
		}

		// 결재번호를 기준으로 품목정보를 조회
		if (!appDocNum.equals("") && !appDocCnt.equals("")) {
			param.put("APP_DOC_NUM", appDocNum);
			param.put("APP_DOC_CNT", appDocCnt);
			param.put("SEARCH_TYPE", "APP");
			searchType = "APP";
		}

		// 조회구분에 따라 품목정보 조회
		// SEARCH_TYPE = RFQ(견적), CN(품의=EXEC), APP(품의=APP_DOC_NUM)
		if (!EverString.isEmpty(param.get("SEARCH_TYPE"))) {
			formData = rq0102_Service.rq01023_getFormData(param);
		}

		// 기존 REG_USER_ID => CTRL_USER_ID로 변경
		if (formData != null) {
			if (formData.get("REG_USER_ID").equals(userInfo.getUserId())) {
				havePermission = true;
			}
		}

		// 품의기준으로 품의서 조회
		if (!EverString.isEmpty(formData.get("EXEC_NUM"))) {
			searchType = "CN";
		}

		req.setAttribute("searchType", searchType);
		req.setAttribute("formData", formData);
		req.setAttribute("today", EverDate.getDate());
		req.setAttribute("todayTime", EverDate.getTime());
		req.setAttribute("havePermission", havePermission);
		return "/evermp/RQ01/RQ01_023";
	}

	// 신규 품목 계약품의시 "견적정보(RQHD, RQDT)" 조회
	@RequestMapping(value = "/rq01023_doSearchGridR")
	public void rq01023_doSearchGridR(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String searchType = EverString.nullToEmptyString(req.getParameter("searchType"));
		Map<String, String> param = req.getFormData();
		param.put("SEARCH_TYPE", searchType);

		resp.setGridObject("gridR", rq0102_Service.rq01023_doSearchGridR(req.getFormData()));
	}

	// 신규상품 요청정보(STOUNWRQ) 가져오기
	@RequestMapping(value = "/rq01023_doSearchGridC")
	public void rq01023_doSearchGridC(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridC", rq0102_Service.rq01023_doSearchGridC(req.getFormData()));
	}

	// 2022.09.22 미사용 : 공급사 재계약(200)인 경우 공급사 정보 가져오기
	@RequestMapping(value = "/rq01023_doSearchGridV")
	public void rq01023_doSearchGridV(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("ITEM_CD_STR", EverString.nullToEmptyString(req.getParameter("itemCdStr")));
		param.put("VENDOR_CD_STR", EverString.nullToEmptyString(req.getParameter("vendorCdStr")));
		resp.setGridObject("gridV", rq0102_Service.rq01023_doSearchGridV(param));
	}

	// 2022.09.22 미사용 : 고객사 최근 1년 실적정보 가져오기
	@RequestMapping(value = "/rq01023_doSearchGridCU")
	public void rq01023_doSearchGridCU(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("ITEM_CD_STR", EverString.nullToEmptyString(req.getParameter("itemCdStr")));
		resp.setGridObject("gridCU", rq0102_Service.rq01023_doSearchGridCU(param));
	}

	/**
	 * 신규상품 계약 품의서 (RQ01_023) : 저장 및 결재상신
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/rq01023_doSave")
	public void rq01023_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String signStatus = (EverString.nullToEmptyString(req.getParameter("signStatus")).equals("") ? "E"
						   : EverString.nullToEmptyString(req.getParameter("signStatus")));

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridDatas = req.getGridData("gridR");

		Map<String, String> rtnMap = rq0102_Service.rq01023_doSave(signStatus, formData, gridDatas);
		resp.setParameter("EXEC_NUM", rtnMap.get("EXEC_NUM"));
		resp.setResponseMessage(rtnMap.get("rtnMsg"));
	}

	// 신규상품 계약 품의서 (RQ01_023) : 삭제
	@RequestMapping(value = "/rq01023_doDelete")
	public void rq01023_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setResponseMessage(rq0102_Service.rq01023_doDelete(req.getFormData()));
	}

	/**
	 * ***************** 견적비교표
	 ******************/
	@RequestMapping(value = "/RQ01_024/view")
	public String RQ01_024_View(EverHttpRequest req) throws Exception {

		Map<String, String> formData = new HashMap<String, String>();
		Map<String, String> param = new HashMap<String, String>();

		String rfqNum = EverString.nullToEmptyString(req.getParameter("RFQ_NUM"));
		String rfqCnt = EverString.nullToEmptyString(req.getParameter("RFQ_CNT"));
		if (!rfqNum.equals("") && !rfqCnt.equals("")) {
			param.put("RFQ_NUM", rfqNum);
			param.put("RFQ_CNT", rfqCnt);
			formData = rq0102_Service.rq01024_getFormData(param);
		}
		req.setAttribute("formData", formData);
		return "/evermp/RQ01/RQ01_024";
	}

	@RequestMapping(value = "/rq01024_doSearch")
	public void rq01024_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String lastCnt = "";
		List<Map<String, Object>> rtnList = rq0102_Service.rq01024_doSearch(req.getFormData());
		if (rtnList.size() > 0) {
			Map<String, Object> tmpMap = rtnList.get(rtnList.size() - 1);
			lastCnt = String.valueOf(tmpMap.get("RFQ_CNT"));
		}
		resp.setGridObject("grid", rtnList);
		resp.setParameter("lastCnt", lastCnt);
	}

	/**
	 * ***************** 대상공급사
	 ******************/
	@RequestMapping(value = "/RQ01_025/view")
	public String RQ01_025_View(EverHttpRequest req) throws Exception {
		return "/evermp/RQ01/RQ01_025";
	}

	@RequestMapping(value = "/rq01025_doSearch")
	public void rq01025_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
		param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));
		resp.setGridObject("grid", rq0102_Service.rq01025_doSearch(param));
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
	/**
	 * ***************** 품의현황
	 ******************/
	@RequestMapping(value = "/RQ01_026/view")
	public String RQ01_026_View(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
		param.put("COMPANY_CD", userInfo.getManageCd());
		req.setAttribute("ctrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));

		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -3));
		req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));
		return "/evermp/RQ01/RQ01_026";
	}

	@RequestMapping(value = "/rq01026_doSearch")
	public void rq01026_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", rq0102_Service.rq01026_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/rq01026_doSearchD")
	public void rq01026_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		param.put("EXEC_NUM", EverString.nullToEmptyString(req.getParameter("EXEC_NUM")));
		resp.setGridObject("gridD", rq0102_Service.rq01026_doSearchD(param));
	}

	/**
	 * 소싱관리 > 신규소싱 > 신규상품 CMS 맵핑 (RQ01_030)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/RQ01_030/view")
	public String RQ01_030_View(EverHttpRequest req) throws Exception {


        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
		param.put("COMPANY_CD", userInfo.getManageCd());
		req.setAttribute("ctrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -3));
		req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));
		return "/evermp/RQ01/RQ01_030";
	}

	@RequestMapping(value = "/rq01030_doSearch")
	public void rq01030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", rq0102_Service.rq01030_doSearch(req.getFormData()));
	}

	/**
	 * 소싱관리 > 신규소싱 > 신규상품 CMS 맵핑 (RQ01_030) : 상품등록완료
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/rq01030_doConfirm")
	public void rq01030_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> grid = req.getGridData("grid");

		String rtnMap = rq0102_Service.rq01030_doConfirm(grid);
		resp.setResponseMessage(rtnMap);
	}

}
