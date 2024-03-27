package com.st_ones.common.cache.data;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.text.StrBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
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
 * @File Name : LoginController.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
public class MapLogger<T> {
	
	Set<String> keySet = new HashSet<String>();
	
	Map<String, Integer> maxLengthMap = new HashMap<String, Integer>();
	
	private String formatter;
	
	private int totalLength;
	
	Logger logger = LoggerFactory.getLogger(this.getClass().getName());
	
	private String output;
	
	List<String> orderedKeyList = new ArrayList<String>();

	public MapLogger(Map<String, T> map) {
		if (map == null || map.keySet().size() == 0) {
			output = "empty";
		} else {
			output = mapToString(map);
		}
	}

	public MapLogger(List<Map<String, T>> list) {
		if (list == null || list.size() == 0) {
			output = "empty";
		} else {
			output = listToString(list);
		}
	}

	@Override
	public String toString() {
		return output;
	}

	public static String mapToJSON(Map<String, ?> map) throws IOException {
		return new ObjectMapper().writeValueAsString(map);
	}

	private void makeKeySet(Map<String, String> map) {
		if (!keySet.containsAll(map.keySet())) {
			for (String key : map.keySet()) {
				if (!keySet.contains(key)) {
					keySet.add(key);
				}
			}
		}

		setMaxLengthMap(map);
		setFormatter();
	}

	private void setFormatter() {
		StrBuilder builder = new StrBuilder();
		int _totalLength = 0;
		builder.append("\t|");
		_totalLength += 1;
		for (String key : orderedKeyList) {
			int unitMaxLength = maxLengthMap.get(key);
			int keyLength = key.length();
			
			if(keyLength > unitMaxLength){
				unitMaxLength = keyLength;
			}
			builder.append(" %-" + unitMaxLength + "s |");
			_totalLength += 3;
			_totalLength += unitMaxLength;
		}

		this.totalLength = _totalLength;
		this.formatter = builder.toString();
	}

	private String getLine() {
		StrBuilder strBuilder = new StrBuilder();
		strBuilder.append("\t|");
		for (int i = 1; i < totalLength - 1; i++) {
			strBuilder.append("-");
		}
		strBuilder.append("|");
		return strBuilder.toString();
	}

	private void setMaxLengthMap(Map<String, String> map) {
		for (String key : keySet) {
			int maxLehgth = getMaxLength(key, map);
			maxLengthMap.put(key, maxLehgth);
			setOrderedKeyList(key);
		}
	}

	private void setOrderedKeyList(String key) {
		if (orderedKeyList.contains(key)) {
			return;
		}
		boolean isAdded = false;
		for (int i = 0; i < orderedKeyList.size(); i++) {
			int maxLength = maxLengthMap.get(orderedKeyList.get(i));
			if (maxLength > maxLengthMap.get(key)) {
				orderedKeyList.add(i, key);
				isAdded = true;
				return;
			}
		}
		if (!isAdded) {
			orderedKeyList.add(key);
		}
	}

	private int getMaxLength(String key, Map<String, String> map) {
		int valueLength = map.get(key) == null ? 0 : map.get(key).length();
		int storedLength = maxLengthMap.get(key) == null ? 0 : maxLengthMap.get(key);
		return storedLength > valueLength ? storedLength : valueLength;
	}

	private String mapKeysToString() {
		List<String> list = new ArrayList<String>();
		for (String key : orderedKeyList) {
			list.add(key);
		}
		return String.format(formatter, list.toArray());
	}

	public String mapValuesToString(Map<String, String> map) {
		List<String> list = new ArrayList<String>();
		for (String key : orderedKeyList) {
			list.add(map.get(key));
		}
		return String.format(formatter, list.toArray());
	}

	public String mapToString(Map<String, ?> src) {
		Map<String, String> map = convertMap(src);
		makeKeySet(map);

		StrBuilder strBuilder = new StrBuilder();
		strBuilder.appendln(getLine());
		strBuilder.appendln(mapKeysToString());
		strBuilder.appendln(getLine());

		strBuilder.appendln(mapValuesToString(map));
		strBuilder.append(getLine());

		return strBuilder.toString();
	}

	private Map<String, String> convertMap(Map<String, ?> src) {
		Map<String, String> map = new HashMap<String, String>();
		Set<String> srcKeySet = src.keySet();
		for (String key : srcKeySet) {
			Object value = src.get(key);
			if (value != null) {
				value = value.toString();
			}
			map.put(key, (String) value);
		}
		return map;
	}

	public String listToString(List<Map<String, T>> list) {
		for (Map<String, ?> src : list) {
			Map<String, String> map = convertMap(src);
			makeKeySet(map);
		}

		StrBuilder strBuilder = new StrBuilder();
		strBuilder.appendln(getLine());
		strBuilder.appendln(mapKeysToString());
		strBuilder.appendln(getLine());

		for (Map<String, ?> src : list) {
			Map<String, String> map = convertMap(src);
			strBuilder.appendln(mapValuesToString(map));
		}
		strBuilder.append(getLine());
		return strBuilder.toString();
	}

}