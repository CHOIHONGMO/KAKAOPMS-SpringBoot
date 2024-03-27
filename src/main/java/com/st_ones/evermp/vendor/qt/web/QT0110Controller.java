package com.st_ones.evermp.vendor.qt.web;

import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.qt.service.QT0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value="/eversrm/vendor/qt")
public class QT0110Controller {

    @Autowired QT0100Service qt0100Service;

    @RequestMapping(value="/QT0110/view")
    public String QT0110(EverHttpRequest req) throws Exception{

        req.setAttribute("fromDate",EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("todayTime",EverDate.getTime());
        return "/eversrm/vendor/qt/QT0110";
    }

    @RequestMapping(value="/QT0110/doSearch")
    public void QT0110_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid",qt0100Service.getRqList(req.getFormData()));
    }

    @RequestMapping(value="/QT0110/doReceipt")
    public void QT0110_doReceipt(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        qt0100Service.receiptRQVN(req.getGridData("grid"));
        resp.setResponseCode("true");
    }

    @RequestMapping(value="/QT0110/doWaive")
    public void QT0110_doWaive(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        String msg = qt0100Service.waiveRFQ(req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }



}
