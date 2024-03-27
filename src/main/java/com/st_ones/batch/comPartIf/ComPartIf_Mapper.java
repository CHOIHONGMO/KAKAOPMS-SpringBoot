package com.st_ones.batch.comPartIf;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface ComPartIf_Mapper {

	List<Map<String, Object>> getComPartList();
	
	void setComPartOGDP(Map<String, Object> param);
	
	// 인터페이스 결과 Update
	void doUpdateIfResultPart(Map<String, Object> param);
}
