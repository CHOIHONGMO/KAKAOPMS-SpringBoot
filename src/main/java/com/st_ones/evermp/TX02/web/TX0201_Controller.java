package com.st_ones.evermp.TX02.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.TX02.service.TX0201_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/TX02/TX0201")
public class TX0201_Controller extends BaseController {

    @Autowired TX0201_Service tx0201Service;
    @Autowired private MessageService msg;

    /**
     * sendbill 사용자조회
     */
    @RequestMapping(value="/TX02_010/view")
    public String TX02_010(EverHttpRequest req) {
        return "/evermp/TX02/TX02_010";
    }

    @RequestMapping(value = "/tx02010_doSearch")
    public void tx02010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", tx0201Service.tx02010_doSearch(req.getFormData()));
    }

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입세금계산서 현황
     */
    @RequestMapping(value="/TX02_020/view")
    public String TX02_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        /*if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }*/

        req.setAttribute("TODAY", EverDate.getDate());
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.addMonths(0).substring(4, 6));

        return "/evermp/TX02/TX02_020";
    }

    @RequestMapping(value = "/tx02020_doSearch")
    public void tx02020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", tx0201Service.tx02020_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/tx02020_doSearchTTID")
    public void tx02020_doSearchTTID(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid_TTID", tx0201Service.tx02020_doSearchTTID(req.getFormData()));
    }

    @RequestMapping(value = "/tx02020_doUpdateTTID")
    public void tx02020_doUpdateTTID(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid_TTID");

        tx0201Service.tx02020_doUpdateTTID(gridList, form);
    }

    @RequestMapping(value = "/tx02020_doSave")
    public void tx02020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx0201Service.tx02020_doSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 병합
    @RequestMapping(value = "/tx02020_doSaveMerge")
    public void tx02020_doSaveMerge(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx0201Service.tx02020_doSaveMerge(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 삭제
    @RequestMapping(value = "/tx02020_doTaxCancel")
    public void tx02020_doTaxCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx0201Service.tx02020_doTaxCancel(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/tx02020_doSavePayment")
    public void tx02020_doSavePayment(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = tx0201Service.tx02020_doSavePayment(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 전송
    @RequestMapping(value = "/tx02020_doUniPostTrans")
    public void tx02020_doUniPostTrans(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx0201Service.tx02020_doUniPostTrans(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX02_020", "038"));
            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 재전송
    @RequestMapping(value = "/tx02020_doUniPostReSend")
    public void tx02020_doUniPostReSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx0201Service.tx02020_doUniPostReSend(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
//            String[] s = e.getMessage().split((":"));
//            String TAX_NUM = s[0];
//
//            if("T".equals(s[1])) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX02_020", "038"));
//            } else if("S".equals(s[1])) {
//                resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "037"));
//            }

            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", TAX_NUM);
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 취소
    @RequestMapping(value = "/tx02020_doUniPostCancel")
    public void tx02020_doUniPostCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx0201Service.tx02020_doUniPostCancel(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX01_010", "037"));
            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    // 메일 재발송
    @RequestMapping(value = "/tx02020_doUniPostMailReSend")
    public void tx02020_doUniPostMailReSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        Map<String, Object> rtnMsg = new HashMap<String, Object>();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        try {
            rtnMsg = tx0201Service.tx02020_doUniPostMailReSend(gridList, form);

            resp.setResponseMessage((String) rtnMsg.get("msgName"));
            resp.setResponseCode((String) rtnMsg.get("msgCode"));
            resp.setDataObject("ERR", rtnMsg);
        } catch (Exception e) {
            resp.setResponseMessage(msg.getMessageByScreenId("TX02_020", "050"));
            resp.setResponseCode("ERR");
//            rtnMsg.put("TAX_NUM", e.getMessage());
            resp.setDataObject("ERR", rtnMsg);
        }
    }

    @RequestMapping(value = "/doAlarmInvoiceDelay")
    public void doAlarmInvoiceDelay(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = tx0201Service.doAlarmInvoiceDelay(gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 운영사 > 정산관리 > 매입정산 > 매입회계계산서 목록
    @RequestMapping(value="/TX02_030/view")
    public String TX02_030(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.addMonths(0).substring(4, 6));

        return "/evermp/TX02/TX02_030";
    }

    // 조회
    @RequestMapping(value = "/tx02030_doSearch")
    public void tx02030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", tx0201Service.tx02030_doSearch(req.getFormData()));
    }
}