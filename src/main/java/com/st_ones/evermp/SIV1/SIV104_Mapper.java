package com.st_ones.evermp.SIV1;

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
 * @File Name : SIV104_Mapper.java 
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0  
 * @see 
 */
@Repository
public interface SIV104_Mapper {

	/** ******************************************************************************************
     * 공급사 : 납품거부 취소
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1040_doSearch(Map<String, String> param);
	
	// 공급사 납품거부
	public void siv1040_doCancelReject(Map<String, Object> map);
	
	/** ******************************************************************************************
     * 공급사 : 납품완료 입력/수정
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1050_doSearch(Map<String, String> param);
	
	// 공급사 납품완료
	public void siv1050_doCompleteUIVDT(Map<String, Object> map);
	public void siv1050_doCompleteYIVDT(Map<String, Object> map);
	public void siv1050_doCompleteUPODT(Map<String, Object> map);
	public void siv1050_doCompleteYPODT(Map<String, Object> map);
	
	// 공급사 납품완료 취소
	public void siv1050_doCancelUIVDT(Map<String, Object> map);
	public void siv1050_doCancelYIVDT(Map<String, Object> map);
	public void siv1050_doCancelUPODT(Map<String, Object> map);
	public void siv1050_doCancelYPODT(Map<String, Object> map);

	List<Map<String, Object>> siv1060_doSearch(Map<String, Object> param);
}