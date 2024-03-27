package com.st_ones.evermp.BS03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BS0302_Mapper {

	//승인관리 리스트조회
	List<Map<String, Object>> bs03004_doSearch(Map<String, String> param);

	//사용자 리스트조회
	List<Map<String, Object>> bs03005_doSearch(Map<String, String> param);

	//사용자수정_그리드
	void bs03005_doUpdate(Map<String, Object> gridData);

	//사용자_해당 업체 관리자여부 초기화
	void bs03005_doDeleteMngYn(Map<String, Object> gridData);

	//사용자삭제_그리드
	void bs03005_doDelete(Map<String, Object> gridData);

	//사용자상세 조회
	Map<String, String> bs03005_doSearchInfo(Map<String, String> param);

	///사용자 merge저장
	void bs03006_doSave(Map<String, String> formData);

	//사용자(고객사)_배송지 저장
	void bs03006_doSave_custDM(Map<String, String>FormData);

	//처음등록시권한저장
	void bs03006_doInsertUser_USAP(Map<String, String> formData);

	//사용자 아이디 중복체크
	String bs01002_doCheckUserId(Map<String, String> param);


	String bs01002_doCheckIrsNo(Map<String, String> param);
}