<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO02_010/";
        var RowId = 0;

        function init() {

            grid = EVF.C("grid");

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);
                }
            });

            grid.addRowEvent(function() {
                grid.addRow([{
                      REMARK : EVF.V("REMARK")
                    , MOVEMENT_TYPE : EVF.V("MOVEMENT_TYPE")
                    , TRAN_DATE : EVF.V("TRAN_DATE")
                }]);
            });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });

            grid.cellClickEvent(function(rowId, colId, value) {
                RowId = rowId;
                if (colId === "ITEM_CD") {
                    var param = {
                        ITEM_CD: grid.getCellValue(rowId, 'ITEM_CD'),
                        callBackFunction : 'callbackITEM_CD',
                        'detailView': false,
                        'popupFlag': true,
                        rowId: rowId
                    };
                    everPopup.openPopupByScreenId("STO03_010", 1100, 700, param);
                } else if (colId === "WH_NM"){
                    param = {
                        DEAL_CD : grid.getCellValue(rowId, 'DEAL_CD'),
                        callBackFunction: "callbackWH_NM",
                        rowId: rowId,
                        detailView: false,
                    };
                    everPopup.openPopupByScreenId("STO02P01", 600, 600, param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {
                    case 'TRAN_QTY':
                        var unit = Number(grid.getCellValue(rowId, 'TRAN_QTY'));
                        var unitPrice    = Number(grid.getCellValue(rowId, 'TRAN_UNIT_PRICE'));
                        grid.setCellValue(rowId, 'TRAN_AMT', unit * unitPrice);
                    case 'TRAN_UNIT_PRICE':
                        var unit = Number(grid.getCellValue(rowId, 'TRAN_QTY'));
                        var unitPrice    = Number(grid.getCellValue(rowId, 'TRAN_UNIT_PRICE'));
                        grid.setCellValue(rowId, 'TRAN_AMT', unit * unitPrice);
                    default:
                }
            });

            grid.setColGroup([{
                "groupName": "현재창고",
                "columns": [ "WH_NM_H", "WAREHOUSE_CODE_H", "STR_CTRL_CODE_H", "WAREHOUSE_TYPE_H" ]
            }, {
                "groupName": "이동창고",
                "columns": [ "WH_NM", "WAREHOUSE_CODE", "STR_CTRL_CODE", "WAREHOUSE_TYPE" ]
            }],35);


            EVF.C('MOVEMENT_TYPE').removeOption('103');
            EVF.C('MOVEMENT_TYPE').removeOption('107');
            EVF.C('MOVEMENT_TYPE').removeOption('108');
            EVF.C('MOVEMENT_TYPE').removeOption('109');
            EVF.C('MOVEMENT_TYPE').removeOption('110');
            EVF.C('MOVEMENT_TYPE').removeOption('903');
            EVF.C('MOVEMENT_TYPE').removeOption('907');
            EVF.C('MOVEMENT_TYPE').removeOption('908');
            EVF.C('MOVEMENT_TYPE').removeOption('909');
            EVF.C('MOVEMENT_TYPE').removeOption('910');
            EVF.C('MOVEMENT_TYPE').removeOption('999');

        }

        function doSave(){
            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "sto0201_doSave", function () {
                alert(this.getResponseMessage());
                doResetForm();
                doResetGrid();
            });
        }

        function doResetForm() {
            EVF.C("form").iterator(function (){
                EVF.C('TRAN_DATE').setValue('${toDate}');
                EVF.C('MOVEMENT_TYPE').setValue("905");
                EVF.C('REMARK').setValue("");
            });
        }

        function doResetGrid() {
            grid.delRow();
        }

        function callbackITEM_CD(data) {
            var itemdata = JSON.parse(data);
                grid.setCellValue(RowId, 'DEAL_CD', itemdata.DEAL_CD);
                grid.setCellValue(RowId, 'UNIT_CD', itemdata.UNIT_CD);
                grid.setCellValue(RowId, 'CUST_ITEM_CD', itemdata.CUST_ITEM_CD);
                grid.setCellValue(RowId, 'ITEM_CD', itemdata.ITEM_CD);
                grid.setCellValue(RowId, 'ITEM_DESC', itemdata.ITEM_DESC);
                grid.setCellValue(RowId, 'ITEM_SPEC', itemdata.ITEM_SPEC);
                grid.setCellValue(RowId, 'ITEM_NOTC_MAKER', itemdata.ITEM_NOTC_MAKER);
                grid.setCellValue(RowId, 'ITEM_NOTC_DESC', itemdata.ITEM_NOTC_DESC);
                grid.setCellValue(RowId, 'STR_CTRL_CODE_H', itemdata.STR_CTRL_CODE);
                grid.setCellValue(RowId, 'WAREHOUSE_CODE_H', itemdata.WAREHOUSE_CODE);
                grid.setCellValue(RowId, 'WAREHOUSE_TYPE_H', itemdata.WAREHOUSE_TYPE);
                grid.setCellValue(RowId, 'WH_NM_H', itemdata.WH_NM);
                grid.setCellValue(RowId, 'VENDOR_CD', itemdata.VENDOR_CD);
                grid.setCellValue(RowId, 'VENDOR_NM', itemdata.VENDOR_NM);
                grid.setCellValue(RowId, 'TRAN_UNIT_PRICE', itemdata.CONT_UNIT_PRICE);
                grid.setCellValue(RowId, 'CUR', itemdata.CUR);
        }

        function callbackWH_NM_H(data) {
            var whdata = JSON.parse(data);
            grid.setCellValue(RowId, 'WH_NM_H', whdata.WH_NM);
            grid.setCellValue(RowId, 'WAREHOUSE_CODE_H', whdata.WAREHOUSE_CODE);
            grid.setCellValue(RowId, 'STR_CTRL_CODE_H', whdata.STR_CTRL_CODE);
            grid.setCellValue(RowId, 'WAREHOUSE_TYPE_H', whdata.WAREHOUSE_TYPE);
        }

        function callbackWH_NM(data) {
            var whdata = JSON.parse(data);
            grid.setCellValue(RowId, 'WH_NM', whdata.WH_NM);
            grid.setCellValue(RowId, 'WAREHOUSE_CODE', whdata.WAREHOUSE_CODE);
            grid.setCellValue(RowId, 'STR_CTRL_CODE', whdata.STR_CTRL_CODE);
            grid.setCellValue(RowId, 'WAREHOUSE_TYPE', whdata.WAREHOUSE_TYPE);
        }
    </script>

    <e:window id="STO02_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
         <e:row>
             <e:label for="TRAN_DATE" title="${form_TRAN_DATE_N}"/>
             <e:field>
                 <e:inputDate id="TRAN_DATE" name="TRAN_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TRAN_DATE_R}" disabled="${form_TRAN_DATE_D}" readOnly="${form_TRAN_DATE_RO}" />
             </e:field>
             <e:label for="MOVEMENT_TYPE" title="${form_MOVEMENT_TYPE_N}"/>
             <e:field>
                 <e:select id="MOVEMENT_TYPE" name="MOVEMENT_TYPE" value="905" options="${movementTypeOptions}" width="${form_MOVEMENT_TYPE_W}" disabled="${form_MOVEMENT_TYPE_D}" readOnly="${form_MOVEMENT_TYPE_RO}" required="${form_MOVEMENT_TYPE_R}" placeHolder="" />
             </e:field>
             <e:label for="REMARK" title="${form_REMARK_N}" />
             <e:field>
                 <e:inputText id="REMARK" name="REMARK" value="" width="${form_REMARK_W}" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}" />
             </e:field>
         </e:row>
        </e:searchPanel>


        <e:buttonBar align="right" width="100%">
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>