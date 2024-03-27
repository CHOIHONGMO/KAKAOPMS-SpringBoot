<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/eApproval/eApprovalModule/";
    var consultContentsUrl = '';
    var detailView = '';
    var gateCd = '';
    var appDocNum = '';
    var appDocCnt = '';

    function init() {

    	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
    	$('#upload-button-attFile').css('display','none');

        window.focus();

        grid = EVF.C("grid");

        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

        var editor = EVF.C('DOC_CONTENTS').getInstance();
        editor.config.contentsCss  = "/css/richText.css";
        editor.config.allowedContent = true;

        EVF.C('APP_DOC_NUM').setValue("${param.appDocNum}");
        EVF.C('APP_DOC_CNT').setValue("${param.appDocCnt}");
        EVF.C('DOC_TYPE').setValue("${param.docType}");

        doSearch();

        if ('${param.sendBox}' !== 'true') {
            // EVF.C('onCancel').setVisible(false);
            if(EVF.V("MY_SIGN_STATUS") != "P") {
                //EVF.C('onApproval').setVisible(false);
                //EVF.C('onReject').setVisible(false);
            }
        } else {
            // EVF.C('onApproval').setVisible(false);
            // EVF.C('onReject').setVisible(false);
            if ('${param.signStatus}' !== 'P') {
               // EVF.C('onCancel').setVisible(false);
            }
        }
        grid.setProperty('shrinkToFit', true);
    }

    function doSearch() {

    	var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'BAPP_051/doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
            	var data = this.data.formData;
				if(data.ATT_FILE_NUM) {
//					EVF.C('attFile').getUploadedFileInfo(data.DOC_TYPE, data.ATT_FILE_NUM);
				}
            	consultContentsUrl = this.getParameter('consultContentsUrl');
            	screen_id = consultContentsUrl.substring(consultContentsUrl.indexOf('?')+11 ,consultContentsUrl.length );
            	consultContentsUrl = consultContentsUrl.substring(0, consultContentsUrl.indexOf('?')+1);

            	detailView = this.getParameter('detailView');
            	gateCd = this.getParameter('gateCd');
            	appDocNum = this.getParameter('appDocNum');
            	appDocCnt = this.getParameter('appDocCnt');
            	openDocDetail();
            }
        });
    }

	var screen_id;
    function openDocDetail() {
        var store = new EVF.Store();
        store.load(baseUrl + 'BAPP_051/documentRead', function() {
			var width="1150";
			var height="920";
        	if( consultContentsUrl.indexOf('IM02_011') > -1) {
    			width="950";
    			height="420";
        	}
        	if( consultContentsUrl.indexOf('IM01_060') > -1) {
    			width="950";
    			height="420";
        	}

        	everPopup.openWindowPopup(consultContentsUrl, width, height, { detailView : detailView, gateCd : gateCd, appDocNum : appDocNum, appDocCnt : appDocCnt, SCREEN_ID : screen_id, APP_DOC_NUM : appDocNum, APP_DOC_CNT : appDocCnt }, 'appDetail', true, true);
        });
    }

    function onCancel() {
        EVF.C('SUBJECT').setValue(EVF.C('SUBJECT').getValue() + ' ');
        EVF.C('SUBJECT').setValue(EVF.C('SUBJECT').getValue().trim());

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'BAPP_051/doCancel', function() {
            alert(this.getResponseMessage());
            opener.doSelect();
            window.close();
        });
    }

    function doApprovalOrReject(approvalType, signRmk) {

    	EVF.C('SIGN_RMK').setValue(signRmk);

        var store = new EVF.Store();
        store.setParameter('APPROVAL_TYPE', approvalType);
        store.load(baseUrl + 'BAPP_051/doApprovalOrReject', function() {
            alert(this.getResponseMessage());
            onClose();
        });
    }

    function onApproval() {
        everPopup.openApprovalRemarkPopup('E');
    }

    function onReject() {
        everPopup.openApprovalRemarkPopup('R');
    }

    function checkVlidation() {

    	var mySignStatus = EVF.C('MY_SIGN_STATUS').getValue();
        if (mySignStatus === 'E') {
            alert('Approved Item');
            return false;
        }

        if (mySignStatus === 'R') {
            alert('Rejected Item');
            return false;
        }
    }

    function onClose() {
        if (opener !== undefined && opener.doSearch !== undefined) {
            opener.doSearch();
        }
        window.close();
    }

    function doAddLinePop() {
        var param = {
            APP_DOC_NUM: EVF.V("APP_DOC_NUM"),
            APP_DOC_CNT: EVF.V("APP_DOC_CNT")
        };
        var url = "/eversrm/eApproval/eApprovalModule/BAPP_053/view";
        everPopup.openWindowPopup(url, 1100, 400, param, "BAPP_053");
    }

    function doSearchGrid() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'bapp051_doSearchGrid', function() {
        });

    }
    </script>

    <e:window id="BAPP_051" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">

	    	<c:if test="${!param.fCnt and param.sendBox and param.signStatus eq 'P' }">
