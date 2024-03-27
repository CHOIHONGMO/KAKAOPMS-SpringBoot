package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0280Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0280Controller extends BaseController{
@Autowired EV0280Service EV0280_service;

	/**
	 * 회사현황 평가결과
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0280/view")
	public String EV0280(EverHttpRequest req, EverHttpResponse resp) {
		return "/evermp/buyer/eval/EV0280";
	}

	/**
	 * 조회
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/srm280_doSearch")
	public void srm280_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();

		List<Map<String, Object>> gridDatas = EV0280_service.srm280_doSearch(param);

		resp.setGridObject("grid", gridDatas);
	}
}







