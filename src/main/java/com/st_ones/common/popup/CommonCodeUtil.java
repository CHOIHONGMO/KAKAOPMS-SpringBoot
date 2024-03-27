package com.st_ones.common.popup;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import org.apache.commons.beanutils.BeanMap;
import org.apache.commons.lang3.text.StrBuilder;

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
 * @File Name : CommonCodeUtil.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 30.
 * @version 1.0
 * @see
 */

public class CommonCodeUtil {

	public static String getReplacedSql(String sql, Map<String, String> parameters) throws Exception {

		UserInfo userInfo2 = UserInfoManager.getUserInfo();
		Map<String, String> userInfo = convertObjectMap(new BeanMap(userInfo2));
		Set<String> userInfoKeySet = userInfo.keySet();
		for (String key : userInfoKeySet) {
			parameters.put("ses." + key, userInfo.get(key));
		}

		/*
		if(parameters.get("ses.gateCd") == null) {
			parameters.put("ses." + "gateCd", PropertiesManager.getString("eversrm.gateCd.default"));
		}
		*/

		return putParameter(sql, parameters);
	}

	private static String putParameter(String sql, Map<String, String> parameters) throws Exception {
		Set<String> keySet = parameters.keySet();
		StrBuilder strBuilder = new StrBuilder(sql);
		for (String key : keySet) {

			String prefix = String.format("<%s>", key);
			String postfix = String.format("</%s>", key);

			strBuilder.deleteAll(prefix);
			strBuilder.deleteAll(postfix);
			String argKey = String.format("#%s#", key);
			String argValue = String.format("'%s'", EverString.CheckInjection(parameters.get(key)));

			strBuilder.replaceAll(argKey, argValue);

		}

//		List<String> parameterInSql = getParameterInSql(sql);
//		for (String key : parameterInSql) {
//			String prefix = String.format("<%s>", key);
//			String postfix = String.format("</%s>", key);
//			if (strBuilder.contains(prefix) &&!strBuilder.contains(postfix)) {
//				throw new NoResultException(String.format("Tag not Correctly end.[%s][%s]", prefix, postfix));
//			}
//			if (strBuilder.contains(prefix)) {
//				int startIndex = strBuilder.indexOf(prefix);
//				int endIndex = strBuilder.indexOf(postfix);
//				strBuilder.delete(startIndex, endIndex + postfix.length());
//				continue;
//			}
//		}
		return strBuilder.toString();
	}

	private static List<String> getParameterInSql(String sql) {
		StrBuilder builder = new StrBuilder(sql);
		List<String> keyList = new ArrayList<String>();
		while (builder.contains("#")) {
			builder.delete(0, builder.indexOf("#") + 1);
			String parameterKey = builder.substring(0, builder.indexOf("#"));
			builder.delete(0, builder.indexOf("#") + 1);
			keyList.add(parameterKey);
		}

		for (int i = keyList.size() - 1; i >= 0; i--) {
			String key = keyList.get(i);
			if (key.contains("arg") || key.contains("ses.")) {
				keyList.remove(i);
			}
		}
		return keyList;
	}

	public static Map<String, String> convertObjectMap(Map<?, ?> map) {
		Map<String, String> newMap = new HashMap<String, String>();
		@SuppressWarnings("rawtypes")
		Set keySet = map.keySet();
		for (Object key : keySet) {
			Object value = map.get(key);
			if (key instanceof String && value instanceof String) {
				newMap.put((String)key, (String)value);
			}
		}
		return newMap;
	}
}