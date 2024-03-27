package com.st_ones.evermp.PY01;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface PY01_Mapper {

    /**
     * 운영사 > 정산관리 > 매출정산 > 매출마감대상
     */
    List<Map<String, Object>> py01010_doSearch(Map<String, String> param);
    void py01010_doSaveConfirmAPAR(Map<String, Object> param);
    void py01010_doSaveConfirmGRDT(Map<String, Object> param);
    List<Map<String, Object>> py01010_doSaveConfirmSELECT_MAIL(Map<String, String> param);

    /**
     * 운영사 > 정산관리 > 매출정산 > 매출마감 현황
     */
    List<Map<String, Object>> py01020_doSearch(Map<String, String> param);
    void py01020_doDeleteAPAR(Map<String, Object> param);
    void py01020_doDeleteGRDT(Map<String, Object> param);
    void py01020_doConfirmAPAR(Map<String, Object> param);
    void py01020_UPDATE_APAR(Map<String, Object> param);


    void resultInfoSave(Map<String, Object> param);



    void py01020_doConfirmCancleAPAR(Map<String, Object> param);
    void py01020_doTaxCreateINSERT_TTIT(Map<String, Object> param);
    String py01020_doTaxCreateSELECT_TAX_CHK(Map<String, String> param);
    List<Map<String, Object>> py01020_doTaxCreateSELECT_TAX(Map<String, String> param);

    void py01020_doTaxCreateOUT_INSERT_TTIH(Map<String, Object> param);
    List<Map<String, Object>> py01020_doTaxCreateSELECT_TTID(Map<String, Object> param);
    void py01020_doTaxCreateINSERT_TTID(Map<String, Object> param);
    void py01020_doTaxCreateUPDATE_APAR(Map<String, Object> param);
    void py01020_doTaxCreateDELETE_TTIT(Map<String, String> param);
    String py01020_doTaxCreateSELECT_CUCL(Map<String, String> param);
    void py01020_doTaxCreateIN_INSERT_TTIH(Map<String, Object> param);


    int chkCloseAR(Map<String, Object> param);



    int chkTaxCreAR(Map<String, Object> param);


}