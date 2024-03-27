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
import com.st_ones.evermp.buyer.cont.service.CT0400Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0420Controller  extends BaseController {


    private static Logger logger = LoggerFactory.getLogger(CT0420Controller.class);
	@Autowired private CommonComboService commonComboService;

	@Autowired private LargeTextService largeTextService;

    @Autowired private MessageService messageService;

    @Autowired private CT0400Service ct0400service;


    @RequestMapping(value = "/CT0420/view")
    public String CT0420(EverHttpRequest req) throws Exception {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        req.setAttribute("fromDate", EverDate.addMonths(-1));
        req.setAttribute("toDate", EverDate.addMonths(1));



        Map<String, String> param = new HashMap<>();
        param.put("FLAG1", "C");
        param.put("FLAG2", "O");
        req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));

        return "/evermp/buyer/cont/CT0420";
    }

	@RequestMapping(value = "/CT0420/doSearch")
	public void formManagementDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", ct0400service.getContPoList(req.getFormData()));
	}


    @RequestMapping(value="/CT0420/doCancelPo")
    public void doCancelPo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridData = req.getGridData("grid");
        String rtnMsg = ct0400service.cancelPo(gridData);
        resp.setResponseMessage(rtnMsg);
    }







}
