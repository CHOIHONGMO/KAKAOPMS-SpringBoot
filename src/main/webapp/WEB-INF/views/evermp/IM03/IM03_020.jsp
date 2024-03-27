<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0302/";

        function init() {

            grid = EVF.C("grid");
            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == 'MOD_USER_NM') {
                    if( grid.getCellValue(rowId, 'MOD_USER_NM') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'MOD_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.addRowEvent(function() {
            	grid.addRow();
            });

            grid.delRowEvent(function() {
                grid.delRow();
            });

            grid.dupRowEvent(function() {

            }, ["STD_WORD", "DUP_WORD"]);

            grid.cellChangeEvent(function(rowId, colId, ir, or, value, oldValue) {

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
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "im03020_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {
        	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if (!confirm("${msg.M0021}")) return;
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im03020_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
        	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if (!confirm("${msg.M0013}")) return;
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im03020_doDelete", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="IM03_020" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:label for="STD_WORD" title="${form_STD_WORD_N}" />
			<e:field>
				<e:inputText id="STD_WORD" name="STD_WORD" value="" width="${form_STD_WORD_W}" maxLength="${form_STD_WORD_M}" disabled="${form_STD_WORD_D}" readOnly="${form_STD_WORD_RO}" required="${form_STD_WORD_R}" />
			</e:field>
			<e:label for="DUP_WORD" title="${form_DUP_WORD_N}" />
			<e:field>
				<e:inputText id="DUP_WORD" name="DUP_WORD" value="" width="${form_DUP_WORD_W}" maxLength="${form_DUP_WORD_M}" disabled="${form_DUP_WORD_D}" readOnly="${form_DUP_WORD_RO}" required="${form_DUP_WORD_R}" />
			</e:field>
			<e:label for="SEARCH_COUNT_CD" title="${form_SEARCH_COUNT_CD_N}"/>
			<e:field>
				<e:select id="SEARCH_PAGE_NO" name="SEARCH_PAGE_NO" value="1" options="${searchPageNoOptions}" width="40%" disabled="${form_SEARCH_PAGE_NO_D}" readOnly="${form_SEARCH_PAGE_NO_RO}" required="${form_SEARCH_PAGE_NO_R}" placeHolder="" usePlaceHolder="false"/>
				<e:select id="SEARCH_COUNT_CD" name="SEARCH_COUNT_CD" value="500" options="${searchCountCdOptions}" width="60%" disabled="${form_SEARCH_COUNT_CD_D}" readOnly="${form_SEARCH_COUNT_CD_RO}" required="${form_SEARCH_COUNT_CD_R}" placeHolder="" />
			</e:field>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>