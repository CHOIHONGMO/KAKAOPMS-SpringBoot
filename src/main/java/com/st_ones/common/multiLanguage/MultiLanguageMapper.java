package com.st_ones.common.multiLanguage;

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
 * @File Name : MultiLanguageMapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 08. 23.
 * @version 1.0  
 * @see 
 */
@Repository
public interface MultiLanguageMapper {

	List<Map<String, Object>> getMultiLanguageList(Map<String, String> param);

	void multiLanguagePopupDoUpdate(Map<String, Object> gridData);

	void multiLanguagePopupDoInsert(Map<String, Object> gridData);
	
	void multiLanguagePopupDoDelete(Map<String, Object> gridData);
	
	void insertMenuName(Map<String, String> param);

	void updateMenuName(Map<String, String> param);

}