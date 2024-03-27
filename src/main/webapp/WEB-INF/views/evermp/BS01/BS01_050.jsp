<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var gridH, gridD;
        var baseUrl = "/evermp/BS01/BS0102/";
        var eventRowId = 0;
        var G_CUST_CD;
        var G_CUST_NM;

        function init(){
            gridH = EVF.C("gridH");
            gridD = EVF.C("gridD");

            gridH.setProperty('shrinkToFit', false);
            gridH.setProperty('multiSelect', false);

            gridD.setProperty('shrinkToFit', false);




            if ('${ses.userType}' != 'C') {
				EVF.C("CUST_CD_L").setDisabled(true);
				EVF.C("CUST_NM_L").setDisabled(true);
				EVF.C("CUST_CD_L").setValue('${ses.companyCd}');
				EVF.C("CUST_NM_L").setValue('${ses.companyNm}');
            }



            gridH.cellClickEvent(function(rowId, colName, value) {
                if(colName === "CUST_NM") {

                    var CUST_CD = gridH.getCellValue(rowId, "CUST_CD");
                    var CUST_NM = gridH.getCellValue(rowId, "CUST_NM");

                    G_CUST_CD = CUST_CD;
                    G_CUST_NM = CUST_NM;
                    EVF.C("CUST_CD_R").setValue(CUST_CD);
                    EVF.C("CUST_NM_R").setValue(CUST_NM);

                    doSearchD(CUST_CD);
                }
            });

            gridD.cellClickEvent(function(rowId, colName, value) {
                var param;

                eventRowId = rowId;

                if (colName == "CUST_CD") {
                    param = {
                        CUST_CD: gridD.getCellValue(rowId, "CUST_CD"),
                        detailView: false,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }

                if (colName == "DELY_ZIP_CD") {
                    param = {
                        callBackFunction: "setGridZipCode",
                        modalYn: false
                    };
                    //everPopup.openWindowPopup(url, 700, 600, param);
                    everPopup.jusoPop("/common/code/BADV_020/view", param);
                }

                if (colName == "DELY_RMK") {
                    param = {
                        title : "요청사항",
                        message : gridD.getCellValue(rowId, "DELY_RMK"),
                        callbackFunction : "setGridDelyText",
                        detailView : false,
                        rowId : rowId
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
                }

                if (colName == "PLANT_NM") {
	                var param = {
                        callBackFunction: "_setPlant",
                        rowid: rowId,
                        custCd: gridD.getCellValue(rowId, 'CUST_CD')
                    };
                    everPopup.openCommonPopup(param, 'SP0901');
                }
            });

            gridD.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {
                if(value != oldValue) {
                    if(colIdx == "SEQ") {
                        var allRowId = gridD.getAllRowId();
                        for(var i in allRowId) {
                            var rowId = allRowId[i];

                            if(rowIdx != rowId) {
                                if(value == gridD.getCellValue(rowId, colIdx)) {
                                    gridD.setCellValue(rowIdx, colIdx, oldValue);
                                    return alert("${BS01_050_004}");
                                }
                            }
                        }
                    }
                }
            });

            gridH.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridD.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridD.addRowEvent(function() {
                var CUST_CD_R = EVF.C("CUST_CD_R").getValue();
                var CUST_NM_R = EVF.C("CUST_NM_R").getValue();

                if (CUST_CD_R == "") {
                    alert("${BS01_050_001 }");
                    return;
                }

                var addParam = [{
                    CUST_CD: CUST_CD_R,
                    CUST_NM: CUST_NM_R,
                    USE_FLAG: "1"
                }];

                var rowIdx = gridD.addRow(addParam);
                gridD.setCellReadOnly(rowIdx, "SEQ", false);
            });

            gridD.delRowEvent(function() {
                if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var delCnt = 0;
                var rowIds = gridD.getSelRowId();
                for(var i = rowIds.length -1; i >= 0; i--) {
                    if(!EVF.isEmpty(gridD.getCellValue(rowIds[i], "SEQ"))) {
                        delCnt++;
                    } else {
                        gridD.delRow(rowIds[i]);
                    }
                }
                if(delCnt > 0) {
                    doDeleteDT();
                }
            });

            gridD._gvo.setColumnProperty("SEQ", "dynamicStyles", [{
                criteria: "(value['MOD_USER_NM'] = null)",
                styles: {figureBackground: "#99AAFF", figureName: "leftTop", iconLocation: "left", figureSize: "7", paddingRight: 6}
            }]);


            doSearch();
        }




        function _setPlant(plantInfo) {
        	gridD.setCellValue(plantInfo.rowid, 'PLANT_CD', plantInfo['PLANT_CD']);
        	gridD.setCellValue(plantInfo.rowid, 'PLANT_NM', plantInfo['PLANT_NM']);
        }





        function setGridZipCode(data) {
            if (data.ZIP_CD != "") {
                gridD.setCellValue(eventRowId, "DELY_ZIP_CD", data.ZIP_CD_5);
                gridD.setCellValue(eventRowId, 'DELY_ADDR_1', data.ADDR1);
                gridD.setCellValue(eventRowId, 'DELY_ADDR_2', data.ADDR2);
                //grid.setCellValue(eventRowId, 'DELY_ADDR_2', '');
            }
        }

        function setGridDelyText(data){
            gridD.setCellValue(data.rowId, 'DELY_RMK', data.message);
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            //everPopup.openCommonPopup(param, 'SP0067');
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD_L").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM_L").setValue(dataJsonArray.CUST_NM);

            //chgCustCd();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridH]);
            store.load(baseUrl + "bs01050_doSearch", function () {
                if(gridH.getRowCount() === 0) {
                    //return alert('${msg.M0002}'); CO001113
                }
            });
        }

        function doSearchDC(){
            var CUST_CD = EVF.C('CUST_CD_R').getValue();
            doSearchD(CUST_CD);
        }
        // 고객사 배송지조회
        function doSearchD(CUST_CD) {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridD]);
            store.setParameter("CUST_CD", CUST_CD);
            store.setParameter("USE_FLAG", EVF.C('USE_FLAG').getValue());
            store.setParameter("DELY_NM", EVF.C('DELY_NM').getValue());
            store.load(baseUrl + "bs01050_doSearchD", function () {
                if(gridD.getRowCount() === 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // 고객사배송지 저장
        function doSaveDT() {
            var store = new EVF.Store();

            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!gridD.validate().flag) { return alert(gridD.validate().msg); }

            if(!confirm("${BS01_050_002}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load(baseUrl + "bs01050_doSaveDT", function() {
                alert(this.getResponseMessage());
                //doSearch();
                doSearchD(EVF.C('CUST_CD_R').getValue());
            });
        }

        // 고객사배송지삭제
        function doDeleteDT() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm("${msg.M0013}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load(baseUrl + "bs01050_doDeleteDT", function() {
                alert(this.getResponseMessage());
                //doSearch();
                doSearchD(EVF.C('CUST_CD_R').getValue());
            });
        }


        function chgCustCd() {
            var store = new EVF.Store;
            store.load('/evermp/SY01/SY0101/' + '/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
            	}
            });

            doSearch();
        }


    </script>
    <e:window id="BS01_050" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="panL" width="39%" height="100%">
            <e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="1" useTitleBar="false" onEnter="doSearch">
                <e:row>
                    <e:label for="CUST_CD_L" title="${formL_CUST_CD_N}"/>
                    <e:field>
                        <e:search id="CUST_CD_L" name="CUST_CD_L" value="" width="40%" maxLength="${formL_CUST_CD_M}" onIconClick="searchCustCd" disabled="${formL_CUST_CD_D}" readOnly="${formL_CUST_CD_RO}" required="${formL_CUST_CD_R}" />
                        <e:inputText id="CUST_NM_L" name="CUST_NM_L" value="" width="60%" maxLength="${formL_CUST_NM_M}" disabled="${formL_CUST_NM_D}" readOnly="${formL_CUST_NM_RO}" required="${formL_CUST_NM_R}" />
                    </e:field>


                </e:row>
            </e:searchPanel>

            <e:buttonBar align="right" width="100%">
                <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
            </e:buttonBar>

            <e:gridPanel id="gridH" name="gridH" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridH.gridColData}" />
        </e:panel>

        <e:panel id="panBlank" width="1%">&nbsp;</e:panel>

        <e:panel id="panR" width="60%" height="100%">
            <e:searchPanel id="formR" title="" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
                <e:row>
                    <e:label for="DELY_NM" title="${formR_DELY_NM_N}" />
                    <e:field>
                    <e:inputText id="DELY_NM" name="DELY_NM" value="" onEnter="doSearchDC" width="${formR_DELY_NM_W}" maxLength="${formR_DELY_NM_M}" disabled="${formR_DELY_NM_D}" readOnly="${formR_DELY_NM_RO}" required="${formR_DELY_NM_R}" />
					<e:inputHidden id="CUST_CD_R" name="CUST_CD_R"/>
					<e:inputHidden id="CUST_NM_R" name="CUST_NM_R"/>
					</e:field>
                    <e:label for="USE_FLAG" title="${formR_USE_FLAG_N }" />
                    <e:field>
                        <e:select id="USE_FLAG" name="USE_FLAG" value="" options="${useFlagOptions }" onChange="doSearchDC" readOnly="${formR_USE_FLAG_RO }" width="${formR_USE_FLAG_W }" required="${formR_USE_FLAG_R }" disabled="${formR_USE_FLAG_D }" />
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar align="right" width="100%">
                <e:button id="SaveDT" name="SaveDT" label="${SaveDT_N}" onClick="doSaveDT" disabled="${SaveDT_D}" visible="${SaveDT_V}"/>
                <e:button id="DeleteDT" name="DeleteDT" label="${DeleteDT_N}" onClick="doDeleteDT" disabled="${DeleteDT_D}" visible="${DeleteDT_V}"/>
            </e:buttonBar>

            <e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />
        </e:panel>
    </e:window>
</e:ui>