package com.st_ones.nosession.index.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.nosession.index.IndexMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class IndexService extends BaseService {

    @Autowired
    IndexMapper indexMapper;

    @Autowired
    LargeTextService largeTextService;

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired private EverMailService everMailService;

    public List<Map<String, String>> getNoticeList(List<Map<String, String>> noticeList) throws Exception {
        List<Map<String, String>> noticeList1 = indexMapper.getNoticeList(noticeList);
        for (Map<String, String> datum : noticeList1) {
            datum.put("CONTENTS", largeTextService.selectLargeText(datum.get("NOTICE_TEXT_NUM")));
        }

        return noticeList1;
    }

    /**
     * 공지사항 팝업 목록
     * @param noticeList
     * @return
     * @throws Exception
     */
    public List<Map<String, String>> getNoticeListPopup(List<Map<String, String>> noticeList) throws Exception {
        return indexMapper.getNoticeListPopup(noticeList);
    }

    /**
     * 공지사항 상세정보
     * @return
     * @throws Exception
     */
    public Map<String, Object> getNoticePopupInfo(Map<String, String> param) throws Exception {
    	Map<String, Object> rtnMap = indexMapper.getNoticePopupInfo(param);

    	String splitString = "";
    	if( rtnMap != null && rtnMap.size() > 0 && rtnMap.get("NOTICE_TEXT_NUM") != null ) {
        	splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
    		rtnMap.put("NOTICE_CONTENTS", splitString);
    	}

    	return rtnMap;
    }

    /**
     * 공지사항 메인화면 목록
     * @return
     * @throws Exception
     */
    public List<Map<String, String>> getNoticeListMain(List<Map<String, String>> param) throws Exception {
        return indexMapper.getNoticeListMain(param);
    }

    /**
     * 운영사 메인 목록
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> mainNoticeList(Map<String, String> param) throws Exception {
        return indexMapper.mainNoticeList(param);
    }

    public Map<String, String> mainNoticeDetail(Map<String, String> param) throws Exception {
        return indexMapper.mainNoticeDetail(param);
    }

    public int mainNoticeTotalCount(Map<String, String> param) throws Exception {
        return indexMapper.mainNoticeTotalCount(param);
    }

    /**
     * 대명소노시즌 TMS 로그인
     * @param param
     * @return
     * @throws Exception
     */
    public String tmsLogin(Map<String, String> param) throws Exception {
    	String result = "";
    	param.put("isDev", PropertiesManager.getString("eversrm.system.developmentFlag"));
    	if("S".equals(param.get("radio"))) {
    		result = indexMapper.tmsLoginS(param);
    	} else if("C".equals(param.get("radio"))) {
    		result = indexMapper.tmsLoginC(param);
    	}
    	return result;
    }

    public Map<String, String> getTmsInfo(Map<String, String> param) throws Exception {
        return indexMapper.getTmsInfo(param);
    }

    public List<Map<String, Object>> poList01(Map<String, String> param) throws Exception {
    	param.put("isDev", PropertiesManager.getString("eversrm.system.developmentFlag"));
        return indexMapper.poList01(param);
    }

    public List<Map<String, Object>> poList02(Map<String, String> param) throws Exception {
    	param.put("isDev", PropertiesManager.getString("eversrm.system.developmentFlag"));
        return indexMapper.poList02(param);
    }

    /**
     * 공급사 거래제안 팝업(BS03_011P)
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> BS03_012_doSave(Map<String, String> formData) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();
        String noticeNum = com.st_ones.everf.serverside.util.EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
        String noticeTextNum = com.st_ones.everf.serverside.util.EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

        if(noticeNum.equals("")) {
            noticeNum = docNumService.getDocNumber("NT");
            noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
            formData.put("NOTICE_NUM", noticeNum);
            formData.put("NOTICE_TEXT_NUM", noticeTextNum);
            indexMapper.BS03_012_doInsert(formData);
        }
        else {
            noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
            indexMapper.BS03_012_doUpdate(formData);
        }

        rtnMap.put("NOTICE_NUM", noticeNum);
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }
}
