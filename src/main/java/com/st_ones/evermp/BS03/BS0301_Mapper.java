package com.st_ones.evermp.BS03;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 4:50
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BS0301_Mapper {

	/** ******************************************************************************************
	 * 공급회사
	 * @param req
	 * @return
	 * @throws Exception
	 */

	// 공급회사 리스트조회
	List<Map<String,Object>> bs03001_doSearch(Map<String, String> formData);

	// 공급회사상세 조회
	Map<String, String> bs03002_doSearchInfo(Map<String, String> param);

	Map<String, String> getCreditHist(Map<String, String> param);



	// 공급회사 첨부파일 조회
	Map<String, String> bs03002_doSearchFileVNGL(Map<String, String> param);

	// 공급회사 담당자 조회
	List<Map<String, Object>> bs03002_doSearchUser(Map<String, String> param);

	//공급회사 취급분야 조회
	List<Map<String, Object>> bs03002_doSearchSG(Map<String, String> param);

	//공급회사 계산서담당자 조회
	List<Map<String, Object>> bs03002_doSearchTX(Map<String, String> param);

	// 공급사 저장
	void bs03002_doMergeVendor(Map<String, Object> formData);

	void bs03002_doDelVNCP(Map<String,  Object> gridData);
	// 공급사 담당자 저장
	void bs03002_doMergeVNCP(Map<String, Object> gridData);

	//공급사 취급분야(sg)저장
	void bs03002_doMergeSGVN(Map<String, Object> gridData);

	//공급사 취급분야sg 삭제
	void bs03002_dodeleteSGVN(Map<String, Object> grid1) throws Exception;

	//공급사 계산서사용자저장
	void bs03002_doMergeTX(Map<String, Object> gridData);

	//공급사 계산서사용자 삭제
	void bs03002_dodeleteTX(Map<String, Object> grid1) throws Exception;

	// 공급사 주요취급품목 / 지역정보 삭제
	void bs03002_doDeleteVN(Map<String, Object> formData);

	//공급사 재무사항삭제
	void bs03002_doDeleteVNFI(Map<String, Object> formData);

	//공급사 재무사항 저장
	void bs03002_doInsertVNFI(Map<String, Object> gridData);

	// 공급사 주요취급품목 저장
	void bs03002_doMergeVNMG(Map<String, Object> gridData);

	// 공급사 지역정보 저장
	void bs03002_doMergeVNRG(Map<String, Object> gridData);

	//공급사 담당자id저장
	void bs03002_doMergeUser_CVUR(Map<String, Object> formData);

	//공급사 담당자 프로파일삭제
	void bs03002_doDeleteUser_USAP(Map<String, Object> formData);

	//공급사 담당자 프로파일저장
	void bs03002_doInsertUser_USAP(Map<String, Object> formData);

	//공급사 변경이력저장
	void bs03002_doInsert_VNGH(Map<String, Object> formData);

	// 공급회사 Block 정보
	Map<String, String> bs03003_doSearchInfo(Map<String, String> param);

	// 공급사 이력조회
	List<Map<String, Object>> bs03003_doSearchHistory(Map<String, String> param);

	// 공급회사 Block 정보 update
	void bs03003_doUpdateVendor(Map<String, String> formData);

	// 공급회사 Block 이력 저장
	void bs03003_doInsertBlockHistory(Map<String, String> formData);
	//공급사 Block 해제 후 이력저장
	void bs03003_doInsertBlockHistory_Approval(Map<String, String> formData);


	// 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
	void updateSignStatus(Map<String, String> param);

	void endApproval(Map<String, String> param);

    void endApproval_CVUR(Map<String, String> param);

	List<Map<String,Object>> bs03007_doSearch(Map<String, String> formData);

	Map<String, String> bs03008_doSearchInfo(Map<String, String> param);

	List<Map<String,Object>> bs03008_doSearchList(Map<String, String> param);

	void bs03008_doSave(Map<String, String> formData);

	List<Map<String, Object>> getMailUserInfo(Map<String, String> param);

	List<Map<String,Object>> doSearchMailUserList(Map<String, String> param);

    List<Map<String, Object>> BS03_001P_doSearch(Map<String, String> formData);

	String bs03010_doSearchDeliveryLevel(Map<String, String> param);

	Map<String, String> bs03010_doSearchInfo(Map<String, String> param);

	List<Map<String, Object>> bs03010_doSearchList(Map<String, String> param);

	void bs03010_doInsert(Map<String, String> formData);

	List<Map<String, Object>> bs03009_doSearch(Map<String, Object> paramObj);

	List<Map<String, Object>> BS03_009P_doSearch(Map<String, String> formData);

	void bs03009_doUpdateProgressCd(Map<String, Object> grid);
	/*	220902 sikim 반려 시 STOCVNGL update */
	void bs03009_doUpdateRejectStatusSTOCVNGL(Map<String, Object> grid);
	/*	220902 sikim 반려 시 STOCSPEV update */
	void bs03009_doUpdateRejectStatusSTOCSPEV(Map<String, Object> grid);

	void bs03010_doUpdate(Map<String, String> formData);

	/**
	 * 공급사 거래제안 (BS03_011)
	 */

	List<Map<String, Object>> BS03_011_doSearch(Map<String, String> param);

	void BS03_011_doDelete(Map<String, Object> gridData);

	/**
	 * 공급사 거래제안 팝업 (BS03_011P)
	 */

	Map<String, Object> BS03_011P_doSearchNoticeInfo(Map<String, String> param);

	void BS03_011P_doSaveCount(Map<String, Object> param);

	void BS03_011P_doInsert(Map<String, String> formData);

	void BS03_011P_doUpdate(Map<String, String> formData);

	Map<String, String> vnbhInfo(Map<String, String> map);

	void updateBhSignStatus(Map<String, String> map);

	void endApprovalBh(Map<String, String> map);
}