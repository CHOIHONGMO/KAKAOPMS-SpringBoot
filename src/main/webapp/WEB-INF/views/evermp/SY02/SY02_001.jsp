<%@page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

		var grid;
		var gridTx;
		var addParam = [];
		var baseUrl = "/evermp/SY02/SY0201/";

		function init() {
			grid = EVF.C("grid");
			gridTx = EVF.C("gridTx");

			grid.cellClickEvent(function(rowId, colId, value) {

			});

			grid.addRowEvent(function() {
				//var addParam = [{"YEAR":(new Date().toString('yyyy'))}];
				grid.addRow();
			});

			grid.delRowEvent(function() {
				if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
				grid.delRow();
			});

			grid.excelImportEvent({
				'append': false
			}, function (msg, code) {
				if (code) {
					grid.checkAll(true);
				}
			});

			grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			gridTx.addRowEvent(function() {
				//var addParam = [{"YEAR":(new Date().toString('yyyy'))}];
				gridTx.addRow();
			});

			gridTx.delRowEvent(function() {
				if(!gridTx.isExistsSelRow()) { return alert("${msg.M0004}"); }
				gridTx.delRow();
			});

			grid.setProperty('shrinkToFit', true);
			gridTx.setProperty('shrinkToFit', true);
			<%--
			grid.setProperty('shrinkToFit', true/false);	컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다.
			grid.setProperty('rowNumbers', true/false);		로우의 번호 표시 여부를 지정한다.
			grid.setProperty('sortable', true/false);		컬럼 정렬기능 사용여부를 지정한다.
			grid.setProperty('panelVisible', true/false);	그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다.
			grid.setProperty('enterToNextRow', true/false);	셀에서 엔터입력 시 포커스의 이동방향을 지정한다.
			grid.setProperty('acceptZero', true/false);		그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다.
			grid.setProperty('multiSelect', true/false);	[선택] 컬럼의 사용여부를 지정한다.
			grid.setProperty('singleSelect', true/false);	[선택] 컬럼의 다중선택 여부를 지정한다.
			--%>
		}



		function doSearch() {
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([grid]);
			store.load(baseUrl + 'sy02001_doSearch', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doSave() {
			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if(!confirm('${msg.M0021}')) { return; }

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'sy02001_doSave', function() {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doDelete() {

			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if(!confirm('${msg.M0013}')) { return; }

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'sy02001_doDelete', function() {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doSearchTx() {
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([gridTx]);
			store.load(baseUrl + 'sy02001_doSearchTx', function() {
				if(gridTx.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doSaveTx() {
			if (gridTx.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!gridTx.validate().flag) { return alert(gridTx.validate().msg); }

			if(!confirm('${msg.M0021}')) { return; }

			var store = new EVF.Store();
			store.setGrid([gridTx]);
			store.getGridData(gridTx, 'sel');
			store.load(baseUrl + 'sy02001_doSaveTx', function() {
				alert(this.getResponseMessage());
				doSearchTx();
			});
		}
		function doDeleteTx() {
			if (gridTx.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if(!confirm('${msg.M0013}')) { return; }

			var store = new EVF.Store();
			store.setGrid([gridTx]);
			store.getGridData(gridTx, 'sel');
			store.load(baseUrl + 'sy02001_doDeleteTx', function() {
				alert(this.getResponseMessage());
				doSearchTx();
			});
		}

	</script>
	<e:window id="SY02_001" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:panel id="leftPanel" height="100%" width="49%">
			<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="100" width="100%" columnCount="3" useTitleBar="false">
				<e:row>
					<e:label for="YEAR" title="${form_YEAR_N}" />
					<e:field>
						<e:select id="YEAR" name="YEAR" value="<%=EverDate.getYear()%>" options="${yearOptions}" width="100%" required="${form_YEAR_R }" readOnly="${form_YEAR_RO }" disabled="${form_YEAR_D }" useMultipleSelect="true" />
					</e:field>
					<e:label for="MONTH" title="${form_MONTH_N}" />
					<e:field>
						<e:select id="MONTH" name="MONTH" value="<%=EverDate.getMonth()%>" options="${monthOptions}" width="100%" required="${form_MONTH_R }" readOnly="${form_MONTH_RO }" disabled="${form_MONTH_D }" useMultipleSelect="true" usePlaceHolder="false"/>
					</e:field>
					<e:label for="HOLYDAY_TYPE" title="${form_HOLYDAY_TYPE_N}" />
					<e:field>
						<e:select id="HOLYDAY_TYPE" name="HOLYDAY_TYPE" value="" options="${holydayTypeOptions}" width="100%" required="${form_HOLYDAY_TYPE_R }" readOnly="${form_HOLYDAY_TYPE_RO }" disabled="${form_HOLYDAY_TYPE_D }" useMultipleSelect="true" />
					</e:field>
				</e:row>
			</e:searchPanel>

			<e:buttonBar id="buttonBar" align="right" width="100%">
				<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
				<e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
				<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
			</e:buttonBar>

			<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</e:panel>
		<e:panel id="middlePanel" height="100%" width="1%">&nbsp;</e:panel>
		<e:panel id="rightPanel" height="100%" width="50%">
			<e:searchPanel id="formTx" title="${formTx_CAPTION_N }" labelWidth="100" width="100%" columnCount="1" useTitleBar="false">
				<e:row>
					<e:label for="YEARTX" title="${formTx_YEARTX_N}" />
					<e:field>
						<e:select id="YEARTX" name="YEARTX" value="<%=EverDate.getYear()%>" options="${yeartxOptions}" width="100%" required="${formTx_YEARTX_R }" readOnly="${formTx_YEARTX_RO }" disabled="${formTx_YEARTX_D }" useMultipleSelect="true" />
					</e:field>
				</e:row>
			</e:searchPanel>

			<e:panel width="60%">
				<div style="float: left;margin-top: 3px;">
					<e:text style="color:blue;font-weight:bold;">■ 세금계산서 발행마감일 관리 </e:text>
				</div>
			</e:panel>

			<e:panel width="40%">
				<e:buttonBar id="buttonBarTx" align="right" width="100%">
					<e:button id="SearchTx" name="SearchTx" label="${SearchTx_N }" disabled="${SearchTx_D }" visible="${SearchTx_V}" onClick="doSearchTx" />
					<e:button id="SaveTx" name="SaveTx" label="${SaveTx_N }" disabled="${SaveTx_D }" visible="${SaveTx_V}" onClick="doSaveTx" />
					<e:button id="DeleteTx" name="DeleteTx" label="${DeleteTx_N }" disabled="${DeleteTx_D }" visible="${DeleteTx_V}" onClick="doDeleteTx" />
				</e:buttonBar>
			</e:panel>

			<e:gridPanel id="gridTx" name="gridTx" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridTx.gridColData}" />


		</e:panel>
	</e:window>
</e:ui>