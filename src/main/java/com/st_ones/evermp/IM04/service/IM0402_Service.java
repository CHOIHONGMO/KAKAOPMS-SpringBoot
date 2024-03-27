package com.st_ones.evermp.IM04.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.multiLanguage.service.MultiLanguageService;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM04.IM0402_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

@Service(value = "im0402_Service")
public class IM0402_Service extends BaseService {

	@Autowired private DocNumService docNumService;

    @Autowired private MessageService msg;

    @Autowired private IM0402_Mapper im0402_Mapper;

    @Autowired LargeTextService largeTextService;

    @Autowired MultiLanguageService multiLanguageService;

    /** ****************************************************************************************************************
     * 품목분류 현황
     * @param param
     * @return
     * @throws Exception
     */
    public Map<String, String> doGetSgInfoById(Map<String, String> param) {
		return im0402_Mapper.doGetSgInfoById(param);
	}

    public List<Map<String, Object>> doSearchSupplierInfo(Map<String, String> param) {
		return im0402_Mapper.doSearchSupplierInfo(param);
	}

    public List<Map<String, Object>> doSearchItemClassnfo(Map<String, String> param) {
		return im0402_Mapper.doSearchItemClassnfo(param);
	}
	public List<Map<String, Object>> doSearchPTItemClassnfo(Map<String, String> param) {
		return im0402_Mapper.doSearchPTItemClassnfo(param);
	}

