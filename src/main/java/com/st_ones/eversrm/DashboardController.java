package com.st_ones.eversrm;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping(value = "/eversrm")
public class DashboardController extends BaseController {

	@Autowired private CommonComboService commonComboService;

	@Autowired private DashboardService DashboardService;

	// 운영사 대쉬보드
	@RequestMapping(value = "/mypageBuyer/view")
	public String mypageBuyer(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = new HashMap<String, String>();

		req.setAttribute("form", null/*DashboardService.mypageTypeC(param)*/);
		req.setAttribute("accessableScreenId", DashboardService.getMyScreenId(null));
		req.setAttribute("noticeListMain", DashboardService.getNoitceListMain(param));
		req.setAttribute("voiceListMain", DashboardService.getVoiceListMain(param));
		return "/eversrm/mypageBuyer";
	}

	// 공급사 대쉬보드
	@RequestMapping(value = "/mypageSupplier/view")
	public String mypageSupplier(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = new HashMap<String, String>();
		param.put("VENDOR_CD", userInfo.getCompanyCd());
		param.put("FROM_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("TO_DATE", EverDate.getDate());
		param.put("FROM_DATE2", EverDate.addDateMonth(EverDate.getDate(), -2));
		param.put("RFQ_FROM_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("RFQ_TO_DATE", EverDate.addDateMonth(EverDate.getDate(), 1));

		req.setAttribute("form", DashboardService.mypageTypeS(param));
		req.setAttribute("systemDateTime", EverDate.getDateString());
		req.setAttribute("fromDate1", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("fromDate2", EverDate.addDateMonth(EverDate.getDate(), -2));
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("RFQ_FROM_DATE", param.get("RFQ_FROM_DATE"));
		req.setAttribute("RFQ_TO_DATE", param.get("RFQ_TO_DATE"));
		req.setAttribute("noticeListMain", DashboardService.getNoitceListMain(param));
		return "/eversrm/mypageSupplier";
	}

	// 고객사 대쉬보드
	@RequestMapping(value = "/mypageCustomer/view")
	public String mypageCustomer(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = new HashMap<String, String>();
		param.put("CUST_CD", userInfo.getCompanyCd());
		param.put("USER_ID", userInfo.getUserId());
		param.put("FROM_DATE3", EverDate.addDateMonth(EverDate.getDate(), -3));
		param.put("FROM_DATE", EverDate.addDateMonth(EverDate.getDate(), -1));
		param.put("TO_DATE", EverDate.getDate());
		param.put("TWO_WEEKS", EverDate.addDateDay(EverDate.getDate(), -14));

		req.setAttribute("form", DashboardService.mypageTypeB(param));
		req.setAttribute("systemDateTime", EverDate.getDateString());
		req.setAttribute("ItemClsList", DashboardService.getItemClsList(param));
		req.setAttribute("fromDate3", EverDate.addDateMonth(EverDate.getDate(), -3));
		req.setAttribute("fromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("toDate", EverDate.getDate());
		req.setAttribute("twoWeeks", EverDate.addDateDay(EverDate.getDate(), -14));
		req.setAttribute("noticeListMain", DashboardService.getNoitceListMain(param));
		return "/eversrm/mypageCustomer";
	}

	@RequestMapping(value = "/getTodo{division}")
	public void getTodos(EverHttpResponse resp, @PathVariable("division") String division) {

		resp.setParameter("division", division);
		resp.setParameter("todo"+division+"Html", DashboardService.getTodo(division));
	}

   	@RequestMapping(value = "/doNotice")
   	public void doNotice(EverHttpRequest req, EverHttpResponse resp) throws Exception {
   		Map<String, String> param = req.getFormData();
   		resp.setLinkStyle("notice", "SUBJECT");
        resp.setGridObject("notice", DashboardService.doNotice(param));
        resp.setResponseCode("true");
   	}

   	@RequestMapping(value = "/doFaq")
   	public void doFaq(EverHttpRequest req, EverHttpResponse resp) throws Exception {
   		Map<String, String> param = req.getFormData();
   		param.put("NOTICE_TYPE", "PCF");
   		resp.setLinkStyle("faq", "SUBJECT");
        resp.setGridObject("faq", DashboardService.doFaq(param));
        resp.setResponseCode("true");
   	}

   	@RequestMapping(value = "/doQna")
   	public void doQna(EverHttpRequest req, EverHttpResponse resp) throws Exception {
   		Map<String, String> param = req.getFormData();
   		EverString.makeGridTextBlueStyle(resp, "qna", "SUBJECT");
        resp.setGridObject("qna", DashboardService.doQna(param));
        resp.setResponseCode("true");
   	}

	@RequestMapping(value = "/doNewgrid")
	public void doNewgrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("newgrid", DashboardService.doNewgrid(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/doBggrid")
	public void doBggrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("bggrid", DashboardService.doBggrid(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/doMygrid")
	public void doMygrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("mygrid", DashboardService.doMygrid(param));
		resp.setResponseCode("true");
	}

	// 운영사 Grid 조회
    @RequestMapping(value = "/opGrids")
    public void doOpGrid1(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = req.getFormData();
        param.put("START_DATE", EverDate.addMonths(-12));
        param.put("FROM_DATE", EverDate.addMonths(-1));
        param.put("END_DATE", EverDate.getDate());
        param.put("YESTERDAY", EverDate.addDateDay(EverDate.getDate(), -1));

        resp.setGridObject("grid1", DashboardService.doOpGrid1(param));
        resp.setGridObject("grid2", DashboardService.doOpGrid2(param));
        resp.setGridObject("grid3", DashboardService.doOpGrid3(param));
        resp.setGridObject("grid4", DashboardService.doOpGrid4(param));
        resp.setGridObject("grid5", DashboardService.doOpGrid5(param));
		resp.setGridObject("grid6", DashboardService.doOpGrid6(param));
		resp.setGridObject("grid7", DashboardService.doOpGrid7(param));

        resp.setResponseCode("true");
    }

}
