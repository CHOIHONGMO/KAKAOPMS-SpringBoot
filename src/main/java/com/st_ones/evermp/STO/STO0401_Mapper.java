package com.st_ones.evermp.STO;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface STO0401_Mapper {

	List<Map<String, Object>> sto0405_doSearch(Map<String, String> formData);

/** ****************************************************************************************************************
   * 재고관리 > 재고수불마감 > 재고수불마감
   */
	List<Map<String, Object>> sto0402_doSearch(Map<String, String> formData);

	int APARdataCheck(Map<String, String> form);
	int IGIMSdataCheck(Map<String, String> form);
	int IGIMSdataCheck2(Map<String, String> form);

	void sto0402_doDeleteNowData(Map<String, String> param);

	List<Map<String, Object>> getAPARdata(Map<String, String> param);

	void sto0402_insertIGIMS(Map<String, Object> data);

	void sto0402_insertIGIMS2(Map<String, Object> data);

	void sto0402_doDelete(Map<String, String> param);



	/* 재고관리 > 재고수불마감 > 월별 재고수불부 */
	List<Map<String, Object>> sto0404_doSearch(Map<String, String> formData);
	/* 재고관리 > 재고수불마감 > 기간별 재고수불부 */
	List<Map<String, Object>> sto0401_doSearch(Map<String, String> formData);
	/* 재고관리 > 재고수불마감 > 기간별 재고수불마감 상세 */
	List<Map<String, Object>> sto0403_doSearch(Map<String, String> formData);
	/* 재고관리 > 재고수불마감 > 월별 재고수불부 마감 리스트 */
	List<Map<String, Object>> sto0404_getRdList(Map<String, String> param);
	/* 재고관리 > 재고수불마감 > 월별 재고수불부 마감 저장 */
	void insertRd(Map<String, Object> rdData);
	/* 재고관리 > 재고수불마감 > 월별 재고수불부 마감 삭제 */
	void delRd(Map<String, Object> rdData);
	/* 재고관리 > 재고수불마감 > 월별 재고수불부 중복방지익월 */
	int sto0404_overlapCheck(Map<String, String> param);
	/* 재고관리 > 재고수불마감 > 월별 재고수불부 삭제리스트조회 */
	List<Map<String, Object>> sto0404_deleteList(Map<String, String> param);
	/* 재고관리 > 재고수불마감 > 월별 재고수불부 중복방지전월 */
	List<Map<String, Object>> sto0404_overlapBefCheck(Map<String, String> param);

	void sto0402_deleteIGIMS(Map<String, String> form);

	List<Map<String, Object>> sto0401p01_doSearch(Map<String, String> formData);

	List<Map<String, Object>> sto0406_doSearch(Map<String, String> formData);




















}
