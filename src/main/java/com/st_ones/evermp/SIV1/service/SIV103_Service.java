package com.st_ones.evermp.SIV1.service;

import com.st_ones.common.generator.service.QueryGenService;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import com.st_ones.evermp.SIV1.SIV101_Mapper;
import com.st_ones.evermp.SIV1.SIV103_Mapper;
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
 * @File Name : SIV103_Service.java
 * @author  최홍모
 * @date 2018. 09. 04.
 * @version 1.0
 * @see
 */

@Service(value = "siv103_Service")
public class SIV103_Service extends BaseService {

	@Autowired
	SIV103_Mapper siv103_Mapper;

	@Autowired
	SIV101_Mapper siv101_Mapper;

	@Autowired
	private QueryGenService queryGenService;

	@Autowired
	MessageService msg;

	@Autowired
	private EverMailService everMailService;

	@Autowired
    private EverSmsService everSmsService;

	/** ******************************************************************************************
     * 공급사 : 납품서 조회/수정
     * @param req
     * @return
     * @throws Exception
     */
	public List<Map<String, Object>> siv1030_doSearch(Map<String, String> param) throws Exception {
		Map<String, String> sParam = new HashMap<String, String>();
        if(!EverString.nullToEmptyString(param.get("ITEM_DESC")).trim().equals("")) {
            sParam.put("COL_VAL", param.get("ITEM_DESC"));
            sParam.put("COL_NM", "YPODT.ITEM_DESC");
            param.put("ITEM_DESC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
            sParam.put("COL_NM", "YPODT.ITEM_SPEC");
            param.put("ITEM_SPEC", EverString.nullToEmptyString(queryGenService.generateSearchCondition(sParam)));
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

		if(EverString.isNotEmpty(param.get("ITEM_CD"))) {
			param.put("ITEM_CD_ORG", param.get("ITEM_CD"));
			param.put("ITEM_CD", EverString.forInQuery(param.get("ITEM_CD"), ","));
			param.put("ITEM_CNT", param.get("ITEM_CD").contains(",") ? "1" : "0");
		}

		return siv103_Mapper.siv1030_doSearch(param);
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1030_doSave2(List<Map<String, Object>> gridList) throws Exception {

		// 2. IVDT 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUIVDT2(gridData);
			// STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYIVDT2(gridData);
		}

		return msg.getMessage("0001");

	}


	// 공급사 납품서 수정
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1030_doSave(List<Map<String, Object>> gridList) throws Exception {

		// 1. IVHD 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUIVHD(gridData);
			// STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYIVHD(gridData);
		}

		// 2. IVDT 업데이트
		for( Map<String, Object> gridData : gridList ) {
			// STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUIVDT(gridData);
			// STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYIVDT(gridData);

			int chkGrCount = siv103_Mapper.chkGrdt(gridData);
			if(chkGrCount != 0) {
				throw new Exception("입고가 진행된건 입니다. 다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}
		}

		// 3. PODT 업데이트
		boolean isChangeFlag = false;
		String cpoNo = "";
		Map<String, Object> ivSeqMap = null;
		List<Map<String, Object>> ivSeqList = new ArrayList<Map<String, Object>>();
		for( Map<String, Object> gridData : gridList ) {
			// 3-1. STOU 업데이트
			siv103_Mapper.siv1030_doUpdateUPODT(gridData);
			// 3-2. STOY 업데이트
			siv103_Mapper.siv1030_doUpdateYPODT(gridData);

			Map<String, Object> checkMap = siv101_Mapper.getPoQtySumInvQty(gridData);
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
				ivSeqMap.put("IV_NO_SEQ", String.valueOf(gridData.get("IV_NO")) + String.valueOf(gridData.get("IV_SEQ")));
				ivSeqList.add(ivSeqMap);
			}
		}

		// EMAIL 및 SMS 발송
		/*try {
			if( !"".equals(cpoNo) && isChangeFlag ){
				Map<String, Object> mailParam = new HashMap<String, Object>();
				mailParam.put("CPO_NO", cpoNo);
				mailParam.put("ivSeqList", ivSeqList);
				sendEmailNSms(mailParam);
			}
		} catch ( Exception ex ){
			System.out.println("=====> 납품서 변경(SIV1_030) EMAIL, SMS 발송 오류 : " + ex);
		}
		 2022 12 22 납품일자변경시 메일 발송 삭제 */
		return msg.getMessage("0001");
	}

	// 공급사 납품서 삭제
	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String siv1030_doDelete(List<Map<String, Object>> gridList) throws Exception {

		for( Map<String, Object> gridData : gridList ) {
			
			// 납품완료건은 삭제 안됨
			int chkCount = siv103_Mapper.chkUivdt(gridData);
			if(chkCount > 0) {
				throw new Exception("납품이 완료된 건은 납품서 등록을 취소할 수 없습니다.");
			}
			
			// 입고 진행된 건은 삭제 안됨
			int chkGrCount = siv103_Mapper.chkGrdt(gridData);
			if(chkGrCount > 0) {
				throw new Exception("이미 입고가 진행된 건은 납품서 등록을 취소할 수 없습니다.");
			}

			// 1. IVDT 삭제
			siv103_Mapper.siv1030_doDeleteUIVDT(gridData);
			siv103_Mapper.siv1030_doDeleteYIVDT(gridData);
			// 2. PODT 업데이트
			siv103_Mapper.siv1030_doDeleteUPODT(gridData);
			siv103_Mapper.siv1030_doDeleteYPODT(gridData);

			Map<String, Object> checkMap = siv101_Mapper.getPoQtySumInvQty(gridData);
			double podtInvQty = Double.parseDouble(String.valueOf(checkMap.get("PODT_INV_QTY")));
			if(podtInvQty < 0) {
				throw new Exception("다시 조회하여 처리하시기 바랍니다. 주문번호 : " + gridData.get("CPO_NO") + ", 품목코드 : " + gridData.get("ITEM_CD"));
			}
		}

		return msg.getMessage("0001");
	}

	// 납품서 납기일 변경 : EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public void sendEmailNSms(Map<String, Object> param) throws Exception {

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

		// 주문헤더(UPOHD) 가져오기
        Map<String, Object> cpoUserInfo = siv103_Mapper.getInvChangeHeaderInfo(param);
        // 고객사 주문자에게 EMAIL 전송
        String fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        fileContents = EverString.replace(fileContents, "$CPO_NO$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO"))); // 주문번호
        fileContents = EverString.replace(fileContents, "$CPO_DATE$", EverString.nullToEmptyString(cpoUserInfo.get("CPO_DATE"))); // 주문일자
        fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM"))); // 주문자명
        fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호

        String tblBody = "<tbody>";
        String enter = "\n";
        // 주문품목(UPODT) 가져오기
        List<Map<String, Object>> itemList = siv103_Mapper.getInvChangeDetailInfo(param);
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
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("BRAND_NM")) + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</td>"
                        + enter + "</tr>"
                        + enter + "<tr>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + itemSpec + "</td>"
                        + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("MAKER_PART_NO")) + "</td>"
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
            mdata.put("SEND_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_ID")));
            mdata.put("SEND_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("OPER_USER_NM")));
            mdata.put("SEND_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("OPER_EMAIL")));
            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_ID")));
            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(cpoUserInfo.get("CUST_USER_NM")));
            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(cpoUserInfo.get("CUST_EMAIL")));
            mdata.put("REF_NUM", EverString.nullToEmptyString(cpoUserInfo.get("CPO_NO")));
            mdata.put("REF_MODULE_CD","IV"); // 참조모듈
            // Mail 발송처리.
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
			// SMS 발송처리.
			everSmsService.sendSms(hdata);
			hdata.clear();
        }
	}
}
