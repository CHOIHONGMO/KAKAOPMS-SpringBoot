<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var headerG;
        var baseUrl = "/evermp/IM01/IM0101/";

        function init() {
            grid = EVF.C("grid");
            headerG = EVF.C('headerG');
            grid.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "VENDOR_CD") {
                    var param = {
                        callBackFunction : "selectVendorCd",
                        'rowId': rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0063');
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearchHD();
        }

        function doSearchHD(){
            var store = new EVF.Store();
            store.setGrid([headerG]);
            store.load(baseUrl + "im01001_doSearchHeader", function () {
                if(headerG.getRowCount() == 0) {
                } else {
                    var allRowId = headerG.getAllRowId();
                    for(var i in allRowId) {
                        var HeadrNm = headerG.getCellValue(allRowId[i], 'REGION_NM');
                        var HeadrCd = headerG.getCellValue(allRowId[i], 'SET_REGION_CD');

                        grid.addColumn(HeadrCd,HeadrNm, 80, 'center', 'checkbox', 50, true, true, '', 0);
                    }

                    var addParam = [{}];
                    grid.addRow(addParam);
                }
            });

        }

        function doSave() {

            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im01002_doSave", function () {
                alert(this.getResponseMessage());

                opener.doSearch();
                doClose();
            });
        }


        function selectVendorCd(data) {
            grid.setCellValue(data.rowId, 'VENDOR_CD', data.VENDOR_CD);
            grid.setCellValue(data.rowId, 'VENDOR_NM', data.VENDOR_NM);
        }


        function doClose() {
            window.close();
        }
    </script>

    <e:window id="IM01_002" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">


        <e:buttonBar align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

        <e:panel width="0px" height="0px">
            <e:gridPanel id="headerG" name="headerG" width="0px" height="0px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.headerG.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>