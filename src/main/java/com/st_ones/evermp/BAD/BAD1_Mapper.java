package com.st_ones.evermp.BAD;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BAD1_Mapper {
	
	//고객사 사용자 조회
	List<Map<String, Object>> bad1020_doSearch(Map<String, String> param);
	
	///고객사 사용자 저장
	void bad1020_doSave(Map<String, Object> gridData);
	
	//고객사 사용자 삭제
	void bad1020_doDelete(Map<String, Object> gridData);
	
	//고객사 사용자상세 조회
	Map<String, String> bad1021_doSearch(Map<String, String> param);
	
	//고객사 사용자 등록 및 수정
	void bad1021_doSave(Map<String, String> formData);

	//고객사 사용자 아이디 중복체크
	String bad1021_doCheckUserId(Map<String, String> param);

	//처음등록시권한저장
	void bad1021_doInsertUser_USAP(Map<String, String> formData);

	//예산조회
	List<Map<String, Object>> bad1040_doSearch(Map<String, String> param);
	
	///예산저장
	void bad1040_mergeData(Map<String, Object> gridData);
	
	//예산삭제
	void bad1040_doDelete(Map<String, Object> gridData);

	//계정조회
	List<Map<String, Object>> bad1050_doSearch(Map<String, String> param);
	
	///계정저장
	void bad1050_mergeData(Map<String, Object> gridData);
	
	//계정삭제
	void bad1050_doDelete(Map<String, Object> gridData);

	List<Map<String, Object>> bad1030_doSearch(Map<String, String> param);

	void bad1030_doSave(Map<String, Object> gridData);

	// BAD2_010 : 부서별 실적분석
	List<Map<String, Object>> bad2010_doSearch(Map<String, String> param);
	
	// BAD2_020 : 주문번호별 실적분석
	List<Map<String, Object>> bad2020_doSearch(Map<String, String> param);
	
	// BAD2_030 : 품목별 실적분석
	List<Map<String, Object>> bad2030_doSearch(Map<String, String> param);
	
	/** *****************
	 * 관리자 > 배송지현황
	 * ******************/
	List<Map<String, Object>> bad1070_doSearchD(Map<String, String> param);
	int insertStocCsdm(Map<String, Object> gridData);
	int updateStocCsdm(Map<String, Object> gridData);
	void bad1070_doDeleteDT(Map<String, Object> param);
	/** *****************
	 * 관리자 > 청구지현황
	 * ******************/
	List<Map<String, Object>> bad1080_doSearchD(Map<String, String> param);
	

}