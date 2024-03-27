package com.st_ones.evermp.buyer.cn.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.bd.BD0300Mapper;
import com.st_ones.evermp.buyer.cn.service.CN0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
@Controller
@RequestMapping(value = "/evermp/buyer/cn")
public class CN0120Controller  extends BaseController {
	@Autowired CommonComboService commonComboService;
	@Autowired LargeTextService largeTextService;
	@Autowired CN0100Service cn0100service;
    @Autowired MessageService messageService;
    @Autowired private BD0300Mapper test;




	@RequestMapping(value = "/CN0120/view")
	public String CN0120(EverHttpRequest req) throws Exception {
		Map<String,String> param = req.getParamDataMap();
		Map<String, String> formData = new HashMap<String, String>();
		UserInfo userInfo = UserInfoManager.getUserInfo();


		if(EverString.isEmpty(param.get("EXEC_NUM")) && EverString.isEmpty(param.get("APP_DOC_NUM"))) {
			List<Map<String, Object>> qtaList = new ObjectMapper().readValue(param.get("QTA_NUM_LIST"), List.class);
			formData.put("PR_TYPE"		,String.valueOf(qtaList.get(0).get("PR_TYPE")));
			formData.put("PR_BUYER_CD"	,String.valueOf(qtaList.get(0).get("PR_BUYER_CD")));
			formData.put("PR_BUYER_NM"	,String.valueOf(qtaList.get(0).get("PR_BUYER_NM")));
			formData.put("PR_PLANT_CD"	,String.valueOf(qtaList.get(0).get("PR_PLANT_CD")));
			formData.put("PR_PLANT_NM"	,String.valueOf(qtaList.get(0).get("PR_PLANT_NM")));
			formData.put("SHIPPER_TYPE"	,String.valueOf(qtaList.get(0).get("SHIPPER_TYPE")));
			formData.put("EXEC_SUBJECT"	,String.valueOf(qtaList.get(0).get("RFX_SUBJECT")));
			formData.put("REQ_USER_NM"	,String.valueOf(qtaList.get(0).get("REQ_USER_NM")));
			formData.put("REQ_DEPT_INFO",String.valueOf(qtaList.get(0).get("REQ_DEPT_INFO")));
			formData.put("REQ_USER_ID"	,String.valueOf(qtaList.get(0).get("REQ_USER_ID")));
			formData.put("CTRL_USER_ID"	,userInfo.getUserId());
			formData.put("CTRL_USER_NM"	,userInfo.getUserNm());
			formData.put("EXEC_DATE"	,EverDate.getDate());
			formData.put("SIGN_STATUS"	,"");
			formData.put("IF_SIGN_FLAG"	,"");

			String qtaNumList = "";
			for(Map<String,Object> data : qtaList) {
				qtaNumList += ","+data.get("QTA_NUM");
			}
			formData.put("QTA_NUM_LIST",qtaNumList);
		}else if("EXEC_CHAGE".equals(param.get("EXEC_TYPE_D"))) {
			List<Map<String, Object>> qtaList = new ObjectMapper().readValue(param.get("QTA_NUM_LIST"), List.class);

			formData = cn0100service.getCnhd(param);
			String qtaNumList = "";
			for(Map<String,Object> data : qtaList) {
				qtaNumList += ","+data.get("QTA_NUM");
			}
			formData.put("QTA_NUM_LIST",qtaNumList);
			formData.put("EXEC_TYPE_D",param.get("EXEC_TYPE_D"));
			formData.put("CH_CTRL_USER_ID",param.get("CH_CTRL_USER_ID"));
			formData.put("CH_CTRL_USER_NM",param.get("CH_CTRL_USER_NM"));
		}else {
			formData = cn0100service.getCnhd(param);
//			formData.put("GUBN","1");

		}
    	req.setAttribute("form", formData);
		return "/evermp/buyer/cn/CN0120";
	}

	@RequestMapping(value = "/CN0120P02/view")
	public String CN0120_2(EverHttpRequest req) throws Exception {
		req.setAttribute("fromDate", EverDate.addMonths(-12));
		req.setAttribute("toDate", EverDate.getDate());
		Map<String,String> param = req.getParamDataMap();
		Map<String, String> formData = new HashMap<String, String>();
		List<Map<String, Object>> qtaList = new ObjectMapper().readValue(param.get("QTA_NUM_LIST"), List.class);
		formData.put("PR_TYPE"			,String.valueOf(qtaList.get(0).get("PR_TYPE")));
		formData.put("PR_BUYER_CD"		,String.valueOf(qtaList.get(0).get("PR_BUYER_CD")));
		formData.put("PR_BUYER_NM"		,String.valueOf(qtaList.get(0).get("PR_BUYER_NM")));
		formData.put("PR_PLANT_CD"		,String.valueOf(qtaList.get(0).get("PR_PLANT_CD")));
		formData.put("PR_PLANT_NM"		,String.valueOf(qtaList.get(0).get("PR_PLANT_NM")));
		formData.put("RFX_TYPE"			,String.valueOf(qtaList.get(0).get("RFX_TYPE")));
		formData.put("CPO_USER_ID"		,String.valueOf(qtaList.get(0).get("CPO_USER_ID")));
		formData.put("CPO_USER_NM"		,String.valueOf(qtaList.get(0).get("CPO_USER_NM")));
		formData.put("CH_CTRL_USER_ID"	,String.valueOf(qtaList.get(0).get("CTRL_USER_ID")));
		formData.put("CH_CTRL_USER_NM"	,String.valueOf(qtaList.get(0).get("CTRL_USER_NM")));
		formData.put("updatePg","true");
		req.setAttribute("form", formData);
		req.setAttribute("QTA_NUM_LIST", param.get("QTA_NUM_LIST"));
		return "/evermp/buyer/cn/CN0120P02";
	}

