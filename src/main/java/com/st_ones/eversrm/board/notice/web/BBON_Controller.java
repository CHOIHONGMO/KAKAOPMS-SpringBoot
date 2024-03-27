package com.st_ones.eversrm.board.notice.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.board.notice.service.BBON_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : BBON_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = {"/eversrm/board/notice"})
public class BBON_Controller extends BaseController {

	@Autowired private MessageService msg;

	@Autowired
	private CommonComboService commonComboService;

	@Autowired
	LargeTextService largeTextService;

	@Autowired
	private BBON_Service bbonService;

	@RequestMapping(value = "/BBON_020/view")
	public String noticeList(EverHttpRequest req) {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		boolean havePermission = true;

		//직무가 존재하지 않으면 권한이 없음.
		if(!EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1")) {
			havePermission = false;
		}

		//슈퍼관리자
		havePermission = EverString.nullToEmptyString(userInfo.getSuperUserFlag()).equals("1") || havePermission;
		req.setAttribute("havePermission", havePermission);

		return "/eversrm/basic/notice/BBON_020";
	}

	@RequestMapping(value = "/BBON_010/view")
	public String postNotice(EverHttpRequest req) throws Exception {
        UserInfo baseInfo = UserInfoManager.getUserInfo();

		String noticeNo = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));


		req.setAttribute("today", EverDate.getDate());
		req.setAttribute("havePermission", true);
		req.setAttribute("havePermission", checkAuthViewBBON_010());

		if(noticeNo.length() <= 0) {
			if(baseInfo.getUserId().equals("VIRTUAL")) {
				noticeNo = EverString.nullToEmptyString(req.getSession().getAttribute("NOTICE_NUM"));
			}
		}

		if (noticeNo != null && !"".equals(noticeNo)) {
			Map<String, String> formData = bbonService.selectNotice(noticeNo);
			String splitString = largeTextService.selectLargeText(formData.get("NOTICE_TEXT_NUM"));
			formData.put("CONTENTS", splitString);

			//조회한 경우에는 등록자만 권한이 있는 것으로 처리함.
			if("loginPopupNotice".equals(EverString.nullToEmptyString(req.getParameter("loginPopupNotice")))) {
				req.setAttribute("havePermission", true);
				req.setAttribute("detailView", EverString.nullToEmptyString(req.getParameter("detailView")));
				req.setAttribute("popupFlag", EverString.nullToEmptyString(req.getParameter("popupFlag")));
			} else if (EverString.nullToEmptyString(formData.get("REG_USER_ID")).equals(baseInfo.getUserId())) {    //등록자=ses.userId
				req.setAttribute("havePermission", true);
				req.setAttribute("detailView", false);
			} else if (EverString.nullToEmptyString(baseInfo.getSuperUserFlag()).equals("1")) {    //마스터
				req.setAttribute("havePermission", true);
				req.setAttribute("detailView", false);
			} else {
				req.setAttribute("havePermission", false);
				req.setAttribute("detailView", true);
			}

			req.setAttribute("formData", formData);
		} else {

			if(!baseInfo.getUserType().equals("C")){
				req.setAttribute("havePermission", false);
				req.setAttribute("detailView", true);
			}else{
				req.setAttribute("havePermission", true);
				req.setAttribute("detailView", false);
			}
		}



		return "/eversrm/basic/notice/BBON_010";
	}

	private boolean checkAuthViewBBON_010() {
        UserInfo baseInfo = UserInfoManager.getUserInfo();
		boolean havePermission = true;

		//직무가 존재하지 않으면 권한이 없음.
		if( !EverString.nullToEmptyString(baseInfo.getSuperUserFlag()).equals("1")) {
			havePermission = false;
		}

		return havePermission;
	}

	@RequestMapping(value = "/noticeContent/view")
	public String noticeContent(EverHttpRequest req) throws Exception {
		String userId = UserInfoManager.getUserInfo().getUserId();
		String noticeNo = null;
		if ("VIRTUAL".equals(userId)) {
			noticeNo = (String)req.getSession().getAttribute("NOTICE_NUM");
		} else {
			noticeNo = req.getParameter("NOTICE_NUM");
		}
		Map<String, String> formData = bbonService.selectNotice(noticeNo);
		String splitString = largeTextService.selectLargeText(formData.get("NOTICE_TEXT_NUM"));
		formData.put("CONTENTS", splitString);
		req.setAttribute("formData", formData);
		return "/eversrm/basic/notice/noticeContent";
	}

	@RequestMapping(value = "/screenNotice/view")
	public String screenNotice() {
		return "/eversrm/basic/notice/screenNotice";
	}

	@RequestMapping(value = "/noticeList/selectNoticeList")
	public void selectNoticeList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		makeGridTextLinkStyle(resp, "grid", "SUBJECT");

		resp.setGridObject("grid", bbonService.selectNoticeList(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/noticeList/deleteNoticeList")
	public void deleteNoticeList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bbonService.deleteNoticeList(gridData);
		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/postNotice/deleteNotice")
	public void deleteNotice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		checkAuthSaveBBON_010(param);

		String msg = bbonService.deleteNotice(param);
		resp.setResponseMessage(msg);


	}

	@RequestMapping(value = "/postNotice/selectNotice")
	public void selectNotice(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param = bbonService.selectNotice(param.get("NOTICE_NUM"));

		String splitString = (param == null ? "" : largeTextService.selectLargeText(param.get("NOTICE_TEXT_NUM")));
		if (param != null) {
			req.setAttribute("searchParam", param);
		}
		resp.setParameter("CONTENTS", splitString);

	}

	private void checkAuthSaveBBON_010(Map<String, String> param) throws Exception {

		boolean havePermission = checkAuthViewBBON_010();
		UserInfo baseInfo = UserInfoManager.getUserInfo();

		String noticeNum = EverString.nullToEmptyString(param.get("NOTICE_NUM"));

		if(noticeNum.length() > 0) {
			Map<String, String> formData = bbonService.selectNotice(noticeNum);

			//조회한 경우에는 등록자만 권한이 있는 것으로 처리함.
            havePermission = EverString.nullToEmptyString(formData.get("REG_USER_ID")).equals(baseInfo.getUserId());
		} else {
			havePermission = true;
		}

		if(EverString.nullToEmptyString(baseInfo.getSuperUserFlag()).equals("1")) {
			havePermission = true;
		}

		if(! havePermission) {
			throw new EverException(msg.getMessage("0008"));
		}
	}

	@RequestMapping(value = "/postNotice/saveNotice")
	public void saveNotice(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		checkAuthSaveBBON_010(param);

		String msg[] = bbonService.saveNotice(param);

		resp.setParameter("NOTICE_NUM", msg[1]);
		resp.setResponseMessage(msg[0]);


	}

	//이미지 텍스트그리드
	private void makeGridTextLinkStyle(EverHttpResponse resp, String grid, String columnName) {
        resp.setGridColStyle(grid, columnName, "cursor", "pointer");
        resp.setGridColStyle(grid, columnName, "color", "#000DFF");
        resp.setGridColStyle(grid, columnName, "text-decoration", "underline");
	}

}