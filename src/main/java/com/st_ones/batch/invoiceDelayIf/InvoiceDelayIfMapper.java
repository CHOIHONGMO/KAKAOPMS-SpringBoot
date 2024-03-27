package com.st_ones.batch.invoiceDelayIf;
/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface InvoiceDelayIfMapper {
	// 납품지연 품목담당자 목록 가져오기(희망납기일 D+1 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	public List<Map<String, Object>> getInvoiceDelayList(Map<String, String> param);
	
	// 품목담당자별 납품지연 목록 가져오기(희망납기일 D+1 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	public List<Map<String, Object>> getInvoiceDelayItemList(Map<String, String> param);
}