<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
		var baseUrl = "/evermp/buyer/cn/CN0120P03/";
		var grid;


	    function init() {
	        grid = EVF.C("grid");
			grid.setProperty("shrinkToFit", false);
			grid.showCheckBar(false);

			grid.excelExportEvent({
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${fullScreenName}"
			});

		    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

		    });

	        grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

		    });

			grid.setColGroup([{
				"groupName": "예산",
				"columns": [ "CPO_UNIT_PRICE", "CPO_UNIT_AMT" ]
			}, {
				"groupName": "매출기준",
				"columns": [ "S_UNIT_CD", "S_ITEM_QT" ]
			}, {
				"groupName": "매출",
				"columns": [ "SALES_UNIT_PRC", "SALES_UNIT_AMT", "SALES_RATE" ]
			}, {
				"groupName": "매입",
				"columns": [ "QTA_UNIT_PRC", "QTA_UNIT_AMT", "QTA_RATE" ]
			},{
				"groupName": "이익",
				"columns": [ "PROFIT_AMT", "PROFIT_RATE" ]
			}],35);

			doSearch();
	    }


	    function doSearch() {
	        var store = new EVF.Store();
	        if(!store.validate()) return;

	        store.setGrid([grid]);

			store.setParameter("qtaNumList", '${param.QTA_NUM_LIST}');
			store.setParameter("EXEC_NUM", '${param.EXEC_NUM}');
			store.setParameter("EXEC_CNT", '${param.EXEC_CNT}');
	        store.load(baseUrl + "doSearch", function() {
	        });
        }

        function doClose() {
     		if(opener != null) {
     			window.close();
     		} else {
     			new EVF.ModalWindow().close(null);
     		}
        }

	</script>

	<e:window id="CN0120P03" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">

		<%--
        <e:buttonBar align="right">
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
		--%>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>