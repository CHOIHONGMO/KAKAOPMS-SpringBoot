package com.st_ones.eversrm.system.code;

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
 * @File Name : BSYC_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BSYC_Mapper {

	List<Map<String, Object>> doSearchHD(Map<String, String> param);

	int checkHDData(Map<String, Object> gridData);

	int doInsertHD(Map<String, Object> gridData);

	int doSelectInsertHD(Map<String, Object> gridData);

	int doUpdateHD(Map<String, Object> gridData);

	int doDeleteHD(Map<String, Object> gridData);

	List<Map<String, Object>> doSearchDT(Map<String, String> param);

	int checkConstraintR31(Map<String, Object> gridData);

	int checkDTData(Map<String, Object> gridData);

	int doInsertDT(Map<String, Object> gridData);

	int doSelectInsertDT(Map<String, Object> gridData);

	int doUpdateDT(Map<String, Object> gridData);

	int doDeleteDT(Map<String, Object> gridData);

	String getNewKey(Map<String, Object> gridData);

	List<Map<String, String>> getComCodeAndText(Map<String, String> param);

}
