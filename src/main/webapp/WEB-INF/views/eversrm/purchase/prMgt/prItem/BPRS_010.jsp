<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>

    var grid;
    var baseUrl = "/wisepro/purchase/prMgt/prItem/";

    function init() {
        grid = EVF.C("grid");
        var gridStringData = '${param.gridStringData}';
        if (gridStringData !== '') {
            grid.addRow(JSON.parse(gridStringData));
        }

        grid.addRowEvent(function () {
            grid.addRow();
            calculateTotalAmt();
        });

        grid.delRowEvent(function () {
            grid.delRow();
            calculateTotalAmt();
        });

        grid.cellChangeEvent(function (rowId, celName, iRow, iCol, newValue, oldValue) {
            if (celName === 'UNIT_PRC') {
                calculateTotalAmt();
            }
        });

        grid.setProperty('shrinkToFit', true);

        calculateTotalAmt();
    }

    function calculateTotalAmt() {

        var totalAmt = 0;

        var gridData = grid.getAllRowValue();
        for(var x in gridData) {
            var rowData = gridData[x];
            var unitPrice = Number(rowData['UNIT_PRC']);
            totalAmt += unitPrice;
        }

        EVF.C('TOTAL_AMT').setValue(totalAmt);
    }

    function saveSub() {
        var unitPriceChk = 0;
        var rowCount = grid.getRowCount();
        var rowData = grid.getAllRowValue();
        for (var i = 0; i < rowCount; i++) {
            if (rowData[i]['UNIT_PRC'] == 0) {
                unitPriceChk++;
            }
        }

        if (unitPriceChk != 0) {
            return alert('${BPRS_010_UNIT_PRC_MSG}');
        }

        if (EVF.C('TOTAL_AMT').getValue() != '${param.itemAmt}' && EVF.C('TOTAL_AMT').getValue() != 0) {
            return alert('${BPRS_010_ITEM_AMT_MSG} (예상금액: ${param.itemAmt})');
        }

        grid.checkAll(true);

        if (!grid.validate().flag) { return alert(grid.validate().msg); }

        parent['${param.callbackFunction}'](JSON.stringify(rowData), '${param.nRow}');
        close();
    }

    function close() {
        new EVF.ModalWindow().close(null);
    }

</script>
    <e:window id="BPRS_010" onReady="init" initData="${initData}">
        <e:searchPanel id="form" labelWidth="100" labelAlign="${labelAlign}">
            <e:label for="TOTAL_AMT" title="${form_TOTAL_AMT_N}"/>
            <e:field>
                <e:inputNumber id='TOTAL_AMT' name="TOTAL_AMT" label='${form_TOTAL_AMT_N }' value='' decimalPlace='2' align='right' width='${inputNumberWidth }' required='${form_TOTAL_AMT_R }' readOnly='${form_TOTAL_AMT_RO }' disabled='${form_TOTAL_AMT_D }' visible='${form_TOTAL_AMT_V }'/>
            </e:field>
        </e:searchPanel>
        <e:buttonBar align="right">
            <e:button label='${save_N }' id='save' onClick='saveSub' disabled='${save_D }' visible='${save_V }' data='${save_A }'/>
            <e:button label='${close_N }' id='close' onClick='close' disabled='${close_D }' visible='${close_V }' data='${close_A }'/>
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>