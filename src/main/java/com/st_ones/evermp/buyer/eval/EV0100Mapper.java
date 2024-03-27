package com.st_ones.evermp.buyer.eval;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface EV0100Mapper {

	public List<Map<String, Object>> doSearchEvalItemMgt(Map<String, String> param);

	public List<Map<String, Object>> doSearchEvalItemMgtDetail(Map<String, String> param);
	public List<Map<String, Object>> doSearchEvalItemMgtDetail2(Map<String, String> param);





	public void doInsertEvalItemMgtMaster(Map<String, String> param);

	public void doInsertEvalItemMgtDetail(Map<String, Object> param);

	public void doUpdateEvalItemMgtMaster(Map<String, String> param);

	public void doUpdateEvalItemMgtDetail(Map<String, Object> param);

	public void doDeleteEvalItemMgtMaster(Map<String, Object> param);

	public void doDeleteEvalItemMgtAllDetail(Map<String, Object> param);

	public void doDeleteEvalItemMgtDetail(Map<String, Object> param);

	public int doCheckEvalItemMgtDetail(Map<String, String> param);

	public int doCheckInTemplateItemWeight(Map<String, String> param);

	public List<Map<String, String>> getEvimType(Map<String, String> param);












	public List<Map<String, Object>> doSearchLeftGrid(Map<String, String> param);

	public List<Map<String, Object>> doSearchRightGrid(Map<String, String> param);

	public int doUpdateSTOCEVTMFlag(Map<String, Object> param);

	public int doDeleteSTOCEVTM(Map<String, Object> param);

	public int doDeleteSTOCEVTD(Map<String, Object> param);

	public int doDeleteAllSTOCEVTD(Map<String, Object> param);

	public int doInsertSTOCEVTM(Map<String, String> param);

	public int doInsertSTOCEVTD(Map<String, Object> param);

	public int doUpdateSTOCEVTM(Map<String, String> param);

	public int doUpdateSTOCEVTD(Map<String, Object> param);

	public int checkExistEVTM(Map<String, String> param);

	public int checkExistEVTD(Map<String, Object> param);

	public List<Map<String, Object>> doSearchAppendItem(Map<String, String> param);


}
