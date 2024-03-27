package com.st_ones.common.multiLanguage.service;

import com.st_ones.common.cache.data.MulgMtCache;
import com.st_ones.common.cache.data.MulgPopupInfoCache;
import com.st_ones.common.cache.data.MulgPopupNameCache;
import com.st_ones.common.cache.data.MulgSaCache;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.multiLanguage.MultiLanguageMapper;
import com.st_ones.common.sample.SampleMapper;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Iterator;
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
 * @File Name : MultiLanguageService.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 08. 23.
 * @version 1.0  
 * @see 
 */

@Service(value = "multiLanguageService")
public class MultiLanguageService extends BaseService {

	/* @formatter:off */
	@Autowired	MultiLanguageMapper multiLanguageMapper;
	@Autowired MulgSaCache mulgSaCache;
	@Autowired MulgPopupNameCache mulgPopupNameCache;
	@Autowired MulgPopupInfoCache mulgPopupInfoCache;
	@Autowired MulgMtCache mulgMtCache;
	@Autowired SampleMapper sampleMapper;
	@Autowired private MessageService msg;
	/* @formatter:on */

	public List<Map<String, Object>> getMultiLanguageList(Map<String, String> param) {
		return multiLanguageMapper.getMultiLanguageList(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class, timeout = -1)
	public String multiLanguagePopupDoSave(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {

			gridData.put("MULTI_NM", EverString.isEmpty((String) gridData.get("MULTI_NM")) ? param.get("multi_nm") : gridData.get("MULTI_NM"));
			gridData.put("MULTI_CD", EverString.isEmpty((String) gridData.get("MULTI_CD")) ? param.get("multi_cd") : gridData.get("MULTI_CD"));
			gridData.put("SCREEN_ID", EverString.isEmpty((String) gridData.get("SCREEN_ID")) ? param.get("screen_id") : gridData.get("SCREEN_ID"));
			gridData.put("ACTION_CD", EverString.isEmpty((String) gridData.get("ACTION_CD")) ? param.get("action_cd") : gridData.get("ACTION_CD"));
			gridData.put("TMPL_MENU_CD", EverString.isEmpty((String) gridData.get("TMPL_MENU_CD")) ? param.get("tmpl_menu_cd") : gridData.get("TMPL_MENU_CD"));
			gridData.put("AUTH_CD", EverString.isEmpty((String) gridData.get("AUTH_CD")) ? param.get("auth_cd") : gridData.get("AUTH_CD"));
			gridData.put("ACTION_PROFILE_CD", EverString.isEmpty((String) gridData.get("ACTION_PROFILE_CD")) ? param.get("action_profile_cd") : gridData.get("ACTION_PROFILE_CD"));
			gridData.put("TMPL_MENU_GROUP_CD", EverString.isEmpty((String) gridData.get("TMPL_MENU_GROUP_CD")) ? param.get("tmpl_menu_group_cd") : gridData.get("TMPL_MENU_GROUP_CD"));
			gridData.put("MENU_GROUP_CD", EverString.isEmpty((String) gridData.get("MENU_GROUP_CD")) ? param.get("menu_group_cd") : gridData.get("MENU_GROUP_CD"));
			gridData.put("COMMON_ID", EverString.isEmpty((String) gridData.get("COMMON_ID")) ? param.get("common_id") : gridData.get("COMMON_ID"));
			gridData.put("OTHER_CD", EverString.isEmpty((String) gridData.get("OTHER_CD")) ? param.get("other_cd") : gridData.get("OTHER_CD"));

			Iterator<String> mapItor = gridData.keySet().iterator();
			while (mapItor.hasNext()) {

				String keyVal = mapItor.next();

				if ("GATE_CD".equals(keyVal) || "MULTI_SQ".equals(keyVal) || "LANG_CD".equals(keyVal)) {
					String tmpVal = "";
					if(gridData.get(keyVal) instanceof Integer || gridData.get(keyVal) instanceof Long) {
						tmpVal = String.valueOf(gridData.get(keyVal));
					} else {
						tmpVal = (String) gridData.get(keyVal);
					}
					gridData.put(keyVal, tmpVal.trim());
				}
			}

			/* This parameter is use for sync of each database server. */
			gridData.put("TABLE_NM", "STOCMULG");
			if ("U".equals(gridData.get("INSERT_FLAG"))) {
				multiLanguageMapper.multiLanguagePopupDoUpdate(gridData);
				removeMulgCache(gridData);
			} else {
				multiLanguageMapper.multiLanguagePopupDoInsert(gridData);
				removeMulgCache(gridData);

			}
		}
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String insertMenuName(Map<String, String> param) throws Exception {

		Iterator<String> mapItor = param.keySet().iterator();
		while (mapItor.hasNext()) {
			String keyVal = mapItor.next();

			if ("GATE_CD".equals(keyVal) || "MULTI_SQ".equals(keyVal) || "LANG_CD".equals(keyVal)) {
				String tmpVal = param.get(keyVal);
				param.put(keyVal, tmpVal.trim());
			}
		}

		param.put("TABLE_NAME", "STOCMULG");
		multiLanguageMapper.insertMenuName(param);
		initMulgCache();

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeletePopup(List<Map<String, Object>> gridData) throws Exception {

		for (Map<String, Object> gridRow : gridData) {
			if (EverString.isEmpty(gridRow.get("MULTI_SQ") instanceof String ? (String) gridRow.get("MULTI_SQ") : String.valueOf(gridRow.get("MULTI_SQ")))) {
				continue;
			}
			gridRow.put("TABLE_NM", "STOCMULG");
			multiLanguageMapper.multiLanguagePopupDoDelete(gridRow);

			initMulgCache();
		}
		return msg.getMessage("0017");
	}

	private void removeMulgCache(Map<String, Object> gridData) {

		String screenId = (String) gridData.get("SCREEN_ID");
		String langCd = (String) gridData.get("LANG_CD");
		String commonId = (String) gridData.get("COMMON_ID");
		String tmplMenuCd = (String) gridData.get("TMPL_MENU_CD");
		String multiCd = (String) gridData.get("MULTI_CD");

		mulgMtCache.removeData(tmplMenuCd, langCd);
		mulgPopupInfoCache.removeData(commonId, langCd);
		mulgSaCache.removeData(screenId, langCd);
		mulgPopupNameCache.removeData(screenId, multiCd, langCd);
	}

	private void initMulgCache() {
		mulgMtCache.initData();
		mulgPopupInfoCache.initData();
		mulgSaCache.initData();
		mulgPopupNameCache.initData();
	}
}