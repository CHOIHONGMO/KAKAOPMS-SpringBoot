<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid, gridSub;
		var baseUrl = "/eversrm/system/multiLang/";

		function init() {
			grid = EVF.C("grid");
			grid.setProperty('multiselect', true);
			grid.setProperty("shrinkToFit", true);

			gridSub = EVF.C("gridSub");
			gridSub.setProperty('multiselect', true);
			gridSub.setProperty("shrinkToFit", true);

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			});

			$("#BSYL_021").css("overflow-y", "hidden");
			grid.resize();
			gridSub.resize();

			doSearch();
			doSearchSub();
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
			store.load(baseUrl + 'BSYL021_doSearch', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				} else {
					EVF.C("SCREEN_NM").setValue("화면 : "+grid.getCellValue(0, "SCREEN_NM"));
					grid.setColMerge(['FORM_GRID_ID']);
				}
			});
        }

	    function doSearchSub() {

		    var store = new EVF.Store();
		    store.setGrid([gridSub]);
		    store.load(baseUrl + 'BSYL021_doSearchSub', function() {
			    if(gridSub.getRowCount() != 0){
				    gridSub.setColMerge(['FORM_GRID_ID']);
			    }
		    });
	    }

        function doSave() {
			if (!confirm("${msg.M0011 }")) return;
	        var store = new EVF.Store();
	        store.setGrid([gridSub]);
        	store.getGridData(gridSub, 'sel');
        	store.load(baseUrl + 'BSYL021_doSave', function(){
					if (!confirm("${BSYL_021_M002}")) return;
					if(opener) {
						opener.location.reload();
				}
				doSearchSub();
        	});

        }

        function doDelete() {
	        if (!confirm("${msg.M0013}")) return;
	        var store = new EVF.Store();
	        store.setGrid([gridSub]);
	        store.getGridData(gridSub, "sel");
	        store.load(baseUrl + 'BSYL021_doDelete', function() {
		        alert("${msg.M0017}");
		        if(opener) {
			        opener.location.reload();
		        }
		        doSearchSub();
	        });
		}

		//초기화 :usln의 테이블의 해당 화면 id 데이터 모두 삭제하고 다시 조회
		function doreset() {
			if (!confirm("${BSYL_021_M001}")) return;
			var store = new EVF.Store();
			store.setGrid([gridSub]);
			store.getGridData(gridSub, "all");
			store.load(baseUrl + 'BSYL021_doReset', function() {
				if (!confirm("${BSYL_021_M003}")) return;
				if(opener) {
					opener.location.reload();
				}
				doSearchSub();
			});
	    }

		function doClose() {
			window.close();
		}

		function doCopyGrid(type) {
			if (type == "R") {
				gridSub.addRow(valid.equalPopupValid(JSON.stringify(grid.getSelRowValue()), gridSub, "COLUMN_ID"));
			} else {
				gridSub.delRow();
			}
		}

    </script>
    <e:window id="BSYL_021" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" height="100%" >
		<e:buttonBar id="buttonBar" align="right" width="100%">

			<e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="${param.screenId}" />
			<e:text id="SCREEN_NM" name="SCREEN_NM" style="font-weight:bold; color:blue;">${SCREEN_NM}</e:text>

            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
			<%--<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>--%>
            <e:button id="reset" name="reset" label="${reset_N }" disabled="${reset_D }" onClick="doreset" />
			<%-- <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="doClose" align="right" /> --%>
        </e:buttonBar>
		<e:panel width="49%">
			<span style="position: relative; float: right; top: 0px; font-size: 12px; color: blue; font-weight: bold;">■ 시스템설정</span>
			<e:gridPanel id="grid" name="grid" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</e:panel>
		<e:panel width="2%" height="100%">
			<div style="display:inline-block; width: 100%; height: 100%; min-height: 1000px; margin-top: 1000%;">
				<p style="margin: 10px auto; width: 13px; height: 22px; cursor: pointer; background: url(/images/eversrm/button/thumb_next.png) no-repeat;" onclick="doCopyGrid('R');"></p>
				<p style="margin: 10px auto; width: 13px; height: 22px; cursor: pointer; background: url(/images/eversrm/button/thumb_prev.png) no-repeat;" onclick="doCopyGrid('L');"></p>
			</div>
		</e:panel>
		<e:panel width="49%">
			<span style="position: relative; float: left; top: 0px; font-size: 12px; color: blue; font-weight: bold;">■ 사용자설정</span>
			<e:gridPanel id="gridSub" name="gridSub" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
		</e:panel>
    </e:window>
</e:ui>