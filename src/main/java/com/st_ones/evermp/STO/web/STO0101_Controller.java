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
import com.st_ones.evermp.STO.service.STO0101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/STO")
public class STO0101_Controller extends BaseController {

    @Autowired
    STO0101_Service sto0101Service;
    @Autowired
    CommonComboService commonComboService;
    @Autowired
    FileAttachService fileAttachService;
    @Autowired
    MessageService messageService;
    @Autowired
    LargeTextService largeTextService;
    /** ****************************************************************************************************************
     * *창고 등록
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/STO01_010/view")
    public String STO01_010(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }
        return "/evermp/STO/STO01_010";
    }

    @RequestMapping(value = "/STO01_010/sto0101_doSearch")
    public void sto0101_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sto0101Service.sto0101_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/STO01_010/sto0101_doSave")
    public void sto01010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	List<Map<String, Object>> gridData = req.getGridData("grid");
    		sto0101Service.sto0101_doSave(gridData);
    }
	/* *******************************************************************************************************************************
	 * * 안전재고 현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
    @RequestMapping(value = "/STO01_020/view")
    public String STO01_020(EverHttpRequest req) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	throw new Exception("운영사만 접근가능합니다.");
        }
    	req.setAttribute("form", req.getParamDataMap());

        return "/evermp/STO/STO01_020";
    }
    @RequestMapping(value = "/STO01_020/sto0102_doSearch")
    public void sto0102_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        resp.setGridObject("grid", sto0101Service.sto0102_doSearch(req.getFormData()));
    }

    @RequestMapping(value = "/STO01_020/sto0102_doSave")
    public void sto0102_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	List<Map<String, Object>> gridData = req.getGridData("grid");
    	  Map<String, String> param = req.getFormData();

    	String returnMsg =sto0101Service.sto0102_doSave(param, gridData);
    	    resp.setResponseMessage(returnMsg);
    }

}