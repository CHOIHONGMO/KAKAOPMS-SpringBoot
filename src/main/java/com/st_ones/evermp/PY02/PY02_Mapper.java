package com.st_ones.evermp.PY02;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface PY02_Mapper {

	/**
     * 운영사 > 정산관리 > 매입정산 > 매입정산현황
     */
	List<Map<String, Object>> py02010_doSearch(Map<String, String> param);

	/**
	 * 운영사 > 정산관리 > 매입정산 > 매입현황
	 */
	List<Map<String, Object>> py02020_doSearch(Map<String, String> param);

	/**
	 * 운영사 > 정산관리 > 매입정산 > 매입마감대상
	 */
	List<Map<String, Object>> py02030_doSearch(Map<String, String> param);
	void py02030_doSaveConfirmAPAR(Map<String, Object> param);
	void py02030_doSaveConfirmGRDT(Map<String, Object> param);
	List<Map<String, Object>> py02030_doSaveConfirmSELECT_MAIL(Map<String, String> param);

	/**
	 * 운영사 > 정산관리 > 매입정산 > 매입마감 현황
	 */
	List<Map<String, Object>> py02040_doSearch(Map<String, String> param);
	void py02040_doDeleteAPAR(Map<String, Object> param);
	void py02040_doDeleteGRDT(Map<String, Object> param);


	void py2040_UPDATE_APAR(Map<String, Object> param);

	void py02040_doTaxCreateINSERT_TTIT(Map<String, Object> param);
	String py02040_doTaxCreateSELECT_TAX_CHK(Map<String, String> param);
	List<Map<String, Object>> py02040_doTaxCreateSELECT_TAX(Map<String, String> param);

	List<Map<String, Object>> py02040_doTaxCreateSELECT_TTID(Map<String, Object> param);
	void py02040_doTaxCreateINSERT_TTID(Map<String, Object> param);
	void py02040_doTaxCreateUPDATE_APAR(Map<String, Object> param);
	void py02040_doTaxCreateDELETE_TTIT(Map<String, String> param);
	String py01020_doTaxCreateSELECT_CUCL(Map<String, String> param);
	void py02040_doTaxCreateIN_INSERT_TTIH(Map<String, Object> param);
	List<Map<String, String>> getInvoiceDelayItemList(Map<String, Object> param);



    int chkCloseAP(Map<String, Object> param);

    int chkTaxCreAP(Map<String, Object> param);

}