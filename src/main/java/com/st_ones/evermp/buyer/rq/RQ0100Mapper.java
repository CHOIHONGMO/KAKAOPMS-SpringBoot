package com.st_ones.evermp.buyer.rq;

import java.util.List;
import java.util.Map;

public interface RQ0100Mapper {

	List<Map<String, Object>> getDecAmtVendorList(Map<String, Object> param);
	void updateDecodeQthd(Map<String, Object> formData);
	void updateDecodeQtdt(Map<String, Object> formData);


	List<Map<String, Object>> getTargetVendor(Map<String, String> param);
	List<Map<String, Object>> getTargetItemList(Map<String, String> param);


	List<Map<String, Object>> getRfqHdList(Map<String, String> param);

	List<Map<String, Object>> getOpenSettleTargetList(Map<String, String> param);

	List<Map<String, Object>> getRfqQtaList(Map<String, String> param);



	Map<String, Object> getRfqHd(Map<String, String> param);



	void chgRfqDate(Map<String, String> formData);
	void closeRfq(Map<String, Object> formData);
    void deleteRFX(Map<String, String> formData);

    //---------------------------------------------------------------------

    void updatePrdtProgress(Map<String, Object> gridData);

    void insertRQHD(Map<String, String> param);
    void updateRQHD(Map<String, String> param);
    void deleteRQDT(Map<String, Object> param);
    void insertRQDT(Map<String, Object> param);
    void updateRQDT(Map<String, Object> param);

    List<Map<String, Object>> getRqdtByRfxNum(Map<String, String> formData);

    List<Map<String, Object>> getVendorListDefault(Map<String, Object> param);

    String getSignStatus(Map<String, String> formData);

    void insertRQVN(Map<String, Object> gridData);
    void deleteRQVN(Map<String, String> gridData);


    void transfer(Map<String, Object> param);

    Map<String,Object> getRfxHdDetail(Map<String,String> param);
    List<Map<String,Object>> getRfxDtDetail(Map<String, String> formData);
    List<Map<String, Object>> getRqvnByItem(Map<String, Object> gridData);

    void updateRqSignStatus(Map<String, String> param);

    void sendRQ(Map<String,Object> param);

    List<String> getVendorCdListByRfx(Map<String,Object> formData);
    List<Map<String,Object>> getVendorUserList(Map<String,Object> data);


    /********************************************************************************************
     * 구매사> 구매관리 > 견적/입찰관리 > 견적서 현황 (RQ0130)
     * 처리내용 : (구매사) 견적 진행 현황을 조회하는 화면
     * @param formData
     * @return
     * @throws Exception
     */
    List<Map<String, Object>> getQtaList(Map<String, String> formData);


    void saveQtaOpen(Map<String, Object> param);


    List<Map<String, Object>> getSettleItemList(Map<String, String> formData);


    void setDocSettleCancelRqhd(Map<String, String> param);
    void setDocSettleQtdt(Map<String, String> param);

    void setCancelPrdt(Map<String, String> param);



    void reRfqRqhd(Map<String, String> param);
    void reRfqRqdt(Map<String, String> param);
    void reRfqRqvn(Map<String, String> param);


    void setItemSettleQtdt(Map<String, Object> param);



    void reRfqRqdtItem(Map<String, String> param);
    void reRfqRqvnItem(Map<String, String> param);


}