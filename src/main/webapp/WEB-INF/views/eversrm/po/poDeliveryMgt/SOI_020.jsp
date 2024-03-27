<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/po/deliveryMgt/SOI_020"
                , grid;
        var isConfirmed = false;

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

                    everPopup.openPopupByScreenId('BBM_040', 1200, 625, param);
                    --%>
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {
                    case 'INV_QT':
						var cur = EVF.C('CUR').getValue();
                        var rowData = grid.getRowValue(rowId);
                        var invQt = Number(rowData['INV_QT']);

                        var kkk=0;
                        if (!everString.isEmpty(rowData['BALANCE_QT'])) {
                        	kkk = Number(rowData['BALANCE_QT']);
                        }

                        var balanceQt = kkk;

                        var unitPrc = Number(rowData['UNIT_PRC']);

                        if (everString.isEmpty(oldValue)) {
                        	oldValue=0;
                        }



                        if ((balanceQt + Number(oldValue) - invQt) < 0) {
                            grid.setCellValue(rowId, 'INV_QT', Number(oldValue));
                            return alert('${SOI_020_001}');
                        } else {
                            grid.setCellValue(rowId, 'BALANCE_QT', (balanceQt + Number(oldValue) - invQt));
                            grid.setCellValue(rowId, 'ITEM_AMT', everCurrency.getAmount(cur, invQt * unitPrc));
                        }

                        setInvAmt();

                    default:
                }
            });

            var invNum = EVF.C('INV_NUM').getValue();

            if(invNum === '') {
            	EVF.C('doDelete').setVisible(false);
            	EVF.C('doDeleteItem').setVisible(false);
            }

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();

            store.setGrid([grid]);
            store.setParameter('poJsonData', '${param.poJsonData}');
            store.load(baseUrl + '/doSearch', function () {

                if(grid.getRowCount() == 0) {
                    if(confirm('${SOI_020_002}')) {
                        doDelete(true);
                    }
                }

            }, false);
        }

        function setInvAmt() {

            var invAmt;
            var cur = EVF.C('CUR').getValue();
            var gridData = grid.getAllRowValue();
            for (var idx in gridData) {
                var rowData = gridData[idx];
                var invQt = Number(rowData['INV_QT']);
                var unitPrc = Number(rowData['UNIT_PRC']);
                invAmt = everCurrency.getAmount(cur, invQt * unitPrc);
            }

            EVF.C('INV_AMT').setValue(invAmt);
        }

        function doSave() {
            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }
            grid.checkAll(true);
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            if (!confirm('${msg.M0021}')) {
                return;
            }

            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.load(baseUrl + '/doSave', function () {
                alert(this.getResponseMessage());
                location.href = baseUrl + '/view.so?invNum=' + this.getParameter('invNum');
                if(opener) {
                    if(opener['doSearch']) {
                        opener['doSearch']();
                    }
                }
            });
        }

        function doDelete(isConfirmed) {
            if(EVF.isEmpty('${form.INV_NUM}')) {
                return alert('${msg.M0118}');
            }
            if(isConfirmed !== true) {
                if (!confirm('${msg.M0013}')) {
                    return;
                }
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.load(baseUrl + '/doDelete', function () {
                alert(this.getResponseMessage());
                if(opener) {
                    if(opener['doSearch']) {
                        opener['doSearch']();
                    }
                }
                doClose();
            });
        }

        function doDeleteItem() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var gridData = grid.getSelRowValue();
            for(var i in gridData) {
                var itemData = gridData[i];
                if(EVF.isEmpty(itemData['INV_NUM'])) {
                    return alert('${msg.M0118}');
                }
            }

            if (!confirm('${msg.M0013}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doDeleteItem', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doClose() {
            formUtil.close();
        }



        function doPrint(){

            /*
            var urlPath = document.location.protocol + "//" + document.location.host;
            var url = urlPath + "/ClipReport4/JavaOOFGenerator_Popup.jsp";

            var param = {
                'crfName': 'trading_statement.crf',
                'crfDbName': 'sql',
                'crfParams': "GATE_CD:100^INV_NUM:${form.INV_NUM}" // 샘플확인 번호 : IV151100013
            };

            everPopup.openWindowPopup(url, 1000, 700, param, "reportPopup");
             */

            var param = {
                'inv_num': "${form.INV_NUM}" // 샘플확인 번호 : IV151100013
            };
            everPopup.printInvoice(param);
        }



    </script>
    <e:window id="SOI_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="poJsonData" name="poJsonData" value="${param.poJsonData}"/>
        <e:searchPanel id="form" title="${msg.M7777}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="INV_NUM" title="${form_INV_NUM_N}"/>
                <e:field>
                    <e:inputText id="INV_NUM" style="ime-mode:inactive" name="INV_NUM" value="${form.INV_NUM}" width="100%" maxLength="${form_INV_NUM_M}" disabled="${form_INV_NUM_D}" readOnly="${form_INV_NUM_RO}" required="${form_INV_NUM_R}"/>
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:inputHidden id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${empty form.VENDOR_CD ? ses.companyCd : form.VENDOR_CD}" width="100%" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>
                    <e:inputText id="VENDOR_NM" style="ime-mode:active" name="VENDOR_NM" value="${empty form.VENDOR_NM ? ses.companyNm : form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PIC_USER_NM" title="${form_PIC_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="PIC_USER_NM" style="${imeMode}" name="PIC_USER_NM" value="${empty form.PIC_USER_NM ? ses.userNm : form.PIC_USER_NM}" width="100%" maxLength="${form_PIC_USER_NM_M}" disabled="${form_PIC_USER_NM_D}" readOnly="${form_PIC_USER_NM_RO}" required="${form_PIC_USER_NM_R}"/>
                </e:field>
                <e:label for="PIC_TEL_NUM" title="${form_PIC_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id="PIC_TEL_NUM" style="ime-mode:inactive" name="PIC_TEL_NUM" value="${empty form.PIC_TEL_NUM ? ses.telNum : form.PIC_TEL_NUM}" width="100%" maxLength="${form_PIC_TEL_NUM_M}" disabled="${form_PIC_TEL_NUM_D}" readOnly="${form_PIC_TEL_NUM_RO}" required="${form_PIC_TEL_NUM_R}"/>
                </e:field>
                <e:label for="PIC_CELL_NUM" title="${form_PIC_CELL_NUM_N}"/>
                <e:field>
                    <e:inputText id="PIC_CELL_NUM" style="ime-mode:inactive" name="PIC_CELL_NUM" value="${empty form.PIC_CELL_NUM ? ses.cellNum : form.PIC_CELL_NUM}" width="100%" maxLength="${form_PIC_CELL_NUM_M}" disabled="${form_PIC_CELL_NUM_D}" readOnly="${form_PIC_CELL_NUM_RO}" required="${form_PIC_CELL_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CUR" title="${form_CUR_N}"/>
                <e:field>
                    <e:inputText id="CUR" style="ime-mode:inactive" name="CUR" value="${form.CUR}" width="100%" maxLength="${form_CUR_M}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}"/>
                </e:field>
                <e:label for="INV_AMT" title="${form_INV_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="INV_AMT" name="INV_AMT" value="${form.INV_AMT}" maxValue="${form_INV_AMT_M}" decimalPlace="${form_INV_AMT_NF}" disabled="${form_INV_AMT_D}" readOnly="${form_INV_AMT_RO}" required="${form_INV_AMT_R}"/>
                </e:field>
				<e:label for="INV_DATE" title="${form_INV_DATE_N}"/>
				<e:field>
				<e:inputDate id="INV_DATE" name="INV_DATE" value="${form.INV_DATE}" width="${inputTextDate}" datePicker="false" required="${form_INV_DATE_R}" disabled="${form_INV_DATE_D}" readOnly="${form_INV_DATE_RO}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="RMK_TEXT_NUM" title="${form_RMK_TEXT_NUM_N}"/>
                <e:field colSpan="5">
                    <e:inputHidden id="RMK_TEXT_NUM" style="${imeMode}" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}" width="100%"/>
                    <e:richTextEditor id="SPECIAL_CONTENTS" width="100%" name="SPECIAL_CONTENTS" value="${form.SPECIAL_CONTENTS}" label="${RMK_TEXT_NUM_N }" height="200" disabled="${form_RMK_TEXT_NUM_D }" visible="${form_RMK_TEXT_NUM_V }" readOnly="${form_RMK_TEXT_NUM_RO }" required="${form_RMK_TEXT_NUM_R }"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <c:if test="${ses.userType != 'B'}">
                <e:button id="doDeleteItem" name="doDeleteItem" label="${doDeleteItem_N}" onClick="doDeleteItem" disabled="${doDeleteItem_D}" visible="${doDeleteItem_V}" align="left"/>
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            </c:if>
	        <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>
