package com.st_ones.evermp.buyer.cn;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface CN0100Mapper {
    List<Map<String, Object>> doSearchTargetExec(Map<String, String> param);


    List<Map<String, Object>> getBaseRfqVendor(Map<String, Object> param);
    List<Map<String, Object>> doSearchCnvd(Map<String, Object> param);

    List<Map<String, Object>> getBaseRfqItem(Map<String, Object> param);
    List<Map<String, Object>> doSearchCndt(Map<String, Object> param);

    List<Map<String, Object>> getCnpyList(Map<String, Object> param);

    List<Map<String, Object>> getExecList(Map<String, Object> param);



    public String getOldSignStatus(Map<String, String> formData);
    int getChkExec(Map<String, Object> gridData);


    Map<String, String> getCnhd(Map<String, String> param);



    void doRQExcept(Map<String, Object> gridData);
    void doRQExceptRqdt(Map<String, Object> gridData);
    void doRQExceptDt(Map<String, Object> gridData);

    void doBDExcept(Map<String, Object> gridData);
    void doBDExceptRqdt(Map<String, Object> gridData);
    void doBDExceptDt(Map<String, Object> gridData);




    void saveCnhd(Map<String, String> gridData);
    void delCndt(Map<String, String> gridData);
    void saveCndt(Map<String, Object> gridData);

    void delCnvd(Map<String, String> gridData);
    void saveCnvd(Map<String, Object> gridData);

    void delCnpy(Map<String, String> gridData);
    void saveCnpy(Map<String, Object> gridData);


    void deleteCnhd(Map<String, String> gridData);
    void deleteCndt(Map<String, String> gridData);
    void deleteCnpy(Map<String, String> gridData);
    void deleteCnvd(Map<String, String> gridData);


    void upsSignResult(Map<String, String> gridData);



    List<Map<String, Object>> getPoTargetCnvd(Map<String, String> param);
    List<Map<String, Object>> getInfoTargetCnvd(Map<String, String> param);





    void createPohd(Map<String, Object> gridData);
    void createPodt(Map<String, Object> gridData);
    void createPopy(Map<String, Object> gridData);

    void insStocInfo(Map<String, Object> gridData);



    List<Map<String, String>> getSapInfoTargetCnvd(Map<String, String> param);


    void upsErpInfoNum(Map<String, String> gridData);

    String checkCn(Map<String, Object> param);

    List<Map<String, Object>> CN0140_doSearch(Map<String, Object> formData);


	void createMtgl(Map<String, Object> data);


	void createMtgc(Map<String, Object> data);


	void createYINFH(Map<String, Object> data);


	void createUINFH(Map<String, Object> data);


	List<Map<String, Object>> getTargetYInfhList(Map<String, String> map);


	void updateSignYInfh(Map<String, String> map);

	List<Map<String, Object>> chkYInfo(Map<String, Object> data);

	void updateValidTodateYInfo(Map<String, Object> data);

	void copyYInfhToYInfo(Map<String, Object> data);

	void createStoYInfo(Map<String, Object> data);

	void createStoUInfo(Map<String, Object> data);

	void doUpdateContInfoCNDT(Map<String, Object> data);

	void doReqConfirmUpo(Map<String, Object> data);

	void createDohd(Map<String, Object> data);

	void createDodt(Map<String, Object> data);

	String checEexeckCnt(Map<String, String> param);

	// 고객사 판가정보 DGNS I/F
	String getCustErpIfFlag(Map<String, Object> param);


	List<Map<String, Object>> getHtmlCnpyList(Map<String, String> formData);


	List<Map<String, Object>> doHtmlSearchCnvd(Map<String, Object> paramObj);


	void gwSignResult(Map<String, String> signData);


	int gbunFlag(Map<String, String> formData);



	Map<String, Object> getBlsmHtml(Map<String, String> formData);


	Map<String, Object> getLocalItemInfo(Map<String, Object> data);


	List<Map<String, Object>> getPuVendorList(Map<String, String> formData);


	List<Map<String, Object>> getPuBdItemList(Map<String, Object> puVendor);


	List<Map<String, Object>> getPuRqItemList(Map<String, Object> puVendor);


	List<Map<String, Object>> doHtmlChCndt(Map<String, String> formData);


	List<Map<String, Object>> getHtmlCnpyListSum(Map<String, String> formData);

}