package com.st_ones.batch.rfqNoticeMail.service;

import com.st_ones.batch.rfqNoticeMail.RfqNoticeMail_Mapper;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 25 오전 9:26
 */
@Service(value = "rfqNoticeMailService")
public class RfqNoticeMail_Service {

    @Autowired private MessageService msg;
    @Autowired LargeTextService largeTextService;
    @Autowired private EverMailService everMailService;
    @Autowired private EverSmsService everSmsService;
    @Autowired private RfqNoticeMail_Mapper rfqNoticeMail_Mapper;

    // 견적마감 D+0일 시점에 공급사 담당자에게 Mail 발송.
    @AuthorityIgnore
    public String doSendNoticeMail(Map<String, String> param) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.RFQNOTICE_TemplateFileName");

        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");

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

		// 협력사 견적 미제출
        List<Map<String, Object>> nonRfqVendorList = rfqNoticeMail_Mapper.doSelectNonPartRfqVendors(param);
        if(nonRfqVendorList.size() > 0) {
            for(Map<String, Object> nonVendorData : nonRfqVendorList) {

                if(!EverString.nullToEmptyString(nonVendorData.get("RECV_EMAIL")).equals("")) {
	                String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
	                fileContents = EverString.replace(fileContents, "$RECV_USER_NM$", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM"))); // 담당자명
	                fileContents = EverString.replace(fileContents, "$VENDOR_NM$", EverString.nullToEmptyString(nonVendorData.get("VENDOR_NM"))); // 공급사명
	                fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", EverString.nullToEmptyString(nonVendorData.get("RFQ_SUBJECT"))); // 견적의뢰명
	                fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM_CNT")) + "차"); // 견적의뢰번호/차수
	                fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", EverString.nullToEmptyString(nonVendorData.get("RFQ_CLOSE_DATE"))); // 견적마감일시
	                fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", EverString.nullToEmptyString(nonVendorData.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(nonVendorData.get("SETTLE_TYPE")))); // 지명방식/입찰서제출방식
	                String rmks  = EverString.nullToEmptyString(nonVendorData.get("RMK"));
	                if( EverString.isEmpty(rmks) ) {
	                	rmks = largeTextService.selectLargeText(EverString.nullToEmptyString(nonVendorData.get("RMK_TEXT_NUM")));
	                }
	                fileContents = EverString.replace(fileContents, "$RMK_TEXT$", rmks); // 요청사항
	                fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
	                fileContents = EverString.rePreventSqlInjection(fileContents);

                    Map<String, String> mdata = new HashMap<String, String>();
                    mdata.put("SUBJECT", "[대명소노시즌] " + EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM")) + " 님. 견적서(" + EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM_CNT")) + " 차) 제출이 지연되고 있습니다.");
                    mdata.put("CONTENTS_TEMPLATE", fileContents);
                    mdata.put("RECV_USER_ID", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_ID")));
                    mdata.put("RECV_USER_NM", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM")));
                    mdata.put("RECV_EMAIL", EverString.nullToEmptyString(nonVendorData.get("RECV_EMAIL")));
                    mdata.put("REF_NUM", EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM")));
                    mdata.put("REF_MODULE_CD", "RFQ"); // 참조모듈
                    // 메일발송
                    everMailService.sendMail(mdata);
                    mdata.clear();
                }

                // SMS 전송
                if( !EverString.nullToEmptyString(nonVendorData.get("RECV_CELL_NUM")).equals("") ){
                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM")) + " 님. 견적서(" + EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM_CNT")) + " 차) 제출이 지연되고 있습니다.");
                    sdata.put("RECV_USER_ID", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_ID"))); // 받는 사용자ID
                    sdata.put("RECV_USER_NM", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM"))); // 받는사람
                    sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(nonVendorData.get("RECV_CELL_NUM"))); // 받는 사람 전화번호
                    sdata.put("REF_NUM", ""); // 참조번호
                    sdata.put("REF_MODULE_CD", "RFQ"); // 참조모듈
    				// SMS 전송
    				everSmsService.sendSms(sdata);
    				sdata.clear();
                }
            }
        }

        // 협력사 입찰 미제출
        templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BIDNOTICE_TemplateFileName");

        List<Map<String, Object>> nonBidVendorList = rfqNoticeMail_Mapper.doSelectNonPartBidVendors(param);
        if(nonBidVendorList.size() > 0) {
            for(Map<String, Object> nonVendorData : nonBidVendorList) {

                if(!EverString.nullToEmptyString(nonVendorData.get("RECV_EMAIL")).equals("")) {
	                String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
	                fileContents = EverString.replace(fileContents, "$RECV_USER_NM$", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM"))); // 담당자명
	                fileContents = EverString.replace(fileContents, "$VENDOR_NM$", EverString.nullToEmptyString(nonVendorData.get("VENDOR_NM"))); // 공급사명
	                fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", EverString.nullToEmptyString(nonVendorData.get("RFQ_SUBJECT"))); // 입찰의뢰명
	                fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM_CNT")) + "차"); // 입찰의뢰번호/차수
	                fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", EverString.nullToEmptyString(nonVendorData.get("RFQ_CLOSE_DATE"))); // 입찰마감일시
	                fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", EverString.nullToEmptyString(nonVendorData.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(nonVendorData.get("SETTLE_TYPE")))); // 지명방식/입찰서제출방식
	                fileContents = EverString.replace(fileContents, "$RMK_TEXT$", EverString.nullToEmptyString(nonVendorData.get("RMK"))); // 요청사항
	                fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
	                fileContents = EverString.rePreventSqlInjection(fileContents);

                    Map<String, String> mdata = new HashMap<String, String>();
                    mdata.put("SUBJECT", "[대명소노시즌] " + EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM")) + " 님. 입찰서(" + EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM_CNT")) + " 차) 제출이 지연되고 있습니다.");
                    mdata.put("CONTENTS_TEMPLATE", fileContents);
                    mdata.put("RECV_USER_ID", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_ID")));
                    mdata.put("RECV_USER_NM", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM")));
                    mdata.put("RECV_EMAIL", EverString.nullToEmptyString(nonVendorData.get("RECV_EMAIL")));
                    mdata.put("REF_NUM", EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM")));
                    mdata.put("REF_MODULE_CD", "BID"); // 참조모듈
                    // 메일발송
                    everMailService.sendMail(mdata);
                    mdata.clear();
                }

                // SMS 전송
                if( !EverString.nullToEmptyString(nonVendorData.get("RECV_CELL_NUM")).equals("") ){
                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM")) + " 님. 입찰서(" + EverString.nullToEmptyString(nonVendorData.get("RFQ_NUM_CNT")) + " 차) 제출이 지연되고 있습니다.");
                    sdata.put("RECV_USER_ID", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_ID"))); // 받는 사용자ID
                    sdata.put("RECV_USER_NM", EverString.nullToEmptyString(nonVendorData.get("RECV_USER_NM"))); // 받는사람
                    sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(nonVendorData.get("RECV_CELL_NUM"))); // 받는 사람 전화번호
                    sdata.put("REF_NUM", ""); // 참조번호
                    sdata.put("REF_MODULE_CD", "BID"); // 참조모듈
    				// SMS 전송
    				everSmsService.sendSms(sdata);
    				sdata.clear();
                }
            }
        }
        return msg.getMessage("0001");
    }

}
