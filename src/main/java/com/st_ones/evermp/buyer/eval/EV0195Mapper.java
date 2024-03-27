package com.st_ones.evermp.buyer.eval;

/**  
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며, 
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>  
 * @File Name : SRM_195_Mapper.java 
 * @author   
 * @date 2015.11.03
 * @version 1.0  
 * @see 
 */

import java.util.List;
import java.util.Map;

public interface EV0195Mapper {

//////   SRM_195	//////
	
	public List<Map<String, Object>> doSearch(Map<String, String> param);
	
	public Map<String, Object> doCheck(Map<String, Object> param);
	
	public int doRepUserCheck(Map<String, Object> param);	
	
	public int doCompleteEvvu(Map<String, Object> param);
	
	public int doCancelEvvu(Map<String, Object> param);
	
	public int doUpdateEvScore(Map<String, Object> param);	
	
	
/////   /////	

}
