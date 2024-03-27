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
 * @author ST-Ones
 * @version 1.0
 */
@Service(value = "formInfoCache")
public class FormInfoCache {

    @Autowired
    ScrnCache scrnCache;
    @Autowired
    CacheMapper cacheMapper;

    protected Map<String, List<Map<String, String>>> data = new HashMap<String, List<Map<String, String>>>();

    protected Map<String, List<Map<String, String>>> getCacheData() {
        return data;
    }

    @Cacheable("formCache")
    public List<Map<String, String>> getData(String screenId, String langCd) {
        return cacheMapper.getFormInfo(screenId, langCd);
    }

    public String getExcelDownMode(String screenId) throws Exception {
        return scrnCache.getExcelDownMode(screenId);
    }

    @CacheEvict(value = "formCache")
    public void removeData(String screenId, String langCd) {}

    @CacheEvict(value = "formCache", allEntries = true)
    public void removeAllCaches() {}
}