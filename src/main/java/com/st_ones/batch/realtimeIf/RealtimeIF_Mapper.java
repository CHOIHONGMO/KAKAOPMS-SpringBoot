package com.st_ones.batch.realtimeIf;

import org.springframework.stereotype.Repository;

import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 22. 08. 26 오전 8:04
 */
@Repository
public interface RealtimeIF_Mapper {

	// everMailService.java : DGNS Mail 실제 발송 테이블 등록
	int insertRealMail(Map<String, String> param);

	// everSmsService.java : DGNS SMS 실제 발송 테이블 등록
	void insertRealSms(Map<String, String> param);

    //================== Service도 함께 구현 ===================
    // 품목 신규 등록시 DGNS 품목코드 가져오기
	Map<String, String> getDgnsItemCd(Map<String, String> param);

    // IM0301_Service.java : 품목 신규 등록시 DGNS 품목코드 가져오기
	String getDgnsItemCd2(Map<String, String> param);

    // IM0301_Service.java : 품목 등록 후 DGNS 품목 기본정보 등록하기
    int insPuaMtrlCd(Map<String, String> param);

    // IM0301_Service.java : 품목 등록 후 DGNS 품목 상세정보 등록하기
    int insPuaMtrlSpec(Map<String, String> param);

    // 고객사 상품정보 변경
    int updatePuaMtrlCd(Map<String, String> param);

    // 고객사 상품정보 변경
    int updatePuaMtrlSpec(Map<String, String> param);
    //====================================================

    // 고객사 상품정보 단종 및 단종해제, 사용여부 처리
    int updateItemUseFlag(Map<String, String> param);

    // 고객사 품목코드의 판매단가 생성 및 변경 후 I/F 데이터 등록
    int insCustUinfo(Map<String, String> param);

    // 고객사 견적합의대기 : 신규상품 업체 선정품의 완료 후 진행상태 변경
    int updateItemStatusPRHD(Map<String, Object> param);

    // 고객사 견적합의대기 : 신규상품 업체 선정품의 완료 후 진행상태 변경
    int updateItemStatusPRDT(Map<String, Object> param);

    // 고객사 반품 확정 후 dgns 상태값 변경
    int doUpdatePuaRtnDgns(Map<String, String> param);

    // 고객사 입고데이터 처리 후 진행상태 변경
    int updateGrStatusGRDT(Map<String, String> param);

    // XXXXX_Service.java : 납품서 등록 후 DGNS 납품서 Header I/F하기
    int regDgnsInvoiceHD(Map<String, String> param);

    // XXXXX_Service.java : 납품서 등록 후 DGNS 납품서 Detail I/F하기
    int regDgnsInvoiceDT(Map<String, String> param);
    
    // 납품완료취소 가능여부 체크
    int checkDgnsInvoice(Map<String, Object> param);
    void delDgnsInvoiceHD(Map<String, Object> param);
    void delDgnsInvoiceDT(Map<String, Object> param);

    // 고객의 소리(VOC) 처리완료 후 gw package Call
 	void gwVocCall(Map<String, String> param);

}