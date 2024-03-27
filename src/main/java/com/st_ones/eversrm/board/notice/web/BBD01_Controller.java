package com.st_ones.eversrm.board.notice.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.board.notice.service.BBD01_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 */

@Controller
@RequestMapping(value = "/eversrm/buyer/board")
public class BBD01_Controller extends BaseController {

	@Autowired private BBD01_Service bbd01_service;

	@Autowired private CommonComboService commonComboService;

	@Autowired MessageService msg;



	/********************************************************************************************
     * 고객사 > My Page > My Page > 게시판  (MY01_003 > BBD01_020)
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BBD01_020/view")
	public String BBD01_020_view(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		/*req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -2));
		req.setAttribute("addToDate", EverDate.getDate());*/

		req.setAttribute("NOTICE_TYPE",req.getParameter("NOTICE_TYPE"));
		return "/eversrm/board/BBD01_020";
	}

	@RequestMapping(value = "/BBD01_020_doSearch")
	public void BBD01_020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bbd01_service.BBD01_020_doSearch(param));
	}

	@RequestMapping(value = "/BBD01_020_doDelete")
	public void BBD01_020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		UserInfo userInfo = UserInfoManager.getUserInfo();
		boolean havePermission = false;
		String rtnMsg = "";
		havePermission = userInfo.getUserId().equals(String.valueOf(gridData.get(0).get("REG_USER_ID")));

		if(havePermission) {
			rtnMsg = bbd01_service.BBD01_020_doDelete(req.getGridData("grid"));
		} else {
			rtnMsg = msg.getMessage("0037"); //권한이 없습니다.
		}

		resp.setResponseMessage(rtnMsg);
	}

	/********************************************************************************************
     * 고객사 > My Page > My Page > 게시판-작성  (MY01_004 > BBD01_021)
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BBD01_021/view")
	public String BBD01_021_view(EverHttpRequest req) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		Map<String, Object> formData = new HashMap<String, Object>();
		UserInfo userInfo = UserInfoManager.getUserInfo();
		String noticeType = "";
		String ctrlCd = userInfo.getCtrlCd();

		if(ctrlCd != null && ctrlCd.indexOf("B200") > -1){
			req.setAttribute("ctrlFlag","Y");
		} else {
			req.setAttribute("ctrlFlag","N");
		}

		boolean havePermission = false;
		String noticeNum = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));
		String detailView = EverString.nullToEmptyString(req.getParameter("detailView"));

		if(!noticeNum.equals("")) { //수정/상세
			param.put("NOTICE_NUM", noticeNum);
			param.put("detailView", detailView);
			formData = bbd01_service.BBD01_021_doSearchNoticeInfo(param);
			formData.put("MOD_DATE", EverDate.getDate());
            havePermission = userInfo.getUserId().equals(String.valueOf(formData.get("REG_USER_ID")));
		} else { // 신규등록
			formData.put("START_DATE", EverDate.getDate());
			formData.put("REG_USER_NM", userInfo.getUserNm());
			formData.put("REG_DATE", EverDate.getDate());
			formData.put("INS_DATE", EverDate.getDate());
			havePermission = true;
		}

		if(req.getParameter("NOTICE_TYPE") != null){
			noticeType = req.getParameter("NOTICE_TYPE");
		} else if (formData.get("NOTICE_TYPE") != null) {
			noticeType = (String)formData.get("NOTICE_TYPE");
		}

		param.put("NOTICE_TYPE",noticeType);
		formData.put("title",commonComboService.getCodes("CB0011", param).get(0).get("NOTICE_TYPE"));
		formData.put("NOTICE_TYPE", noticeType);

		req.setAttribute("formData", formData);
		req.setAttribute("havePermission", havePermission);
		req.setAttribute("buyerCdOptions", commonComboService.getCodeComboAsJson("CB0002"));

		return "/eversrm/board/BBD01_021";
	}

	@RequestMapping(value = "/BBD01_021_doSave")
	public void BBD01_021_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> rtnMap = bbd01_service.BBD01_021_doSave(req.getFormData());
		resp.setParameter("NOTICE_NUM", rtnMap.get("NOTICE_NUM"));
		resp.setResponseMessage(rtnMap.get("rtnMsg"));
	}

	/*@RequestMapping(value = "/BBD01_021_doDelete")
	public void BBD01_021_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, Object> formData = (Map)req.getFormData();
		UserInfo userInfo = UserInfoManager.getUserInfo();
		boolean havePermission = false;
		String rtnMsg = "";
		havePermission = userInfo.getUserId().equals(String.valueOf(formData.get("REG_USER_ID")));

		if(havePermission) {
			rtnMsg = bbd01_service.BBD01_021_doDelete((Map)formData);
		} else {
			rtnMsg = msg.getMessage("0037"); //권한이 없습니다.
		}
		resp.setResponseMessage(rtnMsg);
	}*/

	/********************************************************************************************
	 * 고객사 > My Page > My Page > ESH게시판  (BBD01_030)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/BBD01_030/view")
	public String BBD01_030(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.addDateMonth(EverDate.getDate(), +2));
		return "/eversrm/buyer/board/BBD01_030";
	}

	@RequestMapping(value = "/BBD01_030_doSearch")
	public void BBD01_030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bbd01_service.BBD01_030_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/BBD01_030_doDelete")
	public void BBD01_030_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bbd01_service.BBD01_030_doDelete(req.getGridData("grid"));
		resp.setResponseMessage(rtnMsg);
	}

	/********************************************************************************************
	 * 고객사 > My Page > My Page > ESH게시판-작성  (BBD01_031)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/BBD01_031/view")
	public String BBD01_031(EverHttpRequest req) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		Map<String, Object> formData = new HashMap<String, Object>();
		UserInfo userInfo = UserInfoManager.getUserInfo();

		boolean havePermission = false;
		String noticeNum = EverString.nullToEmptyString(req.getParameter("NOTICE_NUM"));
		String detailView = EverString.nullToEmptyString(req.getParameter("detailView"));

		if(!noticeNum.equals("")) {
			param.put("NOTICE_NUM", noticeNum);
			param.put("detailView", detailView);
			formData = bbd01_service.BBD01_031_doSearchNoticeInfo(param);
			havePermission = userInfo.getUserId().equals(String.valueOf(formData.get("REG_USER_ID")));
		} else {
			formData.put("START_DATE", EverDate.getDate());
			formData.put("REG_USER_NAME", userInfo.getUserNm());
			formData.put("USER_TYPE", "USNA"); // 게시구분 : 전체
			formData.put("ANN_FLAG", "0"); // 공지구분 : N
			formData.put("FIXED_TOP_FLAG", "0"); //최상단게시여부 : N
			havePermission = true;
		}

		req.setAttribute("formData", formData);
		req.setAttribute("havePermission", havePermission);
		return "/eversrm/buyer/board/BBD01_031";
	}

	@RequestMapping(value = "/BBD01_031_doSave")
	public void BBD01_031_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> rtnMap = bbd01_service.BBD01_031_doSave(req.getFormData());
		resp.setParameter("NOTICE_NUM", rtnMap.get("NOTICE_NUM"));
		resp.setResponseMessage(rtnMap.get("rtnMsg"));
	}

	@RequestMapping(value = "/BBD01_031_doDelete")
	public void BBD01_031_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String rtnMsg = bbd01_service.BBD01_031_doDelete(req.getFormData());
		resp.setResponseMessage(rtnMsg);
	}


}
