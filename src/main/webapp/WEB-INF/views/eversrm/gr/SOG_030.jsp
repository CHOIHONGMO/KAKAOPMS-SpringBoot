<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/eversrm/gr/SOG_030";
        var grid;
        var gridAccept;

        function init() {

            grid = EVF.C('grid');
            gridAccept = EVF.C('gridAccept');

            grid.setProperty('multiselect', false);
            gridAccept.setProperty('multiselect', false);
            gridAccept.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function (rowId, colId) {

                if (colId == 'multiSelect') {

                  //  grid.checkAll(false);
                  //  grid.checkRow(rowId, true);

                } else if (colId == 'INV_NUM') {

                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('SOI_020', 1000, 800, param);

                } else if (colId == 'PO_NUM') {

                    var param = {
                        "poNum": grid.getCellValue(rowId, 'PO_NUM'),
                        "detailView": true
                    };

                    everPopup.openPopupByScreenId('BPOM_020', 1000, 800, param);

                }
            });

            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {

                if (colId === 'INV_QT') {

                    var invAmt = 0;
                    var cur = EVF.C('CUR').getValue();
                    var gridData = grid.getAllRowValue();

                    for (var ri in gridData) {

                        var rowData = gridData[ri];
                        var qty = everCurrency.getQty(cur, rowData['INV_QT']);
                        var poQty = everCurrency.getQty(cur, rowData['PO_QT']);
                        var unitPrc = everCurrency.getPrice(cur, rowData['UNIT_PRC']);
                        var itemAmt = everCurrency.getAmount(cur, (unitPrc * qty));

                        if (qty > poQty) {
                            grid.setCellValue(rowId, 'INV_QT', oldValue);
                            <%-- return alert('검수요청 가능수량을 초과했습니다.'); --%>
                            return alert('${SOG_030_1000}');
                        }

                        grid.setCellValue(ri, 'ITEM_AMT', itemAmt);
                        invAmt = invAmt + (unitPrc * qty);
                    }

                    EVF.C('INV_AMT').setValue(invAmt);

                } else if (colId === 'ITEM_AMT') {

                    var invAmt = 0;
                    var cur = EVF.C('CUR').getValue();
                    var allRowId = grid.getAllRowId();

                    for(var i in allRowId) {

                        var ri = allRowId[i];
                        var poItemAmt = everCurrency.getAmount(cur, grid.getCellValue(ri, 'PO_ITEM_AMT'));
                        var unitPrc = everCurrency.getPrice(cur, grid.getCellValue(ri, 'UNIT_PRC'));
                        var itemAmt = everCurrency.getAmount(cur, grid.getCellValue(ri, 'ITEM_AMT'));
                        var sumInvAmt = everCurrency.getAmount(cur, grid.getCellValue(ri, 'SUM_INV_AMT'));

                        if (itemAmt > (poItemAmt - sumInvAmt)) {
                            grid.setCellValue(rowId, 'ITEM_AMT', oldValue);
                            <%-- return alert('검수요청 가능금액을 초과했습니다.'); --%>
                            return alert('${SOG_030_1010}');
                        }

                        grid.setCellValue(ri, 'INV_QT', everCurrency.getQty(cur, (itemAmt / unitPrc)));
                        invAmt = invAmt + itemAmt;
                    }

                    EVF.C('INV_AMT').setValue(invAmt);

                }
            });

            gridAccept.cellClickEvent(function (rowId, colId) {

                if (colId == 'INV_NUM') {

                    var param = {
                        "invNum": grid.getCellValue(rowId, 'INV_NUM'),
                        "detailView": true
                    };
                    //everPopup.openPopupByScreenId('SOI_020', 1000, 800, param);

                    var url = "/eversrm/gr/SOG_030/view.so?";
                    var property = {
                         'url': url
                        ,'width': 1000
                        ,'height': 800
                        ,'scrollbars': true
                        ,'resizable': true
                        ,'name': 'SOG_030_SUB'
                        ,'param': param
                    };

                    var form = everPopup.makePostForm(property, param);
                    var popWindow = window.open('', 'SOG_030_SUB', everPopup.argsToString(property));
                    form.submit();
                    popWindow.focus();
                }
            });

            var invNum = EVF.C('INV_NUM').getValue();
            if(invNum === '') {
            	EVF.C('doDelete').setVisible(false);
            	EVF.C('doSendRequest').setVisible(false);
            }

            doSearchItem();
        }

        function doSearchItem() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + '/doSearchItem', function () {
                doSearchDetail();
            }, false);
        }

        function doSearchDetail() {

            var store = new EVF.Store();
            store.setGrid([gridAccept]);
            store.load(baseUrl + '/doSearchDetail', function () {

            }, false);
        }

        function doValidate() {

            var cur = EVF.C('CUR').getValue();
            var payAmt = everCurrency.getAmount(cur, EVF.C('PAY_AMT').getValue());
            var originalInvAmt = everCurrency.getAmount(cur, '${form.INV_AMT}');
            var invAmt = everCurrency.getAmount(cur, EVF.C('INV_AMT').getValue());
            var accInvAmt = everCurrency.getAmount(cur, EVF.C('ACC_INV_AMT').getValue());

            if(payAmt < accInvAmt - originalInvAmt + invAmt) {
                alert('${SOG_030_005}');
                return false;
            }

            var store = new EVF.Store();
            if(!store.validate()) { return false; }

            var validate = grid.validate();
            if(!validate) {
                return alert(validate.msg);
            }

            return true;
        }

        function doSave() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

			if(!doValidate()) { return; }
            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.doFileUpload(function () {
                store.load(baseUrl + '/doSave', function () {
                	EVF.C('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());
                    location.href = baseUrl + '/view.so?invNum=' + this.getParameter('invNum');
                });
            });
        }

        function doSendRequest() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            if(!doValidate()) { return; }
            if (!confirm('${SOG_030_006}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.doFileUpload(function () {
                store.load(baseUrl + '/doSend', function () {
                	EVF.C('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());
                    var params = {
                        "detailView": true,
                        "invNum": this.getParameter('invNum')
                    };
                    location.href = baseUrl + '/view.so?'+ $.param(params);
                });
            });
        }

        function doDelete() {
			if (EVF.C('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            if (!confirm('${msg.M0013}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'all');
            store.load(baseUrl + '/doDelete', function () {
            	EVF.C('TRANSACTION_FLAG').setValue('Y');

                alert(this.getResponseMessage());
                formUtil.close();
            });
        }

        function doClose() {
            if(opener) {
                if(opener['doSearch']) {
                    opener['doSearch']();
                }
            }
            formUtil.close();
        }

        function doPrint(){
            /*
            var urlPath = document.location.protocol + "//" + document.location.host;
            var url = urlPath + "/ClipReport4/JavaOOFGenerator_Popup.jsp";

            var param = {
                'crfName': 'trading_statement.crf',
                'crfDbName': 'sql',
                'crfParams': "GATE_CD:100^INV_NUM:"+EVF.C('INV_NUM').getValue() // 샘플확인 번호 : IV151100013
            };

            everPopup.openWindowPopup(url, 1000, 700, param, "reportPopup");
            */
            var param = {
                'inv_num': EVF.C('INV_NUM').getValue() // 샘플확인 번호 : IV151100013
            };
            everPopup.printInvoice(param);
        }

    </script>
    <e:window id="SOG_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="PO_NUM" name="PO_NUM" value="${param.poNum}"/>
        <e:inputHidden id="PAY_SQ" name="PAY_SQ" value="${param.paySq}"/>
        <e:inputHidden id="CUR" name="CUR" value="${form.CUR}"/>
        <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}"/>
        <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>

        <e:searchPanel id="form" title="일반정보" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
            <e:row>
                <e:label for="INV_NUM" title="${form_INV_NUM_N}"/>
                <e:field>
                    <e:inputText id="INV_NUM" style="ime-mode:inactive" name="INV_NUM" value="${form.INV_NUM}" width="${inputTextWidth}" maxLength="${form_INV_NUM_M}" disabled="${form_INV_NUM_D}" readOnly="${form_INV_NUM_RO}" required="${form_INV_NUM_R}"/>
                    <e:inputHidden id="REQ_CNT" name="REQ_CNT" value="${form.REQ_CNT}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputHidden id="VENDOR_CD" style="${imeMode}" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${inputTextWidth}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PIC_USER_NM" title="${form_PIC_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="PIC_USER_NM" style="${imeMode}" name="PIC_USER_NM" value="${form.PIC_USER_NM}" width="${inputTextWidth}" maxLength="${form_PIC_USER_NM_M}" disabled="${form_PIC_USER_NM_D}" readOnly="${form_PIC_USER_NM_RO}" required="${form_PIC_USER_NM_R}"/>
                </e:field>
                <e:label for="PIC_TEL_NUM" title="${form_PIC_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id="PIC_TEL_NUM" style="ime-mode:inactive" name="PIC_TEL_NUM" value="${form.PIC_TEL_NUM}" width="${inputTextWidth}" maxLength="${form_PIC_TEL_NUM_M}" disabled="${form_PIC_TEL_NUM_D}" readOnly="${form_PIC_TEL_NUM_RO}" required="${form_PIC_TEL_NUM_R}"/>
                </e:field>
                <e:label for="PIC_CELL_NUM" title="${form_PIC_CELL_NUM_N}"/>
                <e:field>
                    <e:inputText id="PIC_CELL_NUM" style="ime-mode:inactive" name="PIC_CELL_NUM" value="${form.PIC_CELL_NUM}" width="${inputTextWidth}" maxLength="${form_PIC_CELL_NUM_M}" disabled="${form_PIC_CELL_NUM_D}" readOnly="${form_PIC_CELL_NUM_RO}" required="${form_PIC_CELL_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SEND_DATE" title="${form_SEND_DATE_N}"/>
                <e:field>
                    <e:inputDate id="SEND_DATE" name="SEND_DATE" value="${form.SEND_DATE}" width="${inputTextDate}" datePicker="true" required="${form_SEND_DATE_R}" disabled="${form_SEND_DATE_D}" readOnly="${form_SEND_DATE_RO}"/>
                </e:field>
                <e:label for="INSPECT_DATE_2" title="${form_INSPECT_DATE_2_N}"/>
                <e:field>
                    <e:inputDate id="INSPECT_DATE_2" name="INSPECT_DATE_2" value="${form.INSPECT_DATE_2}" width="${inputTextDate}" datePicker="true" required="${form_INSPECT_DATE_2_R}" disabled="${form_INSPECT_DATE_2_D}" readOnly="${form_INSPECT_DATE_2_RO}"/>
                </e:field>
                <e:label for="PO_CREATE_DATE" title="${form_PO_CREATE_DATE_N}"/>
                <e:field>
                    <e:inputDate id="PO_CREATE_DATE" name="PO_CREATE_DATE" value="${form.PO_CREATE_DATE}" width="${inputTextDate}" datePicker="true" required="${form_PO_CREATE_DATE_R}" disabled="${form_PO_CREATE_DATE_D}" readOnly="${form_PO_CREATE_DATE_RO}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
                <e:field>
                    <e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
                </e:field>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.CTRL_USER_ID}"/>
                    <e:inputText id="CTRL_USER_NM" style="ime-mode:auto" name="CTRL_USER_NM" value="${form.CTRL_USER_NM}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_ID_M}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}"/>
                </e:field>
                <e:label for="INSPECT_USER_ID" title="${form_INSPECT_USER_ID_N}"/>
                <e:field>
                    <e:inputHidden id="INSPECT_USER_ID" name="INSPECT_USER_ID" value="${form.INSPECT_USER_ID}"/>
                    <e:inputText id="INSPECT_USER_NM" style="ime-mode:auto" name="INSPECT_USER_NM" value="${form.INSPECT_USER_NM}" width="${inputTextWidth}" maxLength="${form_INSPECT_USER_ID_M}" disabled="${form_INSPECT_USER_ID_D}" readOnly="${form_INSPECT_USER_ID_RO}" required="${form_INSPECT_USER_ID_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PAY_METHOD_TYPE" title="${form_PAY_METHOD_TYPE_N}"/>
                <e:field>
                    <e:select id="PAY_METHOD_TYPE" name="PAY_METHOD_TYPE" value="${form.PAY_METHOD_TYPE}" options="${payMethodTypeOptions}" width="100%" disabled="${form_PAY_METHOD_TYPE_D}" readOnly="${form_PAY_METHOD_TYPE_RO}" required="${form_PAY_METHOD_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PO_AMT" title="${form_PO_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="PO_AMT" name="PO_AMT" value="${form.PO_AMT}" maxValue="${form_PO_AMT_M}" decimalPlace="${form_PO_AMT_NF}" disabled="${form_PO_AMT_D}" readOnly="${form_PO_AMT_RO}" required="${form_PO_AMT_R}"/>
                </e:field>
                <e:label for="INV_AMT" title="${form_INV_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="INV_AMT" name="INV_AMT" value="${form.INV_AMT}" maxValue="${form_INV_AMT_M}" decimalPlace="${form_INV_AMT_NF}" disabled="${form_INV_AMT_D}" readOnly="${form_INV_AMT_RO}" required="${form_INV_AMT_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PAY_CNT_TYPE" title="${form_PAY_CNT_TYPE_N}"/>
                <e:field>
                    <e:select id="PAY_CNT_TYPE" name="PAY_CNT_TYPE" value="${form.PAY_CNT_TYPE}" options="${payCntTypeOptions}" width="${inputTextWidth}" disabled="${form_PAY_CNT_TYPE_D}" readOnly="${form_PAY_CNT_TYPE_RO}" required="${form_PAY_CNT_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PAY_AMT" title="${form_PAY_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="PAY_AMT" name="PAY_AMT" value="${form.PAY_AMT}" maxValue="${form_PAY_AMT_M}" decimalPlace="${form_PAY_AMT_NF}" disabled="${form_PAY_AMT_D}" readOnly="${form_PAY_AMT_RO}" required="${form_PAY_AMT_R}" />
                </e:field>
                <e:label for="ACC_INV_AMT" title="${form_ACC_INV_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="ACC_INV_AMT" name="ACC_INV_AMT" value="${form.ACC_INV_AMT}" maxValue="${form_ACC_INV_AMT_M}" decimalPlace="${form_ACC_INV_AMT_NF}" disabled="${form_ACC_INV_AMT_D}" readOnly="${form_ACC_INV_AMT_RO}" required="${form_ACC_INV_AMT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="SPECIAL_CONTENT" title="${form_SPECIAL_CONTENT_N}"/>
                <e:field colSpan="5">
                    <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}"/>
                    <e:richTextEditor id="SPECIAL_CONTENT" style="${imeMode}" name="SPECIAL_CONTENT" value="${form.SPECIAL_CONTENT}" width="100%" height="150" maxLength="${form_SPECIAL_CONTENT_M}" disabled="${form_SPECIAL_CONTENT_D}" readOnly="${form_SPECIAL_CONTENT_RO}" required="${form_SPECIAL_CONTENT_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                <e:field colSpan="5">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="GR" fileId="${form.ATT_FILE_NUM}" width="100%" height="100" readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}"/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doSendRequest" name="doSendRequest" label="${doSendRequest_N}" onClick="doSendRequest" disabled="${doSendRequest_D}" visible="${doSendRequest_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" height="200" readOnly="${param.detailView}" title="품목정보" useTitleBar="true" columnDef="${gridInfos.grid.gridColData}" />

        <e:gridPanel gridType="${_gridType}" id="gridAccept" height="180" readOnly="${param.detailView}" title="검수요청 이력현황" useTitleBar="true" columnDef="${gridInfos.gridAccept.gridColData}" />

    </e:window>
</e:ui>
