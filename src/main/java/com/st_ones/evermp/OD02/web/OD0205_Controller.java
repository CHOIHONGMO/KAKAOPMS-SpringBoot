package com.st_ones.evermp.OD02.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.OD02.service.OD0205_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/OD02/OD0205")
public class OD0205_Controller extends BaseController {

	@Autowired private OD0205_Service od0205_Service;
	@Autowired private CommonComboService commonComboService;

	@RequestMapping(value="/OD02_050/view")
	public String OD02_050(EverHttpRequest req) throws Exception {
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));

		return "/evermp/OD02/OD02_050";
	}
	@RequestMapping(value = "/OD02_050/doSearch")
	public void od02050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
		List<Map<String, Object>> gridList=od0205_Service.od02050_doSearch(param);
		resp.setGridObject("grid", gridList);
	}

	@RequestMapping(value = "/OD02_050/doCompleteDely")
	public void od02050_doCompleteDely(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0205_Service.od02050_doCompleteDely(gridList);

        resp.setResponseMessage(returnMsg);
	}

	@RequestMapping(value = "/OD02_050/doCancelDely")
	public void od02050_doCancelDely(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0205_Service.od02050_doCancelDely(gridList);

        resp.setResponseMessage(returnMsg);
	}

	@RequestMapping(value = "/OD02_050/doSave")
	public void od02050_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0205_Service.od02050_doSave(gridList);

        resp.setResponseMessage(returnMsg);
	}

	@RequestMapping(value = "/OD02_050/doDelete")
	public void od02050_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0205_Service.od02050_doDelete(gridList);

	     resp.setResponseMessage(returnMsg);
	}

}