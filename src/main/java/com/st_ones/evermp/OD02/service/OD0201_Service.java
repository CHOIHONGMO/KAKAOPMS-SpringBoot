package com.st_ones.evermp.OD02.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.BizHttp;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.evermp.SIV1.SIV101_Mapper;
import com.st_ones.evermp.SIV1.SIV103_Mapper;
import com.st_ones.evermp.SIV1.SIV104_Mapper;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
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
 * @File Name : OD0201_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "od0201_Service")
public class OD0201_Service extends BaseService {


	@Autowired
	private RealtimeIF_Service realtimeifService;

	@Autowired
	private RealtimeIF_Mapper realtimeifMapper;

	@Autowired
	SIV101_Mapper siv101_Mapper;

	@Autowired
	SIV103_Mapper siv103_Mapper;

	@Autowired
	SIV104_Mapper siv104_Mapper;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	MessageService msg;

	@Autowired
    private DocNumService docNumService;

	@Autowired
	private EverMailService everMailService;

	@Autowired
    private EverSmsService everSmsService;

	/** ******************************************************************************************
     * 운영사 : 납품서생성 대행
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> od02010_doSearch(Map<String, String> param) throws Exception {
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

		return siv101_Mapper.siv1020_doSearch(param);
	}

	/**
	 * 납품생성 대행
	 * @param gridList
	 * @throws Exception
	 * 들어오는 건별로 시작해서 CPO_NO가 같다면 채번은 같고 틀리다면 다르게 입력
	 * 동일한 주문 CPO 이더라도 공급사가 다르면 다르게 채번
	 * 즉, 아예 라인수로 for문으로 데이터 입력 할 수 있게 작성
	 * 단 한건만 들어오면 한건은 for문을 무시한다.더욱이 PODT에 INV에 입력할때는 주의해서 입력이 필요
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, Object> od02010_doCreateInvoice(List<Map<String, Object>> gridList, List<Map<String, Object>> reqInList) throws Exception {

		String cpoNo    = gridList.get(0).get("CPO_NO").toString();
		String vendorCd = gridList.get(0).get("VENDOR_CD").toString();
		String IV_NO    = "";//docNumService.getDocNumber("IV"); // 공급사 납품서 번호
		String INV_NO   = ""; // 고객사 납품서 번호
		String invcCd = "";

		int invNoCount = 1;
		int invSeq = 1; // 납품서 항번
		Map<String, Object> respMap = new HashMap<String, Object>();
		respMap.put("IV_NO_0", IV_NO);
		invcCd = docNumService.getDocNumber("VO");

		for( int i = 0; i < gridList.size(); i++) {

			if(siv101_Mapper.chkIvPo(gridList.get(i)) !=0) {
				throw new Exception("이미 종결된 발주입니다.");
			}

		    IV_NO  = docNumService.getDocNumber("IV"); // 공급사 납품서 번호
			INV_NO = docNumService.getDocNumber("INV");

			Map<String, Object> reqMap = gridList.get(i);
			reqMap.put("IV_NO",  IV_NO);
			reqMap.put("INV_NO", INV_NO);
			reqMap.put("IV_SEQ", invSeq);
			reqMap.put("IF_INVC_CD", invcCd); //거레명세서용
			reqInList.add(reqMap);

			if( vendorCd.equals(gridList.get(i).get("VENDOR_CD").toString()) ) {

			} else {
				vendorCd = gridList.get(i).get("VENDOR_CD").toString();
				invcCd = docNumService.getDocNumber("VO");
			}




			siv1020_doCreateDB(reqMap, "wayCode_11");
		}
//		if(1==1) throw new Exception("====================================");
		respMap.put("invNoCount", Integer.toString(invNoCount));
		return respMap;
	}




	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, Object> od02010_doCreateInvoice20230103(List<Map<String, Object>> gridList, List<Map<String, Object>> reqInList) throws Exception {

		String cpoNo    = gridList.get(0).get("CPO_NO").toString();
		String vendorCd = gridList.get(0).get("VENDOR_CD").toString();
		String IV_NO    = docNumService.getDocNumber("IV"); // 공급사 납품서 번호
		String INV_NO   = ""; // 고객사 납품서 번호

		int invNoCount = 1;
		int invSeq = 1; // 납품서 항번
		Map<String, Object> respMap = new HashMap<String, Object>();
		respMap.put("IV_NO_0", IV_NO);

		for( int i = 0; i < gridList.size(); i++) {

			if(siv101_Mapper.chkIvPo(gridList.get(i)) !=0) {
				throw new Exception("이미 종결된 발주입니다.");
			}

			if( i == 0 ) {
				//if( !"400".equals(gridList.get(0).get("DEAL_CD").toString()) ){
				INV_NO = docNumService.getDocNumber("INV");
				//}

				Map<String, Object> reqMap = gridList.get(0);
				reqMap.put("IV_NO",  IV_NO);
				reqMap.put("INV_NO", INV_NO);
				reqMap.put("IV_SEQ", invSeq);
				reqInList.add(reqMap);

				siv1020_doCreateDB(reqMap, "wayCode_11");
			}
			else {
				// 동일 주문건
				if( cpoNo.equals(gridList.get(i).get("CPO_NO").toString()) || 1 == 1) {
					// 동일한 공급사면 납품서 동일
					if( vendorCd.equals(gridList.get(i).get("VENDOR_CD").toString()) ) {
						invSeq = invSeq + 1;

						Map<String, Object> reqMap = gridList.get(i);
						reqMap.put("IV_NO",  IV_NO);
						reqMap.put("INV_NO", INV_NO);
						reqMap.put("IV_SEQ", invSeq);
						reqInList.add(reqMap);

						siv1020_doCreateDB(reqMap, "wayCode_00");
					} // 공급사가 다르면 납품서도 다르게
					else {
						vendorCd = gridList.get(i).get("VENDOR_CD").toString();

						IV_NO  = docNumService.getDocNumber("IV");  // 공급사 납품번호
						//if( !"400".equals(gridList.get(i).get("DEAL_CD").toString()) ){
						INV_NO = docNumService.getDocNumber("INV"); // 고객사 납품번호
						//}
						invSeq = 1;

						respMap.put("IV_NO_" + invNoCount, IV_NO);
						invNoCount = invNoCount + 1;

						Map<String, Object> reqMap = gridList.get(i);
						reqMap.put("IV_NO",  IV_NO);
						reqMap.put("INV_NO", INV_NO);
						reqMap.put("IV_SEQ", invSeq);
						reqInList.add(reqMap);

						siv1020_doCreateDB(reqMap, "wayCode_11");

					}
				} // 다른 주문건
			}
		}

		respMap.put("invNoCount", Integer.toString(invNoCount));
		return respMap;
	}


	// DB 등록
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void siv1020_doCreateDB(Map<String, Object> reqMap, String wayCode) throws Exception {
		reqMap.put("AGENT_YN", "1"); // 납품서 대행여부

		//1. IVHD 입력
		if("wayCode_11".equals(wayCode)){
			// YIVHD (공급사납품)
			siv101_Mapper.siv1020_doCreateYIVHD(reqMap);
			// UIVHD (고객사납품) : 물류
			//if( !"400".equals(reqMap.get("DEAL_CD").toString()) ){
			siv101_Mapper.siv1020_doCreateUIVHD(reqMap);
			//}
		}

		// 2. IVDT 입력
		// YIVDT (공급사납품)
		siv101_Mapper.siv1020_doCreateYIVDT(reqMap);
		// UIVDT (고객사납품) : 물류
		//if(!"400".equals(reqMap.get("DEAL_CD").toString())){
		siv101_Mapper.siv1020_doCreateUIVDT(reqMap);
		//}

		siv101_Mapper.siv1020_doUpdateUPODT(reqMap);
		// 3. PODT 업데이트
		// YPODT (공급사발주)
		siv101_Mapper.siv1020_doUpdateYPODT(reqMap);

		Map<String, Object> checkMap = siv101_Mapper.getPoQtySumInvQty(reqMap);
		double poQty = Double.parseDouble(String.valueOf(checkMap.get("PO_QTY")));
		double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));

		if(poQty < podtInvQty) {
			throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + reqMap.get("CPO_NO") + ", 품목코드 : " + reqMap.get("ITEM_CD"));
		}
	}

	/** ******************************************************************************************
     * 운영사 : 납품서수정 대행
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> od02020_doSearch(Map<String, String> param) throws Exception {

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

		/*
		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}*/

