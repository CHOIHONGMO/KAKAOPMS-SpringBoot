package com.st_ones.evermp.IM01.web;

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
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS99.service.BS9901_Service;
import com.st_ones.evermp.IM01.service.IM0101_Service;
import com.st_ones.evermp.IM03.service.IM0301_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM01/IM0101")
public class IM0101_Controller extends BaseController {

    @Autowired IM0101_Service im0101Service;
    @Autowired CommonComboService commonComboService;
    @Autowired FileAttachService fileAttachService;
    @Autowired MessageService messageService;

    @Autowired IM0301_Service im0301Service;
    @Autowired private BS9901_Service bs9901service;

    /** ****************************************************************************************************************
     * 납품지역관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_001/view")
    public String IM01_001(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_001";
    }


    @RequestMapping(value = "/im01001_doSearchHeader")
    public void im01001_doSearchHeader(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("headerG", im0101Service.im01001_doSearchHeader(req.getFormData()));
    }


    @RequestMapping(value = "/im01001_doSearch")
    public void im01001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> headerG = req.getGridData("headerG"); // 조회조건의 창고 list

        resp.setGridObject("grid", im0101Service.im01001_doSearch(formData,headerG));
    }

    //저장
    @RequestMapping(value="/im01001_doSave")
    public void im01001_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("grid");

        String returnMsg = im0101Service.im01001_doSave(param, gridData);
        resp.setResponseMessage(returnMsg);
        resp.setResponseCode("true");
    }


    /** ****************************************************************************************************************
     * 납품지역관리 일괄변경
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_002/view")
    public String IM01_002(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_002";
    }


    //일괄저장
    @RequestMapping(value="/im01002_doSave")
    public void im01002_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("grid");

        String returnMsg = im0101Service.im01002_doSave(param, gridData);
        resp.setResponseMessage(returnMsg);
        resp.setResponseCode("true");
    }

    /** ****************************************************************************************************************
     * 품목현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_070/view")
    public String IM01_070(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

        boolean havePermission = (EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
        req.setAttribute("havePermission", havePermission);

        req.setAttribute("fromDate", EverDate.addMonths(-36));
        req.setAttribute("toDate", EverDate.addMonths(36));

        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/IM01/IM01_070";
    }

    @RequestMapping(value = "/im01070_doSearch")
    public void im01070_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0101Service.im01070_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/im01070_doSave")
    public void im01070_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        String returnMsg = im0101Service.im01070_doSave(gridData);

        resp.setResponseMessage(returnMsg);
    }

    //견적의뢰
    @RequestMapping(value = "/im01070_doEstimate")
    public void im01070_doEstimate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = im0301Service.im03008_doEstimate(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    /** ****************************************************************************************************************
     * 독점품목 상세현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_071/view")
    public String IM01_071(EverHttpRequest req) throws Exception {

        return "/evermp/IM01/IM01_071";
    }
    @RequestMapping(value = "/im01071_doSearch")
    public void im01071_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0101Service.im01071_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 이미지 상세보기_VIEW
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_072/view")
    public String IM01_072(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_072";
    }

    /** ****************************************************************************************************************
     * 수기견적
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_073/view")
    public String IM01_073(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_073";
    }

    /** ****************************************************************************************************************
     * 일괄등록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_060/view")
    public String IM01_060(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();

        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("nowDate", EverDate.getDate());
        req.setAttribute("toDate", EverDate.addDateMonth(EverDate.getDate(), 1));

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자

        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));

        //================== 템플릿 파일 번호 가져오기 ==================
        Map<String, String> tempData = new HashMap<String, String>();
        tempData.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.ITEMPRICE.BULK.key"));
        Map<String, String> tempMap = bs9901service.doSearch_templateFile(tempData);
        req.setAttribute("TEMP_ATT_FILE_NUM", (tempMap!=null&&tempMap.size()>0)?tempMap.get("ATT_FILE_NUM"):"");
        //================== 템플릿 파일 번호 가져오기 ==================

        return "/evermp/IM01/IM01_060";
    }

    //일괄등록_신규상품 벌크정보 조회
    @RequestMapping(value = "/im01060_doSearch")
    public void im01060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridB", im0101Service.im01060_doSearch(req.getFormData()));
    }

    //일괄등록_매입단가 벌크정보 조회
    @RequestMapping(value = "/im01060_doSearchCT")
    public void im01060_doSearchCT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridct", im0101Service.im01060_doSearchCT(req.getFormData()));
    }

    //일괄등록_판매단가 벌크정보 조회
    @RequestMapping(value = "/im01060_doSearchPR")
    public void im01060_doSearchPR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridpr", im0101Service.im01060_doSearchPR(req.getFormData()));
    }

    //일괄등록_이미지 벌크정보 조회
    @RequestMapping(value = "/im01060_doSearchIMG")
    public void im01060_doSearchIMG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridimg", im0101Service.im01060_doSearchIMG(req.getFormData()));
    }

    // 일괄등록_신규상품 저장/유효성검사
    @RequestMapping(value="/im01060_doSave")
    public void im01060_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridB");

        String returnMsg = im0101Service.im01060_doSave(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_매입단가 저장/유효성검사
    @RequestMapping(value="/im01060_doSaveCT")
    public void im01060_doSaveCT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridct");
        String returnMsg = im0101Service.im01060_doSaveCT(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_판매단가 저장/유효성검사
    @RequestMapping(value="/im01060_doSavePR")
    public void im01060_doSavePR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridpr");
        String returnMsg = im0101Service.im01060_doSavePR(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_이미지 저장/유효성검사
    @RequestMapping(value="/im01060_doSaveIMG")
    public void im01060_doSaveIMG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridimg");
        String returnMsg = im0101Service.im01060_doSaveIMG(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_신규상품 벌크삭제
    @RequestMapping(value="/im01060_doDelete")
    public void im01060_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridB");
        String returnMsg = im0101Service.im01060_doDelete(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_매입단가 벌크삭제
    @RequestMapping(value="/im01060_doDeleteCT")
    public void im01060_doDeleteCT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridct");
        String returnMsg = im0101Service.im01060_doDelete(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_판매단가 벌크삭제
    @RequestMapping(value="/im01060_doDeletePR")
    public void im01060_doDeletePR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridpr");
        String returnMsg = im0101Service.im01060_doDelete(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_이미지 벌크삭제
    @RequestMapping(value="/im01060_doDeleteIMG")
    public void im01060_doDeleteIMG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridimg");
        String returnMsg = im0101Service.im01060_doDelete(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    // 일괄등록_신규상품 등록
    @RequestMapping(value="/im01060_doRealSave")
    public void im01060_doRealSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("grid");
        im0101Service.im01060_doRealSave(param, gridList);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    // 일괄등록_매입단가 등록
    @RequestMapping(value="/im01060_doRealSaveCT")
    public void im01060_doRealSaveCT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridct");
        im0101Service.im01060_doRealSaveCT(param, gridList);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    // 일괄등록_판매단가 등록
    @RequestMapping(value="/im01060_doRealSavePR")
    public void im01060_doRealSavePR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridpr");
        im0101Service.im01060_doRealSavePR(param, gridList);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    // 일괄등록_이미지 등록
    @RequestMapping(value="/im01060_doRealSaveIMG")
    public void im01060_doRealSaveIMG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridList = req.getGridData("gridimg");
        im0101Service.im01060_doRealSaveIMG(param, gridList);
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    /**
     * 상품관리 > 계약단가관리 > 상품단가 일괄등록 (IM01_060) : 엑셀 업로드
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/doSetExcelImportItemItem")
    public void doSetExcelImportItemItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridB", im0101Service.doSetExcelImportItem(req.getGridData("gridB")));
    }
}