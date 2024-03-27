package com.st_ones.evermp.BOD1.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BOD1.service.BOD104_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/BOD1/BOD104")
public class BOD104_Controller extends BaseController {

	@Autowired private BOD104_Service bod104_Service;

	@Autowired private MessageService msg;

    /** ******************************************************************************************
     * 고객사 > 주문관리 > 주문관리 > 주문조회/수정
     * @param req
     * @return String
     * @throws Exception
     */
	@RequestMapping(value="/BOD1_040/view")
	public String BOD1_040(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	       return "/eversrm/noSuperAuth";
	  	      }

		// 2022.10.23 시스템관리자 권한(mng_yn=Y), 직무=M100(업무관리자) : 사업장 변경 가능, 직무=T100(구매담당자) : 사업장 변경 불가
		boolean superUserFlag  = (EverString.nullToEmptyString(userInfo.getMngYn()).equals("1") || EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("M100"));
		boolean havePermission = (EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100"));
		req.setAttribute("superUserFlag", superUserFlag);
		req.setAttribute("havePermission", havePermission);

		req.setAttribute("START_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("END_DATE", EverDate.getDate());
		req.setAttribute("CPO_USER_ID", userInfo.getUserId());
		req.setAttribute("CPO_USER_NM", userInfo.getUserNm());

		return "/evermp/BOD1/BOD1_040";
	}

	@RequestMapping(value = "/bod1040_doSearch")
	public void bod1040_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bod104_Service.bod1040_doSearch(req.getFormData()));
	}

	@RequestMapping(value = "/bod1040_doSave")
	public void bod1040_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridList = req.getGridData("grid");
		String rtnMsg = bod104_Service.bod1040_doSave(gridList);

		resp.setResponseMessage(rtnMsg);
	}

	@RequestMapping(value = "/bod1040_doCancel")
	public void bod1040_doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		List<Map<String, Object>> gridList = req.getGridData("grid");
		String rtnMsg = bod104_Service.bod1040_doCancel(gridList);

		resp.setResponseMessage(rtnMsg);
	}

	/** ******************************************************************************************
	 * 고객사 > 주문관리 > 주문관리 > 주문조회/수정 > 주문상세정보
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/BOD1_041/view")
	public String BOD1_041(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		List<Map<String, Object>> list = bod104_Service.bod1041_doSearch(req.getParamDataMap());
		Map<String, Object> map = list.get(0);
		req.setAttribute("DATA", map);

		return "/evermp/BOD1/BOD1_041";
	}

	@RequestMapping(value = "/bod1041_doSearch")
	public void bod1041_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> list = bod104_Service.bod1041_doSearchINV(req.getFormData());
		List<Map<String, Object>> list2 = bod104_Service.bod1041_doSearchINV2(req.getFormData());

		resp.setGridObject("grid", list2);
		resp.setGridObject("grid2", list);
	}

	/** ******************************************************************************************
	 * 고객사 > 주문관리 > 주문상세정보
	 * @param req
	 * @return String
	 * @throws Exception
	 */
	@RequestMapping(value="/BOD1_042/view")
	public String BOD1_042(EverHttpRequest req) throws Exception {
		Map<String, String> param = req.getParamDataMap();
		req.setAttribute("formData", bod104_Service.bod1042_doSearchHD(param));
		return "/evermp/BOD1/BOD1_042";
	}

	@RequestMapping(value = "/bod1042_doSearch")
	public void bod1042_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		String gridType = EverString.nullToEmptyString(req.getParameter("gridType"));
		resp.setGridObject((gridType.equals("I") ? "gridImg" : "grid"), bod104_Service.bod1042_doSearchDT(req.getFormData(), gridType));
	}

	@RequestMapping(value = "/bod1042_doCart")
	public void bod1042_doCart(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		String gridType = EverString.nullToEmptyString(req.getParameter("gridType"));
		List<Map<String, Object>> gridDatas = req.getGridData((gridType.equals("I") ? "gridImg" : "grid"));

		String rtnMsg = bod104_Service.bod1042_doCart(req.getFormData(), gridDatas);
		resp.setResponseMessage(rtnMsg);
	}

}
