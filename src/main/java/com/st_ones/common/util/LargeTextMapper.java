package com.st_ones.common.util;

import org.springframework.stereotype.Repository;

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
 * @File Name : LargeTextMapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface LargeTextMapper {

	// LargeTextCLOB
    void insertLargeText(Map<String, String> param);
	String selectLargeText(Map<String, String> map);
	void updateLargeText(Map<String, String> map);
	
	// LargeTextSplitString
    List<String> selectTXTD(Map<String, String> map);
	void insertTXTH(Map<String, String> param);
	String getTextSq(Map<String, String> map);
	void insertTXTD(Map<String, String> param);
	void deleteTXTD(Map<String, String> map);

	// MSSQL TEXT For Mail
	void insertMailContents(Map<String, String> param);
	String selectMailContents(Map<String, String> map);

}