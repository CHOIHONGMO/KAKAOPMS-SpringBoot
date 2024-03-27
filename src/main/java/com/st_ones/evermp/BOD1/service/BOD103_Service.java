package com.st_ones.evermp.BOD1.service;

import com.st_ones.common.combo.service.CommonComboService;
import com.st_ones.common.docNum.service.DocNumService;
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
import com.st_ones.evermp.BOD1.BOD102_Mapper;
import com.st_ones.evermp.BOD1.BOD103_Mapper;
import com.st_ones.evermp.BOD1.BOD104_Mapper;
import com.st_ones.evermp.BYM1.BYM101_Mapper;
import com.st_ones.eversrm.eApproval.service.EApprovalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : BOD103_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "bod103_Service")
public class BOD103_Service extends BaseService {

	@Autowired private EApprovalService approvalService;
	@Autowired BOD103_Mapper bod103_Mapper;
	@Autowired BOD104_Mapper bod104_Mapper;
	@Autowired MessageService msg;
	@Autowired private DocNumService docNumService;
	@Autowired private EverMailService everMailService;
    @Autowired private EverSmsService everSmsService;
    @Autowired LargeTextService largeTextService;
	@Autowired private CommonComboService commonComboService;
	@Autowired private BYM101_Mapper bym101_mapper;
    @Autowired BOD102_Mapper  bod102_Mapper;

	/** ******************************************************************************************
     * 주문 CART 조회
     * @param req
     * @return
     * @throws Exception
     */
	public Map<String, String> getAccData(Map<String, String> param) throws Exception {
		return bod103_Mapper.getAccData(param);
	}

	public Map<String, String> getCommonAccData(Map<String, String> param) throws Exception {
		return bod103_Mapper.getCommonAccData(param);
	}

