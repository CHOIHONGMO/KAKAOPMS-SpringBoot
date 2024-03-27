package com.st_ones.batch.custCfmReqMail.service;

import com.st_ones.batch.custCfmReqMail.CustCfmReqMailMapper;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 22. 9. 19
 */
@Service(value = "custCfmReqMailService")
public class CustCfmReqMailService {

	@Autowired private MessageService msg;
	@Autowired private CustCfmReqMailMapper custCfmReqMailMapper;
	@Autowired private EverMailService everMailService;
	@Autowired private EverSmsService everSmsService;

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doCustCfmReqMail(Map<String, String> param) throws Exception {
		
		// Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.PY01_TemplateFileName");
		
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
		
		String fileContents = "";
		List<Map<String, Object>> list = custCfmReqMailMapper.doCustCfmReqMail();
		for(Map<String, Object> map : list) {
			if (!"".equals(map.get("EMAIL"))) {
				
				String CONTENTS = "고객사 " + EverString.nullToEmptyString(map.get("CUST_NM")) + "의 정산마감이 지연되고있습니다.<br>확인 후 처리하시기 바랍니다.";
				fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
				fileContents = EverString.replace(fileContents, "$CUST_NM$", EverString.nullToEmptyString(map.get("CUST_NM")));
				fileContents = EverString.replace(fileContents, "$CLOSING_MONTH$", EverString.nullToEmptyString(map.get("CLOSING_MONTH")));
				fileContents = EverString.replace(fileContents, "$CONTENTS$", CONTENTS);
				fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
				fileContents = EverString.rePreventSqlInjection(fileContents);
				
				Map<String, String> mdata = new HashMap<String, String>();
				mdata.put("SUBJECT", "[대명소노시즌] " + map.get("CUST_NM") + ", " + map.get("CLOSING_MONTH") + "월 마감확정을 요청드립니다.");
				mdata.put("CONTENTS_TEMPLATE", fileContents);
				mdata.put("RECV_USER_ID", EverString.nullToEmptyString(map.get("USER_ID")));
				mdata.put("RECV_USER_NM", EverString.nullToEmptyString(map.get("USER_NM")));
				mdata.put("RECV_EMAIL", EverString.nullToEmptyString(map.get("EMAIL")));
				mdata.put("REF_NUM", EverString.nullToEmptyString(map.get("CLOSING_NO")));
				mdata.put("REF_MODULE_CD", "APAR");
				// 메일 발송
				everMailService.sendMail(mdata);
				mdata.clear();
			}
		}
		return msg.getMessage("0001");
	}

}
