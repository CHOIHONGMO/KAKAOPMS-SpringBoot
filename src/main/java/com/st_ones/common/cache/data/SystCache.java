package com.st_ones.common.cache.data;

import com.st_ones.common.config.EverConfigMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
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
 * @File Name : SystCache.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "systCache")
public class SystCache extends DataCacheCommon{

	protected Map<String, List<Map<String, String>>> data = new HashMap<String, List<Map<String, String>>>();
	
	@Autowired EverConfigMapper everConfigMapper;
	
	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, List<Map<String, String>>> getCacheData() {
		return data;
	}

	@SuppressWarnings({"rawtypes", "unchecked"})
	public List<Map<String, String>> getData(String key) {
		if(!PropertiesManager.getBoolean("everF.cacheEnable.button")){
			return everConfigMapper.getConfig(key);
		}
		
		List<Map<String, String>> systData = getCacheDataByKey(key);
		if(systData == null){
			setDatum(key, everConfigMapper.getConfig(key));
			systData = getCacheDataByKey(key);
		}
		
		logging("configType - " + key, new MapLogger(systData).toString());
		return systData;
	}

	public void removeData(String key) {
		removeDatum(key);
	}
}