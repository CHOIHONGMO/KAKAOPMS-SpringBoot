package com.st_ones.evermp.REGISTER.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS03.service.BS0301_Service;
import com.st_ones.evermp.REGISTER.service.REG_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * The type REG _ controller.
 */
@Controller
@RequestMapping(value = "/evermp")
public class REG_Controller {
    @Autowired
    private MessageService msg;
    @Autowired
    private REG_Service reg_service;
    @Autowired
    BS0301_Service bs0301Service;
    @Autowired
    private CommonComboService commonComboService;

    /**
     * 메인화면 - 회원가입
     */
    @RequestMapping("/register/register_step/view")
    public String register_step(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	String irsNo  = EverString.nullToEmptyString(req.getParameter("IRS_NUM"));

    	Map<String, String> param = new HashMap<String, String>();
        param.put("IRS_NO", irsNo);

        Map<String, String> baseInfo = new HashMap<String, String>();
        List<Map<String, Object>> sgList = new ArrayList<Map<String, Object>>();

    	if (EverString.isNotEmpty(irsNo)) {
    		//1. 협력업체 기본정보
    		baseInfo = bs0301Service.bs03002_doSearchInfo(param);
    		if(baseInfo != null && baseInfo.size() > 0) {
    			param.put("VENDOR_CD", baseInfo.get("VENDOR_CD"));

    			//2. 협력업체 취급분야
    			sgList = bs0301Service.bs03002_doSearchSG(param);
    		}
    	}

    	// 협력업체 기본정보
    	req.setAttribute("form", baseInfo);
    	// 협력업체 취급분야
    	req.setAttribute("sgList", sgList);

        req.setAttribute("sslFlag", String.valueOf(PropertiesManager.getBoolean("ever.ssl.use.flag")));
        // 사업자구분
        req.setAttribute("regType", commonComboService.getCodeCombo("M014"));
        // 주요배송수단
        req.setAttribute("deliberyType", commonComboService.getCodeCombo("MP041"));
        // 기업규모
        req.setAttribute("businessSize", commonComboService.getCodeCombo("MP039"));
        // 기업구분
        req.setAttribute("businessList", commonComboService.getCodeCombo("MP040"));
        // 상장여부, 특허여부, SMS 수신여부, 메일수신여부
        req.setAttribute("ynFlag", commonComboService.getCodeCombo("M044"));
        // 유통레벨
        req.setAttribute("deliveryLevel", commonComboService.getCodeCombo("MP044"));
        // 납품가능지역
        req.setAttribute("regionCd", commonComboService.getCodeCombo("MP005"));
        // 과세구분
        req.setAttribute("taxType", commonComboService.getCodeCombo("M036"));
        // ISO여부
        req.setAttribute("iosType", commonComboService.getCodeCombo("MP043"));
        // 계산서발행구분
        req.setAttribute("eBillAspType", commonComboService.getCodeCombo("MP075"));
        // 기준년도
        req.setAttribute("fiYear", commonComboService.getCodeCombo("MP051"));
        // 자료근거
        req.setAttribute("evidenceType", commonComboService.getCodeCombo("MP048"));
        // 권한
        req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));
        // 은행
        req.setAttribute("bcFlag", commonComboService.getCodeCombo("M017"));
        return "/evermp/REGISTER/06_register_step02";
    }

    /**
     * 메인화면 - 회원가입
     */
    @RequestMapping("/register/userIdCheck")
    public void userIdCheck(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> reqMap = req.getParamDataMap();
        int userCnt = reg_service.userIdCheck(req.getParamDataMap());

        if(userCnt > 0) {
            reqMap.put("responseCode", "fail");
        } else {
            reqMap.put("responseCode", "success");
        }
        resp.sendJSON(reqMap);
    }

    /**
     * 메인화면 - 회원가입 - 파일창 호출
     */
    @RequestMapping("/register/fileSearchPop/view")
    public String fileSearchPop(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	String vendorCd = EverString.nullToEmptyString(req.getParameter("VENDOR_CD"));

    	Map<String, String> param = new HashMap<String, String>();
        param.put("VENDOR_CD", vendorCd);

        Map<String, String> fileInfo = new HashMap<String, String>();
    	if (EverString.isNotEmpty(vendorCd)) {
    		fileInfo = bs0301Service.bs03002_doSearchFileVNGL(param);
    	}
    	req.setAttribute("form", fileInfo);

        return "/evermp/REGISTER/fileSearchPop";
    }

    /**
     * 메인화면 - 회원가입
     */
    @RequestMapping("/register/doSave")
    public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> sendMsg = new HashMap<String, String>();

        reg_service.doSave(req.getParamDataMap());
        sendMsg.put("responseCode", "success");
        resp.sendJSON(sendMsg);
    }

    /**
     *  메인화면 - 회원가입 - 고객사 회원가입
     */

    @RequestMapping("/register/register_stepB/view")
    public String register_stepB(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        req.setAttribute("sslFlag", String.valueOf(PropertiesManager.getBoolean("ever.ssl.use.flag")));
        // 사업자구분
        req.setAttribute("regType", commonComboService.getCodeCombo("M014"));
        // 주요배송수단
        req.setAttribute("deliberyType", commonComboService.getCodeCombo("MP041"));
        // 기업규모
        req.setAttribute("businessSize", commonComboService.getCodeCombo("MP039"));
        // 기업구분
        req.setAttribute("businessList", commonComboService.getCodeCombo("MP040"));
        // 상장여부, 특허여부, SMS 수신여부, 메일수신여부
        req.setAttribute("ynFlag", commonComboService.getCodeCombo("M044"));
        // 유통레벨
        req.setAttribute("deliveryLevel", commonComboService.getCodeCombo("MP044"));
        // 납품가능지역
        req.setAttribute("regionCd", commonComboService.getCodeCombo("MP005"));
        // 과세구분
        req.setAttribute("taxType", commonComboService.getCodeCombo("M036"));
        // ISO여부
        req.setAttribute("iosType", commonComboService.getCodeCombo("MP043"));
        // 계산서발행구분
        req.setAttribute("eBillAspType", commonComboService.getCodeCombo("MP075"));
        // 기준년도
        req.setAttribute("fiYear", commonComboService.getCodeCombo("M174"));
        // 자료근거
        req.setAttribute("evidenceType", commonComboService.getCodeCombo("MP048"));
        // 권한
        req.setAttribute("RoleList", commonComboService.getCodeCombo("MP055"));
        // 법인구분
        req.setAttribute("CorpSize", commonComboService.getCodeCombo("MP049"));
        return "/evermp/REGISTER/06_register_step03";
    }

    /**
     * 메인화면 - 회원가입 - 고객사 - 파일창 호출
     */

    @RequestMapping("/register/fileSearchPopB/view")
    public String fileSearchPopB(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        return "/evermp/REGISTER/fileSearchPopB";
    }

    /**
     * 메인화면 - 회원가입 - 저장
     */
    @RequestMapping("/register/doSaveB")
    public void doSaveB(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        Map<String, String> sendMsg = new HashMap<String, String>();

        // 저장
        reg_service.doSaveB(req.getParamDataMap());

        sendMsg.put("responseCode", "success");
        resp.sendJSON(sendMsg);
    }
}

