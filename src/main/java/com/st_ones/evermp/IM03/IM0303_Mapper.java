package com.st_ones.evermp.IM03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0303_Mapper {

    // 신규품목 처리현황
	//List<Map<String, Object>> im03031_doSearch(Map<String, String> param);
	List<Map<String, Object>> im03031_doSearch(Map<String, Object> param);

 	void im03031_doAcpt(Map<String, Object> gridData);

 	void im03031_doReject(Map<String, Object> gridData);

	void im03031_doDelete(Map<String, Object> gridData);

 	// 계약현황
    List<Map<String,Object>> im01040_doSearch(Map<String, String> formData);

	void doInsertINFH(Map<String, Object> data);

	void doUpdateINFO(Map<String, Object> data);

	void doInsertNWRQ(Map<String, Object> rqdtData);

	void doInsertRQHD(Map<String, String> rqhdData);

	void doInsertRQDT(Map<String, Object> rqdtData);

	void doInsertRQVN(Map<String, Object> rqvnData);

	Map<String, String> getRfqInfoHD(Map<String, String> param);

	List<Map<String, String>> getRfqItemList(Map<String, String> param);

	List<Map<String, String>> getRfqVendorList(Map<String, String> param);

	List<Map<String, Object>> im01042_doNeoSearch(Map<String, String> param);

}
