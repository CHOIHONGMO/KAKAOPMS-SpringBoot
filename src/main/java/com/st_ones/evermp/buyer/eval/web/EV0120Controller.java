package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0120Controller  extends BaseController {
	@Autowired
	private CommonComboService commonComboService;
	@Autowired private EV0100Service ev0100service;






	@RequestMapping(value = "/EV0120/view")
	public String EV0120(EverHttpRequest req) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		req.setAttribute("evalKind", commonComboService.getCodeComboAsJson("M115"));
		return "/evermp/buyer/eval/EV0120";
	}

	@RequestMapping(value = "/EV0120/doSearchLeftGrid")
	public void doSearchLeftGrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setGridObject("leftGrid", ev0100service.doSearchLeftGrid(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0120/doSearchRightGrid")
	public void doSearchRightGrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("EV_TPL_NUM", req.getParameter("EV_TPL_NUM"));
		List<Map<String,Object>> gridData = ev0100service.doSearchRightGrid(param);

		for(int i = 0; i < gridData.size(); i++) {
			resp.setGridRowStyle("rightGrid", String.valueOf(i), "text-decoration", "inherit");
			//resp.setGridRowStyle("rightGrid", String.valueOf(i), "background-color", "#fdd");
		}

		resp.setGridObject("rightGrid", gridData);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/EV0120/doEdit")
	public void doEdit(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String msg = "";
		try {
			List<Map<String, Object>> gridData = req.getGridData("leftGrid");

			msg = ev0100service.doEdit(gridData);
		} catch (Exception e) {
			msg = e.getMessage();
		} finally {
			resp.setResponseMessage(msg);
			resp.setResponseCode("true");
		}
	}

	@RequestMapping(value = "/EV0120/doDelete")
	public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String msg = "";
		try {
			//Map<String, String> param = req.getFormData();
			List<Map<String, Object>> gridData = req.getGridData("leftGrid");

			msg = ev0100service.doDelete(gridData);
		} catch (Exception e) {
			msg = e.getMessage();
		} finally {
			resp.setResponseMessage(msg);
			resp.setResponseCode("true");
		}
	}

	@RequestMapping(value = "/EV0120/doCopy")
	public void doCopy(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String[] msg = new String[2] ;
		try {
			Map<String, String> param = req.getFormData();
			List<Map<String, Object>> gridDatas = req.getGridData("rightGrid");
			msg = ev0100service.doCopy(param, gridDatas);
		} catch (Exception e) {
			msg[1] = e.getMessage();
		} finally {
			resp.setParameter("EV_TPL_NO", msg[0]);
			resp.setResponseMessage(msg[1]);
			resp.setResponseCode("true");
		}
	}

	@RequestMapping(value = "/EV0120/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String[] msg = new String[2] ;
		try {
			Map<String, String> param = req.getFormData();
			List<Map<String, Object>> gridDatas = req.getGridData("rightGrid");
			msg = ev0100service.doSave(param, gridDatas);
		} catch (Exception e) {
			msg[1] = e.getMessage();
		} finally {
			resp.setParameter("EV_TPL_NO", msg[0]);
			resp.setResponseMessage(msg[1]);
			resp.setResponseCode("true");
		}
	}

	//EV0101
	@RequestMapping(value = "/EV0101/view")
	public String evalTemplateMgtAppendItem(EverHttpRequest req) throws Exception {
		String evalKind = req.getParameter("evalKind");
		if(evalKind.equals("E")){
			req.setAttribute("evalType", commonComboService.getCodeComboAsJson("M114"));
		}else if(evalKind.equals("S")) {
			req.setAttribute("evalType", commonComboService.getCodeComboAsJson("M113"));
		}else{
			req.setAttribute("evalType", commonComboService.getCodeComboAsJson("P091"));
		}
		req.setAttribute("evalKind", commonComboService.getCodeComboAsJson("M115"));
		req.setAttribute("evalMethod", commonComboService.getCodeComboAsJson("M116"));
		return "/evermp/buyer/eval/EV0101";
	}

	@RequestMapping(value = "/EV0101/doSearch")
	public void doSearchAppendItem(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("leftGrid", ev0100service.doSearchAppendItem(param));
		resp.setResponseCode("true");
	}




}
