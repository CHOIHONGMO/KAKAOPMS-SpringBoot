<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/master/vendor/";
    var rowc;
    var vendorCdList = "${vendorCdList}";
    var vendorCd = "${param.vendorCdParams}";
    var vendorNm ="${param.vendorNmParams}";

    function init() {

        grid = EVF.C("grid");

        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.cellClickEvent(function(rowid, celname, value, iRow, iCol, treeInfo) {

        });
		<%--
        grid.addRowEvent(function() {
        	var addParam = [
				{"VENDOR_CD" : vendorCd
				,"VENDOR_NM" : vendorNm
				,"MAIL_FLAG" : '1'}
			];
        	grid.addRow(addParam);
        });

        grid.delRowEvent(function() {
            if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
                return alert("${msg.M0004}");
            }
            grid.delRow();
        });
        --%>

        grid.setProperty('shrinkToFit', true);

        doSearch();
    }

    function doSearch() {
    	var store = new EVF.Store();
        store.setGrid([grid]);
        store.setParameter("vendorCdParams", "${param.vendorCdParams}");
        store.load(baseUrl + "BBV_060/doSearch", function() {
            if(grid.getRowCount() == 0){
                this.getParameter("ABC");
            }
            grid.checkAll(true);
        });
    }

    function doInsert() {
        grid.addRow();
    }

    function doDel() {
        if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
        grid.delRow();
    }

	function doClose() {
        formUtil.close();
    }

	function doSelect() {

        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        <%-- 해당리스트에서 추가된 데이터가 있으면 저장 후 선택하라는 경고띄울것 --%>
        var rowData = grid.getSelRowId();
        for (var i in rowData) {
            if(grid.getCellValue(i, "PERSON_SQ")==""||grid.getCellValue(i, "PERSON_SQ")==null){
                alert('${BBV_060_0001}');
                return;
            }
        }
        opener.window['${param.callBackFunction}'](JSON.stringify(grid.getSelRowValue()));
        window.close();
    }

    <%--신규로 추가된 사용자 저장 ||업데이트 --%>
    function doSave(){
        var store = new EVF.Store();
        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if (!grid.validate().flag) { return alert(grid.validate().msg); }


        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        if (!confirm("${msg.M0021}")) return;
        store.load(baseUrl + "BBV_060/doSave", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    <%--사용자 삭제 --%>
    function doDelete(){
        var store = new EVF.Store();
        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        if (!confirm('${BBV_060_0002}')) return;
        store.load(baseUrl + "BBV_060/doDelete", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function selectVendorCode(dataJsonArray) {
        grid.setCellValue(rowc, "VENDOR_CD", dataJsonArray.VENDOR_CD);
        grid.setCellValue(rowc, "VENDOR_NM", dataJsonArray.VENDOR_NM);
        grid.setCellValue(rowc, "VENDOR_NMs", dataJsonArray.VENDOR_NM);
    }

    </script>

    <e:window id="BBV_060" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}" />
            <%--
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}" />
            <e:button id="doInsert" name="doInsert" label="${doInsert_N}" onClick="doInsert" disabled="${doInsert_D}" visible="${doInsert_V}" />
            <e:button id="doDel" name="doDel" label="${doDel_N}" onClick="doDel" disabled="${doDel_D}" visible="${doDel_V}" />
            --%>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
