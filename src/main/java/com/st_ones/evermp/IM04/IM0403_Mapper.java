package com.st_ones.evermp.IM04;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 07 kkj
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0403_Mapper {

    List<Map<String, Object>> selectItemClass(Map<String, String> param);

    List<Map<String, Object>> selectItemClassSearchNm(Map<String, String> param);

    List<Map<String, Object>> selectChildClass(Map<String, String> param);


    int existsItemClass(Map<String, Object> param);

    String newItemClassKey(Map<String, Object> param);

    int updateItemClass(Map<String, Object> gridData);

    String newSortSeq(Map<String, Object> param);

    int insertItemClass(Map<String, Object> gridData);


    int notDeleteItemClass(Map<String, Object> param);


    int deleteItemClass_r(Map<String, Object> gridData);

    List<Map<String, Object>> doSearchPTItemClassPopup_TREE(Map<String, String> param);

}
