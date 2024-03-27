package com.st_ones.evermp.vendor.cont.web;

import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.cont.service.CT0600Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/cont")
public class CT0610Controller {
    @Autowired  private CT0600Service ct0600service;

    @RequestMapping(value = "/CT0610/view")
    public String CT0610(EverHttpRequest req) throws Exception {

        req.setAttribute("fromDate", EverDate.addMonths(-2));
        req.setAttribute("toDate", EverDate.getDate());
        req.setAttribute("pdfPath", PropertiesManager.getString("wizpdf.server.domainName") + "/contPDF/");
        //work list에서 호출 시 넘기는 parameter
        req.setAttribute("dashBoardFlag", EverString.defaultIfEmpty(req.getParamDataMap().get("dashBoardFlag"),""));
        req.setAttribute("PROGRESS_CD", EverString.defaultIfEmpty(req.getParamDataMap().get("PROGRESS_CD"),""));

        return "/evermp/vendor/cont/CT0610";
    }

    @RequestMapping(value = "/CT0610/doSearch")
    public void doSearchContractProgressStatus(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", ct0600service.doSearchContractProgressStatus(req.getFormData()));
    }


    @RequestMapping(value = "/CT0610/doReceipt")
    public void doReceipt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	List<Map<String,Object>> grid = req.getGridData("grid");
        String rtnMsg = ct0600service.receipt(grid);
        resp.setResponseMessage(rtnMsg);
    }


    @RequestMapping(value = "/CT0610/doReject")
    public void doReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	List<Map<String,Object>> grid = req.getGridData("grid");
        String rtnMsg = ct0600service.reject(grid);
        resp.setResponseMessage(rtnMsg);
    }


}
