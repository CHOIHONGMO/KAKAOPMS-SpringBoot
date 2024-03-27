package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.rq.service.RQ0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0320Controller extends BaseController {


	@Autowired private RQ0300Service rq0300service;
	@Autowired private CommonComboService commonComboService;
    @RequestMapping(value="/RQ0320/view")
    public String RQ0110(EverHttpRequest req) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


    	req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        Map<String, String> param = req.getParamDataMap();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
        return "/evermp/buyer/rq/RQ0320";
    }


    @RequestMapping(value = "/RQ0320/doSearch")
    public void getRfqHdList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        resp.setGridObject("grid", rq0300service.getRfqHdList(formData));
        resp.setResponseCode("true");
    }

	@RequestMapping(value = "/RQ0320/doCloseRfq")
	public void doCloseRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0300service.closeRfq(gridData));
	}

	@RequestMapping(value = "/RQ0320/doCtrlIdChg")
	public void Transfer(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0300service.transfer(formData,gridData));
	}



    @RequestMapping(value="/RQ0320P01/view")
    public String RQ0120P02(EverHttpRequest req) throws Exception{
        req.setAttribute("toDay", EverDate.getDate());
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0300service.getRfqHd(formData));
        return "/evermp/buyer/rq/RQ0320P01";
    }

	@RequestMapping(value = "/RQ0320P01/chgEndDate")
	public void chgEndDate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
    	resp.setResponseMessage(rq0300service.chgRfqDate(formData));
	}

	@RequestMapping(value="/RQ0320P02/view")
    public String RQ0120P01(EverHttpRequest req) throws Exception{
        req.setAttribute("toDay", EverDate.getDate());
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0300service.getRfqHd(formData));
    	req.setAttribute("RFX_DATE", String.valueOf(rq0300service.getRfqHd(formData).get("RFX_DATE")).split(" ")[0]);
        return "/evermp/buyer/rq/RQ0320P02";
    }

	@RequestMapping(value = "/RQ0320P02/chgStartDate")
	public void chgStartDate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
    	resp.setResponseMessage(rq0300service.chgRfqDate(formData));
	}


//
//
//
//
//    @RequestMapping(value="/RQ0120P03/view")
//    public String RQ0120P03(EverHttpRequest req) throws Exception{
//        req.setAttribute("toDay", EverDate.getDate());
//    	Map<String, String> formData = req.getParamDataMap();
//    	req.setAttribute("form", rq0100service.getRfqHd(formData));
//        return "/evermp/buyer/rq/RQ0120P03";
//    }
//
//    @RequestMapping(value = "/RQ0120P03/doSearch")
//    public void getRfqQtaList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
//        Map<String, String> formData = req.getFormData();
//        resp.setGridObject("grid", rq0100service.getRfqQtaList(formData));
//        resp.setResponseCode("true");
//    }












}