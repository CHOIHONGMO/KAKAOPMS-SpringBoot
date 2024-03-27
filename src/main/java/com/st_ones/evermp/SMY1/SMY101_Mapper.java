package com.st_ones.evermp.SMY1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 28 오전 11:44
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SMY101_Mapper {

	/** ******************************************************************************************
     * 협력사 납품게시판
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> smy1030_doSearch(Map<String, String> param);

}