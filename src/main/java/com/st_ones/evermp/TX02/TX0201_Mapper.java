package com.st_ones.evermp.TX02;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface TX0201_Mapper {


    List<Map<String, Object>> tx02010_doSearch(Map<String, String> param);

    /**
     * 운영사 > 정산관리 > 매입정산 > 매입세금계산서 현황
     */
    List<Map<String, Object>> tx02020_doSearch(Map<String, String> param);
    List<Map<String, Object>> tx02020_doSearchTTID(Map<String, String> param);
    void tx02020_doUpdateTTID(Map<String, Object> param);
    void tx02020_doUpdateTTID_TTIH(Map<String, Object> param);
    void tx02020_doSaveTTIH(Map<String, Object> param);

    void tx02020_doTaxCancelTTIH_AR(Map<String, Object> param);
    void tx02020_doTaxCancelTTID_AR(Map<String, Object> param);
    void tx02020_doTaxCancelAPAR(Map<String, Object> param);

    void tx02020_doSavePaymentTTIH(Map<String, Object> param);

    List<Map<String, Object>> getInvoiceDelayItemList(Map<String, Object> param);

    // 매출회계계산서 목록
    List<Map<String, Object>> tx02030_doSearch(Map<String, String> param);
}