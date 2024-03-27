package com.st_ones.evermp.BS03.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 *
 * @LastModified 18. 1. 5 오후 5:27
 */

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverEncryption;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverMath;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.NoResultException;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BS03.BS0301_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import com.st_ones.eversrm.master.user.BADU_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;


@Service(value = "bs0301_Service")
public class BS0301_Service extends BaseService {

    @Autowired
    private DocNumService docNumService;

    @Autowired
    private MessageService msg;

    @Autowired
    private EApprovalService approvalService;

    @Autowired
    private BS0301_Mapper bs0301Mapper;

    @Autowired
    private EApprovalService eApprovalService;

    @Autowired
    LargeTextService largeTextService;

    @Autowired
    private BADU_Mapper baduMapper;

    @Autowired
    private EverMailService everMailService;

    /** ******************************************************************************************
     * 공급회사 현황
     * @param formData
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> bs03001_doSearch(Map<String, String> formData) {

        return bs0301Mapper.bs03001_doSearch(formData);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bs03001_doConfirmReject(String signStatus, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {
            Map<String, String> appParam = new HashMap<String, String>();
            appParam.put("APP_DOC_NUM", String.valueOf(gridData.get("APP_DOC_NUM")));
            appParam.put("APP_DOC_CNT", String.valueOf(gridData.get("APP_DOC_CNT")));
            appParam.put("DOC_TYPE", "BS");
            appParam.put("SIGN_STATUS", signStatus);
            if (signStatus.equals("E")) {
                eApprovalService.approve(appParam);
            }
            if (signStatus.equals("R")) {
                eApprovalService.reject(appParam);
            }
        }
        return msg.getMessage("0001");
    }

    /** ******************************************************************************************
     * 공급회사 상세
     * @param param
     * @return
     * @throws Exception
     */
    public Map<String, String> bs03002_doSearchInfo(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03002_doSearchInfo(param);
    }

    // 공급사 첨부파일 조회
    public Map<String, String> bs03002_doSearchFileVNGL(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03002_doSearchFileVNGL(param);
    }

    // 공급회사 담당자조회
    public List<Map<String, Object>> bs03002_doSearchUser(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03002_doSearchUser(param);
    }

    // 공급회사 취급분야조회
    public List<Map<String, Object>> bs03002_doSearchSG(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03002_doSearchSG(param);
    }
    //공급회사 취급분야삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs03002_dodeleteSGVN(Map<String, String> form, List<Map<String, Object>> grid1Data) throws Exception {

