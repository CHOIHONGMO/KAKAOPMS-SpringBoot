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
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping(value = "/evermp/buyer/bd")
public class BD0340Controller extends BaseController {


	@Autowired private BD0300Service bd0300Service;
	@Autowired CommonComboService commonComboService;


	/********************************************************************************************
	 * 구매사> 구매관리 > 입찰관리 > 협력업체 선정 (BD0340)
	 * 처리내용 : (구매사) 협력사 선정 대상을 조회하는 화면
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value="/BD0340/view")
	public String BD0340(EverHttpRequest req) throws Exception{
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		Map<String, String> param = new HashMap<>();
		param.put("FLAG1", "B");
		req.setAttribute("PROGRESS_CD_Options", commonComboService.getCodesAsJson("CB0109", param));
        req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
        req.setAttribute("addToDate", EverDate.addDays(7));
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD","T100");    //구매담당
        req.setAttribute("ctrlUserNmOptions", commonComboService.getCodesAsJson("CB0064", param));
		return "/evermp/buyer/bd/BD0340";
	}

	@RequestMapping(value="/BD0340/doSearch")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", bd0300Service.getBdOpenSettleTargetList(req.getFormData()));
	}
	@RequestMapping(value = "/BD0340/doSearchT")
    public void sso1010_doSearchB(EverHttpRequest req, EverHttpResponse resp) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("RFX_NUM", EverString.nullToEmptyString(req.getParameter("RFX_NUM")));
        param.put("RFX_CNT", EverString.nullToEmptyString(req.getParameter("RFX_CNT")));
        resp.setGridObject("gridT", bd0300Service.doSearchT(param));
    }
	@RequestMapping(value = "/BD0340/doQtOpen")
	public void doQtOpen(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(bd0300Service.saveBQOpen(gridData));
	}

	@RequestMapping(value="/BD0340P01/view")
	public String BD0340P01(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", bd0300Service.getBdHdDetail(formData));
		return "/evermp/buyer/bd/BD0340P01";
	}

	@RequestMapping(value="/BD0340P01/doSearchDocVendor")
	public void getDocBqVendor(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridV", bd0300Service.getBqDocVendorListByBd(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P01/doSearchDocItem")
	public void getTargetItemList(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", bd0300Service.getBqDocItemListByBq(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P01/doDocSettle")
	public void doDocSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(bd0300Service.setDocSettle(formData, req.getGridData("gridV")));
	}

	@RequestMapping(value="/BD0340P01/doCancelRfq")
	public void doCancelRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(bd0300Service.cancelBD(formData));

	}

	@RequestMapping(value="/BD0340P02/view")
	public String BD0340P02(EverHttpRequest req) throws Exception{
    	Map<String, String> formData = req.getParamDataMap();
    	req.setAttribute("form", bd0300Service.getBdHdDetail(formData));
		return "/evermp/buyer/bd/BD0340P02";
	}

	@RequestMapping(value="/BD0340P02/doSearch")
	public void getSettleItemListByBd(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("grid", bd0300Service.getSettleItemListByBd(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P02/doCancelRfq")
	public void doCancelRfq2(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		resp.setResponseMessage(bd0300Service.cancelBD(formData));

	}

	@RequestMapping(value="/BD0340P02/doItemSettle")
	public void doItemSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
        Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridData = req.getGridData("grid");
		resp.setResponseMessage(bd0300Service.doItemSettle(formData, gridData));

	}

	@RequestMapping(value="/BD0340P03/view")
	public String BD0340P03(EverHttpRequest req) throws Exception{
		Map<String, String> formData = req.getParamDataMap();

		List<Map<String,Object>> addColumn = bd0300Service.getAdditionalColumnInfos(formData);

		req.setAttribute("additionalColumn", addColumn);
		req.setAttribute("columnsize", addColumn.size());
		req.setAttribute("form", bd0300Service.getBdHdDetail(formData));
		return "/evermp/buyer/bd/BD0340P03";
	}

	@RequestMapping(value="/BD0340P03/doSearch")
	public void getItemSettleListP03(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bd0300Service.doSearchComparisonTable(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value="/BD0340P04/view")
	public String BD0340P04(EverHttpRequest req) throws Exception{
		Map<String, String> param = req.getParamDataMap();
		req.setAttribute("form", bd0300Service.getBdHdForEV(param));
		return "/evermp/buyer/bd/BD0340P04";
	}

	@RequestMapping(value="/BD0340P04/doSearch")
	public void BD0340P04_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridVendor", bd0300Service.BD0340P04_getVendorListForBDEV(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P04/doReqEV")
	public void BD0340P04_doReqEV(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setResponseMessage(bd0300Service.doReqEVforBD(req.getFormData(), req.getGridData("gridUs"), req.getGridData("gridVendor")));
	}

	@RequestMapping(value="/BD0340P04/doSearch_gridUs")
	public void BD0340P04_doSearch_gridR(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridUs", bd0300Service.getEveuByBD(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P05/view")
	public String BD0340P05(EverHttpRequest req) throws Exception{
		Map<String, String> param = req.getParamDataMap();
		req.setAttribute("form", bd0300Service.getBdHdForEV(param));
		return "/evermp/buyer/bd/BD0340P05";
	}

	@RequestMapping(value="/BD0340P05/doSearchVendor")
	public void BD0340P05_doSearchVendor(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridVendor", bd0300Service.BD0340P05_getVendorInfoForBDEV(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P05/doSearchItem")
	public void BD0340P05_doSearchItem(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setGridObject("gridItem", bd0300Service.BD0340P05_getItemInfoForBDEV(req.getFormData()));
	}

	@RequestMapping(value="/BD0340P05/doNego")
	public void BD0340P05_doNego(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		bd0300Service.BD0340P05_doNego(req.getGridData("gridVendor"), req.getFormData());
	}

	@RequestMapping(value="/BD0340P05/doSettle")
	public void BD0340P05_doSettle(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		bd0300Service.BD0340P05_doSettle(req.getGridData("gridVendor"), req.getFormData());
	}

	@RequestMapping(value="/BD0340P05/doCancelRfq")
	public void BD0340P05_doCancelRfq(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		bd0300Service.BD0340P05_doCancelRfq(req.getGridData("gridVendor"), req.getFormData());
	}

	@RequestMapping(value="/BD0340P06/view")
	public String BD0340P06(EverHttpRequest req) throws Exception{
		Map<String, Object> form = (Map)req.getParamDataMap();
		form.put("RFX_FROM_DATE", EverDate.getDate());
		form.put("RFX_FROM_HOUR", EverDate.getTime().substring(0,2));
		form.put("RFX_FROM_MIN", "00");
		form.put("RFX_TO_DATE", EverDate.addDays(1));
		form.put("RFX_TO_HOUR", EverDate.getTime().substring(0,2));
		form.put("RFX_TO_MIN", "00");
		req.setAttribute("form", form);
		return "/evermp/buyer/bd/BD0340P06";
	}

	@RequestMapping(value="/BD0340P06/chgBidDateForRebid")
	public void BD0340P06_chgBidDateForRebid(EverHttpRequest req, EverHttpResponse resp) throws Exception{
		resp.setResponseMessage(bd0300Service.chgBidDateForRebid(req.getFormData()));
	}

}