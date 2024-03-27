/*
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 */
package com.st_ones.eversrm.main.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.config.service.EverConfigService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.util.clazz.SessionIgnore;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.main.service.MSI_Service;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = {"/eversrm/main", "/"})
public class MSI_Controller extends BaseController {

    @Autowired
    private MessageService messageService;

    @Autowired
    private CommonComboService commonComboService;

    @Autowired
    private EverConfigService everConfigService;

    @Autowired
    private MSI_Service mainService;

//	@Autowired
//	private UserService userService;

    @Autowired
    private MessageService msg;

    private static final String SMS_FINDPASSWORD_FLAG = "eversrm.sms.findPassword.flag";
    private static final String MAIL_FINDPASSWORD_FLAG = "eversrm.mail.findPassword.flag";

    private String smsFindPasswordFlag;
    private String smsMailPasswordFlag;

    @SessionIgnore
    @RequestMapping(value = "/join_popup/view")
    public String join_popup(EverHttpRequest req) throws Exception {
//		String GateCd = (String)httpSession.getAttribute("GateCd");
        String defaultGateCd = PropertiesManager.getString("eversrm.gateCd.default");
        req.setAttribute("smsAcceptFlag", everConfigService.getHouseConfig(defaultGateCd, SMS_FINDPASSWORD_FLAG));
        smsMailPasswordFlag = everConfigService.getHouseConfig(defaultGateCd, MAIL_FINDPASSWORD_FLAG);
        smsFindPasswordFlag = everConfigService.getHouseConfig(defaultGateCd, SMS_FINDPASSWORD_FLAG);
        return "/join_popup";
    }

    @RequestMapping(value = "/MSI_030/view")
    public String findIdPassword(EverHttpRequest req) throws Exception {
//		String GateCd = (String)httpSession.getAttribute("GateCd");
        String defaultGateCd = PropertiesManager.getString("eversrm.gateCd.default");
        req.setAttribute("smsAcceptFlag", everConfigService.getHouseConfig(defaultGateCd, SMS_FINDPASSWORD_FLAG));
        smsMailPasswordFlag = everConfigService.getHouseConfig(defaultGateCd, MAIL_FINDPASSWORD_FLAG);
        smsFindPasswordFlag = everConfigService.getHouseConfig(defaultGateCd, SMS_FINDPASSWORD_FLAG);
        return "/eversrm/main/MSI_030";
    }

    @SessionIgnore
    @RequestMapping(value = "/MSI_030/doFindID")
    public void doFindIDFindIdPassword(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        Map<String, Object> formData = mainService.doFindIDFindIdPassword(param);
        String listJson = new ObjectMapper().writeValueAsString(formData);
        resp.setParameter("formDatas", listJson);
        resp.setResponseCode("true");
    }

    @SessionIgnore
    @RequestMapping(value = "/MSI_030/doFindPassword")
    public void doFindPasswordFindIdPassword(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("smsMailPasswordFlag", smsMailPasswordFlag);
        param.put("smsFindPasswordFlag", smsFindPasswordFlag);
        resp.setResponseMessage(mainService.doFindPasswordFindIdPassword(param));
        resp.setResponseCode("true");
    }

    @RequestMapping(value = "/MSI_040/view")
    public String newCompanyReg(@SuppressWarnings("unused") EverHttpRequest req) throws Exception {
        return "/eversrm/main/MSI_040";
    }

    @RequestMapping(value = "/MSI_050/view")
    public String agreementNewCompanyReg() throws Exception {
        return "/eversrm/main/MSI_050";
    }

    @RequestMapping(value = "/MSI_060/view")
    public String checkUserInfo(EverHttpRequest req) throws Exception {
        HttpSession httpSession = req.getSession();
        String userType = (String)httpSession.getAttribute("userType");
        Map<String, Object> formData = new HashMap<String, Object>();

        formData.put("GATE_CD", req.getParameter("gateCd"));
        formData.put("LANG_CD", req.getParameter("langCd"));
        formData.put("IRS_NUM", req.getParameter("irsNum"));
        formData.put("USER_TYPE", userType);
        req.setAttribute("searchParam", formData);
        return "/eversrm/main/MSI_060";
    }

