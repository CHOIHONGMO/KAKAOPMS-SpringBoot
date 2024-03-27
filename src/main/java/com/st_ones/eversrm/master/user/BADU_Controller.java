package com.st_ones.eversrm.master.user;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.master.user.service.BADU_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/master/user")
public class BADU_Controller extends BaseController {

	@Autowired
	private BADU_Service baduService;

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	private MessageService msg;

	@RequestMapping(value = "/BADU_050/view")
	public String userSearch(EverHttpRequest req) throws Exception {
		req.setAttribute("refUSER_TYPE", commonComboService.getCodeComboAsJson("M006"));
		return "/eversrm/master/user/BADU_050";
	}

	@RequestMapping(value = "/BADU_050/selectUserSearch")
	public void selectUserSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("mode", EverString.nullToEmptyString(req.getParameter("mode")));
		param.put("buyerCd", EverString.nullToEmptyString(req.getParameter("buyerCd")));

		if (param.get("USER_TYPE").equals("B")) {
			resp.setGridObject("grid", baduService.doSearchUserCust(param));
		} else if (param.get("USER_TYPE").equals("S")) {
			resp.setGridObject("grid", baduService.doSearchUserSup(param));
		} else if (param.get("USER_TYPE").equals("C")){
			resp.setGridObject("grid", baduService.selectUserSearch(param));
		}

