package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.rq.service.RQ0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0110P02Controller extends BaseController {

    @Autowired
    RQ0100Service rq0100Service;

    @RequestMapping(value="/RQ0110P02/view")
    public String RQ0110P02(EverHttpRequest req) throws Exception{
        return "/evermp/buyer/rq/RQ0110P02";
    }

    @RequestMapping(value="/RQ0110P02/doSearch")
    public void RQ0110P02_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("gridL", rq0100Service.getVendorListDefault((Map)req.getFormData()));
    }

}
