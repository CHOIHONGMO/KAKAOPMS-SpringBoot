package com.st_ones.evermp.IM04;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0401_Mapper {

    List<Map<String, Object>> doSearchItemAttributeLink(Map<String, String> param);

    int doInsertItemAttrLink(Map<String, Object> gridData);

    int doUpdateItemAttrLink(Map<String, Object> gridData);

    int checkDataItemLink(Map<String, Object> param);

    List<Map<String, Object>> doSearchItemAttributeManagement(Map<String, String> param);

    int checkItemManagementData(Map<String, Object> param);

    int doInsertItemManagementData(Map<String, Object> gridData);

    int doUpdateItemManagementData(Map<String, Object> gridData);

    int notDeleteAttribute(Map<String, Object> param);

    int doDeleteAttributeManagement(Map<String, Object> gridData);

    int notDeleteItemLink(Map<String, Object> param);

    int doDeleteItemLink(Map<String, Object> gridData);


    List<Map<String, Object>> doSearchUnitPriceItemSearch(Map<String, String> param);

    int terminateInfo(Map<String, Object> gridData);

    int doUpdateAttFiles(Map<String, Object> gridData);

    List<Map<String, Object>> doSearchUnitPriceHistorySearch(Map<String, String> param);


    //  ///////item class popup BBM_011   //////

    List<Map<String, Object>> doSearchItemClassPopup(Map<String, String> param);

    List<Map<String, Object>> doSearchItemClassPopup_TREE(Map<String, String> param);

    //  ///////item management BBM_010   //////

    List<Map<String, Object>> getAttrItemManagement(Map<String, String> param);


    List<Map<String, Object>> listClassItemStatusByType(Map<String, String> param);


    List<Map<String, Object>> getAttrLinkItemManagement(Map<String, String> param);

    int doSaveItemManagement(Map<String, String> param);

    int doDeleteItemManagement(Map<String, String> param);

    Map<String, Object> doSearchItemManagement(Map<String, String> param);

    int doUpdateAttrItemManagement(Map<String, Object> gridData);

    int doInsertAttrItemManagement(Map<String, Object> gridData);

    int doDeleteAttrItemManagement(Map<String, String> gridData);

    int doDeleteAttrDetailItemManagement(Map<String, Object> gridData);

    int existsAttrItemManagement(Map<String, Object> param);

    String checkItemProgressCode(Map<String, String> param);

    int doRequestItemManagement(Map<String, String> gridData);

    int doUpdateMtimItemManagement(Map<String, String> gridData);

    int doInsertMtimItemManagement(Map<String, String> gridData);

    int doDeleteMtimItemManagement(Map<String, String> gridData);

    int existsMtimItemManagement(Map<String, String> param);

    //  ///////item approval status BBM_020   //////

    List<Map<String, Object>> doSearchItemApprovalStatus(Map<String, String> param);

    int doUpdateItemApprovalStatus(Map<String, Object> gridData);

    /*********************** BBM_100 ***********************/
    List<Map<String, Object>> BBM_100_doSearch(Map<String, String> param);

    @SuppressWarnings("rawtypes")
    List<Map> listClassItemStatus(Map<String, String> param);

    List<Map<String, Object>> doSearchItemStatus(Map<String, String> param);

    /* ITEM CLASS MANAGEMENT */
    List<Map<String, Object>> selectItemClass(Map<String, String> param);

    List<Map<String, Object>> selectItemClassSearchNm(Map<String, String> param);

    List<Map<String, Object>> selectItemClass1(Map<String, String> param);

    List<Map<String, Object>> selectItemClass2(Map<String, String> param);

    List<Map<String, Object>> selectItemClass3(Map<String, String> param);

    List<Map<String, Object>> selectChildClass(Map<String, String> param);

    List<Map<String, Object>> selectParentClass(Map<String, String> param);

    String newSortSeq(Map<String, Object> param);

    int insertItemClass(Map<String, Object> gridData);

    int updateItemClass(Map<String, Object> gridData);

    int notDeleteItemClass(Map<String, Object> param);

    int deleteItemClass(Map<String, Object> gridData);

    int deleteItemClass_r(Map<String, Object> gridData);

    int existsItemClass(Map<String, Object> param);

    int checkItemCd(Map<String, Object> param);

    int checkVendorCd(Map<String, String> param);

    String newItemClassKey(Map<String, Object> param);

    int insCNHD(Map<String, String> gridData);

    int insCNDT(Map<String, Object> gridData);

    List<Map<String, Object>> searchInfoList1(Map<String, String> param);

    int getItemCnt(Map<String, String> formData);

    int doApproval(Map<String, String> formData);
}
