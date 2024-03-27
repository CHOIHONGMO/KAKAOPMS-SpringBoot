package com.st_ones.evermp.BS02;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BS0201_Mapper {

	/** ******************************************************************************************
	 * 협력회사
	 * @param req
	 * @return
	 * @throws Exception
	 */

	//예산조회
	List<Map<String, Object>> bs02001_doSearch(Map<String, String> param);
	
	// 예산 마감여부 체크
	String isBudgetCloseFlag(Map<String, String> param);
	
	// 기준정보 > 고객사 계정/예산 > 예산 관리 (BS02_001) : 예산 관리 => 사업부, 부서 단위로 예산 관리함
	List<Map<String, Object>> doSelect_budgetDeptTree(Map<String, String> param);
	
	///예산저장
	void bs02001_mergeData(Map<String, Object> gridData);
	
	//예산삭제
	void bs02001_doDelete(Map<String, Object> gridData);

	//계정조회
	List<Map<String, Object>> bs02002_doSearch(Map<String, String> param);
	
	///계정저장
	void bs02002_mergeData(Map<String, Object> gridData);
	
	//계정삭제
	void bs02002_doDelete(Map<String, Object> gridData);

}