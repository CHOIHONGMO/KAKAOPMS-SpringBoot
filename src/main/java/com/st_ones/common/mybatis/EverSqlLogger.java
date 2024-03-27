package com.st_ones.common.mybatis;

import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.StringUtil;
import org.apache.commons.beanutils.BeanMap;
import org.apache.commons.lang3.StringUtils;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.ParameterMapping;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StopWatch;

import java.io.UnsupportedEncodingException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : EverSqlLogger.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
public class EverSqlLogger {

	private static final String FOREACH_KEY = "__frch_";
	private static String[] encryptTargetWords = {"USER", "TEL", "ADDR", "EMAIL", "CELL", "FAX", "IRS", "EMPLOYEE", "ZIP_CD"
												 ,"user", "tel", "addr", "email", "cell", "fax", "irs", "employee", "zip_cd"};
	private final Logger logger = LoggerFactory.getLogger(this.getClass());
	private Map<String, Object> parameter = null;
	private String id;
	private String sql;
	private final List<String> paramList;
	private String property;

	@SuppressWarnings("unchecked")
	public EverSqlLogger(String _id, String _sql, Object _parameter) {

		this.paramList = new ArrayList<String>();
		this.id = "/* "+_id + " */\n";
		this.sql = this.id + _sql;

		if (_parameter instanceof Map) {
			this.parameter = (Map<String, Object>)_parameter;
		} else {
			this.parameter = (Map) new BeanMap(_parameter);
		}
	}

