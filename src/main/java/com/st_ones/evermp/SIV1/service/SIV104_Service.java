package com.st_ones.evermp.SIV1.service;

import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.SIV1.SIV104_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : SIV104_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "siv104_Service")
public class SIV104_Service extends BaseService {
	
	@Autowired
	private RealtimeIF_Service realtimeifService;
	
	@Autowired
	SIV104_Mapper siv104_Mapper;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	MessageService msg;

	/** ******************************************************************************************
     * 공급사 : 납품거부
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1040_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "YPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "YPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
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

		return siv104_Mapper.siv1040_doSearch(param);
	}

	// 공급사 납품거부
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1040_doCancelReject(List<Map<String, Object>> gridList) throws Exception {
		for( int i = 0; i < gridList.size(); i++ ) {
			siv104_Mapper.siv1040_doCancelReject(gridList.get(i));
		}
		return msg.getMessage("0001");
	}

	/** ******************************************************************************************
     * 공급사 : 납품완료 입력/수정
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1050_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "YPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "YPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param.put("COL_NM", "YPODT.MAKER_CD");
			param.put("COL_VAL", param.get("MAKER_CD"));
			param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param.put("COL_NM", "YPODT.MAKER_NM");
			param.put("COL_VAL", param.get("MAKER_NM"));
			param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
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

		return siv104_Mapper.siv1050_doSearch(param);
	}

	// 공급사 납품완료
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1050_doCompleteDely(List<Map<String, Object>> gridList) throws Exception {
		
		Map<String, String> ifMap = new HashMap<>();
		for( Map<String, Object> gridData : gridList ) {
			siv104_Mapper.siv1050_doCompleteUIVDT(gridData); // 고객사 납품상세
			siv104_Mapper.siv1050_doCompleteYIVDT(gridData); // 공급사 납품상세
			
			if(gridData.get("IF_CPO_NO_SEQ").toString().length() < 2 ) {
				continue;
			}
			ifMap.put(String.valueOf(gridData.get("INV_NO")), "*");
		}
		
		// ================ 납품완료시 DGNS I/F 데이터 등록 =============== //
		Set set = ifMap.keySet();
		if(set != null && set.size() > 0) {
			realtimeifService.regDgnsInvoice(ifMap);
		}
		// ================ 납품완료시 DGNS I/F 데이터 등록 =============== //
		
		return msg.getMessage("0001");
	}

	// 공급사 납품완료 취소
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1050_doCancelDely(List<Map<String, Object>> gridList) throws Exception {
		for( Map<String, Object> gridData : gridList ) {
			siv104_Mapper.siv1050_doCancelUIVDT(gridData); // 고객사 납품상세
			siv104_Mapper.siv1050_doCancelYIVDT(gridData); // 고객사 납품상세
		}
		return msg.getMessage("0001");
	}

	/**
	 * 주문이력관리(구.MP)
	 */
	public List<Map<String, Object>> siv1060_doSearch(Map<String, String> param) {

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

		return siv104_Mapper.siv1060_doSearch(fParam);
	}
}
