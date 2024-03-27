<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid = {};
		var baseUrl = "/eversrm/system/task/";
		var ID;

		function init() {

			grid = EVF.C('grid');

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if(celname == "CTRL_CD") {
					opener.window["${param.callBackFunction}"](grid.getRowValue(rowid));
					doClose();
				}
			});

			EVF.C("buyerCd").setValue('${param.BUYER_CD}');
			ID = '${param.ID}';
			doSearch();
		}

		function doSearch() {

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + 'selectTaskCodeBySearch', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doClose() {
			window.close();
		}

	</script>
	<e:window id="BSYT_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="4" labelWidth="${labelWidth}">
			<e:row>
				<e:inputHidden id="buyerCd" name="buyerCd" value="" />
				<e:inputHidden id="ctrlType" name="ctrlType" value="" />
			</e:row>
		</e:searchPanel>
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
			<e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" />
		</e:buttonBar>
		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>