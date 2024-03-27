package com.st_ones.evermp.buyer.eval.web;

import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.eval.service.EV0270Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Controller
@RequestMapping(value = "/evermp/buyer/eval")
public class EV0270Controller extends BaseController{
@Autowired EV0270Service ev0270Service;

	/**
	 * Sup confirm list.
	 *
	 * @param req request
	 * @return the string
     */
	@RequestMapping(value="/EV0270/view")
	public String EV0270(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }


		Map<String, String>form = new HashMap<String, String>();
		form.put("REG_DATE_FROM",EverDate.addMonths(-1));
		form.put("REG_DATE_TO"  ,EverDate.getDate());
		req.setAttribute("form", form);
		return "/evermp/buyer/eval/EV0270";
	}


	@RequestMapping(value="/EV0270P01/view")
	public String EV0270P01(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String>form = new HashMap<String, String>();
		Map<String, String> param = req.getParamDataMap();
		form = ev0270Service.getEsgValueInfo(param);
		req.setAttribute("form", form);
		return "/evermp/buyer/eval/EV0270P01";
	}


	@RequestMapping(value="/EV0270P01/doSearch")
	public void doSearchEV0270P01(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();


		List<Map<String, Object>> gridDatas = ev0270Service.doSearchEsgSummaryList(param);


		for(int i = 0; i < gridDatas.size(); i++) {
			Map<String, Object> data = gridDatas.get(i);

			if (String.valueOf(data.get("CONTENTS")).trim().equals("환경")) {
				resp.setGridRowStyle("grid", String.valueOf(i), "text-decoration", "inherit");
				resp.setGridRowStyle("grid", String.valueOf(i), "background-color", "#89aa30");
			}
			if (String.valueOf(data.get("CONTENTS")).trim().equals("사회")) {
				resp.setGridRowStyle("grid", String.valueOf(i), "text-decoration", "inherit");
				resp.setGridRowStyle("grid", String.valueOf(i), "background-color", "#41a1ab");
			}
			if (String.valueOf(data.get("CONTENTS")).trim().equals("지배구조")) {
				resp.setGridRowStyle("grid", String.valueOf(i), "text-decoration", "inherit");
				resp.setGridRowStyle("grid", String.valueOf(i), "background-color", "#cb3a25");
			}
			if (String.valueOf(data.get("CONTENTS")).trim().equals("ESG 종합")) {
				resp.setGridRowStyle("grid", String.valueOf(i), "text-decoration", "inherit");
				resp.setGridRowStyle("grid", String.valueOf(i), "background-color", "#fdd");
			}

		}





		resp.setGridObject("grid", gridDatas);

	}




















	/**
	 * Do search.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0270/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = req.getFormData();

		param.put("REG_DATE_FROM"	, EverDate.getGmtFromDate(param.get("REG_DATE_FROM"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		param.put("REG_DATE_TO"		, EverDate.getGmtToDate  (param.get("REG_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));

		resp.setGridColStyle("grid", "EV_SCORE", "background-color", "#FFFF99");
		resp.setGridColStyle("grid", "EVAL_GRADE_CLS", "background-color", "#FFFF99");
		resp.setGridColStyle("grid", "AMEND_REASON", "background-color", "#FFFF99");


		//평가 완료시 점수,등급,조정사유 편집가능
		List<Map<String, Object>> gridDatas = ev0270Service.doSearch(param);
		for(int i = 0; i<gridDatas.size(); i++){
			String progress_cd = gridDatas.get(i).get("PROGRESS_CD").toString();
			if(progress_cd.equals("300")){
				resp.setCellReadOnly("grid", String.valueOf(i), "EV_SCORE", false);
				resp.setCellReadOnly("grid", String.valueOf(i), "EVAL_GRADE_CLS", false);
				resp.setCellReadOnly("grid", String.valueOf(i), "AMEND_REASON", false);
			}
		}

		resp.setGridObject("grid", gridDatas);

	}
	/**
	 * doComplete.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0270/doComplete")
	public void srm270_doComplete(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");
		String msg = ev0270Service.srm270_doComplete(gridDatas);

		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}
	/**
	 * doCancel.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0270/doCancel")
	public void doCancel(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");
		String msg = ev0270Service.doCancel(gridDatas);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	/**
	 * doEdit.
	 *
	 * @param req request
	 * @param resp response
	 * @throws Exception the exception
     */
	@RequestMapping(value="/EV0270/doEdit")
	public void doEdit(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		List<Map<String, Object>> gridDatas = req.getGridData("grid");
		String msg = ev0270Service.doEdit(gridDatas);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}


	@RequestMapping(value="/EV0270P03/view")
	public String EV0270P03(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		req.setAttribute("form", req.getParamDataMap());
		return "/evermp/buyer/eval/EV0270P03";
	}

	@RequestMapping(value="/EV0270P03/doSearch")
	public void EV0270P03_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", ev0270Service.EV0270P03_doSearch(req.getFormData()));
	}
}







