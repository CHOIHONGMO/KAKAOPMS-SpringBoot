package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0270Mapper {

	public List<Map<String, Object>> doSearch(Map<String, Object> param);


	public List<Map<String, Object>> doSearchEsgSummaryList(Map<String, String> param);



	void srm270_doComplete(Map<String, Object> gridData);

	public void doCancel(Map<String, Object> gridData);

	public void doEdit(Map<String, Object> gridData);

	public void doCompleteEu(Map<String, Object> gridData);


	public void emFinish(Map<String, Object> gridData);

	public String check(Map<String, Object> gridData);

	public void doCancelEm(Map<String, Object> gridData);



	public Map<String, String> getEsgValueInfo(Map<String, String> param);

	List<Map<String, Object>> EV0270P03_doSearch(Map<String, String> param);

}
