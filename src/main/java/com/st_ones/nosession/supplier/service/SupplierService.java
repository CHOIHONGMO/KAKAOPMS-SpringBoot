package com.st_ones.nosession.supplier.service;

import com.st_ones.common.file.FileAttachMapper;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.nosession.supplier.SupplierMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
public class SupplierService extends BaseService {

    @Autowired SupplierMapper supplierMapper;
    @Autowired FileAttachMapper fileAttachMapper;
    @Autowired LargeTextService largeTextService;
    @Autowired private EverMailService everMailService;

    public Map<String, String> doIrsNumCheck(Map<String, String> param) throws Exception {
        
    	Map<String, String> rltMap = new HashMap<String, String>();
    	String userType = EverString.nullToEmptyString(param.get("USER_TYPE"));
    	if ("B".equals(userType)) {
    		rltMap = supplierMapper.doIrsNumCheckCust(param);
    	} else {
    		rltMap = supplierMapper.doIrsNumCheck(param);
    	}
    	
    	String progressCd = "";
        String rejectRmk  = "";
        String blockFlag  = "";
        String blockRmk   = "";
    	int cnt = 0;
        if(rltMap != null && rltMap.size() > 0) {
        	cnt = Integer.parseInt(String.valueOf(rltMap.get("CNT")));
            progressCd = rltMap.get("PROGRESS_CD");
            rejectRmk  = rltMap.get("REJECT_RMK");
            blockFlag  = rltMap.get("BLOCK_FLAG");
            blockRmk   = rltMap.get("BLOCK_REASON");
        }
        
        Map<String, String> rtn = new HashMap<>();
        if(cnt > 0) {
        	if("1".equals(blockFlag)) {
            	rtn.put("code", "fail");
            	rtn.put("Message", "해당 사업자번호는 하단의 사유로 인해 '종료' 되었습니다.\n\n[종료사유] " + blockRmk);
        	} else {
            	if("J".equals(progressCd)) { 		// J : 가입요청
                	rtn.put("code", "fail");
                	rtn.put("Message", "이미 '가입요청'된 사업자번호 입니다. 최종 승인 후 로그인이 가능합니다.");
            	} else if("P".equals(progressCd)) {	// P : 승인요청
                	rtn.put("code", "fail");
                	rtn.put("Message", "요청건에 대한 '평가 진행중'입니다. 최종 승인 후 로그인이 가능합니다.");
            	} else if("R".equals(progressCd)) {	// R : 승인반려
            		rtn.put("code", "success");
                	rtn.put("Message", "하단의 사유로 인해 '승인 반려' 되었습니다.\n\n[반려사유] " + rejectRmk);
            	} else if("T".equals(progressCd)) {	// T : 임시저장
                	rtn.put("code", "fail");
                	rtn.put("Message", "이미 가입이 '진행중'인 사업자번호입니다. 담당자에게 문의하세요.");
            	} else if("E".equals(progressCd)) {	// E : 승인
                	rtn.put("code", "fail");
                	rtn.put("Message", "이미 가입된 사업자번호 입니다.");
            	} else {
                	rtn.put("code", "fail");
                	rtn.put("Message", "이미 가입된 사업자번호 입니다. 담당자에게 문의하세요.");
            	}
        	}
        } else {
        	rtn.put("code", "success");
        	rtn.put("Message", "입력한 사업자번호로 회원가입을 진행하시겠습니까?");
        }

        return rtn;
    }

    public Map<String, String> doIdSearch(Map<String, String> param) throws Exception {
        Map<String, String> userInfo = null;

        if("O".equals(param.get("I_USER_TYPE"))) {			// 운영사
            userInfo = supplierMapper.operIdSearch(param);
        }
        else if("C".equals(param.get("I_USER_TYPE"))) {		// 고객사
            userInfo = supplierMapper.custIdSearch(param);
        }
        else if("S".equals(param.get("I_USER_TYPE"))) {		// 협력사
            userInfo = supplierMapper.vendorIdSearch(param);
        }
        return userInfo;
    }

    public Map<String, String> doPwInfo(Map<String, String> param) throws Exception {
        return supplierMapper.doPwInfo(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String doPwSend(Map<String, String> param) throws Exception {
        try {
            String ppdd = EverString.getRandomPassword(8); // Random 8자리
            
            // Mail Template 및 URL 가져오기
            String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
            String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.PPDD_TemplateFileName");
    		
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
            fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$USER_ID$", param.get("P_USER_ID"));
            fileContents = EverString.replace(fileContents, "$USER_NM$", param.get("P_USER_NM"));
            fileContents = EverString.replace(fileContents, "$PPDD$", ppdd);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
            fileContents = EverString.rePreventSqlInjection(fileContents);

            param.put("RECV_USER_ID", param.get("P_USER_ID"));
            param.put("RECV_USER_NM", param.get("P_USER_NM"));
            param.put("RECV_EMAIL", param.get("P_EMAIL"));
            param.put("SUBJECT", "[대명소노시즌] 요청하신 비밀번호가 도착하였습니다.");
            param.put("CONTENTS_TEMPLATE", fileContents);
            // 메일발송
            everMailService.sendMail(param);

            // 메일 전송 완료 후 패스워드 UPDATE
            param.put("PPDD", EverEncryption.getEncryptedUserPassword(ppdd));

            if(!"C".equals(param.get("USER_TYPE"))) {
                supplierMapper.doUpdateCVUR(param);
            } else {
                supplierMapper.doUpdateUSER(param);
            }

            return "success";
        } catch (Exception e) {
            return "error";
        }
    }
}