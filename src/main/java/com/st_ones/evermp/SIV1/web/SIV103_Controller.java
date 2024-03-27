package com.st_ones.evermp.SIV1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SIV1.service.SIV103_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : SIV103_Controller.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/SIV1/SIV103")
public class SIV103_Controller extends BaseController {

	@Autowired private SIV103_Service siv103_Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 공급사 : 납품서 조회/수정
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SIV1_030/view")
	public String SIV1_030(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		req.setAttribute("defaultGrFlag", "");
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.localserver"));

		return "/evermp/SIV1/SIV1_030";
	}

	@RequestMapping(value = "/SIV1_030/doSearch")
	public void siv1030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = req.getFormData();
		param.put("USER_TYPE", userInfo.getUserType());

		resp.setGridObject("grid", siv103_Service.siv1030_doSearch(param));
	}

	// 납품서 수정
	@RequestMapping(value = "/SIV1_030/doSave")
	public void siv1030_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv103_Service.siv1030_doSave(gridList);

        resp.setResponseMessage(returnMsg);
	}

	@RequestMapping(value = "/SIV1_030/doSave2")
	public void siv1030_doSave2(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv103_Service.siv1030_doSave2(gridList);

        resp.setResponseMessage(returnMsg);
	}




	// 납품서 삭제
	@RequestMapping(value = "/SIV1_030/doDelete")
	public void siv1030_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv103_Service.siv1030_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
	}

}
