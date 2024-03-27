package com.st_ones.evermp.buyer.rq;

import java.util.List;
import java.util.Map;

public interface RQ0300Mapper {



    Map<String, Object> doSetExcelImportItemRfx(Map<String ,Object> grid);
    String getCompanyCdByName(Map<String, Object> grid);
    String getCtrlCd(Map<String,Object> grid);
    String getPlantCd(Map<String,Object> grid);
    String getWhCd(Map<String,Object> grid);

    List<Map<String, Object>> getDecAmtVendorList(Map<String, Object> param);
	List<Map<String, Object>> getDecAmtItemList(Map<String, Object> param);
	void updateDecodeQthd(Map<String, Object> formData);
	void updateDecodeQtdt(Map<String, Object> formData);


	List<Map<String, Object>> getTargetVendor(Map<String, String> param);
	List<Map<String, Object>> getTargetItemList(Map<String, String> param);


	List<Map<String, Object>> getOpenSettleTargetList(Map<String, Object> param);




	Map<String, Object> getRfqHd(Map<String, String> param);



	void chgRfqDate(Map<String, String> formData);
	void closeRfq(Map<String, Object> formData);
    void deleteRFX(Map<String, String> formData);

    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 작성 (RQ0310)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @return
     * @throws Exception
     */
    List<Map<String,Object>> getRfxDtDetailFromPR(Map<String,Object> param);

    void updatePrdtProgress(Map<String, Object> gridData);

    void insertRQHD(Map<String, String> param);
    void updateRQHD(Map<String, String> param);
    void deleteRQDT(Map<String, String> param);
    void insertRQDT(Map<String, Object> param);
    void updateRerfxRqhd(Map<String, String> param);
    void updateRerfxRqdt(Map<String, String> param);

    List<Map<String, Object>> getVendorListFromVnglCvur(Map<String, Object> param);

    String getSignStatus(Map<String, String> formData);

    void insertRQVN(Map<String, Object> gridData);
    void deleteRQVN(Map<String, String> gridData);


    void transfer(Map<String, Object> param);

    Map<String,Object> getRfxHdDetail(Map<String,String> param);
    List<Map<String, Object>> getVendorListByRfx(Map<String, String> formData);
    List<Map<String,Object>> getRfxDtDetail(Map<String, String> formData);
    List<Map<String, Object>> getRqvnByItem(Map<String, Object> gridData);

    void updateRqSignStatus(Map<String, String> param);
    void updateRqSignStatus2(Map<String, String> param);

    void sendRQ(Map<String,Object> param);

    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적요청현황 (RQ0320)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @return
     * @throws Exception
     */
    List<Map<String, Object>> getRfqHdList(Map<String, Object> param);

    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0130)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @return
     * @throws Exception
     */
    List<Map<String, Object>> getQtaList(Map<String, Object> param);


    void saveQtaOpen(Map<String, Object> param);
    void saveQtaOpenDt(Map<String, Object> param);

    List<Map<String, Object>> getSettleItemList_old(Map<String, String> formData);

    List<Map<String, Object>> getSettleItemList(Map<String, Object> param);


    void setDocSettleCancelRqhd(Map<String, String> param);
    void updateRqdtProgress(Map<String,String> param);
    void rejectExec(Map<String,String> formData);

    String getSignStatus2FromRfx(Map<String, String> formData);

    List<Map<String, Object>> getCsInfoByQtNumForDocSettle(Map<String, Object> param);

    void setDocSettleQtdt(Map<String, Object> param);

    void setCancelPrdt(Map<String, String> param);

    void updateRqhdSignStatus2(Map<String,String> param);

    void reRfqRqhd(Map<String, String> param);
    void reRfqRqdt(Map<String, String> param);
    void reRfqRqvn(Map<String, String> param);

    void setItemSettleQtdt(Map<String, Object> param);

    List<Map<String,String>> getQtaNumByRfxnum(Map<String, String> formData);
    void updateSltDate(Map<String,String> param);

    void reRfqRqdtItem(Map<String, String> param);
    void reRfqRqvnItem(Map<String, String> param);


    List<Map<String,Object>> getAdditionalColumnInfos(Map<String,String> param);
    List<Map<String,Object>> doSearchComparisonTable(Map<String,Object> param);

    /********************************************************************************************
     * 업체성정 인터페이스
     */
    List<Map<String,Object>> getSourceFor_SP_GPRO_PROD_CS1(Map<String,String> param);

    /********************************************************************************************
     * 카카오톡, 이메일 수신 발신자 정보
     */
    List<Map<String,String>> getInfoForKakaotalkAndEmail(Map<String,String> param);
 // 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
	void updateSignStatus(Map<String, String> map);
	// 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
	void _doUpdateSignStatus(Map<String, String> map);

	Map<String, String> getRfxInfoHD(Map<String, String> rqhdData);

	List<Map<String, String>> getRfxItemList(Map<String, String> rqhdData);

	List<Map<String, String>> getRfxVendorList(Map<String, String> rqhdData);

	List<Map<String, Object>> getSettleItemListP02(Map<String, String> formData);
}