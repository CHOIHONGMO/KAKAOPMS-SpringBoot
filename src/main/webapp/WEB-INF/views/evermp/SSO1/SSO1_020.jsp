<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SSO1/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'CTRL_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, 'CTRL_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId == 'LEADTIME_RMK_IMG') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "LEADTIME_RMK"))) {
                        var param = {
                            title: "${SSO1_020_006 }",
                            message: grid.getCellValue(rowId, 'LEADTIME_RMK')
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'ITEM_CD') {
                    var param = {
                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                        popupFlag: true,
                        detailView: true
                    };
                    everPopup.im03_014open(param);
                }
            });

            grid.setProperty('multiSelect', false);
            grid.setColIconify("LEADTIME_RMK_IMG", "LEADTIME_RMK", "comment", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "sso1020_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

    </script>

    <e:window id="SSO1_020" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
            	<%--
                <e:label for="DATE_CONDITION">
                    <e:select id="DATE_CONDITION" name="DATE_CONDITION" required="${form_DATE_CONDITION_R}" disabled="${form_DATE_CONDITION_D}" readOnly="${form_DATE_CONDITION_RO}" usePlaceHolder="false" width="${form_DATE_CONDITION_W}">
                        <e:option text="${SSO1_020_001}" value="C"/>
                        <e:option text="${SSO1_020_002}" value="E"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="FROM_DATE" name="FROM_DATE" toDate="TO_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_R}" disabled="${form_DATE_D}" readOnly="${form_DATE_RO}"/>
                    <e:text>~</e:text>
                    <e:inputDate id="TO_DATE" name="TO_DATE" fromDate="FROM_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_R}" disabled="${form_DATE_D}" readOnly="${form_DATE_RO}"/>
                </e:field>
                --%>
                <e:label for="CONT_STATUS" title="${form_CONT_STATUS_N}"/>
                <e:field>
                    <e:radioGroup id="CONT_STATUS" name="CONT_STATUS" value="" width="100%" disabled="${form_CONT_STATUS_D}" readOnly="${form_CONT_STATUS_RO}" required="${form_CONT_STATUS_R}">
                        <e:radio id="CONT_STATUS_9" name="CONT_STATUS_9" value="9" label="${SSO1_020_007}" disabled="${form_CONT_STATUS_D}" readOnly="${form_CONT_STATUS_RO}" />
                        <e:radio id="CONT_STATUS_1" name="CONT_STATUS_1" value="1" label="${SSO1_020_003}" disabled="${form_CONT_STATUS_D}" readOnly="${form_CONT_STATUS_RO}" checked="true" />
                        <e:radio id="CONT_STATUS_0" name="CONT_STATUS_0" value="0" label="${SSO1_020_004}" disabled="${form_CONT_STATUS_D}" readOnly="${form_CONT_STATUS_RO}" />
                        <e:radio id="CONT_STATUS_A" name="CONT_STATUS_A" value="A" label="${SSO1_020_005}" disabled="${form_CONT_STATUS_D}" readOnly="${form_CONT_STATUS_RO}" />
                    </e:radioGroup>
                </e:field>
                <e:label for="DEAL_TYPE" title="${form_DEAL_TYPE_N}"/>
                <e:field>
                    <e:select id="DEAL_TYPE" name="DEAL_TYPE" value="" options="${dealTypeOptions}" width="${form_DEAL_TYPE_W}" disabled="${form_DEAL_TYPE_D}" readOnly="${form_DEAL_TYPE_RO}" required="${form_DEAL_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="" options="${ctrlUserIdOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC_SPEC" title="${form_ITEM_DESC_SPEC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC_SPEC" name="ITEM_DESC_SPEC" value="" width="${form_ITEM_DESC_SPEC_W}" maxLength="${form_ITEM_DESC_SPEC_M}" disabled="${form_ITEM_DESC_SPEC_D}" readOnly="${form_ITEM_DESC_SPEC_RO}" required="${form_ITEM_DESC_SPEC_R}" />
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="" title=""/>
                <e:field> </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>