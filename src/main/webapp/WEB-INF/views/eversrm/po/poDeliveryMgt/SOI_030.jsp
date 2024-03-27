<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <link rel="stylesheet" type="text/css" href="/ClipReport4/css/clipreport.css">
    <script type='text/javascript' src='/ClipReport4/js/clipreport.js'></script>
    <script type='text/javascript' src='/ClipReport4/js/UserConfig.js'></script>
    <script type="text/javascript">

        var baseUrl = "/eversrm/po/deliveryMgt/SOI_030"
                , grid;
        var flag = 0;

        function init() {
            grid = EVF.C('grid');
            grid.setProperty('panelVisible', ${panelVisible});
            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'multiSelect') {
                    if(flag == 0) {
                        var invNum = grid.getCellValue(rowId, 'INV_NUM');
                        var invSq = grid.getCellValue(rowId, 'INV_SQ');

                        grid.checkAll(false);
                        var gridData = grid.getAllRowValue();
                        for (var i in gridData) {

                            var item = gridData[i];
                            if (invNum == item['INV_NUM']) {
                                grid.checkRow(i, true);
                            }

                            if (gridData.length == parseInt(i) + 1) {
                                flag = 0;
                            } else {
                                flag = 1;
                            }
                        }
                    }

                } else if(colId == 'INV_NUM') {

                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('SOI_020', 1000, 800, param);

                } else if(colId == 'PO_NUM') {

                    everPopup.printPoReport(grid.getCellValue(rowId, 'PO_NUM'))


                }
            });

            $('#cb_grid_table').remove();

            EVF.C('PURCHASE_TYPE').removeOption('DMRO');
        }

        function doSearch() {

            var store = new EVF.Store();

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
            });
        }

        function doChange() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var param = {
                "invNum": grid.getSelRowValue()[0]['INV_NUM'],
                "detailView": false
            };
            everPopup.openPopupByScreenId('SOI_020', 1000, 800, param);

        }

        function doDelete() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!confirm('${msg.M0013}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter('invNum', grid.getSelRowValue()[0]['INV_NUM']);
            store.load(baseUrl + '/doDelete', function () {
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
    <e:window id="SOI_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }" >
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="">
                    <e:select id="COMBO_DATE" name="COMBO_DATE" usePlaceHolder="false" width="100" required="${form_COMBO_DATE_R}" disabled="${form_COMBO_DATE_D }" readOnly="${form_COMBO_DATE_RO}">
                        <e:option text="${SOI_030_INV_DATE}" value="INV_DATE">${SOI_030_INV_DATE}</e:option>
                        <e:option text="${SOI_030_DUE_DATE}" value="DUE_DATE">${SOI_030_DUE_DATE}</e:option>
                        <e:option text="${SOI_030_PO_DATE}" value="PO_DATE">${SOI_030_PO_DATE}</e:option>
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
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="100%" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="INV_NUM" title="${form_INV_NUM_N}"/>
                <e:field>
                    <e:inputText id="INV_NUM" style="ime-mode:inactive" name="INV_NUM" value="${form.INV_NUM}" width="100%" maxLength="${form_INV_NUM_M}" disabled="${form_INV_NUM_D}" readOnly="${form_INV_NUM_RO}" required="${form_INV_NUM_R}"/>
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
                <e:field>
                    <e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder=""/>
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doChange" name="doChange" label="${doChange_N}" onClick="doChange" disabled="${doChange_D}" visible="${doChange_V}"/>
            <%-- 2015.11.24 daguriKing 삭제버튼 비활성
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            --%>
            <e:button id="doPrint"  name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
