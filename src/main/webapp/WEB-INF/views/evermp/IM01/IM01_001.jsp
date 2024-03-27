<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var headerG;
        var baseUrl = "/evermp/IM01/IM0101/";

        function init() {
            grid = EVF.C("grid");
            headerG = EVF.C('headerG');

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_014open(param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearchHD();
        }

        function doSearchHD(){
            var store = new EVF.Store();
            store.setGrid([headerG]);
            store.load(baseUrl + "im01001_doSearchHeader", function () {
                if(headerG.getRowCount() == 0) {
                } else {
                    var allRowId = headerG.getAllRowId();
                    for(var i in allRowId) {
                        var HeadrNm = headerG.getCellValue(allRowId[i], 'REGION_NM');
                        var HeadrCd = headerG.getCellValue(allRowId[i], 'SET_REGION_CD');

                        grid.addColumn(HeadrCd,HeadrNm, 75, 'center', 'checkbox', 50, true, true, '', 0);
                    }
                }
            });

        }
        function doSearch() {
            var	store =	new	EVF.Store();
            if(!store.validate()) return;
            store.setGrid([headerG, grid]);
            store.getGridData(headerG, 'all');
            store.load(baseUrl + "im01001_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {

            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im01001_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doAllSave(){
            var param = {
                detailView : false
            };
            everPopup.im01_002open(param);

        }


        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function searchMaker(){
            var param = {
                callBackFunction : "selectMaker"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }
        function selectMaker(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.VENDOR_CD);
            EVF.V("MAKER_NM",dataJsonArray.VENDOR_NM);
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

    </script>

    <e:window id="IM01_001" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">

            <e:row>

                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field>
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:search id="MAKER_CD" style="ime-mode:inactive" name="MAKER_CD"  value="" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="${form_MAKER_CD_RO ? 'everCommon.blank' : 'searchMakerCd'}" disabled="${form_MAKER_CD_D}" readOnly="${form_MAKER_CD_RO}" required="${form_MAKER_CD_R}" />
                    <e:inputText id="MAKER_NM" style="${imeMode}" name="MAKER_NM" value="" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}"/>
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
                <e:field>
                    <e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            <e:button id="AllSave" name="AllSave" label="${AllSave_N}" onClick="doAllSave" disabled="${AllSave_D}" visible="${AllSave_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />


        <e:panel width="0px" height="0px">
            <e:gridPanel id="headerG" name="headerG" width="0px" height="0px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>