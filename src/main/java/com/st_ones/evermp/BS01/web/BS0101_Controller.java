package com.st_ones.evermp.BS01.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:24
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS01.service.BS0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BS01/BS0101")
public class BS0101_Controller extends BaseController {

    @Autowired
    BS0101_Service bs0101Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    private MessageService msg;

    /** ****************************************************************************************************************
     * 고객사관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS01_001/view")
    public String BS01_001(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

        String fromDate = EverDate.addMonths(-1);
        String toDate = EverDate.getDate();
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate",toDate);
        return "/evermp/BS01/BS01_001";
    }

    //고객사 조회
    @RequestMapping(value="/bs01001_doSearch")
    public void bs01001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0101Service.bs01001_doSearch(param));
    }

    // 고객사 변경이력 조회
    @RequestMapping(value = "/BS01_001P/view")
    public String BS01_001P(EverHttpRequest req) throws Exception {
        return "/evermp/BS01/BS01_001P";
    }

    // 고객사 변경이력 조회
    @RequestMapping(value="/bs01001p_doSearch")
    public void bs01001p_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0101Service.bs01001p_doSearch(param));
    }

    //고객사 거래정지 또는 거래정지 해제
    @RequestMapping(value="/bs01001_doSuspensionOrTrading")
    public void bs01001_doSuspensionOrTrading(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0101Service.bs01001_doSuspensionOrTrading(req.getGridData("grid"));
    }

    /** ****************************************************************************************************************
     * 고객사 상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS01_002/view")
    public String BS01_002(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>(); // 고객사정보
        Map<String, String> mngUser  = new HashMap<String, String>(); // 고객사담당자정보
        Map<String, String> param = new HashMap<String, String>();

        String custCd = EverString.nullToEmptyString(req.getParameter("CUST_CD"));
        String appDocNum = EverString.nullToEmptyString(req.getParameter("appDocNum"));
        String appDocCnt = EverString.nullToEmptyString(req.getParameter("appDocCnt"));
        //========= 권한 설정 ==============//
        boolean superUserFlag  = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1");
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("B100") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        if( !custCd.equals("") || !appDocNum.equals("")) {

            param.put("CUST_CD", custCd);
            param.put("APP_DOC_NUM", appDocNum);
            param.put("APP_DOC_CNT", appDocCnt);
            formData = bs0101Service.bs01002_doSearchInfo(param);
            param.put("CUST_CD", formData.get("CUST_CD"));
            mngUser  = bs0101Service.bs01002_doSearchUser(param);

            String ctrlStr = userInfo.getCtrlCd();
            String[] ctrlArgs = ctrlStr.split(",");
            for(int i = 0; i < ctrlArgs.length; i++) {
                if ("B100".equals(EverString.replaceAll(ctrlArgs[i], " ", ""))) {
                    havePermission = true;
                }
            }

        } else {
        	formData.put("IPO_FLAG", "0");
        	formData.put("MY_SITE_FLAG", "0");
        	formData.put("PLANT_FLAG", "0");
        	formData.put("BUDGET_USE_FLAG", "0");
        	formData.put("APPROVE_USE_FLAG", "0");
        	formData.put("AUTO_PO_FLAG", "0");
        	formData.put("STOP_FLAG", "0");
        	formData.put("MNG_COM_TAX_YN", "1");
            formData.put("TAX_TYPE", "T1");
            formData.put("COST_CENTER_FLAG", "0");
            /*formData.put("SOURCING_AUTO_PO_FLAG", "0");*/
            formData.put("NEW_COMPANY_FLAG", "0");
            formData.put("PAY_CONDITION", "");
            formData.put("DEPT_PRICE_FLAG", "0");

