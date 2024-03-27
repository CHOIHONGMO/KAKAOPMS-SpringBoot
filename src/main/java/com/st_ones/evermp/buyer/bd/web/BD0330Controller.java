package com.st_ones.evermp.buyer.bd.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.bd.service.BD0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/bd")
public class BD0330Controller extends BaseController {


    @Autowired private BD0300Service bd0300Service;
    @Autowired private CommonComboService commonComboService;

    @RequestMapping(value = "/BD0330/view")
    public String RQ0130(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<>();
        param.put("FLAG1", "B");
        req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
        req.setAttribute("FROM_DATE", EverDate.addMonths(-1));
        req.setAttribute("TO_DATE", EverDate.getDate());
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));

        return "/evermp/buyer/bd/BD0330";
    }

    @RequestMapping(value="/BD0330/doSearch")
    public void RQ0130_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        resp.setGridObject("grid", bd0300Service.getBqList(req.getFormData()));
    }

}

