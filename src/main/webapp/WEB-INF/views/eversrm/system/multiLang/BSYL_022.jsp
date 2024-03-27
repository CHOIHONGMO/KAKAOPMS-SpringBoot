<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid;
		var baseUrl = "/eversrm/system/multiLang/";

		function init() {

			grid = EVF.getComponent("grid");
			grid.setProperty('multiselect', true);
			grid.setProperty("shrinkToFit", true);

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
			    excelOptions : {
					imgWidth      : 0.12,       <%-- // 이미지의 너비. --%>
					imgHeight     : 0.26,      <%-- // 이미지의 높이. --%>
					colWidth      : 20,        <%-- // 컬럼의 넓이. --%>
					rowSize       : 500,       <%-- // 엑셀 행에 높이 사이즈. --%>
			        attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
			    }
			});

            // Grid AddRow Event
            grid.addRowEvent(function () {
                grid.addRow({
                    "SCREEN_ID": EVF.V("SCREEN_ID"),
                    "COLUMN_ID": EVF.V("COLUMN_ID")
                });
            });

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {});
            doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
			store.load(baseUrl + 'BSYL_022_doSearch', function() {

			});
        }

        function doSave() {
			if (!confirm("${msg.M0011 }")) return;
	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'all');
        	store.load(baseUrl + 'BSYL_022_doSave', function(){
                alert('${msg.M0031}');
				doSearch();
        	});

        }

        function doDelete() {
            if (!confirm("${msg.M0011 }")) return;
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BSYL_022_doDelete', function(){
                alert('${msg.M0017}');
                doSearch();
            });

        }

		function doClose() {
			window.close();
		}

    </script>
    <e:window id="BSYL_022" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
		<e:buttonBar id="buttonBar" align="right" width="100%">

			<e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="${param.screen_Id}" />
            <e:inputHidden id="COLUMN_ID" name="COLUMN_ID" value="${param.column_Id}" />
			<e:text id="SCREEN_NM" name="SCREEN_NM" style="font-weight:bold; color:blue;">너비, 높이는 동일하게 적용하시기 바랍니다.</e:text>

            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" />
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" />
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" />

        </e:buttonBar>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>