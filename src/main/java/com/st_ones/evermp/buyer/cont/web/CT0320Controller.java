package com.st_ones.evermp.buyer.cont.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.service.CT0100Service;
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
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
public class CT0320Controller  extends BaseController {

	@Autowired private CommonComboService commonComboService;
	@Autowired private LargeTextService largeTextService;
    @Autowired private MessageService messageService;
    @Autowired private CT0300Service ct0300service;
    @Autowired private CT0100Service ct0100service;
    @Autowired private makeHtmlService makehtmlservice;

    // 개별계약서 작성 화면
    @RequestMapping(value = "/CT0320/view")
    public String contractRegistrationView(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        UserInfo baseInfo = UserInfoManager.getUserInfo();

        String openType       = EverString.nullToEmptyString(req.getParameter("openType"));
        String openFormType       = EverString.nullToEmptyString(req.getParameter("openFormType"));
        String selPurcContNum = EverString.nullToEmptyString(req.getParameter("selPurcContNum"));
        String resumeFlag     = EverString.nullToEmptyString(req.getParameter("resumeFlag")).equals("true") ? "true" : "false";

        /*
         openFormType
          A : 단가계약
          B : 기본계약
          D : 일반계약
          D : 기타계약
         */

        System.err.println("=========================openType=============="+openType);
        System.err.println("=========================openFormType=============="+openFormType);
        System.err.println("=========================resumeFlag=============="+resumeFlag);



        // I/F로 받은 계약대기정보를 토대로 신규계약작성
        if(openType.equals("createCont")) {
        	req.setAttribute("form", ct0300service.getFormDataFromERP(req));
            req.setAttribute("subFormList", new ArrayList<Map<String, Object>>());
        }
        // I/F로 받은 계약대기정보를 토대로 변경계약작성
        else if(openType.equals("modCont")) {

            Map<String, String> parameterMap = reqParamMapToStringMap(req.getParameterMap());
            Map<String, String> formData = ct0300service.getFormContractInfoForERP(req, resp, parameterMap);
            //Map<String, String> erpData = ct0300service.getFormDataFromERP(req);

            //formData.putAll(erpData);
            if("true".equals(resumeFlag)) {
            	formData.remove("M_ATT_FILE_NUM");
            	formData.remove("ATT_FILE_NUM");
            }

            req.setAttribute("form", formData);

            List<Map<String, Object>> subFormList = ct0300service.doSearchAdditionalFormForERP(formData);
            req.setAttribute("subFormList", subFormList);
        }
        else {
            Map<String, String> parameterMap = reqParamMapToStringMap(req.getParameterMap());
            parameterMap.put("resumeFlag", resumeFlag); // 변경계약여부

            ct0300service.getFormWithManualContractInfo(req, resp, parameterMap);

            List<Map<String, Object>> subFormList = ct0300service.doSearchAdditionalForm(parameterMap);
            req.setAttribute("subFormList", subFormList);
        }

        req.setAttribute("contractFormType",req.getParameter("contractFormType"));
        req.setAttribute("openType", openType);
        req.setAttribute("selPurcContNum", selPurcContNum);
        req.setAttribute("toDate", EverDate.getShortDateString());
        req.setAttribute("resumeFlag", resumeFlag);
        req.setAttribute("authFlag", (!baseInfo.getGrantedAuthCd().equals("PF0113") ? true : false));
        return "/evermp/buyer/cont/CT0320";
    }


    // 개별계약서 상세보기 화면
    @RequestMapping(value = "/contract/view")
    public String contractDetailView(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> parameterMap = reqParamMapToStringMap(req.getParameterMap());
        parameterMap.put("resumeFlag", (EverString.nullToEmptyString(req.getParameter("resumeFlag")).equals("true") ? "true" : "false")); // 변경계약여부

        ct0300service.getFormWithManualContractInfo(req, resp, parameterMap);

        List<Map<String, Object>> subFormList = ct0300service.doSearchAdditionalForm(parameterMap);
        req.setAttribute("subFormList", subFormList);

        req.setAttribute("openType", "");
        req.setAttribute("selPurcContNum", "");
        req.setAttribute("toDate", EverDate.getShortDateString());
        return "/evermp/buyer/cont/CT0320";
    }

    // 부서식 조회
    @RequestMapping(value = "/CT0320/doSearchAdditionalForm")
    public void doSearchAdditionalForm(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", ct0300service.doSearchAdditionalForm(req.getFormData()));
    }


