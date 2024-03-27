package com.st_ones.evermp.IM03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0301_Mapper {

    List<Map<String,Object>> im03007_doSearch(Map<String, String> formData);

    int im03007_doSave(Map<String, Object> gridDatum);

    List<Map<String,Object>> im03008_doSearch(Map<String, String> formData);

    Map<String, Object> setSgData(Map<String, String> param);

    Map<String, Object> setDPSgData(Map<String, String> param);

    String im03008_getNewItemCode(Map<String, Object> gridDatum);

    int im03008_doSaveMTGL(Map<String, Object> gridDatum);

    List<Map<String,Object>> im03008_doSelectMTIM(Map<String, Object> gridDatum);

    int im03008_doDeleteMTIM(Map<String, Object> gridDatum);

    int im03008_doSaveMTIM(Map<String, Object> gridDatum);

    int im03008_doSaveMTGC(Map<String, Object> gridDatum);


    int im03008_delMTGC(Map<String, String> gridDatum);

    int im03008_copyCustMTGC(Map<String, String> gridDatum);

    int im03008_delCustMTGB(Map<String, String> gridDatum);
    int im03008_copyCustMTGB(Map<String, String> gridDatum);



    int im03008_doSaveMTGS(Map<String, Object> gridDatum);

    List<Map<String,Object>> im03008P_doSearch(Map<String, String> formData);

    int im03008P_doSave(Map<String, Object> gridDatum);

    int im03008P_doDelete(Map<String, Object> gridDatum);

    boolean im03008P_isDuplicateData(Map<String, Object> gridDatum);

    List<Map<String,Object>> im01020_doSearch(Map<String, String> formData);

    int im01020_doSave_MTGB(Map<String, Object> gridDatum);

    int im01020_doSave_MTGH(Map<String, Object> gridDatum);

    List<Map<String,Object>> im01021_doSearch(Map<String, String> formData);

    int im01020_doDelete_MTGB(Map<String, Object> gridDatum);

    Map<String, String> im03009_doSearchInfo(Map<String, String> param);
    Map<String, String> im03009_doSearch_app_Info(Map<String, String> param);

    Map<String, String> im03014_doSearchInfo_doCart(Map<String, String> param);

    Map<String, String> im03009_doSearchInfo_RP(Map<String, String> param);

    List<Map<String,Object>> im03009_doSearch_CT(Map<String, String> formData);

    List<Map<String,Object>> im03009_doSearch_CT_SIGN(Map<String, String> formData);




    List<Map<String,Object>> im03009_doSearchRP_CT(Map<String, String> formData);
    List<Map<String,Object>> im03009_doSearch_PR(Map<String, String> formData);
    List<Map<String,Object>> im03009_doSearch_AT(Map<String, String> formData);

    List<Map<String,Object>> im03009_doSearch_NmgCust(Map<String, String> formData);


    void im03009_UpdateCustItemCd (Map<String, String> formData) throws Exception;

    void im03009_MTGL_Insert(Map<String, String> formData) throws Exception;
    /*22.08.17*/
    void im03009_STOYMTRP_Update (Map<String, String> formData) throws Exception;
    /*22.08.18*/
    void doUpdateMTRP (Map<String, String> formData) throws Exception;

    void im03009_MTGL_Update(Map<String, String> formData) throws Exception;
    void im03009_MTGL_Update_CUST_ITEM_CD(Map<String, String> formData) throws Exception;
    void im03009_NWRQ_Update_CUST_ITEM_CD(Map<String, String> formData) throws Exception;
    void im03009_doDeleteMTAT(Map<String, String> formData) throws Exception;

    int im03009_doDeleteMTIM(Map<String, String> formData);
    int im03009_doSaveMTIM(Map<String, String> formData);

    int im03009_doSaveMTAT(Map<String, Object> gridDatum) throws Exception;

    int im03009_doSave_YINFO(Map<String, Object> gridDatum) throws Exception;
    int im03009_doDelete_YINFO(Map<String, Object> gridDatum) throws Exception;
    int im03009_doSave_YINFH(Map<String, Object> gridDatum) throws Exception;
    void im03009_doSave_MTGB(Map<String, Object> gridDatum) throws Exception;

    List<Map<String, String>> changeYINFOInfo(Map<String, Object> gridData);
    void doUpdateYINFOBeforeDate(Map<String, String> data);

    void im03009_MTRP_BASIC_Update(Map<String, String> formData) throws Exception;
    int im03009_MTRP_CONT_Update(Map<String, Object> gridDatum) throws Exception;

    void im03009_doDelete_YINFR(Map<String, Object> gridDatum) throws Exception;
    int im03009_doSave_YINFR(Map<String, Object> gridDatum) throws Exception;
    String returnYinfoContSeq(Map<String, Object> gridData);

    int im03009_doSave_UINFO(Map<String, Object> gridDatum) throws Exception;
    int im03009_doSave_UINFH(Map<String, Object> gridDatum) throws Exception;


    int im03008_doEstimate(Map<String, Object> gridDatum);

    int im03009_doDeletegridpr(Map<String, Object> gridDatum);
    int im03009_doUpdateDel_YINFR(Map<String, Object> gridDatum);

    void endApproval_YINFO(Map<String, String> param);
    void doUpdate_app_YINFO(Map<String, String> param);

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수
     * ******************/
    List<Map<String,Object>> im03010_doSearch(Map<String, Object> formData);
    void im03010_doSave(Map<String, Object> gridData);
    void im03010_doAssigmnent(Map<String, Object> gridData);
    void im03010_doItemMapping(Map<String, Object> gridData);
    void im03010_doReRequest(Map<String, Object> gridData);
    void im03010_doNotStandardization(Map<String, Object> gridData);
    void im03010_MTGL_Insert(Map<String, Object> gridData);
    void im03010_doDelete(Map<String, Object> gridData);
    Map<String, Object> getReqItemInfo(Map<String, Object> param);

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수 > 표준화 팝업
     * ******************/
    void im03015_NWRQ_Update(Map<String, String> gridData);
    void im03015_MTGL_Insert(Map<String, String> gridData);

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수 > 신규요청등록 팝업
     * ******************/
    void im03016_doRequest(Map<String, Object> gridData);

    Map<String, String> im03014_detailImgInfo(Map<String, String> formData);
    Map<String, String> im03014_detailImgInfo2(Map<String, String> formData);

    List<Map<String,Object>> getTargetYInfhList(Map<String, String> formData);
    int updateSignYInfh(Map<String, String> gridDatum);
    List<Map<String,Object>> chkYInfo(Map<String, Object> formData);
    int deleteYInfo(Map<String, Object> gridDatum);
    int updateValidTodateYInfo(Map<String, Object> gridDatum);
    int copyYInfhToYInfo(Map<String, Object> gridDatum);

    List<Map<String,Object>> getTargetUInfhList(Map<String, String> formData);

    // stocinfo의 erp_if_send_flag=1 처리하기
    void updateDgnsIfFlag(Map<String, Object> gridDatum);

    int updateSignUInfh(Map<String, String> gridDatum);
    int deleteUInfo(Map<String, String> gridDatum);
    int copyUInfhToUInfo(Map<String, String> gridDatum);

    // 상품관리 > 계약단가관리 > 상품단가 일괄등록 (IM01_060) : 엑셀 업로드
    Map<String, Object> doSetExcelImportItemInfo(Map<String ,Object> grid);

    Map<String, String> getItemViewData(Map<String, String> param);

	void chageTemporaryItem(Map<String, String> map);

	void chageNewTemporaryItem(Map<String, String> map);

	int checkChageDtSign(Map<String, String> formData);

	void updateAppCheck(Map<String, String> formData);

	void updateAppSign(Map<String, String> map);



    int deleteYInfoValid(Map<String, Object> gridDatum);


    void copyMtglHist(Map gridDatum);




    List<Map<String,Object>> getItemHistList(Map<String, String> formData);



    int upsMtglStatus(Map<String, Object> param);

}