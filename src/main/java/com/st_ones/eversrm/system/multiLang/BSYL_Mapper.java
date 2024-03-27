package com.st_ones.eversrm.system.multiLang;

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
 * @File Name : BSYL_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Repository
public interface BSYL_Mapper {

	List<Map<String, Object>> doSearch(Map<String, String> searchForm);

	int checkColumnId(Map<String, Object> gridData);

	void doInsert(Map<String, Object> gridData);
	void doUpdate(Map<String, Object> gridData);
	void doDelete(Map<String, Object> gridData);

	List<Map<String, Object>> doSearchDataLength(Map<String, String> param);
	List<Map<String, Object>> doSearchDOMC(Map<String, String> param);
	List<Map<String, Object>> doSearchWord(Map<String, String> param);
	Map<String,String> getMostUsedWord(Map<String, String> param);
	List<Map<String, Object>> getMultiLanguageList(Map<String, String> param);

	void multiLanguagePopupDoUpdate(Map<String, Object> gridData);
	void multiLanguagePopupDoInsert(Map<String, Object> gridData);
	void multiLanguagePopupDoDelete(Map<String, Object> gridData);

	void insertMenuName(Map<String, String> param);
	void updateMenuName(Map<String, String> param);

	Map<String, String> selectScreenAccessibleCode(Map<String, String> param);
	int insertScreenAccessibleCode(Map<String, String> rowData);
	int updateScreenAccessibleCode(Map<String, String> rowData);
	int getCountExistsScreenAccessibleCode(Map<String, String> formData);

	int checkUSLN(Map<String, String> param);
	List<Map<String, Object>> BSYL021_STOCLANG_Search(Map<String, String> param);
	List<Map<String, Object>> BSYL021_STOCUSCC_Search(Map<String, String> param);

	void BSYL021_doSave(Map<String, Object> grid) throws Exception;
	void BSYL021_doDelete(Map<String, Object> param) throws Exception;
	void BSYL021_doReset(Map<String, String> param);

	void BSYL_022_doSave(Map<String, Object> grid) throws Exception;
	List<Map<String,Object>> BSYL_022_doSearch(Map<String, String> formData) throws Exception;
	void BSYL_022_doDelete(Map<String, Object> grid);

}
