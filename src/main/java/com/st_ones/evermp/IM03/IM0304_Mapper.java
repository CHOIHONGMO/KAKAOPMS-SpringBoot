package com.st_ones.evermp.IM03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0304_Mapper {

    List<Map<String,Object>> im03011_doSearch(Map<String, String> formData);
    
    /**
     * 품목관리 > 품목표준화 > 신규품목 재요청 승인(IM03_040)
     * @param formData
     * @return
     */
    List<Map<String,Object>> im03040_doSearch(Map<String, String> formData);
    void im03040_doConfirm(Map<String, Object> gridData);
 	void im03040_doReject(Map<String, Object> gridData);
 	
}
