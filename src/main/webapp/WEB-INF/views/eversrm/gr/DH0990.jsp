<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/DH0990"
                , grid;

        function init() {
            grid = EVF.C('grid');
            grid.setProperty('panelVisible', ${panelVisible});
            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'multiSelect') {
					<%--
                    grid.checkAll(false);
                    grid.checkRow(rowId, true);
                    --%>
                } else if(colId == 'INV_NUM') {

                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('SOG_030', 1000, 800, param);

                } else if(colId == 'PO_NUM') {

                    var param = {
                        "poNum": grid.getCellValue(rowId, 'PO_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('BPOM_020', 1300, 800, param);

                }
            });

            EVF.C('PURCHASE_TYPE').removeOption('DMRO');
        }

        function doSearch() {

            var store = new EVF.Store();

            if(!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

//            if(valid.equalColValid(grid, "PR_NUM", "")) {
//                return alert("${DH0990_002}"); // 품의번호를 입력하여 주시기 바랍니다.
//            }

//            if(valid.equalColValid(grid, "LINK", "")) {
//                return alert("${DH0990_003 }"); // 링크를 입력하여 주시기 바랍니다.
//            }




            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {

                var rowId = selRowId[i];
                var inspectUserId = grid.getCellValue(rowId, 'INSPECT_USER_ID');

                <%-- 공장별 권한 적용 2016.01.18 DAGURI
                if(inspectUserId != '${ses.userId}') {
                    return alert('${msg.M0008}');
                }
                --%>
            }

            var store = new EVF.Store();
            if(!confirm('${msg.M0021}')) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+'/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doCancel() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {

                var rowId = selRowId[i];
                var inspectUserId = grid.getCellValue(rowId, 'INSPECT_USER_ID');

                <%-- 공장별 권한 적용 2016.01.18 DAGURI
                if(inspectUserId != '${ses.userId}') {
                    return alert('${msg.M0008}');
                }
                --%>

                if(EVF.isNotEmpty(grid.getCellValue(rowId, 'DEAL_NUM'))) {
                    return alert('${DH0990_004}'); <%-- 이미 송장이 생성된 건입니다. 처리할 수 없습니다. --%>
                }
            }

            if (!confirm('${DH0990_001}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doCancel', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doPrint(){
            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            /*
            var urlPath = document.location.protocol + "//" + document.location.host;
            var url = urlPath + "/ClipReport4/JavaOOFGenerator_Popup.jsp";

            var param = {
                'crfName': 'trading_statement.crf',
                'crfDbName': 'sql',
                'crfParams': "GATE_CD:100^INV_NUM:"+grid.getSelRowValue()[0]['INV_NUM'] // 샘플확인 번호 : IV151100013
            };

            everPopup.openWindowPopup(url, 1000, 700, param, "reportPopup");
            */

            var param = {
                'inv_num': grid.getSelRowValue()[0]['INV_NUM'] // 샘플확인 번호 : IV151100013
            };
            everPopup.printInvoice(param);
        }
    </script>
    <e:window id="DH0990" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="INSPECT_DATE_2" title="${form_INSPECT_DATE_2_N}"/>
                <e:field>
                    <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
                    <e:text> ~ </e:text>
                    <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
                </e:field>
                <e:label for="INSPECT_USER_NM" title="${form_INSPECT_USER_NM_N}" />
                <e:field>
                    <e:inputText id="INSPECT_USER_NM" style="${imeMode}" name="INSPECT_USER_NM" value="${ses.userNm}" width="${inputTextWidth}" maxLength="${form_INSPECT_USER_NM_M}" disabled="${form_INSPECT_USER_NM_D}" readOnly="${form_INSPECT_USER_NM_RO}" required="${form_INSPECT_USER_NM_R}"/>
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}" />
                <e:field>
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="${inputTextWidth}" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
                <e:label for="DL_FLAG" title="${form_DL_FLAG_N}"/>
                <e:field>
                    <e:select id="DL_FLAG" name="DL_FLAG" value="${form.DL_FLAG}" options="${dlFlagOptions}" width="${inputTextWidth}" disabled="${form_DL_FLAG_D}" readOnly="${form_DL_FLAG_RO}" required="${form_DL_FLAG_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
