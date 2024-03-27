package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
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
 * @File Name : ButtonInfoCache.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Service(value = "buttonInfoCache")
public class ButtonInfoCache {

	@Autowired CacheMapper cacheMapper;
//	@Autowired MulgSaCache mulgSaCaptionCache;
	protected Map<String, List<Map<String, String>>> data = new HashMap<String, List<Map<String, String>>>();

	@SuppressWarnings("unchecked")
	protected Map<String, List<Map<String, String>>> getCacheData() {
		return data;
	}

	@Cacheable("buttonCache")
	public List<Map<String, String>> getData(String screenId, String langCd, String userId) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		param.put("screenId", screenId);
		param.put("userId", userId);
		param.put("langCd", langCd);
		List<Map<String, String>> buttonInfoList = cacheMapper.getButtonInfo(param);

		return buttonInfoList;
	}
	
	@SuppressWarnings({"rawtypes", "unchecked"})
	public void buttonInfoLoggging(String screenId, List<Map<String, String>> buttonInfoList){

	}

	@CacheEvict(value = "buttonCache", allEntries = true)
	public void removeAllCaches() {}

	@CacheEvict(value = "buttonCache", allEntries = true)
	public void removeData(String screenId) {}

	@CacheEvict(value = "buttonCache")
	public void removeData(String screenId, String langCd, String userId) {}

	public Map<String, Object> getToolbarInfo(String screenId, String tmplMenuCd) {
		return cacheMapper.getToolbarInfo(screenId, tmplMenuCd);
	}
}
