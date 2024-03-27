package com.st_ones.evermp.OD02.service;

import com.st_ones.batch.realtimeIf.RealtimeIF_Mapper;
import com.st_ones.batch.realtimeIf.service.RealtimeIF_Service;
import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.evermp.OD02.OD0204_Mapper;
import com.st_ones.evermp.OD02.OD0205_Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service(value = "OD0205_Service")
public class OD0205_Service extends BaseService {

	@Autowired
	OD0205_Mapper od0205_Mapper;

	@Autowired
	OD0204_Mapper od0204_Mapper;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	private RealtimeIF_Service realtimeifService;

	@Autowired
	private RealtimeIF_Mapper realtimeifMapper;

	@Autowired
	MessageService msg;

	@Autowired
	private EverMailService everMailService;

	@Autowired
    private EverSmsService everSmsService;


	/** ******************************************************************************************
     * 재고관리 > 출하관리 > 출하 진행현황 (OD02_050)
     * @param param
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> od02050_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "YPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "YPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.ITEM_CD");
			param.put("ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
			sParam.put("COL_NM", "YPODT.CUST_ITEM_CD");
			param.put("CUST_ITEM_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
        }
        if(!EverString.nullToEmptyString(param.get("MAKER_CD")).trim().equals("")) {
			param.put("COL_NM", "YPODT.MAKER_CD");
			param.put("COL_VAL", param.get("MAKER_CD"));
			param.put("MAKER_CD", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}
		if(!EverString.nullToEmptyString(param.get("MAKER_NM")).trim().equals("")) {
			param.put("COL_NM", "YPODT.MAKER_NM");
			param.put("COL_VAL", param.get("MAKER_NM"));
			param.put("MAKER_NM", EverString.nullToEmptyString(queryGenService.generateSearchCondition(param)));
		}

		if(EverString.isNotEmpty(param.get("DOC_NUM"))) {
			param.put("DOC_NUM_ORG", param.get("DOC_NUM"));
			param.put("DOC_NUM", EverString.forInQuery(param.get("DOC_NUM"), ","));
			param.put("DOC_CNT", param.get("DOC_NUM").contains(",") ? "1" : "0");
		}
		return od0205_Mapper.od0205_doSearch(param);
	}

	/**
	 * 재고관리 > 출하관리 > 출하 진행현황 (OD02_050): 출하완료
	 * @param gridList
	 * @return
	 * @throws Exception
	 */
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od02050_doCompleteDely(List<Map<String, Object>> gridList) throws Exception {
		Map<String, String> ifMap = new HashMap<>();
		for( Map<String, Object> gridData : gridList ) {
			od0205_Mapper.OD0205_doCompleteUIVDT(gridData);

			if(gridData.get("IF_CPO_NO_SEQ").toString().length() < 2 ) {
				continue;
			}
			ifMap.put(String.valueOf(gridData.get("INV_NO")), "*");
		}

		// ================ 납품완료시 DGNS I/F 데이터 등록 =============== //
		Set set = ifMap.keySet();
		if(set != null && set.size() > 0) {
			realtimeifService.regDgnsInvoice(ifMap);
		}
		// ================ 납품완료시 DGNS I/F 데이터 등록 =============== //
		return msg.getMessage("0001");
	}


	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od02050_doCancelDely(List<Map<String, Object>> gridList) throws Exception {

		String rtnMsg = "";
		for( Map<String, Object> gridData : gridList ) {


			String chk = od0205_Mapper.chkIV(gridData); // 출하확정 체크

			if("Y".equals(chk)) {
				rtnMsg += gridData.get("PO_NO")+"-"+gridData.get("PO_SEQ")+"\n";
				continue;
			}





			if(gridData.get("IF_CPO_NO_SEQ").toString().length() < 2 ) {
				od0205_Mapper.OD0205_doCancelUIVDT(gridData); // 고객사 납품상세
			} else {
				// ==================== DGNS I/F 데이터 삭제 ========================== //
				//2023.01.27추가: 납품완료 취소시 IF_FLAG='2'인 경우 납품완료취소(IF테이블삭제) 가능
				int checkCnt = realtimeifMapper.checkDgnsInvoice(gridData);
				if( checkCnt > 0) {
					realtimeifMapper.delDgnsInvoiceHD(gridData);	// IF 납품서 삭제
					realtimeifMapper.delDgnsInvoiceDT(gridData);	// IF 납품서 삭제

					od0205_Mapper.OD0205_doCancelUIVDT(gridData); 	// 고객사 납품상세
				} else {
					rtnMsg += gridData.get("PO_NO")+"-"+gridData.get("PO_SEQ")+"\n";
				}
				// ==================== DGNS I/F 데이터 삭제 ========================== //
			}
		}
		if( !"".equals(rtnMsg) ) {
			rtnMsg += "위 출하번호는 취소할 수 없습니다. DGNS 납품상태 및 출하확정여부를 확인하세요.";
		}

		return msg.getMessage("0001") + ((!"".equals(rtnMsg))?"\n":"") + rtnMsg;
	}


