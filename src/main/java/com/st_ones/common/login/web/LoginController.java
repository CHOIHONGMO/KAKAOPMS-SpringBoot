package com.st_ones.common.login.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.enums.system.ToolKitType;
import com.st_ones.common.login.domain.LoginSearch;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.login.service.LoginResultType;
import com.st_ones.common.login.service.LoginService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.UtilService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.info.UserInfoNotFoundException;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import crosscert.Base64;
import crosscert.Certificate;
import crosscert.PrivateKey;
import crosscert.Verifier;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import tradesign.crypto.provider.JeTS;
import tradesign.pki.pkix.Login;
import tradesign.pki.pkix.X509Certificate;
import tradesign.pki.util.JetsUtil;

import javax.crypto.Cipher;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.InvalidKeyException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @version 1.0
 * @File Name : LoginController.java
 * @date 2013. 07. 22.
 * @see
 */

@Controller
@RequestMapping(value = "/")
public class LoginController extends BaseController {

	private static final String CUSTOMER_HOME = "/customerHome";
	private static final String OPERATOR_HOME = "/operatorHome";
	private static final String SUPPLIER_HOME = "/supplierHome";
	private final static String TOOLKIT_PROVIDER = "eversrm.system.toolkit.provider";
	private final static String TOOLKIT_TRADESIGN_FILEPATH = "eversrm.system.tradesign.path";	// KTNET
	private final static String TOOLKIT_CROSSCERT_FILEPATH = "eversrm.system.crosscert.path";
	private final static String SSO_ENCRYPT_KEY  = "eversrm.plusi.sso.encryptionKey"; //SSO 복호화 키

	private static String RSA_WEB_KEY = "_RSA_WEB_Key_"; 	// 개인키 session key
	private static String RSA_INSTANCE = "RSA"; 			// rsa transformation

	Logger logger = LoggerFactory.getLogger(this.getClass());

	@Autowired private LoginService loginService;
	@Autowired private MessageService messageService;
	@Autowired private UtilService utilService;

	@RequestMapping("/noAuth")
	public String noAuth(EverHttpRequest req, EverHttpResponse res) {
		return "/eversrm/noSuperAuth";
	}

	@RequestMapping(value = "noticePopup")
	public String noticePopup(EverHttpRequest req) {
		return "/noticePopup";
	}

	@RequestMapping(value = "/login")
	public void login(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		LoginSearch loginSearch = new LoginSearch();

		String EuserId = req.getParameter("userId");
		String EuserPw = req.getParameter("password");

		HttpSession session = req.getSession(true);
		java.security.PrivateKey privateKey = (java.security.PrivateKey) session.getAttribute(RSA_WEB_KEY);

		// 복호화 : customerHome.jsp에서 Session Change시에 incryptFlag=Y 처리함
		if(!"Y".equals(req.getParameter("incryptFlag"))) {
			EuserId = decryptRsa(privateKey, EuserId);
			EuserPw = decryptRsa(privateKey, EuserPw);
		}

		final String userId = EuserId.trim().toUpperCase();
		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", PropertiesManager.getString("eversrm.gateCd.default"));
		param.put("USER_ID", userId);

		loginSearch.setUserId(userId);
		loginSearch.setPassword(EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(EuserPw)));
		loginSearch.setCheckUserMonth(EverString.nullToEmptyString(req.getParameter("checkUserMonth")));

		if (EverString.nullToEmptyString(req.getParameter("sessionChange")).length() == 0) {
			loginSearch.setSessionChange("false");
		} else {
			loginSearch.setSessionChange(req.getParameter("sessionChange"));
			loginSearch.setUserType(req.getParameter("userType"));
		}

		//사용자 타입(USER_TYPE)
		String UserType = loginService.findUserType(param);
		param.put("USER_TYPE", UserType);

		loginSearch.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
		Map<String, UserInfo> resultInfo = new HashMap<String, UserInfo>();
		// 사용자 로그인 정보 가져오기
		LoginResultType loginResultType = loginService.login(loginSearch, resultInfo);

		// 비밀번호를 5회이상 잘못 입력시 접근 제한(통제)
		int passwordWrongCount = 0;
		if( "true".equals(PropertiesManager.getString("everF.login.PasswordFailCountFlag")) ) {
			int passwordWrongLimit = Integer.parseInt(PropertiesManager.getString("everF.login.WrongLimit"));

			passwordWrongCount = loginService.getPasswordWrongCount(param);
			if (passwordWrongCount >= passwordWrongLimit) {
				utilService.logForJob("LoginFail", "com.st_ones.common.login.service.LoginService", "LoginFail", "Login", "비밀번호 "+passwordWrongLimit+"회 실패", "F", userId, req.getRemoteAddr(), "F", UserType);
				loginResultType = LoginResultType.WRONG_PASSWORD_EXCEEDED_CNT;
			}
		}

		// 잘못된 비밀번호 입력
		if (loginResultType == LoginResultType.FAIL_WRONG_PASSWORD) {
			utilService.logForJob("LoginFail", "com.st_ones.common.login.service.LoginService", "LoginFail", "Login", "잘못된 비밀번호 입력", "F", userId, req.getRemoteAddr(), "", UserType);
			loginService.updateWrongPasswordCount(param);
		} else if(loginResultType == LoginResultType.SUCCESS) {
			loginService.resetPasswordWrongCount(param);
		}

