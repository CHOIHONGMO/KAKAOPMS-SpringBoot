<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var approvalType = '${param.approvalType}';

    function init() {
        window.focus();
    }

    function onConfirm() {

        var signRemark = EVF.C('SIGN_RMK').getValue();
        if (approvalType === 'R' && signRemark === '') {
            alert('${BAPP_052_EnterRejectComment}');
            return;
        }

	    parent.${'doApprovalOrReject'}(approvalType, signRemark);
        onClose();
    }

    function onClose() {
    	new EVF.ModalWindow().close(null);
    }

    </script>

    <e:window id="BAPP_052" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="onConfirm" name="onConfirm" label="${onConfirm_N }" disabled="${onConfirm_D }" onClick="onConfirm" />
            <e:button id="onClose" name="onClose" label="${onClose_N }" disabled="${onClose_D }" onClick="onClose" />
        </e:buttonBar>

		<e:searchPanel id="form" useTitleBar="false" title="${form_caption_form_N}" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:row>
				<e:label for="SIGN_RMK" title="${param.approvalType == 'E' ? BAPP_052_ApprovalComment : BAPP_052_RejectComment}"></e:label>
                <e:field colSpan="3">
                	<e:textArea id="SIGN_RMK" name="SIGN_RMK" width="100%" height="270" required="${form_SIGN_RMK_R}" readOnly="${form_SIGN_RMK_RO}" disabled="${form_SIGN_RMK_D}" maxLength="${form_SIGN_RMK_M }"/>
                </e:field>
            </e:row>
        </e:searchPanel>

    </e:window>
</e:ui>