	// 운영사 납품서 수정
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od02050_doSave(List<Map<String, Object>> gridList) throws Exception {

		// 1. IVHD 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			od0205_Mapper.od0205_doUpdateUIVHD(gridData);
		}

		// 2. IVDT 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			od0205_Mapper.od0205_doUpdateUIVDT(gridData);
			od0205_Mapper.od0205_doUpdateMMRS(gridData);

			int chkGrCount = od0205_Mapper.chkGidt(gridData);
			if(chkGrCount != 0) {
				throw new Exception("이미 출고가 진행된건 입니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}
		}

		// 3. PODT 업데이트
		boolean isChangeFlag = false;
		String cpoNo = "";
		Map<String, Object> ivSeqMap = null;
		List<Map<String, Object>> ivSeqList = new ArrayList<Map<String, Object>>();
		for( Map<String, Object> gridData : gridList ) {
			// 3-1. STOUPODT 업데이트
			od0205_Mapper.od0205_doUpdateUPODT(gridData);
			// 3-2. STOYPODT 업데이트
			od0205_Mapper.od0205_doUpdateYPODT(gridData);

			Map<String, Object> checkMap = od0204_Mapper.getPoQtySumInvQty(gridData);
			double poQty = Double.parseDouble(String.valueOf(checkMap.get("PO_QTY")));
			double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));
			if(poQty < podtInvQty) {
				throw new Exception("납품수량이 발주수량을 초과하여 처리할 수 없습니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}

			// 납품예정일이 변경되는 경우에만 메일 발송
			if( gridData.get("DELY_APP_DATE") != gridData.get("DELY_APP_DATE_RES") ){
				isChangeFlag = true;
				cpoNo = gridData.get("CPO_NO").toString();

				ivSeqMap = new HashMap<String, Object>();
				ivSeqMap.put("INV_NO_SEQ", String.valueOf(gridData.get("INV_NO")) + String.valueOf(gridData.get("INV_SEQ")));
				ivSeqList.add(ivSeqMap);
			}
		}

		// 납품서 변경 EMAIL 및 SMS 발송
	/*	try {
			if( !"".equals(cpoNo) && isChangeFlag ){
				Map<String, Object> mailParam = new HashMap<String, Object>();
				mailParam.put("CPO_NO", cpoNo);
				mailParam.put("ivSeqList", ivSeqList);
				sendEmailNSms_Change(mailParam);
			}
		} catch ( Exception ex ){
			System.out.println("=====>  출하 진행현황(OD02_050) EMAIL, SMS 발송 오류 : " + ex);
		}
		 2022 12 22 납품일 변경시 메일 발송 삭제*/
		return msg.getMessage("0001");
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String od02050_doDelete(List<Map<String, Object>> gridList) throws Exception {

		for( Map<String, Object> gridData : gridList ) {

			int chkCount = od0205_Mapper.chkUivdt(gridData);
			if(chkCount == 0) continue;

			int chkGrCount = od0205_Mapper.chkGidt(gridData);
			if(chkGrCount != 0) {
				throw new Exception("이미 출고가 진행된 건입니다.");
			}

			od0205_Mapper.od0205_doDeleteUIVDT(gridData);
			od0205_Mapper.od0205_doDeleteUPODT(gridData);
			od0205_Mapper.od0205_doDeleteYPODT(gridData);
			od0205_Mapper.od0205_doDeleteIMMRS(gridData); //수불 삭제

			Map<String, Object> checkMap = od0204_Mapper.getPoQtySumInvQty(gridData);
			double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));
			if(podtInvQty < 0) {
				throw new Exception("다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}
		}

		return msg.getMessage("0001");
	}

	@AuthorityIgnore
	public void sendEmailNSms_Change(Map<String, Object> param) throws Exception {

        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_CHNG_TemplateFileName");

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

		String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
		// 주문헤더(UPOHD) 가져오기
        Map<String, Object> cpoUserInfo = od0205_Mapper.getInvChangeHeaderInfo(param);
        // 고객사 주문자에게 EMAIL 전송
        fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 주문번호
        fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_DATE"))); // 주문일자
        fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 주문자명
        fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

        String tblBody = "<tbody>";
        String enter = "\n";
        // 주문품목(UPODT) 가져오기
        List<Map<String, Object>> itemList = od0205_Mapper.getInvChangeDetailInfo(param);
        if( itemList.size() > 0 ){
            for( Map<String, Object> itemData : itemList ){
                // 품목명
            	String itemDesc = (String)itemData.get("ITEM_DESC");
                if(itemDesc.length() > 29) { itemDesc = itemDesc.substring(0, 30) + "..."; }
                // 품목규격
                String itemSpec = (String)itemData.get("ITEM_SPEC");
                if(itemSpec.length() > 29) { itemSpec = itemSpec.substring(0, 30) + "..."; }

                // 품목리스트
                String tblRow = "<tr>"
                		+ enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd' rowspan='2'>" + EverString.nullToEmptyString(itemData.get("ITEM_CD")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemDesc + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
                        + enter + "</tr>"
                        + enter + "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("DELY_DELAY_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("DELY_APP_DATE")) + "</td>"
                        + enter + "</tr>";
                tblBody += tblRow;
            }
        }

        fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
        fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
        fileContents = EverString.rePreventSqlInjection(fileContents);

        // 운영사 진행관리담당자 -> 고객사 주문자
    	if( !"".equals(cpoUserInfo.get("CUST_EMAIL")) ){
            Map<String, String> mdata = new HashMap<String, String>();
            mdata.put("SUBJECT", "[대명소노시즌] 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납기일이 변경되었습니다.");
            mdata.put("CONTENTS_TEMPLATE", fileContents);
            mdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 주문자
            mdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM")));
            mdata.put("SEND_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("OPER_EMAIL")));
            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID")));
            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM")));
            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("CUST_EMAIL")));
            mdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")));
            mdata.put("REF_MODULE_CD","IV"); // 참조모듈
			// 메일발송
			everMailService.sendMail(mdata);
			mdata.clear();
        }

    	// 운영사 진행관리담당자 -> 고객사 주문자
        if( !"".equals(cpoUserInfo.get("CUST_CELL_NUM")) ){
            Map<String, String> hdata = new HashMap<String, String>();
            hdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))+"님. 주문번호("+EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))+")의 납기일이 변경되었습니다. 확인바랍니다."); // 전송내용
            hdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID"))); // 보내는 사용자ID(운영사 품목담당자)
            hdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM"))); // 보내는사람(운영사 품목담당자)
            hdata.put("SEND_TEL_NUM", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 보내는 사람 전화번호(대표전화번호)
            hdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID"))); // 받는 사용자ID(고객사 주문자)
            hdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 받는사람(고객사 주문자)
            hdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_CELL_NUM"))); // 받는 사람 전화번호(고객사 주문자)
            hdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 참조번호
            hdata.put("REF_MODULE_CD","IV"); // 참조모듈
			// SMS 발송
			everSmsService.sendSms(hdata);
			hdata.clear();
        }
	}


}

