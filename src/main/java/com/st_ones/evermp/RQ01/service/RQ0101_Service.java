package com.st_ones.evermp.RQ01.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.RQ01.RQ0101_Mapper;
import com.st_ones.evermp.RQ01.RQ0102_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 9. 5 오후 5:27
 */

@Service(value = "rq0101_Service")
public class RQ0101_Service extends BaseService {

	@Autowired private DocNumService docNumService;

    @Autowired private MessageService msg;
    @Autowired LargeTextService largeTextService;

    @Autowired private RQ0101_Mapper rq0101_Mapper;

    @Autowired private QueryGenService queryGenService;
    @Autowired private RQ0102_Mapper rq0102_Mapper;

    @Autowired private EverMailService everMailService;

    @Autowired private EverSmsService everSmsService;

    /** *****************
     * 견적의뢰대상
     * ******************/

    public List<Map<String, Object>> rq01010_doSearch(Map<String, String> param) throws Exception {

        Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC_SPEC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC_SPEC"));
            sParam.put("COL_NM", "NVL(GL.ITEM_DESC, RQ.ITEM_DESC)");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "NVL(GL.ITEM_SPEC, RQ.ITEM_SPEC)");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "NVL(GL.ITEM_CD, RQ.ITEM_CD)");
            param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("HD_PROGRESS_CD_LIST", Arrays.asList(param.get("HD_PROGRESS_CD").split(",")));

        if(EverString.isNotEmpty(param.get("ITEM_REQ_NO"))) {
            fParam.put("ITEM_REQ_NO_ORG", param.get("ITEM_REQ_NO"));
            fParam.put("ITEM_REQ_NO", EverString.forInQuery(param.get("ITEM_REQ_NO"), ","));
            fParam.put("ITEM_REQ_CNT", param.get("ITEM_REQ_NO").contains(",") ? "1" : "0");
        }

        /*
        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            fParam.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            fParam.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            fParam.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }
        */

        return rq0101_Mapper.rq01010_doSearch(fParam);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01010_doTransferCtrl(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            String progressCd = rq0101_Mapper.checkProgressCd(gridData);
            if (!"300".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("RQ01_010", "005"));
            }
            gridData.put("SG_CTRL_USER_ID", formData.get("SG_CTRL_USER_ID"));
            gridData.put("SG_CTRL_CHANGE_RMK", formData.get("SG_CTRL_CHANGE_RMK"));
            rq0101_Mapper.doTransferCtrlUser(gridData);
        }
        return msg.getMessageByScreenId("RQ01_010", "006");
    }

    // 소싱관리 > 신규소싱 > 견적의뢰 현황 (RQ01_010) : 접수취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01010_doReturnItem(String returnReason, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            String progressCd = rq0101_Mapper.checkProgressCd(gridData);
            if (!"300".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("RQ01_010", "005"));
            }
            gridData.put("PROGRESS_CD", "100");
            gridData.put("MOVE_REASON", returnReason);
            rq0101_Mapper.doReturnItem(gridData);
        }
        return msg.getMessageByScreenId("RQ01_010", "006");
    }

    // 기존 견적건 품목 조회
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01010_getReItemList(String sendType, Map<String, String> rqhdData) throws Exception {

        Map<String, String> param = new HashMap<String, String>();
        param.put("RFQ_NUM", rqhdData.get("RFQ_NUM"));
        param.put("RFQ_CNT", rqhdData.get("ORI_RFQ_CNT"));

        // 재견적인 경우 사용
        param.put("NEW_RFQ_CNT", rqhdData.get("NEW_RFQ_CNT"));

        String itemList = "";
        List<Map<String, Object>> reRqdtDatas = rq0101_Mapper.getReRfqItemList(param);
        for (Map<String, Object> rqdtData : reRqdtDatas) {
        	itemList += rqdtData.get("ITEM_CD") + ",";
        }

        if(itemList.length() > 0) {
        	return itemList.substring(0,itemList.length() - 1);
        } else {
        	return "";
        }
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rq01010_doSendRFQ(String sendType, Map<String, String> rqhdData, List<Map<String, Object>> rqdtDatas) throws Exception {

    	UserInfo userInfo = UserInfoManager.getUserInfo();

        String rmkTextNum = largeTextService.saveLargeText(rqhdData.get("RMK_TEXT_NUM"), rqhdData.get("RMK_TEXT"));
        rqhdData.put("RMK_TEXT_NUM", rmkTextNum);

        String rfqNum = "";
        String rfqCnt = "";
        if (sendType.equals("F")) {	// 신규 견적의뢰서 작성
        	if(rqhdData.get("RFQ_NUM").equals("")) {
        		rfqNum = docNumService.getDocNumber("RFQ");
        		rfqCnt = "1";
        	} else {
    	        rfqNum = rqhdData.get("RFQ_NUM");
    	        rfqCnt = rqhdData.get("ORI_RFQ_CNT");
        	}
        } else if(sendType.equals("E")) {	// 견적의뢰서 수정
        	if(rqhdData.get("RFQ_NUM").equals("")) {
        		rfqNum = docNumService.getDocNumber("RFQ");
        		rfqCnt = "1";
        	} else {
    	        rfqNum = rqhdData.get("RFQ_NUM");
    	        rfqCnt = rqhdData.get("ORI_RFQ_CNT");
        	}
        } else if(sendType.equals("R")) {	// 재견적
	        rfqNum = rqhdData.get("RFQ_NUM");
	        rfqCnt = rqhdData.get("NEW_RFQ_CNT");
        }

        rqhdData.put("RFQ_NUM", rfqNum);
        rqhdData.put("RFQ_CNT", rfqCnt);
        //업체삭제
        rq0101_Mapper.deleteRQVN(rqhdData);
        // MP066: 150(작성중), 200(견적중)
        String signStatus = EverString.nullToEmptyString(rqhdData.get("signStatus"));
        rqhdData.put("PROGRESS_CD", signStatus.equals("E") ? "200" : "150");

        String vendorListStr = rqhdData.get("VENDOR_LIST");
        String[] vendorArgs = vendorListStr.split(",");

        // 1. STOCRQHD : 견적 요청서 Header 등록
        rq0101_Mapper.doInsertRQHD(rqhdData);

        // 최초 견적의뢰 or 재작성(수정)
        if(sendType.equals("F") || sendType.equals("E")) {
            int rfqSq = 1;
            for (Map<String, Object> rqdtData : rqdtDatas) {

                // 2. STOCNWRQ : 신규 상품요청의 진행상태가 접수(300)인 경우에만 가능함..
                String progressCd = rq0101_Mapper.checkProgressCd(rqdtData);
                //if (!"300".equals(progressCd)) { throw new NoResultException(msg.getMessageByScreenId("RQ01_010", "005")); }

                rqdtData.put("RFQ_NUM", rfqNum);
                rqdtData.put("RFQ_CNT", rfqCnt);
                rqdtData.put("RFQ_SQ", rfqSq);
                rqdtData.put("PROGRESS_CD", rqhdData.get("PROGRESS_CD"));

                String operatorFlag = String.valueOf(rqdtData.get("OPERATOR_FLAG"));    // 운영사 등록여부 (0 : 고객사 등록, 1 : 운영사 등록)
                rqdtData.put("CUST_REQ_FLAG", (operatorFlag.equals("1") ? "0" : "1"));    // 고객사 견적서 합의요청 여부 (운영사에서 등록한 경우 자동 합의)

                // 3. STOCRQHD : 견적 상품 등록
                rq0101_Mapper.doInsertRQDT(rqdtData);

                // 4. STOCRQVN : 견적 공급사 등록
                for (int i = 0; i < vendorArgs.length; i++) {
                    Map<String, Object> rqvnData = new HashMap<String, Object>();
                    rqvnData.put("RFQ_NUM", rfqNum);
                    rqvnData.put("RFQ_CNT", rfqCnt);
                    rqvnData.put("RFQ_SQ", rfqSq);
                    rqvnData.put("VENDOR_CD", vendorArgs[i]);
                    rqvnData.put("RFQ_PROGRESS_CD", "100"); // 공급사 견적진행상태(M072) : 미접수(100)
                    rq0101_Mapper.doInsertRQVN(rqvnData);
                }

                // 5. STOCNWRQ : 신규상품 등록요청 진행상태 변경
                rqdtData.put("NWRQ_PROGRESS_CD", "400");// 소싱중
                rq0101_Mapper.updateProgressCdNWRQ(rqdtData);
                rfqSq++;
            }
        } // 재견적
        else if(sendType.equals("R") ){
        	Map<String, String> param = new HashMap<String, String>();
            param.put("RFQ_NUM", rfqNum);
            param.put("RFQ_CNT", rfqCnt);
            param.put("ORI_RFQ_CNT", rqhdData.get("ORI_RFQ_CNT"));
            param.put("NEW_RFQ_CNT", rqhdData.get("NEW_RFQ_CNT"));

            param.put("sendType", sendType); // 재견적:R
            List<Map<String, Object>> reRqdtDatas = rq0101_Mapper.getReRfqItemList(param);
            for (Map<String, Object> rqdtData : reRqdtDatas) {
            	// RQDT(견적상품) 등록
            	rq0101_Mapper.doInsertRQDT(rqdtData);

            	//===> 이전 차수의 견적 상품은 재견적 상태 변경
            	rq0101_Mapper.updateReRfqStatusDT(rqdtData);

                for (int i = 0; i < vendorArgs.length; i++) {
                    Map<String, Object> rqvnData = new HashMap<String, Object>();
                    rqvnData.put("RFQ_NUM", rfqNum);
                    rqvnData.put("RFQ_CNT", rfqCnt);
                    rqvnData.put("RFQ_SQ", rqdtData.get("RFQ_SQ"));
                    rqvnData.put("VENDOR_CD", vendorArgs[i]);
                    rqvnData.put("RFQ_PROGRESS_CD", "100");	// 공급사 견적진행상태(M072) : 미접수(100)
                    rq0101_Mapper.doInsertRQVN(rqvnData);
                }
            }

        	//===> 이전 차수의 견적 Header 재견적 상태 변경
        	rq0101_Mapper.updateReRfqStatusHD(param);
        }

        // 협력사 전송(E)인 경우에만 EMAIL, SMS 발송
        if ("E".equals(signStatus)) {

        	// Mail Template 및 URL 가져오기
            String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
            String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.RFQ_TemplateFileName");

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

            Map<String, String> rfqData = rq0101_Mapper.getRfqInfoHD(rqhdData);
            String rfqNumCnt = EverString.nullToEmptyString(rfqData.get("RFQ_NUM")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("RFQ_CNT")));
            String vendorOpenDealType = EverString.nullToEmptyString(rfqData.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(rfqData.get("DEAL_TYPE")));
            String rmkText = largeTextService.selectLargeText(EverString.nullToEmptyString(rfqData.get("RMK_TEXT_NUM")));

            String tblBody = "<tbody>";
            String enter = "\n";
            List<Map<String, String>> itemList = rq0101_Mapper.getRfqItemList(rqhdData);
            if(itemList.size() > 0) {
                for (Map<String, String> itemData : itemList) {

                    String itemDesc = itemData.get("ITEM_DESC");
                    if(itemDesc.length() > 16) { itemDesc = itemDesc.substring(0, 15) + "..."; }

                    String itemSpec = itemData.get("ITEM_SPEC");
                    if(itemSpec.length() > 30) { itemSpec = itemSpec.substring(0, 29) + "..."; }

                    String tblRow = "<tr>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</th>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</th>"
                            + enter + "</tr>";
                    tblBody += tblRow;
                }
            }

            List<Map<String, String>> vendorList = rq0101_Mapper.getRfqVendorList(rqhdData);
            for (Map<String, String> vendorData : vendorList) {

                String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
                fileContents = EverString.replace(fileContents, "$VENDOR_NM$", vendorData.get("VENDOR_NM")); // 공급사명
                fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", rfqNumCnt); // 견적의뢰번호/차수
                fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", EverString.nullToEmptyString(rfqData.get("RFQ_SUBJECT"))); // 견적의뢰명
                fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", EverString.nullToEmptyString(rfqData.get("RFQ_CLOSE_DATE"))); // 견적마감일시
                fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", vendorOpenDealType); // 지명방식/거래유형
                fileContents = EverString.replace(fileContents, "$RMK_TEXT$", rmkText); // 요청사항
                fileContents = EverString.replace(fileContents, "$CTRL_USER_NM$", EverString.nullToEmptyString(rfqData.get("CTRL_USER_NM"))); // 품목담당자
                fileContents = EverString.replace(fileContents, "$TEL_NUM$", EverString.nullToEmptyString(rfqData.get("TEL_NUM"))); // 연락처
                fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
                fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
                fileContents = EverString.rePreventSqlInjection(fileContents);
                if(!(vendorData.get("RECV_EMAIL")==null) && !vendorData.get("RECV_EMAIL").equals("")) {
                    Map<String, String> mdata = new HashMap<String, String>();
                    mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 귀사에 견적을 요청드립니다.");
                    mdata.put("CONTENTS_TEMPLATE", fileContents);
                    mdata.put("SEND_EMAIL", vendorData.get("SEND_EMAIL"));
                    mdata.put("SEND_USER_NM", vendorData.get("SEND_USER_NM"));
                    mdata.put("SEND_USER_ID", vendorData.get("SEND_USER_ID"));
                    mdata.put("RECV_EMAIL", vendorData.get("RECV_EMAIL"));
                    mdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM"));
                    mdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID"));
                    mdata.put("REF_NUM", rfqData.get("RFQ_NUM"));
                    mdata.put("REF_MODULE_CD","RFQ"); // 참조모듈

                    // 메일전송.
                    everMailService.sendMail(mdata);
                    mdata.clear();
                }
                else {
                	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 email 정보가 없습니다.");
                }

                if(!(vendorData.get("RECV_TEL_NUM")==null) && !vendorData.get("RECV_TEL_NUM").equals("")) {
                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("SMS_SUBJECT", "[대명소노시즌] 견적요청서가 도착했습니다."); // SMS 제목
                    sdata.put("CONTENTS", "[대명소노시즌] 견적요청서가 도착했습니다.(" + vendorData.get("RFQ_NUM") + ") 빠른 견적진행 부탁드립니다."); // 전송내용
                    sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(vendorData.get("SEND_USER_ID")).equals("") ? "SYSTEM" : vendorData.get("SEND_USER_ID"))); // 보내는 사용자ID
                    sdata.put("SEND_USER_NM",vendorData.get("SEND_USER_NM")); // 보내는사람
                    sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
                    sdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID")); // 받는 사용자ID
                    sdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM")); // 받는사람
                    sdata.put("RECV_TEL_NUM", vendorData.get("RECV_TEL_NUM")); // 받는 사람 전화번호
                    sdata.put("REF_NUM", rfqData.get("RFQ_NUM")); // 참조번호
                    sdata.put("REF_MODULE_CD","RFQ"); // 참조모듈

                    // SMS 전송.
                    everSmsService.sendSms(sdata);
                    sdata.clear();
                }
                else {
                	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 전화번호 정보가 없습니다.");
                }
            }
        }



        if ("E".equals(signStatus)) {
            return msg.getMessageByScreenId("RQ01_010", "010");

        } else {
            return msg.getMessageByScreenId("RQ01_010", "017");

        }




    }

    public Map<String, String> getRfqHD(Map<String, String> param) throws Exception {
		return rq0101_Mapper.getRfqHD(param);
    }

    public List<Map<String, String>> getPreRfqVendorList(Map<String, String> param) throws Exception {
        return rq0101_Mapper.getPreRfqVendorList(param);
    }

    /** *****************
     * 공급사선택
     * ******************/
    public List<Map<String, Object>> rq01012_doSearchDefault(Map<String, String> param) throws Exception {
        if(param.get("ITEM_CD_STR").indexOf(",") > -1) {
            param.put("ITEM_CD_STR", EverString.forInQuery(param.get("ITEM_CD_STR"), ","));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_CD_STR")).equals("") && param.get("ITEM_CD_STR").indexOf(",") == -1) { param.put("ITEM_CD_STR", "('" + param.get("ITEM_CD_STR") + "')"); }
        return rq0101_Mapper.rq01012_doSearchDefault(param);
    }

    /** *****************
     * 공급사선택
     * ******************/
    public List<Map<String, Object>> rq01013_doSearchDefault(Map<String, String> param) throws Exception {
        if(param.get("ITEM_CD_STR").indexOf(",") > -1) {
            param.put("ITEM_CD_STR", EverString.forInQuery(param.get("ITEM_CD_STR"), ","));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_CD_STR")).equals("") && param.get("ITEM_CD_STR").indexOf(",") == -1) {
        	param.put("ITEM_CD_STR", "('" + param.get("ITEM_CD_STR") + "')");
        }
        return rq0101_Mapper.rq01013_doSearchDefault(param);
    }

    /** *****************
     * Item List
     * ******************/
    public List<Map<String, Object>> rq01011_doSearchDefault(Map<String, String> param) throws Exception {
        if(param.get("ITEM_CD_STR").indexOf(",") > -1) {
            param.put("ITEM_CD_STR", EverString.forInQuery(param.get("ITEM_CD_STR"), ","));
        }
        if(!EverString.nullToEmptyString(param.get("ITEM_CD_STR")).equals("") && param.get("ITEM_CD_STR").indexOf(",") == -1) {
        	param.put("ITEM_CD_STR", "('" + param.get("ITEM_CD_STR") + "')");
        }


        if (param.get("ITEM_CD_STR") == null || "".equals(param.get("ITEM_CD_STR"))) {
            return rq0102_Mapper.rq01020_doSearchB(param);
        } else {
            return rq0101_Mapper.rq01011_doSearchDefault(param);
        }

    }


    public List<Map<String, Object>> rq01012_doSearch(Map<String, String> param) throws Exception {

//        if(param.get("REGION_CD").indexOf(",") > -1) {
//            param.put("REGION_CD", EverString.forInQuery(param.get("REGION_CD"), ","));
//        }
//        if(!EverString.nullToEmptyString(param.get("REGION_CD")).equals("") && param.get("REGION_CD").indexOf(",") == -1) { param.put("REGION_CD", "('" + param.get("REGION_CD") + "')"); }

        Map<String, Object> param2 = new HashMap<String, Object>();
        param2.putAll(param);

        String sgNum1 = EverString.nullToEmptyString(param.get("SG_NUM1"));
        String sgNum2 = EverString.nullToEmptyString(param.get("SG_NUM2"));
        String sgNum3 = EverString.nullToEmptyString(param.get("SG_NUM3"));
        String sgNum4 = EverString.nullToEmptyString(param.get("SG_NUM4"));

        param2.put("PARENT_SG_NUM","");
        if(!sgNum4.equals("")){
            param2.put("SG_NUM",sgNum4);
        } else if(!sgNum3.equals("")) {
            param2.put("SG_NUM",sgNum3);
        } else if(!sgNum2.equals("")) {
            param2.put("SG_NUM",sgNum2);
        } else if(!sgNum1.equals("")) {
            param2.put("SG_NUM", sgNum1);
            param2.put("PARENT_SG_NUM","Y");
            Map<String, String> tmpParam = new HashMap<String, String>();
            tmpParam.put("PARENT_SG_NUM", param.get("SG_NUM1"));

            List<Map<String, Object>> sgList = rq0101_Mapper.getSgParentList(tmpParam);
            System.out.println(">>>>>>>>> sgList's Size : " + sgList.size());
            param2.put("sgList", sgList);
        } else {
            param2.put("SG_NUM","");
        }
        return rq0101_Mapper.rq01012_doSearch(param2);
    }

    public Map<String, String> getWorkingDay() {
        return rq0101_Mapper.getWorkingDay();
    }
}