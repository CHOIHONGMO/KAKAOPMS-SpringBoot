package com.st_ones.batch.gwApprovalIf;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 10. 12 오전 9:18
 */
@Repository
public interface GwApprovalIF_Mapper {

	// 입찰시행품의 공급사 목록 가져오기
	List<Map<String, String>> getBidSmsSELECT(Map<String, String> param);

	// 입찰시행품의 품목 목록 가져오기
	List<Map<String, String>> getRfxItemList(Map<String, String> param);

	// 발주대상 목록 가져오기
	List<Map<String, Object>> getPoTargetList(Map<String, String> param);

	// 임시품목코드 생성 (시행구매 : 품목코드가 없는 경우)
	void createMtgl(Map<String, Object> param);
	void createMtgc(Map<String, Object> param);

	// 공급사 발주서 생성
	void createPohd(Map<String, Object> param);
	void createPodt(Map<String, Object> param);

	// 물류센터 납입지시 생성
	void createDohd(Map<String, Object> param);
	void createDodt(Map<String, Object> param);

	// 단가대상 목록 가져오기
	List<Map<String, Object>> getInfoTargetList();

	// 기존 유효한 단가 만료로직 추가
	void updateValidTodateYInfo(Map<String, Object> param);

	// 매입 및 매출단가 생성
	void createStoYInfo(Map<String, Object> param);
	void createStoUInfo(Map<String, Object> param);

	void createStoYInfh(Map<String, Object> param);
	void createStoUInfh(Map<String, Object> param);

	// 결과값 UPDATE
	void doUpdateContInfoCNDT(Map<String, Object> data);
	void doReqConfirmUpo(Map<String, Object> data);
	void doUpdateGwApprovalResult(Map<String, Object> param);

	// 고객사 판가정보 DGNS I/F
	String getCustErpIfFlag(Map<String, Object> param);
    //고객사 단가 등록리스트
	List<Map<String, Object>> getInfoTargetCnvd(Map<String, Object> data);
    //발주생성리스트
	List<Map<String, Object>> getPoTargetCnvd(Map<String, Object> dataInfo);
}