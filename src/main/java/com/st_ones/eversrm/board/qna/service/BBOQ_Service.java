package com.st_ones.eversrm.board.qna.service;

import com.st_ones.everf.serverside.service.BaseService;
import org.springframework.stereotype.Service;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : BBOQ_Service.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "bboq_Service")
public class BBOQ_Service extends BaseService {

//	@Autowired
//	private DocNumService docNumService;
//
//	@Autowired
//	private MessageService msg;
//
//	@Autowired
//	QnaMapper qnaMapper;
//
//	@Autowired
//	LargeTextService largeTextService;
//
//	//////////              Qna List /////////////////////////
//	public List<Map<String, Object>> doSearchQnaList(Map<String, String> param) throws Exception {
//		return qnaMapper.doSearchQnaList(param);
//	}
//
//	//////////write Qna /////////////////////////	
//	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
//	public String[] doSaveWriteQna(Map<String, String> params) throws Exception {
//		String args[] = new String[2];
//
//		// String textNum = utilService.setLargeTextInfo(params.get("EDITOR1"), 1000, params);
//		String textNum = largeTextService.saveLargeText(null, params.get("EDITOR1"));
//
//		params.put("QNA_TEXT_NUM", textNum);
//
//		if (WiseString.isEmpty(params.get("QNA_NUM"))) {
//			String rtn = docNumService.getDocNumber("QA");
//			params.put("QNA_NUM", rtn);
//
//			qnaMapper.doInsertQna(params);
//		} else {
//			qnaMapper.doUpdateQna(params);
//		}
//
//		args[0] = params.get("QNA_NUM").toString();
//		args[1] = msg.getMessage("0001");
//
//		return args;
//	}
//
//	public Map<String, String> doReviewWriteQna(Map<String, String> param) throws Exception {
//		if ("1".equals(param.get("QNA_REVIEW_MODE")))
//			qnaMapper.doUpdateHITQna(param);
//
//		Map<String, String> params = qnaMapper.doReviewQna(param);
//		String textNum = params.get("QNA_TEXT_NUM");
//		String splitString = largeTextService.selectLargeText(textNum);
//		params.put("EDITOR1", splitString);
//
//		return params;
//	}
//
//	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
//	public String doDeleteWriteQna(Map<String, String> params) throws Exception {
//		qnaMapper.doDeleteQna(params);
//		return msg.getMessage("0017");
//	}
//
//	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
//	public String doUpdateHITQna(Map<String, String> params) throws Exception {
//		qnaMapper.doUpdateHITQna(params);
//		return msg.getMessage("0001");
//	}

}