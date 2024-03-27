<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var grid = {};
        var baseUrl = "/eversrm/po/poMgt/poProgress/BPOP_040/";

        function init() {
            grid = EVF.getComponent("grid");

            EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
            grid.setProperty('panelVisible', ${panelVisible});
            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12      <%-- // 이미지의 너비. --%>
                    , imgHeight: 0.26      <%-- // 이미지의 높이. --%>
                    , colWidth: 20        <%-- // 컬럼의 넓이. --%>
                    , rowSize: 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                    , attachImgFlag: false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

                switch (colId) {
                    case 'ITEM_CD':
                        var param = {
                            GATE_CD: grid.getCellValue(rowId, "GATE_CD"),
                            ITEM_CD: grid.getCellValue(rowId, "ITEM_CD")
                        };
                        everPopup.openItemDetailInformation(param);
                        break;

                    case 'PO_NUM':

                        var param = {
                            "poNum": grid.getCellValue(rowId, 'PO_NUM'),
                            "detailView": true
                        };
                        everPopup.openPopupByScreenId('BPOM_020', 1200, 800, param);
                        break;

                    case 'PROGRESS_DETAIL':
                        var param = {
                            poNum: grid.getCellValue(rowId, "PO_NUM"),
                            poSq: grid.getCellValue(rowId, "SEQ"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BPOP_050", 1200, 600, param);
                        break;

                    case 'VENDOR_CD':
                        var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: true
                        };
                        everPopup.openSupManagementPopup(param);
                        break;

                    case 'FORCE_CLOSE_DATE':

                        if(EVF.isEmpty(grid.getCellValue(rowId, 'FORCE_CLOSE_DATE'))) {
                            return;
                        }

                        var param = {
                            "TEXT_CONTENTS": grid.getCellValue(rowId, "FORCE_CLOSE_RMK"),
                            "detailView": true
                        };

                        everPopup.openWindowPopup('/common/popup/commonTextContents/view', 700, 320, param, 'common_text_input');

                        break;

                    default:
                        return;
                }
            });

            EVF.getComponent("COMBO_DATE").setValue('PO_DATE');
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if (!everDate.fromTodateValid('FROM_DATE', 'TO_DATE', '${ses.dateFormat }')) return alert('${msg.M0073}');

            store.setGrid([grid]);
            store.load(baseUrl + 'doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }

            });
        }

        function doSearchBuyer() {
            everPopup.openCommonPopup({
                callBackFunction: "selectBuyer"
            }, 'SP0040');
        }
        function selectBuyer(data) {
            EVF.getComponent("CTRL_USER_ID").setValue(data.CTRL_USER_ID);
            EVF.getComponent("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
        }
        function doSearchVendor() {
            everPopup.openCommonPopup({
                callBackFunction: "selectVendor"
            }, 'SP0016');
        }
        function selectVendor(data) {
            EVF.getComponent("VENDOR_CD").setValue(data['VENDOR_CD']);
        }
        function doSearchItem() {
            everPopup.openCommonPopup({
                callBackFunction: "selectItem"
            }, 'SP0018');
        }
        function selectItem(data) {
            EVF.getComponent("ITEM_CD").setValue(data['ITEM_CD']);
        }
        function doSearchPurGroup() {
            everPopup.openCommonPopup({
                callBackFunction: "selectPurGroup"
            }, 'SP0021');
        }
        function selectPurGroup(data) {
            EVF.getComponent("PG_CD").setValue(data['CTRL_CD']);
        }
        function readyToTerminate() {

            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length == 0) return alert("${msg.M0004}");

            for (var idx in gridDatas) {
                var rowData = gridDatas[idx];

                if (rowData['CTRL_USER_ID'] != "${ses.userId }") {
                    return alert("${msg.M0008}");
                }
                if (rowData['FORCE_CLOSE_DATE'] != "") {
                    return alert("${BPOP_040_001}");
                }
            }

            var param = {
                "detailView": false,
                "title": '발주종결사유',
                "callbackFunction": "doTerminate"
            };
            everPopup.openWindowPopup('/common/popup/common_text_input/view', 700, 310, param, 'common_text_input');
        }

        function doTerminate(data) {

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

            var hasInspectionPo = false;
            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {

                var rowId = selRowId[i];
                grid.setCellValue(rowId, 'FORCE_CLOSE_RMK', data.message);

                var deliveryType = grid.getCellValue(rowId, 'DELIVERY_TYPE');
                if(deliveryType == 'PI') {
                    hasInspectionPo =  true;
                }
            }

            if(hasInspectionPo) {
                if(!confirm('${BPOP_040_005}')) {
                    return;
                }
            }

            if (!confirm("${BPOP_040_002}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("terminateType", "ITEM");
            store.load(baseUrl + 'doTerminate', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doCreateDO() {
            var gridDatas = grid.getSelRowValue();
            if (gridDatas.length != 1) return alert("${msg.M0004}");

            var poNum = "";
            var poSq = "";
            for (var idx in gridDatas) {
                var rowData = gridDatas[idx];

                if (rowData['CTRL_USER_ID'] != "${ses.userId }" || rowData['DO_OWNER_TYPE'] != "${ses.userType }") return alert("${msg.M0008}");
                if (rowData['SIGN_STATUS'] != "E")     return alert("${msg.M0047}");
                if (rowData['FORCE_CLOSE_DATE'] != "") return alert("${BPOP_040_001}");
                if (rowData['DELIVERY_TYPE'] == "PI")  return alert("${BPOP_040_CAN_NOT_CREATE_DO}");

                poNum = rowData['PO_NUM'];
                poSq = rowData['PO_SQ'];
            }

            var params = {
                poNum: poNum,
                poSq: poSq,
                detailView: false
            };
            everPopup.openDoDetailInformation(params);
        }

        function doSave() {

        	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var gridData = grid.getSelRowValue();
            for (var idx in gridData) {
                var rowData = gridData[idx];
                <%--
                if (rowData['PURCHASE_TYPE'] != 'NORMAL') {
                    return alert('${BPOP_040_004}');
                }
                --%>
                if (rowData['EXPORT_DATE'] == '') {
                    return alert('${BPOP_040_003}');
                }
            }

            var store = new EVF.Store();
            if (!confirm('${msg.M0021}')) {
                return;
            }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'doSave', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="BPOP_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="100" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="">
                    <e:select id="COMBO_DATE" name="COMBO_DATE" usePlaceHolder="false" width="100" required="${form_COMBO_DATE_R}" disabled="${form_COMBO_DATE_D }" readOnly="${form_COMBO_DATE_RO}">
                        <e:option text="${BPOP_040_PO_DATE}" value="PO_DATE">${BPOP_040_PO_DATE}</e:option>
                        <e:option text="${BPOP_040_DELIVERY_DATE}" value="DELIVERY_DATE">${BPOP_040_DELIVERY_DATE}</e:option>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
                    <e:text> ~ </e:text>
                    <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder=""/>
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" name="PO_NUM" value="" width="${inputTextWidth }" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:search id="ITEM_CD" name="ITEM_CD" value="" width="40%" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'doSearchItem'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                    <e:text>&nbsp;</e:text>
					<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="50%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:search id="CTRL_USER_ID" style="ime-mode:inactive" name="CTRL_USER_ID" value="${ses.userId }" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_RO ? 'everCommon.blank' : 'doSearchBuyer'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${ses.userNm }" width="${inputTextWidth }" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field colSpan="3">
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder=""/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doTerminate" name="doTerminate" label="${doTerminate_N}" onClick="readyToTerminate" disabled="${doTerminate_D}" visible="${doTerminate_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
