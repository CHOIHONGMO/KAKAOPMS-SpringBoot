<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var s_userGrid; var s_ctrlGrid;
        var menuGrid; var buttonGrid;
        var userGrid; var ctrlGrid;
        var historymenuGrid;

        var tab2_menuGrid; var tab2_buttonGrid;
        var tab2_userGrid; var tab2_ctrlGrid;

        var baseUrl = "/eversrm/system/auth/BSYA_030/";
        var title; var title2;

        var treeViewObj;
        var selectUserNm;

        function init() {

            s_userGrid = EVF.C("s_userGrid");
            s_ctrlGrid = EVF.C("s_ctrlGrid");
            menuGrid = EVF.C("menuGrid");
            buttonGrid = EVF.C("buttonGrid");
            userGrid = EVF.C("userGrid");
            ctrlGrid = EVF.C("ctrlGrid");
            historymenuGrid = EVF.C("historymenuGrid");

            tab2_menuGrid = EVF.C("tab2_menuGrid");
            tab2_buttonGrid = EVF.C("tab2_buttonGrid");
            tab2_userGrid = EVF.C("tab2_userGrid");
            tab2_ctrlGrid = EVF.C("tab2_ctrlGrid");

            s_userGrid.setProperty('shrinkToFit', true);
            s_ctrlGrid.setProperty('shrinkToFit', true);

            var treeViewObj = menuGrid.getGridViewObj();
            treeViewObj.setHeader({visible: true});
            treeViewObj.setCheckBar({visible: true});
            treeViewObj.setIndicator({visible: false});
            treeViewObj.setTreeOptions({showCheckBox: true});
            menuGrid.setProperty('shrinkToFit', true);

            menuGrid.setColCursor('MENU_NM', 'pointer');
            menuGrid.setColReadOnly('CTRL_MAPPING_YN', true);
            menuGrid.setColReadOnly('USER_MAPPING_YN', true);

            var treeViewObj_tab2 = tab2_menuGrid.getGridViewObj();
            treeViewObj_tab2.setHeader({visible: true});
//        treeViewObj_tab2.setCheckBar({visible: false});
            treeViewObj_tab2.setIndicator({visible: false});
            tab2_menuGrid.setProperty('shrinkToFit', true);
            tab2_menuGrid.setColCursor('MENU_NM', 'pointer');

            buttonGrid.setProperty('shrinkToFit', true);
            userGrid.setProperty('shrinkToFit', true);
            ctrlGrid.setProperty('shrinkToFit', true);
            tab2_menuGrid.setProperty('shrinkToFit', true);
            tab2_buttonGrid.setProperty('shrinkToFit', true);
            tab2_userGrid.setProperty('shrinkToFit', true);
            tab2_ctrlGrid.setProperty('shrinkToFit', true);

            s_userGrid.setProperty('multiselect', false);
            s_ctrlGrid.setProperty('multiselect', false);
            menuGrid.setProperty('multiselect', false);
            buttonGrid.setProperty('multiselect', false);
            userGrid.setProperty('multiselect', false);
            ctrlGrid.setProperty('multiselect', false);
            tab2_menuGrid.setProperty('multiselect', false);

            s_userGrid.cellClickEvent(function(rowid, colId, value) {
                if(colId == "USER_ID_V") {
                    EVF.V("CtrlClickYn","");
                    EVF.V("userClickYn","Y");
                    EVF.C("title").setValue("※ 적용대상 : "+s_userGrid.getCellValue(rowid, "USER_NM_$TP"));
                    selectUserNm=s_userGrid.getCellValue(rowid, "USER_NM_$TP");
                    EVF.V("USER_ID",s_userGrid.getCellValue(rowid, "USER_ID"));

                    doSearch_Ctrl();
                    doSearchTree();
                }
            });

            s_ctrlGrid.cellClickEvent(function(rowid, colId, value) {
                if(colId == "CTRL_NM") {
                    EVF.V("CtrlClickYn","Y");
                    EVF.V("userClickYn","");
                    EVF.V("CTRL_CD",s_ctrlGrid.getCellValue(rowid, "CTRL_CD"));
                    EVF.C("title").setValue("${BSYA_030_TITLE8 }"+s_ctrlGrid.getCellValue(rowid, "CTRL_NM"));
                    doSearchTree();

                }
            });

            menuGrid.cellClickEvent(function(rowId, colId, value) {

                if(colId=="MENU_NM"){
                    EVF.V("SCREEN_ID",menuGrid.getCellValue(rowId, 'SCREEN_ID'));
                    doSearch_DT();
                }
                else if(colId=="CTRL_MAPPING_YN"){
                    if(EVF.V("CtrlClickYn")!="Y"){
                        menuGrid.setColReadOnly('CTRL_MAPPING_YN', true);
                        return alert("${BSYA_030_002 }");
                    }else{
                        menuGrid.setColReadOnly('CTRL_MAPPING_YN', false);
                        var allRowId = menuGrid.getAllRowId();
                        if(menuGrid.getCellValue(rowId, 'LVL')=="1"){
                            for(var i in allRowId) {
                                var rowIds = allRowId[i];
                                var datum = menuGrid.getRowValue(rowIds);

                                if(rowIds!=rowId){
                                    if(datum['CLS1']==menuGrid.getCellValue(rowId, 'CLS1')){
                                        if(menuGrid.getCellValue(rowId, 'CTRL_MAPPING_YN')=="0"){
                                            menuGrid.setCellValue(rowIds, 'CTRL_MAPPING_YN', '1');
                                        }else{
                                            menuGrid.setCellValue(rowIds, 'CTRL_MAPPING_YN', '0');
                                        }
                                    }
                                }
                            }
                        }else if(menuGrid.getCellValue(rowId, 'LVL')=="2"){
                            for(var i in allRowId) {
                                var rowIds = allRowId[i];
                                var datum = menuGrid.getRowValue(rowIds);
                                if(rowIds!=rowId){
                                    if(datum['CLS2']==menuGrid.getCellValue(rowId, 'CLS2')){
                                        if(menuGrid.getCellValue(rowId, 'CTRL_MAPPING_YN')=="0"){
                                            menuGrid.setCellValue(rowIds, 'CTRL_MAPPING_YN', '1');
                                        }else{
                                            menuGrid.setCellValue(rowIds, 'CTRL_MAPPING_YN', '0');
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if(colId=="USER_MAPPING_YN"){
                    if(EVF.V("userClickYn")!="Y"){
                        menuGrid.setColReadOnly('USER_MAPPING_YN', true);
                        return alert("${BSYA_030_003 }");
                    }else{
                        menuGrid.setColReadOnly('USER_MAPPING_YN', false);
                        var allRowId = menuGrid.getAllRowId();
                        if(menuGrid.getCellValue(rowId, 'LVL')=="1"){
                            for(var i in allRowId) {
                                var rowIds = allRowId[i];
                                var datum = menuGrid.getRowValue(rowIds);

                                if(rowIds!=rowId){
                                    if(datum['CLS1']==menuGrid.getCellValue(rowId, 'CLS1')){
                                        if(menuGrid.getCellValue(rowId, 'USER_MAPPING_YN')=="0"){
                                            menuGrid.setCellValue(rowIds, 'USER_MAPPING_YN', '1');
                                        }else{
                                            menuGrid.setCellValue(rowIds, 'USER_MAPPING_YN', '0');
                                        }
                                    }
                                }
                            }
                        }else if(menuGrid.getCellValue(rowId, 'LVL')=="2"){
                            for(var i in allRowId) {
                                var rowIds = allRowId[i];
                                var datum = menuGrid.getRowValue(rowIds);
                                if(rowIds!=rowId){
                                    if(datum['CLS2']==menuGrid.getCellValue(rowId, 'CLS2')){
                                        if(menuGrid.getCellValue(rowId, 'USER_MAPPING_YN')=="0"){
                                            menuGrid.setCellValue(rowIds, 'USER_MAPPING_YN', '1');
                                        }else{
                                            menuGrid.setCellValue(rowIds, 'USER_MAPPING_YN', '0');
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            });


            buttonGrid.cellClickEvent(function(rowid, colId, value) {
                if(colId == "ACTION_CD") {
                    EVF.V("SCREEN_ID",buttonGrid.getCellValue(rowid, "SCREEN_ID"));
                    EVF.V("ACTION_CD",buttonGrid.getCellValue(rowid, "ACTION_CD"));
                    doSearch_DT_Tab1();

                }
            });


            tab2_menuGrid.cellClickEvent(function(rowId, colId, value) {

                if(colId=="MENU_NM"){
                    EVF.V("SCREEN_ID",tab2_menuGrid.getCellValue(rowId, 'SCREEN_ID'));
                    EVF.V("SCREEN_NM",tab2_menuGrid.getCellValue(rowId, 'MENU_NM'));
                    tab2_buttonGrid.delAllRow();
                    doSearch_DT_Button_Tab2();
                }
            });


            tab2_buttonGrid.cellClickEvent(function(rowid, colId, value) {
                if(colId == "ACTION_CD") {
                    EVF.V("tab2_buttonGrid_YN","Y");
                    EVF.V("SCREEN_ID",tab2_buttonGrid.getCellValue(rowid, "SCREEN_ID"));
                    EVF.V("ACTION_CD",tab2_buttonGrid.getCellValue(rowid, "ACTION_CD"));
                    tab2_userGrid.delAllRow();
                    tab2_ctrlGrid.delAllRow();
                    doSearch_DT_Tab2();
                }
            });

            doSearchTree();

            doSearch_Ctrl();

            doSearchTree_tab2();
        }

        $(document.body).ready(function() {
            $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                    activate: function(event, ui) {

                        $(window).trigger('resize');
                    }
                }
            );
            $('#e-tabs').tabs('option', 'active', 0);
            getContentTab('1');

        });
        function getContentTab(uu) {
            if (uu == '1') {
                window.scrollbars = true;
            }
            if (uu == '2') {
                window.scrollbars = true;
            }
        }

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([s_userGrid]);
            store.load(baseUrl + 'doSearch_UserList', function() {
                if(s_userGrid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                    doClear();
                }else {

                }
            });
        }


        function doSearch_Ctrl() {
            var store = new EVF.Store();
            store.setGrid([s_ctrlGrid]);
            store.load(baseUrl + 'doSearch_CtrlList', function() {
            });
        }


        function doSearch_DT(){
            var store = new EVF.Store();
            store.setGrid([buttonGrid]);
            store.load(baseUrl + 'doSearch_ButtonList', function() {

                var store = new EVF.Store();
                store.setGrid([userGrid]);
                store.load(baseUrl + 'doSearch_Menu_UserList', function() {
                    var store = new EVF.Store();
                    store.setGrid([ctrlGrid]);
                    store.load(baseUrl + 'doSearch_Menu_CtrlList', function() {

                    }, false);
                }, false);
            }, false);
        }


        function doSearchTree() {

            var store = new EVF.Store();
            store.load(baseUrl + 'doSearch_menuTree', function() {

                var treeData = this.getParameter("treeData");
                var jsonTree = JSON.parse(treeData);

                menuGrid.getDataProvider().setRows(jsonTree, 'tree', '', '', 'icon');
                treeViewObj = menuGrid.getGridViewObj();
                treeViewObj.expandAll();
            });
        }


        function doSearch_DT_Tab1(){
            var store = new EVF.Store();
            store.setGrid([userGrid]);
            store.load(baseUrl + 'doSearch_Button_UserList_Tab1', function() {
                var store = new EVF.Store();
                store.setGrid([ctrlGrid]);
                store.load(baseUrl + 'doSearch_Button_CtrlList_Tab1', function() {

                });
            });
        }



        function doSave() {
            var checkMappingYn="";
            var allRowId = menuGrid.getAllRowId();
            for(var i in allRowId) {
                var rowIds = allRowId[i];
                var datum = menuGrid.getRowValue(rowIds);

                if(EVF.V("CtrlClickYn")=="Y"){
                    if(datum['CTRL_MAPPING_YN']=="1"){
                        if(datum['SCREEN_ID']==" "||datum['SCREEN_ID']==""){

                        }else{
                            checkMappingYn="Y";
                        }
                    }
                }
                if(EVF.V("userClickYn")=="Y"){
                    if(datum['USER_MAPPING_YN']=="1"){
                        if(datum['SCREEN_ID']==" "||datum['SCREEN_ID']==""){

                        }else{
                            checkMappingYn="Y";
                        }
                    }
                }
            }


            if (!confirm("${msg.M0021}")) return;

            doSetMenuHistoryTable();

            var store = new EVF.Store();
            store.setGrid([menuGrid, historymenuGrid]);
            store.getGridData(menuGrid, 'all');
            store.getGridData(historymenuGrid, 'all');
            store.load(baseUrl + 'doSave_Menu_Auth', function() {
                alert(this.getResponseMessage());
                doSearchTree();
            });
        }

        function doSave2(){

            if(!ctrlGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([ctrlGrid]);
            store.getGridData(ctrlGrid, 'all');
            store.load(baseUrl + 'doSave_Menu_Auth_CTRL', function() {
                alert(this.getResponseMessage());
                var store = new EVF.Store();
                store.setGrid([ctrlGrid]);
                store.load(baseUrl + 'doSearch_Button_CtrlList_Tab1', function() {});
            });
        }

        function doSetMenuHistoryTable(){

            var addParam = [];
            var chType;
            var allRowId = menuGrid.getAllRowId();
            for(var ri in allRowId) {
                var rowId = allRowId[ri];

                if(menuGrid.getCellValue(rowId, 'SCREEN_ID')!=""){

                    if(menuGrid.getCellValue(rowId, 'CTRL_MAPPING_YN') != menuGrid.getCellValue(rowId, 'HIDDEN_CTRL_MAP_YN')){


                        if(menuGrid.getCellValue(rowId, 'CTRL_MAPPING_YN')=="0"){
                            chType="D";
                        }else{
                            chType="C";
                        }

                        addParam = [{
                            "SCREEN_ID" : menuGrid.getCellValue(rowId, 'SCREEN_ID')
                            ,"DATA_TYPE" : 'J'
                            ,"DATA_CD" : EVF.V("CTRL_CD")
                            ,"CH_TYPE" : chType
                        }];
                        historymenuGrid.addRow(addParam);
                    }
                    if(menuGrid.getCellValue(rowId, 'USER_MAPPING_YN') != menuGrid.getCellValue(rowId, 'HIDDEN_USER_MAP_YN')){

                        if(menuGrid.getCellValue(rowId, 'USER_MAPPING_YN')=="0"){
                            chType="C";
                        }else{
                            chType="D";
                        }

                        addParam = [{

                            "SCREEN_ID" : menuGrid.getCellValue(rowId, 'SCREEN_ID')
                            ,"DATA_TYPE" : 'U'
                            ,"DATA_CD" : EVF.V("USER_ID")
                            ,"CH_TYPE" : chType
                        }];
                        historymenuGrid.addRow(addParam);
                    }
                }
            }
        }



        function doClear(){
            s_ctrlGrid.delAllRow();
            menuGrid.delAllRow();
            buttonGrid.delAllRow();
            userGrid.delAllRow();
            ctrlGrid.delAllRow();
        }

        function doSearchTree_tab2() {

            var store = new EVF.Store();
            store.load(baseUrl + 'doSearch_menuTree', function() {

                var treeData = this.getParameter("treeData");
                var jsonTree = JSON.parse(treeData);

                tab2_menuGrid.getDataProvider().setRows(jsonTree, 'tree', '', '', 'icon');
                var treeViewObj_tab2 = tab2_menuGrid.getGridViewObj();
                treeViewObj_tab2.expandAll();
            });
        }


        function doSearch_DT_Button_Tab2(){
            var store = new EVF.Store();
            store.setGrid([tab2_buttonGrid]);
            store.load(baseUrl + 'doSearch_ButtonList_tab2', function() {
                if(tab2_buttonGrid.getRowCount() != 0){

                    EVF.V("tab2_buttonGrid_YN","Y");
                    EVF.V("SCREEN_ID",tab2_buttonGrid.getCellValue(0, "SCREEN_ID"));
                    EVF.V("ACTION_CD",tab2_buttonGrid.getCellValue(0, "ACTION_CD"));
                    tab2_userGrid.delAllRow();
                    tab2_ctrlGrid.delAllRow();
                    doSearch_DT_Tab2();
                }
            });
        }

        function doSearch_DT_Tab2(){
            var store = new EVF.Store();
            store.setGrid([tab2_userGrid]);
            store.load(baseUrl + 'doSearch_Button_UserList_Tab2', function() {
                var store = new EVF.Store();
                store.setGrid([tab2_ctrlGrid]);
                store.load(baseUrl + 'doSearch_Button_CtrlList_Tab2', function() {

                });
            });
        }

        function Tab2_doSave(){

            if(!tab2_buttonGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!tab2_ctrlGrid.isExistsSelRow()&&!tab2_userGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([tab2_buttonGrid,tab2_ctrlGrid,tab2_userGrid]);
            store.getGridData(tab2_buttonGrid, 'sel');
            store.getGridData(tab2_ctrlGrid, 'sel');
            store.getGridData(tab2_userGrid, 'sel');
            store.load(baseUrl + 'doSave_Button_Auth', function() {
                alert(this.getResponseMessage());
                doSearch_DT_Tab2();
            });
        }

        function Tab2_doDelete(){
            if(!tab2_buttonGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!tab2_ctrlGrid.isExistsSelRow()&&!tab2_userGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([tab2_buttonGrid,tab2_ctrlGrid,tab2_userGrid]);
            store.getGridData(tab2_buttonGrid, 'sel');
            store.getGridData(tab2_ctrlGrid, 'sel');
            store.getGridData(tab2_userGrid, 'sel');
            store.load(baseUrl + 'doDelete_Button_Auth', function() {
                alert(this.getResponseMessage());
                doSearch_DT_Tab2();
            });
        }

        function doSearchCTRL(){

            if(this.getData()=="T1"){
                var param = {
                    callBackFunction : "setCtrlCdMulti_T1"
                };
                everPopup.openCommonPopup(param, 'MP0016');
            }else{
                var param = {
                    callBackFunction : "setCtrlCdMulti_T2"
                };
                everPopup.openCommonPopup(param, 'MP0016');
            }


        }

        function setCtrlCdMulti_T1(data) {
            if(data.length != undefined) {
                var dataArr = [];
                for(idx in data) {
                    var arr = {
                        'CTRL_CD': data[idx].CTRL_CD,
                        'CTRL_NM': data[idx].CTRL_NM
                    };
                    dataArr.push(arr);
                }
                var validData = valid.equalPopupValid(JSON.stringify(dataArr), ctrlGrid, "CTRL_NM");
                ctrlGrid.addRow(validData);
            }
        }

        function setCtrlCdMulti_T2(data) {
            if(data.length != undefined) {
                var dataArr = [];
                for(idx in data) {
                    var arr = {
                        'CTRL_CD': data[idx].CTRL_CD,
                        'CTRL_NM': data[idx].CTRL_NM
                    };
                    dataArr.push(arr);
                }
                var validData = valid.equalPopupValid(JSON.stringify(dataArr), tab2_ctrlGrid, "CTRL_NM");
                tab2_ctrlGrid.addRow(validData);
            }
        }

        function doSearchUser(){
            var param = {
                callBackFunction : "setUserCdMulti"
            };
            everPopup.openCommonPopup(param, 'MP0007');
        }
        function setUserCdMulti(data) {
            if(data.length != undefined) {
                var dataArr = [];
                for(idx in data) {
                    var arr = {
                        'USER_ID_V': data[idx].USER_ID,
                        'DATA_CD': data[idx].USER_ID,
                        'USER_NM': data[idx].USER_NM,
                        'DEPT_NM': data[idx].DEPT_NM
                    };
                    dataArr.push(arr);
                }
                var validData = valid.equalPopupValid(JSON.stringify(dataArr), tab2_userGrid, "USER_ID");
                tab2_userGrid.addRow(validData);
            }
        }

        function getRegUserId() {
            var param = {
                callBackFunction : "setRegUserId"
            };
            everPopup.openCommonPopup(param, 'SP0011');
        }
        function setRegUserId(dataJsonArray) {
            EVF.C("COPY_USER_ID").setValue(dataJsonArray.USER_ID);
        }

        function doCopy(){

            if(EVF.V("userClickYn")==""){
                return alert("${BSYA_030_003 }");
            }

            if(EVF.V("COPY_USER_ID")==""){
                return alert("${BSYA_030_004 }");
            }
            if(!confirm(everString.getMessage("${BSYA_030_005}",selectUserNm))) { return; }

            var store = new EVF.Store();
            store.load(baseUrl + 'doCopy_Auth', function() {
                alert(this.getResponseMessage());
                doSearch_DT_Tab2();
            });

        }


    </script>
    <e:window id="BSYA_030" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:panel id="pnl2" width="100%"  height="fit">
            <div id="e-tabs" class="e-tabs">
                <ul>
                    <li><a href="#ui-tabs-1" onclick="getContentTab('1');">메뉴 권한</a></li>
                    <li><a href="#ui-tabs-2" onclick="getContentTab('2');">버튼 권한</a></li>
                </ul>
                <e:panel id="pnl2_sub" width="100%"  height="fit">

                    <%-----------------------------------------------------------------------%>
                    <div id="ui-tabs-1">
                        <e:panel id="H1" width="25%" height="fit" >
                            <e:panel id="h1_f1" width="100%"  height="80px">
                                <e:searchPanel id="form" title="${form_CAPTION_N }" onEnter="doSearch" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="1">
                                    <e:inputHidden id="USER_ID" name="USER_ID" value="" />
                                    <e:inputHidden id="SCREEN_ID" name="SCREEN_ID" value="" />
                                    <e:inputHidden id="SCREEN_NM" name="SCREEN_NM" value="" />
                                    <e:inputHidden id="ACTION_CD" name="ACTION_CD" value="" />
                                    <e:inputHidden id="CTRL_CD" name="CTRL_CD" value="" />
                                    <e:inputHidden id="userClickYn" name="userClickYn" value="" />
                                    <e:inputHidden id="CtrlClickYn" name="CtrlClickYn" value="" />
                                    <e:row>
                                        <e:label for="USER_NM" title="${form_USER_NM_N}"></e:label>
                                        <e:field>
                                            <e:inputText id="USER_NM" style="${imeMode}" name="USER_NM" value="${form.USER_NM}" width="100%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                                        </e:field>
                                    </e:row>
                                </e:searchPanel>
                                <e:buttonBar id="bt1" align="right" width="100%">
                                    <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" visible="${doSearch_V }"  onClick="doSearch" />
                                </e:buttonBar>
                            </e:panel>

                            <e:panel id="h1_g1" width="100%" height="260px">
                                <e:gridPanel gridType="${_gridType}" id="s_userGrid" name="s_userGrid" width="100%" height="230px" readOnly="${param.detailView}" columnDef="${gridInfos.s_userGrid.gridColData}" />
                            </e:panel>
                            <e:panel id="h1_g2" width="100%" height="fit" >
                                <e:title title="${BSYA_030_TITLE5}" depth="1" />
                                <e:gridPanel gridType="${_gridType}" id="s_ctrlGrid" name="s_ctrlGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.s_ctrlGrid.gridColData}" />
                            </e:panel>
                        </e:panel>

                        <e:panel id="H2_b" width="1%" height="fit" >&nbsp;</e:panel>
                        <e:panel id="H2" width="43%" height="fit">
                            <e:text id="title" name="title" style="font-weight:bold; color:blue; font-size:13px; margin-right : 5px;">${title}</e:text>
                            <e:search id="COPY_USER_ID" name="COPY_USER_ID" value="" width="120px" maxLength="${form_COPY_USER_ID_M}" onIconClick="getRegUserId" disabled="${form_COPY_USER_ID_D}" readOnly="${form_COPY_USER_ID_RO}" required="${form_COPY_USER_ID_R}" />
                            &nbsp;
                            <e:button id="copy" name="copy" label="${copy_N }" disabled="${copy_D }" visible="${copy_V }"  onClick="doCopy" />

                            <e:buttonBar id="bt2" align="right" width="100%" title="${BSYA_030_TITLE3 }">
                                <e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" visible="${doSave_V }"  onClick="doSave" />
                            </e:buttonBar>
                            <e:gridPanel gridType="RGT" id="menuGrid" name="menuGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.menuGrid.gridColData}" />

                            <e:panel id="Hidden1" width="0"  height="0">
                                <e:gridPanel gridType="${_gridType}" id="historymenuGrid" name="historymenuGrid" width="0" height="0" columnDef="${gridInfos.historymenuGrid.gridColData}" />
                            </e:panel>
                        </e:panel>

                        <e:panel id="H3_b" width="1%"  height="fit" >&nbsp;</e:panel>
                        <e:panel id="H3" width="30%"  height="fit">
                            <e:title title="${BSYA_030_TITLE4}" depth="1" />
                            <e:gridPanel gridType="${_gridType}" id="buttonGrid" name="buttonGrid" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.buttonGrid.gridColData}" />

                            <e:title title="${BSYA_030_TITLE1}" depth="1" />
                            <e:gridPanel gridType="${_gridType}" id="userGrid" name="userGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.userGrid.gridColData}" />

                            <e:buttonBar id="tab1_btn3" align="right" width="100%" title="${BSYA_030_TITLE2 }">
                                <e:button id="doSelectBaco" name="doSelectBaco" label="${doSelectBaco_N }" disabled="${doSelectBaco_D }" visible="${doSelectBaco_V}" onClick="doSearchCTRL" data="T1"/>
                                <e:button id="doSave2" name="doSave2" label="${doSave2_N }" disabled="${doSave2_D }" visible="${doSave2_V}" onClick="doSave2" />
                            </e:buttonBar>
                            <e:gridPanel gridType="${_gridType}" id="ctrlGrid" name="ctrlGrid" width="100%" height="200" readOnly="${param.detailView}" columnDef="${gridInfos.ctrlGrid.gridColData}" />
                        </e:panel>
                    </div>

                    <%-----------------------------------------------------------------------%>
                    <div id="ui-tabs-2">
                        <e:panel id="tab2_t1" height="fit" width="50%">
                            <e:gridPanel gridType="RGT" id="tab2_menuGrid" name="tab2_menuGrid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.tab2_menuGrid.gridColData}" />
                        </e:panel>
                        <e:panel id="tab2_null1" height="400" width="1%">&nbsp;</e:panel>
                        <e:panel id="tab2_t2" height="400" width="49%">
                            <e:buttonBar id="tab2_btn1" align="right" width="100%" title="${BSYA_030_TITLE4 }">
                                <e:button id="Tab2_doSave" name="Tab2_doSave" label="${Tab2_doSave_N }" disabled="${Tab2_doSave_D }" visible="${Tab2_doSave_V}" onClick="Tab2_doSave" />
                                <e:button id="Tab2_doDelete" name="Tab2_doDelete" label="${Tab2_doDelete_N }" disabled="${Tab2_doDelete_D }" visible="${Tab2_doDelete_V}" onClick="Tab2_doDelete" />
                            </e:buttonBar>
                            <e:inputHidden id="tab2_buttonGrid_YN" name="tab2_buttonGrid_YN" value="" />
                            <e:gridPanel id="tab2_buttonGrid" name="tab2_buttonGrid" width="100%" height="345" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.tab2_buttonGrid.gridColData}" />
                        </e:panel>
                        <e:panel id="tab2_b1" height="fit" width="50%">
                            <e:buttonBar id="tab2_btn2" align="right" width="100%" title="${BSYA_030_TITLE6 }">
                                <e:button id="doSearchCTRL" name="doSearchCTRL" label="${doSearchCTRL_N }" disabled="${doSearchCTRL_D }" visible="${doSearchCTRL_V}" onClick="doSearchCTRL" data="T2"/>
                            </e:buttonBar>
                            <e:gridPanel id="tab2_ctrlGrid" name="tab2_ctrlGrid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.tab2_ctrlGrid.gridColData}" />
                        </e:panel>
                        <e:panel id="tab2_null2" height="fit" width="1%">&nbsp;</e:panel>
                        <e:panel id="tab2_b2" height="fit" width="49%">
                            <e:buttonBar id="tab2_btn3" align="right" width="100%" title="${BSYA_030_TITLE7 }">
                                <e:button id="doSearchUser" name="doSearchUser" label="${doSearchUser_N }" disabled="${doSearchUser_D }" visible="${doSearchUser_V}" onClick="doSearchUser" />
                            </e:buttonBar>
                            <e:gridPanel id="tab2_userGrid" name="tab2_userGrid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.tab2_userGrid.gridColData}" />
                        </e:panel>
                    </div>
                </e:panel>
            </div>
        </e:panel>
    </e:window>
</e:ui>