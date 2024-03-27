package com.st_ones.eversrm.eApproval.eApprovalModule.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.common.config.service.EverConfigService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.mail.web.MailTemplate;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.serverpush.reverseajax.EverAlarm;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.ApprovalException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.eApproval.EApprovalMapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.BAPM_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import com.st_ones.eversrm.eApproval.service.EndApprovalService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.net.URLEncoder;
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
 * @File Name : BAPM_Service.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Service(value = "bapm_Service")
public class BAPM_Service extends BaseService {

    @Autowired MessageService msg;
    @Autowired BAPM_Mapper bapm_Mapper;
    @Autowired EndApprovalService endApprovalService;
    @Autowired LargeTextService largeTextService;
    @Autowired EverAlarm requestAlarm;
    @Autowired EverConfigService everConfigService;
    @Autowired EApprovalMapper eApprovalMapper;
    @Autowired EApprovalService eApprovalService;

    // DGNS Group Ware I/F
    @Autowired RealtimeIF_Mapper realtimeif_mapper;

    // 메일보내기
    @Autowired private MailTemplate mt;
    @Autowired private EverMailService everMailService;

    private Logger logger = LoggerFactory.getLogger(BAPM_Service.class);

    public List<Map<String, Object>> selectPath(Map<String, String> param) throws Exception {
        return bapm_Mapper.selectPath(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String insertPath(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        String pathNo = bapm_Mapper.getPathNo(formData);

        formData.put("PATH_NUM", pathNo);
        bapm_Mapper.insertPath(formData);

        bapm_Mapper.deleteLULP(formData);
        for (Map<String, Object> gridData : gridDatas) {
            gridData.put("PATH_NUM", pathNo);
            bapm_Mapper.insertPathDetail(gridData);
        }

        return msg.getMessage("0015");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String updatePath(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        String pathNo = formData.get("PATH_NUM");

        bapm_Mapper.updatePath(formData);

        bapm_Mapper.deleteLULP(formData);
        for (Map<String, Object> gridData : gridDatas) {
            if (!gridData.get("INSERT_FLAG").toString().equals("D")) {
                gridData.put("PATH_NUM", pathNo);
                bapm_Mapper.insertPathDetail(gridData);
            }
        }

        return msg.getMessage("0016");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String deletePath(List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            bapm_Mapper.deletePathDetail(gridData);
            bapm_Mapper.deletePath(gridData);
        }

        return msg.getMessage("0017");
    }

    public List<Map<String, Object>> selectPathDetail(Map<String, String> param) throws Exception {
        return bapm_Mapper.selectPathDetail(param);
    }

    ///pathSearch
    public List<Map<String, Object>> selectPathPopup(Map<String, String> param) throws Exception {
        return bapm_Mapper.selectPathPopup(param);
    }

    //////////
    public String getMatchUserInfoByName(String userNm) throws ApprovalException, IOException {
        int count = matchUserCountByName(userNm);

        if (count != 1) {
            if (count > 1) {
                ApprovalException e = new ApprovalException("More Than 1 Result");
                e.setSelectedUserCount(count);
                throw e;
            }
            ApprovalException e = new ApprovalException("No Result");
            e.setSelectedUserCount(count);
            throw e;
        }

        Map<String, String> userInfo = getUserInfoByName(userNm);
        return new ObjectMapper().writeValueAsString(userInfo);
    }

    /**
     * userInfo by userNm
     * @param userNm
     * @return
     * @throws Exception
     */
    private Map<String, String> getUserInfoByName(String userNm) {
        HashMap<String, String> hashMap = new HashMap<String, String>();
        hashMap.put("USER_NM", userNm);
        return bapm_Mapper.getUserInfoByName(hashMap);
    }

    /**
     * userCount with name
     * @param userNm
     * @return
     * @throws Exception
     */
    private int matchUserCountByName(String userNm) {
        HashMap<String, String> hashMap = new HashMap<String, String>();
        hashMap.put("USER_NM", userNm);
        return bapm_Mapper.matchUserCountByName(hashMap);
    }

    /**
     * Request Approval Service
     * @param docInfo APP_DOC_NUM, APP_DOC_CNT, DOC_TYPE, PROCEEDING_FLAG를 설정 해야 합니다.
     * @param strApprovalFormData 공통 결재 요청 팝업으로 부터 결재 Header Data 입니다.
     * @param strApprovalGridData 공통 결재 요청 팝업으로 부터 결재 Detail Data 입니다.
     * @throws ApprovalException
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doApprovalProcess(Map<String, String> docInfo, String strApprovalFormData, String strApprovalGridData) throws Exception {
    	
    	// 해당 결재문서번호가 STOCSCTM에 존재하는지 체크
        String previousUnAcceptableStatus = previousUnacceptableStatus(docInfo);
        if (EverString.equals(previousUnAcceptableStatus, "P")) {
            throw new ApprovalException(msg.getMessageForService(this, "proceeding_item"));
        }
        
        Map<String, String> approvalHeader = new ObjectMapper().readValue(strApprovalFormData, Map.class);
        List<Map<String, String>> approvalDetails = new ObjectMapper().readValue(strApprovalGridData, List.class);
        
        docInfo.remove("ATT_FILE_NUM");
        approvalHeader.putAll(docInfo);
        
        String nextSignUserId = approvalDetails.get(0).get("SIGN_USER_ID");
        approvalHeader.put("NEXT_SIGN_USER_ID", nextSignUserId);
        String appContentsTextNum = largeTextService.saveLargeText(approvalHeader.get("CONTENTS_TEXT_NUM"), approvalHeader.get("DOC_CONTENTS"));
        approvalHeader.put("APP_CONTENTS_TEXT_NUM", appContentsTextNum);
        
        // GW 연동여부
        // 구매유형(일반구매, 시행구매)에 따라 G/W 연동여부 결정됨
        //boolean isBlossomUseFlag = PropertiesManager.getBoolean("eversrm.approval.blossom.use.flag");
        /** BLSM_STATUS
		 * 01	품의신청
		 * 02	품의저장
		 * 03	품의중
		 * 04	품의반려
		 * 10	품의완료
		 * 91	품의취소
         */
        boolean isBlossomUseFlag = false;
        if (isBlossomUseFlag) {
            approvalHeader.put("BLSM_USE_FALG",   "1");
            approvalHeader.put("BLSM_STATUS",     "01"); // 품의신청(01)
            approvalHeader.put("BLSM_APPLY_FLAG", "0");

            // G/W와 연동할 HTML 가져와서 등록하기
            // AS-IS : product_pd_report1.jsp, product_pd_report2.jsp 참고
            approvalHeader.put("BLSM_HTML", approvalHeader.get("DOC_CONTENTS"));
        }
        else {
            approvalHeader.put("BLSM_USE_FALG",   "0");
            approvalHeader.put("BLSM_STATUS",     "");
            approvalHeader.put("BLSM_APPLY_FLAG", "");
        }
        bapm_Mapper.insertSTOCSCTM(approvalHeader);

        for (Map<String, String> approvalData : approvalDetails) {
            approvalData.putAll(docInfo);
            bapm_Mapper.insertSTOCSCTP(approvalData);
        }

    	/**
    	 * 대명소노 DGNS G/W와 연동 (Package "PKG_ELCT_CONFM_IF" 참고)
    	 * 일반구매 : 내부결재, 시행구매 : G/W 연동
    	 * AS-IS : product_pd_report1.jsp, product_pd_report2.jsp 참고
    	 *
    	 * Package "PKG_ELCT_CONFM_IF"에서 GW 결재연동 테이블 "COM_ELCT_CONFM_IF"에 상태값 등록, 변경 진행함
    	 *
        if (isBlossomUseFlag) {
			var objForm = document.forms["form1"];
 			document.getElementById("xmlParam").value = "<?xml version='1.0' encoding='euc-kr'?><root>    <title>[매입/매출] " + document.form1.product_name.value+ " </title>    <approvalline></approvalline>    <htmlcontent><![CDATA["+html_string+"]]></htmlcontent></root>";
 			objForm.method = "post";
 			objForm.target = "POP";

 			// 테스트 환경
			//objForm.action = "http://devgw.dgns.com/apprCreatePost.do"
			// 실 환경
			// 연결Key값 : project_no_seq = PD000000009-1 => PE0000000091
  			objForm.action = "http://portal.daemyung.com/apprCreatePost.do"
        		+ "?formId=120135724086" // 문서종류 120017001126
		   		+ "&appKey01=" + document.form1.product_no_seq.value.substr(0,1) + 'E' + document.form1.product_no_seq.value.substr(2,9) + document.form1.product_no_seq.value.substr(12,1) // 결재번호
		   		+ "&popupYn=true"
		   		+ "&appSystem=si" // 업무구분 = si(ISN)
		   		+ "&appModule=purchase";
   			var popup = window.open('','POP','toolbar=no, location=no, directories=no, status=yes,menubar=no,scrollbars=yes,resizable=yes,width=1000,height=900,left=0,top=0');
  			popup.focus();
			objForm.submit();
        }*/
    }

    /**
     * When the document is approved or proceeded then return the status of the approval process
     * @param docInfo<br>
     * GATE_CD, APP_DOC_NUM
     * @return
     * Approved then E, Proceeding then P others null
     * @throws Exception
     */
    private String previousUnacceptableStatus(Map<String, String> docInfo) {
        List<String> signStatusHistory = bapm_Mapper.selectSTOCSCTPSignStatusHistory(docInfo);
        if (signStatusHistory.isEmpty()) {
            return null;
        }
        if (signStatusHistory.contains("P")) {
            return "P";
        }
        return null;
    }

    /**
     * 결재 마스터 조회
     * GATE_CD, APP_DOC_NUM, APP_DOC_CNT
     * @param approvalInfoKey
     * @return
     * @throws Exception
     * @throws ApprovalException
     */
    public Map<String, String> selectApprovalInfoHeader(Map<String, String> approvalInfoKey) throws Exception {

        if (!isAuthorized(approvalInfoKey)) {
            throw new ApprovalException("결재라인에 존재하지 않는 사용자입니다.");
        }

        Map<String, String> infoHeader = bapm_Mapper.selectSTOCSCTM(approvalInfoKey);
        String splitString = largeTextService.selectLargeText(infoHeader.get("CONTENTS_TEXT_NUM"));
        infoHeader.put("DOC_CONTENTS", splitString);
        return infoHeader;
    }

    public String selectMySignStatus(Map<String, String> formDataParam) {
        formDataParam.put("SIGN_PATH_SQ", bapm_Mapper.getNextSignPathSeq(formDataParam));

        return bapm_Mapper.selectMySignStatus(formDataParam);
    }

    /**
     * 결재 상세 조회
     * GATE_CD, APP_DOC_NUM, APP_DOC_CNT
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> selectApprovalInfoDetail(Map<String, String> formData) throws Exception {
        return bapm_Mapper.selectSTOCSCTP(formData);
    }

    public boolean isAuthorized(Map<String, String> approvalInfoKey) throws Exception {
        int authorizedUserCount = bapm_Mapper.getAuthorizedCount(approvalInfoKey);
        return authorizedUserCount > 0;
    }

    /**
     * approve document
     * @param formData
     * @return
     * @throws Exception
     * @throws ApprovalException
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String approve(Map<String, String> formData) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();

        formData.put("SIGN_PATH_SQ", bapm_Mapper.getNextSignPathSeq(formData));

        bapm_Mapper.updateSTOCSCTP(formData);

        int nextUserCnt = bapm_Mapper.getNextSignUserCnt(formData);

        String appDocNum = formData.get("APP_DOC_NUM");
        String appDocCnt = formData.get("APP_DOC_CNT");
        Map<String, String> approvalRequestInfo = bapm_Mapper.selectSTOCSCTM(appDocNum, appDocCnt);
        Map<String, String> receiverInfo = new HashMap<String, String>();

        if (nextUserCnt > 0) {

            List<Map<String, Object>> nextUserInfo = bapm_Mapper.getNextSignUserId(formData);
            String nextUserId = "";
            for(int i = 0; i < nextUserInfo.size(); i++) {
                nextUserId = String.valueOf(nextUserInfo.get(i).get("SIGN_USER_ID"));
                formData.put("NEXT_SIGN_USER_ID", nextUserId);
                break;
            }

            bapm_Mapper.setNextUser(formData);

            String receiverUserId = nextUserId;
            String refModuleCode = "AP";

            /* 다음 결재자한테 메일 보내기 */
            Map<String, String> param = new HashMap<String, String>();
            param.put("APP_DOC_NUM", appDocNum);
            param.put("APP_DOC_CNT", appDocCnt);
            receiverInfo = eApprovalMapper.getReceiverInfo(param);
            eApprovalService.eApprovalMailSend("P", receiverInfo, appDocNum, appDocCnt);

            // sms
			/* if ("true".equals(everConfigService.getBuyerConfig(userInfo.getGateCd(), userInfo.getCompanyCd(), "eversrm.system.sms.eApprovalNext.flag"))) {
				String smsContents = msg.getMessageForService(this, "nextApproverSendSMSContents");
				smsContents = String.format(smsContents, appDocNum);
				endApprovalService.sendSMS(receiverUserId, refModuleCode, smsContents);
			} */
            return msg.getMessageForService(this, "approved");
        }

        /**
         * 결재승인완료 메일 보내기 [상신자, 참조자]
         */
        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", appDocNum);
        param.put("APP_DOC_CNT", appDocCnt);
        receiverInfo = eApprovalMapper.getEndReceiverInfo(param);
        eApprovalMailSend("E", receiverInfo, appDocNum, appDocCnt);

        param.put("USER_TYPE", userInfo.getUserType());
        List<Map<String, String>> ccInfos = eApprovalMapper.getCcReceiverInfo(param);
        for(Map<String, String> ccInfo : ccInfos) {
            eApprovalMailSend("CC", ccInfo, appDocNum, appDocCnt);
        }

        // end Approval Process
        bapm_Mapper.updateSTOCSCTM(formData);
        String docType = formData.get("DOC_TYPE");
        return endApprovalService.doAfterApprove(docType, appDocNum, appDocCnt);
    }

