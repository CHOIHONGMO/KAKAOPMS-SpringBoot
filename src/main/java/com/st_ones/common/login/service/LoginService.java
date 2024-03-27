package com.st_ones.common.login.service;

import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.LoginMapper;
import com.st_ones.common.login.domain.LoginSearch;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.menu.MenuMapper;
import com.st_ones.common.session.web.EverHttpSessionListener;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : LoginService.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Service(value = "loginService")
public class LoginService extends BaseService {

	protected Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired private LoginMapper loginMapper;
	@Autowired private MenuMapper menuMapper;

	/**
	 * 일반 로그인
	 * @param loginSearch
	 * @param baseUserInfo
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public LoginResultType login(LoginSearch loginSearch, Map<String, UserInfo> baseUserInfo) throws Exception {

		// 사용자 아이디에 맞는 사용자 유형 가져오기
		String loginAttemptUserType = loginMapper.findUserId(loginSearch);
		if (StringUtils.isEmpty(loginAttemptUserType)) {
			return LoginResultType.FAIL_NOT_EXIST_ID;
		} else {
			loginSearch.setUserType(loginAttemptUserType);
		}

		// 사용자 비밀번호 체크
		String loginAttemptUserPw = loginMapper.findUserIdPW(loginSearch);
		if (StringUtils.isEmpty(loginAttemptUserPw)) {
			return LoginResultType.FAIL_WRONG_PASSWORD;
		}

		loginSearch.setDatabaseCd(PropertiesManager.getString("eversrm.system.database"));
		loginSearch.setGmtDefault(PropertiesManager.getString("eversrm.gmt.default"));
		loginSearch.setLangCd(PropertiesManager.getString("eversrm.langCd.default"));
		loginSearch.setIsDev(PropertiesManager.getString("eversrm.system.developmentFlag"));

		// 사용자 유형
		String userType = loginSearch.getUserType();
		if(userType.equals(Code.OPERATOR)) {
			baseUserInfo.put("baseInfo", loginMapper.getUserInfoB(loginSearch));	// O
		} else if(userType.equals(Code.BUYER)) {
			baseUserInfo.put("baseInfo", loginMapper.getUserInfoB(loginSearch));	// B
		} else if(userType.equals(Code.CUSTOMER)) {
			baseUserInfo.put("baseInfo", loginMapper.getUserInfoC(loginSearch));	// C
		} else if(userType.equals(Code.SUPPLIER)) {
			baseUserInfo.put("baseInfo", loginMapper.getUserInfoS(loginSearch));	// S
		} else {
			return LoginResultType.FAIL_NOT_EXIST_USER_TYPE;
		}

		if (baseUserInfo.get("baseInfo") == null) {
			return LoginResultType.FAIL_NOT_EXIST_ID;
		}

		UserInfo userInfo = baseUserInfo.get("baseInfo");

		// 사용자 Block, 고객사/협력사 Block
		if( "1".equals(StringUtils.defaultIfEmpty(userInfo.getBlockFlag(), "0")) ) {
			return LoginResultType.FAIL_USER_BLOCK;
		}

		if(userInfo.getDateFormat() == null) { userInfo.setDateFormat(PropertiesManager.getString("eversrm.default.dateFormat")); }
		if(userInfo.getDateValueFormat() == null) { userInfo.setDateValueFormat(PropertiesManager.getString("eversrm.default.dateValueFormat")); }

		if(!StringUtils.equals(loginSearch.getSessionChange(), "true")) {
			//협력사일경우 최종로그인한 시간 3개월체크
			if(userType.equals(Code.SUPPLIER)) {
				if(userInfo.getLastLoginDate() == null) {

				}
			}
		}

		return LoginResultType.SUCCESS;
	}

	/**
	 * SSO 로그인
	 * @param loginSearch
	 * @param baseUserInfo
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public LoginResultType loginSSO(LoginSearch loginSearch, Map<String, UserInfo> baseUserInfo) throws Exception {

		// 사용자 아이디에 맞는 사용자 유형 가져오기
		String loginAttemptUserType = loginMapper.findUserId(loginSearch);
		if (StringUtils.isEmpty(loginAttemptUserType)) {
			return LoginResultType.FAIL_NOT_EXIST_ID;
		} else {
			loginSearch.setUserType(loginAttemptUserType);
		}

		loginSearch.setDatabaseCd(PropertiesManager.getString("eversrm.system.database"));
		loginSearch.setGmtDefault(PropertiesManager.getString("eversrm.gmt.default"));
		loginSearch.setLangCd(PropertiesManager.getString("eversrm.langCd.default"));
		loginSearch.setIsDev(PropertiesManager.getString("eversrm.system.developmentFlag"));

		// 사용자 유형
		String userType = loginSearch.getUserType();
		if(userType.equals(Code.OPERATOR)) {
			baseUserInfo.put("baseInfo", loginMapper.getUserInfoC_SSO(loginSearch));
		} else if(userType.equals(Code.CUSTOMER)) {
			baseUserInfo.put("baseInfo", loginMapper.getUserInfoB_SSO(loginSearch));
		} else {
			return LoginResultType.FAIL_NOT_EXIST_USER_TYPE;
		}

		if (baseUserInfo.get("baseInfo") == null) {
			return LoginResultType.FAIL_NOT_EXIST_ID;
		}

		UserInfo userInfo = baseUserInfo.get("baseInfo");

		// 사용자 Block, 고객사/협력사 Block
		if (StringUtils.defaultIfEmpty(userInfo.getBlockFlag(), "0") == "1") {
			return LoginResultType.FAIL_USER_BLOCK;
		}

		if(userInfo.getDateFormat() == null) { userInfo.setDateFormat(PropertiesManager.getString("eversrm.default.dateFormat")); }
		if(userInfo.getDateValueFormat() == null) { userInfo.setDateValueFormat(PropertiesManager.getString("eversrm.default.dateValueFormat")); }

		return LoginResultType.SUCCESS;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String findUserType(Map<String, String> param) {
		return loginMapper.findUserType(param);
	}

	// 개인정보 취급방침 검토
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String checkAgree(Map<String, String> param) {

		return loginMapper.checkAgree(param);
	}

	// 개인정보 취급방침 변경
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String ConfirmAgree(Map<String, String> param) throws Exception {

		String userType = EverString.nullToEmptyString(param.get("USER_TYPE"));
		if(userType.equals(Code.OPERATOR)) {
			loginMapper.ConfirmAgree(param);	//운영사
		}else{
			loginMapper.ConfirmAgree_BS(param);	//고객사,공급사
		}
		return "SUCCESS";
	}

	public List<Map<String, String>> getTopMenu(String authCd) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();

		//2023.03.23 HMCHOI
		//고객사, 협력사도 메뉴권한 적용되도록 함 (evercomp.properties에서 설정)
		boolean isMenuAuth = false;

		Map<String, String> params = new HashMap<String, String>();
		params.put("menuAuth", String.valueOf(isMenuAuth));
		params.put("AUTH_CD", authCd);

		return menuMapper.getTopMenu(params);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String updateWrongPasswordCount(Map<String, String > userInfo) throws Exception {

		String userType = loginMapper.getUserType(userInfo);
		userInfo.put("userType", userType);
		if(userType.equals("C")) {
			userInfo.put("USER_TABLE", "STOCUSER");
		} else {
			userInfo.put("USER_TABLE", "STOCCVUR");
		}
		loginMapper.updateWrongPasswordCount(userInfo);

		return "SUCCESS";
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateVendorUserPassword() throws Exception {
		List<Map<String, String>> userList = loginMapper.getVendorUserList();
		String newPassword = "";

		for (Map<String, String> each : userList) {
			newPassword = EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(each.get("USER_ID")));
			each.put("GATE_CD",  "100");
			each.put("PASSWORD",  newPassword);
		}
		return "SUCCESS";
	}

	public int getPasswordWrongCount (Map<String, String > userInfo) throws Exception {
		return loginMapper.getPasswordWrongCount(userInfo);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String resetPasswordWrongCount(Map<String, String > userInfo) throws Exception {
		String userType = loginMapper.getUserType(userInfo);
		userInfo.put("userType", userType);
		if(userType.equals("C")) {
			userInfo.put("USER_TABLE", "STOCUSER");
		} else {
			userInfo.put("USER_TABLE", "STOCCVUR");
		}
		loginMapper.resetPasswordWrongCount(userInfo);
		return "SUCCESS";
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String setLastLoginDate(Map<String, String > userInfo,EverHttpRequest req) throws Exception {
		String userType = loginMapper.getUserType(userInfo);
		userInfo.put("userType", userType);
		if(userType.equals("C")) {
			userInfo.put("USER_TABLE", "STOCUSER");
		} else {
			userInfo.put("USER_TABLE", "STOCCVUR");
		}

		userInfo.put("IP_ADDR",getClientIpAddress(req));
		loginMapper.setLastLoginDate(userInfo);
		return "SUCCESS";
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String resetPassword(Map<String, String> formData) throws Exception {

		formData.put("USER_TYPE", "O");
		return "";
	}

	/**
	 * Multi Login 체크
	 * @param req
	 * @param resp
	 * @param resultInfo
	 */
	public void checkLoggedUserExists(EverHttpRequest req, EverHttpResponse resp, Map<String, UserInfo> resultInfo) {

		Map<String, String> userInfo = new HashMap<String, String>();

		UserInfo baseInfo = resultInfo.get("baseInfo");
		userInfo.put("GATE_CD", baseInfo.getGateCd());
		userInfo.put("USER_ID", baseInfo.getUserId());
		userInfo.put("LANG_CD", baseInfo.getLangCd());

		// Client IP 가져오기
		baseInfo.setIpAddress(getClientIpAddress(req));
		System.out.println("Client IP Addr : " + baseInfo.getIpAddress());
		baseInfo.setSystemGmt(PropertiesManager.getString("eversrm.gmt.default"));

		// 중복세션 체크 유무(이미 로그인 된 세션이 있는지를 확인하여 기존 세션을 끊고 새로운 세션생성)
		EverHttpSessionListener everHttpSessionListener = null;
		String userId = resultInfo.get("baseInfo").getUserId();
		String userType = resultInfo.get("baseInfo").getUserType();

		getLog().info("Searching for a user who logged in with another IP");

		String jSessionId = req.getSession().getId();
		everHttpSessionListener = EverHttpSessionListener.getInstance();
		UserInfo loggedSomeoneInfo = everHttpSessionListener.getLoggedUserInfo(userId, userType);

		if(loggedSomeoneInfo != null) {

			getLog().info("Logged User IP: "+loggedSomeoneInfo.getIpAddress()+"/ Login Attempt IP : " + getClientIpAddress(req));
			if (PropertiesManager.getBoolean("eversrm.system.prevent.multiple.login", false)) {
				if (!loggedSomeoneInfo.getIpAddress().equals(getClientIpAddress(req))) {

					getLog().warn("Found same user who logged in with another IP.");
					String invalidate = req.getParameter("invalidate");
					if (StringUtils.equals(invalidate, "true")) {

						getLog().info("Logged as " + userId + " [" + loggedSomeoneInfo.getIpAddress() + "] to logout.");
						everHttpSessionListener.addUserToLogout(loggedSomeoneInfo);
						everHttpSessionListener.addLoginUser(jSessionId, baseInfo);
						resp.setResponseCode("200");
						return;
					} else {
						getLog().info("Return 201 code to login confirm.");
						resp.setResponseCode("201");
						return;
					}
				} else {
					getLog().info("Multiple Login Check passed.");
					resp.setResponseCode("200");
					return;
				}
			}
		}

		getLog().info("Registered to login user list.");
		resp.setResponseCode("200");

		if(!"Y".equals(req.getParameter("incryptFlag"))) {
			everHttpSessionListener.addLoginUser(jSessionId, baseInfo);
		}
	}

