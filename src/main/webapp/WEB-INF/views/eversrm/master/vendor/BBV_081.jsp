
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var baseUrl = "/eversrm/master/vendor/";

		function init() {
			if (EVF.C('DOC_NUM').getValue() == '') {
				doClose();
			}
        }
        function doClose() {

			if (opener) {
				window.open("", "_self");
				window.close();
			} else if (parent) {
				new EVF.ModalWindow().close(null);
			}

		}
	</script>

	<e:window id="BBV_081" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" />
		</e:buttonBar>

		<e:searchPanel id="form" useTitleBar="false" title="" labelWidth="${labelWidth}" width="100%" columnCount="2">
			<e:inputHidden id="TEXT_NUM" name="TEXT_NUM" value="${form.TEXT_NUM}" />

			<e:row>
				<e:label for="DOC_NUM" title="${form_DOC_NUM_N}" />
				<e:field>
					<e:inputText id="DOC_NUM" name="DOC_NUM" value="${form.DOC_NUM}" width="${inputTextWidth}" maxLength="${form_DOC_NUM_M}" disabled="${form_DOC_NUM_D}" readOnly="${form_DOC_NUM_RO}" required="${form_DOC_NUM_R}" />
				</e:field>
				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}" />
				<e:field>
					<e:inputText id="REG_USER_NM" name="REG_USER_NM" value="${form.REG_USER_NM}" width="100%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" />
				</e:field>
			</e:row>
			<!-- 
			<e:row>
				<e:label for="DOC_TYPE" title="${form_DOC_TYPE_N}" />
				<e:field>
					<e:select id="DOC_TYPE" name="DOC_TYPE" value="${form.DOC_TYPE}" options="${refDocType }" width="${inputTextWidth}" disabled="${form_DOC_TYPE_D}" readOnly="${form_DOC_TYPE_RO}" required="${form_DOC_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			 -->
			<e:row>
				<e:label for="EMAIL" title="${form_EMAIL_N}" />
				<e:field>
					<e:inputText id="EMAIL" name="EMAIL" value="${form.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" />
				</e:field>
				<e:label for="TEL_NUM" title="${form_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" value="${form.TEL_NUM}" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DOC_TEXT" title="${form_DOC_TEXT_N}" />
				<e:field colSpan="3">
					<e:richTextEditor id="DOC_TEXT" name="DOC_TEXT" value="${form.DOC_TEXT}" width="100%" height="370px" maxLength="${form_DOC_TEXT_M}" disabled="${form_DOC_TEXT_D}" readOnly="${form_DOC_TEXT_RO}" required="${form_DOC_TEXT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
				<e:field colSpan="3">
					<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="true" fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="OF" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
		</e:searchPanel>

	</e:window>
</e:ui>