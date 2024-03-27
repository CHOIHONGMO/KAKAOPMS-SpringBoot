package com.st_ones.evermp.SMY1.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 8. 29 오후 3:12
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS03.BS0301_Mapper;
import com.st_ones.evermp.SMY1.SMY101_Mapper;
import com.st_ones.eversrm.master.user.BADU_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "smy101_Service")
public class SMY101_Service extends BaseService {

	@Autowired SMY101_Mapper smy101_Mapper;

	@Autowired
	private MessageService msg;

	@Autowired LargeTextService largeTextService;

	@Autowired private DocNumService docNumService;

	@Autowired
	private BADU_Mapper baduMapper;

	@Autowired
	private BS0301_Mapper bs0301Mapper;

	/** ******************************************************************************************
     * 협력사 납품게시판
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> smy1030_doSearch(Map<String, String> param) throws Exception {
		return smy101_Mapper.smy1030_doSearch(param);
	}
	
	//공급사 사용자 등록 / 수정
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String smy1051_doSave(Map<String, String> paramData) throws Exception {

		Map<String, Object> formData = new HashMap<String, Object>();
		formData.putAll(paramData);
		formData.put("VENDOR_CD",formData.get("COMPANY_CD"));
		formData.put("USER_EMAIL",formData.get("EMAIL"));
		formData.put("HQ_ZIP_CD",formData.get("ZIP_CD"));
		formData.put("HQ_ADDR_1",formData.get("ADDR_1"));
		formData.put("HQ_ADDR_2",formData.get("ADDR_2"));

		//해당 회사코드에 관리자여부가 있으면 중복체크 >> 관리자 N명
//		String mngYn = EverString.nullToEmptyString(formData.get("MNG_YN"));
//		int checkmngId = 0;
//		if(mngYn.equals("1")) {
//			Map<String, String> params2 = new HashMap<String, String>();
//			params2.put("COMPANY_CD",EverString.nullToEmptyString(formData.get("COMPANY_CD")));
//			params2.put("USER_ID",EverString.nullToEmptyString(formData.get("USER_ID")));
//			checkmngId = baduMapper.existsMYNUser_VNGL(params2);
//			if (checkmngId > 0) {
//				throw new NoResultException(msg.getMessage("0173"));
//			}
//		}

		formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(String.valueOf(formData.get("PASSWORD"))));

		String oriUserId = EverString.nullToEmptyString(formData.get("ORI_USER_ID"));
		//신규등록일경우 id 중복체크
		if(oriUserId.equals("")) {
			int checkCnt = baduMapper.existsUserInformation_VNGL(paramData);
			if (checkCnt > 0) {
				throw new NoResultException(msg.getMessage("0155"));
			}

			//사용자처음등록시 프로파일 등록
			formData.put("AUTH_CD","PF0132");
			bs0301Mapper.bs03002_doInsertUser_USAP(formData);
		}
		formData.put("USER_PROGRESS_CD","E");
		bs0301Mapper.bs03002_doMergeUser_CVUR(formData);

		return msg.getMessage("0031");
	}


	//공급사 회사수정
	// 공급회사 저장
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public Map<String, String> smy1060_doSave(Map<String, String> paramData, List<Map<String, Object>> grid1Datas, List<Map<String, Object>> gridTxDatas, List<Map<String, Object>> gridVncp) throws Exception {


		Map<String, Object> formData = new HashMap<String, Object>();
		formData.putAll(paramData);
		Map<String, String> rtnMap = new HashMap<String, String>();
		String vendorCd = EverString.nullToEmptyString(formData.get("VENDOR_CD"));

		// 공급회사 등록/수정---------------------------------------------------------------------------------------------------------------------------------------------
		if (formData.get("EMPLOYEE_CNT").equals("")) {
			formData.put("EMPLOYEE_CNT", null);
		} else {
			formData.put("EMPLOYEE_CNT", Double.parseDouble((String) formData.get("EMPLOYEE_CNT")));
		}
		bs0301Mapper.bs03002_doMergeVendor(formData);


		// 공급사 납품가능지역(checkBox) 저장-----------------------------------------------------------------------------------------------------------------------------
		String regionCd = EverString.nullToEmptyString(formData.get("REGION_CD"));
		// 삭제 후 저장
		formData.put("TABLE", "STOCVNRG");
		bs0301Mapper.bs03002_doDeleteVN(formData);
		if (!regionCd.equals("")) {
			String[] regionCdArray = regionCd.split(",");
			for (int i = 0; i < regionCdArray.length; i++) {
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("VENDOR_CD", vendorCd);
				map.put("REGION_CD", regionCdArray[i]);
				bs0301Mapper.bs03002_doMergeVNRG(map);
			}
		}

		//취급분야(S/G)------------------------------------------------------------------------------------------------------------------------------------------------
		for (Map<String, Object> sgList : grid1Datas) {

			sgList.put("VENDOR_CD", vendorCd);
			bs0301Mapper.bs03002_doMergeSGVN(sgList);
		}

		//재무사항 VNFI(1건) : DELETE 후 INSERT-------------------------------------------------------------------------------------------------------------------------
		//bs0301Mapper.bs03002_doDeleteVNFI(formData);
		//bs0301Mapper.bs03002_doInsertVNFI(formData);


		//사용자(관리자)(1건) 저장---------------------------------------------------------------------------------------------------------------------------------------
		formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(String.valueOf(formData.get("PASSWORD"))));
		formData.put("MNG_YN", "1"); // 관리자.
		bs0301Mapper.bs03002_doMergeUser_CVUR(formData);

		//계산서담당자------------------------------------------------------------------------------------------------------------------------------------------------
		for (Map<String, Object> txList : gridTxDatas) {

			txList.put("VENDOR_CD", vendorCd);
			bs0301Mapper.bs03002_doMergeTX(txList);
		}

		// 영업담당자
		bs0301Mapper.bs03002_doDelVNCP(formData);
		for (Map<String, Object> vncp : gridVncp) {
			vncp.put("VENDOR_CD", vendorCd);
			bs0301Mapper.bs03002_doMergeVNCP(vncp);
		}

		//최초등록 or 회사주소, 대표자 변경시 이력테이블에저장-------------------------------------------------------------------------------------------------------------
		String chReason = EverString.nullToEmptyString(formData.get("CH_REASON"));
		if (!chReason.equals("")) {
			bs0301Mapper.bs03002_doInsert_VNGH(formData);
		}


		rtnMap.put("VENDOR_CD", vendorCd);
		rtnMap.put("rtnMsg", msg.getMessage("0016"));
		return rtnMap;
	}

}
