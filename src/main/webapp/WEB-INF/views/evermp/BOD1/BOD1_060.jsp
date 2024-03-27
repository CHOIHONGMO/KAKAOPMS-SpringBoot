<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var grid;
        var baseUrl = "/evermp/BOD1/BOD105/";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty("multiSelect", false);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == "AP_TAX_NUM" || colId == "AR_TAX_NUM") {
                    EVF.V("TAX_NUM", value);
                    doSearch();
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            EVF.V("CUST_NM", "${ses.companyNm}");
            EVF.C("CUST_NM").setReadOnly(true);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "bod1060_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }
    </script>

    <e:window id="BOD1_060" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${inputNumberWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${BOD1_060_002}" value="AR_DATE"/>
                        <e:option text="${BOD1_060_003}" value="AP_DATE"/>
                        <e:option text="${BOD1_060_004}" value="CPO_DATE"/>
                        <e:option text="${BOD1_060_005}" value="GR_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="CPO_USER_ID_NM" title="${form_CPO_USER_ID_NM_N}" />
                <e:field>
                    <e:inputText id="CPO_USER_ID_NM" name="CPO_USER_ID_NM" value="" width="${form_CPO_USER_ID_NM_W}" maxLength="${form_CPO_USER_ID_NM_M}" disabled="${form_CPO_USER_ID_NM_D}" readOnly="${form_CPO_USER_ID_NM_RO}" required="${form_CPO_USER_ID_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_KEY" title="${form_ITEM_KEY_N}" />
                <e:field>
                    <e:inputText id="ITEM_KEY" name="ITEM_KEY" value="" width="${form_ITEM_KEY_W}" maxLength="${form_ITEM_KEY_M}" disabled="${form_ITEM_KEY_D}" readOnly="${form_ITEM_KEY_RO}" required="${form_ITEM_KEY_R}" />
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="">
                        <e:option text="매출매입마감" value="매출매입마감"/>
                        <e:option text="매입마감" value="매입마감"/>
                        <e:option text="매출마감" value="매출마감"/>
                    </e:select>
                </e:field>
                <e:label for="TAX_NUM" title="${form_TAX_NUM_N}" />
                <e:field>
                    <e:inputText id="TAX_NUM" name="TAX_NUM" value="" width="${form_TAX_NUM_W}" maxLength="${form_TAX_NUM_M}" disabled="${form_TAX_NUM_D}" readOnly="${form_TAX_NUM_RO}" required="${form_TAX_NUM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar width="100%" align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>