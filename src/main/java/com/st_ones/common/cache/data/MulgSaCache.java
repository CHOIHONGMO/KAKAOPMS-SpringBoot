package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
 * @File Name : IcommulgSaCache.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Service(value = "IcommulgSaCache")
public class MulgSaCache extends DataCacheCommon {
	@Autowired
	private CacheMapper cacheMapper;
	protected Map<String, List<Map<String, String>>> data = new HashMap<String, List<Map<String, String>>>();

	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, List<Map<String, String>>> getCacheData() {
		return data;
	}

	public Map<String, String> getData(String screenId) throws Exception {
		String langCd = UserInfoManager.getUserInfo().getLangCd();
		List<Map<String, String>> buttonCaptionList = getDataPrivate(screenId, langCd);
		Map<String, String> buttonCaptionMap = new HashMap<String, String>();
		for (Map<String, String> buttonCaption : buttonCaptionList) {
			buttonCaptionMap.put(buttonCaption.get("ACTION_CD"), buttonCaption.get("MULTI_NM"));
		}
		return buttonCaptionMap;
	}

	@SuppressWarnings({"rawtypes", "unchecked"})
	private List<Map<String, String>> getDataPrivate(String screenId, String langCode) {
		if (!PropertiesManager.getBoolean("everF.cacheEnable.button")) {
			return cacheMapper.getMULGSa(screenId, langCode, "SA");
		}
		List<Map<String, String>> buttonCaption = getCacheDataByKey(screenId + langCode);
		if (buttonCaption == null) {
			setDatum(screenId + langCode, cacheMapper.getMULGSa(screenId, langCode, "SA"));
			buttonCaption = getCacheDataByKey(screenId + langCode);
		}
		logging(String.format("screenId: %s, langCode: %s", screenId, langCode), new MapLogger(buttonCaption).toString());
		return buttonCaption;
	}

	public void removeData(String screenId, String langCode) {
		removeDatum(screenId + langCode);

	}
}
