package com.st_ones.evermp.STO;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface PO06_Mapper {


/* 재고관리 > 재고발주 > VMI재고보충 신청 (PO0610) */

	//조회
	List<Map<String, Object>> po0610_doSearch(Map<String, String> formData);

/* 재고관리 > 재고발주 > VMI재고보충 신청 (PO0610) */

	//조회
	List<Map<String, Object>> PO0620_doSearch(Map<String, Object> fParam);

	//[SPO0601] 주문
	void doInsertUPOHD(Map<String, Object> gridData);

	void doInsertUPODT(Map<String, Object> gridData);

	void doInsertYPOHD(Map<String, Object> gridData);

	void doInsertYPODT(Map<String, Object> gridData);





}
