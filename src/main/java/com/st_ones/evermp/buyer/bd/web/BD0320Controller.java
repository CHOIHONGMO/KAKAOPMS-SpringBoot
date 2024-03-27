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
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/bd")
public class BD0320Controller extends BaseController {


	@Autowired private BD0300Service bd0300Service;
	@Autowired private CommonComboService commonComboService;


    @RequestMapping(value="/BD0320/view")
    public String RQ0110(EverHttpRequest req) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

    	Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "B");
		req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
        return "/evermp/buyer/bd/BD0320";
    }


    @RequestMapping(value = "/BD0320/doSearch")
    public void getRfqHdList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        resp.setGridObject("grid", bd0300Service.getBdHdList(formData));
        resp.setResponseCode("true");
    }


	@RequestMapping(value = "/BD0320/doCtrlIdChg")
	public void Transfer(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(bd0300Service.transferBdCtrlUser(formData,gridData));
	}




	@RequestMapping(value="/BD0320P01/view")
	public String RQ0120P03(EverHttpRequest req) throws Exception{
		req.setAttribute("toDay", EverDate.getDate());
		Map<String, String> formData = req.getParamDataMap();
		req.setAttribute("form", bd0300Service.getBdHdDetail(formData));
		return "/evermp/buyer/bd/BD0320P01";
	}

	@RequestMapping(value = "/BD0320P01/doSearch")
	public void getRfqQtaList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		resp.setGridObject("grid", bd0300Service.getRfqQtaList(formData));
		resp.setResponseCode("true");
	}










}