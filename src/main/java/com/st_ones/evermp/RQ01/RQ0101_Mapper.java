package com.st_ones.evermp.RQ01;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */


@Repository
public interface RQ0101_Mapper {

	/** *****************
     * 견적의뢰대상
     * ******************/
	List<Map<String, Object>> rq01010_doSearch(Map<String, Object> param);

	List<Map<String, Object>> getReRfqItemList(Map<String, String> param);

	String checkProgressCd(Map<String, Object> param);

	void doTransferCtrlUser(Map<String, Object> gridData);

	void doReturnItem(Map<String, Object> gridData);

	void doInsertRQHD(Map<String, String> rqhdData);
	// by sslee
	int doDeleteRQVN(Map<String, Object> rqvnData);

	void doInsertRQDT(Map<String, Object> rqdtData);

	// 재견적시 기존차수는 "재견적" 진행상태 변경
	void updateReRfqStatusDT(Map<String, Object> rqdtData);
	void updateReRfqStatusHD(Map<String, String> param);

	void doInsertRQVN(Map<String, Object> rqvnData);

	void updateProgressCdNWRQ(Map<String, Object> rqdtData);

	Map<String, String> getRfqInfoHD(Map<String, String> param);

	List<Map<String, String>> getRfqItemList(Map<String, String> param);

	List<Map<String, String>> getRfqVendorList(Map<String, String> param);

	Map<String, String> getRfqHD(Map<String, String> param);

	List<Map<String, String>> getPreRfqVendorList(Map<String, String> param);

	/** *****************
	 * 공급사선택
	 * ******************/
	List<Map<String, Object>> rq01012_doSearchDefault(Map<String, String> param);
	List<Map<String, Object>> rq01013_doSearchDefault(Map<String, String> param);
	/** *****************
	 * item list
	 * ******************/
	List<Map<String, Object>> rq01011_doSearchDefault(Map<String, String> param);

	List<Map<String, Object>> getSgParentList(Map<String, String> param);

	List<Map<String, Object>> rq01012_doSearch(Map<String, Object> param);

	Map<String, String> getWorkingDay();

	void deleteRQVN(Map<String, String> rqhdData);
}
