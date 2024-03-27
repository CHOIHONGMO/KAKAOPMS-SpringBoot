package com.st_ones.eversrm.system;

import com.st_ones.common.cache.data.CacheUtil;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Iterator;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/system")
public class cacheSyncController extends BaseController {

    @Autowired
    private CacheUtil cacheUtil;
    
    /**
     * 캐쉬리로드
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/cacheSync/view")
    public String QS04_00A(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
            return "/eversrm/noSuperAuth";
        }

        Map<String, String> propertiesByPrefixAsMap = PropertiesManager.getPropertiesByPrefixAsMap("everF.cacheEnable");
        Iterator<String> iterator = propertiesByPrefixAsMap.keySet().iterator();
        while (iterator.hasNext()) {
            String key = iterator.next();
            String value = propertiesByPrefixAsMap.get(key);
            req.setAttribute(StringUtils.replace(key, ".", "_"), value);
        }

        return "/eversrm/system/cacheSync";
    }

    @RequestMapping(value = "/cacheSync")
    public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        cacheUtil.initCacheCode();
        cacheUtil.loadCacheData();
        PropertiesManager.refresh();
        resp.setResponseMessage("SUCCESS");
        resp.setResponseCode("0001");
    }

    @RequestMapping(value = "/ajaxTest")
    public void ajaxTest(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getParamDataMap();

        formData.put("msg", "success");
        resp.sendJSON(formData);
    }
}