package com.st_ones.evermp.BS03.web;

import blowfishj.BlowfishEasy;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS03.service.BS0301_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BS03/BS0301")
public class BS0301_Controller extends BaseController {

    @Autowired
    BS0301_Service bs0301Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    LargeTextService largeTextService;
    @Autowired
    private MessageService msg;

    /** ****************************************************************************************************************
     * 조직정보 현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_001/view")
    public String BS03_001(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	String fromDate = EverDate.addMonths(-1);
        String toDate = EverDate.getDate();
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate",toDate);
        return "/evermp/BS03/BS03_001";
    }


    @RequestMapping(value="/bs03001_doSearch")
    public void bs03001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs0301Service.bs03001_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/bs03001_doConfirmReject")
	public void bs03001_doConfirmReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bs0301Service.bs03001_doConfirmReject(EverString.nullToEmptyString(req.getParameter("signStatus")), req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

    /** ****************************************************************************************************************
     * 공급사 평가현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_002P/view")
    public String BS03_002P(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());
        return "/evermp/BS03/BS03_002P";
    }

    @RequestMapping(value="/BS03_002P_doSearch")
    public void BS03_002P_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs0301Service.BS03_002P_doSearch(req.getFormData()));
    }
    /** ****************************************************************************************************************
     * 공급사 평가현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_001P/view")
    public String BS03_001P(EverHttpRequest req) throws Exception {
        // req.setAttribute("yyyymm", EverDate.getShortDateString().substring(0, 6));
        req.setAttribute("form", req.getParamDataMap());
        return "/evermp/BS03/BS03_001P";
    }

    @RequestMapping(value="/BS03_001P_doSearch")
    public void BS03_001P_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs0301Service.BS03_001P_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 공급회사 상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_002/view")
    public String BS03_002(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();

        String vendorCd  = EverString.nullToEmptyString(req.getParameter("VENDOR_CD"));
        String appDocNum = EverString.nullToEmptyString(req.getParameter("appDocNum"));
        String appDocCnt = EverString.nullToEmptyString(req.getParameter("appDocCnt"));

        boolean superUserFlag  = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1");
        // 시스템 담당자, 고객 및 공급사 담당자, 관리자
        boolean havePermission = (EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("B100") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));

        if(!vendorCd.equals("")) {
            param.put("VENDOR_CD", vendorCd);
            formData = bs0301Service.bs03002_doSearchInfo(param);
            if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
                havePermission = true;
            }
        } else {
        	formData.put("IPO_FLAG", "0");
        	formData.put("TAX_TYPE", "T1");
        	formData.put("SMS_FLAG", "1");
        	formData.put("MAIL_FLAG", "1");
        }
        if(!appDocNum.equals("") && !appDocCnt.equals("")) {
        	param.put("APP_DOC_NUM", appDocNum);
        	param.put("APP_DOC_CNT", appDocCnt);
        	formData = bs0301Service.bs03002_doSearchInfo(param);
        	if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
        		havePermission = true;
        	}
        }

        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));

        //req.setAttribute("majorItemCd", commonComboService.getCodeCombo("MP004"));
        req.setAttribute("regionCd", commonComboService.getCodeCombo("MP005"));
        req.setAttribute("businessList", commonComboService.getCodeCombo("MP040"));
        req.setAttribute("deliberyType", commonComboService.getCodeCombo("MP041"));
        req.setAttribute("dealType", commonComboService.getCodeCombo("MP042"));
        req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "T100");    //지원직무(고객 및 공급사 담당자)
        req.setAttribute("bacpUserOptions", commonComboService.getCodesAsJson("CB0064", param));
        param.put("CTRL_CD", "P100");    //계산서직무(마감 및 정산 담당자)
        req.setAttribute("payUserOptions", commonComboService.getCodesAsJson("CB0064", param));

    	String encodedKey = "";
    	String encdtoday  = "";
    	java.text.SimpleDateFormat encdDateFormat = new java.text.SimpleDateFormat("ddHHmmss");
        Calendar encdCalendar = Calendar.getInstance();
        encdtoday  = encdDateFormat.format(encdCalendar.getTime()); //fKey구성에쓰일 시간값

        String KEY = PropertiesManager.getString("eversrm.blowfish.encrypt.key");
        BlowfishEasy bfes = new BlowfishEasy(KEY.toCharArray());
        encodedKey = bfes.encryptString(encdtoday);

        req.setAttribute("encdtoday", encdtoday);
        req.setAttribute("encodedKey", encodedKey);
        req.setAttribute("today", EverDate.getShortDateString());

        req.setAttribute("superUserFlag", superUserFlag);
        req.setAttribute("havePermission", havePermission);
        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);
        return "/evermp/BS03/BS03_002";
    }










    @RequestMapping(value = "/BS03_002C/view")
    public String BS03_002C(EverHttpRequest req) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = new HashMap<String, String>();

        String vendorCd  = EverString.nullToEmptyString(req.getParameter("VENDOR_CD"));
        String closeYear  = EverString.nullToEmptyString(req.getParameter("CLOSE_YEAR"));


        System.err.println("======================================vendorCd="+vendorCd);
        System.err.println("======================================closeYear="+closeYear);

        if(closeYear==null || "".equals(closeYear)) {
            formData = bs0301Service.bs03002_doSearchInfo(param);
            req.setAttribute("CLOSE_YEAR", EverDate.getYear());
        } else {
            formData = bs0301Service.getCreditHist(param);
            req.setAttribute("CLOSE_YEAR", closeYear);
        }
        param.put("VENDOR_CD", vendorCd);




        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));


    	String encodedKey = "";
    	String encdtoday  = "";
    	java.text.SimpleDateFormat encdDateFormat = new java.text.SimpleDateFormat("ddHHmmss");
        Calendar encdCalendar = Calendar.getInstance();
        encdtoday  = encdDateFormat.format(encdCalendar.getTime()); //fKey구성에쓰일 시간값

        String KEY = PropertiesManager.getString("eversrm.blowfish.encrypt.key");
        BlowfishEasy bfes = new BlowfishEasy(KEY.toCharArray());
        encodedKey = bfes.encryptString(encdtoday);

        req.setAttribute("encdtoday", encdtoday);
        req.setAttribute("encodedKey", encodedKey);
        req.setAttribute("today", EverDate.getShortDateString());

        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);
        return "/evermp/BS03/BS03_002C";
    }


















    // 공급회사 담당자 조회
    @RequestMapping(value = "/bs03002_doSearchUser")
    public void bs03002_doSearchUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("VENDOR_CD", req.getParameter("VENDOR_CD"));
        resp.setGridObject("gridVncp", bs0301Service.bs03002_doSearchUser(param));
    }

    // 공급회사 취급분야 조회
    @RequestMapping(value = "/bs03002_doSearchSG")
    public void bs03002_doSearchSG(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("VENDOR_CD", req.getParameter("VENDOR_CD"));
        resp.setGridObject("grid1", bs0301Service.bs03002_doSearchSG(param));
    }

    //공급사_취급분야 삭제
    @RequestMapping(value="/bs03002_dodeleteSGVN")
    public void bs03002_dodeleteSGVN(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> grid1Data = req.getGridData("grid1");
        formData.put("VENDOR_CD", req.getParameter("VENDOR_CD"));
        bs0301Service.bs03002_dodeleteSGVN(formData, grid1Data);
        resp.setResponseMessage(msg.getMessage("0017"));
        resp.setResponseCode("true");
    }

    // 공급사 저장
    @RequestMapping(value = "/bs03002_doSave")
    public void bs03002_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        formData.put("SIGN_STATUS", EverString.nullToEmptyString(req.getParameter("signStatus")));

        List<Map<String, Object>> grid1Datas = req.getGridData("grid1");    //s/g(취급분야)
        List<Map<String, Object>> gridTxDatas = req.getGridData("gridtx");    //계산서사용자
        List<Map<String, Object>> gridVncp = req.getGridData("gridVncp");    //계산서사용자

        Map<String, String> rtnMap = bs0301Service.bs03002_doSave(formData, grid1Datas,gridTxDatas,gridVncp);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
        resp.setParameter("VENDOR_CD", rtnMap.get("VENDOR_CD"));
    }

    //공급사계산서사용자 조회
    @RequestMapping(value = "/bs03002_doSearchTX")
    public void bs03002_doSearchTX(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("VENDOR_CD", req.getParameter("VENDOR_CD"));
        resp.setGridObject("gridtx", bs0301Service.bs03002_doSearchTX(param));
    }

    //공급사_계산서사용자 삭제
    @RequestMapping(value="/bs03002_dodeleteTX")
    public void bs03002_dodeleteTX(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridtxData = req.getGridData("gridtx");
        formData.put("VENDOR_CD", req.getParameter("VENDOR_CD"));
        bs0301Service.bs03002_dodeleteTX(formData, gridtxData);
        resp.setResponseMessage(msg.getMessage("0017"));
        resp.setResponseCode("true");
    }

    /** ****************************************************************************************************************
     * 공급회사 Block 이력 상세
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_003/view")
    public String BS03_003(EverHttpRequest req) throws Exception {
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = req.getParamDataMap();

        System.out.println(param);
        formData = bs0301Service.bs03003_doSearchInfo(param);


        boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));

        req.setAttribute("blockFlag", commonComboService.getCodeCombo("MP006"));
        req.setAttribute("detailView", detailView);
        req.setAttribute("formData", formData);



        return "/evermp/BS03/BS03_003";
    }

    //공급사 Block 저장 / 이력저장
    @RequestMapping(value = "/bs03003_doSave")
    public void bs03003_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        Map<String, String> rtnMap = bs0301Service.bs03003_doSave(formData);
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
        resp.setParameter("VENDOR_CD", rtnMap.get("VENDOR_CD"));
    }


    //공급회사 이력 조회
    @RequestMapping(value = "/bs03003_doSearchHistory")
    public void bs03003_doSearchHistory(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("VENDOR_CD", req.getParameter("VENDOR_CD"));

        resp.setGridObject("grid", bs0301Service.bs03003_doSearchHistory(param));
    }

    /** ****************************************************************************************************************
     * 공급회사 정보 변경이력
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_007/view")
    public String BS03_007(EverHttpRequest req) throws Exception {

        return "/evermp/BS03/BS03_007";
    }
    @RequestMapping(value = "/bs03007_doSearch")
    public void bs03007_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs0301Service.bs03007_doSearch(req.getFormData()));
    }


    /** ****************************************************************************************************************
     * 공급회사 평가항목
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_008/view")
    public String BS03_008(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> formData = new HashMap<String, String>();
        Map<String, String> param = req.getParamDataMap();

        String vendorCd = EverString.nullToEmptyString(req.getParameter("VENDOR_CD"));

        boolean havePermission = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1");

        if(!vendorCd.equals("")) {
            param.put("VENDOR_CD", vendorCd);
            formData = bs0301Service.bs03008_doSearchInfo(param);
            if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
                havePermission = true;
            }
        }else{
            formData.put("VENDOR_NM",EverString.nullToEmptyString(req.getParameter("VENDOR_NM")));
            String foundationDate = EverString.nullToEmptyString(req.getParameter("FOUNDATION_DATE"));
            formData.put("FOUNDATION_DATE",foundationDate.substring(0,4)+"-"+foundationDate.substring(4,6)+"-"+foundationDate.substring(6,8));
            formData.put("EVAL_ITEM_1_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_1_SCORE")));
            formData.put("EVAL_ITEM_2_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_2_SCORE")));
            formData.put("EVAL_ITEM_3_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_3_SCORE")));
            formData.put("EVAL_ITEM_4_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_4_SCORE")));
            formData.put("EVAL_ITEM_5_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_5_SCORE")));
            formData.put("EVAL_ITEM_6_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_6_SCORE")));
            formData.put("EVAL_ITEM_7_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_7_SCORE")));
            formData.put("EVAL_ITEM_8_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_8_SCORE")));
            formData.put("EVAL_ITEM_9_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_9_SCORE")));
            formData.put("EVAL_ITEM_10_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_10_SCORE")));
            formData.put("EVAL_ITEM_11_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_11_SCORE")));
            formData.put("EVAL_ITEM_12_SCORE",EverString.nullToEmptyString(req.getParameter("EVAL_ITEM_12_SCORE")));
            formData.put("EVAL_REMARK",EverString.nullToEmptyString(req.getParameter("EVAL_REMARK")));
            formData.put("EVAL_GRADE_CLS",EverString.nullToEmptyString(req.getParameter("EVAL_GRADE_CLS")));
            param.putAll(formData);
        }
        param.put("VNEV_YN",EverString.nullToEmptyString(req.getParameter("VNEV_YN")));

        req.setAttribute("havePermission", havePermission);
        req.setAttribute("formData", formData);

        //평가리스트
        List<Map<String, Object>> CList = bs0301Service.bs03008_doSearchList(param);
        req.setAttribute("CList", CList);


        return "/evermp/BS03/BS03_008";
    }

    //평가저장
    @RequestMapping(value = "/bs03008_doSave")
    public void bs03008_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        Map<String, String> rtnMap = bs0301Service.bs03008_doSave(formData);

        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    /** ****************************************************************************************************************
     * 협력업체 현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_009/view")
    public String BS03_009(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
    	String fromDate = EverDate.addMonths(-1);
        String toDate = EverDate.getDate();
        req.setAttribute("fromDate", fromDate);
        req.setAttribute("toDate",toDate);
        return "/evermp/BS03/BS03_009";
    }


    @RequestMapping(value="/bs03009_doSearch")
    public void bs03009_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs0301Service.bs03009_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/bs03009_doUpdateProgressCd")
    public void bs03009_doUpdateProgressCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0301Service.bs03009_doUpdateProgressCd(req.getParamDataMap(), req.getGridData("grid"));
    }

    @RequestMapping(value = "/bs03009_doUpdateRejectStatus")
    public void bs03009_doUpdateRejectStatus(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        bs0301Service.bs03009_doUpdateRejectStatus(req.getParamDataMap(), req.getGridData("grid"));
    }

    /** ****************************************************************************************************************
     * 공급사 평가현황
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_009P/view")
    public String BS03_009P(EverHttpRequest req) throws Exception {
        req.setAttribute("form", req.getParamDataMap());
        return "/evermp/BS03/BS03_009P";
    }

    @RequestMapping(value="/BS03_009P_doSearch")
    public void BS03_009P_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", bs0301Service.BS03_009P_doSearch(req.getFormData()));
    }

    /** ****************************************************************************************************************
     * 공급회사 평가항목
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/BS03_010/view")
    public String BS03_010(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = req.getParamDataMap();

        String vendorCd = EverString.nullToEmptyString(req.getParameter("VENDOR_CD"));

        boolean havePermission = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1");
        req.setAttribute("havePermission", havePermission);

        param.put("VENDOR_CD", vendorCd);

        // 업체의 유통레벨 조회 = A : 제조, 나머지...
        String deliveryLevel = bs0301Service.bs03010_doSearchDeliveryLevel(param);
        if( deliveryLevel == null || deliveryLevel == ""){
            param.put("DELIVERY_LEVEL", "A");
        } else {
            param.put("DELIVERY_LEVEL", deliveryLevel);
        }

        req.setAttribute("formData", bs0301Service.bs03010_doSearchInfo(param));




        //평가리스트
        List<Map<String, Object>> CList = bs0301Service.bs03010_doSearchList(param);
        req.setAttribute("CList", CList);
        req.setAttribute("DELIVERY_LEVEL", deliveryLevel);
        req.setAttribute("SPEV_YN", EverString.nullToEmptyString(param.get("SPEV_YN")));
        req.setAttribute("readOnly", Boolean.valueOf(param.get("detailView")));

        return "/evermp/BS03/BS03_010";
    }

    //평가저장
    @RequestMapping(value = "/bs03010_doSave")
    public void bs03010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        formData.put("PROGRESS_CD", "100");
        Map<String, String> rtnMap = bs0301Service.bs03010_doSave(formData);

        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }


    /**
     * 공급사 거래제안
     */
    @RequestMapping(value="/BS03_011/view")
    public String BS03_011(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		/*req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -2));
		req.setAttribute("addToDate", EverDate.getDate());*/
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("NOTICE_TYPE",req.getParameter("NOTICE_TYPE"));
        return "/evermp/BS03/BS03_011";
    }

