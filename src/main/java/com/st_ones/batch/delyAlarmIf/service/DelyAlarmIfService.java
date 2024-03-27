package com.st_ones.batch.delyAlarmIf.service;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 18. 7. 25 오전 11:12
 */

import com.st_ones.batch.delyAlarmIf.DelyAlarmIfMapper;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.sms.service.EverSmsService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "DelyAlarmIfService")
public class DelyAlarmIfService {

	@Autowired private MessageService msg;
	@Autowired private DelyAlarmIfMapper delyAlarmIfMapper;
	@Autowired private EverMailService everMailService;
	@Autowired private EverSmsService everSmsService;
	
	// D-1일 공급사에게 EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public String doAlarmInvoiceInfo(Map<String, String> param) throws Exception {
		
		// Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_DELY_TemplateFileName");
		
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
		
        // 납품지연 주문의 운영사 품목담당자 가져오기
        String fileContents = "";
        List<Map<String, Object>> headerList = delyAlarmIfMapper.getInvoiceHeaderList(param);
        for( Map<String, Object> rowData : headerList ){
            // 공급사 납품담당자에게 mail 발송하기
        	if( !rowData.get("VEND_EMAIL").equals("") ){
        		fileContents = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        		fileContents = EverString.replace(fileContents, "$CURRENT_DATE$", EverString.nullToEmptyString(rowData.get("CUR_DATE"))); // 현재일자
	        	fileContents = EverString.replace(fileContents, "$VENDOR_NM$", EverString.nullToEmptyString(rowData.get("VENDOR_NM"))); // 공급사명
	            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
	            
	            String tblBody = "<tbody>";
	            String enter = "\n";
	            // 공급사별, 품목담당자별 납품예정 주문정보 가져오기
	            param.put("VENDOR_CD", rowData.get("VENDOR_CD").toString());
	            List<Map<String, Object>> itemList = delyAlarmIfMapper.getInvoiceItemList(param);
	            if( itemList.size() > 0 ){
	                for( Map<String, Object> itemData : itemList ){
	                    String tblRow = "<tr>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CUST_NM")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_NO")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_USER_NM")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_DATE")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("PO_NO")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</th>"
	                            + enter + "</tr>";
	                    tblBody += tblRow;
	                }
	            }
	            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
	            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
	            fileContents = EverString.rePreventSqlInjection(fileContents);
	            
	            Map<String, String> mdata = new HashMap<String, String>();
	            mdata.put("SUBJECT", "[대명소노시즌] (" + EverString.nullToEmptyString(rowData.get("CUR_DATE")) + ") 일부로 납기일정이 D-1일 남은 주문건이 존재합니다.");
	            mdata.put("CONTENTS_TEMPLATE", fileContents);
	            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VEND_USER_ID"))); // 공급사 납품담당자
	            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VEND_USER_NM")));
	            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(rowData.get("VEND_EMAIL")));
	            mdata.put("REF_NUM", "");
	            mdata.put("REF_MODULE_CD", "IV"); // 참조모듈
				// Mail 발송
				everMailService.sendMail(mdata);
				mdata.clear();
        	}
        	
        	// SMS 전송
            if( !rowData.get("VEND_CELL_NUM").equals("") ){
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("CONTENTS", "[대명소노시즌] " + EverString.nullToEmptyString(rowData.get("VENDOR_NM")) + "님. " + EverString.nullToEmptyString(rowData.get("CUR_DATE")) + " 일부로 납품예정인 주문건이 존재합니다."); // 전송내용
                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VEND_USER_ID"))); // 받는 사용자ID
                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VEND_USER_NM"))); // 받는사람
                sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(rowData.get("VEND_CELL_NUM"))); // 받는 사람 전화번호
                sdata.put("REF_NUM", ""); // 참조번호
                sdata.put("REF_MODULE_CD", "IV"); // 참조모듈
				// SMS 전송
				everSmsService.sendSms(sdata);
				sdata.clear();
            }
        }
        return msg.getMessage("0001");
	}
	
	// D+0일 공급사에게 EMAIL 및 SMS 보내기
	@AuthorityIgnore
	public String doAlarmCurInvoiceInfo(Map<String, String> param) throws Exception {
		
        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.CUR_IV_DELY_TemplateFileName");
		
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
        
        // 납품지연 주문의 운영사 품목담당자 가져오기
        String fileContents   = "";
        List<Map<String, Object>> headerList = delyAlarmIfMapper.getCurInvoiceHeaderList(param);
        for( Map<String, Object> rowData : headerList ){
            // 공급사 납품담당자에게 mail 발송하기
        	if( !rowData.get("VEND_EMAIL").equals("") ){
        		fileContents   = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        		fileContents = EverString.replace(fileContents, "$CURRENT_DATE$", EverString.nullToEmptyString(rowData.get("CUR_DATE"))); // 현재일자
	        	fileContents = EverString.replace(fileContents, "$VENDOR_NM$", EverString.nullToEmptyString(rowData.get("VENDOR_NM"))); // 공급사명
	            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
	            
	            String tblBody = "<tbody>";
	            String enter = "\n";
	            // 공급사별, 품목담당자별 납품예정 주문정보 가져오기
	            param.put("VENDOR_CD", rowData.get("VENDOR_CD").toString());
	            List<Map<String, Object>> itemList = delyAlarmIfMapper.getCurInvoiceItemList(param);
	            if( itemList.size() > 0 ){
	                for( Map<String, Object> itemData : itemList ){
	                    String tblRow = "<tr>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CUST_NM")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_NO")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_USER_NM")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_DATE")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("PO_NO")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</th>"
	                            + enter + "</tr>";
	                    tblBody += tblRow;
	                }
	            }
	            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
	            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
	            fileContents = EverString.rePreventSqlInjection(fileContents);
	            
	            Map<String, String> mdata = new HashMap<String, String>();
	            mdata.put("SUBJECT", "[대명소노시즌] 금일(" + EverString.nullToEmptyString(rowData.get("CUR_DATE")) + ")까지 납품해야 하는 주문건이 존재합니다.");
	            mdata.put("CONTENTS_TEMPLATE", fileContents);
	            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VEND_USER_ID"))); // 공급사 납품담당자
	            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VEND_USER_NM")));
	            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(rowData.get("VEND_EMAIL")));
	            mdata.put("REF_NUM", "");
	            mdata.put("REF_MODULE_CD", "IV"); // 참조모듈
	            // Mail 발송
				everMailService.sendMail(mdata);
        	}
        	
        	// SMS 전송
            if( !rowData.get("VEND_CELL_NUM").equals("") ){
                Map<String, String> sdata = new HashMap<String, String>();
                sdata.put("CONTENTS", "[대명소노시즌] "+EverString.nullToEmptyString(rowData.get("VENDOR_NM"))+"님. 금일 납품해야 하는 주문건이 존재합니다. 확인하시기 바랍니다."); // 전송내용
                sdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("VEND_USER_ID"))); // 받는 사용자ID
                sdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("VEND_USER_NM"))); // 받는사람
                sdata.put("RECV_TEL_NUM", EverString.nullToEmptyString(rowData.get("VEND_CELL_NUM"))); // 받는 사람 전화번호
                sdata.put("REF_NUM", ""); // 참조번호
                sdata.put("REF_MODULE_CD", "IV"); // 참조모듈
				// SMS 발송
				everSmsService.sendSms(sdata);
            }
        }
        return msg.getMessage("0001");
	}

}
