<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var baseUrl = "/eversrm/master/item/BBM_060/";

    var grid;
    var rowIndex;
    var clickFlag = false;
    var activeRowId;

    function init() {
        grid = EVF.C("grid");
        grid.setProperty('panelVisible', ${panelVisible});
        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
            if(celName == 'ATTR_NM') {
                activeRowId = rowId;
                var param = {
                    GATE_CD: "${ses.gateCd}",
                    callBackFunction: "setAttrId"
                };
                everPopup.openCommonPopup(param, 'SP0017');
            }
        });

        grid.addRowEvent(function() {
            if (grid.getRowCount() == 0) {
                return alert("${msg.M0004 }");
            }

            //var lastRowData = grid.getRowValue(grid.getLastRowId());
            var lastRowData = grid.getRowValue(grid.getRowId(grid.getRowCount() - 1));
            var newRowData = {
                'ITEM_CLS1': lastRowData['ITEM_CLS1'],
                'ITEM_CLS1_NM': lastRowData['ITEM_CLS1_NM'],
                'ITEM_CLS2': lastRowData['ITEM_CLS2'],
                'ITEM_CLS2_NM': lastRowData['ITEM_CLS2_NM'],
                'ITEM_CLS3': lastRowData['ITEM_CLS3'],
                'ITEM_CLS3_NM': lastRowData['ITEM_CLS3_NM'],
                'ITEM_CLS4': lastRowData['ITEM_CLS4'],
                'ITEM_CLS4_NM': lastRowData['ITEM_CLS4_NM'],
                'REQUIRE_FLAG': lastRowData['REQUIRE_FLAG'],
                'GATE_CD': lastRowData['GATE_CD'],
                'INSERT_FLAG': lastRowData['INSERT_FLAG']
            };
            grid.addRow([newRowData]);
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

        grid.setProperty('shrinkToFit', false);
    }

        function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "doSearchItemAttributeLink", function () {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
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
        store.load(baseUrl + "doDeleteItemLink", function () {
            alert(this.getResponseMessage());
            doSearch();
        });
    }


    function doSave() {

        if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        if(!confirm('${msg.M0021}')) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + "doSaveItemAttrLink", function () {
            alert(this.getResponseMessage());
            doSearch();
        });

    }

    function setAttrId(data) {
        grid.setCellValue(activeRowId, "ATTR_NM", data['ATTR_NM']);
        grid.setCellValue(activeRowId, "ATTR_ID", data['ATTR_ID']);
    }

    function doCopy() {

        if(grid.jsonToArray(grid.getSelRowId())['key'].length === 0) {
            return alert("${msg.M0004}");
        }

        var selRowId = grid.getSelRowId();
        var copiedData = [];
        for(var i in selRowId) {
            var rowData = grid.getRowValue(selRowId[i]);
            copiedData.push({
                'ITEM_CLS1': rowData['ITEM_CLS1'],
                'ITEM_CLS2': rowData['ITEM_CLS2'],
                'ITEM_CLS3': rowData['ITEM_CLS3'],
                'ITEM_CLS4': rowData['ITEM_CLS4'],
                'ITEM_CLS1_NM': rowData['ITEM_CLS1_NM'],
                'ITEM_CLS2_NM': rowData['ITEM_CLS2_NM'],
                'ITEM_CLS3_NM': rowData['ITEM_CLS3_NM'],
                'ITEM_CLS4_NM': rowData['ITEM_CLS4_NM'],
                'INSERT_FLAG': 'I'
            });
        }
        grid.checkRow(selRowId, false);
        grid.addRow(copiedData);
    }

</script>

<e:window id="BBM_060" onReady="init" initData="${initData}" title="${fullScreenName}">
    <e:inputHidden id="gateCdOri" name="gateCdOri"/>
    <e:inputHidden id="buyerCodeOri" name="buyerCodeOri"/>
    <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
        <e:row>
            <e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}" />
            <e:field colSpan="3">
                <e:select id='ITEM_CLS' name="ITEM_CLS" options="${refItemType}" required='${form_ITEM_CLS_R }' readOnly='${form_ITEM_CLS_RO }' placeHolder='${placeHolder }' disabled="${form_ITEM_CLS_D }" />
                <e:text>&nbsp;</e:text>
                <e:inputText id='ITEM_CLS_NM' name="ITEM_CLS_NM" maxLength='${form_ITEM_CLS_NM_M }' required='${form_ITEM_CLS_NM_R }' readOnly='${form_ITEM_CLS_NM_RO }' width='60%' disabled="${form_ITEM_CLS_NM_D}" visible="${form_ITEM_CLS_NM_V}" style="${imeMode}"/>
            </e:field>
            <e:label for="USE_FLAG" title="${form_USE_FLAG_N}" />
            <e:field>
                <e:select id='USE_FLAG' name="USE_FLAG" label='${form_USE_FLAG_N }' disabled="${form_USE_FLAG_D}" options="${refUsageStatus}" required='${form_USE_FLAG_R }' width='${inputTextWidth }' readOnly='${form_USE_FLAG_RO }' placeHolder='${placeHolder }'/>
            </e:field>
        </e:row>
    </e:searchPanel>
    <e:buttonBar align="right">
        <e:button label='${doSearch_N }' id='doSearch' onClick='doSearch' disabled='${doSearch_D }' visible='${doSearch_V }' data='${doSearch_A}'/>
		<c:if test="${ses.ctrlCd != null && ses.ctrlCd != '' }">
	        <e:button label='${doCopy_N }' id='doCopy' onClick='doCopy' disabled='${doCopy_D }' visible='${doCopy_V }' data='${doCopy_A}'/>
    	    <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' data='${doSave_A}'/>
        	<e:button label='${doDelete_N }' id='doDelete' onClick='doDelete' disabled='${doDelete_D }' visible='${doDelete_V }' data='${doDelete_A}'/>
		</c:if>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
</e:window>
</e:ui>