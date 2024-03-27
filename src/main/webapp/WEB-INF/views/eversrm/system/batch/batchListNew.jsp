<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var gridBatchList; var grid;
		var baseUrl = "/eversrm/system/batch/batchListNew";
		var eventRowId;

		function init() {

			gridBatchList = EVF.C('gridBatchList');
			grid = EVF.C('grid');

			grid.showCheckBar(false);
			grid.setProperty('shrinkToFit', true);
			gridBatchList.setProperty('shrinkToFit', true);
			gridBatchList.setProperty('singleSelect', true);

			gridBatchList.cellClickEvent(function(rowId, colId, value) {

				eventRowId = rowId;

				if (colId == "BATCH_NM") {

					EVF.V("JOB_NM", gridBatchList.getCellValue(rowId, 'BATCH_ID'));

					var store = new EVF.Store();
					store.setGrid([grid]);
					store.setParameter("JOB_ID", gridBatchList.getCellValue(rowId, 'BATCH_ID'));
					store.load(baseUrl + '/doSearch', function() {
						if(grid.getRowCount() == 0){
							alert("${msg.M0002 }");
						}
					});
				}
			});

			gridBatchList.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			doSearchBatchList();
		}

		function doSearchBatchList() {

			var store = new EVF.Store();
			if(!store.validate()) return;
			store.setGrid([gridBatchList]);
			store.load(baseUrl + '/doSearchBatchList', function() {
				if(gridBatchList.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doSearch() {

			var store = new EVF.Store();
			if(!store.validate()) return;
			store.setGrid([grid]);
			store.setParameter("JOB_ID", EVF.V("JOB_NM"));
			store.load(baseUrl + '/doSearch', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doExecute() {

			if (gridBatchList.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!confirm("${msg.M8888 }")) return;

			var store = new EVF.Store();
			store.setGrid([gridBatchList]);
			store.getGridData(gridBatchList, 'sel');
			store.load(baseUrl + '/doExecute', function() {

				EVF.V("JOB_NM", gridBatchList.getCellValue(eventRowId, 'BATCH_ID'));

				alert(this.getResponseMessage());
				gridBatchList.checkAll(false);
				doSearch();
			});
		}

    </script>

	<e:window id="batchListNew" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="JOB_DATE_FROM" title="${form_JOB_DATE_FROM_N}" />
				<e:field>
					<e:inputDate id="JOB_DATE_FROM" name="JOB_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_JOB_DATE_FROM_R}" disabled="${form_JOB_DATE_FROM_D}" readOnly="${form_JOB_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="JOB_DATE_TO" name="JOB_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_JOB_DATE_FROM_R}" disabled="${form_JOB_DATE_FROM_D}" readOnly="${form_JOB_DATE_FROM_RO}" />
				</e:field>
				<e:label for="JOB_NM" title="${form_JOB_NM_N}" />
				<e:field>
					<e:select id="JOB_NM" name="JOB_NM" value="" options="${refExecCd }" width="${form_JOB_NM_W}" disabled="${form_JOB_NM_D}" readOnly="${form_JOB_NM_RO}" required="${form_JOB_NM_R}" placeHolder="" />
				</e:field>
				<e:label for="JOB_RLT" title="${form_JOB_RLT_N}" />
				<e:field>
					<e:select id="JOB_RLT" name="JOB_RLT" value="" options="${refProgressCd }" width="${form_JOB_RLT_W}" disabled="${form_JOB_RLT_D}" readOnly="${form_JOB_RLT_RO}" required="${form_JOB_RLT_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doExecute" name="doExecute" label="${doExecute_N}" disabled="${doExecute_D}" visible="${doExecute_V}" onClick="doExecute" align="left" />
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" disabled="${doSearch_D}" visible="${doSearch_V}" onClick="doSearch" />
		</e:buttonBar>

		<!-- 좌측 패널 -->
		<e:panel id="leftPanel" width="20%">
			<e:gridPanel id="gridBatchList" name="gridBatchList" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridBatchList.gridColData}"/>
		</e:panel>

		<e:panel width="1%">&nbsp;</e:panel>

		<!-- 우측 패널 -->
		<e:panel id="rightPanel" width="79%">
			<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</e:panel>

	</e:window>
</e:ui>
