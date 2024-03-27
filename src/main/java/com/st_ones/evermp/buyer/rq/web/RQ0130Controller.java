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

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0130Controller extends BaseController {


	@Autowired private RQ0100Service rq0100service;
	@Autowired CommonComboService commonComboService;


	/********************************************************************************************
	 * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0130)
	 * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/RQ0130/view")
	public String RQ0130(EverHttpRequest req) throws Exception{

		Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "Q");

		req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
		req.setAttribute("FROM_DATE", EverDate.addMonths(-1));
		req.setAttribute("TO_DATE", EverDate.getDate());

		return "/evermp/buyer/rq/RQ0130";
	}

	@RequestMapping(value="/RQ0130/doSearch")
	public void RQ0130_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0100service.getQtaList(req.getFormData()));
	}


}