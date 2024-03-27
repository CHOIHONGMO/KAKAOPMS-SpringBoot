package com.st_ones.evermp.vendor.qt.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.qt.service.QT0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/vendor/qt")
public class QT0130Controller extends BaseController {


	@Autowired private QT0100Service qt0100Service;
	@Autowired private CommonComboService commonComboService;

	/********************************************************************************************
	 * 협력사 > 견적관리 > 견적관리 > 견적결과 (QT0220)
	 * 처리내용 : (협력사) 견적 진행 결과를 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value= "/QT0130/view")
	public String QT0130(EverHttpRequest req) throws Exception{

		Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "Q");

		req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
		req.setAttribute("FROM_DATE", EverDate.addMonths(-1));
		req.setAttribute("TO_DATE", EverDate.getDate());

		return "/eversrm/vendor/qt/QT0130";
	}

	@RequestMapping(value= "/QT0130/doSearch")
	public void QT0130_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", qt0100Service.getQtaList(req.getFormData()));
	}

}