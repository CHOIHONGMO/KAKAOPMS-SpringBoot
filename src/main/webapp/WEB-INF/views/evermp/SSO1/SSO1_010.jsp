<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var gridT;
        var gridB;
        var rfqNum;
        var rfqCnt;
        var progressCd;
        var sendFlag;
        var selRow;
        var eventRow = -1;
        var baseUrl = "/evermp/SSO1/";

        function init() {

            gridT = EVF.C("gridT");
            gridB = EVF.C("gridB");

            gridT.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == 'multiSelect' && value =='1') {
                    gridBLoad(rowId);
                }
                if(colId == 'RFQ_SUBJECT') {
                	gridT.checkAll(false);
                    gridT.checkRow(rowId, true);
                    
                    rfqNum = gridT.getCellValue(rowId, 'RFQ_NUM');
                    rfqCnt = gridT.getCellValue(rowId, 'RFQ_CNT');
                    progressCd = gridT.getCellValue(rowId, 'PROGRESS_CD')
                    sendFlag = gridT.getCellValue(rowId, 'SEND_FLAG');

                    if( progressCd != "200" ) {	// 견적중
                        EVF.C('Send').setDisabled(true);
                        EVF.C('GiveUp').setDisabled(true);
                    } else {
                        EVF.C('Send').setDisabled(false);
                        EVF.C('GiveUp').setDisabled(false);
                    }

                    var store = new EVF.Store();
                    store.setParameter("RFQ_NUM", gridT.getCellValue(rowId, 'RFQ_NUM'));
                    store.setParameter("RFQ_CNT", gridT.getCellValue(rowId, 'RFQ_CNT'));
                    store.setGrid([gridB]);
                    store.load(baseUrl + "sso1010_doSearchB", function () {
                        var rowIds = gridB.getAllRowId();
                        for(var i in rowIds) {
                            if(gridB.getCellValue(rowIds[i], 'SETTLE_FLAG') == "Y") {
                                gridB.setCellFontColor(rowIds[i], 'SETTLE_FLAG', "#ff6928");
                                gridB.setCellFontWeight(rowIds[i], "SETTLE_FLAG", true);
                            }
                        }
                    }, false);
                }
                if(colId == 'CTRL_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: gridT.getCellValue(rowId, 'CTRL_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'RMK_TEXT_NUM_IMG') {
                    if(!EVF.isEmpty(gridT.getCellValue(rowId, "RMK_TEXT_NUM"))) {
                        var param = {
                             rowId : rowId
                            ,havePermission : true
                            ,screenName : "${SSO1_010_003}"
                            ,callBackFunction : ''
                            ,largeTextNum : gridT.getCellValue(rowId, "RMK_TEXT_NUM")
                            ,detailView : true
                        };
                        everPopup.openPopupByScreenId('commonRichTextContents', 900, 600, param);
                    }
                }
                if(colId == 'EXTEND_RMK_IMG') {
                    if(!EVF.isEmpty(gridT.getCellValue(rowId, "EXTEND_RMK"))) {
                        var param = {
                            title: "${SSO1_010_004}",
                            message: gridT.getCellValue(rowId, 'EXTEND_RMK')
                        };
                        everPopup.openModalPopup('/common/popup/common_text_view/view', 500, 300, param);
                    }
                }
                if(colId == 'ATT_FILE_CNT') {
                    if(Number(gridT.getCellValue(rowId, "ATT_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridT.getCellValue(rowId, 'ATT_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'RFQ',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
            });

            gridB.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        ITEM_CD: gridB.getCellValue(rowId, "ITEM_CD"),
                        popupFlag: true,
                        detailView: true
                    };
                    everPopup.im03_014open(param);
                }
                if(colId == 'VENDOR_REGION_NM') {

                    var param = {
                        VENDOR_REGION_CD : gridB.getCellValue(rowId, 'VENDOR_REGION_CD'),
                        QTA_UNIT_PRC : gridB.getCellValue(rowId, 'QTA_UNIT_PRC'),
                        LEADTIME : gridB.getCellValue(rowId, 'LEADTIME'),
                        LEADTIME_CD : gridB.getCellValue(rowId, 'LEADTIME_CD'),
                        MOQ_QT : gridB.getCellValue(rowId, 'MOQ_QT'),
                        RV_QT : gridB.getCellValue(rowId, 'RV_QT'),
                        TAX_CD : gridB.getCellValue(rowId, 'TAX_CD'),
                        QTA_REMARK : gridB.getCellValue(rowId, 'QTA_REMARK'),
                        LEADTIME_RMK : gridB.getCellValue(rowId, 'LEADTIME_RMK'),
                        callbackFunction: 'setRegionInfo',
                        'rowId': rowId,
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("SSO1_011", 1000, 300, param);
                }
                if(colId == 'LEADTIME_RMK') {
                    var param = {
                        title: "${SSO1_010_005 }",
                        message: gridB.getCellValue(rowId, 'LEADTIME_RMK'),
                        callbackFunction: 'setRMKL',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                if(colId == 'RQDT_ATT_FILE_CNT') {
                    if(Number(gridT.getCellValue(rowId, "RQDT_ATT_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridB.getCellValue(rowId, 'RQDT_ATT_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'VENDOR',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == 'QTA_FILE_CNT') {
                    var param = {
                        havePermission: true,
                        attFileNum: gridB.getCellValue(rowId, 'QTA_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: 'fileAttachPopupCallback',
                        bizType: 'QTA',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'QTA_REMARK') {
                    var param = {
                        title: "${SSO1_010_006 }",
                        message: gridB.getCellValue(rowId, 'QTA_REMARK'),
                        callbackFunction: 'setRMKQ',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                if(colId == 'GIVEUP_REASON') {
                    var param = {
                        title: "${SSO1_010_007 }",
                        message: gridB.getCellValue(rowId, 'GIVEUP_REASON'),
                        callbackFunction: 'setRMKG',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
            });

            gridT.setProperty('shrinkToFit', true);
            gridT.setProperty('multiSelect', true);
            gridB.setProperty('multiSelect', false);

            gridT.setColIconify("RMK_TEXT_NUM_IMG", "RMK_TEXT_NUM", "comment", false);
            gridT.setColIconify("EXTEND_RMK_IMG", "EXTEND_RMK", "comment", false);
            gridB.setColIconify("LEADTIME_RMK", "LEADTIME_RMK", "comment", false);
            gridB.setColIconify("QTA_REMARK", "QTA_REMARK", "comment", false);
            gridB.setColIconify("GIVEUP_REASON", "GIVEUP_REASON", "comment", false);

            gridT.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            gridB.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            if('${param.dashBoardFlag}' == 'Y'){
                EVF.V('PROGRESS_CD', '200');
            }

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            
            store.setGrid([gridT]);
            store.load(baseUrl + "sso1010_doSearchT", function () {
                if(gridT.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                var rowIds = gridT.getAllRowId();
                for(var i in rowIds) {
                    if(gridT.getCellValue(rowIds[i], 'SETTLE_FLAG_NM') == "Y") {
                        gridT.setCellFontColor(rowIds[i], 'SETTLE_FLAG_NM', "#ff6928");
                        gridT.setCellFontWeight(rowIds[i], "SETTLE_FLAG_NM", true);
                    }
                }
            });
        }

        function gridBLoad(rowId){
            rfqNum = gridT.getCellValue(rowId, 'RFQ_NUM');
            rfqCnt = gridT.getCellValue(rowId, 'RFQ_CNT');
            progressCd = gridT.getCellValue(rowId, 'PROGRESS_CD');
            sendFlag = gridT.getCellValue(rowId, 'SEND_FLAG');

            if(rowId!=eventRow){
                gridT.checkRow(eventRow, false);
                eventRow = rowId;
            }

            if( progressCd != "200" ) {	// 견적중
                EVF.C('Send').setDisabled(true);
                EVF.C('GiveUp').setDisabled(true);
            } else {
                EVF.C('Send').setDisabled(false);
                EVF.C('GiveUp').setDisabled(false);
            }

            var store = new EVF.Store();
            store.setParameter("RFQ_NUM", gridT.getCellValue(rowId, 'RFQ_NUM'));
            store.setParameter("RFQ_CNT", gridT.getCellValue(rowId, 'RFQ_CNT'));
            store.setGrid([gridB]);
            store.load(baseUrl + "sso1010_doSearchB", function () {
                var rowIds = gridB.getAllRowId();
                for(var i in rowIds) {
                    if(gridB.getCellValue(rowIds[i], 'SETTLE_FLAG') == "Y") {
                        gridB.setCellFontColor(rowIds[i], 'SETTLE_FLAG', "#ff6928");
                        gridB.setCellFontWeight(rowIds[i], "SETTLE_FLAG", true);
                    }
                }
            }, false);
        }

        function doSend() {

            gridB.checkAll(true);

            if(EVF.isEmpty(rfqNum) || rfqNum == '') { return alert("${SSO1_010_024}"); }

            var firstSendFlag = "Y";
            var qtaNum = "";
            var rowIds = gridB.getSelRowId();

            for(var i in rowIds) {
            	if( progressCd != "200" ) {	// 견적중
                    return alert("${SSO1_010_021}");	// 300: 견적마감
                }
                if(sendFlag == "150" || sendFlag == "300"){
                    return alert("${SSO1_010_031}");
                }
                if(!EVF.isEmpty(gridB.getCellValue(rowIds[i], 'QTA_NUM'))) {
                    firstSendFlag = "N";
                    qtaNum = gridB.getCellValue(rowIds[i], 'QTA_NUM');
                }
                if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'GIVEUP_FLAG'))) {
                    return alert("'" + gridB.getCellValue(rowIds[i], 'ITEM_DESC') + "'" + "${SSO1_010_016}");
                }
                if(gridB.getCellValue(rowIds[i], 'GIVEUP_FLAG') == "0") {
                    /**
                     * 2022.11.09 : 제외
                	if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'VENDOR_REGION_CD')) || gridB.getCellValue(rowIds[i], 'VENDOR_REGION_NM') == "N") {
                        return alert("${SSO1_010_008}");
                    }
                    if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'LEADTIME_CD'))) {
                        return alert("${SSO1_010_011}");
                    }
                    if(gridB.getCellValue(rowIds[i], 'LEADTIME_CD') == "50" && EVF.isEmpty(gridB.getCellValue(rowIds[i], 'LEADTIME_RMK'))) {
                        return alert("${SSO1_010_012}");
                    }*/

                    if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'QTA_UNIT_PRC')) || gridB.getCellValue(rowIds[i], 'QTA_UNIT_PRC') == 0 || gridB.getCellValue(rowIds[i], 'QTA_UNIT_PRC') == "0") {
                        return alert("${SSO1_010_009}");	// 견적단가를 입력하세요.
                    }
                    if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'LEADTIME')) || gridB.getCellValue(rowIds[i], 'LEADTIME') == 0 || gridB.getCellValue(rowIds[i], 'LEADTIME') == "0") {
                        return alert("${SSO1_010_010}");	// 표준납기를 입력하세요.
                    }
                    if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'MOQ_QT')) || gridB.getCellValue(rowIds[i], 'MOQ_QT') == 0 || gridB.getCellValue(rowIds[i], 'MOQ_QT') == "0") {
                        return alert("${SSO1_010_013}");	// 최소주문수량을 입력하세요.
                    }
                    if(Number(gridB.getCellValue(rowIds[i], 'MOQ_QT')) < 0) {
                        return alert("${SSO1_010_027}");	// 최소주문수량에는 음수를 입력할 수 없습니다.
                    }
                    if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'RV_QT')) || gridB.getCellValue(rowIds[i], 'RV_QT') == 0 || gridB.getCellValue(rowIds[i], 'RV_QT') == "0") {
                        //return alert("${SSO1_010_014}");	// 주문배수를 입력하세요.
                    }
                    if(Number(gridB.getCellValue(rowIds[i], 'RV_QT')) < 0) {
                        //return alert("${SSO1_010_028}");	// 주문배수에는 음수를 입력할 수 없습니다.
                    }
                    if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'TAX_CD'))) {
                        return alert("${SSO1_010_015}");	// 과세구분을 선택하세요.
                    }
                }
                if(gridB.getCellValue(rowIds[i], 'GIVEUP_FLAG') == "1" && EVF.isEmpty(gridB.getCellValue(rowIds[i], 'GIVEUP_REASON'))) {
                    return alert("${SSO1_010_019}");	// 견적포기시 포기사유를 입력하셔야 합니다.
                }
                if(EVF.isEmpty(gridB.getCellValue(rowIds[i], 'QTA_REMARK'))){
                    return alert("${SSO1_010_032}"); // 공급사 특이사항을 입력하세요.
                }
            }

            if(!confirm('${SSO1_010_018}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'all');
            store.setParameter("firstSendFlag", firstSendFlag);
            store.setParameter("RFQ_NUM", rfqNum);
            store.setParameter("RFQ_CNT", rfqCnt);
            store.setParameter("QTA_NUM", qtaNum);
            store.setParameter("giveUpFlag", "N");
            store.load(baseUrl + 'sso1010_doSend', function() {
                alert(this.getResponseMessage());
                gridB.delAllRow();
                doSearch();
            });
        }

        function doGiveUp() {
            if(EVF.isEmpty(rfqNum) || rfqNum == '') { return alert("${SSO1_010_025}"); }

            if( progressCd != "200" ) {	// 견적중
            	return alert("${SSO1_010_021}"); // 300: 견적마감
            }

            if(progressCd == "200" && sendFlag != "100"){ //견적중이면서 미접수가 아니면
                return alert("${SSO1_010_030}");
            }

            if(!confirm('${SSO1_010_022}')) { return; }
            var param = {
                title: "${SSO1_010_007 }",
                message: '',
                callbackFunction: 'doGiveUpTransaction',
                rowId: ''
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function doGiveUpTransaction(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${SSO1_010_019 }");
            }

            var allIds = gridB.getAllRowId();
            for(var i in allIds) {
                gridB.setCellValue(allIds[i], 'GIVEUP_FLAG', "1");
                gridB.setCellValue(allIds[i], 'GIVEUP_REASON', data.message);
            }

            gridB.checkAll(true);

            var firstSendFlag = "Y";
            var qtaNum = "";
            var rowIds = gridB.getSelRowId();
            for(var i in rowIds) {
                if(!EVF.isEmpty(gridB.getCellValue(rowIds[i], 'QTA_NUM'))) {
                    firstSendFlag = "N";
                    qtaNum = gridB.getCellValue(rowIds[i], 'QTA_NUM');
                }
            }

            var store = new EVF.Store();
            store.setGrid([gridB]);
            store.getGridData(gridB, 'all');
            store.setParameter("firstSendFlag", firstSendFlag);
            store.setParameter("RFQ_NUM", rfqNum);
            store.setParameter("RFQ_CNT", rfqCnt);
            store.setParameter("QTA_NUM", qtaNum);
            store.setParameter("giveUpFlag", "Y");
            store.load(baseUrl + 'sso1010_doSend', function() {
                alert(this.getResponseMessage());
                gridB.delAllRow();
                doSearch();
            });
        }

        function setRegionInfo(data) {
            gridB.setCellValue(data.rowId, 'VENDOR_REGION_CD', data.VENDOR_REGION_CD);
            gridB.setCellValue(data.rowId, 'VENDOR_REGION_NM', (EVF.isEmpty(data.VENDOR_REGION_CD) ? "N" : "Y"));
            gridB.setCellValue(data.rowId, 'QTA_UNIT_PRC', data.QTA_UNIT_PRC);
            gridB.setCellValue(data.rowId, 'LEADTIME', data.LEADTIME);
            gridB.setCellValue(data.rowId, 'LEADTIME_CD', data.LEADTIME_CD);
            gridB.setCellValue(data.rowId, 'MOQ_QT', data.MOQ_QT);
            gridB.setCellValue(data.rowId, 'RV_QT', data.RV_QT);
            gridB.setCellValue(data.rowId, 'TAX_CD', data.TAX_CD);
            gridB.setCellValue(data.rowId, 'QTA_REMARK', data.QTA_REMARK);
            gridB.setCellValue(data.rowId, 'LEADTIME_RMK', data.LEADTIME_RMK);
        }

        function setRMKL(data) {
            gridB.setCellValue(data.rowId, 'LEADTIME_RMK', data.message);
        }

        function setRMKQ(data) {
            gridB.setCellValue(data.rowId, 'QTA_REMARK', data.message);
        }

        function setRMKG(data) {
            gridB.setCellValue(data.rowId, 'GIVEUP_REASON', data.message);
        }

        function fileAttachPopupCallback(rowId, fileId, fileCount) {
            gridB.setCellValue(rowId, 'QTA_FILE_CNT', fileCount);
            gridB.setCellValue(rowId, 'QTA_FILE_NUM', fileId);
        }

        function doPrint() {
            if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rfqList = [];
            var rowIds = gridT.getSelRowId();
            for( var i in rowIds ) {
                if(gridT.getCellValue(rowIds[i], 'SEND_FLAG') != '300') {
                    return alert("${SSO1_010_026}"); // 제출한 견적서만 출력하실 수 있습니다.
                }

                rfqList.push(
                    {
                        'RFQ_NUM': gridT.getCellValue(rowIds[i], 'RFQ_NUM'),
                        'RFQ_CNT': gridT.getCellValue(rowIds[i], 'RFQ_CNT')
                    }
                );
            }

            var param = {
                RFQ_LIST : JSON.stringify(rfqList)
            };
            everPopup.openPopupByScreenId("PRT_020", 976, 800, param);
        }
    </script>

    <e:window id="SSO1_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="COMBO_BOX">
                    <e:select id="COMBO_BOX" name="COMBO_BOX" usePlaceHolder="false" width="99" required="${form_COMBO_BOX_R}" disabled="${form_COMBO_BOX_D }" readOnly="${form_COMBO_BOX_RO}" >
                        <e:option text="${SSO1_010_001}" value="R">R</e:option>
                        <e:option text="${SSO1_010_002}" value="S">S</e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="${empty param.fromDate ? fromDate : param.fromDate}" toDate="TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="${empty param.toDate ? toDate : param.toDate}" fromDate="FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
                <e:label for="RFQ_SUBJECT" title="${form_RFQ_SUBJECT_N}"/>
                <e:field>
                    <e:inputText id="RFQ_SUBJECT" name="RFQ_SUBJECT" value="" width="${form_RFQ_SUBJECT_W}" maxLength="${form_RFQ_SUBJECT_M}" disabled="${form_RFQ_SUBJECT_D}" readOnly="${form_RFQ_SUBJECT_RO}" required="${form_RFQ_SUBJECT_R}" />
                </e:field>
                <e:label for="RFQ_NUM" title="${form_RFQ_NUM_N}"/>
                <e:field>
                    <e:inputText id="RFQ_NUM" name="RFQ_NUM" value="" width="${form_RFQ_NUM_W}" maxLength="${form_RFQ_NUM_M}" disabled="${form_RFQ_NUM_D}" readOnly="${form_RFQ_NUM_RO}" required="${form_RFQ_NUM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_DESC_SPEC" title="${form_ITEM_DESC_SPEC_N}"/>
                <e:field>
                    <e:inputText id="ITEM_DESC_SPEC" name="ITEM_DESC_SPEC" value="" width="${form_ITEM_DESC_SPEC_W}" maxLength="${form_ITEM_DESC_SPEC_M}" disabled="${form_ITEM_DESC_SPEC_D}" readOnly="${form_ITEM_DESC_SPEC_RO}" required="${form_ITEM_DESC_SPEC_R}" />
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${empty param.progressCd ? '' : param.progressCd}" options="${progressCdOptions}" width="50%" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                    <e:select id="SEND_FLAG" name="SEND_FLAG" value="" options="${sendFlagOptions}" width="50%" disabled="${form_SEND_FLAG_D}" readOnly="${form_SEND_FLAG_RO}" required="${form_SEND_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="btnT" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
        </e:buttonBar>

        <e:gridPanel id="gridT" name="gridT" width="100%" height="250px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}" />

        <e:buttonBar id="btnB" align="right" width="100%">
            <e:button id="Send" name="Send" label="${Send_N}" disabled="${Send_D}" visible="${Send_V}" onClick="doSend" />
            <e:button id="GiveUp" name="GiveUp" label="${GiveUp_N}" disabled="${GiveUp_D}" visible="${GiveUp_V}" onClick="doGiveUp" />
        </e:buttonBar>

        <e:gridPanel id="gridB" name="gridB" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridB.gridColData}" />

    </e:window>
</e:ui>