	@RequestMapping(value = "/CN0120P02/doSearch")
	public void formManagementDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
	    param.put("PROGRESS_CD", EverString.nullToEmptyString(req.getParameter("PROGRESS_CD")));
	    param.put("EXEC_TYPE_D", EverString.nullToEmptyString(req.getParameter("EXEC_TYPE_D")));

	    resp.setGridObject("grid", cn0100service.getExecList(param));
	}

	@RequestMapping(value = "/CN0120/doSearchCnvd")
	public void doSearchCnvd(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridV", cn0100service.doSearchCnvd(req.getFormData()));
		req.getFormData().put("GUBN","1");
		resp.setDataObject("PAY_INFO",cn0100service.doSearchCnvd(req.getFormData()));

	}

	@RequestMapping(value = "/CN0120/doSearchCndt")
	public void doSearchCndt(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("gridItem", cn0100service.doSearchCndt(req.getFormData()));
	}

	@RequestMapping(value = "/CN0120/doSave")
	public void CN0120_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
        List<Map<String, Object>> gridV = req.getGridData("gridV");
        List<Map<String, Object>> gridItem = req.getGridData("gridItem");
        Map<String, String> result;

        try {
        	result = cn0100service.saveExec( formData , gridV, gridItem);

            resp.setParameter("isSuccess", "true");
            resp.setResponseMessage(result.get("message"));
            resp.setResponseCode("true");
            resp.setParameter("EXEC_NUM", result.get("EXEC_NUM"));
            resp.setParameter("EXEC_CNT", result.get("EXEC_CNT"));
        } catch (Exception e) {
            resp.setParameter("isSuccess", "false");
            resp.setResponseMessage(e.getMessage());
            resp.setResponseCode("false");
            e.printStackTrace();
        }
	}



	@RequestMapping(value = "/CN0120/doDelete")
	public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> formData = req.getFormData();
        Map<String, String> result;

        try {
        	result = cn0100service.deleteExec( formData);

            resp.setResponseMessage(result.get("message"));
            resp.setResponseCode("true");
        } catch (Exception e) {
            resp.setParameter("isSuccess", "false");
            resp.setResponseMessage(e.getMessage());
            resp.setResponseCode("false");
            e.printStackTrace();
        }
	}


	@RequestMapping(value = "/CN0120P01/view")
	public String CN0120P01(EverHttpRequest req) throws Exception {
		Map<String,String> param = req.getParamDataMap();
		Map<String, String> formData = new HashMap<String, String>();
		UserInfo userInfo = UserInfoManager.getUserInfo();


    	req.setAttribute("form", formData);
		return "/evermp/buyer/cn/CN0120P01";
	}


	@RequestMapping(value="/CN0120P03/view")
	public String CN0120P03(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		return "/evermp/buyer/cn/CN0120P03";
	}

	@RequestMapping(value = "/CN0120P03/doSearch")
	public void CN0120P03_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String,String> param = req.getParamDataMap();
		List<Map<String, Object>> qtaList = new ObjectMapper().readValue(param.get("qtaNumList"), List.class);
		String qtaNumList = "";
		for(Map<String,Object> data : qtaList) {
			qtaNumList += ","+data.get("QTA_NUM");
		}
		param.put("QTA_NUM_LIST",qtaNumList);
		//물품대비표 쿼리 같이씀.
		if(!EverString.isEmpty(param.get("EXEC_NUM"))) {
			param.put("CN0120P03_GUBN","CN0120P03");

		}
		resp.setGridObject("grid", cn0100service.doSearchCndt(param));
	}
	@RequestMapping(value="/CN0120P04/view")
	public String CN0120P04(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String,String> param = req.getParamDataMap();
		List<Map<String, Object>> qtaList = new ObjectMapper().readValue(param.get("QTA_NUM_LIST"), List.class);
		String qtaNumList = "";
		for(Map<String,Object> data : qtaList) {
			qtaNumList += ","+data.get("RFX_NUM")+"-"+data.get("RFX_CNT");
		}
		req.setAttribute("QTA_NUM_LIST", qtaNumList);
		return "/evermp/buyer/cn/CN0120P04";
	}

	@RequestMapping(value = "/CN0120P04/doSearch")
	public void CN0120P04_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String,String> param = req.getParamDataMap();
		String[] contArr = req.getParameter("RFX_SEQ").split("-");
		param.put("RFX_NUM",contArr[0]);
		param.put("RFX_CNT",contArr[1]);
		List<Map<String,Object>> addColumn = cn0100service.getAdditionalColumnInfos(param);
		Map<String, Object> formData =cn0100service.getHdDetail(param);
		resp.setDataObject("additionalColumn", addColumn);
		resp.setDataObject("columnsize", addColumn.size());
		resp.setFormDataObject(formData);
		resp.setDataObject("grid", cn0100service.getDtList(param));
	}
}
