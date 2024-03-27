package com.st_ones.evermp.BOD1.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BOD1.BOD105_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Arrays;
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
 * @File Name : BOD105_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "bod105_Service")
public class BOD105_Service extends BaseService {
	
	@Autowired BOD105_Mapper bod105_Mapper;
	@Autowired private QueryGenService queryGenService;
	@Autowired MessageService msg;
	
	/** ******************************************************************************************
     * 고객사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> bod1050_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "UPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param.put("COL_NM", "UPODT.MAKER_CD");
			param.put("COL_VAL", param.get("MAKER_CD"));
			param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param.put("COL_NM", "UPODT.MAKER_NM");
			param.put("COL_VAL", param.get("MAKER_NM"));
			param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		if(!EverString.nullToEmptyString(param.get("BRAND_NM")).trim().equals("")) {
			param.put("COL_NM", "UPODT.BRAND_NM");
			param.put("COL_VAL", param.get("BRAND_NM"));
			param.put("BRAND_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		
		if(EverString.isNotEmpty(param.get("DOC_NUM"))) { 
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		Map<String, Object> fParam = new HashMap<String, Object>(param);
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));
		
		return bod105_Mapper.bod1050_doSearch(fParam);
	}

	/**
	 * 주문이력관리(구.MP)
	 */
	public List<Map<String, Object>> bod1060_doSearch(Map<String, String> param) {

		Map<String, String> sParam = new HashMap<>();
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", param.get("ITEM_DESC"));
			sParam.put("COL_NM", "ITEM_DESC");
			param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "ITEM_SPEC");
			param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}

		if(EverString.isNotEmpty(param.get("ITEM_KEY"))) {
			param.put("ITEM_KEY_ORG", param.get("ITEM_KEY"));
			param.put("ITEM_KEY", EverString.forInQuery(param.get("ITEM_KEY"), ","));
			param.put("ITEM_KEY_CNT", param.get("ITEM_KEY").contains(",") ? "1" : "0");
		}

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		Map<String, Object> fParam = new HashMap<String, Object>(param);
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

		return bod105_Mapper.bod1060_doSearch(fParam);
	}
}
