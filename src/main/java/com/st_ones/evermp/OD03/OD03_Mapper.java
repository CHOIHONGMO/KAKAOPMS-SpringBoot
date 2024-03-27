package com.st_ones.evermp.OD03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface OD03_Mapper {

	/** ******************************************************************************************
     * 운영사 > 주문관리 > 입고현황 > 미입고현황
     * @param param
     * @return List
     * @throws Exception
     */
	List<Map<String, Object>> od03010_doSearch(Map<String, String> param);


	int chkGrdt(Map<String, Object> param);
	int chkGrdtSubul(Map<String, Object> param);


	void od03010_doGrSaveGRDT(Map<String, Object> param);
	void od03010_doGrSaveUIVDT(Map<String, Object> param);
	void od03010_doGrSaveYIVDT(Map<String, Object> param);
	void od03010_doGrSaveYPODT(Map<String, Object> param);
	void od03010_doGrSaveUPODT(Map<String, Object> param);
	int od03010_doSearchTOT_GR_QTY(Map<String, Object> param);

	/** ******************************************************************************************
	 * 운영사 > 주문관리 > 입고현황 > 입고현황
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> od03020_doSearch(Map<String, String> param);
	void od03020_doGrCancelGRDT(Map<String, Object> param);



	/** ******************************************************************************************
	 * 재고관리 > 재고입고관리 > 물류센터 입고대상목록 (OD03_030)
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	//조회
	List<Map<String, Object>> od03030_doSearch(Map<String, String> param);

	//수불업데이트
	void od03030_doMMRSInsert(Map<String, Object> gridData);
	//수불삭제
	void od03040_doDeleteMMRS(Map<String, Object> gridData);

	//납품서수정
	void od03030_doUpdateUIVHD(Map<String, Object> gridData);
	void od03030_doUpdateYIVHD(Map<String, Object> gridData);
	void od03030_doUpdateUIVDT(Map<String, Object> gridData);
	void od03030_doUpdateYIVDT(Map<String, Object> gridData);
	Map<String, Object> getPoQtySumInvQty(Map<String, Object> gridData);
	void od03030_doUpdateUPODT(Map<String, Object> gridData);
	void od03030_doUpdateYPODT(Map<String, Object> gridData);

	//납품취소
	int chkUivdt(Map<String, Object> gridData);
	void od03030_doDeleteUIVDT(Map<String, Object> gridData);
	void od03030_doDeleteYIVDT(Map<String, Object> gridData);
	void od03030_doDeleteUPODT(Map<String, Object> gridData);
	void od03030_doDeleteYPODT(Map<String, Object> gridData);


	/** ******************************************************************************************
	 * 재고관리 > 재고입고관리 > 물류센터 입고현황 (OD03_040) (OD03_030)
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> od03040_doSearch(Map<String, String> param);












	Map<String, Object> chkPoGr(Map<String, Object> param);




	void deleteUpoHD(Map<String, Object> gridData);
	void deleteUpoDT(Map<String, Object> gridData);
	void deleteYpoHD(Map<String, Object> gridData);
	void deleteYpoDT(Map<String, Object> gridData);
	void deleteIvHD(Map<String, Object> gridData);
	void deleteIvDT(Map<String, Object> gridData);
	void deleteInvHD(Map<String, Object> gridData);
	void deleteInvDT(Map<String, Object> gridData);
	void deleteGrDT(Map<String, Object> gridData);


}