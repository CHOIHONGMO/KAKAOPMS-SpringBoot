package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
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
 * @File Name : MessageCache.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "messageCache")
public class MessageCache extends DataCacheCommon{

	@Autowired private CacheMapper cacheMapper;
	
	protected Map<String, List<Map<String, String>>> data = new HashMap<String, List<Map<String,String>>>();

	@SuppressWarnings("unchecked")
	@Override
	protected Map<String, List<Map<String, String>>> getCacheData(){
		return data;
	}

	public List<Map<String, String>> getData(String screenId, String langCd) throws Exception {

		if(!PropertiesManager.getBoolean("everF.cacheEnable.message")){
			return cacheMapper.getMessagesByScreenId(screenId, langCd);
		}
		List<Map<String, String>> messages = getCacheDataByKey(screenId + langCd);

		if (messages == null) {
			setDatum(screenId+langCd, cacheMapper.getMessagesByScreenId(screenId, langCd));
			messages = getCacheDataByKey(screenId + langCd);
		}
		//logging(String.format("screenId: %s, langCd: %s", screenId, langCd), new MapLogger(messages).toString());
		return messages;
	}
	
	public void removeData(String screenId, String langCd) {
		removeDatum(screenId+langCd);
	}

	public String getData(String screenId, String langCd, String multiCd) throws Exception {
		
		List<Map<String, String>> messages = getData(screenId, langCd);

		for (Map<String, String> map : messages) {
			if (map.get("MULTI_CD").equals(multiCd)) {
				String message = map.get("MULTI_CONTENTS");
				//logging(String.format("screenId: %s, langCd: %s, multiCd: %s", screenId, langCd, multiCd), message);
				return message;
			}
		}
		logger.info(String.format("MESSAGE NOT EXIST - screenId : %s, multiCd: %s", screenId, multiCd));
		return null;
	}
}