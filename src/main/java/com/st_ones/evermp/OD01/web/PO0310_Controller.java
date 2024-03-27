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
import com.st_ones.evermp.OD01.service.PO0310_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;



@Controller
@RequestMapping(value = "/evermp/OD01/OD0101")
public class PO0310_Controller extends BaseController {

    @Autowired private PO0310_Service po0310_Service;
	@Autowired private CommonComboService commonComboService;
    @Autowired private MessageService msg;


    // 출하지시목록
    @RequestMapping(value="/PO0310/view")
    public String PO0310(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("samUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("sgCtrlUserIdOption", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));

        return "/evermp/OD01/PO0310";
    }

    //조회
    @RequestMapping(value = "/PO0310_doSearch")
    public void PO0310_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));

        resp.setGridObject("grid", po0310_Service.PO0310_doSearch(param));
    }

    // 출하지시 확정, 출하지시 취소
    @RequestMapping(value = "/PO0310_doPoConfirm")
    public void po0310_doPoConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = po0310_Service.po0310_doPoConfirmXX(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    // 출하지시수정
    @RequestMapping(value = "/PO0310_poItemChange")
    public void yPoChange(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = po0310_Service.YPODTChange(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    //담당자 이관
    @RequestMapping(value = "/po0310_doTransferCtrl")
    public void od01001_doTransferCtrl(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("AM_USER_ID", EverString.nullToEmptyString(req.getParameter("sAM_USER_ID")));
        formData.put("AM_USER_CHANGE_RMK", EverString.nullToEmptyString(req.getParameter("AM_USER_CHANGE_RMK")));

        String msg = po0310_Service.po0310_doTransferCtrl(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }

    @RequestMapping(value="/PO0311/view")
    public String PO0311(EverHttpRequest req) throws Exception {
        return "/evermp/OD01/PO0311";
    }

    @RequestMapping(value = "/PO0311/doSearch")
    public void PO0311_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", po0310_Service.PO0311_doSearch(param));
    }







}