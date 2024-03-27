<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var gridPodt;
        var baseUrl = "/eversrm/po/poMgt/poProgress/SPOM_040";
        var popupFlag = '';

        function init() {

            gridPodt = EVF.C('gridPodt');

            gridPodt.excelExportEvent({
                allCol: "${excelOption.allCol}",
                selRow: "${excelOption.selRow}",
                fileType: 'xls',
                fileName: "${screenName }"
            });
            gridPodt.setProperty('panelVisible', ${panelVisible});
            gridPodt.cellClickEvent(function (rowId, colId, value, iRow, iCol, treeInfo) {
                if (colId == "PO_NUM") {

                    everPopup.printPoReport(gridPodt.getCellValue(rowId, 'PO_NUM'))
                }
            });

            EVF.C('PURCHASE_TYPE').removeOption('DMRO');

            doSearch();
        }

        function doSearch() {

            if (!everDate.fromTodateValid('FROM_DATE', 'TO_DATE', '${ses.dateFormat }')) return alert('${msg.M0073}');

            var store = new EVF.Store();
            if (!store.validate()) return;

            store.setGrid([gridPodt]);
            store.load(baseUrl + "/doSearch", function () {
                if(gridPodt.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

    </script>

    <e:window id="SPOM_040" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" onEnter="doSearch">
            <e:row>
                <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
                <e:field>
                    <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
                    <e:text> ~ </e:text>
                    <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" name="PO_NUM" style='ime-mode:inactive' value="${form.PO_NUM}" width="100%" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="45%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                    <e:text width="4%">/</e:text>
                    <e:inputText id="ITEM_DESC" style="ime-mode:auto" name="ITEM_DESC" value="${form.ITEM_DESC}" width="45%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doAccept" name="doAccept" label="${doAccept_N}" onClick="doAccept" disabled="${doAccept_D}" visible="${doAccept_V}"/>
            <e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="gridPodt" name="gridPodt" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridPodt.gridColData}"/>

    </e:window>
</e:ui>