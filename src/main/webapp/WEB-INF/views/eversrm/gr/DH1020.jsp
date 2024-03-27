<%--
  Date: 2015/11/13
  Time: 18:49:26
  Scrren ID : DH1020
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/eversrm/gr";
        var selRow;

        function init() {

            grid = EVF.getComponent('grid');

//    		EVF.C('PURCHASE_TYPE').removeOption('NORMAL'); // 부품

            //grid Column Head Merge
            grid.setProperty('multiselect', true);

            grid.setProperty('panelVisible', ${panelVisible});
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

            grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

                if (colId == 'GL_ACCOUNT_NM') {
                    var param = {
                        "callBackFunction": '_setGlAccount',
                        "rowId": rowId
                    };
                    everPopup.openCommonPopup(param, "SP0024");

                } else if (colId == 'GR_CNT') {

                    var param = {
                        'WORK_NUM': grid.getCellValue(rowId, 'WORK_NUM')
                    };

                    everPopup.openPopupByScreenId("DH1020P", 950, 500, param);

                } else if (colId == 'FIND_COST_CD') {

                    var param = {
                        "callBackFunction": '_setCostCd',
                        "rowId": rowId,
                        "PLANT_CD": grid.getCellValue(rowId, 'PLANT_CD')
                    };
                    everPopup.openCommonPopup(param, "SP0036");
                }

            });

            grid.cellChangeEvent(function (rowid, colId, iRow, iCol, value, oldValue) {

            });

        }

        function _setGlAccount(data) {
            grid.setCellValue(data.rowId, "GL_ACCOUNT_CD", data['ACCOUNT_CD']);
            grid.setCellValue(data.rowId, "GL_ACCOUNT_NM", data['ACCOUNT_NM']);
        }

        function _setCostCd(data) {
            grid.setCellValue(data.rowId, "COST_CD", data['COST_CD']);
            grid.setCellValue(data.rowId, "COST_NM", data['COST_NM']);
        }

        // Search
        function doSearch() {
            var store = new EVF.Store();

            // form validation Check
            if (!store.validate()) return;

            store.setGrid([grid]);
            store.load(baseUrl + '/DH1020/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // Save
        function doSave() {

            var store = new EVF.Store();

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!grid.validate().flag) {
                return alert("${msg.M0014}");
            }

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {

                var rowId = selRowId[i];
                if(grid.getCellValue(rowId, 'PURCHASE_TYPE') == 'ISP') {
                    if(EVF.isEmpty(grid.getCellValue(rowId, 'SAP_ORDER_NUM'))) {
                        return alert('${DH1020_SAP_ORDER_NUM_REQUIRED}');
                    }

                    if(EVF.isEmpty(grid.getCellValue(rowId, 'SAP_PR_NUM')) &&
                       (EVF.isEmpty(grid.getCellValue(rowId, 'MATL_GROUP')) ||
                    	EVF.isEmpty(grid.getCellValue(rowId, 'TRACKING_NUM')) ||
                    	EVF.isEmpty(grid.getCellValue(rowId, 'CO_AREA')))) {
                        return alert('${DH1020_SAP_PR_NUM_REQUIRED}');
                    }
                }
            }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            if (!confirm("${msg.M0021}")) return;
            store.load(baseUrl + '/DH1020/doSave', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="DH1020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="REG_FROM_DATE" title="${form_REG_DATE_N}"/>
                <e:field>
                    <e:inputDate id="REG_FROM_DATE" toDate="REG_TO_DATE" name="REG_FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}"/>
                    <e:text>~</e:text>
                    <e:inputDate id="REG_TO_DATE" fromDate="REG_FROM_DATE" name="REG_TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder=""/>
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
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="${inputTextWidth}" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
                <e:label for="TAX_CD" title="${form_TAX_CD_N}"/>
                <e:field>
                    <e:select id="TAX_CD" name="TAX_CD" value="${form.TAX_CD}" options="${taxCdOptions}" width="${inputTextWidth}" disabled="${form_TAX_CD_D}" readOnly="${form_TAX_CD_RO}" required="${form_TAX_CD_R}" placeHolder=""/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
                <e:field colSpan="5">
                    <e:select id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" options="${payTermsOptions}" width="${inputTextWidth}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder=""/>
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar width="100%" align="right">
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" align="right"/>
            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">${DH1020_TITLE_PROOF_DATE}</e:text>
                <e:inputDate id="PROOF_DATE" name="PROOF_DATE" value="${toDate}" required="true" disabled="false" readOnly="false"/>
            </div>
            <div style="float: right; padding-right: 3px; height: 28px;">
                <e:text style="line-height: 21px;">${DH1020_TITLE_DEAL_DATE}</e:text>
                <e:inputDate id="DEAL_DATE" name="DEAL_DATE" value="${toDate}" required="true" disabled="false" readOnly="false"/>
            </div>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" style="float: right; padding-right: 3px;"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
