package com.st_ones.eversrm.system.menu;

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
 * @File Name : BSYM_Mapper.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Repository
public interface BSYM_Mapper {

	List<Map<String, Object>> getMenuTemplates(Map<String, String> param);

	List<Map<String, Object>> getStocmutm(Map<String, String> param);

	int createMenuTemplate(Map<String, Object> gridData);

	int updateMenuTemplate(Map<String, Object> gridData);

	int updateMenuTemplateList(Map<String, Object> gridData);

	int deleteMenuTemplate(Map<String, Object> gridData);

	int deleteMenuTemplateDetailList(Map<String, Object> gridData);

	List<Map<String, Object>> getMenuTemplateTree(Map<String, String> param);

	List<Map<String, Object>> getMenuTemplateDtree(Map<String, String> param);

	List<Map<String, Object>> selectStocmuba(Map<String, String> param);

	Map<String, Object> searchMenuTemplateTreeNode(Map<String, String> param);

	String getMenuTmplCode(Map<String, String> param);

	int existsMenuTemplateDetail(Map<String, String> param);

	int updateSortSeqPlusOne(Map<String, String> param);

	int createMenuTemplateDetail(Map<String, String> param);

	int createMenuTemplateDetailMulg(Map<String, String> param);

	int copyMenuTemplateDetailMulg(Map<String, String> param);

	int updateMenuTemplateDetail(Map<String, String> param);

	int deleteMenuTemplateDetail(Map<String, String> param);

	int deleteStocmuba(Map<String, String> param);

	List<Map<String, Object>> searchMenu(Map<String, String> param);

	int createMenu(Map<String, Object> gridData);

	int copyMenuMums(Map<String, Object> gridData);

	int updateMenu(Map<String, Object> gridData);

	int deleteMenu(Map<String, Object> gridData);

	int deleteMenuMums(Map<String, Object> gridData);

	List<Map<String, Object>> getMenuTree(Map<String, String> param);

	List<Map<String, Object>> getMenuDtree(Map<String, String> param);

	List<Map<String, Object>> getMenuTreeForHiddenGrid(Map<String, String> param);

	List<Map<String, Object>> getMenuTemplateTreePopup(Map<String, String> param);

	List<Map<String, Object>> getMenuTemplateDtreePopup(Map<String, String> param);

	int deleteMenuTree(Map<String, String> param);

	int createMenuGroupCode(Map<String, Object> gridData);

	int insertStocmuba(Map<String, Object> gridData);

	int deleteMenuGroupCode(Map<String, Object> gridData);

	int updateMenuGroupCode(Map<String, Object> gridData);

	int existsMenuGroupCode(Map<String, Object> param);

}
