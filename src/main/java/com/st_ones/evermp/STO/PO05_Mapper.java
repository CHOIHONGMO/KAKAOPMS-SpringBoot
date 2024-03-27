package com.st_ones.evermp.STO;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface PO05_Mapper {

	List<Map<String, Object>> po0510_doSearch(Map<String, String> formData);

/** ******************************************************************************************
 **  공급사 선택*/

	List<Map<String, Object>> PO0560_doSearch(Map<String, String> param);

/** ******************************************************************************************
 **  발주등록 */

	// 주문

	void po0550_doInsertUPOHD(Map<String, Object> gridData);

	void po0550_doInsertUPODT(Map<String, Object> gridData);

	void doInsertYPOHD(Map<String, Object> poData);

	void doInsertYPODT(Map<String, Object> poData);

	//발주등록조회
	List<Map<String, Object>> PO0550_doSearch(Map<String, String> param);

	//발주현황
	List<Map<String, Object>> PO0520_doSearch(Map<String, Object> fParam);

	String checkProgressCd(Map<String, Object> gridData);

	void doPoConfirmUpo(Map<String, Object> gridData);

	void doPoConfirmYpo(Map<String, Object> gridData);
	//발주취소
	void doDelYpo(Map<String, Object> gridData);

	void doDelYpoHd(Map<String, Object> gridData);

	void doDelUPODT(Map<String, Object> gridData);

	void doDelUPOHD(Map<String, Object> gridData);

	//발주종결
	void setUPoClose(Map<String, Object> gridData);

	void setYPoClose(Map<String, Object> gridData);
	//담당자 이관
	void doTransferAmUserUpo(Map<String, Object> gridData);

	void doTransferAmUserYpo(Map<String, Object> gridData);

	//메일발송
	List<Map<String, String>> getTargetList(Map<String, Object> param);












}
