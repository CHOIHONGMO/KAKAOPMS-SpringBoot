package com.st_ones.eversrm.board.qna.web;

import com.st_ones.everf.serverside.web.BaseController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : BBOQ_Controller.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Controller
@RequestMapping(value = "/eversrm/board/qna")
public class BBOQ_Controller extends BaseController {

//	@Autowired
//	private QnaService qnaService;
//
//	//     /////    qna list /////
//
//	@RequestMapping(value = "/qnaList/view")
//	public String qnaList() throws Exception {
//		return "/eversrm/basic/qna/qnaList";
//	}
//
//	@RequestMapping(value = "/qnaList/doSearchQnaList")
//	public void doSearchQnaList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> param = wuxReq.getValueObject("form");
//		wuxReq.setValueObject("gridData", qnaService.doSearchQnaList(param));
//		wuxResp.setResponseCode("true");
//
//	}
//
//	//  /////    write qna  /////
//	@RequestMapping(value = "/writeQna/view")
//	public String writeQna() throws Exception {
//		return "/eversrm/basic/qna/writeQna";
//	}
//
//	@RequestMapping(value = "/writeQna/doSave")
//	public void doSaveWriteQna(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> formMap = wuxReq.getValueObject("form");
//
//		String[] msg = qnaService.doSaveWriteQna(formMap);
//
//		wuxResp.setResponseMessage(msg[1]);
//		wuxResp.setParameter("qna_no", msg[0]);
//		wuxResp.setResponseCode("true");
//	}
//
//	@RequestMapping(value = "/writeQna/doReview")
//	public void doReviewWriteQna(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> param = wuxReq.getValueObject("form");
//		param.put("QNA_REVIEW_MODE", "1");
//
//		wuxReq.setValueObject("form", qnaService.doReviewWriteQna(param));
//		wuxResp.setResponseCode("true");
//	}
//
//	@RequestMapping(value = "/writeQna/doDelete")
//	public void doDeleteWriteQna(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> form = wuxReq.getValueObject("form");
//		String msg = qnaService.doDeleteWriteQna(form);
//
//		wuxResp.setResponseMessage(msg);
//		wuxResp.setResponseCode("true");
//	}
//
//	//  /////    reply qna  /////
//
//	@RequestMapping(value = "/replyQna/view")
//	public String replyQna() throws Exception {
//		return "/eversrm/basic/qna/replyQna";
//	}
//
//	@RequestMapping(value = "/replyQna/doReview")
//	public void doReviewReplyQna(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> param = wuxReq.getValueObject("form");
//		param.put("QNA_REVIEW_MODE", "1");
//
//		wuxReq.setValueObject("form", qnaService.doReviewWriteQna(param));
//		wuxResp.setResponseCode("true");
//
//	}
//
//	//  /////    write reply qna  /////
//
//	@RequestMapping(value = "/writeReplyQna/view")
//	public String writeReplyQna() throws Exception {
//		return "/eversrm/basic/qna/writeReplyQna";
//	}
//
//	@RequestMapping(value = "/writeReplyQna/doReview")
//	public void doReviewWriteReplyQna(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> param = wuxReq.getValueObject("form");
//		param.put("QNA_REVIEW_MODE", "0");
//
//		wuxReq.setValueObject("form", qnaService.doReviewWriteQna(param));
//		wuxResp.setResponseCode("true");
//
//	}
//
//	@RequestMapping(value = "/writeReplyQna/doSave")
//	public void doSaveWriteReplyQna(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//
//		Map<String, String> formMap = wuxReq.getValueObject("form");
//
//		String[] msg = qnaService.doSaveWriteQna(formMap);
//
//		wuxResp.setResponseMessage(msg[1]);
//		wuxResp.setParameter("qna_no", msg[0]);
//		wuxResp.setResponseCode("true");
//	}

}