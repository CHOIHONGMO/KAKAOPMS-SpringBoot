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

            doCheckBudget();
        }

        function doCheckBudget() {

        	var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            if("${param.itemInfo }" == ""){
                store.setParameter("itemInfo", '${param.itemInfo }');
                store.load(baseUrl + 'BOD1_031/doSearchAll', function() {
                	grid.checkAll(true);
                });
            }else{
                store.setParameter("itemInfo", '${param.itemInfo }');
                store.load(baseUrl + 'BOD1_031/doSearch', function() {
                	grid.checkAll(true);
                });
            }
        }

        function doConfirm() {
        	grid.checkAll(true);

        	var resultFlagCnt = 0;
        	var rowIds = grid.getSelRowId();
        	for( var i in rowIds ) {
	        	if( grid.getCellValue(rowIds[i], 'RESULT_CD') == 'F'){
	        		 resultFlagCnt++;
	        	}
	        }

        	var budgetCheckFlag = 'N';
	        if( resultFlagCnt > 0 ) {
	        	if( !confirm("${BOD1_031_001}") ) return;
	        } else {
	        	budgetCheckFlag = 'Y';
	        }

	        var param = {
            		'budgetCheckFlag' : budgetCheckFlag
        		};
	        parent['${param.callBackFunction}'](param);
	        doClose();
        }

        function doClose() {
			new EVF.ModalWindow().close(null);
		}
    </script>

    <e:window id="BOD1_031" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doCheckBudget" name="doCheckBudget" label="${doCheckBudget_N}" onClick="doCheckBudget" disabled="${doCheckBudget_D}" visible="${doCheckBudget_V}"/>
            <c:if test="${param.itemInfo != ''}">
                <e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
            </c:if>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>