package com.st_ones.common.mail.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.mail.EverMailMapper;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : EverMailService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 09. 10.
 * @version 1.0
 * @see
 */

@Service(value = "everMailService")
public class EverMailService extends BaseController {

	private Logger logger = LoggerFactory.getLogger(EverMailService.class);

	final FileAttachService fileAttachService;
	final LargeTextService largeTextService;
	final EverMailMapper everMailMapper;

	protected final JavaMailSender mailSender;
	// 실시간 IF는 공통으로 처리
	private final RealtimeIF_Mapper realtimeif_mapper;

	public EverMailService(FileAttachService fileAttachService, LargeTextService largeTextService, EverMailMapper everMailMapper, JavaMailSender mailSender, RealtimeIF_Mapper realtimeif_mapper) {
		this.fileAttachService = fileAttachService;
		this.largeTextService = largeTextService;
		this.everMailMapper = everMailMapper;
		this.mailSender = mailSender;
		this.realtimeif_mapper = realtimeif_mapper;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void sendMail(Map<String, String> param) throws Exception {

		if(EverString.isNotEmpty(param.get("DIRECT_TARGET")) ) {
			param.put("DIRECT_FLAG", "1");
		}

		Map<String,String> mailMap = everMailMapper.getReceiverMailAddress(param);

		System.out.println("====>SEND_USER_ID: " + param.get("SEND_USER_ID") + ", SEND_USER_NM: " + param.get("SEND_USER_NM") + ", SEND_EMAIL: " + param.get("SEND_EMAIL"));
		System.out.println("====>RECV_USER_ID: " + param.get("RECV_USER_ID") + ", RECV_USER_NM: " + param.get("RECV_USER_NM") + ", RECV_EMAIL: " + param.get("RECV_EMAIL"));

		if (mailMap != null) {

			param.putAll(mailMap);
			param.put("SEND_EMAIL", PropertiesManager.getString("eversrm.system.mailSenderMail"));
			param.put("SEND_USER_NM", PropertiesManager.getString("eversrm.system.mailSenderName"));

			if("test".equals(PropertiesManager.getString("eversrm.system.mailSendType"))) {
				param.put("RECV_EMAIL", PropertiesManager.getString("eversrm.system.mail.test.receive.mail"));
			}

			goSendMail(param);
		}
	}
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public synchronized String goSendMail(Map<String, String> param) {

		String succYn = "0";
		try {
			/*if(PropertiesManager.getBoolean("eversrm.system.mailSendFlag")) {
				MimeMessage msg = mailSender.createMimeMessage();
				MimeMessageHelper helper = new MimeMessageHelper(msg, false);
				helper.setSubject(param.get("SUBJECT"));

				helper.setFrom(new InternetAddress(param.get("SEND_EMAIL"), param.get("SEND_USER_NM"), "UTF-8"));
				helper.setTo(new InternetAddress(param.get("RECV_EMAIL"), param.get("RECV_USER_NM"), "UTF-8"));
				helper.setText(param.get("CONTENTS_TEMPLATE"), true);

				mailSender.send(msg);
			}*/
			succYn = "1";
		} catch (Exception mex) {
			mex.printStackTrace();
			succYn = "0";
			logger.error(mex.getMessage(), mex);
		} finally {
			try {
				param.put("SEND_FLAG", succYn);
				insertMailHistory(param);
			} catch (Exception e) { }
		}
		return succYn;
	}

	@Transactional(propagation = Propagation.NESTED, rollbackFor = Exception.class)
	public void insertMailHistory(Map<String, String> param) throws Exception {
		
		String localServerYN= PropertiesManager.getString("eversrm.system.localserver"); 		// 로컬서버 여부
		String devServerYN  = PropertiesManager.getString("eversrm.system.developmentFlag"); 	// 개발모드 여부
		
		/**
		 * 2023.01.18 : LargeText 등록시 DB Lock으로 인해 주석처리
		String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
		String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");

		String siteUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { siteUrl = "https://"; }
		else { siteUrl = "http://"; }
		if ("80".equals(domainPort)) {
			siteUrl += domainNm;
		} else {
			siteUrl += domainNm + ":" + domainPort;
		}
		siteUrl += contextNm;

		// MAIL TOP
		String mailTop = EverFile.fileReadByOffsetByEncoding(templatePath + "mail_top.template", "UTF-8");
		mailTop	= EverString.replace(mailTop, "$siteUrl$", siteUrl);
		mailTop = EverString.replace(mailTop, "$TITLE$", param.get("SUBJECT"));

		// MAIL BOTTOM
		String mailBottom = EverFile.fileReadByOffsetByEncoding(templatePath + "mail_bottom.template", "UTF-8");
		mailBottom = EverString.replace(mailBottom, "$siteUrl$", siteUrl);

		// MAIL CONTENTS
		String mailContents = mailTop + param.get("CONTENTS_TEMPLATE") + mailBottom;

		String textNum = largeTextService.saveMailContents(mailContents);
		param.put("MAILTEXTNUM", textNum);*/
		param.put("SEND_FLAG", ((EverString.nullToEmptyString(localServerYN).equals("true") || EverString.nullToEmptyString(devServerYN).equals("true")) ? "0" : "1"));
		
		if(PropertiesManager.getBoolean("eversrm.system.mailSendFlag")) {
			String mailSq = everMailMapper.getMailSq(param);
			param.put("MAIL_SQ", mailSq);
			
			// 대명소노시즌 DGNS 실제 Mail 전송 테이블에 INSERT
			realtimeif_mapper.insertRealMail(param);
			// Mail 전송이력
			everMailMapper.doSendMail(param);
		}
	}

}
