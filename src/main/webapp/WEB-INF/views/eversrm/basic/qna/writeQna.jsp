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
            <c:if test="${not empty ERROR_MESSAGE}">
            alert("${ERROR_MESSAGE}");
            do2Close();
            </c:if>

            var editor = EVF.C('EDITOR1').getInstance();
            editor.config.contentsCss  = "/css/richText.css";
            editor.config.allowedContent = true;
        }

        function save() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

            if (EVF.V('START_DATE') == '') {return alert("${BSN_150_MSG2 }");}
            if (EVF.V('EDITOR1') == '') {return alert("${BSN_150_MSG1 }");}
            if (!confirm("${msg.M0021 }")) return;

        		store.doFileUpload(function() {
	        	store.load(baseUrl + 'writeQna/doSave', function(){
	        		alert(this.getResponseMessage());
 	        		location.href =baseUrl + 'writeQna/view.so?QNA_NUM=' + encodeURIComponent(this.getParameter('QNA_NUM'))+'&onClose=${param.onClose}'   ;
	        		 if (opener != null) {
	        			 opener.search();
	        		 }
	        	});
            });
        }

        function delete2() {
	        var store = new EVF.Store();
        	if (!confirm("${msg.M0013 }")) return;
        		store.doFileUpload(function() {
	        	store.load(baseUrl + 'writeQna/doDelete', function(){
	        		alert(this.getResponseMessage());
	        		 if (opener != null) {
	        			opener.search();
						window.close();
	        		 } else {
	 	        		location.href =baseUrl + 'writeQna/view.so?QNA_NUM=' + encodeURIComponent(this.getParameter('QNA_NUM'))+'&onClose=${param.onClose}'   ;
	        		 }
	        	});
            });
        }

        function do2Close(){
        	window.close();
        }

    </script>
    <e:window id="BSN_150" onReady="init" initData="${initData}" title="게시판 작성" breadCrumbs="${breadCrumb }">


        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${longLabelWidth}" width="100%" columnCount="2">

			<e:row>
				<e:label for="QNA_TYPE" title="${form_QNA_TYPE_N}"/>
				<e:field>
					<e:select id="QNA_TYPE" name="QNA_TYPE" value="${form.QNA_TYPE }" options="${qnaTypeOptions}" width="${form_QNA_TYPE_W}" disabled="${form_QNA_TYPE_D}" readOnly="${form_QNA_TYPE_RO}" required="${form_QNA_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="VIEW_CNT" title="${form_VIEW_CNT_N }" />
				<e:field>
					<e:text>&nbsp;${form.VIEW_CNT }</e:text>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N }" />
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${form.START_DATE }" width="${inputDateWidth }" required="${form_START_DATE_R }" readOnly="${form_START_DATE_RO }" disabled="${form_START_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${form.END_DATE }" width="${inputDateWidth }" required="${form_END_DATE_R }" readOnly="${form_END_DATE_RO }" disabled="${form_END_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="REG_INFO" title="${form_REG_INFO_N }" />
				<e:field>
					<e:text>&nbsp;${form.REG_INFO }</e:text>
				</e:field>
			</e:row>
           <e:row>
               <e:label for="SUBJECT" title="${form_SUBJECT_N }" />
                <e:field colSpan="3">
                    <e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${form.SUBJECT }" maxLength="${form_SUBJECT_M}" width="${form_SUBJECT_W }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }" />
		            <e:inputHidden id="QNA_NUM" name="QNA_NUM" value="${form.QNA_NUM }" />
		            <e:inputHidden id="PARENT_QNA_NUM" name="PARENT_QNA_NUM" value="${form.PARENT_QNA_NUM }" />
		            <e:inputHidden id="QNA_TEXT_NUM" name="QNA_TEXT_NUM" value="${form.QNA_TEXT_NUM }" />
		            <e:inputHidden id="GATE_CD" name="GATE_CD" value="${form.GATE_CD }" />
                </e:field>
 			</e:row>

           <e:row>
               <e:label for="EDITOR1" title="${form_EDITOR1_N }" />
                <e:field colSpan="3">
                	<e:richTextEditor height="300px" id="EDITOR1" name="EDITOR1" width="${form_EDITOR1_W }" required="${form_EDITOR1_R }" readOnly="${form_EDITOR1_RO }" disabled="${form_EDITOR1_D }" value="${form.EDITOR1 }" useToolbar="${!param.detailView}" />
 				</e:field>
 			</e:row>

           <e:row>
               <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="false"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="NT" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
 				</e:field>
 			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<c:if test="${form.QNA_NUM == null}">
				<e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="save" />
			</c:if>
			<c:if test="${form.QNA_NUM != null}">
				<e:button id="doUpdate" name="doUpdate" label="${doUpdate_N }" disabled="${doUpdate_D }" onClick="save" />
				<e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="delete2" />
				<%-- <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="do2Close" /> --%>
			</c:if>

		</e:buttonBar>

    </e:window>
</e:ui>