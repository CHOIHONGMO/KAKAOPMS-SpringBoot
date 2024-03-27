<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var gridPodt;
        var baseUrl = "/eversrm/po/poMgt/poProgress/SPOM_010";
        var popupFlag = '';
        var isImageView = true;
        var catalogSearch = 0;
        var colHideFlag = false;

        function init() {
            popupFlag = '${param.popupFlag}';
            catalogSearch = '${param.catalogSearch}';
            gridPodt = EVF.C('gridPodt');

            gridPodt.setProperty('panelVisible', ${panelVisible});

            gridPodt.excelExportEvent({
                allCol: "${excelOption.allCol}",
                selRow: "${excelOption.selRow}",
                fileType: 'xls',
                fileName: "${screenName }"
            });

            gridPodt.cellClickEvent(function (rowId, colId, value, iRow, iCol, treeInfo) {

                if (colId == "PO_NUM") {
                    everPopup.printPoReport(gridPodt.getCellValue(rowId, 'PO_NUM'))


                } else if (colId == 'VENDOR_REJECT_ICON_RMK') {

                    var param = {
                        "message": EVF.isEmpty(gridPodt.getCellValue(rowId, "VENDOR_REJECT_RMK")) ? '' : gridPodt.getCellValue(rowId, "VENDOR_REJECT_RMK"),
                        "detailView": true,
                        "title": '반려 사유',
                        "havePermission": "true",
                        "callbackFunction": "setRejectRmk",
                        "rowId": rowId
                    };
                    everPopup.openWindowPopup('/common/popup/common_text_input/view', 700, 310, param, 'common_text_input');
                } else if (colId == 'I_PO_ATT_FILE_NUM') {

                    var uuid = gridPodt.getCellValue(rowId, 'PO_ATT_FILE_NUM');
                    var param = {
                            havePermission: false,
                            attFileNum: uuid,
                            rowId: rowId,
                            callBackFunction: '_setFileUuidItemGrid',
                            bizType: 'PO'
                        };

                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }

            });

            EVF.C('PURCHASE_TYPE').removeOption('DMRO');

            doSearch();
        }

        function setRejectRmk(param) {
            gridPodt.setCellValue(param.rowId, 'VENDOR_REJECT_RMK', param.message);
        }

        function setFiile(row, attachNUm, cnt) {
            gridPodt.setCellValue(row, 'ATT_FILE_NUM', attachNUm);
            gridPodt.setCellValue(row, 'ATT_FILE_CNT', cnt);
        }
        var currRow;

        function getPlantGrid() {
            var param = {
                callBackFunction: 'setPlantGrid'
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function setPlantGrid(dataJsonArray) {
            gridPodt.setCellValue(currRow, 'PLANT_CD', dataJsonArray.PLANT_CD);
            gridPodt.setCellValue(currRow, 'PLANT_NM', dataJsonArray.PLANT_NM);
        }

        function doSearch() {

            if (!everDate.fromTodateValid('FROM_DATE', 'TO_DATE', '${ses.dateFormat }')) return alert('${msg.M0073}');

            var store = new EVF.Store();
            if (!store.validate()) return;

            store.setGrid([gridPodt]);
            store.load(baseUrl + "/doSearch", function () {
                if(gridPodt.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function getPlant() {
            var param = {
                callBackFunction: 'setPlant'
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function setPlant(dataJsonArray) {
            EVF.getComponent("PLANT_NM").setValue(dataJsonArray.PLANT_NM);
        }

        function doSelectUser() {
            var param = {
                GATE_CD: '${ses.gateCd}'
                , callBackFunction: 'selectUser'
            };
            everPopup.openCommonPopup(param, "SP0001");
        }
        function selectUser(dataJsonArray) {
            EVF.getComponent("CTRL_USER_NM").setValue(dataJsonArray.USER_NM);
        }
        function doAccept() {

            if (!gridPodt.isExistsSelRow()) { return alert('${msg.M0004}'); }

            var gridData = gridPodt.getSelRowValue();
            for(var i in gridData) {

                var rowData = gridData[i];
                if(rowData['FORCE_CLOSE_FLAG'] == '1') {
                    return alert('${SPOM_010_010}');
                }
            }

            var store = new EVF.Store();
            if(!confirm('${SPOM_010_005}')) { return; }

            store.setGrid([gridPodt]);
            store.getGridData(gridPodt, 'sel');
            store.load(baseUrl+'/doAccept', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doReject() {

            if (!gridPodt.isExistsSelRow()) { return alert('${msg.M0004}'); }

            var selRowId = gridPodt.getSelRowId();
            for(var idx in selRowId) {

                var rowId = selRowId[idx];
                var data = gridPodt.getRowValue(rowId);
                if(EVF.isEmpty(data['VENDOR_REJECT_RMK'])) {

                    var param = {
                        "message": '',
                        "detailView": true,
                        "title": '반려 사유',
                        "havePermission": "true",
                        "callbackFunction": "setRejectRmk",
                        "rowId": gridPodt.getRowId(rowId)
                    };

                    alert('${SPOM_010_008}');
                    return everPopup.openWindowPopup('/common/popup/common_text_input/view', 700, 310, param, 'common_text_input');
                }
            }

            var store = new EVF.Store();
            if(!confirm('${SPOM_010_007}')) { return; }
            store.setGrid([gridPodt]);
            store.getGridData(gridPodt, 'sel');
            store.load(baseUrl+'/doReject', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="SPOM_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
            <e:row>
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
                    <e:text> ~ </e:text>
                    <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" name="PO_NUM" style='ime-mode:inactive' value="${form.PO_NUM}" width="45%" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                    <e:text width="4%">/</e:text>
                    <e:inputText id="SUBJECT" name="SUBJECT" style='ime-mode:auto' value="${form.SUBJECT}" width="45%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="VENDOR_RECEIPT_STATUS" title="${form_VENDOR_RECEIPT_STATUS_N}"/>
                <e:field>
                    <e:select id="VENDOR_RECEIPT_STATUS" name="VENDOR_RECEIPT_STATUS" value="${form.VENDOR_RECEIPT_STATUS}" options="${vendorReceiptStatusOptions}" width="${inputTextWidth}" disabled="${form_VENDOR_RECEIPT_STATUS_D}" readOnly="${form_VENDOR_RECEIPT_STATUS_RO}" required="${form_VENDOR_RECEIPT_STATUS_R}" placeHolder="" />
                </e:field>
                <e:label for="SIGN_FLAG" title="${form_SIGN_FLAG_N}"/>
                <e:field>
                    <e:select id="SIGN_FLAG" name="SIGN_FLAG" value="${form.SIGN_FLAG}" options="${signFlagOptions}" width="${inputTextWidth}" disabled="${form_SIGN_FLAG_D}" readOnly="${form_SIGN_FLAG_RO}" required="${form_SIGN_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doAccept" name="doAccept" label="${doAccept_N}" onClick="doAccept" disabled="${doAccept_D}" visible="${doAccept_V}"/>
            <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="gridPodt" name="gridPodt" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridPodt.gridColData}"/>

    </e:window>
</e:ui>