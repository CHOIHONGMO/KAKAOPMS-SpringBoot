package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS99.service.BS9901_Service;
import com.st_ones.evermp.buyer.rq.service.RQ0300Service;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.text.SimpleDateFormat;
import java.util.*;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0310Controller extends BaseController {


	@Autowired private RQ0300Service rq0300service;
	@Autowired private BS9901_Service bs9901service;
	@Autowired private CommonComboService commonComboService;
	
	/**
	 * 견적요청작성 (RQ0310)
	 * @param req
	 * @param resp
	 * @return
	 * @throws Exception
	 */
    @RequestMapping(value="/RQ0310/view")
    public String RQ0110(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = req.getParamDataMap();

        String baseDataType = EverString.defaultIfEmpty(req.getParameter("baseDataType"), "");

        Map<String, Object> data = new HashMap<>();

        Date date = new Date();
        SimpleDateFormat sdformat = new SimpleDateFormat("yyyyMMddHHmmss");
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.MINUTE, 10);

        data.put("today",EverDate.getDate());
        data.put("todayTime",EverDate.getTime());

        if(StringUtils.isEmpty(param.get("RFX_NUM")) && StringUtils.isEmpty(param.get("APP_DOC_NUM")) )
        {
            // 매뉴얼 작성, PR(구매요청), 품목마스터에서 넘어올 때(견적 최초 작성 시)
            data.put("GATE_CD"			, userInfo.getGateCd());
            data.put("BUYER_CD"			, userInfo.getCompanyCd());
            data.put("CTRL_USER_ID"		, userInfo.getUserId());
            data.put("CTRL_USER_NM"		, userInfo.getUserNm());
            data.put("CTRL_USER_DEPT"	, userInfo.getDeptNm());
            data.put("PROGRESS_CD"		, "2300");	// 견적요청 작성중
            data.put("SIGN_STATUS"		, "T");		// 작성중
            data.put("RFX_FROM_DATE"	, EverDate.getDate());
            data.put("RFX_FROM_HOUR"	, EverDate.getTime().substring(0,2));
            data.put("RFX_FROM_MIN"		, "00");
            data.put("RFX_TO_DATE"		, EverDate.addDays(5));
            data.put("RFX_TO_HOUR"		, EverDate.getTime().substring(0,2));
            data.put("RFX_BF_DAY1"		, EverDate.addDays(3));
            data.put("RFX_BF_HOUR1"		, EverDate.getTime().substring(0,2));
            data.put("RFX_BF_MIN1"		, "00");
            data.put("RFX_BF_DAY2"		, EverDate.addDays(4));
            data.put("RFX_BF_HOUR2"		, EverDate.getTime().substring(0,2));
            data.put("RFX_BF_MIN2"		, "00");
            data.put("RFX_TO_MIN"		, "00");
            data.put("PRC_SLT_TYPE"		, "PRI");	// 최저가
            //data.put("SHIPPER_TYPE","D");

            //pr에서 넘어갈 때
            data.put("RFX_SUBJECT"		, param.get("PR_SUBJECT"));
            data.put("CUR"				, param.get("CUR"));
            data.put("PR_TYPE"			, param.get("PR_TYPE"));
            data.put("PR_REQ_TYPE"		, param.get("PR_REQ_TYPE"));
            data.put("PUR_ORG_CD"		, param.get("PUR_ORG_CD"));
            data.put("CONT_REQ_FLAG"	, param.get("CONT_REQ_FLAG"));
            data.put("PR_BUYER_CD"		, param.get("PR_BUYER_CD"));
            data.put("PR_BUYER_NM"		, param.get("PR_BUYER_NM"));
            data.put("PR_PLANT_CD"		, param.get("PR_PLANT_CD"));
            data.put("PR_PLANT_NM"		, param.get("PR_PLANT_NM"));
        }
        else {
            //최초 작성이 아닐때
            data = rq0300service.getRfxHdDetail(param);
            data.put("updatePg", true);

            //재견적시
            if(baseDataType.equals("RERFX")){
                data.put("CTRL_USER_ID"		, userInfo.getUserId());
                data.put("CTRL_USER_NM"		, userInfo.getUserNm());
                data.put("CTRL_USER_DEPT"	, userInfo.getDeptNm());
                data.put("PROGRESS_CD"		, "2300");	// 견적요청 작성중
                data.put("SIGN_STATUS"		, "T");		// 작성중
                data.put("RFX_FROM_DATE"	, EverDate.getDate());
                data.put("RFX_FROM_HOUR"	, EverDate.getTime().substring(0,2));
                data.put("RFX_FROM_MIN"		, "00");
                data.put("RFX_TO_DATE"		, EverDate.addDays(5));
                data.put("RFX_TO_HOUR"		, EverDate.getTime().substring(0,2));
                data.put("RFX_BF_DAY1"		, EverDate.addDays(3));
                data.put("RFX_BF_HOUR1"		, EverDate.getTime().substring(0,2));
                data.put("RFX_BF_MIN1"		, "00");
                data.put("RFX_BF_DAY2"		, EverDate.addDays(4));
                data.put("RFX_BF_HOUR2"		, EverDate.getTime().substring(0,2));
                data.put("RFX_BF_MIN2"		, "00");
                data.put("RFX_TO_MIN"		, "00");
                data.put("BUYER_CD"			, userInfo.getCompanyCd());
            }
        }

        // 견적품목 리스트
        List<Map<String,Object>> prList = new ArrayList<>();
        // 구매요청(PR), 공급사 제안상품(VD), 상품마스터(GL) 기준 견적서 작성
        if (baseDataType.equals("PR") || baseDataType.equals("VD") || baseDataType.equals("GL")) {
            prList = rq0300service.getRfxDtDetailFromPrList(param.get("prList"));
        }
        if(StringUtils.isEmpty((String)data.get("PR_BUYER_CD"))){
        	String BUY_CD = PropertiesManager.getString("eversrm.default.cust.code");
        	Map<String, String> rData = new HashMap<String, String>();
        	rData.put("PR_BUYER_CD", BUY_CD);
        	data.put("PR_BUYER_CD", BUY_CD);
        	data.put("PR_BUYER_NM", commonComboService.getCodes("CB0203", rData).get(0).get("VALUE"));
        }

        //================== 템플릿 파일 번호 가져오기 ==================
        Map<String, String> tempData = new HashMap<String, String>();
        tempData.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.RFQ.key"));
        Map<String, String> tempMap = bs9901service.doSearch_templateFile(tempData);
        req.setAttribute("TEMP_ATT_FILE_NUM", (tempMap!=null&&tempMap.size()>0)?tempMap.get("ATT_FILE_NUM"):"");
        //================== 템플릿 파일 번호 가져오기 ==================

        req.setAttribute("formData", data);
        req.setAttribute("APPROVAL_PFX", PropertiesManager.getString("eversrm.approval.PFX.use.flag"));
        req.setAttribute("CONT_REQ_FLAG",req.getParameter("CONT_REQ_FLAG"));
        req.setAttribute("prList", prList);

        return "/evermp/buyer/rq/RQ0310";
    }

    @RequestMapping(value = "/RQ0310/doSearch")
    public void RQ0310_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();

        resp.setGridObject("gridL", rq0300service.getRfxDtDetail(formData));
    	resp.setResponseCode("true");
    }
    
    /**
     * 견적요청작성 (RQ0310) : 저장 및 협력사 전송
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value="/RQ0310/doSave")
    public void RQ0310_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception{
    	
        Map<String, String> formData = req.getFormData();
        List<Map<String, Object >> gridL = req.getGridData("gridL");
        List<Map<String, Object >> gridDEL = req.getGridData("gridDEL");
        Map<String, String> rtnMap = rq0300service.insertRq(formData, gridL, gridDEL);

        resp.setParameter("gateCd", rtnMap.get("GATE_CD"));
        resp.setParameter("buyerCd", rtnMap.get("BUYER_CD"));
        resp.setParameter("rfxNum", rtnMap.get("RFX_NUM"));
        resp.setParameter("rfxCnt", rtnMap.get("RFX_CNT"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value="/RQ0310/doDelete")
    public void RQ0310_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception{
    	
        Map<String, String> rtnMap = rq0300service.deleteRFX(req.getFormData(), req.getGridData("gridL"), req.getGridData("gridDEL"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    /**
     * 소싱관리 > 견적관리 > 견적의뢰 작성 (RQ0310) : 엑셀 업로드
     * @param req
     * @param resp
     * @throws Exception
     */
    @RequestMapping(value = "/RQ0310/doSetExcelImportItemRfx")
    
    public void doSetExcelImportItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("gridL",rq0300service.doSetExcelImportItem(req.getGridData("gridL")));
    }

    @RequestMapping(value="/RQ0310P01/view")
    public String RQ0110P01(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	
        return "/evermp/buyer/rq/RQ0310P01";
    }

}