		return siv103_Mapper.siv1030_doSearch(param);
	}

	// 운영사 납품서 수정
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od02020_doSave(List<Map<String, Object>> gridList) throws Exception {

		// 1. IVHD 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUIVHD(gridData);
			// STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYIVHD(gridData);
		}

		// 2. IVDT 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUIVDT(gridData);
			// STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYIVDT(gridData);

			int chkGrCount = siv103_Mapper.chkGrdt(gridData);
			if(chkGrCount != 0) {
				throw new Exception("입고가 진행된건 입니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}
		}

		// 3. PODT 업데이트
		boolean isChangeFlag = false;
		String cpoNo = "";
		Map<String, Object> ivSeqMap = null;
		List<Map<String, Object>> ivSeqList = new ArrayList<Map<String, Object>>();
		for( Map<String, Object> gridData : gridList ) {
			// 3-1. STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUPODT(gridData);
			// 3-2. STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYPODT(gridData);

			Map<String, Object> checkMap = siv101_Mapper.getPoQtySumInvQty(gridData);
			double poQty = Double.parseDouble(String.valueOf(checkMap.get("PO_QTY")));
			double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));
			if(poQty < podtInvQty) {
				throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}

			// 납품예정일이 변경되는 경우에만 메일 발송
			if( gridData.get("DELY_APP_DATE") != gridData.get("DELY_APP_DATE_RES") ){
				isChangeFlag = true;
				cpoNo = gridData.get("CPO_NO").toString();

				ivSeqMap = new HashMap<String, Object>();
				ivSeqMap.put("IV_NO_SEQ", String.valueOf(gridData.get("IV_NO")) + String.valueOf(gridData.get("IV_SEQ")));
				ivSeqList.add(ivSeqMap);
			}
		}

		// 납품서 변경 EMAIL 및 SMS 발송
		/*try {
			if( !"".equals(cpoNo) && isChangeFlag ){
				Map<String, Object> mailParam = new HashMap<String, Object>();
				mailParam.put("CPO_NO", cpoNo);
				mailParam.put("ivSeqList", ivSeqList);
				sendEmailNSms_Change(mailParam);
			}
		} catch ( Exception ex ){
			System.out.println("=====> 납품서 변경대행(OD02_020) EMAIL, SMS 발송 오류 : " + ex);
		} 2022 12 22 납품일 변경시 메일발송 삭제
		*/

		return msg.getMessage("0001");
	}

	// 운영사 납품서 삭제 대행
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od02020_doDelete(List<Map<String, Object>> gridList) throws Exception {

		for( Map<String, Object> gridData : gridList ) {

			int chkCount = siv103_Mapper.chkUivdt(gridData);
			if(chkCount > 0) continue;

			int chkGrCount = siv103_Mapper.chkGrdt(gridData);
			if(chkGrCount != 0) {
				throw new Exception("이미 입고가 진행된 건입니다.");
			}

			// 1. IVDT 삭제
			siv103_Mapper.siv1030_doDeleteUIVDT(gridData);
			siv103_Mapper.siv1030_doDeleteYIVDT(gridData);
			// 2. PODT 업데이트
			siv103_Mapper.siv1030_doDeleteUPODT(gridData);
			siv103_Mapper.siv1030_doDeleteYPODT(gridData);

			Map<String, Object> checkMap = siv101_Mapper.getPoQtySumInvQty(gridData);
			double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));
			if(podtInvQty < 0) {
				throw new Exception("다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}
		}

		return msg.getMessage("0001");
	}

	/** ******************************************************************************************
     * 운영사 : 납품완료 입력/수정 대행
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> od02030_doSearch(Map<String, String> param) throws Exception {
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
	public String od02030_doCompleteDely(List<Map<String, Object>> gridList) throws Exception {

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
	public String od02030_doCancelDely(List<Map<String, Object>> gridList) throws Exception {

		String rtnMsg = "";
		for( Map<String, Object> gridData : gridList ) {

			if(gridData.get("IF_CPO_NO_SEQ").toString().length() < 2 ) {
				siv104_Mapper.siv1050_doCancelUIVDT(gridData); // 고객사 납품상세
				siv104_Mapper.siv1050_doCancelYIVDT(gridData); // 공급사 납품상세
			} else {
				// ==================== DGNS I/F 데이터 삭제 ========================== //
				//2023.01.27추가: 납품완료 취소시 IF_FLAG='2'인 경우 납품완료취소(IF테이블삭제) 가능
				int checkCnt = realtimeifMapper.checkDgnsInvoice(gridData);
				if( checkCnt > 0) {
					realtimeifMapper.delDgnsInvoiceHD(gridData);	// IF 납품서 삭제
					realtimeifMapper.delDgnsInvoiceDT(gridData);	// IF 납품서 삭제

					siv104_Mapper.siv1050_doCancelUIVDT(gridData); 	// 고객사납품 삭제
					siv104_Mapper.siv1050_doCancelYIVDT(gridData); 	// 공급사납품 삭제
				} else {
					rtnMsg += gridData.get("IV_NO")+"-"+gridData.get("IV_SEQ")+"\n";
				}
				// ==================== DGNS I/F 데이터 삭제 ========================== //
			}
		}
		if( !"".equals(rtnMsg) ) {
			rtnMsg += "위 납품번호는 취소할 수 없습니다. DGNS 납품상태를 확인하세요.";
		}

		return msg.getMessage("0001") + ((!"".equals(rtnMsg))?"\n":"") + rtnMsg;
	}

	// 납품서 생성 : EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public void sendEmailNSms(Map<String, Object> param) throws Exception {
        // 주문헤더(UPOHD) 가져오기
        Map<String, Object> cpoUserInfo = siv101_Mapper.siv1020_doSearchCpoHeaderInfo(param);

        // 고객사 주문자에게 SMS 전송
        if( !"".equals(cpoUserInfo.get("CUST_CELL_NUM")) ){
            Map<String, String> hdata = new HashMap<String, String>();
            hdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_ID"))); // 보내는 사용자ID(공급사 납품담당자)
            hdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_USER_NM"))); // 보내는사람(공급사 납품담당자)
            hdata.put("SEND_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("VENDOR_TEL_NUM"))); // 보내는 사람 전화번호(대표전화번호)
            hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID"))); // 받는 사용자ID
            hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 받는사람
            hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_CELL_NUM"))); // 받는 사람 전화번호
            hdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))+"님. 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납품서가 생성되었습니다. 감사합니다."); // 전송내용
            hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
            hdata.put("REF_MODULE_CD", "IV"); // 참조모듈
            everSmsService.sendSms(hdata);
        }
	}

	// 납품서 납기일 변경 : EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public void sendEmailNSms_Change(Map<String, Object> param) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_CHNG_TemplateFileName");

        String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm  = PropertiesManager.getString("eversrm.system.contextName");

		String maintainUrl  = "";
		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
		if (sslFlag) { maintainUrl = "https://"; }
		else { maintainUrl = "http://"; }
		if ("80".equals(domainPort)) {
			maintainUrl += domainNm;
		} else {
			maintainUrl += domainNm + ":" + domainPort;
		}
		maintainUrl += contextNm;

		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		// 주문헤더(UPOHD) 가져오기
        Map<String, Object> cpoUserInfo = siv103_Mapper.getInvChangeHeaderInfo(param);
        // 고객사 주문자에게 EMAIL 전송
        fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 주문번호
        fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_DATE"))); // 주문일자
        fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 주문자명
        fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

        String tblBody = "<tbody>";
        String enter = "\n";
        // 주문품목(UPODT) 가져오기
        List<Map<String, Object>> itemList = siv103_Mapper.getInvChangeDetailInfo(param);
        if( itemList.size() > 0 ){
            for( Map<String, Object> itemData : itemList ){
                // 품목명
            	String itemDesc = (String)itemData.get("ITEM_DESC");
                if(itemDesc.length() > 29) { itemDesc = itemDesc.substring(0, 30) + "..."; }
                // 품목규격
                String itemSpec = (String)itemData.get("ITEM_SPEC");
                if(itemSpec.length() > 29) { itemSpec = itemSpec.substring(0, 30) + "..."; }

                // 품목리스트
                String tblRow = "<tr>"
                		+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd' rowspan='2'>" + EverString.nullToEmptyString(itemData.get("ITEM_CD")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
                        + enter + "</tr>"
                        + enter + "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("DELY_DELAY_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("DELY_APP_DATE")) + "</td>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }

        fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
        fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
        fileContents = EverString.rePreventSqlInjection(fileContents);

        // 운영사 진행관리담당자 -> 고객사 주문자
    	if( !"".equals(cpoUserInfo.get("CUST_EMAIL")) ){
            Map<String, String> mdata = new HashMap<String, String>();
            mdata.put("SUBJECT", "[대명소노시즌] 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납기일이 변경되었습니다.");
            mdata.put("CONTENTS_TEMPLATE", fileContents);
            mdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 주문자
            mdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM")));
            mdata.put("SEND_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("OPER_EMAIL")));
            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID")));
            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM")));
            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("CUST_EMAIL")));
            mdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")));
            mdata.put("REF_MODULE_CD","IV"); // 참조모듈
			// 메일발송
			everMailService.sendMail(mdata);
			mdata.clear();
        }

    	// 운영사 진행관리담당자 -> 고객사 주문자
        if( !"".equals(cpoUserInfo.get("CUST_CELL_NUM")) ){
            Map<String, String> hdata = new HashMap<String, String>();
            hdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))+"님. 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납기일이 변경되었습니다. 확인바랍니다."); // 전송내용
            hdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 보내는 사용자ID(운영사 품목담당자)
            hdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM"))); // 보내는사람(운영사 품목담당자)
            hdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 보내는 사람 전화번호(대표전화번호)
            hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID"))); // 받는 사용자ID(고객사 주문자)
            hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 받는사람(고객사 주문자)
            hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_CELL_NUM"))); // 받는 사람 전화번호(고객사 주문자)
            hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
            hdata.put("REF_MODULE_CD","IV"); // 참조모듈
			// SMS 발송
			everSmsService.sendSms(hdata);
			hdata.clear();
        }
	}

	@Async
	public void od02010_sendBizNetworkStorageNo(List<Map<String, Object>> gridData, String divYn, List<Map<String, Object>> reqInList) throws Exception{

		int num = 0;

		for (Map<String, Object> grid : gridData) {

			grid.putAll(reqInList.get(num));

			// 입하번호 받아오기 전에 YPODT 의 IF_CPO_NO, SEQ 가 존재하는지 조회
			Map<String, String> cpoInfo = siv101_Mapper.siv1020_doSearch_CPO_INFO(grid);

			if(cpoInfo != null) {
				cpoInfo.put("GR_QTY", String.valueOf(grid.get("INV_QTY")));
				//cpoInfo.put("GR_QTY", "252");
				cpoInfo.put("GR_DT", String.valueOf(grid.get("DELY_APP_DATE")));

				JSONArray jsArr = new JSONArray();

				String url = "";
				if (PropertiesManager.getBoolean("eversrm.system.developmentFlag")) {
					url = "http://211.194.150.42:8080/";
				} else {
					url = "http://srm.soulbrain.co.kr/";
				}

				JSONObject jsObj = new JSONObject();
				jsObj.put("PO_NO", cpoInfo.get("PO_NO"));
				jsObj.put("PO_LINE_LN", cpoInfo.get("PO_LINE_LN"));
				jsObj.put("GR_QTY", cpoInfo.get("GR_QTY"));
				jsObj.put("GR_DT", cpoInfo.get("GR_DT"));

				// 일괄/분할 여부 판단
				if(String.valueOf(grid.get("CPO_QTY")).equals(String.valueOf(grid.get("INV_QTY")))) {
					jsObj.put("DIV_YN", "N");
				} else {
					jsObj.put("DIV_YN", "Y");
				}

				jsArr.put(0, jsObj);

				BizHttp http = new BizHttp(url+"srmInBound.jsp", BizHttp.HttpMethod.POST);

				http.addBody("S_PO_NO", cpoInfo.get("PO_NO"));
				http.addBody("ITEMLIST", ""+jsArr);

				JSONObject resultJson = http.getJSONObject();
				JSONArray jsGrlist = resultJson.getJSONArray("GRLIST");

				// 입하번호 update
				String sInvcCd = getStroageNo(jsGrlist);

				grid.put("sInvcCd", sInvcCd);
				siv101_Mapper.siv1020_doUpdateYIVDT(grid);
				siv101_Mapper.siv1020_doUpdateUIVDT(grid);

				num++;
			}

		}
	}

	public String getStroageNo(JSONArray jsArray)
	{
		//HashMap<String, Object> param = new HashMap<String, Object>();
		String sInvcCd = null;
		for(int i=0; i < jsArray.length(); i++)
		{
			JSONObject jsObj = (JSONObject)jsArray.get(i);
			sInvcCd = (String)jsObj.get("S_INVC_CD");
			//param.put("buy_ref_no", jsObj.get("S_PO_NO").toString() + "-" + jsObj.get("S_PO_LINE_NO").toString());
			//param.put("s_invc_cd", sInvcCd);
			//vd에서 처리
			//buyerMapper.updInvcCd(param);
		}
		return sInvcCd;
	}


}
