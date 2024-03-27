package com.st_ones.eversrm.system.menu.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.menu.service.BSYM_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.*;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BSYM_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/menu")
public class BSYM_Controller extends BaseController {

	@Autowired
	private BSYM_Service bsym_Service;

	@Autowired
	private CommonComboService commonComboService;

	/**
	 * 메뉴템플릿관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_010/view")
	public String BSYM_010(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		return "/eversrm/system/menu/BSYM_010";
	}

	@RequestMapping(value = "/menuTemplateManagement/doSelectMenuTemplate")
	public void doSelectMenuTemplate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridDatas = bsym_Service.getMenuTemplates(param);
		resp.setGridObject("grid", gridDatas);
	}

	@RequestMapping(value = "/menuTemplateManagement/doSaveMenuTemplate")
	public void doSaveMenuTemplate(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsym_Service.doSaveMenuTemplateMgmt(gridData);
		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/menuTemplateManagement/doCopyMenuTemplate")
	public void doCopyMenuTemplate(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsym_Service.doCopyMenuTemplateMgmt(gridData);
		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/menuTemplateManagement/doDeleteMenuTemplate")
	public void doDeleteMenuTemplate(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsym_Service.doDeleteMenuTemplateMgmt(gridData);
		resp.setResponseMessage(msg);
	}

	/**
	 * 메뉴템플릿상세
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_020/view")
	public String BSYM_020(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		req.setAttribute("refUseFlag", commonComboService.getCodeComboAsJson("M008"));
		return "/eversrm/system/menu/BSYM_020";
	}

	/**
	 * 메뉴템플릿상세-TREE
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_020_TREE/view")
	public String BSYM_020_TREE(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		req.setAttribute("refUseFlag", commonComboService.getCodeComboAsJson("M008"));
		return "/eversrm/system/menu/BSYM_020_TREE";
	}

	@RequestMapping(value = "/menuTemplateDetail/listMenuTemplateTree")
	public void listMenuTemplateTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		ObjectMapper om = new ObjectMapper();

		Map<String, String> param = req.getFormData();
		param.put("TMPL_MENU_GROUP_CD", req.getParameter("TMPL_MENU_GROUP_CD"));
		param.put("MODULE_TYPE", req.getParameter("MODULE_TYPE"));
		param.put("TMPL_MENU_CD", null);

		// 1Level의 데이터를 가져온다.
		List<Map<String, Object>> listOfLevel1 = bsym_Service.getMenuTemplateTree(param);
		listOfLevel1 = addChilds(listOfLevel1, param, "BSYM_020");

		resp.setParameter("treeData", om.writeValueAsString(listOfLevel1));
		resp.setResponseMessage("Success");
	}

	@RequestMapping(value = "/menuTemplateDetail/listMenuTemplateDtree")
	public void listMenuTemplateDtree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		ObjectMapper om = new ObjectMapper();

		Map<String, String> param = req.getFormData();
		param.put("TMPL_MENU_GROUP_CD", req.getParameter("TMPL_MENU_GROUP_CD"));
		param.put("MODULE_TYPE", req.getParameter("MODULE_TYPE"));
		param.put("TMPL_MENU_CD", null);

		List<Map<String, Object>> treeData = bsym_Service.getMenuTemplateDtree(param);

		resp.setParameter("treeData", om.writeValueAsString(treeData));
		resp.setResponseMessage("Success");
	}

	@RequestMapping(value = "/menuTemplateDetail/searchMenuTemplateTreeNode")
	public void searchMenuTemplateTreeNode(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		Map<String, Object> result = bsym_Service.searchMenuTemplateTreeNode(param);

		Map<String, String> saveParam = new HashMap<String, String>();
		saveParam.putAll(param);

		Iterator<String> iterator = saveParam.keySet().iterator();
		while (iterator.hasNext()) {
			String key = iterator.next();
			if (!result.containsKey(key)) {
				result.put(key, "");
			}
		}

		req.setAttribute("searchParam", result);
	}

	@RequestMapping(value = "/menuTemplateDetail/doSearchStocmuba")
	public void searchStocmuba(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bsym_Service.selectStocmuba(param));
	}


	@RequestMapping(value = "/menuTemplateDetail/createMenuTemplateTree")
	public void createMenuTemplateTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");

		if (!String.valueOf(param.get("DEPTH")).equals("0")) {
			param.put("HIGH_TMPL_MENU_CD", param.get("TMPL_MENU_CD"));
		}

		String tmplMenuCd = bsym_Service.getMenuTmplCode(param);
		param.put("TMPL_MENU_CD", tmplMenuCd);
		int rowCount = bsym_Service.existsMenuTemplateDetail(param);

		if (rowCount == 0) {
			param.put("DEPTH", "1");
			param.put("SORT_SQ", "1");
		} else {

			if (param.get("SORT_SQ").equals("0")) {
				param.put("SORT_SQ", param.get("HIDDEN_SORT_SQ"));
				bsym_Service.updateSortSeqPlusOne(param);
			} else {
				param.put("SORT_SQ", Integer.toString(Integer.parseInt(param.get("HIDDEN_SORT_SQ")) + 1));
				bsym_Service.updateSortSeqPlusOne(param);
			}
		}

		String msg = bsym_Service.createMenuTemplateDetail(param, gridData);

		resp.setResponseMessage(msg);
		resp.setParameter("tmplMenuCd", tmplMenuCd);
	}

	@RequestMapping(value = "/menuTemplateDetail/updateMenuTemplateDetail")
	public void updateMenuTemplateDetail(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		String tmplMenuCode = param.get("TMPL_MENU_CD");
		String msg = bsym_Service.updateMenuTemplateDetail(param, gridData);

		resp.setResponseMessage(msg);
		resp.setParameter("tmplMenuCd", tmplMenuCode);
	}

	@RequestMapping(value = "/menuTemplateDetail/deleteMenuTemplateDetail")
	public void deleteMenuTemplateDetail(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> searchParam = req.getFormData();
		String msg = bsym_Service.deleteMenuTemplateDetail(searchParam);

		resp.setResponseMessage(msg);
	}

	/**
	 * 메뉴그룹관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_030/view")
	public String BSYM_030(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}
		return "/eversrm/system/menu/BSYM_030";
	}

	@RequestMapping(value = "/menuRegistration/searchMenu")
	public void searchMenu(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", bsym_Service.searchMenu(param));
	}

	@RequestMapping(value = "/menuRegistration/doSaveMenu")
	public void doSaveMenu(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsym_Service.doSaveMenu(gridData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/menuRegistration/doCopyMenu")
	public void doCopyMenu(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsym_Service.doCopyMenu(gridData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/menuRegistration/deleteMenu")
	public void deleteMenu(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsym_Service.deleteMenu(gridData);

		resp.setResponseMessage(msg);
	}

	/**
	 * 메뉴그룹코드
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_040/view")
	public String BSYM_040(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		req.setAttribute("refUseFlag", commonComboService.getCodeComboAsJson("M008"));
		return "/eversrm/system/menu/BSYM_040";
	}

	/**
	 * 메뉴그룹코드-TREE
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_040_TREE/view")
	public String BSYM_040_TREE(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		req.setAttribute("refUseFlag", commonComboService.getCodeComboAsJson("M008"));
		return "/eversrm/system/menu/BSYM_040_TREE";
	}

	@RequestMapping(value = "/menuGroupCode/loadTree")
	public void loadTree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		ObjectMapper om = new ObjectMapper();

		Map<String, String> param = req.getFormData();
		param.put("MENU_GROUP_CD", req.getParameter("MENU_GROUP_CD"));
		param.put("TMPL_MENU_GROUP_CD", req.getParameter("TMPL_MENU_GROUP_CD"));
		param.put("MODULE_TYPE", req.getParameter("MODULE_TYPE"));

		List<Map<String, Object>> mapMenuTemplateTree = bsym_Service.getMenuTemplateTreePopup(param);
		mapMenuTemplateTree = addChilds(mapMenuTemplateTree, param, "BSYM_040R");

		List<Map<String, Object>> mapMenuTree = bsym_Service.getMenuTree(param);
		mapMenuTree = addChilds(mapMenuTree, param, "BSYM_040L");

		resp.setParameter("treeData", om.writeValueAsString(mapMenuTemplateTree));
		resp.setParameter("mumsData", om.writeValueAsString(mapMenuTree));
		resp.setGridObject("grid", new ArrayList<Map<String, Object>>());
		resp.setResponseMessage("Success");
	}

	@RequestMapping(value = "/menuGroupCode/loadDtree")
	public void loadDtree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		ObjectMapper om = new ObjectMapper();

		Map<String, String> param = req.getFormData();
		param.put("MENU_GROUP_CD", req.getParameter("MENU_GROUP_CD"));
		param.put("TMPL_MENU_GROUP_CD", req.getParameter("TMPL_MENU_GROUP_CD"));
		param.put("MODULE_TYPE", req.getParameter("MODULE_TYPE"));

		List<Map<String, Object>> mapMenuTemplateDtree = bsym_Service.getMenuTemplateDtreePopup(param);
		List<Map<String, Object>> mapMenuDtree = bsym_Service.getMenuDtree(param);

		resp.setParameter("treeData", om.writeValueAsString(mapMenuTemplateDtree)); // RIGHT
		resp.setParameter("mumsData", om.writeValueAsString(mapMenuDtree)); // LEFT
		resp.setGridObject("grid", new ArrayList<Map<String, Object>>());
		resp.setResponseMessage("Success");
	}

	@RequestMapping(value = "/menuGroupCode/doSaveMenuGroupCode")
	public void doSaveMenuGroupCode(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		UserInfo baseInfo = UserInfoManager.getUserInfoImpl();

		@SuppressWarnings("unchecked")
		List<Map<String, Object>> tLists = new ObjectMapper().readValue(req.getParameter("treeData"), List.class);
		List<Map<String, Object>> gridData = req.getGridData("grid");

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", baseInfo.getGateCd());
		param.put("MENU_GROUP_CD", req.getParameter("MENU_GROUP_CD"));
		param.put("MODULE_TYPE", req.getParameter("MODULE_TYPE"));

		String msg = bsym_Service.doSaveMenuGroupCode((tLists.size() > 0 ? tLists : gridData), param);

		resp.setParameter("retVal", "OK");
		resp.setResponseMessage(msg);

	}

	/**
	 * 메뉴템플릿코드 Search
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYM_050/view")
	public String BSYM_050(EverHttpRequest req) throws Exception {
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
		if(!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
			if (!baseInfo.isSuperUser() || !baseInfo.isOperator()) {
				return "/eversrm/noSuperAuth";
			}
		}

		req.setAttribute("refModuleType", commonComboService.getCodeComboAsJson("M009"));
		return "/eversrm/system/menu/BSYM_050";
	}

	@RequestMapping(value = "/menuTemplateGroupCode/doSelect")
	public void doSelect(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", bsym_Service.getMenuTemplates(param));

	}

	private List<Map<String, Object>> addChilds(List<Map<String, Object>> listOfLevel1, Map<String, String> searchParam, String type) throws Exception {

		ObjectMapper om = new ObjectMapper();

		for(int i = 0; i < listOfLevel1.size(); i++) {

			Map<String, Object> valudOfLevel1 = listOfLevel1.get(i);

			// 1Level의 데이터 중 isFolder가 true인 것은 2Level 데이터를 가져온다.
			if(EverString.nullToEmptyString(valudOfLevel1.get("isFolder")).equals("true")) {

				Map<String, String> paramOfLevel2 = new HashMap<String, String>();

				if(EverString.nullToEmptyString(type).equals("BSYM_020"))
				{
					paramOfLevel2.put("TMPL_MENU_GROUP_CD", searchParam.get("TMPL_MENU_GROUP_CD"));
					paramOfLevel2.put("MODULE_TYPE", searchParam.get("MODULE_TYPE"));
					paramOfLevel2.put("TMPL_MENU_CD", (String) valudOfLevel1.get("key"));
				}
				else if(EverString.nullToEmptyString(type).equals("BSYM_040R") || EverString.nullToEmptyString(type).equals("BSYM_040L")) {
					paramOfLevel2.put("TMPL_MENU_GROUP_CD", searchParam.get("TMPL_MENU_GROUP_CD"));
					paramOfLevel2.put("MENU_GROUP_CD", searchParam.get("MENU_GROUP_CD"));
					paramOfLevel2.put("MODULE_TYPE", searchParam.get("MODULE_TYPE"));
					paramOfLevel2.put("TMPL_MENU_CD", (String) valudOfLevel1.get("key"));
				}

				List<Map<String, Object>> listOfLevel2 = new ArrayList<Map<String, Object>>();
				if(EverString.nullToEmptyString(type).equals("BSYM_020")) {
					listOfLevel2 = bsym_Service.getMenuTemplateTree(paramOfLevel2);
				}
				else if(EverString.nullToEmptyString(type).equals("BSYM_040R")) {
					listOfLevel2 = bsym_Service.getMenuTemplateTreePopup(paramOfLevel2);
				}
				else if(EverString.nullToEmptyString(type).equals("BSYM_040L")) {
					listOfLevel2 = bsym_Service.getMenuTree(paramOfLevel2);
				}

				if(listOfLevel2.size() > 0) {

					for(int j = 0; j < listOfLevel2.size(); j++) {

						Map<String, Object> valudOfLevel2 = listOfLevel2.get(j);

						// 2Level 데이터 중 isFolder가 true인 것은 3Level 데이터를 가져온다.
						if(EverString.nullToEmptyString(valudOfLevel2.get("isFolder")).equals("true")) {

							Map<String, String> paramOfLevel3 = new HashMap<String, String>();

							if(EverString.nullToEmptyString(type).equals("BSYM_020")) {
								paramOfLevel3.put("TMPL_MENU_GROUP_CD", searchParam.get("TMPL_MENU_GROUP_CD"));
								paramOfLevel3.put("MODULE_TYPE", searchParam.get("MODULE_TYPE"));
								paramOfLevel3.put("TMPL_MENU_CD", (String) valudOfLevel2.get("key"));
							}
							else if(EverString.nullToEmptyString(type).equals("BSYM_040R") || EverString.nullToEmptyString(type).equals("BSYM_040L")) {
								paramOfLevel3.put("TMPL_MENU_GROUP_CD", searchParam.get("TMPL_MENU_GROUP_CD"));
								paramOfLevel3.put("MENU_GROUP_CD", searchParam.get("MENU_GROUP_CD"));
								paramOfLevel3.put("MODULE_TYPE", searchParam.get("MODULE_TYPE"));
								paramOfLevel3.put("TMPL_MENU_CD", (String) valudOfLevel2.get("key"));
							}

							List<Map<String, Object>> listOfLevel3 = new ArrayList<Map<String, Object>>();
							if(EverString.nullToEmptyString(type).equals("BSYM_020")) {
								listOfLevel3 = bsym_Service.getMenuTemplateTree(paramOfLevel3);
							}
							else if(EverString.nullToEmptyString(type).equals("BSYM_040R")) {
								listOfLevel3 = bsym_Service.getMenuTemplateTreePopup(paramOfLevel3);
							}
							else if(EverString.nullToEmptyString(type).equals("BSYM_040L")) {
								listOfLevel3 = bsym_Service.getMenuTree(paramOfLevel3);
							}

							if(listOfLevel3.size() > 0) {

								for(int k = 0; k < listOfLevel3.size(); k++) {

									Map<String, Object> valudOfLevel3 = listOfLevel3.get(k);

									// 3Level 데이터 중 isFolder가 true인 것은 4Level 데이터를 가져온다.
									if(EverString.nullToEmptyString(valudOfLevel3.get("isFolder")).equals("true")) {

										Map<String, String> paramOfLevel4 = new HashMap<String, String>();

										if(EverString.nullToEmptyString(type).equals("BSYM_020")) {
											paramOfLevel4.put("TMPL_MENU_GROUP_CD", searchParam.get("TMPL_MENU_GROUP_CD"));
											paramOfLevel4.put("MODULE_TYPE", searchParam.get("MODULE_TYPE"));
											paramOfLevel4.put("TMPL_MENU_CD", (String) valudOfLevel3.get("key"));
										}
										else if(EverString.nullToEmptyString(type).equals("BSYM_040R") || EverString.nullToEmptyString(type).equals("BSYM_040L")) {
											paramOfLevel4.put("TMPL_MENU_GROUP_CD", searchParam.get("TMPL_MENU_GROUP_CD"));
											paramOfLevel4.put("MENU_GROUP_CD", searchParam.get("MENU_GROUP_CD"));
											paramOfLevel4.put("MODULE_TYPE", searchParam.get("MODULE_TYPE"));
											paramOfLevel4.put("TMPL_MENU_CD", (String) valudOfLevel3.get("key"));
										}

										List<Map<String, Object>> listOfLevel4 = null;
										if(EverString.nullToEmptyString(type).equals("BSYM_020")) {
											listOfLevel4 = bsym_Service.getMenuTemplateTree(paramOfLevel4);
										}
										else if(EverString.nullToEmptyString(type).equals("BSYM_040R")) {
											listOfLevel4 = bsym_Service.getMenuTemplateTreePopup(paramOfLevel4);
										}
										else if(EverString.nullToEmptyString(type).equals("BSYM_040L")) {
											listOfLevel4 = bsym_Service.getMenuTree(paramOfLevel4);
										}

										// 3Level 데이터의 childs에 4Level 데이터를 넣는다.
										listOfLevel3.get(k).put("childs", om.writeValueAsString(listOfLevel4));
									}
								}
							}
							// 2Level 데이터의 childs에 3Level 데이터를 넣는다.
							listOfLevel2.get(j).put("childs", om.writeValueAsString(listOfLevel3));
						}
					}
				}
				// 1Level 데이터의 childs에 2Level 데이터를 넣는다.
				listOfLevel1.get(i).put("childs", om.writeValueAsString(listOfLevel2));
			}
		}
		return listOfLevel1;
	}

}