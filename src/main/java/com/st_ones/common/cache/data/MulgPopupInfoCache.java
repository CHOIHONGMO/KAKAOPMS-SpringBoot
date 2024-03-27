package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author ST-Ones
 * @version 1.0
 */
@Service(value = "mulgPopupInfoCache")
public class MulgPopupInfoCache extends DataCacheCommon{

	@Autowired private CacheMapper cacheMapper;

	protected Map<String, List<Map<String,String>>> data = new HashMap<String, List<Map<String,String>>>();

	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, List<Map<String,String>>> getCacheData() {
		return data;
	}

	@SuppressWarnings({"unchecked", "rawtypes"})
	public List<Map<String,String>> getData(String commonId, String langCode) {
		if(!PropertiesManager.getBoolean("everF.cacheEnable.popup")){
			return cacheMapper.getMULGCommonPopupInfo(commonId, langCode, null);
		}
		List<Map<String,String>> popupInfo = getCacheDataByKey(commonId + langCode);
		if(popupInfo == null){
			setDatum(commonId+langCode, cacheMapper.getMULGCommonPopupInfo(commonId, langCode, null));
			popupInfo = getCacheDataByKey(commonId + langCode);
		}
		
		logging(String.format("commonId: %s, langCode: %s", commonId, langCode), new MapLogger(popupInfo).toString());
		return popupInfo;
	}

	public void removeData(String commonId, String langCode) {
		removeDatum(commonId + langCode);
	}
}