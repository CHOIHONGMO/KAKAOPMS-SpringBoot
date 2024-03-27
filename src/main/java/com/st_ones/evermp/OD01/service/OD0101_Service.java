package com.st_ones.evermp.OD01.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.BOD1.BOD103_Mapper;
import com.st_ones.evermp.BOD1.BOD104_Mapper;
import com.st_ones.evermp.BOD1.service.BOD103_Service;
import com.st_ones.evermp.IM02.service.IM0201_Service;
import com.st_ones.evermp.OD01.OD0101_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
 * @File Name : BOD1_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "od0101_Service")
public class OD0101_Service extends BaseService {

    @Autowired OD0101_Mapper od0101_Mapper;
    @Autowired BOD103_Mapper bod103_Mapper;
    @Autowired BOD104_Mapper bod104_Mapper;
    @Autowired private DocNumService docNumService;
    @Autowired private EApprovalService approvalService;
    @Autowired private QueryGenService queryGenService;
    @Autowired LargeTextService largeTextService;
    @Autowired MessageService msg;
    @Autowired private CommonComboService commonComboService;
    @Autowired IM0201_Service im0201_Service;
    @Autowired BOD103_Service bod103_service;

    @Autowired  private EverMailService everMailService;
    @Autowired  private EverSmsService everSmsService;



    /** ******************************************************************************************
     * 운영사 : 주문대기목록
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> od01001_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "UPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_CD");
            param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.CUST_ITEM_CD");
            param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_CD");
            param.put("COL_VAL", param.get("MAKER_CD"));
            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_NM");
            param.put("COL_VAL", param.get("MAKER_NM"));
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        /*
        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }
         */

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

        return od0101_Mapper.od01001_doSearch(fParam);
    }


    /** ******************************************************************************************
     * 운영사 : 주문대기목록
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> PO0210_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "UPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_CD");
            param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.CUST_ITEM_CD");
            param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_CD");
            param.put("COL_VAL", param.get("MAKER_CD"));
            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_NM");
            param.put("COL_VAL", param.get("MAKER_NM"));
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        /*
        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }
         */

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

        return od0101_Mapper.PO0210_doSearch(fParam);
    }


    public List<Map<String, Object>> PO0211_doSearch(Map<String, String> param) throws Exception {
        return od0101_Mapper.PO0211_doSearch(param);
    }
























    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doTransferCtrl(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"2200".equals(progressCd) && !"5100".equals(progressCd)) {
                //throw new Exception(msg.getMessageByScreenId("OD01_001", "0006"));
            }
            gridData.put("AM_USER_ID", formData.get("AM_USER_ID"));
            gridData.put("AM_USER_CHANGE_RMK", formData.get("AM_USER_CHANGE_RMK"));
            od0101_Mapper.doTransferAmUserUpo(gridData);
            od0101_Mapper.doTransferAmUserYpo(gridData);
        }
        return msg.getMessageByScreenId("OD01_001", "0012");
    }

    // 승인요청
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doReqConfirm(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {

            String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"30".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("OD01_001", "0006"));
            }
//            od0101_Mapper.od01001_doSaveUPDATE_UPOHD(gridData);
            od0101_Mapper.od01001_doSaveUPODT(gridData);
//            od0101_Mapper.od01001_doSaveYPODT(gridData);

            gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));
            gridData.put("CONFIRM_REQ_RMK", formData.get("CONFIRM_REQ_RMK"));

            od0101_Mapper.doReqConfirmUpo(gridData);
