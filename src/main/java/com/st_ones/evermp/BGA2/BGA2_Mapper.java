package com.st_ones.evermp.BGA2;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BGA2_Mapper {

	List<Map<String, Object>> bga2010_doSearch(Map<String, String> param);

	void bga2010_doGrSaveGIDT(Map<String, Object> gridData);

	void bga2010_doGrSaveUIVDT(Map<String, Object> gridData);

	int bga2010_doSearchTOT_GR_QTY(Map<String, Object> gridData);

	void bga2010_doGrSaveYPODT(Map<String, Object> gridData);

	void bga2010_doGrSaveUPODT(Map<String, Object> gridData);

	List<Map<String, Object>> bga2020_doSearch(Map<String, String> param);

  //void bga2010_doGrSaveMMRS(Map<String, Object> gridData); 수불업데이트 미사용

	/* 출고취소 */
	void bga2010_doGiCancelGIDT(Map<String, Object> gridData);

	void bga2010_doGiCancelMMRS(Map<String, Object> gridData);

	List<Map<String, Object>> bga2030_doSearch(Map<String, String> param);
}
