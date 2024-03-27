package com.st_ones.evermp.buyer.bd;

import java.util.List;
import java.util.Map;

public interface BD0300Mapper {


    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 작성 (BD0310)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @return
     * @throws Exception
     */

    Map<String, Object> doSetExcelImportItemRfx(Map<String,Object> grid);

    List<Map<String,Object>> getRfxDtDetailFromPR(Map<String,Object> param);

    void updatePrdtProgress(Map<String, Object> gridData);

    void insertBDHD(Map<String, String> param);
    void updateBDHD(Map<String, String> param);
    void updateBDHDDEL(Map<String, String> param);


    void deleteBDAN(Map<String, String> param);
    void insertBDAN(Map<String, String> param);

    void deleteBDDT(Map<String, String> param);
    void insertBDDT(Map<String, Object> param);
    void updateBDDTDEL(Map<String, String> param);

    void saveBDVO(Map<String, Object> param);
    void deleteBDVO(Map<String, String> param);

    void updateRerfxBdhd(Map<String, String> param);
    void updateRerfxBddt(Map<String, String> param);


    List<Map<String, Object>> getVendorListFromVnglCvur(Map<String, Object> param);

    String getSignStatus(Map<String, String> formData);

    void deleteBDVN(Map<String, String> gridData);
    void insertBDVN(Map<String, Object> gridData);
    void updateBDVNDEL(Map<String, String> param);

    void transferBdCtrlUser(Map<String, Object> param);

    Map<String,Object> getBdHdDetail(Map<String,String> param);
    List<Map<String, Object>> getVendorListByBdRfx(Map<String, String> formData);
    List<Map<String,Object>> getBdDtDetail(Map<String, String> formData);
    List<Map<String, Object>> getBdvnByItem(Map<String, Object> gridData);

    void updateBdSignStatus(Map<String, String> param);
    void updateBdSignStatus2(Map<String, String> param);
    void sendBD(Map<String,Object> param);


    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 입찰요청 현황 (BD0320)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @return
     * @throws Exception
     */

    List<Map<String, Object>> getBdHdList(Map<String, Object> param);
    List<Map<String, Object>> getRfqQtaList(Map<String, String> param);


    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 입찰서 현황 (BD0330)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     */
    List<Map<String, Object>> getBqList(Map<String, Object> param);

    void setDocSettleBqdt(Map<String, Object> param);

    void setCancelPrdt(Map<String, String> param);

    void updateBdhdSignStatus2(Map<String,String> param);


    void setItemSettleBqdt(Map<String, Object> param);

    List<Map<String,String>> getBqNumListByBdNum(Map<String, String> formData);
    void updateBqSltDate(Map<String,String> param);


    List<Map<String,Object>> getAdditionalColumnInfos(Map<String,String> param);
    List<Map<String,Object>> doSearchComparisonTable(Map<String,Object> param);


    /********************************************************************************************
     * 구매사> 구매관리 > 입찰관리 > 협력업체 선정 현황 (BD0340)
     * 처리내용 : (구매사) 입찰 협력업체를 선정하는 화면
     */
    List<Map<String, Object>> getBdOpenSettleTargetList(Map<String, Object> param);

    void saveBdOpenHd(Map<String, Object> param);
    void saveBdOpenDt(Map<String, Object> param);

    List<Map<String, Object>> getDecAmtVendorListForBdOpen(Map<String, Object> param);
    List<Map<String, Object>> getDecAmtItemListForBdOpen(Map<String, Object> param);
    void updateDecodeBqhd(Map<String, Object> formData);
    void updateDecodeBqdt(Map<String, Object> formData);

    //개찰 시 협상중인 업체 개찰
    Map<String, Object> getDecAmtVendorListForNego(Map<String, Object> param);


    /**구매사> 구매관리 > 입찰관리 > 협력업체 선정 총액별 (BD0340P01) **/
    List<Map<String, Object>> getBqDocVendorListByBd(Map<String, String> param);
    List<Map<String, Object>> getBqDocItemListByBq(Map<String, String> param);

