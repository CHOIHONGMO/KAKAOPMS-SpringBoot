package com.st_ones.evermp.vendor.qt.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.qt.service.QT0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/qt")
public class QT0310Controller {

    @Autowired  QT0300Service qt0300Service;

    @RequestMapping(value="/QT0310/view")
    public String QT0310(EverHttpRequest req) throws Exception{

        req.setAttribute("fromDate",EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.addDays(5));
        req.setAttribute("todayTime",EverDate.getTime());
        return "/evermp/vendor/qt/QT0310";
    }

    @RequestMapping(value="/QT0310/doSearch")
    public void QT0310_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid",qt0300Service.getRqList(req.getFormData()));
    }

    @RequestMapping(value="/QT0310/doReceipt")
    public void QT0310_doReceipt(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        qt0300Service.receiptRQVN(req.getGridData("grid"));
        resp.setResponseCode("true");
    }
    
    /**
     * 견적/입찰 > 견적관리 > 견적현황 (QT0310) : 견적포기
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value="/QT0310/doWaive")
    public void QT0310_doWaive(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        String msg = qt0300Service.waiveRFQ(req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }
    
    @RequestMapping(value = "/QT0310/doSearchT")
    public void sso1010_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("RFX_NUM", EverString.nullToEmptyString(req.getParameter("RFX_NUM")));
        param.put("RFX_CNT", EverString.nullToEmptyString(req.getParameter("RFX_CNT")));
        param.put("BUYER_CD", EverString.nullToEmptyString(req.getParameter("BUYER_CD")));
        param.put("VENDOR_CD", userInfo.getCompanyCd());
        param.put("scrId", "0310");
        resp.setGridObject("gridT", qt0300Service.doSearchT(param));
    }



}
