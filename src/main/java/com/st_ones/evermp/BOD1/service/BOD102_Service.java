package com.st_ones.evermp.BOD1.service;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BOD1.BOD102_Mapper;
import com.st_ones.evermp.BOD1.BOD103_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BOD102_Service.java
 * @author  최홍모
 * @date 2018. 10. 25.
 * @version 1.0
 */

@Service(value = "bod102_Service")
public class BOD102_Service extends BaseService {

    @Autowired BOD102_Mapper  bod102_Mapper;
    @Autowired BOD103_Mapper  bod103_Mapper;  // 주문Cart
    @Autowired BOD103_Service bod103_Service; // 주문Cart
    @Autowired DocNumService  docNumService;  // 문서번호채번
    @Autowired EApprovalService approvalService;
    @Autowired LargeTextService largeTextService;
    @Autowired private CommonComboService commonComboService;
    @Autowired MessageService msg;

    /** ******************************************************************************************
     * 주문일괄등록 조회
     */
    public List<Map<String, Object>> bod1020_doSearch(Map<String, String> param) throws Exception {
        List<Map<String, Object>> list = bod102_Mapper.bod1020_doSearch(param);
        return list;
    }


    public List<Map<String, Object>> bod1021_doSearch(Map<String, String> param) throws Exception {
        List<Map<String, Object>> list = bod102_Mapper.bod1021_doSearch(param);
        return list;
    }


    // 사용자 기본배송지 가져오기
    public Map<String, Object> bod1020_doSearchDelyInfo(Map<String, String> param) throws Exception {

        return bod102_Mapper.bod1020_doSearchDelyInfo(param);
    }

