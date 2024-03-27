<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};
        var selRow;

        function init() {

        	grid = EVF.C('grid');

            grid.cellClickEvent(function(rowId, colId, value) {

            	if(colId == "AMEND_REASON") {
            		var param = {
           				 title : "${IM02_021_001}"
           				,message : grid.getCellValue(rowId, "AMEND_REASON")
           				,detailView : true
           			};
            		var url = '/common/popup/common_text_view/view';
    				everPopup.openModalPopup(url, 500, 320, param);
				}
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('shrinkToFit', true);
            grid.setProperty('multiSelect', false);
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
            store.load(baseUrl + 'im02021_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doClose() {
			window.close();
        }

    </script>

    <e:window id="IM02_021" onReady="init" initData="${initData}" title="${labelString }" breadCrumbs="${breadCrumb }">

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" />
        </e:buttonBar>

    </e:window>
</e:ui>