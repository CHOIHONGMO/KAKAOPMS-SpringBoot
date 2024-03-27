package com.st_ones.evermp.IM03.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.message.service.MessageType;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BYM1.BYM101_Mapper;
import com.st_ones.evermp.IM03.IM0301_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "im0301_Service")
public class IM0301_Service extends BaseService {

    @Autowired private DocNumService docNumService;
    @Autowired private MessageService msg;
    @Autowired LargeTextService largeTextService;

    @Autowired private IM0301_Mapper im0301Mapper;
    @Autowired private BYM101_Mapper bym101Mapper;
    @Autowired private QueryGenService queryGenService;
    @Autowired private EApprovalService approvalService;

    // 실시간 I/F는 공통에서 관리함
    @Autowired private RealtimeIF_Service realtimeif_service;
    @Autowired private RealtimeIF_Mapper realtimeif_mapper;

    /**
     * ***************************************************************************************************************
     * 제조사/브랜드 현황
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im03007_doSearch(Map<String, String> formData) {
        return im0301Mapper.im03007_doSearch(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void im03007_doSave(List<Map<String, Object>> gridData) {
        for (Map<String, Object> gridDatum : gridData) {
            im0301Mapper.im03007_doSave(gridDatum);
        }
    }

    /**
     * ***************************************************************************************************************
     * Item Master
     *
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> im03008_doSearch(Map<String, String> formData) {

        Map<String, String> sParam = new HashMap<String, String>();
		/*
		  if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).equals("")) {
		  sParam.put("COL_VAL", formData.get("ITEM_DESC")); sParam.put("COL_NM",
		  "A.ITEM_DESC||A.ITEM_SPEC"); formData.put("ITEM_DESC",
		  EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam))
		  ); }
		 */
        return im0301Mapper.im03008_doSearch(formData);
    }

    public Map<String, Object> setSgData(Map<String, String> param) throws Exception {

        Map<String, Object> rtnMap = im0301Mapper.setSgData(param);
        return rtnMap;
    }

    public Map<String, Object> setDPSgData(Map<String, String> param) throws Exception {
        return im0301Mapper.setDPSgData(param);
    }

    /**
     * 상품관리 > 상품기본정보 > 상품정보 관리 (IM03_008) : 상품정보 변경
     * @param gridData
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void im03008_doSave(List<Map<String, Object>> gridData) throws Exception{

    	for (Map<String, Object> gridDatum : gridData) {

            if( "".equals(EverString.nullToEmptyString(gridDatum.get("ITEM_CD"))) ) {
                String newItemCode = im0301Mapper.im03008_getNewItemCode(gridDatum);
                gridDatum.put("ITEM_CD", newItemCode);
            }

            im0301Mapper.im03008_doSaveMTGL(gridDatum);     // 품목마스터
            im0301Mapper.im03008_doSaveMTGC(gridDatum);     // 분류맵핑

            if (!StringUtils.isEmpty((String) gridDatum.get("PT_ITEM_CLS_NM"))) {
                //분류매핑(판촉)
                gridDatum.put("ITEM_CLS1", gridDatum.get("PT_ITEM_CLS1"));
                gridDatum.put("ITEM_CLS2", gridDatum.get("PT_ITEM_CLS2"));
                gridDatum.put("ITEM_CLS3", gridDatum.get("PT_ITEM_CLS3"));
                im0301Mapper.im03008_doSaveMTGC(gridDatum);     // 분류맵핑
            }

            Map<String, String> imgMap = new HashMap<String, String>();
            imgMap.put("ITEM_CD", EverString.nullToEmptyString(gridDatum.get("ITEM_CD")));
            imgMap.put("IMG_ATT_FILE_NUM", EverString.nullToEmptyString(gridDatum.get("IMG_FILE_NUM")));
            imgMap.put("MAIN_IMG_SQ", EverString.nullToEmptyString(gridDatum.get("MAIN_IMG_SQ")));

            //이미지저장 -------------------------------------------------------------------------------------
            // 메인이미지 정보 초기화 후, 메인이미지가 있으면 저장
            im0301Mapper.im03009_doDeleteMTIM(imgMap);
            if (StringUtils.isNotEmpty(imgMap.get("MAIN_IMG_SQ"))) {
                im0301Mapper.im03009_doSaveMTIM(imgMap);
            }

            // ================== DGNS 상품정보 변경 ============================
            if( !"".equals(EverString.nullToEmptyString(gridDatum.get("CUST_ITEM_CD"))) ) {
                Map<String, String> dgnsData = new HashMap<>();
                dgnsData.put("CUST_ITEM_CD", EverString.nullToEmptyString(gridDatum.get("CUST_ITEM_CD")));
                dgnsData.put("ITEM_DESC", EverString.nullToEmptyString(gridDatum.get("ITEM_DESC")));
                dgnsData.put("ITEM_SPEC", EverString.nullToEmptyString(gridDatum.get("ITEM_SPEC")));
                dgnsData.put("ORGN_CD", EverString.nullToEmptyString(gridDatum.get("ORGN_CD")));
                dgnsData.put("ORGN_NM", EverString.nullToEmptyString(gridDatum.get("ORGN_NM")));
                dgnsData.put("UNIT_CD", EverString.nullToEmptyString(gridDatum.get("UNIT_CD")));
                realtimeif_service.updatePuaMtrlCd(dgnsData); 	//DGNS 품목 수정
            }


            im0301Mapper.copyMtglHist(gridDatum);


            // ================== DGNS 상품정보 변경 ============================
        }
    }

    // 품목 견적의뢰
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im03008_doEstimate(List<Map<String, Object>> gridData) throws Exception {

        String docNo = docNumService.getDocNumber("RE");
        for (Map<String, Object> gridDatum : gridData) {

            gridDatum.put("ITEM_REQ_NO", docNo);
            im0301Mapper.im03008_doEstimate(gridDatum);
        }
        return msg.getMessageByScreenId("IM01_070", "003");
    }

    public List<Map<String, Object>> im03008P_doSearch(Map<String, String> formData) {
        return im0301Mapper.im03008P_doSearch(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void im03008P_doSave(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {
        for (Map<String, Object> gridDatum : gridData) {

            gridDatum.put("ITEM_CD", formData.get("ITEM_CD"));
            if (im0301Mapper.im03008P_isDuplicateData(gridDatum)) {
                throw new Exception("[" + gridDatum.get("VENDOR_NM") + "] 업체의 품목코드가 이미 등록되어 있습니다.");
            }

            im0301Mapper.im03008P_doSave(gridDatum);
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void im03008P_doDelete(Map<String, String> formData, List<Map<String, Object>> gridData) {
        for (Map<String, Object> gridDatum : gridData) {
            gridDatum.put("ITEM_CD", formData.get("ITEM_CD"));
            im0301Mapper.im03008P_doDelete(gridDatum);
        }
    }


    //고객사품목코드매핑 조회
    public List<Map<String, Object>> im01020_doSearch(Map<String, String> formData) {

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(formData.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_DESC"));
            sParam.put("COL_NM", "MTGL.ITEM_DESC");
            formData.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(formData.get("ITEM_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("ITEM_SPEC"));
            sParam.put("COL_NM", "MTGL.ITEM_SPEC");
            formData.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(formData.get("MAKER_NM")).trim().equals("")) {
            sParam.put("COL_VAL", formData.get("MAKER_NM"));
            sParam.put("COL_NM", "MKBR.MKBR_NM");
            formData.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(formData.get("ITEM_CD"))) {
            formData.put("ITEM_CD_ORG", formData.get("ITEM_CD"));
            formData.put("ITEM_CD", EverString.forInQuery(formData.get("ITEM_CD"), ","));
            formData.put("ITEM_CNT", formData.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return im0301Mapper.im01020_doSearch(formData);
    }

    //고객사 품목코드 매핑 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01020_doSave(Map<String, String> param, List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {

            if(EverString.nullToEmptyString(rowData.get("OLD_CUST_ITEM_CD")).equals("")){
                rowData.put("OLD_CUST_ITEM_CD", rowData.get("CUST_ITEM_CD"));
            }

            im0301Mapper.im01020_doSave_MTGB(rowData);

            im0301Mapper.im01020_doSave_MTGH(rowData);
        }

        return msg.getMessage(MessageType.SAVE_SUCCEED);
    }

    //고객사 품목코드 매핑 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String im01020_doDelete(Map<String, String> param, List<Map<String, Object>> gridData) throws Exception {

        for (Map<String, Object> rowData : gridData) {
            im0301Mapper.im01020_doDelete_MTGB(rowData);
        }
        return msg.getMessage(MessageType.DELETE_SUCCEED);
    }

    //고객사품목코드 이력조회
    public List<Map<String, Object>> im01021_doSearch(Map<String, String> formData) {
        return im0301Mapper.im01021_doSearch(formData);
    }

    /**
     * *****************************************************************************************
     * 품목상세정보
     *
     * @param param
     * @return
     * @throws Exception
     */

    //품목상세정보
    public Map<String, String> im03009_doSearchInfo(Map<String, String> param) throws Exception {
        Map<String, String> formData = im0301Mapper.im03009_doSearchInfo(param);
        return formData;
    }
    //품목상세정보(APP_DOC_NUM)로 조회 (결재상세)
    public Map<String, String> im03009_doSearch_app_Info(Map<String, String> param) throws Exception {
        Map<String, String> formData = im0301Mapper.im03009_doSearch_app_Info(param);
        return formData;
    }

    //품목상세정보(cart대상)
    public Map<String, String> im03014_doSearchInfo_doCart(Map<String, String> param) throws Exception {
        Map<String, String> formData = im0301Mapper.im03014_doSearchInfo_doCart(param);
        if(formData.get("VIEW_UNIT_PRC") !=null && "".equals(formData.get("VIEW_UNIT_PRC"))) formData.put("VIEW_UNIT_PRC",EverMath.EverNumberType(EverString.nullToEmptyString(formData.get("UNIT_PRC")), "###,###"));
        if(formData.get("VIEW_RV_QTY") !=null && "".equals(formData.get("VIEW_RV_QTY"))) formData.put("VIEW_RV_QTY",EverMath.EverNumberType(EverString.nullToEmptyString(formData.get("RV_QTY")), "###,###"));
        if(formData.get("VIEW_MOQ_QTY") !=null && "".equals(formData.get("VIEW_MOQ_QTY"))) formData.put("VIEW_MOQ_QTY",EverMath.EverNumberType(EverString.nullToEmptyString(formData.get("MOQ_QTY")), "###,###"));
        return formData;
    }
    //공급사 신규품목제안 > 품목상세정보
    public Map<String, String> im03009_doSearchInfo_RP(Map<String, String> param) throws Exception {
        Map<String, String> formData = im0301Mapper.im03009_doSearchInfo_RP(param);
        return formData;
    }



    //품목_계약정보
    public List<Map<String, Object>> im03009_doSearch_CT(Map<String, String> formData) {
//    	System.err.println(formData);

    	if(!"".equals(formData.get("APP_DOC_NUM"))) {
            return im0301Mapper.im03009_doSearch_CT_SIGN(formData);
    	} else {
            return im0301Mapper.im03009_doSearch_CT(formData);
    	}



    }

    //품목_계약정보_공급사신규품목제약
    public List<Map<String, Object>> im03009_doSearchRP_CT(Map<String, String> formData) {
        return im0301Mapper.im03009_doSearchRP_CT(formData);
    }

    //품목_고객사별 판매단가
    public List<Map<String, Object>> im03009_doSearch_PR(Map<String, String> formData) {
        return im0301Mapper.im03009_doSearch_PR(formData);
    }

    //품목 속성
    public List<Map<String, Object>> im03009_doSearch_AT(Map<String, String> formData) {
        return im0301Mapper.im03009_doSearch_AT(formData);
    }


    public List<Map<String, Object>> im03009_doSearch_NmgCust(Map<String, String> formData) {
        return im0301Mapper.im03009_doSearch_NmgCust(formData);
    }

    //품목등록
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03009_doSave(Map<String, String> formData, List<Map<String, Object>> gridDataCt, List<Map<String, Object>> gridDataAt) throws Exception {

        Map<String, Object> ObjData = new HashMap<String, Object>();
        Map<String, String> rtnMap = new HashMap<String, String>();
        String itemCd = EverString.nullToEmptyString(formData.get("ITEM_CD"));
        String signStatus = EverString.nullToEmptyString(formData.get("signStatus"));

        // 상품상세정보 저장
        String itemDetailTextNum = largeTextService.saveLargeText(formData.get("ITEM_DETAIL_TEXT_NUM"), formData.get("TEXT_CONTENTS"));
        formData.put("ITEM_DETAIL_TEXT_NUM", itemDetailTextNum);
        formData.put("PROGRESS_CD", signStatus); // 임시저장 : T, 등록/수정 : E

        // 신규등록일경우 상품코드 번호채번, 품목 등록 | 수정 --------------------------------------------------
        if (itemCd.equals("")) {
            //품목 insert
        	itemCd = docNumService.getDocNumber("IT");
            formData.put("ITEM_CD", itemCd);

            // 고객사 분류체계가 존재하는 경우 DGNS의 상품코드 채번
            im0301Mapper.im03009_MTGL_Insert(formData);			// 품목 기본정보 등록
        	// ======================== DGNS 품목코드 연동 ==================================
            if( formData.get("ITEM_CLS3_CUST") != null && !"".equals(formData.get("ITEM_CLS3_CUST")) && !"*".equals(formData.get("ITEM_CLS3_CUST")) ) {
            	Map<String, String> dgnsData = realtimeif_mapper.getDgnsItemCd(formData);
            	formData.put("DGNS_ITEM_ID", dgnsData.get("DGNS_ITEM_ID"));
            	formData.put("MK_NM", dgnsData.get("MK_NM"));
            	formData.put("DGNS_ITEM_CD", realtimeif_mapper.getDgnsItemCd2(formData));

            	if( formData.get("DGNS_ITEM_CD") != null && !"".equals(formData.get("DGNS_ITEM_CD")) ) {
	            	realtimeif_service.insPuaMtrlCd(formData);		//DGNS 품목 등록

	                im0301Mapper.im03008_copyCustMTGC(formData);	// 고객사 분류맵핑
	                im0301Mapper.im03008_copyCustMTGB(formData);	// 고객사 품목저장
	                im0301Mapper.im03009_UpdateCustItemCd(formData);// 고객사 품목저장
            	}
            }
        	// ======================== DGNS 품목코드 연동 ==================================
            im0301Mapper.im03009_STOYMTRP_Update(formData);		// 공급사 품목제안
        }
        else {
        	// ======================== DGNS 품목코드 연동 ==================================
            if( formData.get("ITEM_CLS3_CUST") != null && !"".equals(formData.get("ITEM_CLS3_CUST")) && !"*".equals(formData.get("ITEM_CLS3_CUST")) ) {
            	if( "".equals(formData.get("ITEM_CLS3_CUST_BEFORE")) ) {
            		Map<String, String> dgnsData = realtimeif_mapper.getDgnsItemCd(formData);
	            	formData.put("DGNS_ITEM_ID", dgnsData.get("DGNS_ITEM_ID"));
	            	formData.put("MK_NM", dgnsData.get("MK_NM"));
	            	formData.put("DGNS_ITEM_CD", realtimeif_mapper.getDgnsItemCd2(formData));

	            	if( formData.get("DGNS_ITEM_CD") != null && !"".equals(formData.get("DGNS_ITEM_CD")) ) {
		            	realtimeif_service.insPuaMtrlCd(formData); 		// DGNS 품목 신규등록

		            	im0301Mapper.im03008_copyCustMTGC(formData);    // 고객사 분류 신규등록
		                im0301Mapper.im03008_copyCustMTGB(formData);    // 고객사 품목 신규등록
	            	}
            	} else {
            		realtimeif_service.updatePuaMtrlCd(formData); 	//DGNS 품목 수정
            	}
            }
        	// ======================== DGNS 품목코드 연동 ==================================

            //품목 update
            im0301Mapper.im03009_MTGL_Update(formData);
        }

        im0301Mapper.copyMtglHist(formData);

        // 이미지저장 -------------------------------------------------------------------------------------
        // 메인이미지 정보 초기화 후, 메인이미지가 있으면 저장
        im0301Mapper.im03009_doDeleteMTIM(formData);
        if (StringUtils.isNotEmpty(formData.get("MAIN_IMG_SQ"))) {
            im0301Mapper.im03009_doSaveMTIM(formData);
        }

        // 품목분류매핑저장
        ObjData.putAll(formData);
        im0301Mapper.im03008_doSaveMTGC(ObjData);     // 분류맵핑

        im0301Mapper.im03009_doDeleteMTAT(formData);
        for (Map<String, Object> atList : gridDataAt) {
            atList.put("ITEM_CD", itemCd);
            atList.put("ITEM_CLS1", formData.get("ITEM_CLS1"));
            atList.put("ITEM_CLS2", formData.get("ITEM_CLS2"));
            atList.put("ITEM_CLS3", formData.get("ITEM_CLS3"));
            atList.put("ITEM_CLS4", formData.get("ITEM_CLS4"));
            im0301Mapper.im03009_doSaveMTAT(atList);
        }

        // 계약정보저장 -----------------------------------------------------------------------------------
        String contNo = "";
        if(gridDataCt.size() > 0) {
        	// 단가가 변경 되면 무조건 결재를 태운다.
            formData.put("YINFO_SIGN_STATUS","P");

            // 단가등록 or 단가수정시 결재요청
            //String appDocNum = EverString.nullToEmptyString(gridDataCt.get(0).get("APP_DOC_NUM"));
            //String appDocCnt = EverString.nullToEmptyString(gridDataCt.get(0).get("APP_DOC_CNT"));

            String appDocNum = "";
            String appDocCnt = "";
            if (EverString.nullToEmptyString(formData.get("YINFO_SIGN_STATUS")).equals("P")) {

                formData.put("SIGN_STATUS",formData.get("YINFO_SIGN_STATUS"));
                if (EverString.isEmpty(appDocNum)) {
                    appDocNum = docNumService.getDocNumber("AP");
                }
                formData.put("APP_DOC_NUM", appDocNum);

                if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                    appDocCnt = "1";
                    formData.put("APP_DOC_CNT", appDocCnt);
                } else {
                    appDocCnt = EverString.nullToEmptyString(Integer.parseInt(appDocCnt) + 1);
                    formData.put("APP_DOC_CNT", appDocCnt);
                }
                //임시 품목 정식코드전환시 결재 상태값 업데이트. 이유--> 똑같은 임시품목 중복결재 방지.
                if(!EverString.isEmpty(EverString.nullToEmptyString(formData.get("OLD_ITEM_CD"))) && !EverString.isEmpty(formData.get("CHANGE_DT"))) {
                	int check = im0301Mapper.checkChageDtSign(formData);
                	if(check>0) {
                		throw new Exception("결재 신청 된건입니다.");
                	}else {
                		im0301Mapper.updateAppCheck(formData);
                	}
                }
            }

            for(int i = 0; i < gridDataCt.size(); i++) {
                // 계약번호 생성.
                Map<String, Object> ctData = gridDataCt.get(i);
                ctData.put("ITEM_CD", formData.get("ITEM_CD"));

                if("".equals(ctData.get("CONT_NO")) || ctData.get("CONT_NO") == null) {
                    contNo = docNumService.getDocNumber("CT");
                    ctData.put("CONT_NO", contNo);
                    ctData.put("CONT_SEQ", "1");
                }


                /**
                List<Map<String, Object>> chkList =  im0201_Mapper.doCheckExistUinfo(ctData);
    	    	if(chkList.size() == 0) {
                    if(EverString.nullToEmptyString(ctData.get("CONT_NO")).equals("")){
                        contNo = docNumService.getDocNumber("CT");
                        ctData.put("CONT_NO", contNo);
                        ctData.put("CONT_SEQ", "1");
                    }
    	    	} else {
                    ctData.put("CONT_NO", chkList.get(0).get("CONT_NO"));
                    ctData.put("CONT_SEQ",  chkList.get(0).get("CONT_SEQ"));
                    ctData.put("PREV_UNIT_PRICE",  chkList.get(0).get("SALES_UNIT_PRICE"));
    	    	}*/

                ctData.put("ITEM_CD", itemCd);
                ctData.put("CONT_TYPE_CD", "MN");
                ctData.put("TAX_CD", EverString.nullToEmptyString(formData.get("VAT_CD")));
                ctData.put("SG_CTRL_USER_ID", EverString.nullToEmptyString(formData.get("SG_CTRL_USER_ID")));
                ctData.put("CMS_CTRL_USER_ID", EverString.nullToEmptyString(formData.get("CMS_CTRL_USER_ID")));

                ctData.put("UNIT_CD", EverString.nullToEmptyString(formData.get("UNIT_CD")));

                ctData.put("APP_DOC_NUM", appDocNum);
                ctData.put("APP_DOC_CNT", appDocCnt);
                ctData.put("SIGN_STATUS", formData.get("YINFO_SIGN_STATUS"));
                ctData.put("PLANT_CD", (EverString.nullToEmptyString(ctData.get("APPLY_PLANT")).equals("") ? "*" : EverString.nullToEmptyString(ctData.get("APPLY_PLANT"))));

                im0301Mapper.im03009_doSave_YINFH(ctData);

                ctData.put("CUST_CD", ctData.get("APPLY_COM"));
                im0301Mapper.im03009_doSave_UINFH(ctData);

                formData.put("DOC_TYPE", "INFOCH");
            }

            approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        }
        rtnMap.put("ITEM_CD", itemCd);
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        //if (1==1) throw new Exception("===========================================================1=");
        return rtnMap;
    }

    //품목_계약정보삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void im03009_doDeletegridct(Map<String, String> formData, List<Map<String, Object>> gridDataCt) throws Exception {
        for(Map<String, Object> ctList : gridDataCt) {
            //계약테이블삭제
            im0301Mapper.im03009_doDelete_YINFO(ctList);

            im0301Mapper.im03009_doDeletegridpr(ctList);
            //해당계약의 지역정보삭제
            //im0301Mapper.im03009_doUpdateDel_YINFR(ctList);

        }
    }

    //품목_단가정보삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void im03009_doDeletegridpr(Map<String, String> formData, List<Map<String, Object>> gridData) throws Exception {
        for (Map<String, Object> gridDatum : gridData) {

            //단가정보삭제
            im0301Mapper.im03009_doDeletegridpr(gridDatum);
            //이력등록
        }
    }

    // 품목단가정보 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void progressApproval(String docNum, String docCnt, String signStatus, String itemCd, String contNo) throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);
        map.put("ITEM_CD", itemCd);
        map.put("CONT_NO", contNo);
        im0301Mapper.doUpdate_app_YINFO(map);
    }

    // 품목단가정보 등록 및 변경 _ 결재승인(E) / 반려(R) / 취소(C)시 sign_status, sign_date, progress_cd(2100) 변경
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval(String docNum, String docCnt, String signStatus) throws Exception {

    	Map<String, String> map = new HashMap<String, String>();

        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);

        List<Map<String,Object>> yinfhList = im0301Mapper.getTargetYInfhList(map);
    	map.put("OLD_ITEM_CD", EverString.nullToEmptyString(yinfhList.get(0).get("OLD_ITEM_CD")));

        if(signStatus.equals("E") || signStatus.equals("R") || signStatus.equals("C")) {

        	// 1. 매입가 처리
        	im0301Mapper.updateSignYInfh(map);
    		// 2. 매출가 처리
    		im0301Mapper.updateSignUInfh(map);

    		if(signStatus.equals("E")) {
    			//임시품목 => 정식코드 전환시 임시품목상태 "삭제"로 변경
    	        if( yinfhList.get(0).get("TEMP_CD_FLAG") != null && "1".equals(yinfhList.get(0).get("TEMP_CD_FLAG")) ) {
    	        	im0301Mapper.chageTemporaryItem(map);
    	        }
    			for( Map<String, Object> data : yinfhList ) {


    				// 무조건 업데이트 단가변경 후 상품상태 사용으로 업데이트
    				im0301Mapper.upsMtglStatus(data);



    				List<Map<String,Object>> chk = im0301Mapper.chkYInfo(data);
    				//System.err.println(data+"========================================================================chk="+chk);
    				if( chk.size() == 0 ) {
        				im0301Mapper.updateValidTodateYInfo(data);
    				} else {
        				im0301Mapper.deleteYInfo(data);
    				}
    				// 유효 지난거 일괄 삭제
    				im0301Mapper.deleteYInfoValid(data);







    				im0301Mapper.copyYInfhToYInfo(data);

    				// ==============================================================================
    				// 3. DGNS I/F 테이블 등록
        			if( "1".equals(EverString.nullToEmptyString(data.get("ERP_IF_FLAG"))) ) {
            			Map<String,String> ifData = new HashMap<>();
            			ifData.put("CUST_ITEM_CD", EverString.nullToEmptyString(data.get("CUST_ITEM_CD")));	// 고객사 상품코드
            			ifData.put("USE_FLAG", "1");
            			realtimeif_mapper.updateItemUseFlag(ifData);	// DGNS 품목마스터(PUA_MTRL_CD)의 USE_YN=1 처리함

            			// 변경전 매입단가와 변경후 매입단가가 다르고, 계약기간이 유효한 경우에만 단가 i/f
            			// 1 : 신규단가, 2 : 변경단가
            			if( "1".equals(EverString.nullToEmptyString(data.get("UNIT_IF_FLAG"))) || "2".equals(EverString.nullToEmptyString(data.get("UNIT_IF_FLAG"))) ) {
            				BigDecimal STD_UNIT_PRICE =(BigDecimal) data.get("STD_UNIT_PRICE");
            				STD_UNIT_PRICE = STD_UNIT_PRICE ==null ? BigDecimal.ZERO : STD_UNIT_PRICE;
            				ifData.put("COMPANY_CODE"	, EverString.nullToEmptyString(data.get("APPLY_COM")));	// 단가적용 고객사코드
	            			ifData.put("DIVISION_CODE"	, EverString.nullToEmptyString(data.get("APPLY_PLANT")));	// 단가적용 사업장코드
	            			ifData.put("UNIT_PRICE"		, String.valueOf(STD_UNIT_PRICE));	// 표준 판매단가

	            			// 매출단가 변경인 경우에만 변경정보를 함께 전송
	            			if( "2".equals(EverString.nullToEmptyString(data.get("UNIT_IF_FLAG"))) ) {
	            				ifData.put("PRICE_CHANGE_REASON", EverString.nullToEmptyString(data.get("PRICE_CHANGE_REASON")));
	            				ifData.put("PRICE_CHANGE_DATE", EverString.nullToEmptyString(data.get("PRICE_CHANGE_DATE")));
	            				ifData.put("PRICE_CHANGE_TIME", EverString.nullToEmptyString(data.get("PRICE_CHANGE_TIME")));
	            				ifData.put("PRICE_USER_ID", EverString.nullToEmptyString(data.get("REG_USER_ID")));
	            			}

	            			// 품목정보 i/f 테이블 등록(ICOYITEM_IF)
	            			realtimeif_service.insCustUinfo(ifData);

	            			//판매단가 DGNS I/F 여부 세팅(ERP_IF_SEND_FLAG)
	                		im0301Mapper.updateDgnsIfFlag(data);
            			}
        			}
        			// ==============================================================================
    			}

        		im0301Mapper.deleteUInfo(map);
        		im0301Mapper.copyUInfhToUInfo(map);

        		// 공급사 요청품목 : 품목접수 결재 승인 시 계약완료
        		im0301Mapper.doUpdateMTRP(map);
    		}
        }
        //승인반려 시 정식품목코드전환 결재상태변경
        if( yinfhList.get(0).get("TEMP_CD_FLAG") != null && "1".equals(yinfhList.get(0).get("TEMP_CD_FLAG")) ) {
        	im0301Mapper.updateAppSign(map);
        }
        //if(1==1) throw new Exception("======================================================");
        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }

    /** *****************
     * 품목상세 > 카트담기, 관심품목담기
     ******************/
    //품목등록
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03014_doSaveCart(Map<String, String> formData) throws Exception {
        Map<String, String> rtnMap = new HashMap<String, String>();


        UserInfo userInfo = UserInfoManager.getUserInfo();
        Map<String, Object> ObjData = new HashMap<String, Object>();
        formData.put("USER_ID",userInfo.getUserId());
        ObjData.putAll(formData);
        bym101Mapper.bym1020_doAddCart(ObjData);

        rtnMap.put("rtnMsg", msg.getMessageByScreenId("IM03_014", "006"));
        return rtnMap;
    }

    /** *****************
      * 품목관리 > 품목표준화 > 신규품목 접수
      ******************/
    public List<Map<String, Object>> im03010_doSearch(Map<String, String> param) throws Exception {

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_NM")).trim().equals("")) {
            sParam.put("COL_NM", "A.ITEM_DESC");
            sParam.put("COL_VAL", param.get("ITEM_NM"));
            param.put("ITEM_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_SPEC")).trim().equals("")) {
            sParam.put("COL_NM", "A.ITEM_SPEC");
            sParam.put("COL_VAL", param.get("ITEM_SPEC"));
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(param.get("ITEM_REQ_NO"))) {
            param.put("ITEM_REQ_NO_ORG", param.get("ITEM_REQ_NO"));
            param.put("ITEM_REQ_NO", EverString.forInQuery(param.get("ITEM_REQ_NO"), ","));
            param.put("ITEM_REQ_CNT", param.get("ITEM_REQ_NO").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }
        Map<String, Object> fParam = new HashMap<String, Object>(param);
        if(param.get("PROGRESS_CD")!=null && !param.get("PROGRESS_CD").equals("")) {
        	fParam.put("PROGRESS_CD_LIST", Arrays.asList(param.get("PROGRESS_CD").split(",")));
        }
        return im0301Mapper.im03010_doSearch(fParam);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doSave(List<Map<String, Object>> grid) throws Exception {
        Map<String, String> rtnMap = new HashMap<String, String>();

        for (Map<String, Object> data : grid) {
            im0301Mapper.im03010_doSave(data);
        }

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    // 소싱관리 > 신규소싱 > 신규상품 접수 (IM03_010) : 표준화담당자 지정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doAssigmnent(List<Map<String, Object>> grid) throws Exception {

        for (Map<String, Object> data : grid) {
            im0301Mapper.im03010_doAssigmnent(data);
        }

        Map<String, String> rtnMap = new HashMap<String, String>();
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    // 소싱관리 > 신규소싱 > 신규상품 접수 (IM03_010) : 취소/삭제건 재접수
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doItemMapping(List<Map<String, Object>> grid) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();

        for (Map<String, Object> data : grid) {
            data.put("PROGRESS_CD", "300");
            im0301Mapper.im03010_doItemMapping(data);
        }
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    // 고객사 신규품목코드 할당정보 회신
    // 회신시 신규품목등록 요청자에게 품목코드 할당(매핑) 완료를 통보한다.
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doReply(List<Map<String, Object>> grid) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();

        for (Map<String, Object> data : grid) {
            data.put("PROGRESS_CD", "250");
            im0301Mapper.im03010_doItemMapping(data);
        }

        /**
         *  메일 발송은 제외 [2022.09.05 HMCHOI] : 필요한 경우 메일 템플릿 작성 후 주석 풀기 바랍니다...
        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.BNM3_TemplateFileName");

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

        for (Map<String, Object> data : grid) {

            data.put("PROGRESS_CD", "250");
            im0301Mapper.im03010_doItemMapping(data);

            Map<String, Object> reqData = im0301Mapper.getReqItemInfo(data);

            String itemDesc = EverString.nullToEmptyString(reqData.get("ITEM_DESC"));
            if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }

            String itemSpec = EverString.nullToEmptyString(reqData.get("ITEM_SPEC"));
            if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }

            String tblBody = "<tbody>";
            String enter = "\n";
            String tblRow = "<tr>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("ITEM_REQ_SEQ")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("ITEM_CD")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("MAKER_NM")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("UNIT_CD")) + "</th>"
                    + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(reqData.get("SEND_USER_NM")) + "</th>"
                    + enter + "</tr>";
            tblBody += tblRow;

            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$RECV_USER_NM$", EverString.nullToEmptyString(reqData.get("RECV_USER_NM"))); // 주문자명(고객)
            fileContents = EverString.replace(fileContents, "$ITEM_REQ_NO$", EverString.nullToEmptyString(reqData.get("ITEM_REQ_NO"))); // 신규품목요청번호
            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            if(!EverString.nullToEmptyString(reqData.get("RECV_EMAIL")).equals("")) {
                Map<String, String> mdata = new HashMap<String, String>();
                mdata.put("SUBJECT", "[대명소노시즌] " + EverString.nullToEmptyString(reqData.get("RECV_USER_NM")) + "님. 요청하신 신규품목 등록 처리가 완료되었습니다.");
                mdata.put("CONTENTS_TEMPLATE", fileContents);
                mdata.put("SEND_USER_ID", EverString.nullToEmptyString(reqData.get("SEND_USER_ID")));
                mdata.put("SEND_USER_NM", EverString.nullToEmptyString(reqData.get("SEND_USER_NM")));
                mdata.put("SEND_EMAIL", EverString.nullToEmptyString(reqData.get("SEND_EMAIL")));
                mdata.put("RECV_USER_ID", EverString.nullToEmptyString(reqData.get("RECV_USER_ID")));
                mdata.put("RECV_USER_NM", EverString.nullToEmptyString(reqData.get("RECV_USER_NM")));
                mdata.put("RECV_EMAIL", EverString.nullToEmptyString(reqData.get("RECV_EMAIL")));
                mdata.put("REF_NUM", EverString.nullToEmptyString(reqData.get("ITEM_REQ_NO")));
                mdata.put("REF_MODULE_CD", "RE"); // 참조모듈
                // 메일전송.
                everMailService.sendMail(mdata);
                mdata.clear();
            }
            if(!EverString.nullToEmptyString(reqData.get("RECV_TEL_NUM")).equals("")) {
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("SMS_SUBJECT", "[대명소노시즌] 신규품목 등록처리가 완료되었습니다."); // SMS 제목
                sdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(reqData.get("RECV_USER_NM")) + "님. 요청하신 신규품목 등록 처리가 완료되었습니다."); // 전송내용
                sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(reqData.get("SEND_USER_ID")).equals("") ? "SYSTEM" : EverString.nullToEmptyString(reqData.get("SEND_USER_ID")))); // 보내는 사용자ID
                sdata.put("SEND_USER_NM", EverString.nullToEmptyString(reqData.get("SEND_USER_NM"))); // 보내는사람
                sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(reqData.get("RECV_USER_ID"))); // 받는 사용자ID
                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(reqData.get("RECV_USER_NM"))); // 받는사람
                sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(reqData.get("RECV_TEL_NUM"))); // 받는 사람 전화번호
                sdata.put("REF_NUM", EverString.nullToEmptyString(reqData.get("ITEM_REQ_NO"))); // 참조번호
                sdata.put("REF_MODULE_CD", "RE"); // 참조모듈
                // SMS 전송.
                everSmsService.sendSms(sdata);
                sdata.clear();
            }
        }*/

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    // 소싱관리 > 신규소싱 > 신규상품 접수 (IM03_010) : 상품 신규요청 반려
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doReRequest(List<Map<String, Object>> grid) throws Exception {
        Map<String, String> rtnMap = new HashMap<String, String>();

        for (Map<String, Object> data : grid) {
            data.put("PROGRESS_CD", "110"); // 반려

            im0301Mapper.im03010_doReRequest(data);
        }

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doNotStandardization(List<Map<String, Object>> grid) throws Exception {
        Map<String, String> rtnMap = new HashMap<String, String>();
        Map<String, Object> map = new HashMap<String, Object>();

        String ITEM_CD = "";

        for (Map<String, Object> data : grid) {
            ITEM_CD = docNumService.getDocNumber("IT");

            data.put("PROGRESS_CD", "300");
            data.put("ITEM_CD", ITEM_CD);

            im0301Mapper.im03010_doNotStandardization(data);

            String itemDetailTextNum = largeTextService.saveLargeText("", EverString.nullToEmptyString(data.get("ITEM_RMK")));
            data.put("ITEM_DETAIL_TEXT_NUM", itemDetailTextNum);
            data.put("PROGRESS_CD", "E");
            data.put("ITEM_STATUS", "10");

            im0301Mapper.im03010_MTGL_Insert(data);

            map.clear();
            map.putAll(data);
            im0301Mapper.im03008_doSaveMTGC(map);     // 분류맵핑
        }

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03010_doDelete(List<Map<String, Object>> grid) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();

        for (Map<String, Object> data : grid) {
            data.put("PROGRESS_CD", "700");
            im0301Mapper.im03010_doDelete(data);
        }

        rtnMap.put("rtnMsg", msg.getMessage("0017"));
        return rtnMap;
    }

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수 > 표준화 팝업
     ******************/
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03015_doSave(Map<String, String> formData, List<Map<String, Object>> gridDataAt) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();
        Map<String, Object> map = new HashMap<String, Object>();

        String ITEM_CD = docNumService.getDocNumber("IT");
        formData.put("MTGL_ITEM_CD", ITEM_CD);

        formData.put("PROGRESS_CD", "300"); // STOUNWRQ의 진행상태 : 300(접수)
        formData.put("MTGL_STD_FLAG", "1");

        im0301Mapper.im03015_NWRQ_Update(formData);

        String itemDetailTextNum = largeTextService.saveLargeText(formData.get("MTGL_ITEM_DETAIL_TEXT_NUM"), formData.get("MTGL_TEXT_CONTENTS"));
        formData.put("MTGL_ITEM_DETAIL_TEXT_NUM", itemDetailTextNum);
        formData.put("PROGRESS_CD", "W");	// 승인요청(W) 상태로 등록 => 상품등록완료 처리시 승인(E) 으로 진행상태 변경
        formData.put("ITEM_STATUS", "10");	// 사용(10)

        im0301Mapper.im03015_MTGL_Insert(formData);

        formData.put("ITEM_CD", ITEM_CD);

        im0301Mapper.im03009_doDeleteMTIM(formData);
        if (StringUtils.isNotEmpty(formData.get("MAIN_IMG_SQ"))) {
            im0301Mapper.im03009_doSaveMTIM(formData);  // 이미지 저장
        }

        formData.put("ITEM_CLS1", formData.get("MTGL_ITEM_CLS1"));
        formData.put("ITEM_CLS2", formData.get("MTGL_ITEM_CLS2"));
        formData.put("ITEM_CLS3", formData.get("MTGL_ITEM_CLS3"));
        formData.put("ITEM_CLS4", formData.get("MTGL_ITEM_CLS4"));

        map.putAll(formData);
        im0301Mapper.im03008_doSaveMTGC(map);     // 분류맵핑

        im0301Mapper.im03009_doDeleteMTAT(formData);
        for (Map<String, Object> atList : gridDataAt) {
            atList.put("ITEM_CD", ITEM_CD);
            atList.put("ITEM_CLS1", formData.get("ITEM_CLS1"));
            atList.put("ITEM_CLS2", formData.get("ITEM_CLS2"));
            atList.put("ITEM_CLS3", formData.get("ITEM_CLS3"));
            atList.put("ITEM_CLS4", formData.get("ITEM_CLS4"));
            im0301Mapper.im03009_doSaveMTAT(atList);    // 속성 저장
        }



        im0301Mapper.copyMtglHist(formData);

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    /** *****************
     * 품목관리 > 품목표준화 > 신규품목 접수 > 신규요청등록 팝업
     ******************/
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> im03016_doRequest(Map<String, String> form, List<Map<String, Object>> grid) throws Exception {

        for (Map<String, Object> data : grid) {
            data.put("PROGRESS_CD", "100");	// 운영사에서 대행 등록시 "신규견적요청(100)"로 등록
            data.put("ITEM_REQ_NO", docNumService.getDocNumber("RE"));
            data.put("CUST_CD", form.get("CUST_CD"));
            data.put("PLANT_CD", form.get("ADD_PLANT_CD"));
            data.put("REQUEST_DATE", form.get("REQUEST_DATE"));
            data.put("REQUEST_USER_ID", form.get("ADD_USER_ID"));
            data.put("REQ_DIVISION_CD", form.get("REQ_DIVISION_CD"));
            data.put("REQ_DEPT_CD", form.get("REQ_DEPT_CD"));
            data.put("REQ_PART_CD", form.get("REQ_PART_CD"));
            data.put("BUDGET_DEPT_CD", form.get("BUDGET_DEPT_CD"));
            data.put("HOPE_DUE_DATE", form.get("HOPE_DUE_DATE"));

            im0301Mapper.im03016_doRequest(data);
        }

        Map<String, String> rtnMap = new HashMap<String, String>();
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    public Map<String, String> im03014_detailImgInfo(Map<String, String> formData) {
        return im0301Mapper.im03014_detailImgInfo(formData);
    }
    public Map<String, String> im03014_detailImgInfo2(Map<String, String> formData) {
    	return im0301Mapper.im03014_detailImgInfo2(formData);
    }















    public Map<String, String> getItemViewData(Map<String, String> param) throws Exception {
        Map<String, String> formData = im0301Mapper.getItemViewData(param);
        return formData;
    }




















    public List<Map<String, Object>> getItemHistList(Map<String, String> param) throws Exception {
        return im0301Mapper.getItemHistList(param);
    }


















}