package com.st_ones.common.cache.data;

import com.st_ones.common.cache.CacheMapper;
import com.st_ones.common.generator.domain.GridMeta;
import org.apache.commons.beanutils.BeanMap;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
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
 * @File Name : ColumnInfoCache.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Service(value = "columnInfoCache")
public class ColumnInfoCache {

	@Autowired private CacheMapper cacheMapper;
	protected Map<String, List<GridMeta>> data = new HashMap<String, List<GridMeta>>();

	protected Map<String, List<GridMeta>> getCacheData() {
		return data;
	}

	@Cacheable("gridCache")
	public List<GridMeta> getData(String screenId, String gridId, String langCode) {

		List<GridMeta> columnInfos = cacheMapper.getColumnInfos(screenId, gridId, langCode);
		List<GridMeta> clone = new ArrayList<GridMeta>();
		List<GridMeta> maskColumns = new ArrayList<GridMeta>();
		for (GridMeta columnInfo : columnInfos) {

			Map<String, Object> map = (Map) new BeanMap(columnInfo);
			Set<String> keySet = map.keySet();
			for (String key: keySet) {
				if(key.equals("ses")){
					continue;
				}
				if(map.get(key) instanceof String && ((String)map.get(key)).contains("\n")){
//					LOGGER.warn("GridMeta data has line feed");
				}
			}

			if(StringUtils.equals(columnInfo.getWidth(), "0")) {
				columnInfo.setVisible(false);
			}

			clone.add(new GridMeta(columnInfo));

			if(StringUtils.isNotEmpty(columnInfo.getMaskType())) {
				GridMeta t = new GridMeta(columnInfo);
				t.setColumnId(t.getColumnId()+"_$TP");
				t.setWidth("0");
				t.setEssential("D");
				t.setVisible(false);

				maskColumns.add(t);
			}
		}

		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		for (GridMeta GridMeta : columnInfos) {
			Map<String, Object> map = new HashMap<String, Object>();
			map.putAll((Map) new BeanMap(GridMeta));
			map.remove("ses");
			map.remove("class");
			list.add(map);
		}

		clone.addAll(maskColumns);

		return clone;
	}

	@CacheEvict(value = "gridCache", allEntries = true)
	public void removeAllCaches() {}

	@CacheEvict(value = "gridCache")
	public void removeData(String screenId, String gridId, String langCode) {}
}
