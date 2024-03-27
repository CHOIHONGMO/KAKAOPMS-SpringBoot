package com.st_ones.batch.comPlantIf;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface ComPlantIf_Mapper {

	List<Map<String, Object>> getComPlantList();
	
	// 고객사 사업장 등록
	void setComPlantCUPL(Map<String, Object> param);
	
	// 운영사 사업장 등록
	void setComPlantOGPL(Map<String, Object> param);
	
	// 기본 청구지 등록
	void setComPlantCUBL(Map<String, Object> param);
	
	// 인터페이스 결과 Update
	void doUpdateIfResultPlant(Map<String, Object> param);
}
