<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
    var grid;
    var baseUrl = "/eversrm/solicit/rfq/";

    function init() {
        grid = EVF.C("grid");

        grid.delRowEvent(function() {
			grid.delRow();
        });        
        
        grid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
        	
        });
        
        grid.cellChangeEvent(function(rowId, colKey, iRow, iCol, newVal, oldVal) {
        	onCellChange(colKey, rowId, oldVal, newVal);
        });
        
        // Grid Excel Event
        grid.excelExportEvent({
          allCol : "${excelExport.allCol}",
          selRow : "${excelExport.selRow}",
          fileType : "${excelExport.fileType }",
          fileName : "${screenName }",
          excelOptions : {
            imgWidth      : 0.12, 		// 이미지 너비
            imgHeight     : 0.26,		    // 이미지 높이
            colWidth      : 20,        	// 컬럼의 넓이
            rowSize       : 500,       	// 엑셀 행에 높이 사이즈
            attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
          }
        });
        
        // 대금지불정보를 저장하지 않고, 화면에만 있는 경우 해당 정보를 세팅해준다.
        if ('${param.PAY_TYPES}' != null && '${param.PAY_TYPES}' != '') {
        	var data = JSON.parse('${param.PAY_TYPES}');
            var arrData = [];
        	for (var k = 0; k < data.length; k++) {
                arrData.push({
                	PAY_SQ          : data[k].PAY_SQ,
                	PAY_CNT_TYPE    : data[k].PAY_CNT_TYPE,
                	PAY_PERCENT     : data[k].PAY_PERCENT,
                	PAY_AMT         : String(data[k].PAY_AMT).replace('.',''),
                	PAY_METHOD_TYPE : data[k].PAY_METHOD_TYPE,
                	PAY_METHOD_NM   : data[k].PAY_METHOD_NM ,
                	PAY_DUE_DATE    : data[k].PAY_DUE_DATE 
                });
                
                EVF.getComponent('PAY_CNT').setValue(k+1);
        	}
        	grid.addRow(arrData);
        } else {
        
        // 품의번호가 있는 경우 품의번호에 해당하는 대금지불정보를 가져온다.
        if ('${param.EXEC_NUM}' != '') {
        	doSearch();
        }       
        }
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + "BFAR_030/doSearch", function() {
        	EVF.getComponent('PAY_CNT').setValue(grid.getRowCount() );
        });
    }
    
    function doApply() {
        if (EVF.getComponent('PAY_TYPE').getValue() == "LS" && EVF.getComponent('PAY_CNT').getValue() > 1) {
            alert("${BFAR_030_0003}");
            return;
        }
    	var cnt = EVF.getComponent('PAY_CNT').getValue();
    	
    	grid.delAllRow();
        var arrData = [];
    	for (var k =0; k<cnt;k++) {
            arrData.push({
            	PAY_SQ : k+1
            });
    	}
    	grid.addRow(arrData);
    }
    
    function changePayType() {
    	grid.delAllRow();
    }    
    
    function doSave() {
    	var store = new EVF.Store();
        if(!store.validate()) return;
    	grid.checkAll(true);
    	if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
            alert("${msg.M0004}");
            return;
        }
    	
    	if(!grid.validate().flag) {
    		alert(grid.validate().msg);
            return false;
        }
        var currency = EVF.getComponent('CUR').getValue();
        var approvalAmount = EVF.getComponent('EXEC_AMT').getValue();
        var pay_type = EVF.getComponent('PAY_TYPE').getValue();
        var pay_type_nm = EVF.getComponent('PAY_TYPE').getText();

        var gridAmount = 0;
        var gridper = 0;
        for (var nRow = 0; nRow < grid.getRowCount(); nRow++) {
			gridAmount = gridAmount + Number(grid.getCellValue(nRow,'PAY_AMT'));
			gridper = gridper + Number(grid.getCellValue(nRow,'PAY_PERCENT'));
        }
        
        if (gridper != 100) {
            alert("${BFAR_030_0013}");
            return;
        }
        
        if (gridAmount != approvalAmount) {
            alert("${BFAR_030_0005}");
            return;
        }    	
        
        var sformData = JSON.stringify(grid.getSelRowValue());
        opener.${param.callBackFunction}(pay_type, pay_type_nm, sformData, ${param.rowid});
    	doClose();
    }
    
    function doClose() {
    	window.close();
    }

    function onCellChange(strColumnKey, nRow, oVal, nVal) {

        grid.setCellValue( nRow, 'DEL_FLAG', 'U');

        if (strColumnKey === 'PAY_DUE_DATE') {
//        	alert(grid.getCellValue(nRow,'PAY_DUE_DATE' ))
        	
        	everDate.diffWithServerDate(grid.getCellValue(nRow,'PAY_DUE_DATE' ), function(status, message) {
                if (status === '-1') {
                    alert('${BFAR_030_0012}');
                    grid.setCellValue(nRow,strColumnKey, oVal);
                }
            }, "true");
        }

        if (strColumnKey == "PAY_PERCENT") {
            if (nVal > 100 || nVal < 0) {
                alert("${BFAR_030_0010}");
                grid.setCellValue(nRow,"PAY_PERCENT", oVal);
                return;
            }

            var currency = EVF.getComponent('CUR').getValue();
            var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('EXEC_AMT').getValue());
            var payAmt = everCurrency.getAmount(currency, nVal * approvalAmount / 100);
            grid.setCellValue(nRow, 'PAY_AMT', payAmt);
            var remainPercent = 100 - nVal;
            for (var i = 0; i < grid.getRowCount(); i++) {
            	
            	ii = grid.getRowId(i);
            	
                if (ii != nRow) {
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
        }

        
        
        if (strColumnKey == "PAY_AMT") {
            var currency = EVF.getComponent('CUR').getValue();
            
            var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('EXEC_AMT').getValue());
            var payAmt = everCurrency.getAmount(currency, nVal);

            if (payAmt > approvalAmount || payAmt < 0) {
                alert("${BFAR_030_0005}");
                grid.setCellValue(nRow,"PAY_AMT", oVal);
                return;
            }

            var currency = EVF.getComponent('CUR').getValue();
            var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('EXEC_AMT').getValue());
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
//					alert(totoalper)
//					alert(everMath.round_float(100.00 - totoalper,2))
                    grid.setCellValue(ii,'PAY_AMT', approvalAmount - totoalMat );
                    grid.setCellValue(ii,'PAY_PERCENT', everMath.round_float(100.00 - totoalper,2));
				}
                
            }
        }
    }
    
    function chPayTemplete() {
        var store = new EVF.Store();
        store.setParameter('PAY_TEMPLTET',EVF.getComponent('PAY_TEMPLTET').getValue());
        store.load(baseUrl + "BFAR_030/doSearchTemplete", function() {
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
            var approvalAmount = everCurrency.getAmount(currency, EVF.getComponent('EXEC_AMT').getValue());
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

    <e:window id="BFAR_030" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
            <e:row>
				<e:label for="PAY_TYPE" title="${form_PAY_TYPE_N}"/>
				<e:field>
					<e:select id="PAY_TYPE" name="PAY_TYPE" onChange="changePayType" value="${param.PAY_TYPE}" options="${payTypeOptions}" width="${inputTextWidth}" disabled="${form_PAY_TYPE_D}" readOnly="${form_PAY_TYPE_RO}" required="${form_PAY_TYPE_R}" placeHolder="" />
				</e:field>   
				<e:label for="PAY_CNT" title="${form_PAY_CNT_N}"/>
				<e:field>
					<e:inputNumber id="PAY_CNT" name="PAY_CNT" value="${form.PAY_CNT}" width="30" maxValue="${form_PAY_CNT_M}" decimalPlace="${form_PAY_CNT_NF}" disabled="${form_PAY_CNT_D}" readOnly="${form_PAY_CNT_RO}" required="${form_PAY_CNT_R}" />
					<e:text>&nbsp;</e:text>
				<c:if test="${param.detailView != 'true' }">
					<e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
				</c:if>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="EXEC_AMT" title="${form_EXEC_AMT_N}"/>
				<e:field>
				<e:inputNumber id="EXEC_AMT" name="EXEC_AMT" value="${param.EXEC_AMT}" maxValue="${form_EXEC_AMT_M}" decimalPlace="${form_EXEC_AMT_NF}" disabled="${form_EXEC_AMT_D}" readOnly="${form_EXEC_AMT_RO}" required="${form_EXEC_AMT_R}" />
				</e:field>
				<e:label for="CUR" title="${form_CUR_N}"/>
				<e:field>
				<e:inputText id="CUR" style="ime-mode:inactive" name="CUR" value="${param.CUR}" width="${inputTextWidth}" maxLength="${form_CUR_M}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}"/>
				</e:field>
			    <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${param.EXEC_NUM}"/>
			    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"/>
			</e:row>
			<c:if test="${param.detailView != 'true' }">
	            <e:row>
					<e:label for="PAY_TEMPLTET" title="${form_PAY_TEMPLTET_N}"/>
					<e:field colSpan="3">
					<e:select id="PAY_TEMPLTET" name="PAY_TEMPLTET" onChange="chPayTemplete"  value="${form.PAY_TEMPLTET}" options="${payTempltetOptions}" width="100%" disabled="${form_PAY_TEMPLTET_D}" readOnly="${form_PAY_TEMPLTET_RO}" required="${form_PAY_TEMPLTET_R}" placeHolder="" />
					</e:field>
				</e:row>
			</c:if>
        </e:searchPanel>

        <e:buttonBar align="right">
			<c:if test="${param.detailView != 'true' }">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			</c:if>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>