//            od0101_Mapper.doReqConfirmYpo(gridData);
        }

        return msg.getMessageByScreenId("OD01_001", "0016");
    }




















	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void sendEmail(Map<String, Object> rqhdData) throws Exception {
		// E-Mail, SMS 발송
        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CPO_TemplateFileName");

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

		Iterator<String> iterator = rqhdData.keySet().iterator();
		while (iterator.hasNext()) {
			String vendorCd = iterator.next();
			String poNo = String.valueOf(rqhdData.get(vendorCd));

			Map<String,Object> param = new HashMap<String,Object>();
			param.put("VENDOR_CD", vendorCd);
			param.put("PO_NO", poNo);

			StringTokenizer st = new StringTokenizer(poNo,",");
			int poCount = st.countTokens();

			String poOne = st.nextToken();



	        List<Map<String, String>> vendorList = od0101_Mapper.getTargetList(param);
	        for(Map<String, String> vendorData : vendorList) {
	            String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
	            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", vendorData.get("VENDOR_NM")); // 공급사명

	            if(poCount==1) {
		            fileContents = EverString.replace(fileContents, "$CPO_NO$", poNo);
	            } else {
		            fileContents = EverString.replace(fileContents, "$CPO_NO$", poOne +" 외 "+(poCount-1)+"건");
	            }



	            fileContents = EverString.replace(fileContents, "$tblBody$", poNo);



	            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
	            fileContents = EverString.rePreventSqlInjection(fileContents);

	            if(!(vendorData.get("RECV_EMAIL")==null) && !vendorData.get("RECV_EMAIL").equals("")) {
	                Map<String, String> mdata = new HashMap<String, String>();
	                mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 귀사에 발주서가 도착했습니다.");
	                mdata.put("CONTENTS_TEMPLATE", fileContents);
	                mdata.put("SEND_USER_ID", vendorData.get("SEND_USER_ID"));
	                mdata.put("SEND_USER_NM", vendorData.get("SEND_USER_NM"));
	                mdata.put("SEND_EMAIL", vendorData.get("SEND_EMAIL"));
	                mdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID"));
	                mdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM"));
	                mdata.put("RECV_EMAIL", vendorData.get("RECV_EMAIL"));
	                mdata.put("REF_NUM", String.valueOf(rqhdData.get("PO_NO")));
	                mdata.put("REF_MODULE_CD","PO"); // 참조모듈
	                // 메일전송.
	                everMailService.sendMail(mdata);
	                mdata.clear();
	            }
	            else {
	            	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 email 정보가 없습니다.");
	            }

	            if(!(vendorData.get("RECV_TEL_NUM")==null) && !vendorData.get("RECV_TEL_NUM").equals("")) {
	                Map<String, String> sdata = new HashMap<String, String>();
	                sdata.put("SMS_SUBJECT", "[대명소노시즌] 발주서가 도착했습니다."); // SMS 제목


		            if(poCount==1) {
		                sdata.put("CONTENTS", "[대명소노시즌] 발주서가 도착했습니다.(" + poNo + ")"); // 전송내용
		            } else {
		                sdata.put("CONTENTS", "[대명소노시즌] 발주서가 도착했습니다.(" + poOne +" 외 "+(poCount-1)+"건" + ")"); // 전송내용
		            }


	                sdata.put("SEND_USER_ID", (EverString.nullToEmptyString(vendorData.get("SEND_USER_ID")).equals("") ? "SYSTEM" : vendorData.get("SEND_USER_ID"))); // 보내는 사용자ID
	                sdata.put("SEND_USER_NM",vendorData.get("SEND_USER_NM")); // 보내는사람
	                sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
	                sdata.put("RECV_USER_ID", vendorData.get("RECV_USER_ID")); // 받는 사용자ID
	                sdata.put("RECV_USER_NM", vendorData.get("RECV_USER_NM")); // 받는사람
	                sdata.put("RECV_TEL_NUM", vendorData.get("RECV_TEL_NUM")); // 받는 사람 전화번호
	                sdata.put("REF_NUM", String.valueOf(rqhdData.get("PO_NO"))); // 참조번호
	                sdata.put("REF_MODULE_CD","PO"); // 참조모듈
	                // SMS 전송.
	                everSmsService.sendSms(sdata);
	                sdata.clear();
	            }
	            else {
	            	System.out.println("["+vendorData.get("RECV_USER_ID")+":"+vendorData.get("RECV_USER_NM")+"]는 전화번호 정보가 없습니다.");
	            }
	        }
		}


        //if (1==1) throw new Exception("=================================");

	}







    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doPoConfirmXX(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
    	String progressCdF = formData.get("PROGRESS_CD");
    	Map<String, Object> mailTargetList = new HashMap<String,Object>();

        for (Map<String, Object> gridData : gridDatas) {
            String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"5100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("OD01_001", "0022"));
            }
            gridData.put("PROGRESS_CD", progressCdF);

            if("2100".equals(progressCdF)) { // 접수취소일시 YPO 삭제
                od0101_Mapper.doPoConfirmUpo(gridData);
                od0101_Mapper.doDelYpo(gridData);
            } else {
                od0101_Mapper.doPoConfirmUpo(gridData);
                od0101_Mapper.doPoConfirmYpo(gridData);
                String vendorCd = String.valueOf(gridData.get("VENDOR_CD"));
                String poNo = String.valueOf(gridData.get("PO_NO"));

                if (mailTargetList.containsKey(vendorCd)) {
                	mailTargetList.put(vendorCd, mailTargetList.get(vendorCd) + "," + poNo);
                } else {
                	mailTargetList.put(vendorCd,poNo);
                }


            }
        }



        if("6100".equals(progressCdF)) {

        	sendEmail(mailTargetList);



        	return msg.getMessageByScreenId("PO0210", "0038");
        } else {
            return msg.getMessageByScreenId("PO0210", "0040");
        }

    }


    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String PO0240_doPoCancel(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
    	String progressCdF = formData.get("PROGRESS_CD");
        for (Map<String, Object> gridData : gridDatas) {
            String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"6100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("PO0240", "0029"));
            }
            gridData.put("PROGRESS_CD", progressCdF);
            od0101_Mapper.doPoConfirmRejectUpo(gridData);
            od0101_Mapper.doPoConfirmRejectYpo(gridData);
        }
