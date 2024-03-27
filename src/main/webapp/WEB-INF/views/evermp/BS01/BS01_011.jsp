<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var gridL, gridR;
        var addParam = [{}];
        var baseUrl = "/evermp/BS01/BS0102/";

        function init() {

            gridL = EVF.C('gridL');
            gridL.setProperty('shrinkToFit', true);

            gridL.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });

            gridL.addRowEvent(function () {
                var newRowId = gridL.addRow([{"DML_TYPE":"AGR","USE_FLAG":"1"}]);
                gridL.setRowReadOnly(newRowId, false);

            });

            gridL.delRowEvent(function () {
                var selRowId = gridL.getSelRowId();
                for(var i in selRowId) {
                    var rowId = selRowId[i];
                    if(gridL.getCellValue(rowId, 'MOD_DATE') == '') {
                        gridL.delRow(rowId);
                    }
                }
            });

            gridL.cellClickEvent(function (rowId, colId, value) {
                if(colId == 'REF_USER_ID') {
                    if(gridL.getCellValue(rowId, 'MOD_DATE') == '') {
                        doUserSearchL({
                            rowId: rowId
                        });
                    } else {
                        return alert('${BS01_011_NOT_EDITABLE}');
                    }
                }
            });

            gridR = EVF.C('gridR');
            gridR.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
            });

            gridR.addRowEvent(function () {
                var newRowId = gridR.addRow([{"DML_TYPE":"REF","USE_FLAG":"1"}]);
                gridR.setRowReadOnly(newRowId, false);
            });

            gridR.delRowEvent(function () {
                gridR.delRow();
            });

            gridR.dupRowEvent(function(rowId) {

            }, ["DML_TYPE","REF_USER_ID","REF_USER_ID_$TP","USE_FLAG"]);

            gridR.cellClickEvent(function (rowId, colId, value) {
                if(colId == 'REF_USER_ID') {
                    if(gridR.getCellValue(rowId, 'MOD_DATE') == '') {
                        doUserSearchR({
                            rowId: rowId
                        });
                    } else {
                        return alert('${BS01_011_NOT_EDITABLE}');
                    }
                }
            });
            doSearchL();
            doSearchR();
        }

        function doSearchL() {

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            store.setGrid([gridL]);
            store.setParameter('gridType', "L");
            store.load(baseUrl + 'bs01011_doSearchL', function () {

                var allRowId = gridL.getAllRowId();
                for(var i in allRowId) {
                    var rowId = allRowId[i];
                    gridL.setCellReadOnly(rowId, 'REF_CD', true);
                    gridL.setCellReadOnly(rowId, 'REF_USER_ID', true);
                }
            });
        }

        function doSearchR() {

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            store.setGrid([gridR]);
            store.setParameter('gridType', "R");
            store.load(baseUrl + 'bs01011_doSearchR', function () {

                var allRowId = gridR.getAllRowId();
                for(var i in allRowId) {
                    var rowId = allRowId[i];
                    gridR.setCellReadOnly(rowId, 'REF_CD', true);
                    gridR.setCellReadOnly(rowId, 'REF_CD2', true);
                    gridR.setCellReadOnly(rowId, 'REF_CD3', true);
                    gridR.setCellReadOnly(rowId, 'FROM_AMT', true);
                    gridR.setCellReadOnly(rowId, 'TO_AMT', true);
                    gridR.setCellReadOnly(rowId, 'REF_USER_ID', true);
                }
            });
        }

        function doSave() {

            var paramGrid;
            var data = this.getData();
            if(data == 'L') {
                paramGrid = gridL;
            } else if(data == 'R') {
                paramGrid = gridR;
            }

            if (paramGrid.getSelRowCount() == 0) {
                return alert("${msg.M0004}");
            }
            if (!paramGrid.validate().flag) {
                return alert(paramGrid.validate().msg);
            }

            if (!confirm('${msg.M0021}')) {
                return;
            }

            var store = new EVF.Store();
            store.setParameter('gridType', data);
            store.setGrid([paramGrid]);
            store.getGridData(paramGrid, 'sel');
            store.load(baseUrl + 'bs01011_doSave', function () {
                alert(this.getResponseMessage());
                if(data == 'L') {
                    doSearchL();
                } else if(data == 'R') {
                    doSearchR();
                }
            });
        }

        function doDelete() {

            var paramGrid;
            var data = this.getData();
            if(data == 'L') {
                paramGrid = gridL;
            } else if(data == 'R') {
                paramGrid = gridR;
            }

            if (paramGrid.getSelRowCount() == 0) {
                return alert("${msg.M0004}");
            }

            if (!confirm('${msg.M0013}')) {
                return;
            }

            var store = new EVF.Store();
            store.setParameter('gridType', data);
            store.setGrid([paramGrid]);
            store.getGridData(paramGrid, 'sel');
            store.load(baseUrl + 'bs01011_doDelete', function () {
                alert(this.getResponseMessage());
                if(data == 'L') {
                    doSearchL();
                } else if(data == 'R') {
                    doSearchR();
                }
            });
        }

        function doClose() {
            EVF.closeWindow();
        }

        // 사용자검색 (합의)
        function doUserSearchL(param) {

            var param = {
                callBackFunction: "setUserL",
                custCd: EVF.V("SET_CUST_CD"),
                rowId : param.rowId
            };

            everPopup.openCommonPopup(param, 'MP0007');
        }

        // 사용자검색 (참조)
        function doUserSearchR(param) {
            var param = {
                callBackFunction: "setUserR",
                custCd: EVF.V("SET_CUST_CD"),
                rowId : param.rowId
            };
            everPopup.openCommonPopup(param, 'MP0007');
        }

        function setUserL(data, rowId) {
            console.log(data, rowId);
            var refCd = gridL.getCellValue(rowId, 'REF_CD');
            for(var i in data) {
                var datum = data[i];
                var userDatum = {
                    "DML_TYPE": "AGR"
                    ,"REF_CD": refCd
                    ,"REF_USER_ID": datum.USER_ID
                    ,"REF_USER_ID_$TP": datum.USER_ID_$TP
                    ,"REF_USER_NM": datum.USER_NM
                    ,"DUTY_NM": datum.DUTY_NM
                    ,"DEPT_NM": datum.DEPT_NM
                    ,"USE_FLAG": "1"
                    ,"CUST_CD" : datum.CUST_CD
                    ,"CUST_NM" : datum.CUST_NM
                };

                if(i == 0) {
                    gridL.setRowValue(rowId, userDatum);
                } else {
                    var newRowId = gridL.addRow(userDatum);
                    gridL.setRowReadOnly(newRowId, false);
                }
            }
        }

        function setUserR(data, rowId) {

            var refCd = gridR.getCellValue(rowId, 'REF_CD');
            for(var i in data) {
                var datum = data[i];
                var userDatum = {
                    "DML_TYPE": "REF"
                    ,"REF_CD": refCd
                    ,"REF_USER_ID": datum.USER_ID
                    ,"REF_USER_ID_$TP": datum.USER_ID_$TP
                    ,"REF_USER_NM": datum.USER_NM
                    ,"DUTY_NM": datum.DUTY_NM
                    ,"DEPT_NM": datum.DEPT_NM
                    ,"USE_FLAG": "1"
                    ,"CUST_CD" : datum.CUST_CD
                    ,"CUST_NM" : datum.CUST_NM
                };

                if(i == 0) {
                    gridR.setRowValue(rowId, userDatum);
                } else {
                    var newRowId = gridR.addRow(userDatum);
                    gridR.setRowReadOnly(newRowId, false);
                }
            }
        }

    </script>

    <e:window id="BS01_011" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="SET_CUST_CD" name="SET_CUST_CD" value="${param.custCd}"></e:inputHidden>

        <e:panel width="49%">
            <e:buttonBar width="100%" title="합의" align="right">
                <e:button id="Delete2" name="Delete2" label="${Delete_N}" disabled="${Delete_D}" visible="${Delete_V}" onClick="doDelete" data="L"  style="float:right; padding-right: 2px;" />
                <e:button id="Save2" name="Save2" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" data="L"  style="float:right; padding-right: 2px;" />
                <e:button id="Search2" name="Search2" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearchL" data="L" style="float:right; padding-right: 2px;" />
                <e:select id="REF_CD_L" name="REF_CD_L" options="${refCdLOptions}" width="180" style="height: 22px; float:right; margin-right: 2px;" readOnly="false" disabled="false" required="false"  />
            </e:buttonBar>
            <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="fit" readOnly="false" columnDef="${gridInfos.gridL.gridColData}"/>
        </e:panel>
        <e:panel width="1%">&nbsp;</e:panel>
        <e:panel width="50%">
            <e:buttonBar width="100%" title="참조" align="right">
                <e:button id="Delete" name="Delete" label="${Delete_N}" disabled="${Delete_D}" visible="${Delete_V}" onClick="doDelete" data="R" style="float:right; padding-right: 2px;"/>
                <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" data="R" style="float:right; padding-right: 2px;"/>
                <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearchR" data="R" style="float:right; padding-right: 2px;"/>
                <e:select id="REF_CD_R" name="REF_CD_R" options="${refCdROptions}" width="180" readOnly="false" disabled="false" required="false" style="height: 22px; float:right; margin-right: 2px;" />
            </e:buttonBar>
            <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="fit" readOnly="false" columnDef="${gridInfos.gridR.gridColData}"/>
        </e:panel>
    </e:window>
</e:ui>