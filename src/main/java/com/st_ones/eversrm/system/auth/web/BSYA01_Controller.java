package com.st_ones.eversrm.system.auth.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.auth.service.BSYA01_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 *
 * @File Name : A0303_Service.java
 * @author 김경지
 * @date 2017. 06. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/auth")
public class BSYA01_Controller extends BaseController {

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	private BSYA01_Service bsya01_Service;
	
	/**
	 * 메뉴/버튼 권한설정
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYA_030/view")
	public String BSYA_030(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		return "/eversrm/system/auth/BSYA_030";
	}

	@RequestMapping(value = "/BSYA_030/doSearch_UserList")
	public void doSearch_UserList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		resp.setLinkStyle("s_userGrid", "USER_ID_V");
		resp.setGridObject("s_userGrid", bsya01_Service.doSearch_UserList(req.getFormData()));
	}

	//직무검색
	@RequestMapping(value = "/BSYA_030/doSearch_CtrlList")
	public void doSearch_CtrlList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("s_ctrlGrid", bsya01_Service.doSearch_CtrlList(req.getFormData()));
	}

	//버튼검색
	@RequestMapping(value = "/BSYA_030/doSearch_ButtonList")
	public void doSearch_ButtonList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("buttonGrid", bsya01_Service.doSearch_ButtonList(req.getFormData()));
	}

	//메뉴-사용자매핑 조회
	@RequestMapping(value = "/BSYA_030/doSearch_Menu_UserList")
	public void doSearch_Menu_UserList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("userGrid", bsya01_Service.doSearch_Menu_UserList(req.getFormData()));
	}

	//메뉴-직무매핑 조회
	@RequestMapping(value = "/BSYA_030/doSearch_Menu_CtrlList")
	public void doSearch_Menu_CtrlList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("ctrlGrid", bsya01_Service.doSearch_Menu_CtrlList(req.getFormData()));
	}

	//버튼-사용자매핑 조회(Tab2)
	@RequestMapping(value = "/BSYA_030/doSearch_Button_UserList_Tab1")
	public void doSearch_Button_UserList_Tab1(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("userGrid", bsya01_Service.doSearch_Button_UserList(req.getFormData()));
	}

	//버튼-직무매핑 조회(Tab2)
	@RequestMapping(value = "/BSYA_030/doSearch_Button_CtrlList_Tab1")
	public void doSearch_Button_CtrlList_Tab1(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("ctrlGrid", bsya01_Service.doSearch_Button_CtrlList(req.getFormData()));
	}

	//메뉴검색-트리
	@RequestMapping(value = "/BSYA_030/doSearch_menuTree")
	public void doSearch_menuTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formTree = req.getFormData();
		List<Map<String,Object>> treeData = bsya01_Service.doSearch_menuTree(formTree);
		resp.setParameter("treeData", EverConverter.getJsonString(treeData));
	}

	//메뉴 - 직무/사용자 권한 등록(Tab1)
	@RequestMapping(value = "/BSYA_030/doSave_Menu_Auth")
	public void doSave_Menu_Auth(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> menuGrid = req.getGridData("menuGrid");
		List<Map<String, Object>> historymenuGrid = req.getGridData("historymenuGrid");


		String msg = bsya01_Service.doSave_Menu_Auth(formData, menuGrid, historymenuGrid);
		resp.setResponseMessage(msg);
	}

	//직무 - 메뉴 권한 등록(Tab1)
	@RequestMapping(value = "/BSYA_030/doSave_Menu_Auth_CTRL")
	public void doSave_Menu_Auth_CTRL(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> ctrlGrid = req.getGridData("ctrlGrid");
		String msg = bsya01_Service.doSave_Menu_Auth_CTRL(formData, ctrlGrid);

		resp.setResponseMessage(msg);
	}



	//버튼검색(Tab2)
	@RequestMapping(value = "/BSYA_030/doSearch_ButtonList_tab2")
	public void doSearch_ButtonList_tab2(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("tab2_buttonGrid", bsya01_Service.doSearch_ButtonList(req.getFormData()));
	}

	//버튼-사용자매핑 조회(Tab2)
	@RequestMapping(value = "/BSYA_030/doSearch_Button_UserList_Tab2")
	public void doSearch_Button_UserList_Tab2(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("tab2_userGrid", bsya01_Service.doSearch_Button_UserList(req.getFormData()));
	}

	//버튼-직무매핑 조회(Tab2)
	@RequestMapping(value = "/BSYA_030/doSearch_Button_CtrlList_Tab2")
	public void doSearch_Button_CtrlList_Tab2(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("tab2_ctrlGrid", bsya01_Service.doSearch_Button_CtrlList(req.getFormData()));
	}

	//버튼 - 직무/사용자 권한 등록(Tab2)
	@RequestMapping(value = "/BSYA_030/doSave_Button_Auth")
	public void doSave_Button_Auth(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> buttonGrid = req.getGridData("tab2_buttonGrid");
		List<Map<String, Object>> ctrlgrid = req.getGridData("tab2_ctrlGrid");
		List<Map<String, Object>> usergrid = req.getGridData("tab2_userGrid");

		String msg = bsya01_Service.doSave_Button_Auth(formData, buttonGrid, ctrlgrid, usergrid);
		resp.setResponseMessage(msg);
	}

	//버튼 - 직무/사용자 권한 삭제(Tab2)
	@RequestMapping(value = "/BSYA_030/doDelete_Button_Auth")
	public void doDelete_Button_Auth(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> buttonGrid = req.getGridData("tab2_buttonGrid");
		List<Map<String, Object>> ctrlgrid = req.getGridData("tab2_ctrlGrid");
		List<Map<String, Object>> usergrid = req.getGridData("tab2_userGrid");

		String msg = bsya01_Service.doDelete_Button_Auth(formData, buttonGrid, ctrlgrid, usergrid);
		resp.setResponseMessage(msg);
	}

	//메뉴/버튼 권한 이력
	@RequestMapping(value = "/BSYA_040/view")
	public String BSYA_040(EverHttpRequest req) throws Exception {

		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo userInfo = UserInfoManager.getUserInfo();
			if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		return "/eversrm/system/auth/BSYA_040";
	}

	//버튼-직무매핑 조회(Tab2)
	@RequestMapping(value = "/BSYA_040/doSearch")
	public void BSYA_040doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		resp.setGridObject("meGrid", bsya01_Service.doSearch_MenuHistory(req.getFormData()));
		resp.setGridObject("buGrid", bsya01_Service.doSearch_ButtonHistory(req.getFormData()));
	}

}
