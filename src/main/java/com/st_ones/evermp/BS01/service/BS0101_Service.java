package com.st_ones.evermp.BS01.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS01.BS0101_Mapper;
import com.st_ones.eversrm.eApproval.eApprovalModule.service.BAPM_Service;
import com.st_ones.eversrm.master.user.BADU_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


@Service(value = "bs0101_Service")
public class BS0101_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private BS0101_Mapper bs0101Mapper;

    @Autowired
	private BADU_Mapper baduMapper;

    @Autowired
    LargeTextService largeTextService;

    @Autowired
    private BAPM_Service approvalService;

    /** ******************************************************************************************
     * 고객사 조회
     * @param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs01001_doSearch(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01001_doSearch(param);
    }

    // 고객사 변경이력 조회
    public List<Map<String, Object>> bs01001p_doSearch(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01001p_doSearch(param);
    }

    //고객사 거래정지 또는 거래정지 해제
    public void bs01001_doSuspensionOrTrading(List<Map<String, Object>> gridData) throws Exception{
        bs0101Mapper.bs01001_doSuspensionOrTrading(gridData.get(0));
    }

    /** ******************************************************************************************
     * 고객사 상세
     * @param
     * @return
     * @throws Exception
     */
    public Map<String, String> bs01002_doSearchInfo(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01002_doSearchInfo(param);
    }

    public Map<String, String> bs01002_doSearchUser(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01002_doSearchUser(param);
    }

    public String bs01002_checkIrsNum(Map<String, String> param) throws Exception {
		return bs0101Mapper.bs01002_checkIrsNum(param);
	}

    public String bs01002_checkDupCustUser(Map<String, String> param) throws Exception {
		return bs0101Mapper.bs01002_checkDupCustUser(param);
	}


    //공급회사 계산서사용자 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs01002_dodeleteTX(Map<String, String> form, List<Map<String, Object>> gridtxData) throws Exception {

        for (Map<String, Object> gridtx : gridtxData) {
            gridtx.put("CUST_CD", form.get("CUST_CD"));
            bs0101Mapper.bs01002_dodeleteTX(gridtx);
        }
    }

    // 고객시 신규 등록 및 수정
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> bs01002_doSave(Map<String, Object> formData, List<Map<String, Object>> gridTxDatas) throws Exception {
    	UserInfo userInfo = UserInfoManager.getUserInfo();

    	Map<String, String> rtnMap = new HashMap<String, String>();

        String custCd = EverString.nullToEmptyString(formData.get("CUST_CD"));

        String signStatus = String.valueOf(formData.get("SIGN_STATUS"));
        String oldSignStatus = EverString.nullToEmptyString(bs0101Mapper.bs01002_getSignStatus(formData));
        String appDocCnt = String.valueOf(formData.get("APP_DOC_CNT"));


        if(signStatus.equals("P")){
            if(EverString.isEmpty(appDocCnt)){
                formData.put("APP_DOC_NUM", docNumService.getDocNumber("AP"));
            }
            if(EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")){
                appDocCnt = "1";
            }else{
                if (oldSignStatus.equals("R") || oldSignStatus.equals("C")) {
                    appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                }
            }
            formData.put("APP_DOC_CNT", appDocCnt);
            formData.put("DOC_TYPE", "CUST");

            approvalService.doApprovalProcess((Map)formData, String.valueOf(formData.get("approvalFormData")), String.valueOf(formData.get("approvalGridData")));
        }

        // 1. 신규등록일경우  법인등록번호 + 사업자번호 + 종사업자 중복체크
  		if( "".equals(custCd) ) {
  			String cehckNum = EverString.nullToEmptyString(formData.get("COMPANY_REG_NUM")) + EverString.nullToEmptyString(formData.get("IRS_NUM")) + EverString.nullToEmptyString(formData.get("IRS_SUB_NUM"));
  			cehckNum = cehckNum.replaceAll("-","");
  			cehckNum = cehckNum.replaceAll("\\p{Z}","");
  			formData.put("CEHCK_NUM", cehckNum);

  			int check = bs0101Mapper.bs01002_doCheckNum(formData);
  			if( check > 0 ) {
  				rtnMap.put("rtnMsg", msg.getMessage("0147"));
  				return rtnMap;
  			}
  		}

  		// 2. 신규 등록 : 고객사번호 채번
  		boolean isNew = false; // 신규여부
        if( "".equals(EverString.nullToEmptyString(custCd)) ) {
        	isNew  = true;
        	custCd = docNumService.getDocNumber("CUST");
        }
 		formData.put("CUST_CD", custCd);
 		//formData.put("PROGRESS_CD", "E"); // 승인(M050)

 		// 종업원수
        if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("EMPLOYEE_CNT")))) ) {
            formData.put("EMPLOYEE_CNT", null);
        } else {
            formData.put("EMPLOYEE_CNT", Double.parseDouble(String.valueOf(formData.get("EMPLOYEE_CNT"))));
        }
        // 재무정보 : 고객사가 아닌 경우에만 적용함
        if( !"B".equals(userInfo.getUserType()) ) {
        	// 고객사정률
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("PROFIT_RATIO")))) ) {
                formData.put("PROFIT_RATIO", null);
            } else {
                formData.put("PROFIT_RATIO", Double.parseDouble(String.valueOf(formData.get("PROFIT_RATIO"))));
            }
        	// 여신금액
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("CREDIT_LIMIT_AMT")))) ) {
                formData.put("CREDIT_LIMIT_AMT", null);
            } else {
                formData.put("CREDIT_LIMIT_AMT", Double.parseDouble(String.valueOf(formData.get("CREDIT_LIMIT_AMT"))));
            }
            // 총자산
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("TOT_ASSET")))) ) {
                formData.put("TOT_ASSET", null);
            } else {
                formData.put("TOT_ASSET", Double.parseDouble(String.valueOf(formData.get("TOT_ASSET"))));
            }
            // 총부채
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("TOT_SDEPT")))) ) {
                formData.put("TOT_SDEPT", null);
            } else {
                formData.put("TOT_SDEPT", Double.parseDouble(String.valueOf(formData.get("TOT_SDEPT"))));
            }
            // 총자본
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("TOT_FUND")))) ) {
                formData.put("TOT_FUND", null);
            } else {
                formData.put("TOT_FUND", Double.parseDouble(String.valueOf(formData.get("TOT_FUND"))));
            }
            // 총매출액
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("TOT_SALES")))) ) {
                formData.put("TOT_SALES", null);
            } else {
                formData.put("TOT_SALES", Double.parseDouble(String.valueOf(formData.get("TOT_SALES"))));
            }
            // 당기순이익
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("NET_INCOM")))) ) {
                formData.put("NET_INCOM", null);
            } else {
                formData.put("NET_INCOM", Double.parseDouble(String.valueOf(formData.get("NET_INCOM"))));
            }
            // 영업이익
            if( "".equals(EverString.nullToEmptyString(String.valueOf(formData.get("BUSINESS_PROFIT")))) ) {
                formData.put("BUSINESS_PROFIT", null);
            } else {
                formData.put("BUSINESS_PROFIT", Double.parseDouble(String.valueOf(formData.get("BUSINESS_PROFIT"))));
            }
        }

        // 3. 고객사 등록/수정
        bs0101Mapper.bs01002_doMergeCust(formData);

        // 3.1. 대표자명, 우편번호, 주소, 상세주소, 고객사판가정율 변경시 History 등록
        if( isNew || !"".equals(EverString.nullToEmptyString(formData.get("CHANGE_REMARK"))) ) {
            bs0101Mapper.bs01002_doInsertCVSH(formData);
        }

        // 4. 고객사 납품가능지역 저장
        /*String regionCd = EverString.nullToEmptyString(formData.get("REGION_CD"));
        String[] regionCdArray = regionCd.split(",");
        for( int i = 0; i < regionCdArray.length; i++ ) {
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("CUST_CD", custCd);
            map.put("REGION_CD", regionCdArray[i]);

            bs0101Mapper.bs01002_doMergCURG(map);
        }*/

        // 5. 고객사 담당자 등록/수정(비밀번호 암호화)
        String password = EverString.nullToEmptyString(formData.get("PASSWORD"));
        if( !"".equals(password) ) {
        	formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(password));
        }
        bs0101Mapper.bs01002_doMergeCVUR(formData);

        // 5-1. 고객사 권한 등록
        Map<String, Object> auData = new HashMap<String, Object>();
        auData.put("GATE_CD", userInfo.getGateCd());
        auData.put("USER_ID", formData.get("USER_ID"));
        auData.put("AUTH_CD", "PF0131"); // 고객사 권한 프로파일
		int checkCnt = baduMapper.existsUSAP(auData);
		if (checkCnt == 0) {
			baduMapper.createUSAP(auData);
		} else {
			baduMapper.updateUSAP(auData);
		}

		//6. 계산서담당자
        /*for (Map<String, Object> txList : gridTxDatas) {

            txList.put("CUST_CD", custCd);
            bs0101Mapper.bs01002_doMergeTX(txList);
        }*/

        // 7. 고객사 기본 청구지 관리 등록
        formData.put("PLANT_CD", "001");
        formData.put("CUBL_NM", formData.get("CUST_NM"));
        bs0101Mapper.bs01002_doMergeCUBL(formData);
        
     	rtnMap.put("CUST_CD", custCd );
		rtnMap.put("rtnMsg", isNew ? msg.getMessage("0015") : msg.getMessage("0016") );
        return rtnMap;
    }


    //승인 후
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval(String docNo, String docCnt, String signStatus) throws Exception {
        Map<String,String> param = new HashMap<>();
        param.put("APP_DOC_NUM", docNo);
        param.put("APP_DOC_CNT", docCnt);
        param.put("SIGN_STATUS", signStatus);
        String progressCd;
        if(signStatus.equals("E")){
            progressCd = "E";
        }else{
            progressCd = "P";
        }
        param.put("PROGRESS_CD", progressCd);
        bs0101Mapper.bs01002_doUpdateSignStatus(param);
        String rtnmsg;
        if(signStatus.equals("E")){
            bs01002_insertSTOCCUPL(param);





            rtnmsg = msg.getMessage("0057"); // 승인이 완료되었습니다
        }else if(signStatus.equals("R")){
            rtnmsg = msg.getMessage("0058"); // 반려 처리되었습니다.
        }else{
            rtnmsg = msg.getMessage("0061"); // 취소되었습니다.
        }
        return rtnmsg;
    }

    //ERP_I/F가 아닌 경우(ERP_IF_FLAG == 0)
    public void bs01002_insertSTOCCUPL(Map<String,String> param){
        Map formData = bs0101Mapper.bs01002_doSearchInfo(param);
        if(formData.get("ERP_IF_FLAG").equals("1")){
            return;
        }

        bs0101Mapper.bs01002_insertSTOCCUPL(formData);



//        bs0101Mapper.bs01002_doMergeCUBL(formData);



    }

    /** ******************************************************************************************
     * TIER이력 조회
     * @param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs01005_doSearch(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01005_doSearch(param);
    }

    /** ******************************************************************************************
     * 조직정보
     * @param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs01004_doSearch(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01004_doSearch(param);
    }
    public List<Map<String, Object>> bs01004_doSearch_parent(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01004_doSearch_parent(param);
    }

    //부서저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01004_doSave(Map<String, String> formData, List<Map<String, Object>> gridList) throws Exception {
        int checkCnt =0;
        for(Map<String, Object> gridData : gridList) {
            //고객사별 부서코드 중복체크
            gridData.put("BUYER_CD", formData.get("CUST_CD"));
            checkCnt = bs0101Mapper.existsCust_OPDP(gridData);
            if (checkCnt > 0) {
                return "이미 등록된 부서코드가 존재합니다.";
            }
        }

        if (checkCnt < 1) {
            for(Map<String, Object> gridData : gridList) {

                gridData.put("BUYER_CD", formData.get("CUST_CD"));
                gridData.put("DEPT_TYPE", formData.get("DEPT_TYPE_RADIO"));
                gridData.put("DIVISION_YN", formData.get("DIVISION_YN"));

                bs0101Mapper.bs01004_mergeData(gridData);
            }
        }

        return msg.getMessage("0031");
    }


    /** ******************************************************************************************
     * 마감일자 조회
     * @param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs01003_doSearch(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01003_doSearch(param);
    }

    //마감일자저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01003_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bs0101Mapper.bs01003_mergeData(gridData);
        }
        return msg.getMessage("0031");
    }

    //마감일자삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs01003_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            bs0101Mapper.bs01003_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    public String bs01003_doCheckIrsNo(Map<String, String> param) throws Exception {
        return bs0101Mapper.bs01003_doCheckIrsNo(param);
    }



}
