package com.st_ones.evermp.vendor.cont.service;

import com.ktnet.license.LicenseVerifyUtil;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.mail.web.MailTemplate;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.ContStringUtil;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.everf.kica_sp.SendServlet;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cont.CT0300Mapper;
import com.st_ones.evermp.buyer.cont.service.makeHtmlService;
import com.st_ones.evermp.vendor.cont.CT0600Mapper;
import jakarta.servlet.ServletException;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import tradesign.crypto.cert.validator.ExtendedPKIXParameters;
import tradesign.crypto.cert.validator.PKIXCertPath;
import tradesign.crypto.provider.JeTS;
import tradesign.pki.pkix.SignedData;
import tradesign.pki.pkix.X509CRL;
import tradesign.pki.pkix.X509Certificate;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.cert.CertPathValidator;
import java.security.cert.PKIXCertPathValidatorResult;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value="CT0600Service")
public class CT0600Service {
    @Autowired  private CT0600Mapper ct0600mapper;
    @Autowired  private CT0300Mapper ct0300mapper;
	@Autowired private MessageService messageService;
    @Autowired private EverMailService everMailService;
    @Autowired private MailTemplate mailTemplate;
    @Autowired private SendServlet sendServlet;


    @Autowired private makeHtmlService makehtmlservice;
    @Autowired MessageService msg;
    /**
     * 계약서 현황 조회
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> doSearchContractProgressStatus(Map<String, String> param) {
		return ct0600mapper.doSearchContractProgressStatus(param);
	}



    /**
     * 계약서 정보
     * @param req
     * @param resp
     * @throws Exception
     */
	public void secm030_getContractInfo(EverHttpRequest req, EverHttpResponse resp) {

		String contNum = req.getParameter("contNum");
		String contCnt = req.getParameter("contCnt");

		Map<String, String> formData = req.getFormData();

		/* 계약서 키값이 존재하냐 안하냐에 따라 insert, update를 구분합니다. */
		if(StringUtils.isNotEmpty(contNum) && StringUtils.isNotEmpty(contCnt)) {

			/* 키값이 존재하면 데이터를 조회만 합니다. */
			formData.put("CONT_NUM", contNum);
			formData.put("CONT_CNT", contCnt);
			Map<String, String> contInfo = ct0300mapper.getContractInformation(formData);
			// String contractFormContents = largeTextService.selectLargeText(contInfo.get("CONTRACT_TEXT_NUM"));
			String contractFormContents = StringUtils.defaultIfEmpty(contInfo.get("CONTRACT_TEXT"), "");

			// HTML 서식 제거한 계약폼(전자서명용)
			String signContractFormContents = ContStringUtil.getHtmlContents(contractFormContents.replaceAll("&lt;", "<").replaceAll("&gt;", ">"), true);
			contInfo.put("formContents", signContractFormContents);

			// Number Formatting
            contInfo.put("CONT_AMT", EverMath.EverNumberType(String.valueOf(contInfo.get("CONT_AMT")), "###,###"));
            contInfo.put("DELAY_DENO_RATE_STR", EverMath.EverNumberType(String.valueOf(contInfo.get("DELAY_DENO_RATE_STR")), "###,###"));
            contInfo.put("DELAY_NUME_RATE_STR", EverMath.EverNumberType(String.valueOf(contInfo.get("DELAY_NUME_RATE_STR")), "###,###.##"));
            contInfo.put("CONT_GUAR_PERCENT", EverMath.EverNumberType(String.valueOf(contInfo.get("CONT_GUAR_PERCENT")), "###,###"));
            contInfo.put("CONT_GUAR_AMT", EverMath.EverNumberType(String.valueOf(contInfo.get("CONT_GUAR_AMT")), "###,###"));
            contInfo.put("ADV_GUAR_PERCENT", EverMath.EverNumberType(String.valueOf(contInfo.get("ADV_GUAR_PERCENT")), "###,###"));
            contInfo.put("ADV_GUAR_AMT", EverMath.EverNumberType(String.valueOf(contInfo.get("ADV_GUAR_AMT")), "###,###"));
            contInfo.put("WARR_GUAR_PERCENT", EverMath.EverNumberType(String.valueOf(contInfo.get("WARR_GUAR_PERCENT")), "###,###"));
            contInfo.put("WARR_GUAR_AMT", EverMath.EverNumberType(String.valueOf(contInfo.get("WARR_GUAR_AMT")), "###,###"));

			formData.putAll(contInfo);
		}

		req.setAttribute("form", formData);
	}