    String getSignStatus2FromBD(Map<String, String> formData);
    void updateBdhdProgress(Map<String, String> param);
    void updateBddtProgress(Map<String,String> param);
    void rejectBq(Map<String,String> formData);



    /**구매사> 구매관리 > 입찰관리 > 협력업체 선정 품목별 (BD0340P02) **/
    List<Map<String, Object>> getSettleItemListByBd(Map<String, String> formData);


    /**구매사> 구매관리 > 입찰관리 > 협력업체 평가 요청 (BD0340P04) **/
    List<Map<String,Object>> BD0340P04_getVendorListForBDEV(Map<String,String> formData);
    void updateEvNumtoBDVN(Map<String,String> formData);

    //안쓰는거 나중에 정리
    List<Map<String,Object>> getEveuListForBD(Map<String,String> praam);
    void insertEVEN(Map<String, String> formData);
    void deleteEVEU(Map<String, String> formData);
    void insertEVEU(Map<String, Object> grid);
    List<Map<String,Object>> getVendorDistinctByBD(Map<String,String> formData);
    List<Map<String,Object>> getEveuByBD(Map<String,String> formData);
    Map<String,Object> getBdHdForEV(Map<String,String> param);



    /********************************************************************************************
     * 평가항목 필요한 목록
     */
    List<Map<String,String>> getEVScoreByEVT(Map<String,String> param);
    Map<String,String> getBdInfoForEV(Map<String,Object> param);
    void updateEvResultBDVN(Map<String,Object> param);

    List<Map<String,String>> getEVScoreInfoByEVNUM(Map<String,Object> param);
    List<Map<String,String>> getEveeForEVResult(Map<String,Object> grid);

    /********************************************************************************************
     * BD0340P05
     */
    List<Map<String,Object>> getVendorInfoForBDEV(Map<String,String> formData);
    List<Map<String,Object>> getItemInfoForBDEV(Map<String,String> param);
    void BD0340P05_updateBDVN_NegoResultType(Map<String,Object> param);
    void BD0340P05_updateBDHD_progressCd(Map<String,Object> param);
    void BD0340P05_updateBDDT_progressCd(Map<String,Object> param);


    /********************************************************************************************
     * BD0340P06
     */
    void bd0340P06_updateBDVN_reBid(Map<String,String> param);
    void bd0340P06_insertBDVO(Map<String,String> formData);

    /********************************************************************************************
     * 이메일 수신 발신자 정보
     */
    List<Map<String,String>> getInfoForEmail(Map<String,String> param);
    /********************************************************************************************
     * BD0340 상세보기
     */
	List<Map<String, Object>> getBDdtSubmitData(Map<String, String> param);
	 /********************************************************************************************
     * BD0350 조회
     */
	List<Map<String, Object>> getBdHdAnList_old(Map<String, String> formData);

	List<Map<String, Object>> getBdHdAnList(Map<String, Object> param);

	List<Map<String, Object>> getBdVnList(Map<String, String> formData);

	void updateBdVn(Map<String, Object> gridT);

	void updateBdAn(Map<String, String> formData);

	Map<String, String> getRfxInfoHD(Map<String, String> rqhdData);

	List<Map<String, String>> getRfxItemList(Map<String, String> rqhdData);

	List<Map<String, String>> getRfxVendorList(Map<String, String> rqhdData);
	/********************************************************************************************
     * BD0360 조회
     */
	List<Map<String, Object>> getBDdtSubmitData_0360(Map<String, Object> param);

	int gbunFlag(Map<String, String> formData);

	List<Map<String, Object>> getVendorListHtml(Map<String, String> param);

	void gwSignResult(Map<String, String> signData);

	Map<String, Object> getBlsmHtml(Map<String, String> formData);

	List<Map<String, Object>> getBDdtSubmitDataR_0360(Map<String, Object> paramObj);

}