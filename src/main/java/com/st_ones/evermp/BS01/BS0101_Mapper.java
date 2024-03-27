package com.st_ones.evermp.BS01;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BS0101_Mapper {

	/** ******************************************************************************************
	 * 협력회사
	 * @param req
	 * @return
	 * @throws Exception
	 */

	//고객사조회
	List<Map<String, Object>> bs01001_doSearch(Map<String, String> param);

	List<Map<String, Object>> bs01001p_doSearch(Map<String, String> param);

	//고객사 거래정지 또는 거래정지 해제
	void bs01001_doSuspensionOrTrading(Map<String, Object> grid);

	//고객사상세 조회
	Map<String, String> bs01002_doSearchInfo(Map<String, String> param);

	// 고객사 담당자 조회
	Map<String, String> bs01002_doSearchUser(Map<String, String> param);

	//이전 승인상태 조회
	String bs01002_getSignStatus(Map<String,Object> param);

	// 사업자번호 중복 체크
	String bs01002_checkIrsNum(Map<String, String> param);

	// 고객사 담당자ID 중복 체크
	String bs01002_checkDupCustUser(Map<String, String> param);

	// 고객사 중복 체크
	int bs01002_doCheckNum(Map<String, Object> param);


	// 신규 고객사코드 채번
	String bs01002_getCustCd(Map<String, Object> param);

	// 고객사 저장
	void bs01002_doMergeCust(Map<String, Object> formData);

	void bs01002_doInsertCVSH(Map<String, Object> formData);

	// 고객사 지역정보 저장
	void bs01002_doMergCURG(Map<String, Object> formData);

	// 고객사 담당자 저장
	void bs01002_doMergeCVUR(Map<String, Object> formData);

	//고객사 청구지관리 저장
	void bs01002_doMergeCUBL(Map<String,Object> formData);

	//고객사 TIER 이력저장
	void bs01002_doInsert(Map<String, Object> formData);

	//고객사 승인상태 업데이트
	void bs01002_doUpdateSignStatus(Map<String,String> param);


	//ERP_IF_FLAG : DGNS IF 여부[M044] 가져오기
	void bs01002_insertSTOCCUPL(Map<String,String> param);

	//고객사 TIER 조회
	List<Map<String, Object>> bs01005_doSearch(Map<String, String> param);

	//고객사 부서조회
	List<Map<String, Object>> bs01004_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01004_doSearch_parent(Map<String, String> param);

	//고객사 부서저장
	void bs01004_mergeData(Map<String, Object> gridData);
	//고객사 부서 중복체크
	int existsCust_OPDP(Map<String, Object> gridData);

	//공급사 계산서사용자저장
	void bs01002_doMergeTX(Map<String, Object> gridData);

	//공급사 계산서사용자 삭제
	void bs01002_dodeleteTX(Map<String, Object> grid1) throws Exception;

	//계정조회
	List<Map<String, Object>> bs01003_doSearch(Map<String, String> param);
	//마감일자 저장/수정
	void bs01003_mergeData(Map<String, Object> gridData);
	void bs01003_doDelete(Map<String, Object> gridData);




	String bs01003_doCheckIrsNo(Map<String, String> param);
}