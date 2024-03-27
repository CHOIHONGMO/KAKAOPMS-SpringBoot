package com.st_ones.evermp.OD01.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.OD01.service.OD0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;



@Controller
@RequestMapping(value = "/evermp/OD01/OD0101")
public class PO0210Controller extends BaseController {

    @Autowired private OD0101_Service od0101_Service;
	@Autowired private CommonComboService commonComboService;
    @Autowired private MessageService msg;


    // 발주(YPO) 대기현황
    @RequestMapping(value="/PO0210/view")
    public String OD01_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }



    	req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));

        return "/evermp/OD01/PO0210";
    }
    @RequestMapping(value = "/PO0210/doSearch")
    public void PO0210_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));

        resp.setGridObject("grid", od0101_Service.PO0210_doSearch(param));
    }

    // 발주승인
    @RequestMapping(value = "/PO0210_doPoConfirm")
    public void od01001_doPoConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = od0101_Service.od01001_doPoConfirmXX(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }


    // 발주수정
    @RequestMapping(value = "/PO0210_poItemChange")
    public void yPoChange(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = od0101_Service.yPoChange(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }



    @RequestMapping(value="/PO0211/view")
    public String PO0211(EverHttpRequest req) throws Exception {
        return "/evermp/OD01/PO0211";
    }

    @RequestMapping(value = "/PO0211/doSearch")
    public void PO0211_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", od0101_Service.PO0211_doSearch(param));
    }











    // 발주(YPO) 상세현황
    @RequestMapping(value="/PO0240/view")
    public String PO0240(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


    	req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));
        return "/evermp/OD01/PO0240";
    }
    @RequestMapping(value = "/PO0240/doSearch")
    public void PO0240_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));
        resp.setGridObject("grid", od0101_Service.PO0240_doSearch(param));
    }



    // 확정취소
    @RequestMapping(value = "/PO0240_doPoCancel")
    public void PO0240_doPoConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = od0101_Service.PO0240_doPoCancel(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }


    // 발주종결
    @RequestMapping(value = "/PO0240_doPoClose")
    public void PO0240_doPoClose(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = od0101_Service.PO0240_doPoClose(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }



















}