    //
//	@RequestMapping(value = "/postNoticeList/view")
//	public String postNoticeList(EverHttpRequest req) throws Exception {
//		HttpSession httpSession = req.getSession();
//		String GateCd = (String)httpSession.getAttribute("GateCd");
//		String langCd = (String)httpSession.getAttribute("langCd");
//		String noticeType = (String)httpSession.getAttribute("noticeType");
//
//		req.setAttribute("GateCd", GateCd);
//		req.setAttribute("langCd", langCd);
//		req.setAttribute("noticeType", noticeType);
//
//		Map<String, String> param = new HashMap<String, String>();
//		param.put("GATE_CD", GateCd);
//		param.put("LANG_CD", langCd);
//		param.put("NOTICE_TYPE", noticeType);
//		param.put("SUBJECT", "");
//		param.put("TEXT_CONTENTS", "");
//
//		req.setValueObject("gridData", mainService.getPostNoticeList(param));
//
//		return "/eversrm/main/postNoticeList";
//	}
//
//	@RequestMapping(value = "/postNoticeList/doSearchPostNoticeList")
//	public void doSearchPostNoticeList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
//		HttpSession httpSession = req.getSession();
//		String GateCd = (String)httpSession.getAttribute("GateCd");
//		String langCd = (String)httpSession.getAttribute("langCd");
//		String noticeType = (String)httpSession.getAttribute("noticeType");
//
//		Map<String, String> param = req.getValueObject("formData");
//		param.put("GATE_CD", GateCd);
//		param.put("LANG_CD", langCd);
//		param.put("NOTICE_TYPE", noticeType);
//
//		req.setValueObject("gridData", mainService.getPostNoticeList(param));
//
//		resp.setResponseCode("true");
//	}
//
//	@RequestMapping(value = "/newCompanyReg/view")
//	public String newCompanyReg(@SuppressWarnings("unused") EverHttpRequest req) throws Exception {
//		return "/eversrm/main/newCompanyReg";
//	}
//
//	@RequestMapping(value = "/checkUserInfo/view")
//	public String checkUserInfo(EverHttpRequest req) throws Exception {
//		HttpSession httpSession = req.getSession();
//		String userType = (String)httpSession.getAttribute("userType");
//		Map<String, Object> formData = new HashMap<String, Object>();
//
//		formData.put("GATE_CD", req.getParameter("houseCode"));
//		formData.put("LANG_CD", req.getParameter("langCd"));
//		formData.put("IRS_NUM", req.getParameter("irsNum"));
//		formData.put("USER_TYPE", userType);
//		req.setValueObject("searchParam", formData);
//		return "/eversrm/main/checkUserInfo";
//	}
//
	@RequestMapping(value = "/checkUserInfo/doRegister")
	public void doRegister(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		Map<String, Object> formData = mainService.doRegister(param);
		String listJson = new ObjectMapper().writeValueAsString(formData);
		resp.setParameter("formDatas", listJson);
		resp.setResponseCode("true");
	}
//
	@RequestMapping(value = "/checkUserInfo/doChange")
	public void doChange(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		Map<String, Object> formData = mainService.doChange(param);
		String listJson = new ObjectMapper().writeValueAsString(formData);
		resp.setParameter("formDatas", listJson);
		resp.setResponseCode("true");
	}

	//	//////	  userInfoReg - MSI_070  //////
	@RequestMapping(value = "/MSI_070/view")
	public String userInfoReg(EverHttpRequest req) throws Exception {
		HttpSession httpSession = req.getSession();
		String GateCd = (String)httpSession.getAttribute("GateCd");
		String langCd = (String)httpSession.getAttribute("langCd");
		String callBackFunction = (String)httpSession.getAttribute("callBackFunction");
		req.setAttribute("GateCd", GateCd);
		req.setAttribute("langCd", langCd);
		req.setAttribute("callBackFunction", callBackFunction);
		req.setAttribute("userType", commonComboService.getCodeComboAsJson("M006"));
		req.setAttribute("workType", commonComboService.getCodeComboAsJson("M007"));
		req.setAttribute("langCd", commonComboService.getCodeComboAsJson("M001"));
		req.setAttribute("countryCd", commonComboService.getCodeComboAsJson("M004"));
		req.setAttribute("gmtCd", commonComboService.getCodeComboAsJson("M005"));
		req.setAttribute("superUserType", commonComboService.getCodeComboAsJson("M044"));
		req.setAttribute("userDateFormat", commonComboService.getCodeComboAsJson("M054"));
		req.setAttribute("userNumberFormat", commonComboService.getCodeComboAsJson("M055"));

		return "/eversrm/main/MSI_070";
	}
//
//	@RequestMapping(value = "/agreementNewCompanyReg/view")
//	public String agreementNewCompanyReg() throws Exception {
//		return "/eversrm/main/agreementNewCompanyReg";
//	}
//
    @RequestMapping(value = "/userInfoChange/view")
    public String viewUserInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        req.setAttribute("userDateFormat", commonComboService.getCodeComboAsJson("M054"));
        req.setAttribute("gmtCd", commonComboService.getCodeComboAsJson("M005"));
        req.setAttribute("countryCd", commonComboService.getCodeComboAsJson("M004"));
        req.setAttribute("langCd", commonComboService.getCodeComboAsJson("M001"));
        req.setAttribute("numCd", commonComboService.getCodeComboAsJson("M055"));