    @RequestMapping(value = "/CT0320/doSearchContItem")
    public void doSearchContItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setGridObject("gridItem", ct0300service.doSearchContItem(req.getFormData()));
    }


    @RequestMapping(value = "/CT0320/doSearchEcpy")
    public void doSearchEcpy(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setGridObject("gridP", ct0300service.doSearchEcpy(req.getFormData()));
    }



    // 계약서 저장
    @RequestMapping(value = "/CT0320/doSave")
    public void doSaveContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();
        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));
        dataForm.put("oriMainContractContents", req.getParameter("oriMainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridItem = req.getGridData("gridItem");
        List<Map<String, Object>> gridDataP = req.getGridData("gridP");

        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
        // 부서식 확인 없이 저장할 수 있으므로 DB의 부서식을 가져온다.
        for(Map<String, Object> gridData : gridDataA) {
        	//2021-03-19 formContents
            //if(EverString.nullToEmptyString(gridData.get("FORM_CONTENTS")).equals("") || EverString.nullToEmptyString(gridData.get("FORM_CONTENTS")).equals("null") || gridData.get("FORM_CONTENTS") == null) {
                Map<String, String> param = req.getFormData();
                param.put("contNum", dataForm.get("CONT_NUM"));
                param.put("contCnt", dataForm.get("CONT_CNT"));
                param.put("FORM_NUM", (String)gridData.get("REL_FORM_NUM"));
                param.put("type", "S"); // Sub Form
                param.put("selectedFormNum", (String)gridData.get("REL_FORM_NUM"));
                param.put("isUpdatedFormNum", "false");
                //param.put("formContents", null);
                param.put("formContents", (String)gridData.get("FORM_CONTENTS"));
                gridData.put("FORM_CONTENTS", ct0100service.getFormWithManualContractInfo(req, resp, param));
            //}
        }

        Map<String, String> resultMap = ct0300service.doSaveContract(dataForm, gridDataM, gridDataA, gridItem, gridDataP);
        resp.setParameter("contNum", resultMap.get("CONT_NUM"));
        resp.setParameter("contCnt", String.valueOf(resultMap.get("CONT_CNT")));



        resp.setResponseMessage(messageService.getMessage("0001"));
    }

    @RequestMapping(value = "/CT0320/doReqLegalTeam")
    public void becm030_doReqLegalTeam(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();
        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));
        dataForm.put("oriMainContractContents", req.getParameter("oriMainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridItem = req.getGridData("gridItem");
        List<Map<String, Object>> gridDataP = req.getGridData("gridP");

        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
        // 부서식 확인 없이 저장할 수 있으므로 DB의 부서식을 가져온다.
        for(Map<String, Object> gridData : gridDataA) {
        	//2021-03-19
            //if(EverString.nullToEmptyString(gridData.get("FORM_CONTENTS")).equals("") || EverString.nullToEmptyString(gridData.get("FORM_CONTENTS")).equals("null") || gridData.get("FORM_CONTENTS") == null) {
                Map<String, String> param = req.getFormData();
                param.put("contNum", dataForm.get("CONT_NUM"));
                param.put("contCnt", dataForm.get("CONT_CNT"));
                param.put("FORM_NUM", (String)gridData.get("REL_FORM_NUM"));
                param.put("type", "S"); // Sub Form
                param.put("selectedFormNum", (String)gridData.get("REL_FORM_NUM"));
                param.put("isUpdatedFormNum", "false");
                // param.put("formContents", null);
                param.put("formContents", (String)gridData.get("FORM_CONTENTS"));
                gridData.put("FORM_CONTENTS", ct0100service.getFormWithManualContractInfo(req, resp, param));
            //}
        }

        Map<String, String> resultMap = ct0300service.becm030_doReqLegalTeam(dataForm, gridDataM, gridDataA, gridItem, gridDataP);
        resp.setParameter("contNum", resultMap.get("CONT_NUM"));
        resp.setParameter("contCnt", String.valueOf(resultMap.get("CONT_CNT")));
        resp.setParameter("aparType" , resultMap.get("APAR_TYPE"));



        resp.setResponseMessage(resultMap.get("rtnMsg"));
    }

    // 계약체결 기안 요청
    @RequestMapping(value = "/CT0320/doReqSign")
    public void becm030_doReqSign(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();
        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));
        dataForm.put("oriMainContractContents", req.getParameter("oriMainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
//        List<Map<String, Object>> gridDataS = req.getGridData("gridS");
        List<Map<String, Object>> gridDataP = req.getGridData("gridP");
        List<Map<String, Object>> gridItem = req.getGridData("gridItem");

        Map<String, String> resultMap = ct0300service.becm030_doReqSign(dataForm, gridDataM, gridDataA, gridItem, gridDataP);
        resp.setParameter("contNum", resultMap.get("CONT_NUM"));
        resp.setParameter("contCnt", String.valueOf(resultMap.get("CONT_CNT")));
        resp.setResponseMessage(resultMap.get("rtnMsg"));
    }

    // 계약서 전송
    @RequestMapping(value = "/CT0320/doSendContract")
    public void doSend(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> dataForm = req.getFormData();

        //전송시점에 계약일을 현재일로 셋팅한다.
        dataForm.put("CONT_DATE", EverDate.getShortDateString());

        dataForm.put("mainContractContents", req.getParameter("mainContractContents"));
        dataForm.put("oriMainContractContents", req.getParameter("oriMainContractContents"));

        List<Map<String, Object>> gridDataM = req.getGridData("gridM");
        List<Map<String, Object>> gridDataS = req.getGridData("gridS");
        List<Map<String, Object>> gridDataP = req.getGridData("gridP");

        List<Map<String, Object>> gridDataA = req.getGridData("gridA");
        // 부서식 확인 없이 저장할 수 있으므로 DB의 부서식을 가져온다.
        for(Map<String, Object> gridData : gridDataA) {
        	//2021-03-19
            //if(EverString.nullToEmptyString(gridData.get("FORM_CONTENTS")).equals("") || EverString.nullToEmptyString(gridData.get("FORM_CONTENTS")).equals("null") || gridData.get("FORM_CONTENTS") == null) {
                Map<String, String> param = req.getFormData();
                param.put("contNum", dataForm.get("CONT_NUM"));
                param.put("contCnt", dataForm.get("CONT_CNT"));
                param.put("FORM_NUM", (String)gridData.get("REL_FORM_NUM"));
                param.put("type", "S"); // Sub Form
                param.put("selectedFormNum", (String)gridData.get("REL_FORM_NUM"));
                param.put("isUpdatedFormNum", "false");
                param.put("APAR_TYPE", dataForm.get("APAR_TYPE"));
                param.put("CTRL_USER_ID", dataForm.get("CTRL_USER_ID"));
                //param.put("formContents", null);
                param.put("formContents", (String)gridData.get("FORM_CONTENTS"));
                gridData.put("FORM_CONTENTS", ct0100service.getFormWithManualContractInfo(req, resp, param));
            //}
        }

        Map<String, String> resultMap = ct0300service.doSaveContract(dataForm, gridDataM, gridDataA, gridDataS, gridDataP);
        dataForm.put("CONT_NUM", resultMap.get("CONT_NUM"));
        dataForm.put("CONT_CNT", resultMap.get("CONT_CNT"));


        ct0300service.doSendContract(dataForm);

        resp.setParameter("contNum"  , dataForm.get("CONT_NUM"));
        resp.setParameter("contCnt"  , String.valueOf(dataForm.get("CONT_CNT")));
        resp.setResponseMessage(messageService.getMessageByScreenId("CT0320", "0004")); // 계약서를 전송하셨습니다.
    }

    // 계약서 삭제
    @RequestMapping(value = "/CT0320/doDeleteContract")
    public void doDeleteContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = ct0300service.doDeleteContract(req.getFormData());
        resp.setResponseMessage(rtnMsg);
    }

    // 계약서 서명
    @RequestMapping(value = "/CT0320/doSign")
    public void doSignContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param =new HashMap<String, String>();
    	String scrId=req.getParameter("GUBN");
    	if(scrId.equals("CT0320")) {
    		param=req.getFormData();
    		ct0300service.signContract(param, resp);
    	}else {
    		for(Map<String, Object> info :req.getGridData("grid")) {
    			 param.put("CONT_NUM",String.valueOf(info.get("CONT_NUM")));
    			 param.put("CONT_CNT", String.valueOf(info.get("CONT_CNT")));
    			 ct0300service.signContract(param, resp);
    		}
    	}
    }

    // 계약완료
    @RequestMapping(value = "/CT0320/doFinishContract")
    public void doFinishContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = ct0300service.doFinishContract(req, resp);
        resp.setParameter("contNum", formData.get("CONT_NUM"));
        resp.setParameter("contCnt", String.valueOf(formData.get("CONT_CNT")));
    }
    // 매출일때 협력업체 자동세팅
    @RequestMapping(value = "/CT0320/getVendorCustInformation")
    public void getVendorCustInformation(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = ct0300service.getVendorCustInformation(req, resp);
        resp.setParameter("VENDOR_NM", formData.get("VENDOR_NM"));
        resp.setParameter("VENDOR_CD", String.valueOf(formData.get("VENDOR_CD")));
        resp.setParameter("VENDOR_PIC_CELL_NUM", String.valueOf(formData.get("VENDOR_PIC_CELL_NUM")));
        resp.setParameter("VENDOR_PIC_USER_NM", String.valueOf(formData.get("VENDOR_PIC_USER_NM")));
        resp.setParameter("VENDOR_PIC_EMAIL", String.valueOf(formData.get("VENDOR_PIC_EMAIL")));
    }

    // 계약서 승인
    @RequestMapping(value = "/CT0320/doContAgree")
    public void doContAgree(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();

    	param.put("SIGN_STATUS","E");

        String rtnMsg = ct0300service.setSignAgreeReject(param);
        resp.setResponseMessage(rtnMsg);
    }
    // 계약서 반려
    @RequestMapping(value = "/CT0320/doContReject")
    public void doContReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
    	param.put("SIGN_STATUS","R");

        String rtnMsg = ct0300service.setSignAgreeReject(param);
        resp.setResponseMessage(rtnMsg);
    }
    // 계약서 회수
    @RequestMapping(value = "/CT0320/doSendCancle")
    public void doSendCancle(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();

        String rtnMsg = ct0300service.doSendCancle(param);
        resp.setResponseMessage(rtnMsg);
    }

















}