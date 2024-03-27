package com.st_ones.evermp.SY01;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface SY0101_Mapper {

	/** ******************************************************************************************
	 * 조직정보
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> sy01001_doSearch(Map<String, String> param);

	//팀검색 트리
	List<Map<String, Object>> sy01001_doSelect_deptTree(Map<String, String> param);
	List<Map<String, Object>> sy01001_doSearch_parent(Map<String, String> param);

	int existsOPDP(Map<String, Object> gridData);

	List<Map<String, Object>> sy01001_doSelect_DP(Map<String, String> param);

	void sy01001_updateDEPTData(Map<String, Object> gridData);
	void sy01001_mergeData(Map<String, Object> gridData);
	void sy01001_doSave_DP(Map<String, Object> gridData);
	int sy01001_doDelete_DP(Map<String, Object> gridData);


	void sy0101_updateDEPTData(Map<String, Object> gridData);

	List<Map<String, Object>> sy01002_doSelect_deptTree(Map<String, String> formTree);

	List<Map<String, Object>> findPlant(Map<String, String> formData);

}