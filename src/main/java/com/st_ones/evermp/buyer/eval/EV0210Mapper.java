package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0210Mapper {

	public void doInsertEVEM(Map<String, String> params);

	public Map<String, Object> doCheckEVEM(Map<String, String> params);

	public void doInsertEVEU(Map<String, Object> gridUsData);

	public void doDeleteEVEU(Map<String, Object> gridUsData);

	public void doUpdateEVEU(Map<String, Object> gridUsData);

	public int existsEVES(Map<String, Object> gridVendorData);

	public void doInsertEVES(Map<String, Object> gridVendorData);

	public void doDeleteEVES(Map<String, Object> gridVendorData);

	public void deleteEVES(Map<String, String> gridVendorData);


	public void doUpdateEVES(Map<String, Object> gridVendorData);

	public void doUpdateEVEM(Map<String, String> params);

	public int existsEVEU(Map<String, Object> gridUsData);

	public Map<String, String> doSearchEVEM(Map<String, String> param);

	public List<Map<String, Object>> doSearchEVES(Map<String, String> param);

	//public List<Map<String, Object>> doSearchEVEU(Map<String, String> param);

	List<Map<String, Object>> doSearchEVEU(Map<String, Object> formData);





	public void doDeleteEVEM(Map<String, String> params);

	public void doDeleteEVESAll(Map<String, String> params);

	public void doDeleteEVEUAll(Map<String, String> params);

	public void doUpdateProgressEVEU(Map<String, String> params);

	public void doUpdateProgressEVES(Map<String, String> params);

	public void doUpdateProgressEVEM(Map<String, String> params);

	List<Map<String,Object>> getOfVendorInfo(Map<String, String> map);

	List<Map<String,String>> getReceiverMailAddress(Map<String, String> map);

	public List<Map<String, Object>> doSearchDataForEVET(Map<String, String> param);

	public int doInsertEVET(Map<String, Object> param);

	public void doDeleteEVET(Map<String, String> params);


	public List<Map<String, Object>> doSearchExcelEVES(Map<String, Object> param);
	Map<String, Object> doSearchExcelEVES_User(Map<String, Object> param);
	List<Map<String, Object>> doSearchExcelEVEU(Map<String, Object> formData);

}


