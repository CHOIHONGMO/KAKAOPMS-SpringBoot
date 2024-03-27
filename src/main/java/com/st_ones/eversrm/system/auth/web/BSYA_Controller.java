package com.st_ones.eversrm.system.auth.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.auth.service.BSYA_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BSYA_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/auth")
public class BSYA_Controller extends BaseController {

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	private BSYA_Service bsya_Service;
	
	/**
	 * 권한프로파일관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYA_010/view")
	public String BSYA_010(EverHttpRequest req) throws Exception {
		
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		return "/eversrm/system/auth/BSYA_010";
	}

	@RequestMapping(value = "/BSYA_010/doSearch")
	public void doSearchAuthProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", bsya_Service.doSearchAuthProfileManagement(param));

	}

	@RequestMapping(value = "/BSYA_010/doSave")
	public void doSaveAuthProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsya_Service.doSaveAuthProfileManagement(gridData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSYA_010/doDelete")
	public void doDeleteAuthProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsya_Service.doDeleteAuthProfileManagement(gridData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
	
	/**
	 * 메뉴-권한 Mapping
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYA_020/view")
	public String BSYA_020(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		return "/eversrm/system/auth/BSYA_020";
	}

	@RequestMapping(value = "/BSYA_020/doSearchL")
	public void doSearchLMenuAuthMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData(); //formL

		resp.setGridObject("gridL", bsya_Service.doSearchLMenuAuthMapping(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSYA_020/doSearchR")
	public void doSearchRMenuAuthMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData(); //formR

		resp.setGridObject("gridR", bsya_Service.doSearchRMenuAuthMapping(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSYA_020/doSave")
	public void doSaveMenuAuthMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridLData = req.getGridData("gridL");
		String msg = bsya_Service.doSaveMenuAuthMapping(gridLData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSYA_020/doDelete")
	public void doDeleteMenuAuthMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridLData = req.getGridData("gridL");
		String msg = bsya_Service.doDeleteMenuAuthMapping(gridLData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
	
	/**
	 * 화면액션권한 Mapping
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSA_120/view")
	public String BSA_120(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		return "/eversrm/system/auth/BSA_120";
	}

	@RequestMapping(value = "/BSA_120/doSearchL")
	public void doSearcLBSA_120(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData(); //formL
		resp.setGridObject("gridL", bsya_Service.doSearchLScreenActionAuthMapping(param));
		resp.setResponseCode("true");
	}



	@RequestMapping(value = "/BSA_120/doSearchR")
	public void doSearcRBSA_120(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData(); //formL
		resp.setGridObject("gridR", bsya_Service.doSearchRScreenActionAuthMapping(param));
		resp.setResponseCode("true");
	}



	@RequestMapping(value = "/BSA_120/doSave")
	public void doSaveScreenActionAuthMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridLData = req.getGridData("gridR");
		Map<String, String> formData = req.getFormData();
		String msg = bsya_Service.doSaveScreenActionAuthMapping(gridLData, formData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}


	@RequestMapping(value = "/BSA_120/doDelete")
	public void doDeleteScreenActionAuthMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridLData = req.getGridData("gridL");
		String msg = bsya_Service.doDeleteScreenActionAuthMapping(gridLData);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * User Authorization
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSA_130/view")
	public String BSA_130(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
        ObjectMapper om = new ObjectMapper();
		req.setAttribute("refBuyerCd", om.writeValueAsString(commonComboService.getCodes("CB0002", new HashMap<String, String>())));

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		return "/eversrm/system/auth/BSA_130";
	}




	@RequestMapping(value = "/BSA_130/doSearchL")
	public void doSearcLBSA_130(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData(); //formL

		if (param.get("DEPT_CD") == null) {
			param.put("DEPT_CD", req.getParameter("DEPT_CD"));
		}

		resp.setGridObject("gridL", bsya_Service.listUserByDept(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSA_130/doSearchR")
	public void doSearcRBSA_130(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData(); //formL
		if (param.get("USER_ID") == null) {
			param.put("USER_ID", req.getParameter("USER_ID"));
		}

		resp.setGridObject("gridR", bsya_Service.listSTOCUSAC(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSA_130/saveUSAC")
	public void saveSTOCUSAC(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridLData = req.getGridData("gridR");
		String msg = bsya_Service.saveSTOCUSAC(gridLData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
	@RequestMapping(value = "/BSA_130/deleteUSAC")
	public void deleteUSAC(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridLData = req.getGridData("gridR");
		String msg = bsya_Service.deleteSTOCUSAC(gridLData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSA_130/saveUSAP")
	public void saveICOMSAP(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String authCode = req.getParameter("AUTH_CD");
		List<Map<String, Object>> gridLData = req.getGridData("gridL");
		String msg = bsya_Service.saveSTOCUSAP(gridLData, authCode);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/BSA_130/deleteUSAP")
	public void deleteICOMUSAP(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridLData = req.getGridData("gridL");
		String msg = bsya_Service.deleteSTOCUSAP(gridLData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
}