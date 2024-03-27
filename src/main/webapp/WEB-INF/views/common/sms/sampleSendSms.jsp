<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
    	var addParam = [];
    	var baseUrl = "/common/sms/";
		function init() {
			
        }
         function send() {
        	if (!confirm("${msg.M0060 }")) return;
	        var store = new EVF.Store();
	        store.setParameter('toFlag','S');
        	store.load(baseUrl + 'doSend', function(){
        		alert(this.getResponseMessage());
        	});
        }            
        
         function sendAll() {
         	if (!confirm("${msg.M0060 }")) return;
 	        var store = new EVF.Store();
	        store.setParameter('toFlag','A');
         	store.load(baseUrl + 'doSend', function(){
         		alert(this.getResponseMessage());
         	});
         }   
         
         
     	function sendTelNo() {       
        	var param = {
            	GATE_CD: '${ses.gateCd }', 
            	callBackFunction : "setSendTelNo"
        	};
        	everPopup.openCommonPopup(param, 'SP0011');

}
        function setSendTelNo(dataJsonArray) {
    		EVF.C("SEND_USER_ID").setValue(dataJsonArray.USER_ID);
    		EVF.C("SEND_USER_NM").setValue(dataJsonArray.USER_NM);
    		EVF.C("SEND_TEL_NO").setValue(dataJsonArray.CELL_NUM);

}
        function receTelNo() {
        	var param = {
            	GATE_CD: '${ses.gateCd }', 
            	callBackFunction : "setReceTelNo"
        	};
        	everPopup.openCommonPopup(param, 'SP0011');

}
        function setReceTelNo(dataJsonArray) {
    		EVF.C("RECV_USER_ID").setValue(dataJsonArray.USER_ID);
    		EVF.C("RECV_USER_NM").setValue(dataJsonArray.USER_NM);
    		EVF.C("RECV_TEL_NO").setValue(dataJsonArray.CELL_NUM);

}
    </script>
    <e:window id="SAM_018" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
         <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSend" name="doSend" label="${doSend_N }" disabled="${doSend_D }" onClick="send" />
            <e:button id="doSendAll" name="doSendAll" label="${doSendAll_N }" disabled="${doSendAll_D }" onClick="sendAll" />
        </e:buttonBar>
    
    
        <e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="180" width="100%" columnCount="2">
           <e:row>
				<e:label for="SEND_USER_NM" title="${form_SEND_USER_NM_N}"/>
				<e:field>
				<e:search id="SEND_USER_NM" name="SEND_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_SEND_USER_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'sendTelNo'}" disabled="${form_SEND_USER_NM_D}" readOnly="${form_SEND_USER_NM_RO}" required="${form_SEND_USER_NM_R}" />
				<e:inputText id="SEND_TEL_NO" name="SEND_TEL_NO" value="${form.SEND_TEL_NO}" width="30%" maxLength="${form_SEND_TEL_NO_M}" disabled="${form_SEND_TEL_NO_D}" readOnly="${form_SEND_TEL_NO_RO}" required="${form_SEND_TEL_NO_R}" />
				<e:inputText id="SEND_USER_ID" name="SEND_USER_ID" value="${form.SEND_USER_ID}" width="30%" maxLength="${form_SEND_USER_ID_M}" disabled="${form_SEND_USER_ID_D}" readOnly="${form_SEND_USER_ID_RO}" required="${form_SEND_USER_ID_R}" />
				</e:field>
				<e:label for="RECV_USER_NM" title="${form_RECV_USER_NM_N}"/>
				<e:field>
				<e:search id="RECV_USER_NM" name="RECV_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_RECV_USER_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'receTelNo'}" disabled="${form_RECV_USER_NM_D}" readOnly="${form_RECV_USER_NM_RO}" required="${form_RECV_USER_NM_R}" />
				<e:inputText id="RECV_TEL_NO" name="RECV_TEL_NO" value="${form.RECV_TEL_NO}" width="30%" maxLength="${form_RECV_TEL_NO_M}" disabled="${form_RECV_TEL_NO_D}" readOnly="${form_RECV_TEL_NO_RO}" required="${form_RECV_TEL_NO_R}" />
				<e:inputText id="RECV_USER_ID" name="RECV_USER_ID" value="${form.RECV_USER_ID}" width="30%" maxLength="${form_RECV_USER_ID_M}" disabled="${form_RECV_USER_ID_D}" readOnly="${form_RECV_USER_ID_RO}" required="${form_RECV_USER_ID_R}" />

				</e:field>
 			</e:row>
 
           <e:row>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
				<e:inputText id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="100%" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
				 </e:field>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:inputText id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}" width="100%" maxLength="${form_BUYER_CD_M}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
				 </e:field>
 			</e:row>

           <e:row>
				<e:label for="REF_NUM" title="${form_REF_NUM_N}"/>
				<e:field>
				<e:inputText id="REF_NUM" name="REF_NUM" value="${form.REF_NUM}" width="100%" maxLength="${form_REF_NUM_M}" disabled="${form_REF_NUM_D}" readOnly="${form_REF_NUM_RO}" required="${form_REF_NUM_R}" />
				 </e:field>
				<e:label for="REF_MODULE_CD" title="${form_REF_MODULE_CD_N}"/>
				<e:field>
				<e:inputText id="REF_MODULE_CD" name="REF_MODULE_CD" value="${form.REF_MODULE_CD}" width="100%" maxLength="${form_REF_MODULE_CD_M}" disabled="${form_REF_MODULE_CD_D}" readOnly="${form_REF_MODULE_CD_RO}" required="${form_REF_MODULE_CD_R}" />
				 </e:field>
 			</e:row>
           
           <e:row>
				<e:label for="CONTENTS" title="${form_CONTENTS_N}"/>
				<e:field colSpan="3">
				<e:inputText id="CONTENTS" name="CONTENTS" value="${form.CONTENTS}" width="100%" maxLength="${form_CONTENTS_M}" disabled="${form_CONTENTS_D}" readOnly="${form_CONTENTS_RO}" required="${form_CONTENTS_R}" />
				 </e:field>
 			</e:row>
		</e:searchPanel>
    </e:window>
</e:ui>