package com.st_ones.evermp.IM04;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 22 chm
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0407_Mapper {

    List<Map<String, Object>> doSearchCAAT(Map<String, String> param);
    
    int doInsertCAAT(Map<String, Object> gridData);
    
    int doDeleteCAAT(Map<String, Object> gridData);
    
    List<Map<String, Object>> doSearchCommonCode(Map<String, String> param);
    
}
