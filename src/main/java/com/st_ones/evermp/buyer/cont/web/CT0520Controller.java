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
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
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
public class CT0520Controller  extends BaseController {


    private static Logger logger = LoggerFactory.getLogger(CT0520Controller.class);
	@Autowired private CommonComboService commonComboService;

	@Autowired private LargeTextService largeTextService;

    @Autowired private MessageService messageService;

    @Autowired private CT0300Service ct0300service;

    @Autowired MessageService msg;


    /**
     * 계약서 현황
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/CT0520/view")
    public String contractStatus(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        UserInfo baseInfo = UserInfoManager.getUserInfo();
        req.setAttribute("fromDate", EverDate.addMonths(-3));
        req.setAttribute("toDate", EverDate.addMonths(13));
        req.setAttribute("pdfPath", PropertiesManager.getString("wizpdf.server.domainName") + "/contPDF/");

        String ctrlCd = baseInfo.getCtrlCd();
        if(ctrlCd==null) ctrlCd = "";

        req.setAttribute("authFlag", ( ctrlCd.indexOf("T100") > -1 ? true : false));

        Map<String, String> param = new HashMap<>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("contUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/buyer/cont/CT0520";
    }

    /**
     * 계약서 현황 조회
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0520/doSearch")
    public void ecoa0020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("authFlag", EverString.nullToEmptyString(req.getParameter("authFlag")));

        resp.setGridObject("grid", ct0300service.ecoa0020_doSearch(param));
    }


    // 계약해지
    @RequestMapping(value="/CT0520/doCancelCont")
    public void ECOA0020_doCancelCont(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        Map<String, String> param = req.getFormData();
        ct0300service.ECOA0020_doCancelCont(param,gridData);
        resp.setResponseMessage(msg.getMessageByScreenId("CT0520", "0022"));
    }
}
