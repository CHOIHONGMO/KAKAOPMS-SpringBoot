package com.st_ones.evermp.vendor.cont;

import java.util.List;
import java.util.Map;

public interface CT0600Mapper {
    List<Map<String, Object>> doSearchContractProgressStatus(Map<String, String> param);



    List<Map<String, String>> getContractAllContents(Map<String, String> formData);

    List<Map<String, Object>> ecob0050_doSearchSupAttachFileInfo(Map<String, String> param);

    List<Map<String, Object>> ecob0050_doSearchPayInfo(Map<String, String> param);

    int doUpdateContractStatusECCT(Map<String, String> formData);

    int doSupplyReceiptEcct(Map<String, String> formData);



    int doDeleteSignedData(Map<String, String> formData);

    int doInsertSignedData(Map<String, String> formData);

    int doMergeRejectHistoryECRJ(Map<String, String> formData);

    int doUpdateFileNumECAT(Map<String, Object> gridData);

    Map<String, String> getContractFormTypeAndBusinessUserEmail(Map<String, String> formData);

    void doDeleteFileECRL(Map<String, String> param);

    List<Map<String, Object>> getFileFormList(Map<String, String> formData);

    List<Map<String, Object>> getFileInfoList(Map<String, String> formData);

    void doInsertFileECRL(Map<String, Object> data);



    void contReceiptOrReject(Map<String, Object> data);
    void poReceiptOrReject(Map<String, Object> data);



	Map<String, String> getEcInfo(Map<String, String> formData);



	void doUpdateEc(Map<String, String> formData);



	void updateSaInfo(Map<String, String> dataInfo);



	void GW_TEST(Map<String, String> contMap);



	void updateRecvSaInfo(Map<String, String> contMap);



	int overlapRecvInfo(Map<String, String> contMap);



	int receiptCheck(Map<String, String> form);


}