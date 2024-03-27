<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD02/OD0201/";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('sortable', false);

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;

                if(colId === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO")
                        };
                        everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
                    }
                } else if (colId == "CPO_SEQ") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if(colId == 'CPO_USER_NM') { // 주문자
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        USER_ID: grid.getCellValue(rowId, 'CPO_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colId == "ITEM_CD") {
                    param = {
                        ITEM_CD: grid.getCellValue(rowId, 'ITEM_CD'),
                        popupFlag: true,
                        detailView: true
                    };
                    everPopup.im03_014open(param);
                } else if(colId == "DELY_DELAY_NM") { // 납품지연상세사유
                    var delyCd = grid.getCellValue(rowId, 'DELY_DELAY_CD');
                    if( delyCd == "" ) return;
                    param = {
                        title: '납품지연사유',
                        CODE: grid.getCellValue(rowId, 'DELY_DELAY_CD'),
                        TEXT: grid.getCellValue(rowId, 'DELY_DELAY_REASON'),
                        rowId: rowId,
                        detailView: 'true'
                    };
                    var url = '/evermp/SIV1/SIV101/SIV1_022/view';
                    everPopup.openModalPopup(url, 600, 360, param);
                } else if(colId == 'MANAGE_NM') {// 진행관리담당자
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
                } else if(colId == 'REQ_TEXT') { // 주문요청사항
                    if( grid.getCellValue(rowId, 'REQ_TEXT') == '' ) return;
                    param = {
                        title: '주문요청사항',
                        message: grid.getCellValue(rowId, 'REQ_TEXT'),
                        detailView: true,
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_view/view';
                    everPopup.openModalPopup(url, 500, 310, param);
                } else if(colId == 'ATTACH_FILE_CNT') { // 주문 첨부파일 업로드
                    if( grid.getCellValue(rowId, 'ATTACH_FILE_CNT') == '0' ) return;
                    everPopup.readOnlyFileAttachPopup('CPO',grid.getCellValue(rowId, 'ATTACH_FILE_NO'),'',rowId);
                } else if(colId == 'AGENT_ATTACH_FILE_CNT') {
                    if( grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_CNT') == '0' ) return;
                    everPopup.readOnlyFileAttachPopup('CPO',grid.getCellValue(rowId, 'AGENT_ATTACH_FILE_NO'),'',rowId);
                } else if(colId == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        rowId: rowId,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 310, param);
                }else if (colId == "VENDOR_NM") {
                    param = {
                        VENDOR_CD: grid.getCellValue(rowId, 'VENDOR_CD'),
                        detailView: true,
                        popupFlag: true
                    };

                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {
                    case 'DELY_COMPLETE_DATE':
                        if( newValue > '${addToDate }' ) {
                            grid.setCellValue(rowId, 'DELY_COMPLETE_DATE', oldValue);
                            return alert("${OD02_030_006 }");
                        }
                    default:
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);
            grid.setColIconify("AGENT_MEMO", "AGENT_MEMO", "comment", false);

            grid.freezeCol("GR_COMPLETE_FLAG");
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "OD02_030/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                grid.setColMerge(['CUST_NM','CPO_USER_DEPT_NM','CPO_USER_NM','CPO_NO','CPO_SEQ','DEAL_NM','PRIOR_GR_FLAG','PO_NO','REF_MNG_NO',
                    'ITEM_CD','CUST_ITEM_CD','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM','ORIGIN_CD','UNIT_CD','CPO_QTY',
                    'CUR','PO_UNIT_PRICE','TAX_NM','VENDOR_ITEM_CD','CPO_DATE','LEAD_TIME_DATE','HOPE_DUE_DATE',
                    'RECIPIENT_NM','RECIPIENT_DEPT_NM','RECIPIENT_TEL_NUM','RECIPIENT_CELL_NUM','DELY_ZIP_CD','DELY_ADDR_1','DELY_ADDR_2']);
            });
        }

        function doAllApply() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var delyDate = EVF.V("DELY_COMPLETE_DATE");
            if( delyDate == "" || delyDate.length != 8 ) {
                EVF.C("DELY_COMPLETE_DATE").setFocus();
                return alert("${OD02_030_007 }");
            }
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                grid.setCellValue(rowIds[i], 'DELY_COMPLETE_DATE', delyDate);
            }
        }

        function doComplete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "1" ) {
                    return alert("${OD02_030_004 }");
                }
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_DATE') > '${addToDate }' ) {
                    return alert("${OD02_030_006 }");
                }
            }

            if (!confirm("${OD02_030_002 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_030/doCompleteDely', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doCancel() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'DELY_COMPLETE_FLAG') == "0" ) {
                    return alert("${OD02_030_005 }");
                }
                if( grid.getCellValue(rowIds[i], 'GR_COMPLETE_FLAG') == "1" ) {
                    return alert("${OD02_030_008 }");
                }
            }

            if (!confirm("${OD02_030_003 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'OD02_030/doCancelDely', function() {
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
                alert("${OD02_030_001}");
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
                alert("${OD02_030_001}");
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

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

    </script>

    <e:window id="OD02_030" onReady="init" initData="${initData}" title="${fullScreenName}">
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
                        <e:option text="${OD02_030_010}" value="REG_DATE"/>
                        <e:option text="${OD02_030_011}" value="DELY_APP_DATE"/>
                        <e:option text="${OD02_030_012}" value="CPO_DATE"/>
                        <e:option text="${OD02_030_013}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${addFromDate }" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${addToDate }" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
                <e:label for="DOC_NUM">
                    <e:select id="DOC_NUM_COMBO" name="DOC_NUM_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD02_030_014}" value="CPO_NO_SEQ"/>
                        <e:option text="${OD02_030_015}" value="CPO_NO"/>
                        <e:option text="${OD02_030_016}" value="PO_NO"/>
                        <e:option text="${OD02_030_019}" value="IF_INVC_CD"/>
                        <e:option text="${OD02_030_017}" value="REF_MNG_NO"/>
                        <e:option text="${OD02_030_018}" value="IV_NO"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputText id="DOC_NUM" name="DOC_NUM" value="" width="80%" maxLength="${form_DOC_NUM_M}" disabled="${form_DOC_NUM_D}" readOnly="${form_DOC_NUM_RO}" required="${form_DOC_NUM_R}" />
                    <e:check id="EXCLUDE" name="EXCLUDE" value="1"/><e:text>${msg.M0204}</e:text>
                </e:field>
                <e:label for="DELY_COMPLETE_FLAG" title="${form_DELY_COMPLETE_FLAG_N}"/>
                <e:field>
                    <e:select id="DELY_COMPLETE_FLAG" name="DELY_COMPLETE_FLAG" value="${defaultFlagCd }" options="${delyCompleteFlagOptions}" width="${form_DELY_COMPLETE_FLAG_W}" disabled="${form_DELY_COMPLETE_FLAG_D}" readOnly="${form_DELY_COMPLETE_FLAG_RO}" required="${form_DELY_COMPLETE_FLAG_R}" placeHolder="" />
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
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:search id="MAKER_CD" name="MAKER_CD" value="" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="searchMakerCd" disabled="${form_MAKER_CD_D}" readOnly="${form_MAKER_CD_RO}" required="${form_MAKER_CD_R}" />
                    <e:inputText id="MAKER_NM" name="MAKER_NM" value="" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:panel id="leftP1" height="fit" width="10%">
            <e:text style="font-weight: bold;">●&nbsp;${OD02_030_CAPTION1} &nbsp;:&nbsp; </e:text>
        </e:panel>
        <e:panel id="leftP2" height="fit" width="30%">
            <e:inputDate id="DELY_COMPLETE_DATE" name="DELY_COMPLETE_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_DELY_COMPLETE_DATE_R}" disabled="${form_DELY_COMPLETE_DATE_D}" readOnly="${form_DELY_COMPLETE_DATE_RO}" />
            <e:text>&nbsp;</e:text>
            <e:button id="doAllApply" name="doAllApply" label="${doAllApply_N}" onClick="doAllApply" disabled="${doAllApply_D}" visible="${doAllApply_V}"/>
        </e:panel>

        <e:panel id="rightP1" height="fit" width="60%">
            <e:buttonBar align="right" width="100%">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                <e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
                <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
            </e:buttonBar>
        </e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>