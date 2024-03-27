package com.st_ones.common.util.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EverException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
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
 * @File Name : LargeTextService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "largeTextService")
public class LargeTextService {

	@Autowired private DocNumService docNumService;
	@Autowired LargeTextCLOB largeTextCLOB;
	@Autowired LargeTextSplitString largeTextSplitString;

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveLargeText(String textNo, String contents) throws Exception{

		Map<String, String> map = new HashMap<String, String>();
		map.put("RICH_TEXT_EDIT", contents);
		if (EverString.isEmpty(textNo)) {
			textNo = docNumService.getDocNumber("TN");
			map.put("TEXT_NUM", textNo);
			getLargeTextHandler().insert(map);
		} else {
			map.put("TEXT_NUM", textNo);
			getLargeTextHandler().update(map);
		}
		return textNo;
	}

	@SuppressWarnings("finally")
	public String selectLargeText(String textNo) throws Exception {

		Map<String, String> map = new HashMap<String, String>();
		map.put("TEXT_NUM", textNo);
		String text = getLargeTextHandler().get(map);
		if (text == null || text.equals("null")) {
			return "";
		}
		return text;
	}

	private LargeText getLargeTextHandler() throws Exception {

		LargeText largeText = null;
		final String largeTextServiceMode = PropertiesManager.getString("eversrm.system.largeTextService");
		if(largeTextServiceMode.equals("clob")){
			largeText = largeTextCLOB;
		} else if(largeTextServiceMode.equals("splitString")){
			largeText = largeTextSplitString;
		} else {
			throw new EverException("unknown largeTextService Mode");
		}
		return largeText;
	}

	public String selectTXTD(String textNo) throws Exception {

		Map<String, String> map = new HashMap<String, String>();
		map.put("TEXT_NUM", textNo);
		String text = getLargeTextHandler().get(map);
		if (text == null || text.equals("null")) {
			return "";
		}
		return text;
	}

	@Transactional(propagation = Propagation.NESTED, rollbackFor = Exception.class)
	public String saveMailContents(String contents) throws Exception{

		Map<String, String> map = new HashMap<String, String>();
		String textNo = docNumService.getDocNumber("TN");
		map.put("RICH_TEXT_EDIT", contents);

		//System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		//System.out.println(contents);
		//System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		map.put("TEXT_NUM", textNo);
		getLargeTextHandler().insert(map);

		return textNo;
	}

	public String selectMailContents(String textNo) throws Exception {

		return selectLargeText(textNo);
	}

}