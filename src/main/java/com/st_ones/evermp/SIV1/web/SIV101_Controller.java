package com.st_ones.evermp.SIV1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.SIV1.service.SIV101_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
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
 * @author  개발자
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/SIV1/SIV101")
public class SIV101_Controller extends BaseController {

	@Autowired private SIV101_Service siv101_Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 공급사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SIV1_010/view")
	public String SIV1_010(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		return "/evermp/SIV1/SIV1_010";
	}

	@RequestMapping(value = "/SIV1_010/doSearch")
	public void siv1010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", siv101_Service.siv1010_doSearch(req.getFormData()));
	}

	/** ******************************************************************************************
     * 공급사 : 납품서생성
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/SIV1_020/view")
	public String SIV1_020(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getManageCd());
        param.put("CTRL_CD", "T100");
        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));

		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		return "/evermp/SIV1/SIV1_020";
	}

	@RequestMapping(value = "/SIV1_020/doSearch")
	public void siv1020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String, String> param = req.getFormData();
		param.put("USER_TYPE", userInfo.getUserType());

		resp.setGridObject("grid", siv101_Service.siv1020_doSearch(param));
	}

	// 납품서 생성
	@RequestMapping(value = "/SIV1_020/doCreateInvoice")
	public void siv1020_doCreateInvoice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		List<Map<String, Object>> reqInList = new ArrayList<>();
		Map<String, Object> respMap = siv101_Service.siv1020_doCreateInvoice(gridList, reqInList);

		resp.setParameter("invNoCount", respMap.get("invNoCount").toString());
		for( int i = 0; i < Integer.parseInt(respMap.get("invNoCount").toString()); i++ ) {
			String id = "IV_NO_"+i;
			resp.setParameter(id, respMap.get(id).toString());
		}

		// 입하번호 받기 No Transactional
		//siv101_Service.siv1020_sendBizNetworkStorageNo(gridList, "N", reqInList);



        //resp.setResponseMessage("OK");
        resp.setResponseMessage(msg.getMessage("0031"));
	}

	// 납품거부
	@RequestMapping(value = "/SIV1_020/doRejectInvoice")
	public void siv1020_doRejectInvoice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = siv101_Service.siv1020_doRejectInvoice(gridList);

        resp.setResponseMessage(returnMsg);
	}

	/**
	 * 분할납품생성
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/SIV1_021/view")
	public String SIV1_021(EverHttpRequest req) throws Exception {
		return "/evermp/SIV1/SIV1_021";
	}

	/**
	 * SIV1_021 : 분할납품 생성
	 * @param req
	 * @param resp
	 * @throws Exception
	 */
	@RequestMapping(value = "/SIV1_021/doCreateInvoice")
	public void siv1021_doCreateInvoice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridList = req.getGridData("grid");
		List<Map<String, Object>> reqInList = new ArrayList<>();



		formData.put("AGENT_YN","1");

		Map<String, String> respMap = siv101_Service.siv1021_doCreateInvoice(formData, gridList, reqInList);





		resp.setParameter("invNoCount", respMap.get("invNoCount").toString());
		for( int i = 0; i < Integer.parseInt(respMap.get("invNoCount").toString()); i++ ) {
			String id = "IV_NO_"+i;
			resp.setParameter(id, respMap.get(id).toString());
		}

		//입하번호 받기 No Transactional
		siv101_Service.siv1020_sendBizNetworkStorageNo(gridList, "Y", reqInList);

        //resp.setResponseMessage("OK");
        resp.setResponseMessage(msg.getMessage("0031"));
	}

	/**
	 * 납품지연사유
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/SIV1_022/view")
	public String SIV1_022(EverHttpRequest req) throws Exception {
		return "/evermp/SIV1/SIV1_022";
	}

	/**
	 * 납품거부사유
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/SIV1_023/view")
	public String SIV1_023(EverHttpRequest req) throws Exception {
		return "/evermp/SIV1/SIV1_023";
	}

	/**
	 * 인수자정보
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/SIV1_024/view")
	public String SIV1_024(EverHttpRequest req) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		String cpoNo = EverString.nullToEmptyString(req.getParameter("CPO_NO"));
		String cpoSq = EverString.nullToEmptyString(req.getParameter("CPO_SEQ"));
		param.put("CPO_NO", cpoNo);
		param.put("CPO_SEQ", cpoSq);

		Map<String, String> formData = siv101_Service.getRecipientUserInfo(param);
		req.setAttribute("formData", formData);

		return "/evermp/SIV1/SIV1_024";
	}

	/**
	 * 인수자정보(고객사)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/SIV1_026/view")
	public String SIV1_026(EverHttpRequest req) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		String cpoNo = EverString.nullToEmptyString(req.getParameter("CPO_NO"));
		String cpoSq = EverString.nullToEmptyString(req.getParameter("CPO_SEQ"));
		param.put("CPO_NO", cpoNo);
		param.put("CPO_SEQ", cpoSq);

		Map<String, String> formData = siv101_Service.getRecipientUserInfoCust(param);
		req.setAttribute("formData", formData);

		return "/evermp/SIV1/SIV1_026";
	}

}
