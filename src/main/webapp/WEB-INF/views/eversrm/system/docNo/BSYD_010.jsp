<!--
* BSYD_010 : 문서번호
* 시스템관리 > 기본정보 > 문서번호
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/docNo/";

		function init() {

			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.setProperty('shrinkToFit', true);

			grid.addRowEvent(function() {
				addParam = [{"USE_FLAG": "1", "DB_FLAG": "I"}];
            	grid.addRow(addParam);
			});

			grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

				grid.delRow();
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch() {
        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doSave', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

    </script>
    <e:window id="BSYD_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_SC_TEXT_N }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
        	<e:row>
                <e:label for="DOC_TYPE" title="${form_DOC_TYPE_N }" />
                <e:field>
                    <e:select id="DOC_TYPE" name="DOC_TYPE" options="${docTypeOptions}" width="${form_DOC_TYPE_W }" required="${form_DOC_TYPE_R }" disabled="${form_DOC_TYPE_D }" readOnly="${form_DOC_TYPE_RO } "  usePlaceHolder="true" useMultipleSelect="true" singleSelect="true"/>
                </e:field>
                <e:label for="PREFIX_STRING" title="${form_PREFIX_STRING_N }" />
                <e:field colSpan="3">
                	<e:inputText id="PREFIX_STRING" style='ime-mode:inactive' name="PREFIX_STRING" width="${form_PREFIX_STRING_W }" required="${form_PREFIX_STRING_R }" disabled="${form_PREFIX_STRING_D }" value="" readOnly="${form_PREFIX_STRING_RO }" maxLength="${form_PREFIX_STRING_M}"/>
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>