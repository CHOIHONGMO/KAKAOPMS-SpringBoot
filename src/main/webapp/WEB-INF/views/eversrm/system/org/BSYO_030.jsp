<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    	var baseUrl = "/eversrm/system/org/";
    	var grid = {};
    	
		function init() {

			grid = EVF.C('grid');
			grid.setProperty('shrinkToFit', true);

			var companyCdList =  ${companyCdList};
	        for(var x in companyCdList){
	        	if(companyCdList.hasOwnProperty(x)){
	        		//grid.addComboListValue("REAL_BUYER_CODE", companyCdList[x], companyCdList[x].value)
	        	}
	        }
		    grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",        
			    excelOptions : {
					 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
					,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
			        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});

		    doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();        	
        	store.setGrid([grid]);
            store.load(baseUrl + 'BSYO_030/selectPurchaseComMapping', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }                
            });
        }

        function doSave() {

			if (grid.getSelRowId() == null) {
	            return alert("${msg.M0004}");
	        }
			if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');        	
        	store.load(baseUrl + 'BSYO_030/savePurchaseComMapping', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }
	
    </script>
    <e:window id="BSYO_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:inputHidden id="gateCdOri" name="gateCdOri"/>
		<e:inputHidden id="buyerCdOri" name="buyerCdOri"/>
		
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
        </e:buttonBar>
        
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        
    </e:window>
</e:ui>