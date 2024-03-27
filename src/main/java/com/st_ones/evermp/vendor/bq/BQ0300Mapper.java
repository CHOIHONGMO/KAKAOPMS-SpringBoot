package com.st_ones.evermp.vendor.bq;

import java.util.List;
import java.util.Map;

public interface BQ0300Mapper {

    /********************************************************************************************
     * 협력사 > 구매관리 > 입찰관리 > 입찰현황 (BQ0310)
     * 처리내용 : (협력사) 입찰 요청 현황을 조회하는 화면
     */

    List<Map<String,Object>> getBdList(Map<String,String> formData);

    int getQtaCnt_BDVO(Map<String,Object> gridData);

    void receiptBDVN(Map<String,Object> gridData);
    void receiptBDVO(Map<String,Object> gridData);

    List<Map<String,String>> getInfoForEmail(Map<String,Object> gridData);

    List<Map<String, Object>> getBddtForOBReceipt(Map<String,Object> gridData);
    int checkParticipationPrevBd(Map<String,Object> gridData);
    void insertBDVNForOBReceipt(Map<String, Object> gridData);
    void updateProgressCdBDVN(Map<String,String> formData);

    Map<String, String> getBqHdSubmitData(Map<String,String> param);
    List<Map<String, Object>> getBqdtSubmitData(Map<String,String> param);

    void saveBQHD(Map<String,String> formData);
    void saveBQDT(Map<String,Object> gridData);

    int checkExistsQtaCreation_BQHD(Map<String,String> formData);
    int checkExistsQtaCreation_BQDT(Map<String,Object> gridData);
    int checkAlreadySubmitedBQ(Map<String,String> formData);

    void submitBQHD(Map<String,String> formData);
    void updateProgressCdBQDT(Map<String,String> formData);

    String getBdRfqCloseFlag(Map<String,String> formData);
    int getBqSubmitExist(Map<String, String> formData);
    int getExistBqNum(Map<String, String> formData);

    void waiveBDVN(Map<String,Object> gridData);
    String checkBDVN_ProgressCd(Map<String,Object> gridData);


    Map<String,String> BQ0310P01_getBDDetail(Map<String,String> param);

    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0130)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @param formData
     * @return
     * @throws Exception
     */
    List<Map<String, Object>> getBqListByVendor(Map<String, String> formData);

	int checkPrgressCd(Map<String, Object> gridData);

}
