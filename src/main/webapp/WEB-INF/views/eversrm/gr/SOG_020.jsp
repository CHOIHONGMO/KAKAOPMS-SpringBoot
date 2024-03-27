<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/SOG_020"
                , grid;

        function init() {
            grid = EVF.C('grid');
            grid.setProperty('panelVisible', ${panelVisible});
            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'multiSelect') {

                    grid.checkAll(false);
                    grid.checkRow(rowId, true);

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

            if(!store.validate()) { return; }

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

        function doAcceptRequest() {


            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            var param = {
                "poNum": grid.getSelRowValue()[0]['PO_NUM'],
                "paySq": grid.getSelRowValue()[0]['PAY_SQ'],
                "detailView": false
            };
            everPopup.openPopupByScreenId('SOG_030', 1000, 800, param);
        }

    </script>
    <e:window id="SOG_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="">
                    <e:select id="COMBO_DATE" name="COMBO_DATE" usePlaceHolder="false" width="100" required="${form_COMBO_DATE_R}" disabled="${form_COMBO_DATE_D }" readOnly="${form_COMBO_DATE_RO}">
                        <e:option text="${SOG_020_PO_CREATE_DATE}" value="PO_CREATE_DATE">${SOG_020_PO_CREATE_DATE}</e:option>
                        <e:option text="${SOG_020_PAY_DUE_DATE}" value="PAY_DUE_DATE">${SOG_020_PAY_DUE_DATE}</e:option>
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
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="40%" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="55%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PAY_METHOD" title="${form_PAY_METHOD_N}"/>
                <e:field colSpan="3">
                    <e:select id="PAY_METHOD" name="PAY_METHOD" value="${form.PAY_METHOD}" options="${payMethodOptions}" width="${inputTextWidth}" disabled="${form_PAY_METHOD_D}" readOnly="${form_PAY_METHOD_RO}" required="${form_PAY_METHOD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doAcceptRequest" name="doAcceptRequest" label="${doAcceptRequest_N}" onClick="doAcceptRequest" disabled="${doAcceptRequest_D}" visible="${doAcceptRequest_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
