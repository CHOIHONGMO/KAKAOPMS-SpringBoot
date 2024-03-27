<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<w:ux debug="${wiseDebug }" theme="${wiseTheme }" locale="${ses.langCode}_${ses.countryCode}">
    <w:loadCSS src="/css/icon.css"/>
    <w:loadJS src="${jsInclude}"/>
    <w:dataModel>
        <w:valueObject initByTags="true" id="searchTerms" type="List<com.icompia.wisec.common.util.domain.GeneralCombo>"/>
        <w:valueObject initByTags="true" id="refYN" type="List<com.icompia.wisec.common.util.domain.GeneralCombo>"/>
        <w:valueObject initByTags="true" id="searchParam" type="Map"/>
        <w:valueObject initByTags="true" id="gridData" type="List<Map>"/>
    </w:dataModel>
    <w:script>

        var grid;
        var baseUrl = "/wisepro/purchase/prMgt/prItem/";

        function init() {
        grid = WUX.getComponent("grid");
        doSearch();
        }

        function doSearch() {

        var store = new WUX.data.Store();
        store.setProxy(baseUrl + "doSearch.wu");
        store.setValueObject("searchParam");
        WUX.getValueObject("searchParam").mark();
        store.load(function() {
        if (grid.getRowCount() == 0) {
        alert("${msg.M0002 }");
        }
        });
        }

        function doAddLine() {
        grid.addRow();
        grid.setCellValue("SELECTED", grid.getActiveRowIndex(), "1");
        }

        function doDelLine() {
        gridUtil.deleteRows(grid, "SELECTED");
        }

        function onCellChange(strColumnKey, nRow, oVal, nVal) {
        gridUtil.autoSelect(grid, "SELECTED", strColumnKey, nRow, oVal, nVal);
        }
    </w:script>

    <w:window id="window" onReady="init" initData="${initData}">
        <w:panel caption="${fullScreenName}" width="1ft" height="1ft" padding="true" scrollable="true" styleName="${wiseStyleName}" breadCrumb="${breadCrumb}">

            <w:fieldPanel value="@{searchParam}" id="form" height="1ft" labelWidth="${labelWidth}" labelAlign="${labelAlign}">
                <w:fieldSet caption="${form_CAPTION_N }" padding="true" spacing="true" collapsible="true" styleName="important">
                    <w:layoutConfig sizes="1ft,1ft" type="table"/>
                    <w:fieldGroup label="${form_ADD_DATE_N }"> <!-- Registration Date -->
                        <w:inputDate id="ADD_DATE_FROM" value="${fromDate }" valueFormat="${valueFormat}" format="${inputDateFormat }" width="${inputDateWidth}" required="${form_ADD_DATE_R }" readOnly="${form_ADD_DATE_RO }" datePicker="true" disabled="${form_ADD_DATE_D}" visible="${form_ADD_DATE_V}"/>~
                        <w:inputDate id="ADD_DATE_TO" value="${toDate }" valueFormat="${valueFormat}" format="${inputDateFormat }" width="${inputDateWidth}" required="${form_ADD_DATE_R }" readOnly="${form_ADD_DATE_RO }" datePicker="true" disabled="${form_ADD_DATE_D}" visible="${form_ADD_DATE_V}"/>
                    </w:fieldGroup>
                    <w:fieldGroup label="${form_TEST_N }"> <!-- Test -->
                        <w:inputText id="TEST" width="${inputTextWidth }" maxLength="${form_TEST_M }" required="${form_TEST_R }" readOnly="${form_TEST_RO }" onKeyDown="formUtil.onFormKeyDown" disabled="${form_TEST_D}" visible="${form_TEST_V}"/>
                    </w:fieldGroup>
                    <w:select id="DEL_FLAG" label="${form_DEL_FLAG_N }" required="${form_DEL_FLAG_R }" readOnly="${form_DEL_FLAG_RO }" placeHolder="${placeHolder }"> <!-- Check deleted or not -->
                        <w:options value="@{refYN}">
                            <w:optionText value="@{.text}"/>
                            <w:optionVal value="@{.value}"/>
                        </w:options>
                    </w:select>
                </w:fieldSet>

                <w:fieldGroup>
                    <w:space width="1ft"/>
                    <w:button caption="${doSearch_N }" id="doSearch" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V }" userData="${doSearch_A }"/>
                </w:fieldGroup>

                <w:panel height="1ft">
                    <c:import url="/wisec/common/generator/gridMetaGen.wu">
                        <c:param name="_gridId" value="grid"/>
                        <c:param name="_screenId" value="BPR_130"/>
                        <c:param name="_bottomBars" value="doAddLine,doDelLine"/>
                        <c:param name="_gridEvent" value="onCellChange"/>
                    </c:import>
                </w:panel>
            </w:fieldPanel>
        </w:panel>
    </w:window>
</w:ux>