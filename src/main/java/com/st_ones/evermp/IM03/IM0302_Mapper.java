package com.st_ones.evermp.IM03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0302_Mapper {

    List<Map<String,Object>> im01030_doSearch(Map<String, String> formData);

    void im01030_doSave(Map<String, Object> gridData);

    void im01030_doDelete(Map<String, Object> gridData);
    
    // 동의/유사어 관리
    List<Map<String,Object>> im03020_doSearch(Map<String, String> formData);
    
    // 동의/유사어 중복 체크
    String im03020_isDupFlag(Map<String, Object> gridData);
    
    // 동의/유사어 저장
    void im03020_doSave(Map<String, Object> gridData);
    
    // 동의/유사어 삭제
    void im03020_doDelete(Map<String, Object> gridData);

    List<Map<String,Object>> im01050_doSearch(Map<String, String> formData);

    List<Map<String,Object>> im01050_doSearchDp(Map<String, String> formData);

    void im01050_doSave(Map<String, Object> gridData);
    void im01050_doSaveMTGC(Map<String, Object> gridData);

    void im01050_doDelete(Map<String, Object> gridData);
//    void im01050_doDeleteMTGC(Map<String, Object> gridData);

    void im01050_doSaveDp(Map<String, Object> gridData);

    void im01050_doDeleteDp(Map<String, Object> gridData);

}
