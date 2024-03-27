package com.st_ones.evermp.IM03.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM03.IM0303_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "im0303_Service")
public class IM0303_Service extends BaseService {

    @Autowired private DocNumService docNumService;

    @Autowired private MessageService msg;

    @Autowired private IM0303_Mapper im0303Mapper;

    @Autowired private QueryGenService queryGenService;

    @Autowired LargeTextService largeTextService;

    @Autowired private EverMailService everMailService;

    @Autowired private EverSmsService everSmsService;

    /** ****************************************************************************************************************
     * 신규품목처리현황
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im03031_doSearch(Map<String, String> param) {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "A.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "A.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
		/*
		 * if(!EverString.nullToEmptyString(param.get("ITEM_SPEC")).equals("")) {
		 * sParam.put("COL_VAL", param.get("ITEM_SPEC")); sParam.put("COL_NM",
		 * "A.ITEM_SPEC"); param.put("ITEM_SPEC",
		 * EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam))
		 * ); }
		 */

        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("MAKER_NM"));
            sParam.put("COL_NM", "A.MAKER_NM");
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

    //	return im0303Mapper.im03031_doSearch(param);
    	return im0303Mapper.im03031_doSearch(fParam);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03031_doAcpt(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			im0303Mapper.im03031_doAcpt(gridData);
		}
		return msg.getMessage("0156");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03031_doReject(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			im0303Mapper.im03031_doReject(gridData);
		}
		return msg.getMessage("0058");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03031_doDelete(List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {
            im0303Mapper.im03031_doDelete(gridData);
        }
        return msg.getMessage("0016");
    }

    /** ****************************************************************************************************************
     * 계약현황
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im01040_doSearch(Map<String, String> param) {

        return im0303Mapper.im01040_doSearch(param);
    }

    /** ****************************************************************************************************************
     * 입고 내역 및 실적, 판매가 이력 확인 Popup
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im01042_doSearch(Map<String, String> param) {

        return im0303Mapper.im01042_doNeoSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01041_doChangeVendor(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            gridData.put("VENDOR_CD", formData.get("pVENDOR_CD"));
            gridData.put("PRICE_CHANGE_REASON", formData.get("pPRICE_CHANGE_REASON"));
            gridData.put("VALID_FROM_DATE", formData.get("pVALID_FROM_DATE"));
            gridData.put("VALID_TO_DATE", formData.get("pVALID_TO_DATE"));
            im0303Mapper.doInsertINFH(gridData);

            im0303Mapper.doUpdateINFO(gridData);
        }
        return msg.getMessageByScreenId("IM01_041", "002");
    }
    
    // 상품관리 > 계약단가관리 > 단가이력 조회 (IM01_040) : 기존 계약 기준으로 새로운 견적요청할 경우
    // 신규품목 등록요청에 대한 공급사 견적요청서 전송
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01040_doSendRFQ(Map<String, String> rqhdData, List<Map<String, Object>> rqdtDatas) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();

        rqhdData.put("VENDOR_LIST", rqhdData.get("pVENDOR_LIST"));
        rqhdData.put("RFQ_SUBJECT", rqhdData.get("pRFQ_SUBJECT"));
        rqhdData.put("VENDOR_OPEN_TYPE", rqhdData.get("pVENDOR_OPEN_TYPE"));
        rqhdData.put("RFQ_CLOSE_DATE", rqhdData.get("pRFQ_CLOSE_DATE"));
        rqhdData.put("RFQ_CLOSE_HOUR", rqhdData.get("pRFQ_CLOSE_HOUR"));
        rqhdData.put("RFQ_CLOSE_MIN", rqhdData.get("pRFQ_CLOSE_MIN"));
        rqhdData.put("DEAL_TYPE", rqhdData.get("pDEAL_TYPE"));
        rqhdData.put("CONT_START_DATE", rqhdData.get("pCONT_START_DATE"));
        rqhdData.put("CONT_END_DATE", rqhdData.get("pCONT_END_DATE"));
        rqhdData.put("RMK_TEXT", rqhdData.get("pRMK_TEXT"));
        rqhdData.put("ATT_FILE_NUM", rqhdData.get("pATT_FILE_NUM"));
        rqhdData.put("OPTION_RFQ_REASON", rqhdData.get("pOPTION_RFQ_REASON"));
        rqhdData.put("RFQ_TYPE", rqhdData.get("pRFQ_TYPE"));

        String rmkTextNum = largeTextService.saveLargeText(rqhdData.get("RMK_TEXT_NUM"), rqhdData.get("RMK_TEXT"));
        rqhdData.put("RMK_TEXT_NUM", rmkTextNum);

        String itemReqNo = docNumService.getDocNumber("RE");
        String rfqNum = docNumService.getDocNumber("RFQ");
        String rfqCnt = "1";

        rqhdData.put("RFQ_NUM", rfqNum);
        rqhdData.put("RFQ_CNT", rfqCnt);
        rqhdData.put("PROGRESS_CD", "200"); // 견적중
        im0303Mapper.doInsertRQHD(rqhdData);

        String vendorListStr = rqhdData.get("VENDOR_LIST");
        String[] vendorArgs = vendorListStr.split(",");
        int rfqSq = 1;
        for (Map<String, Object> rqdtData : rqdtDatas) {

            rqdtData.put("CUST_CD", userInfo.getCompanyCd());
            rqdtData.put("ITEM_REQ_NO", itemReqNo);
            rqdtData.put("ITEM_REQ_SEQ", rfqSq);
            rqdtData.put("PROGRESS_CD", "400"); // 소싱중
            rqdtData.put("OPERATOR_FLAG", "1"); // 운영사 등록여부 (0 : 고객사 등록, 1 : 운영사 등록)
            im0303Mapper.doInsertNWRQ(rqdtData);

            rqdtData.put("RFQ_NUM", rfqNum);
            rqdtData.put("RFQ_CNT", rfqCnt);
            rqdtData.put("RFQ_SQ", rfqSq);
            rqdtData.put("PROGRESS_CD", "200"); // 견적중
            rqdtData.put("CUST_REQ_FLAG", "0"); // 고객사 요청 여부
            im0303Mapper.doInsertRQDT(rqdtData);

            for (int i = 0; i < vendorArgs.length; i++) {
                Map<String, Object> rqvnData = new HashMap<String, Object>();
                rqvnData.put("RFQ_NUM", rfqNum);
                rqvnData.put("RFQ_CNT", rfqCnt);
                rqvnData.put("RFQ_SQ", rfqSq);
                rqvnData.put("VENDOR_CD", vendorArgs[i]);
                rqvnData.put("RFQ_PROGRESS_CD", "100");	// 공급사 견적진행상태(M072) : 미접수(100)
                im0303Mapper.doInsertRQVN(rqvnData);
            }
            rfqSq++;
        }
        
        // 공급사 견적 요청 후 메일발송
        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.RFQ_TemplateFileName");

        String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm  = PropertiesManager.getString("eversrm.system.contextName");
		
		String maintainUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { maintainUrl = "https://"; }
		else { maintainUrl = "http://"; }
		if ("80".equals(domainPort)) {
			maintainUrl += domainNm;
		} else {
			maintainUrl += domainNm + ":" + domainPort;
		}
		maintainUrl += contextNm;

        Map<String, String> rfqData = im0303Mapper.getRfqInfoHD(rqhdData);
        String rfqNumCnt = EverString.nullToEmptyString(rfqData.get("RFQ_NUM")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("RFQ_CNT")));
        String vendorOpenDealType = EverString.nullToEmptyString(rfqData.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("DEAL_TYPE")));
        String rmkText = largeTextService.selectLargeText(EverString.nullToEmptyString(rfqData.get("RMK_TEXT_NUM")));

        String tblBody = "<tbody>";
        String enter = "\n";
        List<Map<String, String>> itemList = im0303Mapper.getRfqItemList(rqhdData);
        if(itemList.size() > 0) {
            for (Map<String, String> itemData : itemList) {

                String itemDesc = EverString.nullToEmptyString(itemData.get("ITEM_DESC"));
                if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }

                String itemSpec = EverString.nullToEmptyString(itemData.get("ITEM_SPEC"));
                if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }

                String tblRow = "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</th>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }

        List<Map<String, String>> vendorList = im0303Mapper.getRfqVendorList(rqhdData);
        for (Map<String, String> vendorData : vendorList) {

            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", vendorData.get("VENDOR_NM")); // 공급사명
            fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", rfqNumCnt); // 견적의뢰번호/차수
            fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", EverString.nullToEmptyString(rfqData.get("RFQ_SUBJECT"))); // 견적의뢰명
            fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", EverString.nullToEmptyString(rfqData.get("RFQ_CLOSE_DATE"))); // 견적마감일시
            fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", vendorOpenDealType); // 지명방식/거래유형
            fileContents = EverString.replace(fileContents, "$RMK_TEXT$", rmkText); // 요청사항
            fileContents = EverString.replace(fileContents, "$CTRL_USER_NM$", EverString.nullToEmptyString(rfqData.get("CTRL_USER_NM"))); // 품목담당자
            fileContents = EverString.replace(fileContents, "$TEL_NUM$", EverString.nullToEmptyString(rfqData.get("TEL_NUM"))); // 연락처
            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            if(!vendorData.get("RECV_EMAIL").equals("")) {
                Map<String, String> mdata = new HashMap<String, String>();
                mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 귀사에 견적을 요청드립니다.");
                mdata.put("CONTENTS_TEMPLATE", fileContents);
                mdata.put("SEND_EMAIL", vendorData.get("SEND_EMAIL"));
                mdata.put("SEND_USER_NM", vendorData.get("SEND_USER_NM"));
                mdata.put("SEND_USER_ID", vendorData.get("SEND_USER_ID"));
                mdata.put("RECV_EMAIL", vendorData.get("RECV_EMAIL"));
                mdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM"));
                mdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID"));
                mdata.put("REF_NUM", rfqData.get("RFQ_NUM"));
                mdata.put("REF_MODULE_CD","RFQ"); // 참조모듈
                // 메일전송.
                everMailService.sendMail(mdata);
                mdata.clear();
            }

            if(!vendorData.get("RECV_TEL_NUM").equals("")) {
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("SMS_SUBJECT", "[대명소노시즌] 견적요청서가 도착했습니다."); // SMS 제목
                sdata.put("CONTENTS", "[대명소노시즌] 견적요청서가 도착했습니다.(" + vendorData.get("RFQ_NUM") + ") 빠른 견적진행 부탁드립니다."); // 전송내용
                sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(vendorData.get("SEND_USER_ID")).equals("") ? "SYSTEM" : vendorData.get("SEND_USER_ID"))); // 보내는 사용자ID
                sdata.put("SEND_USER_NM",vendorData.get("SEND_USER_NM")); // 보내는사람
                sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                sdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID")); // 받는 사용자ID
                sdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM")); // 받는사람
                sdata.put("RECV_TEL_NUM", vendorData.get("RECV_TEL_NUM")); // 받는 사람 전화번호
                sdata.put("REF_NUM", rfqData.get("RFQ_NUM")); // 참조번호
                sdata.put("REF_MODULE_CD","RFQ"); // 참조모듈
                // SMS 전송.
                everSmsService.sendSms(sdata);
                sdata.clear();
            }
        }
        return msg.getMessageByScreenId("IM01_040", "012");
    }

}