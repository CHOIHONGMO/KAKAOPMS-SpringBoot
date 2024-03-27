<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BOD1/BOD103/";
        var eventRowId = 0;
        var signStatus = "T";
		//var signStatus = "T";
		var custCommonAccUseFlag = "${custCommonAccUseFlag}";
		var buyerBudgetUseFlag = "${ses.buyerBudgetUseFlag}";

        function init() {
//         	if( "${ses.plantFlag}" == "1" ) {
//         		EVF.C("PLANT_CD").setRequired(true);
//         	} else {
//         		EVF.C("PLANT_CD").setRequired(false);
//         		EVF.C("PLANT_CD").setDisabled(true);
//         		EVF.C("PLANT_CD").setReadOnly(true);
//         	}

        	if( "${ses.costCenterFlag}" == "1" ) {
        		EVF.C("COST_CENTER_CD").setRequired(true);
        	} else {
        		EVF.C("COST_CENTER_CD").setRequired(false);
        		EVF.C("COST_CENTER_CD").setDisabled(true);
        		EVF.C("COST_CENTER_NM").setDisabled(true);
        	}
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {

            	eventRowId = rowId;

                if(colId === "multiSelect") {
                    var ITEM_TOT_AMT = 0;
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        ITEM_TOT_AMT += Number(rows[i].ITEM_AMT);
                    }
                    EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                    EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));
                }
                if (colId == "ITEM_CD") {
            		var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupYn': "Y",
                            'detailView': false
                        };
                    everPopup.im03_014open(param);
                }
                /* if (colId == "VENDOR_NM") {
            		var param = {
                            'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': true,
                            'popupFlag': true
                        };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } */
				if (colId == "BD_DEPT_NM") {
					if( buyerBudgetUseFlag == '1' && (EVF.isEmpty("${ACCOUNT_CD}") || "${ACCOUNT_CD}" == "")) {
						var popupUrl = "/evermp/SY01/SY0101/SY01_004/view";
						var param = {
							callBackFunction: "setGridDeptCd",
							'AllSelectYN': true,
							'parentsSelectYN': false,
							'detailView': false,
							'multiYN': false,
							'ModalPopup': true,
							'custCd' : EVF.V("CUST_CD"),
							'custNm' : "${ses.companyNm }"
						};
						everPopup.openModalPopup(popupUrl, 500, 600, param, "setGridDeptCd");
					} else {
						return;
					}
				}
            	if (colId == "ACCOUNT_CD") {
					if( buyerBudgetUseFlag == '1' && (EVF.isEmpty("${ACCOUNT_CD}") || "${ACCOUNT_CD}" == "")) {
						var param = {
							callBackFunction : "setGridAccountCd",
							BD_DEPT_CD		 : grid.getCellValue(rowId, 'BD_DEPT_CD')
						};
						everPopup.openCommonPopup(param, 'SP0087');
					} else {
						return;
					}
                }
                if (colId == "COST_CENTER_CD") {
                    var param = {
						callBackFunction: "setGridCostCenterCd",
						custCd : EVF.V("CUST_CD")
					};
                    everPopup.openCommonPopup(param, 'SP0036');
                }
            	if (colId == "RECIPIENT_NM") {
            		var param = {
						callBackFunction : "setGridDelyInfo",
						CUST_CD : EVF.V("CUST_CD"),
						USER_ID : EVF.V("CUST_USER_ID"),
						detailView : false
					};
                    //everPopup.openPopupByScreenId("MY01_006", 800, 600, param);
            		everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                }
            	if (colId == "DELY_ZIP_CD") {
            		var url = '/common/code/BADV_020/view';
                    var param = {
                        callBackFunction : "setGridZipCode",
                        modalYn : false
                    };
                    //everPopup.openWindowPopup(url, 700, 600, param);
                    everPopup.jusoPop(url, param);
                }
            	if (colId == "REQ_TEXT") {
            		var url = '/common/popup/common_text_input/view';
            		var param = {
						title : '요청사항',
						message : grid.getCellValue(rowId, 'DELY_RMK'),
						callbackFunction : 'setGridDelyText',
						detailView : false,
						rowId : rowId
					};
            	    everPopup.openModalPopup(url, 500, 320, param);
                }
            	if (colId == "ATTACH_FILE_NO_IMG") {
            		var param = {
						attFileNum: grid.getCellValue(rowId, 'ATTACH_FILE_NO'),
						rowId: rowId,
						callBackFunction: 'setAttFile',
						havePermission: true,
						bizType: 'CART',
						fileExtension: '*'
					};
                    everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                }
            });

            grid.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {

            	if(colId == 'CART_QT') {
            		var mouQty = Number(grid.getCellValue(rowid, "MOQ_QTY")); // 최소주문량
            		var rvQty  = Number(grid.getCellValue(rowid, "RV_QTY")); // 주문배수
        			var cartQt = Number(grid.getCellValue(rowid, "CART_QT")); // 주문수량
        			var itemtotAmt = 0;

					if(value > 0) {
						//if(!(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0))) {
                        if(!(cartQt >= mouQty && (cartQt === mouQty || cartQt % rvQty === 0)) && rvQty != 0) {

    						if(mouQty <= rvQty) {
    							grid.setCellValue(rowid, "CART_QT", grid.getCellValue(rowid, 'RV_QTY'));
    						} else {
    							grid.setCellValue(rowid, "CART_QT", grid.getCellValue(rowid, 'MOQ_QTY'));
    						}

                        	itemtotAmt = parseInt(grid.getCellValue(rowid, 'CART_QT')) * parseInt(grid.getCellValue(rowid, 'UNIT_PRC'));
                            grid.setCellValue(rowid, "ITEM_AMT", itemtotAmt);
                            return alert("${BOD1_030_011}");
                        }
					}
                    if( value != oldValue ) {
                        var unitPrc = Number(grid.getCellValue(rowid, "UNIT_PRC")); // 단가
                        var itemAmt = cartQt * unitPrc;
                        grid.setCellValue(rowid, "ITEM_AMT", everMath.round_float(itemAmt, 0));

                        var ITEM_TOT_AMT = 0;
                        var rows = grid.getSelRowValue();
                        for( var i = 0; i < rows.length; i++ ) {
                            ITEM_TOT_AMT += Number(rows[i].ITEM_AMT);
                        }

                        EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                        EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));

                        // 수량 변경시 예산체크 여부 Clear
                        grid.setCellValue(rowid, 'BUDGET_CHECK_FLAG', "");
                    }
            	}
            	if(colId == 'HOPE_DUE_DATE') {
            		var cpoDate = EVF.V("ORD_DATE");
                    if( Number(cpoDate) > Number(grid.getCellValue(rowid, "HOPE_DUE_DATE")) ) {
                    	grid.setCellValue(rowid, "HOPE_DUE_DATE", oldValue);
                    	return alert("${BOD1_030_012}");
                    }
            	}
            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {
                if(checked) {
                    var ITEM_TOT_AMT = 0;
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        ITEM_TOT_AMT += Number(rows[i].ITEM_AMT);
                    }
                    EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                    EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));
                } else {
                    EVF.V("ITEM_TOT_AMT", "0");
                    EVF.V("ITEM_TOT_CNT", "0");
                }
            };

			grid._gvo.onImageButtonClicked = function (gridObj, rowId, column, buttonIdx, name) {

				var value;
				var mouQty = Number(grid.getCellValue(rowId, 'MOQ_QTY')); // 최소주문량
				switch (name) {
					case "upButton":
						value = grid.getCellValue(rowId, column.name);
						grid.setCellValue(rowId, column.name, Number(value) + mouQty);
					break;
					case "downButton":
						value = grid.getCellValue(rowId, column.name);
						if(Number(value) > mouQty) {
							grid.setCellValue(rowId, column.name, Number(value) <= 0 ? 0 : Number(value) - mouQty);
						}
					break;
				}

				var itemtotAmt = 0;
				var cartQt = Number(grid.getCellValue(rowId, "CART_QT")); // 주문수량
				var unitPrc = Number(grid.getCellValue(rowId, "UNIT_PRC")); // 단가
				if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0)) {
					/* if(cartQt >= mouQty && (cartQt === mouQty || (cartQt - mouQty) % rvQty === 0)) { */
					itemtotAmt = cartQt * unitPrc;
					grid.setCellValue(rowId, "ITEM_AMT", itemtotAmt);
				} else {
					grid.setCellValue(rowId, "CART_QT", grid.getCellValue(rowId, 'MOQ_QTY'));
					itemtotAmt = cartQt * unitPrc;
					grid.setCellValue(rowId, "ITEM_AMT", itemtotAmt);
					return alert("${BOD1_030_011}");
				}

				var formItemAmt = 0;
				var rowIds = grid.getSelRowId();
				for (var i in rowIds) {
					formItemAmt += Number(grid.getCellValue(rowIds[i], 'ITEM_AMT'));
				}

				EVF.V("ITEM_TOT_AMT", comma(String(formItemAmt)));
				EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));

				// 수량 변경시 예산체크 여부 Clear
				grid.setCellValue(rowId, 'BUDGET_CHECK_FLAG', "");
			};

            grid.dupRowEvent(function() {

            }, ["ITEM_STATUS","CUST_ITEM_CD","ITEM_CD","ITEM_DESC","ITEM_SPEC","MAKER_CD","MAKER_NM","MAKER_PART_NO","BRAND_CD","BRAND_NM",
                "ORIGIN_CD","VENDOR_CD","VENDOR_NM","UNIT_CD","MOQ_QTY","RV_QTY","CUR","UNIT_PRC","TAX_CD","LEAD_TIME","LEAD_TIME_DATE",
                "APPLY_COM","CONT_NO","CONT_SEQ","SG_CTRL_USER_ID","ITEM_REQ_NO","ITEM_REQ_SEQ","DEAL_CD"]);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            // 예산사용여부
            var isCheckBudget = EVF.V("CUST_BUDGET_FLAG");
            if( isCheckBudget != '1' ) {
            	/*EVF.C("doCheckBudget").setDisabled(true);*/
				EVF.C("doCheckBudget").setVisible(false);
            } else {
            	grid.setColRequired("ACCOUNT_CD", true); // 계정코드 필수
            	grid.setColRequired("BD_DEPT_CD", true); // 예산부서 필수
            	grid.setColRequired("BD_DEPT_NM", true); // 예산부서 필수
            	EVF.V("BD_DEPT_CD","${ses.companyCd}"+"-"+"${ses.plantCd}"+"-"+"${form.DIVISION_CD}"+"-"+"${ses.deptCd}");
            	EVF.V("BD_DEPT_NM","${ses.deptNm}");

				var accountCd = "${ACCOUNT_CD}";
				var accountNm = "${ACCOUNT_NM}";
				if(!EVF.isEmpty(accountCd) && accountCd != "") {
					EVF.V("ACCOUNT_CD", accountCd);
					EVF.V("ACCOUNT_NM", accountNm);
					EVF.C('ACCOUNT_NM').setReadOnly(true);
				}
            }

            // ses의 companyCd와 코드의 값이 일치하면 form, grid ACCOUNT_NM 필수체크
			var ifVendorList = JSON.parse('${ifVendorList}');
			for(var i in ifVendorList) {
				if("${ses.companyCd}" == ifVendorList[i].CUST_CD) {
					EVF.C("ACCOUNT_NM").setRequired(true);
					grid.setColRequired("ACCOUNT_CD", true);
					grid.setColRequired("ACCOUNT_NM", true);
				}
			}


            // 주문정보 일괄적용 collepse
	        // $(".e-panel-titlebar").trigger('click');

            priorGrFlagCheck(); // 선입고여부
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            //if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.setParameter("buyerBudgetUseFlag", "${ses.buyerBudgetUseFlag}");
            store.setParameter("custCommonAccUseFlag", custCommonAccUseFlag);
            store.load(baseUrl + 'BOD1_030/doSearch', function() {
            	var itemTotal = 0;

            	if(grid.getRowCount() > 0){
	            	var rowIds = grid.getAllRowId();
	                for( var i in rowIds ) {
	                    if(Number(grid.getCellValue(rowIds[i], 'ITEM_AMT')) > 0) {
							grid.checkRow(rowIds[i], true);
						}
	                	itemTotal += Number(grid.getCellValue(rowIds[i], 'ITEM_AMT'));
	        		}
            	}
                EVF.C("ITEM_TOT_AMT").setValue(comma(String(itemTotal)));
                EVF.C("ITEM_TOT_CNT").setValue(comma(String(grid.getSelRowCount())));

                if('${ses.costCenterFlag}' == '1') {
                	grid.setColRequired("COST_CENTER_CD",true);
                }else {
                	grid.hideCol("COST_CENTER_CD",true);
                	grid.hideCol("COST_CENTER_NM",true);
                }
//                 if('${ses.plantFlag}' == '1') {
//                 	grid.setColRequired("PLANT_CD",true);
//                 }else {
//                 	grid.hideCol("PLANT_CD",true);
//                 }
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {

                if( Number(grid.getCellValue(rowIds[i], 'CART_QT')) <= 0 || EVF.isEmpty(grid.getCellValue(rowIds[i], 'CART_QT')) || grid.getCellValue(rowIds[i], 'CART_QT') == "" ) {
    				return alert("${BOD1_030_016}");
    			}
				if(grid.getCellValue(rowIds[i], 'ITEM_STATUS') != '10'){
					return alert("${BOD1_030_018}");
				}
            	var mouQty = Number(grid.getCellValue(rowIds[i], "MOQ_QTY")); // 최소주문량
        		var rvQty  = Number(grid.getCellValue(rowIds[i], "RV_QTY")); // 주문배수
    			var cartQt = Number(grid.getCellValue(rowIds[i], "CART_QT")); // 주문수량
    			var itemtotAmt = 0;
    			// 주문수량 >= 최소주문량 and 주문수량 = 최소주문량 * 발주배수
    			//if(!(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0))) {
//   			    if(!(cartQt >= mouQty && (cartQt == mouQty || rvQty != 0 || cartQt % rvQty == 0))) {
// 				   return alert("${BOD1_030_011}");
//                }

                if(cartQt >= mouQty && (cartQt == mouQty || rvQty == 0 || cartQt % rvQty == 0)) {

                } else {
    				   return alert("${BOD1_030_011}");
                }




    		}

            if(!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BOD1_030/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if( grid.getCellValue(rowIds[i], 'MNG_YN') == "1" ) {
    				return alert("${BOD1_030_001}");
    			}
    		}

            if (!confirm("${msg.M0013 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BOD1_030/doDelete', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doOrder() {
			if(EVF.V('PR_SUBJECT') =='' || EVF.V('PR_SUBJECT') ==null){
				$("#PR_SUBJECT").focus();
				return alert("${BOD1_030_017}");
			}
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            // 내부고객사(C00007)
            // 230201 : 사무용품비, 240102 : 소모품비
            // 240101 : 소모성기구비, 240103 : 소모품비(화주요청)
        	<%-- var inCustCd = "${inCustCd}"; --%>
        	var cuCustCd = "${ses.companyCd}";
			var userAutoPoFlag = "0";
			var relatYn  = "${ses.relatYn}";
			// 관계사일 경우 1회 주문 시 1000만원 미만 체크
			if(relatYn == "Y" && cuCustCd != "C00004") {
				var ITEM_TOT_AMT = 0;
				var rows = grid.getSelRowValue();
				for( var i = 0; i < rows.length; i++ ) {
					ITEM_TOT_AMT += Number(rows[i].ITEM_AMT);

					if(ITEM_TOT_AMT >= 50000000) {
						return alert("${BOD1_030_014}");
					}
				}
			}

            // 예산체크여부 = y ? 예산체크 해야함
        	var accountCdFlag = "";
            var isCheckBudget = EVF.V("CUST_BUDGET_FLAG");
            if( isCheckBudget == '1') {
                // 내부고객인 경우 예산 전결라인 적용
				<%--
                if( inCustCd == cuCustCd ) {
                    var selRowId = grid.getSelRowId();
                    for( var i in selRowId ) {
                    	// 내부 고객사인 경우 예산코드 중복 배제
                    	if( accountCdFlag != "" && accountCdFlag != checkAccountCd(grid.getCellValue(selRowId[i], 'ACCOUNT_CD')) ){
                    		return alert("${BOD1_030_013}");
                    	}
                    	accountCdFlag = checkAccountCd(grid.getCellValue(selRowId[i], 'ACCOUNT_CD'));
                    }
                }
                --%>

                var rowSelId = grid.getSelRowId();
                for( var i in rowSelId ) {
	            	// 예산체크하지 않은 품목이 존재하는 경우
	            	if( grid.getCellValue(rowSelId[i], 'BUDGET_CHECK_FLAG') == "" ){
	            		return alert("${BOD1_030_004}");
	            	}
	            	// 예산체크하지 않은 품목이 존재하는 경우
	            	if( grid.getCellValue(rowSelId[i], 'BUDGET_CHECK_FLAG') == "N" ){
	            		return alert("${BOD1_030_005}");
	            	}
	            	if(grid.getCellValue(rowIds[i], 'ITEM_STATUS') != '10'){
						return alert("${BOD1_030_018}");
					}
                }
            }

            // 선입고 : 주문일자 <= 현재일자
            var priorGrFlag = EVF.C("FIRST_GR_FLAG").isChecked();
            var cpoDate = EVF.V("ORD_DATE");
            var curDate = new Date().toString('yyyyMMdd');
            if( priorGrFlag ) {
            	if( Number(cpoDate) >= Number(curDate) )
            	return alert("${BOD1_030_009}");
            }

            // 품목상태 : 사용, 주문수량 > 0
            var ITEM_TOT_AMT = 0;
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	if( grid.getCellValue(rowIds[i], 'ITEM_STATUS') != '10' ) {
    				return alert("${BOD1_030_007}");
    			}
            	if( Number(grid.getCellValue(rowIds[i], 'CART_QT')) == 0 || EVF.isEmpty(grid.getCellValue(rowIds[i], 'CART_QT')) || grid.getCellValue(rowIds[i], 'CART_QT') == "" ) {
    				return alert("${BOD1_030_016}");
    			}
            	if( Number(grid.getCellValue(rowIds[i], 'ITEM_AMT')) == 0 ) {
    				return alert("${BOD1_030_015}");
    			}

            	var mouQty = Number(grid.getCellValue(rowIds[i], "MOQ_QTY")); // 최소주문량 1
        		var rvQty  = Number(grid.getCellValue(rowIds[i], "RV_QTY")); // 주문배수 2
    			var cartQt = Number(grid.getCellValue(rowIds[i], "CART_QT")); // 주문수량 2

				if(cartQt > 0) {
					if(!(cartQt >= mouQty && (cartQt === mouQty || cartQt % rvQty === 0))) {
						if(rvQty != 0){
	                    	return alert("${BOD1_030_011}");
						} else if(cartQt < mouQty) {
	                    	return alert("${BOD1_030_011}");
						}
                    }
                }

    			if( Number(cpoDate) > Number(grid.getCellValue(rowIds[i], "HOPE_DUE_DATE")) ) {
                	return alert("${BOD1_030_012}");
                }

            	ITEM_TOT_AMT += Number(grid.getCellValue(rowIds[i], 'ITEM_AMT'));
    		}



            if(!confirm('${BOD1_030_006}')) { return; }

            // 결재사용여부 = 1
            var approvalFlag = EVF.V("CUST_SIGN_FLAG");
            if( approvalFlag == "1" && userAutoPoFlag != "1") {
            	var bizCls1  = "";
            	var bizCls2  = "";
            	var bizCls3  = "";
            	if( accountCdFlag == "1" ){
            		bizCls1  = "09"; // 주문
                	bizCls2  = "10"; // 계정별
                	bizCls3  = "08"; // 사무용품비
            	} else if( accountCdFlag == "2" ){
            		bizCls1  = "09"; // 주문
                	bizCls2  = "10"; // 계정별
                	bizCls3  = "10"; // 소모성기구비
            	} else if( accountCdFlag == "3" ){
            		bizCls1  = "09"; // 주문
                	bizCls2  = "10"; // 계정별
                	bizCls3  = "09"; // 소모품비
            	} else if( accountCdFlag == "4" ){
            		bizCls1  = "09"; // 주문
                	bizCls2  = "10"; // 계정별
                	bizCls3  = "11"; // 소모품비(화주요청)
            	}

                signStatus = "P";
                var subject = grid.getCellValue(rowIds[0], 'ITEM_DESC');
            	var param = {
					subject: (grid.getSelRowCount() == 1 ? ("[" + subject + "] 건 주문 결재요청") : ("[" + subject + "] 외 " + (Number(grid.getSelRowCount()) - 1) + "건 주문 결재요청")),
					docType: "CPO",
					signStatus: signStatus,
					screenId: "BOD1_030",
					approvalType: 'APPROVAL',
					oldApprovalFlag: "",
					attFileNum: "",
					docNum: "",
					appDocNum: "",
					callBackFunction: "goApproval",
//					bizCls1: bizCls1, // 전결라인1
//					bizCls2: bizCls2, // 전결라인2
//					bizCls3: bizCls3, // 전결라인3
					bizAmt: ITEM_TOT_AMT+"",
					reqUserId: "${ses.userId}",
					prSubject:EVF.V("PR_SUBJECT")
				};
                everPopup.openApprovalRequestIIPopup(param);
            } else {
            	goApproval();
            }
        }

        // 결재창 오픈
        function goApproval(formData, gridData, attachData) {

            var appFormData;
            var appSignStatus;
            if(signStatus == "P") {
                EVF.C('approvalFormData').setValue(formData);
                EVF.C('approvalGridData').setValue(gridData);
                EVF.C('attachFileDatas').setValue(attachData);
                appFormData = JSON.parse(formData);
                appSignStatus = EVF.isEmpty(appFormData.SIGN_STATUS) ? "P" : appFormData.SIGN_STATUS;
            } else {
                appSignStatus = "E";
			}

        	var store = new EVF.Store();
        	store.doFileUpload(function() {
            	store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.setParameter("signStatus", (appSignStatus == "E" ? appSignStatus : signStatus));
            	store.load(baseUrl + 'BOD1_030/doOrder', function () {
                    alert(this.getResponseMessage());
                    var param = {
                        'detailView': false,
                        'popupFlag': true
                    };
                    window.location.href = '/evermp/BOD1/BOD103/BOD1_030/view.so?' + $.param(param);
                });
            });
	    }

        function checkAccountCd(accountCd) {
        	var rlt = "";
        	if( accountCd == "230201" ) { // 230201 : 사무용품비,
        		rlt = "1";
        	} else if( accountCd == "240101" ) { // 240101 : 소모성기구비,
        		rlt = "2";
        	} else if( accountCd == "240102" ) { // 240102 : 소모품비
        		rlt = "3";
        	} else if( accountCd == "240103" ) { // 240103 : 소모품비(화주요청)
        		rlt = "4";
        	}
        	return rlt;
        }

        function doopenConCart() {
        	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

        	var itemInfo = "";
        	var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	itemCd   = grid.getCellValue(rowIds[i], 'ITEM_CD');
            	applyCom = grid.getCellValue(rowIds[i], 'APPLY_COM');
            	contNum  = grid.getCellValue(rowIds[i], 'CONT_NO');
            	contSeq  = grid.getCellValue(rowIds[i], 'CONT_SEQ');

            	itemInfo = itemInfo + itemCd + ":" + applyCom + ":" + contNum + ":" + contSeq + ",";
    		}

        	var param = {
        			itemInfo : itemInfo,
        			detailView : false
        		};
        	everPopup.openPopupByScreenId('BOD1_032', 600, 400, param);
        }

        function doCheckBudget() {

        	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

        	var itemInfo = "";
        	var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	if( grid.getCellValue(rowIds[i], 'ITEM_STATUS') != '10' ) {
    				return alert("${BOD1_030_007}");
    			}
            	if( grid.getCellValue(rowIds[i], 'BD_DEPT_CD') == "" ) {
            		return alert("${BOD1_030_001}");
            	}
            	if( grid.getCellValue(rowIds[i], 'ACCOUNT_CD') == "" ) {
            		return alert("${BOD1_030_002}");
            	}
            	if( Number(grid.getCellValue(rowIds[i], 'ITEM_AMT')) == 0 ) {
            		return alert("${BOD1_030_003}");
            	}
            	deptCd    = grid.getCellValue(rowIds[i], 'BD_DEPT_CD');
            	accountCd = grid.getCellValue(rowIds[i], 'ACCOUNT_CD');
            	itemAmt   = grid.getCellValue(rowIds[i], 'ITEM_AMT');

            	itemInfo = itemInfo + deptCd + ":" + accountCd + ":" + itemAmt + ",";
    		}

        	var param = {
				itemInfo : itemInfo,
				callBackFunction : 'setCheckBudget',
				detailView : false
			};
        	var url = "/evermp/BOD1/BOD103/BOD1_031/view";
        	everPopup.openModalPopup(url, 840, 400, param);
        }

        function setCheckBudget(data) {
        	var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
            	grid.setCellValue(rowIds[i], 'BUDGET_CHECK_FLAG', data.budgetCheckFlag);
    		}
        }

        function searchCostCenter() {
            var param = {
                	custCd : EVF.V("CUST_CD"),
                	callBackFunction : "setCostCenterCd"
            	};
            everPopup.openCommonPopup(param, 'SP0036');
        }

        function setCostCenterCd(data) {
            EVF.C("COST_CENTER_CD").setValue(data.COST_CD);
            EVF.C("COST_CENTER_NM").setValue(data.COST_NM);
        }

        function searchDeptCd() {

			if( buyerBudgetUseFlag == '1' && (EVF.isEmpty("${ACCOUNT_CD}") || "${ACCOUNT_CD}" == "")) {
				if( EVF.isEmpty(EVF.V("CUST_CD")) || EVF.V("CUST_CD") == "" ) {
					return alert("${BOD1_050_001}");
				}
				var popupUrl = "/evermp/SY01/SY0101/SY01_004/view";
				var param = {
					 callBackFunction: "selectCustDeptCd",
					'AllSelectYN': true,
					'parentsSelectYN': false,
					'detailView': false,
					'multiYN': false,
					'ModalPopup': true,
					'custCd' : EVF.V("CUST_CD"),
					'custNm' : "${ses.companyNm }"
				};
				everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
			}
        }

        function selectCustDeptCd(dataJsonArray) {
        	data = JSON.parse(dataJsonArray);
        	if(data.CNT=='1'){
        		EVF.V("ACCOUNT_NM",data.ACCOUNT_NM);
        		EVF.V("ACCOUNT_CD",data.ACCOUNT_CD);
        	}
            EVF.C("BD_DEPT_CD").setValue('${ses.companyCd}'+"-"+data.ITEM_CLS1+"-"+data.ITEM_CLS2+"-"+data.ITEM_CLS3);
            EVF.C("BD_DEPT_NM").setValue(data.DEPT_NM);
        }

		function setGridDeptCd(dataJsonArray) {
			data = JSON.parse(dataJsonArray);
			if(data.CNT=='1'){
        		grid.setCellValue(eventRowId, 'ACCOUNT_NM', data.ACCOUNT_NM);
        		grid.setCellValue(eventRowId, 'ACCOUNT_CD', data.ACCOUNT_CD);
        	}
			grid.setCellValue(eventRowId, 'BD_DEPT_CD', '${ses.companyCd}'+"-"+data.ITEM_CLS1+"-"+data.ITEM_CLS2+"-"+data.ITEM_CLS3);
			grid.setCellValue(eventRowId, 'BD_DEPT_NM', data.DEPT_NM);
		}

        function searchAccountCd() {
			//if( buyerBudgetUseFlag == '1' && (EVF.isEmpty("${ACCOUNT_CD}") || "${ACCOUNT_CD}" == "")) {
				var param = {
					BD_DEPT_CD : EVF.V("BD_DEPT_CD"),
					callBackFunction : "setAccountCd"
				};
				everPopup.openCommonPopup(param, 'SP0087');
			//}
        }

        function setAccountCd(data) {
            EVF.C("ACCOUNT_CD").setValue(data.ACCOUNT_CD);
            EVF.C("ACCOUNT_NM").setValue(data.ACCOUNT_NM);
        }

        function searchZipCd() {
            var url = '/common/code/BADV_020/view';
            var param = {
                callBackFunction : "setZipCode",
                modalYn : false
            };
            //everPopup.openWindowPopup(url, 700, 600, param);
            everPopup.jusoPop(url, param);
        }

        function setZipCode(data) {
            if (data.ZIP_CD != "") {
                EVF.C("DELY_ZIP_CD").setValue(data.ZIP_CD_5);
                EVF.C('DELY_ADDR_1').setValue(data.ADDR1);
                EVF.C('DELY_ADDR_2').setValue(data.ADDR2);
                EVF.C('DELY_ADDR_2').setFocus();
            }
        }

