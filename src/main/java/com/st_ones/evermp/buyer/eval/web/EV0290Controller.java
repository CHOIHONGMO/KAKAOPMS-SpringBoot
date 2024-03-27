package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0290Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0290Controller extends BaseController{
@Autowired EV0290Service EV0290_service;

	/**
	 * 회사현황 평가결과
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0290/view")
	public String EV0290(EverHttpRequest req, EverHttpResponse resp) {
		return "/evermp/buyer/eval/EV0290";
	}

	/**
	 * 조회
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/srm290_doSearch")
	public void srm290_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();

		Map<String, Object> map = EV0290_service.srm290_doSearch(param);

		resp.setGridObject("grid", (List<Map<String, Object>>) map.get("grid"));
	}

	// 평가자 조회, 그리드를 만들기 위해
    @RequestMapping(value="/srm290_doSearchUSER")
    public void srm290_doSearchUSER(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> param = req.getFormData();

        List<Map<String, Object>> colData = EV0290_service.srm290_doSearchUSER(param);

        resp.setParameter("colList", EverConverter.getJsonString(colData));
    }
}







