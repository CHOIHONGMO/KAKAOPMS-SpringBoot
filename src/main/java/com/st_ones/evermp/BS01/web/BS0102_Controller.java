package com.st_ones.evermp.BS01.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 07 kkj
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS01.service.BS0102_Service;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BS01/BS0102")
public class BS0102_Controller extends BaseController {

    @Autowired private BS0102_Service bs0102Service;

    @Autowired private CommonComboService commonComboService;

    @Autowired private MessageService messageService;

    /** ****************************************************************************************************************
     * 전결관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS01_010/view")
    public String BS01_010(EverHttpRequest req) throws Exception {

        String custCd = EverString.nullToEmptyString(req.getParameter("CUST_CD"));

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("CUST_CD", (!custCd.equals("") ? custCd : userInfo.getCompanyCd()));

        req.setAttribute("appAgrLineOptions", commonComboService.getCodesAsJson("CB0069", param));
        req.setAttribute("gridAppLinesOptions", commonComboService.getCodesAsJson("CB0069", param));
        req.setAttribute("gridAgrLinesOptions", commonComboService.getCodesAsJson("CB0070", param));
        req.setAttribute("dmlTypeOptions", commonComboService.getCodeComboAsJson("MP028"));
        return "/evermp/BS01/BS01_010";
    }

    // 전결조회
    @RequestMapping(value="/bs01010_doSearch")
    public void bs01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0102Service.bs01010_doSearch(param));
    }

    // 전결저장
    @RequestMapping(value = "/bs01010_doSave")
    public void m99009_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDatas = req.getGridData("grid");
        String returnMsg = bs0102Service.bs01010_doSave(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 결재/합의라인 조회
    @RequestMapping(value="/bs01010_doSearchLineCd")
    public void bs01010_doSearchLineCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
        param.put("DML_TYPE", EverString.nullToEmptyString(req.getParameter("DML_TYPE")));
        resp.setGridObject("gridUR1", bs0102Service.bs01010_doSearchLineCd(param));
    }

    // 결재/합의라인 저장
    @RequestMapping(value = "/bs01010_doSaveLine")
    public void bs01010_doSaveLine(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDatas = req.getGridData("gridUR1");
        String returnMsg = bs0102Service.bs01010_doSaveLine(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 결재/합의라인 삭제
    @RequestMapping(value = "/bs01010_doDelLine")
    public void bs01010_doDelLine(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDatas = req.getGridData("gridUR1");
        String returnMsg = bs0102Service.bs01010_doDelLine(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 결재/합의라인 조회
    @RequestMapping(value="/bs01010_doSearchAppAgr")
    public void bs01010_doSearchAppAgr(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String dmlType = EverString.nullToEmptyString(req.getParameter("DML_TYPE"));

        Map<String, String> param = req.getFormData();
        param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
        param.put("DML_TYPE", dmlType);
        param.put("LINE_CD", EverString.nullToEmptyString(req.getParameter("LINE_CD")));
        resp.setGridObject("gridUR2", bs0102Service.bs01010_doSearchAppAgr(param));
    }

    // 결재/합의라인 저장
    @RequestMapping(value = "/doSaveAppAgr")
    public void doSaveAppAgr(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String dmlType = EverString.nullToEmptyString(req.getParameter("DML_TYPE"));

        Map<String, String> formData = req.getFormData();
        formData.put("DML_TYPE", dmlType);
        formData.put("LINE_CD", EverString.nullToEmptyString(req.getParameter("LINE_CD")));

        List<Map<String, Object>> gridDatas = req.getGridData("gridUR2");
        String returnMsg = bs0102Service.doSaveAppAgr(formData, gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 결재/합의라인 삭제
    @RequestMapping(value = "/bs01010_doDelAppAgr")
    public void bs01010_doDelAppAgr(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String dmlType = EverString.nullToEmptyString(req.getParameter("dmlType"));

        List<Map<String, Object>> gridDatas = req.getGridData("gridUR2");
        String returnMsg = bs0102Service.bs01010_doDelAppAgr(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 참조자조회
    @RequestMapping(value="/bs01010_doSearchUR3")
    public void bs01010_doSearchUR3(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
        param.put("DML_TYPE", EverString.nullToEmptyString(req.getParameter("DML_TYPE")));
        param.put("LINE_CD", EverString.nullToEmptyString(req.getParameter("LINE_CD")));

        resp.setGridObject("gridUR3", bs0102Service.bs01010_doSearchUR3(param));
    }

    // 참조자저장
    @RequestMapping(value = "/bs01010_doSaveREF")
    public void bs01010_doSaveREF(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDatas = req.getGridData("gridUR3");
        String returnMsg = bs0102Service.bs01010_doSaveREF(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 참조자삭제
    @RequestMapping(value = "/bs01010_doDelRef")
    public void bs01010_doDelRef(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridDatas = req.getGridData("gridUR3");
        String returnMsg = bs0102Service.bs01010_doDelRef(gridDatas);
        resp.setResponseMessage(returnMsg);
    }

    // 결재/합의라인 Combo 조회
    @RequestMapping(value = "/bs01010_doSearchCombo")
    public void bs01010_doSearchCombo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        String custCd = EverString.nullToEmptyString(req.getParameter("custCd"));
        Map<String, String> param = new HashMap<String, String>();
        param.put("CUST_CD", (!custCd.equals("") ? custCd : userInfo.getCompanyCd()));

        String dmlTyle = EverString.nullToEmptyString(req.getParameter("dmlTyle"));
        if (dmlTyle.equals("R1")) {
            resp.setParameter("appAgrLine", commonComboService.getCodesAsJson("CB0069", param));
        } else {
            resp.setParameter("appAgrLine", commonComboService.getCodesAsJson("CB0070", param));
        }
    }

    /** ******************************************************************************************
     * 합의/참조자 매핑
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value="/BS01_011/view")
    public String BS01_011(EverHttpRequest req) throws Exception {
        req.setAttribute("refCdLOptions", commonComboService.getCodeComboAsJson("MP029"));
        req.setAttribute("refCdROptions", commonComboService.getCodeComboAsJson("MP031"));
        return "/evermp/BS01/BS01_011";
    }

    @RequestMapping(value = "/bs01011_doSearchL")
    public void m99011_doSearchL(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String gridType = EverString.nullToEmptyString(req.getParameter("gridType"));

        Map<String, String> formData = req.getFormData();
        formData.put("gridType", gridType);
        formData.put("custCd", EverString.nullToEmptyString(formData.get("SET_CUST_CD")));
        resp.setGridObject("grid"+gridType, bs0102Service.bs01011_doSearch(formData));
    }

    @RequestMapping(value = "/bs01011_doSearchR")
    public void m99011_doSearchR(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String gridType = EverString.nullToEmptyString(req.getParameter("gridType"));

        Map<String, String> formData = req.getFormData();
        formData.put("gridType", gridType);
        formData.put("custCd", EverString.nullToEmptyString(formData.get("SET_CUST_CD")));

        resp.setGridObject("grid"+gridType, bs0102Service.bs01011_doSearch(formData));
    }

    @RequestMapping(value = "/bs01011_doSave")
    public void bs01011_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String gridType = req.getParameter("gridType");
        List<Map<String, Object>> gridData = req.getGridData("grid" + gridType);
        bs0102Service.bs01011_doSave(gridData);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    @RequestMapping(value = "/bs01011_doDelete")
    public void bs01011_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String gridType = req.getParameter("gridType");
        List<Map<String, Object>> gridData = req.getGridData("grid" + gridType);
        bs0102Service.bs01011_doDelete(gridData);
        resp.setResponseMessage(messageService.getMessage("0017"));
    }

    /** *****************
     * 운영사 > 관리그룹
     * ******************/
    @RequestMapping(value = "/BS01_020/view")
    public String BS01_020(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BS01/BS01_020";
    }