	public List<Map<String, Object>> bod1030_doSearch(Map<String, String> param) throws Exception {
		return bod103_Mapper.bod1030_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1030_doSave(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
        	bod103_Mapper.bod1030_doSave(gridData);
        }
        return msg.getMessage("0031");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1030_doDelete(List<Map<String, Object>> gridList) throws Exception {
        for(Map<String, Object> gridData : gridList) {
        	bod103_Mapper.bod1030_doDelete(gridData);
        }
        return msg.getMessage("0017");
    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1030_doOrder(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {

    	String APPROVALFLAG = param.get("CUST_SIGN_FLAG"); // 결재여부
		String BUDGETFLAG 	= param.get("CUST_BUDGET_FLAG"); // 예산체크여부
		String PRIORGRFLAG 	= param.get("FIRST_GR_FLAG"); // 선입고여부
		String CPODATE		= param.get("ORD_DATE"); // 주문일자
		String signStatus	= param.get("signStatus"); // 결재요청상태 (전결에 미등록되거나 조건에 부합하지 않아, 결재 필요없이 담당자가 직접 주문하는 경우, "E"로 넘어온다.)
		String AUTO_PO_FLAG	= param.get("AUTO_PO_FLAG");
		String PROGRESS_CD = "2100";

    	String CPONO = docNumService.getDocNumber("CPO");
		param.put("CPO_NO", CPONO);
		param.put("APPROVE_FLAG", APPROVALFLAG);
		param.put("BUDGET_FLAG", BUDGETFLAG);
		param.put("PRIOR_GR_FLAG", PRIORGRFLAG);
		param.put("CPO_DATE", CPODATE);

		// 1. STOUPOHD 등록
		param.put("PR_TYPE","G");
		bod103_Mapper.doInsertUPOHD(param);

		if( "Y".equals(APPROVALFLAG) || "1".equals(APPROVALFLAG) ) {
			PROGRESS_CD = "1100";
		} else {
			if("1".equals(AUTO_PO_FLAG)) {
				PROGRESS_CD = "5300";
			}
		}



    	UserInfo userInfo = UserInfoManager.getUserInfo();

		Map<String,Object> param2 = new HashMap<String,Object>();
		param2.put("CPO_USER_ID", userInfo.getUserId() );
		Map<String, Object> custUser = bod102_Mapper.doGetCustUser(param2); //고객사 사용자 체크
		
		String cublSeq = String.valueOf(custUser.get("CUBL_SEQ"));
		if( EverString.isEmpty(cublSeq) || "null".equals(cublSeq) ) {
			cublSeq = "";
		}
		
		int cpo_seq = 1;
    	for(Map<String, Object> gridData : gridList) {

    		gridData.put("CPO_NO", CPONO);
			gridData.put("CPO_SEQ", String.valueOf(cpo_seq++));
			gridData.put("CPO_DATE", CPODATE);
			gridData.put("PROGRESS_CD", PROGRESS_CD);
			gridData.put("cublSeq", cublSeq);
			
			if("1".equals(AUTO_PO_FLAG)) {
				gridData.put("DELY_TYPE", "A");      // 배송방법,  A:직접배송
				gridData.put("DELY_PLACE", "1");    // 배송장소, 1: 고객사
			}
			
			// 2. STOUPODT 등록
			gridData.put("PR_TYPE",param.get("PR_TYPE"));
			bod103_Mapper.doInsertUPODT(gridData);


			// 3. 예산 차감
			if( "Y".equals(BUDGETFLAG) || "1".equals(BUDGETFLAG) ) {

				// MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
//				gridData.put("P_ACCOUNT_CD", gridData.get("ACCOUNT_CD"));
//				String pAccountCd = bod103_Mapper.getAccountCd(gridData);
//				gridData.put("ACCOUNT_CD", pAccountCd);

				bod103_Mapper.doCalulateBudget(gridData);
			}

			// 4. 고객사 신규품목(STOUNWRQ) 변경
			if( !"".equals(EverString.nullToEmptyString(gridData.get("ITEM_REQ_NO"))) ) {
				bod103_Mapper.doUpdateNWRQpo(gridData);
			}
        }

    	// 5. 결재여부 : 'Y'인 경우
    	String messageCode = "0001";
    	if( "Y".equals(APPROVALFLAG) || "1".equals(APPROVALFLAG) ) {

    		if(signStatus.equals("P")) {

				String APPDOCNO = docNumService.getDocNumber("AP");
				String APPDOCCNT = "1";

				param.put("SIGN_STATUS", "P");
				param.put("APP_DOC_NUM", APPDOCNO);
				param.put("APP_DOC_CNT", APPDOCCNT);
				param.put("DOC_TYPE", "CPO");

				// 5.1. 결재상태 및 결재번호 저장
				bod103_Mapper.doUpdateUPOHDapp(param);
				// 5.2. 결재정보 저장
				approvalService.doApprovalProcess(param, param.get("approvalFormData"), param.get("approvalGridData"));

				messageCode = "0023";
			}

			if(signStatus.equals("E")) {
				if("1".equals(AUTO_PO_FLAG)) {
					PROGRESS_CD = "5300";
				} else {
					PROGRESS_CD = "2100";
				}

				Map<String, String> sParam = new HashMap<String, String>();
				sParam.put("CPO_NO", CPONO);
				sParam.put("SIGN_STATUS", "E");
				sParam.put("PROGRESS_CD", PROGRESS_CD);

				Map<String, String> cpoInfo = bod103_Mapper.getCpoNo(sParam);
				sParam.put("CPO_NO", cpoInfo.get("CPO_NO"));

				// 고객사po 진행상태 변경
				bod103_Mapper.doUpdateSignStatusUPOHDNoApp(sParam);
				bod103_Mapper.doUpdateSignStatusUPODT(sParam);

				// CPO를 PO로 분리하여 생성함
				// 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호, 배송지코드
				// HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD, CSDM_SEQ
				if("1".equals(AUTO_PO_FLAG)) {
					List<Map<String, Object>> poList = bod103_Mapper.getPOList(sParam);
					List<Map<String, String>> vendorList = commonComboService.getCodeCombo("MP088");

					for(Map<String, Object> poData : poList) {
						String PONO = docNumService.getDocNumber("PO");
						poData.put("CPO_NO", CPONO);
						poData.put("PO_NO",  PONO);
                        poData.put("PROGRESS_CD", PROGRESS_CD);

						bod103_Mapper.doInsertYPOHD(poData);
						bod103_Mapper.doInsertYPODT(poData);
					}

					// 2022.09.02 HMCHOI 제외 (주문 완료 후 공급사에게 메일 발송)
					//sendEmailNSms(sParam);
				}

				// 1회성 품목인 경우 "품목상태=단종"으로 변경
				bod103_Mapper.doUpdateItemStatus(sParam);

				messageCode = "0001";
			}
    	} else {
			// CPO를 PO로 분리하여 생성함
			// 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호, 배송지코드
			// HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD, CSDM_SEQ
			if("1".equals(AUTO_PO_FLAG)) {
				PROGRESS_CD = "5300"; // 발주확정

				List<Map<String, Object>> poList = bod103_Mapper.getPOList(param);
				List<Map<String, String>> vendorList = commonComboService.getCodeCombo("MP088");

				for(Map<String, Object> poData : poList) {
					String PONO = docNumService.getDocNumber("PO");

					poData.put("CPO_NO",  CPONO);
					poData.put("PO_NO",   PONO);
					poData.put("CUST_CD", param.get("CUST_CD"));
                    poData.put("PROGRESS_CD", PROGRESS_CD);

					bod103_Mapper.doInsertYPOHD(poData);
					bod103_Mapper.doInsertYPODT(poData);
				}

				// 공급사 발주 이후 공급사에게 메일 보내기
				sendEmailNSms(param);
			}

			// 1회성 품목인 경우 "품목상태=단종"으로 변경
			bod103_Mapper.doUpdateItemStatus(param);

			messageCode = "0001";
		}

    	// 주문 완료건 cart에서 삭제
		for (Map<String, Object> gridData : gridList) {
			bod103_Mapper.bod1030_doDelete(gridData);
		}
        return msg.getMessage(messageCode);
    }

    // 결재승인
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String endApproval(String docNo, String docCnt, String signStatus) throws Exception {
		Map<String, String> param = new HashMap<String, String>();
		String PROGRESS_CD = "2100";

		param.put("APP_DOC_NUM", docNo);
		param.put("APP_DOC_CNT", docCnt);
		param.put("SIGN_STATUS", "E");

		Map<String, String> cpoInfo = bod103_Mapper.getCpoNo(param);
		String CPONO = cpoInfo.get("CPO_NO");

		if("1XX".equals(cpoInfo.get("AUTO_PO_FLAG"))) {
			PROGRESS_CD = "5300";
		}

		param.put("PROGRESS_CD", PROGRESS_CD);
		param.put("CPO_NO", CPONO);


		// 고객사po 진행상태 변경
		bod103_Mapper.doUpdateSignStatusUPOHD(param);
		bod103_Mapper.doUpdateSignStatusUPODT(param);

		// CPO를 PO로 분리하여 생성함
		// 분리조건 : 납품희망일자, 공급사코드, 거래유형, 인수자명, 우편번호, 배송지코드
		// HOPE_DUE_DATE, VENDOR_CD, DEAL_CD, RECIPIENT_NM, DELY_ZIP_CD, CSDM_SEQ
		if("1XX".equals(cpoInfo.get("AUTO_PO_FLAG"))) {
			List<Map<String, Object>> poList = bod103_Mapper.getPOList(param);
			List<Map<String, String>> vendorList = commonComboService.getCodeCombo("MP088");

			for(Map<String, Object> poData : poList) {
				String PONO = docNumService.getDocNumber("PO");
				poData.put("CPO_NO", CPONO);
				poData.put("PO_NO",  PONO);
                poData.put("PROGRESS_CD", PROGRESS_CD);

				bod103_Mapper.doInsertYPOHD(poData);
				bod103_Mapper.doInsertYPODT(poData);
			}

			// 공급사 발주 이후 공급사에게 메일 보내기
			sendEmailNSms(param);
		}

		//1회성 품목인 경우 "품목상태=단종"으로 변경
		//bod103_Mapper.doUpdateItemStatus(param);

		return msg.getMessage("0057"); // 승인이 완료되었습니다
	}

    // 결재반려
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String rejectApproval(String docNo, String docCnt, String signStatus) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		param.put("APP_DOC_NUM", docNo);
		param.put("APP_DOC_CNT", docCnt);
		param.put("SIGN_STATUS", "R");
		param.put("PROGRESS_CD", "1100"); // 결재반려

		Map<String, String> cpoInfo = bod103_Mapper.getCpoNo(param);
		String CPONO = cpoInfo.get("CPO_NO");
		param.put("CPO_NO", CPONO);

		// 1. 집행예산 삭감(BULK로 주문생성은 예산체크 제외)
		if( !"BULK".equals(cpoInfo.get("DATA_CREATE_TYPE")) ){
			List<Map<String, Object>> poDatas = bod103_Mapper.getPoDatas(param);
			for(Map<String, Object> poData : poDatas) {
				bod103_Mapper.doDecreaseBudgetForApp(poData);
			}
			// bod103_Mapper.doDecreaseBudget(param);
		}

		// 2. 결재상태 반려로 변경
		bod103_Mapper.doUpdateSignStatusUPOHD(param);
		bod103_Mapper.doUpdateSignStatusUPODT(param);

		return msg.getMessage("0058"); // 반려 처리되었습니다.
	}

	// 결재취소
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String cancelApproval(String docNo, String docCnt, String signStatus) throws Exception {

		Map<String, String> param = new HashMap<String, String>();
		param.put("APP_DOC_NUM", docNo);
		param.put("APP_DOC_CNT", docCnt);
		param.put("SIGN_STATUS", "C");

		Map<String, String> cpoInfo = bod103_Mapper.getCpoNo(param);
		String CPONO = cpoInfo.get("CPO_NO");
		param.put("CPO_NO", CPONO);

		// 1. 집행예산 삭감(BULK로 주문생성은 예산체크 제외)
		if( !"BULK".equals(cpoInfo.get("DATA_CREATE_TYPE")) ){
			List<Map<String, Object>> poDatas = bod103_Mapper.getPoDatas(param);
			for(Map<String, Object> poData : poDatas) {
				bod103_Mapper.doDecreaseBudgetForApp(poData);
			}
			// bod103_Mapper.doDecreaseBudget(param);
		}

		// 2. 결재상태 반려로 변경
		bod103_Mapper.doUpdateSignStatusUPOHD(param);
		bod103_Mapper.doUpdateSignStatusUPODT(param);

		return msg.getMessage("0061"); // 취소 되었습니다.
	}

    /** ******************************************************************************************
     * 예산체크
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> bod1031_doSearch(Map<String, Object> param) throws Exception {

		String itemParamRow  = (String) param.get("itemParam");
		String[] accountCode = itemParamRow.trim().split(",");

		List<Map<String, String>> accountSeqList = new ArrayList<Map<String, String>>();
		for (int i = 0; i < accountCode.length; i++) {
			Map<String, String> accountSeqMap = new HashMap<String, String>();
			String itemParamCol = accountCode[i];
			String[] orderAmt =  itemParamCol.trim().split(":");

			accountSeqMap.put("pBudgetDeptCode", orderAmt[0]); // 예산부서
			accountSeqMap.put("pItemAmt", orderAmt[2]); // 주문금액

			// MP102에 등록된 CUST_CD와 ses.companyCd가 같은 경우, 고정계정을 사용하는 고객사이므로 고정계정을 사용한다.
			//Map<String, Object> sParam = new HashMap<String, Object>();
			//sParam.put("P_ACCOUNT_CD", orderAmt[1]);
			//String pAccountCd = bod103_Mapper.getAccountCd(sParam);
			accountSeqMap.put("pAccountCode", orderAmt[1]); // 계정코드

			accountSeqList.add(accountSeqMap);
		}
		param.put("accountSeqList", accountSeqList);

		return bod103_Mapper.bod1031_doSearch(param);
	}

	public List<Map<String, Object>> bod1031_doSearchAll(Map<String, Object> param) throws Exception {
		return bod103_Mapper.bod1031_doSearchAll(param);
	}

	/** ******************************************************************************************
     * 관심품목 등록
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> bod1032_doSearch(Map<String, String> param) throws Exception {
		return bod103_Mapper.bod1032_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public String bod1032_doSave(Map<String, String> param, List<Map<String, Object>> gridList) throws Exception {
		String itemInfoRow = param.get("itemInfo");
		String[] rowItem   = itemInfoRow.trim().split(",");

        for(Map<String, Object> gridData : gridList) {
        	for (int i = 0; i < rowItem.length; i++) {
				String itemParamCol = rowItem[i];
				String[] colItem 	= itemParamCol.split(":");
				gridData.put("ITEM_CD",   colItem[0]);
				gridData.put("APPLY_COM", colItem[1]);
				gridData.put("CONT_NO",   colItem[2]);
				gridData.put("CONT_SEQ",  colItem[3]);
				gridData.put("APPLY_PLANT",  colItem[4]);

				if (param.get("ACTION_FLAG").equals("M")) {
					String tpl_no = String.valueOf(gridData.get("TPL_NO"));
					String old_tpl_no = colItem[4];
					String old_tpl_sq = colItem[5];
					gridData.put("TPL_NO", old_tpl_no);
					gridData.put("TPL_SQ", old_tpl_sq);

					bym101_mapper.bym1020_doDeleteCart(gridData);

					gridData.put("TPL_NO", tpl_no);
				}
				bod103_Mapper.bod1032_doSave(gridData);
        	}
        }
        return msg.getMessage("0031");
    }

	// 자동발주(AUTO_PO_FLAG=1)인 경우에만 공급사 발주(YPOHD, YPODT) 생성 후 메일 발송
	// 발주상태는 발주확정(5300)인 경우에만 .., 발주대기(5100)인 경우 메일 발송 안함
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public void sendEmailNSms(Map<String, String> param) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
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

        // 공급사별 주문헤더(UPOHD) 가져오기
		Map<String, String> headerMap = new HashMap<>();
        headerMap.put("CPO_NO", param.get("CPO_NO"));

        List<Map<String, Object>> headerList = bod104_Mapper.getCpoHeaderInfo(headerMap);

        // 1. 주문자에게 SMS 전송
        /*Map<String, Object> cpoUserInfo = headerList.get(0);
        if( !cpoUserInfo.get("CUST_HP_NUM").equals("") ){
            Map<String, String> hdata = new HashMap<String, String>();
            hdata.put("SEND_USER_ID", "SYSTEM"); // 보내는 사용자ID
            hdata.put("SEND_USER_NM", "SYSTEM"); // 보내는사람
            hdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 보내는 사람 전화번호
            hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID"))); // 받는 사용자ID
            hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 받는사람
            hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_HP_NUM"))); // 받는 사람 전화번호
            hdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))+"님. 주문이 정상접수 되었습니다.("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+") 감사합니다."); // 전송내용
            hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
            hdata.put("REF_MODULE_CD","CPO"); // 참조모듈
            everSmsService.sendSms(hdata);
			hdata.clear();
        }*/

        // 2. 공급사에게 mail, sms 발송하기
        String fileContents   = "";
        for( Map<String, Object> headerInfo : headerList ){
        	fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
            fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(headerInfo.get("CPO_NO"))); // 주문번호
            fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(headerInfo.get("CPO_DATE"))); // 주문일자
            fileContents = EverString.replace(fileContents, "$PRIOR_GR_FLAG$", EverString.nullToEmptyString(headerInfo.get("PRIOR_GR_FLAG"))); // 선입고여부
            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", EverString.nullToEmptyString(headerInfo.get("VENDOR_NM"))); // 공급사
            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

            String tblBody = "<tbody>";
            String enter = "\n";
            // 주문품목(UPODT) 가져오기
			Map<String, String> detailMap = new HashMap<>();
			detailMap.put("CPO_NO", param.get("CPO_NO"));
			detailMap.put("CPO_SEQ", param.get("CPO_SEQ"));
			detailMap.put("VENDOR_CD", (String)headerInfo.get("VENDOR_CD"));

            List<Map<String, Object>> itemList = bod104_Mapper.getCpoDetailInfo(detailMap);
            if( itemList.size() > 0 ){
                for( Map<String, Object> itemData : itemList ){
                    // 품목명
                	String itemDesc = (String)itemData.get("ITEM_DESC");
                    if(itemDesc != null && itemDesc.length() > 29) { itemDesc = itemDesc.substring(0, 30) + "..."; }
                    // 품목규격
                    String itemSpec = (String)itemData.get("ITEM_SPEC");
                    if(itemSpec != null && itemSpec.length() > 29) { itemSpec = itemSpec.substring(0, 30) + "..."; }
                    // 품목리스트
                    String tblRow = "<tr>"
                    		+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd' rowspan='2'>" + EverString.nullToEmptyString(itemData.get("ITEM_CD")) + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_NM")) + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:right;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_QTY")) + "</td>"
                            + enter + "</tr>"
                            + enter + "<tr>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("UNIT_CD")) + "</td>"
                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
                            + enter + "</tr>";
                    tblBody += tblRow;
                }
            }
            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
            fileContents = EverString.rePreventSqlInjection(fileContents);

            // 공급사에게 MAIL, SMS 발송
			Map<String, String> vendorMap = new HashMap<>();
			vendorMap.put("CPO_NO", param.get("CPO_NO"));
			vendorMap.put("CPO_SEQ", param.get("CPO_SEQ"));
			vendorMap.put("VENDOR_CD", (String)headerInfo.get("VENDOR_CD"));

            List<Map<String, Object>> vendorList = bod104_Mapper.getCpoVendorList(vendorMap);
            for (Map<String, Object> vendorData : vendorList) {
                // 메일 발송
            	if( !vendorData.get("EMAIL").equals("") ){
                    Map<String, String> mdata = new HashMap<String, String>();
                    mdata.put("SUBJECT", "[대명소노시즌] 발주가 도착하였습니다.("+EverString.nullToEmptyString(headerInfo.get("CPO_NO"))+EverString.nullToEmptyString(headerInfo.get("PRIOR_GR_FLAG"))+")");
                    mdata.put("CONTENTS_TEMPLATE", fileContents);
                    mdata.put("RECV_USER_ID", EverString.nullToEmptyString(vendorData.get("USER_ID"))); // 공급사
                    mdata.put("RECV_USER_NM", EverString.nullToEmptyString(vendorData.get("USER_NM")));
                    mdata.put("RECV_EMAIL", EverString.nullToEmptyString(vendorData.get("EMAIL")));
                    mdata.put("REF_NUM", EverString.nullToEmptyString(headerInfo.get("CPO_NO")));
                    mdata.put("REF_MODULE_CD", "CPO"); // 참조모듈
                    // Mail 발송
                    everMailService.sendMail(mdata);
					mdata.clear();
                }

                // SMS 전송
                if( !vendorData.get("CELL_NUM").equals("") ){
                    Map<String, String> sdata = new HashMap<String, String>();
                    sdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(headerInfo.get("VENDOR_NM"))+"님. 발주가 도착하였습니다.("+EverString.nullToEmptyString(headerInfo.get("CPO_NO"))+") 확인바랍니다."); // 전송내용
                    sdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 보내는 사람 전화번호
                    sdata.put("RECV_USER_ID", EverString.nullToEmptyString(vendorData.get("USER_ID"))); // 받는 사용자ID
                    sdata.put("RECV_USER_NM", EverString.nullToEmptyString(vendorData.get("USER_NM"))); // 받는사람
                    sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(vendorData.get("CELL_NUM"))); // 받는 사람 전화번호
                    sdata.put("REF_NUM", EverString.nullToEmptyString(headerInfo.get("CPO_NO"))); // 참조번호
                    sdata.put("REF_MODULE_CD", "CPO"); // 참조모듈
                    // SMS 전송
                    everSmsService.sendSms(sdata);
					sdata.clear();
                }
            }
        }
	}

    public List<Map<String, String>> doSearchIfVendorList() {
		return bod103_Mapper.doSearchIfVendorList();
    }
}
