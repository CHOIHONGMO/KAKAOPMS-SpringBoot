package com.st_ones.evermp.BS02.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS02.BS0201_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Map.Entry;


@Service(value = "bs0201_Service")
public class BS0201_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private BS0201_Mapper bs0201Mapper;

    @Autowired
    LargeTextService largeTextService;

    /** ******************************************************************************************
     * 예산관리 조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs02001_doSearch(Map<String, String> param) throws Exception {

    	List<Map<String, Object>> gridList = bs0201Mapper.bs02001_doSearch(param);
    	return gridList;
    }

    public String isBudgetCloseFlag(Map<String, String> param) throws Exception {
        return bs0201Mapper.isBudgetCloseFlag(param);
    }
    
    //조직 - 트리검색
    public List<Map<String, Object>> doSelect_budgetDeptTree(Map<String, String> param) throws Exception {
        
        return bs0201Mapper.doSelect_budgetDeptTree(param);
    }
    
    //예산관리저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs02001_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
        	// 이월예산
        	if( "null".equals(String.valueOf(gridData.get("TRANSFERED_AMT"))) ) {
        		gridData.put("TRANSFERED_AMT", null);
            } else {
            	gridData.put("TRANSFERED_AMT", Double.parseDouble(String.valueOf(gridData.get("TRANSFERED_AMT"))));
            }
        	// 당해예산
        	if( "null".equals(String.valueOf(gridData.get("BUDGET_AMT"))) ) {
        		gridData.put("BUDGET_AMT", null);
            } else {
            	gridData.put("BUDGET_AMT", Double.parseDouble(String.valueOf(gridData.get("BUDGET_AMT"))));
            }
        	// 추가예산
        	if( "null".equals(String.valueOf(gridData.get("ADDITIONAL_AMT"))) ) {
        		gridData.put("ADDITIONAL_AMT", null);
            } else {
            	gridData.put("ADDITIONAL_AMT", Double.parseDouble(String.valueOf(gridData.get("ADDITIONAL_AMT"))));
            }
            bs0201Mapper.bs02001_mergeData(gridData);
        }
        return msg.getMessage("0031");
    }

    //예산관리삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs02001_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bs0201Mapper.bs02001_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ******************************************************************************************
     * 계정관리 조회
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs02002_doSearch(Map<String, String> param) throws Exception {
        for(Entry<String, String> elem : param.entrySet()){
            System.out.println("키 : " + elem.getKey() + "값 : " + elem.getValue());
        }

        return bs0201Mapper.bs02002_doSearch(param);
    }

    //계정관리저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs02002_doSave(List<Map<String, Object>> gridList) throws Exception {


        for(Map<String, Object> gridData : gridList) {
            bs0201Mapper.bs02002_mergeData(gridData);
        }
        return msg.getMessage("0031");
    }

    //계정관리삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs02002_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bs0201Mapper.bs02002_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }
}
