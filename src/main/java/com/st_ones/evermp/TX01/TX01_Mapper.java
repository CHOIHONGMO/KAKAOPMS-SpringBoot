package com.st_ones.evermp.TX01;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 19 오전 9:18
 */

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface TX01_Mapper {

	/** ******************************************************************************************
	 * 운영사 > 정산관리 > 매출정산 > 세금계산서 현황
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> tx01010_doSearch(Map<String, String> param);
	List<Map<String, Object>> tx01010_doSearchTTID(Map<String, String> param);
	void tx01010_doUpdateTTID(Map<String, Object> param);
	void tx01010_doUpdateTTID_TTIH(Map<String, Object> param);
	String tx01010_doSearchBILLSTAT(Map<String, String> param);
	void tx01010_doSaveTTIH(Map<String, Object> param);

	List<Map<String, Object>> tx01010_doTaxCancelSELECT_TAX_AR(Map<String, Object> param);
	void tx01010_doTaxCancelAPAR(Map<String, Object> param);
    void tx01010_doTaxCancelTTIH_AP(Map<String, Object> param);
	void tx01010_doTaxCancelTTIH_AR(Map<String, Object> param);
	void tx01010_doTaxCancelTTID_AP(Map<String, Object> param);
	void tx01010_doTaxCancelTTID_AR(Map<String, Object> param);

	void tx01010_doSaveDepositTTIH(Map<String, Object> param);

	void tx01010_doSendBillCancelINSERT_BILL_MNGMT_ORDR(Map<String, Object> param);
	void tx01010_doSendBillCancelDELETE_BILL_LOG(Map<String, Object> param);

	List<Map<String, Object>> tx01010_doSendBillTransSELECT_TTID(Map<String, Object> param);
	Map<String, Object> tx01010_doSendBillTransSELECT_TTID_SUM(Map<String, Object> param);
	Map<String, Object> tx01010_doSendBillTransSELECT_TTID_SUMAMT(Map<String, Object> param);
	void tx01010_doSendBillTransINSERT_BILL_TRANS(Map<String, Object> param);
	void tx01010_doSendBillTransINSERT_BILL_TRANS_ITEM(Map<String, Object> param);

	Map<String, Object> tx01010_doSendBillSELECT_BILL_STAT_CHK(Map<String, Object> param);
	void tx01010_doSaveUPDATE_TTIH(Map<String, Object> param);

	void tx01010_doSendBillReSendUPDATE_BILL_TRANS(Map<String, Object> param);
	void tx01010_doSendBillReSendUPDATE_BILL_TRANS_ITEM(Map<String, Object> param);
	void tx01010_doSendBillReSendBILL_STAT(Map<String, Object> param);

	Map<String, String> tx01010_doSendBillCancelSELECT_BILL_CHK(Map<String, Object> param);
	void tx01010_doSendBillCancelUPDATE_TTIH(Map<String, Object> param);

	// 매출회계계산서 목록
	List<Map<String, Object>> tx01020_doSearch(Map<String, String> param);


	List<Map<String, Object>> tx01020_detail(Map<String, String> param);



	/** ******************************************************************************************
	 * 운영사 > 정산관리 > 매출정산 > 전표이관
	 * @param param
	 * @return List
	 * @throws Exception
	 */
	List<Map<String, Object>> tx01011_doSearch(Map<String, String> param);
	List<Map<String, Object>> tx01011_doSearchTTID(Map<String, String> param);

	String tx01011_doSlipTransSELECT_TAX_CHK(Map<String, Object> param);
	String tx01011_doSlipTransSELECT_CUST(Map<String, Object> param);
	Map<String, Object> tx01011_doSlipTransSELECT_CUST_CHK(Map<String, Object> param);
	List<Map<String, Object>> tx01011_doSlipTransSELECT_TTID(Map<String, Object> param);
	Map<String, Object> tx01011_doSlipTransSELECT_TTID_CHK(Map<String, Object> param);
	void tx01011_doSaveUPDATE_TTID(Map<String, Object> param);
	void tx01011_doSaveUPDATE_TTIH(Map<String, Object> param);
	void tx01011_doSlipTransINSERT_IF_MROOUTCLO(Map<String, Object> param);
	void tx01011_doSlipTransDELETE_IF_MROOUTCLO(Map<String, Object> param);
	void tx01011_doSlipTransINSERT_IF_MROINCLO(Map<String, Object> param);
	void tx01011_doSlipTransDELETE_IF_MROINCLO(Map<String, Object> param);

	void tx01020_doAccC(Map<String, Object> grid);
	void tx01020_doAccC_Cancel(Map<String, Object> grid);
	void tx01020_doAccV(Map<String, Object> grid);
	void tx01020_doAccV_Cancel(Map<String, Object> grid);
	void tx01020_doSalesClose(Map<String, Object> grid);

	String tx01020_doSalesCloseCUCLCHK(Map<String, String> param);


	void tx01020_doSalesCloseCUCL(Map<String, String> param);

	void doSalesCloseCancel(Map<String, String> param);


	void tx01020_doAutoDocExe(Map<String, Object> grid);







	List<Map<String, Object>> getSapList(Map<String, Object> param);
	String getDocSeq(Map<String, Object> param);
	void saveSLHD(Map<String, Object> param);
	void saveSLDT(Map<String, Object> param);
	String getSeqId(Map<String, Object> param);
	void saveAccSlipDocuMst(Map<String, Object> param);
	void saveAccSlipDocuDtl(Map<String, Object> param);
	Map<String, Object> callPkgAccautochitcrt(Map<String, Object> param);
	void updateSlhd(Map<String, Object> param);
	void delSLHD(Map<String, Object> param);
	void delSLDT(Map<String, Object> param);





	List<Map<String, Object>> getSapList_AP(Map<String, Object> param);
	void saveSLHD_AP(Map<String, Object> param);
	void saveSLDT_AP(Map<String, Object> param);
	String getSeqId_AP(Map<String, Object> param);
	void saveAccSlipDocuMst_AP(Map<String, Object> param);
	void saveAccSlipDocuDtl_AP(Map<String, Object> param);



	Map<String, String> getCustInfo(Map<String, Object> param);

	Map<String, String> getVendorInfo(Map<String, Object> param);

	int chkDgnsSend(Map<String, Object> param);

}