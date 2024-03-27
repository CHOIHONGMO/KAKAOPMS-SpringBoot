package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author ST-Ones
 * @version 1.0
 */
@Service(value = "scrnCache")
public class ScrnCache extends DataCacheCommon {

	protected List<Map<String, String>> scrnDataList = new ArrayList<Map<String, String>>();

	@Autowired
	CacheMapper cacheMapper;

	private Map<String, String> getScreenIdUrlMap() throws Exception {
		setCacheData();
		Map<String, String> scrnMap = new HashMap<String, String>();
		for (Map<String, String> scrnData : scrnDataList) {
			scrnMap.put(scrnData.get("SCREEN_ID"), scrnData.get("SCREEN_URL"));
		}
		return scrnMap;
	}

	public String getScreenIdByURL(String url) throws Exception {
		Map<String, String> screenIdUrlMap = getScreenIdUrlMap();
		Set<String> screenIdSet = screenIdUrlMap.keySet();
		for (String screenId : screenIdSet) {
			if (screenIdUrlMap.get(screenId).equals(url)) {
				// LOGGER.info(String.format("getScreenIdByURL: url: %s, screenId: ", url, screenId));
				return screenId;
			}
		}
		return null;
	}

	public String getUrlByScreenId(String screenId) throws Exception {
		String url = getScreenIdUrlMap().get(screenId);
		// LOGGER.info(String.format("getUrlByScreenId: url: %s, screenId: ", url, screenId));
		return url;
	}

	public boolean hasScreenId(String screenURL) throws Exception {
		return getScreenIdUrlMap().containsValue(screenURL);
	}

	public void removeData() {
		scrnDataList.clear();
	}

    protected void setCacheData() throws Exception {
        if(!PropertiesManager.getBoolean("everF.cacheEnable.scrn")){
            scrnDataList = cacheMapper.getScrnData();
        }
        if(scrnDataList.size() == 0){
            scrnDataList = cacheMapper.getScrnData();
        }
    }

	@Override
	protected <T> T getCacheData() {
		return null;
	}
	
	@Override
	public void initData(){
		scrnDataList.clear();
	}

	public String getGridTypeByScreenId(String screenId) throws Exception {
		setCacheData();
		for (Map<String, String> scrnData : scrnDataList) {
			if(EverString.equals(scrnData.get("SCREEN_ID"), screenId)){
				String gridType = scrnData.get("GRID_TYPE");
				// LOGGER.info(String.format("getGridTypeByScreenId: gridType: %s, screenId: %s", gridType, screenId));
				return gridType;
			}
		}
		logger.error("screen id Does not exist in STOCSCRN TABLE. Screen ID: " + screenId);
		return null;
	}
	
	public String getExcelDownMode(String screenId) throws Exception {
		setCacheData();
		for (Map<String, String> scrnData : scrnDataList) {
			if(EverString.equals(scrnData.get("SCREEN_ID"), screenId)){
				String gridType = scrnData.get("EXCEL_OPTION");
				// LOGGER.info(String.format("getGridTypeByGridId: gridType: %s, screenId: %s", gridType, screenId));
				return gridType;
			}
		}
		logger.error("screen id Does not exist in STOCSCRN TABLE. Screen ID: " + screenId);
		return null;
	}

	public Map<String, String> getFullMenuNm(String tmpl_menu_cd) throws Exception {
		return cacheMapper.getFullMenuNm(tmpl_menu_cd);
	}
}