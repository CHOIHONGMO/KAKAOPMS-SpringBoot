package com.st_ones.evermp.BS99.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS99.BS9901_Mapper;
import com.st_ones.eversrm.system.code.service.BSYC_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 17 오후 5:27
 */

@Service(value = "bs9901_Service")
public class BS9901_Service extends BaseService {

    @Autowired private BS9901_Mapper bs9901_Mapper;
    @Autowired private BSYC_Service bsycService;
    @Autowired private RealtimeIF_Mapper realtimeif_mapper;
    
    @Autowired private MessageService msg;
    @Autowired LargeTextService largeTextService;
    @Autowired private EverMailService everMailService;
    @Autowired private EverSmsService everSmsService;

    /** *****************
     * 템플릿관리
     * ******************/
    public List<Map<String, Object>> bs99010_doSearch(Map<String, String> param) throws Exception {
        return bs9901_Mapper.bs99010_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs99010_doSave(List<Map<String, Object>> gridList) throws Exception {

    	String rtnMsg = "";
    	for(Map<String, Object> gridData : gridList) {

			if(!gridData.get("TMPL_NUM").equals(gridData.get("TMPL_NUM_H"))){
				int checkNo = bs9901_Mapper.bs99010_doCheck(gridData);
				if (checkNo > 0) {
					rtnMsg = msg.getMessageByScreenId("BS99_010", "WARNING1") + gridData.get("TMPL_NUM") + msg.getMessageByScreenId("BS99_010", "WARNING2");
					return rtnMsg;
				}
			}
        	bs9901_Mapper.bs99010_doSave(gridData);
        }
        return msg.getMessage("0031");
    }
    
    public Map<String, String> doSearch_templateFile(Map<String, String> param) throws Exception {
        return bs9901_Mapper.doSearch_templateFile(param);
    }
    
    /** *****************
     * 기준정보 > 고객의소리 > 고객의소리 진행현황
     * ******************/
    public List<Map<String, Object>> bs99020_doSearch(Map<String, String> param) throws Exception {

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("VOC_TYPE_LIST", Arrays.asList(param.get("VOC_TYPE").split(",")));

        return bs9901_Mapper.bs99020_doSearch(fParam);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs99020_doReceipt(List<Map<String, Object>> gridList) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            gridData.put("PROGRESS_CD", "200");
            bs9901_Mapper.bs99020_doReceipt(gridData);
        }
        return msg.getMessage("0156");
    }

    public List<Map<String, Object>> bs99021_doSearch(Map<String, String> param) {
        Map<String, Object> fParam = new HashMap<String, Object>(param);
        return bs9901_Mapper.bs99020_doSearch(fParam);
    }

