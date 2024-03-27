<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var grid1 = {};
        var grid2 = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/basic/qna/";
		function init() {

            var editor = EVF.C('EDITOR1').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;
        }
        function save() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

        	if (!confirm("${msg.M0021 }")) return;
        		store.doFileUpload(function() {
	        	store.load(baseUrl + 'writeReplyQna/doSave', function(){
	        		alert(this.getResponseMessage());
 	        		location.href =baseUrl + 'writeQna/view.so?QNA_NUM=' + encodeURIComponent(this.getParameter('QNA_NUM'))+'&onClose=${param.onClose}'   ;
 	        		window.close();
 	        	});
            });
        }


        function do2Close(){
        	window.close();
        }
    </script>
    <e:window id="BSN_170" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">


        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="2">

			<e:row>
				<e:label for="QNA_TYPE" title="${form_QNA_TYPE_N}"/>
				<e:field>
					<e:select id="QNA_TYPE" name="QNA_TYPE" value="${form.QNA_TYPE }" options="${qnaTypeOptions}" width="${form_QNA_TYPE_W}" disabled="true" readOnly="true" required="${form_QNA_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="VIEW_CNT" title="${form_VIEW_CNT_N }" />
				<e:field>
					<e:text>&nbsp;${form.VIEW_CNT }</e:text>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N }" />
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${form.START_DATE }" width="${form_START_DATE_W }" required="${form_START_DATE_R }" readOnly="${form_START_DATE_RO }" disabled="${form_START_DATE_D }" datePicker="true" />
					<e:text> ~ </e:text>
					<e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${form.END_DATE }" width="${form_END_DATE_W }" required="${form_END_DATE_R }" readOnly="${form_END_DATE_RO }" disabled="${form_END_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="REG_INFO" title="${form_REG_INFO_N }" />
				<e:field>
					<e:text>&nbsp;${form.REG_INFO }</e:text>
				</e:field>
			</e:row>

			<e:row>
               <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                    <e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT }" maxLength="${form_SUBJECT_M}" width="${form_SUBJECT_W }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
		            <e:inputHidden id="QNA_NUM" name="QNA_NUM" value="${form.QNA_NUM }" />
		            <e:inputHidden id="PARENT_QNA_NUM" name="PARENT_QNA_NUM" value="${form.PARENT_QNA_NUM }" />
		            <e:inputHidden id="QNA_TEXT_NUM" name="QNA_TEXT_NUM" value="${form.QNA_TEXT_NUM }" />
		            <e:inputHidden id="GATE_CD" name="GATE_CD" value="${form.GATE_CD }" />
                </e:field>
 			</e:row>

           <e:row>
               <e:label for="EDITOR1" title="${form_EDITOR1_N }" />
                <e:field colSpan="3">
                	<e:richTextEditor height="300px" id="EDITOR1"    name="EDITOR1" width="100%" required="${form_EDITOR1_R }" readOnly="${form_EDITOR1_RO }" disabled="${form_EDITOR1_D }" value="${form.EDITOR1 }"/>
 				</e:field>
 			</e:row>

           <e:row>
               <e:label for="ATT_FILE_NUM" title="${form_fileAttach_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly=""  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
 				</e:field>
 			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSaveReply" name="doSaveReply" label="${doSaveReply_N }" disabled="false" onClick="save" />
			<e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="do2Close" />
		</e:buttonBar>

    </e:window>
</e:ui>