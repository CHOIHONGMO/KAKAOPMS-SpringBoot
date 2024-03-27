package com.st_ones.eversrm.main;

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
 * @File Name : BMSI_Mapper.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0
 * @see
 */

public interface MSI_Mapper {

	List<Map<String, Object>> doFindIDFindIdPassword(Map<String, String> param);

	List<Map<String, Object>> doFindPasswordFindIdPassword(Map<String, String> param);

	List<Map<String, Object>> checkVendor(Map<String, String> param);

	List<Map<String, Object>> checkUser(Map<String, String> param);

	List<Map<String, Object>> getPostNoticeList(Map<String, String> param);

	HashMap<String, String> selectUser(Map<String, String> param);
	HashMap<String, String> selectUserCS(Map<String, String> param);

	HashMap<String, String> selectEncPassword(Map<String, String> param);

	void doUpdate(Map<String, String> formData);
	void doUpdateCS(Map<String, String> formData);

	Map<String, String> getBaseLoginInfo(Map<String, String> certificateInfoMap);

	HashMap<String, String> getDateFormatValue(Map<String, String> formData);

	HashMap<String, String> getNumberFormatValue(Map<String, Object> formData);

	List<HashMap<String, String>> getCTRLInfo(com.st_ones.everf.serverside.info.BaseInfo CTRLData);

	void doSavePassword(Map<String, Object> userInfo);

}
