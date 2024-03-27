package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.util.EverString;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BS99.service.BS9901_Service;
import com.st_ones.evermp.buyer.eval.service.EV0210Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0210Controller extends BaseController {

	@Autowired private EV0210Service EV0210Service;
	@Autowired private BS9901_Service bs9901service;
	@Autowired private CommonComboService commonComboService;
	@Autowired FileAttachService fileAttachService;

	//	////    EV0210    //////
	@RequestMapping(value = "/EV0210/view")
	public String evalMgt(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		String evNum = req.getParameter("EV_NUM");

		HashMap<String, String> form  = new HashMap<String, String>();
		form.put("REG_DATE", EverDate.getDate());
		form.put("REG_USER_NM", baseInfo.getUserNm());
		form.put("EV_CTRL_USER_ID", baseInfo.getUserId());

		if( EverString.isNotEmpty(evNum) ) {
			form.put("EV_NUM", evNum);
			form = (HashMap<String, String>) EV0210Service.getEvMaster(form);
		}

		//================== 템플릿 파일 번호 가져오기 ==================
        Map<String, String> tempData = new HashMap<String, String>();
        tempData.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.ESTM.VENDOR.key"));
        Map<String, String> tempMap = bs9901service.doSearch_templateFile(tempData);
        req.setAttribute("TEMP_ATT_FILE_NUM", (tempMap!=null&&tempMap.size()>0)?tempMap.get("ATT_FILE_NUM"):"");

        Map<String, String> tempData1 = new HashMap<String, String>();
        tempData1.put("TMPL_NUM", PropertiesManager.getString("eversrm.template.file.ESTM.USER.key"));
        Map<String, String> tempMap1 = bs9901service.doSearch_templateFile(tempData1);
        req.setAttribute("USER_TEMP_ATT_FILE_NUM", (tempMap1!=null&&tempMap1.size()>0)?tempMap1.get("ATT_FILE_NUM"):"");
        //================== 템플릿 파일 번호 가져오기 ==================

		req.setAttribute("form", form);
		req.setAttribute("result_enter_cd", commonComboService.getCodeComboAsJson("M123"));

		return "/evermp/buyer/eval/EV0210";
	}

	/**
	 * 평가 등록/수정
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param =req.getFormData();

		List<Map<String, Object>> gridUs = req.getGridData("gridUs");
		List<Map<String, Object>> gridVendor = req.getGridData("gridVendor");

		String msg[] = EV0210Service.doSave(param, gridUs, gridVendor);

		resp.setResponseMessage(msg[1]);
		resp.setParameter("ev_num", msg[0]);
		resp.setResponseCode("true");
	}

	/**
	 * 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doSearch")
	public void doSearchEvalMgt(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		EV0210Service.doSearch(param, req);

		resp.setResponseCode("true");
	}

	/**
	 * 협력사 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doSearchEVES")
	public void doSearchEVES(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridVendor", EV0210Service.doSearchEVES(req.getFormData()));
	}

	/**
	 * 협력사 조회(엑셀 업로드용)
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doSearchExecelEVES")
	public void doSearchExecelEVES(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridVendor = req.getGridData("gridVendor");
		resp.setGridObject("gridVendor", EV0210Service.doSearchExecelEVES(param, gridVendor));
	}

	/**
	 * 평가자 조회(엑셀 업로드용)
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doSearchExecelEVEU")
	public void doSearchExecelEVEU(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> gridVendor = req.getGridData("gridVendor");
		List<Map<String, Object>> gridUs = req.getGridData("gridUs");
		resp.setGridObject("gridVendor", EV0210Service.doSearchExecelEVEU(param, gridVendor, gridUs));
	}

	/**
	 * 평가자 조회
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	/*
	 * @RequestMapping(value = "/EV0210/doSearchEVEU") public void
	 * doSearchEVEU(EverHttpRequest req, EverHttpResponse resp) throws Exception {
	 * Map<String, String> param =req.getFormData(); List<Map<String, Object>>
	 * importL = EV0210Service.doSearchEVEU(param); resp.setGridObject("gridUs",
	 * importL); resp.setResponseCode("true"); }
	 */

	/**
	 * 평가 삭제
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doDelete")
	public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		String msg = EV0210Service.doDelete(param);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * 평가요청
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doRequest")
	public void doRequestExecEvalMgt(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		//List<Map<String, Object>> gridUs = req.getValueObject("gridUsData");
		//List<Map<String, Object>> gridVendor = req.getGridData("gridVendor");
		//EV0210Service.doSave(param, gridUs, gridVendor);

		String msg = EV0210Service.doUpdateProgressEVEM(param, "doRequest");

		//EV0210Service.doInsertEVET(param, gridVendor);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * 요청취소
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/EV0210/doCancel")
	public void doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		String msg = EV0210Service.doUpdateProgressEVEM(param, "doCancel");

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
}
