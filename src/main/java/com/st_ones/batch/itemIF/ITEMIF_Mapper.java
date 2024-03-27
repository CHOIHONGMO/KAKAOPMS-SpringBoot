package com.st_ones.batch.itemIF;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface ITEMIF_Mapper {
	
	// 신규품목 등록요청
	List<Map<String, Object>> getNewItemList();
	
	void setNewItemNWRQ(Map<String, Object> param);
	
	// 인터페이스 결과 Update
	void doUpdateIfResultPRHD_IF(Map<String, Object> param);
	void doUpdateIfResultPRDT_IF(Map<String, Object> param);
	
	// 고객사 견적요청 합의
	List<Map<String, Object>> getItemConfirmList();
	
	// 견적합의 결과 변경
	void doUpdateItemConfirmNWRQ(Map<String, Object> param);
	void doUpdateItemConfirmRQDT(Map<String, Object> param);
	void doUpdateItemConfirmRQHD(Map<String, Object> param);
	
	void doUpdateItemConfirmPRHD_IF(Map<String, Object> param);
	void doUpdateItemConfirmPRDT_IF(Map<String, Object> param);
	
}