package com.st_ones.evermp.MY01.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.MY01.MY01_Mapper;
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
 * @File Name : MY01_Service.java
 * @author  이연무
 * @date 2018. 01. 30.
 * @version 1.0
 * @see
 */

@Service(value = "my01_Service")
public class MY01_Service extends BaseService {

	@Autowired MY01_Mapper my01_Mapper;

	@Autowired MessageService msg;

	@Autowired LargeTextService largeTextService;

	@Autowired private DocNumService docNumService;

	/** ******************************************************************************************
     * 공지사항
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my01001_doSearch(Map<String, String> param) throws Exception {
		return my01_Mapper.my01001_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01001_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			my01_Mapper.my01001_doDelete(gridData);
		}
		return msg.getMessage("0017");
	}

	/** ******************************************************************************************
     * 공지사항 - 작성
     * @param req
     * @return
     * @throws Exception
     */
	public Map<String, Object> my01001_doSearchNoticeInfo(Map<String, String> param) throws Exception {

		Map<String, Object> rtnMap = my01_Mapper.my01002_doSearchNoticeInfo(param);

		String splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
		rtnMap.put("NOTICE_CONTENTS", splitString);

		if (param.get("detailView").toString().trim().toLowerCase().equals("true")) {
			Double cnt = Double.parseDouble(String.valueOf(rtnMap.get("VIEW_CNT"))) + 1;
			rtnMap.put("VIEW_CNT", cnt.toString());
			my01_Mapper.my01002_doSaveCount(rtnMap);
		}
		rtnMap.put("VIEW_CNT", EverMath.EverNumberType(String.valueOf(rtnMap.get("VIEW_CNT")), "###,###"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> my01002_doSave(Map<String, String> formData) throws Exception {

		Map<String, String> rtnMap = new HashMap<String, String>();
		String noticeNum = EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
		String noticeTextNum = EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

		if(noticeNum.equals("")) {
			noticeNum = docNumService.getDocNumber("NT");
			noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
			formData.put("NOTICE_NUM", noticeNum);
			formData.put("NOTICE_TEXT_NUM", noticeTextNum);
			my01_Mapper.my01002_doInsert(formData);
		}
		else {
			noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
			my01_Mapper.my01002_doUpdate(formData);
		}

		rtnMap.put("NOTICE_NUM", noticeNum);
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01002_doDelete(Map<String, String> formData) throws Exception {

		Map<String, Object> param = new HashMap<String, Object>();
		param.put("NOTICE_NUM", formData.get("NOTICE_NUM"));
		my01_Mapper.my01001_doDelete(param);
		return msg.getMessage("0017");
	}

	/** ******************************************************************************************
     * 납품게시판
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my01003_doSearch(Map<String, String> param) throws Exception {
		return my01_Mapper.my01003_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01003_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

		for(Map<String, Object> gridData : gridDatas) {
			my01_Mapper.my01003_doDelete(gridData);
		}
		return msg.getMessage("0017");
	}

	/** ******************************************************************************************
     * 납품게시판 - 작성
     * @param req
     * @return
     * @throws Exception
     */
	public Map<String, Object> my01004_doSearchNoticeInfo(Map<String, String> param) throws Exception {

		Map<String, Object> rtnMap = my01_Mapper.my01004_doSearchNoticeInfo(param);

		String splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
		rtnMap.put("NOTICE_CONTENTS", splitString);

		if (param.get("detailView").toString().trim().toLowerCase().equals("true")) {
			Double cnt = Double.parseDouble(String.valueOf(rtnMap.get("VIEW_CNT"))) + 1;
			rtnMap.put("VIEW_CNT", cnt.toString());
			my01_Mapper.my01004_doSaveCount(rtnMap);
		}
		rtnMap.put("VIEW_CNT", EverMath.EverNumberType(String.valueOf(rtnMap.get("VIEW_CNT")), "###,###"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> my01004_doSave(Map<String, String> formData) throws Exception {

		Map<String, String> rtnMap = new HashMap<String, String>();
		String noticeNum = EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
		String noticeTextNum = EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

		if(noticeNum.equals("")) {
			noticeNum = docNumService.getDocNumber("NT");
			noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
			formData.put("NOTICE_NUM", noticeNum);
			formData.put("NOTICE_TEXT_NUM", noticeTextNum);
			my01_Mapper.my01004_doInsert(formData);
		}
		else {
			noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
			my01_Mapper.my01004_doUpdate(formData);
		}

		rtnMap.put("NOTICE_NUM", noticeNum);
		rtnMap.put("rtnMsg", msg.getMessage("0031"));
		return rtnMap;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01004_doDelete(Map<String, String> formData) throws Exception {

		Map<String, Object> param = new HashMap<String, Object>();
		param.put("NOTICE_NUM", formData.get("NOTICE_NUM"));
		my01_Mapper.my01003_doDelete(param);
		return msg.getMessage("0017");
	}

	/** ******************************************************************************************
     * 개인정보관리
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> my01005_doSearchG(Map<String, String> param) throws Exception {
        return my01_Mapper.my01005_doSearchG(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String my01005_doSaveG(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {
        	my01_Mapper.my01005_doSaveG(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String my01005_doDeleteG(List<Map<String, Object>> gridDatas) throws Exception {

    	for(Map<String, Object> gridData : gridDatas) {
    		my01_Mapper.my01005_doDeleteG(gridData);
    	}
    	return msg.getMessage("0017");
    }

    /** ******************************************************************************************
     * 배송지목록
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> my01006_doSearch(Map<String, String> param) throws Exception {
        return my01_Mapper.my01006_doSearch(param);
    }

    /** ******************************************************************************************
     * 배송지목록-NEW
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> my01007_doSearch(Map<String, String> param) throws Exception {
        return my01_Mapper.my01007_doSearch(param);
    }

    /** ******************************************************************************************
     * 청구지목록
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> my01008_doSearch(Map<String, String> param) throws Exception {
        return my01_Mapper.my01008_doSearch(param);
    }
    
	/** ******************************************************************************************
	 * 관심업체그룹
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my01010_doSearch(Map<String, String> param) throws Exception {
		return my01_Mapper.my01010_doSearch(param);
	}
	
	/** ******************************************************************************************
	 * 관심업체상세
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> my01010_doSearchD(Map<String, String> param) throws Exception {
		return my01_Mapper.my01010_doSearchD(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01010_doSave(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			if("".equals(gridData.get("TPL_NO"))  || null == gridData.get("TPL_NO")) {
				String TPL_NO = docNumService.getDocNumber("DCV"); // 관심업체 문서번호 채번
				gridData.put("TPL_NO", TPL_NO);
			}
			my01_Mapper.my01010_doSave(gridData);
		}
		return msg.getMessage("0015");
	}
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01010_doDelete(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			// 관심업체 그룹 삭제
			my01_Mapper.my01010_doDelete(gridData);
			// 관심업체 상세 삭제
			my01_Mapper.my01010_doDeleteD(gridData);
		}
		return msg.getMessage("0017");
	}
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01010_doSaveD(List<Map<String, Object>> gridDatas,Map<String, String> params) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			my01_Mapper.my01010_doSaveD(gridData);
		}
		return msg.getMessage("0015");
	}
	
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String my01010_doDeleteD(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			my01_Mapper.my01010_doDeleteD(gridData);
		}
		return msg.getMessage("0017");
	}

}
