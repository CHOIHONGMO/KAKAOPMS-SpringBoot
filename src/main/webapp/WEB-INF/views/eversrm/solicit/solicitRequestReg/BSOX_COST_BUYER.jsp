<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    var grid;
    var baseUrl = "";
	var selRow;

    function init() {
        grid = EVF.C("grid");
     
        grid.delRowEvent(function() {
			grid.delRow();
        });
        
        grid.addRowEvent(function() {
            grid.addRow();
        });        
        
        
        grid.setProperty('shrinkToFit', true);
        <c:if test="${param.COST_TEXT != null && param.COST_TEXT != ''}">

        var kkk = ${param.COST_TEXT};
//    	var data = JSON.parse(kkk);
        var arrData = [];
    	for (var k = 0; k < kkk.length; k++) {
            arrData.push({
            	COST_TYPE_CD          : kkk[k].COST_TYPE_CD,
            	COST_TEXT    : kkk[k].COST_TEXT 
            });
            
    	}
    	grid.addRow(arrData);
        
        </c:if>

    }

    function doClose() {
    	window.close();
    }
    
    function doApply() {
    	var store = new EVF.Store();
        if(!store.validate()) return;
    	grid.checkAll(true);

    	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

    	if (!grid.validate().flag) { return alert(grid.validate().msg); }    	
    	
    	var sformData = JSON.stringify(grid.getSelRowValue());
        opener.${param.callBackFunction}(sformData, ${param.rowid});
    	doClose();
    	
    }
    
</script>


    <e:window id="BSOX_COST_BUYER" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar align="right">
        <e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
        <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>