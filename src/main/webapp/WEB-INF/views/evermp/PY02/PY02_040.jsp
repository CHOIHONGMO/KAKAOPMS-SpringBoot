<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var grid;
		var baseUrl = "/evermp/PY02/";
		var ROW_ID;

		function init() {
			grid = EVF.C("grid");
			//grid.setProperty("sortable", false);

			grid.cellClickEvent(function (rowId, colId, value) {
				ROW_ID = rowId;

				if (colId === "multiSelect") {
					var GR_ITEM_AMT = 0;
					var PO_ITEM_AMT = 0;
					var MARGIN_RATE = 0;

					var rows = grid.getSelRowValue();
					for( var i = 0; i < rows.length; i++ ) {
						GR_ITEM_AMT += Number(rows[i].GR_AMT);
						PO_ITEM_AMT += Number(rows[i].PO_GR_ITEM_AMT);
					}

					if(PO_ITEM_AMT > 0) {
						MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
					}

					EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT)) + " 원");
					EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT)) + " 원");
					EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT - PO_ITEM_AMT)) + " 원");
					EVF.V("MARGIN_RATE", String(MARGIN_RATE) + " %");
				} else if (colId === "CUST_NM") {
					param = {
						CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
						detailView: true,
						popupFlag: true
					};
					everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
				} else if (colId == "VENDOR_NM") {
					param = {
						VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
						detailView: true,
						popupFlag: true
					};
					everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
				} else if (colId === "CPO_USER_NM") {
					param = {
						callbackFunction: "",
						USER_TYPE: "B",  // C:운영사, B:고객사, S:공급사
						USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
				} else if (colId === "GR_USER_NM") {
					var GR_AGENT_FLAG = grid.getCellValue(rowId, "GR_AGENT_FLAG");

					param = {
						callbackFunction: "",
						USER_TYPE: GR_AGENT_FLAG === "1" ? "C" : "B",  // C:운영사, B:고객사, S:공급사
						USER_ID: GR_AGENT_FLAG === "1" ? grid.getCellValue(rowId, "GR_USER_ID") : grid.getCellValue(rowId, "CPO_USER_ID"),
						detailView: true
					};
					everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
				} else if (colId === "CPO_NO") {
					param = {
						callbackFunction: "",
						CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
						CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
					};
					everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
				} else if (colId === "ITEM_CD") {
					if (value !== "") {
						param = {
							ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
							popupFlag: true,
							detailView: true
						};
						everPopup.im03_014open(param);
					}
                } else if(colId == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowId,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }
			});

			grid.cellChangeEvent(function (rowId, colId, iRow, iCol, value, oldValue) {

			});

			grid._gvo.onItemAllChecked = function (gridView, checked) {
				var GR_ITEM_AMT = 0;
				var PO_ITEM_AMT = 0;
				var MARGIN_RATE = 0;

				if(checked) {
					var rows = grid.getSelRowValue();
					for( var i = 0; i < rows.length; i++ ) {
						GR_ITEM_AMT += Number(rows[i].GR_AMT);
						PO_ITEM_AMT += Number(rows[i].PO_GR_ITEM_AMT);
					}

					MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);

					EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT)) + " 원");
					EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT)) + " 원");
					EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT - PO_ITEM_AMT)) + " 원");
					EVF.V("MARGIN_RATE", String(MARGIN_RATE) + " %");
				} else {
					EVF.V("TOT_GR_AMT", "0 원");
					EVF.V("TOT_PO_AMT", "0 원");
					EVF.V("MARGIN_AMT", "0 원");
					EVF.V("MARGIN_RATE", "0 %");
				}
			};

			grid.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${screenName }"
			});

			var val = {visible: true, count: 1, height: 40};
			var footerTxt = {
				styles: {
					textAlignment: "center",
					font: "굴림,12",
					background: "#ffffff",
					foreground: "#FF0000",
					fontBold: true
				},
				text: ["합 계"]
			};
			var footerSum = {
				styles: {
					textAlignment: "far",
					suffix: " ",
					background: "#ffffff",
					foreground: "#FF0000",
					numberFormat: "###,###",
					fontBold: true
				},
				text: "0",
				expression: ["sum"],
				groupExpression: "sum"
			};
			grid.setProperty("footerVisible", val);
			//grid.setRowFooter("PO_GR_UNIT_PRICE", footerTxt);

			grid.setRowFooter("CPO_ITEM_AMT", footerSum);
			grid.setRowFooter("PO_ITEM_AMT", footerSum);


			grid.setRowFooter("GR_AMT", footerSum);
			grid.setRowFooter("PO_GR_ITEM_AMT", footerSum);
			grid.setRowFooter("PROFIT_AMT", footerSum);

			/*
			grid.setColMerge(["CUST_NM", "DEPT_NM", "CPO_USER_NM", "CPO_NO", "CPO_SEQ", "PO_NO", "PO_SEQ",
				"CUST_ITEM_CD", "ITEM_CD", "ITEM_DESC", "ITEM_SPEC",
				"MAKER_NM", "MAKER_PART_NO", "UNIT_CD", "CUR", "VENDOR_NM", "TAX_NM",
				"BD_DEPT_CD", "BD_DEPT_NM", "ACCOUNT_CD", "ACCOUNT_NM", "CPO_DATE"
			]);
			*/

