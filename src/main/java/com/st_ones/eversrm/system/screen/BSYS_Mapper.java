package com.st_ones.eversrm.system.screen;

import org.apache.ibatis.annotations.Param;
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
 * @File Name : BSYS_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */
@Repository
public interface BSYS_Mapper {

	List<Map<String, Object>> doSearchScreenManagement(Map<String, String> param);

	int checkScreenManagement(Map<String, Object> param);

	int doInsertScreenManagement(Map<String, Object> gridData);

	int doUpdateScreenManagement(Map<String, Object> gridData);

	int doDeleteScreenManagement(Map<String, Object> gridData);

	int checkScreenId(Map<String, String> param);

	int doCopyScreenManagementSCRN(Map<String, String> Data);

	int doCopyScreenManagementSCAC(Map<String, String> Data);

	int doCopyScreenManagementMULG(Map<String, String> Data);

	int doCopyScreenManagementLANG(Map<String, String> Data);

	List<Map<String, Object>> doSearchScreenActionManagement(Map<String, String> param);

	int checkScreenActionManagement(Map<String, Object> param);

	int doInsertScreenActionManagement(Map<String, Object> gridData);

	int doUpdateScreenActionManagement(Map<String, Object> gridData);

	int doDeleteScreenActionManagement(Map<String, Object> gridData);

	List<Map<String, Object>> doSearchScreenIdPopup(Map<String, String> param);

	List<Map<String, Object>> doSearchLAuthorizationCommission(Map<String, String> param);

	List<Map<String, Object>> doSearchRAuthorizationCommission(Map<String, String> param);

	int checkAuthorizationCommission(Map<String, Object> param);

	int doInsertAuthorizationCommission(Map<String, Object> gridData);

	int doUpdateAuthorizationCommission(Map<String, Object> gridData);

	int doDeleteAuthorizationCommission(Map<String, Object> gridData);

	List<Map<String, Object>> doSearchLActionProfileManagement(Map<String, String> param);

	List<Map<String, Object>> doSearchRActionProfileManagement(Map<String, String> param);

	List<Map<String, Object>> doSearchTActionProfileManagement(Map<String, String> param);

	int doInsertTActionProfileManagement(Map<String, Object> gridData);

	int doUpdateTActionProfileManagement(Map<String, Object> gridData);

	int doDeleteTActionProfileManagement(Map<String, Object> gridData);

	int checkTActionProfileManagement(Map<String, Object> param);

	int doInsertLActionProfileManagement(Map<String, Object> gridData);

	int doUpdateLActionProfileManagement(Map<String, Object> gridData);

	int doDeleteLActionProfileManagement(Map<String, Object> gridData);

	int checkLActionProfileManagement(Map<String, Object> param);

	List<Map<String, String>> getAvailableButtonCodeList();

	Map<String, String> selectHelpInfo(@Param("paramScreenId") String paramScreenId);

	int updateHelpInfo(Map<String, String> formData);

	int deleteHelpInfo(Map<String, String> formData);

}
