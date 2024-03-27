<!--
* IM04_008p : 속성조회 팝업
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
<script>

	var grid;
	var gridTree;
    var baseUrl = "/evermp/IM04/IM0407/";
    var selRowId;

    function init() {
    	grid = EVF.C("grid");
		grid.setProperty('multiSelect', true);
		grid.setProperty('shrinkToFit', true);
		
	    grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
	    	 if(colId == 'CODE') {
	    	    grid.checkRow(rowId, true);
   	          }
	    });
	    
		grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});
    }

    
    function doSearch() {
      	var store = new EVF.Store();
		
      	if(!store.validate()) return; 
		
      	store.setGrid([grid]);
      	store.load(baseUrl + 'doSearchCommonCode', function() {
      	});
    }

    function doSelect() {
    	var resultData = grid.getSelRowValue();
        if( resultData.length == 0 ) {
        	alert('${msg.M0004}');
        	return;
        }
        
        opener.window['${param.callBackFunction}'](JSON.stringify(resultData));
        grid.checkAll(false);
    }
    
    function doClose() {
        if( ${param.ModalPopup == true} ){
            new EVF.ModalWindow().close(null);
        } else {
            window.close();
        }
    }

</script>

<e:window id="IM04_008P" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" columnCount="1" useTitleBar="false" onEnter="doSearch">
		<e:row>
			<e:label for="CODE_NM" title="${form_CODE_NM_N}" />
			<e:field>
				<e:inputText id="CODE_NM" name="CODE_NM" value="" width="${form_CODE_NM_W}" maxLength="${form_CODE_NM_M}" disabled="${form_CODE_NM_D}" readOnly="${form_CODE_NM_RO}" required="${form_CODE_NM_R}" />
			</e:field>
		</e:row>
    </e:searchPanel>
    
    <e:buttonBar id="buttonBar" align="right" width="100%">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        <e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}"/>
    </e:buttonBar>
    
    <e:gridPanel id="grid" name="grid" width="100%" height="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
</e:window>

</e:ui>
