package com.st_ones.evermp.RQ01.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.IM03.IM0301_Mapper;
import com.st_ones.evermp.RQ01.RQ0102_Mapper;
import com.st_ones.evermp.SSO1.SSO1_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */

@Service(value = "rq0102_Service")
public class RQ0102_Service extends BaseService {

    @Autowired private RQ0102_Mapper rq0102_Mapper;
    @Autowired private IM0301_Mapper im0301Mapper;
    @Autowired private SSO1_Mapper sso1_Mapper;

    @Autowired private EApprovalService approvalService;
	@Autowired private DocNumService docNumService;
    @Autowired private MessageService msg;
    @Autowired LargeTextService largeTextService;

    @Autowired  private EverMailService everMailService;
    @Autowired  private EverSmsService everSmsService;

    // 실시간 I/F는 공통에서 관리함
    @Autowired private RealtimeIF_Service realtimeif_service;
    @Autowired private RealtimeIF_Mapper realtimeif_mapper;

    /** *****************
     * 견적비교
     * ******************/
    public List<Map<String, Object>> rq01020_doSearchT(Map<String, String> param) throws Exception {

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

        return rq0102_Mapper.rq01020_doSearchT(fParam);
    }

    public List<Map<String, Object>> rq01020_doSearchB(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01020_doSearchB(param);
    }
    // 견적서 개찰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String saveQtaOpen(List<Map<String, Object>> gridData) throws Exception {

