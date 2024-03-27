package com.st_ones.common.session.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.login.service.LoginService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.session.service.SessionService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.commons.beanutils.BeanMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.net.InetAddress;
import java.security.*;
import java.security.spec.RSAPublicKeySpec;
import java.util.*;

@Controller
@RequestMapping(value = "/common")
public class SessionController extends BaseController {

    @Autowired
    private MessageService msg;

    @Autowired
    private SessionService sessionService;

	@Autowired
	private LoginService loginService;
	private Logger logger = LoggerFactory.getLogger(SessionController.class);

	@RequestMapping(value = "/sessionInfo/view")
	public String sessionInfo(EverHttpRequest req) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> newMap = new HashMap<String, String>();
		newMap.putAll((Map) new BeanMap(userInfo));
		newMap.remove("ses");
		newMap.remove("class");
		TreeSet<String> treeKeys = new TreeSet<String>(newMap.keySet());

		List<Map<String, Object>> colComments = sessionService.getColComments();

		List<Map<String, Object>> listResultMap = new ArrayList<Map<String,Object>>();
		for (String key : treeKeys) {
			Map<String, Object> resultMap = new HashMap<String, Object>();
			resultMap.put("text", key);
			resultMap.put("value", newMap.get(key));
			for (Map<String, Object> colComment : colComments) {
				String columnName = ((String)colComment.get("COLUMN_NAME")).replaceAll("_", "");
				if(columnName.equalsIgnoreCase(key)) {
//					getLog().info("{} : {}", columnName, key);
					resultMap.put("comments", colComment.get("COMMENTS"));
					break;
				}
			}
			listResultMap.add(resultMap);
		}

		InetAddress local = InetAddress.getLocalHost();

		getLog().info("address --> " + local.getHostAddress());
		getLog().info("getCanonicalHostName --> " + local.getCanonicalHostName());
		getLog().info("getAddress --> " + local.getAddress());
		getLog().info("getHostName --> " + local.getHostName());
		getLog().info(req.getRemoteUser());
		getLog().info(req.getLocalAddr());
		getLog().info(req.getLocalName());
		getLog().info("remote host ---> " + req.getRemoteHost());


		Enumeration<String> headerNames = req.getHeaderNames();
		while (headerNames.hasMoreElements()) {
			String headerName = headerNames.nextElement();
			getLog().error("Header Name: " + headerName);
			String headerValue = req.getHeader(headerName);
			getLog().error(", Header Value: " + headerValue);
		}

		req.setAttribute("SESSION_INFO", listResultMap);
		return "/common/sessionInfo";
	}


	/*
	 * 슈퍼권한자인지아닌지
	 */
	private boolean checkSuperCtrl() {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		return userInfo.isSuperUser();
	}

	@RequestMapping(value = "/sessionChange/view")
	public String sessionChange(EverHttpRequest req) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		Map<String, String> newMap = new HashMap<String, String>();
		newMap.putAll((Map) new BeanMap(userInfo));
		newMap.remove("ses");
		newMap.remove("class");
		TreeSet<String> treeKeys = new TreeSet<String>(newMap.keySet());
		List<Map<String, Object>> listResultMap = new ArrayList<Map<String,Object>>();
		for (String key : treeKeys) {
			Map<String, Object> resultMap = new HashMap<String, Object>();
			resultMap.put("text", key);
			resultMap.put("value", newMap.get(key));
			listResultMap.add(resultMap);
		}

		req.setAttribute("SESSION_INFO", listResultMap);
		req.setAttribute("developmentFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		initRsa(req);

		return "/common/sessionChange";
	}

    @RequestMapping(value="/doUpdateVendorUserPassword")
    public void doUpdateVendorUserPassword(EverHttpRequest req, EverHttpResponse resp) throws Exception {
//        Map<String, String> formData = req.getFormData();
        loginService.doUpdateVendorUserPassword();
        resp.setResponseCode("true");
        resp.setResponseMessage(msg.getMessage("0001"));
    }

    @RequestMapping(value="/doUpdateVendorEncQta")
    public void doUpdateVendorEncQta(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
		sessionService.doUpdateVendorEncQta(formData);

        resp.setResponseCode("true");
        resp.setResponseMessage(msg.getMessage("0001"));
    }

    @RequestMapping(value="/changeVendorCd")
    public void changeVendorCd(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
		sessionService.changeVendorCd(formData);

        resp.setResponseCode("true");
        resp.setResponseMessage(msg.getMessage("0001"));
    }

	/**
	 * rsa 공개키, 개인키 생성
	 *
	 * @param request
	 */
	public void initRsa(EverHttpRequest request) {
		HttpSession session = request.getSession();

		KeyPairGenerator generator;
		try {
			generator = KeyPairGenerator.getInstance("RSA");
			generator.initialize(1024);

			KeyPair keyPair = generator.genKeyPair();
			KeyFactory keyFactory = KeyFactory.getInstance("RSA");
			PublicKey publicKey = keyPair.getPublic();
			PrivateKey privateKey = keyPair.getPrivate();

			session.setAttribute("_RSA_WEB_Key_", privateKey); // session에 RSA 개인키를 세션에 저장

			RSAPublicKeySpec publicSpec = keyFactory.getKeySpec(publicKey, RSAPublicKeySpec.class);
			String publicKeyModulus = publicSpec.getModulus().toString(16);
			String publicKeyExponent = publicSpec.getPublicExponent().toString(16);

			request.setAttribute("RSAModulus", publicKeyModulus); // rsa modulus 를 request 에 추가
			request.setAttribute("RSAExponent", publicKeyExponent); // rsa exponent 를 request 에 추가
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

}