    public List<Map<String, Object>> doSearchDtree(Map<String, String> param) throws Exception {
        for(Entry<String, String> elem : param.entrySet()){
            System.out.println("키 : " + elem.getKey() + "값 : " + elem.getValue());
        }

		return im0402_Mapper.doSearchDtree(param);
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String[] saveSgDefinition(Map<String, String> param) throws Exception {

		String sg_text_NUM = "";
		Map<String, String> paramMul = new HashMap<String, String>();
		UserInfo baseInfo = UserInfoManager.getUserInfo();

		String docNo = !param.get("SG_NUM").equals("") ? param.get("SG_NUM") : docNumService.getDocNumber("SG");
		param.put("SG_NUM", docNo);

		// check SG_NUM for insert or update
		Map<String, String> sg = im0402_Mapper.doGetSgInfoById(param);

		//int countExist = srm_010_mapper.doCountExist(param);

		String sgNo = sg != null && !sg.get("SG_NUM").equals("") ? sg.get("SG_NUM") : "";

		if (sgNo.equals("")) { //INSERT MODE

			sg_text_NUM = largeTextService.saveLargeText(null, param.get("CONTENT"));
			param.put("SG_DEF_TEXT_NUM", sg_text_NUM);
			im0402_Mapper.saveSgDefinition(param);

//			paramMul.put("MULTI_NM", param.get("SG_NM").toString());
//			paramMul.put("SCREEN_ID", "-");
//			paramMul.put("MULTI_DESC", "");
//			paramMul.put("LANG_CD", baseInfo.getLangCd());
//			paramMul.put("MULTI_CD", "SG");
//			paramMul.put("ACTION_CD", "");
//			paramMul.put("AUTH_CD", "");
//			paramMul.put("ACTION_PROFILE_CD", "");
//			paramMul.put("TMPL_MENU_GROUP_CD", "");
//			paramMul.put("MENU_GROUP_CD", "");
//			paramMul.put("COMMON_ID", "");
//			paramMul.put("OTHER_CD", param.get("SG_NUM"));
//
//			multiLanguageService.insertMenuName(paramMul);

		} else { //UPDATE MODE

			sg_text_NUM = largeTextService.saveLargeText(param.get("SG_DEF_TEXT_NUM"), param.get("CONTENT"));
			param.put("SG_DEF_TEXT_NUM", sg_text_NUM);
			im0402_Mapper.updateSgDefinition(param);

//			paramMul.put("MULTI_NM", param.get("SG_NM").toString());
//			paramMul.put("SCREEN_ID", "-");
//			paramMul.put("MULTI_DESC", "");
//			paramMul.put("LANG_CD", baseInfo.getLangCd());
//			paramMul.put("MULTI_CD", "SG");
//			paramMul.put("ACTION_CD", "");
//			paramMul.put("AUTH_CD", "");
//			paramMul.put("ACTION_PROFILE_CD", "");
//			paramMul.put("TMPL_MENU_GROUP_CD", "");
//			paramMul.put("MENU_GROUP_CD", "");
//			paramMul.put("COMMON_ID", "");
//			paramMul.put("OTHER_CD", param.get("SG_NUM"));
//
//			im0402_Mapper.multiLanguagePopupDoUpdateWithoutMultiSEQ(paramMul);
		}

		String[] result = new String[2];
		result[0] = docNo;
		result[1] = msg.getMessage("0001");
		return result;
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String deleteSGDefinition(Map<String, String> param) throws Exception {

    	int returnNumber = 0;

		List<Map<String, Object>> treeList = im0402_Mapper.getWholeTreeBySG_NO(param);

		Map<String,Object> param2 = new HashMap<String,Object>();
		param2.putAll(param);
		param2.put("treeList", treeList);

		returnNumber = im0402_Mapper.deleteSupplierWithDefinition(param2);
		returnNumber = im0402_Mapper.deletePICWithDefinition(param2);
		returnNumber = im0402_Mapper.deleteItemClassWithDefinition(param2);
		returnNumber = im0402_Mapper.deleteSGDefinition(param2);
		returnNumber = im0402_Mapper.deleteSGNMDefinition(param2);

		if (returnNumber <= -1)
			return msg.getMessage("fail");

		return msg.getMessage("0017");
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveSupplierInfo(Map<String, String> param) throws Exception {

    	int checkFlag = im0402_Mapper.checkExistSupplier(param);
		if (checkFlag < 1)
			im0402_Mapper.doSaveSupplierInfo(param);

		return msg.getMessage("0001");
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteSuplier(Map<String, String> param, List<Map<String, Object>> supplierGrid) throws Exception {

    	for (Map<String, Object> one : supplierGrid) {
			param.put("VENDOR_CD", String.valueOf(one.get("VENDOR_CD")));
			im0402_Mapper.doDeleteSuplier(param);
		}
		return msg.getMessage("0017");
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveItemClass(Map<String, Object> one) throws Exception {

    	int checkFlag = im0402_Mapper.checkExistItemClass(one);
		if (checkFlag < 1) {
			im0402_Mapper.doSaveItemClass(one);
		}
		return msg.getMessage("0001");
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteItemClass(Map<String, String> param, List<Map<String, Object>> ClassGrid) throws Exception {

    	for (Map<String, Object> one : ClassGrid) {
			one.put("SG_NUM", param.get("SG_NUM"));
			im0402_Mapper.doDeleteItemClass(one);
		}
		return msg.getMessage("0017");
	}

    /** ****************************************************************************************************************
     * S/G-품목분류 연결
     * @param req
     * @return
     * @throws Exception
     */
    @SuppressWarnings("rawtypes")
	public List<Map> listClassItemStatus(String codeType) throws Exception {
		Map<String, String> params = new HashMap<String, String>();
		params.put("ITEM_CLS_NUM", codeType);
		return im0402_Mapper.listClassItemStatus(params);
	}

    public List<Map<String, Object>> doSearchSgItemClassMapping(Map<String, String> param) throws Exception {

		Map<String,Object> param2 = new HashMap<String,Object>();
		param2.putAll(param);

//		String sgNum1 = EverString.nullToEmptyString(param.get("SG_NUM1"));
//		String sgNum2 = EverString.nullToEmptyString(param.get("SG_NUM2"));
//		String sgNum3 = EverString.nullToEmptyString(param.get("SG_NUM3"));
//		String sgNum4 = EverString.nullToEmptyString(param.get("SG_NUM4"));
//
//		param2.put("PARENT_SG_NUM","");
//		if(!"".equals(sgNum4)){
//			param2.put("SG_NUM",sgNum4);
//		} else if(!"".equals(sgNum3)) {
//			param2.put("SG_NUM",sgNum3);
//		} else if(!"".equals(sgNum2)) {
//			param2.put("SG_NUM",sgNum2);
//		} else if(!"".equals(sgNum1)) {
//			param2.put("SG_NUM",sgNum1);
//			param2.put("PARENT_SG_NUM","Y");
//
//			Map<String, String> tmpParam = new HashMap<String, String>();
//			tmpParam.put("PARENT_SG_NUM", param.get("SG_NUM1"));
//			List<Map<String, Object>> sgList = im0402_Mapper.getSgParentList(tmpParam);
//
//			param2.put("sgList", sgList);
//		} else {
//			param2.put("SG_NUM","");
//		}

		List<Map<String, Object>> retrunlist = new ArrayList<Map<String, Object>>();
		//MRO품목카테고리 --- SG 매핑
		retrunlist =  im0402_Mapper.doSearchSgItemClassMapping(param2);

		// 판촉품목분류 제외(2022.08.03)
		//if(param.get("M_CATE_YN").equals("1")){
		//	retrunlist =  im0402_Mapper.doSearchSgItemClassMapping(param2);	//MRO품목카테고리 --- SG 매핑
		//}else{
		//	retrunlist =  im0402_Mapper.doSearchSg_PTItemClassMapping(param2);	//판촉품목카테고리 --- SG 매핑
		//}

		return retrunlist;
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteSgItemClassMapping(List<Map<String, Object>> gridDatas) throws Exception {
		for (Map<String, Object> gridData : gridDatas) {
			im0402_Mapper.doDeleteSgItemClassMapping(gridData);
		}
		return msg.getMessage("0017");
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveSgItemClassMapping(List<Map<String, Object>> params) throws Exception {

    	for (Map<String, Object> map : params) {
			// 이전데이터는 완전삭제
			im0402_Mapper.doDeleteRealItemClass(map);

			int checkFlag = im0402_Mapper.checkExistItemClass(map);

			if (checkFlag < 1){
				im0402_Mapper.doSaveItemClass(map);
			}else{
				return msg.getMessage("0005");
			}
		}
		return msg.getMessage("0001");
	}

    /** ******************************************************************************************	 *
	 * S/G선택 팝업(트리그리드)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> im04006_treepdoSearch(Map<String, String> param) throws Exception {
		return im0402_Mapper.im04006_treepdoSearch(param);
	}
	/** ****************************************************************************************************************
	 * 판촉_품목분류(팝업)
	 * @param req
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> doSearchPT_ItemClassPopup_TREE(Map<String, String> param) throws Exception {
		return im0402_Mapper.doSearchPT_ItemClassPopup_TREE(param);
	}
    /** ****************************************************************************************************************
     * 품목분류(팝업)
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> doSearchItemClassPopup_TREE(Map<String, String> param) throws Exception {
		return im0402_Mapper.doSearchItemClassPopup_TREE(param);
	}

    /** ****************************************************************************************************************
     * S/G-협력회사 연결
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> doSearchSgVendorMapping(Map<String, String> param) throws Exception {

		Map<String,Object> param2 = new HashMap<String,Object>();
		param2.putAll(param);
//		String sgNum1 = EverString.nullToEmptyString(param.get("CLS01"));
//		String sgNum2 = EverString.nullToEmptyString(param.get("CLS02"));
//		String sgNum3 = EverString.nullToEmptyString(param.get("CLS03"));
//		String sgNum4 = EverString.nullToEmptyString(param.get("CLS04"));
//
//		param2.put("sgList", null);
//		param2.put("PARENT_SG_NUM","");
//
//		if(!"".equals(sgNum4)){
//			param2.put("SG_NUM",sgNum4);
//		} else if(!"".equals(sgNum3)) {
//			param2.put("SG_NUM",sgNum3);
//		} else if(!"".equals(sgNum2)) {
//			param2.put("SG_NUM",sgNum2);
//		} else if(!"".equals(sgNum1)) {
//			param2.put("SG_NUM",sgNum1);
//			param2.put("PARENT_SG_NUM","Y");
//
//			//상위 노드를찍었을때..
//			Map<String, String> tmpParam = new HashMap<String, String>();
//			tmpParam.put("PARENT_SG_NUM", param.get("CLS01"));
//			List<Map<String, Object>> sgList = im0402_Mapper.getSgParentList(tmpParam);
//			param2.put("sgList", sgList);
//
//		} else {
//			param2.put("SG_NUM","");
//		}
		List<Map<String,Object>> rtnList = im0402_Mapper.doSearchSgVendorMapping(param2);
		return rtnList;
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doDeleteSgVendorMapping(List<Map<String, Object>> params) throws Exception {
		for (Map<String, Object> map : params) {
			im0402_Mapper.doDeleteSgVendorMapping(map);
		}
		return msg.getMessage("0001");
	}

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doSaveSgVVendorMapping(List<Map<String, Object>> params) throws Exception {

    	for (Map<String, Object> map : params) {
			// 이전데이터는 완전삭제
			im0402_Mapper.doDeleteRealSupplierInfo(map);

			Map<String, String> param = new HashMap<String, String>();
			param.put("SG_NUM", String.valueOf(map.get("SG_NUM")));
			param.put("VENDOR_CD", String.valueOf(map.get("VENDOR_CD")));

			int checkFlag = im0402_Mapper.checkExistSupplier(param);
			if (checkFlag < 1){
				im0402_Mapper.doSaveSupplierInfo(param);
			} else {
				return msg.getMessage("0005");
			}
		}
		return msg.getMessage("0001");
	}

}
