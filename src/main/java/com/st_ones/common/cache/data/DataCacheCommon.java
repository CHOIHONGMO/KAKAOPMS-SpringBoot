package com.st_ones.common.cache.data;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : DataCacheCommon.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

public abstract class DataCacheCommon {


	protected final static Logger logger = LoggerFactory.getLogger(DataCacheCommon.class);

	protected void logging(String description, String contents) {
		if(logger.isDebugEnabled()) {
			logger.debug("Description: {} / Contents: {}", description, contents);
		}
	}

	public void createTempSession(String gateCd, String langCd) {
		UserInfo userInfo = new UserInfo();
		userInfo.setGateCd(gateCd);
		userInfo.setLangCd(langCd);
		UserInfoManager.createUserInfo(userInfo);
	}

	protected abstract <T extends Object> T getCacheData();

	protected <T extends Object> T getCacheDataByKey(String key) {
		Map<String, T> data = getCacheData();
		return data.get(key);
	}

	protected <T extends Object> void setDatum(String key, List<T> datum) {
		Map<String, List<T>> data = getCacheData();
		data.put(key, datum);
	}

	protected void removeDatum(String key) {
		Map<String, ?> cacheData = getCacheData();
		if (!cacheData.containsKey(key)) {
//			logging(getName() + " - " + "It doesn't have stored data key: " + key);
		}
		cacheData.remove(key);
//		logging("stored data Removed key: " + key);
	}

	protected void removeDatumContainKey(String key) {
		Map<String, ?> cacheData = getCacheData();
		Set<String> keySet = cacheData.keySet();

		List<String> keyList = new ArrayList<String>();
		for (String cacheKey : keySet) {
			if (cacheKey.contains(key)) {
				keyList.add(cacheKey);
			}
		}

		if (keyList.size() == 0) {
//			logging(getName() + " - " + "It doesn't have stored data key: " + key);
			return;
		}

		for (String cacheKey : keyList) {
			cacheData.remove(cacheKey);
//			logging("stored data Removed key: " + cacheKey);
		}
	}

	public void initData() {
		Map<String, ?> data = getCacheData();
		data.clear();
//		logging("init stored cache data");
	}

	protected void logging(String message) {
//		LOGGER.info(getName() + " " + message);
	}

	public void saveData() throws IOException {

		File tempFile = new File("temp");
		OutputStream out = new FileOutputStream(tempFile);
		ObjectOutputStream oos = new ObjectOutputStream(out);

		try {
			oos.writeObject(getCacheData());
			oos.close();
			out.close();
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(oos != null) {
				oos.close();
			}
		}
//		logging(String.format("file size: [%d] byte", tempFile.length()));
	}
}