    @RequestMapping(value = "/BS03_011_doSearch")
    public void BS03_011_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", bs0301Service.BS03_011_doSearch(param));
    }

    @RequestMapping(value = "/BS03_011_doDelete")
    public void BS03_011_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridData = req.getGridData("grid");
        UserInfo userInfo = UserInfoManager.getUserInfo();
        boolean havePermission = false;
        String rtnMsg = "";
        havePermission = userInfo.getUserId().equals(String.valueOf(gridData.get(0).get("REG_USER_ID")));

        if(havePermission) {
            rtnMsg = bs0301Service.BS03_011_doDelete(req.getGridData("grid"));
        } else {
            rtnMsg = msg.getMessage("0037"); //권한이 없습니다.
        }

        resp.setResponseMessage(rtnMsg);
    }

    /**
     * 공급사 거래제안 팝업
     */
    @RequestMapping(value="/BS03_011P/view")
    public String BS03_011P(EverHttpRequest req) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        Map<String, Object> formData = new HashMap<String, Object>();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        String noticeType = "";
        String ctrlCd = userInfo.getCtrlCd();

        if(ctrlCd != null && ctrlCd.indexOf("B200") > -1){
            req.setAttribute("ctrlFlag","Y");
        } else {
            req.setAttribute("ctrlFlag","N");
        }

        boolean havePermission = false;
        String noticeNum = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));
        String detailView = EverString.nullToEmptyString(req.getParameter("detailView"));
        String noticeTextNum = largeTextService.selectLargeText("TN221125000009");

        if(!noticeNum.equals("")) { //수정/상세
            param.put("NOTICE_NUM", noticeNum);
            param.put("detailView", detailView);
            formData = bs0301Service.BS03_011P_doSearchNoticeInfo(param);
            formData.put("MOD_DATE", EverDate.getDate());
            havePermission = userInfo.getUserId().equals(String.valueOf(formData.get("REG_USER_ID")));
        } else { // 신규등록
            formData.put("NOTICE_CONTENTS", noticeTextNum);
            formData.put("START_DATE", EverDate.getDate());
            formData.put("REG_DATE", EverDate.getDate());
            formData.put("INS_DATE", EverDate.getDate());
            havePermission = true;
        }

        if(req.getParameter("NOTICE_TYPE") != null){
            noticeType = req.getParameter("NOTICE_TYPE");
        } else if (formData.get("NOTICE_TYPE") != null) {
            noticeType = (String)formData.get("NOTICE_TYPE");
        }

        param.put("NOTICE_TYPE",noticeType);
        formData.put("title",commonComboService.getCodes("CB0011", param).get(0).get("NOTICE_TYPE"));
        formData.put("NOTICE_TYPE", noticeType);

        req.setAttribute("formData", formData);
        req.setAttribute("havePermission", havePermission);

        return "/evermp/BS03/BS03_011P";
    }

    @RequestMapping(value = "/BS03_011P_doSave")
    public void BS03_011P_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> rtnMap = bs0301Service.BS03_011P_doSave(req.getFormData());
        resp.setParameter("NOTICE_NUM", rtnMap.get("NOTICE_NUM"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }
}