    	resp.setResponseCode("true");
	}

	@RequestMapping(value = "/userInformation/view")
	public String userInformation(EverHttpRequest req) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		return "/eversrm/master/user/BSB_060";
	}

	@RequestMapping(value = "/userInformation/doSearchUser")
	public void doSearchUser(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "userType") String userType) throws Exception {

		Map<String, String> formData = req.getFormData(); // <--formL
		formData.put("userType", userType);
		resp.setGridObject("sGrid", baduService.doSearchUser(formData));
	}

	@RequestMapping(value = "/userInformation/doGetUser")
	public void doGetUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData(); // <--formR

		Map<String, Object> userMap;
		if("C".equals(String.valueOf(formData.get("GRID_USER_TYPE")))){
			userMap = baduService.doGetUser(formData);
		}else{
			userMap = baduService.doGetUser_VNGL(formData);
		}

    	String[] userColumns =
    		{
    			  "GATE_CD"
    			, "USER_ID"
    			, "USER_ID_ORI"
    			, "MOD_DATE_LAST"
    			, "MOD_DATE"
    			, "MOD_USER_ID"
    			, "MOD_USER_NM"
    			, "CHANGE_USER_ID"
    			, "DEL_FLAG"
    			, "USE_FLAG"
    			, "COMPANY_CD"
    			, "USER_TYPE"
    			, "WORK_TYPE"
    			, "USER_NM"
    			, "USER_NM_ENG"
    			, "PASSWORD"
    			, "PASSWORD_CHECK"
    			, "TMP_WORD"
    			, "TMP_WORD_CHK"
    			, "DEPT_CD"
    			, "POSITION_NM"
    			, "DUTY_NM"
    			, "EMPLOYEE_NUM"
    			, "EMAIL"
    			, "TEL_NUM"
    			, "CELL_NUM"
    			, "FAX_NUM"
    			, "COUNTRY_CD"
    			, "PROGRESS_CD"
    			, "PW_WRONG_CNT"
    			, "PW_RESET_FLAG"
    			, "PW_RESET_DATE"
    			, "LAST_LOGIN_DATE"
    			, "LAST_LOGIN_TIME"
    			, "IP_ADDR"
    			, "COMPANY_NM"
    			, "DEPT_NM"
    			, "INSERT_FLAG"
    			, "SUPER_USER_FLAG"
    			, "PROGRESS_CD"
    			, "USER_DATE_FORMAT_CD"
    			, "USER_NUMBER_FORMAT_CD"
    		};

    	for(int i = 0; i < userColumns.length; i++) {
    		if(! userMap.containsKey(userColumns[i])) {
    			userMap.put(userColumns[i],  "");
    		}
    	}

		resp.setFormDataObject(userMap);

	}

	@RequestMapping(value = "/userInformation/doGetProfile")
	public void doGetProfile(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "userType") String userType) throws Exception {
    	Map<String, String> formData = req.getFormData(); // <--formR
    	formData.put("userType", userType);

    	resp.setGridObject("acGrid", baduService.doGetAcProfile(formData));
    	resp.setGridObject("auGrid", baduService.doGetAuProfile(formData));
	}


	@SuppressWarnings("cast")
	@RequestMapping(value = "/userInformation/checkPass")
	public void checkPass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formR = req.getFormData();
		String pwd = EverString.nullToEmptyString(formR.get("PASSWORD")).trim();
		String pwdChk = EverString.nullToEmptyString(formR.get("PASSWORD_CHECK")).trim();

		String strMsg = "";
		String userId = formR.get("USER_ID");
		String userIdOri = formR.get("USER_ID_ORI");

		if(! userId.equals(userIdOri)) {
			if(pwd.length() <= 0 || pwdChk.length() <= 0) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "006"));
			}
		}

		if(! pwd.equals(pwdChk)) {
			throw new EverException(msg.getMessageByScreenId("MSI_080", "004"));
		}

		//암호방식 변경
		/*
		if(pwd.length() > 0) {
			pwd = EverEncryption.getEncryptedUserPassword(pwd);
		}

		if(pwdChk.length() > 0) {
			pwdChk = EverEncryption.getEncryptedUserPassword(pwdChk);
		}*/

		if (pwd.equals(pwdChk)) {
			resp.setParameter("PASSWORD", pwd);
			resp.setParameter("chkFlag", "true");
		} else {
			resp.setParameter("PASSWORD", "");
			resp.setParameter("chkFlag", "false");

			strMsg = msg.getMessage("0028");
		}

		resp.setResponseMessage(strMsg);

	}


	@RequestMapping(value = "/userInformation/doSaveUserInfo_VNGL")
	public void doSaveUserInfo_VNGL(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "mode") String mode) throws Exception {
		Map<String, String> formR = req.getFormData();
		List<Map<String, Object>> auGridData = req.getGridData("auGrid");
		String userId = formR.get("USER_ID");
		String userIdOri = formR.get("USER_ID_ORI");
		String passWord = EverString.nullToEmptyString(formR.get("PASSWORD")).trim();
		String passWordCheck = EverString.nullToEmptyString(formR.get("PASSWORD_CHECK")).trim();
		@SuppressWarnings("hiding")
		String msgString = "";
		if (mode.equals("I") && !userId.equals(userIdOri)) {
			if(passWord.length() <= 0 || passWordCheck.length() <= 0) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "006"));
			}

			if(! passWord.equals(passWordCheck)) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "004"));
			}
			//STOCUSER insert
			msgString = baduService.doInsertUserInfo_VNGL(formR, auGridData);
			if (!msgString.equals("confirm")) {
				resp.setParameter("checkResult", "");
			} else {
				resp.setParameter("checkResult", msgString);
			}
		} else {
			if(! passWord.equals(passWordCheck)) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "004"));
			}
			//STOCUSER update
			msgString = baduService.doUpdateUserInfo_VNGL(formR, auGridData);
		}

		resp.setResponseMessage(msgString);
	}



	@RequestMapping(value = "/userInformation/doSaveUserInfo")
	public void doSaveUserInfo(EverHttpRequest req, EverHttpResponse resp, @RequestParam(value = "mode") String mode) throws Exception {
		Map<String, String> formR = req.getFormData();
		List<Map<String, Object>> auGridData = req.getGridData("auGrid");
		List<Map<String, Object>> acGridData = req.getGridData("acGrid");
		String userId = formR.get("USER_ID");
		String userIdOri = formR.get("USER_ID_ORI");
		String passWord = EverString.nullToEmptyString(formR.get("PASSWORD")).trim();

		String passWordCheck = EverString.nullToEmptyString(formR.get("PASSWORD_CHECK")).trim();

		@SuppressWarnings("hiding")
		String msgString = "";
		if (mode.equals("I") && !userId.equals(userIdOri)) {

			if(passWord.length() <= 0 || passWordCheck.length() <= 0) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "006"));
			}

			if(! passWord.equals(passWordCheck)) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "004"));
			}
			//STOCUSER insert
			msgString = baduService.doInsertUserInfo(formR, auGridData, acGridData);
			if (!msgString.equals("confirm")) {
				resp.setParameter("checkResult", "");
			} else {
				resp.setParameter("checkResult", msgString);
				msgString = "중복되는 사용자ID가 존재합니다.";
			}
		} else {
			if(! passWord.equals(passWordCheck)) {
				throw new EverException(msg.getMessageByScreenId("MSI_080", "004"));
			}
			//STOCUSER update
			msgString = baduService.doUpdateUserInfo(formR, auGridData, acGridData);
		}

		resp.setResponseMessage(msgString);

	}

	@RequestMapping(value = "/userInformation/doDeleteUser")
	public void doDeleteUserInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formR = req.getFormData();
		@SuppressWarnings("hiding")
		String msg = baduService.doDeleteUserInfo(formR);

		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/userInformation/doResetLast")
	public void doResetLast(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formR = req.getFormData();

		@SuppressWarnings("hiding")
		String msg = baduService.doResetUserInfo(formR);

		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/passwordNumberIssue/view")
	public String passwordNumberIssue() throws Exception {
		return "/eversrm/master/user/passwordNumberIssue";
	}

	//비밀번호변경
	@RequestMapping(value = "/passwordNumberIssue/doSave")
	public void doSaveIssue(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> form = req.getFormData();

		//비밀번호 암호화방식변경
		//form.put("PASSWORD", EverEncryption.getEncryptedUserPassword(form.get("PASSWORD").toString()));
		@SuppressWarnings("hiding")
		String msg = baduService.doSaveIssue(form);

		resp.setResponseMessage(msg);

	}

	//비밀번호초기화 >
	@RequestMapping(value = "/userInformation/doInitPassword")
	public void doInitPassword(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> form = req.getFormData();
		String msg = baduService.doInitPassword(form);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/passwordNumberIssue/doSave_CVUR")
	public void doSaveIssue_CVUR(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> form = req.getFormData();
		@SuppressWarnings("hiding")
		String msg = baduService.doSaveIssue_CVUR(form);

		resp.setResponseMessage(msg);

	}

	// 비밀번호초기화 - 협력,고객사
	@RequestMapping(value = "/userInformation/doInitPassword_CVUR")
	public void doInitPassword_CVUR(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> form = req.getFormData();
		String gridFlag = req.getParameter("gridFlag");

		if(!"Y".equals(gridFlag)) {
			baduService.doInitPassword_CVUR(form);
		} else {
			List<Map<String, Object>> gridData = req.getGridData("grid");

			for(Map<String, Object> grid : gridData) {
				grid.put("USER_ID", grid.get("USER_ID_$TP"));
				Map<String, String> parseGrid = new HashMap<String, String>((Map) grid);
				baduService.doInitPassword_CVUR(parseGrid);
			}
		}

		resp.setResponseMessage(msg.getMessage("0094"));
	}



	@RequestMapping(value = "/BSB_090/view")
	public String BSB_080(EverHttpRequest req) throws Exception {
		BaseInfo baseInfo = (BaseInfo)req.getSession().getAttribute("ses");
		/* 관리자 권한이 존재하지 않으면 접속 불가 */
        if (!PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
            UserInfo userInfo = UserInfoManager.getUserInfo();
            if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
                return "/eversrm/noSuperAuth";
            }
        }
		return "/eversrm/master/user/BSB_090";
	}


	@RequestMapping(value = "/BSB_090/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", baduService.getTmsList(param));
		resp.setResponseCode("0001");
	}

	@RequestMapping(value = "/BSB_090/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridDatas = req.getGridData("grid");
		String rtnMsg = baduService.saveTms(gridDatas);
		resp.setResponseMessage(rtnMsg);
	}





}