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
 * @File Name : BOD103_Mapper.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */
@Repository
public interface BOD103_Mapper {

	/** ******************************************************************************************
     * 주문 CART 조회
     * @param req
     * @return
     * @throws Exception
     */
	Map<String, String> getAccData(Map<String, String> param);

	Map<String, String> getCommonAccData(Map<String, String> param);

	List<Map<String, Object>> bod1030_doSearch(Map<String, String> param);

	void bod1030_doSave(Map<String, Object> gridData);

	void bod1030_doDelete(Map<String, Object> gridData);

	void bod1030_doOrder(Map<String, Object> gridData);

	void doInsertUPOHD(Map<String, String> param);

	void doInsertUPODT(Map<String, Object> gridData);

	String getAccountCd(Map<String, Object> param);

	void doCalulateBudget(Map<String, Object> gridData);

	void doUpdateNWRQpo(Map<String, Object> gridData);

	void doUpdateUPOHDapp(Map<String, String> param);

	// CPO에서 PO건수 가져오기
	List<Map<String, Object>> getPOList(Map<String, String> param);

	// CPO에서 PO건수 가져오기
	List<Map<String, Object>> getPOListBulk(Map<String, String> param);

	// 공급사 POHD 등록
	int doInsertYPOHD(Map<String, Object> param);

	// 공급사 PODT 등록
	int doInsertYPODT(Map<String, Object> param);
	int doInsertYPODT2(Map<String, Object> param);

	// 운영사 DOHD 등록  --미사용
	//int doInsertUDOHD(Map<String, Object> param);

	// 운영사 DODT 등록 --미사용
	//int doInsertUDODT(Map<String, Object> param);

	Map<String, String> getCpoNo(Map<String, String> param);

	void doUpdateSignStatusUPOHD(Map<String, String> param);

	void doUpdateSignStatusUPOHDNoApp(Map<String, String> param);

	void doUpdateSignStatusUPODT(Map<String, String> param);

	List<Map<String, Object>> getPoDatas(Map<String, String> param);

	int doDecreaseBudgetForApp(Map<String, Object> param);

	int doDecreaseBudget(Map<String, String> param);

	void doUpdateItemStatus(Map<String, String> param);

	/** ******************************************************************************************
     * 예산체크
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> bod1031_doSearch(Map<String, Object> param);
	List<Map<String, Object>> bod1031_doSearchAll(Map<String, Object> param);

	/** ******************************************************************************************
     * 관심품목 등록
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> bod1032_doSearch(Map<String, String> param);

	void bod1032_doSave(Map<String, Object> gridData);

    List<Map<String, String>> doSearchIfVendorList();




























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


	void doGrSaveGRDT(Map<String, Object> param);


}