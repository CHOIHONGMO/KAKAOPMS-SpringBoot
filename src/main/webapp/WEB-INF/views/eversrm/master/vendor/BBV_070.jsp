
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var baseUrl = "/eversrm/master/vendor/";

		function init() {
        }
        function doSave() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			var signStatus = this.getData();
			EVF.getComponent("SIGN_STATUS").setValue(signStatus);

			if (!confirm('${msg.M0011}')) {
				return;
			}

			_save();
		}

		function doApproval() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			var signStatus = this.getData();
			EVF.getComponent("SIGN_STATUS").setValue(signStatus);

			var param = {
				subject : EVF.C('SUBJECT').getValue(),
				docType : "OF",
				signStatus : signStatus,
				screenId : "BBV_070",
				approvalType : 'APPROVAL',
				oldApprovalFlag : EVF.C('SIGN_STATUS').getValue(),
				attFileNum : "",
				docNum : EVF.getComponent('DOC_NUM').getValue(),
				appDocNum : EVF.C('APP_DOC_NUM').getValue(),
				callBackFunction : "goApproval"
			};
			everPopup.openApprovalRequestIIPopup(param);
		}

		function goApproval(formData, gridData, attachData) {
			EVF.getComponent('approvalFormData').setValue(formData);
			EVF.getComponent('approvalGridData').setValue(gridData);
			EVF.getComponent('attachFileDatas').setValue(attachData);

			_save();
		}

		function _save() {
			var signStatus = EVF.C('SIGN_STATUS').getValue();

			var store = new EVF.Store();
			if (!store.validate())
				return;

			store.doFileUpload(function() {
				store.load(baseUrl + 'BBV_070/doSave', function() {
					alert(this.getResponseMessage());

					if (opener) {
						opener.doSearch();
					}

					var detailView = '${param.detailView}';
					var signStatus = EVF.getComponent('SIGN_STATUS').getValue();
					if (signStatus == 'P' || signStatus == 'E') {
						detailView = true;
					}

					location.href = baseUrl + 'BBV_070/view.so?docNum=' + this.getParameter("docNum") + '&popupFlag=${param.popupFlag}&detailView=' + detailView;
				});
			});
		}

		function doDelete() {
			if (EVF.getComponent('DOC_NUM').getValue() == "") {
				alert("${msg.M0110}");
				return;
			}

			if (!confirm("${msg.M0013}")) {
				return;
			}

			var store = new EVF.Store();

			store.load(baseUrl + 'BBV_070/doDelete', function() {
				alert(this.getResponseMessage());

				if (opener) {
					opener.doSearch();
				}

				$(location).attr('href', baseUrl + 'BBV_070/view');
			});
		}

		function searchCandidate() {
			everPopup.openSearchCandidatePopup({
				callBackFunction : '_setSelectCandidate',
				candidateJson : EVF.C('SELECT_CANDIDATE_JSON').getValue(),
				rowid : '0',
				detailView : '${param.detailView}'
			});
        }
        function _setSelectCandidate(vendorInfo, rowId) {
			EVF.C("SELECT_CANDIDATE_JSON").setValue(vendorInfo);

			var vendors = "";

			var vendorList = JSON.parse(vendorInfo);
			for ( var idx in vendorList) {
				var rowData = vendorList[idx];

				vendors += rowData['VENDOR_NM'] + ', ';
			}

			EVF.C("VENDOR_TEXT").setValue(vendors);
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

	<e:window id="BBV_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<c:if test="${form.SIGN_STATUS != 'P' && form.SIGN_STATUS != 'E' }">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data='T' />
				<e:button id="doApproval" name="doApproval" label="${doApproval_N}" onClick="doApproval" disabled="${doApproval_D}" visible="${doApproval_V}" data='P' />
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
			</c:if>
			<c:if test="${param.popupFlag == 'true'}">
				<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}" />
			</c:if>
		</e:buttonBar>

		<e:searchPanel id="form" useTitleBar="false" title="" labelWidth="${labelWidth}" width="100%" columnCount="2">
			<e:inputHidden id="TEXT_NUM" name="TEXT_NUM" value="${form.TEXT_NUM}" />
			<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}" />
			<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${form.APP_DOC_NUM}" />
			<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${form.APP_DOC_CNT}" />
			<e:inputHidden id="approvalFormData" name="approvalFormData" value="" />
			<e:inputHidden id="approvalGridData" name="approvalGridData" value="" />
			<e:inputHidden id="attachFileDatas" name="attachFileDatas" value="" />
			<e:inputHidden id="SELECT_CANDIDATE_JSON" name="SELECT_CANDIDATE_JSON" value="${form.SELECT_CANDIDATE_JSON}" />
			<e:inputHidden id="DOC_TYPE" name="DOC_TYPE" value="OF" />
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
			<e:row>
				<e:label for="EMAIL" title="${form_EMAIL_N}" />
				<e:field>
					<e:inputText id="EMAIL" name="EMAIL" value="${form.EMAIL}" width="100%" maxLength="${form_EMAIL_M}" disabled="${form_EMAIL_D}" readOnly="${form_EMAIL_RO}" required="${form_EMAIL_R}" style='ime-mode:inactive'/>
				</e:field>
				<e:label for="TEL_NUM" title="${form_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="TEL_NUM" name="TEL_NUM" value="${form.TEL_NUM}" width="100%" maxLength="${form_TEL_NUM_M}" disabled="${form_TEL_NUM_D}" readOnly="${form_TEL_NUM_RO}" required="${form_TEL_NUM_R}" style='ime-mode:inactive'/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" style="${imeMode}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="VENDOR_TEXT" title="${form_VENDOR_TEXT_N}" />
				<e:field colSpan="3">
					<e:search id="VENDOR_TEXT" name="VENDOR_TEXT" value="${form.VENDOR_TEXT}" width="100%" maxLength="${form_VENDOR_TEXT_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchCandidate'}" disabled="${form_VENDOR_TEXT_D}" readOnly="${form_VENDOR_TEXT_RO}" required="${form_VENDOR_TEXT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DOC_TEXT" title="${form_DOC_TEXT_N}" />
				<e:field colSpan="3">
					<e:richTextEditor id="DOC_TEXT" name="DOC_TEXT" value="${form.DOC_TEXT}" width="100%" height="300px" maxLength="${form_DOC_TEXT_M}" disabled="${form_DOC_TEXT_D}" readOnly="${form_DOC_TEXT_RO}" required="${form_DOC_TEXT_R}" style="${imeMode}"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
				<e:field colSpan="3">
					<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView ? true : false}" fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="OF" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true">
			<jsp:param value="${form.APP_DOC_NUM}" name="APP_DOC_NUM" />
			<jsp:param value="${form.APP_DOC_CNT}" name="APP_DOC_CNT" />
		</jsp:include>

	</e:window>
</e:ui>