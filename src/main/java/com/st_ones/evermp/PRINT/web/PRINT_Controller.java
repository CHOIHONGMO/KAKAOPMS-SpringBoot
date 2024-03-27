package com.st_ones.evermp.PRINT.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.PRINT.service.PRINT_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.*;

@Controller
@RequestMapping(value = "/evermp/print")
public class PRINT_Controller extends BaseController {

    @Autowired
    private PRINT_Service print_service;

    /**
     * 공급사 거래명세서
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PRT_040/view")
    public String PRT_040(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String printListString = req.getParameter("printList"); //Invoice JSON list

        Map<String, Object> param = new HashMap<String, Object>();
//        param.put("printList", new ObjectMapper().readValue(printListString, List.class));

    	String IF_INVC_CD = req.getParameter("IF_INVC_CD"); //Invoice JSON list
    	param.put("IF_INVC_CD", IF_INVC_CD);



        param.put("SCREEN_ID", "PRT_040");

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));

        return "/evermp/PRINT/PRT_040";
    }

    /**
     * 고객사사 거래명세서
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PRT_041/view")
    public String PRT_041(EverHttpRequest req) throws Exception {
        String printListString = req.getParameter("printList"); //Invoice JSON list

        Map<String, Object> param = new HashMap<String, Object>();
//        param.put("printList", new ObjectMapper().readValue(printListString, List.class));

    	String IF_INVC_CD = req.getParameter("IF_INVC_CD"); //Invoice JSON list
    	param.put("IF_INVC_CD", IF_INVC_CD);


        param.put("SCREEN_ID", "PRT_041");

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));

        return "/evermp/PRINT/PRT_041";
    }
    /**
     * 고객사사 거래명세서
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PRT_042/view")
    public String PRT_042(EverHttpRequest req) throws Exception {
    	String IF_INVC_CD = req.getParameter("IF_INVC_CD"); //Invoice JSON list

    	Map<String, Object> param = new HashMap<String, Object>();

    	param.put("SCREEN_ID", "PRT_042");
    	param.put("IF_INVC_CD", IF_INVC_CD);

    	ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
    	req.setAttribute("printData", EverConverter.getJsonString(printData));

    	return "/evermp/PRINT/PRT_041";
    }

    /**
     * 고객사 > 주문관리 > 주문조회/수정 > 주문서 출력
     */
    @RequestMapping(value = "/PRT_030/view")
    public String PRT_030(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("CPO_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("CPO_LIST"), List.class));
        param.put("SCREEN_ID", "PRT_030");

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_030";
    }

    /**
     * 공급사 > 납품관리 > 납품서생성 > 발주서 출력
     */
    @RequestMapping(value = "/PRT_031/view")
    public String PRT_031(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("PO_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("PO_LIST"), List.class));
        param.put("SCREEN_ID", "PRT_031");

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_031";
    }

    /**
     * 공급사 > 견적/계약관리 > 계약관리
     */
    @RequestMapping(value = "/PRT_020/view")
    public String PRT_020(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        param.put("VENDOR_CD", userInfo.getCompanyCd());
        param.put("SCREEN_ID", "PRT_020");
        param.put("RFQ_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("RFQ_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_020";
    }

    /**
     * 운영사 > 소싱관리 > 견적비교
     */
    @RequestMapping(value = "/PRT_021/view")
    public String PRT_021(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("SCREEN_ID", "PRT_021");
        param.put("RFQ_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("RFQ_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_021";
    }

    /**
     * 운영사 > 품목현황 > 수기견적
     */
    @RequestMapping(value = "/PRT_022/view")
    public String PRT_022(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("SCREEN_ID", "PRT_022");
        param.put("ITEM_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("ITEM_LIST"), List.class));
        param.put("CUST_NM", EverString.nullToEmptyString(req.getParameter("CUST_NM")));
        param.put("REC_USER_NM", EverString.nullToEmptyString(req.getParameter("REC_USER_NM")));
        param.put("DEPT_NM", EverString.nullToEmptyString(req.getParameter("DEPT_NM")));
        param.put("POSITION_NM", EverString.nullToEmptyString(req.getParameter("POSITION_NM")));
        param.put("TEL_NUM", EverString.nullToEmptyString(req.getParameter("TEL_NUM")));
        param.put("FAX_NUM", EverString.nullToEmptyString(req.getParameter("FAX_NUM")));
        param.put("EMAIL", EverString.nullToEmptyString(req.getParameter("EMAIL")));
        param.put("REMARK", EverString.nullToEmptyString(req.getParameter("REMARK")));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlDirectInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));

        return "/evermp/PRINT/PRT_022";
    }

    /**
     * 운영사 > 소싱관리 > 견적의뢰 현황
     */
    @RequestMapping(value = "/PRT_010/view")
    public String PRT_010(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("SCREEN_ID", "PRT_010");
        param.put("RFQ_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("RFQ_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_010";
    }

    /**
     * 지표관리 Report
     *
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/PRT_050/view")
    public String PRT_050(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>(req.getParamDataMap());

        String date = req.getParameter("CPO_START_DATE");
        String year = date.substring(0, 4);
        String month = date.substring(4, 6);

        String prev_date = EverDate.addDateMonth(year + month, -1);
        String prev_year = prev_date.substring(0, 4);
        String prev_month = prev_date.substring(4, 6);

        param.put("PREV_START_DATE", prev_year + prev_month + "01");
        param.put("PREV_END_DATE", EverDate.getLastDayofMonth(prev_year + prev_month));
        param.put("START_DATE", year + month + "01");
        param.put("END_DATE", EverDate.getLastDayofMonth(year + month));

        param.put("SCREEN_ID", "PRT_050");
        param.put("CUST_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("CUST_LIST"), List.class));
        param.put("CUST_NM_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("CUST_NM_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        req.setAttribute("YEAR", year);
        req.setAttribute("MONTH", month);
        req.setAttribute("START_DATE", year + month + "01");
        req.setAttribute("END_DATE", EverDate.getLastDayofMonth(year + month));

        return "/evermp/PRINT/PRT_050";
    }

    @RequestMapping(value = "/PRT_060/view")
    public String PRT_060(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>(req.getParamDataMap());
        param.put("SCREEN_ID", "PRT_060");
        param.put("TAX_NUM_LIST", Arrays.asList(EverString.nullToEmptyString(req.getParamDataMap().get("TAX_NUM")).split(",")));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));

        return "/evermp/PRINT/PRT_060";
    }














    @RequestMapping(value = "/PRT_070/view")
    public String PRT_070(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("SCREEN_ID", "PRT_070");
        param.put("RFQ_LIST", EverConverter.readJsonObject(req.getParamDataMap().get("RFQ_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_070";
    }






    @RequestMapping(value = "/PRT_090/view")
    public String PRT_090(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("SCREEN_ID", "PRT_090");

        param.put("printList", new ObjectMapper().readValue(req.getParamDataMap().get("TAX_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_090";
    }

    @RequestMapping(value = "/PRT_091/view")
    public String PRT_091(EverHttpRequest req) throws Exception {
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("SCREEN_ID", "PRT_091");
        param.put("printList", new ObjectMapper().readValue(req.getParamDataMap().get("TAX_LIST"), List.class));

        ArrayList<ArrayList<Map<String, Object>>> printData = print_service.printHtmlInvoice(param);
        req.setAttribute("printData", EverConverter.getJsonString(printData));
        return "/evermp/PRINT/PRT_091";
    }







}