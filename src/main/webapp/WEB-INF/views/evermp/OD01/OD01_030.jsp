<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD01/OD0101/";
        var autoSearchFlag = '${form.autoSearchFlag}';
        var callType = '${form.callType}';

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('multiSelect', true);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("autoSearchFlag", autoSearchFlag);
            store.setParameter("callType", callType);
            store.load(baseUrl + "OD01_030/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
        }

        function searchCustDeptCd() {
            var custCd = EVF.V("CUST_CD");
            var custNm = EVF.V("CUST_NM");

            if( custCd == "" ) {
                alert("${OD01_030_001}");
                return;
            }

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "selectCustDeptCd",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : custCd,
                'custNm' : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function selectCustDeptCd(dataJsonArray) {
            var data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function searchCustUserId() {
            var custCd = EVF.V("CUST_CD");
            if( custCd == "" ) {
                alert("${OD01_030_001}");
                return;
            }

            var param = {
                callBackFunction: "selectCustUserId",
                custCd: custCd
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function selectCustUserId(dataJsonArray) {
            EVF.C("CPO_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CPO_USER_NM").setValue(dataJsonArray.USER_NM);
        }

    </script>

    <e:window id="OD01_030" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <%-- 전송일자 / 주문일자 --%>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD01_030_0001}" value="IF_DATE"/>
                        <e:option text="${OD01_030_0002}" value="GR_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${empty param.yesterday ? addFromDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${empty param.yesterday ? addToDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
                <%-- 고객사 --%>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <%-- 입고자명 --%>
                <e:label for="GR_USER_NM" title="${form_GR_USER_NM_N}" />
                <e:field>
                    <e:inputText id="GR_USER_NM" name="GR_USER_NM" value="" width="${form_GR_USER_NM_W}" maxLength="${form_GR_USER_NM_M}" disabled="${form_GR_USER_NM_D}" readOnly="${form_GR_USER_NM_RO}" required="${form_GR_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <%-- 주문번호 --%>
                <e:label for="IF_CPO_NO" title="${form_IF_CPO_NO_N}" />
                <e:field>
                    <e:inputText id="IF_CPO_NO" name="IF_CPO_NO" value="" width="${form_IF_CPO_NO_W}" maxLength="${form_IF_CPO_NO_M}" disabled="${form_IF_CPO_NO_D}" readOnly="${form_IF_CPO_NO_RO}" required="${form_IF_CPO_NO_R}" />
                </e:field>
                <%-- 입고번호 --%>
                <e:label for="GR_NO" title="${form_GR_NO_N}" />
                <e:field>
                    <e:inputText id="GR_NO" name="GR_NO" value="" width="${form_GR_NO_W}" maxLength="${form_GR_NO_M}" disabled="${form_GR_NO_D}" readOnly="${form_GR_NO_RO}" required="${form_GR_NO_R}" />
                </e:field>
                <%-- 상태 --%>
                <e:label for="IF_STATUS" title="${form_IF_STATUS_N}"/>
                <e:field>
                    <e:select id="IF_STATUS" name="IF_STATUS" value="" options="${ifStatusOptions}" width="${form_IF_STATUS_W}" disabled="${form_IF_STATUS_D}" readOnly="${form_IF_STATUS_RO}" required="${form_IF_STATUS_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar width="100%" align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>