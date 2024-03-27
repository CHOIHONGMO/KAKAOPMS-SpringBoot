<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var gridH, gridD;
        var baseUrl = "/evermp/BS01/BS0102/";
        var eventRowId = 0;

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
				chgCustCd();
            }
















            gridH.cellClickEvent(function(rowId, colName, value) {
                if(colName === "CUST_NM") {

                    var CUST_CD = gridH.getCellValue(rowId, "CUST_CD");
                    var CUST_NM = gridH.getCellValue(rowId, "CUST_NM");
                    var PLANT_CD = gridH.getCellValue(rowId, "PLANT_CD");

                    EVF.C("CUST_CD_R").setValue(CUST_CD);
                    EVF.C("CUST_NM_R").setValue(CUST_NM);
                    EVF.C("PLANT_CD_R").setValue(PLANT_CD);
                    EVF.C("CUBL_NM").setValue('');
                    EVF.C("USE_FLAG").setValue('');



                    doSearchD(CUST_CD,PLANT_CD);
                }
            });

            gridD.cellClickEvent(function(rowId, colName, value) {
                eventRowId = rowId;
                if (colName == "CUST_CD") {
                    var param = {
                        'CUST_CD': gridD.getCellValue(rowId, 'CUST_CD'),
                        'detailView': false,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }

                if (colName == "CUBL_ZIP_CD") {
                    var url = '/common/code/BADV_020/view';
                    var param = {
                        callBackFunction : "setGridCublZipCode",
                        modalYn : false
                    };
                    //everPopup.openWindowPopup(url, 700, 600, param);
                    everPopup.jusoPop(url, param);
                }

                if (colName == "IRS_SUB_ZIP_CD") {
                    var url = '/common/code/BADV_020/view';
                    var param = {
                        callBackFunction : "setGridIrsSubZipCode",
                        modalYn : false
                    };
                    //everPopup.openWindowPopup(url, 700, 600, param);
                    everPopup.jusoPop(url, param);
                }

            });

            //doSearch();

            gridH.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridD.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridD.addRowEvent(function() {
                var CUST_CD_R = EVF.C('CUST_CD_R').getValue();
                var CUST_NM_R = EVF.C('CUST_NM_R').getValue();



                if (CUST_CD_R == "") {
                    alert("${BS01_060_001 }");
                    return;
                }

                var addParam = [{"CUST_CD": CUST_CD_R,"CUST_NM": CUST_NM_R,"USE_FLAG": '1',"PLANT_CD": EVF.C("PLANT_CD_R").getValue()}];

                var rowIdx = gridD.addRow(addParam);
//                gridD.setCellReadOnly(rowIdx, "CUBL_SQ", false);
            });

            gridD.delRowEvent(function() {

                var delCnt = 0;
                var rowIds = gridD.getSelRowId();

                for(var i = rowIds.length -1; i >= 0; i--) {
					if(gridD.getCellValue(rowIds[i], "CUBL_SQ")=='1') {
	                    return alert('${BS01_060_004}');
					}
                }
                if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }


                for(var i = rowIds.length -1; i >= 0; i--) {
                    if(!EVF.isEmpty(gridD.getCellValue(rowIds[i], "CUBL_SQ"))) {
                        delCnt++;
                    } else {
                        gridD.delRow(rowIds[i]);
                    }
                }
                if(delCnt > 0) {
                    doDeleteDT();
                }
            });

            gridD._gvo.setColumnProperty("CUBL_SQ", "dynamicStyles", [{
                criteria: "(value['MOD_USER_NM'] = null)",
                styles: {figureBackground: "#99AAFF", figureName: "leftTop", iconLocation: "left", figureSize: "7", paddingRight: 6}
            }]);

            EVF.C("DeleteDT").setVisible(false);
        }

        function setGridCublZipCode(data) {
            if (data.ZIP_CD != "") {
                gridD.setCellValue(eventRowId, "CUBL_ZIP_CD", data.ZIP_CD_5);
                gridD.setCellValue(eventRowId, 'CUBL_ADDR1', data.ADDR1);
                gridD.setCellValue(eventRowId, 'CUBL_ADDR2', data.ADDR2);
                //grid.setCellValue(eventRowId, 'DELY_ADDR_2', '');
            }
        }

        function setGridIrsSubZipCode(data) {
            if (data.ZIP_CD != "") {
                gridD.setCellValue(eventRowId, "IRS_SUB_ZIP_CD", data.ZIP_CD_5);
                gridD.setCellValue(eventRowId, 'IRS_SUB_ADDR', data.ADDR1+" "+data.ADDR2);
            }
        }


        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD_L").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM_L").setValue(dataJsonArray.CUST_NM);
            chgCustCd();


        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridH]);
            store.load(baseUrl + "bs01060_doSearch", function () {
                if(gridH.getRowCount() === 0) {
                    //return alert('${msg.M0002}');
                }
            });
        }

        function doSearchDC(){
            var CUST_CD = EVF.C('CUST_CD_R').getValue();
            var PLANT_CD = EVF.C('PLANT_CD_R').getValue();

            var USE_FLAG = EVF.C('USE_FLAG').getValue();

            doSearchD(CUST_CD,PLANT_CD,USE_FLAG);
        }
        // 고객사 청구지조회
        function doSearchD(CUST_CD,PLANT_CD,USE_FLAG) {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([gridD]);
            store.setParameter("CUST_CD", CUST_CD);
            store.setParameter("PLANT_CD", EVF.C('PLANT_CD_R').getValue());
            store.setParameter("USE_FLAG", EVF.C('USE_FLAG').getValue());

            store.setParameter("CUBL_NM", EVF.C('CUBL_NM').getValue());
            store.setParameter("MNG_ID", EVF.C('MNG_ID').getValue());
            store.load(baseUrl + "bs01060_doSearchD", function () {
                if(gridD.getRowCount() === 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        // 고객사청구지 저장
        function doSaveDT() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!gridD.validate().flag) { return alert(gridD.validate().msg); }

            if(!confirm("${BS01_060_002}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load(baseUrl + "bs01060_doSaveDT", function() {
                alert(this.getResponseMessage());
                //doSearch();
                doSearchD(EVF.C('CUST_CD_R').getValue());
            });
        }

        // 고객사청구지삭제
        function doDeleteDT() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }


            var rowIds = gridD.getSelRowId();
            for(var i = rowIds.length -1; i >= 0; i--) {
				if(gridD.getCellValue(rowIds[i], "CUBL_SQ")=='1') {
                    return alert('${BS01_060_004}');
				}
            }



            if(!confirm("${msg.M0013}")) { return; }

            store.setGrid([gridD]);
            store.getGridData(gridD, "sel");
            store.load(baseUrl + "bs01060_doDeleteDT", function() {
                alert(this.getResponseMessage());
                //doSearch();
                doSearchD(EVF.C('CUST_CD_R').getValue());
            });
        }

        function chgCustCd() {
            var store = new EVF.Store;
            store.load('/evermp/SY01/SY0101/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
            	}
            });

            doSearch();
        }




    </script>
    <e:window id="BS01_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="panL" width="39%" height="100%">
            <e:searchPanel id="formL" title="${form_CAPTION_N}" labelWidth="100" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
                <e:row>
                    <e:label for="CUST_CD_L" title="${formL_CUST_CD_N}"/>
                    <e:field>
                        <e:search id="CUST_CD_L" name="CUST_CD_L" value="" width="40%" maxLength="${formL_CUST_CD_M}" onIconClick="searchCustCd" disabled="${formL_CUST_CD_D}" readOnly="${formL_CUST_CD_RO}" required="${formL_CUST_CD_R}" />
                        <e:inputText id="CUST_NM_L" name="CUST_NM_L" value="" width="60%" maxLength="${formL_CUST_NM_M}" disabled="${formL_CUST_NM_D}" readOnly="${formL_CUST_NM_RO}" required="${formL_CUST_NM_R}" />
                    </e:field>
					<e:label for="PLANT_CD" title="${formL_PLANT_CD_N}"/>
					<e:field>
					<e:select id="PLANT_CD" name="PLANT_CD" value="" options="${plantCdOptions}" width="${formL_PLANT_CD_W}" disabled="${formL_PLANT_CD_D}" readOnly="${formL_PLANT_CD_RO}" required="${formL_PLANT_CD_R}" placeHolder="" />
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
					<e:label for="CUBL_NM" title="${formR_CUBL_NM_N}" />
					<e:field>
					<e:inputText id="CUBL_NM" name="CUBL_NM" onChange="doSearchDC" value="" width="${formR_CUBL_NM_W}" maxLength="${formR_CUBL_NM_M}" disabled="${formR_CUBL_NM_D}" readOnly="${formR_CUBL_NM_RO}" required="${formR_CUBL_NM_R}" />
					</e:field>
					<e:label for="USE_FLAG" title="${formR_USE_FLAG_N}"/>
					<e:field>
					<e:select id="USE_FLAG" name="USE_FLAG" value="" options="${useFlagOptions}" width="${formR_USE_FLAG_W}" disabled="${formR_USE_FLAG_D}" readOnly="${formR_USE_FLAG_RO}" required="${formR_USE_FLAG_R}" placeHolder="" onChange="doSearchDC"/>
					</e:field>

					<e:inputHidden id="CUST_CD_R" name="CUST_CD_R" value=""/>
					<e:inputHidden id="PLANT_CD_R" name="PLANT_CD_R" value=""/>

					<e:inputHidden id="CUST_NM_R" name="CUST_NM_R" value=""/>
					<e:inputHidden id="MNG_ID" name="MNG_ID" value=""/>
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