package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.common.combo.service.CommonComboService;
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
public class RQ0140Controller extends BaseController {


	@Autowired private RQ0100Service rq0100service;
	@Autowired CommonComboService commonComboService;


	/********************************************************************************************
	 * 구매사> 구매관리 > 견적/입찰관리 > 협력사 선정 (RQ0140)
	 * 처리내용 : (구매사) 협력사 선정 대상을 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/RQ0140/view")
	public String RQ0140(EverHttpRequest req) throws Exception{

        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());

		return "/evermp/buyer/rq/RQ0140";
	}

	@RequestMapping(value="/RQ0140/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0100service.getOpenSettleTargetList(req.getFormData()));
	}



	@RequestMapping(value = "/RQ0140/doQtOpen")
	public void doQtOpen(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0100service.saveQtaOpen(formData,gridData));
	}


	@RequestMapping(value="/RQ0140P01/view")
	public String RQ0140P01(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0100service.getRfqHd(formData));

		return "/evermp/buyer/rq/RQ0140P01";
	}

	@RequestMapping(value="/RQ0140P01/doSearchDocVendor")
	public void getTargetVendor(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridV", rq0100service.getTargetVendor(req.getFormData()));
	}

	@RequestMapping(value="/RQ0140P01/doSearchDocItem")
	public void getTargetItemList(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0100service.getTargetItemList(req.getFormData()));
	}


	@RequestMapping(value="/RQ0140P01/doDocSettle")
	public void doDocSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0100service.setDocSettle(formData));

	}

	@RequestMapping(value="/RQ0140P01/doCancelRfq")
	public void doCancelRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0100service.cancelRfq(formData));

	}












	@RequestMapping(value="/RQ0140P02/view")
	public String RQ0140P02(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0100service.getRfqHd(formData));
		return "/evermp/buyer/rq/RQ0140P02";
	}

	@RequestMapping(value="/RQ0140P02/doSearch")
	public void getItemSettleList(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0100service.getSettleItemList(req.getFormData()));
	}


	@RequestMapping(value="/RQ0140P02/doCancelRfq")
	public void doCancelRfq2(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0100service.cancelRfq(formData));

	}

	@RequestMapping(value="/RQ0140P02/doItemSettle")
	public void doItemSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0100service.doItemSettle(formData,gridData));

	}







	@RequestMapping(value="/RQ0140P03/view")
	public String RQ0140P03(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0100service.getRfqHd(formData));
        req.setAttribute("fromDate", EverDate.getDate());
        req.setAttribute("todayTime", EverDate.getTime().substring(0,4));
		return "/evermp/buyer/rq/RQ0140P03";
	}

	@RequestMapping(value="/RQ0140P03/doReRfq")
	public void doReRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0100service.reRfq(formData));
	}














}