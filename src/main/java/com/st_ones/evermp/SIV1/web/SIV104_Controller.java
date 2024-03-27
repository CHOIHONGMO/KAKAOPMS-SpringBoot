package com.st_ones.evermp.SIV1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SIV1.service.SIV104_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @File Name : SIV101_Controller.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/SIV1/SIV104")
public class SIV104_Controller extends BaseController {

	@Autowired private SIV104_Service siv104_Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 공급사 : 납품거부 조회/수정
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SIV1_040/view")
	public String SIV1_040(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));

		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());

		return "/evermp/SIV1/SIV1_040";
	}

	@RequestMapping(value = "/SIV1_040/doSearch")
	public void siv1040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = req.getFormData();
		param.put("USER_TYPE", userInfo.getUserType());

		resp.setGridObject("grid", siv104_Service.siv1040_doSearch(param));
	}

	// 납품거부 취소
	@RequestMapping(value = "/SIV1_040/doCancelReject")
	public void siv1040_doCancelReject(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv104_Service.siv1040_doCancelReject(gridList);

        resp.setResponseMessage(returnMsg);
	}

	/** ******************************************************************************************
     * 공급사 : 납품완료 입력/수정
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SIV1_050/view")
	public String SIV1_050(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		req.setAttribute("defaultFlagCd", "0");

		return "/evermp/SIV1/SIV1_050";
	}

	@RequestMapping(value = "/SIV1_050/doSearch")
	public void siv1050_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = req.getFormData();
		param.put("USER_TYPE", userInfo.getUserType());

		resp.setGridObject("grid", siv104_Service.siv1050_doSearch(param));
	}

	// 납품완료
	@RequestMapping(value = "/SIV1_050/doCompleteDely")
	public void siv1050_doCompleteDely(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv104_Service.siv1050_doCompleteDely(gridList);

        resp.setResponseMessage(returnMsg);
	}

	// 납품완료 취소
	@RequestMapping(value = "/SIV1_050/doCancelDely")
	public void siv1050_doCancelDely(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv104_Service.siv1050_doCancelDely(gridList);

        resp.setResponseMessage(returnMsg);
	}

	/**
	 * 주문이력관리(구.MP)
	 */
	@RequestMapping(value="/SIV1_060/view")
	public String SIV1_060(EverHttpRequest req) {
		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("form", req.getParamDataMap());

		return "/evermp/SIV1/SIV1_060";
	}

	@RequestMapping(value = "/siv1060_doSearch")
	public void siv1060_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		resp.setGridObject("grid", siv104_Service.siv1060_doSearch(param));
	}
}
