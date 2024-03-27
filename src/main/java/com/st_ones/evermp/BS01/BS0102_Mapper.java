package com.st_ones.evermp.BS01;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * 2018. 08. 07 kkj
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface BS0102_Mapper {

	List<Map<String, Object>> bs01010_doSearch(Map<String, String> param);

	void bs01010_doSave(Map<String, Object> gridData);

    List<Map<String, Object>> bs01010_doSearchLineCd(Map<String, String> param);

    void bs01010_doSaveLine(Map<String, Object> gridData);

    void bs01010_doDelLine(Map<String, Object> gridData);

	List<Map<String, Object>> bs01010_doSearchAppAgr(Map<String, String> param);

	void doSaveAppAgr(Map<String, Object> gridData);

	void bs01010_doDelAppAgr(Map<String, Object> gridData);

	List<Map<String, Object>> bs01010_doSearchUR3(Map<String, String> param);

	void bs01010_doSaveREF(Map<String, Object> gridData);

	void bs01010_doDelRef(Map<String, Object> gridData);

	List<Map<String,Object>> bs01011_doSearch(Map<String, String> formData);

	int bs01011_doSave(Map<String, Object> gridDatum);

	int bs01011_doDelete(Map<String, Object> gridDatum);

	/** *****************
	 * 운영사 > 관리그룹
	 * ******************/
	List<Map<String, Object>> bs01020_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01020_doSearchD(Map<String, String> param);
	void bs01020_doSave(Map<String, Object> param);
	void bs01020_doDelete(Map<String, Object> param);
	int existsMNGD(Map<String, Object> gridData);
	void bs01020_doSaveCust(Map<String, Object> param);
	void bs01020_doDeleteCust(Map<String, Object> param);

	/** *****************
	 * 운영사 > 결재그룹
	 * ******************/
	List<Map<String, Object>> bs01021_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01021_doSearchD(Map<String, String> param);
	void bs01021_doSave(Map<String, Object> param);
	void bs01021_doDelete(Map<String, Object> param);
	int existsAPGD(Map<String, Object> gridData);
	void bs01021_doSaveCust(Map<String, Object> param);
	void bs01021_doDeleteCust(Map<String, Object> param);

	/** *****************
	 * 운영사 > 고객사별 코스트센터
	 * ******************/
	List<Map<String, Object>> bs01030_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01030_doSearchD(Map<String, String> param);
	int existsCOST(Map<String, Object> gridData);
	int insertStouCost(Map<String, Object> gridData);
	int updateStouCost(Map<String, Object> gridData);
	void bs01030_doDeleteDT(Map<String, Object> param);

	/** *****************
	 * 운영사 > 고객사별 플랜트관리
	 * ******************/
	List<Map<String, Object>> bs01040_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01040_doSearchD(Map<String, String> param);
	Map<String, Object> bs01040_doSearchPlant(Map<String, String> param);
	void bs01040_doSaveCUPL(Map<String,String> form);
	String bs01040_getPrevPlantCd(Map<String,String> param);
	void bs01040_doSaveCUBL(Map<String,String> form);
	void bs01040_doDeleteCUPL(Map<String,String> form);
	void bs01040_doDeleteCUBL(Map<String,String> form);
	int existsCUPL(Map<String, Object> gridData);
	int insertStocCupl(Map<String, Object> gridData);
	int updateStocCupl(Map<String, Object> gridData);
	void bs01040_doDeleteDT(Map<String, Object> param);

	/** *****************
	 * 운영사 > 고객사별 배송지관리
	 * ******************/
	List<Map<String, Object>> bs01050_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01050_doSearchD(Map<String, String> param);
	int insertStocCsdm(Map<String, Object> gridData);
	int updateStocCsdm(Map<String, Object> gridData);
	void bs01050_doDeleteDT(Map<String, Object> param);
	void bs01050_doDeleteCSDM(Map<String, Object> param);

	/** *****************
	 * 운영사 > 고객사별 청구지관리
	 * ******************/
	List<Map<String, Object>> bs01060_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01060_doSearchD(Map<String, String> param);
	int insertStocCubl(Map<String, Object> gridData);
	int updateStocCubl(Map<String, Object> gridData);
	void bs01060_doDeleteDT(Map<String, Object> param);
	void bs01060_doDeleteCUBL(Map<String, Object> param);

	/** *****************
	 * 운영사 > 그룹관리자
	 * ******************/

    List<Map<String, Object>> bs01022_doSearch(Map<String, String> param);
	List<Map<String, Object>> bs01022_doSearchD(Map<String, String> param);

	void bs01022_doSave(Map<String, Object> grid);
	void bs01022_doDeleteH(Map<String, Object> param);
	void bs01022_doDeleteD(Map<String, Object> param);
	int existsMUCD(Map<String, Object> gridData);
	void bs01022_doSaveUser(Map<String, Object> param);
	void bs01022_doDeleteUser(Map<String, Object> param);

	/** *****************
	 * 운영사 > 고객사 결재경로관리
	 * ******************/
	List<Map<String, Object>> bs01080_doSearchUser(Map<String, String> param);

	Map<String, String> bs01080_doSearchPathInfo(Map<String, String> param);

    List<Map<String, Object>> bs01080_doSearchPathList(Map<String, String> param);

	String getPathNo(Map<String, String> formData);

	void bs01080_doMerge(Map<String, String> formData);

	void bs01080_doDeleteRULM(Map<String, String> formData);

	void bs01080_doDeleteLULP(Map<String, String> formData);

	void bs01080_doInsertPathDetail(Map<String, Object> gridData);


	/** *****************
	 * 운영사 > 고객사 승인대기목록
	 * ******************/


	void bS01_090_doReject(Map<String,Object> grid);

	List<Map<String, Object>> bS01_090_doSearch(Map<String, Object> paramObj);

}