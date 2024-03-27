<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var gridL;
    var gridR;
    var baseUrl = "/eversrm/eApproval/eApprovalModule/";

    function init() {
        gridL = EVF.C("gridL");
        gridR = EVF.C("gridR");

        gridL.setProperty("shrinkToFit", true);
        gridR.setProperty("shrinkToFit", true);
        gridR.setProperty("multiselect", false);

        gridL.cellChangeEvent(function (rowIdx, colIdx) {
            if (colIdx == "SIGN_REQ_TYPE") {
                recountSignSequence();
            }
        });

        gridR.cellClickEvent(function (rowIdx, colIdx) {
            if (colIdx == "SIGN_USER_NM") {
                var selectedData = gridR.getRowValue(rowIdx);
                gridR.checkRow(rowIdx, true);

                var addParam = [{
                    SIGN_USER_ID: selectedData.SIGN_USER_ID,
                    SIGN_USER_NM: selectedData.SIGN_USER_NM,
                    DEPT_CD: selectedData.DEPT_CD,
                    DEPT_NM: selectedData.DEPT_NM,
                    POSITION_NM: selectedData.POSITION_NM,
                    COMPANY_NM: selectedData.COMPANY_NM,
                    INSERT_FLAG: "Y",
                    SIGN_REQ_TYPE: (EVF.C("SIGN_REQ_TYPE").getCheckedValue() == null || EVF.C("SIGN_REQ_TYPE").getCheckedValue() == "") ? "E" : EVF.C("SIGN_REQ_TYPE").getCheckedValue()
                }];

                gridL.addRow(addParam);
                recountSignSequence();
            }
        });

        gridL._gvo.setCheckBar({
            checkableExpression: "values['SIGN_DATE'] is null"
        });
        gridL._gvo.applyCheckables();

        gridL._gvo.addCellStyle("style01", {
            editable: false,
            readOnly: true
        }, true);

        doSearchL();
    }

    function doSearchL() {
        var store = new EVF.Store();
        store.setGrid([gridL]);
        store.setParameter("APP_DOC_NUM", "${param.APP_DOC_NUM}");
        store.setParameter("APP_DOC_CNT", "${param.APP_DOC_CNT}");
        store.load(baseUrl + "bapp053_doSearchL", function () {
            if(gridL.getRowCount() > 0) {
                var allRowId = gridL.getAllRowId();

                for(var i in allRowId) {
                    var rowIdx = allRowId[i];

                    if(gridL.getCellValue(rowIdx, "SIGN_DATE") != "") {
                        gridL._gvo.setCellStyles(rowIdx, ["SIGN_REQ_TYPE"], "style01");
                    }
                }
            }
        });
    }
    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([gridR]);
        store.load(baseUrl + "bapp053_doSearch", function () {
            if (gridR.getRowCount() == 0) { alert("${msg.M0002 }"); }

            if (gridR.getRowCount() == 1) {
                EVF.C("SIGN_USER_NM").setValue("");

                var selectedData = gridR.getRowValue(0);
                gridR.checkRow(0, true);

                var addParam = [{
                    SIGN_USER_ID: selectedData.SIGN_USER_ID,
                    SIGN_USER_NM: selectedData.SIGN_USER_NM,
                    SIGN_USER_NM_$TP: selectedData.SIGN_USER_NM,
                    DEPT_CD: selectedData.DEPT_CD,
                    DEPT_NM: selectedData.DEPT_NM,
                    POSITION_NM: selectedData.POSITION_NM,
                    COMPANY_NM: selectedData.COMPANY_NM,
                    INSERT_FLAG: "Y",
                    SIGN_REQ_TYPE: (EVF.C('SIGN_REQ_TYPE').getCheckedValue() == null || EVF.C('SIGN_REQ_TYPE').getCheckedValue() == "") ? "E" : EVF.C('SIGN_REQ_TYPE').getCheckedValue()
                }];

                gridL.addRow(addParam);

                recountSignSequence();
            }
        });
    }

    function doUp() {
        if (gridL.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
        if (gridL.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

        var selectedRowId = gridL.jsonToArray(gridL.getSelRowId()).value[0];
        var selectedRowData = gridL.getRowValue(selectedRowId);

        if(!gridL._gvo.isCheckable(selectedRowId - 1)) {
            return alert("이미 결재된 건은 수정할 수 업습니다.");
        }

        gridL.setCellValue(selectedRowId, "CHECK_FLAG", "1");

        var store = new EVF.Store();
        store.setGrid([gridL]);
        store.setParameter("sortType", "up");
        store.getGridData(gridL, "all");
        store.load("/eversrm/eApproval/eApprovalBox/getRealignmentApprovalList", function () {
             recountSignSequence();

            var allRowId = gridL.getAllRowId();
            for(var i in allRowId) {
                var rowIdx = allRowId[i];

                if(gridL.getCellValue(rowIdx, "SIGN_DATE") != "") {
                    gridL._gvo.setCellStyles(rowIdx, ["SIGN_REQ_TYPE"], "style01");
                }
            }
        }, false);
    }

    function doDown() {
        if (gridL.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
        if (gridL.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

        var selectedRowId = gridL.jsonToArray(gridL.getSelRowId()).value[0];
        var selectedRowData = gridL.getRowValue(selectedRowId);

        gridL.setCellValue(selectedRowId, "CHECK_FLAG", "1");

        var store = new EVF.Store();
        store.setGrid([gridL]);
        store.setParameter("sortType", "down");
        store.getGridData(gridL, "all");
        store.load("/eversrm/eApproval/eApprovalBox/getRealignmentApprovalList", function () {
            recountSignSequence();

            var allRowId = gridL.getAllRowId();
            for(var i in allRowId) {
                var rowIdx = allRowId[i];

                if(gridL.getCellValue(rowIdx, "SIGN_DATE") != "") {
                    gridL._gvo.setCellStyles(rowIdx, ["SIGN_REQ_TYPE"], "style01");
                }
            }
        }, false);
    }

    function doDelete() {
        if (gridL.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

        gridL.delRow();

        recountSignSequence();
    }

    function doSave() {
        var store = new EVF.Store();
        store.setGrid([gridL]);
        store.getGridData(gridL, "all");
        store.setParameter("APP_DOC_NUM", "${param.APP_DOC_NUM}");
        store.setParameter("APP_DOC_CNT", "${param.APP_DOC_CNT}");
        store.load(baseUrl + "bapp053_doSave", function () {
            opener.doSearchGrid();
            EVF.closeWindow();
        });
    }
    function recountSignSequence() {

        <%-- 병렬타입의 행을 만났는지 여부 --%>
        var isBeforeArrangeAgree = false;
        var isBeforeArrangeApproval = false;
        var rowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
        var selectedRowIdx = [];
        for (var i = 0, pathSq = 0; i < rowIds.length; i++) {
            var rowData = gridL.getRowValue(rowIds[i]);
            var signReqType = rowData["SIGN_REQ_TYPE"];
            <%-- 병렬결재 혹은 병렬합의면 번호를 증가시키지 않는다. --%>
            if (signReqType === "P") {
                if (!isBeforeArrangeAgree) {
                    pathSq++;
                    isBeforeArrangeAgree = true;
                }
            } else {
                pathSq++;
                isBeforeArrangeAgree = false;
                isBeforeArrangeApproval = false;
            }

            var checkFlag = rowData["CHECK_FLAG"];
            if (checkFlag == "1") {
                selectedRowIdx.push(rowIds[i]);
            }

            gridL.setCellValue(rowIds[i], "CHECK_FLAG", "", false);
            gridL.setCellValue(rowIds[i], "SIGN_PATH_SQ", pathSq, false);
        }

        var allRowIds = gridL.jsonToArray(gridL.getAllRowId()).value;
        for (var j = 0; j < allRowIds.length; j++) {
            gridL.setCellValue(allRowIds[j], "CHECK_FLAG", " ", false);
        }

        for (var k = 0; k < selectedRowIdx.length; k++) {
            gridL.checkRow(selectedRowIdx[k], true);
        }
    }
</script>

<e:window id="BAPP_053" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="" columnCount="2" labelWidth="120" useTitleBar="false">
        <e:row>
            <e:label for="SIGN_USER_NM" title="${form_SIGN_USER_NM_N }"/>
            <e:field>
                <e:inputText id="SIGN_USER_NM" name="SIGN_USER_NM" value="" width="86%" maxLength="${form_SIGN_USER_NM_M}" required="${form_SIGN_USER_NM_R }" readOnly="${form_SIGN_USER_NM_RO }" disabled="${form_SIGN_USER_NM_D }" style="${imeMode }" onEnter="doSearch"/>
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            </e:field>
            <e:label for="DEPT_CD" title="${form_DEPT_CD_N }"/>
            <e:field>
                <e:inputText id="DEPT_CD" style="${imeMode }" name="DEPT_CD" value="" width="86%" readOnly="${form_DEPT_CD_RO }" maxLength="${form_DEPT_CD_M}" required="${form_DEPT_CD_R }" disabled="${form_DEPT_CD_D }" onFocus="onFocus" onEnter="doSearch"/>
                <e:button id="doSearch1" name="doSearch1" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            </e:field>
        </e:row>
    </e:searchPanel>

    <e:panel id="bg1" width="59%">
        <e:buttonBar id="buttonBarBottom" align="left" width="100%">
            <e:button id="doUp" name="doUp" label="${doUp_N}" onClick="doUp" disabled="${doUp_D}" visible="${doUp_V}"/>
            <e:button id="doDown" name="doDown" label="${doDown_N}" onClick="doDown" disabled="${doDown_D}" visible="${doDown_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <e:button id="doSave" name="doSave" align="right" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        </e:buttonBar>
    </e:panel>

    <e:panel id="null1" width="1%">&nbsp;</e:panel>

    <e:panel id="bg2" width="40%">
        <e:text style="font-weight:bold;">[${form_SIGN_REQ_TYPE_N }]&nbsp;&nbsp;</e:text>
        <e:radioGroup id="SIGN_REQ_TYPE" name="SIGN_REQ_TYPE" disabled="" readOnly="" required="">
            <e:radio id="R1" name="R1" label="결재" value="E" checked="true" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }"/>
            <e:radio id="R2" name="R2" label="합의" value="A" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }"/>
            <e:radio id="R4" name="R4" label="참조" value="CC" readOnly="${form_SIGN_REQ_TYPE_RO }" disabled="${form_SIGN_REQ_TYPE_D }"/>
        </e:radioGroup>
    </e:panel>

    <e:panel id="fg1" width="59%">
        <e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
    </e:panel>

    <e:panel id="null2" width="1%">&nbsp;</e:panel>

    <e:panel id="fg2" width="40%">
        <e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
    </e:panel>

</e:window>
</e:ui>

