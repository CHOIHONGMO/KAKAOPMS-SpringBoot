<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/po/deliveryMgt/SOI_010",
                grid;

        function init() {
            grid = EVF.C('grid');
            grid.setProperty('panelVisible', ${panelVisible});
            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'PO_NUM') {



                    everPopup.printPoReport(grid.getCellValue(rowId, 'PO_NUM'))





                } else if(colId == 'ITEM_CD') {
                	<%--
                    var param = {
                        "gate_cd": '${ses.gateCd}',
                        "ITEM_CD": grid.getCellValue(rowId, 'ITEM_CD'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('BBM_040', 1100, 625, param);
                    --%>
                }
            });

            EVF.C('PURCHASE_TYPE').removeOption('DMRO'); /* 국내MRO */
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

        function doInvoice() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            var poData = [];
            var firstPlantCd;
            var firstCur;
            var firstPurchaseType;
            var i = 0;
            var plantCd;
            var cur;
            var purchaseType;

            for (var idx in gridData) {

                var rowData = gridData[idx];

                if(i == 0) {
                	firstPlantCd = rowData['PLANT_CD'];
                	firstCur = rowData['CUR'];
                	firstPurchaseType = rowData['PURCHASE_TYPE'];
                }

                plantCd = rowData['PLANT_CD'];
            	cur = rowData['CUR'];
                purchaseType = rowData['PURCHASE_TYPE'];

            	if(plantCd != firstPlantCd || cur != firstCur || purchaseType != firstPurchaseType) {
            		alert('${SOI_010_0001}'); <%-- 동일 플랜트, 구매유형, 통화를 선택하시기 바랍니다. --%>
            		return;
            	}

                poData.push(
                    {"PO_NUM": rowData['PO_NUM']
                    ,"PO_SQ": rowData['PO_SQ']}
                );

                i++;
            }

            var param = {
                "poJsonData": JSON.stringify(poData) ,
                "detailView": false
            };
            everPopup.openPopupByScreenId('SOI_020', 1000, 600, param);
        }

    </script>
    <e:window id="SOI_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="">
                    <e:select id="COMBO_DATE" name="COMBO_DATE" usePlaceHolder="false" width="100" required="${form_COMBO_DATE_R}" disabled="${form_COMBO_DATE_D }" readOnly="${form_COMBO_DATE_RO}">
                        <e:option text="${SOI_010_PO_DATE}" value="PO_DATE">${SOI_010_PO_DATE}</e:option>
                        <e:option text="${SOI_010_DELIVERY_DATE}" value="DELIVERY_DATE">${SOI_010_DELIVERY_DATE}</e:option>
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
                <e:label for="PO_NUM" title="${form_PO_NUM_N}" />
                <e:field>
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="100%" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
                </e:field>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doInvoice" name="doInvoice" label="${doInvoice_N}" onClick="doInvoice" disabled="${doInvoice_D}" visible="${doInvoice_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
