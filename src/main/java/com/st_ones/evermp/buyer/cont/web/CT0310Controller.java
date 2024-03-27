package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0310Controller  extends BaseController {

	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
	@Autowired private MessageService messageService;
	@Autowired private CT0300Service ct0300service;

	// 계약대기현황
	@RequestMapping(value = "/CT0310/view")
	public String ecoa0040_View(EverHttpRequest req) {


		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/buyer/cont/CT0310";
	}

	// 계약대기현황 - 조회
	@RequestMapping(value = "/CT0310/doSearch")
	public void ecoa0040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

//		Map<String,String> mmm = new HashMap<String,String>();
//		mmm.put("RECV_USER_ID", "MASTER");
//		mmm.put("SUBJECT", "test");
//		mmm.put("CONTENTS_TEMPLATE", "TEST TEST 0000000001");
//        if (PropertiesManager.getBoolean("eversrm.system.sms.send.flag")) {
//            kakaoService.sendMessage(mmm);
//    	}

//		kakaoservice.listATSTempalte_TEST();



		resp.setGridObject("grid", ct0300service.ecoa0040_doSearch(req.getFormData()));
	}


	// 계약대기현황 - 계약제외
	@RequestMapping(value = "/CT0310/doExcept")
	public void ecoa0040_doExcept(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("grid");

        String resultMsg = ct0300service.ecoa0040_doExcept(gridDatas);
        resp.setResponseMessage(resultMsg);
	}

	// 계약서 조회
	@RequestMapping(value = "/CT0310P01/view")
	public String ecoa0041_View(EverHttpRequest req) {
		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/buyer/cont/CT0310P01";
	}

	// 조회
	@RequestMapping(value = "/CT0310P01/doSearch")
	public void ecoa0041_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", ct0300service.ecoa0041_doSearch(req.getFormData()));
	}


}