		processCommonLogin(req, resp, loginResultType, resultInfo, passwordWrongCount);
	}

	private void processCommonLogin(EverHttpRequest req, EverHttpResponse resp, LoginResultType loginResultType, Map<String, UserInfo> resultInfo, int passwordWrongCount) throws Exception {

		ObjectMapper mapper = new ObjectMapper();

		// 성공
		if (loginResultType == LoginResultType.SUCCESS) {
			loginService.checkLoggedUserExists(req, resp, resultInfo);
			if(resp.getResponseCode().equals("200")) {	// Single Login
				// 개인정보 동의여부가 "동의"인 경우에만 Session 생성
				UserInfo baseInfo = resultInfo.get("baseInfo");
				if( "1".equals(baseInfo.getAgreeYn()) || 1==1) {
					getLog().info("Creating User Session");
					createLoginUserSession(req, resp, resultInfo);

					resp.setParameter("redirectUrl", "/welcome");

					Map<String, String> userInfo = new HashMap<String, String>();
					userInfo.put("GATE_CD", baseInfo.getGateCd());
					userInfo.put("USER_ID", baseInfo.getUserId());
					userInfo.put("LANG_CD", baseInfo.getLangCd());

					// 로그인일시 업데이트
					loginService.setLastLoginDate(userInfo, req);

					// 개인키 삭제
					HttpSession session = req.getSession();
					session.removeAttribute(RSA_WEB_KEY);
				} else {
					resp.setResponseCode("900");	//개인정보 취급방침 미동의
				}
			}
		}
		// 아이디 미존재
		else if (loginResultType == LoginResultType.FAIL_NOT_EXIST_ID) {
			resp.setResponseMessage("존재하지 않거나 사용할 수 없는 아이디입니다. 다시 확인하세요.");
		}
		// 비밀번호 실패시
		else if (loginResultType == LoginResultType.FAIL_WRONG_PASSWORD) {
			resp.setResponseMessage("비밀번호가 올바르지 않습니다. 다시 확인하세요.");
		}
		// User Type 미존재
		else if (loginResultType == LoginResultType.FAIL_NOT_EXIST_USER_TYPE) {
			resp.setResponseMessage("아이디 또는 비밀번호를 확인하세요.");
		}
		// 비밀번호를 5회 이상 잘못 입력시
		else if (loginResultType == LoginResultType.WRONG_PASSWORD_EXCEEDED_CNT) {
			resp.setResponseMessage("비밀번호를 "+passwordWrongCount+"회 잘못 입력하여 로그인이 금지되었습니다.\n비밀번호를 변경하고 다시 로그인해주시기 바랍니다.");
		}
		// 사용자 또는 업체 Block
		else if (loginResultType == LoginResultType.FAIL_USER_BLOCK) {
			resp.setResponseMessage("사용자 또는 소속 업체가 거래종료 되었습니다.\n관리자 또는 고객센터(sonomro@daemyungsono.com)로 문의 바랍니다.");
		}
		// [미사용] 최종로그인 일시가 3개월이 지나면
		else if (loginResultType == LoginResultType.FAIL_LOGIN_DATE_PASS) {
			UserInfo baseInfo = resultInfo.get("baseInfo");
			resp.setParameter("redirectUrl", "/welcome");
			resp.setResponseMessage("최종 로그인이 3개월 이상 지났습니다.");
		}
		else {
			resp.setResponseMessage("아이디 또는 비밀번호를 확인하세요.\n관리자 또는 고객센터(sonomro@daemyungsono.com)로 문의 바랍니다.");
			resp.getWriter().write(mapper.writeValueAsString(resp.getParameterMap()).toString());
		}
	}

	//사용자 약관동의처리
	@RequestMapping(value = "/ConfirmAgree")
	public void ConfirmAgree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
        String userId = req.getParameter("userId").trim().toUpperCase();
		param.put("GATE_CD", PropertiesManager.getString("eversrm.gateCd.default"));
		param.put("USER_ID", userId);
		String UserType= loginService.findUserType(param);

		param.put("USER_TYPE", UserType);
		param.put("checkYN", req.getParameter("checkYN"));

		String AgreeYn =  loginService.ConfirmAgree(param);
		resp.setResponseMessage(AgreeYn);
	}

	/**
	 * SSO 로그인
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/ssoLogin")
	public void ssoLogin(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		// SSO 사용자ID
		String userId = EverString.nullToEmptyString(req.getParameter("userId"));

		LoginSearch loginSearch = new LoginSearch();
		loginSearch.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
		loginSearch.setSsoUserId(userId);
		loginSearch.setUserId(userId);
		loginSearch.setSsoFlag("true");
		loginSearch.setSessionChange("false");

		// SSO 로그인시 KEY값 복호화
		String key = "aes256-test-key!!";
		// 결재문서를 열기 위해 암호화된 파라미터(결재번호/차수/타입)를 복호화한다.
		Map<String, String> appMap = new HashMap<String, String>();
		if (req.getParameter("appDocNum") != null && req.getParameter("appDocCnt") != null) {
			appMap.put("appDocNum", EverEncryption.decrypt(key, req.getParameter("appDocNum")));
			appMap.put("appDocCnt", EverEncryption.decrypt(key, req.getParameter("appDocCnt")));
			appMap.put("docType", EverEncryption.decrypt(key, req.getParameter("docType")));
		}

		Map<String, UserInfo> resultInfo = new HashMap<String, UserInfo>();
		LoginResultType loginResultType  = loginService.loginSSO(loginSearch, resultInfo);

		// 고객사의 그룹관리자 : 사용자 세션의 M_USER_ID 를 확인한다.
		//loginSearch.setmUserId(req.getParameter("mUserId"));

		processCommonLoginSSO(req, resp, loginResultType, resultInfo, 0, appMap);
	}

	/**
	 * SSO 로그인 프로세스
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	private void processCommonLoginSSO(EverHttpRequest req, EverHttpResponse resp, LoginResultType loginResultType, Map<String, UserInfo> resultInfo, int passwordWrongCount, Map<String, String> appMap) throws Exception {

		ObjectMapper mapper = new ObjectMapper();

		// 성공
		if (loginResultType == LoginResultType.SUCCESS) {

			// Multi Login 체크
			loginService.checkLoggedUserExists(req, resp, resultInfo);
			if(resp.getResponseCode().equals("200")) {

				// SSO 로그인 시에는 "개인정보 동의여부"와 상관없이 Session 생성
				getLog().info("Creating User Session");
				createLoginUserSession(req, resp, resultInfo);

				resp.setParameter("redirectUrl", "/welcomeSSO.so");

				Map<String, String> userInfo = new HashMap<String, String>();

				UserInfo baseInfo = resultInfo.get("baseInfo");
				userInfo.put("GATE_CD", baseInfo.getGateCd());
				userInfo.put("USER_ID", baseInfo.getUserId());
				userInfo.put("LANG_CD", baseInfo.getLangCd());

				// 로그인일시 업데이트
				loginService.setLastLoginDate(userInfo, req);

				// SSO 로그인시 KEY값 암호화
				//String key = "aes256-test-key!!";
				//resp.setHeader("Content-Type", "text/html");
				//resp.getWriter().write("<script>location.href='/welcomeSSO.so?appDocNum=" + URLEncoder.encode(EverEncryption.encrypt(key, appMap.get("appDocNum")), "UTF-8") + "&appDocCnt=" + URLEncoder.encode(EverEncryption.encrypt(key, appMap.get("appDocCnt")), "UTF-8") + "&docType=" + URLEncoder.encode(EverEncryption.encrypt(key, appMap.get("docType")), "UTF-8") + "';</script>");
			}
		}
		// 아이디 미존재
		else if (loginResultType == LoginResultType.FAIL_NOT_EXIST_ID) {
			resp.setResponseMessage("존재하지 않거나 사용할 수 없는 아이디입니다. 다시 확인하세요.");
		}
		// 비밀번호 실패시
		else if (loginResultType == LoginResultType.FAIL_WRONG_PASSWORD) {
			resp.setResponseMessage("비밀번호가 올바르지 않습니다. 다시 확인하세요.");
		}
		// User Type 미존재
		else if (loginResultType == LoginResultType.FAIL_NOT_EXIST_USER_TYPE) {
			resp.setResponseMessage("아이디 또는 비밀번호를 확인하세요.");
		}
		// 비밀번호를 5회 이상 잘못 입력시
		else if (loginResultType == LoginResultType.WRONG_PASSWORD_EXCEEDED_CNT) {
			resp.setResponseMessage("비밀번호를 5회 잘못 입력하여 로그인이 금지되었습니다.\n비밀번호를 변경하고 다시 로그인해주시기 바랍니다.");
		}
		// 사용자 또는 업체 Block
		else if (loginResultType == LoginResultType.FAIL_USER_BLOCK) {
			resp.setResponseMessage("사용자 또는 소속 업체가 거래종료 되었습니다.\n관리자 또는 고객센터(sonomro@daemyungsono.com)로 문의 바랍니다.");
		}
		// [미사용] 최종로그인 일시가 3개월이 지나면
		else if (loginResultType == LoginResultType.FAIL_LOGIN_DATE_PASS) {
			UserInfo baseInfo = resultInfo.get("baseInfo");
			resp.setParameter("redirectUrl", "/welcomeSSO.so");
			resp.setResponseMessage("최종로그인이 3개월 이상 지났습니다.");
		}
		else {
			resp.setResponseMessage("아이디 또는 비밀번호를 확인하세요.\n관리자 또는 고객센터([레저]02-2222-7586,[건설]02-2222-7581)로 문의 바랍니다.");
			resp.getWriter().write(mapper.writeValueAsString(resp.getParameterMap()).toString());
		}
	}

	/**
	 * indexBS.jsp에서 호출 [미사용]
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/loginP")
	public void loginP(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		LoginSearch loginSearch = new LoginSearch();
		String EuserId = req.getParameter("userId");
		String EuserPw = req.getParameter("password");

		HttpSession session = req.getSession(true);
		java.security.PrivateKey privateKey = (java.security.PrivateKey) session.getAttribute(RSA_WEB_KEY);

		// 복호화 : customerHome.jsp에서 Session Change시에 incryptFlag=Y 처리함
        if(!"Y".equals(req.getParameter("incryptFlag"))) {
			EuserId = decryptRsa(privateKey, EuserId);
			EuserPw = decryptRsa(privateKey, EuserPw);
        }

		final String userId = EuserId.trim().toUpperCase();
		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", PropertiesManager.getString("eversrm.gateCd.default"));
		param.put("USER_ID", userId);

		loginSearch.setUserId(userId);
		loginSearch.setPassword(EverEncryption.getEncryptedUserPassword(EverString.nullToEmptyString(EuserPw)));
		loginSearch.setCheckUserMonth(EverString.nullToEmptyString(req.getParameter("checkUserMonth")));

		if (EverString.nullToEmptyString(req.getParameter("sessionChange")).length() == 0) {
			loginSearch.setSessionChange("false");
		} else {
			loginSearch.setSessionChange(req.getParameter("sessionChange"));
			loginSearch.setUserType(req.getParameter("userType"));
		}

		String UserType = "B";

		loginSearch.setGateCd(PropertiesManager.getString("eversrm.gateCd.default"));
		Map<String, UserInfo> resultInfo = new HashMap<String, UserInfo>();
		LoginResultType loginResultType = loginService.login(loginSearch, resultInfo);

		// 비밀번호를 5회이상 잘못 입력시 접근 제한(통제)
		int passwordWrongCount = 0;
		if( "true".equals(PropertiesManager.getString("everF.login.PasswordFailCountFlag")) ) {
			int passwordWrongLimit = Integer.parseInt(PropertiesManager.getString("everF.login.WrongLimit"));

			passwordWrongCount = loginService.getPasswordWrongCount(param);
			if (passwordWrongCount >= passwordWrongLimit) {
				utilService.logForJob("LoginFail", "com.st_ones.common.login.service.LoginService", "LoginFail", "Login", "비밀번호 "+passwordWrongLimit+"회 실패", "F", userId, req.getRemoteAddr(), "F", UserType);
				loginResultType = LoginResultType.WRONG_PASSWORD_EXCEEDED_CNT;
			}
		}

		// 비밀번호를 5회이상 잘못 입력시 접근 제한(통제)
		if (loginResultType == LoginResultType.FAIL_WRONG_PASSWORD) {
			utilService.logForJob("LoginFail", "com.st_ones.common.login.service.LoginService", "LoginFail", "Login", "잘못된 비밀번호 입력", "F", userId, req.getRemoteAddr(), "", UserType);
			loginService.updateWrongPasswordCount(param);
		} else if(loginResultType == LoginResultType.SUCCESS) {
			loginService.resetPasswordWrongCount(param);
		}

		processCommonLoginP(req, resp, loginResultType, resultInfo, passwordWrongCount);
	}

	private void processCommonLoginP(EverHttpRequest req, EverHttpResponse resp, LoginResultType loginResultType, Map<String, UserInfo> resultInfo, int passwordWrongCount) throws Exception {

		ObjectMapper mapper = new ObjectMapper();

		// 성공
		if (loginResultType == LoginResultType.SUCCESS) {

			// Multi Login 체크
			loginService.checkLoggedUserExists(req, resp, resultInfo);
			if(resp.getResponseCode().equals("200")) {

				// 개인정보 동의여부가 "동의"인 경우에만 Session 생성
				UserInfo baseInfo = resultInfo.get("baseInfo");
				if( "1".equals(baseInfo.getAgreeYn()) ) {
					getLog().info("Creating User Session");
					createLoginUserSession(req, resp, resultInfo);

					resp.setParameter("redirectUrl", "/welcomeBS.so");

					Map<String, String> userInfo = new HashMap<String, String>();
					userInfo.put("GATE_CD", baseInfo.getGateCd());
					userInfo.put("USER_ID", baseInfo.getUserId());
					userInfo.put("LANG_CD", baseInfo.getLangCd());

					// 로그인일시 업데이트
					loginService.setLastLoginDate(userInfo, req);

					// 개인키 삭제
					HttpSession session = req.getSession();
					session.removeAttribute(RSA_WEB_KEY);
				} else {
					resp.setResponseCode("900");	//개인정보 취급방침 미동의
				}
			}
		}
		// 아이디 미존재
		else if (loginResultType == LoginResultType.FAIL_NOT_EXIST_ID) {
			resp.setResponseMessage("존재하지 않거나 사용할 수 없는 아이디입니다. 다시 확인하세요.");
		}
		// 비밀번호 실패시
		else if (loginResultType == LoginResultType.FAIL_WRONG_PASSWORD) {
			resp.setResponseMessage("비밀번호가 올바르지 않습니다. 다시 확인하세요.");
		}
		// User Type 미존재
		else if (loginResultType == LoginResultType.FAIL_NOT_EXIST_USER_TYPE) {
			resp.setResponseMessage("아이디 또는 비밀번호를 확인하세요.");
		}
		// 비밀번호를 5회 이상 잘못 입력시
		else if (loginResultType == LoginResultType.WRONG_PASSWORD_EXCEEDED_CNT) {
			resp.setResponseMessage("비밀번호를 "+passwordWrongCount+"회 잘못 입력하여 로그인이 금지되었습니다.\n비밀번호를 변경하고 다시 로그인해주시기 바랍니다.");
		}
		// 사용자 또는 업체 Block
		else if (loginResultType == LoginResultType.FAIL_USER_BLOCK) {
			resp.setResponseMessage("사용자 또는 소속 업체가 거래종료 되었습니다.\n관리자 또는 고객센터(sonomro@daemyungsono.com)로 문의 바랍니다.");
		}
		// [미사용] 최종로그인 일시가 3개월이 지나면
		else if (loginResultType == LoginResultType.FAIL_LOGIN_DATE_PASS) {
			UserInfo baseInfo = resultInfo.get("baseInfo");
			resp.setParameter("redirectUrl", "/welcomeBS.so");
			resp.setResponseMessage("최종로그인이 3개월 이상 지났습니다.");
		}
		else {
			resp.setResponseMessage("아이디 또는 비밀번호를 확인하세요.\n관리자 또는 고객센터(sonomro@daemyungsono.com)로 문의 바랍니다.");
			resp.getWriter().write(mapper.writeValueAsString(resp.getParameterMap()).toString());
		}
	}

	/**
	 * SSO를 통한 로그인 (ssoRespPage.jsp)
	 * @param req
	 * @return
	 */
	@RequestMapping(value = "/eversrm/ssoRespPage/view")
	public String ssoRespPage(EverHttpRequest req) {

		req.setAttribute("returnParam", req.getParameter("returnParam"));
		return "/eversrm/ssoRespPage";
	}

	/**
	 * 비밀번호 초기화
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping("/resetPassword")
	public void resetPassword(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		formData.put("userId", req.getParameter("userId"));
		String message = loginService.resetPassword(formData);
		resp.setResponseMessage(message);
	}

	/**
	 * 로그인 사용자 Session 생성
	 * @param req
	 * @param resp
	 * @param resultInfo
	 * @throws Exception
	 */
	private void createLoginUserSession(EverHttpRequest req, EverHttpResponse resp, Map<String, UserInfo> resultInfo) throws Exception {

		UserInfo userInfo = new UserInfo();
		HttpSession httpSession = req.getSession();
		httpSession.setAttribute("ses", resultInfo.get("baseInfo"));
		UserInfoManager.createUserInfo(resultInfo.get("baseInfo"));
		utilService.logForJob("Login", "com.st_ones.common.login.service.LoginService", "Login", "Login", "Login", "I",  userInfo.getUserId(), req.getRemoteAddr(), "", userInfo.getUserType());
		messageService.setCommonMessage(httpSession);

	}

	@RequestMapping("/home")
	public String home(HttpServletRequest req, HttpServletResponse resp) throws Exception {

		UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
		if (baseInfo == null || baseInfo.getUserId().equals("VIRTUAL")) {
			return "forward:/index.so";
		}

		UserInfo userInfo = UserInfoManager.getUserInfo();
		req.setAttribute("getYear", EverDate.getYear());
		req.setAttribute("getMonth", EverDate.getMonth());
		req.setAttribute("getDay", EverDate.getDay());
		req.setAttribute("getFormattedTime", EverDate.getFormattedTime());
		req.setAttribute("topMenu", loginService.getTopMenu(userInfo.getGrantedAuthCd()));
		req.setAttribute("tabLimit", PropertiesManager.getString("eversrm.ui.tab.limit")); // 메인화면 탭 제한 수

		req.setAttribute("isLocalServer", PropertiesManager.getString("eversrm.system.localserver"));
		req.setAttribute("isDev", PropertiesManager.getString("eversrm.system.developmentFlag"));
		req.setAttribute("everSslUseFlag", PropertiesManager.getString("ever.ssl.use.flag"));
		req.setAttribute("eversrmSystemDomainPort", PropertiesManager.getString("eversrm.system.domainPort"));
		req.setAttribute("eversrmSystemDomainUrl", PropertiesManager.getString("eversrm.system.domainUrl"));
		req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));

		String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");

		String siteUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { siteUrl = "https://"; }
		else { siteUrl = "http://"; }
		if ("80".equals(domainPort)) {
			siteUrl += domainNm;
		} else {
			siteUrl += domainNm + ":" + domainPort;
		}
		req.setAttribute("realDomainUrl", siteUrl);

		UserInfoManager.getUserInfo();
		Map<String, String> noticeInfo = new HashMap<String, String>();
		noticeInfo.put("NOTICE_TYPE", "PCP");

