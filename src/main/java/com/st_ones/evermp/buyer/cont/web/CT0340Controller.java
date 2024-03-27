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
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0340Controller  extends BaseController {


	@Autowired private CommonComboService commonComboService;

	@Autowired private LargeTextService largeTextService;

	@Autowired private MessageService messageService;

	@Autowired private CT0300Service ct0300service;


	// 계약대기현황
	@RequestMapping(value = "/CT0340/view")
	public String ecoa0040_View(EverHttpRequest req) {


		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/buyer/cont/CT0340";
	}

	// 계약대기현황 - 조회
	@RequestMapping(value = "/CT0340/doSearch")
	public void ecoa0040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", ct0300service.getItemUnitPrcList(req.getFormData()));
	}

}
