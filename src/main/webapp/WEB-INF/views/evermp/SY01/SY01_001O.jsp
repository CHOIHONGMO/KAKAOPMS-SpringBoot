<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var gridT; var gridM; var gridB; var gridDP;
        var addParam = [];
        var baseUrl = "/evermp/SY01/SY0101/";

        function init() {
            gridT = EVF.C("gridT");
            gridM = EVF.C("gridM");
            gridB = EVF.C("gridB");
            gridDP = EVF.C("gridDP");

            gridT.setProperty('shrinkToFit', true);
            gridM.setProperty('shrinkToFit', true);
            gridB.setProperty('shrinkToFit', true);
            gridDP.setProperty('shrinkToFit', true);

            if ('${ses.userType}' != 'C') {
				EVF.C("CUST_CD").setDisabled(true);
				EVF.C("CUST_NM").setDisabled(true);
            }



            gridT.cellClickEvent(function(rowId, colId, value) {
                if(colId == "DIVISION_CD") {
                    gridM.delAllRow();
                    gridB.delAllRow();


                    if(gridT.getCellValue(rowId, 'DIVISION_CD')==""){
                        EVF.C("R1").setChecked(true);
                        EVF.C("R2").setChecked(false);
                        EVF.C("R3").setChecked(false);
                        EVF.C("R4").setChecked(false);
                    }else{
                        var store = new EVF.Store();

                        store.setParameter("PARENT_DEPT_CD", gridT.getCellValue(rowId, 'DIVISION_CD'));



                        EVF.V("DIVISION_CD",gridT.getCellValue(rowId, 'DIVISION_CD'));

                        EVF.V("M_PARENT_DEPT_CD",gridT.getCellValue(rowId, 'DEPT_CD'));
                        EVF.V("M_PARENT_DEPT_NM",gridT.getCellValue(rowId, 'DEPT_NM'));
                        EVF.V("B_PARENT_DEPT_CD",""); EVF.V("B_PARENT_DEPT_NM","");
                        store.setGrid([gridM]);
                        store.load(baseUrl + 'sy01001_doSearchM', function() {
                            if(gridM.getRowCount() == 0){
                                alert("${msg.M0002 }");
                            }
                        });
                        EVF.C("R1").setChecked(false);
                        EVF.C("R2").setChecked(true);
                        EVF.C("R3").setChecked(false);
                        EVF.C("R4").setChecked(false);
                    }

                }
                if(colId == "TEAM_LEADER_USER_NM") {
                    var	param =	{
                        rowId: rowId,
                        custCd: EVF.V("CUST_CD"),
                        callBackFunction: "lv1_callBackCTRL_USER_ID"
                    };
                    everPopup.openCommonPopup(param, 'SP0083');
                }
                if (colId == "DEPT_IRS_NUM") {
                	gridT.setCellValue(rowId, 'DEPT_IRS_NUM',gridT.getCellValue(rowId, 'DEPT_IRS_NUM').replace(/-/gi, ''));
                	if(!checkValidationIrsNo(gridT.getCellValue(rowId, 'DEPT_IRS_NUM'))) {
                        alert("${SY01_001O_002}");
                        gridT.setCellValue(rowId, 'DEPT_IRS_NUM','');
                    }
                }
            });

            gridT.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "PARENT_DEPT_NM") {
                    gridT.setCellValue(rowid, 'PARENT_DEPT_CD', gridT.getCellValue(rowid, 'PARENT_DEPT_NM'));
                }
                if (colId == "DEPT_IRS_NUM") {
                	gridT.setCellValue(rowid, 'DEPT_IRS_NUM',gridT.getCellValue(rowid, 'DEPT_IRS_NUM').replace(/-/gi, ''));
                	if(!checkValidationIrsNo(gridT.getCellValue(rowid, 'DEPT_IRS_NUM'))) {
                		alert("${SY01_001O_002}");
                        gridT.setCellValue(rowid, 'DEPT_IRS_NUM','');
                    }
                }
            });

            gridT.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridM.cellClickEvent(function(rowId, colId, value) {

                if(colId == "DEPT_CD") {

                	  gridB.delAllRow();

                    if(gridM.getCellValue(rowId, 'DEPT_CD')==""){
                        EVF.C("R1").setChecked(false);
                        EVF.C("R2").setChecked(true);
                        EVF.C("R3").setChecked(false);
                        EVF.C("R4").setChecked(false);
                    }else{
                        var store = new EVF.Store();
                        store.setParameter("PARENT_DEPT_CD", gridM.getCellValue(rowId, 'DEPT_CD'));
                        EVF.V("B_PARENT_DEPT_CD",gridM.getCellValue(rowId, 'DEPT_CD'));
                        EVF.V("B_PARENT_DEPT_NM",gridM.getCellValue(rowId, 'DEPT_NM'));
                        EVF.V("M_PARENT_DEPT_CD",""); EVF.V("M_PARENT_DEPT_NM","");
                        store.setGrid([gridB]);
                        store.load(baseUrl + 'sy01001_doSearchB', function() {
                        });
                        EVF.C("R1").setChecked(false);
                        EVF.C("R2").setChecked(false);
                        EVF.C("R3").setChecked(true);
                        EVF.C("R4").setChecked(false);
                        EVF.V("DEPT_CD",gridM.getCellValue(rowId, 'DEPT_CD'));
                    }
                }
                if(colId == "TEAM_LEADER_USER_NM") {
                    var	param =	{
                        rowId: rowId,
                        custCd: EVF.V("CUST_CD"),
                        callBackFunction: "lv2_callBackCTRL_USER_ID"
                    };
                    everPopup.openCommonPopup(param, 'SP0083');
                }
                if (colId == "DEPT_IRS_NUM") {
                	gridM.setCellValue(rowId, 'DEPT_IRS_NUM',gridM.getCellValue(rowId, 'DEPT_IRS_NUM').replace(/-/gi, ''));
                	if(!checkValidationIrsNo(gridM.getCellValue(rowId, 'DEPT_IRS_NUM'))) {
                        alert("${SY01_001O_002}");
                        gridM.setCellValue(rowId, 'DEPT_IRS_NUM','');
                    }
                }
            });

            gridM.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "PARENT_DEPT_NM") {
                    gridM.setCellValue(rowid, 'PARENT_DEPT_CD', gridM.getCellValue(rowid, 'PARENT_DEPT_NM'));
                }
                if (colId == "DEPT_IRS_NUM") {
                	gridM.setCellValue(rowid, 'DEPT_IRS_NUM',gridM.getCellValue(rowid, 'DEPT_IRS_NUM').replace(/-/gi, ''));
                	if(!checkValidationIrsNo(gridM.getCellValue(rowid, 'DEPT_IRS_NUM'))) {
                		alert("${SY01_001O_002}");
                        gridM.setCellValue(rowid, 'DEPT_IRS_NUM','');
                    }
                }
            });

            gridM.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridB.cellClickEvent(function(rowId, colId, value) {
            	return;

                if(colId == "DEPT_CD") {

                    if(gridB.getCellValue(rowId, 'DEPT_CD')==""){
                        EVF.C("R1").setChecked(false);
                        EVF.C("R2").setChecked(false);
                        EVF.C("R3").setChecked(true);
                        EVF.C("R4").setChecked(false);
                    }else{
                        var store = new EVF.Store();
                        store.setParameter("PARENT_DEPT_CD", gridB.getCellValue(rowId, 'DEPT_CD'));
                        EVF.V("DP_PARENT_DEPT_CD",gridB.getCellValue(rowId, 'DEPT_CD'));
                        EVF.V("DP_PARENT_DEPT_NM",gridB.getCellValue(rowId, 'DEPT_NM'));
                        EVF.V("B_PARENT_DEPT_CD",""); EVF.V("B_PARENT_DEPT_NM","");
                        store.setGrid([gridDP]);
                        store.load(baseUrl + 'sy01001_doSearchDP', function() {
                        });
                        EVF.C("R1").setChecked(false);
                        EVF.C("R2").setChecked(false);
                        EVF.C("R3").setChecked(false);
                        EVF.C("R4").setChecked(true);
                        EVF.V("DEPT_CD",gridB.getCellValue(rowId, 'DEPT_CD'));
                    }
                }
                if(colId == "TEAM_LEADER_USER_NM") {
                    var	param =	{
                        rowId: rowId,
                        custCd: EVF.V("CUST_CD"),
                        callBackFunction: "lv3_callBackCTRL_USER_ID"
                    };
                    everPopup.openCommonPopup(param, 'SP0083');
                }
                if (colId == "DEPT_IRS_NUM") {
                	gridB.setCellValue(rowId, 'DEPT_IRS_NUM',gridB.getCellValue(rowId, 'DEPT_IRS_NUM').replace(/-/gi, ''));
                	if(!checkValidationIrsNo(gridB.getCellValue(rowId, 'DEPT_IRS_NUM'))) {
                        alert("${SY01_001O_002}");
                        gridB.setCellValue(rowId, 'DEPT_IRS_NUM','');
                    }
                }
            });

            gridB.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {
                if (colId == "PARENT_DEPT_NM") {
                    gridB.setCellValue(rowid, 'PARENT_DEPT_CD', gridB.getCellValue(rowid, 'PARENT_DEPT_NM'));
                }
                if (colId == "DEPT_IRS_NUM") {
                	gridB.setCellValue(rowid, 'DEPT_IRS_NUM',gridB.getCellValue(rowid, 'DEPT_IRS_NUM').replace(/-/gi, ''));
                	if(!checkValidationIrsNo(gridB.getCellValue(rowid, 'DEPT_IRS_NUM'))) {
                		alert("${SY01_001O_002}");
                        gridB.setCellValue(rowid, 'DEPT_IRS_NUM','');
                    }
                }
            });

            gridB.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


          //1
            gridDP.cellClickEvent(function(rowId, colId, value) {
                if(colId == "text" || colId == "value") {
                	  gridM.delAllRow();
                      gridB.delAllRow();
                	  var store = new EVF.Store();

                	    EVF.V("M_PARENT_DEPT_CD","");
                        EVF.V("B_PARENT_DEPT_CD","");
                        EVF.V("DP_PARENT_DEPT_CD","");
                        EVF.V("PLANT_CD",gridDP.getCellValue(rowId,"value"));
                        var store = new EVF.Store();
                        if(!store.validate()) { return;}
                        store.setGrid([gridDP,gridT,gridM,gridB]);
                        store.setParameter("PLANT_CD", gridDP.getCellValue(rowId,"value"));
                        store.load(baseUrl + 'sy01001_doSearch', function() {
                            if(gridDP.getRowCount() == 0&&gridT.getRowCount() == 0&&gridM.getRowCount() == 0&&gridB.getRowCount() == 0){
                                alert("${msg.M0002 }");
                            }
                        });
                      EVF.C("R1").setChecked(true);
                      EVF.C("R2").setChecked(false);
                      EVF.C("R3").setChecked(false);
                      EVF.C("R4").setChecked(false);
                }
            });


            gridDP.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridT.addRowEvent(function() {
                addParam = [{'PARENT_DEPT_CD': EVF.V("CUST_CD"),'PARENT_DEPT_NM': EVF.V("CUST_NM"), 'APPROVE_USE_FLAG': '0', 'DEL_FLAG': '1' ,'DEPT_CD': '*','PART_CD': '*' }];
                gridT.addRow(addParam);
                EVF.C("R1").setChecked(true);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
                EVF.C("R4").setChecked(false);
            });
            gridT.delRowEvent(function() {
                if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridT.delRow();
            });
            gridM.addRowEvent(function() {
                if(EVF.V("M_PARENT_DEPT_CD")==""){
                    return alert("${SY01_001O_003}");
                }
                addParam = [{'DIVISION_CD': EVF.V("DIVISION_CD"), 'PART_CD': '*', 'PARENT_DEPT_CD': EVF.V("DIVISION_CD"),'PARENT_DEPT_NM': EVF.V("M_PARENT_DEPT_NM"), 'APPROVE_USE_FLAG': '0', 'DEL_FLAG': '1'}];
                gridM.addRow(addParam);
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(true);
                EVF.C("R3").setChecked(false);
                EVF.C("R4").setChecked(false);
            });
            gridM.delRowEvent(function() {
                if(!gridM.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridM.delRow();
            });
            gridB.addRowEvent(function() {
                if(EVF.V("B_PARENT_DEPT_CD")==""){
                    return alert("${SY01_001O_003}");
                }
                addParam = [{'DIVISION_CD': EVF.V("DIVISION_CD"),'DEPT_CD': EVF.V("DEPT_CD"), 'PARENT_DEPT_CD': EVF.V("DEPT_CD"),'PARENT_DEPT_NM': EVF.V("B_PARENT_DEPT_NM"), 'APPROVE_USE_FLAG': '0', 'DEL_FLAG': '1'}];
                gridB.addRow(addParam);
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(true);
                EVF.C("R4").setChecked(false);
            });
            gridB.delRowEvent(function() {
                if(!gridB.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridB.delRow();
            });



            gridDP.addRowEvent(function() {
                if(EVF.V("DP_PARENT_DEPT_CD")==""){
                    return alert("${SY01_001O_003}");
                }
                addParam = [{'PARENT_DEPT_CD': EVF.V("DP_PARENT_DEPT_CD"),'PARENT_DEPT_NM': EVF.V("DP_PARENT_DEPT_NM"), 'APPROVE_USE_FLAG': '0', 'DEL_FLAG': '1'}];
                gridDP.addRow(addParam);
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
                EVF.C("R4").setChecked(true);
            });
            gridDP.delRowEvent(function() {
                if(!gridDP.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridDP.delRow();
            });

            findPlant();
        }

        function lv1_callBackCTRL_USER_ID(jsonData)	{
            gridT.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_NM', jsonData.USER_NM);
            gridT.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID', jsonData.USER_ID);
        }
        function lv2_callBackCTRL_USER_ID(jsonData)	{
            gridM.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_NM', jsonData.USER_NM);
            gridM.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID', jsonData.USER_ID);
        }
        function lv3_callBackCTRL_USER_ID(jsonData)	{
            gridB.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_NM', jsonData.USER_NM);
            gridB.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID', jsonData.USER_ID);
        }
        function lv4_callBackCTRL_USER_ID(jsonData)	{
            gridDP.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_NM', jsonData.USER_NM);
            gridDP.setCellValue(jsonData.rowId, 'TEAM_LEADER_USER_ID', jsonData.USER_ID);
        }

        function checkValidationIrsNo(irsNum) {
            var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
            var tmpBizID, i, chkSum = 0, c2, remainder;
            var irsNum = everString.lrTrim(irsNum);
            irsNum = irsNum.replace(/-/gi, '');
            //$('#irsNum').val(irsNum);

            for (i = 0; i <= 7; i++)
                chkSum += checkID[i] * irsNum.charAt(i);
            c2 = "0" + (checkID[8] * irsNum.charAt(8));
            c2 = c2.substring(c2.length - 2, c2.length);
            chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
            remainder = (10 - (chkSum % 10)) % 10;

            if (Math.floor(irsNum.charAt(9)) == remainder) {
                return true;
            } else {
                return false;
            }
        }

        function doSearch() {
            EVF.V("M_PARENT_DEPT_CD","");
            EVF.V("B_PARENT_DEPT_CD","");
            EVF.V("DP_PARENT_DEPT_CD","");

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([gridT,gridM,gridB]);
            store.load(baseUrl + 'sy01001_doSearch', function() {
                if(gridT.getRowCount() == 0&&gridM.getRowCount() == 0&&gridB.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

            if(EVF.V("CUST_CD")==""){
                EVF.C('CUST_NM').setFocus();
                return alert("${SY01_001O_001}");
            }

            var radioVal = (EVF.C("R1").isChecked() == true ? "R1" :(EVF.C("R2").isChecked() == true ? "R2" : (EVF.C("R3").isChecked() == true ? "R3" : "R1")));

            if(radioVal == "R1") {
                if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }
                if (!gridT.validate().flag) { return alert(gridT.validate().msg); }
                EVF.V("DEPT_TYPE_RADIO","100");
                EVF.V("DIVISION_YN","1");
                EVF.V("LVL","1");

            } else if(radioVal == "R2") {
                if(!gridM.isExistsSelRow()) { return alert("${msg.M0004}"); }
                if (!gridM.validate().flag) { return alert(gridM.validate().msg); }
                EVF.V("DEPT_TYPE_RADIO","200");
                EVF.V("DIVISION_YN","0");
                EVF.V("LVL","2");
            } else if(radioVal == "R3") {
                if(!gridB.isExistsSelRow()) { return alert("${msg.M0004}"); }
                if (!gridB.validate().flag) { return alert(gridB.validate().msg); }
                EVF.V("DEPT_TYPE_RADIO","300");
                EVF.V("DIVISION_YN","0");
                EVF.V("LVL","3");
            }


            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setParameter("radioVal", radioVal);
            store.setGrid([gridT, gridM, gridB, gridDP]);
            store.getGridData(gridT, 'sel');
            store.getGridData(gridM, 'sel');
            store.getGridData(gridB, 'sel');
            store.getGridData(gridDP, 'sel');
            store.load(baseUrl + 'sy01001_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function checkRadio() {

            var clickBtn = this.getData();

            if(clickBtn == "R1") {
                EVF.C("R1").setChecked(true);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
                EVF.C("R4").setChecked(false);
            }
            else if(clickBtn == "R2") {
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(true);
                EVF.C("R3").setChecked(false);
                EVF.C("R4").setChecked(false);
            }
            else if(clickBtn == "R3") {
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(true);
                EVF.C("R4").setChecked(false);
            }
            else if(clickBtn == "R4") {
                EVF.C("R1").setChecked(false);
                EVF.C("R2").setChecked(false);
                EVF.C("R3").setChecked(false);
                EVF.C("R4").setChecked(true);
            }
        }

        function setBuyer(data) {
            EVF.V('CUST_CD', data.CUST_CD);
            EVF.V('CUST_NM', data.CUST_NM);
    		EVF.C("ERP_IF_FLAG").setValue(data.ERP_IF_FLAG);
            findPlant();
        }
		function findPlant(){
			 var store = new EVF.Store;
			 store.setGrid([gridDP]);
	         store.load(baseUrl + '/findPlant', function() {
	        	  if(gridDP.getRowCount() == 0) {
	                    return alert('조회된 사업장이 없습니다.');
	                }
	          });
	         gridB.delAllRow();
	         gridT.delAllRow();
	         gridM.delAllRow();
		}


    </script>
    <e:window id="SY01_001O" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
             <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:inputText id="CUST_CD" name="CUST_CD" value="${ses.companyCd}" width="0" maxLength="${form_CUST_CD_M}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:search id="CUST_NM" name="CUST_NM" value="${ses.companyNm}" width="100%" maxLength="${form_CUST_NM_M}" onIconClick="${form_CUST_NM_RO ? 'everCommon.blank' : 'getBuyer'}" popupCode="SP0067.setBuyer" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="dummy" />
                <e:field>
                </e:field>


                    <e:inputHidden id="PLANT_CD" name="PLANT_CD"/>
                    <e:inputHidden id="DEPT_TYPE_RADIO" name="DEPT_TYPE_RADIO"/>
                    <e:inputHidden id="DIVISION_YN" name="DIVISION_YN"/>
                    <e:inputHidden id="M_PARENT_DEPT_CD" name="M_PARENT_DEPT_CD"/>
                    <e:inputHidden id="M_PARENT_DEPT_NM" name="M_PARENT_DEPT_NM"/>
                    <e:inputHidden id="B_PARENT_DEPT_CD" name="B_PARENT_DEPT_CD"/>
                    <e:inputHidden id="B_PARENT_DEPT_NM" name="B_PARENT_DEPT_NM"/>
                    <e:inputHidden id="DP_PARENT_DEPT_CD" name="DP_PARENT_DEPT_CD"/>
                    <e:inputHidden id="DP_PARENT_DEPT_NM" name="DP_PARENT_DEPT_NM"/>
                    <e:inputHidden id="LVL" name="LVL"/>
			        <e:inputHidden id="DEPT_NM" name="DEPT_NM"/>
			        <e:inputHidden id="DEPT_CD" name="DEPT_CD"/>
			        <e:inputHidden id="DIVISION_CD" name="DIVISION_CD"/>
					<e:inputHidden id="ERP_IF_FLAG" name="ERP_IF_FLAG" value="${ses.erpIfFlag}"/>

            </e:row>
        </e:searchPanel>

       <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" visible="${Save_V}" onClick="doSave" />
        </e:buttonBar>

		<e:panel id="rightPanelB" height="385" width="49%">
            <e:radio id="R4" name="R4" label="" value="4" checked="false" readOnly="false" disabled="false" onClick="checkRadio" data="R4" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${SY01_001O_LV4}</e:text>
            <e:gridPanel id="gridDP" name="gridDP" width="100%" height="330px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridDP.gridColData}" />
        </e:panel>
           <e:panel id="nullPanel" height="385" width="1%">&nbsp;</e:panel>
        <e:panel id="leftPanel" height="385px" width="50%">
            <e:radio id="R1" name="R1" label="" value="1" checked="true" readOnly="false" disabled="false" onClick="checkRadio" data="R1" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${SY01_001O_LV1}</e:text>
            <e:gridPanel id="gridT" name="gridT" width="100%" height="330px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}" />
        </e:panel>

        <e:panel id="rightPanel" height="fit" width="49%">
            <e:radio id="R2" name="R2" label="" value="2" checked="false" readOnly="false" disabled="false" onClick="checkRadio" data="R2" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${SY01_001O_LV2}</e:text>
            <e:gridPanel id="gridM" name="gridM" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridM.gridColData}" />
        </e:panel>
		 <e:panel id="nullPanel2" height="fit" width="1%">&nbsp;</e:panel>
        <e:panel id="leftPanelB" height="fit" width="50%">
            <e:radio id="R3" name="R3" label="" value="3" checked="false" readOnly="false" disabled="false" onClick="checkRadio" data="R3" />
            <e:text style="float: left; line-height: 27px; font-size: 14px; font-weight: bold;">${SY01_001O_LV3}</e:text>
            <e:gridPanel id="gridB" name="gridB" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridB.gridColData}" />
        </e:panel>

    </e:window>
</e:ui>