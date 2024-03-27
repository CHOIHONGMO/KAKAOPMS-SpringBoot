<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/RQ01/RQ0102/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'LEADTIME_RMK_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, 'LEADTIME_RMK'))) {
                        var param = {
                            title: "${RQ01_024_001}",
                            message: grid.getCellValue(rowId, 'LEADTIME_RMK'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'QTA_REMARK_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, 'QTA_REMARK'))) {
                        var param = {
                            title: "${RQ01_024_002}",
                            message: grid.getCellValue(rowId, 'QTA_REMARK'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'SETTLE_RMK_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, 'SETTLE_RMK'))) {
                        var param = {
                            title: "${RQ01_024_003}",
                            message: grid.getCellValue(rowId, 'SETTLE_RMK'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'GIVEUP_REASON_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, 'GIVEUP_REASON'))) {
                        var param = {
                            title: "${RQ01_024_004}",
                            message: grid.getCellValue(rowId, 'GIVEUP_REASON'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'VENDOR_REGION_NM') {

                    var param = {
                        VENDOR_REGION_CD : grid.getCellValue(rowId, 'VENDOR_REGION_CD'),
                        QTA_UNIT_PRC : grid.getCellValue(rowId, 'QTA_UNIT_PRC'),
                        LEADTIME : grid.getCellValue(rowId, 'LEADTIME'),
                        LEADTIME_CD : grid.getCellValue(rowId, 'LEADTIME_CD'),
                        MOQ_QT : grid.getCellValue(rowId, 'MOQ_QT'),
                        RV_QT : grid.getCellValue(rowId, 'RV_QT'),
                        TAX_CD : grid.getCellValue(rowId, 'TAX_CD'),
                        QTA_REMARK : grid.getCellValue(rowId, 'QTA_REMARK'),
                        LEADTIME_RMK : grid.getCellValue(rowId, 'LEADTIME_RMK'),
                        callbackFunction: 'setRegionInfo',
                        'rowId': rowId,
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("SSO1_011", 1000, 300, param);
                }
                if(colId == 'QTA_FILE_CNT') {
                    var param = {
                        havePermission: false,
                        attFileNum: grid.getCellValue(rowId, 'QTA_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: '',
                        bizType: 'QTA',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
                if(colId == 'PROOF_FILE_CNT') {
                    var param = {
                        havePermission: false,
                        attFileNum: grid.getCellValue(rowId, 'PROOF_FILE_NUM'),
                        rowId: rowId,
                        callBackFunction: '',
                        bizType: 'QTA',
                        fileExtension: '*'
                    };
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
            });

            grid.setProperty('multiSelect', false);

            grid.setColIconify("LEADTIME_RMK_IMG", "LEADTIME_RMK", "comment", false);
            grid.setColIconify("QTA_REMARK_IMG", "QTA_REMARK", "comment", false);
            grid.setColIconify("SETTLE_RMK_IMG", "SETTLE_RMK", "comment", false);
            grid.setColIconify("GIVEUP_REASON_IMG", "GIVEUP_REASON", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "rq01024_doSearch", function () {
                grid.setColMerge(['RFQ_CNT']);
                //grid.setColMerge(['ITEM_CD','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM','ORIGIN_NM','UNIT_CD','REGION_NM']);
                var rowIds = grid.getAllRowId();
                for(var i in rowIds) {
                    if(grid.getCellValue(rowIds[i], 'RFQ_CNT') == this.getParameter("lastCnt")) {
                        grid.setCellFontColor(rowIds[i], 'RFQ_CNT', "#ff0e07");
                        grid.setCellFontWeight(rowIds[i], "RFQ_CNT", true);
                        if(grid.getCellValue(rowIds[i], 'RANK') == "1") {
                            grid.setCellFontColor(rowIds[i], 'QTA_UNIT_PRC', "#ffb01f");
                        }
                        if(grid.getCellValue(rowIds[i], 'SETTLE_FLAG') == "1") {
                            grid.setCellFontColor(rowIds[i], 'SETTLE_FLAG_LOC', "#4448ff");
                            grid.setCellFontWeight(rowIds[i], "SETTLE_FLAG_LOC", true);
                            grid.setCellFontColor(rowIds[i], 'VENDOR_NM', "#4448ff");
                            grid.setCellFontWeight(rowIds[i], "VENDOR_NM", true);
                            grid.setCellFontColor(rowIds[i], 'QTA_UNIT_PRC', "#4448ff");
                            grid.setCellFontWeight(rowIds[i], "QTA_UNIT_PRC", true);
                        }
                        if(grid.getCellValue(rowIds[i], 'SEND_FLAG_CD') == "300") {
                            grid.setCellFontColor(rowIds[i], 'SEND_FLAG', "#ff6928");
                            grid.setCellFontWeight(rowIds[i], "SEND_FLAG", true);
                        }
                        if(grid.getCellValue(rowIds[i], 'SEND_FLAG_CD') == "150") {
                            grid.setCellFontColor(rowIds[i], 'SEND_FLAG', "#4448ff");
                            grid.setCellFontWeight(rowIds[i], "SEND_FLAG", true);
                        }
                    }
                }
            });
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="RQ01_024" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="RFQ_NUM_CNT" title="${form_RFQ_NUM_CNT_N}"/>
                <e:field>
                    <e:text>${formData.RFQ_NUM_CNT}</e:text>
                    <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="${param.RFQ_NUM}" />
                    <e:inputHidden id="RFQ_CNT" name="RFQ_CNT" value="${param.RFQ_CNT}" />
                </e:field>
                <e:label for="RFQ_SUBJECT" title="${form_RFQ_SUBJECT_N}"/>
                <e:field>
                    <e:text>${formData.RFQ_SUBJECT}</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CONT_DATE" title="${form_CONT_DATE_N}"/>
                <e:field>
                    <e:text>${formData.CONT_DATE}</e:text>
                </e:field>
                <e:label for="CONT_FROM_TO" title="${form_CONT_FROM_TO_N}"/>
                <e:field>
                    <e:text>${formData.CONT_FROM_TO}</e:text>
                </e:field>
            </e:row>
            <%--
            <e:row>
                <e:label for="VENDOR_OPEN_TYPE_LOC" title="${form_VENDOR_OPEN_TYPE_LOC_N}"/>
                <e:field>
                    <e:text>${formData.VENDOR_OPEN_TYPE_LOC}</e:text>
                </e:field>
                <e:label for="DEAL_TYPE_LOC" title="${form_DEAL_TYPE_LOC_N}"/>
                <e:field>
                    <e:text>${formData.DEAL_TYPE_LOC}</e:text>
                </e:field>
            </e:row>
            --%>
        </e:searchPanel>

        <br>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>