    @RequestMapping(value="/bs01020_doSearch")
    public void bs01020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01020_doSearch(param));
    }

    @RequestMapping(value="/bs01020_doSearchD")
    public void bym1020_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01020_doSearchD(param));
    }

    @RequestMapping(value = "/bs01020_doSave")
    public void bs01020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01020_doSave(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01020_doDelete")
    public void bs01020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01020_doDelete(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01020_doSaveCust")
    public void bs01020_doCustAdd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01020_doSaveCust(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01020_doDeleteCust")
    public void bs01020_doDeleteCust(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01020_doDeleteCust(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 결재그룹
     * ******************/
    @RequestMapping(value = "/BS01_021/view")
    public String BS01_021(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BS01/BS01_021";
    }

    @RequestMapping(value="/bs01021_doSearch")
    public void bs01021_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01021_doSearch(param));
    }

    @RequestMapping(value="/bs01021_doSearchD")
    public void bym1021_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01021_doSearchD(param));
    }

    @RequestMapping(value = "/bs01021_doSave")
    public void bs01021_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01021_doSave(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01021_doDelete")
    public void bs01021_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01021_doDelete(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01021_doSaveCust")
    public void bs01021_doCustAdd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01021_doSaveCust(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01021_doDeleteCust")
    public void bs01021_doDeleteCust(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01021_doDeleteCust(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 그룹관리자 매핑
     * ******************/
    @RequestMapping(value = "/BS01_022/view")
    public String BS01_022(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BS01/BS01_022";
    }

    @RequestMapping(value="/bs01022_doSearch")
    public void bs01022_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01022_doSearch(param));
    }

    @RequestMapping(value="/bs01022_doSearchD")
    public void bym1022_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01022_doSearchD(param));
    }

    @RequestMapping(value = "/bs01022_doSave")
    public void bs01022_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0102Service.bs01022_doSave(req.getGridData("gridH"));
    }

    @RequestMapping(value = "/bs01022_doDelete")
    public void bs01022_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01022_doDelete(req.getGridData("gridH"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01022_doSaveUser")
    public void bs01022_doUserAdd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01022_doSaveUser(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01022_doDeleteUser")
    public void bs01022_doDeleteUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01022_doDeleteUser(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 고객사별 코스트센터
     * ******************/
    @RequestMapping(value = "/BS01_030/view")
    public String BS01_030(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());
        UserInfo userInfo = UserInfoManager.getUserInfo();
        // 고객사 운영사 관리자 사용메뉴
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS01/BS01_030";
    }

    @RequestMapping(value="/bs01030_doSearch")
    public void bs01030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01030_doSearch(param));
    }

    @RequestMapping(value="/bs01030_doSearchD")
    public void bs01030_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01030_doSearchD(param));
    }

    @RequestMapping(value = "/bs01030_doSaveDT")
    public void bs01030_doSaveDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01030_doSaveDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01030_doDeleteDT")
    public void bs01030_doDeleteDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01030_doDeleteDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 고객사별 플랜트 관리
     * ******************/
    @RequestMapping(value = "/BS01_040/view")
    public String BS01_040(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS01/BS01_040";
    }

    @RequestMapping(value="/bs01040_doSearch")
    public void bs01040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01040_doSearch(param));
    }

    @RequestMapping(value="/bs01040_doSearchD")
    public void bs01040_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01040_doSearchD(param));
    }

    @RequestMapping(value="/bs01040_doSearchPlant")
    public void bs01040_doSearchPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();
        resp.setFormDataObject(bs0102Service.bs01040_doSearchPlant(param));
    }

    @RequestMapping(value="/bs01040_doSavePlantAndAcc")
    public void bs01040_doSavePlantAndAcc(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0102Service.bs01040_doSaveCUPLAndCUBL(req.getFormData());
    }

    @RequestMapping(value="/bs01040_doDeletePlantAndAcc")
    public void bs01040_doDeletePlantAndAcc(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0102Service.bs01040_doDeletePlantAndAcc(req.getFormData());
    }

    @RequestMapping(value = "/bs01040_doSaveDT")
    public void bs01040_doSaveDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01040_doSaveDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01040_doDeleteDT")
    public void bs01040_doDeleteDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01040_doDeleteDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 고객사별 배송지관리
     * ******************/
    @RequestMapping(value = "/BS01_050/view")
    public String BS01_050(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
       // 고객사 운영사 관리자 사용메뉴
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("form", req.getParamDataMap());

        return "/evermp/BS01/BS01_050";
    }

    @RequestMapping(value="/bs01050_doSearch")
    public void bs01050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01050_doSearch(param));
    }

    @RequestMapping(value="/bs01050_doSearchD")
    public void bs01050_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01050_doSearchD(param));
    }

    @RequestMapping(value = "/bs01050_doSaveDT")
    public void bs01050_doSaveDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	String rtnMsg = bs0102Service.bs01050_doSaveDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01050_doDeleteDT")
    public void bs01050_doDeleteDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01050_doDeleteDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 고객사별 청구지관리
     * ******************/
    @RequestMapping(value = "/BS01_060/view")
    public String BS01_060(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());
        UserInfo userInfo = UserInfoManager.getUserInfo();
        // 고객사 운영사 관리자 사용메뉴
        if(!"B".equals(userInfo.getUserType()) && !"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/BS01/BS01_060";
    }
    @RequestMapping(value="/bs01060_doSearch")
    public void bs01060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();

        resp.setGridObject("gridH", bs0102Service.bs01060_doSearch(param));
    }

    @RequestMapping(value="/bs01060_doSearchD")
    public void bs01060_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getParamDataMap();

        resp.setGridObject("gridD", bs0102Service.bs01060_doSearchD(param));
    }

    @RequestMapping(value = "/bs01060_doSaveDT")
    public void bs01060_doSaveDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01060_doSaveDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01060_doDeleteDT")
    public void bs01060_doDeleteDT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = bs0102Service.bs01060_doDeleteDT(req.getGridData("gridD"));

        resp.setResponseMessage(rtnMsg);
    }

    /** *****************
     * 운영사 > 고객사 결재경로관리
     * ******************/
    @RequestMapping(value = "/BS01_080/view")
    public String BS01_080(EverHttpRequest req) throws Exception {

        String custCd = EverString.nullToEmptyString(req.getParameter("CUST_CD"));

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("CUST_CD", (!custCd.equals("") ? custCd : userInfo.getCompanyCd()));

        req.setAttribute("appAgrLineOptions", commonComboService.getCodesAsJson("CB0069", param));
        req.setAttribute("gridAppLinesOptions", commonComboService.getCodesAsJson("CB0069", param));
        req.setAttribute("gridAgrLinesOptions", commonComboService.getCodesAsJson("CB0070", param));
        req.setAttribute("dmlTypeOptions", commonComboService.getCodeComboAsJson("MP028"));
        return "/evermp/BS01/BS01_080";
    }

    @RequestMapping(value="/bs01080_doSearchUser")
    public void bs01080_doSearchUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("APG_FLAG", EverString.nullToEmptyString(req.getParameter("apgFlag")));
        param.put("ALL_FLAG", EverString.nullToEmptyString(req.getParameter("allFlag")));

        resp.setGridObject("gridU", bs0102Service.bs01080_doSearchUser(param));
    }

    @RequestMapping(value = "/bs01080_doSearchPathInfo")
    public void bs01080_doSearchPathInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("PATH_NUM", EverString.nullToEmptyString(req.getParameter("PATH_NUM")));

        Map<String, String> formData = bs0102Service.bs01080_doSearchPathInfo(param);
        resp.setFormDataObject(formData);
    }

    @RequestMapping(value="/bs01080_doSearchPathList")
    public void bs01080_doSearchPathList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridP", bs0102Service.bs01080_doSearchPathList(req.getFormData()));
    }

    @RequestMapping(value = "/bs01080_doSave")
    public void bs01080_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        formData.put("MAIN_PATH_FLAG", EverString.nullToEmptyString(req.getParameter("mainPathFlag")));

        List<Map<String, Object>> gridDatas = req.getGridData("gridP");

        String rtnMsg = bs0102Service.bs01080_doSave(formData, gridDatas);
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/bs01080_doDelete")
    public void bs01080_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridDatas = req.getGridData("gridP");

        String rtnMsg = bs0102Service.bs01080_doDelete(formData, gridDatas);
        resp.setResponseMessage(rtnMsg);
    }

    /**
     * 공통으로 사용하는 결재순서 변경 컨트롤러이므로 프로그램 변경 시 아래의 화면을 모두 테스트해야합니다.
     * - 사용하는 화면: 결재요청팝업, 결재경로관리
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/getRealignmentApprovalList")
    public void approvalHelper(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        String sortType = req.getParameter("sortType");
        List<Map<String, Object>> grid = req.getGridData("gridP");

        if(sortType.equals("up")) {
            int maxSize = grid.size();
            for(int i = maxSize-1; i >= 0; i--) {
                Map<String, Object> currData = grid.get(i);
                String checkFlag = (String)currData.get("CHECK_FLAG");
                if(StringUtils.equals(checkFlag, "1")) {
                    if(i != 0) {
                        Map<String, Object> prevData = grid.get(i-1);
                        String signReqType = StringUtils.defaultIfEmpty((String)prevData.get("SIGN_REQ_TYPE"), "");
                        // 이전의 결재타입이 병렬합의, 병렬결재라면
                        if(signReqType.equals("4") || signReqType.equals("7")) {
                            for(int j = i; j > 0; j--) {

                                if(j-1 >= 0) {
                                    Map<String, Object> beforePrevData = grid.get(j-1);
                                    String beforePrevSignReqType = StringUtils.defaultIfEmpty((String)beforePrevData.get("SIGN_REQ_TYPE"), "");

                                    if(beforePrevSignReqType.equals("4") || beforePrevSignReqType.equals("7")) {
                                        grid.set(j, beforePrevData);
                                        if(j-1 == 0) {
                                            grid.set(j - 1, currData);
                                        }
                                    } else {
                                        grid.set(j, currData);
                                        grid.set(j - 1, beforePrevData);
                                        i = j-1;
                                        break;
                                    }
                                } else {
                                    grid.set(1, grid.get(0));
                                    grid.set(0, currData);
                                    i = j;
                                    break;
                                }

                            }
                        } else {
                            grid.set(i - 1, currData);
                            grid.set(i, prevData);
                            i--;
                            break;
                        }
                    }
                } else {
                    grid.set(i, currData);
                }
            }

        } else if(sortType.equals("down")) {
            int maxSize = grid.size();
            for(int i = 0; i < maxSize; i++) {
                Map<String, Object> currData = grid.get(i);
                String checkFlag = (String)currData.get("CHECK_FLAG");
                if(StringUtils.equals(checkFlag, "1")) {
                    if(i != maxSize-1) {
                        Map<String, Object> prevData = grid.get(i+1);
                        String signReqType = StringUtils.defaultIfEmpty((String)prevData.get("SIGN_REQ_TYPE"), "");
                        // 이전의 결재타입이 병렬합의, 병렬결재라면
                        if(signReqType.equals("4") || signReqType.equals("7")) {
                            for(int j = i; j < maxSize; j++) {

                                if(j+1 < maxSize) {
                                    Map<String, Object> afterNextData = grid.get(j+1);
                                    String beforePrevSignReqType = StringUtils.defaultIfEmpty((String)afterNextData.get("SIGN_REQ_TYPE"), "");

                                    if(beforePrevSignReqType.equals("4") || beforePrevSignReqType.equals("7")) {
                                        grid.set(j, afterNextData);
                                    } else {
                                        grid.set(j, currData);
                                        i = j;
                                        break;
                                    }
                                } else {
                                    grid.set(maxSize - 2, grid.get(maxSize - 1));
                                    grid.set(maxSize - 1, currData);
                                    i = j;
                                    break;
                                }

                            }
                        } else {
                            grid.set(i, prevData);
                            grid.set(i + 1, currData);
                            i++;
                        }
                    }
                } else {
                    grid.set(i, currData);
                }
            }
        }
        resp.setGridObject("gridP", grid);
    }



    @RequestMapping(value = "/BS01_090/view")
    public String BS01_090(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        String fromDate = EverDate.addMonths(-12);
        String toDate = EverDate.getDate();
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate",toDate);
        return "/evermp/BS01/BS01_090";
    }

    @RequestMapping(value = "/BS01_090/doSerach")
    public void bS01_090_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0102Service.bS01_090_doSearch(param));
    }

    @RequestMapping(value = "/BS01_090/doReject")
    public void bS01_090_doReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0102Service.bS01_090_doReject(req.getGridData("grid"));
    }


}