<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/BS01/BS0102/";
        var grid;
        var gridUR1; var gridUR2; var gridUR3;
        var addParam = [];
        var selRow;
        var bizCls1; var bizCls2; var bizCls3; var bizSeq;

        function init() {

            grid = EVF.C('grid');
            gridUR1 = EVF.C('gridUR1');
            gridUR2 = EVF.C('gridUR2');
            gridUR3 = EVF.C('gridUR3');

            // Grid AddRow Event
            grid.addRowEvent(function() {

                if(EVF.V("CUST_CD")==""){
                    EVF.C('CUST_CD').setFocus();
                    return alert("${BS01_010_003}");
                }
                var addParam = [{'CUST_CD': EVF.V("CUST_CD"), 'CUST_NM': EVF.V("CUST_NM"), 'USE_FLAG': '1'}];
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });

            gridUR1.addRowEvent(function() {

                if(EVF.isEmpty(EVF.V("CUST_CD"))){
                    EVF.C('CUST_CD').setFocus();
                    return alert("${BS01_010_003}");
                }
                if(EVF.isEmpty(EVF.V("DML_TYPE"))){
                    EVF.C('DML_TYPE').setFocus();
                    return alert("${BS01_010_009}");
                }

                var addParam = [{'CUST_CD': EVF.V("CUST_CD"), 'DML_TYPE': EVF.V("DML_TYPE"), 'USE_FLAG': '1'}];
                gridUR1.addRow(addParam);
            });

            gridUR1.delRowEvent(function() {
                if(!gridUR1.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridUR1.delRow();
            });

            gridUR2.addRowEvent(function() {

                var dmlType = (EVF.C("R1").isChecked() == true ? "APP" :(EVF.C("R2").isChecked() == true ? "AGR" : ""));
                var alertMsg = (dmlType == "APP" ? "${BS01_010_006}" : "${BS01_010_007}");

                if(EVF.isEmpty(EVF.V("CUST_CD"))){
                    EVF.C('CUST_CD').setFocus();
                    return alert("${BS01_010_003}");
                }
                if(EVF.isEmpty(EVF.V("APP_AGR_LINE"))){
                    EVF.C('APP_AGR_LINE').setFocus();
                    return alert(alertMsg);
                }
                var addParam = [{'CUST_CD': EVF.V("CUST_CD"), 'DML_TYPE': dmlType, 'USE_FLAG': '1', 'LINE_CD': EVF.V("APP_AGR_LINE")}];
                gridUR2.addRow(addParam);
            });

            gridUR2.delRowEvent(function() {
                if(!gridUR2.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridUR2.delRow();
            });

            gridUR3.addRowEvent(function() {

                if(EVF.isEmpty(EVF.V("CUST_CD"))){
                    EVF.C('CUST_CD').setFocus();
                    return alert("${BS01_010_003}");
                }
                if(EVF.isEmpty(bizCls1) || EVF.isEmpty(bizCls2) || EVF.isEmpty(bizCls3) || EVF.isEmpty(bizSeq)) {
                    return alert("${BS01_010_005}");
                }

                var addParam = [{'CUST_CD': EVF.V("CUST_CD"), 'DML_TYPE': "REF", 'USE_FLAG': '1', 'LINE_CD': bizCls1 + bizCls2 + bizCls3 + bizSeq}];
                gridUR3.addRow(addParam);
            });

            gridUR3.delRowEvent(function() {
                if(!gridUR3.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridUR3.delRow();
            });

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId === 'REG_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "REG_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId === 'MOD_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "MOD_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                if(colId === 'REF_LINE') {

                    bizCls1 = grid.getCellValue(rowId, 'BIZ_CLS1');
                    bizCls2 = grid.getCellValue(rowId, 'BIZ_CLS2');
                    bizCls3 = grid.getCellValue(rowId, 'BIZ_CLS3');
                    bizSeq = grid.getCellValue(rowId, 'BIZ_SEQ');

                    var store = new EVF.Store();
                    store.setGrid([gridUR3]);
                    store.setParameter("CUST_CD", grid.getCellValue(rowId, 'CUST_CD'));
                    store.setParameter("DML_TYPE", "REF");
                    store.setParameter("LINE_CD", bizCls1 + bizCls2 + bizCls3 + bizSeq);
                    store.load(baseUrl + 'bs01010_doSearchUR3', function() {

                    });
                }
            });

            gridUR2.cellClickEvent(function(rowId, colId, value) {

                var commonId = (EVF.V("CUST_CD") == "1000" ? "MP0007" : "MP0012");

                if(colId === 'REF_USER_ID') {
                    var param = {
                        callBackFunction: "setUserAGR",
                        CUST_CD: EVF.V("CUST_CD"),
                        rowId : rowId
                    };
                    everPopup.openCommonPopup(param, commonId);
                }
            });

            gridUR3.cellClickEvent(function(rowId, colId, value) {

                var commonId = (EVF.V("CUST_CD") == "1000" ? "MP0007" : "MP0012");

                if(colId === 'REF_USER_ID') {
                    var param = {
                        callBackFunction: "setUserREF",
                        CUST_CD: EVF.V("CUST_CD"),
                        rowId : rowId
                    };
                    everPopup.openCommonPopup(param, commonId);
                }
            });

            // header setting
            grid.setColGroup([{
                "groupName": '${BS01_010_001}',
                "columns": [ "BIZ_CLS1","BIZ_CLS2","BIZ_CLS3" ]
            },{
                "groupName": '${BS01_010_002}',
                "columns": [ "FROM_AMT", "TO_AMT" ]
            }]);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridUR1.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridUR2.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridUR3.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridUR1.setProperty('shrinkToFit', true);
            gridUR2.setProperty('shrinkToFit', true);
            gridUR3.setProperty('shrinkToFit', true);

            if(!EVF.isEmpty('${param.CUST_CD}')) {
                EVF.V('CUST_CD', '${param.CUST_CD}');
                EVF.V('CUST_NM', '${param.CUST_NM}');
            }
            if (EVF.isEmpty('${param.CUST_CD}') && '${ses.userType}' == 'B') {
                EVF.C('CUST_CD').setReadOnly(true);
                EVF.C('CUST_NM').setReadOnly(true);
            }

            var lookupKeys1 = [];
            var lookupValues1 = [];
            var gridAppLinesOptions =  ${gridAppLinesOptions};
            for(var i in gridAppLinesOptions) {
                lookupKeys1.push(gridAppLinesOptions[i].value);
                lookupValues1.push(gridAppLinesOptions[i].text);
            }

            var lookupKeys2 = [];
            var lookupValues2 = [];
            var gridAgrLinesOptions =  ${gridAgrLinesOptions};
            for(var i in gridAgrLinesOptions) {
                lookupKeys2.push(gridAgrLinesOptions[i].value);
                lookupValues2.push(gridAgrLinesOptions[i].text);
            }

            grid._gvo.setLookups([{
                "id": "lookup1",
                "levels": 1,
                "keys": lookupKeys1,
                "values": lookupValues1
            }, {
                "id": "lookup2",
                "levels": 1,
                "keys": lookupKeys2,
                "values": lookupValues2
            }]);

            var Col1 = grid._gvo.columnByField("APP_LINE");
            Col1.lookupDisplay = true;
            Col1.lookupSourceId = "lookup1";
            Col1.lookupKeyFields = ["APP_LINE"];
            grid._gvo.setColumn(Col1);

            var Col2 = grid._gvo.columnByField("AGR_LINE");
            Col2.lookupDisplay = true;
            Col2.lookupSourceId = "lookup2";
            Col2.lookupKeyFields = ["AGR_LINE"];
            grid._gvo.setColumn(Col2);

            EVF.C('DML_TYPE').removeOption('REF');
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs01010_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
                grid.setColMerge(['CUST_NM']);
                grid.setColMerge(['BIZ_CLS1','BIZ_CLS2','BIZ_CLS3']);
            });
        }

        function doSearchLine() {

            if(EVF.isEmpty(EVF.V("CUST_CD"))){
                EVF.C('CUST_CD').setFocus();
                return alert("${BS01_010_003}");
            }

            if(EVF.isEmpty(EVF.V("DML_TYPE"))){
                EVF.C('DML_TYPE').setFocus();
                return alert("${BS01_010_009}");
            }

            var store = new EVF.Store();
            store.setGrid([gridUR1]);
            store.setParameter("CUST_CD", EVF.V("CUST_CD"));
            store.setParameter("DML_TYPE", EVF.V("DML_TYPE"));
            store.load(baseUrl + 'bs01010_doSearchLineCd', function() {
                if(gridUR1.getRowCount() == 0){
                    alert("${msg.M0002 }");
                } else {
                    var allRowId = gridUR1.getAllRowId();
                    for(var i in allRowId) {
                        gridUR1.setCellReadOnly(allRowId[i], 'LINE_CD', true);
                    }
                }
            });
        }

        function doSearchAppAgr() {

            var dmlType = (EVF.C("R1").isChecked() == true ? "APP" :(EVF.C("R2").isChecked() == true ? "AGR" : ""));

            if(EVF.isEmpty(EVF.V("CUST_CD"))){
                EVF.C('CUST_CD').setFocus();
                return alert("${BS01_010_003}");
            }

            var alertMsg = (dmlType == "APP" ? "${BS01_010_006}" : "${BS01_010_007}");
            if(EVF.isEmpty(EVF.V("APP_AGR_LINE"))){
                EVF.C('APP_AGR_LINE').setFocus();
                return alert(alertMsg);
            }

            var store = new EVF.Store();
            store.setGrid([gridUR2]);
            store.setParameter("CUST_CD", EVF.V("CUST_CD"));
            store.setParameter("DML_TYPE", dmlType);
            store.setParameter("LINE_CD", EVF.V("APP_AGR_LINE"));
            store.load(baseUrl + 'bs01010_doSearchAppAgr', function() {
                if(gridUR2.getRowCount() == 0){
                    alert("${msg.M0002 }");
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
            store.load(baseUrl + 'bs01010_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doSaveLine() {

            if (gridUR1.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!gridUR1.validate().flag) { return alert(gridUR1.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridUR1]);
            store.getGridData(gridUR1, 'sel');
            store.load(baseUrl + 'bs01010_doSaveLine', function() {
                alert(this.getResponseMessage());
                document.location.href = "/evermp/BS01/BS0102/BS01_010/view.so?CUST_CD=" + EVF.V("CUST_CD") + "&CUST_NM=" + EVF.V("CUST_NM");
            });
        }

        function doDelLine() {

            if (gridUR1.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(!confirm('${msg.M0013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridUR1]);
            store.getGridData(gridUR1, 'sel');
            store.load(baseUrl + 'bs01010_doDelLine', function() {
                alert(this.getResponseMessage());
                document.location.href = "/evermp/BS01/BS0102/BS01_010/view.so?CUST_CD=" + EVF.V("CUST_CD") + "&CUST_NM=" + EVF.V("CUST_NM");
            });
        }

        function doSaveAppAgr() {

            var dmlType = (EVF.C("R1").isChecked() == true ? "APP" :(EVF.C("R2").isChecked() == true ? "AGR" : ""));
            var alertMsg = (dmlType == "APP" ? "${BS01_010_006}" : "${BS01_010_007}");
            if(EVF.isEmpty(EVF.V("APP_AGR_LINE"))){
                EVF.C('APP_AGR_LINE').setFocus();
                return alert(alertMsg);
            }

            if (gridUR2.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!gridUR2.validate().flag) { return alert(gridUR2.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridUR2]);
            store.getGridData(gridUR2, 'sel');
            store.setParameter("DML_TYPE", dmlType);
            store.setParameter("LINE_CD", EVF.V("APP_AGR_LINE"));
            store.load(baseUrl + 'doSaveAppAgr', function() {
                alert(this.getResponseMessage());
                doSearchAppAgr();
            });
        }

        function doDelAppAgr() {

            var dmlType = (EVF.C("R1").isChecked() == true ? "APP" :(EVF.C("R2").isChecked() == true ? "AGR" : ""));

            if (gridUR2.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(!confirm('${msg.M0013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridUR2]);
            store.getGridData(gridUR2, 'sel');
            store.setParameter("dmlType", dmlType);
            store.load(baseUrl + 'bs01010_doDelAppAgr', function() {
                alert(this.getResponseMessage());
                doSearchAppAgr();
            });
        }

        function doSaveRef() {

            if (gridUR3.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!gridUR3.validate().flag) { return alert(gridUR3.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridUR3]);
            store.getGridData(gridUR3, 'sel');
            store.load(baseUrl + 'bs01010_doSaveREF', function() {
                alert(this.getResponseMessage());
                gridUR3.delAllRow();
                doSearch();
            });
        }

        function doDelRef() {

            if (gridUR3.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(!confirm('${msg.M0013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([gridUR3]);
            store.getGridData(gridUR3, 'sel');
            store.load(baseUrl + 'bs01010_doDelRef', function() {
                alert(this.getResponseMessage());
                gridUR3.delAllRow();
                doSearch();
            });
        }

        function doMapping() {

            if(EVF.V("CUST_CD")==""){
                EVF.C('CUST_CD').setFocus();
                return alert("${BS01_010_003}");
            }
            var param = {
                'custCd' : EVF.V('CUST_CD'),
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("BS01_011", 1350, 800, param);
        }

        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function setBuyer(data) {
            document.location.href = "/evermp/BS01/BS0102/BS01_010/view.so?CUST_CD=" + data.CUST_CD + "&CUST_NM=" + data.CUST_NM;
        }

        function setUserAPP(data, rowId) {
            for(var i in data) {
                var datum = data[i];
                var userDatum = {
                     "CUST_CD": EVF.V("CUST_CD")
                    ,"DML_TYPE": "APP"
                    ,"REF_USER_ID": datum.USER_ID_$TP
                    ,"REF_USER_NM": datum.USER_NM
                    ,"USE_FLAG": "1"
                };

                if(i == 0) {
                    gridUR1.setRowValue(rowId, userDatum);
                } else {
                    var newRowId = gridUR1.addRow(userDatum);
                }
            }
        }

        function setUserAGR(data, rowId) {
            for(var i in data) {
                var datum = data[i];
                var userDatum = {
                     "CUST_CD": EVF.V("CUST_CD")
                    ,"DML_TYPE": "AGR"
                    ,"REF_USER_ID": datum.USER_ID
                    ,"REF_USER_NM": datum.USER_NM
                    ,"USE_FLAG": "1"
                };

                if(i == 0) {
                    gridUR2.setRowValue(rowId, userDatum);
                } else {
                    var newRowId = gridUR2.addRow(userDatum);
                }
            }
        }

        function setUserREF(data, rowId) {
            for(var i in data) {
                var datum = data[i];
                var userDatum = {
                     "CUST_CD": EVF.V("CUST_CD")
                    ,"DML_TYPE": "REF"
                    ,"REF_USER_ID": datum.USER_ID
                    ,"REF_USER_NM": datum.USER_NM
                    ,"USE_FLAG": "1"
                    ,"LINE_CD": bizCls1 + bizCls2 + bizCls3 + bizSeq
                };

                if(i == 0) {
                    gridUR3.setRowValue(rowId, userDatum);
                } else {
                    var newRowId = gridUR3.addRow(userDatum);
                }
            }
        }

        function checkRadio() {

            var dmlTyle = this.getData();

            if(dmlTyle == "R1") {
                EVF.C("R1").setChecked(true);
                EVF.C("R2").setChecked(false);
            }
            else if(dmlTyle == "R2") {
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(true);
            }
            gridUR2.delAllRow();

            EVF.C('APP_AGR_LINE').resetOption();
            EVF.C('APP_AGR_LINE').appendOption('전체', '');

            var store = new EVF.Store();
            store.setParameter('custCd', EVF.V("CUST_CD"));
            store.setParameter('dmlTyle', dmlTyle);
            store.load(baseUrl + 'bs01010_doSearchCombo', function() {
                EVF.C('APP_AGR_LINE').setOptions(this.getParameter('appAgrLine'));
            }, false);
        }

    </script>

    <e:window id="BS01_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:inputText id="CUST_CD" name="CUST_CD" value="${ses.companyCd}" width="0" maxLength="${form_CUST_CD_M}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:search id="CUST_NM" name="CUST_NM" value="${ses.companyNm}" width="100%" maxLength="${form_CUST_NM_M}" onIconClick="${form_CUST_NM_RO ? 'everCommon.blank' : 'getBuyer'}" popupCode="SP0067.setBuyer" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
                <e:field>
                    <e:select id="USE_FLAG" name="USE_FLAG" value="" options="${useFlagOptions}" width="${form_USE_FLAG_W}" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
                </e:field>
                <e:field colSpan="2"></e:field>
            </e:row>
            <e:row>
                <e:label for="BIZ_CLS1" title="${form_BIZ_CLS1_N}"/>
                <e:field>
                    <e:select id="BIZ_CLS1" name="BIZ_CLS1" value="${form.BIZ_CLS1}" options="${bizCls1Options }" width="100%" disabled="${form_BIZ_CLS1_D}" readOnly="${form_BIZ_CLS1_RO}" required="${form_BIZ_CLS1_R}" placeHolder="" />
                </e:field>
                <e:label for="BIZ_CLS2" title="${form_BIZ_CLS2_N}"/>
                <e:field>
                    <e:select id="BIZ_CLS2" name="BIZ_CLS2" value="${form.BIZ_CLS2}" options="${bizCls2Options }" width="100%" disabled="${form_BIZ_CLS2_D}" readOnly="${form_BIZ_CLS2_RO}" required="${form_BIZ_CLS2_R}" placeHolder="" />
                </e:field>
                <e:label for="BIZ_CLS3" title="${form_BIZ_CLS3_N}"/>
                <e:field>
                    <e:select id="BIZ_CLS3" name="BIZ_CLS3" value="${form.BIZ_CLS3}" options="${bizCls3Options }" width="100%" disabled="${form_BIZ_CLS3_D}" readOnly="${form_BIZ_CLS3_RO}" required="${form_BIZ_CLS3_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <%-- e:button id="Mapping" name="Mapping" label="${Mapping_N}" onClick="doMapping" disabled="${Mapping_D}" visible="${Mapping_V}" align="left" / --%>
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch"/>
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="500px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

        <e:panel id="leftPanel" height="100%" width="33%">
            <e:buttonBar id="buttonBarUR1" align="right" width="100%">
                <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_010_008}&nbsp;</e:text>
                <e:select id="DML_TYPE" name="DML_TYPE" value="" options="${dmlTypeOptions }" width="160px" disabled="${form_DML_TYPE_D}" readOnly="${form_DML_TYPE_RO}" required="${form_DML_TYPE_R}" placeHolder="" onChange="doSearchLine" />
                <e:button id="SaveLine" name="SaveLine" label="${SaveLine_N}" disabled="${SaveLine_D}" visible="${SaveLine_V}" onClick="doSaveLine" />
                <e:button id="DelLine" name="DelLine" label="${DelLine_N}" disabled="${DelLine_D}" visible="${DelLine_V}" onClick="doDelLine"/>
            </e:buttonBar>
            <e:gridPanel id="gridUR1" name="gridUR1" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridUR1.gridColData}" />
        </e:panel>
        <e:panel id="nullPanel1" height="100%" width="1%">&nbsp;</e:panel>
        <e:panel id="centerPanel" height="100%" width="33%">
            <e:buttonBar id="buttonBarUR2" align="right" width="100%">
                <e:radio id="R1" name="R1" label="" value="1" checked="true" readOnly="false" disabled="false" onClick="checkRadio" data="R1" />
                <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_010_UR1}</e:text>
                <e:radio id="R2" name="R2" label="" value="2" checked="" readOnly="false" disabled="false" onClick="checkRadio" data="R2" />
                <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_010_UR2}&nbsp;&nbsp;</e:text>
                <e:select id="APP_AGR_LINE" name="APP_AGR_LINE" value="" options="${appAgrLineOptions }" width="160px" disabled="${form_APP_AGR_LINE_D}" readOnly="${form_APP_AGR_LINE_RO}" required="${form_APP_AGR_LINE_R}" placeHolder="" onChange="doSearchAppAgr" />
                <e:button id="SaveAppAgr" name="SaveAppAgr" label="${SaveAppAgr_N}" disabled="${SaveAppAgr_D}" visible="${SaveAppAgr_V}" onClick="doSaveAppAgr" />
                <e:button id="DelAppAgr" name="DelAppAgr" label="${DelAppAgr_N}" disabled="${DelAppAgr_D}" visible="${DelAppAgr_V}" onClick="doDelAppAgr" />
            </e:buttonBar>
            <e:gridPanel id="gridUR2" name="gridUR2" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridUR2.gridColData}" />
        </e:panel>
        <e:panel id="nullPanel2" height="100%" width="1%">&nbsp;</e:panel>
        <e:panel id="rightPanel" height="100%" width="32%">
            <e:buttonBar id="buttonBarUR3" align="right" width="100%">
                <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${BS01_010_UR3}</e:text>
                <e:button id="SaveRef" name="SaveRef" label="${SaveRef_N}" disabled="${SaveRef_D}" visible="${SaveRef_V}" onClick="doSaveRef"/>
                <e:button id="DelRef" name="DelRef" label="${DelRef_N}" disabled="${DelRef_D}" visible="${DelRef_V}" onClick="doDelRef"/>
            </e:buttonBar>
            <e:gridPanel id="gridUR3" name="gridUR3" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridUR3.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>