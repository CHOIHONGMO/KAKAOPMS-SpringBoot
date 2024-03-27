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
                if(colId == 'REG_USER_NM') {
                    if( grid.getCellValue(rowId, 'REG_USER_NM') == '' ) return; // REG_USER_ID -> REG_USER_NM
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'REG_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'MOD_USER_NM') {
                    if( grid.getCellValue(rowId, 'MOD_USER_NM') == '' ) return; // MOD_USER_ID -> MOD_USER_NM
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'MOD_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.addRowEvent(function() {
                var rowId = grid.addRow([{
                    USE_FLAG: "1",
                    MKBR_TYPE: "MK"
                }]);

                grid.setCellReadOnly(rowId, ["MKBR_TYPE"], true);
                grid.setCellReadOnly(rowId, ["MKBR_NM", "MAJOR_ITEM_TEXT", "ADD_TEXT"], false); // "MKBR_TYPE",
            });

            grid.delRowEvent(function() {

            	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
				var delCnt = 0;
                var rowIds = grid.getSelRowId();
                for(var i = rowIds.length -1; i >= 0; i--) {
                    if(!EVF.isEmpty(grid.getCellValue(rowIds[i], "REG_DATE"))) {
                        delCnt++;
                    } else {
                        grid.delRow(rowIds[i]);
                    }
                }

                if(delCnt > 0){
                	return alert("${IM03_007_002}");
                    //grid.checkAll(false);
                }

            });

            grid.dupRowEvent(function() {

            }, ["MKBR_TYPE", "MKBR_NM", "USE_FLAG", "MAJOR_ITEM_TEXT", "ADD_TEXT"]);

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

//                var allRowIds = grid.getAllRowId();
//                for(var i in allRowIds) {
//                    var rowId = allRowIds[i];
//                    var value = grid.getCellValue(rowId, "MKBR_TYPE");
//                    if(value == "제조사") {
//                        grid.setCellValue(rowId, "MKBR_TYPE", "MK");
//                    } else if(value == "브랜드") {
//                        grid.setCellValue(rowId, "MKBR_TYPE", "BR");
//                    }
//                }
            });

            grid.setProperty('shrinkToFit', true);

        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "IM03_007/im03007_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {

    		if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

    		if (!confirm("${msg.M0021}")) return;

    		var rowIds = grid.getSelRowId();

		    for(var i in rowIds) {
				if(grid.getCellValue(rowIds[i], 'MKBR_NM') == '') {
					return alert("${IM03_007_001}");
				}
			}

		    var store = new EVF.Store();
		    store.setGrid([grid]);
		    store.getGridData(grid, 'sel');
		    store.load(baseUrl + "IM03_007/im03007_doSave", function () {
		        alert(this.getResponseMessage());
		        grid.checkAll(false);
		        doSearch();
		    });
        }

    </script>

    <e:window id="IM03_007" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:label for="MKBR_TYPE" title="${form_MKBR_TYPE_N}"/>
            <e:field>
                <e:select id="MKBR_TYPE" name="MKBR_TYPE" value="MK" options="${mkbrTypeOptions}" width="${form_MKBR_TYPE_W}" disabled="${form_MKBR_TYPE_D}" readOnly="${form_MKBR_TYPE_RO}" required="${form_MKBR_TYPE_R}" placeHolder="" />
            </e:field>
            <e:label for="MKBR_NM" title="${form_MKBR_NM_N}"/>
            <e:field>
                <e:inputText id="MKBR_NM" name="MKBR_NM" value="" maxLength="${form_MKBR_NM_M}" width="${form_MKBR_NM_W}" disabled="${form_MKBR_NM_D}" readOnly="${form_MKBR_NM_RO}" required="${form_MKBR_NM_R}" placeHolder="" />
            </e:field>
            <e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
            <e:field>
                <e:select id="USE_FLAG" name="USE_FLAG" value="1" options="${useFlagOptions}" width="${form_USE_FLAG_W}" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
            </e:field>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>