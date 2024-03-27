package com.st_ones.eversrm.board.notice.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.serverpush.reverseajax.EverAlarm;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.eversrm.board.notice.BBON_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * </pre>  
 * @File Name : BBON_Service.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */

@Service(value = "bbon_Service")
public class BBON_Service extends BaseService {

	@Autowired
	private MessageService msg;

	@Autowired
	LargeTextService largeTextService;

	@Autowired
	private BBON_Mapper bbonmapper;

	@Autowired
	private DocNumService docNumService;

	@Autowired
	private EverAlarm everAlarm;
	
	public List<Map<String, Object>> selectNoticeList(Map<String, String> param) throws Exception {
		return bbonmapper.selectNoticeList(param);
	}

	public Map<String, String> selectNotice(String noticeNo) throws Exception {
		bbonmapper.updateNoticeView(noticeNo);
		return bbonmapper.selectNotice(noticeNo);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] saveNotice(Map<String, String> param) throws Exception {

		String args[] = new String[2];
		String valueOld = param.get("NOTICE_NUM");
		args[1] = valueOld;

		if (EverString.isEmpty(valueOld)) {
			String docNum = docNumService.getDocNumber("NT");
			String textNum = largeTextService.saveLargeText(null, param.get("CONTENTS"));
			param.put("NOTICE_TEXT_NUM", textNum);
			param.put("NOTICE_NUM", docNum);
			args[1] = docNum;

			bbonmapper.createNotice(param);

			Map<String, String> map = new HashMap<String, String>();
			map.put("_title", "");
			map.put("GATE_CD", param.get("GATE_CD"));
			map.put("NOTICE_NUM", param.get("NOTICE_NUM"));
			map.put("NOTICE_TEXT_NUM", param.get("NOTICE_TEXT_NUM"));
			map.put("onClose", "none");
			map.put("USER_TYPE", param.get("USER_TYPE"));

			everAlarm.noticeAlarm(map);

		} else {

			int rowCount = bbonmapper.checkNoticeList(param);
			
			if (rowCount > 0) {
				String textNum = largeTextService.saveLargeText(param.get("NOTICE_TEXT_NUM"), param.get("CONTENTS"));
				param.put("NOTICE_TEXT_NUM", textNum);
				param.put("NOTICE_NUM", args[1]);
				bbonmapper.updateNotice(param);
			}
		}
		args[0] = msg.getMessage("0001");

		return args;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteNoticeList(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			bbonmapper.deleteNotice(gridData);
		}

		return msg.getMessage("0017");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteNotice(Map  param) throws Exception {
		bbonmapper.deleteNotice(param);

		return msg.getMessage("0017");
	}

}