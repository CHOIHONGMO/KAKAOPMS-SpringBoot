<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BOD1/BOD103/";

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('multiSelect', true);
	        grid.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function(rowId, colId, value) {
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'BOD1_032/doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            if(!confirm('${msg.M0011}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("itemInfo", '${param.itemInfo }');
            store.load(baseUrl + 'BOD1_032/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();

                if (EVF.V("ACTION_FLAG") != "") {
                    if(opener != null) {
                        opener.location.reload();
                    }
                }
            });
        }

    </script>

    <e:window id="BOD1_032" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="ACTION_FLAG" name="ACTION_FLAG" value="${form.ACTION_FLAG}"/>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:text style="color:blue;font-weight:bold; float: left;">관심상품 등록에 필요한 관심상품그룹이 있어야 합니다.</e:text>
           	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="true"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>