        for (Map<String, Object> grid1 : grid1Data) {
            grid1.put("VENDOR_CD", form.get("VENDOR_CD"));
            bs0301Mapper.bs03002_dodeleteSGVN(grid1);
        }
    }

    // 공급회사 계산서사용자조회
    public List<Map<String, Object>> bs03002_doSearchTX(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03002_doSearchTX(param);
    }

    //공급회사 계산서사용자 삭제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void bs03002_dodeleteTX(Map<String, String> form, List<Map<String, Object>> gridtxData) throws Exception {

        for (Map<String, Object> gridtx : gridtxData) {
            gridtx.put("VENDOR_CD", form.get("VENDOR_CD"));
            bs0301Mapper.bs03002_dodeleteTX(gridtx);
        }
    }


    // 공급회사 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> bs03002_doSave(Map<String, String> paramData, List<Map<String, Object>> grid1Datas, List<Map<String, Object>> gridTxDatas,List<Map<String, Object>> gridVncp) throws Exception {

        Map<String, Object> formData = new HashMap<String, Object>();
        formData.putAll(paramData);

        Map<String, String> rtnMap = new HashMap<String, String>();
        String vendorCd = EverString.nullToEmptyString(formData.get("VENDOR_CD"));
        String BlocksignStatus = EverString.nullToEmptyString(formData.get("BLOCK_SIGN_STATUS"));  //수정시 Block여부가 변경될때의 상태
        String novendorCD = ""; //처음등록여부

        // 신규등록일경우 공급회사 번호채번
        if (vendorCd.equals("")) {
            novendorCD = "Y";
            vendorCd = docNumService.getDocNumber("VENDOR");
            formData.put("VENDOR_CD", vendorCd);
            paramData.put("VENDOR_CD", vendorCd);
        }

        // 공급회사 등록/수정---------------------------------------------------------------------------------------------------------------------------------------------
        if (formData.get("EMPLOYEE_CNT").equals("")) {
            formData.put("EMPLOYEE_CNT", null);
        } else {
            formData.put("EMPLOYEE_CNT", Double.parseDouble((String) formData.get("EMPLOYEE_CNT")));
        }

        //Block 해제인경우 해당 Block 정보는 저장하지않는다.(임시저장과 처음등록은 예외)
        if (BlocksignStatus.equals("P")) {
            formData.put("BLOCK_FLAG", "1"); //해제로 바꿔도 무조건 해제(1)로
        }

        bs0301Mapper.bs03002_doMergeVendor(formData);


        // 공급사 납품가능지역(checkBox) 저장-----------------------------------------------------------------------------------------------------------------------------
        String regionCd = EverString.nullToEmptyString(formData.get("REGION_CD"));
        // 삭제 후 저장
        formData.put("TABLE", "STOCVNRG");
        bs0301Mapper.bs03002_doDeleteVN(formData);
        if (!regionCd.equals("")) {
            String[] regionCdArray = regionCd.split(",");
            for (int i = 0; i < regionCdArray.length; i++) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("VENDOR_CD", vendorCd);
                map.put("REGION_CD", regionCdArray[i]);
                bs0301Mapper.bs03002_doMergeVNRG(map);
            }
        }

        //취급분야(S/G)------------------------------------------------------------------------------------------------------------------------------------------------
        for (Map<String, Object> sgList : grid1Datas) {

            sgList.put("VENDOR_CD", vendorCd);
            bs0301Mapper.bs03002_doMergeSGVN(sgList);
        }

        // 신용평가사 연계로 저장하지 않는다. 20220707
        //재무사항 VNFI(1건) : DELETE 후 INSERT-------------------------------------------------------------------------------------------------------------------------
        //bs0301Mapper.bs03002_doDeleteVNFI(formData);
        //bs0301Mapper.bs03002_doInsertVNFI(formData);

        //사용자(관리자)(1건) 저장---------------------------------------------------------------------------------------------------------------------------------------
        formData.put("PASSWORD", EverEncryption.getEncryptedUserPassword(String.valueOf(formData.get("PASSWORD"))));
        String oriUserId = EverString.nullToEmptyString(formData.get("ORI_USER_ID"));
        if (oriUserId.equals("")) {

            //아이디중복체크
            Map<String, String> params = new HashMap<String, String>();
            String userId = EverString.nullToEmptyString(formData.get("USER_ID"));
            params.put("USER_ID", userId);
            int checkCnt = baduMapper.existsUserInformation_VNGL(params);
            if (checkCnt > 0) {
                throw new NoResultException(msg.getMessage("0155"));
            }

            //사용자처음등록시 프로파일 등록
            formData.put("AUTH_CD", "PF0132");
            bs0301Mapper.bs03002_doInsertUser_USAP(formData);
            formData.put("USER_PROGRESS_CD", "E");
        }
        formData.put("MNG_YN", "1"); // 관리자.
        bs0301Mapper.bs03002_doMergeUser_CVUR(formData);


        //계산서담당자------------------------------------------------------------------------------------------------------------------------------------------------
        for (Map<String, Object> txList : gridTxDatas) {

            txList.put("VENDOR_CD", vendorCd);
            bs0301Mapper.bs03002_doMergeTX(txList);
        }



        // 영업담당자
        bs0301Mapper.bs03002_doDelVNCP(formData);
        for (Map<String, Object> vncp : gridVncp) {
        	vncp.put("VENDOR_CD", vendorCd);
            bs0301Mapper.bs03002_doMergeVNCP(vncp);
        }



        //최초등록 or 회사주소, 대표자 변경시 이력테이블에저장-------------------------------------------------------------------------------------------------------------
        String chReason = EverString.nullToEmptyString(formData.get("CH_REASON"));
        if (!chReason.equals("")) {
            bs0301Mapper.bs03002_doInsert_VNGH(formData);
        }

        //최초등록시 평가정보있으면 평가정보저장--------------------------------------------------------------------------------------------------------------------------
        if (novendorCD.equals("Y")) {
            //bs03008_doSave(paramData);
        }

        //최초등록 or Block여부 변경시이력테이블에저장-------------------------------------------------------------------------------------------------------------
        String oldBlockFlag = EverString.nullToEmptyString(formData.get("OLD_BLOCK_FLAG"));
        String blockFlag = EverString.nullToEmptyString(formData.get("BLOCK_FLAG"));
        if (!oldBlockFlag.equals(blockFlag)) {
            bs0301Mapper.bs03003_doInsertBlockHistory(paramData);
        }

        //등록된 공급사정보 이후 Block여부 변경시 Mail발송-------------------------------------------------------------------------------------------------------------
        String progressCd = EverString.nullToEmptyString(formData.get("PROGRESS_CD"));  //진행상태
        String blockHistoryYn = EverString.nullToEmptyString(formData.get("BLOCK_HISTORY_YN"));
        if (progressCd.equals("E")) {
            if (!blockHistoryYn.equals("")) {

                // Mail Template 및 URL 가져오기
                String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
                String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.VENDOR_BLOCK_TemplateFileName");

                String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
        		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
        		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
        		
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

        		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
                fileContents = EverString.replace(fileContents, "$VENDOR_CD$", paramData.get("VENDOR_CD")); // 공급사번호
                fileContents = EverString.replace(fileContents, "$VENDOR_NM$", paramData.get("VENDOR_NM")); // 공급사명
                fileContents = EverString.replace(fileContents, "$USER_NM$", paramData.get("USER_NM")); // 공급사명
                fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
                fileContents = EverString.rePreventSqlInjection(fileContents);

                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("SUBJECT", "[대명소노시즌] " + paramData.get("VENDOR_NM") + "의 Block/Block해제가 설정되었습니다.");
                sdata.put("CONTENTS_TEMPLATE", fileContents);
                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(paramData.get("USER_ID")));
                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(paramData.get("USER_NM")));
                sdata.put("RECV_EMAIL", EverString.nullToEmptyString(paramData.get("USER_EMAIL")));
                sdata.put("REF_NUM", paramData.get("VENDOR_CD"));
                sdata.put("REF_MODULE_CD", "VENBLOCK"); // 참조모듈
                // 메일전송.
                everMailService.sendMail(sdata);
                sdata.clear();
            }
        }

        // 등록요청 > 결재요청---------------------------------------------------------------------------------------------------------------------------------------------------
        String appDocNum = EverString.nullToEmptyString(formData.get("APP_DOC_NUM"));
        String appDocCnt = EverString.nullToEmptyString(formData.get("APP_DOC_CNT"));

        String signStatus = EverString.nullToEmptyString(formData.get("SIGN_STATUS"));  //결재상태
        System.err.println("=====================signStatus========"+signStatus);
        System.err.println("=====================signStatus========"+paramData.get("approvalFormData"));

        if (signStatus.equals("P")) {

            if (EverString.isEmpty(appDocNum)) {
                appDocNum = docNumService.getDocNumber("AP");
                paramData.put("APP_DOC_NUM", appDocNum);
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                appDocCnt = "1";
                paramData.put("APP_DOC_CNT", appDocCnt);
            } else {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                paramData.put("APP_DOC_CNT", appDocCnt);
            }
            paramData.put("DOC_TYPE", "VENDOR");
            approvalService.doApprovalProcess(paramData, paramData.get("approvalFormData"), paramData.get("approvalGridData"));

            progressApproval(appDocNum, appDocCnt, signStatus, vendorCd);
        }


        // 수정 > Blokc해제로 변경시 결재요청---------------------------------------------------------------------------------------------------------------------------------------------------
        if (BlocksignStatus.equals("P")) {
            if (EverString.isEmpty(appDocNum)) {
                appDocNum = docNumService.getDocNumber("AP");
                paramData.put("APP_DOC_NUM", appDocNum);
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                appDocCnt = "1";
                paramData.put("APP_DOC_CNT", appDocCnt);
            } else {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                paramData.put("APP_DOC_CNT", appDocCnt);
            }
            paramData.put("DOC_TYPE", "VENBLOCK");
            approvalService.doApprovalProcess(paramData, paramData.get("approvalFormData"), paramData.get("approvalGridData"));

            progressApproval(appDocNum, appDocCnt, BlocksignStatus, vendorCd);
        }

        rtnMap.put("VENDOR_CD", vendorCd);
        rtnMap.put("rtnMsg", (signStatus.equals("P") ? msg.getMessage("0023") : msg.getMessage("0031")));
        return rtnMap;
    }

    // 공급회사 Block 정보
    public Map<String, String> bs03003_doSearchInfo(Map<String, String> param) throws Exception {

        Map<String, String> rtnMap = bs0301Mapper.bs03003_doSearchInfo(param);
        return rtnMap;
    }

    // 공급회사 이력조회
    public List<Map<String, Object>> bs03003_doSearchHistory(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03003_doSearchHistory(param);
    }

    // 공급회사 Block / 이력 저장 ---> 공급사저장시 동시에 진행
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> bs03003_doSave(Map<String, String> formData) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();
        String vendorCd = EverString.nullToEmptyString(formData.get("VENDOR_CD"));
        String signStatus = EverString.nullToEmptyString(formData.get("SIGN_STATUS"));

        // 결재요청---------------------------------------------------------------------------------------------------------------------------------------------------
        String appDocNum = EverString.nullToEmptyString(formData.get("APP_DOC_NUM"));
        String appDocCnt = EverString.nullToEmptyString(formData.get("APP_DOC_CNT"));
        if (signStatus.equals("P")) {
            if (EverString.isEmpty(appDocNum)) {
                appDocNum = docNumService.getDocNumber("AP");
                formData.put("APP_DOC_NUM", appDocNum);
            }
            if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
                appDocCnt = "1";
                formData.put("APP_DOC_CNT", appDocCnt);
            } else {
                appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
                formData.put("APP_DOC_CNT", appDocCnt);
            }
            formData.put("DOC_TYPE", "VENBLOCK");

            approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
        }
        
        bs0301Mapper.bs03003_doInsertBlockHistory(formData);
        bs0301Mapper.bs03003_doUpdateVendor(formData);

        rtnMap.put("VENDOR_CD", vendorCd);
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    // 결재에 대한 APP_DOC_NUM, APP_DOC_CNT, SIGN_STATUS 변경
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void progressApproval(String docNum, String docCnt, String signStatus, String vendorCd) throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);
        map.put("VENDOR_CD", vendorCd);
        bs0301Mapper.updateSignStatus(map);
    }

    // 결재승인(E) / 반려(R) / 취소(C)시 sign_status, sign_date, progress_cd(2100) 변경
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval(String docNum, String docCnt, String signStatus) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);
        if (signStatus.equals("E") || signStatus.equals("R")) {
            map.put("PROGRESS_CD", signStatus);
        } else {
            map.put("PROGRESS_CD", "T");
        }

        bs0301Mapper.endApproval(map);

        //공급사 담당자 업데이트
        bs0301Mapper.endApproval_CVUR(map);

        //승인 / 반려시 해당 공급사관리자에게 Mail 전송
        List<Map<String, Object>> rtnRevList = bs0301Mapper.getMailUserInfo(map);
        // 담당자 정보있으면 해당담당자에게 mail,sms발송
        if (rtnRevList.size() > 0) {

            for(Map<String, Object> rtnRevinfo : rtnRevList) {

                // 승인메일
                if (signStatus.equals("E")) {

                    // Mail Template 및 URL 가져오기
                    String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
                    String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.VENDOR_JOINO_TemplateFileName");

                    String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
            		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
            		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
            		
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

            		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
                    fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(rtnRevinfo.get("USER_NM"))); //
                    fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
                    fileContents = EverString.rePreventSqlInjection(fileContents);

                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("SUBJECT", "[대명소노시즌] 회원가입이 승인 되었습니다.");
                    sdata.put("CONTENTS_TEMPLATE", fileContents);
                    sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rtnRevinfo.get("USER_ID")));
                    sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rtnRevinfo.get("USER_NM")));
                    sdata.put("RECV_EMAIL", EverString.nullToEmptyString(rtnRevinfo.get("EMAIL")));
                    sdata.put("REF_NUM", EverString.nullToEmptyString(rtnRevinfo.get("VENDOR_CD")));
                    sdata.put("REF_MODULE_CD", "VENDOR"); // 참조모듈
                    // 메일전송.
                    everMailService.sendMail(sdata);
                    sdata.clear();
                } // 반려메일
                else if (signStatus.equals("R")) {

                    // Mail Template 및 URL 가져오기
                    String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
                    String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.VENDOR_JOINX_TemplateFileName");

                    String domainNm     = PropertiesManager.getString("eversrm.system.domainName");
            		String domainPort   = PropertiesManager.getString("eversrm.system.domainPort");
            		String contextNm    = PropertiesManager.getString("eversrm.system.contextName");
            		
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

            		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
                    fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(rtnRevinfo.get("USER_NM"))); //
                    fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
                    fileContents = EverString.rePreventSqlInjection(fileContents);

                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("SUBJECT", "[대명소노시즌] 회원가입이 반려 되었습니다.");
                    sdata.put("CONTENTS_TEMPLATE", fileContents);
                    sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rtnRevinfo.get("USER_ID")));
                    sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rtnRevinfo.get("USER_NM")));
                    sdata.put("RECV_EMAIL", EverString.nullToEmptyString(rtnRevinfo.get("EMAIL")));
                    sdata.put("REF_NUM", EverString.nullToEmptyString(rtnRevinfo.get("VENDOR_CD")));
                    sdata.put("REF_MODULE_CD", "VENDOR"); // 참조모듈
                    // 메일전송.
                    everMailService.sendMail(sdata);
                    sdata.clear();
                }
            }
        }
        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }


    // 결재승인(E) / 반려(R) / 취소(C)시 sign_status, sign_date, progress_cd(2100) 변경_ 공급사 블락해제
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String vendorBlockendApproval(String docNum, String docCnt, String signStatus) throws Exception {

        Map<String, String> map = new HashMap<String, String>();
        map.put("APP_DOC_NUM", docNum);
        map.put("APP_DOC_CNT", docCnt);
        map.put("SIGN_STATUS", signStatus);
        
        if(signStatus.equals("E")) {
        	Map<String, String> info = bs0301Mapper.vnbhInfo(map);
        	map.put("BLOCK_FLAG"   , info.get("BLOCK_CD"));
        	map.put("BLOCK_REASON" , info.get("AMEND_REASON"));
        	
        	// STOCVNGL의 공급사 BLOCK 처리
        	bs0301Mapper.endApprovalBh(map);
        }

        //block 여부수정 이력저장.
        bs0301Mapper.updateBhSignStatus(map);

        return (signStatus.equals("E") ? msg.getMessage("0057") : (signStatus.equals("R") ? msg.getMessage("0058") : msg.getMessage("0001")));
    }


    //공급사변경 이력조회
    public List<Map<String, Object>> bs03007_doSearch(Map<String, String> formData) {
        return bs0301Mapper.bs03007_doSearch(formData);
    }


    /** ******************************************************************************************
     * 공급회사 평가정보
     * @param req
     * @return
     * @throws Exception
     */
    public Map<String, String> bs03008_doSearchInfo(Map<String, String> param) throws Exception {
        return bs0301Mapper.bs03008_doSearchInfo(param);
    }

    //평가리스트
    public List<Map<String, Object>> bs03008_doSearchList(Map<String, String> param) {


        List<Map<String, Object>> returnList = new ArrayList<Map<String, Object>>();

        int i = 0;
        int colJ = 1;
        String C1 = "";
        String C2 = "";
        String radioSet = "";
        String nonDataColNm = "";
        List<Map<String, Object>> searchList = bs0301Mapper.bs03008_doSearchList(param);
        for (Map<String, Object> con : searchList) {

            con.put("C2_VALUE_0", false);
            con.put("C2_VALUE_2", false);
            con.put("C2_VALUE_4", false);
            con.put("C2_VALUE_6", false);
            con.put("C2_VALUE_8", false);
            con.put("C2_VALUE_10", false);
            con.put("C2_READONLY", false);

            if (i == 0) {
                C1 = EverString.nullToEmptyString(con.get("C1_CD"));
                C2 = EverString.nullToEmptyString(con.get("C2_CD"));
                if (EverString.nullToEmptyString(param.get("SPEV_YN")).equals("Y")) {
                    //첫번째열 데이터없을때 라디오버튼셋팅
                    nonDataColNm = "EVAL_ITEM_" + colJ + "_SCORE";
                    String eva1 = EverString.nullToEmptyString(param.get(nonDataColNm));
                    radioSet = "C2_VALUE_" + eva1;
                    con.put(radioSet, true);
                } else {
                    //첫번째열 데이터 조회 라디오버튼셋팅
                    String eva1 = EverString.nullToEmptyString(con.get("C_SCORE"));
                    radioSet = "C2_VALUE_" + eva1;
                    con.put(radioSet, true);
                }
            } else {
                //리스트의 평가항목 merge위해서 같은 값이면 데이터 공백으로 넣기
                if (C1.equals(EverString.nullToEmptyString(con.get("C1_CD")))) {
                    con.put("C1_CD", null);
                } else {
                    C1 = EverString.nullToEmptyString(con.get("C1_CD"));
                }

                //기타, 가점. (10, 6, 0점만 가능한 항목)
                if ("E0101".equals(EverString.nullToEmptyString(con.get("C2_CD")))) {
                    con.put("C2_READONLY", true);
                    if("".equals(EverString.nullToEmptyString(con.get("C_SCORE")))) {
                        con.put("C2_VALUE_0", true);
                    }
                }

                //기타, 감점요인 평가
                if ("E0102".equals(EverString.nullToEmptyString(con.get("C2_CD")))) {

                    if (EverString.nullToEmptyString(param.get("VNEV_YN")).equals("Y")) {
                        if (EverString.nullToEmptyString(param.get("EVAL_ITEM_12_SCORE")).equals("10")) {
                            con.put("C2_MINUS_VALUE", true);
                        } else {
                            con.put("C2_MINUS_VALUE", false);
                        }
                    } else {
                        if (EverString.nullToEmptyString(con.get("C_SCORE")).equals("10")) {
                            con.put("C2_MINUS_VALUE", true);
                        } else {
                            con.put("C2_MINUS_VALUE", false);
                        }
                    }
                }

                //일반항목에 대한 점수 체크
                if (C2.equals(EverString.nullToEmptyString(con.get("C2_CD")))) {
                    con.put("C2_CD", null);

                } else {
                    colJ++;
                    C2 = EverString.nullToEmptyString(con.get("C2_CD"));
                    if (EverString.nullToEmptyString(param.get("VNEV_YN")).equals("Y")) {
                        //일반항목 데이터없을경우 점수체크
                        nonDataColNm = "EVAL_ITEM_" + colJ + "_SCORE";
                        String eva1 = EverString.nullToEmptyString(param.get(nonDataColNm));
                        radioSet = "C2_VALUE_" + eva1;
                        con.put(radioSet, true);
                    } else {
                        //일반항목 데이터 조회 점수체크
                        String eva1 = EverString.nullToEmptyString(con.get("C_SCORE"));
                        radioSet = "C2_VALUE_" + eva1;
                        con.put(radioSet, true);
                    }

                }
            }

            returnList.add(con);
            i++;
        }

        return returnList;
    }


    // 공급사 평가저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> bs03008_doSave(Map<String, String> formData) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();
        //bs0301Mapper.bs03008_doSave(formData);

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    public List<Map<String, Object>> BS03_001P_doSearch(Map<String, String> formData) throws Exception {
        return bs0301Mapper.BS03_001P_doSearch(formData);
    }

    public String bs03010_doSearchDeliveryLevel(Map<String, String> param) {
        return bs0301Mapper.bs03010_doSearchDeliveryLevel(param);
    }

    public Map<String, String> bs03010_doSearchInfo(Map<String, String> param) {
        return bs0301Mapper.bs03010_doSearchInfo(param);
    }

    public List<Map<String, Object>> bs03010_doSearchList(Map<String, String> param) {
        List<Map<String, Object>> returnList = new ArrayList<Map<String, Object>>();

        int i = 0;
        int colJ = 1;
        String C1 = "";
        String C2 = "";

        //모든 제조레벨 같은 평가표
        if(param.get("DELIVERY_LEVEL").equals("A")) {
            param.put("C1_CD", "MP093");
            param.put("C2_CD", "MP094");
            param.put("C3_CD", "MP095");
        } else {
            param.put("C1_CD", "MP093");
            param.put("C2_CD", "MP094");
            param.put("C3_CD", "MP095");
        }

        List<Map<String, Object>> searchList = bs0301Mapper.bs03010_doSearchList(param);

        for (Map<String, Object> con : searchList) {

            //리스트의 평가항목 merge위해서 같은 값이면 데이터 공백으로 넣기
            if (C1.equals(EverString.nullToEmptyString(con.get("C1_CD")))) {
                con.put("C1_CD", null);
            } else {
                C1 = EverString.nullToEmptyString(con.get("C1_CD"));
            }

            //일반항목에 대한 점수 체크
            if (C2.equals(EverString.nullToEmptyString(con.get("C2_CD")))) {
                con.put("C2_CD", null);

            } else {
                colJ++;
                C2 = EverString.nullToEmptyString(con.get("C2_CD"));
            }

            returnList.add(con);
            i++;
        }

        return returnList;
    }

    // 공급사 평가저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> bs03010_doSave(Map<String, String> formData) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();


        // SPEV_YN 이 Y 일 경우 협력업체 등록
        if (formData.get("SPEV_YN").equals("Y")) {
            bs0301Mapper.bs03010_doInsert(formData);
        } else if (formData.get("SPEV_YN").equals("N")) {
            // 공급사 등록 팝업 내에서 저장시에도 평가횟수 올라가기 위해
            bs0301Mapper.bs03010_doInsert(formData);
        } else {
            bs0301Mapper.bs03010_doUpdate(formData);
        }

        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }

    public List<Map<String, Object>> bs03009_doSearch(Map<String, String> formData) {
    	  Map<String, Object> paramObj =  new HashMap<String, Object>(formData);
    	  if(EverString.isNotEmpty(formData.get("PROGRESS_CD"))) {
              paramObj.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(formData.get("PROGRESS_CD")).split(",")));
    	  }
        return  bs0301Mapper.bs03009_doSearch(paramObj);
    }

    public List<Map<String, Object>> BS03_009P_doSearch(Map<String, String> formData) throws Exception {
        return bs0301Mapper.BS03_009P_doSearch(formData);
    }

    public void bs03009_doUpdateProgressCd(Map<String, String> param, List<Map<String, Object>> gridData) {
        for(Map<String, Object> grid : gridData) {
            grid.put("PROGRESS_CD", param.get("PROGRESS_CD"));
            bs0301Mapper.bs03009_doUpdateProgressCd(grid);
        }
    }

    /*	220902 sikim BS03_009 반려 클릭 시 PROGRESS_CD = R  및 SIGN_STATUS = R update */
    public void bs03009_doUpdateRejectStatus(Map<String, String> param, List<Map<String, Object>> gridData) {
        for(Map<String, Object> grid : gridData) {
            grid.put("PROGRESS_CD", param.get("PROGRESS_CD"));
            grid.put("SIGN_STATUS", param.get("SIGN_STATUS"));

            bs0301Mapper.bs03009_doUpdateRejectStatusSTOCVNGL(grid);
            if(param.get("PROGRESS_CD").equals("R") && param.get("SIGN_STATUS").equals("R")) {
            	bs0301Mapper.bs03009_doUpdateRejectStatusSTOCSPEV(grid);
            }
        }
    }

    public List<Map<String, Object>> BS03_002P_doSearch(Map<String, String> formData) throws Exception {
        return bs0301Mapper.bs03002_doSearchSG(formData);
    }

    public Map<String, String> getCreditHist(Map<String, String> param) throws Exception {
        return bs0301Mapper.getCreditHist(param);
    }


    /**
     * 공급사 거래제안(BS03_011)
     */

    public List<Map<String, Object>> BS03_011_doSearch(Map<String, String> param) throws Exception {
        return bs0301Mapper.BS03_011_doSearch(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String BS03_011_doDelete(List<Map<String, Object>> gridDatas) throws Exception {

        for(Map<String, Object> gridData : gridDatas) {
            bs0301Mapper.BS03_011_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    /**
     * 공급사 거래제안 팝업(BS03_011P)
     */

    public Map<String, Object> BS03_011P_doSearchNoticeInfo(Map<String, String> param) throws Exception {

        Map<String, Object> rtnMap = bs0301Mapper.BS03_011P_doSearchNoticeInfo(param);

        String splitString = largeTextService.selectLargeText(String.valueOf(rtnMap.get("NOTICE_TEXT_NUM")));
        rtnMap.put("NOTICE_CONTENTS", splitString);

        if (param.get("detailView").toString().trim().toLowerCase().equals("true")) {
            Double cnt = Double.parseDouble(String.valueOf(rtnMap.get("VIEW_CNT"))) + 1;
            rtnMap.put("VIEW_CNT", cnt.toString());
            bs0301Mapper.BS03_011P_doSaveCount(rtnMap);
        }
        rtnMap.put("VIEW_CNT", EverMath.EverNumberType(String.valueOf(rtnMap.get("VIEW_CNT")), "###,###"));
        return rtnMap;
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Map<String, String> BS03_011P_doSave(Map<String, String> formData) throws Exception {

        Map<String, String> rtnMap = new HashMap<String, String>();
        String noticeNum = com.st_ones.everf.serverside.util.EverString.nullToEmptyString(formData.get("NOTICE_NUM"));
        String noticeTextNum = com.st_ones.everf.serverside.util.EverString.nullToEmptyString(formData.get("NOTICE_TEXT_NUM"));

        if(noticeNum.equals("")) {
            noticeNum = docNumService.getDocNumber("NT");
            noticeTextNum = largeTextService.saveLargeText(null, formData.get("NOTICE_CONTENTS"));
            formData.put("NOTICE_NUM", noticeNum);
            formData.put("NOTICE_TEXT_NUM", noticeTextNum);
            bs0301Mapper.BS03_011P_doInsert(formData);
        }
        else {
            noticeTextNum = largeTextService.saveLargeText(noticeTextNum, formData.get("NOTICE_CONTENTS"));
            bs0301Mapper.BS03_011P_doUpdate(formData);
        }

        rtnMap.put("NOTICE_NUM", noticeNum);
        rtnMap.put("rtnMsg", msg.getMessage("0031"));
        return rtnMap;
    }
}
