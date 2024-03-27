package com.st_ones.evermp.BNM1;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BNM101_Mapper {

	void bnm1010_doInsert(Map<String, Object> param);

	void bnm1010_doUpdate(Map<String, Object> param);

	List<Map<String, Object>> bnm1010_doSaveSELECT_MAIL(Map<String, String> param);

	List<Map<String, Object>> getInsujaInfo(Map<String, String> param);

	Map<String, Object> bnm1011_doSearchForm(Map<String, String> param);

	List<Map<String, Object>> bnm1030_doSearch(Map<String, Object> param);

	void bnm1032_doAddCart(Map<String, Object> param);

	void bnm1030_doUpdateProgressCd(Map<String, Object> param);

	void bnm1031_doUpdateAgreeReject(Map<String, Object> param);

	void bnm1031_doUpdateProgressCd(Map<String, Object> param);

	List<Map<String, Object>> getCnInfo(Map<String, Object> param);

	void updateStatusRQDT(Map<String, Object> param);

	void updateStatusQTDT(Map<String, Object> param);

	void updateStatusNWRQ(Map<String, Object> param);

	String getRqhdProgressCd(Map<String, String> param);

	void doUpdateProgressCdRQHD(Map<String, String> formData);

	List<Map<String, String>> getCnVendorList(Map<String, String> param);

	List<Map<String, Object>> getYinfoByVendors(Map<String, String> param);

	Map<String, Object> getYinfoByVendor(Map<String, Object> param);

	List<Map<String, Object>> getUinfoList(Map<String, String> param);

	List<Map<String, Object>> getAutoPoList(Map<String, String> param);
	
	// by sslee add
	List<Map<String, Object>> bnm1040_doSearch(Map<String, Object> param);

}