    /** *****************
     * 기준정보 > 고객의소리 > 고객의소리 진행현황 > 고객의소리 등록/수정 팝업
     * ******************/
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs99021_doReceipt(Map<String, String> param) throws Exception {
    	
        //****************2022.12.26 신규추가*******************//
        //*****접수 및 처리중, 조치완료 후 G/W PACKAGE 호출 (접수상태로)*****//
        /**
         * 2022.12.26 최형신 차장 요청으로 주석처리
        if( !"1".equals(EverString.nullToEmptyString(param.get("IF_FLAG")))) {
            realtimeif_mapper.gwVocCall(param);
            param.put("IF_FLAG", "1");
        }*/
        //**************************************************//
    	
        param.put("PROGRESS_CD", "200");
        bs9901_Mapper.bs99021_doReceipt(param);
        
        return msg.getMessage("0156");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs99021_doInAction(Map<String, String> param) throws Exception {
    	
        param.put("PROGRESS_CD", "300");
        bs9901_Mapper.bs99021_doInAction(param);
        
        //****************2022.12.26 신규추가*******************//
        //*****접수 및 처리중, 조치완료 후 G/W PACKAGE 호출 (접수상태로)*****//
        /**
         * 2022.12.26 최형신 차장 요청으로 주석처리
        if( !"1".equals(EverString.nullToEmptyString(param.get("IF_FLAG")))) {
            realtimeif_mapper.gwVocCall(param);
            param.put("IF_FLAG", "1");
        }*/
        //**************************************************//
        
        return msg.getMessage("0158");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs99021_doActionComplete(Map<String, String> param) throws Exception {
    	
        //****************2022.12.26 신규추가*******************//
        //*****접수 및 처리중, 조치완료 후 G/W PACKAGE 호출 (접수상태로)*****//
    	/**
         * 2022.12.26 최형신 차장 요청으로 주석처리
        if( !"1".equals(EverString.nullToEmptyString(param.get("IF_FLAG")))) {
            realtimeif_mapper.gwVocCall(param);
            param.put("IF_FLAG", "1");
        }*/
        //**************************************************//
        
        param.put("PROGRESS_CD", "400");
        bs9901_Mapper.bs99021_doActionComplete(param);
        
        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BYMR_TemplateFileName");
		
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

        String vocType = ""; //조치담당자
        List<Map<String, String>> vocTypeList = bsycService.getCodeCombo("MP053");
        for(Map<String, String> vocTypeMap : vocTypeList) {
            if(vocTypeMap.get("value").equals(param.get("DS_USER_ID"))) {
                vocType = vocTypeMap.get("text");
            }
        }

        String dsDate = EverDate.formatDate(String.valueOf(EverDate.getDate()), "yyyyMMdd", "yyyy-MM-dd");  //조치완료일
        String recvDate=""; //접수일자
        if(EverString.nullToEmptyString(param.get("RECV_DATE")).equals("")){
            recvDate = dsDate;
        }else{
            recvDate = EverDate.formatDate(String.valueOf(param.get("RECV_DATE")), "yyyyMMdd", "yyyy-MM-dd");
        }
        String cdDate = EverDate.formatDate(String.valueOf(param.get("CD_DATE")), "yyyyMMdd", "yyyy-MM-dd");    //조치예정일
        
        String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        fileContents = EverString.replace(fileContents, "$VC_NO$", param.get("VC_NO")); // VOC번호
        fileContents = EverString.replace(fileContents, "$VOC_TYPE_NM$", param.get("VOC_TYPE_NM")); // VOC유형
        fileContents = EverString.replace(fileContents, "$REQ_COM_TEXT$", param.get("REQ_COM_TEXT")); // 요청사
        fileContents = EverString.replace(fileContents, "$PH_DATE$", param.get("PH_DATE")); // 조치요청일
        fileContents = EverString.replace(fileContents, "$ORDER_NO$", param.get("ORDER_NO")); // 주문번호
        fileContents = EverString.replace(fileContents, "$ITEM_CD$", param.get("ITEM_CD")); // 품목코드
        fileContents = EverString.replace(fileContents, "$REQ_RMK$", EverString.nullToEmptyString(param.get("REQ_RMK")).replaceAll("\n","<br>")); // 요청내역
        fileContents = EverString.replace(fileContents, "$RECV_DATE$", recvDate); // 접수일자
        fileContents = EverString.replace(fileContents, "$CD_DATE$", cdDate); // 조치예정일
        fileContents = EverString.replace(fileContents, "$DS_USER_NM$", param.get("DS_USER_NM")); // 조치담당자
        fileContents = EverString.replace(fileContents, "$DS_DATE$", dsDate); // 조치완료일
        fileContents = EverString.replace(fileContents, "$DF_RMK$", EverString.nullToEmptyString(param.get("DF_RMK")).replaceAll("\n","<br>")); // 조치내역
        fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
        fileContents = EverString.rePreventSqlInjection(fileContents);

        Map<String, String> mdata = new HashMap<String, String>();
        mdata.put("SUBJECT", "[대명소노시즌] 문의주신 상담내역이 처리완료 되었습니다.("+param.get("VC_NO")+")");
        mdata.put("CONTENTS_TEMPLATE", fileContents);
        mdata.put("RECV_USER_ID", EverString.nullToEmptyString(param.get("REQ_USER_ID")));
        mdata.put("RECV_USER_NM", EverString.nullToEmptyString(param.get("REQ_USER_NM")));
        mdata.put("RECV_EMAIL", EverString.nullToEmptyString(param.get("REQ_EMAIL")));
        mdata.put("REF_NUM", param.get("VC_NO"));
        mdata.put("REF_MODULE_CD", "VC"); // 참조모듈
        // 메일전송
        everMailService.sendMail(mdata);
        mdata.clear();

        //sms 발송
        String smsMessage = "[대명소노시즌] 문의주신 상담내역이 처리완료 되었습니다.(" + param.get("VC_NO")+")";
        mdata.put("CONTENTS",      smsMessage);		//전송내용
        mdata.put("RECV_USER_ID",  EverString.nullToEmptyString(param.get("REQ_USER_ID")));		//받는 사용자ID
        mdata.put("RECV_USER_NM",  EverString.nullToEmptyString(param.get("REQ_USER_NM")));		//받는사람
        mdata.put("RECV_TEL_NUM",  EverString.nullToEmptyString(param.get("REQ_CELL_NUM")));	//받는 사람 전화번호
        mdata.put("REF_NUM",       EverString.nullToEmptyString(param.get("VC_NO")));	//참조번호
        mdata.put("REF_MODULE_CD", "VC");		//참조모듈
        // SMS발송
        everSmsService.sendSms(mdata);

        return msg.getMessage("0158");
    }
}
