<%--
  Date: 2015/11/16
  Time: 16:47:57
  Scrren ID : DH1040
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/eversrm/gr/DH1040";
        var selRow;

        function init() {

            grid = EVF.getComponent('grid');
            grid.setProperty('panelVisible', ${panelVisible});
    		EVF.C('PURCHASE_TYPE').removeOption('NORMAL'); // 부품

    		//grid Column Head Merge
            grid.setProperty('multiselect', true);

            // Grid AddRow Event
            grid.addRowEvent(function () {
                grid.addRow();
            });

            // Grid Excel Event
            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,
                    imgHeight: 0.26,
                    colWidth: 20,
                    rowSize: 500,
                    attachImgFlag: false
                }
            });

            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {

                if(colId == 'DEAL_NUM') {
                    var param = {
                        "detailView": "true",
                        "dealNum": grid.getCellValue(rowId, 'DEAL_NUM'),
                        "callbackFunction": "doClose",
                        "popupFlag": true
                    };

                    var screen_id = 'DH1030';
                    if (grid.getCellValue(rowId,'SL_TYPE') == 'ET') {
                    	screen_id = 'DH1031';
                    }
                    if (grid.getCellValue(rowId,'SL_TYPE') == 'BU') {
                    	screen_id = 'DH1032';
                    }
                    everPopup.openPopupByScreenId(screen_id, 1200, 800, param);
                }

            });

            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {

            });

            EVF.getComponent('PURCHASE_TYPE').appendOption('회계전표', 'JAC');
        }

        // Search
        function doSearch() {
            var store = new EVF.Store();

            // form validation Check
            if (!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // Update
        function doUpdate() {

            var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
            if (selRowIds.length == 0) {
                return alert("${msg.M0004}");
            }

            if (selRowIds.length > 1) {
                return alert("${msg.M0006}");
            }

            var rowId = selRowIds[0];
            if(EVF.isNotEmpty(grid.getCellValue(rowId, 'SL_NUM'))) {
                return alert('${DH1040_001}');
            }

            var slType = grid.getCellValue(rowId, 'SL_TYPE');
            if(slType == 'IN') {
            	return alert('${DH1040_003}'); <%-- 투자전표는 수정할 수 없습니다. 송장취소 후 다시 생성하시기 바랍니다. --%>
            }

            var param = {
                "dealNum": grid.getCellValue(rowId, 'DEAL_NUM'),
                "callbackFunction": "doSearch",
                "detailView": false
            };
            var screen_id = 'DH1030';
            if (grid.getCellValue(rowId,'SL_TYPE') == 'ET') {
            	screen_id = 'Dh1031';
            }
            if (grid.getCellValue(rowId,'SL_TYPE') == 'BU') {
            	screen_id = 'Dh1032';
            }

            everPopup.openPopupByScreenId(screen_id, 1200, 800, param);
        }

        function doSapIF() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var i in gridData) {
                var rowData = gridData[i];
                if(EVF.isNotEmpty(rowData['SL_NUM'])) {
                    return alert('${DH1040_001}');
                }
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
        	store.getGridData(grid, 'sel');

        	store.load(baseUrl + '/doSapSend', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

        function doCancel() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

/*            var gridData = grid.getSelRowValue();
            for(var i in gridData) {
                var rowData = gridData[i];
                if(EVF.isEmpty(rowData['SL_NUM'])) {
                    return alert('${DH1040_002}');
                }
            }*/

            if(!confirm('${msg.M0024}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doCancel', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="DH1040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="DEAL_DATE" title="${form_DEAL_DATE_N}"/>
                <e:field>
                    <e:inputDate id="DEAL_FROM_DATE" toDate="DEAL_TO_DATE" name="DEAL_FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_DATE_R}" disabled="${form_DEAL_DATE_D}" readOnly="${form_DEAL_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="DEAL_TO_DATE" fromDate="DEAL_FROM_DATE" name="DEAL_TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_DATE_R}" disabled="${form_DEAL_DATE_D}" readOnly="${form_DEAL_DATE_RO}" />
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" useMultipleSelect="true" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
                <e:field>
                    <e:select id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" options="${payTermsOptions}" width="${inputTextWidth}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder="" />
                </e:field>
                <e:label for="TAX_CD" title="${form_TAX_CD_N}"/>
                <e:field>
                    <e:select id="TAX_CD" name="TAX_CD" value="${form.TAX_CD}" options="${taxCdOptions}" width="${inputTextWidth}" disabled="${form_TAX_CD_D}" readOnly="${form_TAX_CD_RO}" required="${form_TAX_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
                </e:field>
                <e:label for="SL_TYPE" title="${form_SL_TYPE_N}"/>
                <e:field colSpan="">
                    <e:select id="SL_TYPE" name="SL_TYPE" value="${form.SL_TYPE}" options="${slTypeOptions}" width="${inputTextWidth}" disabled="${form_SL_TYPE_D}" readOnly="${form_SL_TYPE_RO}" required="${form_SL_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="SAP_IF_YN" title="${form_SAP_IF_YN_N}"/>
                <e:field>
                    <e:select id="SAP_IF_YN" name="SAP_IF_YN" value="${form.SAP_IF_YN}" options="${sapIfYnOptions}" width="${inputTextWidth}" disabled="${form_SAP_IF_YN_D}" readOnly="${form_SAP_IF_YN_RO}" required="${form_SAP_IF_YN_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar width="100%" align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doUpdate" name="doUpdate" label="${doUpdate_N}" onClick="doUpdate" disabled="${doUpdate_D}" visible="${doUpdate_V}"/>
            <e:button id="doSapIF" name="doSapIF" label="${doSapIF_N}" onClick="doSapIF" disabled="${doSapIF_D}" visible="${doSapIF_V}"/>
            <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