//			grid._gvo.setCheckBar({
//				checkableExpression: "values['TAX_SEQ'] is null"
//			});
//			grid._gvo.applyCheckables();

//			grid.freezeCol("CUST_NM");

			if ("${param.autoSearchFlag}" == "Y") {
//				EVF.V("VENDOR_CD", "${param.VENDOR_CD}");
//				EVF.V("VENDOR_NM", "${param.VENDOR_NM}");
//				EVF.V("CLOSE_YEAR", "${param.CLOSE_YEAR}");
//				EVF.V("CLOSE_MONTH", "${param.CLOSE_MONTH}");
//				doSearch();
			}
			doSearch();
		}

		function doSearch() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			store.setGrid([grid]);
			store.load(baseUrl + "py02040_doSearch", function () {
				EVF.V("TOT_AMT", "0 원");
				EVF.V("TOT_GR_AMT", "0 원");
				EVF.V("TOT_PO_AMT", "0 원");
				EVF.V("MARGIN_AMT", "0 원");
				EVF.V("MARGIN_RATE", "0 %");

				var salesRate = 0;
				var footerRate = {
					"styles": {
						"textAlignment": "far",
						"suffix": " ",
						"numberFormat": "###,###.##",
						"background":"#ffffff",
						"foreground":"#FF0000",
						"fontBold": true
					},
					"text": [salesRate + "%"]
				};
				grid.setRowFooter('ITEM_AMT_RATE', footerRate);

				if (grid.getRowCount() == 0) {
					return alert('${msg.M0002}');
				} else {
					var TOT_PO_AMT = 0;
					var TOT_GR_AMT = 0;
					var rows = grid.getAllRowValue();
					for (var i = 0; i < rows.length; i++) {
						TOT_PO_AMT += Number(rows[i].PO_GR_ITEM_AMT);
						TOT_GR_AMT += Number(rows[i].GR_AMT);
					}

					EVF.V("TOT_AMT", comma(String(TOT_GR_AMT)) + " 원");
					EVF.V("TOT_GR_AMT", "0 원");
					EVF.V("TOT_PO_AMT", "0 원");
					EVF.V("MARGIN_AMT", "0 원");
					EVF.V("MARGIN_RATE", "0 %");

					var cpoItemAmt = Number(grid._gvo.getSummary('GR_ITEM_AMT', 'SUM'));
					var poItemAmt = Number(grid._gvo.getSummary('PO_GR_ITEM_AMT', 'SUM'));

					if(!EVF.isEmpty(cpoItemAmt) && cpoItemAmt > 0) {
						if(!EVF.isEmpty(poItemAmt) && poItemAmt > 0) {
							salesRate = everMath.round_float(((cpoItemAmt - poItemAmt) / cpoItemAmt) * 100, 1);
							footerRate = {
								"styles": {
									"textAlignment": "far",
									"suffix": " ",
									"numberFormat": "###,###.##",
									"background":"#ffffff",
									"foreground":"#FF0000",
									"fontBold": true
								},
								"text": [salesRate + "%"]
							};
							grid.setRowFooter('ITEM_AMT_RATE', footerRate);
						}
					}
				}
			});
		}

		function doDelete() {
			var store = new EVF.Store();

			if (!store.validate()) {
				return;
			}
			if (!grid.isExistsSelRow()) {
				return alert("${msg.M0004}");
			}
			if (!grid.validate().flag) {
				return alert(grid.validate().msg);
			}

			var rows = grid.getSelRowValue();
			for (var i = 0; i < rows.length; i++) {
				<%--if(rows[i].CUST_CONFIRM_FLAG === "1") {--%>
				<%--    alert("${PY02_040_005}");--%>
				<%--    return;--%>
				<%--}--%>

				if (rows[i].TAX_NUM !== "") {
					alert("${PY02_040_011}");
					return;
				}
			}

			if (!confirm("${PY02_040_004}")) {
				return;
			}

			store.setGrid([grid]);
			store.getGridData(grid, "sel");
			store.load(baseUrl + "py02040_doDelete", function () {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doTaxCreate() {
			var store = new EVF.Store();

			if (!store.validate()) {
				return;
			}
			if (!grid.isExistsSelRow()) {
				return alert("${msg.M0004}");
			}
			if (!grid.validate().flag) {
				return alert(grid.validate().msg);
			}
			var tempYYmm = EVF.V("CLOSE_YEAR")+EVF.V("CLOSE_MONTH");

			var rows = grid.getSelRowValue();
			var temp_pr_type = rows[0].PR_TYPE;
			for (var i = 0; i < rows.length; i++) {


                if(rows[i].PR_TYPE != temp_pr_type) {
                    alert("${PY02_040_022}");
                    return;
                }
				if(tempYYmm != rows[i].CLOSING_YEAR_MONTH) {
                    alert("${PY02_040_029}");
                    return;
				}

				if (rows[i].TAX_NUM !== "") {
					alert("${PY02_040_011}");
					return;
				}

			}





            var rowIds = grid.getSelRowId();
            var chkTax = 'Y';
            for(var i in rowIds){
                var TaxCd = grid.getCellValue(rowIds[i], "TAX_CD");
				if (TaxCd !='T1') {
					chkTax = 'N';
				}


            }
            if(chkTax == "N"){
                if(!confirm("${PY02_040_034}")) {
                	return;
                } else {
                    store.setGrid([grid]);
                    store.getGridData(grid, "sel");
                    store.load(baseUrl + "py02040_doTaxCreate", function() {
                        alert(this.getResponseMessage());
                        doSearch();
                    });
                }
            } else {
                if(!confirm("${PY02_040_009}")) {
                	return;
                } else {
                    store.setGrid([grid]);
                    store.getGridData(grid, "sel");
                    store.load(baseUrl + "py02040_doTaxCreate", function() {
                        alert(this.getResponseMessage());
                        doSearch();
                    });
                }
            }












return;
			if (!confirm("${PY02_040_009}")) {
				return;
			}



			store.setGrid([grid]);
			store.getGridData(grid, "sel");
			store.load(baseUrl + "py02040_doTaxCreate", function () {
				alert(this.getResponseMessage());
				doSearch();
			});
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

		function searchDEPT_CD() {
			var custCd = EVF.V("CUST_CD");
			var custNm = EVF.V("CUST_NM");

			if (custCd == "") {
				alert("${PY02_040_007}");
				return;
			}

			var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
			var param = {
				callBackFunction: "callbackDEPT_CD",
				AllSelectYN: true,
				detailView: false,
				multiYN: false,
				ModalPopup: true,
				custCd: custCd,
				custNm: custNm
			};
			everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
		}

		function callbackDEPT_CD(dataJsonArray) {
			var data = JSON.parse(dataJsonArray);
			EVF.C("DEPT_CD").setValue(data.ITEM_CLS3);
			EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
		}

		function searchCPO_USER_ID() {
			var custCd = EVF.V("CUST_CD");

			if (custCd == "") {
				alert("${PY02_040_007}");
				return;
			}

			var param = {
				callBackFunction: "callbackCPO_USER_ID",
				custCd: custCd
			};
			everPopup.openCommonPopup(param, "SP0083");
		}

		function callbackCPO_USER_ID(data) {
			EVF.C("CPO_USER_ID").setValue(data.USER_ID);
			EVF.C("CPO_USER_NM").setValue(data.USER_NM);
		}

		function searchMAKER_CD() {
			var param = {
				callBackFunction: "callbackMAKER_CD"
			};
			everPopup.openCommonPopup(param, 'SP0068');
		}

		function callbackMAKER_CD(data) {
			EVF.V("MAKER_CD", data.MKBR_CD);
			EVF.V("MAKER_NM", data.MKBR_NM);
		}

		function searchCUST_CD() {
			var param = {
				callBackFunction: "callbackCUST_CD"
			};
			everPopup.openCommonPopup(param, "SP0067");
		}

		function callbackCUST_CD(data) {
			EVF.V("CUST_CD", data.CUST_CD);
			EVF.V("CUST_NM", data.CUST_NM);
			//chgCustCd();
		}

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${PY02_040_030}");
            var param = {
                callBackFunction : "callBackPlant",
                custCd: EVF.V("CUST_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
        }

		function searchACCOUNT_CD() {
			var CUST_CD = EVF.V("CUST_CD");

			if (CUST_CD == "") {
				alert("${PY01_020_007}");
				return;
			}

			var param = {
				custCd: CUST_CD,
				callBackFunction: "callbackACCOUNT_CD"
			};
			everPopup.openCommonPopup(param, "SP0085");
		}

		function callbackACCOUNT_CD(data) {
			EVF.V("ACCOUNT_CD", data.ACCOUNT_CD);
			EVF.V("ACCOUNT_NM", data.ACCOUNT_NM);
		}

		function onIconClickVENDOR_CD() {
			var param = {
				callBackFunction: "callbackVENDOR_CD"
			};
			everPopup.openCommonPopup(param, 'SP0063');
		}

		function callbackVENDOR_CD(data) {
			EVF.V("VENDOR_CD", data.VENDOR_CD);
			EVF.V("VENDOR_NM", data.VENDOR_NM);
		}

        function chgCustCd() {
            var store = new EVF.Store;
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
                    EVF.C('DIVISION_CD').setOptions([]);
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);

            	}
            });
        }

        function chgPlantCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "100");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DIVISION_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('DEPT_CD').setOptions([]);
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }
        function chgDivisionCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "200");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('DEPT_CD').setOptions(this.getParameter("divisionDeptPartCd"));
					EVF.C('PART_CD').setOptions([]);
            	}
            });
        }
        function chgDeptCd() {
            var store = new EVF.Store;
            store.setParameter("DEPT_TYPE", "300");
            var baseUrl2 = "/evermp/SY01/SY0101/";
            store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
            	if (this.getParameter("divisionDeptPartCd") != null) {
                    EVF.C('PART_CD').setOptions(this.getParameter("divisionDeptPartCd"));
            	}
            });
        }


        function doSave() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var selRowValue = grid.getSelRowValue();

            for(var i in selRowValue) {
                var row = selRowValue[i];
                if(row.TAX_NUM !== "") {
                    return alert("${PY02_040_011}");
                }
            }

            if(!confirm("${PY02_040_021}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "py2040_doSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doSendMail() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm('${PY02_040_031}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'doAlarmInvoiceDelay', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

	</script>

	<e:window id="PY02_040" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">


            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCUST_CD" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                </e:field>
                <e:label for="DDP_CD" title="${form_DDP_CD_N}" />
                <e:field>
                    <e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
                </e:field>
            </e:row>
            <e:row>

				<e:label for="GR_CLOSE_DATE" title="${form_GR_CLOSE_DATE_N}"/>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE }" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE }" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>


				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				<e:text>&nbsp;</e:text>
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>


				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVENDOR_CD" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
				<e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
				<e:field>
					<e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
				<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
                <e:text> / </e:text>
                <e:select id="TAX_NUM" name="TAX_NUM" value="" options="${taxNumOptions}" width="${form_TAX_NUM_W}" disabled="${form_TAX_NUM_D}" readOnly="${form_TAX_NUM_RO}" required="${form_TAX_NUM_R}" placeHolder="" />
                </e:field>
				<e:label for="RMK" title="${form_RMK_N}" />
				<e:field>
				<e:inputText id="RMK" name="RMK" value="" width="${form_RMK_W}" maxLength="${form_RMK_M}" disabled="${form_RMK_D}" readOnly="${form_RMK_RO}" required="${form_RMK_R}" />
				</e:field>
            </e:row>

            <e:inputHidden id="SELL_TAX_TYPE" name="SELL_TAX_TYPE" value="300"/>
        </e:searchPanel>

        <e:panel width="50%" visible="true">
            <e:text style="color:blue;font-weight:bold;">[ 총금액 : </e:text>
            <e:text id="TOT_AMT" name="TOT_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
            <e:text style="color:blue;font-weight:bold;">][ 매출금액: </e:text>
            <e:text id="TOT_GR_AMT" name="TOT_GR_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
            <e:text style="color:blue;font-weight:bold;">][ 매입금액: </e:text>
            <e:text id="TOT_PO_AMT" name="TOT_PO_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
            <e:text style="color:blue;font-weight:bold;">][ 매출이익금: </e:text>
            <e:text id="MARGIN_AMT" name="MARGIN_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
            <e:text style="color:blue;font-weight:bold;">][ 매출이익율: </e:text>
            <e:text id="MARGIN_RATE" name="MARGIN_RATE" style="color:blue;font-weight:bold;">0 %</e:text>
            <e:text style="color:blue;font-weight:bold;">]</e:text>
        </e:panel>
        <e:panel width="50%" visible="true">
        </e:panel>

        <e:panel width="50%">
	        <e:buttonBar width="100%" align="right">
                <table align="right">
                    <tr>
                        <td>


                    <e:text>매입계산서 년월 :  </e:text>
                    <e:select id="CLOSE_YEAR" name="CLOSE_YEAR" value="${CLOSE_YEAR}" options="${closeYearOptions}" width="100" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false" />
                    <e:text>년 </e:text>
                    <e:select id="CLOSE_MONTH" name="CLOSE_MONTH" value="${CLOSE_MONTH}" width="50" disabled="${form_CLOSE_MONTH_D}" readOnly="${form_CLOSE_MONTH_RO}" required="${form_CLOSE_MONTH_R}" placeHolder="" usePlaceHolder="false">
                        <e:option text="01" value="01"/>
                        <e:option text="02" value="02"/>
                        <e:option text="03" value="03"/>
                        <e:option text="04" value="04"/>
                        <e:option text="05" value="05"/>
                        <e:option text="06" value="06"/>
                        <e:option text="07" value="07"/>
                        <e:option text="08" value="08"/>
                        <e:option text="09" value="09"/>
                        <e:option text="10" value="10"/>
                        <e:option text="11" value="11"/>
                        <e:option text="12" value="12"/>
                    </e:select>
                    <e:text>월 </e:text>
						</td>
                        <td width="50px">
                        </td>
						<td>



                            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
                            <e:button id="doTaxCreate" name="doTaxCreate" label="${doTaxCreate_N}" onClick="doTaxCreate" disabled="${doTaxCreate_D}" visible="${doTaxCreate_V}"/>
                            <e:button id="doSendMail" name="doSendMail" label="${doSendMail_N}" onClick="doSendMail" disabled="${doSendMail_D}" visible="${doSendMail_V}"/>
                            <!-- e:select id="SELL_TAX_TYPE" name="SELL_TAX_TYPE" value="" style="float:right;right:5px;" options="${sellTaxTypeOptions}" width="150" disabled="${form_SELL_TAX_TYPE_D}" readOnly="${form_SELL_TAX_TYPE_RO}" required="${form_SELL_TAX_TYPE_R}" usePlaceHolder="false" placeHolder="" /-->
                            <!-- e:button id="doConfirmCancle" name="doConfirmCancle" style="float:right;right:10px;" label="${doConfirmCancle_N}" onClick="doConfirmCancle" disabled="${doConfirmCancle_D}" visible="${doConfirmCancle_V}"/-->
                            <!-- e:button id="doConfirm" name="doConfirm" style="float:right;right:15px;" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/-->
                        </td>
                    </tr>
                </table>

            </e:buttonBar>

        </e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>