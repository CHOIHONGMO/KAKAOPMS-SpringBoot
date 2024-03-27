package com.st_ones.eversrm.eApproval.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.ApprovalException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.eversrm.eApproval.EApprovalMapper;
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
 * (Copyright ⓒ 2014 ST-Ones CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : EApprovalService.java
 * @author  St-Ones(st-ones@st-ones.com)
 * @date 2018. 2. 06.
 * @version 1.0
 * @see
 */
@Service(value = "eApprovalService")
public class EApprovalService extends BaseService {

	/* @formatter:off */
	@Autowired MessageService msg;
	@Autowired EApprovalMapper eApprovalMapper;
	@Autowired EndApprovalService endApprovalService;
	@Autowired LargeTextService largeTextService;
	// 메일보내기
	@Autowired private EverMailService everMailService;
	/* @formatter:on */

	public List<Map<String, Object>> selectPath(Map<String, String> param) throws Exception {
		return eApprovalMapper.selectPath(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String insertPath(Map<String, Object> formData, List<Map<String, Object>> gridDatas) throws Exception {
		String pathNo = eApprovalMapper.getPathNo(formData);

		if("1".equals(formData.get("MAIN_PATH_FLAG"))){
			eApprovalMapper.updatePathMainPathFlag(formData);
		}
		formData.put("PATH_NO", pathNo);
		eApprovalMapper.insertPath(formData);

		eApprovalMapper.deleteLULP(formData);
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PATH_NO", pathNo);
			eApprovalMapper.insertPathDetail(gridData);
		}

		return msg.getMessage("0015");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String updatePath(Map<String, Object> formData, List<Map<String, Object>> gridDatas) throws Exception {
		String pathNo = (String) formData.get("PATH_NO");

		if("1".equals(formData.get("MAIN_PATH_FLAG"))){
			eApprovalMapper.updatePathMainPathFlag(formData);
		}

		eApprovalMapper.updatePath(formData);

		eApprovalMapper.deleteLULP(formData);
		for (Map<String, Object> gridData : gridDatas) {
			if (!gridData.get("INSERT_FLAG").toString().equals("D")) {
				gridData.put("PATH_NO", pathNo);
				eApprovalMapper.insertPathDetail(gridData);
			}
		}

		return msg.getMessage("0016");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deletePath(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			eApprovalMapper.deletePathDetail(gridData);
			eApprovalMapper.deletePath(gridData);
		}

		return msg.getMessage("0017");
	}

	public List<Map<String, Object>> selectPathDetail(Map<String, String> param) throws Exception {
		return eApprovalMapper.selectPathDetail(param);
	}

	public List<Map<String, Object>> selectPathPopup(Map<String, String> param) throws Exception {
		return eApprovalMapper.selectPathPopup(param);
	}

	public String getMatchUserInfoByName(String userName) throws ApprovalException, IOException {

		int count = matchUserCountByName(userName);

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
		Map<String, String> userInfo = getUserInfoByName(userName);
		return new ObjectMapper().writeValueAsString(userInfo);
	}

	/**
	 * userInfo by userName
	 * @param userName
	 * @return
	 * @throws Exception
	 */
	private Map<String, String> getUserInfoByName(String userName) {
		HashMap<String, String> hashMap = new HashMap<String, String>();
		hashMap.put("USER_NAME", userName);
		return eApprovalMapper.getUserInfoByName(hashMap);
	}

	/**
	 * userCount with name
	 * @param userName
	 * @return
	 * @throws Exception
	 */
	private int matchUserCountByName(String userName) {
		HashMap<String, String> hashMap = new HashMap<String, String>();
		hashMap.put("USER_NAME", userName);
		return eApprovalMapper.matchUserCountByName(hashMap);
	}

	/**
	 * Request Approval Service
	 * @param docInfo APP_DOC_NO, APP_DOC_CNT, DOC_TYPE, PROCEEDING_FLAG를 설정 해야 합니다.
	 * @param strApprovalHeaderData 공통 결재 요청 팝업으로 부터 결재 Header Data 입니다.
	 * @param strApprovalDetailData 공통 결재 요청 팝업으로 부터 결재 Detail Data 입니다.
	 * @throws ApprovalException
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@AuthorityIgnore
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void doApprovalProcess(Map<String, String> docInfo, String strApprovalFormData, String strApprovalGridData) throws Exception {

		// 해당 결재문서번호가 STOCSCTM에 존재하는지 체크
		String previousUnAcceptableStatus = previousUnacceptableStatus(docInfo);
		if (EverString.equals(previousUnAcceptableStatus, "P")) {
			throw new ApprovalException("해당 문서는 현재 결재 진행중입니다.");
		}
		
		Map<String, String> approvalHeader = new ObjectMapper().readValue(strApprovalFormData, Map.class);
		List<Map<String, String>> approvalDetails = new ObjectMapper().readValue(strApprovalGridData, List.class);

		if(EverString.isNotEmpty(docInfo.get("PROCEEDING_FLAG"))){
			docInfo.put("SIGN_STATUS",docInfo.get("PROCEEDING_FLAG"));
		}

		if(EverString.isEmpty(docInfo.get("SIGN_STATUS"))){
			throw new ApprovalException("SIGN_STATUS is null");
		}
		
		docInfo.remove("ATT_FILE_NUM");
		approvalHeader.putAll(docInfo);
		
        String nextSignUserId = "";
        for(int i = 0; i < approvalDetails.size(); i++) {
		    if(!"CC".equals(approvalDetails.get(i).get("SIGN_REQ_TYPE"))) {
                nextSignUserId = approvalDetails.get(i).get("SIGN_USER_ID");
                break;
            }
        }

		approvalHeader.put("NEXT_SIGN_USER_ID", nextSignUserId);
		approvalHeader.put("CONTENTS_TEXT_NUM", largeTextService.saveLargeText(approvalHeader.get("CONTENTS_TEXT_NUM"), approvalHeader.get("DOC_CONTENTS")));

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
		eApprovalMapper.insertSTOCSCTM(approvalHeader);

		for (Map<String, String> approvalDetail : approvalDetails) {
            String positionNm = approvalDetail.get("POSITION_NM");
            String dutyNm = approvalDetail.get("DUTY_NM");
			approvalDetail.putAll(docInfo);
			approvalDetail.put("POSITION_NM",positionNm);
			approvalDetail.put("DUTY_NM",dutyNm);
			eApprovalMapper.insertSTOCSCTP(approvalDetail);
		}

		/* 결재요청 메일보내기 */
		Map<String, String> param = new HashMap<String, String>();
		param.put("APP_DOC_NUM", approvalHeader.get("APP_DOC_NUM"));
		param.put("APP_DOC_CNT", approvalHeader.get("APP_DOC_CNT"));
		Map<String, String> receiverInfo = eApprovalMapper.getReceiverInfo(param);
		eApprovalMailSend("P", receiverInfo, approvalHeader.get("APP_DOC_NUM"), approvalHeader.get("APP_DOC_CNT"));
	}

	/**
	 * When the document is approved or proceeded then return the status of the approval process
	 * @param docInfo<br>
	 * HOUSE_CODE, APP_DOC_NO
	 * @return
	 * Approved then E, Proceeding then P others null
	 * @throws Exception
	 */
	private String previousUnacceptableStatus(Map<String, String> docInfo) {
		List<String> signStatusHistory = eApprovalMapper.selectSTOCSCTPSignStatusHistory(docInfo);
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
	 * HOUSE_CODE, APP_DOC_NO, APP_DOC_CNT
	 * @param approvalInfoKey
	 * @return
	 * @throws Exception
	 * @throws ApprovalException
	 */
	public Map<String, String> selectApprovalInfoHeader(Map<String, String> approvalInfoKey) throws Exception {
		if (!isAuthorized(approvalInfoKey)) {
			throw new ApprovalException("Un Authorized Access");
		}
		return eApprovalMapper.selectSTOCSCTM(approvalInfoKey);
	}

	public String selectMySignStatus(Map<String, String> formDataParam) {
		return eApprovalMapper.selectMySignStatus(formDataParam);
	}

	/**
	 * 결재 상세 조회
	 * HOUSE_CODE, APP_DOC_NO, APP_DOC_CNT
	 * @param formData
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, String>> selectApprovalInfoDetail(Map<String, String> formData) throws Exception {
		return eApprovalMapper.selectSTOCSCTP(formData);
	}

	public boolean isAuthorized(Map<String, String> approvalInfoKey) throws Exception {
		int authorizedUserCount = eApprovalMapper.getAuthorizedCount(approvalInfoKey);
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
		String appDocNum = formData.get("APP_DOC_NUM");
		String appDocCnt = formData.get("APP_DOC_CNT");

		formData.put("SIGN_PATH_SQ", eApprovalMapper.getNextSignPathSeq(formData));
		eApprovalMapper.updateSTOCSCTP(formData);

		String nextUserId = eApprovalMapper.getNextSignUserId(formData);
		formData.put("NEXT_SIGN_USER_ID", nextUserId);

		Map<String, String> receiverInfo = new HashMap<String, String>();
		if (nextUserId != null) {
			eApprovalMapper.setNextUser(formData);

			/* 다음 결재자한테 메일 보내기 */
			Map<String, String> param = new HashMap<String, String>();
			param.put("APP_DOC_NUM", appDocNum);
			param.put("APP_DOC_CNT", appDocCnt);
			receiverInfo = eApprovalMapper.getReceiverInfo(param);
			eApprovalMailSend("P", receiverInfo, appDocNum, appDocCnt);

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

		// 참조자에게 메일 보내기
		param.put("USER_TYPE", userInfo.getUserType());
		List<Map<String, String>> ccInfos = eApprovalMapper.getCcReceiverInfo(param);
		for(Map<String, String> ccInfo : ccInfos) {
			eApprovalMailSend("CC", ccInfo, appDocNum, appDocCnt);
		}

		// end Approval Process
		eApprovalMapper.updateSTOCSCTM(formData);
		String docType = formData.get("DOC_TYPE");
		String msg = endApprovalService.doAfterApprove(docType, appDocNum, appDocCnt);
		return msg;
	}

	/**
	 * 결재 반려, 사용자 서비스 콜, 다음 결재자 승인 정보 NULL
	 * SIGN_STATUS, DOC_TYPE, APP_DOC_NO, APP_DOC_CNT
	 * @param formData
	 * @return
	 * @throws Exception
	 * @throws ApprovalException
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String reject(Map<String, String> formData) throws Exception {

		formData.put("SIGN_PATH_SQ", eApprovalMapper.getNextSignPathSeq(formData));

		eApprovalMapper.updateSTOCSCTP(formData);
		eApprovalMapper.updateSTOCSCTM(formData);

		String docType = formData.get("DOC_TYPE");
		String appDocNum = formData.get("APP_DOC_NUM");
		String appDocCnt = formData.get("APP_DOC_CNT");

		/**
		 * 반려통보 메세지 보내기.
		 */
		Map<String, String> param = new HashMap<String, String>();
		param.put("APP_DOC_NUM", appDocNum);
		param.put("APP_DOC_CNT", appDocCnt);
		Map<String, String> receiverInfo = eApprovalMapper.getEndReceiverInfo(param);
		eApprovalMailSend("R", receiverInfo, appDocNum, appDocCnt);

		// 결재 반려 이후 프로세스 수행
		String msg = endApprovalService.doAfterReject(docType, appDocNum, appDocCnt);
		return msg;
	}

	public List<Map<String, String>> getMyPath() {
		return eApprovalMapper.getMyPath(new HashMap<String, String>());
	}

	public List<Map<String, String>> selectLULP(HashMap<String, String> approvalPathKey) {
		return eApprovalMapper.selectLULP(approvalPathKey);
	}

	/**
	 * 상신취소
	 * cancelApprovalProcess
	 * @param map <br/>
	 * SIGN_STATUS, HOUSE_CODE, APP_DOC_NO, APP_DOC_CNT
	 * @return
	 * @throws Exception
	 * @throws ApprovalException
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String cancelApprovalProcess(Map<String, String> map) throws Exception {
		checkCancellable(map);
		cancelApproval(map);
		String nextSignPathSeq = eApprovalMapper.getNextSignPathSeq(map);
		map.put("SIGN_PATH_SEQ", nextSignPathSeq);
		return msg.getMessageForService(this, "cancel");
	}

	/**
	 * @param map<br>
	 * SIGN_STATUS, HOUSE_CODE, APP_DOC_NO, APP_DOC_CNT
	 * @throws Exception
	 * @throws ApprovalException
	 */
	private void checkCancellable(Map<String, String> map) throws Exception {

		if (!EverString.equals(map.get("SIGN_STATUS"), "P")) {
			throw new ApprovalException(msg.getMessageForService(this, "cannotCancel_01"));
		}
		int incorrectCount = eApprovalMapper.isCancellable(map);
		if (incorrectCount != 0) {
			throw new ApprovalException(msg.getMessageForService(this, "cannotCancel_02"));
		}
		int incorrectCountSctm = eApprovalMapper.isCancellableSctm(map);
		if (incorrectCountSctm != 0) {
			throw new ApprovalException("결재상태가 진행중인 건만 처리 가능합니다.");
		}
	}

	/**
	 * 결재 모듈 취소 후 사용자 모듈 결재 취소 서비스 CALL
	 * 승인 반려자가 없는 경우 가능
	 * @param map<br>
	 * DOC_TYPE, APP_DOC_NO, DOC_TYPE
	 * @return Message from user Method
	 * @throws Exception
	 * @throws ApprovalException
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String cancelApproval(Map<String, String> map) throws Exception {

		int incorrectCountSctm = eApprovalMapper.isCancellableSctm(map);
		if (incorrectCountSctm != 0) {
			throw new ApprovalException("결재상태가 진행중인 건만 처리 가능합니다.");
		}

		// 결재 상신 취소하기
		map.put("SIGN_STATUS", "C");
		eApprovalMapper.updateSTOCSCTM(map);

		// 상신 취소 후 프로세스 수행
		String docType = map.get("DOC_TYPE");
		String appDocNum = map.get("APP_DOC_NUM");
		String appDocCnt = map.get("APP_DOC_CNT");
		return endApprovalService.doAfterCancel(docType, appDocNum, appDocCnt);
	}

	/**
	* @param approvalInfoKey<br>
	* HOUSE_CODE, APP_DOC_NO
	* @return
	* @throws Exception
	* @throws ApprovalException
	*/
	public Map<String, String> selectPreviousInfoForm(Map<String, String> approvalInfoKey) throws Exception {
		Map<String, String> selectSTOCSCTM = eApprovalMapper.selectSTOCSCTM(approvalInfoKey);
		if (selectSTOCSCTM == null) {
			return null;
		}
		String appDocCnt = eApprovalMapper.getCurrentDocCount(approvalInfoKey);
		approvalInfoKey.put("APP_DOC_CNT", appDocCnt);
		if (!isAuthorized(approvalInfoKey)) {
			throw new ApprovalException("Un Authorized Access");
		}
		return selectSTOCSCTM;
	}

	/**
	* @param approvalInfoKey
	* HOUSE_CODE, APP_DOC_NO
	* @return
	* @throws Exception
	*/
	public List<Map<String, String>> selectPreviousInfoGrid(Map<String, String> approvalInfoKey) throws Exception {
		String appDocCnt = eApprovalMapper.getCurrentDocCount(approvalInfoKey);
		approvalInfoKey.put("APP_DOC_CNT", appDocCnt);
		return eApprovalMapper.selectSTOCSCTP(approvalInfoKey);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void deleteSCTM(Map<String, String> appDocNo) {
		eApprovalMapper.deleteSCTM(appDocNo);
		eApprovalMapper.deleteSCTP(appDocNo);
	}

	public Map<String, String> selectPathDetail1(Map<String, String> param) {
		// TODO Auto-generated method stub
		return eApprovalMapper.selectPathDetail1(param);
	}

	public List<Map<String, String>> selectMainPathDetail() throws Exception {
		// TODO Auto-generated method stub
		UserInfo baseInfo = UserInfoManager.getUserInfoImpl();
		Map<String, String> reqMap = new HashMap<String, String>();
		reqMap.put("USER_ID", baseInfo.getUserId());
		return eApprovalMapper.selectMainPathDetail(reqMap);
	}

	/**
	 * 결재 진행에 대한 메일 발송하기
	 * @param approvalStatus
	 * @param receiverInfo
	 * @param approvalNum
	 * @param appDocCnt
	 * @throws Exception
	 */
	public void eApprovalMailSend(String approvalStatus, Map<String, String> receiverInfo, String approvalNum, String appDocCnt) throws Exception {

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
			fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "시스템에 로그인 하시어 해당 문건을 확인 바랍니다.");
		}
		else if(approvalStatus.equals("R")) {
			templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.END_TemplateFileName");
			fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
			fileContents = EverString.replace(fileContents, "$TITLE$", receiverInfo.get("RECV_USER_NM") + " 님. 상신하신 결재문서가 반려 처리 되었습니다.");
			fileContents = EverString.replace(fileContents, "$SIGN_STATUS$", "반려");
			fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "시스템에 로그인 하시어 해당 문건을 확인 바랍니다.");
		}
		else if(approvalStatus.equals("CC")) {
			templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.APPROVAL_TemplateFileName");
			fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
			fileContents = EverString.replace(fileContents, "$TITLE$", receiverInfo.get("RECV_USER_NM") + " 님. 결재문서[참조]가 도착하였습니다.");
			fileContents = EverString.replace(fileContents, "$APP_CONTENTS$", "시스템에 로그인 하시어 해당 문건을 확인 바랍니다.");
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
			mdata.put("SEND_USER_ID", receiverInfo.get("SEND_USER_ID"));
			mdata.put("SEND_USER_NM", receiverInfo.get("SEND_USER_NM"));
			mdata.put("SEND_EMAIL", receiverInfo.get("SEND_EMAIL"));
			mdata.put("RECV_USER_ID", receiverInfo.get("RECV_USER_ID"));
			mdata.put("RECV_USER_NM", receiverInfo.get("RECV_USER_NM"));
			mdata.put("RECV_EMAIL", receiverInfo.get("RECV_EMAIL"));
			mdata.put("REF_NUM", approvalNum);
			mdata.put("REF_MODULE_CD", "APP"); // 참조모듈
			// 메일전송.
			everMailService.sendMail(mdata);
			mdata.clear();
		}
	}

}
