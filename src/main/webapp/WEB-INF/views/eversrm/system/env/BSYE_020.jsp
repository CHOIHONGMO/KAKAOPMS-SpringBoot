<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/env/";
    	var currentRow;
    	
		function init() {

			grid = EVF.C('grid');

			grid.setProperty('singleSelect', true);

			if ("${param.GATE_CD}" > "") {
				EVF.C("GATE_CD", "${param.GATE_CD}");
	        } else {
	        	EVF.C("GATE_CD", "${ses.gateCd}");
	        }
	
	        if ("${param.BUYER_CD}" > "") {
	        	EVF.C("BUYER_CD", "${param.BUYER_CD}");
	        } else {
	        	EVF.C("BUYER_CD", "${ses.companyCd}");
	        }

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				//grid.checkAll(false);
				//grid.checkRow(rowid, true);
			});
			
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
            store.load(baseUrl + 'environmentSetup_PurOrganizationPopup/doSelectPurOrganization', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }                
            });
        }

        function doSelect() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

			var rowIds = grid.jsonToArray(grid.getSelRowId()).value;
			var selectedData = grid.getRowValue(rowIds[0]);
       		opener.window['${param.callBackFunction}'](selectedData);
	        window.close();
        }

    </script>
    <e:window id="BSYE_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Select" name="Select" label="${Select_N }" disabled="${Select_D }" onClick="doSelect" />
        </e:buttonBar>

        <e:inputHidden id="GATE_CD" name="GATE_CD" value=""/>
        <e:inputHidden id="BUYER_CD" name="BUYER_CD" value=""/>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>