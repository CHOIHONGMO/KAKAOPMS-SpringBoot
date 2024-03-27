package com.st_ones.evermp.IM02;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface IM0201_Mapper {


	Map<String, String> chkInfoValid(Map<String, Object> param);



	/** *****************
     * 표준납기관
     * ******************/
	List<Map<String, Object>> im01010_doSearch(Map<String, String> param);

	void im01010_doUpdate(Map<String, Object> gridData);

	/** *****************
     * 품목별 판가관리
     * ******************/
	List<Map<String, Object>> im02010_doSearch(Map<String, String> param);

	void deleteDeleteUinfo(Map<String, Object> gridData);
	void deleteDeleteYinfo(Map<String, Object> gridData);

	/** *****************
     * 판가등록
     * ******************/
	Map<String, Object> doSetExcelImportUinfo(Map<String ,Object> grid);

	List<Map<String, Object>> im02011_doSearch(Map<String, String> param);

	Map<String, Object> doGetPrice(Map<String, String> param);

	List<Map<String, Object>> doCheckExistUinfo(Map<String, Object> gridData);

	void doInsertUinfo(Map<String, Object> gridData);

	void doUpdateUinfo(Map<String, Object> gridData);

	void doInsertUinfh(Map<String, Object> gridData);

	/** *****************
     * 품목검색
     * ******************/
	List<Map<String, Object>> im02012_doSearch(Map<String, String> param);

	/** *****************
     * 분류체계별관리
     * ******************/
	List<Map<String, Object>> im02020_doSearch(Map<String, String> param);

	/** *****************
	 * 분류체계별 이력
	 * ******************/
	List<Map<String, Object>> im02021_doSearch(Map<String, String> param);

	String getLabel(Map<String, String> param);

	/** *****************
	 * 분류체계별 수정
	 * ******************/
	List<Map<String, Object>> im02022_doSearch(Map<String, String> param);

	void doUpdateCATR(Map<String, Object> param);

	void insertCATH(Map<String, Object> param);

	/** *****************
	 * 분류체계별 신규등록
	 * ******************/
	Map<String, String> im02023_doSearchData(Map<String, String> param);

	int doCheckExist(Map<String, String> param);

	void doInsertCATR(Map<String, String> param);


	List<Map<String, Object>> im02013_doSearch(Map<String, String> param);



	String chkItem(Map<String, Object> gridData);














	void block(Map<String, Object> param);
	void blockCancel(Map<String, Object> param);

}