/*         function searchDelyInfo() {
        	var param = {
                callBackFunction : "setDelyInfo",
                CUST_CD : EVF.V("CUST_CD"),
                USER_ID : EVF.V("CUST_USER_ID"),
                detailView : false
            };
        	everPopup.openPopupByScreenId("MY01_006", 800, 600, param);
        }

        function setDelyInfo(data) {
        	EVF.C("RECIPIENT_NM").setValue(data.HIDDEN_RECIPIENT_NM);
        	EVF.C("RECIPIENT_DEPT_NM").setValue(data.RECIPIENT_DEPT_NM);
        	EVF.C("RECIPIENT_TEL_NUM").setValue(data.HIDDEN_RECIPIENT_TEL_NUM);
        	EVF.C("RECIPIENT_CELL_NUM").setValue(data.HIDDEN_RECIPIENT_CELL_NUM);
        	EVF.C("DELY_ZIP_CD").setValue(data.DELY_ZIP_CD);
        	EVF.C("DELY_ADDR_1").setValue(data.DELY_ADDR_1);
        	EVF.C("DELY_ADDR_2").setValue(data.DELY_ADDR_2);
        	EVF.C("DELY_RMK").setValue(data.DELY_RMK);
        } */

        function searchDelyInfo() {

            var param = {
                callBackFunction: "setDelyInfo",
                CUST_CD: EVF.V("CUST_CD"),
                detailView : false
            };
            everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
    	}

	    function setDelyInfo(data) {

	    	EVF.C("CSDM_SEQ").setValue(data.CSDM_SEQ);
	    	EVF.C("DELY_NM").setValue(data.DELY_NM);
	    	EVF.C("RECIPIENT_NM").setValue(data.HIDDEN_DELY_RECIPIENT_NM);
        	EVF.C("RECIPIENT_TEL_NUM").setValue(data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
        	EVF.C("RECIPIENT_CELL_NUM").setValue(data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
        	EVF.C("RECIPIENT_EMAIL").setValue(data.HIDDEN_DELY_RECIPIENT_EMAIL);
        	EVF.C("RECIPIENT_FAX_NUM").setValue(data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
        	EVF.C("RECIPIENT_DEPT_NM").setValue(data.DELY_RECIPIENT_DEPT_NM);
        	EVF.C("DELY_ZIP_CD").setValue(data.DELY_ZIP_CD);
        	EVF.C("DELY_ADDR_1").setValue(data.DELY_ADDR_1);
        	EVF.C("DELY_ADDR_2").setValue(data.DELY_ADDR_2);
	    }

        function setGridAccountCd(data) {
            grid.setCellValue(eventRowId, 'ACCOUNT_CD', data.ACCOUNT_CD);
            grid.setCellValue(eventRowId, 'ACCOUNT_NM', data.ACCOUNT_NM);
        }

        function setGridCostCenterCd(data) {
            grid.setCellValue(eventRowId, 'COST_CENTER_CD', data.COST_CD);
            grid.setCellValue(eventRowId, 'COST_CENTER_NM', data.COST_NM);
        }

        function setGridZipCode(data) {
            if (data.ZIP_CD != "") {
            	grid.setCellValue(eventRowId, "DELY_ZIP_CD", data.ZIP_CD_5);
            	grid.setCellValue(eventRowId, 'DELY_ADDR_1', data.ADDR1);
            	grid.setCellValue(eventRowId, 'DELY_ADDR_2', data.ADDR2);

            	grid.setCellValue(eventRowId, 'CSDM_SEQ', '');
            	grid.setCellValue(eventRowId, 'DELY_NM', '');

            	//grid.setCellValue(eventRowId, 'DELY_ADDR_2', '');
            }
        }

        function setGridDelyInfo(data) {
        	grid.setCellValue(eventRowId, "CSDM_SEQ", data.CSDM_SEQ);
        	grid.setCellValue(eventRowId, "DELY_NM", data.DELY_NM);
        	grid.setCellValue(eventRowId, "RECIPIENT_NM", data.HIDDEN_DELY_RECIPIENT_NM);
        	grid.setCellValue(eventRowId, "RECIPIENT_TEL_NUM", data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
        	grid.setCellValue(eventRowId, "RECIPIENT_CELL_NUM", data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
        	grid.setCellValue(eventRowId, "RECIPIENT_EMAIL", data.HIDDEN_DELY_RECIPIENT_EMAIL);
        	grid.setCellValue(eventRowId, "RECIPIENT_FAX_NUM", data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
        	grid.setCellValue(eventRowId, "RECIPIENT_DEPT_NM", data.DELY_RECIPIENT_DEPT_NM);
        	grid.setCellValue(eventRowId, "DELY_ZIP_CD", data.DELY_ZIP_CD);
        	grid.setCellValue(eventRowId, "DELY_ADDR_1", data.DELY_ADDR_1);
        	grid.setCellValue(eventRowId, "DELY_ADDR_2", data.DELY_ADDR_2);
        	grid.setCellValue(eventRowId, "DELY_RMK", data.DELY_RMK);

        	/* grid.setCellValue(eventRowId, "RECIPIENT_NM", data.HIDDEN_RECIPIENT_NM);
        	grid.setCellValue(eventRowId, "RECIPIENT_DEPT_NM", data.RECIPIENT_DEPT_NM);
        	grid.setCellValue(eventRowId, "RECIPIENT_TEL_NUM", data.HIDDEN_RECIPIENT_TEL_NUM);
        	grid.setCellValue(eventRowId, "RECIPIENT_CELL_NUM", data.HIDDEN_RECIPIENT_CELL_NUM);
        	grid.setCellValue(eventRowId, "DELY_ZIP_CD", data.DELY_ZIP_CD);
        	grid.setCellValue(eventRowId, "DELY_ADDR_1", data.DELY_ADDR_1);
        	grid.setCellValue(eventRowId, "DELY_ADDR_2", data.DELY_ADDR_2);
        	grid.setCellValue(eventRowId, "DELY_RMK", data.DELY_RMK); */
        }

        function setGridDelyText(data){
        	grid.setCellValue(data.rowId, 'REQ_TEXT', data.message);
        }

        function setAttFile(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, 'ATTACH_FILE_NO', fileId);
            grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', fileCnt);
        }

        // 일괄적용
        function doOneApply() {

        	var store = new EVF.Store();
        	EVF.C('PR_SUBJECT').setRequired(false)
        	if(!store.validate()) { return;}
        	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        	if(!confirm('${BOD1_030_010}')) { return; }
        	EVF.C('PR_SUBJECT').setRequired(true)
        	var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if( EVF.V("BD_DEPT_CD") != "" ) {
                	grid.setCellValue(rowIds[i], 'BD_DEPT_CD', EVF.V("BD_DEPT_CD"));
                	grid.setCellValue(rowIds[i], 'BD_DEPT_NM', EVF.V("BD_DEPT_NM"));
                }
                if( EVF.V("ACCOUNT_CD") != "" ) {
                	grid.setCellValue(rowIds[i], 'ACCOUNT_CD', EVF.V("ACCOUNT_CD"));
                	grid.setCellValue(rowIds[i], 'ACCOUNT_NM', EVF.V("ACCOUNT_NM"));
                }
                if( EVF.V("CSDM_SEQ") != "" ) {
                	grid.setCellValue(rowIds[i], 'CSDM_SEQ', EVF.V("CSDM_SEQ"));
                	grid.setCellValue(rowIds[i], 'DELY_NM', EVF.V("DELY_NM"));
                }
                if( EVF.V("RECIPIENT_NM") != "" ) {
                	grid.setCellValue(rowIds[i], 'RECIPIENT_NM', EVF.V("RECIPIENT_NM"));
                }
                if( EVF.V("RECIPIENT_DEPT_NM") != "" ) {
                	grid.setCellValue(rowIds[i], 'RECIPIENT_DEPT_NM', EVF.V("RECIPIENT_DEPT_NM"));
                }
                if( EVF.V("RECIPIENT_TEL_NUM") != "" ) {
                	grid.setCellValue(rowIds[i], 'RECIPIENT_TEL_NUM', EVF.V("RECIPIENT_TEL_NUM"));
                }
                if( EVF.V("RECIPIENT_FAX_NUM") != "" ) {
                	grid.setCellValue(rowIds[i], 'RECIPIENT_FAX_NUM', EVF.V("RECIPIENT_FAX_NUM"));
                }
                if( EVF.V("RECIPIENT_CELL_NUM") != "" ) {
                	grid.setCellValue(rowIds[i], 'RECIPIENT_CELL_NUM', EVF.V("RECIPIENT_CELL_NUM"));
                }
                if( EVF.V("RECIPIENT_EMAIL") != "" ) {
                	grid.setCellValue(rowIds[i], 'RECIPIENT_EMAIL', EVF.V("RECIPIENT_EMAIL"));
                }
                if( EVF.V("HOPE_DUE_DATE") != "" ) {
                	grid.setCellValue(rowIds[i], 'HOPE_DUE_DATE', EVF.V("HOPE_DUE_DATE"));
                }
                if( EVF.V("DELY_ZIP_CD") != "" ) {
                	grid.setCellValue(rowIds[i], 'DELY_ZIP_CD', EVF.V("DELY_ZIP_CD"));
                }
                if( EVF.V("DELY_ADDR_1") != "" ) {
                	grid.setCellValue(rowIds[i], 'DELY_ADDR_1', EVF.V("DELY_ADDR_1"));
                }
                if( EVF.V("DELY_ADDR_2") != "" ) {
                	grid.setCellValue(rowIds[i], 'DELY_ADDR_2', EVF.V("DELY_ADDR_2"));
                }
                if( EVF.V("REQ_RMK") != "" ) {
                	grid.setCellValue(rowIds[i], 'REQ_TEXT', EVF.V("REQ_RMK"));
                }
                if( EVF.V("REF_MNG_NO") != "" ) {
                	grid.setCellValue(rowIds[i], 'REF_MNG_NO', EVF.V("REF_MNG_NO"));
                }
                if( EVF.V("COST_CENTER_CD") != "" ) {
                	grid.setCellValue(rowIds[i], 'COST_CENTER_CD', EVF.V("COST_CENTER_CD"));
                	grid.setCellValue(rowIds[i], 'COST_CENTER_NM', EVF.V("COST_CENTER_NM"));
                }
//                 if( EVF.V("PLANT_CD") != "" ) {
//                 	grid.setCellValue(rowIds[i], 'PLANT_CD', EVF.V("PLANT_CD"));
//                 }
                if( EVF.V("FIRST_GR_FLAG") == "1" ) {
                	grid.setCellValue(rowIds[i], 'PRIOR_GR_FLAG', EVF.V("FIRST_GR_FLAG"));
                }
            }
        }
        //새로고침
        function doRefresh() {

        	doSearch();
        }
        function priorGrFlagCheck() {
        	var priorGrFlag = EVF.C("FIRST_GR_FLAG").isChecked();
            if (priorGrFlag) {
            	EVF.C("ORD_DATE").setReadOnly(false);
            } else {
            	EVF.C("ORD_DATE").setValue('${addToDate}');
            	EVF.C("ORD_DATE").setReadOnly(true);
            }
        }

		function comma(obj) {
			var regx = new RegExp(/(-?\d+)(\d{3})/);
			var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
			var strArr = obj.split('.');
			while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
				//정수 부분에만 콤마 달기
				strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
			}
			if (bExists > -1) {
				//. 소수점 문자열이 발견되지 않을 경우 -1 반환
				obj = strArr[0] + "." + strArr[1];
			} else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
				obj = strArr[0];
			}
			return obj;//문자열 반환
		}

      	function doPrint() {
	        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

	        var cartSeq = "";
	        var rowIds = grid.getSelRowId();
	        for( var i in rowIds ) {
		        cartSeq += grid.getCellValue(rowIds[i], 'CART_SEQ') + ",";
	        }
	        if(cartSeq.length > 0) { cartSeq = cartSeq.substring(0, cartSeq.length - 1); }

	        var localFlag = "${localFlag}";
	        var host_info; var oz_info;
	        if(localFlag == "true") {
		        oz80_url = location.protocol + "//" + location.hostname + ":" + "7070/oz80";
	        } else {
		        oz80_url = location.protocol + "//" + location.hostname + ":" + "7071/oz80";
	        }

	        var param = {
		          MANAGE_CD : '${ses.manageCd}'
		        , COMPANY_CD : '${ses.companyCd}'
				, CART_SEQ : cartSeq
	        };

	        var url = oz80_url + "/ozhviewer/BOD1_030.jsp";
	        everPopup.openWindowPopup(url, 1000, 700, param, "", true);
		}
    </script>

    <e:window id="BOD1_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:panel id="Panel1" height="fit" width="50%">
            <e:title title="${BOD1_030_CAPTION1 }" depth="1"/>
        </e:panel>
        <e:searchPanel id="form1" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false">
        	 <e:panel id="Panel1-1" height="fit" width="50%">
	            <e:buttonBar id="buttonBar3" align="right" width="100%">
	                <e:button id="doRefresh" name="doRefresh" label="${doRefresh_N}" onClick="doRefresh" disabled="${doRefresh_D}" visible="${doRefresh_V}"/>
	            </e:buttonBar>
	        </e:panel>
            <e:inputHidden id="CUST_SIGN_FLAG"   name="CUST_SIGN_FLAG" value="${ses.buyerApproveUseFlag}" /> <!-- 결재사용여부 -->
			<e:inputHidden id="approvalFormData" name="approvalFormData" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" />
            <e:inputHidden id="attachFileDatas"  name="attachFileDatas" />

            <e:inputHidden id="CUST_BUDGET_FLAG" name="CUST_BUDGET_FLAG" value="${ses.buyerBudgetUseFlag}" /> <!-- 예산사용여부 -->
            <e:inputHidden id="CUST_CD"      name="CUST_CD" value="${ses.companyCd }" /> <!-- 고객사코드 -->
            <e:inputHidden id="CUST_USER_ID" name="CUST_USER_ID" value="${ses.userId }" /> <!-- 주문자ID -->
            <e:inputHidden id="CUST_DEPT_CD" name="CUST_DEPT_CD" value="${ses.deptCd }" /> <!-- 주문자부서코드 -->
            <e:inputHidden id="CUST_TEL_NUM" name="CUST_TEL_NUM" value="${ses.telNum }" /> <!-- 주문자전화번호 -->
            <e:inputHidden id="CUST_HP_NUM"  name="CUST_HP_NUM" value="${ses.cellNum }" /> <!-- 주문자헨드폰번호 -->
			<e:inputHidden id="AUTO_PO_FLAG" name="AUTO_PO_FLAG" value="${form.AUTO_PO_FLAG}" />

            <e:row>
				<e:label for="CUST_SIGN_FLAG" title="${form_CUST_SIGN_FLAG_N}"/>
				<e:field>
					<e:text>${(ses.buyerApproveUseFlag) == '1' ? 'Y' : 'N' }</e:text>
				</e:field>
				<e:label for="CUST_BUDGET_FLAG" title="${form_CUST_BUDGET_FLAG_N}"/>
				<e:field>
					<e:text>${(ses.buyerBudgetUseFlag) == '1' ? 'Y' : 'N' }</e:text>
				</e:field>
				<e:label for="CUST_NM" title="${form_CUST_NM_N}" />
				<e:field>
					<e:text>${ses.companyNm }</e:text>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="CUST_USER_NM" title="${form_CUST_USER_NM_N}" />
				<e:field>
					<e:text>${ses.userNm }</e:text>
				</e:field>
				<e:label for="CUST_DEPT_NM" title="${form_CUST_DEPT_NM_N}" />
				<e:field>
				 	<e:text width="100px">${ses.plantNm }</e:text>
					<e:text> / </e:text>
				    <e:text width="100px">${form.DIVISION_NM}</e:text>
					<e:text> / </e:text>
					<e:text width="100px">${ses.deptNm }</e:text>

				</e:field>
				<e:label for="CUST_TEL_NUM" title="${form_CUST_TEL_NUM_N}" />
				<e:field>
					<e:text>${ses.telNum }</e:text>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="CUST_HP_NUM" title="${form_CUST_HP_NUM_N}" />
				<e:field>
					<e:text>${ses.cellNum }</e:text>
				</e:field>
				<e:label for="CUST_EMAIL" title="${form_CUST_EMAIL_N}" />
				<e:field colSpan="3">
					<e:text>${ses.email }</e:text>
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}" />
				<e:field colSpan="5">
					<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="${form_PR_SUBJECT_W}" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel id="form2" title="${BOD1_030_CAPTION2 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="true" collapsed="false">
            <e:row>
				<e:label for="BD_DEPT_NM" title="${form_BD_DEPT_NM_N}"/>
				<e:field>
					<e:inputHidden id="BD_DEPT_CD" name="BD_DEPT_CD" value="" />
					<e:search id="BD_DEPT_NM" name="BD_DEPT_NM" value="" width="${form_BD_DEPT_NM_W}" maxLength="${form_BD_DEPT_NM_M}" onIconClick="searchDeptCd" disabled="${form_BD_DEPT_NM_D}" readOnly="${form_BD_DEPT_NM_RO}" required="${form_BD_DEPT_NM_R}" />
				</e:field>
				<e:label for="ACCOUNT_NM" title="${form_ACCOUNT_NM_N}"/>
				<e:field>
					<e:inputHidden id="ACCOUNT_CD" name="ACCOUNT_CD" value="" />
					<e:search id="ACCOUNT_NM" name="ACCOUNT_NM" value="" width="${form_ACCOUNT_NM_W}" maxLength="${form_ACCOUNT_NM_M}" onIconClick="searchAccountCd" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
				</e:field>
				<e:label for="FIRST_GR_FLAG" title="${form_FIRST_GR_FLAG_N}"/>
				<e:field>
					<e:check id='FIRST_GR_FLAG' name="FIRST_GR_FLAG" value="1" checked="false" width='${form_FIRST_GR_FLAG_W }' required='${form_FIRST_GR_FLAG_R }' disabled='${form_FIRST_GR_FLAG_D }' visible='${form_FIRST_GR_FLAG_V }' onClick="priorGrFlagCheck" />
					<e:button id="doOneApply" name="doOneApply" label="${doOneApply_N}" onClick="doOneApply" disabled="${doOneApply_D}" visible="${doOneApply_V}" align="right"/>
				</e:field>
            </e:row>
            <e:row>
            	<e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}"></e:label>
                <e:field>
                	<e:inputText id="CSDM_SEQ" style='ime-mode:inactive' name="CSDM_SEQ" value="${form.CSDM_SEQ}" width="20%" maxLength="${form_CSDM_SEQ_M}" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
                    <e:inputText id="DELY_NM" style='ime-mode:inactive' name="DELY_NM" value="${form.DELY_NM}" width="80%" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="true" required="${form_DELY_NM_R}" />
                </e:field>
				<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_NM" name="RECIPIENT_NM" value="${form.DELY_RECIPIENT_NM}" width="${form_RECIPIENT_NM_W}" maxLength="${form_RECIPIENT_NM_M}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO}" required="${form_RECIPIENT_NM_R}" />
				</e:field>
				<e:label for="ORD_DATE" title="${form_ORD_DATE_N}"/>
				<e:field>
					<e:inputDate id="ORD_DATE" name="ORD_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_ORD_DATE_R}" disabled="${form_ORD_DATE_D}" readOnly="${form_ORD_DATE_RO}" />
				</e:field>

            </e:row>
            <e:row>
				<e:inputHidden id="RECIPIENT_TEL_NUM" name="RECIPIENT_TEL_NUM"/>
				<e:inputHidden id="RECIPIENT_FAX_NUM" name="RECIPIENT_FAX_NUM"/>
				<e:inputHidden id="RECIPIENT_DEPT_NM" name="RECIPIENT_DEPT_NM"/>
				<e:label for="RECIPIENT_EMAIL" title="${form_RECIPIENT_EMAIL_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" value="${form.DELY_RECIPIENT_EMAIL }" width="${form_RECIPIENT_EMAIL_W}" maxLength="${form_RECIPIENT_EMAIL_M}" disabled="${form_RECIPIENT_EMAIL_D}" readOnly="${form_RECIPIENT_EMAIL_RO}" required="${form_RECIPIENT_EMAIL_R}" />
				</e:field>

				<e:label for="RECIPIENT_CELL_NUM" title="${form_RECIPIENT_CELL_NUM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${form.DELY_RECIPIENT_CELL_NUM }" width="${form_RECIPIENT_CELL_NUM_W}" maxLength="${form_RECIPIENT_CELL_NUM_M}" disabled="${form_RECIPIENT_CELL_NUM_D}" readOnly="${form_RECIPIENT_CELL_NUM_RO}" required="${form_RECIPIENT_CELL_NUM_R}" />
				</e:field>
				<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
				<e:field>
					<e:inputDate id="HOPE_DUE_DATE" fromDate="ORD_DATE" name="HOPE_DUE_DATE" value="" width="${inputDateWidth}" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
				</e:field>
            </e:row>
 	<c:choose>
		<c:when test="${ses.plantFlag == 'z'}">
            <e:row>
				<e:label for="DELY_ZIP_CD" title="${form_DELY_ZIP_CD_N}"/>
				<e:field>
					<e:search id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${form.DELY_ZIP_CD }" width="80px" maxLength="${form_DELY_ZIP_CD_M}" onIconClick="searchZipCd" disabled="${form_DELY_ZIP_CD_D}" readOnly="${form_DELY_ZIP_CD_RO}" required="${form_DELY_ZIP_CD_R}" />
					<e:text>&nbsp;</e:text>
					<e:button id="getDelyLocation" name="getDelyLocation" label="${getDelyLocation_N}" onClick="searchDelyInfo" disabled="${getDelyLocation_D}" visible="${getDelyLocation_V}"/>
				</e:field>
				<e:label for="DELY_ADDR_1" title="${form_DELY_ADDR_1_N}" />
				<e:field>
					<e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="${form.DELY_ADDR_1 }" width="${form_DELY_ADDR_1_W}" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
            </e:row>
		</c:when>
		<c:otherwise>
            <e:row>
				<e:label for="DELY_ZIP_CD" title="${form_DELY_ZIP_CD_N}"/>
				<e:field>
					<e:search id="DELY_ZIP_CD" name="DELY_ZIP_CD" value="${form.DELY_ZIP_CD }" width="80px" maxLength="${form_DELY_ZIP_CD_M}" onIconClick="searchZipCd" disabled="${form_DELY_ZIP_CD_D}" readOnly="${form_DELY_ZIP_CD_RO}" required="${form_DELY_ZIP_CD_R}" />
					<e:text>&nbsp;</e:text>
					<e:button id="getDelyLocation" name="getDelyLocation" label="${getDelyLocation_N}" onClick="searchDelyInfo" disabled="${getDelyLocation_D}" visible="${getDelyLocation_V}"/>
				</e:field>
         		<e:label for="DELY_ADDR_1" title="${form_DELY_ADDR_1_N}" />
				<e:field colSpan="3">
					<e:inputText id="DELY_ADDR_1" name="DELY_ADDR_1" value="${form.DELY_ADDR_1 }" width="${form_DELY_ADDR_1_W}" maxLength="${form_DELY_ADDR_1_M}" disabled="${form_DELY_ADDR_1_D}" readOnly="${form_DELY_ADDR_1_RO}" required="${form_DELY_ADDR_1_R}" />
				</e:field>
            </e:row>
 		</c:otherwise>
	</c:choose>
            <e:row>
				<e:label for="REF_MNG_NO" title="${form_REF_MNG_NO_N}" />
				<e:field>
					<e:inputText id="REF_MNG_NO" name="REF_MNG_NO" value="" width="${form_REF_MNG_NO_W}" maxLength="${form_REF_MNG_NO_M}" disabled="${form_REF_MNG_NO_D}" readOnly="${form_REF_MNG_NO_RO}" required="${form_REF_MNG_NO_R}" />
				</e:field>
				<e:label for="DELY_ADDR_2" title="${form_DELY_ADDR_2_N}" />
				<e:field colSpan="3">
					<e:inputText id="DELY_ADDR_2" name="DELY_ADDR_2" value="${form.DELY_ADDR_2 }" width="${form_DELY_ADDR_2_W}" maxLength="${form_DELY_ADDR_2_M}" disabled="${form_DELY_ADDR_2_D}" readOnly="${form_DELY_ADDR_2_RO}" required="${form_DELY_ADDR_2_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="REQ_RMK" title="${form_REQ_RMK_N}"/>
				<e:field colSpan="5">
					<e:textArea id="REQ_RMK" name="REQ_RMK" value="${form.REQ_RMK }" height="100px" width="${form_REQ_RMK_W}" maxLength="${form_REQ_RMK_M}" disabled="${form_REQ_RMK_D}" readOnly="${form_REQ_RMK_RO}" required="${form_REQ_RMK_R}" />
				</e:field>
            </e:row>
	<c:choose>
		<c:when test="${ses.costCenterFlag == '1'}">
            <e:row>
				<e:label for="COST_CENTER_CD" title="${form_COST_CENTER_CD_N}" />
				<e:field>
					<e:search id="COST_CENTER_CD" name="COST_CENTER_CD" value="" width="${form_COST_CENTER_CD_W}" maxLength="${form_COST_CENTER_CD_M}" onIconClick="${ses.costCenterFlag == '1' ? 'searchCostCenter' : 'everCommon.blank'}" disabled="${form_COST_CENTER_CD_D}" readOnly="${form_COST_CENTER_CD_RO}" required="${form_COST_CENTER_CD_R}" />
				</e:field>
				<e:label for="COST_CENTER_NM" title="${form_COST_CENTER_NM_N}" />
				<e:field>
					<e:inputText id="COST_CENTER_NM" name="COST_CENTER_NM" value="${form.COST_CENTER_NM }" width="${form_COST_CENTER_NM_W}" maxLength="${form_COST_CENTER_NM_M}" disabled="${form_COST_CENTER_NM_D}" readOnly="${form_COST_CENTER_NM_RO}" required="${form_COST_CENTER_NM_R}" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
