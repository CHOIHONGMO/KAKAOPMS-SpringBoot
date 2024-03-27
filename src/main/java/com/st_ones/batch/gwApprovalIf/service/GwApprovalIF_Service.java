package com.st_ones.batch.gwApprovalIf.service;

import com.st_ones.batch.gwApprovalIf.GwApprovalIF_Mapper;
import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.docNum.service.DocNumService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.common.util.service.LargeTextService;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.evermp.IM03.IM0301_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "GwApprovalIF_Service")
public class GwApprovalIF_Service {

    @Autowired private MessageService msg;
    @Autowired private GwApprovalIF_Mapper approvalif_mapper;
    @Autowired private IM0301_Mapper im0301Mapper;

    // 실시간 I/F는 공통에서 관리함
    @Autowired private RealtimeIF_Service realtimeif_service;
    @Autowired private RealtimeIF_Mapper realtimeif_mapper;

    @Autowired private DocNumService docNumService;
    @Autowired private LargeTextService largeTextService;
    @Autowired private EverSmsService everSmsService;
    @Autowired private EverMailService everMailService;

    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public String GwApprovalIF(Map<String, String> param) throws Exception {

    	// 입칠시행품의(120017001126)에 대해 협력사에게 MAIL, SMS 발송
    	param.put("DM_BID_KEY", PropertiesManager.getString("eversrm.dm.gw.bid.key"));
    	List<Map<String, String>> bidVendorList = approvalif_mapper.getBidSmsSELECT(param);
    	if (bidVendorList != null && bidVendorList.size() > 0) {
	    	// E-Mail, SMS 발송
	        String templatePath = PropertiesManager.getString("eversrm.system.mailTemplatePath");
	        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.RFP_TemplateFileName");

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

	    	for (Map<String, String> data : bidVendorList){

	            if(data.get("RECV_USER_EMAIL") != null && !EverString.nullToEmptyString(data.get("RECV_USER_EMAIL")).equals("")) {
		    		String rfqNumCnt = EverString.nullToEmptyString(data.get("RFX_NUM")) + " / " + EverString.nullToEmptyString(String.valueOf(data.get("RFX_CNT")));
			        String vendorOpenDealType = EverString.nullToEmptyString(data.get("VENDOR_OPEN_TYPE")) + " / " + EverString.nullToEmptyString(String.valueOf(data.get("DELY_TYPE")));

			        /**
			         * 2023.01.11 김효주 매니저 제외요청
			        String rmkText = largeTextService.selectLargeText(EverString.nullToEmptyString(data.get("RMK_TEXT_NUM")));
			        String tblBody = "<tbody>";
			        String enter = "\n";
			        List<Map<String, String>> itemList = approvalif_mapper.getRfxItemList(data);
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
			        }*/

			        String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		            fileContents = EverString.replace(fileContents, "$VENDOR_NM$", (data.get("RECV_USER_NM") == null ? "" : data.get("RECV_USER_NM"))); // 공급사명
		            fileContents = EverString.replace(fileContents, "$RFQ_NUM_CNT$", (rfqNumCnt == null ? "" : rfqNumCnt)); // 견적의뢰번호/차수
		            fileContents = EverString.replace(fileContents, "$RFQ_SUBJECT$", (data.get("RFX_SUBJECT") == null ? "" : data.get("RFX_SUBJECT"))); // 견적의뢰명
		            fileContents = EverString.replace(fileContents, "$RFQ_CLOSE_DATE$", (data.get("RFQ_CLOSE_DATE")==null ? "" : data.get("RFQ_CLOSE_DATE"))); // 견적마감일시
		            fileContents = EverString.replace(fileContents, "$VENDOR_OPEN_DEAL_TYPE$", (vendorOpenDealType == null ? "" : vendorOpenDealType)); // 지명방식/거래유형
		            fileContents = EverString.replace(fileContents, "$RMK_TEXT$", (data.get("RMK") == null ? "" : data.get("RMK"))); // 요청사항
		            fileContents = EverString.replace(fileContents, "$CTRL_USER_NM$", (data.get("SEND_USER_NM") == null ? "" : data.get("SEND_USER_NM"))); // 품목담당자
		            fileContents = EverString.replace(fileContents, "$TEL_NUM$", (data.get("SEND_TEL_NO") == null ? "" : data.get("SEND_TEL_NO"))); // 연락처
		            fileContents = EverString.replace(fileContents, "$ANN_ATTEND_FLAG$", (data.get("ANN_ATTEND_FLAG") == null ? "" : data.get("ANN_ATTEND_FLAG"))); // 개최여부
		            fileContents = EverString.replace(fileContents, "$ANN_PLACE_NM$", (data.get("ANN_PLACE_NM") == null ? "" : data.get("ANN_PLACE_NM"))); // 개최장소
		            fileContents = EverString.replace(fileContents, "$ANN_USER_TEL_NM$", (data.get("ANN_USER_TEL_NM") == null ? "" : data.get("ANN_USER_TEL_NM"))); // 문의처
		            fileContents = EverString.replace(fileContents, "$ANN_DATE$", (data.get("ANN_DATE") == null ? "" : data.get("ANN_DATE"))); // 개최일
		            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
		            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
		            fileContents = EverString.rePreventSqlInjection(fileContents);

	                Map<String, String> mdata = new HashMap<String, String>();
	                mdata.put("SUBJECT", "[대명소노시즌] " + data.get("RECV_USER_NM") + " 님. 귀사에 입찰을 요청드립니다.");
	                mdata.put("CONTENTS_TEMPLATE", fileContents);
	                mdata.put("RECV_USER_ID", data.get("RECV_USER_ID"));
	                mdata.put("RECV_USER_NM", data.get("RECV_USER_NM"));
	                mdata.put("RECV_EMAIL", data.get("RECV_USER_EMAIL"));
	                mdata.put("REF_NUM", data.get("RFQ_NUM"));
	                mdata.put("REF_MODULE_CD", "RFP"); // 참조모듈
	                // 메일전송.
	                everMailService.sendMail(mdata);
	                mdata.clear();
	            }

	        	// 입찰 공급사 목록에게 SMS 보내기
	            if(data.get("RECV_CELL_NO") != null && !EverString.nullToEmptyString(data.get("RECV_CELL_NO")).equals("")){

	                Map<String, String> sdata = new HashMap<String, String>();
	                sdata.put("CONTENTS", "[대명소노시즌] 입찰요청서가 도착했습니다.(" + data.get("RFX_NUM") + ") 빠른 입찰진행 부탁드립니다."); // 전송내용
	                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(data.get("RECV_USER_ID")));	// 받는 사용자ID
	                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(data.get("RECV_USER_NM")));	// 받는사람
	                sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(data.get("RECV_CELL_NO")));	// 받는 사람 전화번호
	                sdata.put("REF_NUM", data.get("RFQ_NUM")); // 참조번호
	                sdata.put("REF_MODULE_CD", "RFP"); // 참조모듈
	                // SMS전송.
	                everSmsService.sendSms(sdata);
	            }

