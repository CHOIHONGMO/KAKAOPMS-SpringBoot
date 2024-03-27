package com.st_ones.evermp.vendor.qt.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.qt.service.QT0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/vendor/qt")
public class QT0330Controller extends BaseController {


	@Autowired private QT0300Service qt0300Service;
	@Autowired private CommonComboService commonComboService;

	/********************************************************************************************
	 * 협력사 > 견적관리 > 견적관리 > 견적결과 (QT0220)
	 * 처리내용 : (협력사) 견적 진행 결과를 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value= "/QT0330/view")
	public String QT0330(EverHttpRequest req) throws Exception{

		Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "Q");

		req.setAttribute("fromDate", EverDate.addMonths(-1));
		req.setAttribute("toDate", EverDate.getDate());

		return "/evermp/vendor/qt/QT0330";
	}

	@RequestMapping(value= "/QT0330/doSearch")
	public void QT0330_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", qt0300Service.getQtaList(req.getFormData()));
	}
	 @RequestMapping(value = "/QT0330/doSearchT")
	    public void sso1010_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

	        UserInfo userInfo = UserInfoManager.getUserInfo();
	        Map<String, String> param = new HashMap<String, String>();
	        param.put("RFX_NUM", EverString.nullToEmptyString(req.getParameter("RFX_NUM")));
	        param.put("RFX_CNT", EverString.nullToEmptyString(req.getParameter("RFX_CNT")));
	        param.put("BUYER_CD", EverString.nullToEmptyString(req.getParameter("BUYER_CD")));
	        param.put("VENDOR_CD", userInfo.getCompanyCd())
	        ;param.put("scrId", "0330");
	        resp.setGridObject("gridT", qt0300Service.doSearchT(param));
	    }
}