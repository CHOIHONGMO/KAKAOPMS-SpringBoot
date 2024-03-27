package com.st_ones.batch.invoiceDelayIf.service;

import com.st_ones.batch.invoiceDelayIf.InvoiceDelayIfMapper;
import com.st_ones.common.mail.service.EverMailService;
import com.st_ones.common.message.service.MessageService;
import com.st_ones.common.util.clazz.EverFile;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.clazz.AuthorityIgnore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service(value = "InvoiceDelayIFService")
public class InvoiceDelayIfService {

	@Autowired private MessageService msg;

	@Autowired private InvoiceDelayIfMapper invoiceDelayIfMapper;
	@Autowired private EverMailService everMailService;
	
	// EMAIL 보내기
	@AuthorityIgnore
	public String doAlarmInvoiceDelay(Map<String, String> param) throws Exception {
		
        // Mail Template 및 URL 가져오기
        String templatePath   = PropertiesManager.getString("eversrm.system.mailTemplatePath");
        String templateFileNm = templatePath + PropertiesManager.getString("eversrm.system.IV_DELAY_TemplateFileName");
		
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
        List<Map<String, Object>> ctrlUserList = invoiceDelayIfMapper.getInvoiceDelayList(param);
        for( Map<String, Object> rowData : ctrlUserList ){
            // 운영사 품목담당자에게 mail 발송하기
        	if( !rowData.get("OPER_EMAIL").equals("") ){
        		fileContents   = EverFile.fileReadByOffsetByEncoding(templateFileNm, "UTF-8");
        		fileContents = EverString.replace(fileContents, "$CURRENT_DATE$", EverString.nullToEmptyString(rowData.get("CUR_DATE"))); // 현재일자
	        	fileContents = EverString.replace(fileContents, "$USER_NM$", EverString.nullToEmptyString(rowData.get("OPER_USER_NM"))); // 주문번호
	            fileContents = EverString.replace(fileContents, "$MAIN_TEL_NUM$", PropertiesManager.getString("eversrm.system.sms.default.telNo")); // 대표전화번호
	            
	            String tblBody = "<tbody>";
	            String enter = "\n";
	            // 운영사 품목담당자별 납품지연 주문정보 가져오기
	            param.put("OPER_USER_ID", rowData.get("OPER_USER_ID").toString());
	            List<Map<String, Object>> itemList = invoiceDelayIfMapper.getInvoiceDelayItemList(param);
	            if( itemList.size() > 0 ){
	                for( Map<String, Object> itemData : itemList ){
	                    String tblRow = "<tr>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>[" + EverString.nullToEmptyString(itemData.get("CUST_CD")) + "] " + EverString.nullToEmptyString(itemData.get("CUST_NM")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_NO")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("CPO_USER_NM")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("PO_NO")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:center;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>" + EverString.nullToEmptyString(itemData.get("HOPE_DUE_DATE")) + "</th>"
	                            + enter + "<td style='word-break:break-all;padding:5px 6px 6px 6px;color:#404141;text-align:left;font-size:12px;border-left:1px solid #cdcdcd;border-right:1px solid #cdcdcd;border-bottom:1px solid #cdcdcd'>[" + EverString.nullToEmptyString(itemData.get("VENDOR_CD")) + "] " + EverString.nullToEmptyString(itemData.get("VENDOR_NM")) + "</th>"
	                            + enter + "</tr>";
	                    tblBody += tblRow;
	                }
	            }
	            fileContents = EverString.replace(fileContents, "$tblBody$", tblBody);
	            fileContents = EverString.replace(fileContents, "$maintainUrl$", maintainUrl);
	            fileContents = EverString.rePreventSqlInjection(fileContents);
	            
	            Map<String, String> mdata = new HashMap<String, String>();
	            mdata.put("SUBJECT", "[대명소노시즌] 금일(" + EverString.nullToEmptyString(rowData.get("CUR_DATE")) + ")부로 납품이 지연(D+1)되는 주문건이 있습니다.");
	            mdata.put("CONTENTS_TEMPLATE", fileContents);
	            mdata.put("RECV_USER_ID", EverString.nullToEmptyString(rowData.get("OPER_USER_ID")));
	            mdata.put("RECV_USER_NM", EverString.nullToEmptyString(rowData.get("OPER_USER_NM")));
	            mdata.put("RECV_EMAIL", EverString.nullToEmptyString(rowData.get("OPER_EMAIL")));
	            mdata.put("REF_NUM", "");
	            mdata.put("REF_MODULE_CD", "PO"); // 참조모듈
				// SMS 발송
				everMailService.sendMail(mdata);
				mdata.clear();
        	}
        }
        return msg.getMessage("0001");
	}

}
