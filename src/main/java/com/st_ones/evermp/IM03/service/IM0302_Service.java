package com.st_ones.evermp.IM03.service;

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
import com.st_ones.evermp.IM03.IM0302_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "im0302_Service")
public class IM0302_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private IM0302_Mapper im0302Mapper;

    @Autowired
    LargeTextService largeTextService;

    @Autowired
    private QueryGenService queryGenService;

    /** ****************************************************************************************************************
     * 독점품목관리
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im01030_doSearch(Map<String, String> formData) {
        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(formData.get("ITEM_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_SPEC"));
            sParam.put("COL_NM", "MTGL.ITEM_SPEC");
            formData.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(formData.get("ITEM_CD"))) {
            formData.put("ITEM_CD_ORG", formData.get("ITEM_CD"));
            formData.put("ITEM_CD", EverString.forInQuery(formData.get("ITEM_CD"), ","));
            formData.put("ITEM_CNT", formData.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return im0302Mapper.im01030_doSearch(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01030_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0302Mapper.im01030_doSave(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01030_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0302Mapper.im01030_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ****************************************************************************************************************
     * 동의/유사어 관리
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im03020_doSearch(Map<String, String> formData) {
        return im0302Mapper.im03020_doSearch(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03020_doSave(List<Map<String, Object>> gridList) throws Exception {
    	int dupCnt = 0;
        for(Map<String, Object> gridData : gridList) {
        	if( "".equals(EverString.nullToEmptyString(String.valueOf(gridData.get("SEQ")))) ) {
        		gridData.put("SEQ", null);
            }
        	// 표준명 + 동의/유사어 중복 체크
        	if( "Y".equals(im0302Mapper.im03020_isDupFlag(gridData)) ) {
        		dupCnt++;
        		continue;
        	}
            im0302Mapper.im03020_doSave(gridData);
        }
        String rtnMsg = msg.getMessage("0031");
        if( dupCnt > 0 ) {
        	rtnMsg = msg.getMessageByScreenId("IM03_020", "001") + " [" + dupCnt + "] " + msg.getMessageByScreenId("IM03_020", "002") + "\n" + msg.getMessage("0031");
        }
        return rtnMsg;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03020_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
        	if( "".equals(EverString.nullToEmptyString(String.valueOf(gridData.get("SEQ")))) ) {
        		gridData.put("SEQ", null);
            }
        	im0302Mapper.im03020_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /** ****************************************************************************************************************
     * Mysite
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im01050_doSearch(Map<String, String> formData) {
        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(formData.get("ITEM_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_SPEC"));
            sParam.put("COL_NM", "MTGL.ITEM_SPEC");
            formData.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(formData.get("MAKER_NM")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("MAKER_NM"));
            sParam.put("COL_NM", "K.MAKER_NM");
            formData.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(formData.get("ITEM_CD"))) {
            formData.put("ITEM_CD_ORG", formData.get("ITEM_CD"));
            formData.put("ITEM_CD", EverString.forInQuery(formData.get("ITEM_CD"), ","));
            formData.put("ITEM_CNT", formData.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return im0302Mapper.im01050_doSearch(formData);
    }

    public List<Map<String, Object>> im01050_doSearchDp(Map<String, String> formData) {
        return im0302Mapper.im01050_doSearchDp(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01050_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0302Mapper.im01050_doSave(gridData);
            im0302Mapper.im01050_doSaveMTGC(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01050_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0302Mapper.im01050_doDelete(gridData);
//            im0302Mapper.im01050_doDeleteMTGC(gridData);
        }
        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01050_doSaveDp(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0302Mapper.im01050_doSaveDp(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01050_doDeleteDp(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            im0302Mapper.im01050_doDeleteDp(gridData);
        }
        return msg.getMessage("0017");
    }

}