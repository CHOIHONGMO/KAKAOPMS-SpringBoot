package com.st_ones.evermp.BOD1;

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
 * @File Name : BOD105_Mapper.java 
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0  
 * @see 
 */
@Repository
public interface BOD105_Mapper {

	/** ******************************************************************************************
     * 고객사 : 주문진행현황
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> bod1050_doSearch(Map<String, Object> param);

	List<Map<String, Object>> bod1060_doSearch(Map<String, Object> param);
}