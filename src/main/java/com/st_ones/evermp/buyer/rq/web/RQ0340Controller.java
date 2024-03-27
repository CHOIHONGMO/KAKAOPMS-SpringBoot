package com.st_ones.evermp.buyer.rq.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.buyer.rq.service.RQ0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/rq")
public class RQ0340Controller extends BaseController {


	@Autowired private RQ0300Service rq0300service;
	@Autowired CommonComboService commonComboService;


	/********************************************************************************************
	 * 구매사> 구매관리 > 견적/입찰관리 > 협력사 선정 (RQ0140)
	 * 처리내용 : (구매사) 협력사 선정 대상을 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/RQ0340/view")
	public String RQ0340(EverHttpRequest req) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.getDate());
        Map<String, String> param = req.getParamDataMap();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
		req.setAttribute("dashBoardFlag", EverString.defaultIfEmpty(req.getParamDataMap().get("dashBoardFlag"),""));
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
		return "/evermp/buyer/rq/RQ0340";
	}

	@RequestMapping(value="/RQ0340/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0300service.getOpenSettleTargetList(req.getFormData()));
	}

	@RequestMapping(value = "/RQ0340/doQtOpen")
	public void doQtOpen(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0300service.saveQtaOpen(formData,gridData));
	}

	@RequestMapping(value="/RQ0340P01/view")
	public String RQ0340P01(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0300service.getRfqHd(formData));

		return "/evermp/buyer/rq/RQ0340P01";
	}

	@RequestMapping(value="/RQ0340P01/doSearchDocVendor")
	public void getTargetVendor(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridV", rq0300service.getTargetVendor(req.getFormData()));
	}

	@RequestMapping(value="/RQ0340P01/doSearchDocItem")
	public void getTargetItemList(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0300service.getTargetItemList(req.getFormData()));
	}


	@RequestMapping(value="/RQ0340P01/doDocSettle")
	public void doDocSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0300service.setDocSettle(formData, req.getGridData("gridV")));

	}

	@RequestMapping(value="/RQ0340P01/doCancelRfq")
	public void doCancelRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0300service.cancelRfq(formData));

	}








	@RequestMapping(value="/RQ0340P02/view")
	public String RQ0340P02(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", rq0300service.getRfqHd(formData));
		return "/evermp/buyer/rq/RQ0340P02";
	}

	@RequestMapping(value="/RQ0340P02/doSearch")
	public void getItemSettleList(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", rq0300service.getSettleItemListP02(req.getFormData()));
	}


	@RequestMapping(value="/RQ0340P02/doCancelRfq")
	public void doCancelRfq2(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(rq0300service.cancelRfq(formData));

	}

	@RequestMapping(value="/RQ0340P02/doItemSettle")
	public void doItemSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(rq0300service.doItemSettle(formData, gridData));

	}








	@RequestMapping(value="/RQ0340P03/view")
	public String RQ0340P03(EverHttpRequest req) throws Exception{
		Map<String, String> formData = req.getParamDataMap();

		List<Map<String,Object>> addColumn = rq0300service.getAdditionalColumnInfos(formData);

		req.setAttribute("additionalColumn", addColumn);
		req.setAttribute("columnsize", addColumn.size());
		req.setAttribute("form", rq0300service.getRfqHd(formData));
		return "/evermp/buyer/rq/RQ0340P03";
	}

	@RequestMapping(value="/RQ0340P03/doSearch")
	public void getItemSettleListP03(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", rq0300service.doSearchComparisonTable(param));
		resp.setResponseCode("true");
	}
	@RequestMapping(value = "/RQ0340/doSearchT")
    public void sso1010_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> param = new HashMap<String, String>();
        param.put("RFX_NUM", EverString.nullToEmptyString(req.getParameter("RFX_NUM")));
        param.put("RFX_CNT", EverString.nullToEmptyString(req.getParameter("RFX_CNT")));
        param.put("BUYER_CD", userInfo.getCompanyCd());
        resp.setGridObject("gridT", rq0300service.getSettleItemList(param));
    }

//
//
//
//
//
//
//	@RequestMapping(value="/RQ0140P03/view")
//	public String RQ0140P03(EverHttpRequest req) throws Exception{
//    	Map<String, String> formData = req.getParamDataMap();
//    	req.setAttribute("form", rq0100service.getRfqHd(formData));
//        req.setAttribute("fromDate", EverDate.getDate());
//        req.setAttribute("todayTime", EverDate.getTime().substring(0,4));
//		return "/evermp/buyer/rq/RQ0140P03";
//	}
//
//	@RequestMapping(value="/RQ0140P03/doReRfq")
//	public void doReRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception{
//        Map<String, String> formData = req.getFormData();
//		resp.setResponseMessage(rq0100service.reRfq(formData));
//	}


/*
	@Autowired private POPdfGenerator poPdfGenerator;
	@Autowired private com.st_ones.evermp.buyer.cont.service.makeHtmlService makeHtmlService;

	@RequestMapping(value="/RQ0340/doPDFTest")
	public void doPDF(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		String htmlContents = poPdfGenerator.generatorPdfInvoiceMaterial((Map)req.getFormData());

		makeHtmlService.makepdfStrPO(htmlContents, PropertiesManager.getString("html.output.path.po")+"generatorPdfInvoiceItem0817.pdf");
		//makeHtmlService.makepdfStrInvoice(htmlContents, PropertiesManager.getString("html.output.path.po")+"middest.pdf", PropertiesManager.getString("html.output.path.po")+"finaldest.pdf");
	}

	@RequestMapping(value="/RQ0340/doPDFTestPOOEM")
	public void doPDFTestPOOEM(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		String htmlContents = poPdfGenerator.generatorPdfInvoiceOEM((Map)req.getFormData());

		makeHtmlService.makepdfStrPO(htmlContents, PropertiesManager.getString("html.output.path.po")+"generatorPdfInvoiceOEM0817.pdf");
		//makeHtmlService.makepdfStrInvoice(htmlContents, PropertiesManager.getString("html.output.path.po")+"middest.pdf", PropertiesManager.getString("html.output.path.po")+"finaldest.pdf");
	}
*/











}