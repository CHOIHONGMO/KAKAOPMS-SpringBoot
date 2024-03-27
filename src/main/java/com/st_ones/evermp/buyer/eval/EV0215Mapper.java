package com.st_ones.evermp.buyer.eval;

import java.util.List;
import java.util.Map;

public interface EV0215Mapper {

	List<Map<String, Object>> doImportSrm(Map<String, String> param);
	Map<String, Object> doSearchEVTM(Map<String, String> param);
	Map<String, Object> doSearchVNGL(Map<String, String> param);
	Map<String, Object> doSearchUSER(Map<String, String> param);
}
