package com.st_ones.evermp.IM04;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0402_Mapper {

	/** ****************************************************************************
     * 품목분류 현황
     * @param param
     * @return
     * @throws Exception
     */
	Map<String, String> doGetSgInfoById(Map<String, String> param);

	List<Map<String, Object>> doSearchSupplierInfo(Map<String, String> param);

	List<Map<String, Object>> doSearchItemClassnfo(Map<String, String> param);
	List<Map<String, Object>> doSearchPTItemClassnfo(Map<String, String> param);


	List<Map<String, Object>> doSearchDtree(Map<String, String> param);

	int saveSgDefinition(Map<String, String> param);

	int updateSgDefinition(Map<String, String> param);

	int multiLanguagePopupDoUpdateWithoutMultiSEQ(Map<String, String> paramMul);

	List<Map<String, Object>> getWholeTreeBySG_NO(Map<String, String> param);

	int deleteSupplierWithDefinition(Map<String, Object> param);

	int deletePICWithDefinition(Map<String, Object> param);

	int deleteItemClassWithDefinition(Map<String, Object> param);

	int deleteSGDefinition(Map<String, Object> param);

	int deleteSGNMDefinition(Map<String, Object> param);

	int checkExistSupplier(Map<String, String> param);

	int doSaveSupplierInfo(Map<String, String> param);

	int doDeleteSuplier(Map<String, String> param);

	int checkExistItemClass(Map<String, Object> one);

	int doSaveItemClass(Map<String, Object> one);

	int doDeleteItemClass(Map<String, Object> one);

	/** ****************************************************************************
     * S/G-품목분류 연결
     * @param req
     * @return
     * @throws Exception
     */
	@SuppressWarnings("rawtypes")
	List<Map> listClassItemStatus(Map<String, String> param);

	List<Map<String, Object>> doSearchSgItemClassMapping(Map<String, Object> param);

	List<Map<String, Object>> doSearchSg_PTItemClassMapping(Map<String, Object> param);

	void doDeleteSgItemClassMapping(Map<String, Object> gridData);

	List<Map<String, Object>> getSgParentList(Map<String, String> param);

	int doDeleteRealItemClass(Map<String, Object> one);

	/** ******************************************************************************************	 *
	 * S/G선택 팝업(트리그리드)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> im04006_treepdoSearch(Map<String, String> param);

	/** ****************************************************************************************************************
     * 품목분류(팝업)
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> doSearchItemClassPopup_TREE(Map<String, String> param);

	//판촉팝업
	List<Map<String, Object>> doSearchPT_ItemClassPopup_TREE(Map<String, String> param);


	/** ****************************************************************************************************************
     * S/G-협력회사 연결
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> doSearchSgVendorMapping(Map<String, Object> param);

	int doDeleteSgVendorMapping(Map<String, Object> param);

	int doDeleteRealSupplierInfo(Map<String, Object> param);

}