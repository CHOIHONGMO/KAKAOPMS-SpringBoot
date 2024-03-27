package com.st_ones.eversrm.system.screen.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.screen.service.BSYS_Service;
import org.apache.commons.lang.StringUtils;
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
 * @File Name : BSYS_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/screen")
public class BSYS_Controller extends BaseController {

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	private BSYS_Service bsys_Service;

	@Autowired
	LargeTextService largeTextService;

	/**
	 * 화면관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYS_010/view")
	public String BSYS_010(EverHttpRequest req) throws Exception {
		// 관리자 권한이 존재하지 않으면 접속 불가
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
			if (baseInfo.getSuperUserFlag().equals("0")) {
				return "/everqis/noSuperAuth";
			}
		}

		BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
		boolean havePermission = EverString.nullToEmptyString(baseInfo.getSuperUserFlag()).equals("1");
		req.setAttribute("havePermission", havePermission);

		return "/eversrm/system/screen/BSYS_010";
	}

	@RequestMapping(value = "/screenManagement/doSearch")
	public void doSearchScreenManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bsys_Service.doSearchScreenManagement(param));
	}

	@RequestMapping(value = "/screenManagement/doInsert")
	public void doInsertScreenManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsys_Service.doSaveScreenManagement(gridData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/screenManagement/doUpdate")
	public void doUpdateScreenManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsys_Service.doSaveScreenManagement(gridData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/screenManagement/doDelete")
	public void doDeleteScreenManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsys_Service.doDeleteScreenManagement(gridData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/screenManagement/doCopy")
	public void doCopyScreenManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");

		String msg = bsys_Service.doCopyScreenManagement(formData, gridData);

		resp.setResponseMessage(msg);
	}

	/**
	 * 화면액션관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYS_020/view")
	public String screenActionManagement(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
			if (baseInfo.getSuperUserFlag().equals("0")) {
				return "/everqis/noSuperAuth";
			}
		}
		return "/eversrm/system/screen/BSYS_020";
	}

	@RequestMapping(value = "/screenActionManagement/iconPopup/view")
	public String iconPopup(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
			if (baseInfo.getSuperUserFlag().equals("0")) {
				return "/everqis/noSuperAuth";
			}
		}
		req.setAttribute("refModuleType", commonComboService.getCodeCombo("M009"));
		return "/eversrm/system/screen/iconPopup";
	}

	@RequestMapping(value = "/screenActionManagement/doSearch")
	public void doSearchScreenActionManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String tagGuide = "";
		Map<String, String> param = req.getFormData();

		List<Map<String, Object>> gridData = bsys_Service.doSearchScreenActionManagement(param);
		for (Map<String, Object> gridDatum : gridData) {
			String clickFunctionName = (String)gridDatum.get("ACTION_CD");
			if(!StringUtils.startsWith(clickFunctionName, "do")) {
				clickFunctionName = "do" + clickFunctionName;
			}
			tagGuide = "<e:button id=\"" + gridDatum.get("ACTION_CD") + "\" name=\"" + gridDatum.get("ACTION_CD") + "\" label=\"${" + gridDatum.get("ACTION_CD") + "_N}\""  + " onClick=\"" + clickFunctionName + "\" disabled=\"${" + gridDatum.get("ACTION_CD") + "_D}\" visible=\"${"
					+ gridDatum.get("ACTION_CD") + "_V}\"/>";
			gridDatum.put("BUTTON_TAG", tagGuide);
		}

		resp.setGridObject("grid", gridData);
	}

	@RequestMapping(value = "/screenActionManagement/doSave")
	public void doSaveScreenActionManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsys_Service.doSaveScreenActionManagement(gridData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/screenActionManagement/doDelete")
	public void doDeleteScreenActionManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsys_Service.doDeleteScreenActionManagement(gridData);

		resp.setResponseMessage(msg);
	}

	/**
	 * Screen ID Popup
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYS_030/view")
	public String BSYS_030(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			BaseInfo baseInfo = (BaseInfo) req.getSession().getAttribute("ses");
			if (baseInfo.getSuperUserFlag().equals("0")) {
				return "/everqis/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		return "/eversrm/system/screen/BSYS_030";
	}

	@RequestMapping(value = "/screenIdPopup/doSearch")
	public void doSearchScreenIdPopup(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", bsys_Service.doSearchScreenIdPopup(param));
	}

	@RequestMapping(value = "/BSYS_040/view")
	public String BSYS_040(EverHttpRequest req) throws Exception {

		String paramScreenId = EverString.nullToEmptyString(req.getParameter("PARAM_SCREEN_ID"));

		if (paramScreenId != null && !"".equals(paramScreenId)) {

			Map<String, String> formData = bsys_Service.selectHelpInfo(paramScreenId);
			String splitString = largeTextService.selectLargeText(formData.get("HELP_TEXT_NUM"));
			formData.put("CONTENTS", splitString);

			req.setAttribute("formData", formData);

		} else {
			req.setAttribute("formData", new HashMap<String, String>());
		}
		return "/eversrm/system/screen/BSYS_040";
	}

	@RequestMapping(value = "/helpInfo/doSave")
	public void doSaveHelpInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		String msg = bsys_Service.doSaveHelpInfo(formData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/helpInfo/doDelete")
	public void doDeleteHelpInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		String msg = bsys_Service.doDeleteHelpInfo(formData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/BSYS_050/view")
	public String BSYS_050(EverHttpRequest req) throws Exception {
		return "/eversrm/system/screen/BSYS_050";
	}

	@RequestMapping(value = "/BSA_220/view")
	public String actionProfileManagement() throws Exception {
		return "/eversrm/system/screen/BSA_220";
	}

	@RequestMapping(value = "/actionProfileManagement/doSearchT")
	public void doSearchTActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setGridObject("gridT", bsys_Service.doSearchTActionProfileManagement(param));
	}

	@RequestMapping(value = "/actionProfileManagement/doSearchL")
	public void doSearchLActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("gridL", bsys_Service.doSearchLActionProfileManagement(param));
	}

	@RequestMapping(value = "/actionProfileManagement/doSearchR")
	public void doSearchRActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("gridR", bsys_Service.doSearchRActionProfileManagement(param));
	}

	@RequestMapping(value = "/actionProfileManagement/doSaveT")
	public void doSaveTActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridTData = req.getGridData("gridT");
		String msg = bsys_Service.doSaveTActionProfileManagement(gridTData);

		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/actionProfileManagement/doDeleteT")
	public void doDeleteTActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridTData = req.getGridData("gridT");
		String msg = bsys_Service.doDeleteTActionProfileManagement(gridTData);
		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/actionProfileManagement/doSaveL")
	public void doSaveLActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridRData = req.getGridData("gridR");
		String actionProfileCd = req.getParameter("ACTION_PROFILE_CD");
		String msg = bsys_Service.doSaveLActionProfileManagement(actionProfileCd, gridRData);
		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/actionProfileManagement/doDeleteL")
	public void doDeleteLActionProfileManagement(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridLData = req.getGridData("gridL");
		String msg = bsys_Service.doDeleteLActionProfileManagement(gridLData);
		resp.setResponseMessage(msg);
	}

}