package com.st_ones.evermp.MY03;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : MY03_Mapper.java
 * @author  최홍모
 * @date 2018. 02. 06.
 * @version 1.0
 * @see
 */
@Repository
public interface MY03_Mapper {

	// MY03_010 : 소싱리드타임
	List<Map<String, Object>> my03010_doSearch(Map<String, String> param);
	String my03010_validDateDiff(Map<String, String> param);

	// MY03_020 : 품목생성리드타임
	List<Map<String, Object>> my03020_doSearch(Map<String, String> param);

	// MY03_030 : 납품리드타임
	List<Map<String, Object>> my03030_doSearch(Map<String, String> param);

	// MY03_040 : 납기준수율
	List<Map<String, Object>> my03040_doSearch(Map<String, String> param);
	String my03040_validDateDiff(Map<String, String> param);

	// MY03_050 : 고객사별 실적분석
	List<Map<String, Object>> my03050_doSearch(Map<String, Object> param);

	// MY03_060 : 공급사별 실적분석
	List<Map<String, Object>> my03060_doSearch(Map<String, Object> param);

	// MY03_070 : 품목별 실적분석
	List<Map<String, Object>> my03070_doSearch(Map<String, Object> param);

	// MY03_080 : 일자별접속현황
	List<Map<String, Object>> my03080_doSearch(Map<String, String> param);

	// MY03_090 : 고객사별 매출계획
	List<Map<String, Object>> my03090_doSearch(Map<String, Object> param);

	void my03090_doMerge(Map<String, Object> gridData);

	// MY03_091 : 고객사별 매출현황
	List<Map<String, Object>> my03091_doSearch(Map<String, Object> param);
	// MY03_095 : 고객사별 매출예상현황
	List<Map<String, Object>> my03095_doSearch(Map<String, Object> param);

	// MY03_092 : 고객사별 상품 매출현황
	List<Map<String, Object>> my03092_doSearch(Map<String, Object> param);

	// MY03_093 : 상품별 매출 이익율 관리현황
	List<Map<String, Object>> my03093_doSearch(Map<String, Object> param);

	// MY03_094 : 매출실적 및 매출이익
	List<Map<String, Object>> my03094_doSearch(Map<String, Object> param);

	List<Map<String, String>> getYearList(Map<String, Object> param);

	List<Map<String, String>> getCustList(Map<String, Object> param);
	Object newSaplSeq(Map<String, Object> gridData);

	List<Map<String, Object>>  comboResultSearch();

}