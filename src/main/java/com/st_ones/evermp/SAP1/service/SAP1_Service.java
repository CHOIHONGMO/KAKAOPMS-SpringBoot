package com.st_ones.evermp.SAP1.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 17 오후 5:01
 */

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.SAP1.SAP1_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service(value = "sap1_Service")
public class SAP1_Service extends BaseService {

	@Autowired private QueryGenService queryGenService;

	@Autowired SAP1_Mapper sap1_Mapper;

	@Autowired MessageService msg;

	/**
	 * *****************************************************************************************
	 * 공급사 > 정산관리 > 정산관리 > 마감현황(품목별)
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> sap1010_doSearch(Map<String, String> param) throws Exception {
		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "APAR.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "APAR.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("INV_NO"))) {
			param.put("INV_NO_ORG", param.get("INV_NO"));
			param.put("INV_NO", EverString.forInQuery(param.get("INV_NO"), ","));
			param.put("INV_CNT", param.get("INV_NO").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("GR_NO"))) {
			param.put("GR_NO_ORG", param.get("GR_NO"));
			param.put("GR_NO", EverString.forInQuery(param.get("GR_NO"), ","));
			param.put("GR_CNT", param.get("GR_NO").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return sap1_Mapper.sap1010_doSearch(param);
	}

	/**
	 * *****************************************************************************************
	 * 공급사 > 정산관리 > 정산관리 > 마감현황(고객사별)
	 *
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> sap1020_doSearch(Map<String, String> param) throws Exception {
		if (!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.ITEM_DESC", param.get("ITEM_DESC"), "ITEM_DESC_01");
			param = getQueryParam(param, "UPODT.ITEM_SPEC", param.get("ITEM_DESC"), "ITEM_DESC_02");
		}

		return sap1_Mapper.sap1020_doSearch(param);
	}

	/**
	 * *****************************************************************************************
	 * 공통함수
	 */
	public Map<String, String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
		param.put("COL_NM", COL_NM);
		param.put("COL_VAL", COL_VAL);

		param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

		return param;
	}
}