package com.st_ones.evermp.IM03.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM03.service.IM0301_Service;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/IM03/IM0301")
public class IM0301_Controller extends BaseController {

    @Autowired
    IM0301_Service im0301Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;
    @Autowired
    LargeTextService largeTextService;
    /** ****************************************************************************************************************
     * 제조사/브랜드 현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_007/view")
    public String IM03_007(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        return "/evermp/IM03/IM03_007";
    }

    @RequestMapping(value = "/IM03_007/im03007_doSearch")
    public void im03007_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.im03007_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/IM03_007/im03007_doSave")
    public void im03007_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        im0301Service.im03007_doSave(gridData);

        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    /** ****************************************************************************************************************
     * Item Master
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_008/view")
    public String IM03_008(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();

    	req.setAttribute("oneMonthAgo", EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.getDate());

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자

    	req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        return "/evermp/IM03/IM03_008";
    }

    @RequestMapping(value = "/IM03_008/im03008_doSearch")
    public void im03008_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.im03008_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/IM03_008/im03008_doSave")
    public void im03008_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        im0301Service.im03008_doSave(gridData);

        resp.setResponseMessage(messageService.getMessage("0031"));
    }


    @RequestMapping(value = "/IM03_008/im03008_doEstimate")
    public void im03008_doEstimate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        im0301Service.im03008_doEstimate(gridData);

        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    //분류에 맞는 sg 조회
    @RequestMapping(value="/setSgData")
    public void setSgData(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("ITEM_CLS1",req.getParameter("ITEM_CLS1"));
        param.put("ITEM_CLS2",req.getParameter("ITEM_CLS2"));
        param.put("ITEM_CLS3",req.getParameter("ITEM_CLS3"));
        param.put("ITEM_CLS4",req.getParameter("ITEM_CLS4"));

        Map<String, Object> formData = im0301Service.setSgData(param);
        String listJson = new ObjectMapper().writeValueAsString(formData);
        resp.setParameter("sgDatas", listJson);
    }

    //판촉분류에 맞는 sg 조회
    @RequestMapping(value="/setDPSgData")
    public void setDPSgData(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("PT_ITEM_CLS1",req.getParameter("PT_ITEM_CLS1"));
        param.put("PT_ITEM_CLS2",req.getParameter("PT_ITEM_CLS2"));
        param.put("PT_ITEM_CLS3",req.getParameter("PT_ITEM_CLS3"));

        Map<String, Object> formData = im0301Service.setDPSgData(param);
        String listJson = new ObjectMapper().writeValueAsString(formData);
        resp.setParameter("dpsgDatas", listJson);
    }

    /** ****************************************************************************************************************
     * Item Master (공급사 품목코드 팝업)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_008P/view")
    public String IM03_008P(EverHttpRequest req) throws Exception {
        return "/evermp/IM03/IM03_008P";
    }

    @RequestMapping(value = "/IM03_008P/im03008P_doSearch")
    public void im03008P_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.im03008P_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/IM03_008P/im03008P_doSave")
    public void im03008P_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        im0301Service.im03008P_doSave(req.getFormData(), req.getGridData("grid"));
        resp.setResponseMessage(messageService.getMessage("0031"));
    }

    @RequestMapping(value = "/IM03_008P/im03008P_doDelete")
    public void im03008P_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        im0301Service.im03008P_doDelete(req.getFormData(), req.getGridData("grid"));
        resp.setResponseMessage(messageService.getMessage("0017"));
    }

    /** ****************************************************************************************************************
     * 구매사품목코드 매핑
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_020/view")
    public String IM01_020_view(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_020";
    }

    @RequestMapping(value = "/im01020_doSearch")
    public void im01020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.im01020_doSearch(req.getFormData()));
    }

    //저장
    @RequestMapping(value="/im01020_doSave")
    public void im01020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("grid");

        String returnMsg = im0301Service.im01020_doSave(param, gridData);
        resp.setResponseMessage(returnMsg);
        resp.setResponseCode("true");
    }

    //삭제
    @RequestMapping(value="/im01020_doDelete")
    public void im01020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        List<Map<String, Object>> gridData = req.getGridData("grid");
        String returnMsg = im0301Service.im01020_doDelete(param, gridData);
        resp.setResponseMessage(returnMsg);
        resp.setResponseCode("true");
    }

    /** ****************************************************************************************************************
     * 구매사품목코드 변경이력
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM01_021/view")
    public String IM01_021_view(EverHttpRequest req) throws Exception {
        return "/evermp/IM01/IM01_021";
    }

    @RequestMapping(value = "/im01021_doSearch")
    public void im01021_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.im01021_doSearch(req.getFormData()));
    }


    /** ****************************************************************************************************************
     * 품목등록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_009/view")
    public String IM03_009(HttpServletRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();

//        if(!"1".equals(userInfo.getSuperUserFlag())) {
//        	return "/eversrm/noSuperAuth";
//        }
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("cmsUserOptions", commonComboService.getCodesAsJson("CB0064", param));
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0094", param));

        String itemCd = EverString.nullToEmptyString(req.getParameter("ITEM_CD"));
        String rpNo = EverString.nullToEmptyString(req.getParameter("RP_NO"));

        //결재번호_계약의단가정보변경시
        String appDocNum = EverString.nullToEmptyString(req.getParameter("APP_DOC_NUM"));
        String appDocCnt = EverString.nullToEmptyString(req.getParameter("APP_DOC_CNT"));
        if(!itemCd.equals("")) {
            param.put("ITEM_CD", itemCd);
            formData = im0301Service.im03009_doSearchInfo(param);
            String largeTextNum = formData.get("ITEM_DETAIL_TEXT_NUM");
            if(StringUtils.isNotEmpty(largeTextNum)) {
                req.setAttribute("TEXT_CONTENTS", largeTextService.selectLargeText(largeTextNum));
            }
        }else{
            if(!rpNo.equals("")) {
                param.put("RP_NO", rpNo);
                param.put("RP_SEQ", EverString.nullToEmptyString(req.getParameter("RP_SEQ")));
                param.put("RP_VENDOR_CD", EverString.nullToEmptyString(req.getParameter("RP_VENDOR_CD")));
                formData = im0301Service.im03009_doSearchInfo_RP(param);
                String largeTextNum = formData.get("ITEM_DETAIL_TEXT_NUM");
                if(StringUtils.isNotEmpty(largeTextNum)) {
                    req.setAttribute("TEXT_CONTENTS", largeTextService.selectLargeText(largeTextNum));
                }
            }else{
                if(!appDocNum.equals("")) {

                    param.put("APP_DOC_NUM", appDocNum);
                    param.put("APP_DOC_CNT", appDocCnt);
                    formData = im0301Service.im03009_doSearch_app_Info(param);
                    String largeTextNum = "";
                    if(formData != null) { largeTextNum = formData.get("ITEM_DETAIL_TEXT_NUM"); }
                    if(StringUtils.isNotEmpty(largeTextNum) || !largeTextNum.equals("")) {
                        req.setAttribute("TEXT_CONTENTS", largeTextService.selectLargeText(largeTextNum));
                    }
                }
                else {
                	formData.put("TEMP_CD_FLAG","0");
                	formData.put("STD_FLAG","0");
                	formData.put("ORIGIN_CD","KR");
                	formData.put("UNIT_CD","EA");
                	formData.put("ITEM_STATUS","10");
                }
            }
        }
        req.setAttribute("today", EverDate.getDate());
        req.setAttribute("formData", formData);

        return "/evermp/IM03/IM03_009";
    }


    @RequestMapping(value = "/im03009_doSearch_CT")
    public void im03009_doSearch_CT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridct", im0301Service.im03009_doSearch_CT(req.getFormData()));
    }

    @RequestMapping(value = "/im03009_doSearchRP_CT")
    public void im03009_doSearchRP_CT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridct", im0301Service.im03009_doSearchRP_CT(req.getFormData()));
    }

    @RequestMapping(value = "/im03009_doSearch_PR")
    public void im03009_doSearch_PR(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridpr", im0301Service.im03009_doSearch_PR(req.getFormData()));
    }

    @RequestMapping(value = "/im03009_doSearch_AT")
    public void im03009_doSearch_AT(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridat", im0301Service.im03009_doSearch_AT(req.getFormData()));
    }

    @RequestMapping(value = "/im03009_doSearch_NmgCust")
    public void im03009_doSearch_NmgCust(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridct", im0301Service.im03009_doSearch_NmgCust(req.getFormData()));
    }




    //품목 저장
    @RequestMapping(value = "/im03009_doSave")
    public void im03009_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        formData.put("MAIN_IMG_SQ", req.getParameter("mainImgSq"));
        formData.put("signStatus", EverString.nullToEmptyString(req.getParameter("signStatus")));

        List<Map<String, Object>> gridDataCt = req.getGridData("gridct"); // 계약정보
        List<Map<String, Object>> gridDataAt = req.getGridData("gridat"); // 품목규격

        Map<String, String> rtnMap = im0301Service.im03009_doSave(formData, gridDataCt, gridDataAt);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
        resp.setParameter("ITEM_CD", rtnMap.get("ITEM_CD"));
    }

    //품목_계약정보 삭제
    @RequestMapping(value = "/im03009_doDeletegridct")
    public void im03009_doDeletegridct(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        im0301Service.im03009_doDeletegridct(req.getFormData(), req.getGridData("gridct"));
        resp.setResponseMessage(messageService.getMessage("0017"));
    }

    //품목_단가정보 삭제
    @RequestMapping(value = "/im03009_doDeletegridpr")
    public void im03009_doDeletegridpr(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        im0301Service.im03009_doDeletegridpr(req.getFormData(), req.getGridData("gridpr"));
        resp.setResponseMessage(messageService.getMessage("0017"));
    }

    /** ****************************************************************************************************************
     * 품목등록_VIEW화면
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_014/view")
    public String IM03_014(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();

        //운영사일경우
        boolean havePermission = EverString.nullToEmptyString(userInfo.getUserType()).equals("C");

        String splitString ="";
        String itemCd = EverString.nullToEmptyString(req.getParameter("ITEM_CD"));
        String contNo = EverString.nullToEmptyString(req.getParameter("CONT_NO"));
        boolean cartYn = Boolean.parseBoolean(req.getParameter("CART_YN"));
        if(!itemCd.equals("")) {
            param.put("ITEM_CD", itemCd);

            if(!contNo.equals("")&&cartYn==true) {
                param.put("APPLY_COM", EverString.nullToEmptyString(req.getParameter("APPLY_COM")));
                param.put("CUST_CD", EverString.nullToEmptyString(req.getParameter("CUST_CD")));
                param.put("CONT_NO", contNo);
                param.put("CONT_SEQ", EverString.nullToEmptyString(req.getParameter("CONT_SEQ")));
                formData = im0301Service.im03014_doSearchInfo_doCart(param);
            }else{
                formData = im0301Service.im03009_doSearchInfo(param);
            }

            // 상세품목이미지
            if(StringUtils.isNotEmpty(formData.get("ITEM_DETAIL_FILE_NUM"))) {
                Map<String, String> detailImgInfo = im0301Service.im03014_detailImgInfo(formData);
                if(detailImgInfo!=null){
                	req.setAttribute("ITEM_DETAIL_FILE_PATH", "/common/file/fileAttach/download.so?UUID=" + detailImgInfo.get("UUID") + "&UUID_SQ=" + detailImgInfo.get("UUID_SQ"));
                }
            }else { //상품상세이미지 없으면 메인이미지가 상세이미지로 대체
            	 Map<String, String> detailImgInfo = im0301Service.im03014_detailImgInfo2(formData);
                 if(detailImgInfo!=null){
                 	req.setAttribute("ITEM_DETAIL_FILE_PATH", "/common/file/fileAttach/download.so?UUID=" + detailImgInfo.get("UUID") + "&UUID_SQ=" + detailImgInfo.get("UUID_SQ"));
                 }
            }

            String largeTextNum = formData.get("ITEM_DETAIL_TEXT_NUM");
            if(StringUtils.isNotEmpty(largeTextNum)) {
                splitString = largeTextService.selectLargeText(formData.get("ITEM_DETAIL_TEXT_NUM"));
            }
        }

        req.setAttribute("TEXT_CONTENTS", splitString);
        req.setAttribute("havePermission", havePermission);
        req.setAttribute("formData", formData);

        return "/evermp/IM03/IM03_014";
    }













    /** *****************
     * 품목상세 > 카트담기, 관심품목담기
     * ******************/
    //카트담기
    @RequestMapping(value = "/im03014_doSaveCart")
    public void im03014_doSaveCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        Map<String, String> rtnMap = im0301Service.im03014_doSaveCart(formData);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));

    }
    //관심품목담기
