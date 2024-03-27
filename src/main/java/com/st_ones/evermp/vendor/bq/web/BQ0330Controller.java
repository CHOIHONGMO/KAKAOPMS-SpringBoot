package com.st_ones.evermp.vendor.bq.web;

import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.bq.service.BQ0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/vendor/bq")
public class BQ0330Controller extends BaseController {


	@Autowired private BQ0300Service bq0300Service;

	/********************************************************************************************
	 * 협력사 > 견적관리 > 견적관리 > 견적결과 (QT0220)
	 * 처리내용 : (협력사) 견적 진행 결과를 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value= "/BQ0330/view")
	public String BQ0330(EverHttpRequest req) throws Exception{

		Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "Q");

		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/vendor/bq/BQ0330";
	}

	@RequestMapping(value= "/BQ0330/doSearch")
	public void BQ0330_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", bq0300Service.getBqList(req.getFormData()));
	}

}