package com.st_ones.evermp.BS99;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 17 오후 5:27
 */

@Repository
public interface BS9901_Mapper {

	/** *****************
     * 템플릿관리
     * ******************/
	List<Map<String, Object>> bs99010_doSearch(Map<String, String> param);

	int bs99010_doCheck(Map<String, Object> gridData);
	
	void bs99010_doSave(Map<String, Object> gridData);
	
	Map<String, String> doSearch_templateFile(Map<String, String> param);
	
	/** *****************
	 * VOC > VOC 진행현황
	 * ******************/
	List<Map<String, Object>> bs99020_doSearch(Map<String, Object> param);

	void bs99020_doReceipt(Map<String, Object> gridData);

	void bs99021_doReceipt(Map<String, String> param);

	void bs99021_doInAction(Map<String, String> param);

	void bs99021_doActionComplete(Map<String, String> param);
	
}
