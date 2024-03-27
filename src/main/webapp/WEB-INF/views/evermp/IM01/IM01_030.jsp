<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0302/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "DEL_REQ_USER_NM") {
                    var param = {
                        callBackFunction : "selectGridUser",
                        'rowId': rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0011');
                }else if(colId == "ITEM_CD") {

                    if( grid.getCellValue(rowId, "CUST_CD")==""){
                        return alert("${IM01_030_004}");
                    }

                    var param = {
                        callBackFunction : "setItemInfo"
                        ,rowId : rowId
                        ,multiFlag : true
                        ,detailView : false
                        ,popupFlag : true
                    };
                    everPopup.openPopupByScreenId("IM02_012", 1200, 600, param);
                }else if(colId =="CUST_CD"){
                    var param = {
                        callBackFunction : "selectgridCust",
                        rowId : rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0067');
                }

            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);
                }
            });

            grid.addRowEvent(function() {
                var addParam = [{}];
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {

                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
                for (var i = 0; i < selRowId.length; i++) {
                    if(grid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                        return alert("${msg.M0145}");
                    }
                }
                grid.delRow();
            });

        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + "im01030_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im01030_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if( grid.getCellValue(rowIds[i], 'SOLE_ITEM_STATUS')=="1"){
                    return alert("${IM01_030_001}");
                }
                if( grid.getCellValue(rowIds[i], 'DEL_REQ_USER_ID')==""){
                    return alert("${IM01_030_002}");
                }
                if( grid.getCellValue(rowIds[i], 'DEL_RMK')==""){
                    return alert("${IM01_030_003}");
                }
            }
            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + "im01030_doDelete", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function selectGridUser(data) {
            grid.setCellValue(data.rowId, 'DEL_REQ_USER_ID', data.USER_ID);
            grid.setCellValue(data.rowId, 'DEL_REQ_USER_NM', data.USER_NM);
        }


        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(dataJsonArray) {
            EVF.V("CUST_CD",dataJsonArray.CUST_CD);
            EVF.V("CUST_NM",dataJsonArray.CUST_NM);
        }

        function selectgridCust(data) {
            grid.setCellValue(data.rowId, 'CUST_CD', data.CUST_CD);
            grid.setCellValue(data.rowId, 'CUST_NM', data.CUST_NM);

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


        function setItemInfo(jsonData, rowId) {
            var setRow = rowId;

            for(idx in jsonData) {
                if(idx >0){
                    var addParam = [{"CUST_CD" : grid.getCellValue(rowId, "CUST_CD"),"CUST_NM" : grid.getCellValue(rowId, "CUST_NM")}];
                    setRow = grid.addRow(addParam);
                }
                grid.setCellValue(setRow, 'ITEM_CD', jsonData[idx].ITEM_CD);
                grid.setCellValue(setRow, 'ITEM_DESC', jsonData[idx].ITEM_DESC);
                grid.setCellValue(setRow, 'ITEM_SPEC', jsonData[idx].ITEM_SPEC);
                grid.setCellValue(setRow, 'MAKER_NM', jsonData[idx].MAKER_NM);
                grid.setCellValue(setRow, 'MAKER_PART_NO', jsonData[idx].MAKER_PART_NO);
                grid.setCellValue(setRow, 'BRAND_NM', jsonData[idx].BRAND_NM);
                grid.setCellValue(setRow, 'ORIGIN_CD', jsonData[idx].ORIGIN_CD);
                grid.setCellValue(setRow, 'UNIT_CD', jsonData[idx].UNIT_CD);
                grid.setCellValue(setRow, 'SG_CTRL_USER_ID', jsonData[idx].SG_CTRL_USER_ID);
                grid.setCellValue(setRow, 'SG_CTRL_USER_NM', jsonData[idx].SG_CTRL_USER_NM);

                doGetPrice(setRow);
            }

        }

        function doGetPrice(nRow) {

            if(EVF.isEmpty(grid.getCellValue(nRow, 'CUST_CD')) || EVF.isEmpty(grid.getCellValue(nRow, 'ITEM_CD'))) return;

            var store = new EVF.Store();
            store.setParameter("BUYER_CD", grid.getCellValue(nRow, 'CUST_CD'));
            store.setParameter("ITEM_CD", grid.getCellValue(nRow, 'ITEM_CD'));
            store.load('/evermp/IM02/IM0201/im02011_doGetPrice', function() {
                grid.setCellValue(nRow, "CONT_UNIT_PRC", this.getParameter("CONT_UNIT_PRICE"));
                grid.setCellValue(nRow, "UNIT_PRICE", this.getParameter("UNIT_PRICE"));
                grid.setCellValue(nRow, "CUR", this.getParameter("CUR"));
            }, false);
        }

    </script>

    <e:window id="IM01_030" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }"  labelAlign="${labelAlign}" useTitleBar="false" onEnter="doSearch">

            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="${form.CUST_NM}" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}"/>
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
                <e:field>
                    <e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
                </e:field>
                <e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
                <e:field>
                    <e:select id="ITEM_STATUS" name="ITEM_STATUS" value="" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            <e:button id="Save" name="Save" label="${Save_N}" onClick="doSave" disabled="${Save_D}" visible="${Save_V}"/>
            <e:button id="Delete" name="Delete" label="${Delete_N}" onClick="doDelete" disabled="${Delete_D}" visible="${Delete_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>