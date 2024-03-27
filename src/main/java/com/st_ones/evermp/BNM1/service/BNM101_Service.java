package com.st_ones.evermp.BNM1.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BNM1.BNM101_Mapper;
import com.st_ones.evermp.RQ01.RQ0102_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */
@Service(value = "bnm1_Service")
public class BNM101_Service extends BaseService {

	@Autowired private RQ0102_Mapper rq0102_Mapper;
    @Autowired private BNM101_Mapper bnm101Mapper;

    @Autowired private DocNumService docNumService;
	@Autowired private EverMailService everMailService;
    @Autowired private QueryGenService queryGenService;
    @Autowired private MessageService msg;
	@Autowired LargeTextService largeTextService;

	// 실시간 I/F는 공통에서 관리함
    @Autowired private RealtimeIF_Mapper realtimeif_mapper;

    /** ****************************************************************************************************************
     * 신규상품 > 신규상품요청 > 신규상품 요청 (BNM1_010) : 일괄요청
     * @param req
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bnm1010_doSave(List<Map<String, Object>> gridDatas) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfoImpl();

		// 2022.09.26 로직 추가
		// 신규상품 요청자의 권한이 "구매담당자"인 경우 "운영사에게 직접 요청" = 진행상태 : 100
		String progressCd = "T";
		boolean havePermission = EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100");
		if (havePermission) {
			progressCd = "100"; // 운영사 신규견적요청(100)
		}


		String docNo = docNumService.getDocNumber("RE");
		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("ITEM_REQ_NO", docNo);
			gridData.put("PROGRESS_CD", progressCd); // 신규상품 요청작성(T)
			gridData.put("REQUEST_USER_ID",userInfo.getUserId());
			gridData.put("BUDGET_DEPT_CD", userInfo.getBudgetDeptCode());
			gridData.put("OPERATOR_FLAG", "0");
			/*if (!"1".equals(gridData.get("AUTO_PO_FLAG"))) {
				gridData.put("BUDGET_DEPT_CD", "");
				gridData.put("ACCOUNT_CD", "");
				gridData.put("RECIPIENT_NM", "");
				gridData.put("RECIPIENT_DEPT_NM", "");
				gridData.put("RECIPIENT_TEL_NO", "");
				gridData.put("RECIPIENT_CELL_NO", "");
				gridData.put("DELY_ZIP_CD", "");
				gridData.put("DELY_ADDR_1", "");
				gridData.put("DELY_ADDR_2", "");
				gridData.put("REQ_TXT", "");
			}*/
			bnm101Mapper.bnm1010_doInsert(gridData);
		}

		return msg.getMessage("0122");
    }

    /** ****************************************************************************************************************
     * 신규등록
     * @param req
     * @return
     * @throws Exception
     */
    public Map<String, Object> bnm1011_doSearchForm(Map<String, String> param) {
    	return bnm101Mapper.bnm1011_doSearchForm(param);
    }

    // 신규상품 > 신규상품요청 > 신규상품 요청 (BNM1_010) > 신규상품요청(건별) (BNM1_011)
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bnm1011_doSave(Map<String, String> formData) throws Exception {

    	String itemReqNo = EverString.nullToEmptyString(formData.get("ITEM_REQ_NO"));
		Map<String, Object> objData = new HashMap<String, Object>();
		objData.putAll(formData);

    	UserInfo userInfo = UserInfoManager.getUserInfoImpl();
		objData.put("REQUEST_USER_ID", userInfo.getUserId());

		/*
		 자동발주 여부
		if (!"1".equals(formData.get("AUTO_PO_FLAG"))) {
			objData.put("BUDGET_DEPT_CD", "");
			objData.put("ACCOUNT_CD", "");
			objData.put("RECIPIENT_NM", "");
			objData.put("RECIPIENT_DEPT_NM", "");
			objData.put("RECIPIENT_TEL_NUM", "");
			objData.put("RECIPIENT_CELL_NUM", "");
			objData.put("DELY_ZIP_CD", "");
			objData.put("DELY_ADDR_1", "");
			objData.put("DELY_ADDR_2", "");
			objData.put("REQ_TXT", "");
		}
		*/

		// 2022.09.26 로직 추가
		// 신규상품 요청자의 권한이 "구매담당자"인 경우 "운영사에게 직접 요청" = 진행상태 : 100
		String progressCd = "T";
		boolean havePermission = EverString.nullToEmptyString(userInfo.getCtrlCd()).contains("T100");
		if (havePermission) {
			progressCd = "100"; // 운영사 신규견적요청(100)
		}

		if(EverString.replaceAll(itemReqNo, " ", "").equals("")) {
			String docNo = docNumService.getDocNumber("RE");
			objData.put("ITEM_REQ_NO", docNo);
			objData.put("PROGRESS_CD", progressCd); 	// 신규상품 요청작성(T), 고객사 구매담당자 권한인 경우 "운영사 신규견적요청(100)"으로 처리
			objData.put("RECIPIENT_TEL_NO", objData.get("RECIPIENT_TEL_NUM"));
			objData.put("RECIPIENT_CELL_NO", objData.get("RECIPIENT_CELL_NUM"));
			objData.put("OPERATOR_FLAG", "0");
			bnm101Mapper.bnm1010_doInsert(objData);
		} else {
			objData.put("PROGRESS_CD", progressCd); 	// 신규상품 요청작성(T), 고객사 구매담당자 권한인 경우 "운영사 신규견적요청(100)"으로 처리
			objData.put("RECIPIENT_TEL_NO", objData.get("RECIPIENT_TEL_NUM"));
			objData.put("RECIPIENT_CELL_NO", objData.get("RECIPIENT_CELL_NUM"));
			objData.put("OPERATOR_FLAG", "0");
			bnm101Mapper.bnm1010_doUpdate(objData);
		}
		return msg.getMessage("0122");
    }

    /** ****************************************************************************************************************
     * 신규상품 > 신규상품요청 > 신규상품 요청현황 (BNM1_040)
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bnm1040_doSearch(Map<String, String> param) {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_NM"));
            sParam.put("COL_NM", "A.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "A.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));

    	return bnm101Mapper.bnm1040_doSearch(fParam);
    }

    /** ****************************************************************************************************************
     * 신규상품 > 신규상품요청 > 신규상품 견적의뢰 (BNM1_030)
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bnm1030_doSearch(Map<String, String> param) {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_NM"));
            sParam.put("COL_NM", "ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));

    	return bnm101Mapper.bnm1030_doSearch(fParam);
    }

    /** ****************************************************************************************************************
     * 신규상품 > 신규상품요청 > 견적 합의 (BNM1_031)
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bnm1031_doSearch(Map<String, String> param) {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_NM"));
            sParam.put("COL_NM", "A.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "A.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("VIEW_TYPE", "A"); // 견적합의현황 (BNM1_031)
		fParam.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));

    	return bnm101Mapper.bnm1030_doSearch(fParam);
    }

    /** ****************************************************************************************************************
     * 신규상품 > 신규상품요청 > 상품등록 완료현황 (BNM1_032)
     * @param req
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bnm1032_doSearch(Map<String, String> param) {
    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_NM")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_NM"));
            sParam.put("COL_NM", "A.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "A.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("VIEW_TYPE", "B"); // 상품등록 완료현황 (BNM1_032)
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));

    	return bnm101Mapper.bnm1030_doSearch(fParam);
    }

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bnm1032_doAddCart(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			bnm101Mapper.bnm1032_doAddCart(gridData);
		}

		return msg.getMessageByScreenId("BNM1_030", "007");
	}

	// 신규상품 > 신규상품요청 > 신규상품 견적의뢰 (BNM1_030) : 신규상품요청 승인
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bnm1030_doConfirm(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PROGRESS_CD", "100");
			gridData.put("RE_REQ_REJECT_RMK", "");
			bnm101Mapper.bnm1030_doUpdateProgressCd(gridData);
		}

		// 2022.09.02 HMCHOI 추가
		// 고객의 상품담당자에 의한 승인(신규견적요청(100)) 이후 운영사의 상품담당자(C100)에게 메일발송
		/*if( gridDatas.size() > 0 ) {
			Map<String, String> param = new HashMap<String, String>();
			param.put("REQ_NO", String.valueOf(gridDatas.get(0).get("ITEM_REQ_NO")));
			sendMail(param);
		}*/

		return msg.getMessageByScreenId("BNM1_030", "018");
	}

	// 신규상품 > 신규상품요청 > 견적 합의 (BNM1_031) : 승인
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bnm1031_doConfirm(List<Map<String, Object>> gridDatas) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfo();
		Map<String, String> map = new HashMap<String, String>();

		for (Map<String, Object> gridData : gridDatas) {

			gridData.put("PROGRESS_CD", "500"); // 고객사 합의완료
			bnm101Mapper.bnm1030_doUpdateProgressCd(gridData);

			List<Map<String, Object>> cnInfos = bnm101Mapper.getCnInfo(gridData);
			if(cnInfos.size() > 0) {
				for (Map<String, Object> cnInfo : cnInfos) {

					// 본 품의서에 포함된 견적의뢰서 품목의 진행상태를 '계약완료(600)'로 변경.
					cnInfo.put("PROGRESS_CD", "600");
					bnm101Mapper.updateStatusRQDT(cnInfo);

					// 공급사 견적서 QTDT.CONT_UNIT_PRC (계약단가 변경)
					bnm101Mapper.updateStatusQTDT(cnInfo);

					// 본 품의서에 포함된 신규품목등록 요청 건의 진행상태를 '합의완료(500)'로 변경.
					cnInfo.put("PROGRESS_CD", "500");
					bnm101Mapper.updateStatusNWRQ(cnInfo);

					// ===== I/F를 통한 상품요청은 DGNS Batch(ITEMIF.java)에서 처리하도록 함 ========
					/**
					 * 고객사에서 신규품목 등록 요청한 경우
            		 * (ICOYPRHD_IF, ICOYPRDT_IF)의 IF_FLAG=5(고객사 견적서 합의완료 처리) 처리함
            		 * 고객사 합의완료는 Batch(ITEMIF.java) 에서 처리함
					if (String.valueOf(cnInfo.get("CUST_REQ_FLAG")).equals("1")) {
                        cnInfo.put("IF_FLAG", "5");		// 고객사 견적서 합의완료 MRO 처리
                        realtimeif_mapper.updateItemStatusPRHD(cnInfo);
                        realtimeif_mapper.updateItemStatusPRDT(cnInfo);
                    }*/
					// ==============================================================

					map.put("EXEC_NUM", String.valueOf(cnInfo.get("EXEC_NUM")));
					map.put("EXEC_SQ", String.valueOf(cnInfo.get("EXEC_SQ")));
					map.put("RFQ_NUM", String.valueOf(cnInfo.get("RFQ_NUM")));
					map.put("RFQ_CNT", String.valueOf(cnInfo.get("RFQ_CNT")));
				}

				// 해당 견적의뢰번호/차수의 품목 중 '부분선정(390)'인 상태가 있을 수 있으므로 모든 품목에 대한 진행상태가"계약완료(600)" 이상이면
                // 본 품의가 해당 견적의뢰(RQHD)를 기준으로 작성하는 마지막 품의이므로'계약완료(600)'로 진행상태를 변경한다.
				String rqhdProgressCd = EverString.nullToEmptyString(bnm101Mapper.getRqhdProgressCd(map));
				map.put("PROGRESS_CD", rqhdProgressCd);
				bnm101Mapper.doUpdateProgressCdRQHD(map);

				String contNo = "";
				// 매입단가를 등록한다.
				// 1. 해당 품의서에 포함된 공급사 List를 가져온다.
				List<Map<String, String>> vendorList = bnm101Mapper.getCnVendorList(map);
				for(Map<String, String> vendorData : vendorList) {

					// 해당 공급사별 계약대상 품목정보를 가져온다.
					List<Map<String, Object>> yInfoList = bnm101Mapper.getYinfoByVendors(vendorData);
					for (Map<String, Object> yInfoData : yInfoList) {

						// 계약번호 생성. (공급사별로 계약번호를 달리 생성한다.)
						contNo = docNumService.getDocNumber("CT");

						int contSeq = 1;
						String custListStr = EverString.nullToEmptyString(String.valueOf(yInfoData.get("APPLY_TARGET_CD")));
						if (custListStr.length() > 0) {
							String[] custListArgs = custListStr.split(",");
							for (int i = 0; i < custListArgs.length; i++) {

								yInfoData.put("APPLY_COM", custListArgs[i]);
								Map<String, Object> newInfoData = bnm101Mapper.getYinfoByVendor(yInfoData);

								// 계약 (운영사매입 계약단가)
								newInfoData.put("CONT_NO",  contNo);
								newInfoData.put("CONT_SEQ", contSeq);
								newInfoData.put("AGENT_CD", userInfo.getManageCd());
								newInfoData.put("CONT_TYPE_CD", "RQ"); 	// 계약유형[MP023] : 견적(RQ)
                                newInfoData.put("RFX_TYPE", "RFQ"); 	// RFX구분[M070] - 견적(RFQ), 입찰(BID)
                                newInfoData.put("SIGN_STATUS", "E"); 	// 승인
								newInfoData.put("REG_USER_ID", String.valueOf(newInfoData.get("CTRL_USER_ID")));

								newInfoData.put("CHANGE_CD", "99");
								newInfoData.put("CHANGE_REASON", "견적");

								// 승인후 운영사 매입계약단가
								rq0102_Mapper.insert_YINFO(newInfoData);

								// 고객사 품목 판매단가 정보
								rq0102_Mapper.insert_UINFO(newInfoData);

								// 품의 품목정보에 계약번호/항번을 업데이트한다.
								rq0102_Mapper.update_CnInfo(newInfoData);

								// 품목등록신청청 품목정보에 계약번호/항번을 업데이트한다.
								rq0102_Mapper.update_NwInfo(newInfoData);

								/**
                                 * 2022.09.22 : 지역정보 제외
								// 계약 (운영사매입 계약단가) 지역정보 삭제
								rq0102_Mapper.delete_YINFR(newInfoData);

								// 계약 (운영사매입 계약단가) 지역정보 등록
								String regionCd = com.st_ones.common.util.clazz.EverString.nullToEmptyString(newInfoData.get("REGION_CD"));
								if (!regionCd.equals("")) {
									String[] regionArgs = regionCd.split(",");
									for (int j = 0; j < regionArgs.length; j++) {
										Map<String, Object> regionMap = new HashMap<String, Object>();
										regionMap.put("APPLY_COM", custListArgs[i]);
										regionMap.put("CONT_NO", contNo);
										regionMap.put("CONT_SEQ", contSeq);
										regionMap.put("REGION_CD", regionArgs[j]);
										rq0102_Mapper.insert_YINFR(regionMap);
									}
								}*/

								// 매입단가 이력정보 저장.
								rq0102_Mapper.insert_YINFH(newInfoData);

								// 판매단가 이력정보 저장.
								rq0102_Mapper.insert_UINFH(newInfoData);

								// 품목등록신청에 기존 APPLY_COM, CONT_NO, CONT_SEQ가 존재하면 해당 계약을 폐기한다.
								if (EverString.isNotEmpty(EverString.nullToEmptyString(newInfoData.get("VENDOR_CD")))
								 && EverString.isNotEmpty(EverString.nullToEmptyString(newInfoData.get("ITEM_CD"))))
								{
									List<Map<String, Object>> validList = rq0102_Mapper.getValidInfos(newInfoData);
                                    for (Map<String, Object> validData : validList) {
                                    	validData.put("VALID_FROM_DATE", newInfoData.get("VALID_FROM_DATE"));
                                    	rq0102_Mapper.deadPreContract(validData);
                                    }
								}
								contSeq++;
							}
						}
					}
				}

				/**
                 * 2020.09.22 제외
                 * 매입단가와 판매단가가 1:1로 등록되어 상위에서 처리함.
				List<Map<String, Object>> uInfoList = bnm101Mapper.getUinfoList(map);
				for(Map<String, Object> uInfoData : uInfoList) {

					double salesUnitPrc = Double.parseDouble(String.valueOf(uInfoData.get("SALES_UNIT_PRICE")));

					if (!com.st_ones.common.util.clazz.EverString.nullToEmptyString(uInfoData.get("CUST_CD")).equals("") && salesUnitPrc > 0) {

						String existFlag = com.st_ones.common.util.clazz.EverString.nullToEmptyString(rq0102_Mapper.getUinfoExistFlag(uInfoData));

						uInfoData.put("CHANGE_CD", "99");
						uInfoData.put("CHANGE_REASON", "견적");

						if (existFlag.equals("Y")) {
							// 판매단가 이력정보
							rq0102_Mapper.selectInsert_UINFH(uInfoData);
							// 판매단가 정보
							rq0102_Mapper.update_UINFO(uInfoData);
						} else {
							// 판매단가 정보
							rq0102_Mapper.insert_UINFO(uInfoData);
							// 판매단가 이력정보
							rq0102_Mapper.insert_UINFH(uInfoData);
						}
					}
				}*/

				/**
                 * 자동발주 주석처리 : 2020-10-15
                 * 해당 품의에 포함된 품목이 신규품목요청 건이고, 자동발주로 설정되어 있다면 자동발주 생성.
				Map<String, String> poParam = new HashMap<String, String>();
				poParam.put("EXEC_NUM", map.get("EXEC_NUM"));
				poParam.put("EXEC_SQ", map.get("EXEC_SQ"));

				List<Map<String, Object>> autoPoList = bnm101Mapper.getAutoPoList(poParam);
				if(autoPoList.size() > 0) {

					String CPONO = docNumService.getDocNumber("CPO");
					poParam.put("CPO_NO", CPONO);
					poParam.put("APPROVE_FLAG", "0");
					poParam.put("BUDGET_FLAG", "0");
					poParam.put("PRIOR_GR_FLAG", "0");
					poParam.put("CPO_DATE", EverDate.getDate());
					poParam.put("SIGN_STATUS", "E");
					poParam.put("PROGRESS_CD", "30"); // 주문완료
					poParam.put("CUST_CD", String.valueOf(autoPoList.get(0).get("COMPANY_CD")));
					poParam.put("CUST_USER_ID", String.valueOf(autoPoList.get(0).get("CUST_USER_ID")));
					poParam.put("CUST_DEPT_CD", String.valueOf(autoPoList.get(0).get("CUST_DEPT_CD")));
					poParam.put("CUST_TEL_NUM", String.valueOf(autoPoList.get(0).get("CUST_TEL_NUM")));
					poParam.put("CUST_HP_NUM", String.valueOf(autoPoList.get(0).get("CUST_HP_NUM")));

					// 1. STOUPOHD 등록
					bod103_Mapper.doInsertUPOHD(poParam);

					int cpo_seq = 1;
					for (Map<String, Object> autoPoData : autoPoList) {

						autoPoData.put("CPO_NO", CPONO);
						autoPoData.put("CPO_SEQ", String.valueOf(cpo_seq++));
						autoPoData.put("CPO_DATE", EverDate.getDate());
						autoPoData.put("PROGRESS_CD", "30");
						autoPoData.put("CUST_CD", String.valueOf(autoPoData.get("COMPANY_CD")));

						// 2. STOUPODT 등록
						bod103_Mapper.doInsertUPODT(autoPoData);

						// 3. 고객사 신규품목(STOUNWRQ) 변경
						if (!"".equals(com.st_ones.common.util.clazz.EverString.nullToEmptyString(autoPoData.get("ITEM_REQ_NO")))) {
							bod103_Mapper.doUpdateNWRQpo(autoPoData);
						}
					}

					// 4. 고객사 po 진행상태 변경
					bod103_Mapper.doUpdateSignStatusUPOHDNoApp(poParam);
					bod103_Mapper.doUpdateSignStatusUPODT(poParam);

					// 5. CPO를 PO로 분리하여 생성함
					// 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호
					// HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD
					List<Map<String, Object>> poList = bod103_Mapper.getPOList(poParam);
					for (Map<String, Object> poData : poList) {

						poData.put("CPO_NO", CPONO);
						poData.put("CUST_CD", poParam.get("CUST_CD"));
						poData.put("PO_NO", docNumService.getDocNumber("PO"));

						bod103_Mapper.doInsertYPOHD(poData);
						bod103_Mapper.doInsertYPODT(poData);
					}

					// 1회성 품목인 경우 "품목상태=단종"으로 변경
					bod103_Mapper.doUpdateItemStatus(poParam);

					// EMAIL 및 SMS 발송
					try {
						bod103_Service.sendEmailNSms(poParam);
					} catch (Exception ex) {
						System.out.println("=====> 메일발송 오류 : " + ex);
					}
				}*/

				/**
                 * 2022.09.23 메일 발송 제외
                 * 소싱관리 > 신규소싱 > 신규상품 CMS 맵핑 (RQ01_030) 에서 최종 품목이 등록되기 때문에 별도로 메일/SMS 발송하지 않음
                 * 필요한 경우 "회신" 프로세스를 통해 발송하도록 함
                // Mail Template 및 URL 가져오기
		        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
		        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");

		        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
				String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
				String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
				
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

				String execNum = "";
				if(cnInfos.size() > 0) { execNum = String.valueOf(cnInfos.get(0).get("EXEC_NUM")); }
				Map<String, String> eParam = new HashMap<String, String>();
				eParam.put("EXEC_NUM", execNum);

				String itemReqNo = "";
				String recvUserId = ""; String recvUserNm = ""; String recvTelNum = ""; String recvEmail = "";
				String sendUserId = ""; String sendUserNm = ""; String sendEmail = "";
				List<Map<String, Object>> reqList = rq0102_Mapper.getReqItemInfos(eParam);
				if(reqList.size() > 0) {
					itemReqNo = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("ITEM_REQ_NO"));
					recvUserId = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("RECV_USER_ID"));
					recvUserNm = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("RECV_USER_NM"));
					recvTelNum = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("RECV_TEL_NUM"));
					recvEmail = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("RECV_EMAIL"));
					sendUserId = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("SEND_USER_ID"));
					sendUserNm = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("SEND_USER_NM"));
					sendEmail = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqList.get(0).get("SEND_EMAIL"));
				}

				String tblBody = "<tbody>";
				String enter = "\n";
				if(reqList.size() > 0) {
					for (Map<String, Object> reqData : reqList) {

						String itemDesc = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqData.get("ITEM_DESC"));
						if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }

						String itemSpec = com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqData.get("ITEM_SPEC"));
						if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }

						String tblRow = "<tr>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + String.valueOf(reqData.get("ITEM_REQ_SEQ")) + "</th>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqData.get("ITEM_CD")) + "</th>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqData.get("MAKER_NM")) + "</th>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqData.get("UNIT_CD")) + "</th>"
								+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(reqData.get("CMS_CTRL_USER_NM")) + "</th>"
								+ enter + "</tr>";
						tblBody += tblRow;
					}
				}

				String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
				fileContents = com.st_ones.common.util.clazz.EverString.replace(fileContents, "$RECV_USER_NM$", recvUserNm); // 주문자명(고객)
				fileContents = com.st_ones.common.util.clazz.EverString.replace(fileContents, "$ITEM_REQ_NO$", itemReqNo); // 신규품목요청번호
				fileContents = com.st_ones.common.util.clazz.EverString.replace(fileContents, "$tblBody$", tblBody);
				fileContents = com.st_ones.common.util.clazz.EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
				fileContents = com.st_ones.common.util.clazz.EverString.rePreventSqlInjection(fileContents);

				if(!recvEmail.equals("")) {
					Map<String, String> mdata = new HashMap<String, String>();
					mdata.put("SUBJECT", "[대명소노시즌] " + recvUserNm + " 님. 요청하신 신규품목 등록 처리가 완료되었습니다.");
					mdata.put("CONTENTS_TEMPLATE", fileContents);
					mdata.put("SEND_EMAIL", sendEmail);
					mdata.put("SEND_USER_NM", sendUserNm);
					mdata.put("SEND_USER_ID", sendUserId);
					mdata.put("RECV_EMAIL", recvEmail);
					mdata.put("RECV_USER_NM", recvUserNm);
					mdata.put("RECV_USER_ID", recvUserId);
					mdata.put("REF_NUM", itemReqNo);
					mdata.put("REF_MODULE_CD", "RE"); // 참조모듈
					// 메일전송.
					everMailService.sendMail(mdata);
					mdata.clear();
				}

				if(!recvTelNum.equals("")) {
					Map<String, String> sdata = new HashMap<String, String>();
					sdata.put("SMS_SUBJECT", "[대명소노시즌] 요청하신 신규품목 등록 처리가 완료되었습니다."); // SMS 제목
					sdata.put("CONTENTS", "[대명소노시즌] " + recvUserNm + "님. 요청하신 신규품목 등록 처리가 완료되었습니다."); // 전송내용
					sdata.put("SEND_USER_ID", (com.st_ones.common.util.clazz.EverString.nullToEmptyString(sendUserId).equals("") ? "SYSTEM" : sendUserId)); // 보내는 사용자ID
					sdata.put("SEND_USER_NM", sendUserNm); // 보내는사람
					sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
					sdata.put("RECV_USER_ID", recvUserId); // 받는 사용자ID
					sdata.put("RECV_USER_NM", recvUserNm); // 받는사람
					sdata.put("RECV_TEL_NUM", recvTelNum); // 받는 사람 전화번호
					sdata.put("REF_NUM", itemReqNo); // 참조번호
					sdata.put("REF_MODULE_CD","RE"); // 참조모듈
					// SMS 전송.
					everSmsService.sendSms(sdata);
					sdata.clear();
				}

				// 본 품의서에 포함된 공급사에게 계약확정 통보.
				String vTemplateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CONT_TemplateFileName");

				String mailRfqNumCnt = "";
				String vendorCd = "";
				String vendorNm = "";
				List<Map<String, Object>> vendorDatas = rq0102_Mapper.getContVendorInfos(eParam);
				if (vendorList.size() > 0) {
					for (Map<String, Object> vendorData : vendorDatas) {

						mailRfqNumCnt = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("RFQ_NUM_CNT"));
						sendUserId = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("SEND_USER_ID"));
						sendUserNm = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("SEND_USER_NM"));
						sendEmail = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("SEND_EMAIL"));
						recvUserId = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("RECV_USER_ID"));
						recvUserNm = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("RECV_USER_NM"));
						recvTelNum = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("RECV_TEL_NUM"));
						recvEmail = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("RECV_EMAIL"));
						vendorCd = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("VENDOR_CD"));
						vendorNm = com.st_ones.common.util.clazz.EverString.nullToEmptyString(vendorData.get("VENDOR_NM"));

						eParam.put("VENDOR_CD", vendorCd);
						List<Map<String, Object>> itemList = rq0102_Mapper.getContItemInfos(eParam);

						tblBody = "<tbody>";
						enter = "\n";
						for (Map<String, Object> itemData : itemList) {

							String itemDesc = com.st_ones.common.util.clazz.EverString.nullToEmptyString(itemData.get("ITEM_DESC"));
							if (itemDesc.length() > 16) {
								itemDesc = itemDesc.substring(0, 15) + "...";
							}

							String itemSpec = com.st_ones.common.util.clazz.EverString.nullToEmptyString(itemData.get("ITEM_SPEC"));
							if (itemSpec.length() > 30) {
								itemSpec = itemSpec.substring(0, 29) + "...";
							}

							String tblRow = "<tr>"
									+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
									+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
									+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</th>"
									+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:right;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverMath.EverNumberType(Double.parseDouble(String.valueOf(itemData.get("CONT_UNIT_PRC"))), "###,###.##") + "원 " + "</th>"
									+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(itemData.get("TAX_NM")) + "</th>"
									+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + com.st_ones.common.util.clazz.EverString.nullToEmptyString(itemData.get("CONT_DATE")) + "</th>"
									+ enter + "</tr>";
							tblBody += tblRow;
						}
						tblBody = tblBody + enter + "</tbody>";

						String vFileContents = EverFile.fileReadByOffsetByEncoding(vTemplateFileNm, "UTF-8");
						vFileContents = com.st_ones.common.util.clazz.EverString.replace(vFileContents, "$RECV_USER_NM$", vendorNm); // 공급사명
						vFileContents = com.st_ones.common.util.clazz.EverString.replace(vFileContents, "$RFQ_NUM$", mailRfqNumCnt); // 견적의뢰번호
						vFileContents = com.st_ones.common.util.clazz.EverString.replace(vFileContents, "$tblBody$", tblBody);
						vFileContents = com.st_ones.common.util.clazz.EverString.replace(vFileContents, "$maintainUrl$", maintainUrl);
						vFileContents = com.st_ones.common.util.clazz.EverString.rePreventSqlInjection(vFileContents);

						if (!recvEmail.equals("")) {
							Map<String, String> mdata = new HashMap<String, String>();
							mdata.put("SUBJECT", "[대명소노시즌] " + vendorNm + " 님. 귀사에서 제출하신 견적건에 대해 계약확정 되었습니다.");
							mdata.put("CONTENTS_TEMPLATE", vFileContents);
							mdata.put("SEND_EMAIL", sendEmail);
							mdata.put("SEND_USER_NM", sendUserNm);
							mdata.put("SEND_USER_ID", sendUserId);
							mdata.put("RECV_EMAIL", recvEmail);
							mdata.put("RECV_USER_NM", recvUserNm);
							mdata.put("RECV_USER_ID", recvUserId);
							mdata.put("REF_NUM", mailRfqNumCnt);
							mdata.put("REF_MODULE_CD", "CONT"); // 참조모듈
							// 메일전송.
							everMailService.sendMail(mdata);
							mdata.clear();
						}

						if (!recvTelNum.equals("")) {
							Map<String, String> sdata = new HashMap<String, String>();
							sdata.put("SMS_SUBJECT", "[대명소노시즌] 귀사에서 제출하신 견적건에 대해 계약확정 되었습니다."); // SMS 제목
							sdata.put("CONTENTS", "[대명소노시즌] " + vendorNm + "님. 귀사에서 제출하신 견적건에 대해 계약확정 되었습니다."); // 전송내용
							sdata.put("SEND_USER_ID", (com.st_ones.common.util.clazz.EverString.nullToEmptyString(sendUserId).equals("") ? "SYSTEM" : sendUserId)); // 보내는 사용자ID
							sdata.put("SEND_USER_NM", sendUserNm); // 보내는사람
							sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
							sdata.put("RECV_USER_ID", recvUserId); // 받는 사용자ID
							sdata.put("RECV_USER_NM", recvUserNm); // 받는사람
							sdata.put("RECV_TEL_NUM", recvTelNum); // 받는 사람 전화번호
							sdata.put("REF_NUM", mailRfqNumCnt); // 참조번호
							sdata.put("REF_MODULE_CD", "CONT"); // 참조모듈
							// SMS 전송.
							everSmsService.sendSms(sdata);
							sdata.clear();
						}
					}
				}*/
			}
		}
		return msg.getMessageByScreenId("BNM1_031", "018");
	}

	// 신규상품 > 신규상품요청 > 신규상품 견적의뢰 (BNM1_030) : 신규상품 요청반려
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bnm1030_doRejectExec(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PROGRESS_CD", "R");
			bnm101Mapper.bnm1030_doUpdateProgressCd(gridData);
		}

		return msg.getMessageByScreenId("BNM1_030", "016");
	}

	// 신규상품 > 신규상품요청 > 견적 합의 (BNM1_031) : 견적 합의 반려
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String bnm1031_doRejectExec(List<Map<String, Object>> gridDatas) throws Exception {

		for (Map<String, Object> gridData : gridDatas) {
			gridData.put("PROGRESS_CD", "440");
			bnm101Mapper.bnm1031_doUpdateProgressCd(gridData);
		}

		return msg.getMessageByScreenId("BNM1_031", "016");
	}

	/**
	 * 고객사의 품목담당자가 신규품목에 대해 운영사로 견적요청시 운영사의 표준화 담당자(C100)에게 메일 발송
	 * @param params
	 * @throws Exception
	 */
	public void sendMail(Map<String, String> params) throws Exception {

		UserInfo userInfo = UserInfoManager.getUserInfoImpl();

		// Mail Template 및 URL 가져오기
		String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
		String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");
		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");

        String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
		
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

		// 고객사 신규품목 요청 완료 시 운영사의 표준화 담당자에게 메일 발송
		Map<String, String> param = new HashMap<String, String>();
		param.put("CTRL_CD", "C100"); // 운영사 상품 담당자
		List<Map<String, Object>> list = bnm101Mapper.bnm1010_doSaveSELECT_MAIL(param);

		String SUBJECT  = "[대명소노시즌] 신규품목요청이 접수되었습니다.(" + userInfo.getCompanyNm() + ", " + params.get("REQ_NO") + ")";
		String CONTENTS = "[대명소노시즌] 신규품목요청이 접수되었습니다.(" + userInfo.getCompanyNm() + ", " + params.get("REQ_NO") + ")<br>확인 후 업무진행 부탁드립니다.";

		for(Map<String, Object> map : list) {
			fileContents = EverString.replace(fileContents, "$CONTENTS$", CONTENTS);
			fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
			fileContents = EverString.rePreventSqlInjection(fileContents);

			if(!"".equals(map.get("EMAIL"))) {
				Map<String, String> mdata = new HashMap<String, String>();
				mdata.put("SUBJECT", SUBJECT);
				mdata.put("CONTENTS_TEMPLATE", fileContents);
				mdata.put("SEND_USER_ID", userInfo.getUserId());
				mdata.put("SEND_USER_NM", userInfo.getUserNm());
				mdata.put("SEND_EMAIL", userInfo.getEmail());
				mdata.put("RECV_USER_ID", EverString.nullToEmptyString(map.get("USER_ID")));
				mdata.put("RECV_USER_NM", EverString.nullToEmptyString(map.get("USER_NM")));
				mdata.put("RECV_EMAIL", EverString.nullToEmptyString(map.get("EMAIL")));
				mdata.put("REF_NUM", params.get("REQ_NO"));
				mdata.put("REF_MODULE_CD", "RE");
				// 메일발송
				everMailService.sendMail(mdata);
				mdata.clear();
			}
		}
	}
}