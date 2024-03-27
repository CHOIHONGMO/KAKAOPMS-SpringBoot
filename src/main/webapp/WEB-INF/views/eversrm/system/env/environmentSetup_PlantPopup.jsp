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
    		grid.setProperty('shrinkToFit', true);
    		if ("${param.GATE_CD}".length > 0) {
    			EVF.C('GATE_CD').setValue("${param.GATE_CD}");
    		} else {
    			EVF.C('GATE_CD').setValue("${ses.gateCd}");
    		}
    		
    		if ("${param.BUYER_CD}".length > 0) {
    			EVF.C('BUYER_CD').setValue("${param.BUYER_CD}");
    		} else {
    			EVF.C('BUYER_CD').setValue("${ses.companyCd}");
    		}
    		
    		grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if( celname == 'multiSelect' ) {
					grid.checkRow( grid.jsonToArray(value)['value'], false );
					grid.checkRow( rowid, true );
				}
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
            store.load(baseUrl + 'environmentSetup_PlantPopup/doSelectPlant', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }                
            });
    	}
    	
    	function doSelect() {
    		var selRowCnt = Object.keys(grid.getSelRowId()).length;
    		if( selRowCnt == 0 || selRowCnt > 1) {
    			alert('${BSA_214_ROWCHECK}');
    			return;
    		}
    		
            opener.window['${param.callBackFunction}'](grid.getSelRowValue());
            window.close();
    	}
    </script>
    
    <e:window id="BSA_214" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" columnCount="2" labelWidth="${labelWidth }">
        	<e:inputHidden id="GATE_CD" name="GATE_CD" value=""/>
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value=""/>
        </e:searchPanel>
		<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}"/>
        </e:buttonBar>
        
		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>