<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/SOG_040"
                , grid;

        function init() {
            grid = EVF.C('grid');
            grid.setProperty('panelVisible', ${panelVisible});
            grid.cellClickEvent(function(rowId, colId) {

                if(colId == 'multiSelect') {

                    grid.checkAll(false);
                    grid.checkRow(rowId, true);

                } else if(colId == 'INV_NUM') {

                    var progressCd = grid.getCellValue(rowId, 'PROGRESS_CD');
                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": (progressCd == '50') ? false : true
                    };

                    everPopup.openPopupByScreenId('SOG_030', 1000, 800, param);

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
    <e:window id="SOG_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="">
                    <e:select id="COMBO_DATE" name="COMBO_DATE" usePlaceHolder="false" width="100" required="${form_COMBO_DATE_R}" disabled="${form_COMBO_DATE_D }" readOnly="${form_COMBO_DATE_RO}">
                        <e:option text="${SOG_040_REQ_DATE}" value="REQ_DATE">${SOG_040_REQ_DATE}</e:option>
                        <e:option text="${SOG_040_END_DATE}" value="END_DATE">${SOG_040_END_DATE}</e:option>
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
                    <e:inputText id="PO_NUM" style="ime-mode:inactive" name="PO_NUM" value="${form.PO_NUM}" width="${inputTextWidth}" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="INV_NUM" title="${form_INV_NUM_N}" />
                <e:field>
                    <e:inputText id="INV_NUM" style="ime-mode:inactive" name="INV_NUM" value="${form.INV_NUM}" width="${inputTextWidth}" maxLength="${form_INV_NUM_M}" disabled="${form_INV_NUM_D}" readOnly="${form_INV_NUM_RO}" required="${form_INV_NUM_R}"/>
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
            <e:button id="doAcceptRequest" name="doAcceptRequest" label="${doAcceptRequest_N}" onClick="doAcceptRequest" disabled="${doAcceptRequest_D}" visible="${doAcceptRequest_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
