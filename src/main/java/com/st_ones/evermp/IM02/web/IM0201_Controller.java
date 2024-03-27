package com.st_ones.evermp.IM02.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 8 오후 5:27
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS99.service.BS9901_Service;
import com.st_ones.evermp.IM02.service.IM0201_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM02/IM0201")
public class IM0201_Controller extends BaseController {

    @Autowired private IM0201_Service im0201_Service;
    @Autowired private BS9901_Service bs9901service;

    @Autowired CommonComboService commonComboService;
    @Autowired FileAttachService fileAttachService;
    @Autowired CommonComboService comboService;

    /** *****************
     * 표준납기관
     * ******************/
    @RequestMapping(value = "/IM01_010/view")
    public String IM01_010_View(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

        return "/evermp/IM01/IM01_010";
    }

    @RequestMapping(value = "/im01010_doSearch")
    public void im01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0201_Service.im01010_doSearch(req.getFormData()));
    }

    /** *****************
     * 예산저장
     * ******************/
    @RequestMapping(value="/im01010_doUpdate")
    public void im01010_doUpdate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = im0201_Service.im01010_doUpdate(gridList);
        resp.setResponseMessage(returnMsg);
    }

    /** *****************
     * 품목별 판가관리
     * ******************/
    @RequestMapping(value = "/IM02_010/view")
    public String IM02_010_View(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	req.setAttribute("form", req.getParamDataMap());
        req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("nowDate", EverDate.getDate());
        return "/evermp/IM02/IM02_010";
    }

    @RequestMapping(value="/im02010_doSearch")
    public void im02010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0201_Service.im02010_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/im02010_doModify")
    public void im02010_doModify(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setResponseMessage(im0201_Service.im02010_doModify(req.getGridData("grid")));
    }

    @RequestMapping(value = "/im02010_doDelete")
    public void im02010_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setResponseMessage(im0201_Service.im02010_doDelete(req.getGridData("grid")));
    }

    /** *****************
     * 판가등록
     * ******************/
    @RequestMapping(value = "/IM02_011/view")
    public String IM02_011_View(EverHttpRequest req) throws Exception {

    	//================== 템플릿 파일 번호 가져오기 ==================
        Map<String, String> tempData = new HashMap<String, String>();
        tempData.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.UINFO.key"));
        Map<String, String> tempMap = bs9901service.doSearch_templateFile(tempData);
        req.setAttribute("TEMP_ATT_FILE_NUM", (tempMap!=null&&tempMap.size()>0)?tempMap.get("ATT_FILE_NUM"):"");
        //================== 템플릿 파일 번호 가져오기 ==================

        return "/evermp/IM02/IM02_011";
    }

    @RequestMapping(value="/IM02_011/doSearch")
    public void doSearchChkItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        resp.setGridObject("grid", im0201_Service.doSearchChkItem(req.getGridData("grid")));
    }

    @RequestMapping(value="/im02011_doSearch")
    public void im02011_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", im0201_Service.im02011_doSearch(param));
    }

    @RequestMapping(value="/im02011_doGetPrice")
    public void doGetPrice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("BUYER_CD", req.getParameter("BUYER_CD"));
        param.put("ITEM_CD", req.getParameter("ITEM_CD"));
        param.put("CONT_NO", req.getParameter("CONT_NO"));
        param.put("CONT_SEQ", req.getParameter("CONT_SEQ"));


        Map<String, Object> rtnMap = im0201_Service.doGetPrice(param);

        if(rtnMap != null) {
            resp.setParameter("CONT_UNIT_PRICE", String.valueOf(rtnMap.get("CONT_UNIT_PRICE")));
            resp.setParameter("UNIT_PRICE", String.valueOf(rtnMap.get("UNIT_PRICE")));
            resp.setParameter("CUR", String.valueOf(rtnMap.get("CUR")));
            resp.setParameter("TIER_CD", String.valueOf(rtnMap.get("TIER_CD")));
            resp.setParameter("MOQ_QTY", String.valueOf(rtnMap.get("MOQ_QTY")));
            resp.setParameter("RV_QTY", String.valueOf(rtnMap.get("RV_QTY")));
            resp.setParameter("LEAD_TIME", String.valueOf(rtnMap.get("LEAD_TIME")));
            resp.setParameter("LEAD_TIME_DATE", String.valueOf(rtnMap.get("LEAD_TIME_DATE")));
            resp.setParameter("VENDOR_CD", String.valueOf(rtnMap.get("VENDOR_CD")));
            resp.setParameter("VENDOR_NM", String.valueOf(rtnMap.get("VENDOR_NM")));
            resp.setParameter("APPLY_COM", String.valueOf(rtnMap.get("APPLY_COM")));
            resp.setParameter("CONT_NO", String.valueOf(rtnMap.get("CONT_NO")));
            resp.setParameter("CONT_SEQ", String.valueOf(rtnMap.get("CONT_SEQ")));
            resp.setParameter("DEAL_CD", String.valueOf(rtnMap.get("DEAL_CD")));
            resp.setParameter("TAX_CD", String.valueOf(rtnMap.get("TAX_CD")));
            resp.setParameter("VENDOR_ITEM_CD", EverString.nullToEmptyString(rtnMap.get("VENDOR_ITEM_CD")));
        }
    }

    @RequestMapping(value = "/im02011_doSave")
    public void im02011_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setResponseMessage(im0201_Service.im02011_doSave(param, req.getGridData("grid")));
    }

    /**
     * 상품관리 > 계약단가관리 > 고객판가 관리 (IM02_010) > 고객판가일괄등록 (IM02_011) : 엑셀 업로드
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/doSetExcelImportItemUinfo")
    public void doSetExcelImportItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0201_Service.doSetExcelImportUinfo(req.getGridData("grid")));
    }

    /** *****************
     * 품목검색
     * ******************/
    @RequestMapping(value = "/IM02_012/view")
    public String IM02_012_View(EverHttpRequest req,EverHttpResponse resp) throws Exception {
    	Map<String, Object> data = new HashMap<>();

    	data.put("PR_BUYER_CD",req.getParameter("PR_BUYER_CD"));
    	data.put("PR_PLANT_CD",req.getParameter("PR_PLANT_CD"));
    	req.setAttribute("formData", data);
        return "/evermp/IM02/IM02_012";
    }

    @RequestMapping(value="/im02012_doSearch")
    public void im02012_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        String STD_FLAG	   = req.getParameter("STD_FLAG");
        String PR_BUYER_CD = req.getParameter("PR_BUYER_CD");
        String PR_PLANT_CD = req.getParameter("PR_PLANT_CD");

        param.put("STD_FLAG", STD_FLAG);
        param.put("PR_BUYER_CD", PR_BUYER_CD);
        param.put("PR_PLANT_CD", PR_PLANT_CD);

        resp.setGridObject("grid", im0201_Service.im02012_doSearch(param));
    }

    /** *****************
     * 분류체계별관리
     * ******************/
    @RequestMapping(value = "/IM02_020/view")
    public String IM02_020_View(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfoImpl();
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        req.setAttribute("itemClass1Options", comboService.getCodesAsJson("CB0056", param));
        return "/evermp/IM02/IM02_020";
    }

    @RequestMapping(value = "/getMakerOptions")
    public void getMakerOptions(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfoImpl();
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("ITEM_CLS1", req.getParameter("ITEM_CLASS1"));

        resp.setParameter("makerOptions", comboService.getCodesAsJson("CB0057", param));
    }

    @RequestMapping(value="/im02020_doSearch")
    public void im02020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0201_Service.im02020_doSearch(req.getFormData()));
    }

    /** *****************
     * 분류체계별 이력
     * ******************/
    @RequestMapping(value = "/IM02_021/view")
    public String IM02_021_View(EverHttpRequest req) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("TIER_CD", req.getParameter("TIER_CD"));
        param.put("ITEM_CLS1", req.getParameter("ITEM_CLS1"));
        param.put("ITEM_CLS2", req.getParameter("ITEM_CLS2"));
        req.setAttribute("labelString", im0201_Service.getLabel(param));
        return "/evermp/IM02/IM02_021";
    }

    @RequestMapping(value="/im02021_doSearch")
    public void im02021_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("ITEM_CLS1", req.getParameter("ITEM_CLS1"));
        param.put("ITEM_CLS2", req.getParameter("ITEM_CLS2"));
        param.put("ITEM_CLS3", req.getParameter("ITEM_CLS3"));
        param.put("ITEM_CLS4", req.getParameter("ITEM_CLS4"));
        param.put("TIER_CD", req.getParameter("TIER_CD"));
        resp.setGridObject("grid", im0201_Service.im02021_doSearch(param));
    }

    /** *****************
     * 분류체계별 수정
     * ******************/
    @RequestMapping(value = "/IM02_022/view")
    public String IM02_022_View(EverHttpRequest req) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("ITEM_CLS1", req.getParameter("ITEM_CLS1"));
        param.put("ITEM_CLS2", req.getParameter("ITEM_CLS2"));
        param.put("TIER_CD", req.getParameter("TIER_CD"));
        req.setAttribute("itemClassNm", im0201_Service.getLabel(param));
        return "/evermp/IM02/IM02_022";
    }

    @RequestMapping(value="/im02022_doSearch")
    public void im02022_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("ITEM_CLS1", req.getParameter("ITEM_CLS1"));
        param.put("ITEM_CLS2", req.getParameter("ITEM_CLS2"));
        param.put("ITEM_CLS3", req.getParameter("ITEM_CLS3"));
        param.put("ITEM_CLS4", req.getParameter("ITEM_CLS4"));
        param.put("TIER_CD", req.getParameter("TIER_CD"));
        resp.setGridObject("grid", im0201_Service.im02022_doSearch(param));
    }

    @RequestMapping(value = "/im02022_doSave")
    public void im02022_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setResponseMessage(im0201_Service.im02022_doSave(req.getGridData("grid")));
    }

    /** *****************
     * 분류체계별관리 신규등록
     * ******************/
    @RequestMapping(value = "/IM02_023/view")
    public String IM02_023_View(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfoImpl();

        Map<String, String> param = new HashMap<String, String>();
        param.put("ITEM_CLS1", req.getParameter("ITEM_CLS1"));
        param.put("ITEM_CLS2", req.getParameter("ITEM_CLS2"));
        param.put("TIER_CD", req.getParameter("TIER_CD"));

        Map<String, String> formData = im0201_Service.im02023_doSearchData(param);
        formData.put("ITEM_CLS1", req.getParameter("ITEM_CLS1"));
        formData.put("ITEM_CLS2", req.getParameter("ITEM_CLS2"));
        formData.put("ITEM_CLS3", req.getParameter("ITEM_CLS3"));
        formData.put("ITEM_CLS4", req.getParameter("ITEM_CLS4"));
        formData.put("TIER_CD", req.getParameter("TIER_CD"));
        formData.put("REG_USER_ID", userInfo.getUserId());
        formData.put("REG_USER_NM", userInfo.getUserNm());
        formData.put("REQ_USER_ID", userInfo.getUserId());
        formData.put("REQ_USER_NM", userInfo.getUserNm());

        req.setAttribute("formData", formData);
        return "/evermp/IM02/IM02_023";
    }

    @RequestMapping(value = "/im02023_doSave")
    public void im02023_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setResponseMessage(im0201_Service.im02023_doSave(req.getFormData()));
    }

    /** *****************
     * 품목 판가관리 이력
     * ******************/
    @RequestMapping(value = "/IM02_013/view")
    public String IM02_013_View(EverHttpRequest req) throws Exception {
        return "/evermp/IM02/IM02_013";
    }

    @RequestMapping(value="/im02013_doSearch")
    public void im02013_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0201_Service.im02013_doSearch(req.getFormData()));
    }






    @RequestMapping(value = "/block")
    public void block(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setResponseMessage(im0201_Service.block(req.getGridData("grid")));
    }

    @RequestMapping(value = "/blockCancel")
    public void blockCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setResponseMessage(im0201_Service.blockCancel(req.getGridData("grid")));
    }


}
