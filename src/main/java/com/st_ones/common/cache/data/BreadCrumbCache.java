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
@Service(value = "breadCrumbCache")
public class BreadCrumbCache extends DataCacheCommon {

	@Autowired
	private CacheMapper cacheMapper;

	protected Map<String, List<String>> data = new HashMap<String, List<String>>();

	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, List<String>> getCacheData() {
		return data;
	}

	public List<String> getData(String screenId, String moduleType, String grantedAuthCode, String langCd) throws Exception {

		if (!PropertiesManager.getBoolean("everF.cacheEnable.breadCrumb")) {
			
			List<String> returnInfo = cacheMapper.getBreadCrumbInfoLike(screenId, moduleType, grantedAuthCode, langCd);
			if (returnInfo.size()==0) {
				return cacheMapper.getBreadCrumbInfoLike(screenId, moduleType, grantedAuthCode, langCd);
			} else {
				return returnInfo;
			}
			
		}

		List<String> breadCrumbInfo = getCacheDataByKey(screenId + moduleType + grantedAuthCode + langCd);
		if (breadCrumbInfo == null) {
			setDatum(screenId + moduleType + grantedAuthCode + langCd, cacheMapper.getBreadCrumbInfo(screenId, moduleType, grantedAuthCode, langCd));
			breadCrumbInfo = getCacheDataByKey(screenId + moduleType + grantedAuthCode + langCd);
		}
		logging(String.format("screenId: %s, moduleType: %s, grantedAuthCode: %s, langCode: %s", screenId, moduleType, grantedAuthCode, langCd), breadCrumbInfo.toString());
		return breadCrumbInfo;
	}

	public void removeData(String screenId, String moduleType) {
		removeDatumContainKey(screenId + moduleType);
	}
	
	public void removeData(String screenId, String moduleType, String grantedAuthCode, String langCode) {
		removeDatum(screenId + moduleType + grantedAuthCode + langCode);
	}
}