<%-- 				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}" /> --%>
<%-- 				<e:field> --%>
<%--                     <e:select id="PLANT_CD" name="PLANT_CD" value="" options="${plantList}" width="${form_PLANT_CD_W}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder=""/> --%>
<%--                 </e:field> --%>
            </e:row>
		</c:when>
			<c:otherwise>
				<e:inputHidden id="COST_CENTER_CD"  name="COST_CENTER_CD" value="" />
				<e:inputHidden id="COST_CENTER_NM"  name="COST_CENTER_NM" value="" />
				<e:inputHidden id="PLANT_CD"  name="PLANT_CD" value="" />
			</c:otherwise>
	</c:choose>
		</e:searchPanel>

		<e:panel id="Panel4" height="fit" width="20%">
            <e:title title="${BOD1_030_CAPTION3 }" depth="1"/>
        </e:panel>
        <e:panel id="Panel5" height="fit" width="30%">
        	<e:text style="color:red;font-weight:bold;font-size:14px;">합 계 : </e:text>
        	<e:text id="ITEM_TOT_AMT" name="ITEM_TOT_AMT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
			<e:text style="color:gray;">(부가세별도)</e:text>
			<e:text style="color:red;font-weight:bold;font-size:14px;">, 선택건수 : </e:text>
			<e:text id="ITEM_TOT_CNT" name="ITEM_TOT_CNT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
			<e:text style="color:red;font-weight:bold;font-size:14px;"> 건</e:text>
        </e:panel>
        <e:panel id="Panel6" height="fit" width="50%">
            <e:buttonBar id="buttonBar2" align="right" width="100%">
                <e:button id="doCheckBudget" name="doCheckBudget" label="${doCheckBudget_N}" onClick="doCheckBudget" disabled="${doCheckBudget_D}" visible="${doCheckBudget_V}"/>
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
                <e:button id="openConCart" name="openConCart" label="${openConCart_N}" onClick="doopenConCart" disabled="${openConCart_D}" visible="${openConCart_V}"/>
                <e:button id="doOrder" name="doOrder" label="${doOrder_N}" onClick="doOrder" disabled="${doOrder_D}" visible="${doOrder_V}"/>
			</e:buttonBar>
        </e:panel>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>