package com.st_ones.evermp.SIT1.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */


import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.SIT1.SIT101_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "sit1_Service")
public class SIT101_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private SIT101_Mapper sit101Mapper;
    
    @Autowired
	private QueryGenService queryGenService;
    
    @Autowired
    LargeTextService largeTextService;

    /** ****************************************************************************************************************
     * 신규품목요청
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> sit1021_doSearch(Map<String, String> param) {
    	return sit101Mapper.sit1021_doSearch(param);
    }
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sit1021_doSave(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception
    {
		boolean isNew = false;
		for (Map<String, Object> gridData : gridDatas) {
			if( "I".equals(gridData.get("INSERT_FLAG")) ) {
				isNew = true;
				break;
			}
		}
		
		String docNo = null;
		if( isNew ) {
			docNo = docNumService.getDocNumber("RP");
		}
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PROGRESS_CD", param.get("PROGRESS_CD"));
			if( "I".equals(gridData.get("INSERT_FLAG")) ) {
				gridData.put("RP_NO", docNo);
				sit101Mapper.sit1021_doInsert(gridData);
			} else {
				sit101Mapper.sit1021_doUpdate(gridData);
			}
		}
		return msg.getMessage("0015");
    }
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sit1021_doDelete(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			sit101Mapper.sit1021_doDelete(gridData);
		}
		return msg.getMessage("0017");
    }

    /** ****************************************************************************************************************
     * 신규품목처리현황
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> sit1020_doSearch(Map<String, String> param) {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "A.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "A.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        
    	return sit101Mapper.sit1020_doSearch(param);
    }
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sit1020_doCancel(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			sit101Mapper.sit1020_doCancel(gridData);
		}
		return msg.getMessage("0061");
    }

}