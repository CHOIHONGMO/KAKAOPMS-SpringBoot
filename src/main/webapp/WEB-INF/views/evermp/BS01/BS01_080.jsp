<!--
* BS01_080 : 고객사 결재경로관리
* 운영사 > 기준정보 > 고객사 정보관리 > 고객사 결재경로관리
-->

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script>

        var baseUrl = "/evermp/BS01/BS0102/";
        var gridU; var gridP;
        var selRow;

        function init() {

            gridU = EVF.C('gridU');
            gridP = EVF.C('gridP');

            gridP.setProperty('shrinkToFit', true);

            gridU.cellClickEvent(function(rowIdx, colIdx, value) {

                if(colIdx == 'SIGN_PATH_NM') {

                    var store = new EVF.Store();
                    store.setParameter("PATH_NUM", gridU.getCellValue(rowIdx, 'PATH_NUM'));
                    store.load(baseUrl + 'bs01080_doSearchPathInfo', function() {
                        var data = this.data.formData;
                        EVF.V("APG_FLAG_CD", gridU.getCellValue(rowIdx, 'APG_FLAG'));
                        EVF.V("MAIN_PATH_FLAG", data.MAIN_PATH_FLAG);
                        EVF.C("MAIN_PATH_FLAG_LOC").setChecked((data.MAIN_PATH_FLAG == "1" ? true : false));
                        EVF.V("SIGN_PATH_NM", data.SIGN_PATH_NM);
                        EVF.V("PATH_CNT", data.PATH_CNT);
                        EVF.V("SIGN_RMK", data.SIGN_RMK);
                        EVF.V("REG_INFO", data.REG_DATE + " / " + data.REG_USER_NM);
                        EVF.V("MOD_INFO", data.MOD_DATE + " / " + data.MOD_USER_NM);
                        EVF.V("PATH_NUM", data.PATH_NUM);
                        EVF.V("BUYER_CD", gridU.getCellValue(rowIdx, 'COMPANY_CD'));
                        EVF.V("COMPANY_NM", gridU.getCellValue(rowIdx, 'COMPANY_CD') + " / " + gridU.getCellValue(rowIdx, 'COMPANY_NM'));
                        EVF.V("DEPT_NM", gridU.getCellValue(rowIdx, 'DEPT_CD') + " / " + gridU.getCellValue(rowIdx, 'DEPT_NM'));
                        EVF.V("USER_ID", gridU.getCellValue(rowIdx, 'USER_ID'));
                        EVF.V("USER_NM", gridU.getCellValue(rowIdx, 'USER_NM'));
                        doSearchPathInfo();
                    });
                }

                if(colIdx == "SIGN_RMK") {
                    if(!EVF.isEmpty(gridU.getCellValue(rowIdx, "SIGN_RMK"))) {
                        var param = {
                            title : "${BS01_080_003}",
                            message : gridU.getCellValue(rowIdx, "SIGN_RMK"),
                            callbackFunction : "",
                            detailView : true,
                            rowId : rowIdx
                        };
                        var url = "/common/popup/common_text_input/view";
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
            });

            gridP.cellClickEvent(function(rowIdx, colIdx, value) {

                selRow = rowIdx;

                if (colIdx == 'SIGN_USER_NM') {
                    var buyerCd = EVF.V("BUYER_CD");
                    everPopup.userSearchPopup('selectUserGrid', rowIdx, '', 'approval', buyerCd);
                }
            });

            gridP.addRowEvent(function() {
                var addParam = [{"INSERT_FLAG": "I"}];
                gridP.addRow(addParam);
                recountSignSequence();
            });

            gridP.delRowEvent(function() {
                if(!gridP.isExistsSelRow()) { return alert("${msg.M0004}"); }
                gridP.delRow();
                recountSignSequence();
            });

            gridU.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridP.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            EVF.V('USER_TYPE_SEARCH', "B");
            EVF.C('USER_TYPE_SEARCH').removeOption('C');
            EVF.C('USER_TYPE_SEARCH').removeOption('S');
        }

        function doSearchUser() {

            var apgFlag = "N";
            if( EVF.C("APG_FLAG").isChecked() ) { apgFlag = "Y"; }
            var allFlag = "N";
            if( EVF.C("ALL_FLAG").isChecked() ) { allFlag = "Y"; }

            var store = new EVF.Store();
            store.setGrid([gridU]);
            store.setParameter("apgFlag", apgFlag);
            store.setParameter("allFlag", allFlag);
            store.load(baseUrl + 'bs01080_doSearchUser', function() {
                if(gridU.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
                gridU.setColIconify("SIGN_RMK", "SIGN_RMK", "comment", false);
                doInitData();
            });
        }

        function doSearchPathInfo() {

            var store = new EVF.Store();
            store.setGrid([gridP]);
            store.load(baseUrl + 'bs01080_doSearchPathList', function() {

            });
        }

        function doInitData() {
            EVF.V("MAIN_PATH_FLAG", "");
            EVF.C("MAIN_PATH_FLAG_LOC").setChecked(false);
            EVF.V("SIGN_PATH_NM", "");
            EVF.V("PATH_CNT", "");
            EVF.V("SIGN_RMK", "");
            EVF.V("REG_INFO", "");
            EVF.V("MOD_INFO", "");
            EVF.V("PATH_NUM", "");
            EVF.V("BUYER_CD", "");
            EVF.V("COMPANY_NM", "");
            EVF.V("DEPT_NM", "");
            EVF.V("USER_ID", "");
            EVF.V("USER_NM", "");
            gridP.delAllRow();
        }

        function doSave() {

            var store = new EVF.Store();
            if(!store.validate()) return;

            gridP.checkAll(true);

            if (gridP.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if (!gridP.validate().flag) { return alert(gridP.validate().msg); }

            if (confirm("${msg.M0021}")) {

                var mainPathFlag = "0";
                if( EVF.C("MAIN_PATH_FLAG_LOC").isChecked() ) { mainPathFlag = "1"; }

                store.setGrid([gridP]);
                store.getGridData(gridP, 'all');
                store.setParameter("mainPathFlag", mainPathFlag);
                store.load( baseUrl + "bs01080_doSave", function() {
                    alert(this.getResponseMessage());
                    doSearchUser();
                });
            }
        }

        function doDelete() {

            if(EVF.isEmpty(EVF.V("PATH_NUM"))) {
                return alert("${BS01_080_005}");
            }

            if (confirm("${msg.M0013}")) {
                var store = new EVF.Store();
                store.setGrid([gridP]);
                store.getGridData(gridP, 'all');
                store.load( baseUrl + "bs01080_doDelete", function() {
                    alert(this.getResponseMessage());
                    doSearchUser();
                });
            }
        }

        function doMoveUp() {

            if(!gridP.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if (gridP.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            var selectedRowId = gridP.jsonToArray(gridP.getSelRowId()).value[0]
                ,selectedRowData = gridP.getRowValue(selectedRowId);

            var allRowIds = gridP.jsonToArray(gridP.getAllRowId()).value;
            gridP.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

            var store = new EVF.Store();
            store.setGrid([gridP]);
            store.setParameter('sortType', 'up');
            store.getGridData(gridP, 'all');
            store.load(baseUrl + 'getRealignmentApprovalList', function() {
                gridP.checkAll(false);
                recountSignSequence();
            }, false);
        }

        function doMoveDown() {

            if(!gridP.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if (gridP.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            var selectedRowId = gridP.jsonToArray(gridP.getSelRowId()).value[0]
                ,selectedRowData = gridP.getRowValue(selectedRowId);

            var allRowIds = gridP.jsonToArray(gridP.getAllRowId()).value;
            gridP.setCellValue(selectedRowId, 'CHECK_FLAG', '1');

            var store = new EVF.Store();
            store.setGrid([gridP]);
            store.setParameter('sortType', 'down');
            store.getGridData(gridP, 'all');
            store.load(baseUrl + 'getRealignmentApprovalList', function() {
                gridP.checkAll(false);
                recountSignSequence();
            }, false);
        }

        <%-- 결재 순번 계산 --%>
        function recountSignSequence() {

            var rowIds = gridP.jsonToArray(gridP.getAllRowId()).value;
            var selectedRowIdx = [];
            for(var i = 0; i < rowIds.length; i++) {

                var rowData = gridP.getRowValue(rowIds[i]);
                var checkFlag = rowData['CHECK_FLAG'];
                if(checkFlag == '1') {
                    selectedRowIdx.push(rowIds[i]);
                }
                gridP.setCellValue(rowIds[i], "CHECK_FLAG", "");
                gridP.setCellValue(rowIds[i], 'PATH_SQ', i + 1);
            }

            var allRowIds = gridP.jsonToArray(gridP.getAllRowId()).value;
            for(var i = 0; i < allRowIds.length; i++) {
                gridP.setCellValue(allRowIds[i], 'CHECK_FLAG', '');
            }
            gridP.checkAll(false);
            for(var i = 0; i < selectedRowIdx.length; i++) {
                gridP.checkRow(selectedRowIdx[i], true);
            }
        }

        function getCompanyInfo() {
            if (EVF.V("USER_TYPE_HIDDEN") == "B") {
                var param = {
                    callBackFunction: "setCompanyInfo"
                };
                everPopup.openCommonPopup(param, 'SP0067');
            }
        }

        function setCompanyInfo(dataJsonArray) {
            EVF.C("COMPANY_CD_SEARCH").setValue(dataJsonArray.CUST_CD);
            EVF.C("COMPANY_NM_SEARCH").setValue(dataJsonArray.CUST_NM);
        }

        function cleanCompanyCd() {
            EVF.C("COMPANY_CD_SEARCH").setValue("");
        }

        function getDeptInfo() {

            if(EVF.isEmpty(EVF.V("COMPANY_CD_SEARCH"))) {
                EVF.C("COMPANY_CD_SEARCH").setFocus();
                return alert("${BS01_080_002}");
            }
            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setDeptInfo",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : EVF.V("COMPANY_CD_SEARCH"),
                'custNm' : EVF.V("COMPANY_NM_SEARCH")
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
        }

        function setDeptInfo(data) {
            data = JSON.parse(data);
            EVF.V('DEPT_CD_SEARCH', data.DEPT_CD);
            EVF.V('DEPT_NM_SEARCH', data.DEPT_NM);
        }

        function cleanDeptCd() {
            EVF.C("DEPT_CD_SEARCH").setValue("");
        }

        function getUserInfo() {
            if(!EVF.isEmpty(EVF.V("PATH_NUM"))) {
                return alert("${BS01_080_004}");
            }
            everPopup.userSearchPopup('selectUserForm', '', '', 'approvalS', '');
        }

        function selectUserForm(dataJsonArray) {
            EVF.V("USER_ID", dataJsonArray.USER_ID);
            EVF.V("USER_NM", dataJsonArray.USER_NM);
            EVF.V("BUYER_CD", (EVF.isEmpty(dataJsonArray.BUYER_CD) ? dataJsonArray.COMPANY_CD : dataJsonArray.BUYER_CD));
            EVF.V("COMPANY_NM", (EVF.isEmpty(dataJsonArray.BUYER_CD) ? dataJsonArray.COMPANY_CD : dataJsonArray.BUYER_CD) + " / " + dataJsonArray.BUYER_NM);
            EVF.V("DEPT_NM", dataJsonArray.DEPT_CD + " / " + dataJsonArray.DEPT_NM);
        }

        function selectUserGrid(dataJsonArray) {
            gridP.setCellValue(selRow, "COMPANY_CD", (EVF.isEmpty(dataJsonArray.BUYER_CD) ? dataJsonArray.COMPANY_CD : dataJsonArray.BUYER_CD));
            gridP.setCellValue(selRow, "COMPANY_NM", dataJsonArray.BUYER_NM);
            gridP.setCellValue(selRow, "DEPT_CD", dataJsonArray.DEPT_CD);
            gridP.setCellValue(selRow, "DEPT_NM", dataJsonArray.DEPT_NM);
            gridP.setCellValue(selRow, "SIGN_USER_ID", dataJsonArray.USER_ID);
            gridP.setCellValue(selRow, "SIGN_USER_NM", dataJsonArray.USER_NM);
            gridP.setCellValue(selRow, "POSITION_NM", dataJsonArray.POSITION_NM);
            gridP.setCellValue(selRow, "DUTY_NM", dataJsonArray.DUTY_NM);
            gridP.setCellValue(selRow, "PATH_NUM", EVF.V("PATH_NUM"));
        }

        function UserTypeSearchChange(){
            EVF.V('COMPANY_CD_SEARCH', (EVF.V("USER_TYPE_SEARCH") == "C" ? "${ses.companyCd}" : ""));
            EVF.V('COMPANY_NM_SEARCH', (EVF.V("USER_TYPE_SEARCH") == "C" ? "${ses.companyNm}" : ""));
            EVF.V('DEPT_CD_SEARCH', "");
            EVF.V('DEPT_NM_SEARCH', "");
            EVF.V('USER_TYPE_HIDDEN', EVF.V("USER_TYPE_SEARCH"));
        }

        function clickFlag() {

            var clickData = this.getData();

            if(clickData == "P" && EVF.C("APG_FLAG").isChecked()) {
                EVF.C("ALL_FLAG").setChecked(false);
            }
            if(clickData == "A" && EVF.C("ALL_FLAG").isChecked()) {
                EVF.C("APG_FLAG").setChecked(false);
            }
        }

    </script>

    <e:window id="BS01_080" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">

        <e:panel id="pnl1" width="50%" height="100%">

            <e:buttonBar id="btnL" align="right" width="100%" title="${BS01_080_TITLE1}">
                <e:button id="SearchUser" name="SearchUser" label="${SearchUser_N }" disabled="${SearchUser_D }" visible="${SearchUser_V }" onClick="doSearchUser" />
            </e:buttonBar>

            <e:searchPanel id="formS" title="${msg.M9999}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2" onEnter="doSearchUser">
                <e:row>
                    <e:label for="USER_TYPE_SEARCH" title="${formS_USER_TYPE_SEARCH_N}"></e:label>
                    <e:field>
                        <e:select id="USER_TYPE_SEARCH" name="USER_TYPE_SEARCH" value="" options="${userTypeSearchOptions}" width="100%" disabled="${formS_USER_TYPE_SEARCH_D}" readOnly="${formS_USER_TYPE_SEARCH_RO}" required="${formS_USER_TYPE_SEARCH_R}" placeHolder="" usePlaceHolder="false" onChange="UserTypeSearchChange" />
                    </e:field>
                    <e:label for="APG_FLAG" title="${formS_APG_FLAG_N}"></e:label>
                    <e:field>
                        <e:check id="APG_FLAG" name="APG_FLAG" label="${formS_APG_FLAG_N }" readOnly="${formS_APG_FLAG_RO }" disabled="${formS_APG_FLAG_D }" onClick="clickFlag" data="P" />
                        <e:check id="ALL_FLAG" name="ALL_FLAG" label="${formS_ALL_FLAG_N }" readOnly="${formS_ALL_FLAG_RO }" disabled="${formS_ALL_FLAG_D }" checked="true" onClick="clickFlag" data="A" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="COMPANY_NM_SEARCH" title="${formS_COMPANY_NM_SEARCH_N}"></e:label>
                    <e:field colSpan="3">
                        <e:search id="COMPANY_CD_SEARCH" style="ime-mode:inactive" name="COMPANY_CD_SEARCH" value="" width="25%" maxLength="${form_COMPANY_CD_SEARCH_M}" onIconClick="${form_COMPANY_CD_SEARCH_RO ? 'everCommon.blank' : 'getCompanyInfo'}" data="S" disabled="${form_COMPANY_CD_SEARCH_D}" readOnly="${form_COMPANY_CD_SEARCH_RO}" required="${form_COMPANY_CD_SEARCH_R}" />
                        <e:inputText id="COMPANY_NM_SEARCH" style="${imeMode}" name="COMPANY_NM_SEARCH" value="" width="75%" maxLength="${form_COMPANY_NM_SEARCH_M}" disabled="${form_COMPANY_NM_SEARCH_D}" readOnly="${form_COMPANY_NM_SEARCH_RO}" required="${form_COMPANY_NM_SEARCH_R}" onKeyDown="cleanCompanyCd" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="DEPT_NM_SEARCH" title="${formS_DEPT_NM_SEARCH_N}"></e:label>
                    <e:field colSpan="3">
                        <e:search id="DEPT_CD_SEARCH" style="ime-mode:inactive" name="DEPT_CD_SEARCH" value="" width="25%" maxLength="${formS_DEPT_CD_SEARCH_M}" onIconClick="${formS_DEPT_CD_SEARCH_RO ? 'everCommon.blank' : 'getDeptInfo'}" data ="S" disabled="${formS_DEPT_CD_SEARCH_D}" readOnly="${formS_DEPT_CD_SEARCH_RO}" required="${formS_DEPT_CD_SEARCH_R}" />
                        <e:inputText id="DEPT_NM_SEARCH" style="${imeMode}" name="DEPT_NM_SEARCH" value="" width="75%" maxLength="${formS_DEPT_NM_SEARCH_M}" disabled="${formS_DEPT_NM_SEARCH_D}" readOnly="${formS_DEPT_NM_SEARCH_RO}" required="${formS_DEPT_NM_SEARCH_R}" onKeyDown="cleanDeptCd" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="USER_ID_NM_SEARCH" title="${formS_USER_ID_NM_SEARCH_N}"></e:label>
                    <e:field colSpan="3">
                        <e:inputText id="USER_ID_NM_SEARCH" style='ime-mode:inactive' name="USER_ID_NM_SEARCH" value="" width="100%" maxLength="${formS_USER_ID_NM_SEARCH_M}" disabled="${formS_USER_ID_NM_SEARCH_D}" readOnly="${formS_USER_ID_NM_SEARCH_RO}" required="${formS_USER_ID_NM_SEARCH_R}" />
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:gridPanel id="gridU" name="gridU" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridU.gridColData}" />

        </e:panel>

        <e:panel id="blank_pn" width="1%">&nbsp;</e:panel>

        <e:panel id="pnl2" width="49%" 	height="100%">

            <e:buttonBar id="btnRT" width="100%" align="right" title="${BS01_080_TITLE2}">
                <e:button id="InitData" name="InitData" label="${InitData_N }" visible="${InitData_V }" onClick="doInitData" />
                <e:button id="Save" name="Save" label="${Save_N }" visible="${Save_V }" onClick="doSave" />
                <e:button id="Delete" name="Delete" label="${Delete_N }" visible="${Delete_V }" onClick="doDelete" />
            </e:buttonBar>

            <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2">

                <e:inputHidden id="MAIN_PATH_FLAG" name="MAIN_PATH_FLAG" />
                <e:inputHidden id="APG_FLAG_CD" name="APG_FLAG_CD" />
                <e:inputHidden id="PATH_NUM" name="PATH_NUM" />
                <e:inputHidden id="BUYER_CD" name="BUYER_CD" />
                <e:inputHidden id="USER_TYPE_HIDDEN" name="USER_TYPE_HIDDEN" />

                <e:row>
                    <e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}"></e:label>
                    <e:field>
                        <e:text id="COMPANY_NM" name="COMPANY_NM"></e:text>
                    </e:field>
                    <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"></e:label>
                    <e:field>
                        <e:text id="DEPT_NM" name="DEPT_NM"></e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="USER_NM" title="${form_USER_NM_N}"></e:label>
                    <e:field colSpan="3">
                        <e:search id="USER_ID" name="USER_ID" value="" width="30%" maxLength="${form_USER_ID_M}" onIconClick="getUserInfo" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
                        <e:inputText id="USER_NM" name="USER_NM" value="" width="70%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="MAIN_PATH_FLAG_LOC" title="${form_MAIN_PATH_FLAG_LOC_N}"></e:label>
                    <e:field>
                        <e:check id="MAIN_PATH_FLAG_LOC" name="MAIN_PATH_FLAG_LOC" label="${form_MAIN_PATH_FLAG_LOC_N }" readOnly="${form_MAIN_PATH_FLAG_LOC_RO }" disabled="${form_MAIN_PATH_FLAG_LOC_D }" />
                    </e:field>
                    <e:label for="PATH_CNT" title="${form_PATH_CNT_N}"/>
                    <e:field>
                        <e:text id="PATH_CNT" name="PATH_CNT"></e:text>
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="SIGN_PATH_NM" title="${form_SIGN_PATH_NM_N}"></e:label>
                    <e:field colSpan="3">
                        <e:inputText id="SIGN_PATH_NM" style='ime-mode:inactive' name="SIGN_PATH_NM" value="" width="100%" maxLength="${form_SIGN_PATH_NM_M}" disabled="${form_SIGN_PATH_NM_D}" readOnly="${form_SIGN_PATH_NM_RO}" required="${form_SIGN_PATH_NM_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="SIGN_RMK" title="${form_SIGN_RMK_N}"/>
                    <e:field colSpan="3">
                        <e:textArea id="SIGN_RMK" name="SIGN_RMK" value="" height="150px" width="${form_SIGN_RMK_W}" maxLength="${form_SIGN_RMK_M}" disabled="${form_SIGN_RMK_D}" readOnly="${form_SIGN_RMK_RO}" required="${form_SIGN_RMK_R}" />
                    </e:field>
                </e:row>
                <e:row>
                    <e:label for="REG_INFO" title="${form_REG_INFO_N}"/>
                    <e:field>
                        <e:text id="REG_INFO" name="REG_INFO"></e:text>
                    </e:field>
                    <e:label for="MOD_INFO" title="${form_MOD_INFO_N}"/>
                    <e:field>
                        <e:text id="MOD_INFO" name="MOD_INFO"></e:text>
                    </e:field>
                </e:row>
            </e:searchPanel>

            <e:buttonBar id="btnRB" width="100%" align="right" title="${BS01_080_TITLE3}">
                <e:button id="Up" name="Up" label="${Up_N }" visible="${Up_V }" onClick="doMoveUp" />
                <e:button id="Down" name="Down" label="${Down_N }" visible="${Down_V }" onClick="doMoveDown" />
            </e:buttonBar>

            <e:gridPanel id="gridP" name="gridP" width="100%" height="fit" title="${BS01_080_TITLE3}" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridP.gridColData}" />

        </e:panel>
    </e:window>
</e:ui>
