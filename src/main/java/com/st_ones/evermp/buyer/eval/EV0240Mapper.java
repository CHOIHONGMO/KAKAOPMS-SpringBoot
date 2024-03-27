package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0240Mapper {
	
	public List<Map<String, Object>> doSearch(Map<String, Object> param);

	public Map<String, Object> doCheck(Map<String, Object> param);
	
	public int doRepUserCheck(Map<String, Object> param);	
	
	public int doCompleteEveu(Map<String, Object> param);
	
	public int doCancelEveu(Map<String, Object> param);

	public int qtyCheck(Map<String, Object> gridData);

	public List<Map<String, String>> getVendorCd(Map<String, Object> gridData);

	public void updateEsScore(Map<String, Object> gridData);

	public int checkEuScore(Map<String, Object> gridData);

	public String getEuScore(Map<String, Object> gridData);

	public String getEtScore(Map<String, Object> gridData);

	public List<Map<String, Object>> getEuVendor(Map<String, Object> gridrow);

	public void doIndivisualComplete(Map<String, Object> euList);

	public String checkProgress(Map<String, Object> gridData);

	public int checkAllCount(Map<String, Object> gridData);

	public int checkScoreCount(Map<String, Object> gridData);




}
