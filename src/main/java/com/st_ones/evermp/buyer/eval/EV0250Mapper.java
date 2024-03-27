package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0250Mapper {

	public  List<Map<String, Object>> getRegCombo(Map<String, String> param);

	public List<Map<String, Object>> doSearch(Map<String, String> param);

	public List<Map<String, Object>> getEvUserCombo(Map<String, String> param);

	public List<Map<String, Object>> doSearchType(Map<String, String> param);

	public List<Map<String, Object>> doSearchSubject(Map<String, String> param);

	public List<Map<String, Object>> doSearchDetail(Map<String, String> param);

	public Map<String, String> doSearchEveu(Map<String, String> param);

	public Map<String, String> doCheck(Map<String, String> data);

	public void doUpdateEveu(Map<String, String> data);

	public void doUpdateEvee(Map<String, String> data);

	public void doDeleteEvee(Map<String, String> data);


	public int doRepUserCheck(Map<String, String> chkData);

	public String checkProgress(Map<String, String> data);




	public void doUpdateEves(Map<String, String> data);

}