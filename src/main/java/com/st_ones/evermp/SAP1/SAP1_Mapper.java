package com.st_ones.evermp.SAP1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SAP1_Mapper {

	/** ******************************************************************************************
     * 공급사 > 정산관리 > 정산관리 > 마감현황(품목별)
     * @param param
     * @return List
     * @throws Exception
     */
	List<Map<String, Object>> sap1010_doSearch(Map<String, String> param);
	/** ******************************************************************************************
	 * 공급사 > 정산관리 > 정산관리 > 마감현황(고객사별)
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> sap1020_doSearch(Map<String, String> param);
}