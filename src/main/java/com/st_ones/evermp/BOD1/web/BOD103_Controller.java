package com.st_ones.evermp.BOD1.web;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.BOD1.service.BOD103_Service;
import com.st_ones.eversrm.main.service.MSI_Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BOD103_Controller.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/evermp/BOD1/BOD103")
public class BOD103_Controller extends BaseController {

	@Autowired private BOD103_Service bod103_Service;

	@Autowired private CommonComboService commonComboService;

	@Autowired private MSI_Service mainService;

	@Autowired private MessageService msg;

	/** ******************************************************************************************
     * 주문 CART
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BOD1_030/view")
	public String BOD1_030(EverHttpRequest req) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		if(!"B".equals(userInfo.getUserType())) {
	  	       return "/eversrm/noSuperAuth";
	  	      }
		// 내부고객사 전결라인
		String inCustCd = PropertiesManager.getString("eversrm.default.inCustCd");

		req.setAttribute("inCustCd", inCustCd);
		req.setAttribute("addFromDate", EverDate.addDateMonth(EverDate.getDate(), -1));
		req.setAttribute("addToDate", EverDate.getDate());

		Map<String, String> param = new HashMap<String, String>();
        String userId = userInfo.getUserId();
        param.put("userId", userId);
        req.setAttribute("form", mainService.selectUser(param));

        param.put("GATE_CD", userInfo.getGateCd());
        param.put("CUST_CD", userInfo.getCompanyCd());
        req.setAttribute("plantList", commonComboService.getCodesAsJson("CB0100", param));
        req.setAttribute("ifVendorList", EverConverter.getJsonString(bod103_Service.doSearchIfVendorList()));

		Map<String, String> accData = null;
		Map<String, String> commonAccData = null;
		String accountCd = ""; String accountNm = "";
		String custCommonAccUseFlag = "N"; // 고정계정부서 사용여부

		// 고객사의 예산사용여부가 "1"인 경우...
		// MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 예산부서를 변경할 수 없고
		// 무조건 MP102에 등록된 계정으로만 예산을 체크/가감한다.
		// MP101에 나의 정보로 등록된 계정이 있는 경우, 계정도 변경할 수 없다.
		// 예산부서를 가져온다.
//		if(userInfo.getBuyerBudgetUseFlag().equals("1")) {
//
//			// ses.companyCd가 고정계정부서를 사용한다고 등록되어 있는지 체크.
//			commonAccData = new HashMap<String, String>();
//			commonAccData = bod103_Service.getCommonAccData(new HashMap<String, String>());
//			if(commonAccData != null) {
//				custCommonAccUseFlag = "Y";
//			}
//
//			// 나의 정보로 등록된 계정이 있는지 체크
//			accData = new HashMap<String, String>();
//			accData = bod103_Service.getAccData(new HashMap<String, String>());
//			if(accData != null) {
//				accountCd = accData.get("ACCOUNT_CD");
//				accountNm = accData.get("ACCOUNT_NM");
//			}
//		}
		req.setAttribute("ACCOUNT_CD", accountCd);
		req.setAttribute("ACCOUNT_NM", accountNm);
		req.setAttribute("custCommonAccUseFlag", custCommonAccUseFlag);

		req.setAttribute("localFlag", PropertiesManager.getString("eversrm.system.developmentFlag"));

		return "/evermp/BOD1/BOD1_030";
	}

	@RequestMapping(value = "/BOD1_030/doSearch")
	public void bod1030_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		param.put("buyerBudgetUseFlag", EverString.nullToEmptyString(req.getParameter("buyerBudgetUseFlag")));
		param.put("custCommonAccUseFlag", EverString.nullToEmptyString(req.getParameter("custCommonAccUseFlag")));

		resp.setGridObject("grid", bod103_Service.bod1030_doSearch(param));
	}

    @RequestMapping(value="/BOD1_030/doSave")
    public void bod1030_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bod103_Service.bod1030_doSave(gridList);

        resp.setResponseMessage(returnMsg);
    }

    @RequestMapping(value="/BOD1_030/doDelete")
    public void bod1030_doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bod103_Service.bod1030_doDelete(gridList);

        resp.setResponseMessage(returnMsg);
    }

    @RequestMapping(value="/BOD1_030/doOrder")
    public void bod1030_doOrder(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
    	param.put("signStatus", EverString.nullToEmptyString(req.getParameter("signStatus")));
    	List<Map<String, Object>> gridList = req.getGridData("grid");

        String returnMsg = bod103_Service.bod1030_doOrder(param, gridList);
        resp.setResponseMessage(returnMsg);
    }

    /** ******************************************************************************************
     * 예산체크
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BOD1_031/view")
	public String BOD1_031(EverHttpRequest req) throws Exception {
		return "/evermp/BOD1/BOD1_031";
	}

	@RequestMapping(value = "/BOD1_031/doSearch")
	public void bod1031_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, Object> param = new HashMap<String, Object>();
		String itemParam = EverString.nullToEmptyString(req.getParameter("itemInfo"));
		param.put("itemParam", itemParam);

		resp.setGridObject("grid", bod103_Service.bod1031_doSearch(param));
	}

	@RequestMapping(value = "/BOD1_031/doSearchAll")
	public void bod1031_doSearchAll(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, Object> param = new HashMap<String, Object>();
		resp.setGridObject("grid", bod103_Service.bod1031_doSearchAll(param));
	}
    /** ******************************************************************************************
     * 관심품목 등록
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value="/BOD1_032/view")
	public String BOD1_032(EverHttpRequest req) throws Exception {
		req.setAttribute("form", req.getParamDataMap());
		return "/evermp/BOD1/BOD1_032";
	}

	@RequestMapping(value = "/BOD1_032/doSearch")
	public void bod1032_doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bod103_Service.bod1032_doSearch(param));
	}

    @RequestMapping(value="/BOD1_032/doSave")
    public void bod1032_doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
    	Map<String, String> param = req.getFormData();
    	String itemInfo = EverString.nullToEmptyString(req.getParameter("itemInfo"));
    	param.put("itemInfo", itemInfo);

        List<Map<String, Object>> gridList = req.getGridData("grid");
        String returnMsg = bod103_Service.bod1032_doSave(param, gridList);

        resp.setResponseMessage(returnMsg);
    }

}
