package com.st_ones.evermp.buyer.bd.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.bd.service.BD0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/bd")
public class BD0360Controller extends BaseController {


	@Autowired private BD0300Service bd0300Service;
	@Autowired CommonComboService commonComboService;


	/********************************************************************************************
	 * 구매사> 구매관리 > 입찰관리 > 협력업체 선정 (BD0360)
	 * 처리내용 : (구매사) 협력사 선정 대상을 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/BD0360/view")
	public String BD0360(EverHttpRequest req) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }

		String vendorCd = EverString.nullToEmptyString(req.getParameter("VENDOR_CD"));
		String vendorNm = EverString.nullToEmptyString(req.getParameter("VENDOR_NM"));

		Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "B");
		req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("FromDate", EverDate.addDateMonth(EverDate.getDate(), -24));
        req.setAttribute("addToDate", EverDate.addDays(7));
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
		param.put("VENDOR_CD", vendorCd);
		param.put("VENDOR_NM", vendorNm);
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
		req.setAttribute("searchFlag", EverString.defaultIfEmpty(req.getParamDataMap().get("searchFlag"),""));
		return "/evermp/buyer/bd/BD0360";
	}

	@RequestMapping(value="/BD0360/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> formData=req.getFormData();
		formData.put("BD_COMPLETION",req.getParameter("BD_COMPLETION"));
		resp.setGridObject("grid", bd0300Service.doSearch0360(formData));
	}



}