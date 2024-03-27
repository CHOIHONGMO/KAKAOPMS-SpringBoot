package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.rq.service.RQ0100Service;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.text.SimpleDateFormat;
import java.util.*;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0110Controller extends BaseController {

    @Autowired  CommonComboService commonComboService;
    @Autowired  RQ0100Service rq0100Service;



    @RequestMapping(value="/RQ0110/view")
    public String RQ0110(EverHttpRequest req) throws Exception{

        Map<String, String> param = req.getParamDataMap();
        UserInfo userInfo = UserInfoManager.getUserInfo();

        String baseDataType = EverString.defaultIfEmpty(req.getParameter("baseDataType"), "");

        Map<String, Object> data = new HashMap<>();

        Date date = new Date();
        SimpleDateFormat sdformat = new SimpleDateFormat("yyyyMMddHHmmss");
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.MINUTE, 10);

        data.put("today",EverDate.getDate());
        data.put("todayTime",EverDate.getTime());

        if(StringUtils.isEmpty(param.get("RFX_NUM")) && StringUtils.isEmpty(param.get("APP_DOC_NUM")) ) {
            //매뉴얼작성시 && PR 에서 넘어올 때(견적 최초 작성 시)
            data.put("GATE_CD", userInfo.getGateCd());
            data.put("CTRL_USER_ID", userInfo.getUserId());
            data.put("CTRL_USER_NM", userInfo.getUserNm());
            data.put("CTRL_USER_DEPT", userInfo.getDeptNm());
            data.put("PROGRESS_CD", "2300");
            data.put("SIGN_STATUS","T");
            //pr에서 넘어갈 때
            data.put("RFX_SUBJECT", param.get("PR_SUBJECT"));
            data.put("CUR", param.get("CUR"));
            data.put("PR_TYPE", param.get("PR_TYPE"));
            data.put("PR_REQ_TYPE", param.get("PR_REQ_TYPE"));

        }else{
            //최초작성아닐때
            data = rq0100Service.getRfxHdDetail(param);
            //재견적시
            if(baseDataType.equals("RERFX")){
                String today  = sdformat.format(cal.getTime());
                String tmpMin = ((Integer.parseInt(String.valueOf(Math.round((Math.ceil(Double.parseDouble(today.substring(10, 12)) / 5))) * 5)) < 10) ? "0" + String.valueOf(Math.round((Math.ceil(Double.parseDouble(today.substring(10, 12)) / 5))) * 5) : String.valueOf(Math.round((Math.ceil(Double.parseDouble(today.substring(10, 12)) / 5))) * 5));
                if(tmpMin.equals("00") || tmpMin.equals("60")) {
                    cal.add(Calendar.MINUTE, 10);
                    today = sdformat.format(cal.getTime());
                }
                data.put("RFX_FROM_DATE", EverDate.getDate());
                data.put("RFX_FROM_HOUR", today.substring(8, 10));
                data.put("RFX_FROM_MIN",  null);
                data.put("RFX_TO_DATE", null);
                data.put("RFX_TO_HOUR", null);
                data.put("RFX_TO_MIN",  null);
            }

        }

        req.setAttribute("formData", data);

        //req.setAttribute("refHours", new ObjectMapper().writeValueAsString(commonComboService.getHourCodes()));
        //req.setAttribute("refMinutes", new ObjectMapper().writeValueAsString(commonComboService.getMinutesPartTenCodes()));
        req.setAttribute("prList", com.st_ones.everf.serverside.util.EverString.getJsonString(param.get("prList")));

        return "/evermp/buyer/rq/RQ0110";
    }

    @RequestMapping(value="/RQ0110/doSave")
    public void RQ0110_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
        List<Map<String, Object >> gridL = req.getGridData("gridL");
        Map<String, String> rtnMap = rq0100Service.insertRq(formData, gridL);

        resp.setParameter("gateCd", rtnMap.get("GATE_CD"));
        resp.setParameter("buyerCd", rtnMap.get("BUYER_CD"));
        resp.setParameter("rfxNum", rtnMap.get("RFX_NUM"));
        resp.setParameter("rfxCnt", rtnMap.get("RFX_CNT"));
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

    @RequestMapping(value="/RQ0110/doSearch")
    public void RQ0110_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
        //List<Map<String, Object>> mappp = rq0100Service.getRfxDtDetail(formData);
        resp.setGridObject("gridL", rq0100Service.getRfxDtDetail(formData));

        resp.setResponseCode("true");
    }

    @RequestMapping(value="/RQ0110/doDelete")
    public void RQ0110_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> rtnMap = rq0100Service.deleteRFX(req.getFormData());
        resp.setResponseMessage(rtnMap.get("rtnMsg"));
    }

//    @RequestMapping(value="/RQ0110/doSend")
//    public void RQ0110_doSend(EverHttpRequest req, EverHttpResponse resp) throws Exception{
//        String rtnMsg = rq0100Service.sendRQ(req.getFormData());
//        resp.setResponseMessage(rtnMsg);
//    }



}
