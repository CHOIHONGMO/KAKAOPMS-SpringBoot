package com.st_ones.eversrm.board.notice.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.EverString;
import com.st_ones.eversrm.board.notice.BBD01_Mapper;
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
 */

@Service(value = "bbd01_service")
public class BBD01_Service extends BaseService {

	@Autowired BBD01_Mapper bbd01_mapper;

	@Autowired MessageService msg;

	@Autowired LargeTextService largeTextService;

	@Autowired private DocNumService docNumService;

	/********************************************************************************************
     * 고객사 > My Page > My Page > 공지사항 (MY01_002 > BBD01_010)
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> BBD01_010_doSearch(Map<String, String> param) throws Exception {
		return bbd01_mapper.BBD01_010_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String BBD01_010_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			bbd01_mapper.BBD01_010_doDelete(gridData);
		}
		return msg.getMessage("0017");
	}

	/********************************************************************************************
     * 고객사 > My Page > My Page > 공지사항-작성  (MY01_002 > BBD01_011)
     * @param param
     * @return
     * @throws Exception
     */
	public Map<String, Object> BBD01_011_doSearchNoticeInfo(Map<String, String> param) throws Exception {

		Map<String, Object> rtnMap = bbd01_mapper.BBD01_011_doSearchNoticeInfo(param);

		String splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
		rtnMap.put("NOTICE_CONTENTS", splitString);

		if (param.get("detailView").toString().trim().toLowerCase().equals("true")) {
			Double cnt = Double.parseDouble(String.valueOf(rtnMap.get("VIEW_CNT"))) + 1;
			rtnMap.put("VIEW_CNT", cnt.toString());
			bbd01_mapper.BBD01_011_doSaveCount(rtnMap);
		}
		rtnMap.put("VIEW_CNT", EverMath.EverNumberType(String.valueOf(rtnMap.get("VIEW_CNT")), "###,###"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> BBD01_011_doSave(Map<String, String> formData) throws Exception {

		Map<String, String> rtnMap = new HashMap<String, String>();
		String noticeNum = EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
		String noticeTextNum = EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

		if(noticeNum.equals("")) {
			noticeNum = docNumService.getDocNumber("NT");
			noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
			formData.put("NOTICE_NUM", noticeNum);
			formData.put("NOTICE_TEXT_NUM", noticeTextNum);
			bbd01_mapper.BBD01_011_doInsert(formData);
		}
		else {
			noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
			bbd01_mapper.BBD01_011_doUpdate(formData);
		}

		rtnMap.put("NOTICE_NUM", noticeNum);
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String BBD01_011_doDelete(Map<String, String> formData) throws Exception {

		Map<String, Object> param = new HashMap<String, Object>();
		param.put("NOTICE_NUM", formData.get("NOTICE_NUM"));
		bbd01_mapper.BBD01_010_doDelete(param);
		return msg.getMessage("0017");
	}

	/********************************************************************************************
     * 고객사 > My Page > My Page > 게시판  (MY01_003 > BBD01_020)
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> BBD01_020_doSearch(Map<String, String> param) throws Exception {
		return bbd01_mapper.BBD01_020_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String BBD01_020_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			bbd01_mapper.BBD01_020_doDelete(gridData);
		}
		return msg.getMessage("0017");
	}

	/********************************************************************************************
     * 고객사 > My Page > My Page > 게시판-작성  (MY01_004 > BBD01_021)
     * @param param
     * @return
     * @throws Exception
     */
	public Map<String, Object> BBD01_021_doSearchNoticeInfo(Map<String, String> param) throws Exception {

		Map<String, Object> rtnMap = bbd01_mapper.BBD01_021_doSearchNoticeInfo(param);

		String splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
		rtnMap.put("NOTICE_CONTENTS", splitString);

		if (param.get("detailView").toString().trim().toLowerCase().equals("true")) {
			Double cnt = Double.parseDouble(String.valueOf(rtnMap.get("VIEW_CNT"))) + 1;
			rtnMap.put("VIEW_CNT", cnt.toString());
			bbd01_mapper.BBD01_021_doSaveCount(rtnMap);
		}
		rtnMap.put("VIEW_CNT", EverMath.EverNumberType(String.valueOf(rtnMap.get("VIEW_CNT")), "###,###"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> BBD01_021_doSave(Map<String, String> formData) throws Exception {

		Map<String, String> rtnMap = new HashMap<String, String>();
		String noticeNum = EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
		String noticeTextNum = EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

		if(noticeNum.equals("")) {
			noticeNum = docNumService.getDocNumber("NT");
			noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
			formData.put("NOTICE_NUM", noticeNum);
			formData.put("NOTICE_TEXT_NUM", noticeTextNum);
			bbd01_mapper.BBD01_021_doInsert(formData);
		}
		else {
			noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
			bbd01_mapper.BBD01_021_doUpdate(formData);
		}

		rtnMap.put("NOTICE_NUM", noticeNum);
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}


	/********************************************************************************************
	 * 고객사 > My Page > My Page > ESH 게시판 (MY01_002 > BBD01_030)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> BBD01_030_doSearch(Map<String, String> param) throws Exception {
		return bbd01_mapper.BBD01_030_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String BBD01_030_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			bbd01_mapper.BBD01_030_doDelete(gridData);
		}
		return msg.getMessage("0017");
	}

	/********************************************************************************************
	 * 고객사 > My Page > My Page > ESH게시판-작성  (BBD01_031)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	public Map<String, Object> BBD01_031_doSearchNoticeInfo(Map<String, String> param) throws Exception {

		Map<String, Object> rtnMap = bbd01_mapper.BBD01_031_doSearchNoticeInfo(param);

		String splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
		rtnMap.put("NOTICE_CONTENTS", splitString);

		if (param.get("detailView").toString().trim().toLowerCase().equals("true")) {
			Double cnt = Double.parseDouble(String.valueOf(rtnMap.get("VIEW_CNT"))) + 1;
			rtnMap.put("VIEW_CNT", cnt.toString());
			bbd01_mapper.BBD01_031_doSaveCount(rtnMap);
		}
		rtnMap.put("VIEW_CNT", EverMath.EverNumberType(String.valueOf(rtnMap.get("VIEW_CNT")), "###,###"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> BBD01_031_doSave(Map<String, String> formData) throws Exception {

		Map<String, String> rtnMap = new HashMap<String, String>();
		String noticeNum = EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
		String noticeTextNum = EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

		if(noticeNum.equals("")) {
			noticeNum = docNumService.getDocNumber("EH");
			noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
			formData.put("NOTICE_NUM", noticeNum);
			formData.put("NOTICE_TEXT_NUM", noticeTextNum);
			bbd01_mapper.BBD01_031_doInsert(formData);
		}
		else {
			noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
			bbd01_mapper.BBD01_031_doUpdate(formData);
		}

		rtnMap.put("NOTICE_NUM", noticeNum);
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}

	public String BBD01_031_doDelete(Map<String, String> formData) throws Exception {
		Map<String, Object> param = new HashMap<String, Object>();

		param.put("NOTICE_NUM", formData.get("NOTICE_NUM"));
		bbd01_mapper.BBD01_030_doDelete(param);
		return msg.getMessage("0017");
	}

}
