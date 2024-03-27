package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
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
public class CT0510Controller  extends BaseController {

	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
	@Autowired private MessageService messageService;
	@Autowired private CT0300Service ct0300service;

	// 계약대기현황
	@RequestMapping(value = "/CT0510/view")
	public String ecoa0040_View(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		Map<String, String> param = req.getParamDataMap();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("contUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/buyer/cont/CT0510";
	}

	// 계약대기현황 - 조회
	@RequestMapping(value = "/CT0510/doSearch")
	public void ecoa0040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		resp.setGridObject("grid", ct0300service.getContReadyList(req.getFormData()));
	}


	// 계약대기현황 - 계약제외
	@RequestMapping(value = "/CT0510/doExcept")
	public void ecoa0040_doExcept(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("grid");

        String resultMsg = ct0300service.doExecClose(gridDatas);
        resp.setResponseMessage(resultMsg);
	}

	// 계약서 조회
	@RequestMapping(value = "/CT0510P01/view")
	public String ecoa0041_View(EverHttpRequest req) {
		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());
		return "/evermp/buyer/cont/CT0510P01";
	}

	// 조회
	@RequestMapping(value = "/CT0510P01/doSearch")
	public void ecoa0041_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", ct0300service.ecoa0041_doSearch(req.getFormData()));
	}


}
