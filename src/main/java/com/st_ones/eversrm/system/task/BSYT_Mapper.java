package com.st_ones.eversrm.system.task;

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
 * @File Name : BSYT_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BSYT_Mapper {

	List<Map<String, Object>> selectTaskPersonInCharge(Map<String, String> param);

	int checkTaskPersonInCharge(Map<String, Object> gridData);

	int insertTaskPersonInCharge(Map<String, Object> gridData);

	int updateTaskPersonInCharge(Map<String, Object> gridData);

	int deleteTaskPersonInCharge(Map<String, Object> gridData);

	//직무-사용자 history 저장
	int saveHistoryBACH(Map<String, Object> gridData);

	List<Map<String, Object>> selectUserInCharge(Map<String, String> param);

	List<Map<String, Object>> selectTaskCode(Map<String, String> param);

	List<Map<String, Object>> selectMappingUser_add(Map<String, String> param);

	int checkTaskCode(Map<String, Object> param);

	int insertTaskCode(Map<String, Object> gridData);

	int updateTaskCode(Map<String, Object> gridData);

	int deleteTaskCode(Map<String, Object> gridData);

	List<Map<String, Object>> selectTaskCodeBySearch(Map<String, String> param);

	List<Map<String, Object>> selectTaskItemMapping(Map<String, String> param);

	int existTaskItemMapping(Map<String, Object> param);

	int insertTaskItemMapping(Map<String, Object> gridData);

	int updateTaskItemMapping(Map<String, Object> gridData);

	int deleteTaskItemMapping(Map<String, Object> gridData);

	List<Map<String,Object>> BSYT_070_doSearch(Map<String, String> param);

	int BSYT_070_doSave(Map<String, Object> grid);

	int BSYT_070_doDelete(Map<String, Object> grid);

	List<Map<String, Object>> selectMappingPlant(Map<String, Object> grid);

	int saveMappingPlant(Map<String, Object> gridData);

	int deleteMappingPlant(Map<String, Object> gridData);

	List<Map<String, Object>> selectMappingUser(Map<String, Object> grid);

	List<Map<String, Object>> bsyt080Select(Map<String, String> param);
}