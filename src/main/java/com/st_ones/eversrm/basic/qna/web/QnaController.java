package com.st_ones.eversrm.basic.qna.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.enums.system.Code;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.exception.EverException;
import com.st_ones.everf.serverside.info.BaseInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.basic.qna.service.QnaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm/basic/qna")
public class QnaController extends BaseController {

	@Autowired private MessageService msg;

	@Autowired
	private QnaService qnaService;

	@Autowired
	private CommonComboService commonComboService;

	@RequestMapping(value = "/qnaList/view")
	public String qnaList() throws Exception {
		return "/eversrm/basic/qna/qnaList";
	}

	@RequestMapping(value = "/qnaList/doSearchQnaList")
	public void doSearchQnaList(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", qnaService.doSearchQnaList(param));

	}

	@RequestMapping(value = "/writeQna/view")
	public String writeQna(EverHttpRequest req) throws Exception {
		req.setAttribute("havePermission","false");
		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();
		String qnaNum = "";

		if ( param.get("QNA_NUM") == null || "".equals(param.get("QNA_NUM")) ) {
			param.put("QNA_NUM", req.getParameter("QNA_NUM"));
			param.put("onClose", req.getParameter("onClose"));
			qnaNum = EverString.nullToEmptyString(param.get("QNA_NUM"));
		}

		req.setAttribute("SECRET_FLAG", commonComboService.getCodeComboAsJson("M044"));
		Map<String, String> formMap = new HashMap<String, String>();

		if(qnaNum.length() > 0) {
			formMap = qnaService.doReviewWriteQna(param);
		}

		/* 비밀글이면 작성자나 관리자만 QNA 조회 가능 */
		if(EverString.nullToEmptyString(formMap.get("ROOT_SECRET_FLAG")).equals("1")) {
			if(formMap.get("ROOT_REG_USER_ID").equals(userInfo.getUserId()) ||
					(userInfo.getSuperUserFlag().equals("1") && ! userInfo.getUserType().equals(Code.SUPPLIER))) {
				req.setAttribute("ERROR_MESSAGE", "");
			} else {
				req.setAttribute("ERROR_MESSAGE", msg.getMessage("0142")); // 비밀글입니다. 조회 권한이 존재하지 않습니다.

				for (String mapkey : formMap.keySet()){
					formMap.put(mapkey, "");
				}
			}
		}

		req.setAttribute("form", formMap);
		return "/eversrm/basic/qna/writeQna";
	}

	@RequestMapping(value = "/writeQna/doSave")
	public void doSaveWriteQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formMap = req.getFormData();

		if(EverString.nullToEmptyString(formMap.get("QNA_NUM")).length() > 0) {
			checkQnaAuthority(formMap);
		}