    /**
     * 결재 반려, 사용자 서비스 콜, 다음 결재자 승인 정보 NULL
     * SIGN_STATUS, DOC_TYPE, APP_DOC_NUM, APP_DOC_CNT
     * @param formData
     * @return
     * @throws Exception
     * @throws ApprovalException
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String reject(Map<String, String> formData) throws Exception {
        formData.put("SIGN_PATH_SQ", bapm_Mapper.getNextSignPathSeq(formData));

        bapm_Mapper.updateSTOCSCTP(formData);
        bapm_Mapper.updateSTOCSCTM(formData);

        String docType   = formData.get("DOC_TYPE");
        String appDocNum = formData.get("APP_DOC_NUM");
        String appDocCnt = formData.get("APP_DOC_CNT");

        /**
         * 결재 반려 메일 보내기
         */
        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", appDocNum);
        param.put("APP_DOC_CNT", appDocCnt);
        Map<String, String> receiverInfo = eApprovalMapper.getEndReceiverInfo(param);
        eApprovalMailSend("R", receiverInfo, appDocNum, appDocCnt);

        return endApprovalService.doAfterReject(docType, appDocNum, appDocCnt);
    }

    public List<Map<String, Object>> getMyPath() {
        return bapm_Mapper.getMyPath(new HashMap<String, String>());
    }

    public List<Map<String, String>> selectLULP(HashMap<String, String> approvalPathKey) {
        return bapm_Mapper.selectLULP(approvalPathKey);
    }

    /**
     * cancelApprovalProcess
     * @param map <br/>
     * SIGN_STATUS, GATE_CD, APP_DOC_NUM, APP_DOC_CNT
     * @return
     * @throws Exception
     * @throws ApprovalException
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelApprovalProcess(Map<String, String> map) throws Exception {
        checkCancellable(map);
        cancelApproval(map);
        String nextSignPathSeq = bapm_Mapper.getNextSignPathSeq(map);
        map.put("SIGN_PATH_SEQ", nextSignPathSeq);
        return msg.getMessageForService(this, "cancel");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void documentRead(Map<String, String> param) throws Exception {

        String updateFlag = EverString.nullToEmptyString(bapm_Mapper.getUpdateFlag(param));
        if(updateFlag.equals("Y")) {
            bapm_Mapper.updateReadDate(param);
        }
    }

    /**
     * @param map<br>
     * SIGN_STATUS, GATE_CD, APP_DOC_NUM, APP_DOC_CNT
     * @throws Exception
     * @throws ApprovalException
     */
    private void checkCancellable(Map<String, String> map) throws Exception {
        Map<String, String> approvalRequestInfo = bapm_Mapper.selectSTOCSCTM(map.get("APP_DOC_NUM"), map.get("APP_DOC_CNT"));

        if (!EverString.equals(approvalRequestInfo.get("SIGN_STATUS"), "P")) {
            throw new ApprovalException(msg.getMessageForService(this, "cannotCancel_01"));
        }
    }

    /**
     * 결재 모듈 취소 후 사용자 모듈 결재 취소 서비스 CALL
     * 승인 반려자가 없는 경우 가능
     * @param map<br>
     * DOC_TYPE, APP_DOC_NUM, DOC_TYPE
     * @return Message from user Method
     * @throws Exception
     * @throws ApprovalException
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelApproval(Map<String, String> map) throws Exception {
        map.put("SIGN_STATUS", "C");

        bapm_Mapper.updateSTOCSCTM(map);

        String docType   = map.get("DOC_TYPE");
        String appDocNum = map.get("APP_DOC_NUM");
        String appDocCnt = map.get("APP_DOC_CNT");

        return endApprovalService.doAfterCancel(docType, appDocNum, appDocCnt);
    }

    /**
     * @param approvalInfoKey<br>
     * GATE_CD, APP_DOC_NUM
     * @return
     * @throws Exception
     * @throws ApprovalException
     */
    public Map<String, String> selectPreviousInfoForm(Map<String, String> approvalInfoKey) throws Exception {
        Map<String, String> selectSTOCSCTM = bapm_Mapper.selectSTOCSCTM(approvalInfoKey);
        if (selectSTOCSCTM == null) {
            return null;
        }
        String appDocCnt = bapm_Mapper.getCurrentDocCount(approvalInfoKey);
        approvalInfoKey.put("APP_DOC_CNT", appDocCnt);
        if (!isAuthorized(approvalInfoKey)) {
            throw new ApprovalException("Un Authorized Access");
        }
        return selectSTOCSCTM;
    }

    /**
     * @param approvalInfoKey
     * GATE_CD, APP_DOC_NUM
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> selectPreviousInfoGrid(Map<String, String> approvalInfoKey) throws Exception {
        String appDocCnt = bapm_Mapper.getCurrentDocCount(approvalInfoKey);
        approvalInfoKey.put("APP_DOC_CNT", appDocCnt);
        return bapm_Mapper.selectSTOCSCTP(approvalInfoKey);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void deleteSCTM(Map<String, String> appDocNum) {
        bapm_Mapper.deleteSCTM(appDocNum);
        bapm_Mapper.deleteSCTP(appDocNum);
    }

    /**
     * APPROVAL_TemplateFileName : 결재승인 및 참조 요청
     * @param approvalNum
     * @param appDocCnt
     */
    private void eApprovalMailSend(String approvalStatus, Map<String, String> receiverInfo, String approvalNum, String appDocCnt) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = "";

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

		// 결재자를 위한 자동로그인 (현재 미구현)
		String ssoLoginUrl = maintainUrl;

        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", approvalNum);
        param.put("APP_DOC_CNT", appDocCnt);

        // 결재자 목록 가져오기
        List<Map<String, String>> pathList = eApprovalMapper.getSignPathList(param);

        String appSubject = "";
        if(pathList.size() > 0) {
            appSubject = EverString.nullToEmptyString(pathList.get(0).get("SUBJECT"));
        }

        String fileContents = "";
        if(approvalStatus.equals("P")) {
            templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.APPROVAL_TemplateFileName");
            fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$TITLE$", receiverInfo.get("RECV_USER_NM") + " 님. 결재문서가 도착하였습니다.");
            fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "시스템에 로그인 하시어 해당 문건 검토 후 결재 승인 바랍니다.");

            // 결재요청 메일 발송시 수신자가 '시스템 바로가기' 버튼을 클릭하여 바로 결재할 수 있도록 URL을 변경한다.
            String key = "aes256-test-key!!";
            String appUserId = receiverInfo.get("RECV_USER_ID");
            String appDocNumEnc = URLEncoder.encode(EverEncryption.encrypt(key, approvalNum), "UTF-8");
            String appDocCntEnc = URLEncoder.encode(EverEncryption.encrypt(key, appDocCnt), "UTF-8");
            String docTypeEnc = URLEncoder.encode(EverEncryption.encrypt(key, EverString.nullToEmptyString(receiverInfo.get("DOC_TYPE"))), "UTF-8");

            ssoLoginUrl = ssoLoginUrl + "/ssoLogin.so?userId=" + appUserId + "&appDocNum=" + appDocNumEnc + "&appDocCnt=" + appDocCntEnc + "&docType=" + docTypeEnc;
        }
        else if(approvalStatus.equals("E")) {
            templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.END_TemplateFileName");
            fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$TITLE$", receiverInfo.get("RECV_USER_NM") + " 님. 상신하신 결재문서가 승인 처리 되었습니다.");
            fileContents = EverString.replace(fileContents, "$SIGN_STATUS$", "승인");
            fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "상신하신 결재문서가 승인 처리 되었습니다. 시스템에 로그인 하시어 해당 문건을 확인 바랍니다.");
        }
        else if(approvalStatus.equals("R")) {
            templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.END_TemplateFileName");
            fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$TITLE$", receiverInfo.get("RECV_USER_NM") + " 님. 상신하신 결재문서가 반려 처리 되었습니다.");
            fileContents = EverString.replace(fileContents, "$SIGN_STATUS$", "반려");
            fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "상신하신 결재문서가 반려 처리 되었습니다. 시스템에 로그인 하시어 해당 문건을 확인 바랍니다.");
        }
        else if(approvalStatus.equals("CC")) {
            templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.APPROVAL_TemplateFileName");
            fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$TITLE$", receiverInfo.get("RECV_USER_NM") + " 님. 결재문서[참조]가 도착하였습니다.");
            fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "결재문서[참조]가 도착하였습니다. 시스템에 로그인 하시어 해당 문건을 확인 바랍니다.");
        }
        fileContents = EverString.replace(fileContents, "$APP_DOC_NUM$", approvalNum);
        fileContents = EverString.replace(fileContents, "$APP_SUBJECT$", appSubject);
        fileContents = EverString.replace(fileContents, "$SIGN_USER_NM$", receiverInfo.get("RECV_USER_NM"));

        String tblBody = "<tbody>";
        String enter = "\n";
        if(pathList.size() > 0) {
            for (Map<String, String> pathData : pathList) {
                String tblRow = "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(pathData.get("USER_NM")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(pathData.get("DEPT_NM")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(pathData.get("DUTY_NM")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(pathData.get("SIGN_REQ_TYPE")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(pathData.get("SIGN_STATUS")) + "</th>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(pathData.get("SIGN_DATE")) + "</th>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }

        fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
        fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
        fileContents = EverString.replace(fileContents, "$ssoLoginUrl$", ssoLoginUrl);
        fileContents = EverString.rePreventSqlInjection(fileContents);

        if(receiverInfo.get("RECV_EMAIL") != null && !"".equals(receiverInfo.get("RECV_EMAIL"))) {
            Map<String, String> mdata = new HashMap<String, String>();
            mdata.put("SUBJECT", (approvalStatus.equals("P") ? "[대명소노시즌] " + receiverInfo.get("RECV_USER_NM") + " 님. 결재문서가 도착하였습니다." : (approvalStatus.equals("E") ? "[대명소노시즌] " + receiverInfo.get("RECV_USER_NM") + " 님. 상신하신 결재문서가 승인 처리 되었습니다." : (approvalStatus.equals("R") ? "[니즈풀] " + receiverInfo.get("RECV_USER_NM") + " 님. 상신하신 결재문서가 반려 처리 되었습니다." : "[니즈풀] " + receiverInfo.get("RECV_USER_NM") + " 님. 결재문서[참조]가 도착하였습니다."))));
            mdata.put("CONTENTS_TEMPLATE", fileContents);
            mdata.put("SEND_EMAIL", receiverInfo.get("SEND_EMAIL"));
            mdata.put("SEND_USER_NM", ((approvalStatus.equals("E") || approvalStatus.equals("R")) ? "" : receiverInfo.get("SEND_USER_NM")));
            mdata.put("SEND_USER_ID", ((approvalStatus.equals("E") || approvalStatus.equals("R")) ? "SYSTEM" : receiverInfo.get("SEND_USER_ID")));
            mdata.put("RECV_EMAIL", receiverInfo.get("RECV_EMAIL"));
            mdata.put("RECV_USER_NM", receiverInfo.get("RECV_USER_NM"));
            mdata.put("RECV_USER_ID", receiverInfo.get("RECV_USER_ID"));
            mdata.put("REF_NUM", approvalNum);
            mdata.put("REF_MODULE_CD","APP"); // 참조모듈
            // 메일전송.
            everMailService.sendMail(mdata);
            mdata.clear();
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bapp053_doSave(Map<String, String> param, List<Map<String, Object>> grid) throws Exception {
        bapm_Mapper.bapp053_deleteSCTP(param);

        for(Map<String, Object> data : grid) {
            if("".equals(data.get("SIGN_DATE")) || data.get("SIGN_DATE") == null) {
                data.putAll(param);

                bapm_Mapper.bapp053_insertSCTP(data);
            }
        }
    }

    public void updateBeforGwSTOCSCTM(Map<String, String> param) {
    	bapm_Mapper.updateBeforGwSTOCSCTM(param);
    }

    public void insertSTOCSCTM(Map<String, String> param) {
    	bapm_Mapper.insertSTOCSCTM(param);
    }

    public int elctRequiedCheck(Map<String, String> param) {
    	return bapm_Mapper.elctRequiedCheck(param);
    }


}