    // 저장 및 유효성검증, 주문하기
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1020_doSave(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {
        String messageCode = "0001";
        String pMod = EverString.nullToEmptyString(param.get("pMod"));

        String CPONO = "";
        String APPROVALFLAG = "";  // 결재여부
        String BUDGETFLAG 	= "";  // 예산체크여부


        String SIGN_STATUS  = "E"; // 결재상태
        if( "Order".equals(pMod) ) {
            CPONO = docNumService.getDocNumber("CPO");
            APPROVALFLAG = param.get("APPROVE_FLAG"); // 결재여부
            BUDGETFLAG 	 = param.get("BUDGET_FLAG");  // 예산체크여부
        }

        int cpoSeq = 1;
        String resultCd;
        String resultMsg;
        for( Map<String, Object> gridData : gridList ){
        	String PROGRESS_CD = "";
        	String prType = gridData.get("PR_TYPE").toString();  // G : 일반구매 , C : 시행구매

            resultCd  = "OK";
            resultMsg = "";

            Map<String, Object> custInfo = bod102_Mapper.doGetCustInfo(gridData); //고객사 체크


            if( custInfo == null || "".equals(EverString.nullToEmptyString(custInfo.get("CUST_CD"))) ) {
                resultCd   = "Error";
                resultMsg += "고객사 없음/";
            }



    		if ( "1".equals(gridData.get("AUTO_PO_FLAG")) && gridData.get("ITEM_CD")!=null && !"".equals(gridData.get("ITEM_CD"))) { // 고객사 자동발주 여부 체크 시행구매도 동일하게
        		PROGRESS_CD = "5100"; // 발주완료
    		} else {
        		PROGRESS_CD = "2100"; //접수대기
    		}




            Map<String, Object> custUser = bod102_Mapper.doGetCustUser(gridData); //고객사 사용자 체크
            if( custUser == null || "".equals(EverString.nullToEmptyString(custUser.get("USER_ID"))) ) {
                resultCd   = "Error";
                resultMsg += "주문자 없음/";
            }



            if( "G".equals(prType) ||  (gridData.get("ITEM_CD") !=null && !"".equals(gridData.get("ITEM_CD")))   ) {
                Map<String, Object> itemInfo = bod102_Mapper.doGetItemInfo(gridData); //품목 체크
                if( itemInfo == null || "".equals(EverString.nullToEmptyString(itemInfo.get("ITEM_CD"))) ) {
                    resultCd   = "Error";
                    resultMsg += "품목코드 없음/";
                } else {
                    if( !"10".equals(itemInfo.get("ITEM_STATUS")) ){
                        resultCd  = "Error";
                        resultMsg += "품목상태 체크/";
                    }
                }
            }


        	if(gridData.get("ITEM_CD")!=null &&  !"".equals(gridData.get("ITEM_CD"))) {
                Map<String, Object> vendorInfo = bod102_Mapper.doGetVendorInfo(gridData); // 공급사 체크
                if( vendorInfo == null || "".equals(EverString.nullToEmptyString(vendorInfo.get("VENDOR_CD"))) ) {
                    resultCd   = "Error";
                    resultMsg += "공급사 없음/";
                }
        	}







        	Map<String, Object> priceInfo = bod102_Mapper.doGetUnitPrc(gridData); //매입단가 체크
            if(gridData.get("ITEM_CD") !=null && !"".equals(gridData.get("ITEM_CD"))) {
	            if( priceInfo == null || "".equals(EverString.nullToEmptyString(priceInfo.get("CONT_NO"))) ) {
	                resultCd   = "Error";
	                resultMsg += "매입정보 없음/";
	            }
            }
            gridData.put("RESULT_CD", resultCd);
            gridData.put("RESULT_MSG", resultMsg);
            gridData.put("CPO_USER_DIVISION_CD", EverString.nullToEmptyString(gridData.get("CPO_USER_DIVISION_CD")));
            gridData.put("CPO_USER_DEPT_CD", EverString.nullToEmptyString(gridData.get("CPO_USER_DEPT_CD")));
            gridData.put("CPO_USER_PART_CD", EverString.nullToEmptyString(gridData.get("CPO_USER_PART_CD")));
            gridData.put("CPO_USER_TEL_NUM", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("TEL_NUM")));
            gridData.put("CPO_USER_CELL_NUM", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("CELL_NUM")));
            gridData.put("APPLY_COM", (priceInfo == null) ? null : EverString.nullToEmptyString(priceInfo.get("APPLY_COM")));
            gridData.put("CONT_NO", (priceInfo == null) ? null : EverString.nullToEmptyString(priceInfo.get("CONT_NO")));
            gridData.put("CONT_SEQ", (priceInfo == null) ? null : String.valueOf(priceInfo.get("CONT_SEQ")));
            gridData.put("PROGRESS_CD", PROGRESS_CD);
            gridData.put("SIGN_STATUS", SIGN_STATUS);
            gridData.put("DOC_TYPE", "UI");
            gridData.put("JOB_TYPE", "X");


            UserInfo userInfo = UserInfoManager.getUserInfo();
            if(!"C".equals(userInfo.getUserType())) {
                param.put("CUST_CD", userInfo.getCompanyCd());
            }


            if( "".equals(String.valueOf(gridData.get("JOB_SEQ"))) || "null".equals(String.valueOf(gridData.get("JOB_SEQ"))) ){
                bod102_Mapper.bod1020_doInsertBULK(gridData);
            } else {
                bod102_Mapper.bod1020_doUpdateBULK(gridData);
            }

            // 주문하기
            if( "Order".equals(pMod) ) {
                if( resultMsg.trim().length() > 0 ){
                    throw new Exception("유효성 오류가 발생하여 처리할 수 없습니다. => " + resultMsg);
                }

                gridData.put("CPO_NO", CPONO);
                // 1. 고객사 POHD 등록(UPOHD)
                if( cpoSeq == 1 ){
                    gridData.put("APPROVE_FLAG", APPROVALFLAG);
                    gridData.put("BUDGET_FLAG", BUDGETFLAG);
                    bod102_Mapper.bod1020_doInsertUPOHD(gridData);
                }

                // 2. 고객사 PODT 등록(UPODT)
                gridData.put("CPO_SEQ", cpoSeq);

                if(custInfo != null && "1".equals(custInfo.get("AUTO_PO_FLAG"))) {
//                    gridData.put("DELY_TYPE", "A");      // 배송방법,  A:직접배송
//                    gridData.put("DELY_PLACE", "1");    // 배송장소, 1: 고객사
//                    gridData.put("PROGRESS_CD", "38");
                }

                gridData.put("CUBL_SQ", custUser==null?null:custUser.get("CUBL_SEQ"));    // 기본 청구지
                bod102_Mapper.bod1020_doInsertUPODT(gridData);

                // 3. 예산 차감(제외 : BULK는 예산체크 하지 않는 고객사만 진행함)
    			/*if( "Y".equals(BUDGETFLAG) || "1".equals(BUDGETFLAG) ) {
    				bod103_Mapper.doCalulateBudget(gridData);
    			}*/

                // 주문 생성 후 BULK 데이터 삭제 및 CPO_NO, CPO_SEQ 등록
                gridData.put("RESULT_CD", "주문생성");
                gridData.put("RESULT_MSG", "");

                bod102_Mapper.bod1020_doUpdateAfterCpo(gridData);

                cpoSeq++;
            }
        }

