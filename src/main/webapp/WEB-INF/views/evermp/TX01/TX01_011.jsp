<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var grid_TTID;
        var baseUrl = "/evermp/TX01/";
		var ROW_ID;

        function init() {
            grid = EVF.C("grid");
            grid_TTID = EVF.C("grid_TTID");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                ROW_ID = rowId;

                grid_TTID._gvo.commit();

                if(colId === "multiSelect") {

                } else if (colId === "TAX_NUM") {
//                    doSearchTTID(value);
				} else if (colId === "SCOM_NM" || colId === "RCOM_NM") {
                    var SALES_TYPE = grid.getCellValue(rowId, "SALES_TYPE");
					var CUST_CD = "";
					var VENDOR_CD = "";

                    if("S" === SALES_TYPE) {
						if(colId === "SCOM_NM") {
                            VENDOR_CD = grid.getCellValue(rowId, "SCOM_CODE");
						} else if(colId === "RCOM_NM") {
                            CUST_CD = grid.getCellValue(rowId, "RCOM_CODE")
						}
					} else if("P" === SALES_TYPE) {
                        if(colId === "SCOM_NM") {
                            VENDOR_CD = grid.getCellValue(rowId, "SCOM_CODE");
                        } else if(colId === "RCOM_NM") {
                            VENDOR_CD = grid.getCellValue(rowId, "RCOM_CODE")
                        }
					}

					if(CUST_CD !== "") {
                        var param = {
                            CUST_CD: CUST_CD,
                            detailView: true,
                            popupFlag: true
                        };
//                        everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
					}

					if(VENDOR_CD !== "" && VENDOR_CD !== "1000") {
                        var param = {
                            'VENDOR_CD': VENDOR_CD,
                            'detailView': true,
                            'popupFlag': true
                        };
//                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
					}
                } else if(colId === "SALES_TYPE_NM") {
                    var selRow = grid.getSelRowId();
                    var TAX_NUM = grid.getCellValue(rowId, "TAX_NUM");

                    var rowsAll = grid.getAllRowValue();
                    var rowIdsAll = grid.getAllRowId();
                    for( var j = 0; j < rowsAll.length; j++ ) {
                        var rowIdAll = rowIdsAll[j];

                        if(TAX_NUM === rowsAll[j].AP_TAX_NUM) {
                            grid.setCellValue(rowIdAll, "SEL_CHK_YN", "1", false);
                        } else {
							grid.setCellValue(rowIdAll, "SEL_CHK_YN", "0", false);
                        }
                    }

                    for( var i = 0; i < selRow.length; i++ ) {
                        grid.checkRow(selRow[i], true, false, false);
                    }
				}
            });

            grid_TTID.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId === "ITEM_CD") {
                    if (value !== "") {
                        var param = {
                            ITEM_CD: grid_TTID.getCellValue(rowId, "ITEM_CD"),
                            popupFlag: true,
                            detailView: true
                        };
                        everPopup.im03_014open(param);
                    }
                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
                if(value !== oldValue) {
                    if(colId === "E_BILL_ASP_TYPE") {
                        if("1" === value) {
                            grid._gvo.setCellStyles(rowId, ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style02");
                        } else if("0" === value) {
                            grid._gvo.setCellStyles(rowId, ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style01");
                        }
                    } else if(colId === "TAX_AMT") {
                        var TOT_AMT = Number(grid.getCellValue(rowId, "SUP_AMT")) + Number(grid.getCellValue(rowId, "TAX_AMT"));
                        grid.setCellValue(rowId, "TOT_AMT", TOT_AMT);
                    } else if(colId === "SUSER_TEL_NO" || colId === "RUSER_TEL_NO") {
                        if(!everString.isTel(value)) {
                            alert("${msg.M0128}");
                            grid.setCellValue(rowId, colId, oldValue);
						}
					} else if(colId === "SUSER_EMAIL" || colId === "RUSER_EMAIL") {
//                        var regExp = /[0-9a-zA-Z][_0-9a-zA-Z-]*@[_0-9a-zA-Z-]+(\.[_0-9a-zA-Z-]+){1,2}$/;
//                        if (!value.match(regExp)){
						if(!everString.isValidEmail(value)) {
                            alert("${msg.EMAIL_INVALID}");

                            grid.setCellValue(rowId, colId, oldValue);
                        }
                    }
				}
            });

            grid_TTID.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
                if(value !== oldValue) {
                    if (colId === "TAX_AMT") {
                        var TOT_AMT = value * grid_TTID.getCellValue(rowId, "SUP_AMT");
                        grid_TTID.setCellValue(rowId, "TOT_AMT", TOT_AMT);

                        doUpdateTTID();
                    }
                }
            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {
//                console.log("========================" + checked);
			};

            grid._gvo.onCurrentRowChanged = function(gridView, rowId, newRowId) {
                if(rowId !== newRowId) {
                    var TAX_NUM = grid.getCellValue(newRowId, "TAX_NUM");
                    doSearchTTID(TAX_NUM);
                }
            };

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid_TTID.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            var val = {visible: true, count: 1, height: 40};
            var footerTxt = {
                styles: {
                    textAlignment: "center",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: ["합 계"],
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

            grid_TTID.setProperty("footerVisible", val);
            grid_TTID.setRowFooter("QTY", footerTxt);
            grid_TTID.setRowFooter("SUP_AMT", footerSum);
            grid_TTID.setRowFooter("TAX_AMT", footerSum);
            grid_TTID.setRowFooter("TOT_AMT", footerSum);

            grid._gvo.setDisplayOptions({"focusVisible": true});

            grid_TTID.showCheckBar(false);

            grid_TTID.setColMerge(["ITEM_CD", "CUST_ITEM_CD", "ITEM_DESC", "ITEM_SPEC", "UNIT_AMT","CLOSING_NO"]);

            grid.setColGroup([{
					groupName: "${TX01_011_008}",
					columns: [ "SCOM_NM", "SIRS_NUM", "SCEO_NM", "SBUSINESS_TYPE", "SINDUSTRY_TYPE", "SADDR1", "SADDR2",
								"SUSER_ID_ASP", "SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO", "SUSER_EMAIL", "SSUB_IRS_NUM"]
				}, {
					groupName: "${TX01_011_009}",
					columns: [ "RCOM_NM", "RIRS_NUM", "RCEO_NM", "RBUSINESS_TYPE", "RINDUSTRY_TYPE", "RADDR1", "RADDR2",
								"RUSER_ID_ASP", "RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "RSUB_IRS_NUM"]
            }], 45);

            grid._gvo.setFixedOptions({colCount: 2});

            grid._gvo.addCellStyle("style01", {
                editable: false
            }, true);

            grid._gvo.addCellStyle("style02", {
                foreground: "#000000",
                background: "#ffffcc",
                editable: true
            }, true);

            grid._gvo.addCellStyle("style03", {
                foreground: "#000000",
                background: "#f8d1e4",
                editable: false
            }, false);

            grid._gvo.setColumnProperty('SALES_TYPE_NM', 'renderer', {type:"shape", showTooltip: true});
            grid._gvo.setColumnProperty('SALES_TYPE_NM', 'dynamicStyles', [{
                	criteria: "(value['SEL_CHK_YN'] = '1')",
                	styles: {figureBackground: "#ff00aa00", figureName: 'ellipse', iconLocation: 'left', figureSize: "60%", paddingRight: 6}
            	}, {
                	criteria: "(value['SEL_CHK_YN'] = '0')",
                    styles: {figureBackground: "#ffeeeeee", figureName: 'ellipse', iconLocation: 'left', figureSize: "60%", paddingRight: 6}
			}]);
		}

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
            grid.checkRow(data.rowId, true);
		}

        function callbackGridATTACH_FILE_NO(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, 'ATTACH_FILE_NO', uuid);
			grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', fileCount);
        }

        function callbackGridGR_AGENT_ATTFILE_NUM(rowId, uuid, fileCount) {
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM", uuid);
            grid.setCellValue(rowId, "GR_AGENT_ATTFILE_NUM_CNT", fileCount);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "tx01011_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    grid_TTID.delAllRow();

                    alert('${msg.M0002}');
                } else {
                    var S_SUP_AMT = 0;
                    var P_SUP_AMT = 0;
                    var S_TAX_AMT = 0;
                    var P_TAX_AMT = 0;
                    var TOT_AMT = 0;

                    var rows = grid.getAllRowValue();
                    var rowIds = grid.getAllRowId();
                    for( var i = 0; i < rows.length; i++ ) {
                        var rowId = rowIds[i];

                        if("S" === rows[i].SALES_TYPE) {
                            S_SUP_AMT += Number(rows[i].SUP_AMT);
                            S_TAX_AMT += Number(rows[i].TAX_AMT);
                        } else if("P" === rows[i].SALES_TYPE) {
                            P_SUP_AMT += Number(rows[i].SUP_AMT);
                            P_TAX_AMT += Number(rows[i].TAX_AMT);
                        }

                        if("Y" === rows[i].TRANS_YN) {

                        } else if("C" === rows[i].TRANS_YN) {
                            grid._gvo.setCellStyles(rowId, ["TRANS_NM"], "style03");
                        }

                        TOT_AMT = Number(rows[i].SUP_AMT) + Number(rows[i].TAX_AMT);
                        grid.setCellValue(rowId, "TOT_AMT", TOT_AMT, false);

//                        grid.checkRow(rowId, false);
                    }

                    EVF.V("S_SUP_AMT", comma(String(S_SUP_AMT)) + " ${TX01_011_012}");
                    EVF.V("S_TAX_AMT", comma(String(S_TAX_AMT)) + " ${TX01_011_012}");
                    EVF.V("P_SUP_AMT", comma(String(P_SUP_AMT)) + " ${TX01_011_012}");
                    EVF.V("P_TAX_AMT", comma(String(P_TAX_AMT)) + " ${TX01_011_012}");

//                    grid.checkAll(false);

                    grid._gvo.setCheckBar({
                        checkableExpression: "values['TAX_BILLSEQ_YN'] = 'N'"
                    });
            		grid._gvo.applyCheckables();

//                    doSearchTTID("");
                }
            });
        }

        function doSearchTTID(TAX_NUM) {
            var store = new EVF.Store();

            if("" === TAX_NUM) {
                grid._gvo.resetCurrent();
                EVF.V("TAX_NUM", grid.getCellValue(0, "TAX_NUM"));
			} else {
                EVF.V("TAX_NUM", TAX_NUM);
			}

            store.setGrid([grid_TTID]);
            store.load(baseUrl + "tx01011_doSearchTTID", function () {
                if(grid_TTID.getRowCount() == 0) {

                } else {
                    var TOT_AMT = 0;
                    var rows = grid_TTID.getAllRowValue();
                    var rowIds = grid_TTID.getAllRowId();
                    for( var i = 0; i < rows.length; i++ ) {
                        var rowId = rowIds[i];
                        TOT_AMT = Number(rows[i].SUP_AMT) + Number(rows[i].TAX_AMT);
                        grid_TTID.setCellValue(rowId, "TOT_AMT", TOT_AMT);
                    }
                }
            }, false);
		}

        function doUpdateTTID() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid_TTID.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid_TTID.validate().flag) { return alert(grid_TTID.validate().msg); }

            store.setGrid([grid_TTID]);
            store.getGridData(grid_TTID, "sel");
            store.load(baseUrl + "tx01010_doUpdateTTID", function() {
            });
        }

        function doSave() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];

                if(rows[i].E_BILL_ASP_TYPE === "1") {
                    if(rows[i].TRANS_YN === "Y" || rows[i].TRANS_YN === "N") {
                        alert("${TX01_011_018}");
                        return;
                    }
                } else if(rows[i].E_BILL_ASP_TYPE === "0") {
                    if(rows[i].BILL_STAT_TYPE !== "" || rows[i].TRANS_YN === "Y" || rows[i].TRANS_YN === "N") {
                        alert("${TX01_011_018}");
                        return;
                    }
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX01_011_013}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01011_doSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
		}

		// 전표이관
		function doSlipTrans() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];

                if(rows[i].SALES_TYPE === "P") {
                    alert("${TX01_011_029}");
                    return;
                }

                if(rows[i].E_BILL_ASP_TYPE === "0") {
                    if(rows[i].BILL_TRANS_YN !== "Y") {
                        alert("${TX01_011_021}");
                        var index = {column: "BILL_STAT_NM", dataRow: rowId};
                        grid._gvo.setCurrent(index);
                        return;
                    } else {

                    }
                }

                if(rows[i].TRANS_YN === "Y" || rows[i].TRANS_YN === "N") {
                    alert("${TX01_011_004}");
                    var index = {column: "TRANS_NM", dataRow: rowId};
                    grid._gvo.setCurrent(index);
                    return;
                }

                if(rows[i].E_BILL_ASP_TYPE === "1") {
                    if(rows[i].TAX_ASP_NM === "") {
                        alert("${TX01_011_015}");

                        var index = {column: "TAX_ASP_NM", dataRow: rowId};
                        grid._gvo.setCurrent(index);

                        return;
                    } else if(rows[i].TAX_ASP_BILLSEQ === "") {
                        alert("${TX01_011_015}");

                        var index = {column: "TAX_ASP_BILLSEQ", dataRow: rowId};
                        grid._gvo.setCurrent(index);

                        return;
                    }
                }
            }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];


                var rowsAll = grid.getAllRowValue();
                var rowIdsAll = grid.getAllRowId();
                for( var j = 0; j < rowsAll.length; j++ ) {
                    var rowIdAll = rowIdsAll[j];

                    if(rowsAll[j].SALES_TYPE === "P" && rows[i].TAX_NUM === rowsAll[j].AP_TAX_NUM) {
                        if(rowsAll[j].E_BILL_ASP_TYPE === "0" && rowsAll[j].BILL_TRANS_YN !== "Y") {
                            alert("${TX01_011_030}");
                            var index = {column: "BILL_STAT_NM", dataRow: rowIdAll};
                            grid._gvo.setCurrent(index);
                            grid.setCellBgColor(rowIdAll, "BILL_STAT_NM", "#ffd8eb");
                            checkRow_false();
                            return;
                        } else if(rowsAll[j].E_BILL_ASP_TYPE === "1" && (rowsAll[j].TRANS_YN === "Y" || rowsAll[j].TRANS_YN === "N")) {
                            alert("${TX01_011_030}");
                            var index = {column: "TRANS_NM", dataRow: rowIdAll};
                            grid._gvo.setCurrent(index);
                            grid.setCellBgColor(rowIdAll, "TRANS_NM", "#ffd8eb");
                            checkRow_false();
                            return;
                        } else {
                            grid.checkRow(rowIdAll, true);
                        }

                        if(rowsAll[j].E_BILL_ASP_TYPE === "1") {
                            if(rowsAll[j].TAX_ASP_NM === "") {
                                alert("${TX01_011_015}");

                                var index = {column: "TAX_ASP_NM", dataRow: rowIdAll};
                                grid._gvo.setCurrent(index);

                                return;
                            } else if(rowsAll[j].TAX_ASP_BILLSEQ === "") {
                                alert("${TX01_011_015}");

                                var index = {column: "TAX_ASP_BILLSEQ", dataRow: rowIdAll};
                                grid._gvo.setCurrent(index);

                                return;
                            }
                        }
                    }
                }
            }

            if(!grid.validate().flag) {
                checkRow_false();
                alert(grid.validate().msg);
                return;
            }

            if(!confirm("${TX01_011_005}")) {
                checkRow_false();
                return;
            }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01011_doSlipTrans", function() {
                alert(this.getResponseMessage());

                if(this.responseCode === "ERR") {
                    var rowsAll = grid.getAllRowValue();
                    var rowIdsAll = grid.getAllRowId();

                    for( var j = 0; j < rowsAll.length; j++ ) {
                        var column = "TAX_NUM";
                        var rowIdAll = rowIdsAll[j];

                        if (rowsAll[j].SALES_TYPE === "P") {
                            grid.checkRow(rowIdAll, false);
                        }

                        if(this.data.ERR.TAX_NUM === rowsAll[j].TAX_NUM) {
                            grid._gvo.setCurrent({column: column, dataRow: rowIdAll});
                            grid.setCellBgColor(rowIdAll, column, "#ffd8eb");
                        }
                    }

                    doSearchTTID(this.data.ERR.TAX_NUM);
                } else if(this.responseCode === "031") {
                    var column = "";

                    var rowsAll = grid.getAllRowValue();
                    var rowIdsAll = grid.getAllRowId();

                    for( var j = 0; j < rowsAll.length; j++ ) {
                        var rowIdAll = rowIdsAll[j];

                        if(rowsAll[j].SALES_TYPE === "P") {
                            grid.checkRow(rowIdAll, false);
                        }

                        if(this.data.ERR.CSTCO_TAX_NUM === rowsAll[j].TAX_NUM) {
                            if(this.data.ERR.CSTCO_SALES_TYPE === "S") {
                                column = "RCOM_NM";
							} else {
                                column = "SCOM_NM";
							}
                            grid._gvo.setCurrent({column: column, dataRow: rowIdAll});
                            grid.setCellBgColor(rowIdAll, column, "#ffd8eb");
						}
                    }
				} else if(this.responseCode === "004") {
                    var column = "";

                    var rowsAll = grid.getAllRowValue();
                    var rowIdsAll = grid.getAllRowId();

                    for( var j = 0; j < rowsAll.length; j++ ) {
                        var rowIdAll = rowIdsAll[j];

                        if(rowsAll[j].SALES_TYPE === "P") {
                            grid.checkRow(rowIdAll, false);
                        }

                        if(this.data.ERR.CHK_TAX_NUM === rowsAll[j].TAX_NUM) {
							column = "TRANS_NM";
                            grid._gvo.setCurrent({column: column, dataRow: rowIdAll});
                            grid.setCellBgColor(rowIdAll, column, "#ffd8eb");
                        }
                    }

				} else if(this.responseCode === "006") {
                    doSearch();
                }
            });
		}

		// 전표이관 취소
		function doSlipTransCancel() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];

                if(rows[i].SALES_TYPE === "P") {
                    alert("${TX01_011_029}");
                    return;
                }

                if(rows[i].TRANS_YN === "Y") {
                    alert("${TX01_011_024}");
                    return;
                }

                if(rows[i].TRANS_YN === "" || rows[i].TRANS_YN === "C") {
                    alert("${TX01_011_028}");
                    return;
                }
            }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];

                var rowsAll = grid.getAllRowValue();
                var rowIdsAll = grid.getAllRowId();
                for( var j = 0; j < rowsAll.length; j++ ) {
                    var rowIdAll = rowIdsAll[j];

                    if(rowsAll[j].SALES_TYPE === "P" && rows[i].TAX_NUM === rowsAll[j].AP_TAX_NUM) {
                        grid.checkRow(rowIdAll, true);
                    }
                }
            }

            if(!grid.validate().flag) {
                checkRow_false();
                alert(grid.validate().msg);
                return;
            }

            if(!confirm("${TX01_011_025}")) {
                checkRow_false();
                return;
            }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx01011_doSlipTransCancel", function() {
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

        function checkRow_false() {
            var rowsAll = grid.getAllRowValue();
            var rowIdsAll = grid.getAllRowId();

            for( var j = 0; j < rowsAll.length; j++ ) {
                var rowIdAll = rowIdsAll[j];

                if(rowsAll[j].SALES_TYPE === "P") {
                    grid.checkRow(rowIdAll, false);
                }
            }
		}

        function searchDEPT_CD() {
            var custCd = EVF.V("CUST_CD");
			var custNm = EVF.V("CUST_NM");

            if(custCd == "") {
                alert("${TX01_011_032}");
                return;
            }

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "callbackDEPT_CD",
                AllSelectYN: true,
                detailView: false,
                multiYN: false,
                ModalPopup: true,
                custCd : custCd,
                custNm : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function callbackDEPT_CD(dataJsonArray) {
        	data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS2);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${TX01_011_032}");
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

        function searchVENDOR_CD() {
            var param = {
                callBackFunction : "callbackVENDOR_CD"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function callbackVENDOR_CD(data) {
            EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
        }

        function searchMAKER_CD(){
            var param = {
                callBackFunction : "callbackMAKER_CD"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function callbackMAKER_CD(data) {
            EVF.V("MAKER_CD",data.MKBR_CD);
            EVF.V("MAKER_NM",data.MKBR_NM);
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
        }

        function searchACCOUNT_CD() {
            var CUST_CD = EVF.V("CUST_CD");

            if(CUST_CD == "") {
                alert("${TX01_011_032}");
                return;
            }

            var param = {
            	custCd : CUST_CD,
                callBackFunction : "callbackACCOUNT_CD"
            };
            everPopup.openCommonPopup(param, "SP0085");
        }

        function callbackACCOUNT_CD(data){
            EVF.V("ACCOUNT_CD", data.ACCOUNT_CD);
            EVF.V("ACCOUNT_NM", data.ACCOUNT_NM);
        }
    </script>

    <e:window id="TX01_011" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="TAX_NUM" name="TAX_NUM" value="" />

            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCUST_CD'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
				<e:label for="DEPT_CD" title="${form_DEPT_CD_N}"/>
				<e:field>
					<e:search id="DEPT_CD" name="DEPT_CD" value="" width="40%" maxLength="${form_DEPT_CD_M}" onIconClick="${form_DEPT_CD_RO ? 'everCommon.blank' : 'searchDEPT_CD'}" disabled="${form_DEPT_CD_D}" readOnly="${form_DEPT_CD_RO}" required="${form_DEPT_CD_R}" />
					<e:inputText id="DEPT_NM" name="DEPT_NM" value="" width="60%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
				</e:field>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="CLOSE_YEAR" title="${form_CLOSE_YEAR_N}"/>
				<e:field>
					<e:select id="CLOSE_YEAR" name="CLOSE_YEAR" value="${CLOSE_YEAR}" options="${closeYearOptions}" width="80" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false" />
					<e:text>년 </e:text>
					<e:select id="CLOSE_MONTH" name="CLOSE_MONTH" value="${CLOSE_MONTH}" width="50" disabled="${form_CLOSE_MONTH_D}" readOnly="${form_CLOSE_MONTH_RO}" required="${form_CLOSE_MONTH_R}" placeHolder="" usePlaceHolder="false">
						<e:option text="01" value="01"></e:option>
						<e:option text="02" value="02"></e:option>
						<e:option text="03" value="03"></e:option>
						<e:option text="04" value="04"></e:option>
						<e:option text="05" value="05"></e:option>
						<e:option text="06" value="06"></e:option>
						<e:option text="07" value="07"></e:option>
						<e:option text="08" value="08"></e:option>
						<e:option text="09" value="09"></e:option>
						<e:option text="10" value="10"></e:option>
						<e:option text="11" value="11"></e:option>
						<e:option text="12" value="12"></e:option>
					</e:select>
					<e:text>월 </e:text>
				</e:field>
				<e:label for="DOC_NUM">
                    <e:select id="DOC_NUM_COMBO" name="DOC_NUM_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="주문번호" value="CPO_NO"></e:option>
                        <e:option text="관리번호" value="REF_MNG_NO"></e:option>
                    </e:select>
                </e:label>
				<e:field>
					<e:inputText id="DOC_NUM" name="DOC_NUM" value="" width="${form_DOC_NUM_W}" maxLength="${form_DOC_NUM_M}" disabled="${form_DOC_NUM_D}" readOnly="${form_DOC_NUM_RO}" required="${form_DOC_NUM_R}" />
				</e:field>
				<e:label for="TRANS_YN" title="${form_TRANS_YN_N}"/>
				<e:field>
					<e:select id="TRANS_YN" name="TRANS_YN" value="" options="${transYnOptions}" width="${form_TRANS_YN_W}" disabled="${form_TRANS_YN_D}" readOnly="${form_TRANS_YN_RO}" required="${form_TRANS_YN_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="ACCOUNT_CD" title="${form_ACCOUNT_CD_N}"/>
				<e:field>
					<e:search id="ACCOUNT_CD" name="ACCOUNT_CD" value="" width="40%" maxLength="${form_ACCOUNT_CD_M}" onIconClick="${form_ACCOUNT_CD_RO ? 'everCommon.blank' : 'searchACCOUNT_CD'}" disabled="${form_ACCOUNT_CD_D}" readOnly="${form_ACCOUNT_CD_RO}" required="${form_ACCOUNT_CD_R}" />
					<e:inputText id="ACCOUNT_NM" name="ACCOUNT_NM" value="" width="60%" maxLength="${form_ACCOUNT_NM_M}" disabled="${form_ACCOUNT_NM_D}" readOnly="${form_ACCOUNT_NM_RO}" required="${form_ACCOUNT_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>

		<e:panel width="50%">
			<e:text style="color:blue;font-weight:bold;">[ ${TX01_011_010} - ${TX01_011_017} : </e:text>
			<e:text id="S_SUP_AMT" name="SUP_AMT" style="color:blue;font-weight:bold;">0 ${TX01_011_012}</e:text>
			<e:text style="color:blue;font-weight:bold;">, ${TX01_011_022} : </e:text>
			<e:text id="P_SUP_AMT" name="SUP_AMT" style="color:blue;font-weight:bold;">0 ${TX01_011_012}</e:text>
			<e:text style="color:blue;font-weight:bold;">][ ${TX01_011_011} - ${TX01_011_017} : </e:text>
			<e:text id="S_TAX_AMT" name="TAX_AMT" style="color:blue;font-weight:bold;">0 ${TX01_011_012}</e:text>
			<e:text style="color:blue;font-weight:bold;">, ${TX01_011_022} : </e:text>
			<e:text id="P_TAX_AMT" name="SUP_AMT" style="color:blue;font-weight:bold;">0 ${TX01_011_012}</e:text>
			<e:text style="color:blue;font-weight:bold;">]</e:text>
		</e:panel>
		<e:panel width="50%">
		<e:buttonBar align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doSlipTrans" name="doSlipTrans" label="${doSlipTrans_N}" onClick="doSlipTrans" disabled="${doSlipTrans_D}" visible="${doSlipTrans_V}"/>
			<e:button id="doSlipTransCancel" name="doSlipTransCancel" label="${doSlipTransCancel_N}" onClick="doSlipTransCancel" disabled="${doSlipTransCancel_D}" visible="${doSlipTransCancel_V}"/>
		</e:buttonBar>
		</e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="300px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		<e:panel height="fit" width="30%">
			<e:title title="${TX01_011_007 }" depth="1"/>
		</e:panel>
		<e:gridPanel gridType="${_gridType}" id="grid_TTID" name="grid_TTID" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid_TTID.gridColData}" />
    </e:window>
</e:ui>