<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/board/email/";

		function init() {
        }
		
		function close2() {
			window.close();
			
			if(opener != null) {
				opener.search();
			} 
		}
    </script>
    <e:window id="BSN_130" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="close2" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
        
        <e:searchPanel id="form" title="${form_CAPTION_N }"  useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="1">
           <e:row> 			
               <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field>       
                    <e:inputText id="SUBJECT" name="SUBJECT" value="${formData.SUBJECT }" maxLength="${form_SUBJECT_M}" width="100%" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
		            <e:inputHidden id="TFT_MEMBER" name="TFT_MEMBER" value="" />
                </e:field>
 			</e:row>
 			
           <e:row> 			
				 <e:label for="SENDER" title="${form_SENDER_N}"/>
				<e:field>
				<e:inputText id="SENDER" name="SENDER" value="${formData.SEND_USER_NM }" width="100%" maxLength="${form_SENDER_M}" disabled="${form_SENDER_D}" readOnly="${form_SENDER_RO}" required="${form_SENDER_R}" />
				 </e:field>
 			</e:row>
 			
           <e:row> 			
				 <e:label for="RECIPIENT" title="${form_RECIPIENT_N}"/>
				<e:field>
				<e:inputText id="RECIPIENT" name="RECIPIENT" value="${formData.RECV_USER_NM }" width="100%" maxLength="${form_RECIPIENT_M}"  disabled="${form_RECIPIENT_D}" readOnly="${form_RECIPIENT_RO}" required="${form_RECIPIENT_R}" />
				</e:field>
 			</e:row>
 			
           <e:row>
               <e:label for="CONTENT" title="${form_CONTENT_N }" />
                <e:field>       			
                	<e:richTextEditor height="280px" id="CONTENT" name="CONTENT" width="100%" required="${form_TEXT_CONTENT_R }" readOnly="${form_CONTENT_RO }" disabled="${form_TEXT_CONTENT_D }" value="${formData.CONTENT }"/>
 				</e:field>
 			</e:row>
 			
           <e:row>
               <e:label for="CAPTION_ATTACH" title="${form_CAPTION_ATTACH_N }" />
                <e:field> 			
                    <e:fileManager id="CAPTION_ATTACH" name="CAPTION_ATTACH" readOnly="true"  fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="100px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
 				</e:field>
 			</e:row>
		</e:searchPanel>
    </e:window>
</e:ui>