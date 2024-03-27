package com.st_ones.evermp.IM04.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.file.service.FileAttachService;
import com.st_ones.common.generator.domain.GroupHeader;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverConverter;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.BaseController;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.IM04.service.IM0402_Service;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

@Controller
@RequestMapping(value = "/evermp/IM04/IM0402")
public class IM0402_Controller extends BaseController {

	@Autowired IM0402_Service im0402_Service;

	@Autowired CommonComboService commonComboService;

	@Autowired FileAttachService fileAttachService;

	@Autowired LargeTextService largeTextService;

	@Autowired protected MessageService msg;

    /** ****************************************************************************************************************
     * S/G 관리
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM04_002/view")
	public String sourcing_tree(EverHttpRequest req) throws Exception {
        UserInfo userInfo = UserInfoManager.getUserInfo();
        if(!"C".equals(userInfo.getUserType())) {
        	return "/eversrm/noSuperAuth";
        }
		GroupHeader groupHeaderSI = new GroupHeader("groupHeaderSI", msg.getMessageByScreenId("SRM_010", "SI_HEADER"));
		GroupHeader groupHeaderRA = new GroupHeader("groupHeaderRA", msg.getMessageByScreenId("SRM_010", "RA_HEADER"));
		GroupHeader groupHeaderSRS = new GroupHeader("groupHeaderSRS", msg.getMessageByScreenId("SRM_010", "SRS_HEADER"));

		groupHeaderSI.setChildColumns("SI_X_SCORE,SI_Y_SCORE,SI_XY_POS_CD"); // childColumns def in one String
		groupHeaderRA.setChildColumns("RA_X_SCORE,RA_Y_SCORE,RA_XY_POS_CD"); // childColumns def in one String
		groupHeaderSRS.setChildColumns("SRS_X_SCORE,SRS_Y_SCORE,SRS_CD"); // childColumns def in one String

		ArrayList<GroupHeader> groupHeaderList = new ArrayList<GroupHeader>();
		groupHeaderList.add(groupHeaderSI);
		groupHeaderList.add(groupHeaderRA);
		groupHeaderList.add(groupHeaderSRS);

		Map<String, String> param = new HashMap<String, String>();
        param.put("GATE_CD", userInfo.getGateCd());
        param.put("BUYER_CD", userInfo.getCompanyCd());
        param.put("CTRL_CD", "C100");    //표준화 및 품목 담당자
        req.setAttribute("ctrlUserIdOptions", commonComboService.getCodesAsJson("CB0064", param));

		req.setAttribute("groupList", new ObjectMapper().writeValueAsString(groupHeaderList));
		return "/evermp/IM04/IM04_002";
	}

    @RequestMapping(value = "/IM04_002/doGetSgInfoById")
	public void doGetSgInfoById(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
		Map<String, String> result = im0402_Service.doGetSgInfoById(param);

		String splitString = (result.get("SG_DEF_TEXT_NUM") == null ? "" : largeTextService.selectLargeText(result.get("SG_DEF_TEXT_NUM")));

		resp.setParameter("CONTENT", splitString);
		resp.setParameter("DEPTH", String.valueOf(result.get("DEPTH")));
		resp.setParameter("LEAF", String.valueOf(result.get("LEAF_FLAG")));
		resp.setGridObject("supplierGrid", im0402_Service.doSearchSupplierInfo(param));
		resp.setGridObject("itemClassGrid", im0402_Service.doSearchItemClassnfo(param));
		//판촉 분류체계 제외(2022.08.03)
		//resp.setGridObject("ptItemGrid", im0402_Service.doSearchPTItemClassnfo(param));
		req.setAttribute("formParam", result);
		resp.setResponseCode("true");

	}

    @RequestMapping(value = "/IM04_002/doSearchDtree")
	public void doSearchDtree(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> formData = req.getFormData();
		List<Map<String, Object>> treeData = im0402_Service.doSearchDtree(formData);

		 for(Map<String, Object> tree : treeData) { tree.put("CONTENT",
			 tree.get("SG_DEF_TEXT_NUM") == null ? "" :
			 largeTextService.selectLargeText((String) tree.get("SG_DEF_TEXT_NUM")));
		 }

		resp.setParameter("treeData", EverConverter.getJsonString(treeData));
		resp.setResponseCode("true");

	}

    @RequestMapping(value = "/IM04_002/doSearchContent")
	public void doSearchContent(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	String sg_def_text_num = req.getParameter("SG_DEF_TEXT_NUM");
		String content = sg_def_text_num == null ? "" : largeTextService.selectLargeText(sg_def_text_num);

		resp.setParameter("content", content);
		resp.setResponseCode("true");
	}

    @RequestMapping(value = "/IM04_002/saveSGDefinition")
	public void saveSGDefinition(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		for(Entry<String, String> elem : param.entrySet()){
            System.out.println("IM04_002save___키 : " + elem.getKey() + ", 값 : " + elem.getValue());
        }

		String[] result = im0402_Service.saveSgDefinition(param);

		resp.setResponseMessage(result[1]);
		resp.setParameter("SG_NUM", result[0]);
		resp.setResponseCode("true");

	}

    @RequestMapping(value = "/IM04_002/deleteSGDefinition")
	public void deleteSGDefinition(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		String msg1 = im0402_Service.deleteSGDefinition(param);
		resp.setResponseMessage(msg1);
		resp.setResponseCode("true");
	}

    @RequestMapping(value = "/IM04_002/doSaveSupplierInfo")
	public void doSaveSupplierInfo(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
		List<Map<String, Object>> supplierGrid = req.getGridData("supplierGrid");

		for (Map<String, Object> one : supplierGrid) {
			param.put("VENDOR_CD", String.valueOf(one.get("VENDOR_CD")));
			im0402_Service.doSaveSupplierInfo(param);
		}
		resp.setResponseMessage(msg.getMessage("0001"));
		resp.setResponseCode("true");
	}

    @RequestMapping(value = "/IM04_002/doDeleteSuplier")
	public void doDeleteSuplier(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
		List<Map<String, Object>> supplierGrid = req.getGridData("supplierGrid");

		String msgs = im0402_Service.doDeleteSuplier(param, supplierGrid);
		resp.setResponseMessage(msgs);
		resp.setResponseCode("true");
	}

    @RequestMapping(value = "/IM04_002/doSaveItemClass")
	public void doSaveItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
		List<Map<String, Object>> itemClassGrid = req.getGridData("itemClassGrid");

		for (Map<String, Object> one : itemClassGrid) {
			one.put("SG_NUM", param.get("SG_NUM"));
			im0402_Service.doSaveItemClass(one);
		}
		resp.setResponseMessage(msg.getMessage("0001"));
		resp.setResponseCode("true");
	}

    @RequestMapping(value = "/IM04_002/doDeleteItemClass")
	public void doDeleteItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
		List<Map<String, Object>> itemClassGrid = req.getGridData("itemClassGrid");

		String msgs = im0402_Service.doDeleteItemClass(param, itemClassGrid);
		resp.setResponseMessage(msgs);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_002/doSavePTItemClass")
	public void doSavePTItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> ptItemGrid = req.getGridData("ptItemGrid");

		for (Map<String, Object> one : ptItemGrid) {
			one.put("SG_NUM", param.get("SG_NUM"));
			im0402_Service.doSaveItemClass(one);
		}
		resp.setResponseMessage(msg.getMessage("0001"));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_002/doDeletePTItemClass")
	public void doDeletePTItemClass(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		List<Map<String, Object>> ptItemGrid = req.getGridData("ptItemGrid");

		String msgs = im0402_Service.doDeleteItemClass(param, ptItemGrid);
		resp.setResponseMessage(msgs);
		resp.setResponseCode("true");
	}

    /** ****************************************************************************************************************
     * S/G-품목분류 연결
     * @param req
     * @return
     * @throws Exception
     */
    @RequestMapping(value = "/IM04_003/view")
	public String IM04_003(EverHttpRequest req) throws Exception {
    	UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> params = new HashMap<String, String>();
		params.put("GATE_CD", baseInfo.getGateCd());
		req.setAttribute("refSG_NUM1", commonComboService.getCodesAsJson("CB0026", params));
		req.setAttribute("refITEM_CLASS1", EverConverter.getJsonString(im0402_Service.listClassItemStatus("1")));
		return "/evermp/IM04/IM04_003";
	}

