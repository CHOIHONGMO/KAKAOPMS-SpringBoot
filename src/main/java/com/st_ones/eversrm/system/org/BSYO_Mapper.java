package com.st_ones.eversrm.system.org;

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
 * @File Name : BSYO_Mapper.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Repository
public interface BSYO_Mapper {

	
	String getPlantCd(Map<String, String> param);
	
	List<Map<String, Object>> selectGate(Map<String, String> param);

	int checkGateUnitExists(Map<String, String> param);

	int insertGate(Map<String, String> param);

	int updateGate(Map<String, String> param);

	int deleteGate(Map<String, String> param);

	Map<String, Object> selectGateInfo(Map<String, Object> param);

	List<Map<String, Object>> selectCompany(Map<String, String> param);

	List<Map<String, Object>> selectDeptGrid(Map<String, String> param);

	int checkCompanyExists(Map<String, String> param);

	int insertCompany(Map<String, String> param);

	int updateCompany(Map<String, String> param);

	int deleteCompany(Map<String, String> param);

	List<Map<String, Object>> selectPurchaseComMapping(Map<String, String> param);

	int savePurchaseComMapping(Map<String, Object> gridData);

	List<Map<String, Object>> selectPurchaseOrg(Map<String, String> param);

	int checkPurchaseOrgExists(Map<String, String> param);

	int insertPurchaseOrg(Map<String, String> param);

	int updatePurchaseOrg(Map<String, String> param);

	int deletePurchaseOrg(Map<String, String> param);

	List<Map<String, Object>> selectPlant(Map<String, String> param);

	int checkPlantExists(Map<String, String> param);

	Map<String, String> getPlantInfo(Map<String, String> param);

	int insertPlant(Map<String, String> param);

	int updatePlant(Map<String, String> param);

	int deletePlant(Map<String, String> param);

	List<Map<String, String>> doSearch(Map<String, String> param);

	List<Map<String, String>> doSearch2(Map<String, String> param);
	List<Map<String, String>> doSearchDeptINFO(Map<String, String> param);


	List<Map<String, Object>> selectDeptParent(Map<String, String> param);

	int checkExists_Dept(Map<String, String> param);

	Map<String, String> getInfo_Dept(Map<String, String> param);

	int doInsert_Dept(Map<String, String> param);

	int doUpdate_Dept(Map<String, String> param);

	int doDelete_Dept(Map<String, String> param);

	List<Map<String, Object>> selectWareHouse(Map<String, String> param);

	List<Map<String, Object>> selectWareHouseDetail(Map<String, String> param);

	int checkWareHouseExists(Map<String, String> param);

	int insertWareHouse(Map<String, String> param);

	int updateWareHouse(Map<String, String> param);

	int deleteWareHouse(Map<String, String> param);

	int existsWareHouseDetailKey(Map<String, Object> param);

	int insertDetailByMaster(Map<String, Object> param);

	int updateDetailByMaster(Map<String, Object> param);

	int deleteDetailByMaster(Map<String, Object> param);

//	public int checkExists_PurComMapping(Map<String, Object> param);
//
//	public int doInsert_PurComMapping(Map<String, Object> param);
//
//	public int doUpdate_PurComMapping(Map<String, Object> param);
//
//	public int delete_PurComMapping(Map<String, Object> param);
}
