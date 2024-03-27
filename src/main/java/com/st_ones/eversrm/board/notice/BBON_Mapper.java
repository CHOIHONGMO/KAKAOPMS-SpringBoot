package com.st_ones.eversrm.board.notice;

import org.apache.ibatis.annotations.Param;
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
 * @File Name : BBON_Mapper.java 
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 07. 22.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BBON_Mapper {

	List<Map<String, Object>> selectNoticeList(Map<String, String> param);

	int checkNoticeList(Map<String, String> param);

	void createNotice(Map<String, String> param);

	Map<String, String> selectNotice(@Param("noticeNo") String noticeNo);

	void updateNotice(Map<String, String> param);

	void updateNoticeView(@Param("noticeNo") String noticeNo);

	void deleteNotice(Map<String, Object> param);

	int checkTextNo(Map<String, Object> param);

	void resetTextNo(Map<String, String> param);

}
