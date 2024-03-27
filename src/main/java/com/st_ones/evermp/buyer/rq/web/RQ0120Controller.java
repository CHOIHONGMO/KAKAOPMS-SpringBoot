package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.rq.service.RQ0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0120Controller   extends BaseController {


	@Autowired private RQ0100Service rq0100service;

    @RequestMapping(value="/RQ0120/view")
    public String RQ0110(EverHttpRequest req) throws Exception{
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        return "/evermp/buyer/rq/RQ0120";
    }


    @RequestMapping(value = "/RQ0120/doSearch")
    public void getRfqHdList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        resp.setGridObject("grid", rq0100service.getRfqHdList(formData));
        resp.setResponseCode("true");
    }

	@RequestMapping(value = "/RQ0120/doCloseRfq")
	public void doCloseRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0100service.closeRfq(gridData));
	}

	@RequestMapping(value = "/RQ0120/doCtrlIdChg")
	public void Transfer(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0100service.transfer(formData,gridData));
	}






    @RequestMapping(value="/RQ0120P01/view")
    public String RQ0120P01(EverHttpRequest req) throws Exception{
        req.setAttribute("toDay", EverDate.getDate());
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0100service.getRfqHd(formData));
        return "/evermp/buyer/rq/RQ0120P01";
    }

    @RequestMapping(value="/RQ0120P02/view")
    public String RQ0120P02(EverHttpRequest req) throws Exception{
        req.setAttribute("toDay", EverDate.getDate());
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0100service.getRfqHd(formData));
        return "/evermp/buyer/rq/RQ0120P02";
    }




	@RequestMapping(value = "/RQ0120P01/chgStartDate")
	public void chgStartDate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
    	resp.setResponseMessage(rq0100service.chgRfqDate(formData));
	}






	@RequestMapping(value = "/RQ0120P02/chgEndDate")
	public void chgEndDate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
    	resp.setResponseMessage(rq0100service.chgRfqDate(formData));
	}




    @RequestMapping(value="/RQ0120P03/view")
    public String RQ0120P03(EverHttpRequest req) throws Exception{
        req.setAttribute("toDay", EverDate.getDate());
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0100service.getRfqHd(formData));
        return "/evermp/buyer/rq/RQ0120P03";
    }

    @RequestMapping(value = "/RQ0120P03/doSearch")
    public void getRfqQtaList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        resp.setGridObject("grid", rq0100service.getRfqQtaList(formData));
        resp.setResponseCode("true");
    }












}