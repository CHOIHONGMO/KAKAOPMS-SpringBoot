package com.st_ones.evermp.BYM1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BYM101_Mapper {

	/** *****************
	 * My Page > 고객의소리
	 * ******************/
	List<Map<String, Object>> bym1060_doSearch(Map<String, String> param);
	void bym1060_doSatisSave(Map<String, Object> param);

	/** *****************
	 * My Page > 고객의소리 > 고객의소리 등록/수정 팝업
	 * ******************/
	void bym1061_doSave(Map<String, String> param);
	void bym1061_doDelete(Map<String, String> param);


	Map<String, Object> getCustManageInfo(Map<String, String> param);
	Map<String, Object> getVnglManageInfo(Map<String, String> param);

    /** *****************
     * 사용자정보 팝업
     * ******************/
    List<Map<String, Object>> bym1062_doSearch(Map<String, String> param);

	/** *****************
	 * My Page > 관심품목관리
	 * ******************/
	List<Map<String, Object>> bym1020_doSearch(Map<String, String> param);
    List<Map<String, Object>> bym1020_doSearchD(Map<String, String> param);
	void bym1002_doSave(Map<String, Object> param);
	void bym1020_doDelete(Map<String, Object> param);
	void bym1020_doAddCart(Map<String, Object> param);
    void bym1020_doDeleteCart(Map<String, Object> param);
}