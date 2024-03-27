<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/STO/STO04_050/";
        var RowId = 0;

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', false);

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);
                }
            });

            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

            grid.cellClickEvent(function(rowId, colId, value) {

            });
		 	doSearch();
        }

        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "sto0405_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

    </script>

    <e:window id="STO04_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
                <e:field>
                    <e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                    <e:inputHidden id="ITEM_SPEC" name="ITEM_SPEC"/>
                </e:field>
                <e:label for="STR_CTRL_CODE" title="${form_STR_CTRL_CODE_N}"/>
                <e:field>
                    <e:select id="STR_CTRL_CODE" name="STR_CTRL_CODE" value="" options="${strCtrlCodeOptions}" width="${form_STR_CTRL_CODE_W}" disabled="${form_STR_CTRL_CODE_D}" readOnly="${form_STR_CTRL_CODE_RO}" required="${form_STR_CTRL_CODE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="MOVEMENT_TYPE" title="${form_MOVEMENT_TYPE_N}"/>
                <e:field>
                    <e:select id="MOVEMENT_TYPE" name="MOVEMENT_TYPE" value="" options="${movementTypeOptions}" width="${form_MOVEMENT_TYPE_W}" disabled="${form_MOVEMENT_TYPE_D}" readOnly="${form_MOVEMENT_TYPE_RO}" required="${form_MOVEMENT_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
                <e:field>
                    <e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>


        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>