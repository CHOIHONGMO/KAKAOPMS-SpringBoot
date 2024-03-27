package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.common.util.service.UtilService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * @author ST-Ones
 * @version 1.0
 */
@Service(value = "cmpcPopupCache")
public class CmpcPopupCache extends DataCacheCommon{

	@Autowired CacheMapper cacheMapper;
	@Autowired UtilService utilService;

	protected Map<String, Map<String, String>> data = new HashMap<String, Map<String, String>>();

	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, Map<String, String>>getCacheData() {
		return data;
	}
	
	public void setDatum(String key, Map<String, String> datum){
		Map<String, Map<String, String>> _data = getCacheData();
		_data.put(key, datum);
	}

	@SuppressWarnings({"rawtypes", "unchecked"})
	public Map<String, String> getData(String commonId) {

		String databaseCode = utilService.getDatabaseCode();

		if(!PropertiesManager.getBoolean("everF.cacheEnable.popup")){
			return cacheMapper.getCommonPopupDetailInfo(commonId, databaseCode);
		}
		
		Map<String, String> commonPopupDetailInfo = getCacheDataByKey(commonId);
		if(commonPopupDetailInfo == null){
			setDatum(commonId, cacheMapper.getCommonPopupDetailInfo(commonId, databaseCode));
			commonPopupDetailInfo = getCacheDataByKey(commonId);
		}
		
		logging("commonId - " + commonId, new MapLogger(commonPopupDetailInfo).toString());
		return commonPopupDetailInfo;
	}
	
	public void removeData(String commonId) {
		removeDatum(commonId);
	}
}