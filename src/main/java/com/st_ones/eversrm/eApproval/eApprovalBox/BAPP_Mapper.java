package com.st_ones.eversrm.eApproval.eApprovalBox;

import org.springframework.stereotype.Repository;

import java.util.HashMap;
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
 * @File Name : BAPP_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BAPP_Mapper {

	List<Map<String, Object>> searchMailBox(Map<String, String> param);

	List<Map<String, Object>> getSendBoxList(Map<String, String> param);

	void doCancelRFA(Map<String, Object> gridData);

	String getCurrentDocCount(Map<String, String> approvalInfoKey);

	Map<String, String> selectSTOCSCTM(Map<String, String> approvalInfoKey);
	
	List<Map<String, Object>> selectSTOCSCTP(Map<String, String> formData);

	List<Map<String, Object>> selectLULP(HashMap<String, String> approvalPathKey);

	int getAuthorizedCount(Map<String, String> approvalInfoKey);

	Map<String, String> getUserInfoByName(HashMap<String, String> hashMap);

	int matchUserCountByName(HashMap<String, String> hashMap);

	// BAPP_550
    List<Map<String, Object>> userSearch(Map<String, String> param);

	Map<String, String> getAppLineCd(Map<String, Object> param);

	String getParentDeptCd(Map<String, Object> param);

	Map<String, String> checkITO(Map<String, String> param);

	String getChiefIncludeFlag(Map<String, String> param);

	List<Map<String, Object>> getAgrLines(Map<String, Object> param);

	List<Map<String, Object>> getAppLines(Map<String, String> param);

	List<Map<String, Object>> getAppLinesWithChief(Map<String, String> param);

	List<Map<String, Object>> getAppLinesOperator(Map<String, String> param);

	List<Map<String, Object>> getAppLinesInCust(Map<String, String> param);

	Map<String, Object> getAppLinesTeamLeader(Map<String, String> param);

	List<Map<String, Object>> doSearchSync(Map<String, Object> param);

	List<Map<String, String>> getMyPath(Map<String, String> param);

	List<Map<String, Object>> getMyPathList(Map<String, String> param);

	// BAPP_060
    List<Map<String, Object>> getSendReceiveBoxList(Map<String, String> param);

	List<Map<String, Object>> getSendReceiveBoxListA(Map<String, String> param);

    List<Map<String, Object>> getPcSmartDeviceNewRequest();

	List<Map<String,Object>> getPcSmartDeviceChangeRequest();

	List<Map<String,Object>> getworkRequest();

}