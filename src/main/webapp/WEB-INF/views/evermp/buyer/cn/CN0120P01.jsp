<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    	var gridP = {};
        var delRows = [];
        var baseUrl = "/evermp/buyer/cn/CN0120/";

        function init() {
        	gridP = EVF.C("gridP");
        	gridP.setProperty('panelVisible', ${panelVisible});
        	gridP.setProperty('shrinkToFit', true);
        	gridP.setProperty("footerVisible", {visible: true, count: 1, height: 20});
        	var footerTxt = {
                    styles: {
                        textAlignment: "center",
                        font: "굴림,12",
                        background:"#ffffff",
                        foreground:"#FF0000",
                        fontBold: true
                    },
                    text: ["합 계"]
                };
        	var footerSum = {
                    styles: {
                        textAlignment: "far",
                        suffix: " ",
                        background:"#ffffff",
                        foreground:"#FF0000",
                        numberFormat: "###,###",
                        fontBold: true
                    },
                    text: "0",
                    expression: ["sum"],
                    groupExpression: "sum"
                };
        	gridP.setRowFooter("PAY_CNT_NM", footerTxt);
        	gridP.setRowFooter("PAY_PERCENT", footerSum);
        	gridP.setRowFooter("SUPPLY_AMT", footerSum);
        	gridP.setRowFooter("VAT_AMT", footerSum);
        	gridP.setRowFooter("PAY_AMT", footerSum);
        	initAmt();
            gridP.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {

                if (colIdx == "PAY_PERCENT" || colIdx == "VAT_TYPE") {
                    if(EVF.isEmpty(EVF.V("EXEC_AMT"))) {
                        EVF.alert("${CN0120P01_0011}");
                        gridP.setCellValue(rowIdx, 'PAY_PERCENT', '');
                        return;
                    }
                    var contAmt = Number(EVF.V("SUPPLY_AMT"));
                    var payPer = Number(gridP.getCellValue(rowIdx, 'PAY_PERCENT'));
                    var payAmt = 0;
                    if(payPer > 0 && contAmt > 0) {
                        payAmt = Math.round(contAmt * (payPer / 100));
                    } else {
                        payAmt = 0;
                    }
                    gridP.setCellValue(rowIdx, 'SUPPLY_AMT', payAmt);
                    if(gridP.getCellValue(rowIdx, 'VAT_TYPE') == "1") { // 부가세포함
                        gridP.setCellValue(rowIdx, 'VAT_AMT', (payAmt * 0.1));
                        payAmt = payAmt + (payAmt * 0.1);
                    } else if(gridP.getCellValue(rowIdx, 'VAT_TYPE') == "0") {
                        gridP.setCellValue(rowIdx, 'VAT_AMT', (payAmt * 0.1));
                    } else {
                        gridP.setCellValue(rowIdx, 'VAT_AMT', 0);
                    }
                    gridP.setCellValue(rowIdx, 'PAY_AMT', payAmt);
                    headerSum();
                } else if(colIdx == "SUPPLY_AMT" || colIdx == "VAT_AMT"){
                	var amt = Number(gridP.getCellValue(rowIdx, 'SUPPLY_AMT'))+Number(gridP.getCellValue(rowIdx, 'VAT_AMT'))
                	gridP.setCellValue(rowIdx, 'PAY_AMT', amt);
					sumAmtfn();
                }
            });
			var tempPayInfo = '${param.PAY_INFO}';

			if (tempPayInfo!='') {
				var pay_info = JSON.parse(`${param.PAY_INFO}`);
				gridP.addRow(pay_info);
				sumAmtfn();
			} else {
				changePayType();
			}
        }
		function initAmt(){
			 var contAmt = Number(EVF.V("SUPPLY_AMT"));
			 var vatAmt  = Math.round(contAmt *0.1);
			 EVF.V("VAT_AMT",vatAmt);
			 EVF.V("EXEC_AMT",contAmt+vatAmt)
		}
	   function sumAmtfn(){
		   var iemIds = gridP.getAllRowId();
		   var sumVatAmt = 0;
		   var sumPayAmt = 0;
		   for(var m =0; m < iemIds.length;m++){
       			sumVatAmt += Number(gridP.getCellValue(iemIds[m], 'VAT_AMT'));
       			sumPayAmt += Number(gridP.getCellValue(iemIds[m], 'PAY_AMT'));

       	   }
		   EVF.V("VAT_AMT",sumVatAmt);
		   EVF.V("EXEC_AMT",sumPayAmt);
	   }
		function headerSum() {
			var vatType = EVF.V("VAT_TYPE");
			//alert(EVF.V("SUPPLY_AMT"))
			//alert(vatType)
			var iemIds = gridP.getAllRowId();
			var sumAmt = 0;
        	for(var m =0; m < iemIds.length;m++){
        		var contAmt = Number(EVF.V("SUPPLY_AMT"));
                var payPer = Number(gridP.getCellValue(iemIds[m], 'PAY_PERCENT'));
                var payAmt = 0;
                if(payPer > 0 && contAmt > 0) {
                    payAmt = Math.round(contAmt * (payPer / 100));
                } else {
                    payAmt = 0;
                }
        		gridP.setCellValue(iemIds[m], 'VAT_TYPE', EVF.V("VAT_TYPE"))
       			sumAmt+= gridP.getCellValue(iemIds[m],'PAY_AMT'); //부가세 포함금액
       			gridP.setCellValue(iemIds[m], 'VAT_AMT', (payAmt * 0.1));
                payAmt = payAmt + (payAmt * 0.1);
        		gridP.setCellValue(iemIds[m], 'PAY_AMT', payAmt);
        	}


		}



        function changePayType() {
            gridP.delAllRow();
            if(EVF.V("PAY_TYPE") == "LS") {
                EVF.V('PAY_CNT', 1);
                gridP.addRow([{"PAY_CNT": 1, "PAY_CNT_TYPE": "BP", "PAY_CNT_NM": "잔금", "VAT_TYPE": '1'}]);
            } else {
                if(EVF.isEmpty("${form.PAY_CNT}")) { EVF.V('PAY_CNT', ''); }
            }
        }




        function doApply() {

            // 일시불이고, 적용차수가 1보다 큰경우 알림창
            if (EVF.V('PAY_TYPE') == "LS" || Number(EVF.V('PAY_CNT')) < 1) {
                return EVF.alert("${CN0120P01_0010}");
            }
            if(EVF.V("PAY_TYPE") == "IS" && Number(EVF.V('PAY_CNT')) == 1) {
                EVF.alert("${CN0120P01_0015}");
                EVF.V('PAY_CNT', '');
                return;
            }

            gridP.delAllRow();
            var payCnt = Number(EVF.V('PAY_CNT'));
            for(var i = 0; i < payCnt; i++) {
                var payCntType = "PP";
                var payCntNm = "중도금";
                if(i == 0) {
                    payCntType = "DP";
                    payCntNm = "선급금";
                }
                if((i+1) == payCnt) {
                    payCntType = "BP";
                    payCntNm = "잔금";
                }
                gridP.addRow([{"PAY_CNT": (i + 1), "PAY_CNT_TYPE": payCntType, "PAY_CNT_NM": payCntNm, "VAT_TYPE": '1'}]);
            }
            gridP._gvo.setPasteOptions({enableAppend:false});
        }

		function doClose(){
			window.close();
		}


		function getPayMethod() {
            var buyerCd = EVF.V('PR_BUYER_CD');
            param = {
                 BUYER_CD : buyerCd
                ,callBackFunction : 'setPayMethod'
            }
            everPopup.openCommonPopup(param, 'SP0055');
		}

       function setPayMethod(data){
            EVF.C('PAY_METHOD_NM').setValue(data.CODE_DESC);
            EVF.C('PAY_METHOD').setValue(data.CODE);
        }

		function doSave() {
			var store = new EVF.Store();
			if(!store.validate()) {	return;	}

            if (!gridP.validate().flag) { return EVF.alert("대금지급정보의 " + gridP.validate().msg); }

            var supplyAmt = Math.floor(EVF.V("SUPPLY_AMT"));
            var vatAmt    = Math.floor(EVF.V('VAT_AMT'))
            var execAmt   = Math.floor(EVF.V('EXEC_AMT'))

            var rowValues = gridP.getAllRowValue();
        	var totalAmt 		 = 0;
        	var totalExecAmt 	 = 0;
        	var totalVatAmt 	 = 0;
        	var totalPer 		 = 0;
            var totalContGuarAmt = 0;
        	var totalAdvGuarAmt  = 0;
        	var totalWarrGuarAmt = 0;
        	for(var k =0; k < rowValues.length;k++){
        		totalAmt+=rowValues[k].SUPPLY_AMT
        		totalVatAmt+=rowValues[k].VAT_AMT
        		totalPer+=rowValues[k].PAY_PERCENT
        		totalExecAmt+=rowValues[k].PAY_AMT
        	 	if(rowValues[k].PAY_CNT_TYPE =='DP'){
        			totalContGuarAmt+=rowValues[k].PAY_AMT;
        		}else if(rowValues[k].PAY_CNT_TYPE =='PP'){
        			totalAdvGuarAmt+=rowValues[k].PAY_AMT;
        		}else if(rowValues[k].PAY_CNT_TYPE =='BP'){
        			totalWarrGuarAmt+=rowValues[k].PAY_AMT;
        		}
        	}
        	//지급율100
			if(totalPer!=100){
				EVF.alert("${CN0120P01_0002}")
				return;
			}
//         	//세액금액 그리드 금액 합
//         	console.log(totalVatAmt)
// 			if(Math.floor(totalVatAmt) !=  vatAmt){
// 				EVF.alert("${CN0120P01_0003}");
// 				return;
// 			}
        	//공급금액 그리드 금액 합.
			if (Math.floor(supplyAmt) != totalAmt) {
				EVF.alert("${CN0120P01_0001}");
				return;
			}
// 			//지급금액 그리드 금액 합. execAmt
// 			if (Math.floor(totalExecAmt) != execAmt) {
// 				EVF.alert("${CN0120P01_0004}");
// 				return;
// 			}

			var rowId 			= '${param.rowId}';
			var pay_type 		= EVF.V('PAY_TYPE');
			var pay_cnt 		= EVF.V('PAY_CNT');
			var pay_method_nm 	= EVF.V('PAY_METHOD_NM');
// 			var pay_method 		= EVF.V('PAY_METHOD_NM');
			var pay_rmk 		= EVF.V('PAY_RMK');
			var vat_type 		= EVF.V('VAT_TYPE');
			var supply_amt 		= supplyAmt;
			var vat_amt 		= vatAmt;
			var cont_guar_amt 	= totalContGuarAmt;
			var adv_guar_amt    = totalAdvGuarAmt;
			var warr_guar_amt	= totalWarrGuarAmt;

			var payInfo = JSON.stringify(gridP.getAllRowValue());
			if('${param.gubn}'=='formFlag'){

				opener.setPayInfoForm(vat_amt,cont_guar_amt,adv_guar_amt,warr_guar_amt,rowId,pay_type,pay_cnt,pay_method_nm,pay_rmk,vat_type,supply_amt,payInfo);

			}else{
				opener.setPayInfoGrid(vat_amt,cont_guar_amt,adv_guar_amt,warr_guar_amt,rowId,pay_type,pay_cnt,pay_method_nm,pay_rmk,vat_type,supply_amt,payInfo);

			}
			doClose();
		}

    </script>

    <e:window id="CN0120P01" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
    	<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${param.PR_BUYER_CD}"/>
			<e:inputHidden id="VAT_TYPE" name="VAT_TYPE" value="1"/>
            <e:row>
                <e:label for="PAY_TYPE" title="${form_PAY_TYPE_N}"/>
                <e:field>
                    <e:select id="PAY_TYPE" name="PAY_TYPE" value="${param.PAY_TYPE}" options="${payTypeOptions}" width="120px" disabled="${form_PAY_TYPE_D}" readOnly="${form_PAY_TYPE_RO}" required="${form_PAY_TYPE_R}" placeHolder="" usePlaceHolder="false" onChange="changePayType" />
                </e:field>
                <e:label for="PAY_CNT" title="${form_PAY_CNT_N}"/>
                <e:field>
                    <e:inputNumber id="PAY_CNT" name="PAY_CNT" value="${param.PAY_CNT}" width="60px" required="${form_PAY_CNT_R }" disabled="${form_PAY_CNT_D }" readOnly="${form_PAY_CNT_RO }"/>
                    <e:text>&nbsp;</e:text>
                    <e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}"/>
                </e:field>
            </e:row>
            <e:row>
				<%--청구시기--%>
				<e:label for="PAY_METHOD_NM" title="${form_PAY_METHOD_NM_N}"/>
				<e:field colSpan="3">
					<e:inputText id="PAY_METHOD_NM" name="PAY_METHOD_NM" value="${param.PAY_METHOD_NM}" width="${form_PAY_METHOD_NM_W}" maxLength="${form_PAY_METHOD_NM_M}" disabled="${form_PAY_METHOD_NM_D}" readOnly="${form_PAY_METHOD_NM_RO}" required="${form_PAY_METHOD_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="PAY_RMK" title="${form_PAY_RMK_N}"/>
                <e:field colSpan="3">
                	<e:inputText id="PAY_RMK" name="PAY_RMK" value="${param.PAY_RMK}" width="${form_PAY_RMK_W}" maxLength="${form_PAY_RMK_M}" disabled="${form_PAY_RMK_D}" readOnly="${form_PAY_RMK_RO}" required="${form_PAY_RMK_R}" />

                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
       	    <e:text>공급가액 : </e:text>
       	    <e:inputNumber id="SUPPLY_AMT" name="SUPPLY_AMT" value="${param.EXEC_AMT}" width="${form_SUPPLY_AMT_W}" maxValue="${form_SUPPLY_AMT_M}" decimalPlace="${form_SUPPLY_AMT_NF}" disabled="${form_SUPPLY_AMT_D}" readOnly="${form_SUPPLY_AMT_RO}" required="${form_SUPPLY_AMT_R}" />
        	 <e:text>세액 : </e:text>
        	<e:inputNumber id="VAT_AMT" name="VAT_AMT" value="" width="${form_VAT_AMT_W}" maxValue="${form_VAT_AMT_M}" decimalPlace="${form_VAT_AMT_NF}" disabled="${form_VAT_AMT_D}" readOnly="${form_VAT_AMT_RO}" required="${form_VAT_AMT_R}" />
        	<e:text>지급금액 : </e:text>
			<e:inputNumber id="EXEC_AMT" name="EXEC_AMT" value="" width="${form_EXEC_AMT_W}" maxValue="${form_EXEC_AMT_M}" decimalPlace="${form_EXEC_AMT_NF}" disabled="${form_EXEC_AMT_D}" readOnly="${form_EXEC_AMT_RO}" required="${form_EXEC_AMT_R}" />

			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<%--
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
			--%>
        </e:buttonBar>


        <e:gridPanel gridType="${_gridType}" id="gridP" name="gridP" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>
