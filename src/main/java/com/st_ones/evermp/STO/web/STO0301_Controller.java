package com.st_ones.evermp.STO.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.STO.service.STO0301_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "/evermp/STO")
public class STO0301_Controller extends BaseController {

    @Autowired
    STO0301_Service STO0301Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;
    @Autowired
    LargeTextService largeTextService;
    /** ****************************************************************************************************************
     * 운영사 상품별 현재고(가용)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/STO03_010/view")
    public String STO03_010(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }
       req.setAttribute("form", req.getParamDataMap());
        return "/evermp/STO/STO03_010";
    }

    @RequestMapping(value = "/sto0301_doSearch")
    public void STO0301_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", STO0301Service.sto0301_doSearch(req.getFormData()));
    }




    /** ****************************************************************************************************************
     * 공급사 상품별 현재고(가용)
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/STO03_020/view")
    public String STO03_020(EverHttpRequest req) throws Exception {
       req.setAttribute("form", req.getParamDataMap());
        return "/evermp/STO/STO03_020";
    }
}