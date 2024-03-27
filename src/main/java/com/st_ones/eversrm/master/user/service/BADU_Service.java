package com.st_ones.eversrm.master.user.service;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.session.web.EverHttpSessionListener;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.eversrm.master.user.BADU_Mapper;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "badu_Service")
public class BADU_Service extends BaseService {

	@Autowired
	private MessageService msg;

	@Autowired
	private BADU_Mapper baduMapper;

	@Autowired private EverSmsService everSmsService;

	@Autowired private EverMailService everMailService;


	public List<Map<String, Object>> selectUserSearch(Map<String, String> param) throws Exception {
		return baduMapper.selectUserSearch(param);
	}

	public List<Map<String, Object>> doSearchUserSup(Map<String, String> param) throws Exception {
		return baduMapper.doSearchUserSup(param);
	}

	public List<Map<String, Object>> doSearchUserCust(Map<String, String> param) throws Exception {
		return baduMapper.doSearchUserCust(param);
	}

	public List<Map<String, Object>> doSearchUser(Map<String, String> param) throws Exception {
		EverHttpSessionListener everHttpSessionListener = EverHttpSessionListener.getInstance();
		List<Map<String, Object>> userList = baduMapper.doSearchUser(param);
		for (Map<String, Object> user : userList) {
			UserInfo loggedUserInfo = everHttpSessionListener.getLoggedUserInfo((String) user.get("USER_ID"), (String) user.get("USER_TYPE"));
			if(loggedUserInfo != null) {
				user.put("LOGIN_STATUS", "Y");
			} else {
				user.put("LOGIN_STATUS", "N");
			}
		}

		return userList;
	}
	public Map<String, Object> doGetUser(Map<String, String> formData) throws Exception {
		return baduMapper.doGetUser(formData);
	}

	public Map<String, Object> doGetUser_VNGL(Map<String, String> formData) throws Exception {
		return baduMapper.doGetUser_VNGL(formData);
	}

	public Map<String, Object> doGetEncPassword(Map<String, String> formData) throws Exception {
		return baduMapper.doGetEncPassword(formData);
	}

	@AuthorityIgnore
	public List<Map<String, Object>> doGetAcProfile(Map<String, String> param) throws Exception {
		return baduMapper.doGetAcProfile(param);
	}

