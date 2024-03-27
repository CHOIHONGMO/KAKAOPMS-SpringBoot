package com.st_ones.evermp.buyer.cn.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.cn.service.CN0100Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/cn")
public class CN0110Controller  extends BaseController {
	@Autowired CommonComboService commonComboService;
	@Autowired LargeTextService largeTextService;
	@Autowired CN0100Service cn0100service;
    @Autowired MessageService messageService;




	@RequestMapping(value = "/CN0110/view")
	public String CN0110(EverHttpRequest req) throws Exception {
		Map<String, String> param = req.getParamDataMap();
		Map<String, String> rData = new HashMap<String, String>();

        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
		param.put("CTRL_CD","T100");    //구매담당

	    req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
	    req.setAttribute("fromDate", EverDate.addMonths(-12));
		req.setAttribute("toDate", EverDate.getDate());

		String BUY_CD=PropertiesManager.getString("eversrm.default.cust.code");
    	rData.put("PR_BUYER_CD",BUY_CD);
    	rData.put("PR_BUYER_NM",(String)commonComboService.getCodes("CB0203", rData).get(0).get("VALUE"));
    	req.setAttribute("formData", rData);
    	return "/evermp/buyer/cn/CN0110";
	}

	@RequestMapping(value = "/CN0110/doSearchTargetExec")
	public void formManagementDoSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", cn0100service.doSearchTargetExec(req.getFormData()));
	}





	@RequestMapping(value = "/CN0110/doSettleCancel")
	public void ecoa0040_doExcept(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        List<Map<String, Object>> gridDatas = req.getGridData("grid");

        String resultMsg = cn0100service.settleCancel(gridDatas);
        resp.setResponseMessage(resultMsg);
	}

	@RequestMapping(value = "/CN0110/doSearchT")
    public void sso1010_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        String gubn = "";
        param.put("QTA_NUM"	, EverString.nullToEmptyString(req.getParameter("QTA_NUM")));
        param.put("QTA_CNT"	, EverString.nullToEmptyString(req.getParameter("QTA_CNT")));
        param.put("GUBUN"	, EverString.nullToEmptyString(req.getParameter("GUBUN")));
        if(EverString.nullToEmptyString(req.getParameter("GUBUN")).equals("RQ")) {
        	gubn = "gridQ";
        }else {
        	gubn = "gridB";
        }
        resp.setGridObject(gubn, cn0100service.getSettleItemList(param));
    }

}
