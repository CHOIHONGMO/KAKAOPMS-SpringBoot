<%--기준정보 > 고객사정보관리 > 마감일자 관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS01/BS0101/";

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', false);

            grid.cellClickEvent(function(rowId, colId, value) {
                if (colId == "CUST_CD") {

                    if(grid.getCellValue(rowId, 'CUST_CD') != '') {
                        var param = {
                            'CUST_CD': grid.getCellValue(rowId, 'CUST_CD'),
                            'detailView': false,
                            'popupFlag': true
                        };
                        everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                    }
                }
                if (colId == "CUST_NM") {
                    var param = {
                        callBackFunction : "selectCustGrid",
                        rowId: rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0067');
                }
                if(colId === 'AM_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "AM_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.addRowEvent(function() {
                var addParam = [{}];
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });


        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs01003_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs01003_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }


        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bs01003_doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function selectCustGrid(data) {
            var rowsAll = grid.getAllRowValue();
            var cnt = 0;

            for (var j = 0; j < rowsAll.length; j++) {
                if (rowsAll[j].CUST_CD === data.CUST_CD && rowsAll[j].CLOSING_CNT === rowsAll[data.rowId].CLOSING_CNT) {
                    cnt++;
                }
            }

            if(cnt > 0) {
                alert("${msg.M0167}");
            } else {
                grid.setCellValue(data.rowId, "CUST_CD", data.CUST_CD);
                grid.setCellValue(data.rowId, "CUST_NM", data.CUST_NM);

                grid.setCellValue(data.rowId, "AM_USER_ID", data.AM_USER_ID);
                grid.setCellValue(data.rowId, "AM_USER_NM", data.AM_USER_NM);
            }
        }


        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(data) {
            EVF.V("CUST_CD",data.CUST_CD);
            EVF.V("CUST_NM",data.CUST_NM);
        }



    </script>
    <e:window id="BS01_003" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="AM" title="${form_AM_N}"/>
                <e:field>
                    <e:select id="AM" name="AM" value="${form.AM}" options="${AM_USER_ID_options }" width="${form_AM_W}" disabled="${form_AM_D}" readOnly="${form_AM_RO}" required="${form_AM_R}" placeHolder=""/>
                </e:field>
                <e:label for="YEAR_MONTH" title="${form_YEAR_MONTH_N}" />
                <e:field>
                    <e:inputDate id="YEAR_MONTH" name="YEAR_MONTH" value="${yyyymmFrom }" width="${yearMonthYyyyMmWidth }" datePicker="true" required="${form_YEAR_MONTH_R}" disabled="${form_YEAR_MONTH_D}" readOnly="${form_YEAR_MONTH_RO}" format="yyyy-mm" />
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />


    </e:window>
</e:ui>