    @RequestMapping(value = "/IM04_003/doSearch")
	public void doSearchSgItemClassMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

    	Map<String, String> param = req.getFormData();
//		param.put("M_CATE_YN", "0");
//		param.put("P_CATE_YN", "1");
//		resp.setGridObject("ptGrid", im0402_Service.doSearchSgItemClassMapping(param));

		param.put("M_CATE_YN", "1");
		param.put("P_CATE_YN", "0");
		resp.setGridObject("icGrid", im0402_Service.doSearchSgItemClassMapping(param));
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_003/doDeleteSgGrid")
	public void doDeleteSgItemClassMappingBySgGrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> sgGridData = req.getGridData("sgGrid");
		String msg = im0402_Service.doDeleteSgItemClassMapping(sgGridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_003/doDeleteIcGrid")
	public void doDeleteSgItemClassMappingByIcGrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> icGridData = req.getGridData("icGrid");
		String msg = im0402_Service.doDeleteSgItemClassMapping(icGridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_003/doSaveptGrid")
	public void doSaveSgItemClassMappingBySgGrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> ptGridData = req.getGridData("ptGrid");
		String msg = im0402_Service.doSaveSgItemClassMapping(ptGridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_003/doSaveIcGrid")
	public void doSaveSgItemClassMappingByIcGrid(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> icGridData = req.getGridData("icGrid");
		String msg = im0402_Service.doSaveSgItemClassMapping(icGridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_003/chSg")
	public void chSg(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();
		String retrunStr = "";
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		param.put("GATE_CD", baseInfo.getGateCd());
		param.put("PARENT_SG_NUM", req.getParameter("PARENT_SG_NUM"));
		retrunStr = commonComboService.getCodesAsJson("CB0027", param);

		resp.setParameter("sgData",  retrunStr );
		resp.setResponseCode("true");
	}

	/** ******************************************************************************************
	 * S/G선택 팝업(트리그리드)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	@RequestMapping(value = "/IM04_006/view")
	public String im04_006_treep_view(EverHttpRequest req) throws Exception {

		Map<String, String> formTree = req.getFormData();
		// 손익분류 트리조회
		List<Map<String, Object>> list = im0402_Service.im04006_treepdoSearch(formTree);
		req.setAttribute("treeData", new ObjectMapper().writeValueAsString(list));
		return "/evermp/IM04/IM04_006";
	}

	/** ****************************************************************************************************************
     * 품목분류(팝업)
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/IM04_005/view")
	public String itemClassPopup(EverHttpRequest req) throws Exception {

		Map<String, String> param = req.getFormData();

		String businessType = req.getParameter("businessType");
		if(StringUtils.isNotEmpty(businessType)) {
			param.put("businessType", businessType);
		}
		param.put("CUST_CD",req.getParameter("custCd"));

		// 판촉품목분류 제외 (2022.08.03)
		//if(StringUtils.isNotEmpty(req.getParameter("ptYn"))) {
		//	List<Map<String, Object>> list = im0402_Service.doSearchPT_ItemClassPopup_TREE(param);
		//	req.setAttribute("treeData", new ObjectMapper().writeValueAsString(list));
		//}else{
			List<Map<String, Object>> list = im0402_Service.doSearchItemClassPopup_TREE(param);
			req.setAttribute("treeData", new ObjectMapper().writeValueAsString(list));
		//}

		req.setAttribute("refItemType", commonComboService.getCodeComboAsJson("M041"));
		return "/evermp/IM04/IM04_005";
	}

	@RequestMapping(value = "/IM04_005/doSearch")
	public void doSearchItemClassPopup(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		String businessType = req.getParameter("businessType");
		if(StringUtils.isNotEmpty(businessType)) {
			param.put("businessType", businessType);
		}

		// 판촉품목분류 제외 (2022.08.03)
		//if(StringUtils.isNotEmpty(req.getParameter("ptYn"))) {
		//	List<Map<String,Object>> treeData = im0402_Service.doSearchPT_ItemClassPopup_TREE(param);
		//	resp.setParameter("treeData", EverConverter.getJsonString(treeData));
		//}else{
			List<Map<String,Object>> treeData = im0402_Service.doSearchItemClassPopup_TREE(param);
			resp.setParameter("treeData", EverConverter.getJsonString(treeData));
		//}

	}

	/** ****************************************************************************************************************
     * S/G-협력회사 연결
     * @param req
     * @return
     * @throws Exception
     */
	@RequestMapping(value = "/IM04_004/view")
	public String IM04_004(EverHttpRequest req) throws Exception {
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		Map<String, String> param = new HashMap<String, String>();
		param.put("GATE_CD", baseInfo.getGateCd());
		req.setAttribute("refClass1", commonComboService.getCodesAsJson("CB0026", param));
		return "/evermp/IM04/IM04_004";
	}

	@RequestMapping(value = "IM04_004/doSearch")
	public void doSearchSgVendorMapping(EverHttpRequest req, EverHttpResponse resp) throws Exception {

		Map<String, String> param = req.getFormData();

		List<Map<String, Object>> lstMap = im0402_Service.doSearchSgVendorMapping(param);
		resp.setGridObject("gridSG", lstMap);
		resp.setGridObject("gridV", lstMap);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_004/doDeleteGridSG")
	public void doDeleteSgVendorMappinggByGridSG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("gridSG");
		String msg = im0402_Service.doDeleteSgVendorMapping(gridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_004/doDeleteGridV")
	public void doDeleteSgVendorMappingByGridV(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("gridV");
		String msg = im0402_Service.doDeleteSgVendorMapping(gridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_004/doSaveGridSG")
	public void doSaveVendorMappinggByGridSG(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("gridSG");
		String msg = im0402_Service.doSaveSgVVendorMapping(gridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

	@RequestMapping(value = "/IM04_004/doSaveGridV")
	public void doSaveVendorMappingByGridV(EverHttpRequest req, EverHttpResponse resp) throws Exception {
		List<Map<String, Object>> gridData = req.getGridData("gridV");
		String msg = im0402_Service.doSaveSgVVendorMapping(gridData);
		resp.setResponseMessage(msg);
		resp.setResponseCode("true");
	}

}
