<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
    	var addParam = [];
    	var baseUrl = "/common/mail/";

		function init() {

        }

		function send() {
        	if (!confirm("${msg.M0060 }")) return;
	        var store = new EVF.Store();
        	store.load(baseUrl + 'doSend', function(){
        		alert(this.getResponseMessage());
        	});
        }            
        
         function sendAll() {
         	if (!confirm("${msg.M0060 }")) return;
 	        var store = new EVF.Store();
         	store.load(baseUrl + 'doSendAll', function(){
         		alert(this.getResponseMessage());
         	});
         }

         function openContentsPopup() {
         	var param = {
 					  havePermission : true
 					, callBackFunction : 'setTextContents'
 				};

 			everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
         }

         function setTextContents(contents) {
         	alert(contents);	
         }

    </script>
    <e:window id="SAM_027" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
         <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSend" name="doSend" label="${doSend_N }" disabled="${doSend_D }" onClick="send" />
            <e:button id="doSendAll" name="doSendAll" label="${doSendAll_N }" disabled="${doSendAll_D }" onClick="sendAll" />
            <e:button id="openContentsPopup" name="openContentsPopup" label="Contents Common Popup" disabled="false" onClick="openContentsPopup" />
        </e:buttonBar>
    
    
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="180" width="100%" columnCount="2">
           <e:row>
					<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
					<e:field>
					<e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
					 </e:field>
					<e:label for="CONTENTS" title="${form_CONTENTS_N}"/>
					<e:field>
					<e:inputText id="CONTENTS" name="CONTENTS" value="${form.CONTENTS}" width="100%" maxLength="${form_CONTENTS_M}" disabled="${form_CONTENTS_D}" readOnly="${form_CONTENTS_RO}" required="${form_CONTENTS_R}" />
					 </e:field>
					 
					 
					 
					<e:inputHidden id="INTERFACE_TYPE" name="INTERFACE_TYPE" value="MAP" width="100%" />
					 
					 
					 
 			</e:row>
           <e:row>
					<e:label for="SENDER_NM" title="${form_SENDER_NM_N}"/>
					<e:field>
					<e:inputText id="SENDER_NM" name="SENDER_NM" value="${form.SENDER_NM}" width="100%" maxLength="${form_SENDER_NM_M}" disabled="${form_SENDER_NM_D}" readOnly="${form_SENDER_NM_RO}" required="${form_SENDER_NM_R}" />
					 </e:field>
					<e:label for="SENDER_EMAIL" title="${form_SENDER_EMAIL_N}"/>
					<e:field>
					<e:inputText id="SENDER_EMAIL" name="SENDER_EMAIL" value="${form.SENDER_EMAIL}" width="100%" maxLength="${form_SENDER_EMAIL_M}" disabled="${form_SENDER_EMAIL_D}" readOnly="${form_SENDER_EMAIL_RO}" required="${form_SENDER_EMAIL_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="SENDER_USER_ID" title="${form_SENDER_USER_ID_N}"/>
					<e:field>
					<e:inputText id="SENDER_USER_ID" name="SENDER_USER_ID" value="${form.SENDER_USER_ID}" width="100%" maxLength="${form_SENDER_USER_ID_M}" disabled="${form_SENDER_USER_ID_D}" readOnly="${form_SENDER_USER_ID_RO}" required="${form_SENDER_USER_ID_R}" />
					 </e:field>
					<e:label for="REF_NUM" title="${form_REF_NUM_N}"/>
					<e:field>
					<e:inputText id="REF_NUM" name="REF_NUM" value="${form.REF_NUM}" width="100%" maxLength="${form_REF_NUM_M}" disabled="${form_REF_NUM_D}" readOnly="${form_REF_NUM_RO}" required="${form_REF_NUM_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="REF_MODULE_CD" title="${form_REF_MODULE_CD_N}"/>
					<e:field>
					<e:inputText id="REF_MODULE_CD" name="REF_MODULE_CD" value="${form.REF_MODULE_CD}" width="100%" maxLength="${form_REF_MODULE_CD_M}" disabled="${form_REF_MODULE_CD_D}" readOnly="${form_REF_MODULE_CD_RO}" required="${form_REF_MODULE_CD_R}" />
					 </e:field>
					<e:label for="RECEIVER_NM" title="${form_RECEIVER_NM_N}"/>
					<e:field>
					<e:inputText id="RECEIVER_NM" name="RECEIVER_NM" value="${form.RECEIVER_NM}" width="100%" maxLength="${form_RECEIVER_NM_M}" disabled="${form_RECEIVER_NM_D}" readOnly="${form_RECEIVER_NM_RO}" required="${form_RECEIVER_NM_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="RECEIVER_EMAIL" title="${form_RECEIVER_EMAIL_N}"/>
					<e:field>
					<e:inputText id="RECEIVER_EMAIL" name="RECEIVER_EMAIL" value="${form.RECEIVER_EMAIL}" width="100%" maxLength="${form_RECEIVER_EMAIL_M}" disabled="${form_RECEIVER_EMAIL_D}" readOnly="${form_RECEIVER_EMAIL_RO}" required="${form_RECEIVER_EMAIL_R}" />
					 </e:field>
					<e:label for="RECEIVER_USER_ID" title="${form_RECEIVER_USER_ID_N}"/>
					<e:field>
					<e:inputText id="RECEIVER_USER_ID" name="RECEIVER_USER_ID" value="${form.RECEIVER_USER_ID}" width="100%" maxLength="${form_RECEIVER_USER_ID_M}" disabled="${form_RECEIVER_USER_ID_D}" readOnly="${form_RECEIVER_USER_ID_RO}" required="${form_RECEIVER_USER_ID_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
					<e:field>
					<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="100%" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					 </e:field>
					<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
					<e:field>
					<e:inputText id="ATT_FILE_NUM" name="ATT_FILE_NUM" value="${form.ATT_FILE_NUM}" width="100%" maxLength="${form_ATT_FILE_NUM_M}" disabled="${form_ATT_FILE_NUM_D}" readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
					<e:field>
					<e:inputText id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}" width="100%" maxLength="${form_BUYER_CD_M}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
					 </e:field>
					<e:label for="SMTP_SERVER" title="${form_SMTP_SERVER_N}"/>
					<e:field>
					<e:inputText id="SMTP_SERVER" name="SMTP_SERVER" value="${mailSmtpServer}" width="100%" maxLength="${form_SMTP_SERVER_M}" disabled="${form_SMTP_SERVER_D}" readOnly="${form_SMTP_SERVER_RO}" required="${form_SMTP_SERVER_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="SMTP_PORT" title="${form_SMTP_PORT_N}"/>
					<e:field>
					<e:inputText id="SMTP_PORT" name="SMTP_PORT" value="${mailSmtpPort}" width="100%" maxLength="${form_SMTP_PORT_M}" disabled="${form_SMTP_PORT_D}" readOnly="${form_SMTP_PORT_RO}" required="${form_SMTP_PORT_R}" />
					 </e:field>
					<e:label for="SMTP_USER" title="${form_SMTP_USER_N}"/>
					<e:field>
					<e:inputText id="SMTP_USER" name="SMTP_USER" value="${mailSmtpUser}" width="100%" maxLength="${form_SMTP_USER_M}" disabled="${form_SMTP_USER_D}" readOnly="${form_SMTP_USER_RO}" required="${form_SMTP_USER_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="SMTP_PW" title="${form_SMTP_PW_N}"/>
					<e:field>
					<e:inputText id="SMTP_PW" name="SMTP_PW" value="${mailSmtpPassword}" width="100%" maxLength="${form_SMTP_PW_M}" disabled="${form_SMTP_PW_D}" readOnly="${form_SMTP_PW_RO}" required="${form_SMTP_PW_R}" />
					 </e:field>
					<e:label for="SMTP_ENCODING" title="${form_SMTP_ENCODING_N}"/>
					<e:field>
					<e:inputText id="SMTP_ENCODING" name="SMTP_ENCODING" value="${mailSmtpEncodingSet}" width="100%" maxLength="${form_SMTP_ENCODING_M}" disabled="${form_SMTP_ENCODING_D}" readOnly="${form_SMTP_ENCODING_RO}" required="${form_SMTP_ENCODING_R}" />
					 </e:field>
 			</e:row>
           <e:row>
					<e:label for="SMTP_AUTH_FLAG" title="${form_SMTP_AUTH_FLAG_N}"/>
					<e:field>
					<e:inputText id="SMTP_AUTH_FLAG" name="SMTP_AUTH_FLAG" value="${mailSmtpAuthenticationFlag}" width="100%" maxLength="${form_SMTP_AUTH_FLAG_M}" disabled="${form_SMTP_AUTH_FLAG_D}" readOnly="${form_SMTP_AUTH_FLAG_RO}" required="${form_SMTP_AUTH_FLAG_R}" />
					 </e:field>
					<e:label for="MAIL_SEND_FLAG" title="${form_MAIL_SEND_FLAG_N}"/>
					<e:field>
					<e:inputText id="MAIL_SEND_FLAG" name="MAIL_SEND_FLAG" value="${mailSendFlag}" width="100%" maxLength="${form_MAIL_SEND_FLAG_M}" disabled="${form_MAIL_SEND_FLAG_D}" readOnly="${form_MAIL_SEND_FLAG_RO}" required="${form_MAIL_SEND_FLAG_R}" />
					 </e:field>
 			</e:row>
 			
		</e:searchPanel>
		
    <jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true">
    <jsp:param value="AP00000257" name="APP_DOC_NUM"/>
    <jsp:param value="1" name="APP_DOC_CNT"/>
    </jsp:include>    
		
		
    </e:window>
</e:ui>