        Map<String, String> param = new HashMap<String, String>();
        String userId = userInfo.getUserId();
        param.put("userId", userId);
        req.setAttribute("form", mainService.selectUser(param));
		req.setAttribute("everSslUseFlag", PropertiesManager.getString("ever.ssl.use.flag"));
		req.setAttribute("eversrmSystemDomainPort", PropertiesManager.getString("eversrm.system.domainPort"));
		req.setAttribute("eversrmSystemDomainUrl", PropertiesManager.getString("eversrm.system.domainUrl"));
		req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));
        req.setAttribute("realDomainUrl", (PropertiesManager.getString("eversrm.system.developmentFlag").equals("false") ? PropertiesManager.getString("eversrm.system.domainUrl") : PropertiesManager.getString("eversrm.system.domainUrl") + ":" + PropertiesManager.getString("eversrm.system.domainPort")));
        req.setAttribute("userType", userInfo.getUserType());

        return "/eversrm/main/userInfoChange";
    }

    @RequestMapping(value = "/userInfoChange/saveUser")
    public void saveUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        
        String pwd    = EverString.nullToEmptyString(formData.get("PASSWORD_CHECK1")).trim();
		String pwdChk = EverString.nullToEmptyString(formData.get("PASSWORD_CHECK2")).trim();
		
		if( pwd.equals("") && pwdChk.equals("") ){
			
		} else {
			if(pwd.length() <= 0 || pwdChk.length() <= 0) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "028"));
			}
			if(!pwd.equals(pwdChk)) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "027"));
			}
		}

        String strMsg = mainService.saveUser(formData);

        HttpSession httpSession = req.getSession();

        UserInfo baseInfo = UserInfoManager.getUserInfoImpl();
        baseInfo.setUserNmEng(formData.get("USER_NM_ENG"));
        baseInfo.setUserNm(formData.get("USER_NM"));
        baseInfo.setEmail(formData.get("EMAIL"));
        baseInfo.setTelNum(formData.get("TEL_NUM"));
        baseInfo.setCellNum(formData.get("CELL_NUM"));
        baseInfo.setLangCd(formData.get("LANG_CD"));
        baseInfo.setUserGmt(formData.get("GMT_CD"));
        baseInfo.setFaxNum(formData.get("FAX_NUM"));
        String userType = UserInfoManager.getUserInfo().getUserType();

        // 운영사
        if (userType.equals("C")) {
            baseInfo.setDateFormat(mainService.getUserDateFormat(formData).get("USER_DATE_FORMAT_VALUE"));
            baseInfo.setNumberFormat(mainService.getUserDateFormat(formData).get("USER_NUMBER_FORMAT_VALUE"));
        }

        httpSession.setAttribute("ses", baseInfo);
        UserInfoManager.createUserInfo(baseInfo);
        messageService.setCommonMessage(httpSession);

        resp.setParameter("chkFlag", "0001");
        resp.setResponseMessage(strMsg);
        resp.setResponseCode("true");
    }

	@RequestMapping(value = "/getBaseLoginInfo")
	public void getBaseLoginInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		@SuppressWarnings("unchecked")
		Map<String, String> userInfoMap = new ObjectMapper().readValue(req.getParameter("userId"), Map.class);
		Map<String, String> baseLoginInfo = mainService.getBaseLoginInfo(userInfoMap);
		if (baseLoginInfo != null) {
			baseLoginInfo.put("sessionId", req.getRequestedSessionId());
			resp.setParameter("baseLoginInfo", new ObjectMapper().writeValueAsString(baseLoginInfo));
		}
		resp.setResponseCode("true");
	}

//	@RequestMapping(value = "/histroyOffView")
//	public String histroyOffView(EverHttpRequest req) throws Exception {
//		BaseInfo baseInfoData = (BaseInfo)req.getSession(true).getAttribute("ses");
//
//		req.getRequest().setAttribute("CTRL_Info", mainService.getCTRLInfo(baseInfoData));
//
//		Map<String, Object> paramData = new HashMap<String, Object>();
//		paramData.put("ses", baseInfoData);
//		paramData.put("USER_ID", baseInfoData.getUserId());
//
//		req.getRequest().setAttribute("acProfile", userService.doGetAcProfile(paramData));
//
//		req.getRequest().setAttribute("auProfile", userService.doGetAuProfile(paramData));
//
//		return "/eversrm/main/histroyOffView";
//	}
//
//	@RequestMapping(value = "/histroyOffSave")
//	public void histroyOffSave(EverHttpRequest req) throws Exception {
//		HttpSession httpSession = req.getSession();
//		BaseInfo baseInfo = UserInfoManager.getUserInfoImpl();
//
//		String paramData = req.getRequest().getParameter("ctrlInfo");
//		if (WiseString.isNotEmpty(paramData)) {
//			baseInfo.setCtrlCode(paramData);
//		}
//
//		paramData = req.getRequest().getParameter("acProfile");
//		if (WiseString.isNotEmpty(paramData)) {
//			baseInfo.setActionAuthCode(paramData);
//		}
//
//		paramData = req.getRequest().getParameter("auProfile");
//		if (WiseString.isNotEmpty(paramData)) {
//			baseInfo.setGrantedAuthCode(paramData);
//		}
//
//		httpSession.setAttribute("ses", baseInfo);
//	}

}