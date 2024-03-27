package com.st_ones.evermp.IM01;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0101_Mapper {

    List<Map<String, Object>> im01001_doSearchHeader(Map<String, String> formData);

    List<Map<String, Object>> im01001_doSearch(Map<String, Object> param);


    int im01001_doDelete(Map<String, Object> gridData);

    int im01001_doSave(Map<String, Object> gridDatum);

    int im01001_doDeleteAll(Map<String, Object> gridData);

    List<Map<String, Object>> im01002_doSave_List(Map<String, String> param);

    int doCheckINFR(Map<String, Object> param);

    List<Map<String, Object>> im01070_doSearch(Map<String, String> formData);

    List<Map<String, Object>> im01071_doSearch(Map<String, String> formData);


    List<Map<String, Object>> im01060_doSearch(Map<String, String> formData);

    List<Map<String, Object>> im01060_doSearchCT(Map<String, String> formData);

    List<Map<String, Object>> im01060_doSearchPR(Map<String, String> formData);

    List<Map<String, Object>> im01060_doSearchIMG(Map<String, String> formData);

    void im01070_doSave(Map<String, Object> gridData);


    // 공급사코드체크
    Map<String, Object> doGetVendorInfo(Map<String, Object> gridData);

    // 고객사 체크
    Map<String, Object> doGetCustInfo(Map<String, Object> gridData);

    // 부서단가 사용여부 체크
    String doDeptPriceFlag(Map<String, Object> gridData);

    // 부서 체크
    Map<String, Object> doGetDeptInfo(Map<String, Object> gridData);

    // 품목 체크
    Map<String, Object> doGetItemInfo(Map<String, Object> gridData);

    // 품목 이미지 체크
    Map<String, Object> doGetItemImgInfo(Map<String, Object> gridData);

    // 지역 체크
    Map<String, Object> doGetRegionInfo(Map<String, Object> gridData);

    // 제조사,브랜드 체크
    Map<String, Object> doGetMakerTypeInfo(Map<String, Object> gridData);

    // 품목분류 체크
    Map<String, Object> doGetItemClsInfo(Map<String, Object> gridData);

    // 표준화 속성값 체크
    Map<String, Object> doGetItemCaatInfo(Map<String, Object> gridData);

    // bulk저장
    void im01060_doInsertBULK(Map<String, Object> gridData);

    void im01060_doUpdateBULK(Map<String, Object> gridData);

    void im01060_doUpdateBULKSTATUS(Map<String, Object> gridData);

    //bulk삭제
    void im01060_doDelete(Map<String, Object> gridData);

    //품목 벌크등록 ---
    void im01001_MTGL_Insert(Map<String, Object> gridData);

    int RETURN_deleteMTGL(Map<String, Object> gridData);
    int RETURN_deleteMTGC(Map<String, Object> gridData);
    int RETURN_deleteMTAT(Map<String, Object> gridData);

    //매입단가(계약로직) 벌크 등록 -------------------------
    void im01060_doUpdateYINFOBeforeDate(Map<String, Object> gridData);

    int im01060_doSave_YINFH_FROMDATE(Map<String, Object> gridData);

    String returnYinfoContNo(Map<String, Object> gridData);

    String returnYinfoContSeq(Map<String, Object> gridData);

    int RETURN_deleteYINFO(Map<String, Object> gridData);
    int RETURN_deleteYINFR(Map<String, Object> gridData);
    int RETURN_deleteYINFH(Map<String, Object> gridData);

    Map<String, String> changeYINFOInfo(Map<String, Object> gridData);

    //판매단가 벌크 등록
    int RETURN_deleteUINFO(Map<String, Object> gridData);
    int RETURN_deleteUINFH(Map<String, Object> gridData);

    //이미지 등록
    int im01060_doSaveMTIM(Map<String, Object> gridData);
    int im01060_doSaveATCH(Map<String, Object> gridData);
    int im01060_doUpdateMTGL(Map<String, Object> gridData);
    int RETURN_deleteMTIM(Map<String, Object> gridData);
    int RETURN_deleteATCH(Map<String, Object> gridData);

    String chkItem(Map<String, Object> gridData);

    int updateSignStatus(Map<String, String> gridData);

    List<Map> getAppTargetBulkList(Map<String, String> formData);

}
