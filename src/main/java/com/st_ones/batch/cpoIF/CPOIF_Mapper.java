package com.st_ones.batch.cpoIF;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface CPOIF_Mapper {

	List<Map<String, Object>> CPOIF_SELECT_IF_PODT();
	
	// 고객의 청구지정보 가져오기
	Map<String, Object> getCustCUBL(Map<String, String> param);
	
	// 사용자의 배송지정보 가져오기
	Map<String, Object> getUserCSDM(Map<String, String> param);
	
	// 품목 및 단가정보 가져오기
	Map<String, Object> doGetItemInfo(Map<String, String> param);
	
	void CPOIF_INSERT_UPOHD(Map<String, Object> param);
	void CPOIF_INSERT_UPODT(Map<String, Object> param);
	
	// 인터페이스 결과 Update
	void CPOIF_UPDATE_IFPOHD(Map<String, Object> param);
	void CPOIF_UPDATE_IFPODT(Map<String, Object> param);
}
