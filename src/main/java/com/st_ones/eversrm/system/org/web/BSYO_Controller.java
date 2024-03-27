package com.st_ones.eversrm.system.org.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.eversrm.system.org.service.BSYO_Service;
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
 * @File Name : BSYO_Controller.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

@Controller
@RequestMapping(value = "/eversrm/system/org")
public class BSYO_Controller extends BaseController {

	@Autowired
	private BSYO_Service bsyo_Service;

	@Autowired
	private CommonComboService commonComboService;

	/**
	 * House Unit
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYO_010/view")
	public String BSYO_010(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		ObjectMapper om = new ObjectMapper();
		req.setAttribute("gmtCdList", om.writeValueAsString(commonComboService.getCodeCombo("M005")));

		return "/eversrm/system/org/BSYO_010";
	}

	@RequestMapping(value = "/houseUnit/selectGate")
	public void selectGate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bsyo_Service.selectGate(req.getFormData()));

	}

	@RequestMapping(value = "/houseUnit/saveGate")
	public void saveGate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.saveGate(formData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/houseUnit/deleteGate")
	public void deleteGate(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.deleteGate(formData);
		resp.setResponseMessage(msg);
	}

	/**
	 * 회사단위
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYO_020/view")
	public String BSYO_020(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		//컬럼명이 카멜케이스가 아니라 화면속성관리가 아닌 CONTROLLER 에서 설정하였음.(예외)
        ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("gateCdList", om1.writeValueAsString(commonComboService.getCodes("CB0001", new HashMap<String, String>())));
        ObjectMapper om2 = new ObjectMapper();
		req.setAttribute("languageCdList", om2.writeValueAsString(commonComboService.getCodeCombo("M001")));
        ObjectMapper om3 = new ObjectMapper();
		req.setAttribute("countryCdList", om3.writeValueAsString(commonComboService.getCodeCombo("M004")));
        ObjectMapper om4 = new ObjectMapper();
		req.setAttribute("gmtCdList", om4.writeValueAsString(commonComboService.getCodeCombo("M005")));
		ObjectMapper om5 = new ObjectMapper();
		req.setAttribute("currencyList", om5.writeValueAsString(commonComboService.getCodeComboByColumnKey("M023", "CODE")));
        ObjectMapper om6 = new ObjectMapper();
		req.setAttribute("accountUnitCd", om6.writeValueAsString(commonComboService.getCodeCombo("M166")));

		return "/eversrm/system/org/BSYO_020";
	}

	@RequestMapping(value = "/companyUnit/selectCompany")
	public void doSearch(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		resp.setGridObject("grid", bsyo_Service.selectCompany(req.getFormData()));
	}

	@RequestMapping(value = "/companyUnit/saveCompany")
	public void saveCompany(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.saveCompany(formData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/companyUnit/deleteCompany")
	public void deleteCompany(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.deleteCompany(formData);

		resp.setResponseMessage(msg);
	}

	/**
	 * 구매회사 Mapping
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("rawtypes")
	@RequestMapping(value = "/BSYO_030/view")
	public String BSYO_030(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		final List<Map> companyCdList = commonComboService.getCodes("CB0002", new HashMap<String, String>());
		String companyCdListJson = new ObjectMapper().writeValueAsString(companyCdList);
		req.setAttribute("companyCdList", companyCdListJson);

		return "/eversrm/system/org/BSYO_030";
	}

	@RequestMapping(value = "/BSYO_030/selectPurchaseComMapping")
	public void selectPurchaseComMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bsyo_Service.selectPurchaseComMapping(param));

	}

	@RequestMapping(value = "/BSYO_030/savePurchaseComMapping")
	public void savePurchaseComMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("grid");
		String msg = bsyo_Service.savePurchaseComMapping(gridData);

		resp.setResponseMessage(msg);
	}

	/**
	 * 구매조직
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYO_040/view")
	public String BSYO_040(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		UserInfo baseInfo = UserInfoManager.getUserInfoImpl();
		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", baseInfo.getGateCd());
        ObjectMapper om = new ObjectMapper();
		req.setAttribute("refBuyerCd", om.writeValueAsString(commonComboService.getCodes("CB0002", param)));

		return "/eversrm/system/org/BSYO_040";
	}

	@RequestMapping(value = "/BSYO_040/selectPurchaseOrg")
	public void selectPurchaseOrg(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		makeGridTextLinkStyle(resp, "grid", "PUR_ORG_CD");
		resp.setGridObject("grid", bsyo_Service.selectPurchaseOrg(param));

	}

	@RequestMapping(value = "/BSYO_040/savePurchaseOrg")
	public void savePurchaseOrg(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.savePurchaseOrg(formData);

		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/BSYO_040/deletePurchaseOrg")
	public void deletePurchaseOrg(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.deletePurchaseOrg(formData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/BSYO_050/view")
	public String BSYO_050(EverHttpRequest req) throws Exception {

        ObjectMapper om1 = new ObjectMapper();
		req.setAttribute("refBuyerCd", om1.writeValueAsString(commonComboService.getCodes("CB0002", new HashMap<String, String>())));
        ObjectMapper om2 = new ObjectMapper();
		req.setAttribute("refCountryCd", om2.writeValueAsString(commonComboService.getCodeCombo("M004")));

		return "/eversrm/system/org/BSYO_050";
	}

	@RequestMapping(value = "/BSYO_050/selectPlant")
	public void selectPlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		makeGridTextLinkStyle(resp, "grid", "PLANT_CD");
		resp.setGridObject("grid", bsyo_Service.selectPlant(param));
	}

	@RequestMapping(value = "/BSYO_050/getInfo")
	public void getInfo_BSYO_050(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		Map<String, String> userMap = bsyo_Service.getPlantInfo(param);

    	String[] userColumns =
    		{
    			  "GATE_CD"
    			, "BUYER_CD"
    			, "BUYER_CD_ORI"
    			, "PLANT_CD"
    			, "PLANT_CD_ORI"
    			, "REG_DATE"
    			, "PLANT_NM"
    			, "PLANT_NM_ENG"
    			, "COUNTRY_CD"
    			, "CITY_NM"
    			, "ADDR"
    			, "ADDR_ENG"
    			, "ZIP_CD"
    			, "TEL_NUM"
    			, "FAX_NUM"
    			, "IRS_NUM"
    			, "CEO_USER_NM"
    			, "CEO_USER_NM_ENG"
    			, "INDUSTRY_TYPE"
    			, "BUSINESS_TYPE"
    			, "COMPANY_REG_NUM"
    			, "DUNS_NUM"
    			, "BUYER_NM"
    			, "BUYER_NM_ENG"
    			, "ATT_FILE_NUM"
    			, "REG_USER_NM"
    			, "INSERT_FLAG"
    			, "REGION_CD"
    			, "EMAIL"
    			, "PLANT_TYPE"
    			, "PLANT_STATUS_CD"
    			, "MAPPING_PLANT_CD"
    		};

    	for(int i = 0; i < userColumns.length; i++) {
    		if(! userMap.containsKey(userColumns[i])) {
    			userMap.put(userColumns[i],  "");
    		}

    		if (userMap.get(userColumns[i]) == null) {
    			userMap.put(userColumns[i],  "");
    		}
    	}

		resp.setFormDataObject( userMap );
	}

	@RequestMapping(value = "/BSYO_050/savePlant")
	public void savePlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.savePlant(formData);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/BSYO_050/deletePlant")
	public void deletePlant(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.deletePlant(formData);

		resp.setResponseMessage(msg);
	}

	/**
	 * 부서단위
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYO_060/view")
	public String BSYO_060(EverHttpRequest req) throws Exception {
		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

        ObjectMapper om1 = new ObjectMapper();
   		req.setAttribute("refBuyerCd", commonComboService.getCodeComboAsJson("CB0002")  );
		return "/eversrm/system/org/BSYO_060";
	}

	@RequestMapping(value = "/getPlantComboValue")
    public void getCustomerList(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		HashMap<String, String> hashMap = new HashMap<String, String>();
		hashMap.put("GATE_CD", UserInfoManager.getUserInfo().getGateCd());
		hashMap.put("BUYER_CD", req.getFormData().get("BUYER_CD"));
		resp.setParameter("plantList", commonComboService.getCodesAsJson("CB0003", hashMap));
    }


	@RequestMapping(value = "/BSYO_060/doSearchxxxxx")
	public void doSearch_BSYO_060(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		List<Map<String, String>> result = bsyo_Service.doSearch(param);
		ObjectMapper om = new ObjectMapper();
		String jsonStr = om.writeValueAsString(result);

		resp.setParameter("treeData", jsonStr);
	}

	@RequestMapping(value = "/BSYO_060/doSearchGrid")
	public void doSearch_BSYO_060_GRID(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> list = bsyo_Service.selectDeptGrid(req.getFormData());
		resp.setLinkStyle("grid", "DEPT_CD");
		resp.setGridObject("grid", list);
	}


	@RequestMapping(value = "/BSYO_060/doSearch")
	public void doSearch_BSYO_060JSON(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		String result = bsyo_Service.doSearchJson(param);

		resp.setParameter("treeData", result);
	}

	@RequestMapping(value = "/BSYO_060/doSearchDeptINFO")
	public void doSearch4(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();


		param.put("DEPT_CD", req.getParameter("DEPT_CD"));
		param.put("BUYER_CD", req.getParameter("BUYER_CD"));

		List<Map<String, String>> result = bsyo_Service.doSearchDeptINFO(param);
		ObjectMapper om = new ObjectMapper();
		String jsonStr = om.writeValueAsString(result);

		resp.setParameter("deptInfo", jsonStr);
	}

	@RequestMapping(value = "/BSYO_060/getInfo")
	public void getInfo_BSYO_060(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		Map<String, String> result = bsyo_Service.getDeptInfo(param);
		ObjectMapper om = new ObjectMapper();
		String jsonStr = om.writeValueAsString(result);

		resp.setParameter("formData", jsonStr);
	}

	@RequestMapping(value = "/BSYO_060/doSave")
	public void doSave(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		String msg = bsyo_Service.doSave(param);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/BSYO_060/doDelete")
	public void doDelete(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();

		String msg = bsyo_Service.doDelete(param);

		resp.setResponseMessage(msg);
	}

	@RequestMapping(value = "/deptParentSearch/view")
	public String deptParentSearch() throws Exception {
		return "/eversrm/system/org/deptParentSearch";
	}

	@RequestMapping(value = "/BSYO_060/selectDeptParent")
	public void selectDeptParent(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("grid", bsyo_Service.selectDeptParent(param));

	}

	/**
	 * 창고/저장위치
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/BSYO_070/view")
	public String BSYO_070(EverHttpRequest req) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		if (!userInfo.isSuperUser() || !userInfo.isOperator()) {
		    return "/eversrm/noSuperAuth";
		}

		return "/eversrm/system/org/BSYO_070";
	}

	@RequestMapping(value = "/BSYO_070/selectWareHouse")
	public void selectWareHouse(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("gridL", bsyo_Service.selectWareHouse(param));

	}

	@RequestMapping(value = "/BSYO_070/selectWareHouseDetail")
	public void selectWareHouseDetail(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		Map<String, String> param = req.getFormData();
		resp.setGridObject("gridB", bsyo_Service.selectWareHouseDetail(param));

	}

	@RequestMapping(value = "/BSYO_070/saveWareHouse")
	public void saveWareHouse(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> gridDData = req.getGridData("gridB");
		String msg = bsyo_Service.saveWareHouse(formData, gridDData);

		resp.setResponseMessage(msg);

	}

	@RequestMapping(value = "/BSYO_070/deleteWareHouse")
	public void deleteWareHouse(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> formData = req.getFormData();
		String msg = bsyo_Service.deleteWareHouse(formData);

		resp.setResponseMessage(msg);

	}

	//이미지 텍스트그리드
	private void makeGridTextLinkStyle(EverHttpResponse resp, String grid, String columnName) {
        resp.setGridColStyle(grid, columnName, "cursor", "pointer");
        resp.setGridColStyle(grid, columnName, "color", "#000DFF");
        resp.setGridColStyle(grid, columnName, "text-decoration", "underline");
	}

}