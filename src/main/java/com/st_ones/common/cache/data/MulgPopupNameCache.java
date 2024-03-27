package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * @author ST-Ones
 * @version 1.0
 */
@Service(value = "mulgPopupNameCache")
public class MulgPopupNameCache extends DataCacheCommon {

    @Autowired
    private CacheMapper cacheMapper;

    protected Map<String, String> data = new HashMap<String, String>();

    @Override
    protected Map<String, String> getCacheData() {
        return data;
    }

    public String getData(String screenId, String multiCd) throws UserInfoNotFoundException {

        String langCd = UserInfoManager.getUserInfo().getLangCd();
        if (!PropertiesManager.getBoolean("everF.cacheEnable.breadCrumb")) {
            return cacheMapper.getMulgPopupName(screenId, multiCd, langCd);
        }

        String popupName = getCacheDataByKey(screenId + multiCd + langCd);
        if (popupName == null) {
            String queriedPopupName = cacheMapper.getMulgPopupName(screenId, multiCd, langCd);

            setDatum(screenId + multiCd + langCd, queriedPopupName == null ? "" : queriedPopupName);
            popupName = getCacheDataByKey(screenId + multiCd + langCd);
        }
        logging(String.format("screenId: %s, multiCd %s, langCd: %s", screenId, multiCd, langCd), popupName);
        return popupName;
    }

    public void removeData(String screenId, String multiCd, String langCd) {
        removeDatum(screenId + multiCd + langCd);
    }

    private void setDatum(String key, String value) {
        data.put(key, value);
    }
}