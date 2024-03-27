package com.st_ones.evermp.SSO1.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.SSO1.SSO1_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */

@Service(value = "sso1_Service")
public class SSO1_Service extends BaseService {

	@Autowired private DocNumService docNumService;

    @Autowired private MessageService msg;

    @Autowired LargeTextService largeTextService;

    @Autowired private SSO1_Mapper sso1_Mapper;

    @Autowired private QueryGenService queryGenService;

    /** *****************
     * 견적관리
     * ******************/
    public List<Map<String, Object>> sso1010_doSearchT(Map<String, String> param) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        param.put("VENDOR_CD", userInfo.getCompanyCd());

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC_SPEC")).trim().equals("")) {
            sParam.put("COL_NM", "A.ITEM_DESC_SPEC");
            sParam.put("COL_VAL", param.get("ITEM_DESC_SPEC"));
            param.put("ITEM_DESC_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(param.get("RFQ_NUM"))) {
            param.put("RFQ_NUM_ORG", param.get("RFQ_NUM"));
            param.put("RFQ_NUM", EverString.forInQuery(param.get("RFQ_NUM"), ","));
            param.put("RFQ_CNT", param.get("RFQ_NUM").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return sso1_Mapper.sso1010_doSearchT(param);
    }

    public List<Map<String, Object>> sso1010_doSearchB(Map<String, String> param) throws Exception {
        return sso1_Mapper.sso1010_doSearchB(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String sso1010_doSend(Map<String, String> param, List<Map<String, Object>> gridDatas) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        String firstSendFlag = param.get("firstSendFlag");
        String giveUpFlag = param.get("giveUpFlag");
        String qtaNum = (firstSendFlag.equals("Y") ? docNumService.getDocNumber("QTA") : param.get("QTA_NUM"));

        String possibleFlag = sso1_Mapper.checkDeadLine(param);
        if (!"Y".equals(possibleFlag)) {
            throw new NoResultException(msg.getMessageByScreenId("SSO1_010", "020"));
        }

        Map<String, String> qthd = new HashMap<String, String>();
        qthd.put("QTA_NUM", qtaNum);
        qthd.put("RFQ_NUM", param.get("RFQ_NUM"));
        qthd.put("RFQ_CNT", param.get("RFQ_CNT"));
        qthd.put("VENDOR_CD", userInfo.getCompanyCd());
        qthd.put("IP_ADDR", param.get("IP_ADDR"));

        /* 견적서 일반정보 등록 */
        if(firstSendFlag.equals("Y")) {
            sso1_Mapper.doInsertQTHD(qthd); }
        else {
            sso1_Mapper.doUpdateQTHD(qthd); }

        sso1_Mapper.doDeleteQTDT(qthd);
        for(Map<String, Object> qtdt : gridDatas) {
            qtdt.put("QTA_NUM", qtaNum);
            qtdt.put("VENDOR_CD", userInfo.getCompanyCd());
            /* 견적서 품목정보 등록 */
            sso1_Mapper.doInsertQTDT(qtdt);
            /* 공급사 견적서 제출여부 업데이트 */
            qtdt.put("RFQ_PROGRESS_CD", (String.valueOf(qtdt.get("GIVEUP_FLAG")).equals("1") ? "150" : "300"));
            sso1_Mapper.doUpdateRfqProgressCd(qtdt);
        }
        return (giveUpFlag.equals("N") ? msg.getMessageByScreenId("SSO1_010", "017") : msg.getMessageByScreenId("SSO1_010", "023"));
    }

    /** *****************
     * 표준납기저장
     * ******************/
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01010_doUpdate(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            // im0201_Mapper.im01010_doUpdate(gridData);
        }
        return msg.getMessage("0031");
    }

    /** *****************
     * 계약현황
     * ******************/
    public List<Map<String, Object>> sso1020_doSearch(Map<String, String> param) throws Exception {

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC_SPEC"));
            sParam.put("COL_NM", "C.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "C.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_CD")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_CD"));
            sParam.put("COL_NM", "C.ITEM_CD");
            param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "C.CUST_ITEM_CD");
            param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("MAKER_CD"));
            sParam.put("COL_NM", "C.MAKER_NM");
            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        return sso1_Mapper.sso1020_doSearch(param);
    }

}
