package com.st_ones.eversrm.system.auth.service;

import com.st_ones.common.cache.data.BreadCrumbCache;
import com.st_ones.common.cache.data.MulgSaCache;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.multiLanguage.MultiLanguageMapper;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.system.auth.BSYA_Mapper;
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
 * @File Name : BSYA_Service.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "bsya_Service")
public class BSYA_Service extends BaseService {

	/* @formatter:off */
	@Autowired BSYA_Mapper bsya_Mapper;
	@Autowired MessageService msg;
	@Autowired DocNumService docNumService;
	@Autowired MultiLanguageMapper multiLanguageMapper;
	@Autowired MulgSaCache mulgSaCache;
	@Autowired BreadCrumbCache breadCrumbCache;
//	@Autowired private EverConfigService everConfigService;
	/* @formatter:off */
	
//	private static final String EVER_DBLINK = "ever.remote.database.link.name";
	
	public List<Map<String, Object>> doSearchAuthProfileManagement(Map<String, String> param) throws Exception {
		return bsya_Mapper.doSearchAuthProfileManagement(param);
	}	
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveAuthProfileManagement(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			/* This parameter is use for sync of each database server. */ 
			gridData.put("TABLE_NM", "STOCAUPF");
			
			String docNum = "";
			Map<String, Object> formdata = new HashMap<String, Object>();
			int checkCnt = bsya_Mapper.checkAuthProfileManagement(gridData);
			
			if (checkCnt == 0) {

				docNum = docNumService.getDocNumber("AU");
				gridData.put("AUTH_CD", docNum);

				UserInfo baseInfo = UserInfoManager.getUserInfoImpl();
				String langCd = baseInfo.getLangCd();
				formdata.put("LANG_CD", langCd);
				formdata.put("MULTI_NAME", gridData.get("AUTH_NM"));
				formdata.put("SCREEN_ID", "-");
				formdata.put("DEL_FLAG", "0");
				formdata.put("MULTI_CD", "AU");
				formdata.put("ACTION_PROFILE_CD", "");
				formdata.put("ACTION_CD", "");
				formdata.put("TMPL_MENU_CD", "");
				formdata.put("AUTH_CD", docNum);
				formdata.put("TMPL_MENU_GROUP_CD", "");
				formdata.put("MENU_GROUP_CD", "");
				formdata.put("COMMON_ID", "");
				formdata.put("MULTI_DESC", gridData.get("AUTH_DESC"));

				/* This parameter is use for sync of each database server. */
				formdata.put("TABLE_NM", "STOCMULG");
				//formdata.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
				
				multiLanguageMapper.multiLanguagePopupDoInsert(formdata);
				mulgSaCache.initData();

//				String multiName = (String)gridData.get("AUTH_NAME");
//				String multiDesc = (String)gridData.get("AUTH_DESC");
//				multiLanguageService.insertMultiLanguagePopup_AU(multiName, multiDesc,docNum);

				//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
				bsya_Mapper.doInsertAuthProfileManagement(gridData);
			} else {
				//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
				bsya_Mapper.doUpdateAuthProfileManagement(gridData);
			}
			
//			if(PropertiesManager.getString("wisepro.database.sync").equals("true")) {				
//				/* This parameter is use for sync of each database server. */ 
//				String dblinkName = everConfigService.getSystemConfig(EVER_DBLINK);
//				gridData.put("TABLE_NM", "STOCAUPF"+ dblinkName);
//				if (checkCnt == 0) {	
//					formdata.put("TABLE_NM", "STOCMULG" + dblinkName);
//					
//					multiLanguageMapper.multiLanguagePopupDoInsert(formdata);
//					bsya_Mapper.doInsertAuthProfileManagement(gridData);
//				} else {
//					bsya_Mapper.doUpdateAuthProfileManagement(gridData);
//				}
//			
//			}

		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteAuthProfileManagement(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			
			/* This parameter is use for sync of each database server. */ 
			gridData.put("TABLE_NM", "STOCAUPF");
			//gridData.put("_LINKDB_NM", everConfigService.getSystemConfig(EVER_DBLINK));
			
			bsya_Mapper.doDeleteAuthProfileManagement(gridData);

//			if(PropertiesManager.getString("wisepro.database.sync").equals("true")) {				
//				/* This parameter is use for sync of each database server. */ 
//				String dblinkName = everConfigService.getSystemConfig(EVER_DBLINK);
//				gridData.put("TABLE_NM", "STOCAUPF" + dblinkName);				
//				
//				bsya_Mapper.doDeleteAuthProfileManagement(gridData);
//			}
		}

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> doSearchLMenuAuthMapping(Map<String, String> param) throws Exception {
		return bsya_Mapper.doSearchLMenuAuthMapping(param);
	}

	public List<Map<String, Object>> doSearchRMenuAuthMapping(Map<String, String> param) throws Exception {
		return bsya_Mapper.doSearchRMenuAuthMapping(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveMenuAuthMapping(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			if ("I".equals(gridData.get("INSERT_FLAG"))) {
				/* This parameter is use for sync of each database server. */ 
				gridData.put("TABLE_NM", "STOCAUMP");
//				gridData.put("_LINKDB_NAME", everConfigService.getSystemConfig(EVER_DBLINK));
				
				//int checkCnt = bsya_Mapper.checkMenuAuthMapping(gridData);
				bsya_Mapper.doInsertMenuAuthMapping(gridData);
				
//				if(PropertiesManager.getString("wisepro.database.sync").equals("true")) {				
//					/* This parameter is use for sync of each database server. */ 
//					String dblinkName = everConfigService.getSystemConfig(EVER_DBLINK);
//					gridData.put("TABLE_NM", "STOCAUMP" + dblinkName);
//					bsya_Mapper.doInsertMenuAuthMapping(gridData);
//				}
			}
		}
		breadCrumbCache.initData();
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteMenuAuthMapping(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			/* This parameter is use for sync of each database server. */ 
			gridData.put("TABLE_NM", "STOCAUMP");
			//gridData.put("_LINKDB_NAME", everConfigService.getSystemConfig(EVER_DBLINK));
			
			bsya_Mapper.doDeleteMenuAuthMapping(gridData);
			
//			if(PropertiesManager.getString("wisepro.database.sync").equals("true")) {				
//				/* This parameter is use for sync of each database server. */ 
//				String dblinkName = everConfigService.getSystemConfig(EVER_DBLINK);
//				gridData.put("TABLE_NM", "STOCAUPF" + dblinkName);
//				bsya_Mapper.doDeleteMenuAuthMapping(gridData);
//			}			
		}
		breadCrumbCache.initData();
		return msg.getMessage("0017");
	}	
	
	
	
	
	
	
	
	public List<Map<String, Object>> doSearchLScreenActionAuthMapping(Map<String, String> param) throws Exception {
		return bsya_Mapper.doSearchLScreenActionAuthMapping(param);
	}
	
	public List<Map<String, Object>> doSearchRScreenActionAuthMapping(Map<String, String> param) throws Exception {
		return bsya_Mapper.doSearchRScreenActionAuthMapping(param);
	}
	
	
	
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveScreenActionAuthMapping(List<Map<String, Object>> gridDatas, Map<String, String> formData) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("TABLE_NM", "STOCAUMP");
			gridData.put("AUTH_CD", formData.get("AUTH_CD"));
			bsya_Mapper.doInsertScreenActionAuthMapping(gridData);
		}
		
		breadCrumbCache.initData();
		return msg.getMessage("0001");
	}
	

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteScreenActionAuthMapping(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			/* This parameter is use for sync of each database server. */ 
			gridData.put("TABLE_NM", "STOCAUMP");
			bsya_Mapper.doDeleteScreenActionAuthMapping(gridData);
			
//			if(PropertiesManager.getString("wisepro.database.sync").equals("true")) {				
//				/* This parameter is use for sync of each database server. */ 
//				String dblinkName = wiseConfigService.getSystemConfig(WISE_DBLINK);
//				gridData.put("TABLE_NAME", "ICOMAUPF" + dblinkName);
//				authManagementMapper.doDeleteScreenActionAuthMapping(gridData);
//			}
		}
		breadCrumbCache.initData();
		return msg.getMessage("0017");
	}
	
	
	
	public List<Map<String, Object>> listUserByDept(Map<String, String> param) throws Exception {
		return bsya_Mapper.listUserByDept(param);
	}

	public List<Map<String, Object>> listSTOCUSAC(Map<String, String> param) throws Exception {
		return bsya_Mapper.listSTOCUSAC(param);
	}
	
	
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveSTOCUSAC(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			int checkCnt = bsya_Mapper.existsSTOCUSAC(gridData);

			if (checkCnt == 0) {
				bsya_Mapper.createSTOCUSAC(gridData);
			} else {
				bsya_Mapper.updateSTOCUSAC(gridData);
			}
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteSTOCUSAC(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			bsya_Mapper.deleteSTOCUSAC(gridData);
		}
		return msg.getMessage("0017");
	}	
	

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveSTOCUSAP(List<Map<String, Object>> gridDatas, String authCode) throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("AUTH_CD", authCode);
		if (bsya_Mapper.checkAuthCode(map) == 0) {
			throw new EverException("AUTH_NOT_FOUND");
		}
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("AUTH_CD", authCode);
			int checkCnt = bsya_Mapper.existsSTOCUSAP(gridData);

			if (checkCnt == 0) {
				bsya_Mapper.createSTOCUSAP(gridData);
			} else {
				gridData.put("AUTH_CD_ORI", authCode);
				bsya_Mapper.updateSTOCUSAP(gridData);
			}
		}
		return msg.getMessage("0001");
	}	
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteSTOCUSAP(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			bsya_Mapper.deleteSTOCUSAP(gridData);
		}

		return msg.getMessage("0017");
	}
	
	
	
	
}