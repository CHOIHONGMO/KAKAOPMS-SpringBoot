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
 * @File Name : EV0045_Mapper.java 
 * @author  Y 
 * @date 2015.10.30
 * @version 1.0  
 * @see 
 */

import java.util.List;
import java.util.Map;

public interface EV0045Mapper {

//////   SRM_045	//////
	
	Map<String, Object> srm045_doSearch(Map<String, String> param);
	List<Map<String, Object>> srm045_doSearchEVTM(Map<String, String> param);
	public List<Map<String, Object>> doSearchSg(Map<String, String> param);	
	public List<Map<String, Object>> doSearchUs(Map<String, String> param);	
	public Map<String, Object> doCheckMaster(Map<String, String> param);
	
	/** STOCEVVM */
	void srm045_doSaveINSERT_EVVM(Map<String, String> param);
	void srm045_doSaveUPDATE_EVVM(Map<String, String> param);
	public int doDeleteMaster(Map<String, String> param);
	void srm045_doRequestUPDATE_EVVM(Map<String, String> param);
	void srm045_doCancelEVVM(Map<String, String> param);

	void srm045_doCancelEVET(Map<String, String> param);
	void srm045_doCancelEVES(Map<String, String> param);
	
	/** STOCEVSC */
	public int existsEvsc(Map<String, Object> param);
	public int doInsertEvsc(Map<String, Object> param);
	public int doDeleteEvsc(Map<String, Object> param);
	public int doDeleteAllEvsc(Map<String, Object> param);
	public int doUpdateEvsc(Map<String, Object> param);
	
	/** STOCEVVU */
	public int existsEvvu(Map<String, Object> param);
	public int doInsertEvvu(Map<String, Object> param);
	public int doDeleteEvvu(Map<String, Object> param);
	public int doDeleteAllEvvu(Map<String, Object> param);
	public int doUpdateEvvu(Map<String, Object> param);
	void srm045_doRequestUPDATE_EVVU(Map<String, Object> param);
	void srm045_doCancelEVVU(Map<String, Object> param);

	List<Map<String,Object>> getOfVendorInfo(Map<String, String> map);
	
	List<Map<String,String>> getReceiverMailAddress(Map<String, String> map);

/////   /////	

}
