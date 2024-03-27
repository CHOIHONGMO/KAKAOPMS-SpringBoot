package com.st_ones.evermp.SSO1;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */

@Repository
public interface SSO1_Mapper {

	/** *****************
     * 견적관리
     * ******************/
	List<Map<String, Object>> sso1010_doSearchT(Map<String, String> param);

	List<Map<String, Object>> sso1010_doSearchB(Map<String, String> param);

	String checkDeadLine(Map<String, String> param);

	void doInsertQTHD(Map<String, String> qthd);

	void doUpdateQTHD(Map<String, String> qthd);

	void doDeleteQTDT(Map<String, String> param);

	void doInsertQTDT(Map<String, Object> qtdt);

	void doUpdateRfqProgressCd(Map<String, Object> qtdt);

	/** *****************
	 * 계약현황
	 * ******************/
	List<Map<String, Object>> sso1020_doSearch(Map<String, String> param);

}
