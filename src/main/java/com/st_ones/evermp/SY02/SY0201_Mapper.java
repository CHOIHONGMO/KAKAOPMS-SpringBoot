package com.st_ones.evermp.SY02;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SY0201_Mapper {

	/** ******************************************************************************************
	 * 휴일관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> sy02001_doSearch(Map<String, String> param);

	int sy02001_doCheck(Map<String, Object> gridData);

	void sy02001_doSave(Map<String, Object> gridData);

	void sy02001_doDelete(Map<String, Object> gridData);

	/** ******************************************************************************************
	 * 세금계산서발행마감일관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> sy02001_doSearchTx(Map<String, String> param);

	int sy02001_doCheckTx(Map<String, Object> gridData);

	void sy02001_doSaveTx(Map<String, Object> gridData);

	void sy02001_doDeleteTx(Map<String, Object> gridData);

}