<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var gridD;
        var baseUrl = '/eversrm/eApproval/eApprovalModule/';

        function init() {

            grid = EVF.C("grid");
            gridD = EVF.C("gridD");

            grid.setProperty("shrinkToFit", true);
            grid.setProperty("multiSelect", false);

            gridD.setProperty("shrinkToFit", true);
            gridD.setProperty("multiSelect", false);

            grid.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {

                if(cellName == "SIGN_PATH_NM") {
                    var rowData = grid.getRowValue(rowId);
                    parent.window['myApprovalPathCallBack'](JSON.stringify(rowData));
                    doClose();
                } else if(cellName == "PATH_SQ") {
                    var store = new EVF.Store();
                    store.setGrid([gridD]);
                    store.setParameter("PATH_NUM", grid.getCellValue(rowId, "PATH_NUM"));
                    store.load(baseUrl + 'BAPM_040/getMyPathList', function() {
                    });
                }
            });

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid, gridD]);
            store.load(baseUrl + 'BAPM_040/getMyPath', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doClose() {
            new EVF.ModalWindow().close(null);
        }

    </script>

    <e:window id="BAPM_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
            <e:button id="doClose" name="doClose" label="${doClose_N }" disabled="${doClose_D }" onClick="doClose" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="200px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        <e:gridPanel gridType="${_gridType}" id="gridD" name="gridD" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />

    </e:window>
</e:ui>
