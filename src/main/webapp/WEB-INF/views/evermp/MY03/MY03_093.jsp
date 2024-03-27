<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/MY03/";
        var grid;

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if (colId === "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_009open(param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('multiSelect', false);


        }

        function doSearch() {


            var store = new EVF.Store();
            if(!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'my03093_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                } else {
                    var val = {visible: true, count: 1, height: 40};
                    var footerTxt = {
                        styles: {
                            textAlignment: "center",
                            font: "굴림,12",
                            background:"#ffffff",
                            foreground:"#FF0000",
                            fontBold: true
                        },
                        text: ["합 계"]
                    };
                    var footerSum = {
                        styles: {
                            textAlignment: "far",
                            suffix: " ",
                            background:"#ffffff",
                            foreground:"#FF0000",
                            numberFormat: "###,###.##",
                            fontBold: true
                        },
                        text: "0",
                        expression: ["sum"],
                        groupExpression: "sum"
                    };
                    var PROFIT_RATE = {
                        styles: {
                            textAlignment: "far",
                            suffix: " ",
                            numberFormat: "###,###.#",
                            background:"#ffffff",
                            foreground:"#FF0000",
                            fontBold: true
                        },
                        text: "0",
                        expression: ["(sum['CPO_AMT'] - sum['PO_AMT']) / sum['CPO_AMT'] * 100"],
                        groupExpression: "sum"
                    };

                    grid.setProperty("footerVisible", val);
                    grid.setRowFooter("UNIT_CD", footerTxt);
                    grid.setRowFooter("CPO_AMT", footerSum);
                    grid.setRowFooter("PO_AMT", footerSum);
                    grid.setRowFooter("PROFIT_AMT", footerSum);
                    grid.setRowFooter("PROFIT_RATE", PROFIT_RATE);
                }
            });
        }

        function searchCustInfo() {
            var param = {
                callBackFunction: "setCustInfo"
            };
            everPopup.openCommonPopup(param, "SP0067");
        }

        function setCustInfo(data) {
            EVF.V("CUST_CD", data.CUST_CD);
            EVF.V("CUST_NM", data.CUST_NM);
        }

        function cleanCustCd() {
            EVF.V("CUST_CD", "");
        }

        function searchVendorInfo() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        function cleanVendorCd() {
            EVF.V("VENDOR_CD", "");
        }

    </script>

    <e:window id="MY03_093" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
				<e:label for="DATE_FROM" title="${form_DATE_FROM_N}"/>
                <e:field>
					<e:inputDate id="DATE_FROM" name="DATE_FROM" toDate="DATE_TO" value="${addFromDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_FROM_R}" disabled="${form_DATE_FROM_D}" readOnly="${form_DATE_FROM_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="DATE_TO" name="DATE_TO" fromDate="DATE_FROM" value="${addToDate}" width="${inputDateWidth}" datePicker="true" required="${form_DATE_TO_R}" disabled="${form_DATE_TO_D}" readOnly="${form_DATE_TO_RO}" />
                </e:field>
                <e:label for="dummy" />
				<e:field colSpan="1" />
            </e:row>
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustInfo" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onKeyDown="cleanCustCd" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorInfo" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onKeyDown="cleanVendorCd" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
			</e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:radioGroup id="SORT_SEL" name="SORT_SEL" value="" width="120px" disabled="false" readOnly="false" required="false">
                <e:radio id="SORT_SEL_R" name="SORT_SEL_R" value="R" label="${MY03_093_013}" disabled="false" readOnly="false" checked="true" />
                <e:radio id="SORT_SEL_A" name="SORT_SEL_A" value="A" label="${MY03_093_014}" disabled="false" readOnly="false" />
            </e:radioGroup>
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
