package com.st_ones.common.util.service;

import com.st_ones.common.util.LargeTextMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : LargeTextCLOB.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Component
public class LargeTextCLOB implements LargeText {

	@Autowired private LargeTextMapper largeTextMapper;

	public String get(Map<String, String> map) throws Exception {
		return largeTextMapper.selectLargeText(map);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void insert(Map<String, String> map) {
		largeTextMapper.insertLargeText(map);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void update(Map<String, String> map) {
		largeTextMapper.updateLargeText(map);
	}

	public String selectMailContents(Map<String, String> map) throws Exception {
		return largeTextMapper.selectMailContents(map);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void insertMailContents(Map<String, String> map) {
		largeTextMapper.insertMailContents(map);
	}

}