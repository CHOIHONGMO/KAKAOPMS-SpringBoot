package com.st_ones.evermp.STO.service;

import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.evermp.STO.PO05_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service(value = "PO05_Service")
public class PO05_Service {
    @Autowired
    private PO05_Mapper po05Mapper;
    @Autowired
    private QueryGenService queryGenService;
    @Autowired DocNumService  docNumService;  // 문서번호채번
    @Autowired EApprovalService approvalService;
    @Autowired LargeTextService largeTextService;
    @Autowired MessageService msg;
    @Autowired  private EverMailService everMailService;
    @Autowired  private EverSmsService everSmsService;




    /** ******************************************************************************************
     **  재고관리 > 재고발주 > (재고,VMI)발주 처리 (PO0510)
     */
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public List<Map<String, Object>> po0510_doSearch(Map<String, String> formData) throws Exception {
        if (!EverString.nullToEmptyString(formData.get("ITEM_DESC")).equals("")) {
            formData = getQueryParam(formData, "B.ITEM_DESC", formData.get("ITEM_DESC"), "ITEM_DESC_01");
            formData = getQueryParam(formData, "B.ITEM_SPEC", formData.get("ITEM_DESC"), "ITEM_DESC_02");
        }
    	return po05Mapper.po0510_doSearch(formData);
	}


    /** ******************************************************************************************
     **  발주등록
     */


    // 저장 및 유효성검증, 주문하기
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String PO0550_doSave(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {
        String pMod = EverString.nullToEmptyString(param.get("pMod"));
        String CPONO = "";
        String SIGN_STATUS  = "E"; // 결재상태

        int cpoSeq = 1;
        CPONO = docNumService.getDocNumber("CPO");

        for( Map<String, Object> gridData : gridList ){
        	String prType = gridData.get("PR_TYPE").toString();  // G : 일반구매 , C : 시행구매
        	String PO_NO = docNumService.getDocNumber("PO");
            // 주문하기
            if( "Order".equals(pMod) ) {
            	gridData.put("CPO_NO",  CPONO);
            	gridData.put("PR_TYPE",  prType);
            	gridData.put("PO_NO",   PO_NO);
            	gridData.put("SIGN_STATUS",   SIGN_STATUS);
            	gridData.put("CUST_CD", param.get("CUST_CD"));
            	gridData.put("PROGRESS_CD", "5100"); // 발주대기
            	gridData.put("CPO_SEQ", cpoSeq);
               if( cpoSeq == 1 ){
            	   po05Mapper.po0550_doInsertUPOHD(gridData);
            	 }
            	 po05Mapper.po0550_doInsertUPODT(gridData);
                 po05Mapper.doInsertYPOHD(gridData);
                 po05Mapper.doInsertYPODT(gridData);

				 cpoSeq++;
            }
        }
        return msg.getMessageByScreenId("PO0550", "0038");
    }




    /** ******************************************************************************************
     *  공급사 선택
     */
    public List<Map<String, Object>> PO0560_doSearch(Map<String, String> param) throws Exception {


        Map<String, String> sParam = new HashMap<String, String>();
        if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
            param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
            param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
        }

    	return po05Mapper.PO0560_doSearch(param);
    }

    /** ******************************************************************************************
     * 재고관리 > 재고발주 > (재고, VMI)발주현황 (PO0520)
     */
    public List<Map<String, Object>> PO0520_doSearch(Map<String, String> param) throws Exception {
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


        return po05Mapper.PO0520_doSearch(fParam);
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String po0520_doPoConfirmXX(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
    	String progressCdF = formData.get("PROGRESS_CD");
    	Map<String, Object> mailTargetList = new HashMap<String,Object>();
        for (Map<String, Object> gridData : gridDatas) {
            String progressCd = po05Mapper.checkProgressCd(gridData);
            if (!"5100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("PO0520", "0022"));
            }
            gridData.put("PROGRESS_CD", progressCdF);

            if("2100".equals(progressCdF)) {// 접수취소일시 YPO 삭제
            	po05Mapper.doDelYpo(gridData); //YPODT
            	po05Mapper.doDelUPODT(gridData); //YPODT
            } else {
            	po05Mapper.doPoConfirmUpo(gridData);
            	po05Mapper.doPoConfirmYpo(gridData);
            	  String vendorCd = String.valueOf(gridData.get("VENDOR_CD"));
                  String poNo = String.valueOf(gridData.get("PO_NO"));

                  if (mailTargetList.containsKey(vendorCd)) {
                  	mailTargetList.put(vendorCd, mailTargetList.get(vendorCd) + "," + poNo);
                  } else {
                  	mailTargetList.put(vendorCd,poNo);
                  }

            }
        }
       // if (1==1) throw new Exception("========================================");
        if("6100".equals(progressCdF)) {
        	sendEmail(mailTargetList);

            return msg.getMessageByScreenId("PO0520", "0038");
        } else {
            return msg.getMessageByScreenId("PO0520", "0040");
        }

    }
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String po0520_doPoClose(Map<String, String> formData,List<Map<String, Object>> gridDatas) throws Exception {
        for (Map<String, Object> gridData : gridDatas) {
        	po05Mapper.setUPoClose(gridData);
        	po05Mapper.setYPoClose(gridData);
        }

        return msg.getMessageByScreenId("PO0520", "0033");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String po0520_doTransferCtrl(Map<String, String> formData, List<Map<String, Object>> gridDatas) throws Exception {

        for (Map<String, Object> gridData : gridDatas) {

            String progressCd = po05Mapper.checkProgressCd(gridData);
            if (!"2200".equals(progressCd) && !"5100".equals(progressCd)) {
                throw new Exception(msg.getMessageByScreenId("PO0520", "020"));
            }
            gridData.put("AM_USER_ID", formData.get("AM_USER_ID"));
            gridData.put("AM_USER_CHANGE_RMK", formData.get("AM_USER_CHANGE_RMK"));
            po05Mapper.doTransferAmUserUpo(gridData);
            po05Mapper.doTransferAmUserYpo(gridData);
        }
        return msg.getMessageByScreenId("PO0520", "0012");
    }


    public Map<String, String> getQueryParam(Map<String, String> param, String COL_NM, String COL_VAL, String key) {
        param.put("COL_NM", COL_NM);
        param.put("COL_VAL", COL_VAL);

        param.put(key, EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));

        return param;
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



	        List<Map<String, String>> vendorList = po05Mapper.getTargetList(param);
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
	                mdata.put("SUBJECT", "[대명소노시즌] " + vendorData.get("VENDOR_NM") + " 님. 귀사에 물류센터 발주서가 도착했습니다.");
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
	                sdata.put("SMS_SUBJECT", "[대명소노시즌] 물류센터 발주서가 도착했습니다."); // SMS 제목


		            if(poCount==1) {
		                sdata.put("CONTENTS", "[대명소노시즌] 물류센터 발주서가 도착했습니다.(" + poNo + ")"); // 전송내용
		            } else {
		                sdata.put("CONTENTS", "[대명소노시즌] 물류센터 발주서가 도착했습니다.(" + poOne +" 외 "+(poCount-1)+"건" + ")"); // 전송내용
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

}

