package com.st_ones.eversrm.system.migration;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 23 오전 8:49
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface MIG_Mapper {

	//입력한 querty 실행하기
	List<Map<String,Object>> mig010_doSearch(Map<String, String> formData);

	void mig010_doSave(Map<String, Object> gridData);

}