    	for(Map<String, Object> data : gridData) {
    		rq0102_Mapper.saveCrqOpenHd(data);
    	}
        	return msg.getMessage("0001");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01020_doClosing(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {

            Map<String, String> param = new HashMap<String, String>();
            param.put("RFQ_NUM", String.valueOf(gridData.get("RFQ_NUM")));
            param.put("RFQ_CNT", String.valueOf(gridData.get("RFQ_CNT")));

            // 진행상태가 "견적중" 이 아닌 경우 견적마감 제외
            String progressCd = rq0102_Mapper.checkProgressCd(param);
            if (!"200".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("RQ01_020", "007"));
            }

            gridData.put("PROGRESS_CD", "300");	// 견적마감
            rq0102_Mapper.doClosingHD(gridData);
            rq0102_Mapper.doClosingDT(gridData);
        }
        return msg.getMessageByScreenId("RQ01_020", "009");
    }

    // 신규상품 요청 견적취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01020_doDelete(String moveReason, List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {

            Map<String, String> param = new HashMap<String, String>();
            param.put("RFQ_NUM", String.valueOf(gridData.get("RFQ_NUM")));
            param.put("RFQ_CNT", String.valueOf(gridData.get("RFQ_CNT")));

            // 진행상태가 견적중(200), 견적마감(300)인 경우에만 견적 취소 가능함
            String progressCd = rq0102_Mapper.checkProgressCd(param);
            if (!"200".equals(progressCd)&&!"300".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("RQ01_020", "027"));
            }

            // 해당 견적을 삭제한다. (DEL_FLAG = '1')
            gridData.put("_TABLE_NM", "STOCRQHD");
            rq0102_Mapper.doDeleteRFQ(gridData);

            gridData.put("_TABLE_NM", "STOCRQDT");
            rq0102_Mapper.doDeleteRFQ(gridData);

            gridData.put("_TABLE_NM", "STOCRQVN");
            rq0102_Mapper.doDeleteRFQ(gridData);

            // 해당 품목요청건의 진행상태를 '접수(300)'으로 변경한다.
            gridData.put("NWRQ_PROGRESS_CD", "300");
            rq0102_Mapper.doReturnItem(gridData);
        }
        return msg.getMessage("0017");
    }

    // 신규상품요청 유찰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01020_doFailRFQ(String moveReason, List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {

            Map<String, String> param = new HashMap<String, String>();
            param.put("RFQ_NUM", String.valueOf(gridData.get("RFQ_NUM")));
            param.put("RFQ_CNT", String.valueOf(gridData.get("RFQ_CNT")));

            // 견적 마감(300)인 경우에만 유찰할 수 있음
            String progressCd = rq0102_Mapper.checkProgressCd(param);
            if (!"300".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("RQ01_020", "014"));
            }

            // 해당 견적의 진행상태를 '유찰'로 변경한다.
            gridData.put("PROGRESS_CD", "100");		// 유찰(100)
            gridData.put("MOVE_REASON", moveReason);// 유찰사유

            gridData.put("_TABLE_NM", "STOCRQHD");
            rq0102_Mapper.doFailRFQ(gridData);

            gridData.put("_TABLE_NM", "STOCRQDT");
            rq0102_Mapper.doFailRFQ(gridData);

            // 해당 품목요청건의 진행상태를 '접수(300)'으로 변경한다.
            gridData.put("NWRQ_PROGRESS_CD", "300");
            rq0102_Mapper.doReturnItem(gridData);
        }
        return msg.getMessageByScreenId("RQ01_020", "013");
    }




    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01020_doChoiceCancel(String rfqNum, String rfqCnt, String partSettleFlag, List<Map<String, Object>> gridDatas) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("RFQ_NUM", rfqNum);
        param.put("RFQ_CNT", rfqCnt);

        // RQHD 재견적 이상인 경우 업체선정할 수 없음
        String progressCd = rq0102_Mapper.checkProgressCd(param);
        if (Integer.parseInt(progressCd) != 400 && Integer.parseInt(progressCd) != 390) {
            throw new Exception(msg.getMessageByScreenId("RQ01_020", "046"));
        }

        // 현재 '공급사선정' 혹은 '부분선정'인 상태를 전부 원복시킨 후, 다시 업데이트 한다.
        // '품의서' 작성 전까지는 공급사선정을 여러번 할 수 있다.
        param.put("PROGRESS_CD", "300");	// 견적마감


        rq0102_Mapper.doSettleToRQHD(param);
        rq0102_Mapper.doRollbackToRQDT(param);
        rq0102_Mapper.doRollbackToQTDT(param);


        return msg.getMessageByScreenId("RQ01_020", "048");
    }





















    // 공급사선정 : 소싱관리 > 신규소싱 > 견적마감 및 업체선정 (RQ01_020)
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01020_doChoiceVendor(String rfqNum, String rfqCnt, String partSettleFlag, List<Map<String, Object>> gridDatas) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("RFQ_NUM", rfqNum);
        param.put("RFQ_CNT", rfqCnt);

        // RQHD 재견적 이상인 경우 업체선정할 수 없음
        String progressCd = rq0102_Mapper.checkProgressCd(param);
        if (Integer.parseInt(progressCd) >= 450) {
            throw new Exception(msg.getMessageByScreenId("RQ01_020", "027"));
        }

        // 현재 '공급사선정' 혹은 '부분선정'인 상태를 전부 원복시킨 후, 다시 업데이트 한다.
        // '품의서' 작성 전까지는 공급사선정을 여러번 할 수 있다.
        param.put("PROGRESS_CD", "300");	// 견적마감
        rq0102_Mapper.doSettleToRQHD(param);
        rq0102_Mapper.doRollbackToRQDT(param);
        rq0102_Mapper.doRollbackToQTDT(param);

        // RQHD : 화면에서 선택한 정보로 공급사선정을 한다.
        param.put("PROGRESS_CD", (partSettleFlag.equals("true") ? "390" : "400")); // 390(부분선정), 400(업체선정완료)
        rq0102_Mapper.doSettleToRQHD(param);

        String tmpRfqSq = "";
        int rowIdx = 0;
        boolean settleFlag = false;
        for(Map<String, Object> gridData : gridDatas) {

            if(!tmpRfqSq.equals(String.valueOf(gridData.get("RFQ_SQ")))) {
                if(rowIdx > 0) {
                    gridData.put("PARAM_RFQ_SQ", tmpRfqSq);
                    gridData.put("PROGRESS_CD", (settleFlag ? "400" : "300"));
                    rq0102_Mapper.doSettleToRQDT(gridData);
                    settleFlag = false;
                }
                tmpRfqSq = String.valueOf(gridData.get("RFQ_SQ"));
            }
            if (gridData.get("SETTLE_FLAG").equals("1")) {
                settleFlag = true;
            }
            rowIdx++;
            if(rowIdx == gridDatas.size()) {
                gridData.put("PARAM_RFQ_SQ", tmpRfqSq);
                gridData.put("PROGRESS_CD", (settleFlag ? "400" : "300"));
                rq0102_Mapper.doSettleToRQDT(gridData);
            }
            rq0102_Mapper.doSettleToQTDT(gridData);
        }
        return msg.getMessageByScreenId("RQ01_020", "026");
    }

    public List<Map<String, String>> rq01020_doSearchOzParam(Map<String, String> param) throws Exception {

        List<Map<String, String>> custList = rq0102_Mapper.rq01020_doSearchOzCustList(param);
        for(Map<String, String> custData : custList) {
            param.put("CUST_CD", custData.get("CUST_CD"));
            custData.put("RFQ_NUM_CNT_SQ", rq0102_Mapper.rq01020_getRfqNumCntSq(param));
        }
        return custList;
    }

    /** *****************
     * 마감일변경 (견적중일 경우에만 가능)
     * ******************/
    public Map<String, String> getCloseDate(Map<String, String> param) throws Exception {
        return rq0102_Mapper.getCloseDate(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01021_doChangeDeadLine(Map<String, String> formData) throws Exception {

    	// 견적중(200)인 경우에만 마감일 변경 가능
        String progressCd = rq0102_Mapper.checkProgressCd(formData);
        if (!"200".equals(progressCd)) {
            throw new Exception(msg.getMessageByScreenId("RQ01_021", "002"));
        }

        rq0102_Mapper.doChangeDeadLine(formData);
        return msg.getMessageByScreenId("RQ01_021", "003");
    }

    /** *****************
     * 견적서 대행 입력 (대행사)
     * ******************/
    public List<Map<String, Object>> rq01022_doSearch(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01022_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01022_doSave(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();
        String firstSendFlag = formData.get("firstSendFlag");
        String qtaNum = (firstSendFlag.equals("Y") ? docNumService.getDocNumber("QTA") : formData.get("QTA_NUM"));
        formData.put("QTA_NUM", qtaNum);

        // 견적건의 마감일자가 지났는지 여부 체크
        String possibleFlag = sso1_Mapper.checkDeadLine(formData);
        if (!"Y".equals(possibleFlag)) {
            throw new Exception(msg.getMessageByScreenId("RQ01_022", "015"));
        }

        /* 견적서 일반정보 등록 */
        formData.put("AGENT_USER_ID", userInfo.getUserId());
        formData.put("REG_USER_ID", formData.get("VENDOR_USER"));
        formData.put("MOD_USER_ID", formData.get("VENDOR_USER"));
        formData.put("PIC_USER_ID", formData.get("VENDOR_USER"));

        if(firstSendFlag.equals("Y")) {
            sso1_Mapper.doInsertQTHD(formData);
        } else {
            sso1_Mapper.doUpdateQTHD(formData);
        }

        sso1_Mapper.doDeleteQTDT(formData);
        for(Map<String, Object> qtdt : gridDatas) {
            qtdt.put("QTA_NUM", qtaNum);
            qtdt.put("VENDOR_CD", formData.get("VENDOR_CD"));
            qtdt.put("PLANT_CD", formData.get("PLANT_CD"));
            qtdt.put("REG_USER_ID", formData.get("VENDOR_USER"));
            qtdt.put("MOD_USER_ID", formData.get("VENDOR_USER"));
            /* 견적서 품목정보 등록 */
            sso1_Mapper.doInsertQTDT(qtdt);
            /* 공급사 견적서 제출여부 업데이트 */
            qtdt.put("RFQ_PROGRESS_CD", (String.valueOf(qtdt.get("GIVEUP_FLAG")).equals("1") ? "150" : "300"));
            sso1_Mapper.doUpdateRfqProgressCd(qtdt);
        }
        return msg.getMessageByScreenId("RQ01_022", "016");
    }

    /** *****************
     * 계약품의
     * ******************/
    public Map<String, String> rq01023_getFormData(Map<String, String> param) throws Exception {

        Map<String, String> formData = new HashMap<String, String>();
        String searchType = EverString.nullToEmptyString(param.get("SEARCH_TYPE"));

        // 견적서 기준 품의내용 가져오기
        if(searchType.equals("RFQ")) { formData = rq0102_Mapper.rq01023_getFormDataRFQ(param); }
        // 2022.09.22 미사용 : PROGRESS_CD=999
        if(searchType.equals("NEO")) { formData = rq0102_Mapper.rq01023_getFormDataNEO(param); }
        // 품의서 (exec_num, app_doc_num) 기준 품의내용 가져오기
        if(searchType.equals("CN") || searchType.equals("APP")) { formData = rq0102_Mapper.rq01023_getFormDataCN(param); }

        if(formData != null) { formData.put("RMK_TEXT", largeTextService.selectLargeText(formData.get("RMK_TEXT_NUM"))); }
        return formData;
    }

    // 품의서 작성할 품목정보 가져오기
    public List<Map<String, Object>> rq01023_doSearchGridR(Map<String, String> param) throws Exception {

        List<Map<String, Object>> rtnList = new ArrayList<Map<String, Object>>();
        String searchType = param.get("SEARCH_TYPE");

        if (searchType.equals("NEO")) {
            rtnList = rq0102_Mapper.rq01023_doSearchGridRNeo(param);	// 2022.09.22 미사용 : PROGRESS_CD=999
        } else if(searchType.equals("CN")) {
            rtnList = rq0102_Mapper.rq01023_doSearchGridRCN(param); 	// 품의서 (exec_num, app_doc_num) 기준 품의내용 가져오기
        } else {
            rtnList = rq0102_Mapper.rq01023_doSearchGridR(param);		// 견적서 (rfq_no) 기준 품의내용 가져오기
        }
        return rtnList;
    }

    // 신규상품 요청정보 가져오기
    public List<Map<String, Object>> rq01023_doSearchGridC(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01023_doSearchGridC(param);
    }

    // 2022.09.22 미사용 (공급사 재계약시 공급사 기존 계약정보)
    public List<Map<String, Object>> rq01023_doSearchGridV(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01023_doSearchGridV(param);
    }

    // 2022.09.22 미사용 (해당 품목의 고객사 1년 주문실적)
    public List<Map<String, Object>> rq01023_doSearchGridCU(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01023_doSearchGridCU(param);
    }

    /**
     * 신규상품 요청 > 계약품의서 작성 > 저장 및 결재상신시 DGNS 품목코드 채번
     * @param signStatus
     * @param oriFormData
     * @param gridDatas
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> rq01023_doSave(String signStatus, Map<String, String> oriFormData,  List<Map<String, Object>> gridDatas) throws Exception {

        UserInfo userInfo = UserInfoManager.getUserInfo();

        Map<String, String> rtnMap = new HashMap<String, String>();
        Map<String, Object> formData = new HashMap<String, Object>();
        formData.putAll(oriFormData);

        String execNum = EverString.nullToEmptyString(formData.get("EXEC_NUM"));

        // 진행상태 체크 (결재중, 결재완료인 경우 수정 및 삭제 불가)
        String dbSignStatus = EverString.nullToEmptyString(rq0102_Mapper.rq01023_checkCnSignStatus(formData));
        if (dbSignStatus.equals("E") || dbSignStatus.equals("P")) {
            throw new Exception(msg.getMessageByScreenId("RQ01_023", "012"));
        }

        // 2022.09.22
        // DGNS 시스템과 I/F 하는 내부 관계사인 경우에만 고객사 품목코드 채번
        if (EverString.nullToEmptyString(oriFormData.get("DGNS_IF_CUST_FLAG")).equals("1")) {

	        for(Map<String, Object> gridData : gridDatas) {

	        	if (gridData.get("CUST_ITEM_CD") == null || "".equals(gridData.get("CUST_ITEM_CD"))) {

					Map<String,String> gridData1 = new HashMap<String,String>();
					gridData1.put("CUST_ITEM_CLS1",gridData.get("CUST_ITEM_CLS1").toString());
					gridData1.put("CUST_ITEM_CLS2",gridData.get("CUST_ITEM_CLS2").toString());
					gridData1.put("CUST_ITEM_CLS3",gridData.get("CUST_ITEM_CLS3").toString());
					gridData1.put("CUST_ITEM_CLS4",gridData.get("CUST_ITEM_CLS4").toString());

					gridData1.put("ITEM_CLS1_CUST",gridData.get("CUST_ITEM_CLS1").toString());
					gridData1.put("ITEM_CLS2_CUST",gridData.get("CUST_ITEM_CLS2").toString());
					gridData1.put("ITEM_CLS3_CUST",gridData.get("CUST_ITEM_CLS3").toString());
					gridData1.put("ITEM_CLS4_CUST",gridData.get("CUST_ITEM_CLS4").toString());

					gridData1.put("ITEM_CD", gridData.get("ITEM_CD").toString());
					gridData1.put("VAT_CD", gridData.get("VAT_CD").toString());
					gridData1.put("ITEM_DESC", gridData.get("ITEM_DESC").toString());
					gridData1.put("ITEM_SPEC", gridData.get("ITEM_SPEC").toString());
					gridData1.put("UNIT_CD", gridData.get("UNIT_CD").toString());

					// 품목 insert
					// 품목의 대, 중, 소분류까지 존재하는 경우에만 품목코드 채번
					if(gridData.get("CUST_ITEM_CLS3") != null && !"".equals(gridData.get("CUST_ITEM_CLS3")) && !"*".equals(gridData.get("CUST_ITEM_CLS3"))) {
						// DGNS 시스템과 I/F : cust item id를 가져와서
						Map<String, String> dgnsData = realtimeif_mapper.getDgnsItemCd(gridData1);
						gridData1.put("DGNS_ITEM_ID", dgnsData.get("DGNS_ITEM_ID"));
						gridData1.put("MK_NM", dgnsData.get("MK_NM"));
						// DGNS 시스템과 I/F : cust item cd를 생성한다.
						gridData1.put("DGNS_ITEM_CD", realtimeif_mapper.getDgnsItemCd2(gridData1));

						if( gridData1.get("DGNS_ITEM_CD") != null && !"".equals(gridData1.get("DGNS_ITEM_CD")) ) {
							// DGNS 시스템과 I/F : DGNS 신규품목 등록
							realtimeif_service.insPuaMtrlCd(gridData1); 	 // DGNS 품목 등록

							// ==== MRO 시스템 품목 등록
							// 분류체계 저장
							im0301Mapper.im03008_copyCustMTGC(gridData1);    // 품목 분류체계 맵핑
							// 품목코드저장
							im0301Mapper.im03008_copyCustMTGB(gridData1);    // 고객사별 품목코드 맵핑
							// 품목마스터에 고객사 품목코드 update
							im0301Mapper.im03009_MTGL_Update_CUST_ITEM_CD(gridData1);
							// 신규품목(STOCNWRQ)에 고객사 품목코드 update
						    im0301Mapper.im03009_NWRQ_Update_CUST_ITEM_CD(gridData1);
						}
					}
	            }
	        }
        }

        // 신규등록일경우 품의번호 채번
        if (execNum.equals("")) {
            execNum = docNumService.getDocNumber("EXEC");
            formData.put("EXEC_NUM", execNum);
            oriFormData.put("EXEC_NUM", execNum);
        }

        // 품의서 일반정보 저장
        String rmkTextNum = largeTextService.saveLargeText(oriFormData.get("RMK_TEXT_NUM"), oriFormData.get("RMK_TEXT"));
        formData.put("RMK_TEXT_NUM", rmkTextNum);
        formData.put("APPROVAL_FLAG", "0");
        formData.put("SIGN_STATUS", signStatus);
        oriFormData.put("SIGN_STATUS", signStatus);
        rq0102_Mapper.rq01023_doMergeCNHD(formData);

        // 삭제 후, 품의서 품목정보 저장
        rq0102_Mapper.rq01023_doDeleteCNDT(formData);

        //견적의뢰서 상태 변경
        for(Map<String, Object> gridData : gridDatas) {
            gridData.put("EXEC_NUM", execNum);
            gridData.put("QTY", gridData.get(""));
            rq0102_Mapper.rq01023_doInsertCNDT(gridData);

            gridData.put("PROGRESS_CD", "500"); // RQDT.PROGRESS_CD : 품의중
            rq0102_Mapper.rq01023_doUpdateProgressCdRQDT(gridData);
        }

        // 해당 견적의뢰번호/차수의 품목 중 '부분선정'(390)인 상태가 있을 수 있으므로 모든 품목에 대한 진행상태가"500" 이상이면
        // 본 품의가 해당 견적의뢰를기준으로 작성하는 마지막 품의이므로'품의중'으로 진행상태를 변경한다.
        String rqhdProgressCd = EverString.nullToEmptyString(rq0102_Mapper.rq01023_getRqhdProgressCd(oriFormData));
        oriFormData.put("PROGRESS_CD", rqhdProgressCd);
        rq0102_Mapper.rq01023_doUpdateProgressCdRQHD(oriFormData);

        // 결재요청
        String appDocNum = EverString.nullToEmptyString(formData.get("APP_DOC_NUM"));
        String appDocCnt = EverString.nullToEmptyString(formData.get("APP_DOC_CNT"));
        if (signStatus.equals("P")) {

            if (EverString.isEmpty(appDocNum)) {
                appDocNum = docNumService.getDocNumber("AP");
                oriFormData.put("APP_DOC_NUM", appDocNum);
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                appDocCnt = "1";
                oriFormData.put("APP_DOC_CNT", appDocCnt);
            } else {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                oriFormData.put("APP_DOC_CNT", appDocCnt);
            }
            oriFormData.put("DOC_TYPE", "EXEC");

            approvalService.doApprovalProcess(oriFormData, oriFormData.get("approvalFormData"), oriFormData.get("approvalGridData"));

            // 결재상태 및 결재번호 업데이트.
            oriFormData.put("APPROVAL_FLAG", "1");
            rq0102_Mapper.updateSignStatus(oriFormData);
        }

        rtnMap.put("EXEC_NUM", execNum);
        rtnMap.put("rtnMsg", ((signStatus.equals("T") || signStatus.equals("E")) ? msg.getMessage("0031") : msg.getMessage("0023")));


//if(1==1) throw new Exception("=======================================");
        return rtnMap;
    }

    // 계약 품의서 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01023_doDelete(Map<String, String> formData) throws Exception {

        Map<String, Object> param = new HashMap<String, Object>();
        param.put("EXEC_NUM", formData.get("EXEC_NUM"));

        // 진행상태 체크.
        String dbSignStatus = EverString.nullToEmptyString(rq0102_Mapper.rq01023_checkCnSignStatus(param));
        if (dbSignStatus.equals("E") || dbSignStatus.equals("P")) {
            throw new Exception(msg.getMessageByScreenId("RQ01_023", "012"));
        }

        List<Map<String, Object>> cnInfos = rq0102_Mapper.getCnInfos(param);
        String rfqNum = ""; String rfqCnt = "";
        String rfqSqStr = "'";
        for(Map<String, Object> cnInfo : cnInfos) {
            rfqNum = String.valueOf(cnInfo.get("RFQ_NUM"));
            rfqCnt = String.valueOf(cnInfo.get("RFQ_CNT"));
            rfqSqStr = rfqSqStr + String.valueOf(cnInfo.get("RFQ_SQ")) + "','";
        }
        if(rfqSqStr.length() > 2) {
            rfqSqStr = rfqSqStr.substring(0, rfqSqStr.length() - 2);
            rfqSqStr = "(" + rfqSqStr + ")";
        } else {
            rfqSqStr = "";
        }
        param.put("RFQ_NUM", rfqNum);
        param.put("RFQ_CNT", rfqCnt);
        param.put("RFQ_SQ", rfqSqStr);

        // 품의 일반/품목정보 삭제.
        param.put("_TABLE_NM", "STOCCNHD");
        rq0102_Mapper.doUpdateDelFlagCN(param);
        param.put("_TABLE_NM", "STOCCNDT");
        rq0102_Mapper.doUpdateDelFlagCN(param);

        // 견적 일반정보의 진행상태 원복.
        String progressCd = rq0102_Mapper.getRollbackProgressCd(param);
        param.put("PROGRESS_CD", progressCd);
        rq0102_Mapper.doRollbackRQHD(param);

        for(Map<String, Object> cnInfo : cnInfos) {
            // 견적 품목정보의 진행상태 원복.
            cnInfo.put("PROGRESS_CD", "300");
            rq0102_Mapper.doRollbackRQDT(cnInfo);
            // 공급사 견적서 품목정보의 선정여부 원복.
            rq0102_Mapper.doRollbackQTDT(cnInfo);
        }
        return msg.getMessage("0017");
    }

    /** *****************
     * 견적비교표
     * ******************/
    public Map<String, String> rq01024_getFormData(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01024_getFormData(param);
    }

    public List<Map<String, Object>> rq01024_doSearch(Map<String, String> param) throws Exception {

        int idx = 0;
        List<Map<String, Object>> rtnList = new ArrayList<Map<String, Object>>();
        List<Map<String, Object>> tmpList = new ArrayList<Map<String, Object>>();

        Map<String, String> sParam = new HashMap<String, String>();
        sParam.put("RFQ_NUM", param.get("RFQ_NUM"));

        List<Map<String, Object>> cntList = rq0102_Mapper.rq01024_getRfqCnts(sParam);
        for(int c = 0; c < cntList.size(); c++) {
            Map<String, Object> cntData = cntList.get(c);
            sParam.put("RFQ_CNT", String.valueOf(cntData.get("RFQ_CNT")));
            tmpList = rq0102_Mapper.rq01024_doSearch(sParam);
            for(int i = 0; i < tmpList.size(); i++) {
                rtnList.add(idx, tmpList.get(i));
                idx++;
            }
        }
        return rtnList;
    }

    /** *****************
     * 대상공급사
     * ******************/
    public List<Map<String, Object>> rq01025_doSearch(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01025_doSearch(param);
    }

    /** *****************
     * 품의현황
     * ******************/
    public List<Map<String, Object>> rq01026_doSearch(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01026_doSearch(param);
    }

    public List<Map<String, Object>> rq01026_doSearchD(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01026_doSearchD(param);
    }

    /** *****************
     * 소싱관리 > 신규소싱 > 신규상품 CMS 맵핑 (RQ01_030)
     * ******************/
    public List<Map<String, Object>> rq01030_doSearch(Map<String, String> param) throws Exception {
        return rq0102_Mapper.rq01030_doSearch(param);
    }

    // 신규상품 요청에 대한 => 상품등록완료 : DGNS I/F
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01030_doConfirm(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> grid : gridDatas) {

            // 1. 품목마스터 "승인(E), 사용(10)"으로 변경
            rq0102_Mapper.doUpdateProgressCdMTGL(grid);

            // DGNS I/F 대상여부
            // T : I/F 대상, S : 성공, E : 실패
            if( grid.get("ERP_IF_FLAG") != null && ("1".equals(grid.get("ERP_IF_FLAG")) || "T".equals(grid.get("ERP_IF_FLAG"))) ) {
	            //=======================================================================================
	            // 4. (DGNS I/F) : DGNS 상품코드 USE_YN=1 처리
	            Map<String, String> ifData = new HashMap<String, String>();
	            ifData.put("CUST_ITEM_CD", String.valueOf(grid.get("CUST_ITEM_CD")));	// 고객사 상품코드
	            ifData.put("USE_FLAG", "1");	// 사용여부
	            realtimeif_mapper.updateItemUseFlag(ifData);

	            // 매입단가가 유효한 경우에만 단가 i/f
    			if( grid.get("UNIT_IF_FLAG") != null && "1".equals(grid.get("UNIT_IF_FLAG")) ) {
		            // 3. (DGNS I/F) : 고객사 판매단가 등록
//    				BigDecimal SALES_UNIT_PRC = new BigDecimal(String.valueOf( grid.get("SALES_UNIT_PRC")));
//    				SALES_UNIT_PRC = SALES_UNIT_PRC ==null ? BigDecimal.ZERO : SALES_UNIT_PRC;
    				ifData.put("COMPANY_CODE", String.valueOf(grid.get("CUST_CD")));		// 단가적용 고객사
		            ifData.put("DIVISION_CODE", String.valueOf(grid.get("APPLY_TARGET")));	// 단가적용 사업장
		            ifData.put("UNIT_PRICE", grid.get("SALES_UNIT_PRC").toString());	// 고객사 판매단가
		            realtimeif_service.insCustUinfo(ifData);

		            //판매단가 DGNS I/F 여부 세팅(ERP_IF_SEND_FLAG)
	        		im0301Mapper.updateDgnsIfFlag(grid);
    			}

	            // DGNS I/F 여부
		        grid.put("IF_SUCCESS_FLAG", "S");
	            //=======================================================================================
            }

            // 3. 신규상품 요청상태 변경 : 560(상품등록완료)
            rq0102_Mapper.doUpdateProgressCdNWRQ(grid);


            // 고객사 및 공급사에게 메일, SMS 발송
            // Mail Template 및 URL 가져오기
            String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
            String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BASIC_TemplateFileName");

            String domainNm   = PropertiesManager.getString("eversrm.system.domainName");
    		String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
    		String contextNm  = PropertiesManager.getString("eversrm.system.contextName");

    		String maintainUrl  = "";
    		boolean sslFlag = PropertiesManager.getBoolean("ever.ssl.use.flag");
    		if (sslFlag) { maintainUrl = "https://"; }
    		else { maintainUrl = "http://"; }
    		if ("80".equals(domainPort)) {
    			maintainUrl += domainNm;
    		} else {
    			maintainUrl += domainNm + ":" + domainPort;
    		}
    		maintainUrl += contextNm;

            String execNum = "";
            Map<String, String> map = new HashMap<String, String>();
            map.put("ITEM_REQ_NO",String.valueOf(grid.get("ITEM_REQ_NO")));
            map.put("ITEM_REQ_SEQ",String.valueOf(grid.get("ITEM_REQ_SEQ")));
            List<Map<String, Object>> cnInfos = rq0102_Mapper.getCnInfo(map);
            if(cnInfos.size() > 0) { execNum = String.valueOf(cnInfos.get(0).get("EXEC_NUM")); }
            Map<String, String> eParam = new HashMap<String, String>();
            eParam.put("EXEC_NUM", execNum);

            String itemReqNo = "";
            String recvUserId = ""; String recvUserNm = ""; String recvTelNum = ""; String recvEmail = "";
            String sendUserId = ""; String sendUserNm = ""; String sendEmail = "";
            List<Map<String, Object>> reqList = rq0102_Mapper.getReqItemInfos(eParam);
            if(reqList.size() > 0) {
                itemReqNo  = EverString.nullToEmptyString(reqList.get(0).get("ITEM_REQ_NO"));
                recvUserId = EverString.nullToEmptyString(reqList.get(0).get("RECV_USER_ID"));
                recvUserNm = EverString.nullToEmptyString(reqList.get(0).get("RECV_USER_NM"));
                recvTelNum = EverString.nullToEmptyString(reqList.get(0).get("RECV_TEL_NUM"));
                recvEmail  = EverString.nullToEmptyString(reqList.get(0).get("RECV_EMAIL"));
                sendUserId = EverString.nullToEmptyString(reqList.get(0).get("SEND_USER_ID"));
                sendUserNm = EverString.nullToEmptyString(reqList.get(0).get("SEND_USER_NM"));
                sendEmail  = EverString.nullToEmptyString(reqList.get(0).get("SEND_EMAIL"));
            }

            String tblBody = "<tbody>";
            String enter = "\n";
            if(reqList.size() > 0) {
                for (Map<String, Object> reqData : reqList) {

                    String itemDesc = EverString.nullToEmptyString(reqData.get("ITEM_DESC"));
                    if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }

                    String itemSpec = EverString.nullToEmptyString(reqData.get("ITEM_SPEC"));
                    if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }

                    String tblRow = "<tr>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + String.valueOf(reqData.get("ITEM_REQ_SEQ")) + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("ITEM_CD")) + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("MAKER_NM")) + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("UNIT_CD")) + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("CMS_CTRL_USER_NM")) + "</th>"
                            + enter + "</tr>";
                    tblBody += tblRow;
                }
            }

            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$RECV_USER_NM$", recvUserNm); // 주문자명(고객)
            fileContents = EverString.replace(fileContents, "$ITEM_REQ_NO$", itemReqNo); // 신규품목요청번호
            fileContents = EverString.replace(fileContents, "$CONTENTS$", tblBody);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            if(!recvEmail.equals("")) {
                Map<String, String> mdata = new HashMap<String, String>();
                mdata.put("SUBJECT", "[대명소노시즌] " + recvUserNm + " 님. 요청하신 신규품목이 등록되었습니다.");
                mdata.put("CONTENTS_TEMPLATE", fileContents);
                mdata.put("SEND_EMAIL", sendEmail);
                mdata.put("SEND_USER_NM", sendUserNm);
                mdata.put("SEND_USER_ID", sendUserId);
                mdata.put("RECV_EMAIL", recvEmail);
                mdata.put("RECV_USER_NM", recvUserNm);
                mdata.put("RECV_USER_ID", recvUserId);
                mdata.put("REF_NUM", itemReqNo);
                mdata.put("REF_MODULE_CD","RE"); // 참조모듈
                // 메일전송.
                everMailService.sendMail(mdata);
                mdata.clear();
            }

            if(!recvTelNum.equals("")) {
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("SMS_SUBJECT", "[대명소노시즌] 요청하신 신규품목에 대한 계약이 완료되었습니다."); // SMS 제목
                sdata.put("CONTENTS", "[대명소노시즌] " + recvUserNm + "님. 요청하신 신규품목이 등록되었습니다."); // 전송내용
                sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(sendUserId).equals("") ? "SYSTEM" : sendUserId)); // 보내는 사용자ID
                sdata.put("SEND_USER_NM", sendUserNm); // 보내는사람
                sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                sdata.put("RECV_USER_ID", recvUserId); // 받는 사용자ID
                sdata.put("RECV_USER_NM", recvUserNm); // 받는사람
                sdata.put("RECV_TEL_NUM", recvTelNum); // 받는 사람 전화번호
                sdata.put("REF_NUM", itemReqNo); // 참조번호
                sdata.put("REF_MODULE_CD","RE"); // 참조모듈
                // SMS 전송.
                everSmsService.sendSms(sdata);
                sdata.clear();
            }

            // 본 품의서에 포함된 공급사에게 계약확정 통보.
            String vTemplateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CONT_TemplateFileName");

            String mailRfqNumCnt = "";
            String vendorCd = "";
            String vendorNm = "";
            List<Map<String, Object>> vendorDatas = rq0102_Mapper.getContVendorInfos(eParam);
            if (vendorDatas.size() > 0) {
                for (Map<String, Object> vendorData : vendorDatas) {

                    mailRfqNumCnt = EverString.nullToEmptyString(vendorData.get("RFQ_NUM_CNT"));
                    sendUserId = EverString.nullToEmptyString(vendorData.get("SEND_USER_ID"));
                    sendUserNm = EverString.nullToEmptyString(vendorData.get("SEND_USER_NM"));
                    sendEmail = EverString.nullToEmptyString(vendorData.get("SEND_EMAIL"));
                    recvUserId = EverString.nullToEmptyString(vendorData.get("RECV_USER_ID"));
                    recvUserNm = EverString.nullToEmptyString(vendorData.get("RECV_USER_NM"));
                    recvTelNum = EverString.nullToEmptyString(vendorData.get("RECV_TEL_NUM"));
                    recvEmail = EverString.nullToEmptyString(vendorData.get("RECV_EMAIL"));
                    vendorCd = EverString.nullToEmptyString(vendorData.get("VENDOR_CD"));
                    vendorNm = EverString.nullToEmptyString(vendorData.get("VENDOR_NM"));

                    eParam.put("VENDOR_CD", vendorCd);
                    List<Map<String, Object>> itemList = rq0102_Mapper.getContItemInfos(eParam);

                    tblBody = "<tbody>";
                    enter = "\n";
                    for (Map<String, Object> itemData : itemList) {

                        String itemDesc = EverString.nullToEmptyString(itemData.get("ITEM_DESC"));
                        if (itemDesc.length() > 16) {
                            itemDesc = itemDesc.substring(0, 15) + "...";
                        }

                        String itemSpec = EverString.nullToEmptyString(itemData.get("ITEM_SPEC"));
                        if (itemSpec.length() > 30) {
                            itemSpec = itemSpec.substring(0, 29) + "...";
                        }

                        String tblRow = "<tr>"
                                + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
                                + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
                                + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</th>"
                                + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:right;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverMath.EverNumberType(Double.parseDouble(String.valueOf(itemData.get("CONT_UNIT_PRC"))), "###,###.##") + "원 " + "</th>"
                                + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("TAX_NM")) + "</th>"
                                + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CONT_DATE")) + "</th>"
                                + enter + "</tr>";
                        tblBody += tblRow;
                    }
                    tblBody = tblBody + enter + "</tbody>";

                    String vFileContents = EverFile.fileReadByOffsetByEncoding(vTemplateFileNm, "UTF-8");
                    vFileContents = EverString.replace(vFileContents, "$RECV_USER_NM$", vendorNm); // 공급사명
                    vFileContents = EverString.replace(vFileContents, "$RFQ_NUM$", mailRfqNumCnt); // 견적의뢰번호
                    vFileContents = EverString.replace(vFileContents, "$tblBody$", tblBody);
                    vFileContents = EverString.replace(vFileContents, "$maintainUrl$", maintainUrl);
                    vFileContents = EverString.rePreventSqlInjection(vFileContents);

                    if (!recvEmail.equals("")) {
                        Map<String, String> mdata = new HashMap<String, String>();
                        mdata.put("SUBJECT", "[대명소노시즌] " + vendorNm + " 님. 귀사에서 제출하신 견적건에 대해 계약확정 되었습니다.");
                        mdata.put("CONTENTS_TEMPLATE", vFileContents);
                        mdata.put("SEND_EMAIL", sendEmail);
                        mdata.put("SEND_USER_NM", sendUserNm);
                        mdata.put("SEND_USER_ID", sendUserId);
                        mdata.put("RECV_EMAIL", recvEmail);
                        mdata.put("RECV_USER_NM", recvUserNm);
                        mdata.put("RECV_USER_ID", recvUserId);
                        mdata.put("REF_NUM", mailRfqNumCnt);
                        mdata.put("REF_MODULE_CD", "CONT"); // 참조모듈
                        // 메일전송.
                        everMailService.sendMail(mdata);
                        mdata.clear();
                    }

                    if (!recvTelNum.equals("")) {
                        Map<String, String> sdata = new HashMap<String, String>();
                        sdata.put("SMS_SUBJECT", "[대명소노시즌] 귀사에서 제출하신 견적건에 대해 계약확정 되었습니다."); // SMS 제목
                        sdata.put("CONTENTS", "[대명소노시즌] " + vendorNm + "님. 귀사에서 제출하신 견적건에 대해 계약확정 되었습니다."); // 전송내용
                        sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(sendUserId).equals("") ? "SYSTEM" : sendUserId)); // 보내는 사용자ID
                        sdata.put("SEND_USER_NM", sendUserNm); // 보내는사람
                        sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                        sdata.put("RECV_USER_ID", recvUserId); // 받는 사용자ID
                        sdata.put("RECV_USER_NM", recvUserNm); // 받는사람
                        sdata.put("RECV_TEL_NUM", recvTelNum); // 받는 사람 전화번호
                        sdata.put("REF_NUM", mailRfqNumCnt); // 참조번호
                        sdata.put("REF_MODULE_CD", "CONT"); // 참조모듈
                        // SMS 전송.
                        everSmsService.sendSms(sdata);
                        sdata.clear();
                    }
                }
            }
        }

        return msg.getMessage("0001");
    }

    // 결재승인(E) / 반려(R) / 취소(C)시 sign_status, sign_date 변경.
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval(String docNum, String docCnt, String signStatus) throws Exception {

    	// 품의서별 운영사 대행, 고객사 요청여부
    	// 품의서 1개에 고객사에서 요청한 품목과 운영사에서 등록한 품목이 혼재하는 경우 고객사 요청 품목을 기준으로 함
        String docCustReqFlag = "N";

        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);

        // 결재승인 품목정보 가져오기
        List<Map<String, Object>> cnInfos = rq0102_Mapper.getCnInfo(map);
        if(cnInfos.size() > 0) {

            // 결재상태에 따른 품의 상태값 변경.
            map.put("EXEC_NUM", String.valueOf(cnInfos.get(0).get("EXEC_NUM")));
            rq0102_Mapper.updateStatusCN(map); // STOCCNHD SIGN_STATUS

            // 최종 승인인 경우...
            if (signStatus.equals("E")) {

            	for (Map<String, Object> cnInfo : cnInfos) {
                	/**
                	 * 고객사 견적서 합의요청 여부 (1 : 고객사 요청, 0 : 고객사 미요청)
                	 * 견적 요청서 작성시 신규품목 요청이 "운영사 대행" 인 경우 "자동 합의" 처리함
                	 * 고객사에서 신규품목 등록 요청이 온 경우 "고객사 합의대기"로 처리함
                	 */
                    // 고객사에서 신규품목 등록 요청한 경우
            		// ICOYPRHD_IF의 IF_FLAG=2(고객사 견적서 합의요청) 처리함
            		// 고객사 합의완료는 Batch(ITEMIF.java) 에서 처리함
                    if (String.valueOf(cnInfo.get("CUST_REQ_FLAG")).equals("1")) {
                    	// 본 품의서에 포함된 신규품목등록 요청 건의 진행상태를 '합의대기(450)'으로 변경.
                        cnInfo.put("PROGRESS_CD", "450");
                        rq0102_Mapper.updateStatusNWRQ(cnInfo);

                        // 견적 품목의 진행상태를 '고객승인요청(550)'으로 변경.
                        cnInfo.put("PROGRESS_CD", "550");
                        rq0102_Mapper.updateStatusRQDT(cnInfo);

                        // 신규품목요청 I/F 테이블(ICOYPRHD_IF, ICOYPRDT_IF)의 IF_FLAG=2 변경
                        cnInfo.put("IF_FLAG", "2");				// 고객사 견적서 합의요청
                        cnInfo.put("PROCEEDING_FLAG", "RT");	// 견적합의대기(RT), 견적합의(RE)
                        realtimeif_mapper.updateItemStatusPRHD(cnInfo);
                        realtimeif_mapper.updateItemStatusPRDT(cnInfo);

                        // 고객사에서 요청한 품목과 운영사에서 등록한 품목이 혼재하는 경우 고객사 요청 품목을 기준으로 함
                        if (!"Y".equals(docCustReqFlag)) {
                            docCustReqFlag = "Y"; // 고객승인요청(견적진행상태 : MP066_550)
                        }
                    }// 운영사에서 신규품목 대행 등록한 경우
                    else {
                    	// 본 품의서에 포함된 견적의뢰서 품목의 진행상태를 '계약완료(600)'로 변경.
                        cnInfo.put("PROGRESS_CD", "600");
                        rq0102_Mapper.updateStatusRQDT(cnInfo);

                        // 공급사 견적서 QTDT.CONT_UNIT_PRC (계약단가 변경)
                        rq0102_Mapper.updateStatusQTDT(cnInfo);

                        // 본 품의서에 포함된 신규품목등록 요청 건의 진행상태를 '합의완료(500)'로 변경.
                        cnInfo.put("PROGRESS_CD", "500");
                        rq0102_Mapper.updateStatusNWRQ(cnInfo);
                    }

                    map.put("RFQ_NUM", String.valueOf(cnInfo.get("RFQ_NUM")));
                    map.put("RFQ_CNT", String.valueOf(cnInfo.get("RFQ_CNT")));
            	}

                // 해당 견적의뢰번호/차수의 품목 중 '부분선정(390)'인 상태가 있을 수 있으므로 모든 품목에 대한 진행상태가"계약완료(600)" 이상이면
                // 본 품의가 해당 견적의뢰(RQHD)를 기준으로 작성하는 마지막 품의이므로'계약완료(600)'로 진행상태를 변경한다.
                String rqhdProgressCd = EverString.nullToEmptyString(rq0102_Mapper.getRqhdProgressCd(map));
                map.put("PROGRESS_CD", (docCustReqFlag.equals("Y") ? "550" : rqhdProgressCd));
                rq0102_Mapper.rq01023_doUpdateProgressCdRQHD(map);

                // 매입단가를 등록한다.
                String contNo = "";
                // 1. 해당 품의서에 포함된 공급사 List를 가져온다.
                List<Map<String, String>> vendorList = rq0102_Mapper.getCnVendorList(map);
                for(Map<String, String> vendorData : vendorList) {

                    // 해당 공급사별 계약대상 품목정보를 가져온다.
                    List<Map<String, Object>> yInfoList = rq0102_Mapper.getYinfoByVendors(vendorData);
                    for (Map<String, Object> yInfoData : yInfoList) {

                    	// 고객사 신규상품요청 여부 (1 : 고객사 요청, 0 : 고객사 미요청)
                    	String custReqFlag = String.valueOf(yInfoData.get("CUST_REQ_FLAG"));
                        // 운영사에서 대행 등록한 경우에만 매입단가 생성
                    	// 고객사에서 등록요청한 경우에는 고객사 "견적서 합의"에서 매입단가 생성
                    	if (!custReqFlag.equals("1")) {

	                        // 계약번호 생성. (공급사별로 계약번호를 달리 생성한다.)
	                        contNo = docNumService.getDocNumber("CT");

	                        int contSeq = 1;
	                        String custListStr = EverString.nullToEmptyString(String.valueOf(yInfoData.get("APPLY_TARGET_CD")));
	                        if (custListStr.length() > 0) {
	                            String[] custListArgs = custListStr.split(",");
	                            for (int i = 0; i < custListArgs.length; i++) {
	                                yInfoData.put("APPLY_COM", custListArgs[i]);	// DGNS I/F 고객인 경우 전체 고객사
	                                Map<String, Object> newInfoData = rq0102_Mapper.getYinfoByVendor(yInfoData);


	                                // 품목등록신청에 기존 APPLY_COM, CONT_NO, CONT_SEQ가 존재하면 해당 계약을 폐기한다.
/*
	                                if (EverString.isNotEmpty(EverString.nullToEmptyString(newInfoData.get("VENDOR_CD")))
	                                 && EverString.isNotEmpty(EverString.nullToEmptyString(newInfoData.get("ITEM_CD"))))
	                                {
	                                    List<Map<String, Object>> validList = rq0102_Mapper.getValidInfos(newInfoData);
	                                    for (Map<String, Object> validData : validList) {
	                                    	validData.put("VALID_FROM_DATE", newInfoData.get("VALID_FROM_DATE"));
	                                    	rq0102_Mapper.deadPreContract(validData);
	                                    }
	                                }
*/



	                                // 계약 (운영사매입 계약단가)
	                                newInfoData.put("CONT_NO",  contNo);
	                                newInfoData.put("CONT_SEQ", contSeq);
	                                newInfoData.put("AGENT_CD", userInfo.getManageCd());
	                                newInfoData.put("CONT_TYPE_CD", "RQ"); 			// 계약유형[MP023] : 견적(RQ)
	                                newInfoData.put("RFX_TYPE", "RFQ"); 			// RFX구분[M070] - 견적(RFQ), 입찰(BID)
	                                newInfoData.put("SIGN_STATUS", "E"); 			// 승인
	                                newInfoData.put("REG_USER_ID", String.valueOf(newInfoData.get("CTRL_USER_ID")));
	                                newInfoData.put("DEAL_CD", "200"); 				// 승인
	                                newInfoData.put("CHANGE_CD", "99");
	                                newInfoData.put("CHANGE_REASON", "견적");

	                                // 승인후 운영사 매입계약단가
	                                rq0102_Mapper.insert_YINFO(newInfoData);

	                                // 고객사 품목 판매단가 정보
	                                rq0102_Mapper.insert_UINFO(newInfoData);

	                                // 품의 품목정보에 계약번호/항번을 업데이트한다.
	                                rq0102_Mapper.update_CnInfo(newInfoData);

	                                // 품목등록신청청 품목정보에 계약번호/항번을 업데이트한다.
	                                rq0102_Mapper.update_NwInfo(newInfoData);

	                                /**
	                                 * 2022.09.22 : 지역정보 제외
	                                // 계약 (운영사매입 계약단가) 지역정보 삭제
	                                rq0102_Mapper.delete_YINFR(newInfoData);

	                                // 계약 (운영사매입 계약단가) 지역정보 등록
	                                String regionCd = EverString.nullToEmptyString(newInfoData.get("REGION_CD"));
	                                if (!regionCd.equals("")) {
	                                    String[] regionArgs = regionCd.split(",");
	                                    for (int j = 0; j < regionArgs.length; j++) {
	                                        Map<String, Object> regionMap = new HashMap<String, Object>();
	                                        regionMap.put("APPLY_COM", custListArgs[i]);
	                                        regionMap.put("CONT_NO", contNo);
	                                        regionMap.put("CONT_SEQ", contSeq);
	                                        regionMap.put("REGION_CD", regionArgs[j]);
	                                        rq0102_Mapper.insert_YINFR(regionMap);
	                                    }
	                                }*/

	                                // 매입단가 이력정보 저장.
	                                rq0102_Mapper.insert_YINFH(newInfoData);

	                                // 판매단가 이력정보 저장.
	                                rq0102_Mapper.insert_UINFH(newInfoData);





	                                contSeq++;
	                            }
	                        }
                        }
                    }
                }

                /**
                 * 2020.09.22 제외
                 * 매입단가와 판매단가가 1:1로 등록되어 상위에서 처리함.
                List<Map<String, Object>> uInfoList = rq0102_Mapper.getUinfoList(map);
                for(Map<String, Object> uInfoData : uInfoList) {

                    String custReqFlag = String.valueOf(uInfoData.get("CUST_REQ_FLAG")); // 고객사 요청 여부 (1 : 고객사 요청, 0 : 고객사 미요청)
                    if(!custReqFlag.equals("1")) {

                        double salesUnitPrc = Double.parseDouble(String.valueOf(uInfoData.get("SALES_UNIT_PRICE")));

                        if (!EverString.nullToEmptyString(uInfoData.get("CUST_CD")).equals("") && salesUnitPrc > 0) {

                            String existFlag = EverString.nullToEmptyString(rq0102_Mapper.getUinfoExistFlag(uInfoData));

                            uInfoData.put("CHANGE_CD", "99");
                            uInfoData.put("CHANGE_REASON", "견적");

                            if (existFlag.equals("Y")) {
                                // 판매단가 이력정보
                                rq0102_Mapper.selectInsert_UINFH(uInfoData);
                                // 판매단가 정보
                                rq0102_Mapper.update_UINFO(uInfoData);
                            } else {
                                // 판매단가 정보
                                rq0102_Mapper.insert_UINFO(uInfoData);
                                // 판매단가 이력정보
                                rq0102_Mapper.insert_UINFH(uInfoData);
                            }
                        }
                    } else {
                        docCustReqFlag = "Y";
                    }
                }*/

                /**
                 * 자동발주 주석처리 : 2020-10-15
                 * 해당 품의에 포함된 품목이 신규품목요청 건이고, 자동발주로 설정되어 있다면 자동발주 생성.
                Map<String, String> poParam = new HashMap<String, String>();
                poParam.put("EXEC_NUM", map.get("EXEC_NUM"));

                List<Map<String, Object>> autoPoList = rq0102_Mapper.getAutoPoList(poParam);
                if(autoPoList.size() > 0) {

                    String custReqFlag = String.valueOf(autoPoList.get(0).get("CUST_REQ_FLAG")); // 고객사 요청 여부 (1 : 고객사 요청, 0 : 고객사 미요청)
                    if(!custReqFlag.equals("1")) {

                        String CPONO = docNumService.getDocNumber("CPO");
                        poParam.put("CPO_NO", CPONO);
                        poParam.put("APPROVE_FLAG", "0");
                        poParam.put("BUDGET_FLAG", "0");
                        poParam.put("PRIOR_GR_FLAG", "0");
                        poParam.put("CPO_DATE", EverDate.getDate());
                        poParam.put("SIGN_STATUS", "E");
                        poParam.put("PROGRESS_CD", "30"); // 주문완료
                        poParam.put("CUST_CD", String.valueOf(autoPoList.get(0).get("COMPANY_CD")));
                        poParam.put("CUST_USER_ID", String.valueOf(autoPoList.get(0).get("CUST_USER_ID")));
                        poParam.put("CUST_DEPT_CD", String.valueOf(autoPoList.get(0).get("CUST_DEPT_CD")));
                        poParam.put("CUST_TEL_NUM", String.valueOf(autoPoList.get(0).get("CUST_TEL_NUM")));
                        poParam.put("CUST_HP_NUM", String.valueOf(autoPoList.get(0).get("CUST_HP_NUM")));

                        // 1. STOUPOHD 등록
                        bod103_Mapper.doInsertUPOHD(poParam);

                        int cpo_seq = 1;
                        for (Map<String, Object> autoPoData : autoPoList) {

                            autoPoData.put("CPO_NO", CPONO);
                            autoPoData.put("CPO_SEQ", String.valueOf(cpo_seq++));
                            autoPoData.put("CPO_DATE", EverDate.getDate());
                            autoPoData.put("PROGRESS_CD", "30");
                            autoPoData.put("CUST_CD", String.valueOf(autoPoData.get("COMPANY_CD")));

                            // 2. STOUPODT 등록
                            bod103_Mapper.doInsertUPODT(autoPoData);

                            // 3. 고객사 신규품목(STOUNWRQ) 변경
                            if (!"".equals(EverString.nullToEmptyString(autoPoData.get("ITEM_REQ_NO")))) {
                                bod103_Mapper.doUpdateNWRQpo(autoPoData);
                            }
                        }

                        // 4. 고객사 po 진행상태 변경
                        bod103_Mapper.doUpdateSignStatusUPOHDNoApp(poParam);
                        bod103_Mapper.doUpdateSignStatusUPODT(poParam);

                        // 5. CPO를 PO로 분리하여 생성함
                        // 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호
                        // HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD
                        List<Map<String, Object>> poList = bod103_Mapper.getPOList(poParam);
                        for (Map<String, Object> poData : poList) {

                            poData.put("CPO_NO", CPONO);
                            poData.put("CUST_CD", poParam.get("CUST_CD"));
                            poData.put("PO_NO", docNumService.getDocNumber("PO"));

                            bod103_Mapper.doInsertYPOHD(poData);
                            bod103_Mapper.doInsertYPODT(poData);
                        }

                        // 1회성 품목인 경우 "품목상태=단종"으로 변경
                        bod103_Mapper.doUpdateItemStatus(poParam);

                        // EMAIL 및 SMS 발송
                        try {
                            bod103_Service.sendEmailNSms(poParam);
                        } catch (Exception ex) {
                            System.out.println("=====> 메일발송 오류 : " + ex);
                        }
                    } else {
                        docCustReqFlag = "Y";
                    }
                }*/
            }
        }

        //if(1==1) throw new Exception("==============================================");
        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }
}