package com.st_ones.eversrm.system.popup.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.popup.service.BSYP_Service;
import jakarta.transaction.TransactionRolledbackException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
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
 * @File Name : BSYP_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/popup")
public class BSYP_Controller extends BaseController {

	@Autowired
	BSYP_Service commonPopupMgtService;

	@Autowired
	private CommonComboService commonComboService;
	
	/**
	 * 공통팝업관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYP_020/view")
	public String popupMgmtView(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("databaseCodeData", commonComboService.getCodeComboAsJson("M002"));
		req.setAttribute("typeOfData", commonComboService.getCodeComboAsJson("M003"));
		req.setAttribute("yesNoData", commonComboService.getCodeComboAsJson("M044"));


		String common_id = req.getParameter("COMMON_ID");
		String database_cd = req.getParameter("DATABASE_CD");
		String defaultDatabaseId = PropertiesManager.getString("eversrm.system.database");

		if ( common_id != null && !"".equals(common_id) ) {
			Map<String, String> param = new HashMap<String,String>();
			param.put("COMMON_ID", common_id);
			param.put("DATABASE_CD", database_cd);

			Map<String, String> data = commonPopupMgtService.getComboDetailInfo(param);
			if(data == null) {
				data = new HashMap<String,String>();
				data.put("DATABASE_CD", defaultDatabaseId);
				req.setAttribute("detailData",  data );
			} else {
				req.setAttribute("detailData",  data );
			}
		} else {
			Map<String, String> param = new HashMap<String,String>();
			param.put("DATABASE_CD", defaultDatabaseId);
			req.setAttribute("detailData",  param );
		}

		return "/eversrm/system/popup/BSYP_020";
	}

	@RequestMapping(value = "/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setResponseMessage(commonPopupMgtService.doSaveCommonCodeSql(param));
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/doDelete")
	public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setResponseMessage(commonPopupMgtService.doDeleteCommonCodeSql(param));
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/doVerify")
	public void doVerify(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		String sqlText = param.get("SQL_TEXT").toUpperCase();
		getLog().error(sqlText);
		sqlText = sqlText.replaceAll("#[._0-9a-zA-Z]*#", "''");
		sqlText = sqlText.replaceAll("<ARG.*>", "");
		sqlText = sqlText.replaceAll("</ARG.>", "");
		getLog().error("after:");
		getLog().error(sqlText);
		param.put("SQL_TEXT", sqlText);

		try {
			commonPopupMgtService.doVerifyCommonCodeSql(param);
		} catch (TransactionRolledbackException e) {
			throw e;
		}

		resp.setResponseCode("0001");
	}
	
	/**
	 * 공통팝업현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYP_030/view")
	public String popupListView(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("languageCodes", commonComboService.getCodeComboAsJson("M001"));
		req.setAttribute("databaseCodes", commonComboService.getCodeComboAsJson("M002"));
		req.setAttribute("typeOfData", commonComboService.getCodeComboAsJson("M003"));
		return "/eversrm/system/popup/BSYP_030";
	}

	@RequestMapping(value = "/BSYP_030/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		makeGridTextLinkStyle(resp, "grid1", "COMMON_ID");
	    resp.setGridObject("grid1", commonPopupMgtService.doSearch(param));
	    resp.setResponseCode("0001");
	}

	//이미지 텍스트그리드
	private void makeGridTextLinkStyle(EverHttpResponse resp, String grid, String columnName) {
        resp.setGridColStyle(grid, columnName, "cursor", "pointer");
        resp.setGridColStyle(grid, columnName, "color", "#000DFF");
        resp.setGridColStyle(grid, columnName, "text-decoration", "underline");
	}

}