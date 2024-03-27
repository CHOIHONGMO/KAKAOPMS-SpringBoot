<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0301/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "ITEM_CD") {
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "im01021_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

    </script>

    <e:window id="IM01_021" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">

            <e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${param.ITEM_CD}"></e:inputHidden>
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${param.CUST_CD}"></e:inputHidden>

            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:text>${param.ITEM_CD }</e:text>
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:text>${param.ITEM_DESC }</e:text>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}" />
                <e:field>
                    <e:text>${param.CUST_ITEM_CD }</e:text>
                </e:field>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
                <e:field>
                    <e:text>${param.CUST_NM }</e:text>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>