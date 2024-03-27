<%--
  Date: 2016/01/14
  Time: 13:01:37
  Scrren ID : DH1020P
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/eversrm/gr";
        var selRow;

        function init() {

            grid = EVF.getComponent('grid');

            grid.setProperty('multiselect', true);
            grid.setProperty('shrinkToFit', true);

            // Grid Excel Event
            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,
                    imgHeight: 0.26,
                    colWidth: 20,
                    rowSize: 500,
                    attachImgFlag: false
                }
            });

            grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

            });

            grid.cellChangeEvent(function (rowid, colId, iRow, iCol, value, oldValue) {

            });

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + '/DH1020P/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="DH1020P" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="WORK_NUM" name="WORK_NUM" value="${param.WORK_NUM}" />

        <e:buttonBar align="right">
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