	/**
	 * 로그인 사용자별 공지사항 팝업 호출
	 * @param noticeInfo
	 * @return
	 */
	public List<Map<String, String>> getNoticeListPopup(Map<String, String> noticeInfo) {
		return loginMapper.getNoticeListPopup(noticeInfo);
	}

	public String getSignStatus(Map<String, String> param) throws Exception {
		return loginMapper.getSignStatus(param);
	}

	public Map<String, String> getLogos() {
		return loginMapper.getLogos();
	}

	/**
	 * 로그인한 사용자의 IP 주소 가져오기
	 * @param req
	 * @return
	 */
	public String getClientIpAddress(EverHttpRequest req) {

		// 사용자의 IP 주소 가져오기
		String ipAddress = req.getHeader("X-Forwarded-For");

		// X-Forwarded-For 헤더가 없는 경우 또는 여러 개의 IP 주소가 있는 경우 처리
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("Proxy-Client-IP");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("WL-Proxy-Client-IP");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("HTTP_X_FORWARDED_FOR");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("HTTP_X_FORWARDED");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("HTTP_X_CLUSTER_CLIENT_IP");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("HTTP_CLIENT_IP");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("HTTP_FORWARDED_FOR");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getHeader("HTTP_FORWARDED");
		}
		if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
			ipAddress = req.getRemoteAddr();
		}

		return ipAddress;
	}
}