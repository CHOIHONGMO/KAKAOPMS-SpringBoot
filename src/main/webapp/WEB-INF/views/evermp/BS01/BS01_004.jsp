<%--기준정보 > 고객사정보관리 > 고객사 부서관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var gridT; var gridM; var gridB;
        var addParam = [];
        var baseUrl = "/evermp/BS01/BS0101/";

        function init() {
            gridT = EVF.C("gridT");
            gridM = EVF.C("gridM");
            gridB = EVF.C("gridB");
            //gridDP = EVF.C("gridDP");

            gridT.setProperty('shrinkToFit', true);
            gridM.setProperty('shrinkToFit', true);
            gridB.setProperty('shrinkToFit', true);
            //gridDP.setProperty('shrinkToFit', true);

            gridT.cellClickEvent(function(rowId, colId, value) {
                if(colId == "DEPT_CD") {
                    if(gridT.getCellValue(rowId, 'DEPT_CD')==""){return;}

                    gridM.delAllRow();


                    var store = new EVF.Store();
                    store.setParameter("PARENT_DEPT_CD", gridT.getCellValue(rowId, 'DEPT_CD'));
                    EVF.V("M_PARENT_DEPT_CD",gridT.getCellValue(rowId, 'DEPT_CD'));
                    EVF.V("M_PARENT_DEPT_NM",gridT.getCellValue(rowId, 'DEPT_NM'));
                    EVF.V("B_PARENT_DEPT_CD",""); EVF.V("B_PARENT_DEPT_NM","");
                    store.setGrid([gridM]);
                    store.load(baseUrl + 'bs01004_doSearchM', function() {
                        if(gridM.getRowCount() == 0){
                            alert("${msg.M0002 }");
                        }
                    });
                    EVF.C("R1").setChecked(false);
                    EVF.C("R2").setChecked(true);
                    EVF.C("R3").setChecked(false);
                    gridB.delAllRow();
                }
            });

            gridT.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "PARENT_DEPT_NM") {
                    gridT.setCellValue(rowid, 'PARENT_DEPT_CD', gridT.getCellValue(rowid, 'PARENT_DEPT_NM'));
                }
            });

            gridT.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridM.cellClickEvent(function(rowId, colId, value) {

                if(colId == "DEPT_CD") {

                    gridB.delAllRow();
                    if(gridM.getCellValue(rowId, 'DEPT_CD')==""){return;}

                    var store = new EVF.Store();
                    store.setParameter("PARENT_DEPT_CD", gridM.getCellValue(rowId, 'DEPT_CD'));
                    EVF.V("B_PARENT_DEPT_CD",gridM.getCellValue(rowId, 'DEPT_CD'));
                    EVF.V("B_PARENT_DEPT_NM",gridM.getCellValue(rowId, 'DEPT_NM'));
                    EVF.V("M_PARENT_DEPT_CD",""); EVF.V("M_PARENT_DEPT_NM","");

                    store.setGrid([gridB]);
                    store.load(baseUrl + 'bs01004_doSearchB', function() {
                        if(gridB.getRowCount() == 0){
                            //alert("${msg.M0002 }");
                        }
                    });
                    EVF.C("R1").setChecked(false);
                    EVF.C("R2").setChecked(false);
                    EVF.C("R3").setChecked(true);
                    EVF.V("DEPT_CD",gridM.getCellValue(rowId, 'DEPT_CD'));
                    //영업점조회
                    doSearch_DP();
                }
                if(colId == "TEAM_LEADER_USER_NM") {
                    var	param =	{
                        rowId: rowId,
                        callBackFunction: "callBackCTRL_USER_ID"
                    };
                    everPopup.openCommonPopup(param, 'SP0083');
                }
            });

            gridM.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "PARENT_DEPT_NM") {
                    gridM.setCellValue(rowid, 'PARENT_DEPT_CD', gridM.getCellValue(rowid, 'PARENT_DEPT_NM'));
                }
            });

            gridM.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridB.cellClickEvent(function(rowId, colId, value) {

            });

            gridB.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "PARENT_DEPT_NM") {
                    gridB.setCellValue(rowid, 'PARENT_DEPT_CD', gridB.getCellValue(rowid, 'PARENT_DEPT_NM'));
                }
            });

            gridB.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });



            gridT.addRowEvent(function() {

                if(EVF.V("CUST_CD")==""){
                    return alert("${BS01_004_002}");
                }
                addParam = [{'PARENT_DEPT_CD': EVF.V("CUST_CD"),'PARENT_DEPT_NM': EVF.V("CUST_NM"), 'DEL_FLAG': '1'}];
                gridT.addRow(addParam);
                EVF.C("R1").setChecked(true);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
            });
            gridT.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridT.delRow();
            });
            gridM.addRowEvent(function() {
                if(EVF.V("CUST_CD")==""){
                    return alert("${BS01_004_002}");
                }
                if(EVF.V("M_PARENT_DEPT_CD")==""){
                    return alert("${BS01_004_003}");
                }
                addParam = [{'PARENT_DEPT_CD': EVF.V("M_PARENT_DEPT_CD"),'PARENT_DEPT_NM': EVF.V("M_PARENT_DEPT_NM"), 'DEL_FLAG': '1'}];
                gridM.addRow(addParam);
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(true);
                EVF.C("R3").setChecked(false);
            });
            gridM.delRowEvent(function() {
                if(!gridM.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridM.delRow();
            });
            gridB.addRowEvent(function() {
                if(EVF.V("CUST_CD")==""){
                    return alert("${BS01_004_002}");
                }
                if(EVF.V("B_PARENT_DEPT_CD")==""){
                    return alert("${BS01_004_003}");
                }
                addParam = [{'PARENT_DEPT_CD': EVF.V("B_PARENT_DEPT_CD"),'PARENT_DEPT_NM': EVF.V("B_PARENT_DEPT_NM"), 'DEL_FLAG': '1'}];
                gridB.addRow(addParam);
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(true);
            });
            gridB.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridB.delRow();
            });

        }

        function callBackCTRL_USER_ID(jsonData)	{
            gridM.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_NM', jsonData.USER_NM);
            gridM.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID', jsonData.USER_ID);
        }

        function doSearch() {

            EVF.V("M_PARENT_DEPT_CD","");
            EVF.V("B_PARENT_DEPT_CD","");
            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([gridT,gridM,gridB]);
            store.load(baseUrl + 'bs01004_doSearch', function() {
                if(gridT.getRowCount() == 0&&gridM.getRowCount() == 0&&gridB.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

            var radioVal = (EVF.C("R1").isChecked() == true ? "R1" : (EVF.C("R2").isChecked() == true ? "R2" : (EVF.C("R3").isChecked() == true ? "R3" : "")));

            if(radioVal == "R1") {
                if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }
                if (!gridT.validate().flag) { return alert(gridT.validate().msg); }
                EVF.V("DEPT_TYPE_RADIO","");
                EVF.V("DIVISION_YN","1");

            } else if(radioVal == "R2") {
                if(!gridM.isExistsSelRow()) { return alert("${msg.M0004}"); }
                if (!gridM.validate().flag) { return alert(gridM.validate().msg); }
                EVF.V("DEPT_TYPE_RADIO","200");
                EVF.V("DIVISION_YN","0");
            } else if(radioVal == "R3") {
                if(!gridB.isExistsSelRow()) { return alert("${msg.M0004}"); }
                if (!gridB.validate().flag) { return alert(gridB.validate().msg); }
                EVF.V("DEPT_TYPE_RADIO","300");
                EVF.V("DIVISION_YN","0");
            }

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setParameter("radioVal", radioVal);
            store.setGrid([gridT, gridM, gridB]);
            store.getGridData(gridT, 'sel');
            store.getGridData(gridM, 'sel');
            store.getGridData(gridB, 'sel');
            store.load(baseUrl + 'bs01004_doSave', function() {
                alert(this.getResponseMessage());
                EVF.C("R1").setChecked(true);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
                gridM.delAllRow();
                gridB.delAllRow();
                doSearch();
            });
        }

        function checkRadio() {

            var clickBtn = this.getData();

            if(clickBtn == "R1") {
                EVF.C("R1").setChecked(true);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
            }
            else if(clickBtn == "R2") {
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(true);
                EVF.C("R3").setChecked(false);
            }
            else if(clickBtn == "R3") {
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(true);
            }
        }




        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
        }


    </script>
    <e:window id="BS01_004" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="true" required="${form_CUST_NM_R}" />
                    <e:inputHidden id="DEPT_TYPE_RADIO" name="DEPT_TYPE_RADIO"/>
                    <e:inputHidden id="DIVISION_YN" name="DIVISION_YN"/>
                    <e:inputHidden id="M_PARENT_DEPT_CD" name="M_PARENT_DEPT_CD"/>
                    <e:inputHidden id="M_PARENT_DEPT_NM" name="M_PARENT_DEPT_NM"/>
                    <e:inputHidden id="B_PARENT_DEPT_CD" name="B_PARENT_DEPT_CD"/>
                    <e:inputHidden id="B_PARENT_DEPT_NM" name="B_PARENT_DEPT_NM"/>
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="DEPT_NM" style="${imeMode}" name="DEPT_NM" value="" width="100%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
        </e:buttonBar>

        <e:panel id="leftPanel" height="385px" width="45%">
            <e:radio id="R1" name="R1" label="" value="1" checked="true" readOnly="false" disabled="false" onClick="checkRadio" data="R1" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_004_TITLE2}</e:text>
            <e:gridPanel id="gridT" name="gridT" width="100%" height="330px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}" />
        </e:panel>
        <e:panel id="nullPanel" height="385" width="1%">&nbsp;</e:panel>
        <e:panel id="rightPanel" height="385" width="54%">

            <e:radio id="R2" name="R2" label="" value="2" checked="false" readOnly="false" disabled="false" onClick="checkRadio" data="R2" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_004_TITLE3}</e:text>
            <e:gridPanel id="gridM" name="gridM" width="100%" height="330px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridM.gridColData}" />
            <e:inputHidden id="DEPT_CD" name="DEPT_CD"/>
        </e:panel>
        <e:panel id="leftPanelB" height="fit" width="100%">
            <e:radio id="R3" name="R3" label="" value="3" checked="false" readOnly="false" disabled="false" onClick="checkRadio" data="R3" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_004_TITLE4}</e:text>
            <e:gridPanel id="gridB" name="gridB" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridB.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>