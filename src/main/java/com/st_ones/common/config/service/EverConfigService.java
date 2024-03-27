package com.st_ones.common.config.service;

import com.st_ones.common.cache.data.SystCache;
import com.st_ones.common.config.EverConfigMapper;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : EverConfigService.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "everConfigService")
public class EverConfigService extends BaseService {

		@Autowired
		EverConfigMapper everConfigMapper;

		@Autowired
		SystCache systCache;

		Logger logger = LoggerFactory.getLogger(EverConfigService.class);

		public String getSystemConfig(String key) throws Exception {
			return getValue(filter("SETTING_TYPE", "SYSTEM", getValueList(key)));
		}

		public String getHouseConfig(String gateCd, String key) throws Exception {
			return getValue(filter("GATE_CD", gateCd, filter("SETTING_TYPE", "OSCM", getValueList(key))));
		}

		public String getBuyerConfig(String gateCd, String buyerCd, String key) throws Exception {
			return getValue(filter("BUYER_CD", buyerCd, filter("GATE_CD", gateCd, filter("SETTING_TYPE", "OSCM", getValueList(key)))));
		}

		public String getPurOrgConfig(String gateCd, String buyerCd, String purOrgCd, String key) throws Exception {
			return getValue(filter("PUR_ORG_CD", purOrgCd, filter("BUYER_CD", buyerCd, filter("GATE_CD", gateCd, filter("SETTING_TYPE", "OSCM", getValueList(key))))));
		}

		public String getPlantConfig(String gateCd, String buyerCd, String plantCd, String key) throws Exception {
			return getValue(filter("PLANT_CD", plantCd, filter("BUYER_CD", buyerCd, filter("GATE_CD", gateCd, filter("SETTING_TYPE", "OSCM", getValueList(key))))));
		}

		private String getValue(List<Map<String, String>> list) throws Exception {
			if (list.size() == 0) {
				throw new NoResultException("invalid key");
			}
			
//			2015.11.10 daguri
//			if (list.size() > 1) {
//				throw new NoResultException("duplicated value");
//			}
			
			String value = list.get(0).get("SYS_VALUE");
			return value;
		}

		private List<Map<String, String>> getValueList(String configType) {
			return systCache.getData(configType);
		}

		private List<Map<String, String>> filter(String key, String value, List<Map<String, String>> list) {
			logger.info(String.format("KEY: %s, Value: %s", key, value));
			List<Map<String, String>> filteredList = new ArrayList<Map<String, String>>();
			for (Map<String, String> map : list) {
				if (map.get(key).equals(value)) {
					filteredList.add(map);
				}
			}
			return filteredList;
		}
	}