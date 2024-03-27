package com.st_ones.evermp.SIT1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SIT101_Mapper {
	
	// 신규품목 처리요청
	public List<Map<String, Object>> sit1021_doSearch(Map<String, String> param);
	
	// 신규등록
	public void sit1021_doInsert(Map<String, Object> gridData);
	
	// 변경
	public void sit1021_doUpdate(Map<String, Object> gridData);
	
	// 신규품목 삭제
	public void sit1021_doDelete(Map<String, Object> gridData);

	// 신규품목 처리현황
	public List<Map<String, Object>> sit1020_doSearch(Map<String, String> param);
	
	// 신규품목 요청취소
	public void sit1020_doCancel(Map<String, Object> gridData);
	
}