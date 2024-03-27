package com.st_ones.evermp.RQ01;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */

@Repository
public interface RQ0102_Mapper {

	/** *****************
     * 견적비교
     * ******************/
	List<Map<String, Object>> rq01020_doSearchT(Map<String, Object> param);

	List<Map<String, Object>> rq01020_doSearchB(Map<String, String> param);

	void doClosingHD(Map<String, Object> gridData);

	void doClosingDT(Map<String, Object> gridData);

	void doDeleteRFQ(Map<String, Object> gridData);

	void doFailRFQ(Map<String, Object> gridData);

	void doReturnItem(Map<String, Object> gridData);

	void doSettleToRQHD(Map<String, String> param);

	void doRollbackToRQDT(Map<String, String> param);

	void doSettleToRQDT(Map<String, Object> gridData);

	void doRollbackToQTDT(Map<String, String> param);

	void doSettleToQTDT(Map<String, Object> gridData);

	List<Map<String, String>> rq01020_doSearchOzCustList(Map<String, String> param);

	String rq01020_getRfqNumCntSq(Map<String, String> param);

	/** *****************
	 * 마감일변경
	 * ******************/
	Map<String, String> getCloseDate(Map<String, String> param);

	String checkProgressCd(Map<String, String> param);

	void doChangeDeadLine(Map<String, String> param);

	/** *****************
	 * 견적서 입력 (운영사)
	 * ******************/
	List<Map<String, Object>> rq01022_doSearch(Map<String, String> param);

	/** *****************
	 * 계약품의
	 * ******************/
	Map<String, String> rq01023_getFormDataRFQ(Map<String, String> param);

	Map<String, String> rq01023_getFormDataNEO(Map<String, String> param);

	Map<String, String> rq01023_getFormDataCN(Map<String, String> param);

	List<Map<String, Object>> rq01023_doSearchGridR(Map<String, String> param);

	List<Map<String, Object>> rq01023_doSearchGridRNeo(Map<String, String> param);

	List<Map<String, Object>> rq01023_doSearchGridRCN(Map<String, String> param);

	List<Map<String, Object>> rq01023_doSearchGridC(Map<String, String> param);

	List<Map<String, Object>> rq01023_doSearchGridV(Map<String, String> param);

	List<Map<String, Object>> rq01023_doSearchGridCU(Map<String, String> param);

	String rq01023_checkCnSignStatus(Map<String, Object> formData);

	void rq01023_doMergeCNHD(Map<String, Object> formData);

	void rq01023_doDeleteCNDT(Map<String, Object> formData);

	void rq01023_doInsertCNDT(Map<String, Object> gridData);

	void rq01023_doUpdateProgressCdRQDT(Map<String, Object> gridData);

	String rq01023_getRqhdProgressCd(Map<String, String> formData);

	void rq01023_doUpdateProgressCdRQHD(Map<String, String> formData);

	void updateSignStatus(Map<String, String> param);

	List<Map<String, Object>> getCnInfos(Map<String, Object> param);

	String getRollbackProgressCd(Map<String, Object> param);

	void doUpdateDelFlagCN(Map<String, Object> param);

	void doRollbackRQHD(Map<String, Object> param);

	void doRollbackRQDT(Map<String, Object> param);

	void doRollbackQTDT(Map<String, Object> param);

	/** *****************
	 * 견적비교표
	 * ******************/
	Map<String, String> rq01024_getFormData(Map<String, String> param);

	List<Map<String, Object>> rq01024_getRfqCnts(Map<String, String> param);

	List<Map<String, Object>> rq01024_doSearch(Map<String, String> param);

	/** *****************
	 * 대상공급사
	 * ******************/
	List<Map<String, Object>> rq01025_doSearch(Map<String, String> param);

	/** *****************
	 * 품의현황
	 * ******************/
	List<Map<String, Object>> rq01026_doSearch(Map<String, String> param);

	List<Map<String, Object>> rq01026_doSearchD(Map<String, String> param);

	/** *****************
	 * CMS 맵핑
	 * ******************/
	List<Map<String, Object>> rq01030_doSearch(Map<String, String> param);

	// 신규상품 요청상태 변경 : 560(상품등록완료)
	void doUpdateProgressCdNWRQ(Map<String, Object> param);

	// 품목마스터 "승인(E), 사용(10)"으로 변경
	void doUpdateProgressCdMTGL(Map<String, Object> param);

	/** *****************
	 * 결재
	 * ******************/
	List<Map<String, Object>> getCnInfo(Map<String, String> param);

	void updateStatusCN(Map<String, String> param);

	void updateStatusRQDT(Map<String, Object> param);

	String getRqhdProgressCd(Map<String, String> param);

	void updateStatusQTDT(Map<String, Object> param);

	void updateStatusNWRQ(Map<String, Object> param);

	List<Map<String, String>> getCnVendorList(Map<String, String> param);

	List<Map<String, Object>> getYinfoByVendors(Map<String, String> param);

	Map<String, Object> getYinfoByVendor(Map<String, Object> param);

	void insert_YINFO(Map<String, Object> param);

	void update_CnInfo(Map<String, Object> param);

	void update_NwInfo(Map<String, Object> param);

	void delete_YINFR(Map<String, Object> param);

	void insert_YINFR(Map<String, Object> param);

	void insert_YINFH(Map<String, Object> param);

	List<Map<String, Object>> getValidInfos(Map<String, Object> param);

	void deadPreContract(Map<String, Object> param);

	List<Map<String, Object>> getUinfoList(Map<String, String> param);

	String getUinfoExistFlag(Map<String, Object> param);

	void selectInsert_UINFH(Map<String, Object> param);

	void update_UINFO(Map<String, Object> param);

	void insert_UINFO(Map<String, Object> param);

	void insert_UINFH(Map<String, Object> param);

	List<Map<String, Object>> getAutoPoList(Map<String, String> param);

	List<Map<String, Object>> getReqItemInfos(Map<String, String> param);

	List<Map<String, Object>> getContVendorInfos(Map<String, String> param);

	List<Map<String, Object>> getContItemInfos(Map<String, String> param);
	//개찰
	void saveCrqOpenHd(Map<String, Object> data);

}
