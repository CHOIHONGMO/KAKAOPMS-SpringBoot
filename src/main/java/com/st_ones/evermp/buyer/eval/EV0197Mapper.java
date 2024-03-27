package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0197Mapper {

	public List<Map<String, Object>> doSearch(Map<String, String> param) throws Exception;

	public void doConfirm(Map<String, Object> gridData);

	public void doCancle(Map<String, Object> gridData);

	public void doReEval(Map<String, Object> gridData);

	public void doInconsist(Map<String, Object> gridData);

	public void doRequest(Map<String, Object> gridData);

	public void doRequestVNGL(Map<String, Object> gridData);

	public void doImprove(Map<String, Object> gridData);

	public double getScore(Map<String, Object> gridData);

	public void doInconsistVngl(Map<String, Object> gridData);

	String getSignStatus(Map<String, Object> gridData);

	void doUpdateAppDoc(Map<String, Object> gridData);
}
