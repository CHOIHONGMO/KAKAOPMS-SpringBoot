package com.st_ones.evermp.OD01;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface PO0310_Mapper {

	List<Map<String, Object>> PO0310_doSearch(Map<String, Object> fParam);

	//고객사 주문정보 업데이트
	void doPoConfirmUpo(Map<String, Object> gridData);
	//발주정보상세 삭제
	void doDelYPO(Map<String, Object> gridData);

	void doPoConfirmYPODT(Map<String, Object> gridData);

	void YPODTChange(Map<String, Object> data);

	//담당자 변경
	void doTransferAmUserYPODT(Map<String, Object> gridData);
	void doTransferAmUserUpo(Map<String, Object> gridData);

	//결제상세 보기
	List<Map<String, Object>> PO0311_doSearch(Map<String, String> param);

	//수정결재승인
	void yPoSignApply(Map<String, Object> data);
	void uPoSignApply(Map<String, Object> data);

	void YPODTSignUpdate(Map<String, String> param);

	//진행상태 PROGRESS_CD
	String checkProgressCd(Map<String, Object> gridData);






	//void doPoConfirmYPOHD(Map<String, Object> gridData); [미사용]

	//void moveDohdToPohd(Map<String, Object> data); [미사용]

	//void moveDodtToPodt(Map<String, Object> data); [미사용]

	//void delYPODT(Map<String, Object> data); [미사용]


}