        // 주문하기
        // 결재 및 예산체크는 제외함

        if( "Order".equals(pMod) ) {
            // CPO를 PO로 분리하여 생성함
            // 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호
            // HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD
            // 추가 - SHIPPER_TYPE(내외자)
            param.put("CPO_NO", CPONO);



            List<Map<String, Object>> poList = bod103_Mapper.getPOListBulk(param);

            for(Map<String, Object> poData : poList) {


                String PO_NO = docNumService.getDocNumber("PO");
                poData.put("CPO_NO",  CPONO);
                poData.put("PO_NO",   PO_NO);
                poData.put("CUST_CD", param.get("CUST_CD"));
                poData.put("PROGRESS_CD", "5100");
                bod103_Mapper.doInsertYPOHD(poData);
                bod103_Mapper.doInsertYPODT(poData);

            }


            messageCode = "0001";
        }
        //if(1==1) throw new Exception("==========================================================");
        return msg.getMessage(messageCode);
    }

    // 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1020_doDelete(List<Map<String, Object>> gridList) throws Exception {

        for(Map<String, Object> gridData : gridList) {
            bod102_Mapper.bod1020_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /**
     * 주문일괄등록 엑셀업로드
     * @param gridDatas
     * @return
     */
    public List<Map<String, Object>> doSetExcelImportItem(List<Map<String,Object>> gridDatas){

    	UserInfo userInfo = UserInfoManager.getUserInfo();

    	List<Map<String, Object>> rtnGrid = new ArrayList<>();
        for(Map<String, Object> grid : gridDatas){

        	grid.put("BUYER_CD", userInfo.getCompanyCd());

        	// 주문금액 = 수량 * 주문단가
            double qty     = Double.parseDouble(String.valueOf(grid.get("CPO_QTY") == null ? 0 : grid.get("CPO_QTY")) );
            double salePrc = Double.parseDouble(String.valueOf(grid.get("CPO_UNIT_PRICE") == null ? 0 : grid.get("CPO_UNIT_PRICE")));

            BigDecimal bigDecimal1 = new BigDecimal(qty);

            // 품목코드가 존재하는 경우 품목 기본정보 가져오기
            Map<String, Object> item = new HashMap<String, Object>();
            if( grid.get("ITEM_CD") != null && !"".equals(grid.get("ITEM_CD")) ) {
            	item = bod102_Mapper.doSetExcelImportItemCpo(grid);

            	// 판매금액
            	salePrc = Double.parseDouble(String.valueOf(item.get("CPO_UNIT_PRICE") == null ? 0 : item.get("CPO_UNIT_PRICE")));

            	// 매입금액 = 수량 * 주문단가
                double unitPrc = Double.parseDouble(String.valueOf(item.get("TEMP_PO_UNIT_PRICE") == null ? 0 : item.get("TEMP_PO_UNIT_PRICE")));

                BigDecimal bigDecimal3 = new BigDecimal(unitPrc);
                double tmpAmt = bigDecimal1.multiply(bigDecimal3).doubleValue();
                grid.put("TEMP_PO_ITEM_AMT", tmpAmt);
            }

            // 주문금액 = 수량 * 주문단가
            BigDecimal bigDecimal2 = new BigDecimal(salePrc);
            double cpoAmt = bigDecimal1.multiply(bigDecimal2).doubleValue();
            grid.put("CPO_ITEM_AMT", cpoAmt);

            // 품목이 없는 경우 제외함
        	//if(item == null || item.size() == 0) continue;

            grid.putAll(item);

            rtnGrid.add(grid);
        }

        return rtnGrid;
    }




































    // 저장 및 유효성검증, 주문하기 정산용 ======================================================
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1021_doSave(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {
        String messageCode = "0001";
        String pMod = EverString.nullToEmptyString(param.get("pMod"));
        Map<String,String> poMapList = new HashMap<String,String>();

        String CPONO = "";
        String APPROVALFLAG = "";  // 결재여부
        String BUDGETFLAG 	= "";  // 예산체크여부


        String SIGN_STATUS  = "E"; // 결재상태

        int cpoSeq = 1;
        String resultCd;
        String resultMsg;
        for( Map<String, Object> gridData : gridList ){
        	String PROGRESS_CD = "";
        	String prType = gridData.get("PR_TYPE").toString();  // G : 일반구매 , C : 시행구매

            resultCd  = "OK";
            resultMsg = "";

            Map<String, Object> custInfo = bod102_Mapper.doGetCustInfo(gridData); //고객사 체크


            if( custInfo == null || "".equals(EverString.nullToEmptyString(custInfo.get("CUST_CD"))) ) {
                resultCd   = "Error";
                resultMsg += "고객사 없음/";
            }



        	PROGRESS_CD = "6300"; // 발주완료




            Map<String, Object> custUser = bod102_Mapper.doGetCustUser(gridData); //고객사 사용자 체크
            if( custUser == null || "".equals(EverString.nullToEmptyString(custUser.get("USER_ID"))) ) {
                resultCd   = "Error";
                resultMsg += "주문자 없음/";
            }




            Map<String, Object> vendorInfo = bod102_Mapper.doGetVendorInfo(gridData); // 공급사 체크
            if( vendorInfo == null || "".equals(EverString.nullToEmptyString(vendorInfo.get("VENDOR_CD"))) ) {
                resultCd   = "Error";
                resultMsg += "공급사 없음/";
            }



            gridData.put("RESULT_CD", resultCd);
            gridData.put("RESULT_MSG", resultMsg);
            gridData.put("CPO_USER_DIVISION_CD", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("DIVISION_CD")));
            gridData.put("CPO_USER_DEPT_CD", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("DEPT_CD")));
            gridData.put("CPO_USER_PART_CD", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("PART_CD")));
            gridData.put("CPO_USER_TEL_NUM", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("TEL_NUM")));
            gridData.put("CPO_USER_CELL_NUM", (custUser == null) ? null : EverString.nullToEmptyString(custUser.get("CELL_NUM")));

            gridData.put("APPLY_COM", gridData.get("CUST_CD") );

