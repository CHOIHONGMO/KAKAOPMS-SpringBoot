package com.st_ones.evermp.SIV1;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : SIV101_Mapper.java
 * @author  개발자
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */
@Repository
public interface SIV101_Mapper {

	/** ******************************************************************************************
     * 공급사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1010_doSearch(Map<String, String> param);

	/** ******************************************************************************************
     * 공급사 : 납품서생성
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1020_doSearch(Map<String, String> param);

	public Map<String, Object> getPoQtySumInvQty(Map<String, Object> map);

	// 고객사 납품헤더 등록
	public void siv1020_doCreateUIVHD(Map<String, Object> map);

	// 공급사 납품헤더 등록
	public void siv1020_doCreateYIVHD(Map<String, Object> map);

	// 고객사 납품디테일 등록
	public void siv1020_doCreateUIVDT(Map<String, Object> map);

	// 공급사 납품디테일 등록
	public void siv1020_doCreateYIVDT(Map<String, Object> map);

	// 고객사 주문상세 수정
	public void siv1020_doUpdateUPODT(Map<String, Object> map);

	// 공급사 발주상세 수정
	public void siv1020_doUpdateYPODT(Map<String, Object> map);

	// 공급사 납품거부
	public void siv1020_doRejectInvoice(Map<String, Object> map);

	// 인수자정보 가져오기
	public Map<String, String> getRecipientUserInfo(Map<String, String> param);

	// 인수자정보(고객사) 가져오기
	public Map<String, String> getRecipientUserInfoCust(Map<String, String> param);

	/** ******************************************************************************************
     * 주문정보 가져오기
     * @param req
     * @return
     * @throws Exception
     */
	public Map<String, Object> siv1020_doSearchCpoHeaderInfo(Map<String, Object> param);

	// 납품 거부시 주문 헤더 정보 가져오기
	public List<Map<String, Object>> siv1020_getInvRejectCpoHeaderInfo(Map<String, Object> param);
	public List<Map<String, Object>> siv1020_getInvRejectCpoDetailInfo(Map<String, Object> param);

	/** ******************************************************************************************
	 * CPO_NO / SEQ 존재하는지 조회
	 * @param reqMap
	 * @return
	 * @throws Exception
	 */
	Map<String, String> siv1020_doSearch_CPO_INFO(Map<String, Object> grid);

    void siv1020_doUpdateYIVDT(Map<String, Object> grid);

	void siv1020_doUpdateUIVDT(Map<String, Object> grid);



	int chkIvPo(Map<String, Object> grid);

}