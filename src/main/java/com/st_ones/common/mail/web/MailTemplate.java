package com.st_ones.common.mail.web;

import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : MailTemplate.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 09. 10.
 * @version 1.0  
 * @see 
 */

@Component(value = "mailTemplate")
public class MailTemplate {

	private Logger logger = LoggerFactory.getLogger(MailTemplate.class);
	
	/**
	 * 시스템관리 > 메일전송에서 사용
	 * @param screenNm
	 * @param userType
	 * @param formData
	 * @param gridDatas
	 * @return
	 * @throws Exception
	 */
	public String get_Mail_Template(String screenNm, String userType, Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

		String fileContents = "";
		String templateFileNm ="";
		try {

			String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
			Map<String, Object> param2 = new HashMap<String,Object>();
			param2.putAll(formData);

			//C:운영사 / S:협력사 / B:고객사
			if (userType.equals("C")) {
				templateFileNm = templatePath + "mail_form_C.template";
			} else if (userType.equals("AO")) {
				templateFileNm = templatePath + "mail_form_AO.template";
			} else if (userType.equals("E")) {
				templateFileNm = templatePath + "mail_form_E.template";
			} else if (userType.equals("S")) {
				templateFileNm = templatePath + "mail_form_S.template";
			} else if (userType.equals("B")) {
				templateFileNm = templatePath + "mail_form_B.template";
			}

			boolean isDevelopmentMode = PropertiesManager.getBoolean("eversrm.system.developmentFlag") ;
			String maintainUrl = "",vendorUrl = "",customerUrl="";
			if(isDevelopmentMode){
				maintainUrl = PropertiesManager.getString("eversrm.urls.maintain.dev");
				vendorUrl   = PropertiesManager.getString("eversrm.urls.vendor.dev");
				customerUrl = PropertiesManager.getString("eversrm.urls.customer.dev");
			} else {
				maintainUrl = PropertiesManager.getString("eversrm.urls.maintain.real");
				vendorUrl   = PropertiesManager.getString("eversrm.urls.vendor.real");
				customerUrl = PropertiesManager.getString("eversrm.urls.customer.real");				
			}
			fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");

			fileContents = EverString.replace(fileContents, "$SCREEN_NM$", screenNm); // 제목
			fileContents = EverString.replace(fileContents, "$SUBJECT$", formData.get("SUBJECT")); // 제목
			fileContents = EverString.replace(fileContents, "$CONTENTS$", formData.get("CONTENTS")); // 내용
			fileContents = EverString.replace(fileContents, "$vendorUrl$", vendorUrl);

			if (userType.equals("AO")) {
				fileContents = EverString.replace(fileContents, "$tblBody$", formData.get("TBL_BODY")); // 상세내용
			}
			if (userType.equals("E")) {
				fileContents = EverString.replace(fileContents, "$evalLink$", formData.get("EVAL_LINK")); // 평가페이지 바로가기
			}

			if (userType.equals("C") || userType.equals("AO") || userType.equals("E")) {
				fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
				fileContents = EverString.replace(fileContents, "$customerUrl$", customerUrl);
			}

			// 발신자 메일이 없는경우에는 발신정용 문구 추가.
			if(StringUtils.isEmpty(formData.get("SEND_EMAIL"))) {
				fileContents = EverString.replace(fileContents, "$ALERTTEXT$", "* 본 메일은 발신 전용 메일로 회신을 통한 답변은 받으실 수 없습니다."); // 문구
			}else{
				fileContents = EverString.replace(fileContents, "$ALERTTEXT$", ""); // 문구
			}

			String tblBody = "";
			//그리드데이트 또는 폼추가시 아래 형식처럼 추가할것.
			if(gridDatas!=null){
				for (Map<String, Object> gridData : gridDatas) {
					String enter   = "\n";
					String tblRow = enter + "<tr>"
							+ enter + "<td>" + gridData.get("C1") + "</td>"
							+ enter + "<td>" + gridData.get("C2") + "</td>"
							+ enter + "<td>" + gridData.get("C3") + "</td>"
							+ enter + "<td>" + gridData.get("C4") + "</td>"
							+ enter + "<td class=\"txt_r\">" + gridData.get("C5") + "</td>"	//숫자
							+ enter + "</tr>";
					tblBody += tblRow;
				}
				fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
			}

			fileContents = EverString.rePreventSqlInjection(fileContents);

            logger.info("=======================================");
            logger.info(fileContents);
            logger.info("=======================================");

			return fileContents;
		}
		catch (Exception e) {
			logger.error(e.getMessage(), e);
			throw e;
		}
	}
	
	public String getMailTemplate(String templateFileNm, String subject, String contents, String companyNm, String destUrl) throws Exception {
		try {
			String domainNm  = PropertiesManager.getString("eversrm.system.domainName");
			String contextNm = PropertiesManager.getString("eversrm.system.contextName");
			String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
			String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
			
			String maintainUrl = "";
			boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
			if (sslFlag) { maintainUrl = "https://"; }
			else { maintainUrl = "http://"; }
			if ("80".equals(domainPort)) {
				maintainUrl += domainNm;
			} else {
				maintainUrl += domainNm + ":" + domainPort;
			}
			maintainUrl += contextNm;
			
			if (templateFileNm.trim().length() <= 0) {
				templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.mailSimpleTemplateFileName");
			}
			
			String fileContents = "";
			fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
			fileContents = EverString.replace(fileContents, "$SUBJECT$", subject);
			fileContents = EverString.replace(fileContents, "$CONTEXT_NM$", contextNm);
			fileContents = EverString.replace(fileContents, "$CONTENTS$", EverString.nToBr(contents));
			fileContents = EverString.replace(fileContents, "$DEST_URL$", destUrl);
			fileContents = EverString.replace(fileContents, "$COMPANY_NM$", companyNm);
			fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);

			return fileContents;
		}
		catch (Exception e) {
			logger.error(e.getMessage(), e);
			throw e;
		}
	}

}
