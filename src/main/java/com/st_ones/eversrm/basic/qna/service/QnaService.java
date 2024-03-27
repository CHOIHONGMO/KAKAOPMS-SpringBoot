package com.st_ones.eversrm.basic.qna.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.basic.qna.QnaMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service(value = "qnaService")
public class QnaService extends BaseService {

	@Autowired
	private DocNumService docNumService;

	@Autowired
	private MessageService msg;

	@Autowired
	QnaMapper qnaMapper;

	@Autowired
	LargeTextService largeTextService;

	//////////              Qna List /////////////////////////
	public List<Map<String, Object>> doSearchQnaList(Map<String, String> param) throws Exception {
		return qnaMapper.doSearchQnaList(param);
	}

	//////////write Qna /////////////////////////
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] doSaveWriteQna(Map<String, String> params) throws Exception {
		String args[] = new String[2];

		if (EverString.isEmpty(params.get("QNA_NUM"))) {
			String textNo = largeTextService.saveLargeText(null, params.get("EDITOR1"));
			params.put("QNA_TEXT_NUM", textNo);
			String rtn = docNumService.getDocNumber("QA");
			params.put("QNA_NUM", rtn);
			qnaMapper.doInsertQna(params);
		} else {
			largeTextService.saveLargeText(params.get("QNA_TEXT_NUM"), params.get("EDITOR1"));
			qnaMapper.doUpdateQna(params);
		}

		args[0] = params.get("QNA_NUM").toString();
		args[1] = msg.getMessage("0001");

		return args;
	}

	public Map<String, String> doReviewWriteQna(Map<String, String> param) throws Exception {
		if ("1".equals(param.get("QNA_REVIEW_MODE")))
			qnaMapper.doUpdateHITQna(param);

		Map<String, String> params = qnaMapper.doReviewQna(param);
		if (params!=null) {
			String textNo = params.get("QNA_TEXT_NUM");
			String splitString = largeTextService.selectLargeText(textNo);
			params.put("EDITOR1", splitString);
		}
		return params;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteWriteQna(Map<String, String> params) throws Exception {
		qnaMapper.doDeleteQna(params);
		return msg.getMessage("0017");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doUpdateHITQna(Map<String, String> params) throws Exception {
		qnaMapper.doUpdateHITQna(params);
		return msg.getMessage("0001");
	}
}
