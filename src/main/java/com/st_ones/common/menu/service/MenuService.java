package com.st_ones.common.menu.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.menu.MenuMapper;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 10. 31 오후 4:57
 */

@Service(value = "menuService")
public class MenuService extends BaseService {

	@Autowired
	private MenuMapper menuMapper;

	public List<Map<String, Object>> getScreenInfo(Map<String, String> param) throws Exception {
		return menuMapper.getScreenInfo(param);
	}

	public List<Map<String, Object>> getLeftMenu(Map<String, String> params) throws Exception {

		String sslFlag = PropertiesManager.getString("ever.ssl.use.flag");
		params.put("SSL_FLAG", sslFlag);
		
		// 직무권한 체크
		UserInfo userInfo = UserInfoManager.getUserInfo();
		String ctrlCd = EverString.nullToEmptyString(userInfo.getCtrlCd());
		params.put("T100", String.valueOf(ctrlCd.indexOf("T100")));
		params.put("M100", String.valueOf(ctrlCd.indexOf("M100")));
		
		return menuMapper.getLeftMenu(params);
	}

	public List<Map<String, Object>> getScreenInfo2(Map<String, String> param) throws Exception {
		return menuMapper.getScreenInfo2(param);
	}

	public void setBookmark(String templateMenuCd, String bookmarkMode) throws Exception {

		if(StringUtils.equals(bookmarkMode, "true")) {
			try {
				menuMapper.insertBookmark(templateMenuCd);
			} catch(SQLException e) {
				if(e.getErrorCode() == 1400) {
					throw new Exception("즐겨찾기하실 수 없는 화면입니다.");
				}
			}
		} else {
			menuMapper.deleteBookmark(templateMenuCd);
		}
	}
}