	public List<Map<String, Object>> secm030_doSearchSubForm(Map<String, String> param) {

		param.put("CONT_NUM", param.get("contNum"));
		param.put("CONT_CNT", param.get("contCnt"));
		List<Map<String, Object>> additionalFormList = ct0300mapper.doSearchAdditionalForm(param);

		for (Map<String, Object> map : additionalFormList) {
			// String formTextNum = String.valueOf(map.get("CONTRACT_TEXT_NUM")); // Contract form no.
			// String contents = largeTextService.selectLargeText(formTextNum);
			String contents = (String)map.get("CONTRACT_TEXT");

			contents = ContStringUtil.getHtmlContents(contents, true);

			map.put("ADDITIONAL_CONTENTS", contents);
		}
		return additionalFormList;
	}

    public List<Map<String, Object>> ecob0050_doSearchSupAttachFileInfo(Map<String, String> param) {
        return ct0600mapper.ecob0050_doSearchSupAttachFileInfo(param);
    }

    public List<Map<String, Object>> ecob0050_doSearchPayInfo(Map<String, String> param) {
        return ct0600mapper.ecob0050_doSearchPayInfo(param);
    }

    /**
     * 주계약서, 첨부서식 등을 DB에서 조회한 값으로 전자서명하기 위해 조회 (클라이언트에서 임의로 변경할 수도 있으므로)
     * @param req
     * @param resp
     * @throws Exception
     */
	public void secm030_getContractsToSign(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();

		formData.put("CALL_TYPE", "S");
        makehtmlservice.doMakePDF(formData);

        String filePath = PropertiesManager.getString("html.output.path")+formData.get("CONT_NUM")+"@"+formData.get("CONT_CNT")+".html";
        File htmlFile = new File(filePath);
        Path path = Paths.get(filePath);
        System.err.println("======htmlFile.isFile()="+htmlFile.isFile());

        if(!htmlFile.isFile()) {
        	throw new Exception("Sign File Not Exists!!!");
        }
        System.err.println("======File Size="+Files.size(path));
        if(Files.size(path) == 0 ) {
        	throw new Exception("Sign File Not Exists!!!");
        }

        String filehash = EverFile.fileToHash( htmlFile );
        System.err.println("======filehash="+filehash);

        resp.setParameter("formContents", filehash);
	}

