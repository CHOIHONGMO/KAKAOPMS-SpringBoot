<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/master/item/BBM_070/";
    var grid;
    var clickFlag = false;
    var columnName, rowIndex, columnNameHidden;

    function init() {

        grid = EVF.C("grid");
        grid.setProperty('shrinkToFit', true);
        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            // TODO: 이 화면을 팝업으로 쓰는 화면이 있다면 테스트를 따로 진행해야함
            if ('${param.onSelect}' != '') {
                var iRowCount = grid.getRowCount();
                for (var i = 0; i < iRowCount; i++) {
//                    grid.setCellValue("SELECTED", i, '0');
                }
//                grid.setCellValue("SELECTED", nRow, '1');
            }
        });

        grid.addRowEvent(function() {
            grid.addRow([{'INSERT_FLAG':'I', 'USE_FLAG':'1'}]);
        });

        grid.delRowEvent(function() {
            grid.delRow();
        });

        var excelProp = {
            allCol: "${excelExport.allCol}",
            selRow: "${excelExport.selRow}",
            fileType: "${excelExport.fileType}",
            fileName: "${fullScreenName}",
            excelOptions: {
                imgWidth: 0.12,        <%-- // 이미지의 너비. --%>
                imgHeight: 0.26 ,      <%-- // 이미지의 높이. --%>
                colWidth: 20,          <%-- // 컬럼의 넓이. --%>
                rowSize: 500,          <%-- // 엑셀 행에 높이 사이즈. --%>
                attachImgFlag: false   <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
            }
        };
        grid.excelExportEvent(excelProp);
    }
    function initWhenPopup() {

        EVF.C("btnSearch").setVisible(false);
        EVF.C("btnAddLine").setVisible(false);
        EVF.C("btnSave").setVisible(false);
        EVF.C("btnDelete").setVisible(false);
//        EVF.C("btnSearch").setMaxWidth(1);
//        EVF.C("btnAddLine").setMaxWidth(1);
//        EVF.C("btnSave").setMaxWidth(1);
//        EVF.C("btnDelete").setMaxWidth(1);

        EVF.C("btnSearchPopup").setVisible(true);
        EVF.C("btnSelect").setVisible(true);

    }

    function doSelect() {

        var selectedData = [];
        var selRowId = grid.getSelRowId();
        for(var i in selRowId) {
            var rowData = grid.getRowValue(selRowId[i]);
            selectedData.push(rowData);
        }

        // TODO: 이 화면을 팝업으로 쓰는 화면에서 이 로직의 테스트가 필요 ('14.7.2 azure)
        opener.window['${param.onSelect}'](selectedData);
        self.close();
    }
    function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "doSearchItemAttributeManagement", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
        });
    }

    function doSave() {

        if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        if (!confirm("${msg.M0021}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + "doSaveAttributeManagement", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

    function doDelete() {

        if(grid.jsonToArray(grid.getSelRowId())['key'].length === 0) {
            return alert("${msg.M0004}");
        }

        if (!confirm("${msg.M0013}")) return;

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + "doDeleteAttributeManagement", function() {
            alert(this.getResponseMessage());
            doSearch();
        });
    }

</script>
    <e:window id="BBM_070" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:inputHidden id="houseCodeOri" name="houseCodeOri" />
        <e:inputHidden id="buyerCodeOri" name="buyerCodeOri" />

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="ATTR_NM" title="${form_ATTR_NM_N}" />
                <e:field>
                    <e:inputText id='ATTR_NM' name="ATTR_NM" width='${inputTextWidth }' maxLength='${form_ATTR_NM_M }' required='${form_ATTR_NM_R }' readOnly='${form_ATTR_NM_RO }' disabled="${form_ATTR_NM_D}" visible="${form_ATTR_NM_V}" style="${imeMode}"/>
                </e:field>
                <e:label for="USE_FLAG" title="${form_USE_FLAG_N}" />
                <e:field>
                    <e:select id='USE_FLAG' name="USE_FLAG" placeHolder='${placeHolder }' options="${refUsageStatus}" label='${form_USE_FLAG_N }' required="${form_USE_FLAG_N }" disabled="${form_USE_FLAG_D }" readOnly="${form_USE_FLAG_RO }" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A}' />
			<c:if test="${ses.ctrlCd != null && ses.ctrlCd != '' }">
    	        <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' data='${doSave_A}' />
        	    <e:button label='${doDelete_N }' id='doDelete' onClick='doDelete' disabled='${doDelete_D }' visible='${doDelete_V }' data='${doDelete_A}' />
        	</c:if>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>