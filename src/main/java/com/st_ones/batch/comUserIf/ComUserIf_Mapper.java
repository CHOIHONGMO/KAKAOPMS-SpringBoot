package com.st_ones.batch.comUserIf;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface ComUserIf_Mapper {

	List<Map<String, Object>> getComUserList();
	
	// 고객사 사용자 삭제
	void delComUserCVUR(Map<String, Object> param);
	
	// 고객사 사용자 삭제
	void delComUserUSER(Map<String, Object> param);
	
	// 고객사 사용자 등록
	void setComUserCVUR(Map<String, Object> param);
	
	// 운영사 사용자 등록
	void setComUserUSER(Map<String, Object> param);
	
	// 사용자 기본권한 등록
	void setComUserUSAP(Map<String, Object> param);
	
	// 운영사 사용자 기본직무 등록
	void setComUserBACP(Map<String, Object> param);
	
	// 인터페이스 결과 Update
	void doUpdateIfResultUser(Map<String, Object> param);
}
