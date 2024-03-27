package com.st_ones.evermp.buyer.cont;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
@Repository
public interface CT0300Mapper {

    List<Map<String, Object>> etcContSearch(Map<String, Object> param);

    List<Map<String, Object>> getItemUnitPrcList(Map<String, Object> param);
    List<Map<String, Object>> getValidTargetContList(Map<String, Object> param);

    List<Map<String, Object>> doSearchRfqItem(Map<String, String> param);

    List<Map<String, Object>> ecoa0040_doSearch(Map<String, Object> param);

    List<Map<String, Object>> ecoa0041_doSearch(Map<String, String> param);

    void doUpdateMIGY(Map<String, Object> gridData);

    Map<String, Object> checkExistContData(Map<String, Object> param);

    void doMergeErpContGY(Map<String, Object> data);

    void doDeleteErpContSW(Map<String, Object> data);

    void doCopyErpContSW(Map<String, Object> data);

    void doDeleteErpContGI(Map<String, Object> data);

    void doCopyErpContGI(Map<String, Object> data);

    void doExcept(Map<String, Object> gridData);

    void doExceptRqdt(Map<String, Object> gridData);

    void doExceptDt(Map<String, Object> gridData);

    void saveETcInfo(Map<String, Object> gridData);

    int getEcdtCntByRfxnum(Map<String, Object> gridData);

    Map<String, String> getFormContents(@Param("formNum") String formNum);

    String getAppDocType(Map<String, String> param);

    Map<String, String> getContractInformation(Map<String, String> formData);

    Map<String, String> getContractFormBySelectedFormNum(Map<String, String> formData);

    Map<String, String> getFormDataFromERP(Map<String, String> param);

    Map<String, String> getBuyerInformation(Map<String, String> formData);

    Map<String, String> getVendorInformation(Map<String, String> formData);

    List<Map<String, Object>> doSearchAdditionalForm(Map<String, String> formData);

    void doInsertECCT(Map<String, String> formData);

    void doInsertECRL(Map<String, String> additionalForm);

    void doUpdateECCT(Map<String, String> formData);

    void doUpdateECRL(Map<String, String> additionalForm);

    void doDeleteAddECRL(Map<String, String> formData);

    void doInsertAddECRL(Map<String, Object> additionalForm);

    void doDeleteECAT(Map<String, String> formData);

    void doInsertECAT(Map<String, Object> gridData);

    void doDeleteECPY(Map<String, String> formData);

    void doInsertECPY(Map<String, Object> gridData);

    int doUpdateECCT4NotesIF(Map<String, String> formData);

    public String getOldSignStatus(Map<String, String> formData);

    int doUpdateApprovalInformation(Map<String, String> formData);

    void doUpdateStatusOfECCT(Map<String, String> formData);

    List<Map<String, Object>> getOttogiFileInformation(Map<String, String> paramMap);

    int doDeleteECSV(Map<String, String> formData);

    int doInsertECSV(Map<String, String> formData);

    void doDeleteECCT(Map<String, String> formData);

    void doDeleteECDT(Map<String, String> formData);

    void doDeleteECRL(Map<String, String> formData);

    List<Map<String, String>> getPurcContNum(Map<String, String> param);

    void setNullContNumToERP(Map<String, String> data);

    int doCheckExamFlag(Map<String, String> formData);

    String getMaxContCnt(@Param("CONT_NUM") String contNum);

    Map<String, String> getApprovalContInfoExam(Map<String, String> param);

    void updateSignStatusExam(Map<String, String> param);

    Map<String, String> getApprovalContInfoCont(Map<String, String> param);

    void updateSignStatusCont(Map<String, String> param);

    void doUpdateContNumToERP(Map<String, String> data);

    String getCodeDesc(Map<String, String> param);

    List<Map<String, String>> getContFileList(Map<String, String> param);


    List<Map<String, Object>> ecoa0020_doSearch(Map<String, Object> formData);

    // 담당자 변경
    int ECOA0020_doChangeContUser(Map<String, Object> rowData);

    // 계약해지n해제
    int ecoa0020_doCancelRemoveCont(Map<String, String> map);

    // 계약서 복사
    int ecoa0020_doCopyECCT(Map<String, Object> rowData);

    int ecoa0020_doCopyECRL(Map<String, Object> rowData);

    int ecoa0020_doCopyECAT(Map<String, Object> rowData);

    int ecoa0020_doCopyECPY(Map<String, Object> rowData);

    int ecoa0020_getPurcCnt(Map<String, Object> rowData);

    void ecoa0020_doDelMapping(Map<String, Object> rowData);

    // 계약서 보증서 저장
    int BECM_050_doSave(Map<String, Object> rowData);

    // 계약서 추가첨부저장
    int BECM_050_doAttSave(Map<String, Object> rowData);

    // 계약서 추가첨부저장
    int ECOA0020_doAddFileSave(Map<String, Object> rowData);

    List<Map<String, String>> getContractAllContents(Map<String, String> formData);

    List<Map<String, Object>> ecob0050_doSearchSupAttachFileInfo(Map<String, String> param);

    List<Map<String, Object>> ecob0050_doSearchPayInfo(Map<String, String> param);

    List<Map<String, Object>> getCndtCnpyList(Map<String, String> param);

    Map<String, String> getCndtCnvdInfo(Map<String, String> param);

    int doUpdateContractStatusECCT(Map<String, String> formData);

    int doDeleteSignedData(Map<String, String> formData);

    int doInsertSignedData(Map<String, String> formData);

    int doMergeRejectHistoryECRJ(Map<String, String> formData);

    int doUpdateFileNumECAT(Map<String, Object> gridData);

    Map<String, String> getContractFormTypeAndBusinessUserEmail(Map<String, String> formData);

    void doDeleteFileECRL(Map<String, String> param);

    List<Map<String, Object>> getFileFormList(Map<String, String> formData);

    List<Map<String, Object>> getFileInfoList(Map<String, String> formData);

    void doInsertFileECRL(Map<String, Object> data);

    void delEcdt(Map<String, String> formData);
    void insEcdt(Map<String, Object> gridData);

    List<Map<String, Object>> doSearchContItem(Map<String, String> param);

    List<Map<String, Object>> doSearchPrItem(Map<String, Object> param);

    void insStocInfo(Map<String, String> param);

    void cancelContRfq(Map<String, Object> param);
    void cancelContPr(Map<String, Object> param);
    void cancelContItem(Map<String, String> map);

    void execClose(Map<String, Object> param);

    void setSignAgreeReject(Map<String, String> param);

    void cancelDelInfo(Map<String, Object> param);

    List<Map<String, Object>> getContReadyList(Map<String, Object> param);

    void createPohd(Map<String, String> gridData);
    void createPodt(Map<String, String> gridData);
    void createPopy(Map<String, String> gridData);

	Map<String, String> getVendorCustInformation(Map<String, String> paramMap);

	Map<String, String> getBuyerCustInformation(Map<String, String> paramMap);

	Map<String, String> getMailInfo(Map<String, String> rqhdData);

	String getSignStatus(Map<String, String> formData);

	void updateSignStatus(Map<String, String> formData);

	int getSendCancelCheck(Map<String, String> param);

	void oldContDelChange(Map<String, String> formData);
}