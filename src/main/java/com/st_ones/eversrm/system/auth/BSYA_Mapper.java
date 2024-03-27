package com.st_ones.eversrm.system.auth;

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
 * @File Name : BSYA_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BSYA_Mapper {

	List<Map<String, Object>> doSearchAuthProfileManagement(Map<String, String> param);

	int checkAuthProfileManagement(Map<String, Object> param);

	int doInsertAuthProfileManagement(Map<String, Object> gridData);

	int doUpdateAuthProfileManagement(Map<String, Object> gridData);

	int doDeleteAuthProfileManagement(Map<String, Object> gridData);

	List<Map<String, String>> getDepartmentTree(Map<String, String> param);

	List<Map<String, Object>> listUserByDept(Map<String, String> param);

	List<Map<String, Object>> listSTOCUSAC(Map<String, String> param);

	int createSTOCUSAC(Map<String, Object> gridData);

	int updateSTOCUSAC(Map<String, Object> gridData);

	int deleteSTOCUSAC(Map<String, Object> gridData);

	int createSTOCUSAP(Map<String, Object> gridData);

	int updateSTOCUSAP(Map<String, Object> gridData);

	int deleteSTOCUSAP(Map<String, Object> gridData);

	int existsSTOCUSAP(Map<String, Object> param);

	int checkAuthCode(Map<String, Object> param);

	int existsSTOCUSAC(Map<String, Object> param);

	List<Map<String, Object>> doSearchLMenuAuthMapping(Map<String, String> param);

	List<Map<String, Object>> doSearchRMenuAuthMapping(Map<String, String> param);

	int doInsertMenuAuthMapping(Map<String, Object> gridData);

	int doDeleteMenuAuthMapping(Map<String, Object> gridData);

	int checkMenuAuthMapping(Map<String, Object> param);

	List<Map<String, Object>> doSearchAuthProfileCode(Map<String, String> param);

	List<Map<String, Object>> doSearchLScreenActionAuthMapping(Map<String, String> param);

	List<Map<String, Object>> doSearchRScreenActionAuthMapping(Map<String, String> param);

	int doInsertScreenActionAuthMapping(Map<String, Object> gridData);

	int doDeleteScreenActionAuthMapping(Map<String, Object> gridData);
}
