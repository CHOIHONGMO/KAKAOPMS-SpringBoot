<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var gridL = {};
        var gridR = {};
        var addParam = [];
        var baseUrl = "/eversrm/eApproval/eApprovalBox/";
        var checkRow = -1;
        var isDevelopmentMode = ${isDevelopmentMode};

        function init() {

            gridL = EVF.C('gridL');
            gridR = EVF.C('gridR');

            gridL.cellChangeEvent(function (rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == 'SIGN_REQ_TYPE') {
                    recountSignSequence();
                }
            });

            gridR.cellClickEvent(function (rowid, colId, value, iRow, iCol) {

                if (colId == 'SIGN_USER_NM') {

                    var selectedData = gridR.getRowValue(rowid);
                    gridR.checkRow(rowid, true);

                    var abc = selectedData.SIGN_USER_ID;
                    var rowIds = gridL.getAllRowId();
                    // for(var i in rowIds) {
                    //     if (gridL.getCellValue(rowIds[i], 'SIGN_USER_ID') == abc) {
                    //         return alert('동일한 사용자가 이미 결재 경로에 존재합니다.');
                    //     }
                    // }

                    var userId = '${ses.userId}';

                    /*if (!isDevelopmentMode && (userId == selectedData.SIGN_USER_ID))  {
                        return alert("기안자 본인을 결재경로에 추가할 수 없습니다.");
                    }*/

                    var addParam = [{
                        SIGN_USER_ID: selectedData.SIGN_USER_ID,
                        SIGN_USER_NM: selectedData.SIGN_USER_NM,
                        DEPT_CD: selectedData.DEPT_CD,
                        DEPT_NM: selectedData.DEPT_NM,
                        POSITION_NM: selectedData.POSITION_NM,
                        DUTY_NM: selectedData.DUTY_NM,
                        COMPANY_NM: selectedData.COMPANY_NM,
                        SIGN_REQ_TYPE: (EVF.C('SIGN_REQ_TYPE').getCheckedValue() == null || EVF.C('SIGN_REQ_TYPE').getCheckedValue() == "") ? "E" : EVF.C('SIGN_REQ_TYPE').getCheckedValue()
                    }];

                    gridL.addRow(addParam);
                    fillFixData('add');
                    recountSignSequence();
                }
            });

            gridL.setProperty('shrinkToFit', false);
            gridR.setProperty('shrinkToFit', false);
            gridR.setProperty('multiselect', false);

            doSearchDecideArbitrarily();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([gridR]);
            store.load(baseUrl + 'userSearch', function () {
                if (gridR.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
                if (gridR.getRowCount() == 1) {

                    EVF.C('SIGN_USER_NM').setValue('');

                    var selectedData = gridR.getRowValue(0);
                    gridR.checkRow(0, true);

                    var rowIds = gridL.getAllRowId();
                    // for(var i in rowIds) {
                    //     if (gridL.getCellValue(rowIds[i], 'SIGN_USER_ID') == selectedData.SIGN_USER_ID) {
                    //         return alert('동일한 사용자가 이미 결재 경로에 존재합니다.');
                    //     }
                    // }
                    var userId = '${ses.userId}';
                    /*if (!isDevelopmentMode && (userId == selectedData.SIGN_USER_ID)) {
                        return alert("기안자 본인을 결재경로에 추가할 수 없습니다.");
                    }*/

                    var addParam = [{
                        SIGN_USER_ID: selectedData.SIGN_USER_ID,
                        SIGN_USER_NM: selectedData.SIGN_USER_NM,
                        SIGN_USER_NM_$TP: selectedData.SIGN_USER_NM,
                        DEPT_CD: selectedData.DEPT_CD,
                        DEPT_NM: selectedData.DEPT_NM,
                        POSITION_NM: selectedData.POSITION_NM,
                        DUTY_NM: selectedData.DUTY_NM,
                        COMPANY_NM: selectedData.COMPANY_NM,
                        SIGN_REQ_TYPE: (EVF.C('SIGN_REQ_TYPE').getCheckedValue() == null || EVF.C('SIGN_REQ_TYPE').getCheckedValue() == "") ? "E" : EVF.C('SIGN_REQ_TYPE').getCheckedValue()
                    }];

                    gridL.addRow(addParam);

                    fillFixData('add');
                    recountSignSequence();
                }
            });
        }

        function doSearchDecideArbitrarily() {

            var confirmMsg = ("${param.screenId}" == "BOD1_030" ? "${BAPP_550_M008}" : "${BAPP_550_M007}");

            if (EVF.isEmpty("${param.bizCls1}") || EVF.isEmpty("${param.bizCls2}") || EVF.isEmpty("${param.bizCls3}") || EVF.isEmpty("${param.bizAmt}")) return;

            var store = new EVF.Store();
            store.setParameter('bizCls1', '${param.bizCls1}');
            store.setParameter('bizCls2', '${param.bizCls2}');
            store.setParameter('bizCls3', '${param.bizCls3}');
            store.setParameter('bizAmt', '${param.bizAmt}');
            store.setParameter('bizRate', '${param.bizRate}');
            store.setParameter('reqUserId', '${param.reqUserId}');
            store.setParameter('prSubject','${param.prSubject}')

            store.setGrid([gridL]);
            store.load(baseUrl + 'doSearchDecideArbitrarily', function () {
                if(this.getParameter("appFlag") == "N" && 1 == 2) {// 대명은 전결 없음.
                    if(confirm(confirmMsg)) {
                        var gridData = gridL.getSelRowValue();
                        var formData = {
                            DOC_TYPE: (EVF.isEmpty(EVF.C('DOC_TYPE').getValue()) ? "" : EVF.C('DOC_TYPE').getValue()),
                            SIGN_STATUS: "E"
                        };
                        var attachData = [{"UUID": ""}];
                        opener.window.focus();
                        opener.window['${param.callBackFunction}'](JSON.stringify(formData), JSON.stringify(gridData), JSON.stringify(attachData));
                        window.close();
                    }
                }
                else {
                    recountSignSequence();
                    gridR.showCheckBar(false);
                }
            }, false);
        }

        function doSearchSync() {

            if ('${param.USER_IDS}' == '') return;

            var store = new EVF.Store();
            store.setParameter('USER_IDS', '${param.USER_IDS}');
            store.setGrid([gridL]);
            store.load(baseUrl + 'doSearchSync', function () {
                recountSignSequence();
                gridR.showCheckBar(false);
            }, true);
        }

        function doApprovalRequest() {

            gridL.checkAll(true);

            if (gridL.getSelRowCount() == 0) { return alert("${BAPP_550_M006}"); }

            if (!gridL.validate().flag) { return alert(gridL.validate().msg); }

            <%--
            if (!${isDevelopmentMode }) {
                var kkk = gridL.getSelRowValue();
                for (k = 0; k < kkk.length; k++) {
                    if (kkk[k].SIGN_REQ_TYPE == 'E' || kkk[k].SIGN_REQ_TYPE == 'A') {
                        if (kkk[k].SIGN_USER_ID == '${ses.userId}') {
                            return alert("${BAPP_550_M005}");
                        }
                    }
                }
            }
            --%>

            if (confirm("${param.approvalType }" == "NOTICE" ? "${msg.M0099 }" : "${msg.M0100 }")) {

                var gridData = gridL.getSelRowValue();

                var store = new EVF.Store();
                if (!store.validate()) return;
				store.doFileUpload(function() {
	                var formData = {
	                        SUBJECT: (EVF.isEmpty(EVF.C('SUBJECT').getValue()) ? "" : EVF.C('SUBJECT').getValue()),
	                        DOC_CONTENTS: (EVF.isEmpty(EVF.C('DOC_CONTENTS').getValue()) ? "" : EVF.C('DOC_CONTENTS').getValue()),
	                        CONTENTS_TEXT_NUM: (EVF.isEmpty(EVF.C('CONTENTS_TEXT_NUM').getValue()) ? "" : EVF.C('CONTENTS_TEXT_NUM').getValue()),
	                        ATT_FILE_NUM: EVF.C('ATT_FILE_NUM').getValue(),
	                        IMPORTANCE_STATUS: (EVF.isEmpty(EVF.C('IMPORTANCE_STATUS').getValue()) ? "" : EVF.C('IMPORTANCE_STATUS').getValue()),
	                        DOC_NUM: (EVF.isEmpty(EVF.C('DOC_NUM').getValue()) ? "" : EVF.C('DOC_NUM').getValue()),
	                        DOC_TYPE: (EVF.isEmpty(EVF.C('DOC_TYPE').getValue()) ? "" : EVF.C('DOC_TYPE').getValue()),
	                        SIGN_STATUS: (EVF.isEmpty(EVF.C('SIGN_STATUS').getValue()) ? "" : EVF.C('SIGN_STATUS').getValue()),
	                        DOC_ATT_FILE_NUM: (EVF.isEmpty(EVF.C('DOC_ATT_FILE_NUM').getValue()) ? "" : EVF.C('DOC_ATT_FILE_NUM').getValue()),
	                        SCREEN_ID: (EVF.isEmpty(EVF.C('SCREEN_ID').getValue()) ? "" : EVF.C('SCREEN_ID').getValue()),
	                        DOC_SUB_TYPE: (EVF.isEmpty(EVF.C('DOC_SUB_TYPE').getValue()) ? "" : EVF.C('DOC_SUB_TYPE').getValue()),
	                        APP_DOC_NUM: (EVF.isEmpty(EVF.C('APP_DOC_NUM').getValue()) ? "" : EVF.C('APP_DOC_NUM').getValue()),
	                        CUST_CD: (EVF.isEmpty(EVF.C('CUST_CD').getValue()) ? "" : EVF.C('CUST_CD').getValue())
	                    };
	                    var attachData = [{"UUID": EVF.C('UUID').getValue()}];
	                    opener.window.focus();
	                    opener.window['${param.callBackFunction}'](JSON.stringify(formData), JSON.stringify(gridData), JSON.stringify(attachData));
	                    window.close();
				});
            }
        }

        <%-- @description 행 추가/삭제 시 호출된다. @param flag add, del --%>
        function fillFixData(flag) {
            fillImgUrl(flag);
        }

        <%-- 결재 순번 계산 --%>
        function recountSignSequence() {

            <%-- 병렬타입의 행을 만났는지 여부 --%>
            var isBeforeArrangeAgree = false;
            var isBeforeArrangeApproval = false;
            var rowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
            var selectedRowIdx = [];
            for (var i = 0, pathSq = 0; i < rowIds.length; i++) {
                var rowData = gridL.getRowValue(rowIds[i]);
                var signReqType = rowData['SIGN_REQ_TYPE'];
                <%-- 병렬결재 혹은 병렬합의면 번호를 증가시키지 않는다. --%>
                if (signReqType === 'P') {
                    if (!isBeforeArrangeAgree) {
                        pathSq++;
                        isBeforeArrangeAgree = true;
                    }
                } else {
                    pathSq++;
                    isBeforeArrangeAgree = false;
                    isBeforeArrangeApproval = false;
                }

                var checkFlag = rowData['CHECK_FLAG'];
                if (checkFlag == '1') {
                    selectedRowIdx.push(rowIds[i]);
                }

                gridL.setCellValue(rowIds[i], "CHECK_FLAG", "");
                gridL.setCellValue(rowIds[i], 'SIGN_PATH_SQ', pathSq);
            }

            var allRowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
            for (var j = 0; j < allRowIds.length; j++) {
                gridL.setCellValue(allRowIds[j], 'CHECK_FLAG', ' ');
            }

            gridL.checkAll(false);

            for (var k = 0; k < selectedRowIdx.length; k++) {
                gridL.checkRow(selectedRowIdx[k], true);
            }
        }

        function fillImgUrl(flag) {
            if (flag == 'add') {
                var rowIds = gridL.jsonToArray(gridL.getSelRowId()).value;
                for (var i = 0; i < rowIds.length; i++) {
                    gridL.setCellValue(rowIds[i], 'SIGN_USER_NM_IMG', {src: '/images/icon/grid_search.gif', test: ''});
                }
            }
            else {
                var checkRowData = gridL.getSelRowId();
                var argData = gridL.jsonToArray(checkRowData).value;
                for (var j = 0; j < argData.length; j++) {
                    gridL.setCellValue(argData[j], 'SIGN_USER_NM_IMG', {src: '/images/icon/grid_search.gif'});
                }
            }
        }

        <%-- 병렬 버튼 --%>
