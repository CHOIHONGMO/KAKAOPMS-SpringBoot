<!--
* IM04_007 : 분류별 속성 선택
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
<link rel="StyleSheet" href="/js/dtree/dtree.css" type="text/css" />
<script type="text/javascript" src="/js/dtree/dtree.js"></script>
<script>
<!--
    var grid;
    var baseUrl = "/evermp/IM04/IM0407/";

    function init() {
    	grid = EVF.C("grid");
		grid.setProperty('multiSelect', true);
		grid.setProperty('shrinkToFit', true);
		
		grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.cellClickEvent(function(rowId, colId, value) {
        	if(colId == "CUST_NM") {
        		grid.checkAll(false);
	        	grid.checkRow(rowId,true);
	        	doSearch_2ndCustInfo(rowId);
			}
		});
        
        grid.addRowEvent(function() {
            grid.addRow([
                {"INSERT_FLAG": "I"}
            ]);
        });
        
        doSearch();
    }

    function doSearch() {
      	var store = new EVF.Store();
      	if(!store.validate()) return; 
		
      	store.setGrid([grid]);
      	store.load(baseUrl + 'doSearch', function() {
      	});
    }
	
    function doSave() {
      	var store = new EVF.Store();
      	
    	if( !grid.validate().flag ) {
    		return alert(grid.validate().msg);
    	}
    	
  	  	//if( !confirm("${msg.M0021}") ) {
  	  	//	return;
		//}
	  	
      	store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
      	store.load(baseUrl + 'doSave', function(){
      		alert(this.getResponseMessage());
      		doSearch();
      	});
    }
    
    function doDelete() {
      	var store = new EVF.Store();
      	
  	  	if( !confirm("${msg.M0013}") ) {
  	  		return;
		}
	  	
      	store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
      	store.load(baseUrl + 'doDelete', function(){
      		alert(this.getResponseMessage());
      		doSearch();
      	});
    }
    
    function doClose() {
        if( ${param.ModalPopup == true} ){
            new EVF.ModalWindow().close(null);
        } else {
            window.close();
        }
    }
// -->
</script>

<e:window id="IM04_007" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" columnCount="1" useTitleBar="false" onEnter="doSearch">
    	<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${param.ITEM_CLS1 }" /> 
    	<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${param.ITEM_CLS2 }" />
    	<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${param.ITEM_CLS3 }" />
    	
		<e:row>
			<e:label for="ITEM_PATH_NM" title="${form_ITEM_PATH_NM_N}" />
			<e:field>
				<e:inputText id="ITEM_CLS4" name="ITEM_CLS4" value="${param.ITEM_CLS4 }" width="15%" maxLength="${form_ITEM_CLS4_M}" disabled="${form_ITEM_CLS4_D}" readOnly="${form_ITEM_CLS4_RO}" required="${form_ITEM_CLS4_R}" />
				<e:inputText id="ITEM_PATH_NM" name="ITEM_PATH_NM" value="${param.ITEM_PATH_NM }" width="85%" maxLength="${form_ITEM_PATH_NM_M}" disabled="${form_ITEM_PATH_NM_D}" readOnly="${form_ITEM_PATH_NM_RO}" required="${form_ITEM_PATH_NM_R}" />
			</e:field>
		</e:row>
    </e:searchPanel>
    
    <e:buttonBar id="buttonBar" align="right" width="100%">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
    </e:buttonBar>
    
    <e:gridPanel id="grid" name="grid" width="100%" height="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>

</e:ui>