	@SuppressWarnings({"rawtypes"})
	public void logging(BoundSql boundSql, StopWatch stopWatch, int resultCount) {
		List<ParameterMapping> paramMapping = boundSql.getParameterMappings();
		
		for (ParameterMapping parameterMapping : paramMapping) {
			this.property = parameterMapping.getProperty();

			Object parameterValue = getParameterValue();

			Map<String, Object> parameterMap = new HashMap<>();

			// List 파라미터 값을 매핑하기 위해 값을 찾는다.
			Boolean frchFlag = false;

			if (property.indexOf("__frch") > -1 && property.indexOf(".") < -1) {
				for (ParameterMapping mapping : paramMapping) {
					Object value = ((Map) parameterValue).get(property);
					if (value == null) {
						// __frch_ PREFIX에 대한 처리
						if (boundSql.hasAdditionalParameter(property)) {  // myBatis가 추가 동적인수를 생성했는지 체크하고
							value = boundSql.getAdditionalParameter(property);  // 해당 추가 동적인수의 Value를 가져옴
						}
						if (value == null) continue;
					}
					parameterMap.put(property, value);
				}
				frchFlag = true;
			} else {
				frchFlag = false;
			}

			if (parameterValue instanceof Map) {
				if(frchFlag) {
					parameterMap.putAll((Map) parameterValue);
					addMapToParamList(parameterMap);
				} else {
					addMapToParamList((Map) parameterValue);
				}
			} else if (parameterValue instanceof String) {
				addStringToParamList((String)parameterValue);
			} else if (parameterValue instanceof List) {
				addListToParamList((List)parameterValue);
			} else if (parameterValue == null) {
				addNullToParamListNull();
			} else {
				addStringToParamList(parameterValue.toString());
				logger.debug("Parameter [{}] is not String type. (Type -> {})", property, parameterValue.getClass().getName());
			}
		}

		sql = StringUtil.replace(sql, "?", "'%s'");

    	for (String param : paramList) {
			if (param == null) {
				sql = StringUtils.replaceOnce(sql, "'%s'", "null");
			} else {
				sql = StringUtils.replaceOnce(sql, "%s", param);
			}
		}

		sql = sql + System.getProperty("line.separator") +
				"-- " + resultCount + " row(s), executed in " + stopWatch.getTaskInfo()[0].getTimeMillis() + "ms";

		sql = trimSpace(sql);

		try {
			logger.info(new String((System.getProperty("line.separator") + sql).getBytes("UTF-8"), "UTF-8"));
		} catch (UnsupportedEncodingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	@SuppressWarnings("rawtypes")
	private void addListToParamList(List parameterValue) {
		int listIndex = getListIndex();
		listIndex = listIndex % parameterValue.size();
		if (parameterValue.size() > listIndex) {
			Object element = parameterValue.get(listIndex);

			if (element instanceof LinkedHashMap) {
				// 반환되는 값이 String 인데 넘버형태인 경우 mybatis 오류로 인해 Casting 한다.
				LinkedHashMap linkedHashMap = (LinkedHashMap) element;

				String mapAsString = (String) linkedHashMap.keySet().stream()
						.map(key -> key + "=" + linkedHashMap.get(key))
						.collect(Collectors.joining(","));

				Map<String, String> map = Arrays.stream(mapAsString.split(","))
						.map(entry -> entry.split("="))
						.collect(Collectors.toMap(entry -> entry[0], entry -> entry[1]));

				// paramList.add((String)((LinkedHashMap)element).get(getPropertyNameAfterDot()));
				paramList.add(map.get(getPropertyNameAfterDot()));
			} else if (element instanceof Map) {
				paramList.add((String)((Map)element).get(getPropertyNameAfterDot()));
			} else if (element instanceof String) {
				paramList.add((String)element);
			} else { // Bean
				paramList.add((String)new BeanMap(element).get(getPropertyNameAfterDot()));
			}
		}
	}

	private int getListIndex() {
		String listItemKey = property;
		if (property.contains(".")) {
			listItemKey = getPropertyBeforeDot();
		}
		String listIndexString = listItemKey.substring(listItemKey.lastIndexOf("_") + 1);
		return Integer.parseInt(listIndexString);
	}

	private void addNullToParamListNull() {
		logger.info("Parameter [{}] is null.", property);
		paramList.add(null);
	}

	private Object getParameterValue() {
		if (property.contains(FOREACH_KEY)) {
			if (property.indexOf("__frch") > -1 && property.indexOf(".") < -1) {
				return parameter;
			} else {
				return parameter.get(getListTypeKey());
			}
		} else if (property.contains(".")) {
			return new BeanMap(parameter.get(getPropertyBeforeDot()));
		}
		return parameter.get(property);
	}
	
	/**
	 * 운영서버에서 파라미터 값에 대해 전체 마스킹(A)
	 * @param parameterValue
	 */
	@SuppressWarnings("rawtypes")
	private void addMapToParamList(Map parameterValue) {

		String propName = getPropertyNameAfterDot();
		String value;
		if (PropertiesManager.getBoolean("eversrm.sql.logging.personalInfo.encrypt") && !PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			if(StringUtils.indexOfAny(this.property, encryptTargetWords) > -1) {
				try {
					value = EverString.setEncryptedString((String) parameterValue.get(propName), "A");	// 전체 마스킹 : A, 2번째 글자 마스킹 : N, 3/4번째 글자 마스킹 : E
				} catch (Exception e) {
					logger.error(e.getMessage(), e);
					value = (String) parameterValue.get(propName);
				}
			} else {
				value = (String) parameterValue.get(propName);
			}
		} else {
			value = (String) parameterValue.get(propName);
		}

		paramList.add(value);
	}

	private String getPropertyBeforeDot() {
		return property.substring(0, property.indexOf("."));
	}

	private String getPropertyNameAfterDot() {
		return property.substring(property.indexOf(".") + 1);
	}
	
	/**
	 * 운영서버에서 파라미터 값에 대해 전체 마스킹(A)
	 * @param parameterValue
	 */
	private void addStringToParamList(String parameterValue) {
		if (PropertiesManager.getBoolean("eversrm.sql.logging.personalInfo.encrypt") && !PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
			if(StringUtils.indexOfAny(this.property, encryptTargetWords) > -1) {
				try {
					parameterValue = EverString.setEncryptedString(parameterValue, "A");	// 전체 마스킹 : A, 2번째 글자 마스킹 : N, 3/4번째 글자 마스킹 : E
				} catch (Exception e) {
					logger.error(e.getMessage(), e);
				}
			}
			paramList.add(parameterValue);
		} else {
			paramList.add(parameterValue);
		}
	}

	private String trimSpace(String query) {
		String sqlQuery;
		sqlQuery = query.replaceAll("\n\\s{3,}\n", "\n");
		sqlQuery = sqlQuery.replaceAll("\n\\s{3,},\\s*\n", ",\n");
		sqlQuery = sqlQuery.replaceAll("    ", "\t");
		sqlQuery = sqlQuery.replaceAll("\n\t\t", "\n");
		sqlQuery = sqlQuery.replaceAll("^", "\t");
		sqlQuery = sqlQuery.replaceAll("\n", "\n\t");
		return sqlQuery;
	}

	private String getListTypeKey() {
		Set<String> keySet = parameter.keySet();
		List<String> listTypeKeys = new ArrayList<String>();
		for (String key : keySet) {
			if (key.contains("param")) {
				continue;
			}
			if (parameter.get(key) instanceof List) {
				listTypeKeys.add(key);
			}
		}

		if (listTypeKeys.size() == 1) {
			return listTypeKeys.get(0);
		}

		for (String listTypeKey : listTypeKeys) {
			if (listTypeKey.toUpperCase().contains(property.toUpperCase())) {
				return listTypeKey;
			}
		}

		logger.error("listTypeKeys: " + listTypeKeys);
		logger.error("property: " + property);
		if (listTypeKeys.size() == 0) {
			throw new IllegalArgumentException("doesn't have list element in param");
		}

		//return null;
		throw new IllegalArgumentException("myBatis Mapper has more than 2 foreach element and doesnt match container and element id. Do not use 'param' as foreach collection key");
	}
}