//            gridData.put("CONT_NO", "Y");
//            gridData.put("CONT_SEQ", "1");

            gridData.put("PROGRESS_CD", PROGRESS_CD);
            gridData.put("SIGN_STATUS", SIGN_STATUS);
            gridData.put("DOC_TYPE", "UI");
            gridData.put("JOB_TYPE", "Y");


            gridData.put("PRIOR_GR_FLAG", "1"); // 선입고여부
            //gridData.put("PR_SUBJECT", "정산용 주문");
            //gridData.put("CPO_DATE", EverDate.getDate()); // 주문일자 현재일자
            gridData.put("HOPE_DUE_DATE", EverDate.getDate()); // 납기희망일자 현재일자

            gridData.put("DEAL_CD", "200");


            if( "".equals(String.valueOf(gridData.get("JOB_SEQ"))) || "null".equals(String.valueOf(gridData.get("JOB_SEQ"))) ){
                bod102_Mapper.bod1020_doInsertBULK(gridData);
            } else {
                bod102_Mapper.bod1020_doUpdateBULK(gridData);
            }

            // 주문하기
            if( "Order".equals(pMod) ) {
                CPONO = "X"+docNumService.getDocNumber("CPO");
                poMapList.put(CPONO+"@"+gridData.get("CUST_CD"),"*");
                if( resultMsg.trim().length() > 0 ){
                    throw new Exception("유효성 오류가 발생하여 처리할 수 없습니다. => " + resultMsg);
                }

                gridData.put("CPO_NO", CPONO);
                // 1. 고객사 POHD 등록(UPOHD)
                bod102_Mapper.bod1020_doInsertUPOHD(gridData);

                // 2. 고객사 PODT 등록(UPODT)
                gridData.put("CPO_SEQ", cpoSeq);

                gridData.put("CUBL_SQ", custUser==null?null:custUser.get("CUBL_SEQ"));    // 기본 청구지
                bod102_Mapper.bod1020_doInsertUPODT2(gridData);

                // 주문 생성 후 BULK 데이터 삭제 및 CPO_NO, CPO_SEQ 등록
                gridData.put("RESULT_CD", "주문생성");
                gridData.put("RESULT_MSG", "");

                bod102_Mapper.bod1020_doUpdateAfterCpo(gridData);

                cpoSeq++;
            }
        }

    	Set set = poMapList.keySet();
    	Iterator iter = set.iterator();
    	while(iter.hasNext()) {
    		CPONO = String.valueOf(iter.next());
            System.err.println("======================================================================================================CPONO=="+CPONO);

    		String[] info = CPONO.split("@");

    		CPONO = info[0];


            if( "Order".equals(pMod) ) {
                // CPO를 PO로 분리하여 생성함
                // 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호
                // HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD
                // 추가 - SHIPPER_TYPE(내외자)
                param.put("CPO_NO", CPONO);



//                List<Map<String, Object>> poList = bod103_Mapper.getPOListBulk(param);
//                for(Map<String, Object> poData : poList) {
                Map<String, Object> poData = new HashMap<String,Object>();

                	String PO_NO = "X"+docNumService.getDocNumber("PO");
                    poData.put("CPO_NO",  CPONO);
                    poData.put("PO_NO",   PO_NO);

                    poData.put("CUST_CD",   info[1]);

                    poData.put("PROGRESS_CD", "6300");
                    bod103_Mapper.doInsertYPOHD(poData);
                    bod103_Mapper.doInsertYPODT2(poData);



//            		String IV_NO    = docNumService.getDocNumber("IV"); // 공급사 납품서 번호
//        			String INV_NO   = docNumService.getDocNumber("INV"); // 운영사 납품서 번호
//        			poData.put("IV_NO",  IV_NO);
//        			poData.put("INV_NO", INV_NO);
//        			poData.put("IV_SEQ", "1");
//        			poData.put("INV_SEQ", "1");
//        			poData.put("INV_QTY",  poData.get("CPO_QTY"));

        			bod103_Mapper.siv1020_doCreateYIVHD(poData);
        			bod103_Mapper.siv1020_doCreateUIVHD(poData);
        			bod103_Mapper.siv1020_doCreateYIVDT(poData);
        			bod103_Mapper.siv1020_doCreateUIVDT(poData);

        			bod103_Mapper.siv1020_doUpdateYPODT(poData);
        			bod103_Mapper.siv1020_doUpdateUPODT(poData);

            		String GR_NO = "X"+docNumService.getDocNumber("GR");
            		poData.put("GR_NO",GR_NO);
                	bod103_Mapper.doGrSaveGRDT(poData);

//                }
                messageCode = "0001";
            }
    	}


        //if(1==1) throw new Exception("==========================================================");
        return msg.getMessage(messageCode);
    }
















}