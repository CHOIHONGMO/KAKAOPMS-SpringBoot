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
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM03.IM0304_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "im0304_Service")
public class IM0304_Service extends BaseService {

    @Autowired private DocNumService docNumService;
    @Autowired private EverMailService everMailService;
    @Autowired private MessageService msg;
    @Autowired private IM0304_Mapper im0304Mapper;
    @Autowired LargeTextService largeTextService;
    @Autowired private QueryGenService queryGenService;

    /** ****************************************************************************************************************
     * 품목속성 조회
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im03011_doSearch(Map<String, String> formData) {
        return im0304Mapper.im03011_doSearch(formData);
    }

    /** ****************************************************************************************************************
     * 품목관리 > 품목표준화 > 신규품목 재요청 승인(IM03_040)
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im03040_doSearch(Map<String, String> formData) {
    	
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(formData.get("ITEM_NM")).trim().equals("")) {
            sParam.put("COL_NM", "A.ITEM_DESC");
            sParam.put("COL_VAL", formData.get("ITEM_NM"));
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            
            sParam.put("COL_NM", "A.ITEM_SPEC");
            sParam.put("COL_VAL", formData.get("ITEM_NM"));
            formData.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        return im0304Mapper.im03040_doSearch(formData);
    }
    
    // 2020.09.05 미사용
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03040_doConfirm(List<Map<String, Object>> gridDatas) throws Exception {
        
    	UserInfo userInfo = UserInfoManager.getUserInfoImpl();
        
        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");
		
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
		
        String SUBJECT  = "";
        String CONTENTS = "";
        String REQ_USER_ID = "";
        String templatetelNo = PropertiesManager.getString("eversrm.system.sms.default.telNo");
		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		for (Map<String, Object> gridData : gridDatas) {
			im0304Mapper.im03040_doConfirm(gridData);

			if(!REQ_USER_ID.equals(gridData.get("REQ_USER_ID"))) {
                SUBJECT = "[대명소노시즌] " + gridData.get("REQ_USER_NM") + "님. 신규품목요청건에 대한 추가정보를 요청드립니다.";
                CONTENTS = "<br>신규품목요청건에 대해 추가정보를 요청드립니다.<br>시스템에 로그인 하시어 확인 후 조치 바랍니다.";

                fileContents = EverString.replace(fileContents, "$SUBJECT$", SUBJECT);
                fileContents = EverString.replace(fileContents, "$CONTENTS$", CONTENTS);
                fileContents = EverString.replace(fileContents, "$TELNO$", templatetelNo);
                fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
                fileContents = EverString.rePreventSqlInjection(fileContents);

                if(!"".equals(gridData.get("EMAIL"))) {
                    Map<String, String> mdata = new HashMap<String, String>();
                    mdata.put("CONTENTS_TEMPLATE", fileContents);
                    mdata.put("SUBJECT", SUBJECT);
                    mdata.put("SEND_EMAIL", userInfo.getEmail());
                    mdata.put("SEND_USER_NM", userInfo.getUserNm());
                    mdata.put("SEND_USER_ID", userInfo.getUserId());
                    mdata.put("RECV_EMAIL", EverString.nullToEmptyString(gridData.get("EMAIL")));
                    mdata.put("RECV_USER_NM", EverString.nullToEmptyString(gridData.get("REQ_USER_NM")));
                    mdata.put("RECV_USER_ID", EverString.nullToEmptyString(gridData.get("REQ_USER_ID")));
                    mdata.put("REF_NUM", String.valueOf(gridData.get("ITEM_REQ_NO")));
                    mdata.put("REF_MODULE_CD", "SIT");
                    // 메일발송
                    everMailService.sendMail(mdata);
                    mdata.clear();
                }
            }

            REQ_USER_ID = String.valueOf(gridData.get("REQ_USER_ID"));
		}

		return msg.getMessage("0057");
    }
    
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03040_doReject(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			im0304Mapper.im03040_doReject(gridData);
		}
		return msg.getMessage("0058");
    }


}