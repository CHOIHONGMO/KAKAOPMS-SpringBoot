package com.st_ones.evermp.SMY1.web;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 28 오전 11:44
 */

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS03.service.BS0301_Service;
import com.st_ones.evermp.BS03.service.BS0302_Service;
import com.st_ones.evermp.SMY1.service.SMY101_Service;
import com.st_ones.eversrm.main.service.MSI_Service;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/SMY1/SMY101")
public class SMY101_Controller extends BaseController {

	@Autowired
	SMY101_Service smy101_Service;
	
    @Autowired 
    private MSI_Service mainService;	
    
    @Autowired 
    private MessageService messageService;

	@Autowired 
	private CommonComboService commonComboService;
	
	@Autowired 
	private MessageService msg;

	@Autowired
	BS0302_Service bs0302Service;

	@Autowired
	BS0301_Service bs0301Service;

	/** ******************************************************************************************
     * 협력사 납품게시판
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SMY1_030/view")
	public String smy1030_view(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		
		return "/evermp/SMY1/SMY1_030";
	}

	@RequestMapping(value = "/smy1030_doSearch")
	public void smy1030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", smy101_Service.smy1030_doSearch(req.getFormData()));
	}
	
	/** ******************************************************************************************
     * 개인정보관리
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SMY1_040/view")
	public String SMY1_040_VIEW(EverHttpRequest req) throws Exception {

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
		req.setAttribute("realDomainUrl", (PropertiesManager.getString("eversrm.system.developmentFlag").equals("false") ? PropertiesManager.getString("eversrm.system.domainUrl") : PropertiesManager.getString("eversrm.system.domainUrl") + ":" + PropertiesManager.getString("eversrm.system.domainPort")));
		req.setAttribute("eversrmSystemDomainPortHttp", PropertiesManager.getString("eversrm.system.domainPort.http"));
        req.setAttribute("userType", userInfo.getUserType());
		
		return "/evermp/SMY1/SMY1_040";
	}
	
    @RequestMapping(value = "/smy1040_saveUser")
    public void smy1040_saveUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> formData = req.getFormData();
        
        String pwd = EverString.nullToEmptyString(formData.get("PASSWORD_CHECK1")).trim();
		String pwdChk = EverString.nullToEmptyString(formData.get("PASSWORD_CHECK2")).trim();

		if(pwd.equals("")&&pwdChk.equals("")){

		}else{
			if(pwd.length() <= 0 || pwdChk.length() <= 0) {
				throw new EverException(msg.getMessageByScreenId("MY01_005", "028"));
			}

			if(! pwd.equals(pwdChk)) {
				throw new EverException(msg.getMessageByScreenId("MY01_005", "027"));
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

        httpSession.setAttribute("ses", baseInfo);
        UserInfoManager.createUserInfo(baseInfo);
        messageService.setCommonMessage(httpSession);

        resp.setParameter("chkFlag", "0001");
        resp.setResponseMessage(strMsg);
        resp.setResponseCode("true");
    }

	/** ******************************************************************************************
	 * 사용자관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/SMY1_050/view")
	public String SMY1_050_VIEW(EverHttpRequest req) throws Exception {

		return "/evermp/SMY1/SMY1_050";
	}

	//사용자조회
	@RequestMapping(value="/smy1050_doSearch")
	public void smy1050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bs0302Service.bs03005_doSearch(param));
	}

	//사용자수정
	@RequestMapping(value="/smy1050_doUpdate")
	public void smy1050_doUpdate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = bs0302Service.bs03005_doUpdate(gridList);

		resp.setResponseMessage(returnMsg);
	}

	//사용자 삭제
	@RequestMapping(value="/smy1050_doDelete")
	public void smy1050_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = bs0302Service.bs03005_doDelete(gridList);
		resp.setResponseMessage(returnMsg);
	}

	/** ****************************************************************************************************************
	 * 사용자상세
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/SMY1_051/view")
	public String SMY1_051_VIEW(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> formData = new HashMap<String, String>();
		Map<String, String> param = new HashMap<String, String>();

		String userId = EverString.nullToEmptyString(req.getParameter("USER_ID"));

		boolean havePermission = EverString.nullToEmptyString(userInfo.getMngYn()).equals("1");

		if(!userId.equals("")) {
			param.put("USER_ID", userId);
			formData = bs0302Service.bs03005_doSearchInfo(param);
			if(userInfo.getUserId().equals(formData.get("REG_USER_ID"))) {
				havePermission = true;
			}
		}

		boolean detailView = Boolean.parseBoolean(EverString.nullToEmptyString(req.getParameter("detailView")));


		req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));

		req.setAttribute("havePermission", havePermission);
		req.setAttribute("detailView", detailView);
		req.setAttribute("formData", formData);

		return "/evermp/SMY1/SMY1_051";
	}

	//사용자등록/수정
	@RequestMapping(value="/smy1051_doSave")
	public void smy1051_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String returnMsg = smy101_Service.smy1051_doSave(req.getFormData());
		resp.setResponseMessage(returnMsg);
	}

	/** ******************************************************************************************
	 * 회사관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/SMY1_060/view")
	public String SMY1_060_VIEW(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> formData = new HashMap<String, String>();
		Map<String, String> param = new HashMap<String, String>();
		boolean havePermission = EverString.nullToEmptyString(userInfo.getMngYn()).equals("1");
		boolean detailView = true;
		if(havePermission==true){
			detailView = false;
		}

		req.setAttribute("regionCd", commonComboService.getCodeCombo("MP005"));
		req.setAttribute("businessList", commonComboService.getCodeCombo("MP040"));
		req.setAttribute("deliberyType", commonComboService.getCodeCombo("MP041"));
		req.setAttribute("dealType", commonComboService.getCodeCombo("MP042"));
		req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));
		param.put("GATE_CD", userInfo.getGateCd());
		param.put("BUYER_CD", userInfo.getManageCd());
		param.put("CTRL_CD", "B100");    //지원직무(고객 및 공급사 담당자)
        req.setAttribute("bacpUserOptions", commonComboService.getCodesAsJson("CB0064", param));
        param.put("CTRL_CD", "P100");    //계산서직무(마감 및 정산 담당자)
        req.setAttribute("payUserOptions", commonComboService.getCodesAsJson("CB0064", param));
		param.put("VENDOR_CD", userInfo.getCompanyCd());
		formData = bs0301Service.bs03002_doSearchInfo(param);
		
		req.setAttribute("havePermission", havePermission);
		req.setAttribute("detailView", detailView);
		req.setAttribute("formData", formData);
		
		return "/evermp/SMY1/SMY1_060";
	}

	// 회사 수정
	@RequestMapping(value = "/smy1060_doSave")
	public void smy1060_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> grid1Datas = req.getGridData("grid1");    //s/g(취급분야)
		List<Map<String, Object>> gridTxDatas = req.getGridData("gridtx");    //계산서사용자
		List<Map<String, Object>> gridVncp = req.getGridData("gridVncp");    //계산서사용자

		Map<String, String> rtnMap = smy101_Service.smy1060_doSave(formData, grid1Datas,gridTxDatas, gridVncp);
		resp.setResponseMessage(rtnMap.get("rtnMsg"));
		resp.setParameter("VENDOR_CD", rtnMap.get("VENDOR_CD"));
	}

}
