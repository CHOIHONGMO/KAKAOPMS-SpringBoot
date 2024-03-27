<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var grid;
        var addParam = [{}];
        var baseUrl = "/eversrm/system/migration/";

        function init() {

            grid = EVF.C('grid');
            
            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);
                }
            });

        }

        function doSearch() {

            var store = new EVF.Store();

            store.setGrid([grid]);
            store.load(baseUrl + 'mig010_doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }else{
                    grid.checkAll(true);
                }
            });
        }


        function doSave() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'mig010_doSave', function () {
                alert(this.getResponseMessage());
            });
        }


    </script>

    <e:window id="MIG_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:textArea id="CONSOLE" name="CONSOLE" required="false" disabled="false" readOnly="false" maxLength="" width="100%" height="350px" placeHolder="실행할 query를 입력하세요." />

        <e:buttonBar width="100%" align="right">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch"/>
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>    