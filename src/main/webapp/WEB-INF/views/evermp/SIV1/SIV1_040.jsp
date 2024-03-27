<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/SIV1/SIV104/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;
                // 주문자
                if(colId == 'CPO_USER_NM') {
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, 'CPO_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId === "ITEM_CD") {
                    if(value !== ""){
                        param = {
                            ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                            popupFlag: true,
                            detailView: true
                        };
                        everPopup.im03_014open(param);
                    }
                } else if(colId == "DELY_REJECT_NM") { // 납품거부상세사유
                    if( grid.getCellValue(rowId, 'DELY_REJECT_CD') == "" ) return;
                    param = {
                        title: '납품거부사유',
                        CODE: grid.getCellValue(rowId, 'DELY_REJECT_CD'),
                        TEXT: grid.getCellValue(rowId, 'DELY_REJECT_REASON'),
                        detailView: 'true'
                    };
                    var url = '/evermp/SIV1/SIV101/SIV1_023/view';
                    everPopup.openModalPopup(url, 600, 360, param);
                } else if(colId == 'MANAGE_NM') { // 표준화담당자
                    if( grid.getCellValue(rowId, 'MANAGE_ID') == '' ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, 'MANAGE_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == 'RECIPIENT_NM') { // 인수자
                    if( grid.getCellValue(rowId, 'RECIPIENT_NM') == '' ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowId, 'CPO_NO'),
                        CPO_SEQ: grid.getCellValue(rowId, 'CPO_SEQ'),
                        detailView: 'true'
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colId == 'DELY_RMK') { // 주문요청사항
                    if( grid.getCellValue(rowId, 'DELY_RMK') == '' ) return;
                    param = {
                        title: '주문요청사항',
                        message: grid.getCellValue(rowId, 'DELY_RMK'),
                        detailView: true,
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_view/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                } else if(colId == 'AGENT_ATTACH_FILE_CNT') {
                    if (grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_CNT') == '0') return;
                    everPopup.readOnlyFileAttachPopup('CPO', grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_NO'), '', rowId);
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 310, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            if("${param.autoSearchFlag}" == "Y") { doSearch(); }

            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);

            grid.freezeCol("CPO_USER_DEPT_NM");
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "SIV1_040/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doCancelReject() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if (!confirm("${SIV1_040_002 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'SIV1_040/doCancelReject', function() {
                alert(this.getResponseMessage());
                doSearch();
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
                alert("${SIV1_040_001}");
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
            data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS3);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCustUserId() {
            var custCd = EVF.V("CUST_CD");
            if( custCd == "" ) {
                alert("${SIV1_040_001}");
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

    <e:window id="SIV1_040" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="DEPT_NM" title="${form_DEPT_NM_N}"/>
                <e:field>
                    <e:inputHidden id="DEPT_CD" name="DEPT_CD" />
                    <e:search id="DEPT_NM" name="DEPT_NM" value="" width="${form_DEPT_NM_W}" maxLength="${form_DEPT_NM_M}" onIconClick="searchCustDeptCd" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
                </e:field>
                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${SIV1_040_010}" value="CPO_DATE"/>
                        <e:option text="${SIV1_040_011}" value="DELY_REJECT_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${addFromDate }" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${addToDate }" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
                <e:label for="DOC_NUM">
                    <e:select id="DOC_NUM_COMBO" name="DOC_NUM_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${SIV1_040_012}" value="CPO_NO_SEQ"/>
                        <e:option text="${SIV1_040_013}" value="CPO_NO"/>
                        <e:option text="${SIV1_040_014}" value="PO_NO"/>
                        <e:option text="${SIV1_040_015}" value="REF_MNG_NO"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputText id="DOC_NUM" name="DOC_NUM" value="" width="80%" maxLength="${form_DOC_NUM_M}" disabled="${form_DOC_NUM_D}" readOnly="${form_DOC_NUM_RO}" required="${form_DOC_NUM_R}" />
                    <e:check id="EXCLUDE" name="EXCLUDE" value="1"/><e:text>${msg.M0204}</e:text>
                </e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="" options="${itemUserOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="DELY_REJECT_CD" title="${form_DELY_REJECT_CD_N}"/>
                <e:field>
                    <e:select id="DELY_REJECT_CD" name="DELY_REJECT_CD" value="" options="${delyRejectCdOptions}" width="${form_DELY_REJECT_CD_W}" disabled="${form_DELY_REJECT_CD_D}" readOnly="${form_DELY_REJECT_CD_RO}" required="${form_DELY_REJECT_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doCancelReject" name="doCancelReject" label="${doCancelReject_N}" onClick="doCancelReject" disabled="${doCancelReject_D}" visible="${doCancelReject_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>