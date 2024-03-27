package com.st_ones.evermp.BOD1;

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
 * @File Name : BOD102_Mapper.java
 * @author  최홍모
 * @date 2018. 10. 25.
 * @version 1.0
 * @see
 */
@Repository
public interface BOD102_Mapper {

    // 조회
	List<Map<String, Object>> bod1020_doSearch(Map<String, String> param);
	List<Map<String, Object>> bod1021_doSearch(Map<String, String> param);

	Map<String, Object> bod1020_doSearchDelyInfo(Map<String, String> param);

	// 저장 및 삭제
	void bod1020_doInsertBULK(Map<String, Object> gridData);
	void bod1020_doUpdateBULK(Map<String, Object> gridData);
	void bod1020_doDelete(Map<String, Object> gridData);
	// 주문하기
	void bod1020_doInsertUPOHD(Map<String, Object> gridData);
	void bod1020_doInsertUPODT(Map<String, Object> gridData);
	void bod1020_doInsertUPODT2(Map<String, Object> gridData);
	// 주문완료 후 bulk 데이터 처리
	void bod1020_doUpdateAfterCpo(Map<String, Object> gridData);
	// 1. 고객사 체크
	public Map<String, Object> doGetCustInfo(Map<String, Object> gridData);
	// 2. 주문자 체크
	public Map<String, Object> doGetCustUser(Map<String, Object> gridData);
	// 3. 품목 체크
	public Map<String, Object> doGetItemInfo(Map<String, Object> gridData);
	// 4. 공급사 체크
	public Map<String, Object> doGetVendorInfo(Map<String, Object> gridData);
	// 5. 매입단가 체크
	public Map<String, Object> doGetUnitPrc(Map<String, Object> gridData);

	// 주문일괄등록 엑셀업로드
    Map<String, Object> doSetExcelImportItemCpo(Map<String ,Object> grid);

}