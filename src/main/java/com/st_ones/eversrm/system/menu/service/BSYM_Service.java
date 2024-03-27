package com.st_ones.eversrm.system.menu.service;

import com.st_ones.common.cache.data.BreadCrumbCache;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.menu.BSYM_Mapper;
import com.st_ones.eversrm.system.multiLang.BSYL_Mapper;
import com.st_ones.eversrm.system.multiLang.service.BSYL_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
* @File Name : BSYM_Service.java
* @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
* @date 2013. 07. 22.
* @version 1.0
* @see
*/

@Service(value = "bsym_Service")
public class BSYM_Service extends BaseService {

//	private static final String EVER_DBLINK = "ever.remote.database.link.name";

	@Autowired private BSYM_Mapper bsym_Mapper;
//	@Autowired private EverConfigService everConfigService;
	@Autowired DocNumService docNumService;
	@Autowired MessageService msg;
	@Autowired BSYL_Service multiLanguageService;
	@Autowired BSYM_Mapper menuManagementMapper;
	@Autowired BSYL_Mapper multiLanguageMapper;
	@Autowired BreadCrumbCache breadCrumbCache;

	public List<Map<String, Object>> getMenuTemplates(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTemplates(param);
	}

	@SuppressWarnings("rawtypes")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveMenuTemplateMgmt(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCMUTG");

			if (String.valueOf(gridData.get("INSERT_FLAG")).equals("C")) {
				// Setting document number.
				String docNum = docNumService.getDocNumber("TG");
				gridData.put("TMPL_MENU_GROUP_CD", docNum);

				bsym_Mapper.createMenuTemplate(gridData);

			} else if (String.valueOf(gridData.get("INSERT_FLAG")).equals("U")) {
				bsym_Mapper.updateMenuTemplate(gridData);
				bsym_Mapper.updateMenuTemplateList(gridData);
			}
		}
		return msg.getMessage("0001");
	}

	@SuppressWarnings("rawtypes")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCopyMenuTemplateMgmt(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			String originTmplMenuGroupCd = (String) gridData.get("TMPL_MENU_GROUP_CD");
			Map<String, String> param = new HashMap<String, String>();
			String newTmplMenuGroupCd = docNumService.getDocNumber("TG");
			gridData.put("TABLE_NM", "STOCMUTG");
			gridData.put("TMPL_MENU_GROUP_CD", newTmplMenuGroupCd);
			bsym_Mapper.createMenuTemplate(gridData);

			param.put("TMPL_MENU_GROUP_CD", originTmplMenuGroupCd);
			List<Map<String, Object>> menuDetailList = bsym_Mapper.getStocmutm(param);
			Map<String, String> hisMap = new HashMap<String, String>();

			for(Map<String, Object> memuDetail : menuDetailList) {
				Map<String, String> mutmParam = new HashMap<String, String>();

				String newTmplMenuCd = this.getMenuTmplCode(param);
				mutmParam.put("TMPL_MENU_CD",  newTmplMenuCd);
				mutmParam.put("OLD_TMPL_MENU_CD",  (String) memuDetail.get("TMPL_MENU_CD"));
				mutmParam.put("DEPTH",  String.valueOf(memuDetail.get("DEPTH")));

				hisMap.put((String) memuDetail.get("TMPL_MENU_CD"), newTmplMenuCd);

				String highTmplMenuCd = (String) memuDetail.get("HIGH_TMPL_MENU_CD");
				String newHighTmplMenuCd = EverString.nullToEmptyString(hisMap.get(highTmplMenuCd));

				mutmParam.put("HIGH_TMPL_MENU_CD", newHighTmplMenuCd);
				mutmParam.put("LEAF_FLAG",  (String) memuDetail.get("LEAF_FLAG"));
				mutmParam.put("USE_FLAG",  (String) memuDetail.get("USE_FLAG"));
				mutmParam.put("SORT_SQ",  String.valueOf(memuDetail.get("SORT_SQ")));
				mutmParam.put("TMPL_MENU_GROUP_CD",  newTmplMenuGroupCd);
				mutmParam.put("SCREEN_ID",  (String) memuDetail.get("SCREEN_ID"));
				mutmParam.put("MODULE_TYPE",  (String) memuDetail.get("MODULE_TYPE"));
				mutmParam.put("TABLE_NM", "STOCMUTM");

				int rtn = bsym_Mapper.createMenuTemplateDetail(mutmParam);
				getLog().info("[rtn] - " + rtn);

				int rtnMulg = bsym_Mapper.copyMenuTemplateDetailMulg(mutmParam);
				getLog().info("[rtnMulg] - " + rtnMulg);
			}
		}

		return msg.getMessage("0001");
	}

	@SuppressWarnings("rawtypes")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteMenuTemplateMgmt(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCMUTG");
			bsym_Mapper.deleteMenuTemplateDetailList(gridData);
			bsym_Mapper.deleteMenuTemplate(gridData);

		}
		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> getMenuTemplateTree(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTemplateTree(param);
	}

	public List<Map<String, Object>> getMenuTemplateDtree(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTemplateDtree(param);
	}

	public Map<String, Object> searchMenuTemplateTreeNode(Map<String, String> param) throws Exception {
		return bsym_Mapper.searchMenuTemplateTreeNode(param);
	}

	public List<Map<String, Object>> selectStocmuba(Map<String, String> param) throws Exception {
		return bsym_Mapper.selectStocmuba(param);
	}

	public String getMenuTmplCode(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTmplCode(param);
	}

	public int existsMenuTemplateDetail(Map<String, String> param) throws Exception {
		return bsym_Mapper.existsMenuTemplateDetail(param);
	}

	public int updateSortSeqPlusOne(Map<String, String> param) throws Exception {
		int rtn;
		/* This parameter is use for sync of each database server. */
		param.put("TABLE_NM", "STOCMUTM");
		rtn = bsym_Mapper.updateSortSeqPlusOne(param);

		return rtn;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String createMenuTemplateDetail(Map<String, String> params, List<Map<String, Object>> gridDatas) throws Exception {

		/* This parameter is use for sync of each database server. */
		params.put("TABLE_NM", "STOCMUTM");

		int rtn = bsym_Mapper.createMenuTemplateDetail(params);
		getLog().info("[rtn] - " + rtn);

		int rtnMulg = bsym_Mapper.createMenuTemplateDetailMulg(params);
		getLog().info("[rtnMulg] - " + rtnMulg);

		breadCrumbCache.removeData(params.get("SCREEN_ID"), params.get("MODULE_TYPE"));

		if(gridDatas != null) {
			bsym_Mapper.deleteStocmuba(params);
		}

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("TMPL_MENU_CD", params.get("TMPL_MENU_CD"));
			bsym_Mapper.insertStocmuba(gridData);
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String updateMenuTemplateDetail(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception {

		/* This parameter is use for sync of each database server. */
		param.put("TABLE_NM", "STOCMUTM");
		// param.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

        bsym_Mapper.updateMenuTemplateDetail(param);
		breadCrumbCache.initData();

		if(gridDatas != null) {
			bsym_Mapper.deleteStocmuba(param);
		}

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("TMPL_MENU_CD", param.get("TMPL_MENU_CD"));
			bsym_Mapper.insertStocmuba(gridData);
		}

		return msg.getMessage("0016");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteMenuTemplateDetail(Map<String, String> param) throws Exception {

		/* This parameter is use for sync of each database server. */
		param.put("TABLE_NM", "STOCMUTM");
		bsym_Mapper.deleteMenuTemplateDetail(param);
		bsym_Mapper.deleteStocmuba(param);
		breadCrumbCache.initData();
		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> searchMenu(Map<String, String> param) throws Exception {
		return bsym_Mapper.searchMenu(param);
	}

	@SuppressWarnings("rawtypes")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveMenu(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCMUGR");

			if (String.valueOf(gridData.get("INSERT_FLAG")).equals("C")) {
				// Setting document number.
				String docNum = docNumService.getDocNumber("MG");
				gridData.put("MENU_GROUP_CD", docNum);

				bsym_Mapper.createMenu(gridData);

			} else if (String.valueOf(gridData.get("INSERT_FLAG")).equals("U")) {

				bsym_Mapper.updateMenu(gridData);
			}
		}
		breadCrumbCache.initData();
		return msg.getMessage("0001");
	}

	@SuppressWarnings("rawtypes")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCopyMenu(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			String oldMenuGroupCd = (String)gridData.get("MENU_GROUP_CD");
			gridData.put("TABLE_NM", "STOCMUGR");
			String newMenuGroupCd = docNumService.getDocNumber("MG");
			gridData.put("MENU_GROUP_CD", newMenuGroupCd);
			bsym_Mapper.createMenu(gridData);
			gridData.put("OLD_MENU_GROUP_CD", oldMenuGroupCd);
			bsym_Mapper.copyMenuMums(gridData);
		}

		breadCrumbCache.initData();
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String updateMenu(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NAME", "STOCMUGR");
			bsym_Mapper.updateMenu(gridData);
		}
		breadCrumbCache.initData();
		return msg.getMessage("0001");
	}

	@SuppressWarnings("rawtypes")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteMenu(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCMUGR");

			bsym_Mapper.deleteMenuMums(gridData);
			bsym_Mapper.deleteMenu(gridData);
		}
		breadCrumbCache.initData();
		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> getMenuTree(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTree(param);
	}

	public List<Map<String, Object>> getMenuDtree(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuDtree(param);
	}

	public List<Map<String, Object>> getMenuTreeForHiddenGrid(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTreeForHiddenGrid(param);
	}

	public List<Map<String, Object>> getMenuTemplateTreePopup(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTemplateTreePopup(param);
	}

	public List<Map<String, Object>> getMenuTemplateDtreePopup(Map<String, String> param) throws Exception {
		return bsym_Mapper.getMenuTemplateDtreePopup(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveMenuGroupCode(List<Map<String, Object>> gridDatas, Map<String, String> param) throws Exception {

		param.put("TABLE_NM", "STOCMUMS");
		// param.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));

		// Remove temporarily the items from this MUMS.MENU_GROUP_CD - DB sync
		bsym_Mapper.deleteMenuTree(param);

		for (Map<String, Object> gridData : gridDatas) {

			// MUMS info
			gridData.put("GATE_CD", param.get("GATE_CD"));
			gridData.put("MENU_GROUP_CD", param.get("MENU_GROUP_CD"));
			gridData.put("MODULE_TYPE", param.get("MODULE_TYPE"));
			gridData.put("MENU_CD", gridData.get("MENU_CD"));
			gridData.put("TMPL_MENU_CD", gridData.get("TMPL_MENU_CD"));
			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCMUMS");

			int checkExists = bsym_Mapper.existsMenuGroupCode(gridData);
			if (checkExists > 0) {
				bsym_Mapper.updateMenuGroupCode(gridData);
			} else {
				bsym_Mapper.createMenuGroupCode(gridData);
			}
		}

		return msg.getMessage("0001");
	}
}