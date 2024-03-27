<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script src="//cdn.ckeditor.com/4.4.5/full/ckeditor.js"></script>
    <script type="text/javascript" src="/js/ckeditor/econt_plugins.js"></script>
	<script type="text/javascript">

	var grid = {};
    var toolkit;

    var baseUrl = "/eversrm/eContract/eContractMgt/BECM_030/";
    var userType = '${ses.userType}';
    var baseDataType = '${param.baseDataType}';

	function init(){

		grid = EVF.C("grid");

        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

    		switch (celname) {
	    		case 'REL_FORM_NUM':
	                var params = {
	                    rowIndex         : rowid,
	                    relformNum       : grid.getCellValue(rowid, 'REL_FORM_NUM'),
	                    formTextNum      : grid.getCellValue(rowid, 'FORM_TEXT_NUM'),
	                    contNum          : EVF.C('CONT_NUM').getValue(),
	                    buyerCode        : EVF.C('BUYER_CD').getValue(),
	                    vendorCode       : EVF.C('VENDOR_CD').getValue(),
	                    callBackFunction : 'doCheckAdditionalContractStatus',
	                    contents         : grid.getCellValue(rowid, 'ADDITIONAL_CONTENTS')
	                };
	                everPopup.openAdditionalContract(params);
	    			break;

	    		default:
	    			return;
    		}

    	});

        var editor = CKEDITOR.replace('cont_content', {
            customConfig : '/js/ckeditor/ep_config.js',
            width: '100%',
            height: 330
        });

        editor.on('instanceReady', function(ev){

            var editor = ev.editor;
            editor.resize('100%', 330, true, false);

            $(window).resize(function() {
                editor.resize('100%', 330, true, false);
            });
        });

    }
    function doSave() {

		var gridData = grid.getSelRowValue();
		if (gridData.length != grid.getRowCount()) {
			return alert('${BECM_030_0013}');
		}

		var store = new EVF.Store();
		if (!store.validate()) {
			return;
		}

        if (!confirm('${msg.M0021}')) return;

		store.setGrid([ grid ]);
		store.getGridData(grid, 'sel');
        store.setParameter('mainContractContents', CKEDITOR.instances.cont_content.getData().replace(/%/gi, '&#37;').replace(/'/gi, '&#39;'));
		store.load(baseUrl + 'doSaveContract', function() {
            alert(this.getResponseMessage());
            var param = {
                baseDataType: 'manualContract',
                contNum: this.getParameter('contNum'),
                contCnt: this.getParameter('contCnt')
            };
            location.href=baseUrl+'view.so?'+ $.param(param);
		});
    }
    function doSign() {
		var gridData = grid.getSelRowValue();
		if (gridData.length != grid.getRowCount()) {
			return alert('${BECM_030_0013}');
		}

        // get the signed value by json array from every contracts.
        var allContents = [];

        var contNum     = EVF.C('CONT_NUM').getValue();
        var contCnt     = EVF.C('CONT_CNT').getValue();
        var mainFormNum = EVF.C('FORM_NUM').getValue();
        var mainContents = {
            CONT_NUM : contNum,
            CONT_CNT : contCnt,
            FORM_NUM : mainFormNum,
            CONTENTS : $ ('#mainContractContents').html()
        };
        allContents[0] = mainContents;

        var rowIds = grid.getSelRowId();
        for(var rowid in rowIds) {
            var subContractContent = {
                    CONT_NUM     : contNum,
                    CONT_CNT     : contCnt,
                    FORM_NUM     : grid.getCellValue(rowIds[rowid], 'FORM_NUM'),
                    REL_FORM_NUM : grid.getCellValue(rowIds[rowid], 'REL_FORM_NUM'),
                    CONTENTS     : grid.getCellValue(rowIds[rowid], 'ADDITIONAL_CONTENTS')
                };
            allContents[allContents.length] = subContractContent;
        }

        var serverSignYN = EVF.C('serverSignYN').getValue();
        if (serverSignYN == 'true' && userType == 'C') {
            signResult = allContents;
        } else {
/*
        	signResult = contUtil.getContractCertificateSelection(toolkit, JSON.stringify(allContents));
 */
        }

        if (signResult === null) {

        } else {
        	var store = new EVF.Store();
    		if(!store.validate()) { return; }

            store.setParameter('signResult', JSON.stringify(signResult));
        	store.load(baseUrl + 'doSignContract', function(){
                alert(this.getResponseMessage());
                doClose();
        	});
        }
    }
    function doUpdate() {
		EVF.C("doSave").setDisabled(true);
		EVF.C("doDelete").setDisabled(true);
		EVF.C("doUpdate").setDisabled(false);
    }
    function doDelete() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0013}')) {
        	return;
        }

    	store.load(baseUrl + 'doDeleteContract', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    /*
    function doCheckContractStatusBeforeSend() {
        if (contractEditable) {
            if (confirm('${BECM_030_0015}')) {
                doSave('doSend');
            }
        } else {
            doSend();
        }
    };
*/

    function doSend() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0030}')) {
        	return;
        }

    	store.load(baseUrl + 'doSendContract', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function doCancel() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0030}')) {
        	return;
        }

    	store.load(baseUrl + 'doCancel', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function doTerminationApp() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0030}')) {
        	return;
        }

        store.load(baseUrl + 'doTerminationApp', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function getTerminationRejectPopup() {
        var params = {
            callBackFunction: 'doTerminationReject'
        };
        everPopup.openContractRejectReason(params);
    }
    function doTerminationReject(resultJson) {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        store.setParameter('reason', resultJson.reason);
        store.load(baseUrl + 'doTerminationReject', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function doRequestTermination() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0030}')) {
        	return;
        }

        store.load(baseUrl + 'doRequestTermination', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function getRejectPopup() {
        var params = {
            callBackFunction: 'doReject'
        };
        everPopup.openContractRejectReason(params);
    }
    function doReject(resultJson) {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        store.setParameter('reason', resultJson.reason);
        store.load(baseUrl + 'doReject', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function doDiscardApproval() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0030}')) {
        	return;
        }

        store.load(baseUrl + 'doDiscardApproval', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function getDiscardRejectPopup() {
        var params = {
            callBackFunction: 'doDiscardReject'
        };
        everPopup.openContractRejectReason(params);
    }
    function doDiscardReject(resultJson) {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        store.setParameter('reason', resultJson.reason);
        store.load(baseUrl + 'doDiscardReject', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function doRequestDiscard() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        if (!confirm('${msg.M0030}')) {
        	return;
        }

        store.load(baseUrl + 'doRequestDiscard', function(){
            alert(this.getResponseMessage());
            doClose();
    	});
    }
    function doClose() {
        if (opener.doSearch != undefined) {
            opener.doSearch();
        }
        window.close();
    }
    function doCheckAdditionalContractStatus(params) {
        grid.checkRow(params.rowIndex);
        grid.setCellValue(params.rowIndex, 'ADDITIONAL_CONTENTS', params.contents);
    }
    <%--
        function setButtons() {
            var progressCd             = EVF.C('PROGRESS_CD').getValue();
            var closingType            = EVF.C('CLOSING_TYPE').getValue();
            var closingprogressCd      = EVF.C('CLOSING_PROGRESS_CD').getValue();
            var closingRequestUserType = EVF.C('CLOSING_REQ_USER_TYPE').getValue();
            var signStatus             = EVF.C('SIGN_STATUS').getValue();
            var buyerSignOrder         = EVF.C('buyerSignOrder').getValue();
            var isApprovalRequired     = EVF.C('isApprovalRequired').getValue();

            if (!detailView && userType == 'C') {
                var approvalFlagBtn = EVF.C('APPROVAL_FLAG');
                if (isApprovalRequired == 'true') {
                    approvalFlagBtn.setValue('1');
                } else {
                    approvalFlagBtn.setValue('0');
                }
            }

            switch (userType) {
            case 'C':
                // Buyer
                switch (progressCd) {
                case '':
                    // manual
                case '4100':
                    // waiting for contract.
                case '4200':
                    // writing up contract.

                    if (buyerSignOrder === 'pre') {
                        EVF.C("doSign").setVisible(true);
                    } else if (buyerSignOrder === 'last') {
                        EVF.C("doSend").setVisible(true);
                    }

                    if (contractEditable) {
                        EVF.C("doSave").setVisible(true);
                        EVF.C("doDelete").setVisible(true);
                    } else {
                        EVF.C("doUpdate").setVisible(true);
                    }

                    break;
                case '4210':
                    // waiting for vendor's sign.
                    EVF.C("doCancel").setVisible(true);
                    if (closingprogressCd != '100') {
                        EVF.C("doRequestDiscard").setVisible(true);
                    }
                    break;
                case '4220':
                    // when vendor has returned request for contract.
                    if (contractEditable) {
                        EVF.C("doSave").setVisible(true);
                    } else {
                        EVF.C("doUpdate").setVisible(true);
                        EVF.C("doRequestDiscard").setVisible(true);
                        if (buyerSignOrder === 'pre') {
                            EVF.C("doSign").setVisible(true);
                        } else if (buyerSignOrder === 'last') {
                            EVF.C("doSend").setVisible(true);
                        }
                    }
                    break;
                case '4230':
                    // when vendor has signed the contract.
                    if (closingType == 'D' && closingprogressCd == '100') {
                        if (closingRequestUserType == 'S') {
                            EVF.C("doDiscardApproval").setVisible(true);
                            EVF.C("doDiscardReject").setVisible(true);
                        }
                    } else {
                        EVF.C("doRequestDiscard").setVisible(true);
                        if (isApprovalRequired && (signStatus !== 'P' && signStatus !== 'E')) {
                            EVF.C("doApproval").setVisible(true);
                        }
                    }
                    break;
                case '4300':
                    // when deal.
                    if (closingType == 'T') {
                        if (closingprogressCd == '100') {
                            if (closingRequestUserType == 'S') { // requested/accepted discard status
                                EVF.C("doTerminationReject").setVisible(true);
                                EVF.C("doTerminationApp").setVisible(true);
                            }
                        }
                    } else {
                        EVF.C("doRequestTermination").setVisible(true);
                    }
                    break;
                }
                break;
            case 'S':
                // Vendor
                switch (progressCd) {
                case '4210':
                    // waiting for vendor's sign.
                    if (closingRequestUserType == 'C' && closingprogressCd == '100') {
                        EVF.C("doDiscardApproval").setVisible(true);
                        EVF.C("doDiscardReject").setVisible(true);
                    } else {
                        EVF.C("doSign").setVisible(true);
                        EVF.C("doReject").setVisible(true);
                    }
                    break;
                case '4220':
                    // when vendor has returned request for contract.
                    if (closingRequestUserType == 'C' && closingprogressCd == '100') {
                        EVF.C("doDiscardApproval").setVisible(true);
                        EVF.C("doDiscardReject").setVisible(true);
                    }
                    break;
                case '4230':
                    // when vendor has signed the contract.
                    if (closingType == 'D') {
                        if (closingprogressCd == '100') {
                            if (closingRequestUserType == 'C') {
                                EVF.C("doDiscardReject").setVisible(true);
                                EVF.C("doDiscardApproval").setVisible(true);
                            }
                        }
                    } else {
                        EVF.C("doRequestDiscard").setVisible(true);
                    }
                    break;
                case '4300':
                    // when deal.
                    if (closingType == 'T') {
                        if (closingprogressCd == '100') {
                            if (closingRequestUserType == 'C') { // requested/accepted discard status
                                EVF.C("doTerminationReject").setVisible(true);
                                EVF.C("doTerminationApp").setVisible(true);
                            }
                        }
                    } else {
                        EVF.C("doRequestTermination").setVisible(true);
                    }
                    break;
                }
                break;
            }
        };
    --%>

    function doSelectDrafter() {
    	everPopup.openCommonPopup({
            callBackFunction: "setDrafter"
        }, 'SP0040');
    }
    function setDrafter(drafter) {
        EVF.C("CONT_USER_ID").setValue(drafter.CTRL_USER_ID);
        EVF.C("CONT_USER_NM").setValue(drafter.CTRL_USER_NM);
        EVF.C("BUYER_CD").setValue(drafter.BUYER_CD);
        EVF.C("BUYER_NM").setValue(drafter.BUYER_NM);
    }
    function doSelectVendor() {
    	everPopup.openCommonPopup({
            callBackFunction: "setVendor"
        }, 'SP0016');
    }
    function setVendor(vendor) {
        EVF.C("VENDOR_CD").setValue(vendor.VENDOR_CD);
        EVF.C("VENDOR_NM").setValue(vendor.VENDOR_NM);
    }
    function doApproval() {
        var param = {
            subject         : EVF.C('CONT_DESC').getValue(),
            oldApprovalFlag : EVF.C('SIGN_STATUS').getValue(),
            docNum          : EVF.C('APP_DOC_NUM').getValue()
        };
        everPopup.openApprovalRequestPopup(param);
    }
    function approvalCallBack(approvalData) {
        EVF.C('approvalFormData').setValue(approvalData.formData);
        EVF.C('approvalGridData').setValue(approvalData.gridData);
        EVF.C('SIGN_STATUS').setValue('P');
    }
    function getApproval() {
    	var store = new EVF.Store();
		if(!store.validate()) { return; }

        store.load(baseUrl + 'doApproval', function(){
            alert(this.getResponseMessage());
    	});
    }
    <%--
    function initGuaranteeButtons() {

        if (baseDataType === 'consultation') {
        	EVF.C("ADV_GUAR_FLAG").setDisabled(true);
        	EVF.C("ADV_VAT_FLAG").setDisabled(true);
        	EVF.C("ADV_GUAR_AMT").setDisabled(true);
        	EVF.C("ADV_GUAR_PERCENT").setDisabled(true);

        	EVF.C("CONT_GUAR_FLAG").setDisabled(true);
        	EVF.C("CONT_VAT_FLAG").setDisabled(true);
        	EVF.C("CONT_GUAR_AMT").setDisabled(true);
        	EVF.C("CONT_GUAR_PERCENT").setDisabled(true);

        	EVF.C("WARR_GUAR_FLAG").setDisabled(true);
        	EVF.C("WARR_VAT_FLAG").setDisabled(true);
        	EVF.C("WARR_GUAR_AMT").setDisabled(true);
        	EVF.C("WARR_GUAR_PERCENT").setDisabled(true);
        	EVF.C("WARR_GUAR_QT").setDisabled(true);
        } else {
            var advGuarFlag  = parseInt(EVF.C('ADV_GUAR_FLAG').getValue());
            var contGuarFlag = parseInt(EVF.C('CONT_GUAR_FLAG').getValue());
            var warrGuarFlag = parseInt(EVF.C('WARR_GUAR_FLAG').getValue());

			advGuarFlag  = (advGuarFlag == 1)  ? 0 : 1;
			contGuarFlag = (contGuarFlag == 1) ? 0 : 1;
			warrGuarFlag = (warrGuarFlag == 1) ? 0 : 1;

			EVF.C("ADV_VAT_FLAG").setDisabled(advGuarFlag);
			EVF.C("ADV_GUAR_AMT").setDisabled(advGuarFlag);
			EVF.C("ADV_GUAR_PERCENT").setDisabled(advGuarFlag);

			EVF.C("CONT_VAT_FLAG").setDisabled(contGuarFlag);
			EVF.C("CONT_GUAR_AMT").setDisabled(contGuarFlag);
			EVF.C("CONT_GUAR_PERCENT").setDisabled(contGuarFlag);

			EVF.C("WARR_VAT_FLAG").setDisabled(warrGuarFlag);
			EVF.C("WARR_GUAR_AMT").setDisabled(warrGuarFlag);
			EVF.C("WARR_GUAR_PERCENT").setDisabled(warrGuarFlag);
			EVF.C("WARR_GUAR_QT").setDisabled(warrGuarFlag);

			if (advGuarFlag == 0) {
				EVF.C("ADV_VAT_FLAG").setValue("0");
				EVF.C("ADV_GUAR_AMT").setValue("0");
				EVF.C("ADV_GUAR_PERCENT").setValue("0");
			}

			if (contGuarFlag == 0) {
				EVF.C("CONT_VAT_FLAG").setValue("0");
				EVF.C("CONT_GUAR_AMT").setValue("0");
				EVF.C("CONT_GUAR_PERCENT").setValue("0");
			}

			if (warrGuarFlag == 0) {
				EVF.C("WARR_VAT_FLAG").setValue("0");
				EVF.C("WARR_GUAR_AMT").setValue("0");
				EVF.C("WARR_GUAR_PERCENT").setValue("0");
				EVF.C("WARR_GUAR_QT").setValue("0");
			}
        }
    };
    --%>

    <%--
    function setGuaranteeButtons() {
        var id = this.getId();
        var val = parseInt(this.getValue());

		val = (val == 1) ? 0 : 1;

        switch (id) {
        case 'ADV_GUAR_FLAG':
			EVF.C("ADV_VAT_FLAG").setDisabled(val);
			EVF.C("ADV_GUAR_AMT").setDisabled(val);
			EVF.C("ADV_GUAR_PERCENT").setDisabled(val);

			if (val == 0) {
				EVF.C("ADV_VAT_FLAG").setValue("0");
				EVF.C("ADV_GUAR_AMT").setValue("0");
				EVF.C("ADV_GUAR_PERCENT").setValue("0");
			}
            break;
        case 'ADV_VAT_FLAG':

            break;
        case 'CONT_GUAR_FLAG':
			EVF.C("CONT_VAT_FLAG").setDisabled(val);
			EVF.C("CONT_GUAR_AMT").setDisabled(val);
			EVF.C("CONT_GUAR_PERCENT").setDisabled(val);
			if (val == 0) {
				EVF.C("CONT_VAT_FLAG").setValue("0");
				EVF.C("CONT_GUAR_AMT").setValue("0");
				EVF.C("CONT_GUAR_PERCENT").setValue("0");
			}
            break;
        case 'CONT_VAT_FLAG':

            break;

        case 'WARR_GUAR_FLAG':
			EVF.C("WARR_VAT_FLAG").setDisabled(val);
			EVF.C("WARR_GUAR_AMT").setDisabled(val);
			EVF.C("WARR_GUAR_PERCENT").setDisabled(val);
			EVF.C("WARR_GUAR_QT").setDisabled(val);
			if (val == 0) {
				EVF.C("WARR_VAT_FLAG").setValue("0");
				EVF.C("WARR_GUAR_AMT").setValue("0");
				EVF.C("WARR_GUAR_PERCENT").setValue("0");
				EVF.C("WARR_GUAR_QT").setValue("0");
			}
            break;
        case 'WARR_VAT_FLAG':

            break;
        }
    };
    --%>
    </script>

	<e:window id="BECM_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" onClick="doSave" data="${ses.userType}_SAVE" />
            <%--<e:button id="doUpdate" name="doUpdate" label="${doUpdate_N }" disabled="${doUpdate_D }" onClick="doUpdate" />--%>
			<%--<e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="doDelete" />--%>
			<%--<e:button id="doSend" name="doSend" label="${doSend_N }" disabled="${doSend_D }" onClick="doCheckContractStatusBeforeSend" data="${ses.userType}_SEND" />--%>
			<%--<e:button id="doSign" name="doSign" label="${doSign_N }" disabled="${doSign_D }" onClick="doCheckContractStatusBeforeSign" data="${ses.userType}_SIGN" />--%>
			<%--<e:button id="doReject" name="doReject" label="${doReject_N }" disabled="${doReject_D }" onClick="getRejectPopup" data="${ses.userType}" />--%>
			<%--<e:button id="doApproval" name="doApproval" label="${doApproval_N }" disabled="${doApproval_D }" onClick="doApproval" />--%>
			<%--<e:button id="doRequestTermination" name="doRequestTermination" label="${doRequestTermination_N }" disabled="${doRequestTermination_D }" onClick="doRequestTermination" />--%>
			<%--<e:button id="doTerminationApp" name="doTerminationApp" label="${doTerminationApp_N }" disabled="${doTerminationApp_D }" onClick="doTerminationApp" />--%>
			<%--<e:button id="doTerminationReject" name="doTerminationReject" label="${doTerminationReject_N }" disabled="${doTerminationReject_D }" onClick="getTerminationRejectPopup" />--%>
			<%--<e:button id="doRequestDiscard" name="doRequestDiscard" label="${doRequestDiscard_N }" disabled="${doRequestDiscard_D }" onClick="doRequestDiscard" />--%>
			<%--<e:button id="doDiscardApproval" name="doDiscardApproval" label="${doDiscardApproval_N }" disabled="${doDiscardApproval_D }" onClick="doDiscardApproval" />--%>
			<%--<e:button id="doDiscardReject" name="doDiscardReject" label="${doDiscardReject_N }" disabled="${doDiscardReject_D }" onClick="getDiscardRejectPopup" />--%>
			<%--<e:button id="doCancel" name="doCancel" label="${doCancel_N }" disabled="${doCancel_D }" onClick="doCancel" />--%>
			<%--<e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="doClose" />--%>
		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">

			<e:inputHidden id="mainForm" name="mainForm" value="${param.mainForm}" />
			<e:inputHidden id="additionalForm" name="additionalForm" value="${param.additionalForm}" />

			<%--<e:inputHidden id="FORM_NUM" name="FORM_NUM" value="${param.FORM_NUM}" />--%>
			<%--<e:inputHidden id="CLOSING_TYPE" name="CLOSING_TYPE" value="" />--%>
			<%--<e:inputHidden id="CLOSING_PROGRESS_CD" name="CLOSING_PROGRESS_CD" value="" />--%>
			<%--<e:inputHidden id="CLOSING_REQ_USER_TYPE" name="CLOSING_REQ_USER_TYPE" value="" />--%>
			<%--<e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="" />--%>
			<%--<e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="" />--%>
			<%--<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="" />--%>
			<%--<e:inputHidden id="approvalFormData" name="approvalFormData" value="" />--%>
            <%--<e:inputHidden id="approvalGridData" name="approvalGridData" value="" />--%>
            <%--<e:inputHidden id="isApprovalRequired" name="isApprovalRequired" value="" />--%>
            <%--<e:inputHidden id="buyerSignOrder" name="buyerSignOrder" value="" />--%>
            <%--<e:inputHidden id="toolkit" name="toolkit" value="" />--%>
            <%--<e:inputHidden id="serverSignYN" name="serverSignYN" value="" />--%>
            <%--<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}" />--%>
            <%--<e:inputHidden id="BUYER_NM" name="BUYER_NM" value="${form.BUYER_NM}" />--%>
            <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${empty form.EXEC_NUM ? param.EXEC_NUM : form.EXEC_NUM}" />
            <e:row>
				<e:label for="CONT_NUM" title="${form_CONT_NUM_N }" />
				<e:field>
					<e:inputText id="CONT_NUM" name="CONT_NUM" value="${form.CONT_NUM}" width="70%" required="${form_CONT_NUM_R }" disabled="${form_CONT_NUM_D }" readOnly="${form_CONT_NUM_RO }" maxLength="${form_CONT_NUM_M}" />
					<e:text> / </e:text>
					<e:inputNumber id="CONT_CNT" name="CONT_CNT" value="${form.CONT_CNT}" width="28%" required="${form_CONT_CNT_R }" disabled="${form_CONT_CNT_D }" readOnly="${form_CONT_CNT_RO }" />
				</e:field>
				<%--<e:label for="BUYER_CD" title="${form_BUYER_CD_N }" />--%>
				<%--<e:field>--%>
					<%--<e:inputText id="BUYER_CD" name="BUYER_CD" value="" width="${inputTextWidth }" required="${form_BUYER_CD_R }" disabled="${form_BUYER_CD_D }" readOnly="${form_BUYER_CD_RO }" maxLength="${form_BUYER_CD_M}" />--%>
					<%--<e:inputText id="BUYER_NM" name="BUYER_NM" value="" width="${inputTextWidth }" required="${form_BUYER_NM_R }" disabled="${form_BUYER_NM_D }" readOnly="${form_BUYER_NM_RO }" maxLength="${form_BUYER_NM_M}" />--%>
				<%--</e:field>--%>
				<e:label for="CONT_DESC" title="${form_CONT_DESC_N }" />
				<e:field colSpan="3">
					<e:inputText id="CONT_DESC" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="${form.CONT_DESC}" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_AMT" title="${form_CONT_AMT_N }" />
				<e:field>
					<e:inputNumber id="CONT_AMT" name="CONT_AMT" value="${form.CONT_AMT}" width="100%" required="${form_CONT_AMT_R }" disabled="${form_CONT_AMT_D }" readOnly="${form_CONT_AMT_RO }" />
				</e:field>
				<e:label for="CONT_DATE" title="${form_CONT_DATE_N }" />
				<e:field>
					<e:inputDate id="CONT_DATE" name="CONT_DATE" value="${empty form.CONT_DATE ? toDate : form.CONT_DATE}" width="${inputTextDate }" required="${form_CONT_DATE_R }" readOnly="${form_CONT_DATE_RO }" disabled="${form_CONT_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N }" />
				<e:field>
					<e:inputDate id="CONT_START_DATE" name="CONT_START_DATE" value="${form.CONT_START_DATE}" width="${inputTextDate }" required="${form_CONT_START_DATE_R }" readOnly="${form_CONT_START_DATE_RO }" disabled="${form_CONT_START_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="CONT_END_DATE" name="CONT_END_DATE" value="${form.CONT_END_DATE}" width="${inputTextDate }" required="${form_CONT_END_DATE_R }" readOnly="${form_CONT_END_DATE_RO }" disabled="${form_CONT_END_DATE_D }" datePicker="true" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_USER_ID" title="${form_CONT_USER_ID_N }" />
				<e:field>
					<e:search id="CONT_USER_NM" name="CONT_USER_NM" width="100%" value="${form.CONT_USER_NM}" maxLength="${form_CONT_USER_NM_M }" required="${form_CONT_USER_NM_R }" disabled="${form_CONT_USER_NM_D }" readOnly="${form_CONT_USER_NM_RO }" onIconClick="doSelectDrafter" />
					<e:inputText id="CONT_USER_ID" name="CONT_USER_ID" width="0" value="${form.CONT_USER_ID}" disabled="" maxLength="" readOnly="" required=""/>
				</e:field>
				<e:label for="BUYER_SIGN_DATE" title="${form_BUYER_SIGN_DATE_N }" />
				<e:field>
					<e:inputDate id="BUYER_SIGN_DATE" name="BUYER_SIGN_DATE" value="${form.BUYER_SIGN_DATE}" width="${inputTextDate }" required="${form_BUYER_SIGN_DATE_R }" readOnly="${form_BUYER_SIGN_DATE_RO }" disabled="${form_BUYER_SIGN_DATE_D }" datePicker="false" />
				</e:field>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N }" />
				<e:field>
					<e:search id="VENDOR_NM" name="VENDOR_NM" width="50%" value="${form.VENDOR_NM}" maxLength="${form_VENDOR_NM_M }" required="${form_VENDOR_NM_R }" disabled="${form_VENDOR_NM_D }" readOnly="${form_VENDOR_NM_RO }" onIconClick="doSelectVendor" />
					<e:inputText id="VENDOR_CD" name="VENDOR_CD" width="0" value="${form.VENDOR_CD}" disabled="" maxLength="" readOnly="" required=""/>
					<e:inputText id="VENDOR_PIC_USER_NM" name="VENDOR_PIC_USER_NM" width="50%" required="${form_VENDOR_PIC_USER_NM_R }" disabled="${form_VENDOR_PIC_USER_NM_D }" value="${form.VENDOR_PIC_USER_NM}" readOnly="${form_VENDOR_PIC_USER_NM_RO }" maxLength="${form_VENDOR_PIC_USER_NM_M}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="VENDOR_SIGN_DATE" title="${form_VENDOR_SIGN_DATE_N }" />
				<e:field>
					<e:inputDate id="VENDOR_SIGN_DATE" name="VENDOR_SIGN_DATE" value="${form.VENDOR_SIGN_DATE}" width="${inputTextDate }" required="${form_VENDOR_SIGN_DATE_R }" readOnly="${form_VENDOR_SIGN_DATE_RO }" disabled="${form_VENDOR_SIGN_DATE_D }" datePicker="false" />
				</e:field>
				<c:if test="${ses.userType == 'C'}">
					<e:label for="APPROVAL_FLAG" title="${form_APPROVAL_FLAG_N }" />
					<e:field>
						<e:select id="APPROVAL_FLAG" name="APPROVAL_FLAG" value="${form.APPROVAL_FLAG}" options="${refYN}" readOnly="${form_APPROVAL_FLAG_RO }" width="160" required="${form_APPROVAL_FLAG_R }" disabled="${form_APPROVAL_FLAG_D }" />
					</e:field>
					<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N }" />
					<e:field>
						<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCd}" readOnly="${form_PROGRESS_CD_RO }" width="160" required="${form_PROGRESS_CD_R }" disabled="${form_PROGRESS_CD_D }" />
					</e:field>
				</c:if>
				<c:if test="${ses.userType == 'S'}">
					<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N }" />
					<e:field colSpan="3">
						<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCd}" readOnly="${form_PROGRESS_CD_RO }" width="160" required="${form_PROGRESS_CD_R }" disabled="${form_PROGRESS_CD_D }" />
					</e:field>
				</c:if>
			</e:row>
			<e:row>
				<e:field colSpan="6">
                    <textarea id=cont_content name="cont_content" style="width:100%;">${form.formContents}</textarea>
				</e:field>
			</e:row>
			<e:row>
				<e:field colSpan="6">
					<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="" title="${BECM_030_BUYER_ATTACH_FILE}" />
				<e:field colSpan="2">
					<e:fileManager id="BUYER_ATT_FILE_NUM" height="80" width="100%" fileId="${form.BUYER_ATT_FILE_NUM}" readOnly="${form_BUYER_ATT_FILE_NUM_RO}" bizType="CT" required="${form_BUYER_ATT_FILE_NUM_R}" />
				</e:field>
				<e:label for="" title="${BECM_030_VENDOR_ATTACH_FILE}" />
				<e:field colSpan="2">
					<e:fileManager id="VENDOR_ATT_FILE_NUM" height="80" width="100%" fileId="${form.VENDOR_ATT_FILE_NUM}" readOnly="${form_VENDOR_ATT_FILE_NUM_RO}" bizType="CT" required="${form_VENDOR_ATT_FILE_NUM_R}" />
				</e:field>
			</e:row>
			<%--<e:row>--%>
				<%--<e:label for="ADV_GUAR_FLAG" title="${form_ADV_GUAR_FLAG_N }" />--%>
				<%--<e:field>--%>
					<%--<e:select id="ADV_GUAR_FLAG" name="ADV_GUAR_FLAG" value="" options="${refYN}" readOnly="${form_ADV_GUAR_FLAG_RO }" width="160" required="${form_ADV_GUAR_FLAG_R }" disabled="${form_ADV_GUAR_FLAG_D }" onChange='setGuaranteeButtons' />--%>
				<%--</e:field>--%>
				<%--<e:label for="ADV_GUAR_AMT" title="${form_ADV_GUAR_AMT_N }" />--%>
				<%--<e:field>--%>
					<%--<e:select id="ADV_VAT_FLAG" name="ADV_VAT_FLAG" value="" options="${refYN}" readOnly="${form_ADV_VAT_FLAG_RO }" width="160" required="${form_ADV_VAT_FLAG_R }" disabled="${form_ADV_VAT_FLAG_D }" onChange='setGuaranteeButtons' />--%>
					<%--<e:inputNumber id="ADV_GUAR_AMT" name="ADV_GUAR_AMT" width="${inputTextWidth }" required="${form_ADV_GUAR_AMT_R }" disabled="${form_ADV_GUAR_AMT_D }" value="" readOnly="${form_ADV_GUAR_AMT_RO }" />--%>
				<%--</e:field>--%>
				<%--<e:label for="ADV_GUAR_PERCENT" title="${form_ADV_GUAR_PERCENT_N }" />--%>
				<%--<e:field>--%>
					<%--<e:inputNumber id="ADV_GUAR_PERCENT" name="ADV_GUAR_PERCENT" width="${inputTextWidth }" required="${form_ADV_GUAR_PERCENT_R }" disabled="${form_ADV_GUAR_PERCENT_D }" value="" readOnly="${form_ADV_GUAR_PERCENT_RO }" />--%>
				<%--</e:field>--%>
			<%--</e:row>--%>
			<%--<e:row>--%>
				<%--<e:label for="CONT_GUAR_FLAG" title="${form_CONT_GUAR_FLAG_N }" />--%>
				<%--<e:field>--%>
					<%--<e:select id="CONT_GUAR_FLAG" name="CONT_GUAR_FLAG" value="" options="${refYN}" readOnly="${form_CONT_GUAR_FLAG_RO }" width="160" required="${form_CONT_GUAR_FLAG_R }" disabled="${form_CONT_GUAR_FLAG_D }" onChange='setGuaranteeButtons' />--%>
				<%--</e:field>--%>
				<%--<e:label for="CONT_GUAR_AMT" title="${form_CONT_GUAR_AMT_N }" />--%>
				<%--<e:field>--%>
					<%--<e:select id="CONT_VAT_FLAG" name="CONT_VAT_FLAG" value="" options="${refYN}" readOnly="${form_CONT_GUAR_AMT_RO }" width="160" required="${form_CONT_GUAR_AMT_R }" disabled="${form_CONT_GUAR_AMT_D }" onChange='setGuaranteeButtons' />--%>
					<%--<e:inputNumber id="CONT_GUAR_AMT" name="CONT_GUAR_AMT" width="${inputTextWidth }" required="${form_CONT_GUAR_AMT_R }" disabled="${form_CONT_GUAR_AMT_D }" value="" readOnly="${form_CONT_GUAR_AMT_RO }" />--%>
				<%--</e:field>--%>
				<%--<e:label for="CONT_GUAR_PERCENT" title="${form_CONT_GUAR_PERCENT_N }" />--%>
				<%--<e:field>--%>
					<%--<e:inputNumber id="CONT_GUAR_PERCENT" name="CONT_GUAR_PERCENT" width="${inputTextWidth }" required="${form_CONT_GUAR_PERCENT_R }" disabled="${form_CONT_GUAR_PERCENT_D }" value="" readOnly="${form_CONT_GUAR_PERCENT_RO }" />--%>
				<%--</e:field>--%>
			<%--</e:row>--%>
			<%--<e:row>--%>
				<%--<e:label for="WARR_GUAR_FLAG" title="${form_WARR_GUAR_FLAG_N }" />--%>
				<%--<e:field>--%>
					<%--<e:select id="WARR_GUAR_FLAG" name="WARR_GUAR_FLAG" value="" options="${refYN}" readOnly="${form_WARR_GUAR_FLAG_RO }" width="160" required="${form_WARR_GUAR_FLAG_R }" disabled="${form_WARR_GUAR_FLAG_D }" onChange='setGuaranteeButtons' />--%>
				<%--</e:field>--%>
				<%--<e:label for="WARR_GUAR_AMT" title="${form_WARR_GUAR_AMT_N }" />--%>
				<%--<e:field>--%>
					<%--<e:select id="WARR_VAT_FLAG" name="WARR_VAT_FLAG" value="" options="${refYN}" readOnly="${form_WARR_GUAR_AMT_RO }" width="160" required="${form_WARR_GUAR_AMT_R }" disabled="${form_WARR_GUAR_AMT_D }" onChange='setGuaranteeButtons' />--%>
					<%--<e:inputNumber id="WARR_GUAR_AMT" name="WARR_GUAR_AMT" width="${inputTextWidth }" required="${form_WARR_GUAR_AMT_R }" disabled="${form_WARR_GUAR_AMT_D }" value="" readOnly="${form_WARR_GUAR_AMT_RO }" />--%>
				<%--</e:field>--%>
				<%--<e:label for="WARR_GUAR_PERCENT" title="${form_WARR_GUAR_PERCENT_N }" />--%>
				<%--<e:field>--%>
					<%--<e:inputNumber id="WARR_GUAR_PERCENT" name="WARR_GUAR_PERCENT" width="${inputTextWidth }" required="${form_WARR_GUAR_PERCENT_R }" disabled="${form_WARR_GUAR_PERCENT_D }" value="" readOnly="${form_WARR_GUAR_PERCENT_RO }" />--%>
				<%--</e:field>--%>
			<%--</e:row>--%>
			<%--<e:row>--%>
				<%--<e:label for="WARR_GUAR_QT" title="${form_WARR_GUAR_QT_N }" />--%>
				<%--<e:field colSpan="5">--%>
					<%--<e:inputNumber id="WARR_GUAR_QT" name="WARR_GUAR_QT" width="${inputTextWidth }" required="${form_WARR_GUAR_QT_R }" disabled="${form_WARR_GUAR_QT_D }" value="" readOnly="${form_WARR_GUAR_QT_RO }" />--%>
				<%--</e:field>--%>
			<%--</e:row>--%>
		</e:searchPanel>

		<e:gridPanel gridType="${_gridType}" id="rejectGrid" name="rejectGrid" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.rejectGrid.gridColData}" />

	</e:window>

</e:ui>
