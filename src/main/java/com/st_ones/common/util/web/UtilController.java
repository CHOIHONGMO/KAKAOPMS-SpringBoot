package com.st_ones.common.util.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.refresh.RefreshableSqlSessionFactoryBean;
import com.st_ones.common.serverpush.reverseajax.EverAlarm;
import com.st_ones.common.util.service.UtilService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.commons.beanutils.BeanMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : UtilController.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/common/util")
public class UtilController extends BaseController {

	@Autowired
	UtilService utilService;

	@Autowired
    EverAlarm everAlarm;

	@RequestMapping(value = "/eventNo9")
	public void eventNo9(EverHttpRequest request, EverHttpResponse response) throws Exception {
		RefreshableSqlSessionFactoryBean reFresh = new RefreshableSqlSessionFactoryBean();
		reFresh.afterPropertiesSet();
	}

    @RequestMapping(value = "/sessionInfo")
    public void getSessionInformation(HttpServletRequest req, EverHttpResponse resp) throws Exception {

        UserInfo baseInfo = UserInfoManager.getUserInfo();
        Map<String, String> newMap = new HashMap<String, String>();
        newMap.putAll((Map) new BeanMap(baseInfo));

        newMap.remove("ses");
        TreeSet<String> treeKeys = new TreeSet<String>(newMap.keySet());
        LinkedHashMap<String, Object> resultMap = new LinkedHashMap<String, Object>();
        for (String key : treeKeys) {
            resultMap.put(key, newMap.get(key));
        }

        String sessionInfoString = new ObjectMapper().writeValueAsString(resultMap);

        Map<String, String> map = new HashMap<String, String>();
        map.put("appDocNum", "AP00000311");
        // everAlarm.approvalRequestAlarm(map, "MASTER");

        resp.setParameter("sessionInfoString", sessionInfoString);
        resp.setResponseMessage("Session Information Inquiry Complete!");
        resp.setResponseCode("1");
    }


    @RequestMapping(value = "/menuClickSave")
    public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String,String> map = new HashMap<String,String>();
		map.put("tmpl_menu_cd", req.getParameter("tmpl_menu_cd"));
		map.put("moduleName", req.getParameter("moduleName"));
		map.put("jobDesc", req.getParameter("jobDesc"));
		map.put("methodName", req.getParameter("methodName"));
		map.put("actionCode", req.getParameter("actionCode"));
		utilService.menuClickSave(map);

		resp.setResponseCode("1");
    }

	@RequestMapping(value = "/getItemSearchByCode")
	public void getItemSearchByCode(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "itemCd") String itemCd) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		param.put("ITEM_CD", itemCd);

		List<Map<String, Object>> itemData = utilService.getItemSearchByCode(param);

		// 입력한 ItemCode에 대한 Data가 1건 있으므로 그리드에 바로 Setting 한다.
		if (itemData.size() == 1) {
			Map<String, Object> result = itemData.get(0);
			ObjectMapper om = new ObjectMapper();

			resp.setParameter("clearFlag", "N");
			resp.setParameter("result", om.writeValueAsString(result));
		} else {
			resp.setParameter("clearFlag", "Y");
			resp.setParameter("result", null);
		}
		resp.setResponseCode("true");
	}

}
