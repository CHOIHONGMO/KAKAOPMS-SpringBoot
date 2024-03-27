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
import com.st_ones.evermp.STO.service.PO06_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/STO")
public class PO06_Controller extends BaseController {

    @Autowired
    PO06_Service po06Service;
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
     * 재고관리 > 재고발주 > VMI재고보충 신청 (PO0610)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PO0610/view")
    public String PO0610(EverHttpRequest req) throws Exception {
       req.setAttribute("form", req.getParamDataMap());
        return "/evermp/STO/PO0610";
    }
    //조회
    @RequestMapping(value = "/PO0610/po0610_doSearch")
    public void po0610_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", po06Service.po0610_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
    * 재고관리 > 재고발주 > VMI재고보충 신청> VMI 재고 주문 (SPO0601)
    * @param req
    * @return
    * @throws Exception
    */
    @RequestMapping(value="/SPO0601/view")
    public String SPO0601(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("toDate", EverDate.getDate());
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getManageCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
        req.setAttribute("custMngId", commonComboService.getCodesAsJson("CB0064", param));

        userInfo.getCompanyNm();

        req.setAttribute("form", req.getParamDataMap());
        req.setAttribute("paramArray", EverConverter.getJsonString(EverConverter.readJsonObject(req.getParamDataMap().get("paramArray"), List.class)));
        req.setAttribute("hopeDueDate", EverDate.addDateDay(EverDate.getDate(), 7));

        return "/evermp/STO/SPO0601";
    }

    // 주문하기
    @RequestMapping(value="/SPO0601/PO0550_doOrder")
    public void PO0550_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Order");

        String returnMsg = po05Service.PO0550_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }


    /** ****************************************************************************************************************
     * 재고관리 > 재고발주 > VMI재고보충 현황 (PO0620)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/PO0620/view")
    public String PO0620(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        req.setAttribute("form", req.getParamDataMap());

       return "/evermp/STO/PO0620";
    }

    @RequestMapping(value = "/PO0620/PO0620_doSearch")
    public void PO0620_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
        param.put("callType", EverString.nullToEmptyString(req.getParameter("callType")));
        resp.setGridObject("grid", po06Service.PO0620_doSearch(param));
    }

    /** ****************************************************************************************************************
     * 재고관리 > 재고발주 > VMI 재고 주문 (SPO0601)
     * @param req
     * @return
     * @throws Exception
     */
    // 주문하기
    @RequestMapping(value="SPO0601/SPO0601_doOrder")
    public void SPO0601_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        param.put("pMod", "Order");

        String returnMsg = po06Service.spo0601_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }
}