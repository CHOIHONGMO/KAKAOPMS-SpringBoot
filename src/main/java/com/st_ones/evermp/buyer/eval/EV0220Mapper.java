package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0220Mapper {

	public List<Map<String, Object>> doSearch(Map<String, Object> param);

	public List<Map<String, Object>> doEvCheck(Map<String, Object> param);
	List<Map<String, Object>> doEvCheck_EV0045(Map<String, Object> param);

	public List<Map<String, Object>> getVendorList(Map<String, Object> param);
	List<Map<String, Object>> getVendorListEV0045(Map<String, Object> param);

	public int deleteEvet(Map<String, String> param);

	public int regEvetItem(Map<String, String> param);

	public String getVendorInfoScore(Map<String, String> param);

	public String getEvetScore(Map<String, String> param);

	public String getEveuScore(Map<String, String> param);

	public String getWeightSum(Map<String, String> param);

	public int regEves(Map<String, String> param);




	public String getEsgScore(Map<String, String> param);
	public String getWongaScore(Map<String, String> param);
	public String getGrFollowScore(Map<String, String> param);


	public List<Map<String, Object>> doSearchEsgGubun(Map<String, String> param);

	public int delEsgGubun(Map<String, String> param);
	public int saveEsgGubun(Map<String, Object> param);

}