	@AuthorityIgnore
	public List<Map<String, Object>> doGetAuProfile(Map<String, String> param) throws Exception {
		return baduMapper.doGetAuProfile(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doInsertUserInfo(Map<String, String> generalForm, List<Map<String, Object>> auGridDatas, List<Map<String, Object>> acGridDatas) throws Exception {

		int transCnt = -1;

		//USER_ID중복체크
		int checkCnt = baduMapper.existsUserInformation(generalForm);
		if (checkCnt > 0) {
			// Exist, required user confirm for overwrite.
			return "confirm";
		}
		// not Exist, do Insert.
		//STOCUSER INSERT

		generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(generalForm.get("PASSWORD")));

		transCnt = baduMapper.createUserInformation(generalForm);
		if (transCnt < 1) {
			throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
		}
		String userId = generalForm.get("USER_ID");

		baduMapper.doDeleteUSAP(generalForm);
		baduMapper.doDeleteUSAC(generalForm);

		// Insert User Auth Code
		doSaveAuth(userId, auGridDatas);
		// Insert User Action Code
		doSaveActionProfile(userId, acGridDatas);

		//Basic 직무 insert
		baduMapper.createBACP(generalForm);

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doInsertUserInfo_VNGL(Map<String, String> generalForm, List<Map<String, Object>> auGridDatas) throws Exception {

		int transCnt = -1;

		//USER_ID중복체크
		int checkCnt = baduMapper.existsUserInformation_VNGL(generalForm);

		if (checkCnt > 0) {
			// Exist, required user confirm for overwrite.
			return "confirm";
		}
		// not Exist, do Insert.

		//STOCUSER INSERT_VNGL
		generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(generalForm.get("PASSWORD")));
		transCnt = baduMapper.createUserInformation_VNGL(generalForm);
		if (transCnt < 1) {
			throw new NoResultException(msg.getMessageForService(this, "exception_msg"));
		}

		String userId = generalForm.get("USER_ID");
		baduMapper.doDeleteUSAP(generalForm);
		doSaveAuth(userId, auGridDatas);

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateUserInfo(Map<String, String> generalForm, List<Map<String, Object>> auGridDatas, List<Map<String, Object>> acGridDatas) throws Exception {

		String userId = generalForm.get("USER_ID");
		if("Y".equals(generalForm.get("CHANGE_PW"))){
			generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(generalForm.get("PASSWORD")));
			//비밀번호저장시 기존비밀번호와 동일하면 리턴
			int checkPW = baduMapper.CheckUserInfoPassWordSame(generalForm);
			if (checkPW > 0) {
				return msg.getMessage("0153");
			}
		}
		baduMapper.updateUserInformation(generalForm);

		//delete USAP / USAC
		baduMapper.doDeleteUSAP(generalForm);
		baduMapper.doDeleteUSAC(generalForm);
		// Update User Auth Code
		doSaveAuth(userId, auGridDatas);
		// Update User Action Code
		doSaveActionProfile(userId, acGridDatas);

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateUserInfo_VNGL(Map<String, String> generalForm, List<Map<String, Object>> auGridDatas) throws Exception {
		if("Y".equals(generalForm.get("CHANGE_PW"))){
			generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(generalForm.get("PASSWORD")));
			//비밀번호저장시 기존비밀번호와 동일하면 리턴
			int checkPW = baduMapper.CheckUserInfoPassWordSame_VNGL(generalForm);
			if (checkPW > 0) {
				return msg.getMessage("0153");
			}
		}

		baduMapper.updateUserInformation_VNGL(generalForm);

		String userId = generalForm.get("USER_ID");

		baduMapper.doDeleteUSAP(generalForm);
		doSaveAuth(userId, auGridDatas);

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void doSaveAuth(String userId, List<Map<String, Object>> auGridDatas) throws Exception {

		int checkCnt = 0;

		for (Map<String, Object> auGridData : auGridDatas) {

			if(auGridData.get("SELECTED").equals("0")) {
				continue;
			}

			auGridData.put("USER_ID", userId);
			// checkCnt == 0 ? insert : update
			checkCnt = baduMapper.existsUSAP(auGridData);
			if (checkCnt == 0) {
				baduMapper.createUSAP(auGridData);
			} else {
				baduMapper.updateUSAP(auGridData);
			}
		}

	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void doSaveActionProfile(String userId, List<Map<String, Object>> acGridDatas) throws Exception {

		int checkCnt = 0;

		for (Map<String, Object> acGridData : acGridDatas) {

			if(acGridData.get("SELECTED").equals("0")) {
				continue;
			}

			acGridData.put("USER_ID", userId);
			// checkCnt == 0 ? insert : update
			checkCnt = baduMapper.existsUSAC(acGridData);
			if (checkCnt == 0) {
				baduMapper.createUSAC(acGridData);
			} else {
				baduMapper.updateUSAC(acGridData);
			}
		}
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteUserInfo(Map<String, String> generalForm) throws Exception {
		baduMapper.doDeleteUserInfo(generalForm);
		baduMapper.doDeleteUSAP(generalForm);
		baduMapper.doDeleteUSAC(generalForm);
		return msg.getMessage("0017");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doResetUserInfo(Map<String, String> generalForm) throws Exception {

		if (generalForm.get("USER_TYPE").equals("C")) { // 운영사
			baduMapper.doResetUserInfo(generalForm);
		} else {
			baduMapper.doResetUserInfoCVUR(generalForm);
		}
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveIssue(Map<String, String> generalForm) throws Exception {
		//입력받은 비밀번호로 업데이트

		generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(generalForm.get("PASSWORD")));
		//비밀번호저장시 기존비밀번호와 동일하면 리턴
		int checkPW = baduMapper.CheckUserInfoPassWordSame(generalForm);
		if (checkPW > 0) {
			return msg.getMessage("0153");
		}

		if(generalForm.get("USER_TYPE").equals("C")) {
			baduMapper.doSaveIssue(generalForm);
		} else {
			baduMapper.doSaveIssue_CVUR(generalForm);
		}

		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doInitPassword(Map<String, String> generalForm) throws Exception {

		//비밀번호 난수발생 > 업데이트
		String password = RandomStringUtils.randomAlphanumeric(10);
		generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(password)));
		baduMapper.doSaveIssue(generalForm);

		// Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");

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

		String contents = "[대명소노시즌]임시비밀번호 : <span style=\"font-weight: bold; color: red;\">" + password + "</span>로 로그인 한 후 비밀번호를 변경하세요";

		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		fileContents = EverString.replace(fileContents, "$CONTENTS$", contents);
		fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
		fileContents = EverString.rePreventSqlInjection(fileContents);

		if(!EverString.nullToEmptyString(generalForm.get("EMAIL")).equals("")) {
			Map<String, String> mdata = new HashMap<String, String>();
			mdata.put("SUBJECT", "[대명소노시즌] " + EverString.nullToEmptyString(generalForm.get("USER_NM")) + " 님. 임시비밀번호가 발급 되었습니다.");
			mdata.put("CONTENTS", fileContents);
			mdata.put("RECV_USER_ID", EverString.nullToEmptyString(generalForm.get("USER_ID")));
			mdata.put("RECV_USER_NM", EverString.nullToEmptyString(generalForm.get("USER_NM")));
			mdata.put("RECV_EMAIL", EverString.nullToEmptyString(generalForm.get("EMAIL")));
			mdata.put("REF_NUM", "");
			mdata.put("REF_MODULE_CD","BADU"); // 참조모듈
			// 메일전송.
			everMailService.sendMail(mdata);
			mdata.clear();
		}

		return msg.getMessage("0094");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveIssue_CVUR(Map<String, String> generalForm) throws Exception {
		
		//입력받은 비밀번호로 업데이트
		generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(generalForm.get("PASSWORD"))));
		//비밀번호저장시 기존비밀번호와 동일하면 리턴
		int checkPW = baduMapper.CheckUserInfoPassWordSame_VNGL(generalForm);
		if (checkPW > 0) {
			return msg.getMessage("0153");
		}
		baduMapper.doSaveIssue_CVUR(generalForm);
		
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void doInitPassword_CVUR(Map<String, String> generalForm) throws Exception {

		// 비밀번호 난수발생 > 업데이트
		String password = RandomStringUtils.randomAlphanumeric(10);

		generalForm.put("PASSWORD", EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(password)));
		baduMapper.doSaveIssue_CVUR(generalForm);

		// Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");

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

		String contents = "[대명소노시즌]임시비밀번호 : <span style=\"font-weight: bold; color: red;\">" + password + "</span>로 로그인 한 후 비밀번호를 변경하세요";

		String fileContents = "";
		fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		fileContents = EverString.replace(fileContents, "$CONTENTS$", contents);
		fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
		fileContents = EverString.rePreventSqlInjection(fileContents);

		if(!generalForm.get("EMAIL").equals("")) {
			Map<String, String> mdata = new HashMap<String, String>();
			mdata.put("SUBJECT", "[대명소노시즌] " + EverString.nullToEmptyString(generalForm.get("USER_NM")) + " 님. 임시비밀번호가 발급 되었습니다.");
			mdata.put("CONTENTS", fileContents);
			mdata.put("RECV_USER_ID", generalForm.get("USER_ID"));
			mdata.put("RECV_USER_NM", generalForm.get("USER_NM"));
			mdata.put("RECV_EMAIL", generalForm.get("EMAIL"));
			mdata.put("REF_NUM", "");
			mdata.put("REF_MODULE_CD", "BADU");
			//메일 발송
			everMailService.sendMail(mdata);
			mdata.clear();
		}
	}

	public Map<String, String> getUserInfo(Map<String, String> formData) {
		return baduMapper.getUserInfo(formData);
	}


	public List<Map<String, Object>> getTmsList(Map<String, String> param) throws Exception {
		return baduMapper.getTmsList(param);
	}




    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String saveTms(List<Map<String, Object>> gridDatas) throws Exception
    {
		for (Map<String, Object> gridData : gridDatas) {

			if(!"0".equals(baduMapper.chkTms(gridData))) {
				throw new Exception(gridData.get("CUST_NO")+"는 이미 등록된 계정입니다.");
			}


			baduMapper.saveTms(gridData);
		}
		if(1==1) throw new Exception("=====================================================================");
		return msg.getMessage("0015");
    }















}