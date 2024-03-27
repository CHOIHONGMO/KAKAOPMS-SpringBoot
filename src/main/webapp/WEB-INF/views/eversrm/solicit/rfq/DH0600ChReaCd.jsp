<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
    	grid = EVF.C("grid");
    	doSearch();
    	
    }
    
    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter('itemList','${param.itemList}');
        store.load(baseUrl + "DH0600ChReaCd/doSearch", function() {
        	
        	
        	var kgb = '${param.CHANGE_REASON_CD}';
        	if (kgb!='') {
           	 	var array_data = kgb.split(","); 
           	 	for(k=0;k<array_data.length;k++) {
					
           	 		for(j=0;j<grid.getRowCount();j++) {
  	         	 		if (array_data[k] == grid.getCellValue(j,'REASON_CD') ) {
  	         	 			grid.checkRow(j, true);
  	         	 		}
           	 		}
           	 		
           	 		
           	 	}
        	}
        });
    }
	
    function doApply() {
    	var selDatas = grid.getSelRowValue();
		var codes='';
		var texts='';
    	//alert(JSON.stringify(selDatas));
    	for( k=0; k < selDatas.length; k++ ) {
			if (k!=0) {
				codes+=',';
				texts+=',';
			}
			codes+=selDatas[k].REASON_CD;
			texts+=selDatas[k].REASON_NM
		}
    	opener.${param.callBackFunction}(codes,texts);
		window.close();
    }
    
    
    function doClose() {
    	window.close();
    }
    
    
</script>
    <e:window id="DH0600ChReaCd" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
			<e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="280" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>