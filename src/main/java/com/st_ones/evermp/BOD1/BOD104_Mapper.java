package com.st_ones.evermp.BOD1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BOD104_Mapper {

	/** ******************************************************************************************
     * 고객사 > 주문관리 > 주문관리 > 주문조회/수정
     * @param param
     * @return List
     * @throws Exception
     */
	List<Map<String, Object>> bod1040_doSearch(Map<String, Object> param);
	void bod1040_doSaveUPODT(Map<String, Object> param);
	void bod1040_doSaveYPODT(Map<String, Object> param);
	String bod1040_getAccountCd(Map<String, Object> param);
	void bod1040_doSaveCCUBD(Map<String, Object> param);
	void bod1040_doCancelUPOHD(Map<String, Object> param);
	void bod1040_doCancelUPODT(Map<String, Object> param);
	void bod1040_doCancelYPOHD(Map<String, Object> param);
	void bod1040_doCancelYPODT(Map<String, Object> param);
	void bod1040_doCancelCCUBD(Map<String, Object> param);

	/** ******************************************************************************************
	 * 고객사 > 주문관리 > 주문관리 > 주문조회/수정 > 주문상세정보
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> bod1041_doSearch(Map<String, String> param);
	List<Map<String, Object>> bod1041_doSearchINV(Map<String, String> param);
	List<Map<String, Object>> bod1041_doSearchINV2(Map<String, String> param);
	
	// 고객사 주문정보 가져오기
	Map<String, Object> bod1042_doSearchHD(Map<String, String> param);
	List<Map<String, Object>> bod1042_doSearchDT(Map<String, String> param);
	List<Map<String, Object>> bod1042_doSearchImgDT(Map<String, String> param);
	List<Map<String, Object>> bod1042_getAddList(Map<String, String> param);
	void bod1042_doCart(Map<String, Object> gridData);

	// 주문완료 후 주문 공급사 가져오기
	List<Map<String, Object>> getCpoHeaderInfo(Map<String, String> param);
	List<Map<String, Object>> getCpoDetailInfo(Map<String, String> param);
	List<Map<String, Object>> getCpoVendorList(Map<String, String> param);
	
	// 결재완료 후 메일발송 목록 가져오기
	Map<String, Object> getCpoChangeHeaderInfo(Map<String, Object> param);
	List<Map<String, Object>> getCpoChangeDetailInfo(Map<String, Object> param);

}

