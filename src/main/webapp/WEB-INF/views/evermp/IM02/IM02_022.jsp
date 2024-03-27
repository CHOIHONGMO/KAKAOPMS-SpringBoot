<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};

        function init() {

        	grid = EVF.C('grid');

            grid.cellClickEvent(function(rowId, colId, value) {

            	if(colId == "AMEND_REASON") {
            		var param = {
          				 title : "${IM02_022_002}"
          				,message : grid.getCellValue(rowId, "AMEND_REASON")
          				,callbackFunction : 'setReason'
          				,detailView : false
          				,rowId : rowId
          			};
            		var url = '/common/popup/common_text_input/view';
    				everPopup.openModalPopup(url, 500, 330, param);
				}
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
            	if(colId == "AFTER_TIER_RATE") {
            		
            	}
	    	});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('shrinkToFit', true);
            grid.setProperty('multiSelect', false);
            grid.setColIconify("AMEND_REASON", "AMEND_REASON", "comment", false);

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setParameter("ITEM_CLS1", "${param.ITEM_CLS1}");
            store.setParameter("ITEM_CLS2", "${param.ITEM_CLS2}");
            store.setParameter("ITEM_CLS3", "${param.ITEM_CLS3}");
            store.setParameter("ITEM_CLS4", "${param.ITEM_CLS4}");
            store.setParameter("TIER_CD", "${param.TIER_CD}");
            store.setGrid([grid]);
            store.load(baseUrl + 'im02022_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

	    	var tire_cd = "${param.TIER_CD}";
	    	var rowIds = grid.getAllRowId();
	    	for(var i in rowIds) {
	    		var tireA = Number(grid.getCellValue(rowIds[i], 'TIER_A_RATE'));
	    		var tireB = Number(grid.getCellValue(rowIds[i], 'TIER_B_RATE'));
	    		var tireC = Number(grid.getCellValue(rowIds[i], 'TIER_C_RATE'));
	    		var after_tier_rate = Number(grid.getCellValue(rowIds[i], 'AFTER_TIER_RATE'));

	    		if (tire_cd == 'A') {
	    			if(after_tier_rate > tireB || after_tier_rate > tireC ) {
	    				return alert('${IM02_022_001}');
					}
				}
	    		if (tire_cd == 'B') {
	    			if(after_tier_rate < tireA || after_tier_rate > tireC ) {
	    				return alert('${IM02_022_001}');
					}
				}
	    		if (tire_cd == 'C') {
	    			if(after_tier_rate < tireB || after_tier_rate < tireA ) {
	    				return alert('${IM02_022_001}');
					}
				}

	        }

            if(!confirm('${msg.M0021}')) { return; }

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.getGridData(grid, 'sel');
			store.load(baseUrl + 'im02022_doSave', function(){
           		alert(this.getResponseMessage());
				opener.doSearch();
				doClose();
           	});
        }

        function setReason(data){
        	grid.setCellValue(data.rowId, 'AMEND_REASON', data.message);
        }

        function doClose() {
			window.close();
        }

    </script>

    <e:window id="IM02_022" onReady="init" initData="${initData}" title="${itemClassNm }" breadCrumbs="${breadCrumb }">

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
            <e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" />
        </e:buttonBar>

    </e:window>
</e:ui>