package com.st_ones.eversrm.system.env;

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
 * @File Name : BSYE_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BSYE_Mapper {

	List<Map<String, Object>> doSearchEnv(Map<String, String> param);

	int deleteEnvironment(Map<String, Object> gridData);

	List<Map<String, Object>> selectHouse(Map<String, String> param);

	List<Map<String, Object>> selectCompany(Map<String, String> param);

	List<Map<String, Object>> selectPurOrganization(Map<String, String> param);

	List<Map<String, Object>> selectPlant(Map<String, String> param);

	int existsWiseConfInformation(Map<String, Object> gridData);

	int createEnvironment(Map<String, Object> gridData);

	int updateEnvironment(Map<String, Object> gridData);

}
