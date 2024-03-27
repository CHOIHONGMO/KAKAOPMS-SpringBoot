package com.st_ones.evermp.MY01;

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
 * @File Name : MY01_Mapper.java
 * @author  이연무
 * @date 2018. 01. 30.
 * @version 1.0
 * @see
 */
@Repository
public interface MY01_Mapper {

	/** ******************************************************************************************
     * 공지사항
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> my01001_doSearch(Map<String, String> param);

	void my01001_doDelete(Map<String, Object> gridData);

	/** ******************************************************************************************
     * 공지사항 - 작성
     * @param req
     * @return
     * @throws Exception
     */
	Map<String, Object> my01002_doSearchNoticeInfo(Map<String, String> param);

	void my01002_doSaveCount(Map<String, Object> param);

	void my01002_doInsert(Map<String, String> formData);

	void my01002_doUpdate(Map<String, String> formData);

	/** ******************************************************************************************
     * 납품게시판
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> my01003_doSearch(Map<String, String> param);

	void my01003_doDelete(Map<String, Object> gridData);

	/** ******************************************************************************************
     * 납품게시판 - 작성
     * @param req
     * @return
     * @throws Exception
     */
	Map<String, Object> my01004_doSearchNoticeInfo(Map<String, String> param);

	void my01004_doSaveCount(Map<String, Object> param);

	void my01004_doInsert(Map<String, String> formData);

	void my01004_doUpdate(Map<String, String> formData);

	/** ******************************************************************************************
     * 개인정보관리
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> my01005_doSearchG(Map<String, String> param);

	void my01005_doSaveG(Map<String, Object> gridData);

	void my01005_doDeleteG(Map<String, Object> gridData);

	/** ******************************************************************************************
     * 배송지목록
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> my01006_doSearch(Map<String, String> param);

	/** ******************************************************************************************
     * 배송지목록-NEW
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> my01007_doSearch(Map<String, String> param);

	/** ******************************************************************************************
     * 청구지목록
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> my01008_doSearch(Map<String, String> param);

	/** *****************
	 * My Page > 관심업체관리
	 * ******************/
	List<Map<String, Object>> my01010_doSearch(Map<String, String> param);
	List<Map<String, Object>> my01010_doSearchD(Map<String, String> param);
	
	void my01010_doSave(Map<String, Object> param);
	void my01010_doDelete(Map<String, Object> param);
	
	void my01010_doSaveD(Map<String, Object> param);
    void my01010_doDeleteD(Map<String, Object> param);

}