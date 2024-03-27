package com.st_ones.evermp.SGR1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SGR1_Mapper {

	/** ******************************************************************************************
     * 공급사 > 입고관리 > 입고관리 > 미입고관리
     * @param param
     * @return List
     * @throws Exception
     */
	List<Map<String, Object>> sgr1010_doSearch(Map<String, String> param);

	/** ******************************************************************************************
	 * 공급사 > 입고관리 > 입고관리 > 입고현황
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> sgr1020_doSearch(Map<String, String> param);
}