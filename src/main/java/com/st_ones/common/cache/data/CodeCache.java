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
 * @File Name : CodeCache.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Service(value = "codeCache")
public class CodeCache extends DataCacheCommon {

	@Autowired
	CacheMapper cacheMapper;

	@Cacheable(value = "codeCache")
	public List<Map<String, String>> getData(String codeType, String langCode) {

		logger.info("Caching Code: " + codeType + "/" + langCode);

		Map<String, String> param = new HashMap<String, String>();
		param.put("CODE_TYPE", codeType);
		param.put("LANG_CODE", langCode);
		List<Map<String, String>> codes = cacheMapper.getComCodes(param);

		return codes;
	}

	@CacheEvict(value = "codeCache", allEntries = true)
	public void refreshData(String codeType, String langCode) {
		logger.info("Refreshing Code Cache: " + codeType + "/" + langCode);
	}

	public void loadAllData() {}

	Map<String, List<Map<String, String>>> data = new HashMap<String, List<Map<String, String>>>();

	@Override
	protected Map<String, List<Map<String,String>>> getCacheData() {
		return data;
	}
}
