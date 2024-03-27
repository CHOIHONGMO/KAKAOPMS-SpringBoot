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
 * @File Name : SIV103_Mapper.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */
@Repository
public interface SIV103_Mapper {

	/** ******************************************************************************************
     * 공급사 : 납품서 수정/삭제
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1030_doSearch(Map<String, String> param);


	public int chkUivdt(Map<String, Object> param);

	public int chkGrdt(Map<String, Object> param);


	// 공급사 납품서 수정
	public void siv1030_doUpdateUIVHD(Map<String, Object> gridData);
	public void siv1030_doUpdateYIVHD(Map<String, Object> gridData);
	public void siv1030_doUpdateUIVDT(Map<String, Object> gridData);
	public void siv1030_doUpdateYIVDT(Map<String, Object> gridData);
	public void siv1030_doUpdateUPODT(Map<String, Object> gridData);
	public void siv1030_doUpdateYPODT(Map<String, Object> gridData);

	// 공급사 납품서 삭제
	public void siv1030_doDeleteUIVDT(Map<String, Object> gridData);
	public void siv1030_doDeleteYIVDT(Map<String, Object> gridData);
	public void siv1030_doDeleteUPODT(Map<String, Object> gridData);
	public void siv1030_doDeleteYPODT(Map<String, Object> gridData);

	// 납품서 변경정보 가져오기
	public Map<String, Object> getInvChangeHeaderInfo(Map<String, Object> param);
	public List<Map<String, Object>> getInvChangeDetailInfo(Map<String, Object> param);













	public void siv1030_doUpdateUIVDT2(Map<String, Object> gridData);
	public void siv1030_doUpdateYIVDT2(Map<String, Object> gridData);

}