		String[] msg = qnaService.doSaveWriteQna(formMap);
		resp.setResponseMessage(msg[1]);
		resp.setParameter("QNA_NUM", msg[0]);

	}

	private void checkQnaAuthority(Map<String, String> formMap) throws Exception {
		Map<String, String> qnaMap = new HashMap<String, String>();
		UserInfo userInfo = UserInfoManager.getUserInfo();
		qnaMap = qnaService.doReviewWriteQna(formMap);

		if(! userInfo.isOperator()) {
			if(! qnaMap.get("REG_USER_ID").equals(userInfo.getUserId())) {
				throw new EverException(msg.getMessage("0008")); //처리할 권한이 없습니다.
			}
		} else {
			if(! userInfo.isSuperUser() && ! qnaMap.get("REG_USER_ID").equals(userInfo.getUserId())) {
				throw new EverException(msg.getMessage("0008")); //처리할 권한이 없습니다.
			}
		}
	}

	@RequestMapping(value = "/writeQna/doReview")
	public void doReviewWriteQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("QNA_REVIEW_MODE", "1");
		req.setAttribute("form", qnaService.doReviewWriteQna(param));

	}

	@RequestMapping(value = "/writeQna/doDelete")
	public void doDeleteWriteQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> form = req.getFormData();

		if(EverString.nullToEmptyString(form.get("QNA_NUM")).length() > 0) {
			checkQnaAuthority(form);
		}

		String msg = qnaService.doDeleteWriteQna(form);
		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/replyQna/view")
	public String replyQna(EverHttpRequest req) throws Exception {

		Map<String, String> param = req.getFormData();
		UserInfo userInfo = UserInfoManager.getUserInfo();

		param.put("GATE_CD",  req.getParameter("GATE_CD") );
		param.put("QNA_NUM",  req.getParameter("QNA_NUM") );
		param.put("QNA_REVIEW_MODE", "1");
		Map<String, String> qnaMap = qnaService.doReviewWriteQna(param);

		/* 비밀글이면 작성자나 관리자만 QNA 조회 가능 */
		if(EverString.nullToEmptyString(qnaMap.get("ROOT_SECRET_FLAG")).equals("1")) {
			if(qnaMap.get("ROOT_REG_USER_ID").equals(userInfo.getUserId()) ||
			   (userInfo.getSuperUserFlag().equals("1") && ! userInfo.getUserType().equals(Code.SUPPLIER))) {
				req.setAttribute("ERROR_MESSAGE", "");
			} else {
				req.setAttribute("ERROR_MESSAGE", msg.getMessage("0142")); // 비밀글입니다. 조회 권한이 존재하지 않습니다.

				for (String mapkey : qnaMap.keySet()){
			        qnaMap.put(mapkey, "");
			    }
			}
		}

		req.setAttribute("form", qnaMap);
		return "/eversrm/basic/qna/replyQna";
	}

	@RequestMapping(value = "/replyQna/doReview")
	public void doReviewReplyQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("QNA_REVIEW_MODE", "1");

		req.setAttribute("form", qnaService.doReviewWriteQna(param));


	}

	@RequestMapping(value = "/writeReplyQna/view")
	public String writeReplyQna(EverHttpRequest req) throws Exception {

		req.setAttribute("havePermission","false");
		Map<String, String> param = req.getFormData();
		Map<String, String> data = null;
		if ( param.get("QNA_NUM") == null || "".equals(param.get("QNA_NUM")) ) {
			param.put("QNA_NUM", req.getParameter("QNA_NUM"));
			data = qnaService.doReviewWriteQna(param);

			String regUserNm = EverString.nullToEmptyString(data.get("REG_USER_NM"));
			String regDate = EverString.nullToEmptyString(data.get("REG_DATE_QNA"));

            String orgStr = "<p></p><p>----------------------------------</p><strong><p>From : " + regUserNm + " </p>Created Date : " + regDate + "</strong> <p> </p>";
			data.put("EDITOR1", orgStr + EverString.nullToEmptyString(data.get("EDITOR1")));

			if (data.get("SUBJECT").indexOf("RE") < 0 ) {
				data.put("SUBJECT", "RE : " +  EverString.nullToEmptyString(data.get("SUBJECT")));
			}

			BaseInfo baseInfo = (BaseInfo)req.getSession().getAttribute("ses");
			data.put("PARENT_QNA_NUM",data.get("QNA_NUM"));
			data.put("REG_USER_NM", baseInfo.getUserNm()  );
			data.put("REG_DATE", "");
			data.put("QNA_NUM", "");
			data.put("QNA_TEXT_NUM", "");
			data.put("ATT_FILE_NUM", "");
		}

		req.setAttribute("form",  data );
		return "/eversrm/basic/qna/writeReplyQna";
	}

	@RequestMapping(value = "/writeReplyQna/doReview")
	public void doReviewWriteReplyQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		param.put("QNA_REVIEW_MODE", "0");
		req.setAttribute("form", qnaService.doReviewWriteQna(param));

	}

	@RequestMapping(value = "/writeReplyQna/doSave")
	public void doSaveWriteReplyQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formMap = req.getFormData();
		String[] msg = qnaService.doSaveWriteQna(formMap);
		resp.setResponseMessage(msg[1]);
		resp.setParameter("QNA_NUM", msg[0]);

	}

}
