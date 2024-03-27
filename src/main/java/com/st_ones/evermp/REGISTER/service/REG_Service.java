package com.st_ones.evermp.REGISTER.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.evermp.BS01.BS0101_Mapper;
import com.st_ones.evermp.BS03.BS0301_Mapper;
import com.st_ones.evermp.REGISTER.REG_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

/**
 * The type REG _ service.
 */
@Service(value = "REG_Service")
public class REG_Service {

	@Autowired REG_Mapper reg_mapper;
    @Autowired MessageService msg;
    @Autowired DocNumService docNumService;
    @Autowired BS0301_Mapper bs0301Mapper;
    @Autowired EverMailService everMailService;

    @Autowired
    private BS0101_Mapper bs0101Mapper;

    public int userIdCheck(Map<String, String> param) throws Exception {
        return reg_mapper.userIdCheck(param);
    }

    /**
     * 공급사 회원가입
     * @param param
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doSave(Map<String, String> param) throws Exception {

        Map<String, Object> formData = new HashMap<String, Object>(param);

        String vendorCd = EverString.nullToEmptyString(formData.get("VENDOR_CD"));
        if ( "".equals(vendorCd) ) {
        	vendorCd = docNumService.getDocNumber("VENDOR");
        }
        formData.put("VENDOR_CD", vendorCd);
        formData.put("PROGRESS_CD","J");    //J  : 가입요청

//        formData.put("YEAR"          , formData.get("XXXXXXXX")); //직접입력 기준년도
        formData.put("INS_AMT"       , formData.get("SALES_AMT")); //직접입력 매출액
        formData.put("OPERATION"     , formData.get("SALES_PROF_AMT")); //직접입력 영업이익
        formData.put("PROFIT"        , formData.get("ORI_SALES_AMT")); //직접입력 단기순이익
        formData.put("CAPITAL"       , formData.get("TOT_FUND_AMT")); //직접입력 자본총계
        formData.put("DEBT_TOT"      , formData.get("TOT_LIAB_AMT")); //직접입력 부채총계
        formData.put("SALES_PROFIT"  , formData.get("PROFIT_RATIO")); //직접입력 영업이익율
        formData.put("NET_PROFIT"    , formData.get("ORI_SALES_AMT")); //직접입력 단기순이익율
        formData.put("DEBT_RATIO"    , formData.get("DEBT_RATIO")); //직접입력 부채비율
        //formData.put("MOVE"          , formData.get("XXXXXXXX")); //직접입력 연동구분

        if("D".equals(formData.get("EVIDENCE_TYPE"))) {
        	formData.put("EVA_NAME","NICE평가정보");
        } else if("A".equals(formData.get("EVIDENCE_TYPE"))) {
        	formData.put("EVA_NAME","한국신용정보");
        } else if("B".equals(formData.get("EVIDENCE_TYPE"))) {
        	formData.put("EVA_NAME","한국신용평가");
        } else if("C".equals(formData.get("EVIDENCE_TYPE"))) {
        	formData.put("EVA_NAME","기업신용정보");
        } else if("E".equals(formData.get("EVIDENCE_TYPE"))) {
        	formData.put("EVA_NAME","기타");
        } else {
        	formData.put("EVA_NAME","");
        }


//        formData.put("EVA_NAME"      , formData.get("XXXXXXXX")); //직접입력 평가사명
//        formData.put("EVA1"          , formData.get("XXXXXXXX")); //직접입력 신용평가등급
//        formData.put("EVA2"          , formData.get("XXXXXXXX")); //직접입력 현금흐름등급


        //----- 공급회사 등록/수정 -----//
        bs0301Mapper.bs03002_doMergeVendor(formData);

        //----- 공급사 납품가능지역(checkBox) 저장 -----//
        String regionCd = EverString.nullToEmptyString(formData.get("REGION_CD"));
        if (!regionCd.equals("")) {
            String[] regionCdArray = regionCd.split(",");
            for (int i = 0; i < regionCdArray.length; i++) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("VENDOR_CD", vendorCd);
                map.put("REGION_CD", regionCdArray[i]);
                bs0301Mapper.bs03002_doMergeVNRG(map);
            }
        }

        //----- 취급분야(S/G) -----//
        String sgNum = EverString.nullToEmptyString(formData.get("SG_NUM"));
        if (!sgNum.equals("")) {
            String[] sgNumArray = sgNum.split(",");
            for (int i = 0; i < sgNumArray.length; i++) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("VENDOR_CD", vendorCd);
                map.put("SG_NUM", sgNumArray[i]);
                bs0301Mapper.bs03002_doMergeSGVN(map);
            }
        }

        //----- 재무사항 VNFI(1건) : INSERT -----//
        //bs0301Mapper.bs03002_doDeleteVNFI(formData);
        //bs0301Mapper.bs03002_doInsertVNFI(formData);

        //----- 사용자(관리자)(1건) 저장 -----//
        formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(String.valueOf(formData.get("PPDD"))));
        //사용자 처음 등록시 프로파일 등록
        formData.put("AUTH_CD", "PF0132");
        bs0301Mapper.bs03002_doDeleteUser_USAP(formData);
        bs0301Mapper.bs03002_doInsertUser_USAP(formData);

        formData.put("USER_PROGRESS_CD", "P");
        formData.put("MNG_YN", "1"); // 관리자.
        bs0301Mapper.bs03002_doMergeUser_CVUR(formData);

        //----- 최초등록 이력테이블에저장 -----//
        formData.put("CH_REASON", "신규등록");
        bs0301Mapper.bs03002_doInsert_VNGH(formData);

        /**
         * 2022.12.22 공급사 등록시 메일발송 제외 : WHY?
        //공급사 등록신청시 EMAIL 전송------------------------------------------------------------------------
        //수신자정보 가져오기 : 고객 및 공급사 담당자(B100)
        param.put("CTRL_CD", "B100");
        param.put("BUYER_CD",PropertiesManager.getString("eversrm.default.company.code"));

        List<Map<String, Object>> reciverLists = bs0301Mapper.doSearchMailUserList(param);
        for (Map<String, Object> rec : reciverLists) {

            // Mail Template 및 URL 가져오기
            String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
            String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.VENDOR_APROVAL_TemplateFileName");

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

    		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$VENDOR_CD$", param.get("VENDOR_CD")); // 공급사번호
            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", param.get("VENDOR_NM")); // 공급사명
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            Map<String, String> sdata = new HashMap<String, String>();
            sdata.put("SUBJECT", "[대명소노시즌] 신규 공급사 등록이 요청되었습니다.(" + param.get("VENDOR_CD") + ")");
            sdata.put("CONTENTS_TEMPLATE", fileContents);
            sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rec.get("USER_ID")));
            sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rec.get("USER_NM")));
            sdata.put("RECV_EMAIL", EverString.nullToEmptyString(rec.get("EMAIL")));
            sdata.put("REF_NUM", param.get("VENDOR_CD"));
            // 메일전송.
            everMailService.sendMail(sdata);
            sdata.clear();
        }*/
    }

    /**
     * 고객사 회원가입
     * @param param
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doSaveB(Map<String, String> param) throws Exception {

        Map<String, Object> formData = new HashMap<String, Object>(param);

        String custCd = EverString.nullToEmptyString(formData.get("CUST"));
        if ( "".equals(custCd) ) {
        	custCd = docNumService.getDocNumber("CUST");
        }
        formData.put("CUST_CD", custCd);
        formData.put("PROGRESS_CD","J");    //J  : 가입요청

        // 고객사 등록/수정
        bs0101Mapper.bs01002_doMergeCust(formData);

        // 고객사 담당자 등록/수정(비밀번호 암호화)
        String password = EverString.nullToEmptyString(formData.get("PASSWORD"));
        if( !"".equals(password) ) {
            formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(password));
        }
        bs0101Mapper.bs01002_doMergeCVUR(formData);

        // 고객사 기본 청구지 관리 등록
        formData.put("PLANT_CD", "001");
        formData.put("CUBL_NM", formData.get("CUST_NM"));
        bs0101Mapper.bs01002_doMergeCUBL(formData);
        
        /**
         * 2022.12.22 고객사 등록시 메일발송 제외 : WHY?
        //고객사 등록신청시 EMAIL 전송------------------------------------------------------------------------
        //수신자정보 가져오기 : 고객 및 공급사 담당자(B100)
        param.put("CTRL_CD", "B100");
        param.put("BUYER_CD",PropertiesManager.getString("eversrm.default.company.code"));

        List<Map<String, Object>> reciverLists = bs0301Mapper.doSearchMailUserList(param);
        for (Map<String, Object> rec : reciverLists) {

            // Mail Template 및 URL 가져오기
            String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
            String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.VENDOR_APROVAL_TemplateFileName");

            String domainNm = PropertiesManager.getString("eversrm.system.domainName");
            String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
            String contextNm = PropertiesManager.getString("eversrm.system.contextName");
            
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

            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$VENDOR_CD$", param.get("CUST_CD")); // 고객사코드
            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", param.get("CUST_NM")); // 고객사명
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            Map<String, String> sdata = new HashMap<String, String>();
            sdata.put("SUBJECT", "[대명소노시즌] 신규 고객사 등록이 요청되었습니다.(" + param.get("CUST_CD") + ")");
            sdata.put("CONTENTS_TEMPLATE", fileContents);
            sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rec.get("USER_ID")));
            sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rec.get("USER_NM")));
            sdata.put("RECV_EMAIL", EverString.nullToEmptyString(rec.get("EMAIL")));
            sdata.put("REF_NUM", param.get("CUST_CD"));
            // 메일전송.
            everMailService.sendMail(sdata);
            sdata.clear();
        }*/
    }
}
