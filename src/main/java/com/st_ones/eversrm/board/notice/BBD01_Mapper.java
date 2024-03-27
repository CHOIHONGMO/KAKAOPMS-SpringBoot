package com.st_ones.eversrm.board.notice;

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
 */
@Repository
public interface BBD01_Mapper {

	/********************************************************************************************
	 * 운영사 > My Page > My Page > 공지사항  (MY01_002 > BBD01_010)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> BBD01_010_doSearch(Map<String, String> param);

	void BBD01_010_doDelete(Map<String, Object> gridData);


	/********************************************************************************************
	 * 운영사 > My Page > My Page > 공지사항-작성  (MY01_002 > BBD01_011)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	Map<String, Object> BBD01_011_doSearchNoticeInfo(Map<String, String> param);

	void BBD01_011_doSaveCount(Map<String, Object> param);

	void BBD01_011_doInsert(Map<String, String> formData);

	void BBD01_011_doUpdate(Map<String, String> formData);


	/********************************************************************************************
	 * 운영사 > My Page > My Page > 게시판  (MY01_003 > BBD01_020)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> BBD01_020_doSearch(Map<String, String> param);

	void BBD01_020_doDelete(Map<String, Object> gridData);


	/********************************************************************************************
	 * 운영사 > My Page > My Page > 게시판-작성  (MY01_004 > BBD01_021)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	Map<String, Object> BBD01_021_doSearchNoticeInfo(Map<String, String> param);

	void BBD01_021_doSaveCount(Map<String, Object> param);

	void BBD01_021_doInsert(Map<String, String> formData);

	void BBD01_021_doUpdate(Map<String, String> formData);

	/********************************************************************************************
	 * 운영사 > My Page > My Page > ESH 게시판  (BBD01_030)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> BBD01_030_doSearch(Map<String, String> param);

	void BBD01_030_doDelete(Map<String, Object> gridData);

	/********************************************************************************************
	 * 운영사 > My Page > My Page > ESH 게시판-작성  (BBD01_031)
	 * @param param
	 * @return
	 * @throws Exception
	 */
	Map<String, Object> BBD01_031_doSearchNoticeInfo(Map<String, String> param);

	void BBD01_031_doSaveCount(Map<String, Object> param);

	void BBD01_031_doInsert(Map<String, String> formData);

	void BBD01_031_doUpdate(Map<String, String> formData);


}