            mngUser.put("SMS_FLAG", "0");
        	mngUser.put("MAIL_FLAG", "1");
        	mngUser.put("BUDGET_FLAG", "1");
        	mngUser.put("GR_FLAG", "1");
        	mngUser.put("FINANCIAL_FLAG", "1");
        }
        //========= 권한 설정 ==============//

        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));

        Map<String, String> codeParam = new HashMap<String, String>();
        codeParam.put("GATE_CD",  userInfo.getGateCd());
        codeParam.put("BUYER_CD", userInfo.getCompanyCd());
        codeParam.put("CTRL_CD",  "B100");
        req.setAttribute("custMngId", commonComboService.getCodesAsJson("CB0064", codeParam));
        codeParam.put("CTRL_CD",  "P100");
        req.setAttribute("taxMngId", commonComboService.getCodesAsJson("CB0064", codeParam));
        req.setAttribute("regionCd", commonComboService.getCodeCombo("MP005"));
        req.setAttribute("dealType", commonComboService.getCodeCombo("MP042"));
        req.setAttribute("deliberyType", commonComboService.getCodeCombo("MP041"));

        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);
        req.setAttribute("detailView", detailView);

        req.setAttribute("formData", formData);
        req.setAttribute("mngUser", mngUser);

        return "/evermp/BS01/BS01_002";
    }

    /**
     * 사업자등록번호 중복체크
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/bs01002_checkIrsNum")
	public void bs01002_checkIrsNum(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setParameter("POSSIBLE_FLAG", bs0101Service.bs01002_checkIrsNum(req.getFormData()));
	}

    @RequestMapping(value = "/bs01002_checkDupCustUser")
	public void bs01002_checkDupCustUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setParameter("USER_POSSIBLE_FLAG", bs0101Service.bs01002_checkDupCustUser(req.getFormData()));
	}

    //계산서사용자 삭제
    @RequestMapping(value="/bs01002_dodeleteTX")
    public void bs03002_dodeleteTX(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridtxData = req.getGridData("gridtx");
        formData.put("CUST_CD", req.getParameter("CUST_CD"));
        bs0101Service.bs01002_dodeleteTX(formData, gridtxData);
        resp.setResponseMessage(msg.getMessage("0017"));
        resp.setResponseCode("true");
    }


    //고객사 저장
    @RequestMapping(value = "/bs01002_doSave")
    public void bs01002_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> paramMap = req.getFormData();
        Map<String, Object> formData = new HashMap<String, Object>();
        formData.putAll(paramMap);

        List<Map<String, Object>> gridTxDatas = req.getGridData("gridtx");    //계산서사용자
        Map<String, String> rtnMap = bs0101Service.bs01002_doSave(formData, gridTxDatas);

        resp.setResponseMessage(rtnMap.get("rtnMsg"));
        resp.setParameter("CUST_CD", rtnMap.get("CUST_CD"));
    }


    /** ****************************************************************************************************************
     * 고객사 TIER이력 상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS01_005/view")
    public String BS01_005(EverHttpRequest req) throws Exception {
        return "/evermp/BS01/BS01_005";
    }

    //TIER이력 조회
    @RequestMapping(value="/bs01005_doSearch")
    public void bs01005_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0101Service.bs01005_doSearch(param));

    }
    @RequestMapping(value = "/BS01_006/view")
    public String BS01_006(EverHttpRequest req) throws Exception {
        return "/evermp/BS01/BS01_006";
    }

    /** ****************************************************************************************************************
     * 고객사 부서관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS01_004/view")
    public String BS01_004(EverHttpRequest req) throws Exception {
        return "/evermp/BS01/BS01_004";
    }

    //고객사 부서조회(기본 : 사업부)
    @RequestMapping(value="/bs01004_doSearch")
    public void bs01004_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();

        if(!param.get("DEPT_NM").equals("")){
            param.put("DEPT_TYPE", "300");
            resp.setGridObject("gridB", bs0101Service.bs01004_doSearch(param));

            param.put("DEPT_TYPE", "200");
            param.put("STEP2", "Y");
            resp.setGridObject("gridM", bs0101Service.bs01004_doSearch_parent(param));

            param.put("DEPT_TYPE", "100");
            param.put("STEP2", "");
            param.put("STEP1", "Y");
            resp.setGridObject("gridT", bs0101Service.bs01004_doSearch_parent(param));

        }else{
            param.put("DIVISION_YN", "1");
            resp.setGridObject("gridT", bs0101Service.bs01004_doSearch(param));
        }

    }

    //고객사 - 팀조회
    @RequestMapping(value="/bs01004_doSearchM")
    public void bs01004_doSearchM(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("PARENT_DEPT_CD", req.getParameter("PARENT_DEPT_CD"));
        param.put("DEPT_TYPE", "200");

        resp.setGridObject("gridM", bs0101Service.bs01004_doSearch(param));
    }

    //고객사 - 파트조회
    @RequestMapping(value="/bs01004_doSearchB")
    public void bs01004_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("PARENT_DEPT_CD", req.getParameter("PARENT_DEPT_CD"));
        param.put("DEPT_TYPE", "300");

        resp.setGridObject("gridB", bs0101Service.bs01004_doSearch(param));
    }

    //부서 저장
    @RequestMapping(value="/bs01004_doSave")
    public void bs01004_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();

        String radioVal = EverString.nullToEmptyString(req.getParameter("radioVal"));

        List<Map<String, Object>> gridList = null;
        if(radioVal.equals("R1")) { gridList = req.getGridData("gridT"); }
        else if(radioVal.equals("R2")) { gridList = req.getGridData("gridM"); }
        else if(radioVal.equals("R3")) { gridList = req.getGridData("gridB"); }

        String returnMsg = bs0101Service.bs01004_doSave(formData, gridList);

        resp.setResponseMessage(returnMsg);
    }
    /** ****************************************************************************************************************
     * 마감일자 관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS01_003/view")
    public String BS01_003(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();

        Map<String, String> codeParam = new HashMap<String, String>();

        codeParam.put("GATE_CD",  userInfo.getGateCd());
        codeParam.put("BUYER_CD", userInfo.getCompanyCd());
        codeParam.put("CTRL_CD",  "B100");

        req.setAttribute("AM_USER_ID_options", commonComboService.getCodesAsJson("CB0064", codeParam));

        return "/evermp/BS01/BS01_003";
    }

    //계정조회
    @RequestMapping(value="/bs01003_doSearch")
    public void bs01003_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0101Service.bs01003_doSearch(param));

    }

    //마감일자 저장
    @RequestMapping(value="/bs01003_doSave")
    public void bs01003_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0101Service.bs01003_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }


    //마감일자 삭제
    @RequestMapping(value="/bs01003_doDelete")
    public void bs01003_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bs0101Service.bs01003_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }





    @RequestMapping(value="/bs01003_doCheckIrsNo")
    public void bs01003_doCheckIrsNo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        resp.setParameter("POSSIBLE_FLAG", bs0101Service.bs01003_doCheckIrsNo(req.getFormData()));
    }










}