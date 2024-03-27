package com.st_ones.batch.grIF;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface GRIF_Mapper {

	List<Map<String, Object>> GRIF_SELECT_IF_GRDT(Map<String, String> param);
	
	// 입고요청 등록
	void GRIF_INSERT_GRDT(Map<String, Object> param);
	void GRIF_UPDATE_UIVDT(Map<String, Object> param);
	void GRIF_UPDATE_YIVDT(Map<String, Object> param);
	
	// 납품서 삭제 (입고완료시 미입고 납품서 삭제)
	void GRIF_DELETE_UIVDT(Map<String, Object> param);
	void GRIF_DELETE_YIVDT(Map<String, Object> param);
	
	// 입고취소 등록
	void GRIF_CANCEL_GRDT(Map<String, Object> param);
	void GRIF_CANCEL_UIVDT(Map<String, Object> param);
	void GRIF_CANCEL_YIVDT(Map<String, Object> param);
	
	int GRIF_SELECT_TOT_GR_QTY(Map<String, Object> param);
	
	void GRIF_UPDATE_YPODT(Map<String, Object> param);
	void GRIF_UPDATE_UPODT(Map<String, Object> param);
	void GRIF_UPDATE_IFGRDT(Map<String, Object> param);

}