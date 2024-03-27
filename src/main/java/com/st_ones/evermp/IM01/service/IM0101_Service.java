package com.st_ones.evermp.IM01.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.message.service.MessageType;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM01.IM0101_Mapper;
import com.st_ones.evermp.IM03.IM0301_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "im01_Service")
public class IM0101_Service extends BaseService {
	@Autowired
	private DocNumService docNumService;
	@Autowired
	private EApprovalService approvalService;

	@Autowired
	private MessageService msg;

	@Autowired
	private IM0101_Mapper im0101Mapper;

	@Autowired
	LargeTextService largeTextService;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	private IM0301_Mapper im0301Mapper;

	// 실시간 I/F는 공통에서 관리함
	@Autowired
	private RealtimeIF_Service realtimeif_service;
	@Autowired
	private RealtimeIF_Mapper realtimeif_mapper;

	/**
	 * ****************************************************************************************************************
	 * 독점품목관리
	 *
	 * @param param
	 * @return
	 * @throws Exception
	 */

	// 지역리스트
	public List<Map<String, Object>> im01001_doSearchHeader(Map<String, String> param) throws Exception {
		return im0101Mapper.im01001_doSearchHeader(param);
	}

	// 납품지역관리조회
	public List<Map<String, Object>> im01001_doSearch(Map<String, String> formData, List<Map<String, Object>> headerG)
			throws Exception {

		Map<String, Object> newParam = new HashMap<String, Object>();
		newParam.putAll(formData);
		newParam.put("additionalColumnInfoList", headerG);
		Map<String, String> sParam = new HashMap<String, String>();
		if (!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
			sParam.put("COL_VAL", formData.get("ITEM_DESC"));
			sParam.put("COL_NM", "ISNULL(ITEM_DESC, ITEM_DESC)");
			newParam.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));

		}
		if (!EverString.nullToEmptyString(formData.get("ITEM_SPEC")).trim().equals("")) {
			sParam.put("COL_VAL", formData.get("ITEM_SPEC"));
			sParam.put("COL_NM", "ISNULL(ITEM_SPEC, ITEM_SPEC)");
			newParam.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}
		if (!EverString.nullToEmptyString(formData.get("MAKER_NM")).trim().equals("")) {
			sParam.put("COL_VAL", formData.get("MAKER_NM"));
			sParam.put("COL_NM", "MKBR.MKBR_NM");
			newParam.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		}

		if (EverString.isNotEmpty(formData.get("ITEM_CD"))) {
			newParam.put("ITEM_CD_ORG", formData.get("ITEM_CD"));
			newParam.put("ITEM_CD", EverString.forInQuery(formData.get("ITEM_CD"), ","));
			newParam.put("ITEM_CNT", formData.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return im0101Mapper.im01001_doSearch(newParam);
	}

	// 납품지역 저장
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01001_doSave(Map<String, String> param, List<Map<String, Object>> gridData) throws Exception {

		for (Map<String, Object> rowData : gridData) {

			rowData.put("APPLY_COM", rowData.get("VENDOR_CD"));
			im0101Mapper.im01001_doDeleteAll(rowData);

			List<Map<String, Object>> codeList = im0101Mapper.im01001_doSearchHeader(param);
			for (Map<String, Object> regCode : codeList) {
				rowData.put("REGION_CD", regCode.get("REGION_CD"));
				String regCd = String.valueOf(regCode.get("REGION_CD"));
				if (rowData.get("C" + regCd).equals("1")) {
					// 등록
					im0101Mapper.im01001_doSave(rowData);
				}
			}
		}
		return msg.getMessage(MessageType.SAVE_SUCCEED);
	}

	// 납품지역 일괄저장
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01002_doSave(Map<String, String> param, List<Map<String, Object>> gridData) throws Exception {

		for (Map<String, Object> rowData : gridData) {

			rowData.put("APPLY_COM", rowData.get("VENDOR_CD"));
			im0101Mapper.im01001_doDeleteAll(rowData);

			param.put("VENDOR_CD", String.valueOf(rowData.get("VENDOR_CD")));
			List<Map<String, Object>> contList = im0101Mapper.im01002_doSave_List(param);
			// 해당 공급사의 전체 리스트
			for (Map<String, Object> cont : contList) {

				List<Map<String, Object>> codeList = im0101Mapper.im01001_doSearchHeader(param);
				for (Map<String, Object> regCode : codeList) {
					cont.put("REGION_CD", String.valueOf(regCode.get("REGION_CD")));
					cont.put("VENDOR_CD", String.valueOf(rowData.get("VENDOR_CD")));
					cont.put("APPLY_COM", String.valueOf(rowData.get("VENDOR_CD")));

					String regCd = String.valueOf(regCode.get("REGION_CD"));
					if (rowData.get("C" + regCd).equals("1")) {
						// 등록
						im0101Mapper.im01001_doSave(cont);
					}
//                    else{
//                        if (im0101Mapper.doCheckINFR(cont) > 0) {
//                            //삭제(DEL_FLAG='0')
//                            im0101Mapper.im01001_doDelete(cont);
//                        }
//                    }
				}
			}

		}
		return msg.getMessage(MessageType.SAVE_SUCCEED);
	}

	/**
	 * ***************************************************************************************************************
	 * 품목현황
	 *
	 * @param formData
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> im01070_doSearch(Map<String, String> formData) {

		Map<String, String> sParam = new HashMap<String, String>();

		//if (!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
		//	sParam.put("COL_VAL", formData.get("ITEM_DESC"));
		//	sParam.put("COL_NM", "MTGL.ITEM_CD||MTGL.CUST_ITEM_CD||MTGL.ITEM_DESC||MTGL.ITEM_SPEC");
		//	formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
		//}

//        if(!EverString.nullToEmptyString(formData.get("MAKER_NM")).equals("")) {
//            sParam.put("COL_VAL", formData.get("MAKER_NM"));
//            sParam.put("COL_NM", "A.MAKER_NM");
//            formData.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
//        }
//        if(!EverString.nullToEmptyString(formData.get("BRAND_NM")).equals("")) {
//            sParam.put("COL_VAL", formData.get("BRAND_NM"));
//            sParam.put("COL_NM", "A.BRAND_NM");
//            formData.put("BRAND_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
//        }

//        if(EverString.isNotEmpty(formData.get("ITEM_CD"))) {
//            formData.put("ITEM_CD_ORG", formData.get("ITEM_CD"));
//            formData.put("ITEM_CD", EverString.forInQuery(formData.get("ITEM_CD"), ","));
//            formData.put("ITEM_CNT", formData.get("ITEM_CD").contains(",") ? "1" : "0");
//        }

		return im0101Mapper.im01070_doSearch(formData);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01070_doSave(List<Map<String, Object>> gridList) throws Exception {
		for (Map<String, Object> gridData : gridList) {
			im0101Mapper.im01070_doSave(gridData);
		}
		return msg.getMessage("0031");
	}

	/**
	 * ***************************************************************************************************************
	 * 독점현황상세
	 *
	 * @param formData
	 * @return
	 * @throws Exception
	 */
	public List<Map<String, Object>> im01071_doSearch(Map<String, String> formData) {
		return im0101Mapper.im01071_doSearch(formData);
	}

	/**
	 * ***************************************************************************************************************
	 * 일괄등록
	 *
	 * @param formData
	 * @return
	 * @throws Exception
	 */
	// 신규상품 벌크조회
	public List<Map<String, Object>> im01060_doSearch(Map<String, String> formData) {
		UserInfo baseInfo = UserInfoManager.getUserInfo();
		if (formData.get("REG_DATE_FROM") != null) {
			formData.put("REG_DATE_FROM", EverDate.getGmtFromDate(formData.get("REG_DATE_FROM"),
					baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
			formData.put("REG_DATE_TO",
					EverDate.getGmtToDate(formData.get("REG_DATE_TO"), baseInfo.getSystemGmt(), baseInfo.getUserGmt()));
		}
		List<Map<String, Object>> list = im0101Mapper.im01060_doSearch(formData);
		for (Map<String, Object> data : list) {

			if ("T".equals(data.get("STATUS"))) {
				String chkText = im0101Mapper.chkItem(data);
				if (chkText == null || "".equals(chkText)) {
					chkText = "O";
				}
				data.put("CHK_TEXT", chkText);
			} else {
				data.put("CHK_TEXT", "O");
			}
		}
		return list;
	}

	// 매입단가 벌크조회
	public List<Map<String, Object>> im01060_doSearchCT(Map<String, String> formData) {

		List<Map<String, Object>> CTlist = im0101Mapper.im01060_doSearchCT(formData);
		for (Map<String, Object> ctdata : CTlist) {
			String contRegionCd = "";
			String contRegionNm = "";
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_00")).equals("Y")) {
				contRegionCd = "00,";
				contRegionNm = "전국,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_10")).equals("Y")) {
				contRegionCd = contRegionCd + "10,";
				contRegionNm = contRegionNm + "수도권,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_20")).equals("Y")) {
				contRegionCd = contRegionCd + "20,";
				contRegionNm = contRegionNm + "충청,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_30")).equals("Y")) {
				contRegionCd = contRegionCd + "30,";
				contRegionNm = contRegionNm + "강원,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_40")).equals("Y")) {
				contRegionCd = contRegionCd + "40,";
				contRegionNm = contRegionNm + "부산/경남,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_50")).equals("Y")) {
				contRegionCd = contRegionCd + "50,";
				contRegionNm = contRegionNm + "대구/경북,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_60")).equals("Y")) {
				contRegionCd = contRegionCd + "60,";
				contRegionNm = contRegionNm + "전남,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_70")).equals("Y")) {
				contRegionCd = contRegionCd + "70,";
				contRegionNm = contRegionNm + "전북,";
			}
			if (EverString.nullToEmptyString(ctdata.get("REGION_CD_80")).equals("Y")) {
				contRegionCd = contRegionCd + "80,";
				contRegionNm = contRegionNm + "제주,";
			}
			if (!contRegionCd.equals("")) {
				ctdata.put("CONT_REGION_CD", contRegionCd.substring(0, contRegionCd.length() - 1));
				ctdata.put("CONT_REGION_NM", contRegionNm.substring(0, contRegionNm.length() - 1));
			}
		}

		return CTlist;
	}

	// 판매단가 벌크조회
	public List<Map<String, Object>> im01060_doSearchPR(Map<String, String> formData) {
		return im0101Mapper.im01060_doSearchPR(formData);
	}

	// 이미지 벌크조회
	public List<Map<String, Object>> im01060_doSearchIMG(Map<String, String> formData) {
		return im0101Mapper.im01060_doSearchIMG(formData);
	}

	// 일괄등록_신규상품
	// 저장/유효성검사----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01060_doSave(Map<String, String> formData, List<Map<String, Object>> gridList) throws Exception {

		String yinfoSignStatus = formData.get("YINFO_SIGN_STATUS");

		String appDocNum = "";
		String appDocCnt = "";

		if ("P".equals(yinfoSignStatus)) {
			appDocNum = docNumService.getDocNumber("AP");
			appDocCnt = "1";
			formData.put("APP_DOC_NUM", appDocNum);
			formData.put("APP_DOC_CNT", appDocCnt);
			formData.put("SIGN_STATUS", yinfoSignStatus);
		}

		for (Map<String, Object> gridData : gridList) {
			gridData.put("YINFO_SIGN_STATUS", formData.get("YINFO_SIGN_STATUS"));
			gridData.put("APP_DOC_NUM", appDocNum);
			gridData.put("APP_DOC_CNT", appDocCnt);
			im0101Mapper.im01060_doInsertBULK(gridData);
		}

		if ("P".equals(yinfoSignStatus)) {
			approvalService.doApprovalProcess(formData, formData.get("approvalFormData"),
					formData.get("approvalGridData"));
			return msg.getMessage("0023");
		}

		return msg.getMessage("0001");

	}

	// 일괄등록_매입단가
	// 저장/유효성검사----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01060_doSaveCT(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		for (Map<String, Object> gridData : gridList) {
			gridData.put("JOB_TYPE", "20");
			gridData.put("STATUS", "100");
			gridData.put("FAIL_RMK", "");

			Map<String, Object> vendorInfo = im0101Mapper.doGetVendorInfo(gridData); // 제조사 체크
			if (vendorInfo == null || "".equals(EverString.nullToEmptyString(vendorInfo.get("VENDOR_CD")))) {
				gridData.put("FAIL_RMK", "공급사정보 오류");
				gridData.put("STATUS", "200");
			}

			gridData.put("CUST_CD", EverString.nullToEmptyString(gridData.get("APPLY_COM")));

			String operatorCd = PropertiesManager.getString("eversrm.default.company.code");
			if (!EverString.nullToEmptyString(gridData.get("APPLY_COM")).equals(operatorCd)) {
				Map<String, Object> custInfo = im0101Mapper.doGetCustInfo(gridData); // 고객사 체크
				if (custInfo == null || "".equals(EverString.nullToEmptyString(custInfo.get("CUST_CD")))) {
					gridData.put("FAIL_RMK", "고객사정보 오류");
					gridData.put("STATUS", "200");
				}
			}

			Map<String, Object> itemInfo = im0101Mapper.doGetItemInfo(gridData); // 품목 체크
			if (itemInfo == null || "".equals(EverString.nullToEmptyString(itemInfo.get("ITEM_CD")))) {
				gridData.put("FAIL_RMK", "품목 오류");
				gridData.put("STATUS", "200");
			}

			// 납품지역체크
			String regionCd = EverString.nullToEmptyString(gridData.get("CONT_REGION_CD"));
			if (!regionCd.equals("")) {
				String[] regionCdArray = regionCd.split(",");
				for (int i = 0; i < regionCdArray.length; i++) {
					Map<String, Object> map = new HashMap<String, Object>();
					map.put("REGION_CD", regionCdArray[i]);

					if (regionCdArray[i].equals("00")) {
						gridData.put("REGION_CD_00", "Y");
					} else if (regionCdArray[i].equals("10")) {
						gridData.put("REGION_CD_10", "Y");
					} else if (regionCdArray[i].equals("20")) {
						gridData.put("REGION_CD_20", "Y");
					} else if (regionCdArray[i].equals("30")) {
						gridData.put("REGION_CD_30", "Y");
					} else if (regionCdArray[i].equals("40")) {
						gridData.put("REGION_CD_40", "Y");
					} else if (regionCdArray[i].equals("50")) {
						gridData.put("REGION_CD_50", "Y");
					} else if (regionCdArray[i].equals("60")) {
						gridData.put("REGION_CD_60", "Y");
					} else if (regionCdArray[i].equals("70")) {
						gridData.put("REGION_CD_70", "Y");
					} else if (regionCdArray[i].equals("80")) {
						gridData.put("REGION_CD_80", "Y");
					}
					Map<String, Object> regionInfo = im0101Mapper.doGetRegionInfo(map);
					if (regionInfo == null || "".equals(EverString.nullToEmptyString(regionInfo.get("CODE")))) {
						gridData.put("FAIL_RMK", "납품지역 오류");
						gridData.put("STATUS", "200");
					}
				}
			}

			// BULK 테이블에 저장
			if ("".equals(String.valueOf(gridData.get("SEQ"))) || "null".equals(String.valueOf(gridData.get("SEQ")))) {
				im0101Mapper.im01060_doInsertBULK(gridData);
			} else {
				im0101Mapper.im01060_doUpdateBULK(gridData);
			}
		}
		return msg.getMessage("0001");

	}

	// 일괄등록판매단가
	// 저장/유효성검사----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01060_doSavePR(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		for (Map<String, Object> gridData : gridList) {
			gridData.put("JOB_TYPE", "30");
			gridData.put("STATUS", "100");
			gridData.put("FAIL_RMK", "");
			gridData.put("CUR", "KRW");
			gridData.put("CUST_CD", EverString.nullToEmptyString(gridData.get("CUST_CD")));

			String operatorCd = PropertiesManager.getString("eversrm.default.company.code");
			if (!EverString.nullToEmptyString(gridData.get("APPLY_COM")).equals(operatorCd)) {
				Map<String, Object> custInfo = im0101Mapper.doGetCustInfo(gridData); // 고객사 체크
				if (custInfo == null || "".equals(EverString.nullToEmptyString(custInfo.get("CUST_CD")))) {
					gridData.put("FAIL_RMK", "고객사정보 오류");
					gridData.put("STATUS", "200");
				}
				String deptPriceFlag = EverString.nullToEmptyString(im0101Mapper.doDeptPriceFlag(gridData)); // 부서단가
																												// 사용여부
																												// 체크
				if (!deptPriceFlag.equals("Y") && (!EverString.nullToEmptyString(gridData.get("DEPT_CD")).equals("")
						&& !EverString.nullToEmptyString(gridData.get("DEPT_CD")).equals("*"))) {
					gridData.put("FAIL_RMK", "부서단가 미사용 고객사");
					gridData.put("STATUS", "200");
				}
				Map<String, Object> deptInfo = im0101Mapper.doGetDeptInfo(gridData); // 부서 체크
				if (!EverString.nullToEmptyString(gridData.get("DEPT_CD")).equals("*")
						&& !EverString.nullToEmptyString(gridData.get("DEPT_CD")).equals("")) {
					if (deptInfo == null || "".equals(EverString.nullToEmptyString(deptInfo.get("DEPT_CD")))) {
						gridData.put("FAIL_RMK", "부서정보 오류");
						gridData.put("STATUS", "200");
					}
				}
			}

			Map<String, Object> itemInfo = im0101Mapper.doGetItemInfo(gridData); // 품목 체크
			if (itemInfo == null || "".equals(EverString.nullToEmptyString(itemInfo.get("ITEM_CD")))) {
				gridData.put("FAIL_RMK", "품목 오류");
				gridData.put("STATUS", "200");
			}

			// BULK 테이블에 저장
			if ("".equals(String.valueOf(gridData.get("SEQ"))) || "null".equals(String.valueOf(gridData.get("SEQ")))) {
				im0101Mapper.im01060_doInsertBULK(gridData);
			} else {
				im0101Mapper.im01060_doUpdateBULK(gridData);
			}
		}
		return msg.getMessage("0001");
	}

	// 일괄등록이미지
	// 저장/유효성검사----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01060_doSaveIMG(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		Map<String, Object> itemInfo;
		String ITEM_CD;
		String SEQ;

		for (Map<String, Object> gridData : gridList) {

			ITEM_CD = EverString.nullToEmptyString(gridData.get("ITEM_CD"));
			SEQ = String.valueOf(gridData.get("SEQ"));

			gridData.put("JOB_TYPE", "40");
			gridData.put("STATUS", "100");
			gridData.put("FAIL_RMK", "");
			gridData.put("ITEM_CHECK", "Y");
			gridData.put("ITEM_ALL_FAIL", "");

			for (Map<String, Object> dataCheck : gridList) {
				if (null == dataCheck.get("ITEM_CHECK")
						&& ITEM_CD.equals(EverString.nullToEmptyString(dataCheck.get("ITEM_CD")))) {
					gridData.put("FAIL_RMK", "품목코드가 중복되었습니다.");
					gridData.put("STATUS", "200");
				}
			}

			if ("100".equals(gridData.get("STATUS"))) {

				itemInfo = im0101Mapper.doGetItemImgInfo(gridData); // 품목 및 이미지 체크

				if (itemInfo == null || "".equals(EverString.nullToEmptyString(itemInfo.get("ITEM_CD")))) {
					gridData.put("FAIL_RMK", "품목코드가 없습니다.");
					gridData.put("STATUS", "200");
				} else {
					if (!("".equals(SEQ) || "null".equals(SEQ))
							&& Integer.valueOf(String.valueOf(itemInfo.get("ITEM_DUP_CNT"))) > 1) {
						gridData.put("FAIL_RMK", "품목코드가 중복되었습니다.");
						gridData.put("STATUS", "200");
					} else if (("".equals(SEQ) || "null".equals(SEQ))
							&& Integer.valueOf(String.valueOf(itemInfo.get("ITEM_DUP_CNT"))) > 0) {
						gridData.put("FAIL_RMK", "품목코드가 중복되었습니다.");
						gridData.put("STATUS", "200");
						gridData.put("ITEM_ALL_FAIL", "Y");

						im0101Mapper.im01060_doUpdateBULKSTATUS(gridData);
					} else if (!"".equals(EverString.nullToEmptyString(itemInfo.get("UUID")))) {
						gridData.put("FAIL_RMK", "이미지가 이미 등록되어 있습니다.");
						gridData.put("STATUS", "200");
					} else if (!"".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_NM_DETAIL")))
							&& !"".equals(EverString.nullToEmptyString(itemInfo.get("ITEM_DETAIL_FILE_NUM")))) {
						gridData.put("FAIL_RMK", "상세이미지가 이미 등록되어 있습니다.");
						gridData.put("STATUS", "200");
					} else if (("1".equals(EverString.nullToEmptyString(gridData.get("IMG_MAIN_IMAGE_NO")))
							&& "".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_1_NM"))))
							|| ("2".equals(EverString.nullToEmptyString(gridData.get("IMG_MAIN_IMAGE_NO")))
									&& "".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_2_NM"))))
							|| ("3".equals(EverString.nullToEmptyString(gridData.get("IMG_MAIN_IMAGE_NO")))
									&& "".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_3_NM"))))
							|| ("4".equals(EverString.nullToEmptyString(gridData.get("IMG_MAIN_IMAGE_NO")))
									&& "".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_4_NM"))))
							|| ("".equals(EverString.nullToEmptyString(gridData.get("IMG_MAIN_IMAGE_NO"))))
							|| (Integer.valueOf(String.valueOf(gridData.get("IMG_MAIN_IMAGE_NO"))) > 4
									|| Integer.valueOf(String.valueOf(gridData.get("IMG_MAIN_IMAGE_NO"))) < 1)) {
						gridData.put("FAIL_RMK", "주이미지 번호가 잘못되었습니다.");
						gridData.put("STATUS", "200");
					}
				}
			}

			// BULK 테이블에 저장
			if ("".equals(SEQ) || "null".equals(SEQ)) {
				im0101Mapper.im01060_doInsertBULK(gridData);
			} else {
				im0101Mapper.im01060_doUpdateBULK(gridData);
			}
		}
		return msg.getMessage("0001");
	}

	// 벌크 삭제----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String im01060_doDelete(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		for (Map<String, Object> gridData : gridList) {
			im0101Mapper.im01060_doDelete(gridData);
		}

//        List<Map<String, Object>> list = im0101Mapper.im01060_doSearchIMG(param);
//        im01060_doSaveIMG(param, list);
		// if(1==1) throw new Exception("========================");
		return msg.getMessage("0017");
	}

	// 일괄등록_신규상품 등록----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void im01060_doRealSave(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		String itemCd = "";

		for (Map<String, Object> gridData : gridList) {

			try {

				// 상품코드 채번
				itemCd = docNumService.getDocNumber("IT");
				gridData.put("ITEM_CD", itemCd);
				gridData.put("PROGRESS_CD", "E");
				String itemDetailTextNum = largeTextService.saveLargeText(
						EverString.nullToEmptyString(gridData.get("ITEM_DETAIL_TEXT_NUM")),
						EverString.nullToEmptyString(gridData.get("TEXT_CONTENTS")));
				gridData.put("ITEM_DETAIL_TEXT_NUM", itemDetailTextNum);

				// 상품정보등록
				im0101Mapper.im01001_MTGL_Insert(gridData);

				// 품목분류매핑저장
				im0301Mapper.im03008_doSaveMTGC(gridData); // 분류맵핑

				// 품목속성저장
				// -------------------------------------------------------------------------------------
				// 입력된 품목속성1~15까지 값이 있으면 저장.
				Map<String, Object> tmpMap = new HashMap<String, Object>();

				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD0")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD0")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE0")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD1")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD1")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE1")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD2")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD2")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE2")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD3")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD3")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE3")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD4")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD4")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE4")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD5")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD5")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE5")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD6")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD6")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE6")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD7")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD7")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE7")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD8")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD8")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE8")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD9")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD9")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE9")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD10")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD10")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE10")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD11")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD11")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE11")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD12")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD12")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE12")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD13")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD13")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE13")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}
				if (!EverString.nullToEmptyString(gridData.get("ATTR_CD14")).equals("")) {
					tmpMap.put("ATTR_CD", EverString.nullToEmptyString(gridData.get("ATTR_CD14")));
					tmpMap.put("ATTR_VALUE", EverString.nullToEmptyString(gridData.get("ATTR_VALUE14")));
					tmpMap.put("ITEM_CD", gridData.get("ITEM_CD"));
					tmpMap.put("ITEM_CLS1", gridData.get("ITEM_CLS1"));
					tmpMap.put("ITEM_CLS2", gridData.get("ITEM_CLS2"));
					tmpMap.put("ITEM_CLS3", gridData.get("ITEM_CLS3"));
					tmpMap.put("ITEM_CLS4", gridData.get("ITEM_CLS4"));
					tmpMap.put("ATTR_TYPE", "ITEM");
					im0301Mapper.im03009_doSaveMTAT(tmpMap);
					tmpMap.clear();
				}

				// BULK 삭제
				im0101Mapper.im01060_doDelete(gridData);

			} catch (Exception e) {

				// 오류나면 STOCBULK 테이블 status 업데이트
				// 등록되었던 데이터들삭제
				gridData.put("STATUS", "300");
				im0101Mapper.im01060_doUpdateBULKSTATUS(gridData);

				im0101Mapper.RETURN_deleteMTGL(gridData); // 품목삭제
				im0101Mapper.RETURN_deleteMTGC(gridData); // 품목=분류매핑삭제
				im0101Mapper.RETURN_deleteMTAT(gridData); // 품목-품목속성삭제

				e.printStackTrace();
			} finally {
				gridData.clear();
			}
		}
	}

	// 일괄등록_매입단가 등록----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void im01060_doRealSaveCT(Map<String, String> param, List<Map<String, Object>> gridList) {

		for (Map<String, Object> gridData : gridList) {

			String contNo = "";
			String contSeq = "";

			try {
				// GATE_CD, ITEM_CD 로 CONT_NO 가져오기
				contNo = EverString.nullToEmptyString(im0101Mapper.returnYinfoContNo(gridData));
				if (contNo.equals("")) {
					// 없으면 계약번호생성
					contNo = docNumService.getDocNumber("CT");
				}
				gridData.put("CONT_NO", contNo);
				gridData.put("CONT_TYPE_CD", "BK");
				gridData.put("SIGN_STATUS", "E");
				gridData.put("SIGN_DATE", EverDate.getDate());

				contSeq = im0101Mapper.returnYinfoContSeq(gridData); // 계약seq
				gridData.put("CONT_SEQ", contSeq);

				// 계약(운영사매입계약단가)
				im0301Mapper.im03009_doSave_YINFO(gridData);

				// 운영사 매입단가_지역정보_등록
				String regionCd = EverString.nullToEmptyString(gridData.get("CONT_REGION_CD"));
				if (!regionCd.equals("")) {
					String[] regionCdArray = regionCd.split(",");
					for (int i = 0; i < regionCdArray.length; i++) {
						Map<String, Object> map = new HashMap<String, Object>();
						map.put("CONT_NO", contNo);
						map.put("CONT_SEQ", contSeq);
						map.put("APPLY_COM", gridData.get("APPLY_COM"));
						map.put("VENDOR_CD", gridData.get("VENDOR_CD"));
						map.put("REGION_CD", regionCdArray[i]);
						im0301Mapper.im03009_doSave_YINFR(map);
					}
				}

				// 해당 계약번호와 동일하고 유효한 내용의 CONT_SEQ의 내용 가지고오기.
				Map<String, String> changeContract = im0101Mapper.changeYINFOInfo(gridData);

				if (changeContract != null) {

					gridData.putAll(changeContract);
					gridData.put("CONT_TYPE_CD", "BK");

					// 변경대상 계약의 계약만료일 업데이트
					im0101Mapper.im01060_doUpdateYINFOBeforeDate(gridData);

					// 변경대상 계약이력 저장
					gridData.put("CHANGE_REASON", "일괄등록시 동일계약정보 존재로 이전데이터 만료처리");
					im0101Mapper.im01060_doSave_YINFH_FROMDATE(gridData);
				} else {
					// 신규등록건에 대한 계약이력저장
					im0301Mapper.im03009_doSave_YINFH(gridData);
				}

				// BULK 삭제
				im0101Mapper.im01060_doDelete(gridData);

			} catch (Exception e) {

				// 오류나면 STOCBULK 테이블 status 업데이트
				// 등록되었던 데이터들삭제
				gridData.put("STATUS", "300");
				im0101Mapper.im01060_doUpdateBULKSTATUS(gridData);

				gridData.put("CONT_NO", contNo);
				gridData.put("CONT_SEQ", contSeq);

				im0101Mapper.RETURN_deleteYINFO(gridData);
				im0101Mapper.RETURN_deleteYINFR(gridData);
				im0101Mapper.RETURN_deleteYINFH(gridData);

				e.printStackTrace();
			}
		}
	}

	// 일괄등록_판매단가 등록----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void im01060_doRealSavePR(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		for (Map<String, Object> gridData : gridList) {

			try {

				gridData.put("CONT_TYPE_CD", "BK");
				gridData.put("SIGN_STATUS", "E");
				gridData.put("SIGN_DATE", EverDate.getDate());

				// 고객사-단가저장
				im0301Mapper.im03009_doSave_UINFO(gridData);

				// 단가정보 이력
				im0301Mapper.im03009_doSave_UINFH(gridData);

				// BULK 삭제
				im0101Mapper.im01060_doDelete(gridData);

			} catch (Exception e) {

				// 오류나면 STOCBULK 테이블 status 업데이트
				// 등록되었던 데이터들삭제
				gridData.put("STATUS", "300");
				im0101Mapper.im01060_doUpdateBULKSTATUS(gridData);

				im0101Mapper.RETURN_deleteUINFO(gridData);
				im0101Mapper.RETURN_deleteUINFH(gridData);

				e.printStackTrace();
			}
		}
	}

	// 일괄등록_이미지 등록----------------------------------------------------------------
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void im01060_doRealSaveIMG(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

		String FILE_NM;
		String[] arr_FILE_NM;
		String FILE_PATH = PropertiesManager.getString("everf.imageUpload.path");

		FILE_PATH = FILE_PATH + EverDate.getYear() + "/" + EverDate.getYear() + EverDate.getMonth();

		for (Map<String, Object> gridData : gridList) {

			try {

				gridData.put("JOB_TYPE", "40");
				gridData.put("UUID", gridData.get("ITEM_CD"));

				if (!"".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_1_NM")))) {
					gridData.put("UUID_SQ", "1");

					if ("1".equals(gridData.get("IMG_MAIN_IMAGE_NO"))) {
						gridData.put("MAIN_IMAGE_FLAG", "1");
					} else {
						gridData.put("MAIN_IMAGE_FLAG", "0");
					}

					im0101Mapper.im01060_doSaveMTIM(gridData);

					FILE_NM = String.valueOf(gridData.get("IMG_REAL_FILE_1_NM"));
					arr_FILE_NM = FILE_NM.split("\\.");

					gridData.put("FILE_NM", arr_FILE_NM[0]);
					gridData.put("FILE_PATH", FILE_PATH);
					gridData.put("FILE_SIZE", "0");
					gridData.put("FILE_EXTENSION", arr_FILE_NM[1]);
					gridData.put("REAL_FILE_NM", gridData.get("IMG_REAL_FILE_1_NM"));
					gridData.put("BIZ_TYPE", "IMG");
					gridData.put("FILE_SQ", "0");

					im0101Mapper.im01060_doSaveATCH(gridData);
				}

				if (!"".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_2_NM")))) {
					gridData.put("UUID_SQ", "2");

					if ("2".equals(gridData.get("IMG_MAIN_IMAGE_NO"))) {
						gridData.put("MAIN_IMAGE_FLAG", "1");
					} else {
						gridData.put("MAIN_IMAGE_FLAG", "0");
					}

					im0101Mapper.im01060_doSaveMTIM(gridData);

					FILE_NM = String.valueOf(gridData.get("IMG_REAL_FILE_2_NM"));
					arr_FILE_NM = FILE_NM.split("\\.");

					gridData.put("FILE_NM", arr_FILE_NM[0]);
					gridData.put("FILE_PATH", FILE_PATH);
					gridData.put("FILE_SIZE", "0");
					gridData.put("FILE_EXTENSION", arr_FILE_NM[1]);
					gridData.put("REAL_FILE_NM", gridData.get("IMG_REAL_FILE_2_NM"));
					gridData.put("BIZ_TYPE", "IMG");
					gridData.put("FILE_SQ", "1");

					im0101Mapper.im01060_doSaveATCH(gridData);
				}

				if (!"".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_3_NM")))) {
					gridData.put("UUID_SQ", "3");

					if ("3".equals(gridData.get("IMG_MAIN_IMAGE_NO"))) {
						gridData.put("MAIN_IMAGE_FLAG", "1");
					} else {
						gridData.put("MAIN_IMAGE_FLAG", "0");
					}

					im0101Mapper.im01060_doSaveMTIM(gridData);

					FILE_NM = String.valueOf(gridData.get("IMG_REAL_FILE_3_NM"));
					arr_FILE_NM = FILE_NM.split("\\.");

					gridData.put("FILE_NM", arr_FILE_NM[0]);
					gridData.put("FILE_PATH", FILE_PATH);
					gridData.put("FILE_SIZE", "0");
					gridData.put("FILE_EXTENSION", arr_FILE_NM[1]);
					gridData.put("REAL_FILE_NM", gridData.get("IMG_REAL_FILE_3_NM"));
					gridData.put("BIZ_TYPE", "IMG");
					gridData.put("FILE_SQ", "2");

					im0101Mapper.im01060_doSaveATCH(gridData);
				}

				if (!"".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_4_NM")))) {
					gridData.put("UUID_SQ", "4");

					if ("4".equals(gridData.get("IMG_MAIN_IMAGE_NO"))) {
						gridData.put("MAIN_IMAGE_FLAG", "1");
					} else {
						gridData.put("MAIN_IMAGE_FLAG", "0");
					}

					im0101Mapper.im01060_doSaveMTIM(gridData);

					FILE_NM = String.valueOf(gridData.get("IMG_REAL_FILE_4_NM"));
					arr_FILE_NM = FILE_NM.split("\\.");

					gridData.put("FILE_NM", arr_FILE_NM[0]);
					gridData.put("FILE_PATH", FILE_PATH);
					gridData.put("FILE_SIZE", "0");
					gridData.put("FILE_EXTENSION", arr_FILE_NM[1]);
					gridData.put("REAL_FILE_NM", gridData.get("IMG_REAL_FILE_4_NM"));
					gridData.put("BIZ_TYPE", "IMG");
					gridData.put("FILE_SQ", "3");

					im0101Mapper.im01060_doSaveATCH(gridData);
				}

				if (!"".equals(EverString.nullToEmptyString(gridData.get("IMG_REAL_FILE_NM_DETAIL")))) {
					FILE_NM = String.valueOf(gridData.get("IMG_REAL_FILE_NM_DETAIL"));
					arr_FILE_NM = FILE_NM.split("\\.");

					gridData.put("UUID", gridData.get("ITEM_CD") + "D");
					gridData.put("UUID_SQ", "1");
					gridData.put("FILE_NM", arr_FILE_NM[0]);
					gridData.put("FILE_PATH", FILE_PATH);
					gridData.put("FILE_SIZE", "0");
					gridData.put("FILE_EXTENSION", arr_FILE_NM[1]);
					gridData.put("REAL_FILE_NM", gridData.get("IMG_REAL_FILE_NM_DETAIL"));
					gridData.put("BIZ_TYPE", "IMG");
					gridData.put("FILE_SQ", "0");

					im0101Mapper.im01060_doSaveATCH(gridData);

					gridData.put("ITEM_DETAIL_FILE_NUM", gridData.get("UUID"));

					im0101Mapper.im01060_doUpdateMTGL(gridData);
				}

				im0101Mapper.im01060_doDelete(gridData);

			} catch (Exception e) {

				// 오류나면 STOCBULK 테이블 status 업데이트
				// 등록되었던 데이터들삭제
				gridData.put("STATUS", "300");
				im0101Mapper.im01060_doUpdateBULKSTATUS(gridData);

				im0101Mapper.RETURN_deleteMTIM(gridData);

				gridData.put("UUID", gridData.get("ITEM_CD"));
				im0101Mapper.RETURN_deleteATCH(gridData);

				gridData.put("UUID", gridData.get("ITEM_CD") + "D");
				im0101Mapper.RETURN_deleteATCH(gridData);

				gridData.put("ITEM_DETAIL_FILE_NUM", "");
				gridData.put("ITEM_DETAIL_URL", "");
				im0101Mapper.im01060_doUpdateMTGL(gridData);

				e.printStackTrace();
			}
		}
	}

	/**
	 * 상품관리 > 계약단가관리 > 상품단가 일괄등록 (IM01_060) : 결재승인
	 *
	 * @param docNum
	 * @param docCnt
	 * @param signStatus
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String endApproval(String docNum, String docCnt, String signStatus) throws Exception {

		Map<String, String> formDataM = new HashMap<String, String>();
		formDataM.put("APP_DOC_NUM", docNum);
		formDataM.put("APP_DOC_CNT", docCnt);
		formDataM.put("SIGN_STATUS", signStatus);

		// 1. 엑셀파일 일괄업로드(STOCBULK) 테이블의 SIGN_STATUS 처리
		if (signStatus.equals("E") || signStatus.equals("R") || signStatus.equals("C")) {
			im0101Mapper.updateSignStatus(formDataM);
		}

		if (signStatus.equals("E")) {
			// 엑셀파일 일괄업로드(STOCBULK) 데이터 가져오기
			List<Map> bulkList = im0101Mapper.getAppTargetBulkList(formDataM);
			for (Map formData : bulkList) {

				// 품목생성
				Map<String, Object> ObjData = new HashMap<String, Object>();
				String itemCd = EverString.nullToEmptyString(formData.get("ITEM_CD"));
				formData.put("PROGRESS_CD", signStatus); // 임시저장 : T, 등록/수정 : E

				// 신규등록일경우 상품코드 번호채번, 품목 등록 | 수정
				if( EverString.isEmpty(itemCd) ) {
					itemCd = docNumService.getDocNumber("IT");
					formData.put("ITEM_CD", itemCd);

					// ====================== DGNS I/F ========================================
					if( formData.get("ITEM_CLS3_CUST") != null && !"".equals(formData.get("ITEM_CLS3_CUST")) && !"*".equals(formData.get("ITEM_CLS3_CUST")) ) {
						// 구매사 품목코드 채번
						Map<String, String> dgnsData = realtimeif_mapper.getDgnsItemCd(formData);
						formData.put("DGNS_ITEM_ID", dgnsData.get("DGNS_ITEM_ID"));
						formData.put("MK_NM", dgnsData.get("MK_NM"));
						formData.put("DGNS_ITEM_CD", realtimeif_mapper.getDgnsItemCd2(formData));

						if( formData.get("DGNS_ITEM_CD") != null && !"".equals(formData.get("DGNS_ITEM_CD")) ) {
							realtimeif_service.insPuaMtrlCd(formData); 	 // DGNS 품목등록

							im0301Mapper.im03008_copyCustMTGC(formData); // 고객사 분류맵핑 (erp_if_flag=1인 전체 고객사 : 7개)
							im0301Mapper.im03008_copyCustMTGB(formData); // 고객사 품번맵핑 (erp_if_flag=1인 전체 고객사 : 7개)
						}
					}
					// ====================== DGNS I/F ========================================

					im0301Mapper.im03009_MTGL_Insert(formData);
				}

				// 품목분류매핑저장
				ObjData.putAll(formData);
				im0301Mapper.im03008_doSaveMTGC(ObjData); 	// 운영사 분류맵핑
		        im0301Mapper.copyMtglHist(formData);		// 품목 History 등록

		        // 계약정보저장
				// -----------------------------------------------------------------------------------
				String plantCd = EverString.nullToEmptyString(formData.get("PLANT_CD"));

				formData.put("APPLY_COM", EverString.nullToEmptyString(formData.get("CUST_CD")));
				formData.put("CONT_NO", docNumService.getDocNumber("CT"));
				formData.put("CONT_SEQ", "1");
				formData.put("PLANT_CD", (EverString.isEmpty(plantCd) || "ALL".equals(plantCd)) ? "*" : plantCd);
				formData.put("ITEM_CD", itemCd);
				formData.put("CONT_TYPE_CD", "MN");
				formData.put("TAX_CD", EverString.nullToEmptyString(formData.get("VAT_CD")));
				formData.put("SG_CTRL_USER_ID", EverString.nullToEmptyString(formData.get("SG_CTRL_USER_ID")));
				formData.put("CMS_CTRL_USER_ID", EverString.nullToEmptyString(formData.get("CMS_CTRL_USER_ID")));
				formData.put("APP_DOC_NUM", docNum);
				formData.put("APP_DOC_CNT", docCnt);
				formData.put("SIGN_STATUS", "E");

				im0301Mapper.im03009_doSave_YINFH(formData);
				im0301Mapper.im03009_doSave_UINFH(formData);
			}

			// 결재 완료 처리
			im0301Mapper.updateSignYInfh(formDataM);

			// 매입단가 등록
			List<Map<String, Object>> yinfhList = im0301Mapper.getTargetYInfhList(formDataM);
			for (Map<String, Object> data : yinfhList) {

				im0301Mapper.copyYInfhToYInfo(data);

				// ====================== DGNS I/F ========================================
				// DGNS 단가정보 등록
				if ("1".equals(EverString.nullToEmptyString(data.get("ERP_IF_FLAG"))) && !"".equals(EverString.nullToEmptyString(data.get("CUST_ITEM_CD")))) {
					// 매입단가가 유효한 경우에만 단가 i/f
					if (data.get("UNIT_IF_FLAG") != null && "1".equals(data.get("UNIT_IF_FLAG"))) {
						BigDecimal SALES_UNIT_PRC =(BigDecimal) data.get("SALES_UNIT_PRC");
        				SALES_UNIT_PRC = SALES_UNIT_PRC ==null ? BigDecimal.ZERO : SALES_UNIT_PRC;
						Map<String, String> dgnsInfo = new HashMap<>();
						dgnsInfo.put("CUST_ITEM_CD", EverString.nullToEmptyString(data.get("CUST_ITEM_CD"))); // 고객사
																												// 품목코드
						dgnsInfo.put("COMPANY_CODE", EverString.nullToEmptyString(data.get("APPLY_COM"))); // 고객사코드
						dgnsInfo.put("DIVISION_CODE", EverString.nullToEmptyString(data.get("APPLY_PLANT"))); // 단가적용
																												// 사업장코드
						dgnsInfo.put("UNIT_PRICE", String.valueOf(SALES_UNIT_PRC)); // 판매단가
						realtimeif_service.insCustUinfo(dgnsInfo);

						// 판매단가 DGNS I/F 여부 세팅
						im0301Mapper.updateDgnsIfFlag(data);
					}
				}
				// ====================== DGNS I/F ========================================
			}

			// 매출단가 등록
			im0301Mapper.updateSignUInfh(formDataM);
			im0301Mapper.copyUInfhToUInfo(formDataM);
		}

		return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
	}

	/**
	 * 상품관리 > 계약단가관리 > 상품단가 일괄등록 (IM01_060) : 엑셀 업로드
	 *
	 * @param gridDatas
	 * @return
	 */
	public List<Map<String, Object>> doSetExcelImportItem(List<Map<String, Object>> gridDatas) {

		UserInfo userInfo = UserInfoManager.getUserInfo();

		List<Map<String, Object>> rtnGrid = new ArrayList<>();
		for (Map<String, Object> grid : gridDatas) {

			// 품목코드가 존재하는 경우 품목 기본정보 가져오기
			Map<String, Object> item = new HashMap<String, Object>();
			if (grid.get("ITEM_CD") != null && !"".equals(grid.get("ITEM_CD"))) {
				item = im0301Mapper.doSetExcelImportItemInfo(grid);
				if (item == null || item.size() < 1) {
					item.put("ITEM_CD", "");
					item.put("ITEM_CLS_NM",
							grid.get("ITEM_CLS1")
									+ (EverString.nullToEmptyString(grid.get("ITEM_CLS2")) != "" ? " > " : "")
									+ grid.get("ITEM_CLS2")
									+ (EverString.nullToEmptyString(grid.get("ITEM_CLS3")) != "" ? " > " : "")
									+ grid.get("ITEM_CLS3")
									+ (EverString.nullToEmptyString(grid.get("ITEM_CLS4")) != "" ? " > " : "")
									+ grid.get("ITEM_CLS4"));
					item.put("ITEM_CLS_NM_CUST",
							EverString.nullToEmptyString(grid.get("ITEM_CLS1_CUST"))
									+ (EverString.nullToEmptyString(grid.get("ITEM_CLS2_CUST")) != "" ? " > " : "")
									+ EverString.nullToEmptyString(grid.get("ITEM_CLS2_CUST"))
									+ (EverString.nullToEmptyString(grid.get("ITEM_CLS3_CUST")) != "" ? " > " : "")
									+ EverString.nullToEmptyString(grid.get("ITEM_CLS3_CUST"))
									+ (EverString.nullToEmptyString(grid.get("ITEM_CLS4_CUST")) != "" ? " > " : "")
									+ EverString.nullToEmptyString(grid.get("ITEM_CLS4_CUST")));
				}
			} else {
				item.put("ITEM_CLS_NM",
						grid.get("ITEM_CLS1") + (EverString.nullToEmptyString(grid.get("ITEM_CLS2")) != "" ? " > " : "")
								+ grid.get("ITEM_CLS2")
								+ (EverString.nullToEmptyString(grid.get("ITEM_CLS3")) != "" ? " > " : "")
								+ grid.get("ITEM_CLS3")
								+ (EverString.nullToEmptyString(grid.get("ITEM_CLS4")) != "" ? " > " : "")
								+ grid.get("ITEM_CLS4"));
				item.put("ITEM_CLS_NM_CUST",
						EverString.nullToEmptyString(grid.get("ITEM_CLS1_CUST"))
								+ (EverString.nullToEmptyString(grid.get("ITEM_CLS2_CUST")) != "" ? " > " : "")
								+ EverString.nullToEmptyString(grid.get("ITEM_CLS2_CUST"))
								+ (EverString.nullToEmptyString(grid.get("ITEM_CLS3_CUST")) != "" ? " > " : "")
								+ EverString.nullToEmptyString(grid.get("ITEM_CLS3_CUST"))
								+ (EverString.nullToEmptyString(grid.get("ITEM_CLS4_CUST")) != "" ? " > " : "")
								+ EverString.nullToEmptyString(grid.get("ITEM_CLS4_CUST")));
			}
			grid.putAll(item);

			rtnGrid.add(grid);
		}

		return rtnGrid;
	}

}