package com.st_ones.batch.delyAlarmIf;
/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface DelyAlarmIfMapper {
	// 납품예정 공급사 목록 가져오기(희망납기일 D-1 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	public List<Map<String, Object>> getInvoiceHeaderList(Map<String, String> param);
	
	// 납품예정 공급사별 납품예정 주문 목록 가져오기(희망납기일 D-1 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	public List<Map<String, Object>> getInvoiceItemList(Map<String, String> param);
	
	// 납품예정 공급사 목록 가져오기(희망납기일 D+0 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	public List<Map<String, Object>> getCurInvoiceHeaderList(Map<String, String> param);
	
	// 납품예정 공급사별 납품예정 주문 목록 가져오기(희망납기일 D+0 일까지 납품정보가 생성되지 않은 모든 CPO 정보)
	public List<Map<String, Object>> getCurInvoiceItemList(Map<String, String> param);

}