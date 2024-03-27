package com.st_ones.evermp.vendor.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.cont.service.CT0600Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/cont")
public class CT0620Controller {
    @Autowired  private CT0600Service ct0600service;

    @Autowired private CommonComboService commonComboService;

    @RequestMapping(value = "/CT0620/view")
    public String CT0620(EverHttpRequest req) throws Exception {
    	
        Map<String, String> param = new HashMap<>();
        param.put("FLAG1", "O");
        param.put("FLAG2", "C");
        req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
        req.setAttribute("fromDate", EverDate.addMonths(-2));
        req.setAttribute("toDate", EverDate.getDate());
        req.setAttribute("pdfPath", PropertiesManager.getString("wizpdf.server.domainName") + "/contPDF/");
        //work list에서 호출 시 넘기는 parameter
        req.setAttribute("dashBoardFlag", EverString.defaultIfEmpty(req.getParamDataMap().get("dashBoardFlag"),""));
        req.setAttribute("PROGRESS_CD", EverString.defaultIfEmpty(req.getParamDataMap().get("PROGRESS_CD"),""));
        return "/evermp/vendor/cont/CT0620";
    }

    @RequestMapping(value = "/CT0620/doSearch")
    public void doSearchContractProgressStatus(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
    	param.put("CT0620FG","Y");
    	resp.setGridObject("grid", ct0600service.doSearchContractProgressStatus(param));
    }

    @RequestMapping(value="/CT0620P01/view")
	public String CT0620P01(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	UserInfo userInfo = UserInfoManager.getUserInfo();
    	req.setAttribute("ATT_FILE_FLAG",userInfo.getUserType().equals("S") ? true :false );
    	req.setAttribute("form", ct0600service.getContractInformation(formData));
    	req.setAttribute("gubn", formData.get("gubn"));

		return "/evermp/vendor/cont/CT0620P01";
	}
 // 계약서 저장
    @RequestMapping(value = "/CT0620P01/doSave")
    public void doSaveCT0620P01 (EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();

    	String rtnMsg = ct0600service.doUpdateEc(formData);
    	resp.setResponseMessage(rtnMsg);
    }
 // 계약서 저장
    @RequestMapping(value = "/CT0620P01/SendSevlet")
    public void CT0620P01doSearch (EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
    	ct0600service.SendSevlet(req,resp);

    }
}
