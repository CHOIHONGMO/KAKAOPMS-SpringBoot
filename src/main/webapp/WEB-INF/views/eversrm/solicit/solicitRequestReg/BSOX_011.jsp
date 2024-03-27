<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    var grid;
    var baseUrl = "/eversrm/solicit/solicitRequestReg/";

    function init() {
        grid = EVF.C("grid");

        grid.delRowEvent(function() {
			grid.delRow();
        });        
        
        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	
        });
        
       	doSearch();
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "BSOX_011/doSearch", function() {
            if ('${param.PRICE_DECISION_BASE_CODE_LIST}' != null && '${param.PRICE_DECISION_BASE_CODE_LIST}' != '') {
            	var data = JSON.parse('${param.PRICE_DECISION_BASE_CODE_LIST}');
                var arrData = [];
            	for (var k = 0; k < data.length; k++) {
            		for(var t = 0;t<grid.getRowCount();t++) {
            			if(data[k].CODE == grid.getCellValue(grid.getRowId(t),'CODE')) {
            				grid.checkRow(grid.getRowId(t),true);
            			}
            		}
            	}
            }        	
        });
    }
    
    function doSave() {
    	var store = new EVF.Store();
    	if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
    	var kkk = grid.getSelRowValue();
    	var text = '';
    	var temp_text= '';
    	var cou=0;
    	for(var k = 0;k<kkk.length;k++) {
    		if(temp_text!=kkk[k].CODE_DESC ) {
	    		if (cou!=0) text+=',';
	    		text+=kkk[k].CODE_DESC;
	    		cou++;
	    		temp_text = kkk[k].CODE_DESC;
    		}
    	}
        var sformData = JSON.stringify(kkk);
      //  alert(text)
        opener.${param.callBackFunction}(text, sformData);
        doClose();
    }
    
    function doClose() {
    	window.close();
    }

    </script>

    <e:window id="BSOX_011" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
			<c:if test="${param.detailView != 'true' }">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			</c:if>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>