//        function doArranging() {
//            doChangeArg("A");
//        }

        <%-- 병렬해제 버튼 --%>
//        function doCancelArg() {
//            doChangeArg("D");
//        }

        <%--function doChangeArg(argVal) {--%>

            <%--&lt;%&ndash; docSubType - 결재 : E, 합의 : A,  병렬결재 : P, 참조 : CC &ndash;%&gt;--%>
            <%--var argData = gridL.jsonToArray(gridL.getSelRowId()).value;--%>

            <%--if (argData.length < 2) {--%>
                <%--return alert("${msg.M0106 }");--%>
            <%--}--%>
            <%--<!-- 병렬 -->--%>
            <%--if (argVal == "A") {--%>

                <%--for (var i = 0; i < argData.length; i++) {--%>
                    <%--if (gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE') != "E" /*&& gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE') != "A"*/) {--%>
                        <%--return alert("${msg.M0107 }");--%>
                    <%--}--%>
                <%--}--%>

                <%--for (var i = 0; i < argData.length; i++) {--%>
                    <%--var beforeReqType = gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE');--%>
                    <%--if(beforeReqType=="E"){--%>
                        <%--gridL.setCellValue(argData[i], 'SIGN_REQ_TYPE', beforeReqType == "E" ? "P" : "E");--%>
                    <%--}else if(beforeReqType=="A"){--%>
                        <%--//gridL.setCellValue(argData[i], 'SIGN_REQ_TYPE', beforeReqType == "A" ? "P" : "A");--%>
                    <%--}--%>

                <%--}--%>
            <%--}--%>
            <%--<!-- 병렬해제 -->--%>
            <%--else if (argVal == "D") {--%>
                <%--for (var i = 0; i < argData.length; i++) {--%>
                    <%--var beforeReqType = gridL.getCellValue(argData[i], 'SIGN_REQ_TYPE');--%>
                    <%--gridL.setCellValue(argData[i], 'SIGN_REQ_TYPE', beforeReqType == "P" ? "E" : "E");--%>
                <%--}--%>
            <%--}--%>
            <%--recountSignSequence();--%>
            <%--fillFixData('add');--%>
        <%--}--%>

        function doDelete() {

            if (gridL.getSelRowId() == null) { return alert("${msg.M0004}"); }

            if(!isDevelopmentMode) {
                var rowIds = gridL.getSelRowId();
                for(var i in rowIds) {
                    if(gridL.getCellValue(rowIds[i], 'DECIDE_FLAG') == "Y") {
                        return alert("${BAPP_550_M009}");
                    }
                }
            }
            gridL.delRow();
            recountSignSequence();
        }

        function doUp() {

            if (gridL.getSelRowCount() == 0) {
                return alert("${msg.M0004}");
            }
            if (gridL.getSelRowCount() > 1) {
                return alert("${msg.M0006}");
            }

            var selectedRowId = gridL.jsonToArray(gridL.getSelRowId()).value[0]
                , selectedRowData = gridL.getRowValue(selectedRowId);

            var signReqType = selectedRowData['SIGN_REQ_TYPE'];
            if (signReqType === 'P') {
                return alert('병렬의 건은 이동시키실 수 없습니다.');
            }

            var decideFlag = selectedRowData['DECIDE_FLAG'];
            if (decideFlag === "Y") {
                return alert('전결 결재자는 이동시키실 수 없습니다.');
            }

            gridL.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.setParameter('sortType', 'up');
            store.getGridData(gridL, 'all');
            store.load(baseUrl + '/getRealignmentApprovalList', function () {
                gridL.checkAll(false);
                recountSignSequence();
            }, false);
        }

        function doDown() {

            if (gridL.getSelRowCount() == 0) {
                return alert("${msg.M0004}");
            }
            if (gridL.getSelRowCount() > 1) {
                return alert("${msg.M0006}");
            }

            var selectedRowId = gridL.jsonToArray(gridL.getSelRowId()).value[0]
                , selectedRowData = gridL.getRowValue(selectedRowId);

            var signReqType = selectedRowData['SIGN_REQ_TYPE'];
            if (signReqType === 'P' ) {
                return alert('병렬의 건은 이동시키실 수 없습니다.');
            }

            var decideFlag = selectedRowData['DECIDE_FLAG'];
            if (decideFlag === "Y") {
                return alert('전결 결재자는 이동시키실 수 없습니다.');
            }

            gridL.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.setParameter('sortType', 'down');
            store.getGridData(gridL, 'all');
            store.load(baseUrl + '/getRealignmentApprovalList', function () {
                gridL.checkAll(false);
                recountSignSequence();
            }, false);
        }

        function getMyApprovalPath() {
            everPopup.openMyApprovalPathPopup();
        }

        function myApprovalPathCallBack(dataJsonArray) {

            dataJsonArray = $.parseJSON(dataJsonArray);

            if(!EVF.isEmpty(dataJsonArray)) {
                EVF.V("DOC_CONTENTS", dataJsonArray.SIGN_RMK);
            }

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.setParameter('strApprovalPathKey', JSON.stringify(dataJsonArray));
            store.load(baseUrl + 'BAPP_550/doSelectMyPath', function () {
                fillFixDataL();
            });
        }

        function fillFixDataL() {
            fillPathSeq();
            fillImgUrl('add');
        }

        function fillPathSeq() {
            var seq = 1;
            var rowIds = gridL.getAllRowId();
            for (var i in rowIds) {
                var check = gridL.multiSelTest(i);
                gridL.setCellValue(i, 'SIGN_PATH_SQ', seq++);
            }
        }

        function doClose() {
            window.close();
        }

    </script>
    <e:window id="BAPP_550" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="CONTENTS_TEXT_NUM" name="CONTENTS_TEXT_NUM" value=""/>
        <e:inputHidden id="UUID" name="UUID" value=""/>
        <e:inputHidden id="DOC_NUM" name="DOC_NUM" value="${param.docNum }"/>
        <e:inputHidden id="DOC_TYPE" name="DOC_TYPE" value="${param.docType }"/>
        <e:inputHidden id="DOC_ATT_FILE_NUM" name="DOC_ATT_FILE_NUM" value="${param.attFileNum }"/>
        <e:inputHidden id="DOC_SUB_TYPE" name="DOC_SUB_TYPE" value="${param.approvalType }"/>
        <e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="${param.screenId }"/>
        <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${param.signStatus }"/>
        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.appDocNum }"/>
        <e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd}"/>
        <e:inputHidden id="BIZ_CLS1" name="BIZ_CLS1" value="${param.bizCls1}"/>
        <e:inputHidden id="BIZ_CLS2" name="BIZ_CLS2" value="${param.bizCls2}"/>
        <e:inputHidden id="BIZ_CLS3" name="BIZ_CLS3" value="${param.bizCls3}"/>
        <e:inputHidden id="IMPORTANCE_STATUS" name="IMPORTANCE_STATUS" value="N"/>

        <e:buttonBar id="buttonBarTop" width="100%" title="${form_FORM_CAPTION_N }">
            <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" align="right" onClick="doClose"/>
            <e:button id="ApprovalRequest" name="ApprovalRequest" label="${ApprovalRequest_N }" disabled="${ApprovalRequest_D }" align="right" onClick="doApprovalRequest"/>
        </e:buttonBar>

        <e:searchPanel id="form1" title="" columnCount="2" labelWidth="120" useTitleBar="false">
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N }"/>
                <e:field colSpan="3">
                    <e:inputText id="SUBJECT" style="${imeMode }" name="SUBJECT" width="100%" maxLength="${form_SUBJECT_M }" value="${param.subject }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D }"/>
                </e:field>
            </e:row>
            <c:if test="${param.approvalType == 'APPROVAL'}">
                <e:row>
                    <e:label for="OPINION" title="${form_OPINION_N}"></e:label>
                    <e:field colSpan="3">
                    	<e:richTextEditor id="DOC_CONTENTS" name="DOC_CONTENTS" width="100%" height="300px" value="" required="${form_OPINION_R }" readOnly="${form_OPINION_RO }" disabled="${form_OPINION_D }" useToolbar="${!param.detailView}" style="${imeMode }" />
                    </e:field>
                </e:row>
            </c:if>
            <c:if test="${param.approvalType != 'APPROVAL'}">
                <e:inputHidden id="DOC_CONTENTS" name="DOC_CONTENTS"/>
            </c:if>

            <c:if test="${param.approvalType == 'APPROVAL'}">
                <e:row>
                    <e:label for="SIGN_USER_NM" title="${form_SIGN_USER_NM_N }"/>
                    <e:field>
                        <e:inputText id="SIGN_USER_NM" name="SIGN_USER_NM" value="" width="86%" maxLength="${form_SIGN_USER_NM_M}" required="${form_SIGN_USER_NM_R }" readOnly="${form_SIGN_USER_NM_RO }" disabled="${form_SIGN_USER_NM_D }" style="${imeMode }" onEnter="doSearch"/>
                        &nbsp;
                        <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch"/>
                    </e:field>
                    <e:label for="DEPT_CD" title="${form_DEPT_CD_N }"/>
                    <e:field>
                        <e:inputText id="DEPT_CD" style="${imeMode }" name="DEPT_CD" value="" width="86%" readOnly="${form_DEPT_CD_RO }" maxLength="${form_DEPT_CD_M}" required="${form_DEPT_CD_R }" disabled="${form_DEPT_CD_D }" onFocus="onFocus" onEnter="doSearch"/>
                        &nbsp;
                        <e:button id="Search1" name="Search1" label="${Search_N }" disabled="${Search_D }" onClick="doSearch"/>
                    </e:field>
                </e:row>
            </c:if>
            <c:if test="${param.approvalType != 'APPROVAL'}">
                <e:row>
                    <e:label for="SIGN_USER_NM" title="${form_SIGN_USER_NM_N }"/>
                    <e:field colSpan="3">
                        <e:inputText id="SIGN_USER_NM" style="${imeMode }" name="SIGN_USER_NM" width="150" maxLength="${form_SIGN_USER_NM_M}" required="${form_SIGN_USER_NM_R }" readOnly="${form_SIGN_USER_NM_RO }" disabled="${form_SIGN_USER_NM_D }" onEnter="doSearch"/>
                        &nbsp;&nbsp;
                        <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch"/>
                    </e:field>
                </e:row>
                <e:inputHidden id="SIGN_REQ_TYPE" name="SIGN_REQ_TYPE" value="R"/>
            </c:if>
            <e:row>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
				<e:field colSpan="3">
			        <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView ? true : false}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="APP" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>

        </e:searchPanel>

		<e:panel id="bg1" width="59%">
            <e:buttonBar id="buttonBarBottom" align="left" width="100%">
	            <e:button id="getMyApprovalPath" name="getMyApprovalPath" label="${getMyApprovalPath_N }" disabled="${getMyApprovalPath_D }" onClick="getMyApprovalPath"/>
	            <e:button id="Up" name="Up" label="${Up_N }" disabled="${Up_D }" onClick="doUp"/>
	            <e:button id="Down" name="Down" label="${Down_N }" disabled="${Down_D }" onClick="doDown"/>
	            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete"/>
	            <%--<e:button id="Arranging" name="Arranging" label="${Arranging_N }" disabled="${Arranging_D }" onClick="doArranging"/>--%>
	            <%--<e:button id="CancelArg" name="CancelArg" label="${CancelArg_N }" disabled="${CancelArg_D }" onClick="doCancelArg"/>--%>
	        </e:buttonBar>
        </e:panel>
        <e:panel id="null1" width="1%">&nbsp;</e:panel>
        <e:panel id="bg2" width="40%">
        	<e:text style="font-weight:bold;">[${form_SIGN_REQ_TYPE_N }]&nbsp;&nbsp;</e:text>
            <e:radioGroup id="SIGN_REQ_TYPE" name="SIGN_REQ_TYPE" disabled="" readOnly="" required="">
                <e:radio id="R1" name="R1" label="결재" value="E" checked="true" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }"/>
                <e:radio id="R2" name="R2" label="합의" value="A" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }"/>
                <e:radio id="R4" name="R4" label="참조" value="CC" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }"/>
            </e:radioGroup>
        </e:panel>

        <e:panel id="fg1" width="59%">
            <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
        </e:panel>
        <e:panel id="null2" width="1%">&nbsp;</e:panel>
        <e:panel id="fg2" width="40%">
            <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
        </e:panel>

    </e:window>
</e:ui>