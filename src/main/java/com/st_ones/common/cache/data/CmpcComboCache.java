package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.common.util.clazz.EverString;
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
@Service(value = "cmpcComboCache")
public class CmpcComboCache extends DataCacheCommon{

	protected Map<String, String> data = new HashMap<String, String>();

	private @Autowired CacheMapper cacheMapper;

	private @Autowired UtilService utilService;

	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, String> getCacheData() {
		return data;
	}

	public void setDatum(String commonId, String datum){
		Map<String, String> _data = getCacheData();
		_data.put(commonId, datum);
	}

	public String getData(String commonId) {
		String databaseCode = utilService.getDatabaseCode();
		if(!PropertiesManager.getBoolean("everF.cacheEnable.combo")){
			return EverString.rePreventSqlInjection(cacheMapper.getUserCodes(commonId, databaseCode));
		}
		String sqlQuery = getCacheDataByKey(commonId);
		if(sqlQuery == null){
			setDatum(commonId, cacheMapper.getUserCodes(commonId, databaseCode));
			sqlQuery = getCacheDataByKey(commonId);
		}

		logging(" commonId: " + commonId, sqlQuery);
		return EverString.rePreventSqlInjection(sqlQuery);
	}

	public void removeData(String commonId) {
		removeDatum(commonId);
	}

}