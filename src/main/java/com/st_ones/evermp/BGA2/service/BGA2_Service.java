package com.st_ones.evermp.BGA2.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BGA2.BGA2_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "bga2_Service")
public class BGA2_Service extends BaseService {

	@Autowired private QueryGenService queryGenService;

	@Autowired BGA2_Mapper bga2_Mapper;

	@Autowired MessageService msg;

	/** ******************************************************************************************
	 * 재고관리 > 출하관리 > 출하 확정 (BGA2_010)
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga2010_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", param.get("ITEM_DESC"));
			sParam.put("COL_NM", "YPODT.ITEM_DESC");
			param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_SPEC");
			param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_CD");
			param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.CUST_ITEM_CD");
			param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		/*
		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}
		*/

		return bga2_Mapper.bga2010_doSearch(param);
	}

	public Map<String,String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
		param.put("COL_NM", COL_NM);
		param.put("COL_VAL", COL_VAL);

		param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

		return param;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void bga2010_doGiSave(Map<String, Object> gridData, Map<String, String> form) throws Exception {
		//String PROGRESS_CD = "";
		//String GR_COMPLETE_FLAG = "0";

		//float CPO_QTY = Float.valueOf(String.valueOf(gridData.get("CPO_QTY")));
		//float INV_QTY = Float.valueOf(String.valueOf(gridData.get("INV_QTY")));

	      gridData.put("CANCEL_YN", "N");
	      bga2_Mapper.bga2010_doGrSaveGIDT(gridData);
			/* bga2_Mapper.bga2010_doGrSaveUIVDT(gridData); */

		 // int TOT_GR_QTY = bga2_Mapper.bga2010_doSearchTOT_GR_QTY(gridData);

		  //if(CPO_QTY < (TOT_GR_QTY + INV_QTY )) throw new Exception("주문수량을 초과했습니다. 조회 후 다시 시도 하세요.");

			// PROGRESS_CD = "6120";

	      //gridData.put("PROGRESS_CD", PROGRESS_CD);
	     // gridData.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG);

	 // bga2_Mapper.bga2010_doGrSaveMMRS(gridData); 입고처리 완료되면 수불 바꿈.
	 	//bga2_Mapper.bga2010_doGrSaveYPODT(gridData);
	 	//bga2_Mapper.bga2010_doGrSaveUPODT(gridData);
		//if(1==1) throw new Exception("===============================================");
	}
	/** ******************************************************************************************
	 * 재고관리 > 출하관리 > 출하 상세 내역 (BGA2_020)
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	public List<Map<String, Object>> bga2020_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", param.get("ITEM_DESC"));
			sParam.put("COL_NM", "YPODT.ITEM_DESC");
			param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_SPEC");
			param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_CD");
			param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.CUST_ITEM_CD");
			param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		/*
		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}
		 */

		return bga2_Mapper.bga2020_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bga2020_doGrCancel(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
		String PROGRESS_CD = "";
		String GR_COMPLETE_FLAG = "0";

		for(Map<String, Object> gridData : gridList) {
            float GI_QTY = Float.valueOf(String.valueOf(gridData.get("GI_QTY")));

			gridData.put("CANCEL_YN", "Y");

			bga2_Mapper.bga2010_doGiCancelGIDT(gridData);
			/* bga2_Mapper.bga2010_doGrSaveUIVDT(gridData); */

			PROGRESS_CD = "6120"; //납품중

			gridData.put("PROGRESS_CD", PROGRESS_CD);
			gridData.put("GR_COMPLETE_FLAG", GR_COMPLETE_FLAG); //

			bga2_Mapper.bga2010_doGiCancelMMRS(gridData);
			bga2_Mapper.bga2010_doGrSaveYPODT(gridData);
			bga2_Mapper.bga2010_doGrSaveUPODT(gridData);

			//if (1==1) throw new Exception("==========================================");
		}
		return msg.getMessageByScreenId("BGA2_020", "004");
	}

	/** ******************************************************************************************
	 * 재고관리 >  VMI출하내역조회(공급사)
	 * @param req
	 * @return String
	 * @throws Exception
	 */

	public List<Map<String, Object>> bga2030_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
		if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", param.get("ITEM_DESC"));
			sParam.put("COL_NM", "YPODT.ITEM_DESC");
			param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_SPEC");
			param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_CD");
			param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.CUST_ITEM_CD");
			param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_CD", param.get("MAKER_CD"), "MAKER_CD_01");
		}

		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param = getQueryParam(param, "UPODT.MAKER_NM", param.get("MAKER_NM"), "MAKER_NM_01");
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}

		return bga2_Mapper.bga2030_doSearch(param);
	}
}
