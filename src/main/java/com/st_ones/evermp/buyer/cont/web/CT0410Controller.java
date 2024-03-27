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
import com.st_ones.evermp.buyer.cont.service.CT0400Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0410Controller  extends BaseController {


    private static Logger logger = LoggerFactory.getLogger(CT0410Controller.class);
	@Autowired private CommonComboService commonComboService;

	@Autowired private LargeTextService largeTextService;

    @Autowired private MessageService messageService;

    @Autowired private CT0400Service ct0400service;
	@Autowired private CT0300Service ct0300service;


    @RequestMapping(value = "/CT0410/view")
    public String CT0410(EverHttpRequest req) {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        req.setAttribute("fromDate", EverDate.addMonths(-3));
        req.setAttribute("toDate", EverDate.addMonths(1));
        return "/evermp/buyer/cont/CT0410";
    }

	@RequestMapping(value = "/CT0410/doSearch")
	public void getContPoReadyList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", ct0400service.getContPoReadyList(req.getFormData()));
	}


    @RequestMapping(value="/CT0410/doCancelPo")
    public void doCancelPo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String rtnMsg = ct0400service.cancelPo(gridData);
        resp.setResponseMessage(rtnMsg);
    }


	// 계약대기현황 - 계약제외
	@RequestMapping(value = "/CT0410/doExcept")
	public void ecoa0040_doExcept(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("grid");

        String resultMsg = ct0300service.ecoa0040_doExcept(gridDatas);
        resp.setResponseMessage(resultMsg);
	}




}
