package com.st_ones.eversrm.board.qna;

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
 * @File Name : BBOQ_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BBOQ_Mapper {

	List<Map<String, Object>> doSearchQnaList(Map<String, String> param);

	void doInsertQna(Map<String, String> formData);

	void doUpdateQna(Map<String, String> formData);

	void doUpdateHITQna(Map<String, String> formData);

	void doDeleteQna(Map<String, String> formData);

	Map<String, String> doReviewQna(Map<String, String> param);

}