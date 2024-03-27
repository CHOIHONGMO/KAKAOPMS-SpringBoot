<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cont/CT0110/";
		var gwUseFlag = 'N';   <%-- GW 결재여부--%>

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {

                if (colId == 'FORM_NM') {
                    var formNum = grid.getCellValue(rowId, 'FORM_NUM');
                    everPopup.openPopupByScreenId('CT0120', 1000, 800, {
                        callBackFunction: callBackFunction,
                        formNum: formNum,
                        detailView: true
                    });
                }
            });

            grid.setProperty('panelVisible'	, ${panelVisible});
            grid.setProperty('singleSelect'	, true);
            grid.setProperty('shrinkToFit'	, true);

            grid.excelExportEvent({
                allCol	 : "${excelExport.allCol}",
                selRow	 : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }"
            });

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }

        function doCreate() {
            everPopup.openPopupByScreenId('ECOB0010', 1200, 800, {
                callBackFunction: callBackFunction,
                detailView: false
            });
        }

        function doCreateNew() {
            everPopup.openPopupByScreenId('CT0120', 1000, 800, {
                callBackFunction: callBackFunction,
                detailView: false
            });
        }

        function doCopy() {

            if (!grid.isExistsSelRow()) {
                return EVF.alert('${msg.M0004}');
            }
            EVF.confirm("${CT0110_001 }", function () {

    	        var selRowId = grid.getSelRowId();
    			var rowId = selRowId[0];
                var formNum = grid.getCellValue(rowId, 'FORM_NUM');
                everPopup.openPopupByScreenId('CT0120', 1000, 800, {
                    //callBackFunction: callBackFunction,
                    COPY_YN 	: 'Y',
                    formNum		: formNum,
                    detailView	: false
                });

            	return;
            	var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl + 'doCopy', function () {
                    EVF.alert(this.getResponseMessage(), function() {
                        doSearch();
                    });
                });


            });
        }

        function doChange() {

            var gridData = grid.getSelRowValue();
            if (gridData.length > 0) {
                var valid = grid.validate();
                if (!valid.flag) {
                    return EVF.alert(valid.msg);
                }
            } else if (gridData.length == 0) {
                return EVF.alert('${msg.M0004 }');
            } else if (gridData.length > 1) {
                return EVF.alert("${msg.M0006}");
            }

            var formNum = gridData[0]['FORM_NUM'];
            everPopup.openPopupByScreenId('CT0120', 1000, 800, {
                callBackFunction : callBackFunction,
                formNum			 : formNum,
                detailView		 : false
            });
        }

        function doDelete() {

            if (!grid.isExistsSelRow()) {
                return EVF.alert('${msg.M0004}');
            }

            EVF.confirm("${CT0110_004 }", function () {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl + 'doDelete', function () {
                    EVF.alert(this.getResponseMessage(), function() {
                        doSearch();
                        delRows = [];
                    });
                });
            });
        }

        function openDeptPopup() {
            everPopup.openCommonPopup({
                callBackFunction : 'deptPopupCallBack',
                BUYER_CD		 : '${ses.companyCd}'
            }, 'SP0002');
        }

        function deptPopupCallBack(result) {
            EVF.C('DEPT_CD').setValue(result.DEPT_CD);
        }

        function callBackFunction() {

        }

        function doReplace() {
            var store = new EVF.Store();
            store.load(baseUrl+"/doReplace", function() {

            });
        }

    </script>

    <e:window id="CT0110" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

        <e:inputHidden id="DEPT_CD" name="DEPT_CD"/>
        <e:inputHidden id="FORM_ROLE_TYPE" name="FORM_ROLE_TYPE"/>
        <e:inputHidden id="APPROVAL_FLAG" name="APPROVAL_FLAG"/>
        <e:inputHidden id="DEPT_FLAG" name="DEPT_FLAG"/>

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="125" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="FORM_TYPE" title="${form_FORM_TYPE_N }"/>
                <e:field>
                    <e:select id="FORM_TYPE" name="FORM_TYPE" value="0" options="${formTypes}" readOnly="${form_FORM_TYPE_RO }" width="100%" required="${form_FORM_TYPE_R }" disabled="${form_FORM_TYPE_D }"/>
                </e:field>
                <e:label for="CONTRACT_FORM_TYPE" title="${form_CONTRACT_FORM_TYPE_N}"/>
                <e:field>
                    <e:select id="CONTRACT_FORM_TYPE" name="CONTRACT_FORM_TYPE" value="" options="${contractFormTypeOptions}" width="${form_CONTRACT_FORM_TYPE_W}" disabled="${form_CONTRACT_FORM_TYPE_D}" readOnly="${form_CONTRACT_FORM_TYPE_RO}" required="${form_CONTRACT_FORM_TYPE_R}" placeHolder="" />
                </e:field>
				<%--회사--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
				</e:field>

            </e:row>
            <e:row>
                <e:label for="FORM_NM" title="${form_FORM_NM_N }"/>
                <e:field>
                    <e:inputText id="FORM_NM" style="${imeMode}" name="FORM_NM" width="100%" required="${form_FORM_NM_R }" disabled="${form_FORM_NM_D }" value="" readOnly="${form_FORM_NM_RO }" maxLength="${form_FORM_NM_M}"/>
                </e:field>

                <e:label for="ECONT_FLAG" title="${form_ECONT_FLAG_N}"/>
                <e:field>
                    <e:select id="ECONT_FLAG" name="ECONT_FLAG" value="" options="${econtFlagOptions}" width="${form_ECONT_FLAG_W}" disabled="${form_ECONT_FLAG_D}" readOnly="${form_ECONT_FLAG_RO}" required="${form_ECONT_FLAG_R}" placeHolder="" />
                </e:field>
                <e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
                <e:field>
                    <e:select id="USE_FLAG" name="USE_FLAG" value="1" options="${useFlagOptions}" width="${form_USE_FLAG_W}" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
                </e:field>

            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
            <c:if test="${ses.superUserFlag eq '1'}">
	            <e:button id="doCreateNew" name="doCreateNew" label="${doCreateNew_N }" onClick="doCreateNew" disabled="${doCreateNew_D }" visible="${doCreateNew_V}"/>
                <e:button id="doCopy" name="doCopy" label="${doCopy_N }" onClick="doCopy" disabled="${doCopy_D }" visible="${doCopy_V}"/>
	            <e:button id="doChange" name="doChange" label="${doChange_N }" onClick="doChange" disabled="${doChange_D }" visible="${doChange_V}"/>
	            <e:button id="doDelete" name="doDelete" label="${doDelete_N }" onClick="doDelete" disabled="${doDelete_D }" visible="${doDelete_V}"/>
            </c:if>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
