package com.st_ones.evermp.buyer.cn.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.html.service.HtmlService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.util.EverString;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cn.service.CN0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/cn")
public class CN0130Controller  extends BaseController {

	@Autowired CommonComboService commonComboService;
	@Autowired LargeTextService largeTextService;
	@Autowired CN0100Service cn0100service;
    @Autowired MessageService messageService;
    @Autowired HtmlService htmlService;

	@RequestMapping(value = "/CN0130/view")
	public String CN0110(EverHttpRequest req) throws Exception {
		Map<String, String> rData = new HashMap<String, String>();
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		req.setAttribute("fromDate", EverDate.addMonths(-12));
		req.setAttribute("toDate", EverDate.getDate());

		String BUY_CD=PropertiesManager.getString("eversrm.default.cust.code");
		rData.put("PR_BUYER_CD",BUY_CD);
    	rData.put("PR_BUYER_NM",(String)commonComboService.getCodes("CB0203", rData).get(0).get("VALUE"));
    	req.setAttribute("formData", rData);
		return "/evermp/buyer/cn/CN0130";
	}

	@RequestMapping(value = "/CN0130/doSearch")
	public void formManagementDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", cn0100service.getExecList(req.getFormData()));
	}
	@RequestMapping(value = "/CN0130P01/view")
	public String CN0130P01(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getParamDataMap();
		Map<String, Object> rData = new HashMap<String, Object>();
		boolean flag = cn0100service.gbunFlag(formData);
		//결재신청하면
		if(flag) {
			if(formData.get("EXEC_GB").equals("H") && EverString.isEmpty(formData.get("APP_DOC_NUM2"))) {
				//본사품의
				rData = htmlService.getLoHtml(formData);

			}else  if(formData.get("EXEC_GB").equals("CH") && EverString.isEmpty(formData.get("APP_DOC_NUM2"))) {
				//변경본사품의
				rData = htmlService.getChLoHtml(formData);

			}else {
				rData =cn0100service.getTmHtml(formData);
			}
		}else {
			//결재신청중이면
			if(formData.get("EXEC_GB").equals("P") ) {
				//구매품의
				rData = htmlService.getPuHtml(formData);

			}else if(formData.get("EXEC_GB").equals("CP")) {
				//변경구매품의
				rData = htmlService.getChPuHtml(formData);

			}else if(formData.get("EXEC_GB").equals("BD")) {
				//입찰시행
				rData = htmlService.getBdHtml(formData);

			}else if(formData.get("EXEC_GB").equals("H")){
				rData = htmlService.getLoHtml(formData);
			}else if(formData.get("EXEC_GB").equals("CH")){
				rData = htmlService.getChLoHtml(formData);
			}

		}
		rData.put("screenName",formData.get("screenName"));

		resp.setParameter("EXEC_NUM"		, formData.get("EXEC_NUM"));
		resp.setParameter("EXEC_CNT"		, String.valueOf(formData.get("EXEC_CNT")));
		rData.put("EXEC_NUM"		, String.valueOf(formData.get("EXEC_NUM")));
		rData.put("EXEC_CNT"		, String.valueOf(formData.get("EXEC_CNT")));
		rData.put("APP_DOC_NUM"		, String.valueOf(formData.get("APP_DOC_NUM")));
		rData.put("APP_DOC_CNT"		, String.valueOf(formData.get("APP_DOC_CNT")));
		rData.put("APP_DOC_NUM2"	, String.valueOf(formData.get("APP_DOC_NUM2")));
		rData.put("APP_DOC_CNT2"	, String.valueOf(formData.get("APP_DOC_CNT2")));
		rData.put("IF_SIGN_FLAG"	, String.valueOf(formData.get("EXEC_GB")));
//		rData.put("SIGN_STATUS"		, EverString.isEmpty(String.valueOf(rData.get("SIGN_STATUS")))? "T" : rData.get("SIGN_STATUS"));
		rData.put("SIGN_STATUS2"	, String.valueOf(formData.get("SIGN_STATUS2")));
		rData.put("pageName"		, String.valueOf(formData.get("pageName")));
    	req.setAttribute("formData"	, rData);
		return "/evermp/buyer/cn/CN0130P01";
	}

	@RequestMapping(value = "/doSign")
	public void doSign(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		Map<String, String> reData   = new HashMap<String, String>();
		reData= cn0100service.gwSign(formData);
		resp.setParameter("APP_DON_NUM2", reData.get("APP_DON_NUM2"));
	    resp.setResponseMessage(reData.get("REMSG"));

	}
}