    /**
     * 협력업체 계약서 접수
     * @param req
     * @param resp
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecob0050_doConfirm(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        int check = ct0600mapper.receiptCheck(formData);
		if(check==0) {
			throw new Exception(msg.getMessageByScreenId("CT0611", "0010"));
		}
        ct0600mapper.doSupplyReceiptEcct(formData);

        return messageService.getMessageByScreenId("CT0611", "0010");
    }

    /**
     * 전자서명 데이터 저장 및 계약서 상태 변경
     * @param req
     * @param resp
     */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String ecob0050_doSaveSignedData(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> formData = req.getFormData();
        formData.put("PROGRESS_CD", Code.CONT_SUPPLY_SIGN);


        try {
            JeTS.installProvider(PropertiesManager.getString("net.tradesign.properties.path"));
        } catch(Exception e) {
            throw new Exception("서버인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
        }

        System.err.println("========================formData.get(\"SIGN_VALUE\")========="+formData.get("SIGN_VALUE"));
        SignedData sd = new SignedData(String.valueOf(formData.get("SIGN_VALUE")).getBytes("euc-kr"));

		X509Certificate[] certs = sd.verify();
		String expreason[] = null;
		String expyn[] = null;
		String expday[] = null;

		expreason  = new String[certs.length];
		expyn  = new String[certs.length];
		expday  = new String[certs.length];

		// 인증서 검증 및 DN 정보 출력
		for (int i = 0; i < certs.length; i++)
		{
			PKIXCertPath cp = new PKIXCertPath(certs[i], "PkiPath");
			ExtendedPKIXParameters cpp = new ExtendedPKIXParameters(JeTS.getTAnchorSet());
			CertPathValidator cpvi = CertPathValidator.getInstance("PKIX","JeTS");
			PKIXCertPathValidatorResult cpvr = (PKIXCertPathValidatorResult) cpvi.validate(cp, cpp);
			System.err.println("==============cpvr========="+cpvr);
			System.out.println("검증성공:" + certs[i].getSubjectDNStr());



			X509CRL crl = new X509CRL(certs[i].getCrlDp(), true);
			boolean r= crl.isRevoked(certs[i].getSerialNumber());

			if(r){
				expyn[i] = "폐지됨";
				expday[i] = crl.getRevokedDate().toString();
				if( crl.getRevokedReason() == null ) expreason[i] = "없음";
				else expreason[i] = crl.getRevokedReason();

				throw new Exception("해당인증서는 폐지되었습니다.");
			}
			else{
				expyn[i] = "유효함";
				System.err.println("=============인증서=유효함=========");
			}

		}

		// 유효기간 시작시각(Validity notBefore) 추출
		Date notBefore = certs[0].getNotBefore();
		if (notBefore != null) {
			System.out.println("유효기간 시작시각: " + notBefore);
		} else {
            throw new Exception("인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
		}
		// 유효기간 종료시각(Validity notAfter) 추출
		Date notAfter = certs[0].getNotAfter();
		if (notAfter != null) {
			System.out.println("유효기간 종료시각: " + notAfter);
		} else {
            throw new Exception("인증서 관련 문제가 발생했습니다.\n관리자에게 문의해주시기 바랍니다.");
		}
		System.err.println("===============================notBefore="+notBefore);
		System.err.println("===============================notAfter="+notAfter);
		String expireMessage = null;
		LicenseVerifyUtil.verifyTime(notBefore, notAfter);
		long validToDate = Long.parseLong(DateFormatUtils.format(DateUtils.addDays(notAfter, -14), "yyyyMMddHHmmss"));
		long validToDate2 = Long.parseLong(DateFormatUtils.format(DateUtils.addDays(notAfter, 0), "yyyyMMddHHmmss"));
		long currentDate = Long.parseLong(DateFormatUtils.format(new Date(), "yyyyMMddHHmmss"));
		if(currentDate > validToDate) {
			//expireMessage = "서버용 인증서의 만료기한이 얼마남지 않았습니다.\n(만료일자: "+notAfter+")\n관리자에게 문의해 주시기 바랍니다.";
		}

		if(currentDate > validToDate2) {
			throw new Exception("인증서 유효기간이 만료되었습니다.\n관리자에게 문의해주시기 바랍니다.");
		}


//        if(1==1) throw new Exception("=====================================================");

        // 계약서 상태 변경 & 협력업체 담당자정보 변경
        ct0600mapper.doUpdateContractStatusECCT(formData);

        // 전자서명 데이터 삭제 후, 저장
        ct0600mapper.doDeleteSignedData(formData);
        ct0600mapper.doInsertSignedData(formData);
        makehtmlservice.doMakePDF(formData);
        return messageService.getMessageByScreenId("CT0611", "0007");
    }

    /**
     * 계약서 반려처리
     * @param req
     * @param resp
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void secm030_doRejectContract(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        boolean isDevEnv = PropertiesManager.getBoolean("eversrm.system.developmentFlag");

        Map<String, String> formData = req.getFormData();
        formData.put("REJECT_RMK", req.getParameter("rejectRemark"));
        formData.put("PROGRESS_CD", Code.CONT_SUPPLY_REJECT);
        ct0600mapper.doUpdateContractStatusECCT(formData); // 계약서 상태 변경
        ct0600mapper.doMergeRejectHistoryECRJ(formData); // 반려사유 입력

    }




	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String receipt(List<Map<String,Object>> grid) throws Exception {

		for(Map<String,Object> data : grid) {
			Map<String,String> form = new HashMap<String,String>();
			form.put("CONT_NUM",String.valueOf(data.get("CONT_NUM")));
			form.put("CONT_CNT",String.valueOf(data.get("CONT_CNT")));

			int check = ct0600mapper.receiptCheck(form);
			if(check==0) {
				throw new Exception(msg.getMessageByScreenId("CT0611", "0010"));
			}

			data.put("RECEIPT_YN", "200"); //접수

			ct0600mapper.contReceiptOrReject(data);




		}
        return messageService.getMessageByScreenId("CT0610", "0004");
    }

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String reject(List<Map<String,Object>> grid) throws Exception {
		for(Map<String,Object> data : grid) {
			Map<String,String> form = new HashMap<String,String>();
			form.put("CONT_NUM",String.valueOf(data.get("CONT_NUM")));
			form.put("CONT_CNT",String.valueOf(data.get("CONT_CNT")));
			int check = ct0600mapper.receiptCheck(form);
			if(check==0) {
				throw new Exception(msg.getMessageByScreenId("CT0611", "0010"));
			}
			data.put("RECEIPT_YN", "100"); //반려
			ct0600mapper.contReceiptOrReject(data);

		}
        return messageService.getMessageByScreenId("CT0610", "0005");
    }



	public Map<String, String> getContractInformation(Map<String, String> formData) {

		return ct0600mapper.getEcInfo(formData);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateEc(Map<String, String> formData) throws Exception {
		ct0600mapper.doUpdateEc(formData);
		return msg.getMessage("0001");

	}



	public void updateSaInfo(Map<String, String> dataInfo){
		ct0600mapper.updateSaInfo(dataInfo);

	}



	public void GW_TEST(Map<String, String> contMap) {
		ct0600mapper.GW_TEST(contMap);

	}



	public void updateRecvSaInfo(Map<String, String> contMap) {
		ct0600mapper.updateRecvSaInfo(contMap);

	}







	public void SendSevlet(EverHttpRequest req, EverHttpResponse resp) throws ServletException, IOException {
		sendServlet.service(req,resp);

	}



	public int overlapRecvInfo(Map<String, String> contMap) {
		return ct0600mapper.overlapRecvInfo(contMap);
	}

}
