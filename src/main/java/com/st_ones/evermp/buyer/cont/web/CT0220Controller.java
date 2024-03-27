package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0200Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0220Controller  extends BaseController {

    private static Logger logger = LoggerFactory.getLogger(CT0220Controller.class);
	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
    @Autowired private MessageService messageService;
    @Autowired private CT0200Service ct0200service;

    @RequestMapping(value = "/CT0220/view")
    public String contractStatus(EverHttpRequest req) throws Exception {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        req.setAttribute("fromDate", EverDate.addMonths(-3));
        req.setAttribute("toDate", EverDate.addMonths(1));
        req.setAttribute("pdfPath", PropertiesManager.getString("wizpdf.server.domainName") + "/contPDF/");
        req.setAttribute("authFlag", (!baseInfo.getGrantedAuthCd().equals("PF0113") ? true : false));

        Map<String, String> param = new HashMap<>();
        param.put("FLAG1", "C");
        req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));

        return "/evermp/buyer/cont/CT0220";
    }

    @RequestMapping(value = "/CT0220/doSearch")
    public void ecoa0020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("authFlag", EverString.nullToEmptyString(req.getParameter("authFlag")));

        resp.setGridObject("grid", ct0200service.basicContSearch(param));
    }

}
