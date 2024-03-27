package com.st_ones.evermp.IM04.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 22 chm
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM04.IM0407_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "im0407_Service")
public class IM0407_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private IM0407_Mapper im0407Mapper;

    /**
     * 세분류에 맵핑된 속성 조회
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> doSearchCAAT(Map<String, String> param) throws Exception {
        List<Map<String, Object>> rtn = im0407Mapper.doSearchCAAT(param);
        return rtn;
    }
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doSaveCAAT(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        String rtnmsg = msg.getMessage("0001");;
        for (Map<String, Object> gridData : gridDatas) {
        	gridData.put("ITEM_CLS1", formData.get("ITEM_CLS1"));
        	gridData.put("ITEM_CLS2", formData.get("ITEM_CLS2"));
        	gridData.put("ITEM_CLS3", formData.get("ITEM_CLS3"));
        	gridData.put("ITEM_CLS4", formData.get("ITEM_CLS4"));
        	
            if( "U".equals(gridData.get("INSERT_FLAG")) ) {
            	im0407Mapper.doDeleteCAAT(gridData);
            	im0407Mapper.doInsertCAAT(gridData);
            } else {
            	im0407Mapper.doInsertCAAT(gridData);
            }
        }
        return rtnmsg;
    }
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doDeleteCAAT(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        String rtnmsg = msg.getMessage("0001");;
        for (Map<String, Object> gridData : gridDatas) {
        	gridData.put("ITEM_CLS1", formData.get("ITEM_CLS1"));
        	gridData.put("ITEM_CLS2", formData.get("ITEM_CLS2"));
        	gridData.put("ITEM_CLS3", formData.get("ITEM_CLS3"));
        	gridData.put("ITEM_CLS4", formData.get("ITEM_CLS4"));
        	
            im0407Mapper.doDeleteCAAT(gridData);
        }
        return rtnmsg;
    }
    
    public List<Map<String, Object>> doSearchCommonCode(Map<String, String> param) throws Exception {
        List<Map<String, Object>> rtn = im0407Mapper.doSearchCommonCode(param);
        return rtn;
    }
}