//    @RequestMapping(value = "/im03014_openConCart")
//    public void im03014_openConCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {
//
//        Map<String, String> formData = req.getFormData();
//        Map<String, String> rtnMap = im0301Service.im03014_openConCart(formData);
//        resp.setResponseMessage(rtnMap.get("rtnMsg"));
//
//    }


    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수
     * ******************/
    @RequestMapping(value = "/IM03_010/view")
    public String IM03_010(EverHttpRequest req) throws Exception {
        Map<String, String> param = new HashMap<String, String>();

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("ADD_FROM_DATE", EverDate.addDateMonth(EverDate.getDate(), -3));
        req.setAttribute("ADD_TO_DATE", EverDate.getDate());

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("CMS_CTRL_USER_ID_Options", commonComboService.getCodesAsJson("CB0064", param));

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //표준화 및 품목 담당자
        req.setAttribute("SG_CTRL_USER_ID_Options", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/IM03/IM03_010";
    }

    @RequestMapping(value = "/im03010_doSearch")
    public void im03010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.im03010_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/im03010_doSave")
    public void im03010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> rtnMap = im0301Service.im03010_doSave(req.getGridData("grid"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/im03010_doAssigmnent")
    public void im03010_doAssigmnent(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> rtnMap = im0301Service.im03010_doAssigmnent(req.getGridData("grid"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/im03010_doItemMapping")
    public void im03010_doItemMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> grid = req.getGridData("grid");

        Map<String, String> rtnMap = im0301Service.im03010_doItemMapping(grid);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    // 고객사 신규품목코드 할당정보 회신
    @RequestMapping(value = "/im03010_doReply")
    public void im03010_doReply(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> grid = req.getGridData("grid");

        Map<String, String> rtnMap = im0301Service.im03010_doReply(grid);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/im03010_doReRequest")
    public void im03010_doReRequest(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> grid = req.getGridData("grid");

        Map<String, String> rtnMap = im0301Service.im03010_doReRequest(grid);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/im03010_doNotStandardization")
    public void im03010_doNotStandardization(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> grid = req.getGridData("grid");

        Map<String, String> rtnMap = im0301Service.im03010_doNotStandardization(grid);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value = "/im03010_doDelete")
    public void im03010_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> grid = req.getGridData("grid");

        Map<String, String> rtnMap = im0301Service.im03010_doDelete(grid);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수 > 표준화 팝업
     * ******************/
    @RequestMapping(value = "/IM03_015/view")
    public String IM03_015(EverHttpRequest req) throws Exception {

        Map<String, Object> data = new HashMap<String, Object>();
        Map<String, String> param = req.getParamDataMap();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
        List<Map<String, Object>> list = im0301Service.im03010_doSearch(param);

        if(list != null && list.size() > 0 ) {
            data = list.get(0);
        }

        if(data.get("VAT_CD") == null) {
            data.put("VAT_CD", "T1");
        }
        req.setAttribute("DATA", data);

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("MTGL_CMS_CTRL_USER_ID_options", commonComboService.getCodesAsJson("CB0064", param));
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("MTGL_SG_CTRL_USER_ID_options", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/IM03/IM03_015";
    }

    @RequestMapping(value = "/im03015_doSave")
    public void im03015_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        String MAIN_IMG_SQ = req.getParameter("mainImgSq");

        formData.put("MAIN_IMG_SQ", MAIN_IMG_SQ);

        List<Map<String, Object>> gridDataAt = req.getGridData("gridat"); // 품목규격


        Map<String, String> rtnMap = im0301Service.im03015_doSave(formData, gridDataAt);

        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수 > 신규요청등록 팝업
     * ******************/
    @RequestMapping(value = "/IM03_016/view")
    public String IM03_016(EverHttpRequest req) throws Exception {

        req.setAttribute("REQUEST_DATE", EverDate.getDate());
        return "/evermp/IM03/IM03_016";
    }

    @RequestMapping(value = "/im03016_doRequest")
    public void im03016_doRequest(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> form = req.getFormData();
        List<Map<String, Object>> grid = req.getGridData("grid");

        Map<String, String> rtnMap = im0301Service.im03016_doRequest(form, grid);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    /** ****************************************************************************************************************
     * 품목등록_품목상세이미지 화면
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_017/view")
    public String IM03_017(EverHttpRequest req) throws Exception {

        return "/evermp/IM03/IM03_017";
    }
    /** ****************************************************************************************************************
     * 품목등록_상품고시 화면
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM03_018/view")
    public String IM03_018(EverHttpRequest req) throws Exception {

        return "/evermp/IM03/IM03_018";
    }




















    @RequestMapping(value = "/IM03_009P/view")
    public String IM03_009P(EverHttpRequest req) throws Exception {

        return "/evermp/IM03/IM03_009P";
    }


    @RequestMapping(value = "/IM03_009Hist/view")
    public String IM03_009Hist(EverHttpRequest req) throws Exception {
        return "/evermp/IM03/IM03_009Hist";
    }
    @RequestMapping(value = "/IM03_009Hist/doSearch")
    public void IM03_009Hist_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", im0301Service.getItemHistList(req.getFormData()));
    }




	@RequestMapping(value = "/getStdType")
	public void getDivisionDeptPartCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("CODE_TYPE","MP103");
		param.put("FLAG",req.getParameter("FLAG"));
		resp.setParameter("stdTypes",  commonComboService.getCodeComboAsJson2("CB0206",param) );
		resp.setResponseCode("true");
	}

}