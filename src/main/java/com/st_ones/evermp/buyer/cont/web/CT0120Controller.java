package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.message.service.MessageType;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0100Service;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0120Controller  extends BaseController {

	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
    @Autowired private MessageService messageService;
    
	@Autowired CT0100Service ct0100service;

    @RequestMapping(value = "/CT0120/view")
    public String becf040View(EverHttpRequest req) throws Exception {
    	Map<String, String> formData = req.getParamDataMap();
        String formNum = formData.get("formNum");//req.getParameter("formNum");
        if(StringUtils.isNotEmpty(formNum)) {

        	Map<String, String> contData = ct0100service.becf040_doSearch(formNum);
        	if("Y".equals(formData.get("COPY_YN"))) {
        		contData.put("FORM_NM",     "[복사]"+contData.get("FORM_NM")   );
        	}

            req.setAttribute("form", contData);
        }
        req.setAttribute("formTypes", commonComboService.getCodeComboAsJson("M078"));
        req.setAttribute("formGubun", commonComboService.getCodeComboAsJson("M176"));

        return "/evermp/buyer/cont/CT0120";
    }

    @RequestMapping(value = "/CT0120/doSearchECCR")
	public void becf040_doSearchECCR(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("SEL_FLAG", EverString.nullToEmptyString(req.getParameter("SEL_FLAG")));

		resp.setGridObject("grid", ct0100service.becf040_doSearchECCR(req.getFormData()));
	}

    @RequestMapping(value = "/CT0120/doSave")
    public void becf040_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        formData.put("FORM_CONTENTS", req.getParameter("formContents"));

        String formType = EverString.nullToEmptyString(req.getParameter("formType"));
        List<Map<String, Object>> gridData = (formType.equals("100") ? req.getGridData("grid") : new ArrayList<Map<String, Object>>());

        String formNum = ct0100service.becf040_doSave(formData, gridData);
        resp.setResponseMessage(messageService.getMessage(MessageType.SAVE_SUCCEED));
        resp.setParameter("formNum", formNum);
    }


}