//        if (1==1) throw new Exception("========================================");
        return msg.getMessageByScreenId("PO0240", "0030");

    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String PO0240_doPoClose(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
    	String progressCdF = formData.get("PROGRESS_CD");
        for (Map<String, Object> gridData : gridDatas) {
            od0101_Mapper.setUPoClose(gridData);
            od0101_Mapper.setYPoClose(gridData);
        }

        return msg.getMessageByScreenId("PO0240", "0033");
    }

    /**
     * 주문 접수
     * @param formData
     * @param gridDatas
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doPoConfirm(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
    	for (Map<String, Object> gridData : gridDatas) {
            String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"2100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("OD01_001", "0029")); // 진행상태가 [접수대기] 건만 처리 가능합니다.
            }
        }

        for (Map<String, Object> gridData : gridDatas) {








        	// 시행구매는 시행구매는 접수 처리만 하고, YPO(공급사 발주) SKIP 한다.
        	String prType = EverString.nullToEmptyString(gridData.get("PR_TYPE"));
            if("C".equals(prType)) {
            	gridData.put("PROGRESS_CD", "2200"); // 접수처리
            	od0101_Mapper.doPoConfirmUpo(gridData);
            	continue;
            } else {
            	gridData.put("PROGRESS_CD", "XX");
            	od0101_Mapper.doPoConfirmUpo(gridData);
            }
            if (!"Y".equals(gridData.get("INSERT_YN"))) {
                Map<String, String> param =  new HashMap<>();
                param.put("CPO_NO", EverString.nullToEmptyString(gridData.get("CPO_NO")));
                param.put("CUST_CD", EverString.nullToEmptyString(gridData.get("CUST_CD")));
                param.put("SCR_ID", "OD01_001");

                // 발주서 생성 규칙 : 상품별로 PO 생성
            	List<Map<String, Object>> poList = bod103_Mapper.getPOList(param);
	            for(Map<String, Object> poData : poList) {

	            	if("".equals(poData.get("CPO_SEQ")) || poData.get("CPO_SEQ") == null) {
	                    throw new Exception(msg.getMessageByScreenId("OD01_001", "0028"));
	                }

	            	String PO_NO = "";
	            	if("200".equals((String)poData.get("DEAL_CD"))) {
	            		PO_NO = docNumService.getDocNumber("PO");
	            	} else {
	            		PO_NO = docNumService.getDocNumber("PO");
	            	}

                    poData.put("CPO_NO",  param.get("CPO_NO"));
                    poData.put("PO_NO",   PO_NO);
                    poData.put("CUST_CD", param.get("CUST_CD"));
                    poData.put("SCR_ID",  "OD01_001");
                    poData.put("PROGRESS_CD", "5100"); // 발주대기

                    bod103_Mapper.doInsertYPOHD(poData);
                    bod103_Mapper.doInsertYPODT(poData);

	            }
	            gridData.put("PROGRESS_CD", "5100"); // 발주대기
	            od0101_Mapper.doPoConfirmUpo(gridData);
            }









        }

        return msg.getMessageByScreenId("OD01_001", "0038");
    }

    /**
     * 주문 반려
     * @param formData
     * @param gridDatas
     * @return
     * @throws Exception
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doPoConfirmReject(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

    	for (Map<String, Object> gridData : gridDatas) {
        	String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"C".equals(gridData.get("PR_TYPE")) && !"2100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("OD01_001", "0029")); // 진행상태가 [접수대기] 건만 처리 가능합니다.
            }

            gridData.put("PROGRESS_CD", formData.get("PROGRESS_CD"));
            gridData.put("PO_CONFIRM_REJECT_RMK", formData.get("PO_CONFIRM_REJECT_RMK"));

            od0101_Mapper.doPoConfirmRejectUpo(gridData);
            od0101_Mapper.doPoConfirmRejectYpo(gridData);
        }

        return msg.getMessageByScreenId("OD01_001", "0023");
    }

    // [미사용] 2022.10.04
    // 주문정보 수정사항 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doSave(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            String progressCd = od0101_Mapper.checkProgressCd(gridData);
            if (!"30".equals(progressCd)) { // 30:주문생성
                throw new Exception(msg.getMessageByScreenId("OD01_001", "006"));
            }

            od0101_Mapper.od01001_doSaveUPDATE_UPOHD(gridData);
            od0101_Mapper.od01001_doSaveUPODT(gridData);

        }
        return msg.getMessageByScreenId("OD01_001", "0023");
    }

    // 운영사 메모, 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01001_doSaveAGENT_MEMO(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {
            od0101_Mapper.od01001_doSaveAGENT_MEMO(gridData);
        }

        return msg.getMessageByScreenId("OD01_001", "0023");
    }

    /** ******************************************************************************************
     * 운영사 : 주문진행현황
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> od01010_doSearch(Map<String, String> param) throws Exception {


    	Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "UPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_CD");
            param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.CUST_ITEM_CD");
            param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_CD");
            param.put("COL_VAL", param.get("MAKER_CD"));
            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_NM");
            param.put("COL_VAL", param.get("MAKER_NM"));
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        /*
        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }
        */

        Map<String, Object> fParam = new HashMap<String, Object>(param);

        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));
        List<Map<String, Object>> list = od0101_Mapper.od01010_doSearch(fParam);

        return list;
    }

    // 발주취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01010_doCancelPO(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            String PO_CNT  = String.valueOf(gridData.get("PO_CNT"));

            if("1".equals(PO_CNT)) {
                bod104_Mapper.bod1040_doCancelYPOHD(gridData);
            }
            bod104_Mapper.bod1040_doCancelYPODT(gridData);

            gridData.put("PROGRESS_CD", "30");
            od0101_Mapper.od01010_doCancelPO_UPODT(gridData); // 상태변경
        }

        return msg.getMessageByScreenId("OD01_010", "011");
    }

    /** ******************************************************************************************
     * 운영사 : 주문IF현황
     * @param param
     * @return
     * @throws Exception
     */
    public List<Map<String, Object>> od01020_doSearch(Map<String, String> param) throws Exception {

        if(EverString.isNotEmpty(param.get("IF_CPO_NO"))) {
            param.put("IF_CPO_NO_ORG", param.get("IF_CPO_NO"));
            param.put("IF_CPO_NO", EverString.forInQuery(param.get("IF_CPO_NO"), ","));
            param.put("IF_CPO_CNT", param.get("IF_CPO_NO").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        return od0101_Mapper.od01020_doSearch(param);
    }

    // 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01020_doSave(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        for(Map<String, Object> gridData : gridList) {
            od0101_Mapper.od01020_doSaveUPDATE_IFPODT(gridData);
        }

        return msg.getMessageByScreenId("OD01_020", "0005");
    }

    // 배치실행
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01020_doBatchExec(List<Map<String, Object>> gridList, Map<String, String> form) throws Exception {
        Map<String, Object> param = new HashMap<>();

        int i = 0;
        for(Map<String, Object> gridData : gridList) {
            i++;

            if(i == 1) {
                param.put("IF_ID_SEQ", EverString.nullToEmptyString(gridData.get("IF_ID")) + String.valueOf(gridData.get("IF_SEQ")));
            } else {
                param.put("IF_ID_SEQ", EverString.nullToEmptyString(param.get("IF_ID_SEQ")) + "," + EverString.nullToEmptyString(gridData.get("IF_ID")) + String.valueOf(gridData.get("IF_SEQ")));
            }

            od0101_Mapper.od01020_doSaveUPDATE_IFPODT(gridData);
        }

        param.put("IF_ID_SEQ_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("IF_ID_SEQ")).split(",")));

        List<Map<String, Object>> list = od0101_Mapper.od01020_SELECT_IFPODT(param);

        String IF_CPO_NO = "";
        String IF_CPO_USER_ID = "";
        String CPO_NO = "";
        int CPO_SEQ = 1;

        for(Map<String, Object> data : list) {
            if(!IF_CPO_NO.equals(data.get("IF_CPO_NO"))) {
                IF_CPO_NO = EverString.nullToEmptyString(data.get("IF_CPO_NO"));
                IF_CPO_USER_ID = EverString.nullToEmptyString(data.get("CPO_USER_ID"));
                CPO_SEQ = 1;
            } else {
                if(!IF_CPO_USER_ID.equals(data.get("CPO_USER_ID"))) {
                    IF_CPO_NO = EverString.nullToEmptyString(data.get("IF_CPO_NO"));
                    IF_CPO_USER_ID = EverString.nullToEmptyString(data.get("CPO_USER_ID"));
                    CPO_SEQ = 1;
                }
            }

            if(CPO_SEQ == 1) {
                CPO_NO = docNumService.getDocNumber("CPO");

                data.put("CPO_NO", CPO_NO);

                od0101_Mapper.od01020_doSaveINSERT_UPOHD(data);
            } else {
                data.put("CPO_NO", CPO_NO);
            }

            Map<String, String> paramS = new HashMap<>();
            paramS.put("BUYER_CD", EverString.nullToEmptyString(data.get("IF_CUST_CD")));
            paramS.put("ITEM_CD", EverString.nullToEmptyString(data.get("ITEM_CD")));

            Map<String, Object> map = im0201_Service.doGetPrice(paramS);

            if(map != null && map.size() != 0) {
                data.put("MOQ_QTY", map.get("MOQ_QTY"));
                data.put("RV_QTY", map.get("RV_QTY"));
                data.put("CUR", map.get("CUR"));
                data.put("LEAD_TIME", map.get("LEAD_TIME"));
                data.put("DEAL_CD", map.get("DEAL_CD"));
                data.put("TAX_CD", map.get("TAX_CD"));
                data.put("APPLY_COM", map.get("APPLY_COM"));
                data.put("CONT_NO", map.get("CONT_NO"));
                data.put("CONT_SEQ", map.get("CONT_SEQ"));
                data.put("TEMP_PO_UNIT_PRICE", map.get("CONT_UNIT_PRICE"));
                data.put("TEMP_PO_ITEM_AMT", Float.parseFloat(String.valueOf(data.get("CPO_QTY"))) * Float.parseFloat(String.valueOf(map.get("CONT_UNIT_PRICE"))));
                data.put("VENDOR_CD", map.get("VENDOR_CD"));
            }

            data.put("CPO_SEQ", CPO_SEQ);

            od0101_Mapper.od01020_doSaveINSERT_UPODT(data);
            od0101_Mapper.od01020_doSaveStatus_UPDATE_IFPODT(data);

            CPO_SEQ++;
        }

        return msg.getMessageByScreenId("OD01_020", "0007");
    }

    /** ******************************************************************************************
     * 운영사 > 주문관리 > 주문진행현황 > 주문변경
     * @param param
     * @return List
     * @throws Exception
     */
    public List<Map<String, Object>> od01011_doSearch(Map<String, String> param) throws Exception {
        return od0101_Mapper.od01011_doSearch(param);
    }

    public List<Map<String, Object>> od01011_doSearchINV(Map<String, String> param) throws Exception {
        return od0101_Mapper.od01011_doSearchINV(param);
    }

    public List<Map<String, Object>> od01011_doSearchINV2(Map<String, String> param) throws Exception {
        return od0101_Mapper.od01011_doSearchINV2(param);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01011_doOrder(Map<String, String> param) throws Exception {

        String messageCode = "0001";

        String APPROVALFLAG = param.get("CUST_SIGN_FLAG"); // 결재여부
        String BUDGETFLAG 	= param.get("BUDGET_FLAG"); // 예산체크여부

        // 결재사용시 : 공급사, 매입가, 판매가가 변경되는 경우
        if( "1".equals(APPROVALFLAG) ){
            String vndChangeMod    = "0"; // 공급가변경여부
            String qtyChangeMod    = "0"; // 수량변경여부
            String buyPrcChangeMod = "0"; // 매입가변경여부
            String salPrcChangeMod = "0"; // 판매가변경여부
            String vendorCd        = EverString.nullToEmptyString(param.get("VENDOR_CD")); // 공급사코드
            String vendorCdOri     = EverString.nullToEmptyString(param.get("VENDOR_CD_ORI")); // 공급사코드_원본
            float cpoQty           = Float.parseFloat(String.valueOf(param.get("CPO_QTY"))); // 주문수량
            float cpoQtyOri        = Float.parseFloat(String.valueOf(param.get("CPO_QTY_ORI"))); // 주문수량_원본
            float poUnitPrice      = Float.parseFloat(String.valueOf(param.get("PO_UNIT_PRICE"))); // 매입단가
            float poUnitPriceOri   = Float.parseFloat(String.valueOf(param.get("PO_UNIT_PRICE_ORI"))); // 매입단가_원본
            float cpoUnitPrice     = Float.parseFloat(String.valueOf(param.get("CPO_UNIT_PRICE"))); // 주문단가
            float cpoUnitPriceOri  = Float.parseFloat(String.valueOf(param.get("CPO_UNIT_PRICE_ORI"))); // 주문단가_원본

            // 수량 변경
            if( cpoQty != cpoQtyOri ){
                // 수량 변경 가능 상태 확인
                String isPossibleChangeQty = od0101_Mapper.isPossibleChangeQty(param);
                if (!"Y".equals(isPossibleChangeQty)) {
                    messageCode = "0170";
                    return messageCode;
                }
                qtyChangeMod = "1";
            }
            // 공급사 변경
            if( !vendorCd.equals(vendorCdOri) ) {
                String isExistInvCompleteQty = od0101_Mapper.isExistInvCompleteQty(param);
                if( "Y".equals(isExistInvCompleteQty) ){ // 납품완료건수 존재시 공급사 변경 안됨
                    messageCode = "0171";
                    return messageCode;
                }
                vndChangeMod = "1";
            }
            // 매입가 변경
            if( poUnitPrice != poUnitPriceOri ){
                // 단가 변경 가능 상태 확인
                String isExistInvCompleteQty = od0101_Mapper.isExistInvCompleteQty(param);
                if( "Y".equals(isExistInvCompleteQty) ){ // 납품완료건수 존재시 매입가 변경 안됨
                    messageCode = "0172";
                    return messageCode;
                }
                buyPrcChangeMod = "1";
            }
            // 판매가 변경
            if( cpoUnitPrice != cpoUnitPriceOri ){
                // 단가 변경 가능 상태 확인
                String isExistInvCompleteQty = od0101_Mapper.isExistInvCompleteQty(param);
                if( "Y".equals(isExistInvCompleteQty) ){ // 납품완료건수 존재시 판매가 변경 안됨
                    messageCode = "0172";
                    return messageCode;
                }
                salPrcChangeMod = "1";
            }

            // 공급사 주문정보 변경
            param.put("VND_MOD_YN", vndChangeMod);
            param.put("CPO_QTY_MOD_YN", qtyChangeMod);
            param.put("BUY_PRC_MOD_YN", buyPrcChangeMod);
            param.put("SAL_PRC_MOD_YN", salPrcChangeMod);

            od0101_Mapper.doUpdateChangeYPODT(param);
        }
        else {
            float cpoQty    = Float.parseFloat(String.valueOf(param.get("CPO_QTY"))); // 주문수량
            float cpoQtyOri = Float.parseFloat(String.valueOf(param.get("CPO_QTY_ORI"))); // 주문수량_원본
            if( cpoQty != cpoQtyOri ){
                // 주문품목이 변경 가능 상태가 아닌 경우
                String isPossibleChangeQty = od0101_Mapper.isPossibleChangeQty(param);
                if( !"Y".equals(isPossibleChangeQty) ){
                    messageCode = "0170";
                    return messageCode;
                }

                // 주문수량이 변경된 경우 주문수량 Update
                od0101_Mapper.doUpdateUPODT(param);
                od0101_Mapper.doUpdateYPODT(param);

                if("Y".equals(BUDGETFLAG)) {

                    // MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
                    Map<String, Object> sParam = new HashMap<String, Object>();
                    sParam.put("CUST_CD", param.get("CUST_CD"));
                    sParam.put("BD_DEPT_CD", param.get("BD_DEPT_CD"));
                    sParam.put("P_ACCOUNT_CD", param.get("ACCOUNT_CD"));

                    String pAccountCd = bod103_Mapper.getAccountCd(sParam);
                    param.put("ACCOUNT_CD", pAccountCd);

                    od0101_Mapper.doUpdateCCUBD(param);
                }
            }
        }

        if( "1".equals(APPROVALFLAG) ){

            Map<String, String> approvalHeader = new ObjectMapper().readValue(param.get("approvalFormData"), Map.class);
            String signStatus = approvalHeader.get("SIGN_STATUS");

            // 결재자가 본인이 직접 처리하는 경우(전결정보가 없음)
            if(signStatus.equals("E")) {

                param.put("SIGN_STATUS", "E");
                param.put("PROGRESS_CD", "38");

                // 결재상태 변경
                od0101_Mapper.selfUpdateSignStatusYPODT(param);

                Map<String, String> poInfo = od0101_Mapper.getPoNoSelf(param);
                param.putAll(poInfo);

                // 공급사가 같고, 주문수량이 변경된 경우 주문수량 Update
                // 공급사가 다른 경우 : 결재완료시 기존 주문 삭제 후 신규 주문 생성
                if( "1".equals(param.get("CPO_QTY_MOD_YN")) ) {
                    if (!"1".equals(param.get("VND_MOD_YN"))) {
                        od0101_Mapper.doUpdateUPODT(param);
                        od0101_Mapper.doUpdateYPODT(param);
                    }
                }

                // 공급사 변경 : 새로운 po 생성 => 기존 PO 삭제
                if( "1".equals(param.get("VND_MOD_YN")) ){
                    // 새로운 PO 생성
                    String PONO = docNumService.getDocNumber("PO");
                    param.put("NEW_PO_NO", PONO);

                    // YPODT 등록 후 결재컬럼을 YPOHD에 함께 등록한다.
                    od0101_Mapper.doInsertYPODT(param);
                    od0101_Mapper.doInsertYPOHD(param);

                    // 고객사PO의 변경사항 적용하기
                    od0101_Mapper.doChangeCompleteUPODT(param);

                    // 기존 PO 삭제
                    od0101_Mapper.doDeleteYPODT(param); // 기존 발주정보 삭제
                    od0101_Mapper.doDeleteUIVDT(param); // 기존 고객사 납품정보 삭제
                    od0101_Mapper.doDeleteYIVDT(param); // 기존 공급사 납품정보 삭제
                } else {
                    // 결재완료 후 고객사PO, 공급사PO, 고객사/공급사 납품정보 변경
                    od0101_Mapper.doChangeCompleteYPODT(param);
                    od0101_Mapper.doChangeCompleteUPODT(param);
                    // 판매가 변경
                    if( "1".equals(param.get("SAL_PRC_MOD_YN")) ){
                        od0101_Mapper.doChangeCompleteUIVDT(param);
                    }
                    // 매입가 변경
                    if( "1".equals(param.get("BUY_PRC_MOD_YN")) ){
                        od0101_Mapper.doChangeCompleteYIVDT(param);
                    }
                }

                BUDGETFLAG = param.get("BUDGET_FLAG"); // 예산체크여부
                if("1".equals(BUDGETFLAG)) {

                    // MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
                    Map<String, Object> sParam = new HashMap<String, Object>();
                    sParam.put("CUST_CD", param.get("CUST_CD"));
                    sParam.put("BD_DEPT_CD", param.get("BD_DEPT_CD"));
                    sParam.put("P_ACCOUNT_CD", param.get("ACCOUNT_CD"));

                    String pAccountCd = bod103_Mapper.getAccountCd(sParam);
                    param.put("ACCOUNT_CD", pAccountCd);

                    od0101_Mapper.doUpdateCCUBD(param);
                }
            }
            else {

                String APPDOCNO = docNumService.getDocNumber("AP");
                String APPDOCCNT = "1";

                param.put("SIGN_STATUS", "P");
                param.put("APP_DOC_NUM", APPDOCNO);
                param.put("APP_DOC_CNT", APPDOCCNT);
                param.put("DOC_TYPE", "PO");

                // 5.1. 결재상태 및 결재번호 저장
                od0101_Mapper.doUpdateYPODTapp(param);
                // 5.2. 결재정보 저장
                approvalService.doApprovalProcess(param, param.get("approvalFormData"), param.get("approvalGridData"));
                messageCode = "0023";
            }
        }

        return messageCode;
    }

    // 결재승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApproval(String docNo, String docCnt, String signStatus) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", docNo);
        param.put("APP_DOC_CNT", docCnt);
        param.put("SIGN_STATUS", "E");
        param.put("PROGRESS_CD", "38"); // 주문완료

        // 결재상태 변경
        od0101_Mapper.doUpdateSignStatusYPODT(param);

        Map<String, String> poInfo = od0101_Mapper.getPoNo(param);
        param.putAll(poInfo);

        // 수량변경
        if( "Y".equals(param.get("CPO_QTY_MOD_YN")) ) {
            if (!"Y".equals(param.get("VENDOR_MOD_YN"))) {
                od0101_Mapper.doUpdateUPODT(param);
                od0101_Mapper.doUpdateYPODT(param);
            }
        }

        // 공급사 변경 : 새로운 po 생성 => 기존 PO 삭제
        if( "Y".equals(param.get("VENDOR_MOD_YN")) ){
            // 새로운 PO 생성
            String PONO = docNumService.getDocNumber("PO");
            param.put("NEW_PO_NO", PONO);

            // YPODT 등록 후 결재컬럼을 YPOHD에 함께 등록한다.
            od0101_Mapper.doInsertYPODT(param);
            od0101_Mapper.doInsertYPOHD(param);

            // 고객사PO의 변경사항 적용하기
            od0101_Mapper.doChangeCompleteUPODT(param);

            // 기존 PO 삭제
            od0101_Mapper.doDeleteYPODT(param); // 기존 발주정보 삭제
            od0101_Mapper.doDeleteUIVDT(param); // 기존 고객사 납품정보 삭제
            od0101_Mapper.doDeleteYIVDT(param); // 기존 공급사 납품정보 삭제
        } else {
            // 결재완료 후 고객사PO, 공급사PO, 고객사/공급사 납품정보 변경
            od0101_Mapper.doChangeCompleteYPODT(param);
            od0101_Mapper.doChangeCompleteUPODT(param);
            // 판매가 변경
            if( "Y".equals(param.get("SAL_PRC_MOD_YN")) ){
                od0101_Mapper.doChangeCompleteUIVDT(param);
            }
            // 매입가 변경
            if( "Y".equals(param.get("BUY_PRC_MOD_YN")) ){
                od0101_Mapper.doChangeCompleteYIVDT(param);
            }
        }

        String BUDGETFLAG = param.get("BUDGET_FLAG"); // 예산체크여부

        if("1".equals(BUDGETFLAG)) {

            // MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
            Map<String, Object> sParam = new HashMap<String, Object>();
            sParam.put("CUST_CD", param.get("CUST_CD"));
            sParam.put("BD_DEPT_CD", param.get("BD_DEPT_CD"));
            sParam.put("P_ACCOUNT_CD", param.get("ACCOUNT_CD"));

            String pAccountCd = bod103_Mapper.getAccountCd(sParam);
            param.put("ACCOUNT_CD", pAccountCd);

            od0101_Mapper.doUpdateCCUBD(param);
        }

        return msg.getMessage("0057"); // 승인이 완료되었습니다
    }

    // 결재반려
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String rejectApproval(String docNo, String docCnt) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", docNo);
        param.put("APP_DOC_CNT", docCnt);
        param.put("SIGN_STATUS", "R");
        param.put("PROGRESS_CD", "20"); // 결재반려

        // 결재상태 변경
        od0101_Mapper.doUpdateSignStatusYPODT(param);

        return msg.getMessage("0058"); // 반려 처리되었습니다.
    }

    // 결재취소
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String cancelApproval(String docNo, String docCnt) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", docNo);
        param.put("APP_DOC_CNT", docCnt);
        param.put("SIGN_STATUS", "C");

        // 결재상태 변경
        od0101_Mapper.doUpdateSignStatusYPODT(param);

        return msg.getMessage("0061"); // 취소 되었습니다.
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String od01011_doSaveRecipient(Map<String, String> param) throws Exception {

        od0101_Mapper.od01011_doSaveRecipient_UPDATE_UPODT(param);
        od0101_Mapper.od01011_doSaveRecipient_UPDATE_YPODT(param);

        if("40".equals(param.get("PROGRESS_CD"))) {
            od0101_Mapper.od01011_doSaveRecipient_UPDATE_UIVHD(param);
            od0101_Mapper.od01011_doSaveRecipient_UPDATE_YIVHD(param);
        }

        return msg.getMessageByScreenId("OD01_011", "017");
    }

    public List<Map<String, Object>> od01030_doSearch(Map<String, String> param) {
        if(EverString.isNotEmpty(param.get("IF_CPO_NO"))) {
            param.put("IF_CPO_NO_ORG", param.get("IF_CPO_NO"));
            param.put("IF_CPO_NO", EverString.forInQuery(param.get("IF_CPO_NO"), ","));
            param.put("IF_CPO_CNT", param.get("IF_CPO_NO").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("GR_NO"))) {
            param.put("GR_NO_ORG", param.get("GR_NO"));
            param.put("GR_NO", EverString.forInQuery(param.get("GR_NO"), ","));
            param.put("GR_CNT", param.get("GR_NO").contains(",") ? "1" : "0");
        }

        return od0101_Mapper.od01030_doSearch(param);
    }

    /**
     * 주문이력관리(구.MP)
     */
    public List<Map<String, Object>> od01040_doSearch(Map<String, String> param) {

        Map<String, String> sParam = new HashMap<>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }

        if(EverString.isNotEmpty(param.get("ITEM_KEY"))) {
            param.put("ITEM_KEY_ORG", param.get("ITEM_KEY"));
            param.put("ITEM_KEY", EverString.forInQuery(param.get("ITEM_KEY"), ","));
            param.put("ITEM_KEY_CNT", param.get("ITEM_KEY").contains(",") ? "1" : "0");
        }

        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));

        return od0101_Mapper.od01040_doSearch(fParam);
    }



















    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String yPoChange(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
        String appDocNum = "";
        String appDocCnt = "";

        formData.put("SIGN_STATUS","P");
        if (EverString.isEmpty(appDocNum)) {
            appDocNum = docNumService.getDocNumber("AP");
        }
        formData.put("APP_DOC_NUM", appDocNum);
        if (EverString.isEmpty(appDocCnt) || appDocCnt.equals("0")) {
            appDocCnt = "1";
            formData.put("APP_DOC_CNT", appDocCnt);
        } else {
            appDocCnt = String.valueOf(Integer.parseInt(appDocCnt) + 1);
            formData.put("APP_DOC_CNT", appDocCnt);
        }


        for(Map<String, Object> data : gridDatas) {
        	data.put("APP_DOC_NO", appDocNum);
        	data.put("APP_DOC_CNT", appDocCnt);
            data.put("SIGN_STATUS","P");
        	od0101_Mapper.yPoChange(data);
        }


        formData.put("DOC_TYPE", "POCH");
        approvalService.doApprovalProcess(formData, formData.get("approvalFormData"), formData.get("approvalGridData"));
    	return msg.getMessage("0023");
    }




    // 결재승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String endApprovalPoCh(String docNo, String docCnt, String signStatus) throws Exception {
        Map<String, String> param = new HashMap<String, String>();
        param.put("APP_DOC_NUM", docNo);
        param.put("APP_DOC_CNT", docCnt);
        param.put("SIGN_STATUS", signStatus);
        od0101_Mapper.yPoSignUpdate(param);

		if("E".equals(signStatus)) {
			List<Map<String, Object>> list = od0101_Mapper.PO0211_doSearch(param);

	        for(Map<String, Object> data : list) {
        		od0101_Mapper.uPoSignApply(data); // 주문변경
        		od0101_Mapper.yPoSignApply(data); // 발주변경

//	        	if("200".equals(data.get("PREV_DEAL_CD"))) { // 직발주
//	        		od0101_Mapper.uPoSignApply(data); // 주문변경
//	        		od0101_Mapper.yPoSignApply(data); // 발주변경
//	        	} else { // 매입/VMI
//	        		od0101_Mapper.uPoSignApply(data); // 주문변경
//	        		od0101_Mapper.yPoSignApply(data); // 발주변경
//	        		od0101_Mapper.delYpodt(data);  // 삭제
//	        		String doNo = docNumService.getDocNumber("DO");
//	        		data.put("DO_NO",doNo);
//	        		od0101_Mapper.movePohdToDohd(data);  // 발주 -> 출하지시 이동
//	        		od0101_Mapper.movePodtToDodt(data);  //
//	        	}
	        }

		}
        return msg.getMessage("0057"); // 승인이 완료되었습니다
    }




    public List<Map<String, Object>> PO0240_doSearch(Map<String, String> param) throws Exception {
        Map<String, String> sParam = new HashMap<String, String>();

        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "UPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.ITEM_CD");
            param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "UPODT.CUST_ITEM_CD");
            param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_CD");
            param.put("COL_VAL", param.get("MAKER_CD"));
            param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
            param.put("COL_NM", "UPODT.MAKER_NM");
            param.put("COL_VAL", param.get("MAKER_NM"));
            param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
        }

        if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
            param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
            param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
            param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
        }

        /*
        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }
         */

        Map<String, Object> fParam = new HashMap<String, Object>(param);
        fParam.put("PROGRESS_CD_LIST", Arrays.asList(EverString.nullToEmptyString(param.get("PROGRESS_CD")).split(",")));


        return od0101_Mapper.PO0240_doSearch(fParam);
    }
}