package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0200Service;
import com.st_ones.evermp.buyer.cont.service.makeHtmlService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cont")
public class CT0210Controller  extends BaseController {
	
	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
    @Autowired private MessageService messageService;
	
    @Autowired CT0200Service ct0200service;
    @Autowired private makeHtmlService makehtmlservice;

    /**
     * 일괄계약서 작성 화면
     *
     * @param req
     * @param resp
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/CT0210/view")
    public String ecob0040_view(EverHttpRequest req, EverHttpResponse resp) {

        Map<String, String> param = new HashMap<String, String>();
        param.put("BUNDLE_NUM", EverString.nullToEmptyString(req.getParameter("bundleNum")));
        param.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
        param.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));
        param.put("VENDOR_CD", EverString.nullToEmptyString(req.getParameter("vendorCd")));
        param.put("APP_DOC_NUM", EverString.nullToEmptyString(req.getParameter("appDocNum")));
        param.put("APP_DOC_CNT", EverString.nullToEmptyString(req.getParameter("appDocCnt")));

        String resumeFlag = EverString.nullToEmptyString(req.getParameter("resumeFlag"));

        param.put("resumeFlag", resumeFlag);

        Map<String, String> formData = ct0200service.ecob0040_getBundleContractInfo(param);
        if(formData == null) {
            formData = new HashMap<String, String>();
            formData.put("SEARCH_TYPE", "ALL");
        }

        List<Map<String, Object>> subFormList = new ArrayList<Map<String, Object>>();
        if(formData != null) {
            formData.put("resumeFlag", (EverString.nullToEmptyString(req.getParameter("resumeFlag")).equals("true") ? "true" : "false")); // 변경계약여부


            if(resumeFlag.equals("true")) {
                String progressCd = Code.CONT_TEMP_SAVE;
                formData.put("PROGRESS_CD", progressCd);
                String signStatus = Code.M020_T;
                formData.put("SIGN_STATUS", signStatus);
            }

            subFormList = ct0200service.ecob0040_doSearchAdditionalForm(formData);
        }

        req.setAttribute("form", formData);
        req.setAttribute("subFormList", subFormList);
        req.setAttribute("resumeFlag", resumeFlag);

        req.setAttribute("toDate", EverDate.getShortDateString());
        return "/evermp/buyer/cont/CT0210";
    }

    /**
     * 일괄계약서 - 협력회사 엑셀 업로드 시 협력회사 코드기준으로 모든 데이터를 조회하여 그리드에 출력
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0210/getVendorListForBundleContract")
    public void becm080_getVendorListForBundleContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridVData = req.getGridData("gridV");
        List<Map<String, Object>> resultList = ct0200service.becm080_getVendorListForBundleContract(gridVData);

        resp.setGridObject("gridV", resultList);
    }

    /**
     * 일괄계약서 저장
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0210/doSave")
    public void ecob0040_doSaveBundleContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();
        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
        List<Map<String, Object>> gridDataV = req.getGridData("gridV");

        Map<String, String> resultMap = ct0200service.ecob0040_doSaveBundleContract(dataForm, gridDataM, gridDataA, gridDataV);


        makehtmlservice.doMakePDF(resultMap);


        resp.setParameter("bundleNum", resultMap.get("BUNDLE_NUM"));
        resp.setResponseMessage(messageService.getMessage("0001"));
    }

    /**
     * 일괄계약으로 저장된 협력회사 상세 목록을 조회한다.
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0210/getSavedVendorListForBundleContract")
    public void ecob0040_getSavedVendorListForBundleContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("BUNDLE_NUM", EverString.nullToEmptyString(req.getParameter("bundleNum")));
        param.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
        param.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));

        resp.setGridObject("gridV", ct0200service.ecob0040_getSavedVendorListForBundleContract(param));
    }

    // 일괄계약서 삭제
    @RequestMapping(value = "/CT0210/doDeleteBundleContract")
    public void ecob0040_doDeleteBundleContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        formData.put("BUNDLE_NUM", EverString.nullToEmptyString(req.getParameter("bundleNum")));
        formData.put("CONT_NUM", EverString.nullToEmptyString(req.getParameter("contNum")));
        formData.put("CONT_CNT", EverString.nullToEmptyString(req.getParameter("contCnt")));

        String rtnMsg = ct0200service.ecob0040_doDeleteBundleContract(formData);
        resp.setResponseMessage(rtnMsg);
    }

    /**
     * 일괄계약서 전송
     *
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/CT0210/doSendContract")
    public void ecob0040_doSendBundleContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();
        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
        List<Map<String, Object>> gridDataV = req.getGridData("gridV");

        String rtnMsg = ct0200service.ecob0040_doSendBundleContract(dataForm, gridDataM, gridDataA, gridDataV);
        resp.setResponseMessage(rtnMsg);
    }

    // 일괄계약서 계약체결 기안 요청
    @RequestMapping(value = "/CT0210/doReqSign")
    public void ecob0040_doReqSign(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();
        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
        List<Map<String, Object>> gridDataV = req.getGridData("gridV");

        String rtnMsg = ct0200service.ecob0040_doReqSign(dataForm, gridDataM, gridDataA, gridDataV);

		makehtmlservice.doMakePDF(dataForm);





        resp.setResponseMessage(rtnMsg);
    }

    // 일괄계약서 서명
    @RequestMapping(value = "/CT0210/signContract")
    public void ecob0040_doSignContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        //ct0200service.ecob0040_doSignContract(req, resp);
    }




}
