package com.st_ones.evermp.STO.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.STO.service.STO0201_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "evermp/STO")
public class STO0201_Controller extends BaseController {

    @Autowired
    private MessageService msg;

    @Autowired
    private STO0201_Service sto0201_Service;


    /** 재고이동
     *
     */

    @RequestMapping(value="/STO02_010/view")
    public String STO02_010(EverHttpRequest req) throws Exception {
        req.setAttribute("toDate", EverDate.getDate());

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = req.getFormData();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("USER_ID", userInfo.getUserId());

        return "/evermp/STO/STO02_010";
    }

    // 저장
    @RequestMapping(value="/STO02_010/sto0201_doSave")
    public void sto0201_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        sto0201_Service.sto0201_doSave(gridList);

        resp.setResponseMessage(msg.getMessage("0031"));
    }

    /**
     * 재고조정
     */
    @RequestMapping(value="/STO02_020/view")
    public String STO02_020(EverHttpRequest req) throws Exception {
        req.setAttribute("toDate", EverDate.getDate());

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = req.getFormData();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("USER_ID", userInfo.getUserId());

        return "/evermp/STO/STO02_020";
    }

    // 저장
    @RequestMapping(value="/STO02_020/sto0202_doSave")
    public void sto1020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        sto0201_Service.sto0202_doSave(gridList);

        resp.setResponseMessage(msg.getMessage("0031"));
    }

    /**
     ** 재고조정 팝업
     **/

    @RequestMapping(value = "/STO02P01/view")
    public String STO02P01(EverHttpRequest req) throws Exception{
        String dealCd = EverString.nullToEmptyString(req.getParameter("DEAL_CD"));
        Map<String, String> param = new HashMap<>();
        param.put("DEAL_CD", dealCd);

        return "/evermp/STO/STO02P01";
    }

    @RequestMapping(value ="/STO02P01/sto02p01_doSearch")
    public void sto02p01_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> param = req.getFormData();
        resp.setGridObject("grid", sto0201_Service.sto02p01_doSearch(param));
    }


}
