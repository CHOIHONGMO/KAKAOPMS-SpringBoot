package com.st_ones.common.util.service;

import com.st_ones.common.util.LargeTextMapper;
import org.apache.commons.lang3.text.StrBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class LargeTextSplitString implements LargeText {

	private Logger logger = LoggerFactory.getLogger(LargeTextSplitString.class);
	private final int SEPRATE_STRING_LENGTH = 1000;

	@Autowired
	private LargeTextMapper largeTextMapper;

	public String get(Map<String, String> map) throws Exception {

		List<String> selectTXTDs = largeTextMapper.selectTXTD(map);
		StrBuilder builder = new StrBuilder();
		for (String txtd : selectTXTDs) {
			builder.append(txtd);
		}
		return builder.toString();
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void insert(Map<String, String> map) {

		// CheckInjectionForRichEditor를 두번 타는 것을 막기 위함.
		String richTextValue = map.get("RICH_TEXT_EDIT");
		map.remove("RICH_TEXT_EDIT");
		largeTextMapper.insertTXTH(map);
		
		map.put("RICH_TEXT_EDIT", richTextValue);

		try {
			insertTXTD(map.get("TEXT_NUM"), map.get("RICH_TEXT_EDIT"));
		} catch (Exception e) { logger.error(e.getMessage(), e); }
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void update(Map<String, String> map) {

		largeTextMapper.deleteTXTD(map);

		try {
			insertTXTD(map.get("TEXT_NUM"), map.get("RICH_TEXT_EDIT"));
		} catch (Exception e) { logger.error(e.getMessage(), e); }
	}
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	private void insertTXTD(String textNo, String textContents) throws Exception {

		if(textContents != null) {

			List<String> splitStrings = getSplitString(textContents);
			HashMap<String, String> txtdMap = new HashMap<String, String>();
			for (String splitString : splitStrings) {
				txtdMap.put("TEXT_NUM", textNo);
				txtdMap.put("TEXT_SQ", largeTextMapper.getTextSq(txtdMap));
				txtdMap.put("RICH_TEXT_EDIT", splitString);
				largeTextMapper.insertTXTD(txtdMap);
				txtdMap.clear();
			}
		}
	}

	private List<String> getSplitString(String textContents) {

		List<String> strList = new ArrayList<String>();
		int length = textContents.length();
		int splitCount = length / SEPRATE_STRING_LENGTH;
		
		if(length%SEPRATE_STRING_LENGTH == 0){
			splitCount--;
		}

		for (int i = 0; i < splitCount + 1; i++) {
			int beginIndex = i * SEPRATE_STRING_LENGTH;
			int endIndex = (i + 1) * SEPRATE_STRING_LENGTH;
			if (splitCount == i) {
				endIndex = length;
			}
			strList.add(textContents.substring(beginIndex, endIndex));
		}

		return strList;
	}
}