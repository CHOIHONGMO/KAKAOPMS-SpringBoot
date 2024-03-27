<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var baseUrl = "/eversrm/system/multiLang/BSYL_050/";

		function init() {

			grid = EVF.C('grid');

			grid.addRowEvent(function() {
				grid.addRow();
			});
            grid.setProperty('shrinkToFit', true);
	        doSearch();
        }

        function doSearch() {

        	var store = new EVF.Store();        	
        	store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function() {
                <%--if(parent) {--%>
                    <%--parent['setScreenAccessibleCount']('${param.rowId}', grid.getRowCount());--%>
                <%--}--%>
            });
        }

        function doSave() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
			if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var allRowId = grid.getAllRowId();
            var isExistsCdOption = false;
            for(var x in allRowId) {
                var rowId = allRowId[x];
                if(grid.getCellValue(rowId, 'AUTH_TYPE') === 'CD') {
                    if(isExistsCdOption) {
                        return alert('접근가능직무는 1건만 등록가능합니다.');
                    }
                    isExistsCdOption = true;
                }
            }

			if (!confirm("${msg.M0021 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'all');
        	store.load(baseUrl + 'doSave', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            alert("${msg.M0004}");
	            return;
	        }

			if (!confirm("${msg.M0013 }")) {
	            return;
	        }
			var store = new EVF.Store();
            var selRowId = grid.getSelRowId();
            for(var x in selRowId) {
                var rowId = selRowId[x];
                grid.setCellValue(rowId, 'DEL_FLAG', '1');
            }
            store.setGrid([grid]);
            store.getGridData(grid, 'all');

        	store.load(baseUrl + 'doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

		function doClose() {
	        new EVF.ModalWindow().close(null);
	    }

    </script>
    <e:window id="BSYL_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="${param.screenId}" />
        <e:inputHidden id="ACTION_CD" name="ACTION_CD" value="${param.actionCd}" />

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:text style="float: left;">※ 접근권한체크 우선순위: 접근가능직무→접근불가능직무→접근불가능사용자ID</e:text>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>
	    <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>