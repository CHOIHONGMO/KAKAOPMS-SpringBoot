<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid1;
        var grid2;
        var grid3;
        var grid4;
        var itemList;
        var parentClass;
        var saveClassCode;
        var init;
        var baseUrl = "/evermp/IM04/IM0401/";

        var activeGrid1RowId;
        var activeGrid2RowId;
        var activeGrid3RowId;
        var activeGrid4RowId;

        function init() {

            grid1 = EVF.C("grid1");
            grid2 = EVF.C("grid2");
            grid3 = EVF.C("grid3");
            grid4 = EVF.C("grid4");

            grid1.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio1").setChecked(true);

                if(colId == 'ITEM_CLS1') {
                	activeGrid1RowId = rowId;
                    onCellClick1(colId, rowId);
                }
            });
            grid2.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio2").setChecked(true);

                if(colId == 'ITEM_CLS2') {
                	activeGrid2RowId = rowId;
                    onCellClick2(colId, rowId);
                }
            });
            grid3.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio3").setChecked(true);

                if(colId == 'ITEM_CLS3') {
                    activeGrid3RowId = rowId;
                    onCellClick3(colId, rowId);
                }
            });
            grid4.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                EVF.C("radio4").setChecked(true);

                if(colId == 'ITEM_CLS4') {
                    activeGrid4RowId = rowId;
                    onCellClick4(colId, rowId);
                }
            });

            grid1.addRowEvent(function() {
                grid1.addRow([
                    {"INSERT_FLAG": "I",
                        "ITEM_CLS_TYPE": "C1",
                        "ITEM_CLS2": "*",
                        "ITEM_CLS3": "*",
                        "ITEM_CLS4": "*",
                        "GATE_CD":"${ses.gateCd}",
                        "BUYER_CD":EVF.C("BUYER_CD").getValue(),
                        "USE_FLAG":"1",
                        "ITEM_CLS_RMK": ""}
                ]);
            });

            grid1.delRowEvent(function() {

                if(!grid1.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var delCnt1 = 0;
                var selRowId = grid1.jsonToArray(grid1.getSelRowId()).value;
              	for (var i = selRowId.length -1; i >= 0; i--) {
                    if(grid1.getCellValue(selRowId[i],'INSERT_FLAG') =="I"){
                    	grid1.delRow(selRowId[i]);
                    } else {
                    	delCnt1++;
                    }
                }

                if(delCnt1 > 0){
                	return alert("${msg.M0145}");
                }
            });

            grid2.addRowEvent(function() {

                if (grid1.getRowCount() > 0 && activeGrid1RowId != -1 && grid1.getCellValue(activeGrid1RowId, "ITEM_CLS1") != null) {
                    if (grid1.getCellValue(activeGrid1RowId, "INSERT_FLAG") == "I") {
                        alert("${IM04_001_0002}");
                        return;
                    }

                    grid2.addRow([{
                        "INSERT_FLAG": "I",
                        "ITEM_CLS_TYPE": "C2",
                        "ITEM_CLS1": grid1.getCellValue(activeGrid1RowId, "ITEM_CLS1"),
                        "ITEM_CLS3": "*",
                        "ITEM_CLS4": "*",
                        "GATE_CD": grid1.getCellValue(activeGrid1RowId, "GATE_CD"),
                        "BUYER_CD": grid1.getCellValue(activeGrid1RowId, "BUYER_CD"),
                        "USE_FLAG":"1",
                        "ITEM_CLS_RMK": ""
                    }]);

                    parentClass = "1";
                    saveClassCode = grid2.getCellValue(activeGrid2RowId, "ITEM_CLS1");

                } else {
                    alert("${IM04_001_0002}");

                }
            });

            grid2.delRowEvent(function() {

                if(!grid2.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var delCnt2 = 0;
                var selRowId = grid2.jsonToArray(grid2.getSelRowId()).value;
              	for (var i = selRowId.length -1; i >= 0; i--) {
                    if(grid2.getCellValue(selRowId[i],'INSERT_FLAG') =="I"){
                    	grid2.delRow(selRowId[i]);
                    } else {
                    	delCnt2++;
                    }
                }

                if(delCnt2 > 0){
                	return alert("${msg.M0145}");
                }
            });

            grid3.addRowEvent(function() {

                if (grid2.getRowCount() > 0 && activeGrid2RowId != -1 && grid2.getCellValue(activeGrid2RowId, "ITEM_CLS2") != null) {
                    if (grid2.getCellValue(activeGrid2RowId, "INSERT_FLAG") == "I") {
                        alert("${IM04_001_0003}");
                        return;
                    }

                    grid3.addRow([{
                        "INSERT_FLAG": "I",
                        "ITEM_CLS_TYPE": "C3",
                        "ITEM_CLS1": grid1.getCellValue(activeGrid1RowId, "ITEM_CLS1"),
                        "ITEM_CLS2": grid2.getCellValue(activeGrid2RowId, "ITEM_CLS2"),
                        <%--"ITEM_CLS3": ('${keyRule}' === 'auto' ? "." : ""),--%>
                        "ITEM_CLS4": "*",
                        "GATE_CD": grid1.getCellValue(activeGrid1RowId, "GATE_CD"),
                        "BUYER_CD": grid1.getCellValue(activeGrid1RowId, "BUYER_CD"),
                        "USE_FLAG":"1",
                        "ITEM_CLS_RMK": ""
                    }]);

                    parentClass = "2";
                    saveClassCode = grid3.getCellValue("ITEM_CLS2", activeGrid3RowId);

                } else {
                    alert("${IM04_001_0003}");

                }

            });

            grid3.delRowEvent(function() {

                if(!grid3.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var delCnt3 = 0;
                var selRowId = grid3.jsonToArray(grid3.getSelRowId()).value;
              	for (var i = selRowId.length -1; i >= 0; i--) {
                    if(grid3.getCellValue(selRowId[i],'INSERT_FLAG') =="I"){
                    	grid3.delRow(selRowId[i]);
                    } else {
                    	delCnt3++;
                    }
                }

                if(delCnt3 > 0){
                	return alert("${msg.M0145}");
                }
            });

            grid4.addRowEvent(function() {

                if (grid3.getRowCount() > 0 && activeGrid3RowId != -1 && grid3.getCellValue(activeGrid3RowId, "ITEM_CLS3") != null) {

                    if (grid3.getCellValue(activeGrid3RowId, "INSERT_FLAG") == "I") {
                        alert("${IM04_001_0004}");
                        return;
                    }

                    grid4.addRow([{
                        "INSERT_FLAG": "I",
                        "ITEM_CLS_TYPE": "C4",
                        "ITEM_CLS1": grid1.getCellValue(activeGrid1RowId, "ITEM_CLS1"),
                        "ITEM_CLS2": grid2.getCellValue(activeGrid2RowId, "ITEM_CLS2"),
                        "ITEM_CLS3": grid3.getCellValue(activeGrid3RowId, "ITEM_CLS3"),
                        <%--"ITEM_CLS4": ('${keyRule}' === 'auto' ? "." : ""),--%>
                        "GATE_CD": grid1.getCellValue(activeGrid1RowId, "GATE_CD"),
                        "BUYER_CD": grid1.getCellValue(activeGrid1RowId, "BUYER_CD"),
                        "USE_FLAG":"1",
                        "ITEM_CLS_RMK": ""
                    }]);

                    parentClass = "3";
                    saveClassCode = grid4.getCellValue("ITEM_CLS3", activeGrid4RowId);

                } else {
                    alert("${IM04_001_0004}");

                }
            });

            grid4.delRowEvent(function() {

                if(!grid4.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var delCnt4 = 0;
                var selRowId = grid4.jsonToArray(grid4.getSelRowId()).value;
              	for (var i = selRowId.length -1; i >= 0; i--) {
                    if(grid4.getCellValue(selRowId[i],'INSERT_FLAG') =="I"){
                    	grid4.delRow(selRowId[i]);
                    } else {
                    	delCnt4++;
                    }
                }

                if(delCnt4 > 0){
                	return alert("${msg.M0145}");
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
            grid4.excelExportEvent(excelProp);

            grid1.setProperty('shrinkToFit', true);
            grid2.setProperty('shrinkToFit', true);
            grid3.setProperty('shrinkToFit', true);
            grid4.setProperty('shrinkToFit', true);

            setLinkStyle();
			doSearch();

        }

        function setLinkStyle() {

            grid1.setColFontColor("ITEM_CLS1", '#000DFF');
            grid1.setColFontUnderline("ITEM_CLS1", true);

            grid2.setColFontColor("ITEM_CLS2", '#000DFF');
            grid2.setColFontUnderline("ITEM_CLS2", true);

            grid3.setColFontColor("ITEM_CLS3", '#000DFF');
            grid3.setColFontUnderline("ITEM_CLS3", true);

            grid4.setColFontColor("ITEM_CLS4", '#000DFF');
            grid4.setColFontUnderline("ITEM_CLS4", true);
        }

        function onCellClick1(colId, rowId) {
            var gridClass = grid1;
            if (colId === "ITEM_CLS1" && gridClass.getCellValue(rowId, "INSERT_FLAG") !== "I") {

                grid2.checkAll(true);
                grid2.delRow();
                grid3.checkAll(true);
                grid3.delRow();
                grid4.checkAll(true);
                grid4.delRow();

                EVF.C("ITEM_CLS_CLICKED").setValue(grid1.getCellValue(rowId, "ITEM_CLS1"));
                EVF.C("ITEM_CLS_TYPE_CLICKED").setValue(grid1.getCellValue(rowId, "ITEM_CLS_TYPE"));
                var store = new EVF.Store();
                store.setGrid([grid2, grid3, grid4]);
                store.getGridData(grid2, 'all');
                store.load(baseUrl + "IM04_001/im04001_selectChildClass", function () {
                    /* if(grid2.getRowCount() != 0) {
                        EVF.C("radio2").setChecked(true);
                        activeGrid2RowId = 0;
                        onCellClick2('ITEM_CLS2', 0); //220726
                    } */
                }, false);
            }
        }

        function onCellClick2(colId, rowId) {
            var gridClass = grid2;
            if (colId === "ITEM_CLS2" && gridClass.getCellValue(rowId, "INSERT_FLAG") !== "I") {

                grid3.checkAll(true);
                grid3.delRow();
                grid4.checkAll(true);
                grid4.delRow();

                EVF.C("ITEM_CLS_CLICKED").setValue(grid2.getCellValue(rowId, "ITEM_CLS2"));
                EVF.C("ITEM_CLS_TYPE_CLICKED").setValue(grid2.getCellValue(rowId, "ITEM_CLS_TYPE"));
                var store = new EVF.Store();
                store.setGrid([grid3]);
                store.getGridData(grid3, 'all');
                store.load(baseUrl + "IM04_001/im04001_selectChildClass", function () {
                   /* if(grid3.getRowCount() != 0) {
                        EVF.C("radio3").setChecked(true);
                        activeGrid3RowId = 0;
                        onCellClick3('ITEM_CLS3', 0); //220726
                   } */
                }, false);
            }
        }

        function onCellClick3(colId, rowId) {
            var gridClass = grid3;
            if (colId === "ITEM_CLS3" && gridClass.getCellValue(rowId, "INSERT_FLAG") !== "I") {

                EVF.C("ITEM_CLS_CLICKED").setValue(grid3.getCellValue(rowId, "ITEM_CLS3"));
                EVF.C("ITEM_CLS_TYPE_CLICKED").setValue(grid3.getCellValue(rowId, "ITEM_CLS_TYPE"));
                var store = new EVF.Store();
                store.setGrid([grid4]);
                store.getGridData(grid4, 'all');
                store.load(baseUrl + "IM04_001/im04001_selectChildClass", function () {
                    /* if(grid4.getRowCount() != 0) {
                        EVF.C("radio4").setChecked(true);
                        activeGrid4RowId = 0;
                        onCellClick4('ITEM_CLS4', 0); //220726
                    } */
                }, false);
            }
        }

        function onCellClick4(colId, rowId) {
            var gridClass = grid4;
        }

        function doSearch() {

            if(EVF.C("USE_FLAG").getValue()=="0" || EVF.C("ITEM_CLS_NM").getValue()!=""){ // ITEM_CLS_NM / ITEM_CLS_RMK
                init ="N"
            }else{
                init ="Y";
                EVF.V("ITEM_CLS","C1");
            }

            var store = new EVF.Store();
            store.load(baseUrl + "IM04_001/im04001_selectItemClass", function () {
                itemList = JSON.parse(this.getParameter("refItemList"));
                //console.log("==> " + JSON.stringify(itemList));
                if (itemList.length > 0) {
                    if (init == "Y") {
                        EVF.V("ITEM_CLS", ""); //220726
                    }
                    renderItemClass();
                } else {
                    alert("${msg.M0002 }");
                    grid1.checkAll(true);
                    grid2.checkAll(true);
                    grid3.checkAll(true);
                    grid4.checkAll(true);
                    grid1.delRow();
                    grid2.delRow();
                    grid3.delRow();
                    grid4.delRow();

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
            var grid4Data = [];

            grid1.checkAll(true);
            grid2.checkAll(true);
            grid3.checkAll(true);
            grid4.checkAll(true);
            grid1.delRow();
            grid2.delRow();
            grid3.delRow();
            grid4.delRow();

            for (var i = 0, length = itemList.length; i < length; i++) {

                var itemClassType = itemList[i].ITEM_CLS_TYPE;
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
                    case "C4":
                        insertClass(grid4Data, i);
                        break;
                }
            }

            grid1.setGridData(grid1Data);
            grid2.setGridData(grid2Data);
            grid3.setGridData(grid3Data);
            grid4.setGridData(grid4Data);

            if (grid1.getRowCount() > 0) {

                if(EVF.C("USE_FLAG").getValue()=="0" || EVF.C("ITEM_CLS_NM").getValue()!=""){ // ITEM_CLS_NM / ITEM_CLS_RMK

                }else{
                	EVF.C("radio1").setChecked(true);
                	grid2.checkAll(true);
                    grid3.checkAll(true);
                    grid4.checkAll(true);
                    grid2.delRow();
                    grid3.delRow();
                    grid4.delRow();
                	/* EVF.C("radio1").setChecked(true);
                	activeGrid1RowId = 0;
                	onCellClick1('ITEM_CLS1', 0);
                    if (EVF.C("ITEM_CLS").getValue() != "") {
                    	searchAfter(itemClass);
                    } */
                }
            }
        }

        function searchAfter(itemClass) {
            if(itemClass=='C1'){
                EVF.C("radio1").setChecked(true);
                activeGrid1RowId = 0;
                onCellClick1('ITEM_CLS1', 0);
            }else if(itemClass=='C2'){
                EVF.C("radio2").setChecked(true);
                activeGrid2RowId = 0;
                onCellClick2('ITEM_CLS2', 0);
            }else if(itemClass=='C3'){
                EVF.C("radio3").setChecked(true);
                activeGrid3RowId = 0;
                onCellClick3('ITEM_CLS3', 0);
            }else if(itemClass=='C4'){
                EVF.C("radio4").setChecked(true);
                activeGrid4RowId = 0;
                onCellClick4('ITEM_CLS4', 0);
            }
        }
        function insertClass(gridData, fromIndex) {
            gridData.push({
                ITEM_CLS1 : itemList[fromIndex].ITEM_CLS1
                , ITEM_CLS_ORI: itemList[fromIndex].ITEM_CLS_ORI //itemList[fromIndex].ITEM_CLS + itemList[fromIndex].ITEM_CLS_TYPE.substring(1, 2)
                , ITEM_CLS2: itemList[fromIndex].ITEM_CLS2
                , ITEM_CLS3: itemList[fromIndex].ITEM_CLS3
                , ITEM_CLS4: itemList[fromIndex].ITEM_CLS4
                , ITEM_CLS_NM: itemList[fromIndex].ITEM_CLS_NM
                , ITEM_CLS_TYPE: itemList[fromIndex].ITEM_CLS_TYPE
                , USE_FLAG: itemList[fromIndex].USE_FLAG
                , SORT_SQ: itemList[fromIndex].SORT_SQ
                , GATE_CD: itemList[fromIndex].GATE_CD
                , BUYER_CD: itemList[fromIndex].BUYER_CD
                , INSERT_FLAG: 'U'
                , ITEM_CLS_RMK: itemList[fromIndex].ITEM_CLS_RMK
            });
        }

        function getActiveGrid() {
            var radioArray = ["radio1", "radio2", "radio3", "radio4"];
            var gridArray = ["grid1", "grid2", "grid3", "grid4"];
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
                alert("${IM04_001_0001}");
                return;
            }

            var activeGrid = EVF.C(activeGridId);

            if(!activeGrid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            <%-- 대분류를 제외한 모든 컬럼의 코드가 자동생성(auto)일 때만 유효성을 체크한다. --%>
            if (getActiveRadio() !== "radio1" && "${keyRule}" === "auto") {

                var selectedRowIds = activeGrid.getSelRowId();
                for(var i in selectedRowIds) {
                    var selRowId = selectedRowIds[i];
                    var colValue = activeGrid.getCellValue(selRowId, 'ITEM_CLS_NM');
                    if(EVF.isEmpty(colValue)) {
                        return alert('${IM04_001_0007}'); <%-- 코드명을 입력하시기 바랍니다. --%>
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
                store.load(baseUrl + "IM04_001/im04001_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
                });

            } else if (getActiveRadio() == "radio2") {
                parentClass = "1";
                saveClassCode = grid1.getCellValue(activeGrid1RowId, "ITEM_CLS1");
                var saveClassRow = activeGrid1RowId;

                store.setParameter("CLASS_TO_SAVE", "C2");
                store.load(baseUrl + "IM04_001/im04001_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
//	            onCellClick1("ITEM_CLS1", saveClassRow);
                });

            } else if (getActiveRadio() == "radio3") {
                parentClass = "2";
                saveClassCode = grid2.getCellValue(activeGrid2RowId, "ITEM_CLS2");
                var saveClassRow = activeGrid2RowId;

                store.setParameter("CLASS_TO_SAVE", "C3");
                store.load(baseUrl + "IM04_001/im04001_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
                    //onCellClick2("ITEM_CLS2", saveClassRow);
                });

            } else if (getActiveRadio() == "radio4") {
                parentClass = "3";
                saveClassCode = grid3.getCellValue(activeGrid3RowId, "ITEM_CLS3");
                var saveClassRow = activeGrid3RowId;

                store.setParameter("CLASS_TO_SAVE", "C4");
                store.load(baseUrl + "IM04_001/im04001_saveItemClass", function () {
                    alert(this.getResponseMessage());
                    doSearch();
                    //onCellClick3("ITEM_CLS3", saveClassRow);
                });
            }
        }

        function doDelete() {

            var activeGridId = getActiveGrid();
            if (activeGridId == undefined) {
                alert("${IM04_001_0001}");
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
            } else if (getActiveRadio() == "radio4") {
                store.setParameter("CLASS_TO_DELETE", "C4");
            }

            store.setGrid([activeGrid]);
            store.getGridData(activeGrid, 'sel');
            store.load(baseUrl + "IM04_001/im04001_deleteItemClass", function () {

                if(this.getResponseMessage()=="X"){
                    alert("${IM04_001_0005}");
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
                            grid4.checkAll(true);
                            grid4.delRow();
                            break;
                        case 'grid2':
                            grid3.checkAll(true);
                            grid3.delRow();
                            grid4.checkAll(true);
                            grid4.delRow();
                            break;
                        case 'grid3':
                            grid4.checkAll(true);
                            grid4.delRow();
                            break;
                    }
                }
            });
        }

        // 속성맵핑
        function doAttrMap() {

        	if( grid4.getSelRowCount() == 0 || grid4.getSelRowCount() > 1 ) {
        		return alert("${IM04_001_0006}");
        	}

        	var rowIds = grid4.getSelRowId();
    	  	if (grid4.getCellValue(rowIds[0],"INSERT_FLAG") != 'U'){
    		  	return alert("${IM04_001_0007}");
    	  	}

        	var param = {
         			ITEM_CLS1 : grid4.getCellValue(rowIds[0],"ITEM_CLS1"),
         			ITEM_CLS2 : grid4.getCellValue(rowIds[0],"ITEM_CLS2"),
         			ITEM_CLS3 : grid4.getCellValue(rowIds[0],"ITEM_CLS3"),
         			ITEM_CLS4 : grid4.getCellValue(rowIds[0],"ITEM_CLS4"),
         			ITEM_PATH_NM : grid4.getCellValue(rowIds[0],"ITEM_PATH_NM"),
         			ModalPopup : true,
         			detailView : false
         		};

        	everPopup.openPopupByScreenId("IM04_007", 700, 500, param);
        }

        function setBuyer(data) {
            EVF.V('BUYER_CD', data.CUST_CD);
            EVF.V('BUYER_NM', data.CUST_NM);
        }

    </script>

    <e:window id="IM04_001" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <%--
            <e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
            <e:field>
                <e:inputText id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" width="0" maxLength="${form_BUYER_CD_M}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" />
                <e:search id="BUYER_NM" name="BUYER_NM" value="${ses.companyNm}" width="100%" maxLength="${form_BUYER_NM_M}" onIconClick="${form_BUYER_NM_RO ? 'everCommon.blank' : 'getBuyer'}" popupCode="SP0067.setBuyer" disabled="${form_BUYER_NM_D}" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}" />
            </e:field>
            --%>
            <e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
			<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" value="${ses.manageCd}" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
			</e:field>
            <e:label for="ITEM_CLS" title="${form_ITEM_CLS_NM_N}"/> <!-- ${form_ITEM_CLS_NM_N} ${form_ITEM_CLS_RMK_N}-->
            <e:field>
                <e:select id="ITEM_CLS" name="ITEM_CLS" value="${form.ITEM_CLS}" options="${itemClsOptions}" width="40%" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" usePlaceHolder="false" />
                <e:inputText id="ITEM_CLS_NM" name="ITEM_CLS_NM" width="60%" maxLength="${form_ITEM_CLS_NM_M }" required="${form_ITEM_CLS_NM_R }" readOnly="${form_ITEM_CLS_NM_RO }" disabled="${form_ITEM_CLS_NM_D}" visible="${form_ITEM_CLS_NM_V}"/>
                <%-- <e:inputText id="ITEM_CLS_RMK" name="ITEM_CLS_RMK" width="60%" maxLength="${form_ITEM_CLS_RMK_M}" disabled="${form_ITEM_CLS_RMK_D}" readOnly="${form_ITEM_CLS_RMK_RO}" required="${form_ITEM_CLS_RMK_R}" visible="${form_ITEM_CLS_RMK_V}" value="" /> --%>
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
<%--                 <e:button id="doAttrMap" name="doAttrMap" label="${doAttrMap_N}" onClick="doAttrMap" disabled="${doAttrMap_D}" visible="${doAttrMap_V}"/> --%>
            </c:if>
        </e:buttonBar>

        <%-- <e:panel id="radioPanel" height="100%" width="100%">
            <e:panel id="pn1" width="24%">
                <e:radio id="radio1" name="radio" label="${form_RADIO1_N }" required="${form_RADIO1_R }" readOnly="${form_RADIO1_RO }"/>
            </e:panel>
            <e:panel id="pn1_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn2" width="24%">
                <e:radio id="radio2" name="radio" label="${form_RADIO2_N }" required="${form_RADIO2_R }" readOnly="${form_RADIO2_RO }"/>
            </e:panel>
            <e:panel id="pn2_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn3" width="24%">
                <e:radio id="radio3" name="radio" label="${form_RADIO3_N }" required="${form_RADIO3_R }" readOnly="${form_RADIO3_RO }"/>
            </e:panel>
            <e:panel id="pn3_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn4" width="24%">
                <e:radio id="radio4" name="radio" label="${form_RADIO4_N }" required="${form_RADIO4_R }" readOnly="${form_RADIO4_RO }"/>
            </e:panel>
        </e:panel> --%>
<%--         <e:panel id="gridPanel" height="100%" width="100%">
            <e:panel id="pn11" height="fit" width="24%">
                <e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
            </e:panel>
            <e:panel id="pn11_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn22" height="fit" width="24%">
                <e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}"/>
            </e:panel>
            <e:panel id="pn22_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn33" height="fit" width="24%">
                <e:gridPanel gridType="${_gridType}" id="grid3" name="grid3" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid3.gridColData}"/>
            </e:panel>
            <e:panel id="pn33_1" width="1%">&nbsp;</e:panel>
            <e:panel id="pn44" height="fit" width="25%">
                <e:gridPanel gridType="${_gridType}" id="grid4" name="grid4" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid4.gridColData}"/>
            </e:panel>
        </e:panel> --%>

		<!-- 22.07.26 gridPanel 수정 -->
        <e:panel id="gridPanel_1" height="500px" width="50%">
		    <e:radio id="radio1" name="radio" label="${form_RADIO1_N }" required="${form_RADIO1_R }" readOnly="${form_RADIO1_RO }"/>
		    <e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="450px" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}" />
		</e:panel>
		<e:panel id="nullPanel1" height="500px" width="1%">&nbsp;</e:panel>
		<e:panel id="gridPanel_2" height="500px" width="49%">
		    <e:radio id="radio2" name="radio" label="${form_RADIO2_N }" required="${form_RADIO2_R }" readOnly="${form_RADIO2_RO }"/>
		    <e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="450px" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}"/>
		</e:panel>

		<e:panel id="gridPanel_3" height="fit" width="50%">
		    <e:radio id="radio3" name="radio" label="${form_RADIO3_N }" required="${form_RADIO3_R }" readOnly="${form_RADIO3_RO }"/>
		    <e:gridPanel gridType="${_gridType}" id="grid3" name="grid3" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid3.gridColData}"/>
		</e:panel>
		<e:panel id="nullPanel2" height="fit" width="1%">&nbsp;</e:panel>
			<e:panel id="gridPanel_4" height="fit" width="49%">
		    <e:radio id="radio4" name="radio" label="${form_RADIO4_N }" required="${form_RADIO4_R }" readOnly="${form_RADIO4_RO }"/>
    	<e:gridPanel gridType="${_gridType}" id="grid4" name="grid4" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid4.gridColData}"/>
	</e:panel>



    </e:window>
</e:ui>