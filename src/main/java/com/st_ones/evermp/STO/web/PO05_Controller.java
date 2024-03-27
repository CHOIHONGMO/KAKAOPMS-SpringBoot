package com.st_ones.evermp.STO.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.STO.service.PO05_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/STO")
public class PO05_Controller extends BaseController {

    @Autowired
    PO05_Service po05Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;
    @Autowired
    LargeTextService largeTextService;
    /** ****************************************************************************************************************
     * 재고관리/ 재고발주 처리 , VMI 발주 처리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PO0510/view")
    public String PO0510(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

    	req.setAttribute("form", req.getParamDataMap());
        return "/evermp/STO/PO0510";
    }

    //조회
    @RequestMapping(value = "/PO0510/po0510_doSearch")
    public void po0510_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", po05Service.po0510_doSearch(req.getFormData()));
    }





    /** ******************************************************************************************
     * 재고발주등록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/PO0550/view")
    public String PO0550(EverHttpRequest req) throws Exception {
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());


        UserInfo userInfo = UserInfoManager.getUserInfo();
        userInfo.getCompanyNm();


        String paramArray =EverString.nullToEmptyString(req.getParamDataMap().get("paramArray"));
        if( !paramArray.equals("")  ){
        	req.setAttribute("paramArray", EverConverter.getJsonString(EverConverter.readJsonObject(req.getParamDataMap().get("paramArray"), List.class)));
           }

        req.setAttribute("form", req.getParamDataMap());
        req.setAttribute("hopeDueDate", EverDate.addDateDay(EverDate.getDate(), 7));

        return "/evermp/STO/PO0550";
    }


    @RequestMapping(value="/PO0550/PO0550_doOrder")
    public void PO0550_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Order");

        String returnMsg = po05Service.PO0550_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }



    /** ******************************************************************************************
     *  공급사 선택
      * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PO0560/view")
    public String PO0560(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/STO/PO0560";
    }

    @RequestMapping(value="/PO0560/PO0560_doSearch")
    public void PO0560_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", po05Service.PO0560_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 재고관리/ 재고발주 현황 , VMI 발주 현황 [PO0520]
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/PO0520/view")
    public String PO0520(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("W100"));
        req.setAttribute("havePermission", havePermission);
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));
        return "/evermp/STO/PO0520";
    }
    //조회
    @RequestMapping(value = "/PO0520/PO0520_doSearch")
    public void PO0520_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));
        resp.setGridObject("grid", po05Service.PO0520_doSearch(param));
    }
    //발주확정
    @RequestMapping(value = "/PO0520/PO0520_doPoConfirm")
    public void PO0520_doPoConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = po05Service.po0520_doPoConfirmXX(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }
    // 발주종결
    @RequestMapping(value = "PO0520/po0520_doPoClose")
    public void po0520_doPoClose(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
        String msg = po05Service.po0520_doPoClose(formData,req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }
    //담당자이관
    @RequestMapping(value = "PO0520/po0520_doTransferCtrl")
    public void po0520_doTransferCtrl(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("AM_USER_ID", EverString.nullToEmptyString(req.getParameter("sAM_USER_ID")));
        formData.put("AM_USER_CHANGE_RMK", EverString.nullToEmptyString(req.getParameter("AM_USER_CHANGE_RMK")));

        String msg = po05Service.po0520_doTransferCtrl(formData, req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }
}