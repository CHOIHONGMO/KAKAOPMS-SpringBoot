<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO02_020/";
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
                    , IA_DATE : EVF.V("IA_DATE")
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
                    case 'IA_QTY':
                        var unit = Number(grid.getCellValue(rowId, 'IA_QTY'));
                        var unitPrice    = Number(grid.getCellValue(rowId, 'IA_PRICE'));
                        grid.setCellValue(rowId, 'IA_AMT', unit * unitPrice);
                    case 'IA_PRICE':
                        var unit = Number(grid.getCellValue(rowId, 'IA_QTY'));
                        var unitPrice    = Number(grid.getCellValue(rowId, 'IA_PRICE'));
                        grid.setCellValue(rowId, 'IA_AMT', unit * unitPrice);
                    default:
                }
            });



            EVF.C('MOVEMENT_TYPE').removeOption('103');
            EVF.C('MOVEMENT_TYPE').removeOption('105');
            EVF.C('MOVEMENT_TYPE').removeOption('999');
            EVF.C('MOVEMENT_TYPE').removeOption('903');
            EVF.C('MOVEMENT_TYPE').removeOption('905');
            EVF.C('MOVEMENT_TYPE').removeOption('110');
            EVF.C('MOVEMENT_TYPE').removeOption('910');


        }

        function doSave(){
            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "sto0202_doSave", function () {
                alert(this.getResponseMessage());
                doResetForm();
                doResetGrid();
            });
        }

        function doResetForm() {
            EVF.C("form").iterator(function (){
                EVF.C('IA_DATE').setValue('${toDate}');
                EVF.C('MOVEMENT_TYPE').setValue("");
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
                grid.setCellValue(RowId, 'STR_CTRL_CODE', itemdata.STR_CTRL_CODE);
                grid.setCellValue(RowId, 'WAREHOUSE_CODE', itemdata.WAREHOUSE_CODE);
                grid.setCellValue(RowId, 'WAREHOUSE_TYPE', itemdata.WAREHOUSE_TYPE);
                grid.setCellValue(RowId, 'WH_NM', itemdata.WH_NM);
                grid.setCellValue(RowId, 'VENDOR_CD', itemdata.VENDOR_CD);
                grid.setCellValue(RowId, 'VENDOR_NM', itemdata.VENDOR_NM);
                grid.setCellValue(RowId, 'IA_PRICE', itemdata.CONT_UNIT_PRICE);
        }

        function callbackWH_NM(data) {
            var whdata = JSON.parse(data);
            grid.setCellValue(RowId, 'WH_NM', whdata.WH_NM);
            grid.setCellValue(RowId, 'WAREHOUSE_CODE', whdata.WAREHOUSE_CODE);
            grid.setCellValue(RowId, 'STR_CTRL_CODE', whdata.STR_CTRL_CODE);
            grid.setCellValue(RowId, 'WAREHOUSE_TYPE', whdata.WAREHOUSE_TYPE);
        }

    </script>

    <e:window id="STO02_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
         <e:row>
             <e:label for="IA_DATE" title="${form_IA_DATE_N}"/>
             <e:field>
                 <e:inputDate id="IA_DATE" name="IA_DATE"  value="${toDate}" width="${form_ID_DATE_M}" datePicker="true" required="${form_IA_DATE_R}" disabled="${form_IA_DATE_D}" readOnly="${form_IA_DATE_RO}" />
             </e:field>
             <e:label for="MOVEMENT_TYPE" title="${form_MOVEMENT_TYPE_N}"/>
             <e:field>
                 <e:select id="MOVEMENT_TYPE" name="MOVEMENT_TYPE" value="" options="${movementTypeOptions}" width="${form_MOVEMENT_TYPE_W}" disabled="${form_MOVEMENT_TYPE_D}" readOnly="${form_MOVEMENT_TYPE_RO}" required="${form_MOVEMENT_TYPE_R}" placeHolder="" />
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