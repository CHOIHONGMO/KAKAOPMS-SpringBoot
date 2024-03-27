package com.st_ones.evermp.MY01.web;

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
import com.st_ones.evermp.MY01.service.MY01_Service;
import com.st_ones.eversrm.main.service.MSI_Service;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
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
 * @File Name : MY01_Controller.java
 * @author  이연무
 * @date 2018. 01. 30.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/MY01")
public class MY01_Controller extends BaseController {

	@Autowired private MY01_Service my01_Service;

    @Autowired private MSI_Service mainService;

    @Autowired private MessageService messageService;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 공지사항
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_001/view")
	public String my01001_view(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }



		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.addDateMonth(EverDate.getDate(), +2));
		return "/evermp/MY01/MY01_001";
	}

	@RequestMapping(value = "/my01001_doSearch")
	public void my01001_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my01_Service.my01001_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/my01001_doDelete")
	public void my01001_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = my01_Service.my01001_doDelete(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
     * 공지사항 - 작성
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_002/view")
	public String my01002_view(EverHttpRequest req) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		Map<String, Object> formData = new HashMap<String, Object>();
		UserInfo userInfo = UserInfoManager.getUserInfo();

		boolean havePermission = false;
		String noticeNum = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));
		String detailView = EverString.nullToEmptyString(req.getParameter("detailView"));

		if(!noticeNum.equals("")) {
			param.put("NOTICE_NUM", noticeNum);
			param.put("detailView", detailView);
			formData = my01_Service.my01001_doSearchNoticeInfo(param);
            havePermission = userInfo.getUserId().equals(String.valueOf(formData.get("REG_USER_ID")));
		} else {
			formData.put("START_DATE", EverDate.getDate());
			formData.put("REG_USER_NAME", userInfo.getUserNm());
			formData.put("USER_TYPE", "USNA"); // 게시구분 : 전체
			formData.put("ANN_FLAG", "0"); // 공지구분 : N
			havePermission = true;
		}

		req.setAttribute("formData", formData);
		req.setAttribute("havePermission", havePermission);
		return "/evermp/MY01/MY01_002";
	}

	@RequestMapping(value = "/my01002_doSave")
	public void my01002_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> rtnMap = my01_Service.my01002_doSave(req.getFormData());
		resp.setParameter("NOTICE_NUM", rtnMap.get("NOTICE_NUM"));
		resp.setResponseMessage(rtnMap.get("rtnMsg"));
	}

	@RequestMapping(value = "/my01002_doDelete")
	public void my01002_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = my01_Service.my01002_doDelete(req.getFormData());
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
     * 납품게시판
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_003/view")
	public String my01003_view(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.addDateMonth(EverDate.getDate(), +2));



        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }



		return "/evermp/MY01/MY01_003";
	}

	@RequestMapping(value = "/my01003_doSearch")
	public void my01003_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", my01_Service.my01003_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/my01003_doDelete")
	public void my01003_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = my01_Service.my01003_doDelete(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
     * 납품게시판 - 작성
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_004/view")
	public String my01004_view(EverHttpRequest req) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		Map<String, Object> formData = new HashMap<String, Object>();

		UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		boolean havePermission = false;
		String noticeNum = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));
		String detailView = EverString.nullToEmptyString(req.getParameter("detailView"));

		if(!noticeNum.equals("")) {
			param.put("NOTICE_NUM", noticeNum);
			param.put("detailView", detailView);
			formData = my01_Service.my01004_doSearchNoticeInfo(param);

            havePermission = userInfo.getUserId().equals(String.valueOf(formData.get("REG_USER_ID")));
		} else {
			formData.put("START_DATE", EverDate.getDate());
			formData.put("REG_USER_NM", userInfo.getUserNm());
			havePermission = true;
		}

		req.setAttribute("formData", formData);
		req.setAttribute("havePermission", havePermission);
		req.setAttribute("buyerCdOptions", commonComboService.getCodeComboAsJson("CB0002"));

		return "/evermp/MY01/MY01_004";
	}

	@RequestMapping(value = "/my01004_doSave")
	public void my01004_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> rtnMap = my01_Service.my01004_doSave(req.getFormData());
		resp.setParameter("NOTICE_NUM", rtnMap.get("NOTICE_NUM"));
		resp.setResponseMessage(rtnMap.get("rtnMsg"));
	}

	@RequestMapping(value = "/my01004_doDelete")
	public void my01004_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = my01_Service.my01004_doDelete(req.getFormData());
		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
     * 개인정보관리
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_005/view")
	public String my01005_view(EverHttpRequest req) throws Exception {

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

		return "/evermp/MY01/MY01_005";
	}

    @RequestMapping(value = "/my01005_saveUser")
    public void my01005_saveUser(EverHttpRequest req, EverHttpResponse resp) throws Exception {

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

    @RequestMapping(value = "/my01005_doSearchG")
    public void my01005_doSearchG(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfoImpl();

    	Map<String, String> param = new HashMap<String, String>();
        param.put("CUST_CD", userInfo.getCompanyCd());
        param.put("USER_ID", userInfo.getUserId());
        resp.setGridObject("grid", my01_Service.my01005_doSearchG(param));
    }

    @RequestMapping(value = "/my01005_doSaveG")
    public void my01005_doSaveG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = my01_Service.my01005_doSaveG(req.getGridData("grid"));
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/my01005_doDeleteG")
    public void my01005_doDeleteG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	String rtnMsg = my01_Service.my01005_doDeleteG(req.getGridData("grid"));
    	resp.setResponseMessage(rtnMsg);
    }

    /** ******************************************************************************************
     * 배송지목록
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_006/view")
	public String my01006_view(EverHttpRequest req) throws Exception {
		return "/evermp/MY01/MY01_006";
	}

	@RequestMapping(value = "/my01006_doSearch")
    public void my01006_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("CUST_CD", req.getParameter("CUST_CD"));
        param.put("USER_ID", req.getParameter("USER_ID"));
        resp.setGridObject("grid", my01_Service.my01006_doSearch(param));
    }

	/** ******************************************************************************************
     * 배송지목록--NEW
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_007/view")
	public String my01007_view(EverHttpRequest req) throws Exception {
		return "/evermp/MY01/MY01_007";
	}

	@RequestMapping(value = "/my01007_doSearch")
    public void my01007_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        param.put("CUST_CD", req.getParameter("CUST_CD"));
        resp.setGridObject("gridD", my01_Service.my01007_doSearch(param));
    }




	/** ******************************************************************************************
     * 청구지목록
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_008/view")
	public String my01008_view(EverHttpRequest req) throws Exception {
		return "/evermp/MY01/MY01_008";
	}

	@RequestMapping(value = "/my01008_doSearch")
    public void my01008_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("CUST_CD", req.getParameter("CUST_CD"));
        resp.setGridObject("grid", my01_Service.my01008_doSearch(param));
    }

	/** ******************************************************************************************
     * 관심업체 관리
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/MY01_010/view")
	public String my01010_view(EverHttpRequest req) throws Exception {



		UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }






		return "/evermp/MY01/MY01_010";
	}

	@RequestMapping(value = "/my01010_doSearch")
    public void my01010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        resp.setGridObject("gridH", my01_Service.my01010_doSearch(param));
    }

	@RequestMapping(value = "/my01010_doSearchD")
    public void my01010_doSearchD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
		String TPL_NO = EverString.nullToEmptyString(req.getParameter("TPL_NO"));
		param.put("TPL_NO",TPL_NO);
        resp.setGridObject("gridD", my01_Service.my01010_doSearchD(param));
    }

    @RequestMapping(value = "/my01010_doSave")
    public void my01010_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = my01_Service.my01010_doSave(req.getGridData("gridH"));
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/my01010_doDelete")
    public void my01010_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = my01_Service.my01010_doDelete(req.getGridData("gridH"));
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/my01010_doSaveD")
    public void my01010_doSaveD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> param = req.getFormData();
        String rtnMsg = my01_Service.my01010_doSaveD(req.getGridData("gridD"),param);
        resp.setResponseMessage(rtnMsg);
    }

    @RequestMapping(value = "/my01010_doDeleteD")
    public void my01010_doDeleteD(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        String rtnMsg = my01_Service.my01010_doDeleteD(req.getGridData("gridD"));
        resp.setResponseMessage(rtnMsg);
    }

}
