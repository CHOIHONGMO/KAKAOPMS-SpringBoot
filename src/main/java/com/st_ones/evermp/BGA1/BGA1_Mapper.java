package com.st_ones.evermp.BGA1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BGA1_Mapper {

	/** ******************************************************************************************
     * 고객사 > 입고/정산 > 입고/정산관리 > 미입고관리
     * @param param
     * @return List
     * @throws Exception
     */
	List<Map<String, Object>> bga1010_doSearch(Map<String, String> param);
	void bga1010_doGrSaveGRDT (Map<String, Object> param);
	void bga1010_doGrSaveUIVDT(Map<String, Object> param);
	void bga1010_doGrSaveYIVDT(Map<String, Object> param);
	void bga1010_doGrSaveYPODT(Map<String, Object> param);
	void bga1010_doGrSaveUPODT(Map<String, Object> param);
	int bga1010_doSearchTOT_GR_QTY(Map<String, Object> param);

	/** ******************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 입고관리
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> bga1030_doSearch(Map<String, String> param);
	void bga1030_doGrCancelGRDT(Map<String, Object> param);
	String bga1030_SELECT_CODD();
	List<Map<String, Object>> bga1030_doSearchEXCEL(Map<String, String> param);

	/** ******************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 매입확정
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> bga1040_doSearch(Map<String, String> param);
	void bga1040_doUpdateAPAR(Map<String, Object> param);
	List<Map<String, Object>> bga1040_doSearchEXCEL(Map<String, String> param);

	/** ******************************************************************************************
	 * 고객사 > 입고/정산 > 입고/정산관리 > 정산현황
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> bga1050_doSearch(Map<String, String> param);

	List<Map<String, Object>> bga1060_doSearch(Map<String, String> param);

	// 공급사 납품지연 목록 가져오기(희망납기일 D+1 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	Map<String, Object> getInvoiceDelayItemList(Map<String, Object> param);

	void upsGrClose(Map<String, Object> param);





	int chkCloseAgree(Map<String, Object> param);
	int chkCloseCancel(Map<String, Object> param);


}