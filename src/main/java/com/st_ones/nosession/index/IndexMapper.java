package com.st_ones.nosession.index;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IndexMapper {

    List<Map<String,String>> getNoticeList(List<Map<String,String>> noticeList);

    List<Map<String,String>> getNoticeListPopup(List<Map<String,String>> noticeListPopup);

    List<Map<String,String>> getNoticeListMain(List<Map<String,String>> param);


    Map<String,Object> getNoticePopupInfo(Map<String,String> param);

    List<Map<String,String>> getFaqList(List<Map<String,String>> faqList);



    List<Map<String, Object>> mainNoticeList(Map<String, String> param);

    Map<String, String> mainNoticeDetail(Map<String, String> param);


    Map<String, String> getTmsInfo(Map<String, String> param);

    int mainNoticeTotalCount(Map<String, String> param);


    String tmsLoginS(Map<String, String> param);

    String tmsLoginC(Map<String, String> param);

    List<Map<String, Object>> poList01(Map<String, String> param);

    List<Map<String, Object>> poList02(Map<String, String> param);

    void BS03_012_doInsert(Map<String, String> formData);

    void BS03_012_doUpdate(Map<String, String> formData);
}
