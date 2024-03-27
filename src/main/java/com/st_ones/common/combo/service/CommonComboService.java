package com.st_ones.common.combo.service;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.cache.data.CmpcComboCache;
import com.st_ones.common.cache.data.CodeCache;
import com.st_ones.common.combo.CommonComboMapper;
import com.st_ones.common.popup.CommonCodeUtil;
import com.st_ones.common.util.clazz.EverAuthorityIgnore;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import org.apache.commons.beanutils.BeanMap;
import org.apache.ibatis.session.SqlSessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
 * @File Name : CommonComboService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@EverAuthorityIgnore
@Service(value = "comboService")
public class CommonComboService extends BaseService {

	@Autowired CommonComboMapper comboMapper;
	@Autowired CmpcComboCache cmpcComboCache;
	@Autowired SqlSessionFactory sqlSessionFactory;
	@Autowired CodeCache codeCache;

	Logger logger = LoggerFactory.getLogger(this.getClass());
	protected void logging(String description, String contents) {
		logger.info(getName() + " - " + description + "\n" + contents);
	}
	private String getName() {
		return this.getClass().getSimpleName();
	}

	public List<Map<String, String>> getCodeCombo(String codeType) throws Exception {
		return getCodeComboByColumnKey(codeType, null);
	}

    /**
     * STOCCODD 테이블의 CODE_DESC 컬럼을 기본값으로 공통코드 리스트를 조회하여 JSON 형태로 반환합니다.
     * @param codeType
     * @return
     * @throws Exception
     */
    public String getCodeComboAsJson(String codeType) throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getCodeComboByColumnKey(codeType, null));
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

    /**
     * supports MyBatis
     * @param codeType
     * @param param
     * @return
     * @throws Exception
     */
    public String getCodeComboAsJson2(String codeType, Map<String, String> param) throws Exception {

		Map<String, Object> params = new HashMap<String, Object>();
		if(param != null) {
            params.put("param", param);
        } else {
		    param = new HashMap<String, String>();
        }

    	params.put("sqlSessionFactory", sqlSessionFactory);
		String sqlQuery = cmpcComboCache.getData(codeType);
		Map<String, String> userInfo = convertObjectMap(new BeanMap(UserInfoManager.getUserInfo()));
		Set<String> userInfoKeySet = userInfo.keySet();
		for (String key : userInfoKeySet) {
			param.put("ses." + key, userInfo.get(key));
		}
		params.put("_sqlQuery_", sqlQuery);
		List<Map> resultList = comboMapper.getCodesBySQL2(params);

		return new ObjectMapper().writeValueAsString(resultList);
	}

    /**
     * STOCCODD 테이블에서 텍스트로 가져올 컬럼의 키를 지정해서 공통코드 리스트를 조회하여 JSON 형태로 반환합니다.
     * @param codeType
     * @param columnKey
     * @return
     * @throws Exception
     */
    public String getCodeComboAsJsonByColumnKey(String codeType, String columnKey) throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getCodeComboByColumnKey(codeType, columnKey));
    }

    /**
     * STOCCODD 테이블에서 텍스트로 가져올 컬럼의 키를 지정해서 공통코드 리스트를 반환합니다.
     * @param codeType 코드타입
     * @param columnKey 컬럼 키
     * @return List.Map
     * @throws Exception
     */
	public List<Map<String, String>> getCodeComboByColumnKey(String codeType, String columnKey) throws Exception {

		String colKey;
		colKey = EverString.isEmpty(columnKey) ? "CODE_DESC" : columnKey;
		String langCd = UserInfoManager.getUserInfo().getLangCd();

		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		boolean isCodeExposure = PropertiesManager.getBoolean("eversrm.system.codeExposureFlag");

		if(codeType.indexOf("CB") > -1) {
			Map<String, String> param = new HashMap<String, String>();
			List<Map> codesByCommonId = getCodes(codeType, param);
			for (Map<String, String> code : codesByCommonId) {
				Map<String, String> map = new HashMap<String, String>();
				map.putAll(code);
				map.put("value", code.get("value"));
				map.put("text", code.get("text"));
				ObjectMapper objectMapper = new ObjectMapper();
				objectMapper.configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true);
				objectMapper.configure(JsonParser.Feature.ALLOW_SINGLE_QUOTES, true);
				map.put("data", objectMapper.writeValueAsString(code).replaceAll("\"", "&quot;"));
				list.add(map);
			}
		} else {
			List<Map<String, String>> codes = codeCache.getData(codeType, langCd);
			for (Map<String, String> code : codes) {
				Map<String, String> map = new HashMap<String, String>();
				map.put("value", code.get("CODE"));

				if(colKey.equals("CODE (DESC)")) {
					map.put("text", code.get("CODE") + " (" + code.get("CODE_DESC") + ")" + (isCodeExposure ? " ["+code.get("CODE")+"]" : ""));
				} else {
					map.put("text", code.get(colKey) + (isCodeExposure ? " ["+code.get("CODE")+"]" : ""));
				}

				list.add(map);
			}
		}
		return list;
	}

	public String getCodesAsJson(String codeType, Map<String, String> param) throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getCodes(codeType, param));
    }

	@SuppressWarnings({"rawtypes", "unchecked"})
	public List<Map> getCodes(String commonId, Map<String, String> param) throws Exception {
		String sqlQuery = cmpcComboCache.getData(commonId);
//		logger.info("====================================================================================================================\n{}\n\"====================================================================================================================", sqlQuery);
		/*
		 * How to use?
		 * Query : SELECT * FROM ICOMUSER WHERE HOUSE_CODE = #HOUSE_CODE# AND USER_ID = #USER_ID#
		 * Parameter Map : Map<String, String> param = new HashMap<String, String>();
		 * 				   param.put("HOUSE_CODE", "100");
		 * 				   param.put("USER_ID", "MASTER");
		 *
		 * commonComboService.getCodes("CB0001", param);
		 *
		 */

		sqlQuery = CommonCodeUtil.getReplacedSql(sqlQuery, param);

//		if (sqlQuery.contains("#")) {
//			throw new NoResultException("Set Requried Parameter. \n" + sqlQuery);
//		}

		final List<Map> codeList;
		Map<String, Object> paramObj = new HashMap<>();
		paramObj.put("sqlSessionFactory", sqlSessionFactory);
		paramObj.put("param", param);
		paramObj.put("_sqlQuery_", sqlQuery);

		param.put("_sqlQuery_", sqlQuery);

		codeList = comboMapper.getCodesBySQL2(paramObj); // .size() == 0 ? comboMapper.getCodesBySQL(param) : comboMapper.getCodesBySQL2(paramObj);

		boolean isCodeExposure = PropertiesManager.getBoolean("eversrm.system.codeExposureFlag");

		if ("Y".equals(param.get("codeExposureFlagPassYn"))) {
			return codeList;
		}

		if(isCodeExposure) {
			for (Iterator iterator = codeList.iterator(); iterator.hasNext();) {
				Map<String, String> map = (Map<String, String>)iterator.next();
				if(map.containsKey("text") && map.containsKey("value")) {
					map.put("text", map.get("text") + "[" + map.get("value") + "]");
				}
			}
		}
		return codeList;

	}

	public String getHourCodesAsJson() throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getHourCodes());
    }


	public List<Map<String, String>> getHourCodes() {
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		for (int i = 0; i < 24; i++) {
			HashMap<String, String> hashMap = new HashMap<String, String>();
			final String hour2Digit = String.format("%02d", i);
			hashMap.put("text", hour2Digit);
			hashMap.put("value", hour2Digit);
			list.add(hashMap);
		}
		return list;
	}

	public String getMinutesCodesAsJson() throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getMinutesCodes());
    }

	public List<Map<String, String>> getMinutesCodes() {
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		for (int i = 0; i < 60; i++) {
			HashMap<String, String> hashMap = new HashMap<String, String>();
			final String minuteDigit = String.format("%02d", i);
			hashMap.put("text", minuteDigit);
			hashMap.put("value", minuteDigit);
			list.add(hashMap);
		}
		return list;
	}

	public String getMinutesPartTenCodesAsJson() throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getMinutesPartTenCodes());
    }

	public List<Map<String, String>> getMinutesPartTenCodes() {
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		for (int i = 0; i < 6; i++) {
			HashMap<String, String> hashMap = new HashMap<String, String>();
			final String minuteDigit = String.format("%02d", i * 10);
			hashMap.put("text", minuteDigit);
			hashMap.put("value", minuteDigit);
			list.add(hashMap);
		}
		return list;
	}

	public String getYearListAsJson(String fromYear, String toYear) throws Exception {
        ObjectMapper om = new ObjectMapper();
        return om.writeValueAsString(getYearList(fromYear, toYear));
    }

	public List<Map<String, String>> getYearList(String fromYear, String toYear) throws Exception {
		List<Map<String, String>> list = new ArrayList<Map<String, String>>();
		for (int i = Integer.parseInt(toYear) ; i >= Integer.parseInt(fromYear); i--) {
			HashMap<String, String> hashMap = new HashMap<String, String>();
			final String year = i + "";
			hashMap.put("text", year.substring(year.length() - 4));
			hashMap.put("value", year.substring(year.length() - 4));
			list.add(hashMap);
		}
		return list;
	}

}