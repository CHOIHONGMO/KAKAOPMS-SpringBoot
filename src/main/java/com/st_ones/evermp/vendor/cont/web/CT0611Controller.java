package com.st_ones.evermp.vendor.cont.web;

import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
import com.st_ones.evermp.vendor.cont.service.CT0600Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/cont")
public class CT0611Controller {
    @Autowired  private CT0600Service ct0600service;

    @Autowired private CT0300Service ct0300service;



    // 계약서 상세
    @RequestMapping(value = "/CT0611/view")
    public String secm030_view(EverHttpRequest req, EverHttpResponse resp) {

        Map<String, String> parameterMap = req.getParamDataMap();
        ct0600service.secm030_getContractInfo(req, resp);
        List<Map<String, Object>> subFormList = ct0600service.secm030_doSearchSubForm(parameterMap);

        req.setAttribute("toDate", EverDate.getShortDateString());
        req.setAttribute("subFormList", subFormList);
        req.setAttribute("isDevEnv", PropertiesManager.getBoolean("eversrm.system.developmentFlag"));

        req.setAttribute("itemCnt", ct0300service.doSearchContItem(parameterMap).size());




        return "/evermp/vendor/cont/CT0611";
    }

    // 협력업체 첨부파일 목록을 조회한다.
    @RequestMapping(value = "/CT0611/doSearchSupAttachFileInfo")
    public void ecob0050_doSearchSupAttachFileInfo(EverHttpRequest req, EverHttpResponse resp) throws IOException {
        Map<String, String> param = new HashMap<String, String>();
        param.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
        param.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));
        param.put("CONTRACT_FORM_TYPE", EverString.nullToEmptyString(req.getParameter("contractFormType")));
        resp.setGridObject("gridS", ct0600service.ecob0050_doSearchSupAttachFileInfo(param));
    }

    @RequestMapping(value = "/CT0611/doSearchPayInfo")
    public void ecob0050_doSearchPayInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
        param.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));
        param.put("VENDOR_CD", EverString.nullToEmptyString(req.getParameter("vendorCd")));
        resp.setGridObject("gridP", ct0600service.ecob0050_doSearchPayInfo(param));
    }

    // 첨부파일을 등록하고, PDF를 만든다.
    @RequestMapping(value = "/CT0611/doConfirm")
    public void ecob0050_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = ct0600service.ecob0050_doConfirm(req, resp);
        resp.setResponseMessage(rtnMsg);
    }

    // 서명할 계약서를 조회한다.
    @RequestMapping(value = "/CT0611/getContractsToSign")
    public void secm030_getContractsToSign(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        ct0600service.secm030_getContractsToSign(req, resp);
    }

    // 전자서명된 데이터를 저장하고 계약서 상태를 변경한다.
    @RequestMapping(value = "/CT0611/doSaveSignedData")
    public void ecob0050_doSaveSignedData(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = ct0600service.ecob0050_doSaveSignedData(req, resp);
        resp.setResponseMessage(rtnMsg);
    }

    /**
     * 계약서를 반려처리하고 사유를 저장한다.
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0611/doRejectContract")
    public void secm030_doReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        ct0600service.secm030_doRejectContract(req, resp);
    }

    @RequestMapping(value = "/CT0611/doSearchContItem")
    public void doSearchContItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridItem", ct0300service.doSearchContItem(req.getFormData()));
    }


}
