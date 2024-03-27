<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO01_010/";

        function init() {

            grid = EVF.C("grid");
          grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == 'REG_USER_ID') {
                    if( grid.getCellValue(rowId, 'REG_USER_ID') == '' ) return; // REG_USER_ID -> REG_USER_NM
                    var param = {
                        callbackFunction : "",
                        USER_TYPE : 'C',  // C:운영사, B:고객사, S:공급사
                        USER_ID : grid.getCellValue(rowId, 'REG_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'MOD_USER_ID') {
                    if( grid.getCellValue(rowId, 'MOD_USER_ID') == '' ) return; // MOD_USER_ID -> MOD_USER_NM
                    var param = {
                        callbackFunction : "",
                        USER_TYPE : 'C',  // C:운영사, B:고객사, S:공급사
                        USER_ID : grid.getCellValue(rowId, 'MOD_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.addRowEvent(function() {

                var rowId = grid.addRow([{
                	USE_FLAG: "1",
                	}]);
           	    grid.setRowReadOnly(rowId, false);
                grid.checkAll(false);
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
	                   return alert("${STO01_010_005}");
	                    //grid.checkAll(false);
	                }

	            });
            grid.setProperty('shrinkToFit', true);
            EVF.C('STR_CTRL_CODE').removeOption("2000");
            EVF.C('STR_CTRL_CODE').removeOption("1100");
            doSearch();
        }
        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0101_doSearch", function () {
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
            if(grid.getCellValue(rowIds[i], 'WH_NM') == '') {
               return alert("${STO01_010_001}");
            }
            if(grid.getCellValue(rowIds[i], 'STR_CTRL_CODE') == '') {
			   return alert("${STO01_010_002}");
            }
 			if(grid.getCellValue(rowIds[i], 'WAREHOUSE_TYPE') == '') {
			   return alert("${STO01_010_003}");
            }
         }


          var store = new EVF.Store();
          store.setGrid([grid]);
          store.getGridData(grid, 'sel');
          store.load(baseUrl + "sto0101_doSave", function () {
              alert("${STO01_010_004}");
              grid.checkAll(false);
              doSearch();
          });
        }

    </script>

    <e:window id="STO01_010" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:label for="STR_CTRL_CODE" title="${form_STR_CTRL_CODE_N}"/>
			<e:field>
				<e:select id="STR_CTRL_CODE" name="STR_CTRL_CODE" value="" options="${strCtrlCodeOptions}" width="${form_STR_CTRL_CODE_W}" disabled="${form_STR_CTRL_CODE_D}" readOnly="${form_STR_CTRL_CODE_RO}" required="${form_STR_CTRL_CODE_R}" placeHolder="" />
			</e:field>
			<e:label for="WAREHOUSE_TYPE" title="${form_WAREHOUSE_TYPE_N}"/>
			<e:field>
				<e:select id="WAREHOUSE_TYPE" name="WAREHOUSE_TYPE" value="" options="${warehouseTypeOptions}" width="${form_WAREHOUSE_TYPE_W}" disabled="${form_WAREHOUSE_TYPE_D}" readOnly="${form_WAREHOUSE_TYPE_RO}" required="${form_WAREHOUSE_TYPE_R}" placeHolder="" />
			</e:field>
			<e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
			<e:field>
				<e:select id="USE_FLAG" name="USE_FLAG" value="" options="${useFlagOptions}" width="${form_USE_FLAG_W}" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
			</e:field>
	    </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>