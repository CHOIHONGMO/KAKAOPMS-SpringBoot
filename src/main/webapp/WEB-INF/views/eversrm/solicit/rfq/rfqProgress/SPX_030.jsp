<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var baseUrl = "/eversrm/solicit/rfq/rfqProgress/";

    function init() {
        grid = EVF.getComponent("grid");

        if ('${param.rfxNo}' !== '') {
            var rfxNum = '${param.rfxNo}';
            var rfxCnt = '${param.rfxCnt}';
            var rfxSq = '${param.rfxSq}';
						
            EVF.getComponent('RFX_NUM').setValue(rfxNum);
            EVF.getComponent('RFX_CNT').setValue(rfxCnt);
            EVF.getComponent('RFX_SQ').setValue(rfxSq);
            EVF.getComponent('QTA_NUM').setValue('${param.qtaNum}');
            EVF.getComponent('QTA_SQ').setValue('${param.qtaSq}');
            EVF.getComponent('CUR').setValue('${param.cur}');
			
            doSearch();
        }
    }

    function doSearch() {

        var store = new EVF.Store();
        store.load(baseUrl + "SPX_030/doSearch", function() {
            if (grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
                doClose();
            } else {
                calculateSum();
                EVF.getComponent('SAVED_QTA_ATM').setValue(EVF.getComponent('QTA_ATM').getValue());
            }
        });

    }

    function doSave() {    	
    	var cnt = grid.getRowCount();
    	var unitPriceChk = 0;
    	
    	if('${param.itemAmt}' == 0){
    		alert("${BPX_280_0004}");
    		return ;
    	}
    	
    	for(var i = 0; i < cnt; i++){
    		if(grid.getCellValue(i, 'UNIT_PRC') == 0){
    			unitPriceChk++;
    		}
    	}

    	if(
    		(unitPriceChk != cnt)
    		&& (unitPriceChk != 0)
    	){
    		alert("${BPX_280_0003}");
    		return;
    	}
    	
		if(parseFloat(EVF.getComponent('QTA_ATM').getValue()) != parseFloat('${param.itemAmt}')){
    		alert("${BPX_280_0002}");
    		return;
    	}
    	    	
        if (!confirm("${msg.M0021}")) return;
        if ("${param.qtaSq}" != '') {
            var store = new EVF.Store();
            store.load(baseUrl + "qtaSubItem/doSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        } else {
            doClose();
        }
    }

    function calculateSum() {
        var qtaATM = 0;
        var currency = EVF.getComponent('CUR').getValue();
        for (var i = 0; i < grid.getRowCount(); i++) {
            var price = everCurrency.getPrice(currency, grid.getCellValue('UNIT_PRC', i));
            qtaATM = everCurrency.getAmount(currency, qtaATM + price);
        }
        EVF.getComponent('QTA_ATM').setValue(qtaATM);
    }
    
    function onCellChange(strColumnKey, nRow, oVal, nVal) {

        if (strColumnKey === 'UNIT_PRC') {

            if (Number(nVal) < 0) {
                alert('${SPX_030_0001}');
                grid.setCellValue(strColumnKey, nRow, oVal);
                return;
            }
            calculateSum();
        }

        //wiseDate.diffWithServerDate(nVal, function(status, message){
        //gridUtil.setRowData(grid, nRow, JSON.parse(this.getParameter('result')), [{source: 'ITEM_DESC_ENG', target: 'ITEM_DESC'}]);
    }

    function doClose() {
        if ("${param.detailView }" === "false") {
	        var gridStringData = JSON.stringify(grid.getAllRowValue());
	        opener['${param.callBackFunction}'](gridStringData, '${param.rowid}');
        }
        formUtil.close();
    }
	
	
	</script>

    <e:window id="SPX_030" onReady="init" initData="${initData}" title="${fullScreenName}" margin="0 5px 0 5px">

        <e:inputHidden id='RFX_NUM' name='RFX_NUM' />
        <e:inputHidden id='RFX_CNT' name='RFX_CNT' />
        <e:inputHidden id='RFX_SQ' name='RFX_SQ' />
        <e:inputHidden id='QTA_NUM' name='QTA_NUM' />
        <e:inputHidden id='QTA_SQ' name='QTA_SQ' />
        <e:inputHidden id='SAVED_QTA_ATM' name='SAVED_QTA_ATM' />

        <e:buttonBar>
            <e:inputNumber id='QTA_ATM' name="QTA_ATM" onChange="formUtil.onChangeValueNumeric" align='right' width='${inputNumberWidth }' readOnly='true' required="false" disabled="false" />
            <e:inputText id='CUR' name="CUR" width='50' readOnly="true" disabled="false" required="false" maxLength="100" />
            <e:button label='${doClose_N }' id='doClose' onClick='doClose' align="right" />
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' align="right" />
        </e:buttonBar>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>