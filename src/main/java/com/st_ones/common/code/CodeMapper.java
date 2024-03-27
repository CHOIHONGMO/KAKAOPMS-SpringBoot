package com.st_ones.common.code;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**  test
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : CodeMapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 08. 27.
 * @version 1.0  
 * @see 
 */
@Repository
public interface CodeMapper {

	List<Map<String, Object>> doSearchHD(Map<String, String> param);

	int checkHDData(Map<String, Object> gridData);

	void doInsertHD(Map<String, Object> gridData);

	int doSelectInsertHD(Map<String, Object> gridData);

	void doUpdateHD(Map<String, Object> gridData);

	void doDeleteHD(Map<String, Object> gridData);

	List<Map<String, Object>> doSearchDT(Map<String, String> param);

	int checkConstraintR31(Map<String, Object> gridData);

	int checkDTData(Map<String, Object> gridData);

	void doInsertDT(Map<String, Object> gridData);

	int doSelectInsertDT(Map<String, Object> gridData);

	void doUpdateDT(Map<String, Object> gridData);

	void doDeleteDT(Map<String, Object> gridData);

	String getNewKey(Map<String, Object> gridData);

	List<Map<String, Object>> doSearchByStreet1(Map<String, String> param);

	List<Map<String, Object>> doSearchByStreet2(Map<String, String> param);

	List<Map<String, Object>> doSearchByStreet3(Map<String, String> param);

	List<Map<String, Object>> doSearchByDistrict(Map<String, String> param);

}