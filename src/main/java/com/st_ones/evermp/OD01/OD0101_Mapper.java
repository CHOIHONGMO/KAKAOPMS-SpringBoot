package com.st_ones.evermp.OD01;

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
 * @File Name : OD0101_Mapper.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */
@Repository
public interface OD0101_Mapper {
	List<Map<String, String>> getTargetList(Map<String, Object> param);

	List<Map<String, Object>> od01001_doSearch(Map<String, Object> param);

	List<Map<String, Object>> PO0210_doSearch(Map<String, Object> param);

	List<Map<String, Object>> PO0211_doSearch(Map<String, String> param);


	List<Map<String, Object>> PO0240_doSearch(Map<String, Object> param);





	String checkProgressCd(Map<String, Object> param);
	void doTransferAmUserUpo(Map<String, Object> gridData);
	void doTransferAmUserYpo(Map<String, Object> gridData);
	void doReqConfirmUpo(Map<String, Object> gridData);
	void doReqConfirmYpo(Map<String, Object> gridData);


	void doPoRecpipt(Map<String, Object> gridData);

	void setUPoClose(Map<String, Object> gridData);
	void setYPoClose(Map<String, Object> gridData);

	void doPoConfirmUpo(Map<String, Object> gridData);
	void doPoConfirmYpo(Map<String, Object> gridData);

	void doDelYpo(Map<String, Object> gridData);

	void doPoConfirmRejectUpo(Map<String, Object> gridData);
	void doPoConfirmRejectYpo(Map<String, Object> gridData);
	void od01001_doSaveUPODT(Map<String, Object> gridData);
	void od01001_doSaveUPDATE_UPOHD(Map<String, Object> gridData);
	void od01001_doSaveYPODT(Map<String, Object> gridData);
	void od01001_doSaveAGENT_MEMO(Map<String, Object> gridData);

	/** ******************************************************************************************
     * 운영사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> od01010_doSearch(Map<String, Object> param);
	void od01010_doCancelPO_UPODT(Map<String, Object> gridData);

	/** ******************************************************************************************
	 * 운영사 : 주문IF현황
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> od01020_doSearch(Map<String, String> param);
	void od01020_doSaveUPDATE_IFPODT(Map<String, Object> gridData);
	List<Map<String, Object>> od01020_SELECT_IFPODT(Map<String, Object> param);
	void od01020_doSaveINSERT_UPOHD(Map<String, Object> gridData);
	void od01020_doSaveINSERT_UPODT(Map<String, Object> gridData);
	void od01020_doSaveStatus_UPDATE_IFPODT(Map<String, Object> gridData);

	/** ******************************************************************************************
	 * 운영사 > 주문관리 > 주문진행현황 > 주문변경
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> od01011_doSearch(Map<String, String> param);
	List<Map<String, Object>> od01011_doSearchINV(Map<String, String> param);
	List<Map<String, Object>> od01011_doSearchINV2(Map<String, String> param);

	// 주문변경시 변경가능여부 체크
	String isPossibleChangeQty (Map<String, String> param); // 수량변경가능여부
	String isExistInvQty (Map<String, String> param); // 납품수량 존재여부
	String isExistInvCompleteQty (Map<String, String> param); // 납품완료처리 존재여부
	String isExistGrCompleteQty (Map<String, String> param); // 입고완료처리 존재여부

	// 주문수량 변경시 수량 변경 처리
	void doUpdateUPODT(Map<String, String> param);
	void doUpdateYPODT(Map<String, String> param);
	void doUpdateCCUBD(Map<String, String> param);

	// 주문 변경사항 결재전에 변경전에 등록하기
	void doUpdateChangeYPODT(Map<String, String> param);

	// 주문변경 결재관련항목 update
	void doUpdateYPODTapp(Map<String, String> param);

	// 결재완료 후 주문변경사항 최종 완료하기
	Map<String, String> getPoNo(Map<String, String> param);
	Map<String, String> getPoNoSelf(Map<String, String> param);

	// 결재 완료 후 결재상태 변경하기
	void doUpdateSignStatusYPODT(Map<String, String> param);
	void selfUpdateSignStatusYPODT(Map<String, String> param);

	// 공급사 주문 삭제 후 신규주문 생성하기
	void doDeleteUIVDT(Map<String, String> param);
	void doDeleteYIVDT(Map<String, String> param);
	void doDeleteYPODT(Map<String, String> param);

	void doInsertYPOHD(Map<String, String> param);
	void doInsertYPODT(Map<String, String> param);

	// 결재 완료 후 주문정보 변경
	void doChangeCompleteUPODT(Map<String, String> param);
	void doChangeCompleteYPODT(Map<String, String> param);
	void doChangeCompleteUIVDT(Map<String, String> param);
	void doChangeCompleteYIVDT(Map<String, String> param);

	void od01011_doSaveRecipient_UPDATE_UPODT(Map<String, String> param);
	void od01011_doSaveRecipient_UPDATE_YPODT(Map<String, String> param);
	void od01011_doSaveRecipient_UPDATE_UIVHD(Map<String, String> param);
	void od01011_doSaveRecipient_UPDATE_YIVHD(Map<String, String> param);

	List<Map<String, Object>> od01030_doSearch(Map<String, String> param);

	List<Map<String, Object>> od01040_doSearch(Map<String, Object> param);



	void yPoChange(Map<String, Object> gridData);

	void yPoSignUpdate(Map<String, String> gridData);

	void yPoSignApply(Map<String, Object> gridData);
	void uPoSignApply(Map<String, Object> gridData);

	void delYpodt(Map<String, Object> gridData);


	void movePohdToDohd(Map<String, Object> gridData);
	void movePodtToDodt(Map<String, Object> gridData);




}