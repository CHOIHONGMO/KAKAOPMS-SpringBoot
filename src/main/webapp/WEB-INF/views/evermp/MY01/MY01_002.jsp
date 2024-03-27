<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var baseUrl = "/evermp/MY01/";

    	function init() {

    		// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
    		if('${param.detailView}' == 'true') {
    			$('#upload-button-ATT_FILE_NUM').css('display','none');
    		}

            var editor = EVF.C('NOTICE_CONTENTS').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;
        }
		<c:if test="${param.detailView=='false' }">


        function doSave() {

        	var store = new EVF.Store();
	        if(!store.validate()) return;

            if( EVF.isEmpty(EVF.C('START_DATE').getValue()) ) {
            	return alert("${MY01_002_003 }");
            }
            if( EVF.isEmpty(EVF.C('NOTICE_CONTENTS').getValue()) ) {
            	return alert("${MY01_002_002 }");
            }
			if( EVF.C('ANN_FLAG').getValue() == '1' && EVF.C('USER_TYPE').getValue() != 'USNA' ) {
				return alert('${MY01_002_006 }');
			}

            if(!confirm("${msg.M0021 }")) return;
        	store.doFileUpload(function() {
	        	store.load(baseUrl + 'my01002_doSave', function(){
	        		alert(this.getResponseMessage());
 	        		location.href = baseUrl + 'MY01_002/view.so?NOTICE_NUM=' + this.getParameter('NOTICE_NUM') + '&detailView=false';
 	        		if(opener != null) {
 	        			opener.doSearch();
 	        		}
	        	});
            });
        }

        function doDelete() {
	        var store = new EVF.Store();
        	if (!confirm("${msg.M0013 }")) return;
        	store.load(baseUrl + 'my01002_doDelete', function(){
        		alert(this.getResponseMessage());
        		 if(opener != null) {
        			opener.doSearch();
        		 }
        		 formUtil.close();
        	});
        }

        function doClear() {
        	if(confirm("${MY01_002_005}")) {
        		location.href = baseUrl + 'MY01_002/view.so?NOTICE_NUM=&detailView=false';
        	}
        }
		</c:if>

        function doClose(){
        	formUtil.close();
        }

    </script>

    <e:window id="MY01_002" onReady="init" initData="${initData}" title="${MY01_002_001 }" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<c:if test="${param.detailView == false && ses.userType=='C'}">
				<e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
				<c:if test="${formData.NOTICE_NUM != null}">
					<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
				</c:if>
				<e:button id="Clear" name="Clear" label="${Clear_N }" disabled="${Clear_D }" onClick="doClear" />
			</c:if>
		</e:buttonBar>




        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${longLabelWidth}" width="100%" columnCount="2">
			<e:row>
				<e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                	<e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${formData.SUBJECT }" maxLength="${form_SUBJECT_M}" width="${form_SUBJECT_W }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
		            <e:inputHidden id="NOTICE_NUM" name="NOTICE_NUM" value="${formData.NOTICE_NUM }" />
		            <e:inputHidden id="NOTICE_TEXT_NUM" name="NOTICE_TEXT_NUM" value="${formData.NOTICE_TEXT_NUM }" />
                </e:field>
            </e:row>
			<e:row>
				<e:label for="USER_TYPE" title="${form_USER_TYPE_N}"/>
				<e:field>
					<e:select id="USER_TYPE" name="USER_TYPE" value="${formData.USER_TYPE }" options="${userTypeOptions}" width="${form_USER_TYPE_W}" disabled="${form_USER_TYPE_D}" readOnly="${form_USER_TYPE_RO}" required="${form_USER_TYPE_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
				<e:label for="ANN_FLAG" title="${form_ANN_FLAG_N}"/>
				<e:field>
					<e:select id="ANN_FLAG" name="ANN_FLAG" value="${formData.ANN_FLAG }" options="${annFlagOptions}" width="${form_ANN_FLAG_W}" disabled="${form_ANN_FLAG_D}" readOnly="${form_ANN_FLAG_RO}" required="${form_ANN_FLAG_R}" placeHolder="" usePlaceHolder="false" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N}" />
				<e:field>
					<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${formData.START_DATE }" width="${inputDateWidth }" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${formData.END_DATE }" width="${inputDateWidth }" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<e:label for="REG_USER_NAME" title="${form_REG_USER_NAME_N }" />
				<e:field>
					<e:text>&nbsp;${formData.REG_USER_NAME }</e:text>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="NOTICE_CONTENTS" title="${form_NOTICE_CONTENTS_N }" />
				<e:field colSpan="3">
					<e:richTextEditor id="NOTICE_CONTENTS" name="NOTICE_CONTENTS" width="${form_NOTICE_CONTENTS_W }" height="380px" required="${form_NOTICE_CONTENTS_R }" readOnly="${form_NOTICE_CONTENTS_RO }" disabled="${form_NOTICE_CONTENTS_D }" value="${formData.NOTICE_CONTENTS }" useToolbar="${!param.detailView}" />
 				</e:field>
 			</e:row>
 			<e:row>
 				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="120px" readOnly="${!param.detailView ? false : true }" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
 				</e:field>
 			</e:row>
		</e:searchPanel>
    </e:window>
</e:ui>