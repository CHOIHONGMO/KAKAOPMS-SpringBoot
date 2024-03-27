package com.st_ones.evermp.MY02;

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
 * @File Name : MY02_Mapper.java 
 * @author  이연무
 * @date 2018. 02. 06.
 * @version 1.0  
 * @see 
 */
@Repository
public interface MY02_Mapper {

	/** ******************************************************************************************
     * 미결함, 기결함
     * @param req
     * @return
     * @throws Exception
     */
	List<Map<String, Object>> mailBox_doSearch(Map<String, String> param);

	/** ******************************************************************************************
	 * 상신함
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> my02005_doSearch(Map<String, String> param);

	/** ******************************************************************************************
	 * 결재경로관리
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> my02007_doSearch(Map<String, String> param);

	void deletePath(Map<String, Object> gridData);

	void deletePathDetail(Map<String, Object> gridData);

	/** ******************************************************************************************
	 * 결재경로등록
	 * @param req
	 * @return
	 * @throws Exception
	 */
	List<Map<String, Object>> my02008_doSearchDT(Map<String, String> param);

	String getPathNo(Map<String, String> formData);

	void insertPath(Map<String, String> formData);

	void updatePath(Map<String, String> formData);

	void deleteLULP(Map<String, String> formData);

	void insertPathDetail(Map<String, Object> gridData);

}
