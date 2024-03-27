package com.st_ones.evermp.PY02.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.PY02.service.PY02_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/PY02")
public class PY02_Controller extends BaseController {

    @Autowired private PY02_Service py02_Service;
    @Autowired CommonComboService commonComboService;

    /** ******************************************************************************************
     * 운영사 > 정산관리 > 매입정산 > 매입정산현황
     */
    @RequestMapping(value="/PY02_010/view")
    public String PY02_010(EverHttpRequest req) {
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.getMonth());

        return "/evermp/PY02/PY02_010";
}

    @RequestMapping(value = "/py02010_doSearch")
    public void py02010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", py02_Service.py02010_doSearch(req.getFormData()));
    }

    /** ******************************************************************************************
     * 운영사 > 정산관리 > 매입정산 > 매입현황
     */
    @RequestMapping(value="/PY02_020/view")
    public String PY02_020(EverHttpRequest req) {
        req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.getMonth());

        return "/evermp/PY02/PY02_020";
    }

    @RequestMapping(value = "/py02020_doSearch")
    public void py02020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", py02_Service.py02020_doSearch(req.getFormData()));
    }

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입마감대상
     */
    @RequestMapping(value="/PY02_030/view")
    public String PY02_030(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

    	req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("END_DATE", EverDate.getLastDayofMonth( EverDate.getShortDateString().substring(0,6)  ) );
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));

        return "/evermp/PY02/PY02_030";
    }

    @RequestMapping(value = "/py02030_doSearch")
    public void py02030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", py02_Service.py02030_doSearch(req.getFormData()));
    }

    // 매입마감 확정
    @RequestMapping(value = "/py02030_doSaveConfirm")
    public void py02030_doSaveConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py02_Service.py02030_doSaveConfirm(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입마감 현황
     */
    @RequestMapping(value="/PY02_040/view")
    public String PY02_040(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        req.setAttribute("CLOSE_MONTH", EverDate.getMonth());
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0052", new HashMap<String, String>()));
        req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("END_DATE", EverDate.getLastDayofMonth( EverDate.getShortDateString().substring(0,6)  ) );

        return "/evermp/PY02/PY02_040";
    }

    @RequestMapping(value = "/py02040_doSearch")
    public void py02040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", py02_Service.py02040_doSearch(req.getFormData()));
    }

    // 삭제
    @RequestMapping(value = "/py02040_doDelete")
    public void py02040_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py02_Service.py02040_doDelete(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    // 저장
    @RequestMapping(value = "/py2040_doSave")
    public void py01020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py02_Service.py2040_doSave(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }


    // 매입계사서 생성
    @RequestMapping(value = "/py02040_doTaxCreate")
    public void py02040_doTaxCreate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");

        String rtnMsg = py02_Service.py02040_doTaxCreate(gridList, form);

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/doAlarmInvoiceDelay")
    public void doAlarmInvoiceDelay(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String returnMsg = py02_Service.doAlarmInvoiceDelay(req.getGridData("grid"));
        resp.setResponseMessage(returnMsg);
    }
}