//		if(userInfo_sub.isCustomer()) {
//			noticeInfo.put("USER_TYPE", "USNC");
//		} else if (userInfo_sub.isSupplier()) {
//			noticeInfo.put("USER_TYPE", "USNE");
//		} else if (userInfo_sub.isOperator()) {
//			noticeInfo.put("USER_TYPE", "USNI");
//		}

		// 고객사의 그룹관리자 : 사용자 세션의 M_USER_ID 를 확인한다.
		//if (EverString.nullToEmptyString(userInfo_sub.getmUserId()).equals("")) {
		//	req.setAttribute("changeCombo", commonComboService.getCodes("CB0105", new HashMap<String, String>()));
		//}

		/**
		 * 2020.08.31 HMCHOI 제외
		// 고객사의 회사 로고(logo) 정보를 가져온다.
		Map<String, String> logos = loginService.getLogos();
		if(logos != null) {
			// 운영사, 고객사
			File imageFile = new File(logos.get("FILE_PATH") + "/" + logos.get("FILE_NM") + "." + logos.get("FILE_EXTENSION"));
			// 파일이 존재하는지 체크
			if(imageFile.isFile()) {
				String encode = EverString.getImageEncode(FileUtils.readFileToByteArray(imageFile));
				req.setAttribute("FILE_EXTENSION", logos.get("FILE_EXTENSION"));
				req.setAttribute("BYTE_ARRAY", encode);
			}
		}*/

		req.setAttribute("noticeListPopup", loginService.getNoticeListPopup(noticeInfo));
		return getHomeUrl(req);
	}

	private String getHomeUrl(HttpServletRequest req) throws Exception {

		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();

		Map<String, String> initData = new HashMap<String, String>();
		initData.put("userId", userInfo.getUserId());
		initData.put("userType", UserInfoManager.getUserInfo().getUserType());
		req.setAttribute("initData", new JSONObject(initData).toJSONString());

		if (userInfo.isCustomer()) {
			return CUSTOMER_HOME;
		} else if (userInfo.isSupplier()) {
			return SUPPLIER_HOME;
		} else if (userInfo.isOperator()) {
			return OPERATOR_HOME;
		} else {
			throw new Exception("unknown user type: " + userInfo.getUserType());
		}
	}

	@RequestMapping("/homeSSO")
	public String homeSSO(EverHttpRequest req) throws Exception {

		UserInfo baseInfo = (UserInfo) req.getSession().getAttribute("ses");
		if (baseInfo == null || baseInfo.getUserId().equals("VIRTUAL")) {
			return "forward:/index.so";
		}

		UserInfo userInfo = UserInfoManager.getUserInfo();
		req.setAttribute("getYear", EverDate.getYear());
		req.setAttribute("getMonth", EverDate.getMonth());
		req.setAttribute("getDay", EverDate.getDay());
		req.setAttribute("getFormattedTime", EverDate.getFormattedTime());
		req.setAttribute("topMenu", loginService.getTopMenu(userInfo.getGrantedAuthCd()));
		req.setAttribute("tabLimit", PropertiesManager.getString("eversrm.ui.tab.limit")); // 메인화면 탭 제한 수

		req.setAttribute("isLocalServer", PropertiesManager.getString("eversrm.system.localserver"));
		req.setAttribute("isDev", PropertiesManager.getString("eversrm.system.developmentFlag"));
		req.setAttribute("everSslUseFlag", PropertiesManager.getString("ever.ssl.use.flag"));
		req.setAttribute("eversrmSystemDomainPort", PropertiesManager.getString("eversrm.system.domainPort"));
		req.setAttribute("eversrmSystemDomainUrl", PropertiesManager.getString("eversrm.system.domainUrl"));
		req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));

		String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");

		String siteUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { siteUrl = "https://"; }
		else { siteUrl = "http://"; }
		if ("80".equals(domainPort)) {
			siteUrl += domainNm;
		} else {
			siteUrl += domainNm + ":" + domainPort;
		}
		req.setAttribute("realDomainUrl", siteUrl);

		UserInfo userInfo_sub = (UserInfo) UserInfoManager.getUserInfo();
		Map<String, String> noticeInfo = new HashMap<String, String>();
		noticeInfo.put("NOTICE_TYPE", "PCP");

		if(userInfo_sub.isCustomer()) {
			noticeInfo.put("USER_TYPE", "USNC");
		} else if (userInfo_sub.isSupplier()) {
			noticeInfo.put("USER_TYPE", "USNE");
		} else if (userInfo_sub.isOperator()) {
			noticeInfo.put("USER_TYPE", "USNI");
		}

		req.setAttribute("noticeListPopup", loginService.getNoticeListPopup(noticeInfo));
		return getHomeUrlSSO(req);
	}

	private String getHomeUrlSSO(EverHttpRequest req) throws Exception {

		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();

		Map<String, String> initData = new HashMap<String, String>();
		initData.put("userId", userInfo.getUserId());
		initData.put("userType", UserInfoManager.getUserInfo().getUserType());
		initData.put("ssoFlag", "true");

		if (req.getParameter("appDocNum") != null && req.getParameter("appDocCnt") != null) {
			String key = "aes256-test-key!!";
			initData.put("appDocNum", EverEncryption.decrypt(key, req.getParameter("appDocNum")));
			initData.put("appDocCnt", EverEncryption.decrypt(key, req.getParameter("appDocCnt")));
			initData.put("docType", EverEncryption.decrypt(key, req.getParameter("docType")));

			// 승인, 반려 버튼의 활성/비활성화를 위해 signStatus를 실시간으로 가져온다.
			Map<String, String> param = new HashMap<String, String>();
			param.put("appDocNum", initData.get("appDocNum"));
			param.put("appDocCnt", initData.get("appDocCnt"));
			param.put("userId", initData.get("userId"));

			String signStatus = loginService.getSignStatus(param);
			initData.put("signStatus", signStatus);
		}

		List<Map<String, String>> initDatas = new ArrayList<Map<String, String>>();
		initDatas.add(initData);
		req.setAttribute("initDatas", new ObjectMapper().writeValueAsString(initDatas));

		if (userInfo.isCustomer()) {
			return CUSTOMER_HOME;
		} else if (userInfo.isOperator()) {
			return OPERATOR_HOME;
		} else {
			throw new Exception("unknown user type: " + userInfo.getUserType());
		}
	}

	@RequestMapping(value = "/logout")
	public void logoutProc(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "userId") String userId, @RequestParam(value = "userName") String userName) throws Exception {

		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		String userType = userInfo.getUserType();
		utilService.logForJob("Logout", "com.st_ones.common.login.service.LoginService", "Logout", "Logout", "Logout", "O",  userId, req.getRemoteAddr(), "",userType);
		resp.setParameter("locationAfterLoggedOut", "/welcome");
		resp.setResponseMessage(messageService.getMessage("0038", userName));
		resp.setResponseCode("invalidateSession");
		req.getSession().invalidate();
	}

	@RequestMapping(value = "/sessionCut")
	public void sessionCut(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		req.getSession().invalidate();
	}

	@RequestMapping(value = "/logoutP")
	public void logoutP(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "userId") String userId, @RequestParam(value = "userName") String userName) throws Exception {

		UserInfo userInfo = (UserInfo) UserInfoManager.getUserInfo();
		String userType = userInfo.getUserType();
		utilService.logForJob("Logout", "com.st_ones.common.login.service.LoginService", "Logout", "Logout", "Logout", "O",  userId, req.getRemoteAddr(), "",userType);
		resp.setParameter("locationAfterLoggedOut", "/welcomeBS.so");
		resp.setResponseMessage(messageService.getMessage("0038", userName));
		resp.setResponseCode("invalidateSession");
		req.getSession().invalidate();
	}

	@RequestMapping(value = "/unloadLogout")
	public void unloadLogout(EverHttpRequest req, EverHttpResponse resp) throws UserInfoNotFoundException, IOException, InterruptedException {

    	try {
			req.getSession().invalidate();
			PrintWriter writer = resp.getWriter();
			resp.setContentType("text/html");
			writer.write("<script>top.location.href='/';</script>");
		} catch(Exception e) {
    		logger.error(e.getMessage(), e);
		}
	}

	/**
	 * 공인인증서를 통한 로그인
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/certificateLogin")
	public void certificateLogin(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String encryptedUserInfo = req.getParameter("encryptedUserInfo");
		ToolKitType toolKit = ToolKitType.fromString(PropertiesManager.getString(TOOLKIT_PROVIDER));

		switch (toolKit) {

			case KTNET: // ktnet

				String ktnetPath = PropertiesManager.getString(TOOLKIT_TRADESIGN_FILEPATH);

				JeTS.setprintDetail(true);
				JeTS.installProvider(ktnetPath);

				String message = new String(encryptedUserInfo.getBytes("UTF-8"), "euc-kr");
				byte[] loginRequest = JetsUtil.base64ToBytes(message);

				Login login = new Login(loginRequest);
				login.setupCipher(JeTS.getServerkmCert(0), JeTS.getServerkmPriKey(0), JeTS.getServerKmKeyPassword(0));
				login.parseLoginData(true);

				String userData = new String(login.getUserData(), "UTF-8");
				String ssnNumber = new String(login.getSsn());

				X509Certificate[] certs = login.getSignerCerts();
				String subjectDNStr[];
				String notBeforeStr[];
				String notAfterStr[];
				String serialNumber[];
				String issuerDNStr[];
				String signatureAlgorithm[];

				if (certs != null) {

					subjectDNStr = new String[certs.length];
					notBeforeStr = new String[certs.length];
					notAfterStr = new String[certs.length];
					serialNumber = new String[certs.length];
					issuerDNStr = new String[certs.length];
					signatureAlgorithm = new String[certs.length];

					for (int i = 0; i < certs.length; i++) {
						subjectDNStr[i] = certs[i].getSubjectDNStr();
						notBeforeStr[i] = certs[i].getNotBefore().toString();
						notAfterStr[i] = certs[i].getNotAfter().toString();
						serialNumber[i] = certs[i].getSerialNumber().toString();
						issuerDNStr[i] = certs[i].getIssuerDNStr();
						signatureAlgorithm[i] = certs[i].getSignatureAlgorithm().toString();
					}
				} else {
					throw new Exception("Login certification failed!");
				}

				X509Certificate cert = certs[0];
				boolean ret = cert.VerifyIDN(ssnNumber, login.getRandom());
				boolean isDevelopmentStatus = PropertiesManager.getBoolean("eversrm.system.developmentFlag");
				if (ret || isDevelopmentStatus) {

					if (certs != null) {
						for (int i = 0; i < certs.length; i++) {
							getLog().info("Subject DN: " + subjectDNStr[i]);
							getLog().info("Valid Start Date: " + notBeforeStr[i]);
							getLog().info("Valid End Date:" + notAfterStr[i]);
							getLog().info("Serial Number: " + serialNumber[i]);
							getLog().info("Issuer DN: " + issuerDNStr[i]);
							getLog().info("Signature Algorithm: " + signatureAlgorithm[i]);
						}
					}

					Map<String, String> userInfo = new ObjectMapper().readValue(userData, Map.class);

					LoginSearch loginSearch = new LoginSearch();
					loginSearch.setGateCd(userInfo.get("gateCd"));
					loginSearch.setUserId(userInfo.get("userId"));
					loginSearch.setUserR(message);

					Map<String, UserInfo> resultInfo = new HashMap<String, UserInfo>();
					LoginResultType loginResultType = loginService.login(loginSearch, resultInfo);

					processCommonLogin(req, resp, loginResultType, resultInfo, 0);

				} else {
					String defaultGateCd = PropertiesManager.getString("eversrm.gateCd.default");
					String defaultLangCd = PropertiesManager.getString("eversrm.langCd.default");
					throw new EverException(messageService.getMessage("0048", defaultGateCd, defaultLangCd));
				}

				break;

			case CROSSCERT: // 한국전자인증

				int nRet;
				Base64 cBase64 = new Base64();
				Verifier verifier = new Verifier();

				String certPath = PropertiesManager.getString(TOOLKIT_CROSSCERT_FILEPATH);
				FileInputStream inPri = null;
				FileInputStream inCert = null;

				try {
					inPri = new FileInputStream(new File(certPath + "kmPri.key"));
					inCert = new FileInputStream(new File(certPath + "kmCert.der"));

					int nPriLen = inPri.available();
					byte[] priFileBuf = new byte[nPriLen];
					inPri.read(priFileBuf);

					int certLen = inCert.available();
					byte[] strCertBuf = new byte[certLen];
					inCert.read(strCertBuf);

					PrivateKey privateKey = new PrivateKey();
					nRet = privateKey.DecryptPriKey("88888888", priFileBuf, nPriLen);
					if (nRet != 0) {
						getLog().error("에러내용:" + privateKey.errmessage);
						getLog().error("에러코드:" + privateKey.errcode);
						// throw new EverException("서버인증서의 개인키 복호화에 실패했습니다. (에러내용:" + privateKey.errmessage);
					} else {
						getLog().info("서버인증서개인키 길이 : " + privateKey.prikeylen);
						getLog().info("서버인증서 길이 : " + certLen);
					}

				} catch(Exception e) {
					logger.error(e.getMessage(), e);
				} finally {
					if(inPri != null) inPri.close();
					if(inCert != null) inCert.close();
				}

				/**
				 * 암호화된 데이터를 비공개키로 풀어서 원문을 생성한다.
				 */
				nRet = cBase64.Decode(encryptedUserInfo.getBytes("KSC5601"), encryptedUserInfo.getBytes("KSC5601").length);
				if (nRet != 0) {
					throw new EverException(messageService.getMessage("0088") + verifier.errmessage + ")");
				}

				/**
				 * 선택된 인증서의 공개키를 이용해 전자서명 검증을 수행한다. 또한 전자서명을 수행한 인증서의 유효성 검증도 수행된다.
				 */
				nRet = verifier.VerSignedData(cBase64.contentbuf, cBase64.contentlen);
				if (nRet != 0) {
					throw new EverException(messageService.getMessage("0089") + verifier.errmessage + ")");
				}

				/**
				 * 인증서의 정보를 추출해서 로그에 남긴다.
				 */
				Certificate certificate = new Certificate();

				String policies = "";

				/* 법인상호연동용(범용) */
				policies += "1.2.410.200004.5.2.1.1" + "|"; // 한국정보인증 법인
				policies += "1.2.410.200004.5.1.1.7" + "|"; // 한국증권전산 법인, 단체, 개인사업자
				policies += "1.2.410.200005.1.1.5" + "|"; // 금융결제원 법인, 임의단체, 개인사업자
				policies += "1.2.410.200004.5.3.1.1" + "|"; // 한국전산원 기관(국가기관 및
															// 비영리기관)
				policies += "1.2.410.200004.5.3.1.2" + "|"; // 한국전산원 법인(국가기관 및
															// 비영리기관을 제외한 공공기관, 법인)
				policies += "1.2.410.200004.5.4.1.2" + "|"; // 한국전자인증 법인, 단체, 개인사업자
				policies += "1.2.410.200012.1.1.3" + "|"; // 한국무역정보통신 법인
				nRet = certificate.ValidateCert(verifier.certbuf, verifier.certlen, policies, 1);
				if (nRet != 0) {
					throw new EverException(messageService.getMessage("0126") + certificate.errmessage + ")");
				}

				nRet = certificate.ExtractCertInfo(verifier.certbuf, verifier.certlen);
				if (nRet != 0) {
					getLog().error("인증서 정보 추출 실패");
					getLog().error("에러내용 : " + certificate.errmessage);
					getLog().error("에러코드 : " + certificate.errcode);
					throw new EverException(messageService.getMessage("0127"));
				} else {
					getLog().info("인증서 정보 추출 결과 : " + nRet + "");
					getLog().info("버전 : " + certificate.version + "");
					getLog().info("일련번호 : " + certificate.serial + "");
					getLog().info("발급자 DN : " + certificate.issuer + "");
					getLog().info("주체 DN : " + certificate.subject + "");
					getLog().info("공개키 알고리즘 : " + certificate.subjectAlgId + "");
					getLog().info("유효기간 시작 : " + certificate.from + "");
					getLog().info("유효기간 끝 : " + certificate.to + "");
					getLog().info("서명 알고리즘 : " + certificate.signatureAlgId + "");
					getLog().info("공개키 : " + certificate.pubkey + "");
					getLog().info("서명값 : " + certificate.signature + "");
					getLog().info("발급자 대체 이름 : " + certificate.issuerAltName + "");
					getLog().info("주체 대체 이름 : " + certificate.subjectAltName + "");
					getLog().info("키 사용 용도 : " + certificate.keyusage + "");
					getLog().info("보안 정책 : " + certificate.policy + "");
					getLog().info("기본 제한 : " + certificate.basicConstraint + "");
					getLog().info("정책 제한 : " + certificate.policyConstraint + "");
					getLog().info("CRL 배포 지점 : " + certificate.distributionPoint + "");
					getLog().info("발급자 키 식별자 : " + certificate.authorityKeyId + "");
					getLog().info("주체 키 식별자 : " + certificate.subjectKeyId + "");
				}

				userData = req.getParameter("userInfo");
				Map<String, String> userInfo = new ObjectMapper().readValue(userData, Map.class);

				LoginSearch loginSearch = new LoginSearch();
				loginSearch.setGateCd(userInfo.get("gateCd"));
				loginSearch.setUserId(userInfo.get("userId"));
				loginSearch.setPassword(EverEncryption.getEncryptedUserPassword(userInfo.get("password")));
				loginSearch.setCertLogin(true);

				Map<String, UserInfo> resultInfo = new HashMap<String, UserInfo>();
				LoginResultType loginResultType = loginService.login(loginSearch, resultInfo);

				processCommonLogin(req, resp, loginResultType, resultInfo, 0);

				break;
			default:
				break;
		}

		resp.setResponseMessage("null");
	}

	/**
	 * rsa 복호화
	 * @param privateKey
	 * @param securedValue
	 * @return
	 * @throws Exception
	 */
	private String decryptRsa(java.security.PrivateKey privateKey, String securedValue) throws Exception {

		String decryptedValue;
		try {
			Cipher cipher = Cipher.getInstance(LoginController.RSA_INSTANCE);
			byte[] encryptedBytes = hexToByteArray(securedValue);
			cipher.init(Cipher.DECRYPT_MODE, privateKey);
			byte[] decryptedBytes = cipher.doFinal(encryptedBytes);
			decryptedValue = new String(decryptedBytes, "utf-8");
		} catch(InvalidKeyException e) {
			getLog().error(e.getMessage(), e);
			throw new Exception("로그인 암호화 키가 만료되었습니다. 화면을 새로고침 해주시기 바랍니다.");
		}
		return decryptedValue;
	}

	/**
	 * 16진 문자열을 byte 배열로 변환한다.
	 *
	 * @param hex
	 * @return
	 */
	public static byte[] hexToByteArray(String hex) {
		if (hex == null || hex.length() % 2 != 0) { return new byte[] {}; }

		byte[] bytes = new byte[hex.length() / 2];
		for (int i = 0; i < hex.length(); i += 2) {
			byte value = (byte) Integer.parseInt(hex.substring(i, i + 2), 16);
			bytes[(int) Math.floor(i / 2)] = value;
		}
		return bytes;
	}

}