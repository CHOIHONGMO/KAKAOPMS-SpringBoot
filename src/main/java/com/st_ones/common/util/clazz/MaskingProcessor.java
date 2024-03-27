package com.st_ones.common.util.clazz;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 12. 28 오후 5:52
 */

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.clazz.SessionIgnore;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.http.HttpSession;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;

@SessionIgnore
@Aspect
public class MaskingProcessor {

	public void beforeMethod(JoinPoint joinPoint) throws Exception {

		EverHttpRequest everHttpRequest = null;
		EverHttpResponse everHttpResponse = null;

		Object[] args = joinPoint.getArgs();
		for (Object arg : args) {

			if(arg instanceof EverHttpRequest) {
				everHttpRequest = (EverHttpRequest)arg;
			} else if(arg instanceof EverHttpResponse) {
				everHttpResponse = (EverHttpResponse)arg;
			}
		}

		if(everHttpRequest != null && everHttpResponse != null) {

			everHttpRequest = (EverHttpRequest) joinPoint.getArgs()[0];
			everHttpResponse = (EverHttpResponse) joinPoint.getArgs()[1];

			String screenId = everHttpRequest.getFormData().get("_screenId");
			everHttpResponse.setScreenId(screenId);

			// User Session 정보 가져오기
			HttpSession session = everHttpRequest.getSession(true);
			UserInfo userInfo = (UserInfo) session.getAttribute("ses");

			if(PropertiesManager.getBoolean("eversrm.system.localserver")) {
				String maskDefinitions = everHttpRequest.getFormData().get("_maskDefinitions");
				everHttpResponse.setMaskDefinitions(maskDefinitions);
			} else {
				if(userInfo != null) {
					if(!"1".equals(userInfo.getSuperUserFlag())) {
						String maskDefinitions = everHttpRequest.getFormData().get("_maskDefinitions");
						everHttpResponse.setMaskDefinitions(maskDefinitions);
					}
				}
			}
		}
	}
}