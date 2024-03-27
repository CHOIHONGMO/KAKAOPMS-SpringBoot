package com.st_ones.evermp.vendor.bq.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.bq.service.BQ0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value="/evermp/vendor/bq")
public class BQ0310Controller {

    @Autowired  BQ0300Service bq0300Service;
    @Autowired private CommonComboService commonComboService;
    @RequestMapping(value="/BQ0310/view")
    public String BQ0310(EverHttpRequest req) throws Exception{
    	Map<String, String> param = new HashMap<>();
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        req.setAttribute("fromDate",EverDate.addMonths(-1));
        req.setAttribute("today", EverDate.addDays(14));
        req.setAttribute("todayTime",EverDate.getTime());
        //work list에서 호출 시 넘기는 parameter
        req.setAttribute("dashBoardFlag", EverString.defaultIfEmpty(req.getParamDataMap().get("dashBoardFlag"),""));
        req.setAttribute("PROGRESS_CD", EverString.defaultIfEmpty(req.getParamDataMap().get("PROGRESS_CD"),""));
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", "2518");
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
        return "/evermp/vendor/bq/BQ0310";
    }

    @RequestMapping(value="/BQ0310/doSearch")
    public void BQ0310_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid",bq0300Service.getBdList(req.getFormData()));
    }

    @RequestMapping(value="/BQ0310/doReceipt")
    public void BQ0310_doReceipt(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        bq0300Service.receiptBDVN(req.getGridData("grid"));
        resp.setResponseCode("true");
    }

    @RequestMapping(value="/BQ0310/doWaive")
    public void BQ0310_doWaive(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        String msg = bq0300Service.waiveBD(req.getGridData("grid"));
        resp.setResponseMessage(msg);
    }




    @RequestMapping(value="/BQ0310P01/view")
    public String BQ0310P01(EverHttpRequest req) throws Exception{

        Map<String,String> param = req.getParamDataMap();
        req.setAttribute("form", bq0300Service.BQ0310P01_getBDDetail(param));

        return "/evermp/vendor/bq/BQ0310P01";
    }

}
