<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

	var grid = {};
	var baseUrl = "/eversrm/system/batch/batchList";

	function init() {

		grid = EVF.C('grid');

        grid.showCheckBar(false);
		grid.setProperty('shrinkToFit', true);

		grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

    }

    function doSearch() {

    	var store = new EVF.Store();
        if(!store.validate()) return;
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    </script>

	<e:window id="batchList" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

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
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" />
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>