	            // 결과값 등록하기 : COM_ELCT_CONFM_IF의 END_APPROVAL_FLAG=1, END_APPROVAL_DATE=SYSDATE로 변경
	            Map<String, Object> rltMap = new HashMap<>();
	            rltMap.put("ELCT_CONFM_IF_SEQ", data.get("ELCT_CONFM_IF_SEQ"));
	            approvalif_mapper.doUpdateGwApprovalResult(rltMap);
	        }
    	}

    	// 대명소노시즌 구매품의 완료 이후 발주 생성 목록
    	param.put("DM_PCN_KEY", PropertiesManager.getString("eversrm.dm.gw.pcn.key"));
    	List<Map<String, Object>> poTargetList = approvalif_mapper.getPoTargetList(param);

    	int unitCnt = 0;
        for (Map<String, Object> dataInfo : poTargetList) {
        	List<Map<String, Object>> infoTargetList = approvalif_mapper.getInfoTargetCnvd(dataInfo);
        	for(Map<String, Object> data : infoTargetList) {

            	// 임시품목코드 등록
            	if (data.get("ITEM_CD") == null || "".equals(data.get("ITEM_CD"))) {
                    data.put("ITEM_CLS1", PropertiesManager.getString("eversrm.item.imsi.item_cls1")); // 임시 대분류
                    data.put("ITEM_CLS2", PropertiesManager.getString("eversrm.item.imsi.item_cls2")); // 임시 중분류
                    data.put("ITEM_CLS3", PropertiesManager.getString("eversrm.item.imsi.item_cls3")); // 임시 소분류
                    data.put("ITEM_CLS4", PropertiesManager.getString("eversrm.item.imsi.item_cls4")); // 임시 세분류

                    // 임시품목코드 채번(Prefix : IM)
                    String itemCd = docNumService.getDocNumber("IM");
                    data.put("ITEM_CD", itemCd);
                    data.put("IMSI_ITEM_CD", itemCd);
                    approvalif_mapper.createMtgl(data);		// 상품 마스터
                    approvalif_mapper.createMtgc(data);		// 상품 - 분류체계 맵핑
            	}

            	// DGNS I/F 단가생성 (APPLY_PLANT=*)
                String custListStr = EverString.nullToEmptyString(String.valueOf(data.get("APPLY_TARGET_CD")));
                if (!"null".equals(custListStr) && custListStr.length() > 0) {
                    // 단가생성 고객사코드
                	String[] custListArgs = custListStr.split(",");
                    for (int i = 0; i < custListArgs.length; i++) {
                    	// 단가적용 고객사코드(공통인 경우 7개 ELSE 1개)
                    	data.put("APPLY_COM", custListArgs[i]);

                    	// 기존 유효한 단가 만료처리로직 추가
		            	if( (data.get("ITEM_CD") != null && !"".equals(data.get("ITEM_CD"))) && (data.get("IMSI_ITEM_CD") == null || "".equals(data.get("IMSI_ITEM_CD"))) ) {
		    	            approvalif_mapper.updateValidTodateYInfo(data);
		            	}

                    	// 단가 생성
		            	String contNum = docNumService.getDocNumber("CT");
			            data.put("CONT_NO", contNum);
			            data.put("CONT_SEQ", "1");

			            // 매입단가 생성
			            approvalif_mapper.createStoYInfh(data);
		            	approvalif_mapper.createStoYInfo(data);

		            	// 매출단가 생성
		            	approvalif_mapper.createStoUInfh(data);
		            	approvalif_mapper.createStoUInfo(data);

		            	// 품의상세(STOPCNDT)의 계약정보 UPDATE
		            	approvalif_mapper.doUpdateContInfoCNDT(data);

		                // T : I/F 대상, S : 성공, E : 실패
	    	            // (DGNS I/F) : 고객사 판매단가 등록
	    	            //=======================================================================================
		            	String erpIfFlag = approvalif_mapper.getCustErpIfFlag(data);
		                if( data.get("CUST_ITEM_CD") != null && !"".equals(data.get("CUST_ITEM_CD")) && "1".equals(erpIfFlag) ) {
		    	            Map<String, String> ifData = new HashMap<String, String>();
		    	            ifData.put("CUST_ITEM_CD", String.valueOf(data.get("CUST_ITEM_CD")));	// 고객사 상품코드
	            			ifData.put("USE_FLAG", "1");
	            			realtimeif_mapper.updateItemUseFlag(ifData);	// DGNS 품목마스터(PUA_MTRL_CD)의 USE_YN=1 처리함

	            			// 매입단가가 유효한 경우에만 단가 i/f
	            			if( data.get("UNIT_IF_FLAG") != null && "1".equals(data.get("UNIT_IF_FLAG")) ) {
	            				BigDecimal SALES_UNIT_PRC =(BigDecimal) data.get("SALES_UNIT_PRC");
	            				SALES_UNIT_PRC = SALES_UNIT_PRC ==null ? BigDecimal.ZERO : SALES_UNIT_PRC;
	            				ifData.put("COMPANY_CODE"	, String.valueOf(data.get("APPLY_COM")));		// 단가적용 고객사
			    	            ifData.put("DIVISION_CODE"	, String.valueOf(data.get("APPLY_PLANT")));	// 단가적용 사업장
			    	            ifData.put("UNIT_PRICE"		, String.valueOf(SALES_UNIT_PRC));	// 고객사 판매단가
			    	            realtimeif_service.insCustUinfo(ifData);		// 품목정보 i/f 테이블 등록(ICOYITEM_IF)

			    	            //판매단가 DGNS I/F 여부 세팅(ERP_IF_SEND_FLAG)
		                		im0301Mapper.updateDgnsIfFlag(data);
	            			}
		                }
	    	            //=======================================================================================

	    	            unitCnt++;
                    }
                }
        	}
        	
        	//2. 발주 생성 (임시품목은 임시품목코드 채번 후 발주 생성)
            List<Map<String, Object>> poList = approvalif_mapper.getPoTargetCnvd(dataInfo);
            for(Map<String, Object> data : poList) {
            	// 발주정보 생성
            	String poNum = docNumService.getDocNumber("PO");
	            data.put("PO_NO", poNum);

	            approvalif_mapper.createPohd(data);		// 발주 Header
	            approvalif_mapper.createPodt(data);		// 발주 Detail

            	/**
	            // 직발주(200)
	            if (data.get("DEAL_CD") != null && "200".equals(data.get("DEAL_CD"))) {
		        	String poNum = docNumService.getDocNumber("PO");
		            data.put("PO_NUM", poNum);

		            approvalif_mapper.createPohd(data);		// 발주 Header
		            approvalif_mapper.createPodt(data);		// 발주 Detail
	            }// 매입(100), VMI(400)
	            else {
	            	String poNum = docNumService.getDocNumber("PO");
		            data.put("PO_NUM", poNum);

		            approvalif_mapper.createDohd(data);		// 납입지시 Header
		            approvalif_mapper.createDodt(data);		// 납입지시 Detail
	            }*/

	            // STOUPDT 진행상태 업데이트
	            data.put("PROGRESS_CD_M", "5100");	// 발주대기
	            approvalif_mapper.doReqConfirmUpo(data);

            }

        	// 결과값 등록하기 : COM_ELCT_CONFM_IF의 END_APPROVAL_FLAG=1, END_APPROVAL_DATE=SYSDATE로 변경
            approvalif_mapper.doUpdateGwApprovalResult(dataInfo);

        }

        return "[발주대상: " + (poTargetList==null?0:poTargetList.size()) + "건, 단가생성대상: " + unitCnt + "건] " + msg.getMessage("0001");
    }

}
