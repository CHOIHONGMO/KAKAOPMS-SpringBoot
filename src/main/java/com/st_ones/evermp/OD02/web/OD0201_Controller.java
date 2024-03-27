package com.st_ones.evermp.OD02.web;

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
import com.st_ones.evermp.OD02.service.OD0201_Service;
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
 * @File Name : OD0201_Controller.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/OD02/OD0201")
public class OD0201_Controller extends BaseController {

	@Autowired private OD0201_Service od0201_Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 운영사 : 납품서생성 대행
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/OD02_010/view")
	public String OD02_010(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		req.setAttribute("form", req.getParamDataMap());

		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자

        req.setAttribute("itemUserOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));


        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());

		return "/evermp/OD02/OD02_010";
	}

	@RequestMapping(value = "/OD02_010/doSearch")
	public void od02010_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", od0201_Service.od02010_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/OD02_010/doCreateInvoice")
	public void od02010_doCreateInvoice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		List<Map<String, Object>> reqInList = new ArrayList<>();

		Map<String, Object> respMap = od0201_Service.od02010_doCreateInvoice(gridList, reqInList);

//		resp.setParameter("invNoCount", respMap.get("invNoCount").toString());
//
//		for( int i = 0; i < Integer.parseInt(respMap.get("invNoCount").toString()); i++ ) {
//			String id = "IV_NO_"+i;
//			resp.setParameter(id, respMap.get(id).toString());
//		}
//
//		// 입하번호 받기 No Transactional
//		od0201_Service.od02010_sendBizNetworkStorageNo(gridList, "N", reqInList);

        //resp.setResponseMessage("OK");
        resp.setResponseMessage(msg.getMessage("0031"));
	}

	/** ******************************************************************************************
     * 운영사 : 납품서 조회 및 수정
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/OD02_020/view")
	public String OD02_020(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

        Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("sgCtrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));
        req.setAttribute("amUserIdOptions", commonComboService.getCodesAsJson("CB0094", new HashMap<String, String>()));

		return "/evermp/OD02/OD02_020";
	}

	@RequestMapping(value = "/OD02_020/doSearch")
	public void od02020_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("autoSearchFlag", EverString.nullToEmptyString(req.getParameter("autoSearchFlag")));
		resp.setGridObject("grid", od0201_Service.od02020_doSearch(param));
	}

	@RequestMapping(value = "/OD02_020/doSave")
	public void od02020_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0201_Service.od02020_doSave(gridList);

        resp.setResponseMessage(returnMsg);
	}

	// 납품서 삭제
	@RequestMapping(value = "/OD02_020/doDelete")
	public void od02020_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0201_Service.od02020_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
	}

	/** ******************************************************************************************
     * 운영사 : 납품완료 입력/수정 대행
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/OD02_030/view")
	public String OD02_030(EverHttpRequest req) throws Exception {
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());
		req.setAttribute("defaultFlagCd", "0");

		return "/evermp/OD02/OD02_030";
	}

	@RequestMapping(value = "/OD02_030/doSearch")
	public void od02030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", od0201_Service.od02030_doSearch(req.getFormData()));
	}

	// 납품완료
	@RequestMapping(value = "/OD02_030/doCompleteDely")
	public void od02030_doCompleteDely(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0201_Service.od02030_doCompleteDely(gridList);

        resp.setResponseMessage(returnMsg);
	}

	// 납품완료 취소
	@RequestMapping(value = "/OD02_030/doCancelDely")
	public void od02030_doCancelDely(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridList = req.getGridData("grid");
		String returnMsg = od0201_Service.od02030_doCancelDely(gridList);

        resp.setResponseMessage(returnMsg);
	}

}
