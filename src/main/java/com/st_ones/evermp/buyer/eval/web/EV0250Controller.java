package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.bd.service.BD0300Service;
import com.st_ones.evermp.buyer.eval.service.EV0250Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Controller
@RequestMapping(value="/evermp/buyer/eval")
public class EV0250Controller extends BaseController {

	@Autowired EV0250Service EV0250_service;
	@Autowired BD0300Service bd0300Service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0250/view")
	public String EV0250(EverHttpRequest req, EverHttpResponse resp) throws Exception{

		Map<String, String> param = req.getFormData();
		String gbn = req.getParameter("gbn");

		if( "doSearchRight".equals(gbn) ) { //크리드 셀클릭 조회
			doSelectRight(resp, req);
		} else {								//초기 창
			param.put("EV_USER_NM_L"			, req.getParameter("EV_USER_ID"));
			param.put("EV_NUM_L"				, req.getParameter("EV_NUM"));
			param.put("VENDOR_NM_L"				, req.getParameter("VENDOR_NM_L"));
			param.put("RESULT_ENTER_CD"			, req.getParameter("RESULT_ENTER_CD"));
			param.put("RESULT_ENTER_USER_ID"	, req.getParameter("EV_USER_ID"));
			param.put("EV_CTRL_USER_ID"			, req.getParameter("EV_CTRL_USER_ID"));
			param.put("VENDOR_CD_L"				, req.getParameter("VENDOR_CD"));
			param.put("VENDOR_SQ_L"				, req.getParameter("VENDOR_SQ"));
			param.put("EV_TYPE"					, req.getParameter("EV_TYPE"));
			param.put("detailView"				, req.getParameter("detailView"));

			param.put("ESG_CHK_TYPE"			, req.getParameter("ESG_CHK_TYPE"));

			req.setAttribute("evUserNmLOptions"	,	EverConverter.getJsonString(EV0250_service.getEvUserCombo(param)) );
			req.setAttribute("regStatusLOptions", 	EverConverter.getJsonString(EV0250_service.getRegCombo(param)) );

			//param.put("detailView", EverString.nullToEmptyString(req.getParameter("detailView")).equals("") ? "true" : req.getParameter("detailView"));
			req.setAttribute("leftform"			,	param);

		}
		return "/evermp/buyer/eval/EV0250";
	}

	/**
	 * doSearch.
	 *
	 * @param req request
	 * @return void
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0250/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();


		param.put("exclusion","true");


		req.setAttribute("leftform", param);
		resp.setGridObject("leftgrid", EV0250_service.doSearch(param));
		resp.setResponseCode("true");
	}

	/**
	 * doSelectRight.
	 *
	 * @param req request
	 * @return void
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0250/doSelectRight")
	public void doSelectRight(EverHttpResponse resp, EverHttpRequest req) throws Exception{

		Map<String, String> param = req.getFormData();
		param.put("exclusion","true");
		if(req.getParameter("DETAIL_VIEW").equals("false") || "".equals(EverString.nullToEmptyString(req.getParameter("VENDOR_CD_L")))) {
			param.put("EV_USER_NM_L", req.getParameter("EV_USER_ID"));
		}
		param.put("EV_NUM_L"				, req.getParameter("EV_NUM_L"));
		param.put("VENDOR_NM_L"				, req.getParameter("VENDOR_NM_L"));
		param.put("RESULT_ENTER_CD"			, req.getParameter("RESULT_ENTER_CD"));
		param.put("RESULT_ENTER_USER_ID"	, req.getParameter("RESULT_ENTER_USER_ID"));
		param.put("EV_CTRL_USER_ID"			, req.getParameter("EV_CTRL_USER_ID"));
		param.put("VENDOR_CD_L"				, req.getParameter("VENDOR_CD_L"));
		param.put("VENDOR_SQ_L"				, req.getParameter("VENDOR_SQ_L"));

		param.put("REG_STATUS_L", req.getParameter("REG_STATUS_L"));

		param.put("EV_TPL_NUM"	, req.getParameter("EV_TPL_NUM"));
		param.put("EV_USER_ID"	, req.getParameter("EV_USER_ID"));
		param.put("EV_USER_NM_R", req.getParameter("EV_USER_NM_R"));
		param.put("VENDOR_NM_R"	, req.getParameter("VENDOR_NM_R"));
		param.put("VENDOR_CD"	, req.getParameter("VENDOR_CD"));
		param.put("VENDOR_SQ"	, req.getParameter("VENDOR_SQ"));

		param.put("SEL_ROW"		, req.getParameter("SEL_ROW"));
		param.put("detailView"  , req.getParameter("DETAIL_VIEW"));
		param.put("EV_TYPE"	    , req.getParameter("EV_TYPE"));
		param.put("ESG_CHK_TYPE"	    , req.getParameter("ESG_CHK_TYPE2"));

		req.setAttribute("evUserNmLOptions"	,	EverConverter.getJsonString(EV0250_service.getEvUserCombo(param)));
		req.setAttribute("regStatusLOptions", 	EverConverter.getJsonString(EV0250_service.getRegCombo(param)) );
		req.setAttribute("leftform", param);

		Map<String, String> rightform =  EV0250_service.doSearchEveu(param);
		Map<String, Object> form  = new java.util.HashMap<String, Object>();
		req.setAttribute("rightform", rightform);
		req.setAttribute("gbn", "right");
		form.put("ev_type", 	EV0250_service.doSearchType(param));
		form.put("ev_subject", 	EV0250_service.doSearchSubject(param));
		form.put("ev_item", 	EV0250_service.doSearchDetail(param));

		req.setAttribute("form2", EverConverter.getJsonString(form));
		req.setAttribute("developFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));
		resp.setResponseCode("true");
	}

	/**
	 * doSave.
	 *
	 * @param req request
	 * @return void
	 * @throws Exception the exception
     */
	@RequestMapping(value = "/EV0250/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();
		String msg = "";
		if(param.get("EV_TPL_NUM").equals("EVT20220100004") || param.get("EV_TPL_NUM").equals("EVT20220100005") || param.get("EV_TPL_NUM").equals("EVT20220100006") ){
			msg = bd0300Service.doSaveEvResult(param);
		}else{
			msg = EV0250_service.doSave(param);
		}
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");

	}
}