<%-- 	            <e:button id="onCancel" name="onCancel" label="${onCancel_N }" disabled="${onCancel_D }" onClick="onCancel" /> --%>
			</c:if>
			<c:if test="${!param.sendBox and param.signStatus eq 'P' and formData.SIGN_STATUS ne 'C' }">
	            <e:button id="onApproval" name="onApproval" label="${onApproval_N }" disabled="${onApproval_D }" onClick="onApproval" />
	            <e:button id="onReject" name="onReject" label="${onReject_N }" disabled="${onReject_D }" onClick="onReject" />
	        </c:if>
            <e:button id="openDocDetail" name="openDocDetail" label="${openDocDetail_N }" disabled="${openDocDetail_D }" onClick="openDocDetail" />
            <%--
            <e:button id="onClose" name="onClose" label="${onClose_N }" disabled="${onClose_D }" onClick="onClose" />
            --%>
        </e:buttonBar>

		<e:inputHidden id="DOC_TYPE"       name="DOC_TYPE"			value="${formData.DOC_TYPE }"/>
		<e:inputHidden id="APP_DOC_CNT"    name="APP_DOC_CNT"		value="${formData.APP_DOC_CNT }"/>
		<e:inputHidden id="ATT_FILE_NUM"   name="ATT_FILE_NUM"		value="${formData.ATT_FILE_NUM }"/>
		<e:inputHidden id="SIGN_RMK"       name="SIGN_RMK"/>
		<e:inputHidden id="MY_SIGN_STATUS" name="MY_SIGN_STATUS"	value="${formData.MY_SIGN_STATUS }"/>
		<e:inputHidden id="SIGN_STATUS"    name="SIGN_STATUS"		value="${formData.SIGN_STATUS }"/>
		<e:inputHidden id="DOC_TITLE"      name="DOC_TITLE"			value="${formData.DOC_TITLE }"/>

		<e:searchPanel id="form" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
            <e:row>
                <e:label for="APP_DOC_NUM" title="${form_APP_DOC_NUM_N}"/>
                <e:field>
					<e:inputText id="APP_DOC_NUM" name="APP_DOC_NUM" value="${formData.APP_DOC_NUM }" width="${inputTextWidth }" maxLength="${form_APP_DOC_NUM_M }" required="${form_APP_DOC_NUM_R }" readOnly="${form_APP_DOC_NUM_RO }" disabled="${form_APP_DOC_NUM_D}" visible="${form_APP_DOC_NUM_V}" />
                    <c:if test="${formData.SIGN_STATUS eq 'C' }">
                        <e:text style="color:red;font-weight:bold;">상신취소건 입니다.</e:text>
                    </c:if>
                </e:field>
                <e:label for="IMPORTANCE_STATUS_NM" title="${form_IMPORTANCE_STATUS_NM_N}"/>
                <e:field>
					<e:inputText id="IMPORTANCE_STATUS_NM" name="IMPORTANCE_STATUS_NM" value="${formData.IMPORTANCE_STATUS_NM }" width="${inputTextWidth }" maxLength="${form_IMPORTANCE_STATUS_NM_M }" required="${form_IMPORTANCE_STATUS_NM_R }" readOnly="${form_IMPORTANCE_STATUS_NM_RO }" disabled="${form_IMPORTANCE_STATUS_NM_D}" visible="${form_IMPORTANCE_STATUS_NM_V}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
                <e:field colSpan="3">
					<e:inputText id="SUBJECT" name="SUBJECT" value="${formData.SUBJECT }" width="100%" maxLength="${form_SUBJECT_M }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D}" visible="${form_SUBJECT_V}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
                <e:field>
					<e:inputText id="REG_USER_NM" name="REG_USER_NM" value="${formData.REG_USER_NM }" width="${inputTextWidth }" maxLength="${form_REG_USER_NM_M }" required="${form_REG_USER_NM_R }" readOnly="${form_REG_USER_NM_RO }" disabled="${form_REG_USER_NM_D}" visible="${form_REG_USER_NM_V}" />
                </e:field>
                <e:label for="MOD_DATE" title="${form_MOD_DATE_N}"/>
                <e:field>
					<e:inputText id="MOD_DATE" name="MOD_DATE" value="${formData.MOD_DATE }" width="${inputTextWidth }" maxLength="${form_MOD_DATE_M }" required="${form_MOD_DATE_R }" readOnly="${form_MOD_DATE_RO }" disabled="true" visible="${form_MOD_DATE_V}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="DOC_CONTENTS" title="${form_DOC_CONTENTS_N}"/>
                <e:field colSpan="3">
                	<e:richTextEditor id="DOC_CONTENTS" name="DOC_CONTENTS" value="${formData.DOC_CONTENTS }" width="100%" height="300px" required="${form_DOC_CONTENTS_R }" readOnly="${form_DOC_CONTENTS_RO }" disabled="${form_DOC_CONTENTS_D }" useToolbar="${!param.detailView}" style="${imeMode }" />
                </e:field>
            </e:row>
            <e:row>
                <e:field colSpan="4">
                    <e:fileManager id="attFile" name="attFile" fileId="${formData.ATT_FILE_NUM}" downloadable="true" bizType="APP" height="120px" readOnly="${form_ATT_FILE_NUM_RO}" onSuccess="onSuccess" required="${form_ATT_FILE_NUM_R}"/>
               </e:field>
            </e:row>
		</e:searchPanel>

        <e:button id="doAddLinePop" name="doAddLinePop" label="${doAddLinePop_N}" onClick="doAddLinePop" disabled="${doAddLinePop_D}" visible="${doAddLinePop_V}"/>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>

