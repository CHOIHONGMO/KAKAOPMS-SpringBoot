package com.st_ones.evermp.RQ01.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.RQ01.service.RQ0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */

@Controller
@RequestMapping(value = "/evermp/RQ01/RQ0101")
public class RQ0101_Controller extends BaseController {

	@Autowired CommonComboService commonComboService;

    @Autowired FileAttachService fileAttachService;
	@Autowired LargeTextService largeTextService;

    @Autowired CommonComboService comboService;

    @Autowired RQ0101_Service rq0101_Service;

    /** *****************
     * 견적의뢰대상
     * ******************/
    @RequestMapping(value = "/RQ01_010/view")
    public String RQ01_010_View(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
        param.put("COMPANY_CD", userInfo.getManageCd());
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", param));

        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -3));
        req.setAttribute("SFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());
        req.setAttribute("custCdOptions", commonComboService.getCodesAsJson("CB0060", new HashMap<String, String>()));
        req.setAttribute("form", req.getParamDataMap());

        Map<String, String> p = new HashMap<String, String>();
        p =  (Map<String, String>)req.getParamDataMap();
        return "/evermp/RQ01/RQ01_010";
    }

    @RequestMapping(value = "/rq01010_doSearch")
    public void rq01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", rq0101_Service.rq01010_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/rq01010_doTransferCtrl")
    public void rq01010_doTransferCtrl(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("SG_CTRL_USER_ID", EverString.nullToEmptyString(req.getParameter("sSG_CTRL_USER_ID")));
        formData.put("SG_CTRL_CHANGE_RMK", EverString.nullToEmptyString(req.getParameter("SG_CTRL_CHANGE_RMK")));

        String msg = rq0101_Service.rq01010_doTransferCtrl(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    @RequestMapping(value = "/rq01010_doReturnItem")
    public void rq01010_doReturnItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String returnReason = EverString.nullToEmptyString(req.getParameter("RETURN_REASON"));
        String msg = rq0101_Service.rq01010_doReturnItem(returnReason, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    /**
     * 견적의뢰 (RQ01_011) > 견적의뢰서 작성
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/rq01010_doSendRFQ")
    public void rq01010_doSendRFQ(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	String sendType = EverString.nullToEmptyString(req.getParameter("sendType"));
    	String msg = rq0101_Service.rq01010_doSendRFQ(sendType, req.getFormData(), req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    // 견적의뢰 (RQ01_011) > 재견적의뢰서 작성
    @RequestMapping(value = "/rq01010_doReSendRFQ")
    public void rq01010_doReSendRFQ(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        formData.put("RFQ_SUBJECT", formData.get("F_RFQ_SUBJECT"));
        String msg = rq0101_Service.rq01010_doSendRFQ(EverString.nullToEmptyString(req.getParameter("sendType")), formData, req.getGridData("gridT"));
        resp.setResponseMessage(msg);
    }

    /** *****************
     * 견적의뢰
     * ******************/
    @RequestMapping(value = "/RQ01_011/view")
    public String RQ01_011_View(EverHttpRequest req) throws Exception {

        String sendType = EverString.nullToEmptyString(req.getParameter("sendType"));
        String rfqType  = EverString.nullToEmptyString(req.getParameter("RFQ_TYPE")).equals("") ? "100" : EverString.nullToEmptyString(req.getParameter("RFQ_TYPE"));
    	Map<String, String> formData = new HashMap<String, String>();

    	// 최초작성
    	if(sendType.equals("F") || "".equals(sendType)) {
            formData.put("VENDOR_OPEN_TYPE", "AB");
            formData.put("DEAL_TYPE", "02");
        	formData.put("RFQ_TYPE", rfqType);
            formData.put("RFQ_CLOSE_DATE"		, EverDate.addDays(5));
            formData.put("CONT_START_DATE"		, EverDate.addDays(5));
            formData.put("CONT_END_DATE"		, EverDate.addDays(370));

        } // 기존 견적의뢰서 수정(E) 및 재견적(R)
        else {
            // 견적요청서 헤더정보
        	Map<String, String> param = new HashMap<String, String>();
            param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
            param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));

            param.put("sendType", sendType); // 재견적:R, 최초견적:F, 재작성(수정):E
            formData = rq0101_Service.getRfqHD(param);

            // 요청사항 LargeText
            String splitString = largeTextService.selectLargeText(String.valueOf(formData.get("RMK_TEXT_NUM")));
    		formData.put("RMK_TEXT", splitString);
    		formData.put("RFQ_TYPE", rfqType);
            formData.put("RFQ_CLOSE_DATE"		, formData.get("RFQ_CLOSE_DATE"));
            formData.put("CONT_START_DATE"		, formData.get("CONT_START_DATE"));
            formData.put("CONT_END_DATE"		, formData.get("CONT_END_DATE"));

        }
    	formData.put("sendType", sendType.equals("") ? "F" : sendType);


        // working day 견적마감일시, 계약시작일, 계약종료일 가져오기
        Map<String, String> workingInfo = rq0101_Service.getWorkingDay();

        req.setAttribute("formData", formData);
        req.setAttribute("rfqCloseDate", workingInfo.get("RFQ_CLOSE_DATE"));
        //req.setAttribute("rfqCloseHour", EverDate.getShortTimeString().substring(0, 2));
        req.setAttribute("contStartDate", workingInfo.get("CONT_START_DATE"));
        req.setAttribute("contEndDate", EverDate.addDateDay(workingInfo.get("CONT_START_DATE"), 364));
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("todayTime", EverDate.getTime());
        return "/evermp/RQ01/RQ01_011";
    }

    // 견적요청 품목 조회
    @RequestMapping(value = "/rq01011_doSearchItems")
    public void rq01011_doSearchDefault(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String sendType = EverString.nullToEmptyString(req.getParameter("sendType"));
        Map<String, String> param = req.getFormData();

        // 견적서 수정 및 재견적
        if(sendType.equals("R") || sendType.equals("E")) {
            String itemList = rq0101_Service.rq01010_getReItemList(sendType, param);
            param.put("ITEM_CD_STR", itemList);
        } else {
            param.put("ITEM_CD_STR", EverString.nullToEmptyString(req.getParameter("ITEM_CD_STR")));
        }
        resp.setGridObject("gridL", rq0101_Service.rq01011_doSearchDefault(param));
    }

    // 재견적시 "이전차수 공급사" 목록 가져오기
    @RequestMapping(value = "/getPreRfqVendorList")
    public void getPreRfqVendorList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("RFQ_NUM", EverString.nullToEmptyString(req.getParameter("RFQ_NUM")));
        param.put("RFQ_CNT", EverString.nullToEmptyString(req.getParameter("RFQ_CNT")));

        List<Map<String, String>> rtnList = rq0101_Service.getPreRfqVendorList(param);
        ObjectMapper om = new ObjectMapper();
        String jsonStr = om.writeValueAsString(rtnList);
        resp.setParameter("vendorList", jsonStr);
    }

    /** *****************
     * 공급사선택
     * ******************/
    @RequestMapping(value = "/RQ01_012/view")
    public String RQ01_012_View(EverHttpRequest req) throws Exception {
        return "/evermp/RQ01/RQ01_012";
    }

    @RequestMapping(value = "/rq01012_doSearchDefault")
    public void rq01012_doSearchDefault(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("ITEM_CD_STR", EverString.nullToEmptyString(req.getParameter("ITEM_CD_STR")));
        resp.setGridObject("gridL", rq0101_Service.rq01012_doSearchDefault(param));
    }

    @RequestMapping(value = "/rq01012_doSearch")
    public void rq01012_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridL", rq0101_Service.rq01012_doSearch(req.getFormData()));
    }
    /** *****************
     * 관심업체 추가
     * ******************/
    @RequestMapping(value = "/RQ01_013/view")
    public String RQ01_013_View(EverHttpRequest req) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        req.setAttribute("tplNoOptions", commonComboService.getCodeComboAsJson("CB0065"));
        return "/evermp/RQ01/RQ01_013";
    }

    @RequestMapping(value = "/rq01013_doSearchDefault")
    public void rq01013_doSearchDefault(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("ITEM_CD_STR", EverString.nullToEmptyString(req.getParameter("ITEM_CD_STR")));
        resp.setGridObject("gridL", rq0101_Service.rq01013_doSearchDefault(param));
    }


}
