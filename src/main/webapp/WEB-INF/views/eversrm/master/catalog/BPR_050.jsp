<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/eversrm/master/catalog";
	    var grid;
	    var popupFlag;
	    var datax;

	    function init() {
	        grid = EVF.C("grid");
	        grid.setProperty('shrinkToFit', true);
	        popupFlag = '${param.popupFlag}';
	        datax = '${param.datax}';

			grid.excelExportEvent({
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${screenName }"
			});

			grid.addRowEvent(function() {
				grid.addRow();
			});

	        doSearch();
	    }

	    function doSearch() {
	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.load(baseUrl + "/catalogTemplatePopup/doSearchCatalogTemplate", function() {
	            if (grid.getRowCount() == 0) {
	                alert("${msg.M0002 }");
	            }
	        });
        }
        function doSelect() {
	        var valid = grid.validate();

	        if( !valid.flag ) { alert('${msg.M0006}'); return; }

	        opener.window['${param.callBackFunction}'](grid.getSelRowValue());
	        doClose();
	    }

	    function doSave() {

	        var valid = grid.validate();

	        if( !valid.flag ) { alert("${msg.M0004}"); return; }

	        if (!confirm("${msg.M0021}")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
	        store.getGridData( grid, 'sel');
	        store.setParameter('datax', datax);
	        store.load(baseUrl + "/catalogTemplatePopup/saveCatalogTemplate", function() {
	            alert(this.getResponseMessage());
	            doClose();
	        });
        }
        function doClose() {
	        window.close();
	    }
	</script>

	<e:window id="BPR_050" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="formTree" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" onEnter="doSearchTree">
            <e:row>
				<e:label for="TPL_NM" title="${form_TPL_NM_N}" />
				<e:field>
					<e:inputText id="TPL_NM" name="TPL_NM" value="${form.TPL_NM}" width="100%" maxLength="${form_TPL_NM_M}" disabled="${form_TPL_NM_D}" readOnly="${form_TPL_NM_RO}" required="${form_TPL_NM_R}" onEnter="doSearch"/>
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>