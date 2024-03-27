package com.st_ones.common.util.clazz;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.UtilService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.everf.serverside.util.clazz.SessionIgnore;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 2022. 12. 30 오전 9:14
 */
@Aspect
public class AuthCheckAndLogging {

	@Autowired
    UtilService utilService;

	@Autowired
	private MessageService msg;

	public void afterMethod(JoinPoint joinPoint, List retVal) throws Exception {

	}
	
	/**
	 * 화면에서 버튼 클릭시 권한 체크 : eversrm.auth.button.apply.flag=true
	 * common, batch, nosession, scheduler는 권한체크에서 제외
	 * @param joinPoint
	 * @throws Exception
	 */
	public void beforeMethod(JoinPoint joinPoint) throws Exception {

		String packageName = joinPoint.getSignature().getDeclaringTypeName() + "." + joinPoint.getSignature().getName();
		if (packageName.equals("com.st_ones.eversrm.system.code.service.BSYC_Service.getSTOCCODEByCodeType")) return;
		
		List<Map<String, String>> result = utilService.getCheckCnt(packageName);
		logging(joinPoint, result);
		
		if(ignoreAuthCheck((MethodSignature) joinPoint.getSignature())) return;

		// # false : Not Check, true : Check
		if(PropertiesManager.getString("eversrm.auth.button.apply.flag").equals("true")) {
			if( packageName.indexOf("com.st_ones.common") == -1
					&& packageName.indexOf("com.st_ones.batch") == -1
					&& packageName.indexOf("com.st_ones.nosession") == -1
					&& packageName.indexOf("com.st_ones.eversrm.scheduler") == -1 )
			{
				if (result.size() == 0) {
					throw new NoResultException(PropertiesManager.getString("eversrm.system.developmentFlag").equals("true") ? msg.getMessage("0008") + " (" + packageName + ")" : msg.getMessage("0008")); // You do not have authority.
				}
			}
		}
	}

	private void logging(JoinPoint joinPoint, List<Map<String, String>> result) throws Exception {

		String screenId, actionCode, jobDesc, actionNm;
		if(result.size() > 0){
			screenId = result.get(0).get("SCREEN_ID");
			actionCode = result.get(0).get("ACTION_CD");
			jobDesc = actionCode + " of [" + screenId + "] - " + result.get(0).get("SCREEN_URL");
		} else {
			screenId = "unknown";
			actionCode = "unknown";
			jobDesc = "action did not registered";
		}

		if (screenId.equals("unknown")) {
			return;
		}

		String methodName = joinPoint.getSignature().getName();
		String moduleName = joinPoint.getSignature().getDeclaringTypeName();

		utilService.logForJob(methodName, moduleName, screenId, actionCode, jobDesc, "G", "", "", "","");
	}
	
	@SuppressWarnings("unchecked")
	private boolean ignoreAuthCheck(MethodSignature methodSignagure) throws UserInfoNotFoundException {
		if(!PropertiesManager.getBoolean("eversrm.auth.button.apply.flag", true)) return true; // 해당 프로퍼티 값을 false 로 설정 한 경우 권한 체크 하지 않음.
		if(methodSignagure.getMethod().isAnnotationPresent(SessionIgnore.class)) return true;
		if(methodSignagure.getMethod().isAnnotationPresent(AuthorityIgnore.class)) return true;
		if(methodSignagure.getDeclaringType().isAnnotationPresent(SessionIgnore.class)) return true;
		if(methodSignagure.getDeclaringType().isAnnotationPresent(AuthorityIgnore.class)) return true;
		return UserInfoManager.getUserInfo().getUserId().equals("VIRTUAL");
	}

}
