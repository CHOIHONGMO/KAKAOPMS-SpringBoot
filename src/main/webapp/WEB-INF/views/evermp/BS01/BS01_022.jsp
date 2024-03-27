<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var gridH, gridD;
        var baseUrl = "/evermp/BS01/BS0102/";
        var G_M_USER_ID;
        var data;
        var SelectRowId;

        function init(){
            gridH = EVF.C("gridH");
            gridD = EVF.C("gridD");

            gridH.setProperty("shrinkToFit", true);
            gridD.setProperty("shrinkToFit", true);
            gridD.setProperty('sortable', false);

            gridH.cellClickEvent(function(rowId, colName, value) {
                if(colName === "M_USER_ID") {
                    //searchGridUser("HD", rowId);
                    var param = {
                        callBackFunction : "selectUser_GridH"
                    };
                    SelectRowId = rowId;
                    everPopup.openCommonPopup(param, 'SP0117');
                }
                if(colName === "M_USER_NM") {

                    var M_USER_ID = gridH.getCellValue(rowId, "M_USER_ID");
                    var M_USER_NM = gridH.getCellValue(rowId, "M_USER_NM");
                    var M_CUST_CD = gridH.getCellValue(rowId, "M_CUST_CD");
                    var M_CUST_NM = gridH.getCellValue(rowId, "M_CUST_NM");

                    G_M_USER_ID = M_USER_ID;
                    EVF.C("D_M_CUST_NM").setValue(M_CUST_NM);
                    EVF.C("D_M_CUST_CD").setValue(M_CUST_CD);
                    EVF.C("D_M_USER_NM").setValue(M_USER_NM);
                    EVF.C("D_M_USER_ID").setValue(M_USER_ID);

                    doSearchD(G_M_USER_ID);
                }
            });

            gridD.cellClickEvent(function(rowId, colName, value) {
                if (colName == "CUST_CD") {
                }
            });

            gridH.addRowEvent(function() {
                gridH.addRow();
            });

            gridH.delRowEvent(function() {

                if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }
                doSearch();
            });

            gridD.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function selectUser_GridH(dataJsonArray) {

            gridH.setCellValue(SelectRowId, "M_USER_NM" ,dataJsonArray.USER_NM );
            gridH.setCellValue(SelectRowId, "M_USER_ID" ,dataJsonArray.USER_ID );
            gridH.setCellValue(SelectRowId, "M_CUST_NM" ,dataJsonArray.COMPANY_NM );
            gridH.setCellValue(SelectRowId, "M_CUST_CD" ,dataJsonArray.COMPANY_CD );
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridH]);
            store.load(baseUrl + "bs01022_doSearch", function () {
                if(gridH.getRowCount() === 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // 그룹관리자 상세조회
        function doSearchD(G_M_USER_ID) {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridD]);
            store.setParameter("M_USER_ID", G_M_USER_ID);
            store.load(baseUrl + "bs01022_doSearchD", function () {
                if(gridD.getRowCount() === 0) {
                    <%--return alert('${msg.M0002}');--%>
                }
                gridD.setColMerge(['M_CUST_NM','M_CUST_CD','M_USER_ID','M_USER_NM','M_DEPT_CD','M_DEPT_NM']);
            });
        }

        // 그룹관리자 저장
        function doSave() {
            var store = new EVF.Store();

            if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm("${msg.M0021}")) { return; }

            store.setGrid([gridH]);
            store.getGridData(gridH, "sel");
            store.load(baseUrl + "bs01022_doSave", function() {
                alert("${msg.M0031}");
                doSearch();
            });
        }

        // 그룹관리자 삭제
        function doDelete() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridH.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = gridH.getSelRowId();

            if(!confirm("${msg.M0013}")) { return; }

            store.setGrid([gridH]);
            store.getGridData(gridH, "sel");
            store.load(baseUrl + "bs01022_doDelete", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 고객사 사용자 추가
        function doUserAdd() {

            var D_M_USER_ID = EVF.C('D_M_USER_ID').getValue();

            if (D_M_USER_ID == "") {
                alert("${BS01_022_002 }");
                return;
            }

            var param = {
                callBackFunction : "setUserMulti"
            };
            everPopup.openCommonPopup(param, 'MP0019');
        }
        function setUserMulti(data) {
            if(data.length != undefined) {
                var dataArr = [];
                for(idx in data) {
                    var arr = {
                        'M_CUST_CD': EVF.V('D_M_CUST_CD'),
                        'M_CUST_NM': EVF.V('D_M_CUST_NM'),
                        'M_USER_ID': EVF.V('D_M_USER_ID'),
                        'M_USER_NM': EVF.V('D_M_USER_NM'),
                        'CUST_CD': data[idx].COMPANY_CD,
                        'CUST_NM': data[idx].COMPANY_NM,
                        'USER_ID': data[idx].USER_ID,
                        'USER_NM': data[idx].USER_NM,
                        'DEPT_CD': data[idx].DEPT_CD,
                        'DEPT_NM': data[idx].DEPT_NM
                    };
                    dataArr.push(arr);
                }
                var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridD, "USER_ID");
                gridD.addRow(validData);
            }
        }

        // 고객사 사용자 매핑저장
        function doSaveDT() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm("${BS01_022_003}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load(baseUrl + "bs01022_doSaveUser", function() {
                alert(this.getResponseMessage());
                doSearch();
                doSearchD(G_M_USER_ID);
            });
        }

        // 고객사 사용자 매핑삭제
        function doDeleteDT() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm("${msg.M0013}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load(baseUrl + "bs01022_doDeleteUser", function() {
                alert(this.getResponseMessage());
                doSearch();
                doSearchD(G_M_USER_ID);
            });
        }

         function selectGridUserHD(data) {
            gridH.setCellValue(data.rowId, "M_CUST_CD", data.BUYER_CD);
            gridH.setCellValue(data.rowId, "M_CUST_NM", data.BUYER_NM);
            gridH.setCellValue(data.rowId, "M_USER_ID", data.USER_ID);
            gridH.setCellValue(data.rowId, "M_USER_NM", data.USER_NM_$TP);
            gridH.setCellValue(data.rowId, "M_DEPT_CD", data.DEPT_CD);
            gridH.setCellValue(data.rowId, "M_DEPT_NM", data.DEPT_NM);
        }

    </script>
    <e:window id="BS01_022" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:panel id="panL" width="40%" height="100%">
            <e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
                <e:row>
                    <e:label for="M_CUST_CD" title="${form_M_CUST_CD_N}"/>
                    <e:field>
                        <e:inputText id="M_CUST_NM" name="M_CUST_NM" value="" width="100%" maxLength="${form_M_CUST_NM_M}" disabled="${form_M_CUST_NM_D}" readOnly="${form_M_CUST_NM_RO}" required="${form_M_CUST_NM_R}" />
                    </e:field>
                    <e:label for="M_USER_ID" title="${form_M_USER_ID_N}"/>
                    <e:field>
                        <e:inputText id="M_USER_NM" name="M_USER_NM" value="" width="100%" maxLength="${form_M_USER_NM_M}" disabled="${form_M_USER_NM_D}" readOnly="${form_M_USER_NM_RO}" required="${form_M_USER_NM_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar align="right" width="100%">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            </e:buttonBar>

            <e:gridPanel id="gridH" name="gridH" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridH.gridColData}" />
        </e:panel>

        <e:panel id="panBlank" width="1%">&nbsp;</e:panel>

        <e:panel id="panR" width="59%" height="100%">
            <e:searchPanel id="formR" title="" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
                <e:row>
                    <e:label for="D_M_CUST_CD" title="${form_D_M_CUST_CD_N}" />
                    <e:field>
                        <e:inputText id="D_M_CUST_CD" name="D_M_CUST_CD" value="" width="40%" maxLength="${form_D_M_CUST_CD_M}" disabled="${form_D_M_CUST_CD_D}" readOnly="${form_D_M_CUST_CD_RO}" required="${form_D_M_CUST_CD_R}" />
                        <e:inputText id="D_M_CUST_NM" name="D_M_CUST_NM" value="" width="60%" maxLength="${form_D_M_CUST_NM_M}" disabled="${form_D_M_CUST_NM_D}" readOnly="${form_D_M_CUST_NM_RO}" required="${form_D_M_CUST_NM_R}" />
                    </e:field>
                    <e:label for="D_M_USER_ID" title="${form_D_M_USER_ID_N}" />
                    <e:field>
                        <e:inputText id="D_M_USER_ID" name="D_M_USER_ID" value="" width="40%" maxLength="${form_D_M_USER_ID_M}" disabled="${form_D_M_USER_ID_D}" readOnly="${form_D_M_USER_ID_RO}" required="${form_D_M_USER_ID_R}" />
                        <e:inputText id="D_M_USER_NM" name="D_M_USER_NM" value="" width="60%" maxLength="${form_D_M_USER_NM_M}" disabled="${form_D_M_USER_NM_D}" readOnly="${form_D_M_USER_NM_RO}" required="${form_D_M_USER_NM_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:panel id="leftP2" height="fit" width="40%">
                <e:button id="UserAdd" name="UserAdd" label="${UserAdd_N}" onClick="doUserAdd" disabled="${UserAdd_D}" visible="${UserAdd_V}"/>
            </e:panel>

            <e:panel id="rightP1" height="fit" width="60%">
                <e:buttonBar align="right" width="100%">
                    <e:button id="SaveDT" name="SaveDT" label="${SaveDT_N}" onClick="doSaveDT" disabled="${SaveDT_D}" visible="${SaveDT_V}"/>
                    <e:button id="DeleteDT" name="DeleteDT" label="${DeleteDT_N}" onClick="doDeleteDT" disabled="${DeleteDT_D}" visible="${DeleteDT_V}"/>
                </e:buttonBar>
            </e:panel>

            <e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>