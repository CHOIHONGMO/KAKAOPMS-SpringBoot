<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid1;
        var grid2;
        var grid3;
        var itemList;
        var parentClass;
        var saveClassCode;
        var init;
        var baseUrl = "/evermp/IM04/IM0403/";

        var activeGrid1RowId;
        var activeGrid2RowId;
        var activeGrid3RowId;

        function init() {

            grid1 = EVF.C("grid1");
            grid2 = EVF.C("grid2");
            grid3 = EVF.C("grid3");

            grid1.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio1").setChecked(true);

                if(colId == 'PT_ITEM_CLS1') {
                    activeGrid1RowId = rowId;
                    onCellClick1(colId, rowId);
                }
            });
            grid2.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio2").setChecked(true);

                if(colId == 'PT_ITEM_CLS2') {
                    activeGrid2RowId = rowId;
                    onCellClick2(colId, rowId);
                }
            });
            grid3.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio3").setChecked(true);

                if(colId == 'PT_ITEM_CLS3') {
                    activeGrid3RowId = rowId;
                    onCellClick3(colId, rowId);
                }
            });

            grid1.addRowEvent(function() {
                grid1.addRow([
                    {"INSERT_FLAG": "I",
                        "PT_ITEM_CLS_TYPE": "C1",
                        "PT_ITEM_CLS2": "*",
                        "PT_ITEM_CLS3": "*",
                        "GATE_CD":"${ses.gateCd}",
                        "USE_FLAG":"1"}
                ]);
            });

            grid2.addRowEvent(function() {

                if (grid1.getRowCount() > 0 && activeGrid1RowId != -1 && grid1.getCellValue(activeGrid1RowId, "PT_ITEM_CLS1") != null) {
                    if (grid1.getCellValue(activeGrid1RowId, "INSERT_FLAG") == "I") {
                        alert("${IM04_010_0002}");
                        return;
                    }

                    grid2.addRow([{
                        "INSERT_FLAG": "I",
                        "PT_ITEM_CLS_TYPE": "C2",
                        "PT_ITEM_CLS1": grid1.getCellValue(activeGrid1RowId, "PT_ITEM_CLS1"),
                        "PT_ITEM_CLS3": "*",
                        "GATE_CD": grid1.getCellValue(activeGrid1RowId, "GATE_CD"),
                        "USE_FLAG":"1"
                    }]);

                    parentClass = "1";
                    saveClassCode = grid2.getCellValue(activeGrid2RowId, "PT_ITEM_CLS1");

                } else {
                    alert("${IM04_010_0002}");

                }
            });

            grid3.addRowEvent(function() {

                if (grid2.getRowCount() > 0 && activeGrid2RowId != -1 && grid2.getCellValue(activeGrid2RowId, "PT_ITEM_CLS2") != null) {
                    if (grid2.getCellValue(activeGrid2RowId, "INSERT_FLAG") == "I") {
                        alert("${IM04_010_0003}");
                        return;
                    }

                    grid3.addRow([{
                        "INSERT_FLAG": "I",
                        "PT_ITEM_CLS_TYPE": "C3",
                        "PT_ITEM_CLS1": grid1.getCellValue(activeGrid1RowId, "PT_ITEM_CLS1"),
                        "PT_ITEM_CLS2": grid2.getCellValue(activeGrid2RowId, "PT_ITEM_CLS2"),
                        "GATE_CD": grid1.getCellValue(activeGrid1RowId, "GATE_CD"),
                        "USE_FLAG":"1"
                    }]);

                    parentClass = "2";
                    saveClassCode = grid3.getCellValue("PT_ITEM_CLS2", activeGrid3RowId);

                } else {
                    alert("${IM04_010_0003}");

                }

            });


            var excelProp = {
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType}",
                fileName: "${fullScreenName}",
                excelOptions: {
                    imgWidth: 0.12,        <%-- // 이미지의 너비. --%>
                    imgHeight: 0.26 ,      <%-- // 이미지의 높이. --%>
                    colWidth: 20,          <%-- // 컬럼의 넓이. --%>
                    rowSize: 500,          <%-- // 엑셀 행에 높이 사이즈. --%>
                    attachImgFlag: false   <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            };

            grid1.excelExportEvent(excelProp);
            grid2.excelExportEvent(excelProp);
            grid3.excelExportEvent(excelProp);

            grid1.setProperty('shrinkToFit', true);
            grid2.setProperty('shrinkToFit', true);
            grid3.setProperty('shrinkToFit', true);

            setLinkStyle();
            doSearch();
        }

        function setLinkStyle() {

            grid1.setColFontColor("PT_ITEM_CLS1", '#000DFF');
            grid1.setColFontUnderline("PT_ITEM_CLS1", true);

            grid2.setColFontColor("PT_ITEM_CLS2", '#000DFF');
            grid2.setColFontUnderline("PT_ITEM_CLS2", true);

            grid3.setColFontColor("PT_ITEM_CLS3", '#000DFF');
            grid3.setColFontUnderline("PT_ITEM_CLS3", true);
        }

        function onCellClick1(colId, rowId) {

            var gridClass = grid1;
            if (colId === "PT_ITEM_CLS1" && gridClass.getCellValue(rowId, "INSERT_FLAG") !== "I") {

                grid2.checkAll(true);
                grid2.delRow();
                grid3.checkAll(true);
                grid3.delRow();

                EVF.C("ITEM_CLS_CLICKED").setValue(grid1.getCellValue(rowId, "PT_ITEM_CLS1"));
                EVF.C("ITEM_CLS_TYPE_CLICKED").setValue(grid1.getCellValue(rowId, "PT_ITEM_CLS_TYPE"));
                var store = new EVF.Store();
                store.setGrid([grid2, grid3]);
                store.getGridData(grid2, 'all');
                store.load(baseUrl + "IM04_010/im04010_selectChildClass", function () {
                    if(grid2.getRowCount() != 0) {
                        EVF.C("radio2").setChecked(true);
                        activeGrid2RowId = 0;
                        onCellClick2('PT_ITEM_CLS2', 0);
                    }
                }, false);
            }
        }

        function onCellClick2(colId, rowId) {

            var gridClass = grid2;
            if (colId === "PT_ITEM_CLS2" && gridClass.getCellValue(rowId, "INSERT_FLAG") !== "I") {

                grid3.checkAll(true);
                grid3.delRow();

                EVF.C("ITEM_CLS_CLICKED").setValue(grid2.getCellValue(rowId, "PT_ITEM_CLS2"));
                EVF.C("ITEM_CLS_TYPE_CLICKED").setValue(grid2.getCellValue(rowId, "PT_ITEM_CLS_TYPE"));
                var store = new EVF.Store();
                store.setGrid([grid3]);
                store.getGridData(grid3, 'all');
                store.load(baseUrl + "IM04_010/im04010_selectChildClass", function () {
                    if(grid3.getRowCount() != 0) {
                        EVF.C("radio3").setChecked(true);
                        activeGrid3RowId = 0;
                        onCellClick3('PT_ITEM_CLS3', 0);
                    }
                }, false);
            }
        }

        function onCellClick3(colId, rowId) {
            var gridClass = grid3;
        }

        function doSearch() {


            if(EVF.C("USE_FLAG").getValue()=="0" || EVF.C("ITEM_CLS_NM").getValue()!=""){
                init ="N"
            }else{
                init ="Y";
                EVF.V("ITEM_CLS","C1");
            }

            var store = new EVF.Store();
            store.load(baseUrl + "IM04_010/im04010_selectItemClass", function () {
                itemList = JSON.parse(this.getParameter("refItemList"));
                if (itemList.length > 0) {
                    if (init == "Y") {
                        EVF.V("ITEM_CLS", "");
                    }
                    renderItemClass();
                } else {
                    alert("${msg.M0002 }");
                    grid1.checkAll(true);
                    grid2.checkAll(true);
                    grid3.checkAll(true);
                    grid1.delRow();
                    grid2.delRow();
                    grid3.delRow();

                }
            });
        }

        function renderItemClass() {

            var itemClass = EVF.C("ITEM_CLS").getValue();

            if (itemClass == "" || itemClass == null)
                if(itemClass==""){
                    itemClass = "C1";
                }

            var grid1Data = [];
            var grid2Data = [];
            var grid3Data = [];

            grid1.checkAll(true);
            grid2.checkAll(true);
            grid3.checkAll(true);
            grid1.delRow();
            grid2.delRow();
            grid3.delRow();

            for (var i = 0, length = itemList.length; i < length; i++) {

                var itemClassType = itemList[i].PT_ITEM_CLS_TYPE;
                switch (itemClassType) {
                    case "C1":
                        insertClass(grid1Data, i);
                        break;
                    case "C2":
                        insertClass(grid2Data, i);
                        break;
                    case "C3":
                        insertClass(grid3Data, i);
                        break;
                }
            }

            grid1.setGridData(grid1Data);
            grid2.setGridData(grid2Data);
            grid3.setGridData(grid3Data);

            if (grid1.getRowCount() > 0) {

                if(EVF.C("USE_FLAG").getValue()=="0" || EVF.C("ITEM_CLS_NM").getValue()!=""){

                }else{
                    EVF.C("radio1").setChecked(true);
                    activeGrid1RowId = 0;
                    onCellClick1('PT_ITEM_CLS1', 0);

                    if (EVF.C("ITEM_CLS").getValue() != "") {
                        searchAfter(itemClass);
                    }
                }
            }
        }

        function searchAfter(itemClass) {
            if(itemClass=='C1'){
                EVF.C("radio1").setChecked(true);
                activeGrid1RowId = 0;
                onCellClick1('PT_ITEM_CLS1', 0);
            }else if(itemClass=='C2'){
                EVF.C("radio2").setChecked(true);
                activeGrid2RowId = 0;
                onCellClick2('PT_ITEM_CLS2', 0);
            }else if(itemClass=='C3'){
                EVF.C("radio3").setChecked(true);
                activeGrid3RowId = 0;
                onCellClick3('PT_ITEM_CLS3', 0);
            }
        }
        function insertClass(gridData, fromIndex) {
            gridData.push({
                PT_ITEM_CLS1 : itemList[fromIndex].PT_ITEM_CLS1
                , ITEM_CLS_ORI: itemList[fromIndex].ITEM_CLS_ORI //itemList[fromIndex].ITEM_CLS + itemList[fromIndex].PT_ITEM_CLS_TYPE.substring(1, 2)
                , PT_ITEM_CLS2: itemList[fromIndex].PT_ITEM_CLS2
                , PT_ITEM_CLS3: itemList[fromIndex].PT_ITEM_CLS3
                , PT_ITEM_CLS_NM: itemList[fromIndex].PT_ITEM_CLS_NM
                , PT_ITEM_CLS_TYPE: itemList[fromIndex].PT_ITEM_CLS_TYPE
                , USE_FLAG: itemList[fromIndex].USE_FLAG
                , GATE_CD: itemList[fromIndex].GATE_CD
                , INSERT_FLAG: 'U'
            });
        }

        function getActiveGrid() {
            var radioArray = ["radio1", "radio2", "radio3", "radio4"];
            var gridArray = ["grid1", "grid2", "grid3"];
            for (var i = 0; i < radioArray.length; i++) {
                if (EVF.C(radioArray[i]).isChecked()) {
                    return gridArray[i];
                }
            }
        }

        function getActiveRadio() {
            var radioArray = ["radio1", "radio2", "radio3", "radio4"];
            for (var i = 0; i < radioArray.length; i++) {
                if (EVF.C(radioArray[i]).isChecked()) {
                    return radioArray[i];
                }
            }
        }

        function doSave() {

            var activeGridId = getActiveGrid();

            if (activeGridId == undefined) {
                alert("${IM04_010_0001}");
                return;
            }

            var activeGrid = EVF.C(activeGridId);

            <%-- 대분류를 제외한 모든 컬럼의 코드가 자동생성(auto)일 때만 유효성을 체크한다. --%>
            if (getActiveRadio() !== "radio1" && "${keyRule}" === "auto") {

                var selectedRowIds = activeGrid.getSelRowId();
                for(var i in selectedRowIds) {
                    var selRowId = selectedRowIds[i];
                    var colValue = activeGrid.getCellValue(selRowId, 'PT_ITEM_CLS_NM');
                    if(EVF.isEmpty(colValue)) {
                        return alert('${IM04_010_0006}'); <%-- 코드명을 입력하시기 바랍니다. --%>
                    }
                }

            } else {
                if(!activeGrid.validate()['flag']) {
                    return alert(activeGrid.validate()['msg']);
                }


                if(activeGrid.jsonToArray(activeGrid.getSelRowId())['key'].length === 0) {
                    return alert("${msg.M0004}");
                }



            }

            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([activeGrid]);
            store.getGridData(activeGrid, 'sel');
            if (getActiveRadio() == "radio1") {
                parentClass = undefined;
                saveClassCode = undefined;

                store.setParameter("CLASS_TO_SAVE", "C1");
                store.load(baseUrl + "IM04_010/im04010_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
                });

            } else if (getActiveRadio() == "radio2") {
                parentClass = "1";
                saveClassCode = grid1.getCellValue(activeGrid1RowId, "PT_ITEM_CLS1");
                var saveClassRow = activeGrid1RowId;

                store.setParameter("CLASS_TO_SAVE", "C2");
                store.load(baseUrl + "IM04_010/im04010_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
//	            onCellClick1("PT_ITEM_CLS1", saveClassRow);
                });

            } else if (getActiveRadio() == "radio3") {
                parentClass = "2";
                saveClassCode = grid2.getCellValue(activeGrid2RowId, "PT_ITEM_CLS2");
                var saveClassRow = activeGrid2RowId;

                store.setParameter("CLASS_TO_SAVE", "C3");
                store.load(baseUrl + "IM04_010/im04010_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
                    //onCellClick2("PT_ITEM_CLS2", saveClassRow);
                });

            }
        }

        function doDelete() {

            var activeGridId = getActiveGrid();
            if (activeGridId == undefined) {
                alert("${IM04_010_0001}");
                return;
            }

            var activeGrid = EVF.C(activeGridId);

            if(activeGrid.jsonToArray(activeGrid.getSelRowId())['key'].length === 0) {
                return alert("${msg.M0004}");
            }

            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();

            if (getActiveRadio() == "radio1") {
                store.setParameter("CLASS_TO_DELETE", "C1");
            } else if (getActiveRadio() == "radio2") {
                store.setParameter("CLASS_TO_DELETE", "C2");
            } else if (getActiveRadio() == "radio3") {
                store.setParameter("CLASS_TO_DELETE", "C3");
            }

            store.setGrid([activeGrid]);
            store.getGridData(activeGrid, 'sel');
            store.load(baseUrl + "IM04_010/im04010_deleteItemClass", function () {

                if(this.getResponseMessage()=="X"){
                    alert("${IM04_010_0005}");
                } else {

                    activeGrid.delRow();
                    alert("${msg.M0017 }");

                    <%-- 지운 값을 기준으로 그 다음 분류의 그리드는 모두 초기화시켜버린다. --%>
                    switch(activeGridId) {
                        case 'grid1':
                            grid2.checkAll(true);
                            grid2.delRow();
                            grid3.checkAll(true);
                            grid3.delRow();
                            break;
                        case 'grid2':
                            grid3.checkAll(true);
                            grid3.delRow();
                            break;
                    }
                }
            });
        }

    </script>

    <e:window id="IM04_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:label for="ITEM_CLS" title="${form_ITEM_CLS_NM_N}"/>
            <e:field colSpan="3">
                <e:select id="ITEM_CLS" name="ITEM_CLS" value="${form.ITEM_CLS}" options="${itemClsOptions}" width="40%" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" usePlaceHolder="false" />
                <e:inputText id="ITEM_CLS_NM" name="ITEM_CLS_NM" width="60%" maxLength="${form_ITEM_CLS_NM_M }" required="${form_ITEM_CLS_NM_R }" readOnly="${form_ITEM_CLS_NM_RO }" disabled="${form_ITEM_CLS_NM_D}" visible="${form_ITEM_CLS_NM_V}"/>
            </e:field>
            <e:label for="ITEM_CLS" title="${form_USE_FLAG_N}"/>
            <e:field>
                <e:select id="USE_FLAG" name="USE_FLAG" value="${form.USE_FLAG}" options="${useFlagOptions}" width="${form_USE_FLAG_W}" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
                <e:inputHidden id="ITEM_CLS_CLICKED" name="ITEM_CLS_CLICKED"/>
                <e:inputHidden id="ITEM_CLS_TYPE_CLICKED" name="ITEM_CLS_TYPE_CLICKED"/>
            </e:field>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button label="${doSearch_N }" id="doSearch" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V }" data="${doSearch_A}"/>
            <c:if test="${ses.ctrlCd != null && ses.ctrlCd != '' }">
                <e:button label="${doSave_N }" id="doSave" onClick="doSave" disabled="${doSave_D }" visible="${doSave_V }" data="${doSave_A}"/>
                <e:button label="${doDelete_N }" id="doDelete" onClick="doDelete" disabled="${doDelete_D }" visible="${doDelete_V }" data="${doDelete_A}"/>
            </c:if>
        </e:buttonBar>

        <e:panel id="radioPanel" height="100%" width="100%">
            <e:panel id="pn1" width="33%">
                <e:radio id="radio1" name="radio" label="${form_RADIO1_N }" required="${form_RADIO1_R }" readOnly="${form_RADIO1_RO }"/>
            </e:panel>
            <e:panel id="pn1_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn2" width="32%">
                <e:radio id="radio2" name="radio" label="${form_RADIO2_N }" required="${form_RADIO2_R }" readOnly="${form_RADIO2_RO }"/>
            </e:panel>
            <e:panel id="pn2_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn3" width="32%">
                <e:radio id="radio3" name="radio" label="${form_RADIO3_N }" required="${form_RADIO3_R }" readOnly="${form_RADIO3_RO }"/>
            </e:panel>
        </e:panel>
        <e:panel id="gridPanel" height="100%" width="100%">
            <e:panel id="pn11" height="fit" width="33%">
                <e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
            </e:panel>
            <e:panel id="pn11_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn22" height="fit" width="32%">
                <e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}"/>
            </e:panel>
            <e:panel id="pn22_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn33" height="fit" width="32%">
                <e:gridPanel gridType="${_gridType}" id="grid3" name="grid3" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid3.gridColData}"/>
            </e:panel>

        </e:panel>
    </e:window>
</e:ui>