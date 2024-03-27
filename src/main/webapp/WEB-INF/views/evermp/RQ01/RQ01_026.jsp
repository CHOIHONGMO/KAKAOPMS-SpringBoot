<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var gridD;
        var selRow = -1;
        var baseUrl = "/evermp/RQ01/RQ0102/";

        function init() {
            grid = EVF.C("grid");
            gridD = EVF.C("gridD");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'EXEC_NUM') {

                    var param = {
                        'RFQ_NUM': "",
                        'RFQ_CNT': "",
                        'EXEC_NUM': grid.getCellValue(rowId, 'EXEC_NUM'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("RQ01_023", 1100, 900, param);
                }
                if(colId == 'ATT_FILE_CNT') {
                    var param = {
                        havePermission: false,
                        attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: '',
                        bizType: 'EX',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'RMK_TEXT_NUM_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "RMK_TEXT_NUM"))) {
                        var param = {
                            rowId : rowId
                            ,havePermission : true
                            ,screenName : "${RQ01_026_001}"
                            ,callBackFunction : ''
                            ,largeTextNum : grid.getCellValue(rowId, "RMK_TEXT_NUM")
                            ,detailView : true
                        };
                        everPopup.openPopupByScreenId('commonRichTextContents', 900, 600, param);
                    }
                }
                if(colId === "SOURCING_REJECT_RMK") {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "SOURCING_REJECT_RMK"))) {
                        var param = {
                            title : "${RQ01_026_006}",
                            message : grid.getCellValue(rowId, "SOURCING_REJECT_RMK"),
                            callbackFunction : "",
                            detailView : true,
                            rowId : rowId
                        };
                        var url = "/common/popup/common_text_input/view";
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'CTRL_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, 'CTRL_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'EXEC_SUBJECT') {
                    grid.checkRow(rowId, true);
                    gridDLoad(rowId);
                }
            });

            grid.setProperty('shrinkToFit', true);
            grid.setProperty('singleSelect', true);
            grid.setColIconify("RMK_TEXT_NUM_IMG", "RMK_TEXT_NUM", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridD.setProperty('shrinkToFit', true);

            gridD.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId === "ITEM_REQ_NO") {
                    var param = {
                        CUST_CD: gridD.getCellValue(rowId, "CUST_CD"),
                        ITEM_REQ_NO: gridD.getCellValue(rowId, "ITEM_REQ_NO"),
                        ITEM_REQ_SEQ: gridD.getCellValue(rowId, "ITEM_REQ_SEQ"),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
                }
                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': gridD.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'CUST_NM') {
                    var param = {
                        'CUST_CD': gridD.getCellValue(rowId, 'CUST_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
                if(colId == 'REQUEST_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: gridD.getCellValue(rowId, 'REG_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }X
            });
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "rq01026_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return EVF.alert('${msg.M0002}');
                }
            });
        }

        function doModify() {

            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return EVF.alert('${msg.M0006}'); }

            var execNum;
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return EVF.alert("${RQ01_026_005}");
                }

                // 결재승인 이후 "합의반려(440)인 경우에도 수정 가능
                if(grid.getCellValue(rowIds[i], 'SIGN_STATUS') != "T" && grid.getCellValue(rowIds[i], 'SIGN_STATUS') != "R" && grid.getCellValue(rowIds[i], 'SIGN_STATUS') != "C") {
                    if(grid.getCellValue(rowIds[i], 'SIGN_STATUS') != "E" || grid.getCellValue(rowIds[i], 'NW_PROGRESS_CD') != "440") {
                        return EVF.alert("${RQ01_026_002}");
                    }
                }
                execNum = grid.getCellValue(rowIds[i], 'EXEC_NUM');
            }

            var param = {
                'RFQ_NUM': "",
                'RFQ_CNT': "",
                'EXEC_NUM': execNum,
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_023", 1100, 900, param);
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        function cleanVendorInfo() {
            EVF.C("VENDOR_CD").setValue("");
        }

        function gridDLoad(rowId) {
            if(selRow != rowId){
                grid.checkRow(selRow, false);
                selRow = rowId;
            }

            var store = new EVF.Store();
            store.setParameter("EXEC_NUM", grid.getCellValue(rowId, 'EXEC_NUM'));
            store.setGrid([gridD]);
            store.load(baseUrl + "rq01026_doSearchD", function (){

            });
        }
    </script>

    <e:window id="RQ01_026" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="COMBO_BOX">
                    <e:select id="COMBO_BOX" name="COMBO_BOX" usePlaceHolder="false" width="99" required="${form_COMBO_BOX_R}" disabled="${form_COMBO_BOX_D }" readOnly="${form_COMBO_BOX_RO}" >
                        <e:option text="${RQ01_026_003}" value="E">E</e:option>
                        <e:option text="${RQ01_026_004}" value="C">C</e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" value="${fromDate }" toDate="TO_DATE" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" value="${toDate }" fromDate="FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
                </e:field>
                <e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="" width="${form_EXEC_SUBJECT_W}" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserIdOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
                <e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
                <e:field>
                    <e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onChange="cleanVendorInfo" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="btn" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Modify" name="Modify" label="${Modify_N}" disabled="${Modify_D}" visible="${Modify_V}" onClick="doModify" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

        <e:title title="${RQ01_026_CAPTION }" />
        <e:gridPanel id="gridD" name="gridD" width="100%" height="220px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridC.gridColData}" />

    </e:window>
</e:ui>