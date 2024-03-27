<%-- 공급사 품목코드 팝업 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0301/";

        function init() {

            grid = EVF.C("grid");
            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == 'VENDOR_NM') {
                    var param = {
                        rowId: rowId,
                        callBackFunction: 'setVendorCode'
                    };
                    everPopup.openCommonPopup(param, 'SP0063');
                }
            });

            grid.cellChangeEvent(function(rowId, colId, ir, or, value, oldValue) {

            });

            grid.addRowEvent(function() {
                var rowId = grid.addRow([{

                }]);
            });

            grid.delRowEvent(function() {
                grid.delRow();
            });

            grid.dupRowEvent(function() {

            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);
                }
            });

            grid.setProperty('shrinkToFit', true);
            
            doSearch();
        }

        function setVendorCode(data) {
            grid.setCellValue(data.rowId, "VENDOR_CD", data.VENDOR_CD);
            grid.setCellValue(data.rowId, "VENDOR_NM", data.VENDOR_NM);
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "IM03_008P/im03008P_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }

                var data = {};
                data.rowId = '${param.rowId}';
                data.count = grid.getRowCount();
                if(parent) {
                    parent['${param.callBackFunction}'](data);
                }
            });
        }

        function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }
            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            if (!confirm("${msg.M0021}")) return;
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "IM03_008P/im03008P_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {

            if(!grid.isExistsSelRow()) {  return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }
            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'IM03_008P/im03008P_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="IM03_008P" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${param.itemCd}" />

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
                <e:field>
                    <e:inputText id="VENDOR_CD" name="VENDOR_CD" value="" width="${form_VENDOR_CD_W}" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            <e:button id="Delete" name="Delete" label="${Delete_N}" onClick="doDelete" disabled="${Delete_D}" visible="${Delete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>