<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var grid;
        var baseUrl = "/eversrm/po/poMgt/poRegistration/";

        function init() {

            grid = EVF.C("grid");

            grid.delRowEvent(function () {

                if(${param.PURCHASE_TYPE eq 'ISP'}) {

                    var selRowId = grid.getSelRowId();
                    for(var i in selRowId) {

                        var rowId = selRowId[i];
                        if(grid.getCellValue(rowId, 'IS_EDITABLE') == 'N') {
                            return alert('${BPOM_040_0015}');
                        } else {
                            grid.delRow(rowId);
                        }
                    }

                } else {
                    grid.delRow();
                }

            });

            if(${param.PURCHASE_TYPE eq 'ISP'}) <%-- 구매유형이 투자품의인 경우 지급예정일자 필수입력 --%> {
                grid.setColRequired('PAY_DUE_DATE', true);
            }

            grid.cellChangeEvent(function (rowId, colKey, iRow, iCol, newVal, oldVal) {
                onCellChange(colKey, rowId, oldVal, newVal);
            });

            // 대금지불정보를 저장하지 않고, 화면에만 있는 경우 해당 정보를 세팅해준다.
            if ('${param.payListJsonData}' != null && '${param.payListJsonData}' != '') {

                var data = JSON.parse(${param.payListJsonData});
                var arrData = [];
                for (var k = 0; k < data.length; k++) {
                    arrData.push({
                        PAY_SQ: data[k].PAY_SQ,
                        PAY_CNT_TYPE: data[k].PAY_CNT_TYPE,
                        PAY_PERCENT: data[k].PAY_PERCENT,
                        PAY_AMT: Number(data[k].PAY_AMT),
                        PAY_METHOD_TYPE: data[k].PAY_METHOD_TYPE,
                        PAY_METHOD_NM: data[k].PAY_METHOD_NM,
                        PAY_DUE_DATE: data[k].PAY_DUE_DATE,
                        IS_EDITABLE: data[k].IS_EDITABLE
                    });

                    EVF.getComponent('PAY_CNT').setValue(k + 1);
                }

                grid.addRow(arrData);
                setRowEditStatus();

            } else {

                if ('${param.PO_NUM}' != '') {
                    doSearch();
                } else if ('${param.EXEC_NUM}' != '') {
                    doCnSearch();
                }
            }
        }

        function setRowEditStatus() {

            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {

                var rowId = allRowId[i];


            	if('${_gridType}' == "RG") {

                    if(${param.PURCHASE_TYPE eq 'ISP'} && grid.getCellValue(rowId, 'IS_EDITABLE') == 'N';) {
                        grid.setRowReadOnly(rowId, true);
                    } else {
                        grid.setRowReadOnly(rowId, false);
                    }

            	} else {

                    if(${param.PURCHASE_TYPE eq 'ISP'} && grid.getCellValue(rowId, 'IS_EDITABLE') == 'N';) {
                        grid.setRowNotEdit(rowId, true);
                    } else {
                        grid.setRowNotEdit(rowId, false);
                    }



            	}








            }
        }

        // STOCPOPY 지불정보
        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "BPOM_040/doSearch", function () {
                EVF.getComponent('PAY_CNT').setValue(grid.getRowCount());
                setRowEditStatus();
            });
        }

        // STOCCNPY 지불정보
        function doCnSearch() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "BPOM_040/doCnSearch", function () {
                EVF.getComponent('PAY_CNT').setValue(grid.getRowCount());
            });
        }

        // 적용 버튼 클릭시 Grid에 해당 차수만큼 행추가
        function doApply() {

            // 일시불이고, 적용차수가 1보다 큰경우 알림창
            if (EVF.getComponent('PAY_TYPE').getValue() == "LS" && EVF.getComponent('PAY_CNT').getValue() > 1) {
                alert("${BPOM_040_0003}");
                return;
            }
            var payCnt = EVF.getComponent('PAY_CNT').getValue();

            var notEditableData = [];
            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {

                var rowId = allRowId[i];
                if(grid.getCellValue(rowId, 'IS_EDITABLE') == 'N') {
                    notEditableData.push(grid.getRowValue(rowId));
                }
            }

            grid.delAllRow();
            grid.addRow(notEditableData);

            var rowCount = grid.getRowCount();
            for(var i = rowCount; i < payCnt; i++) {

                //grid.addRow([{"PAY_SQ": Number(grid.getCellValue(grid.getLastRowId(), 'PAY_SQ'))+1}]);
                grid.addRow([{"PAY_SQ": Number(grid.getCellValue(grid.getRowId(grid.getRowCount() - 1), 'PAY_SQ'))+1}]);
            }

            setRowEditStatus();


//            grid.delAllRow();
//            var arrData = new Array();
//            for (var k = 0; k < cnt; k++) {
//                arrData.push({
//                    PAY_SQ: k + 1
//                });
//            }
//            grid.addRow(arrData);
        }

        function changePayType() {
            grid.delAllRow();
        }

        function doSave() {

            var store = new EVF.Store();
            if (!store.validate()) return;

            grid.checkAll(true);

            if (!grid.validate().flag) {
                alert(grid.validate().msg);
                return false;
            }
            var currency = EVF.getComponent('CUR').getValue();
            var approvalAmount = EVF.getComponent('PO_AMT').getValue();
            var pay_type = EVF.getComponent('PAY_TYPE').getValue();
            var pay_type_nm = EVF.getComponent('PAY_TYPE').getText();

            var gridAmount = 0;
            var gridper = 0;

            var paySqArr = [];
            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {

                var rowId = allRowId[i];
                gridAmount = gridAmount + Number(grid.getCellValue(rowId, 'PAY_AMT'));
                gridper = gridper + Number(grid.getCellValue(rowId, 'PAY_PERCENT'));

                var paySq = Number(grid.getCellValue(rowId, 'PAY_SQ'));
                if(paySqArr.indexOf(paySq) > -1) {
                    return alert('${BPOM_040_0017}');
                } else {
                    paySqArr.push(paySq);
                }
            }

            if (gridper != 100) {
                alert("${BPOM_040_0013}");
                return;
            }

            if (gridAmount != approvalAmount) {
                alert("${BPOM_040_0005}");
                return;
            }

            if(${param.screenCaller eq 'BPOP_010'}) /* 발주현황에서 바로 수정할 경우 DB에 저장하고, 그 외에는 opener에 데이터를 내려준다. */ {

                if(!confirm('${msg.M0021}')) {
                    return;
                }

                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'all');
                store.load(baseUrl+'BPOM_040/doSave', function() {
                    alert(this.getResponseMessage());
                    if(opener) {
                        if(opener['doSearch']) {
                            opener['doSearch']();
                            close();
                        }
                    }
                });

            } else {

                var sformData = JSON.stringify(grid.getSelRowValue());
                opener.${param.callBackFunction}(pay_type, sformData, gridAmount);
                doClose();
            }
        }

        function doClose() {
            window.close();
        }

        function onCellChange(strColumnKey, nRow, oVal, nVal) {

            grid.setCellValue(nRow, 'DEL_FLAG', 'U');

            if (strColumnKey === 'PAY_DUE_DATE') {



            	everDate.diffWithServerDate(grid.getCellValue(nRow,'PAY_DUE_DATE' ), function (status, message) {
                    if (status === '-1') {
                        alert('${BPOM_040_0012}');
                        grid.setCellValue(nRow, strColumnKey, oVal);
                    }
                }, "true");
            }

            if (strColumnKey == "PAY_PERCENT") {

                if (nVal > 100 || nVal < 0) {
                    alert("${BPOM_040_0010}");
                    grid.setCellValue(nRow,"PAY_PERCENT", oVal);
                    return;
                }

                var currency = EVF.getComponent('CUR').getValue();
                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payAmt = everCurrency.getAmount(currency, nVal * approvalAmount / 100);
                grid.setCellValue(nRow, 'PAY_AMT', payAmt);

                var remainPercent = 100 - nVal;
                for (var i = 0; i < grid.getRowCount(); i++) {

                    var ii = grid.getRowId(i);

                    if (ii != nRow) {
                        var percentI = grid.getCellValue(ii,'PAY_PERCENT') > remainPercent || grid.getCellValue(ii,'PAY_PERCENT') == 0 || i == grid.getRowCount() - 1 ? remainPercent : grid.getCellValue(ii,'PAY_PERCENT');
                        remainPercent = remainPercent - percentI;
                        var payAmtI = everMath.round_float(percentI * approvalAmount / 100, 2);

                        if(grid.getCellValue(ii, 'IS_EDITABLE') == 'Y') {

                            grid.setCellValue(ii,'PAY_AMT', payAmtI);
                            grid.setCellValue(ii,'PAY_PERCENT', percentI);
                        }
                    }

                    if (ii == grid.getRowId(grid.getRowCount()-1))  {

                        var totalAmt = 0;
                        var totalPer = 0.00;
                        for (var k = 0; k < grid.getRowCount(); k++) {
                            if (grid.getRowId(k) !=ii) {
                                totalAmt += Number(grid.getCellValue(grid.getRowId(k), 'PAY_AMT'));
                                totalPer += Number(grid.getCellValue(grid.getRowId(k), 'PAY_PERCENT'));
                            }
                        }

                        grid.setCellValue(ii,'PAY_AMT', approvalAmount-totalAmt);
                        grid.setCellValue(ii,'PAY_PERCENT', everMath.round_float(100.00 - totalPer, 2));
                    }

                }
            }

            if (strColumnKey == "PAY_AMT") {
                var currency = EVF.getComponent('CUR').getValue();

                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payAmt = everCurrency.getAmount(currency, nVal);

                if (payAmt > approvalAmount || payAmt < 0) {
                    alert("${BPOM_040_0005}");
                    grid.setCellValue(nRow,"PAY_AMT", oVal);
                    return;
                }

                var currency = EVF.getComponent('CUR').getValue();
                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payPercent = everMath.round_float(nVal * 100 / approvalAmount, 2);
                grid.setCellValue(nRow,'PAY_PERCENT',  payPercent);
                var remainPercent = 100 - payPercent;

                for (var i = 0; i < grid.getRowCount(); i++) {
                    ii = grid.getRowId(i);
                    if (i != nRow) {
                        var percentI = grid.getCellValue(ii,'PAY_PERCENT') > remainPercent || grid.getCellValue(ii,'PAY_PERCENT') == 0 || i == grid.getRowCount() - 1 ? remainPercent : grid.getCellValue(ii,'PAY_PERCENT');
                        remainPercent = remainPercent - percentI;
                        var payAmtI = everMath.round_float(percentI * approvalAmount / 100, 2);
                        grid.setCellValue(ii,'PAY_PERCENT', percentI);
                    }

                    if (ii == grid.getRowId(grid.getRowCount()-1))  {
                        var totoalMat = 0;
                        var totoalper = 0.00;
                        for (var k = 0; k < grid.getRowCount(); k++) {
                            if (grid.getRowId(k) !=ii) {
                                totoalMat+=Number(grid.getCellValue(grid.getRowId(k),'PAY_AMT'));
                                totoalper+=Number(grid.getCellValue(grid.getRowId(k),'PAY_PERCENT'));
                            }
                        }

                        grid.setCellValue(ii,'PAY_AMT', approvalAmount - totoalMat );
                        grid.setCellValue(ii,'PAY_PERCENT', everMath.round_float(100.00 - totoalper,2));
                    }

                }
            }

            if (strColumnKey == "PAY_PERCENT2") {
                if (nVal > 100 || nVal < 0) {
                    alert("${BPOM_040_0010}");
                    grid.setCellValue(nRow, "PAY_PERCENT", oVal);
                    return;
                }

                if (grid.getRowCount() > 1 && nRow == grid.getRowCount() - 1) {
                    grid.setCellValue(nRow, "PAY_PERCENT", oVal);
                    return alert('마지막 행의 지급율, 지급예정금액은 자동계산되며, 수정하실 수 없습니다.');
                }

                var currency = EVF.getComponent('CUR').getValue();
                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payAmt = everCurrency.getAmount(currency, nVal * approvalAmount / 100);
                grid.setCellValue(nRow, 'PAY_AMT', payAmt);
                var remainPercent = 100 - nVal;
                for (var i = 0; i < grid.getRowCount(); i++) {
                    if (i != nRow) {
                        var percentI = grid.getCellValue(i, 'PAY_PERCENT') > remainPercent || grid.getCellValue(i, 'PAY_PERCENT') == 0 || i == grid.getRowCount() - 1 ? remainPercent : grid.getCellValue(i, 'PAY_PERCENT');
                        remainPercent = remainPercent - percentI;
                        var payAmtI = Math.ceil(percentI * approvalAmount / 100);

                        grid.setCellValue(i, 'PAY_AMT', payAmtI);
                        grid.setCellValue(i, 'PAY_PERCENT', percentI);
                    }
                }
            }

            if (strColumnKey == "PAY_AMT2") {

                if (payAmt > approvalAmount || payAmt < 0) {
                    alert("${BPOM_040_0005}");
                    grid.setCellValue(nRow, "PAY_AMT", oVal);
                    return;
                }

                if (grid.getRowCount() > 1 && nRow == grid.getRowCount() - 1) {
                    grid.setCellValue(nRow, "PAY_AMT", oVal);
                    return alert('${BPOM_040_013}');
                }

                var currency = EVF.getComponent('CUR').getValue();
                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payAmt = everCurrency.getAmount(currency, nVal);

                var currency = EVF.getComponent('CUR').getValue();
                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payPercent = everMath.round_float(nVal * 100 / approvalAmount, 2);
                grid.setCellValue(nRow, 'PAY_PERCENT', payPercent);
                var remainPercent = 100 - payPercent;
                for (var i = 0; i < grid.getRowCount(); i++) {
                    if (i != nRow) {
                        var percentI = grid.getCellValue(i, 'PAY_PERCENT') > remainPercent || grid.getCellValue(i, 'PAY_PERCENT') == 0 || i == grid.getRowCount() - 1 ? remainPercent : grid.getCellValue(i, 'PAY_PERCENT');
                        remainPercent = remainPercent - percentI;
                        var payAmtI = Math.ceil(percentI * approvalAmount / 100);

                        grid.setCellValue(i, 'PAY_AMT', payAmtI);
                        grid.setCellValue(i, 'PAY_PERCENT', percentI);
                    }
                }
            }
        }

        function chPayTemplete() {

            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {

                var rowId = allRowId[i];
                if(grid.getCellValue(rowId, 'IS_EDITABLE') == 'N') {
                    EVF.getComponent('PAY_TEMPLTET').setValue('', false);
                    return alert('${BPOM_040_0016}');
                }
            }

            var store = new EVF.Store();
            store.setParameter('PAY_TEMPLTET',EVF.getComponent('PAY_TEMPLTET').getValue());
            store.load("/eversrm/solicit/rfq/BFAR_030/doSearchTemplete", function() {

                var templete = JSON.parse(this.getParameter("templete"));
                var cou = 0;
                if (templete[0].TEXT1 != '') cou++;
                if (templete[0].TEXT2 != '') cou++;
                if (templete[0].TEXT3 != '') cou++;
                if (templete[0].TEXT4 != '') cou++;
                grid.delAllRow();
                var cou2 = 1;
                //alert(cou)

                var arrData = [];
                arrData.push({
                    PAY_SQ         : cou2++,
                    PAY_CNT_TYPE   : 'DP',
                    PAY_PERCENT    : templete[0].TEXT1
                });


                if (templete[0].TEXT2 != '') {
                    arrData.push({
                        PAY_SQ         : cou2++,
                        PAY_CNT_TYPE   : cou == cou2-1 ? 'BP' : 'PP',
                        PAY_PERCENT    : templete[0].TEXT2
                    });
                }
                if (templete[0].TEXT3 != '') {
                    arrData.push({
                        PAY_SQ         : cou2++,
                        PAY_CNT_TYPE   : cou == cou2-1 ? 'BP' : 'PP',
                        PAY_PERCENT    : templete[0].TEXT3
                    });
                }
                if (templete[0].TEXT4 != '') {
                    arrData.push({
                        PAY_SQ         : cou2++,
                        PAY_CNT_TYPE   : cou == cou2-1 ? 'BP' : 'PP',
                        PAY_PERCENT    : templete[0].TEXT4
                    });
                }
                grid.addRow(arrData);

                var currency = EVF.getComponent('CUR').getValue();
                var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('PO_AMT').getValue());
                var payAmt = everCurrency.getAmount(currency,  grid.getCellValue(grid.getRowId(0), 'PAY_PERCENT')       * approvalAmount / 100);
                grid.setCellValue(grid.getRowId(0), 'PAY_AMT', payAmt);
                var remainPercent = 100 - grid.getCellValue(grid.getRowId(0), 'PAY_PERCENT');
                for (var i = 0; i < grid.getRowCount(); i++) {

                    ii = grid.getRowId(i);

                    if (ii != grid.getRowId(0)) {
                        var percentI = grid.getCellValue(ii,'PAY_PERCENT') > remainPercent || grid.getCellValue(ii,'PAY_PERCENT') == 0 || i == grid.getRowCount() - 1 ? remainPercent : grid.getCellValue(ii,'PAY_PERCENT');
                        remainPercent = remainPercent - percentI;
                        var payAmtI = everMath.round_float(percentI * approvalAmount / 100, 2);

                        grid.setCellValue(ii,'PAY_AMT', payAmtI);
                        grid.setCellValue(ii,'PAY_PERCENT', percentI);
                    }

                    if (ii == grid.getRowId(grid.getRowCount()-1))  {
                        var totoalMat = 0;
                        for (var k = 0; k < grid.getRowCount(); k++) {
                            if (grid.getRowId(k) !=ii)
                                totoalMat+=Number(grid.getCellValue(grid.getRowId(k),'PAY_AMT'));
                        }
                        grid.setCellValue(ii,'PAY_AMT', approvalAmount-totoalMat);
                    }

                }
            });
        }
    </script>

    <e:window id="BPOM_040" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${param.PURCHASE_TYPE}"/>
        <e:inputHidden id="PO_NUM" name="PO_NUM" value="${param.PO_NUM}"/>
        <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${param.EXEC_NUM}"/>
        <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"/>

        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
                <e:label for="PAY_TYPE" title="${form_PAY_TYPE_N}"/>
                <e:field>
                    <e:select id="PAY_TYPE" name="PAY_TYPE" onChange="changePayType" value="${not empty param.PAY_TYPE_CN ? param.PAY_TYPE_CN : param.PAY_TYPE}" options="${payTypeOptions}" width="${inputTextWidth}" disabled="${form_PAY_TYPE_D}" readOnly="${form_PAY_TYPE_RO}" required="${form_PAY_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PAY_CNT" title="${form_PAY_CNT_N}"/>
                <e:field>
                    <e:inputNumber id="PAY_CNT" name="PAY_CNT" value="${form.PAY_CNT}" width="30" maxValue="${form_PAY_CNT_M}" decimalPlace="${form_PAY_CNT_NF}" disabled="${form_PAY_CNT_D}" readOnly="${form_PAY_CNT_RO}" required="${form_PAY_CNT_R}"/>
                    <e:text>&nbsp;</e:text>
                    <c:if test="${param.detailView != 'true' }">
                        <e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
                    </c:if>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PO_AMT" title="${form_PO_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="PO_AMT" name="PO_AMT" value="${param.PO_AMT}" maxValue="${form_PO_AMT_M}" decimalPlace="${form_PO_AMT_NF}" disabled="${form_PO_AMT_D}" readOnly="${form_PO_AMT_RO}" required="${form_PO_AMT_R}"/>
                </e:field>
                <e:label for="CUR" title="${form_CUR_N}"/>
                <e:field>
                    <e:select id="CUR" name="CUR" value="${param.CUR}" options="${curOptions}" width="${inputTextWidth}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PAY_TEMPLTET" title="${form_PAY_TEMPLTET_N}"/>
                <e:field colSpan="3">
                    <e:select id="PAY_TEMPLTET" name="PAY_TEMPLTET" onChange="chPayTemplete"  value="${form.PAY_TEMPLTET}" options="${payTempltetOptions}" width="100%" disabled="${form_PAY_TEMPLTET_D}" readOnly="${form_PAY_TEMPLTET_RO}" required="${form_PAY_TEMPLTET_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <c:if test="${param.detailView != 'true' }">
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            </c:if>
            <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>

