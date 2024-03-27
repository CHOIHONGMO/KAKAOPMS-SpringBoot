package com.st_ones.evermp.vendor.qt;

import java.util.List;
import java.util.Map;

public interface QT0300Mapper {

    List<Map<String,Object>> getRqList(Map<String,Object> formData);

    void receiptRQVN(Map<String,Object> gridData);
    void updateProgressCdRQVN(Map<String,String> formData);

    Map<String, String> getQtHdSubmitData(Map<String,String> param);
    List<Map<String, Object>> getQtdtSubmitData(Map<String,String> param);

    void insertQTHD(Map<String,String> formData);
    void insertQTDT(Map<String,Object> gridData);
    void updateQTHD(Map<String,String> formData);
    void updateQTDT(Map<String,Object> gridData);

    int checkExistsQtaCreation_QTHD(Map<String,String> formData);
    int checkExistsQtaCreation_QTDT(Map<String,Object> gridData);
    int checkAlreadySubmitedQTA(Map<String,String> formData);

    String getQtnumByRqandVendor(Map<String, String> formData);

    void submitQTHD(Map<String,String> formData);
    void submitQTDT(Map<String,String> formData);

    String getRfqCloseFlag(Map<String,String> formData);

    int getCountExistSubmitQtByRq(Map<String,String> formData);

    void waiveRQVN(Map<String,Object> gridData);
    String checkRqvnProgressCd(Map<String,Object> gridData);

    Map<String,String> getMailInfo(Map<String,String> param);


    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0130)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @param formData
     * @return
     * @throws Exception
     */
    List<Map<String, Object>> getQtaListByVendor(Map<String, Object> formData);


}
