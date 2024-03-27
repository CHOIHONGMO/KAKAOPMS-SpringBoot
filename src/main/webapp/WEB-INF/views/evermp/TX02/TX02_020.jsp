<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var grid_TTID;
        var baseUrl = "/evermp/TX02/TX0201/";
        var ROW_ID;

        function init() {
            grid = EVF.C("grid");
            grid_TTID = EVF.C("grid_TTID");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;
                var SALES_TYPE = grid.getCellValue(rowId, "SALES_TYPE");

                ROW_ID = rowId;

                grid_TTID._gvo.commit();

                if(colId === "multiSelect") {
                    var GR_ITEM_AMT = 0;
                    var PO_ITEM_AMT = 0;
                    var MARGIN_RATE = 0;

                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        GR_ITEM_AMT += Number(rows[i].GR_ITEM_AMT);
                        PO_ITEM_AMT += Number(rows[i].SUP_AMT);
                    }

                    if(PO_ITEM_AMT > 0) {
                        MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
                    }

                    EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT)) + " 원");
                    EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT)) + " 원");
                    EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT - PO_ITEM_AMT)) + " 원");
                    EVF.V("MARGIN_RATE", String(MARGIN_RATE) + " %");
                } else if(colId === "TAX_NUM") {
                    doSearchTTID(value);
                } else if(colId === "SCOM_NM" || colId === "RCOM_NM") {
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
                        param = {
                            CUST_CD: CUST_CD,
                            detailView: true,
                            popupFlag: true
                        };
                       // everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                    }

                    if(VENDOR_CD !== "" && VENDOR_CD !== "1000") {
                        param = {
                            'VENDOR_CD': VENDOR_CD,
                            'detailView': true,
                            'popupFlag': true
                        };
//                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                    }
                } else if(colId === "CPO_NO") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if(colId === "SUSER_ID_ASP" || colId === "RUSER_ID_ASP") {
                    if(("Y" === grid.getCellValue(rowId, "BILL_RE_SEND_YN") && "0" === grid.getCellValue(rowId, "E_BILL_ASP_TYPE")) ||
                        ("" === grid.getCellValue(rowId, "BILL_STAT_TYPE") && "0" === grid.getCellValue(rowId, "E_BILL_ASP_TYPE"))) {
                        var COM_CODE = colId==="SUSER_ID_ASP"?grid.getCellValue(rowId, "SCOM_CODE"):grid.getCellValue(rowId, "RCOM_CODE");
                        param = {
                            callBackFunction: "callbackGridSUSER_ID_ASP",
                            COM_CODE: COM_CODE,
                            SALES_TYPE: SALES_TYPE,
                            rowId: rowId
                        };
                        everPopup.openCommonPopup(param, "SP0115");
                    }
                } else if(colId === "BILL_STAT_NM") {
                    var BILL_STAT_TYPE = grid.getCellValue(rowId, "BILL_STAT_TYPE");

                    // if("E" === BILL_STAT_TYPE || "2" === BILL_STAT_TYPE || "4" === BILL_STAT_TYPE) {
                    //     doSearchBILLSTAT(grid.getCellValue(rowId, "TAX_BILLSEQ"), BILL_STAT_TYPE);
                    // }

                    if("R" == BILL_STAT_TYPE || "DR" == BILL_STAT_TYPE || "DY" == BILL_STAT_TYPE) {
                        alert(grid.getCellValue(rowId, "BILL_STAT_DESC"));
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

            grid_TTID.cellClickEvent(function(rowId, colId, value) {
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
                    if(colId === "TAX_SEND_TYPE") {
                        if(grid.getCellValue(rowId, "SALES_TYPE") === "P") {
                            // if(value === "100") {
                            //     grid.setCellValue(rowId, "E_BILL_ASP_TYPE", "1");
                            //     grid._gvo.setCellStyles([rowId], ["E_BILL_ASP_TYPE"], "style01");
                            //     grid._gvo.setCellStyles([rowId], ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style02");
                            //     // grid._gvo.setCellStyles([rowId], ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style01");
                            // } else {
                            //     grid._gvo.setCellStyles([rowId], ["E_BILL_ASP_TYPE"], "style02");
                            // }
                        }
                    } else if(colId === "E_BILL_ASP_TYPE") {
                        if("1" === value) {
//                            grid._gvo.setCellStyles([rowId], ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style02");
                            // grid._gvo.setCellStyles([rowId], ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style01");
                        } else if("0" === value) {
                        //    grid._gvo.setCellStyles([rowId], ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style01");
                            // grid._gvo.setCellStyles([rowId], ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style02");
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
                    } else if(colId === "ISSUE_DATE") {
                        if("${TODAY}" < value) {
                            alert("${TX02_020_041}");
                            grid.setCellValue(rowId, colId, oldValue);
                        }
                    } else if(colId === "VAT_CD") {
						if(value=='T1') {
							var supAmt = grid.getCellValue(rowId,'SUP_AMT');
						    grid.setCellValue(rowId,'TAX_AMT',supAmt / 10);
						    grid.setCellValue(rowId,'TOT_AMT',supAmt + (supAmt / 10) );
						} else {
							var supAmt = grid.getCellValue(rowId,'SUP_AMT');
						    grid.setCellValue(rowId,'TAX_AMT',0);
						    grid.setCellValue(rowId,'TOT_AMT',supAmt);
						}
                    }

                }
            });

            grid_TTID.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {
                if(value !== oldValue) {
                    if (colId === "TAX_AMT") {
                        <%--if(!confirm("${TX02_020_043}")) {--%>
                        <%--    grid_TTID.setCellValue(rowId, "TAX_AMT", oldValue);--%>
                        <%--    return;--%>
                        <%--}--%>

                        <%--var TOT_AMT = Number(value) + Number(grid_TTID.getCellValue(rowId, "SUP_AMT"));--%>
                        <%--grid_TTID.setCellValue(rowId, "TOT_AMT", TOT_AMT);--%>

                        <%--var SALES_TYPE = grid_TTID.getCellValue(rowId, "SALES_TYPE");--%>
                        <%--var TAX_NUM = grid_TTID.getCellValue(rowId, "TAX_NUM");--%>
                        <%--var AR_TAX_NUM = grid_TTID.getCellValue(rowId, "AR_TAX_NUM");--%>
                        <%--var GRID_ROW_ID = 0;--%>

                        <%--var rowsAll = grid.getAllRowValue();--%>
                        <%--var rowIdsAll = grid.getAllRowId();--%>
                        <%--for( var j = 0; j < rowsAll.length; j++ ) {--%>
                        <%--    var rowIdAll = rowIdsAll[j];--%>

                        <%--    if(SALES_TYPE === "S") {--%>
                        <%--        if(TAX_NUM === rowsAll[j].TAX_NUM) {--%>
                        <%--            GRID_ROW_ID = rowIdAll;--%>
                        <%--        }--%>
                        <%--    } else if(SALES_TYPE === "P") {--%>
                        <%--        if(AR_TAX_NUM === rowsAll[j].TAX_NUM) {--%>
                        <%--            GRID_ROW_ID = rowIdAll;--%>
                        <%--        }--%>
                        <%--    }--%>
                        <%--}--%>

                        <%--var TAX_AMT = Number(value) - Number(oldValue) + Number(grid.getCellValue(GRID_ROW_ID, "TAX_AMT"));--%>
                        <%--grid.setCellValue(GRID_ROW_ID, "TAX_AMT", TAX_AMT);--%>
                        <%--grid.setCellValue(GRID_ROW_ID, "TOT_AMT", TAX_AMT + Number(grid.getCellValue(GRID_ROW_ID, "SUP_AMT")));--%>

                        <%--doUpdateTTID();--%>
                    }
                }
            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {
                var GR_ITEM_AMT = 0;
                var PO_ITEM_AMT = 0;
                var MARGIN_RATE = 0;

                if(checked) {
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        GR_ITEM_AMT += Number(rows[i].GR_ITEM_AMT);
                        PO_ITEM_AMT += Number(rows[i].SUP_AMT);
                    }

                    if(GR_ITEM_AMT > 0) {
                        MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
                    }

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

            grid._gvo.onCurrentRowChanged = function(gridView, rowId, newRowId) {
				return;
                if(rowId !== newRowId && newRowId >= 0) {
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

            var TAX_AMT = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    numberFormat: "###,###",
                    fontBold: true
                },
                text: "0",
                expression: ["sum['SUP_AMT'] * 0.1"],
                groupExpression: "sum"
            };

            var TOT_AMT = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    numberFormat: "###,###",
                    fontBold: true
                },
                text: "0",
                expression: ["sum['SUP_AMT'] + (sum['SUP_AMT'] * 0.1))"],
                groupExpression: "sum"
            };

            grid_TTID.setProperty("footerVisible", val);
            grid_TTID.setRowFooter("QTY", footerTxt);
            grid_TTID.setRowFooter("SUP_AMT", footerSum);
            grid_TTID.setRowFooter("TAX_AMT", TAX_AMT);
            grid_TTID.setRowFooter("TOT_AMT", TOT_AMT);

            grid._gvo.setDisplayOptions({"focusVisible": true});

            grid_TTID.showCheckBar(false);

            //grid_TTID.setColMerge(["ITEM_CD", "CUST_ITEM_CD", "ITEM_DESC", "ITEM_SPEC", "UNIT_AMT","CLOSING_NO"]);

            grid.setColGroup([{
                groupName: "${TX02_020_008}",
                columns: [ "SCOM_NM", "SIRS_NUM", "SCEO_NM", "SBUSINESS_TYPE", "SINDUSTRY_TYPE", "SADDR1", "SADDR2",
                    "SUSER_ID_ASP", "SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO", "SUSER_EMAIL", "SSUB_IRS_NUM"]
            }, {
                groupName: "${TX02_020_009}",
                columns: [ "RCOM_NM", "RIRS_NUM", "RCEO_NM", "RBUSINESS_TYPE", "RINDUSTRY_TYPE", "RADDR1", "RADDR2",
                    "RUSER_ID_ASP", "RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "RSUB_IRS_NUM"]
            }], 45);

            grid._gvo.addCellStyle("style01", {
                editable: false,
                readOnly: true
            }, true);

            grid._gvo.addCellStyle("style02", {
                foreground: "#000000",
                background: "#ffffcc",
                editable: true
            }, true);

            grid._gvo.addCellStyle("style03", {
                foreground: "#0000FF",
                background: "#ffddf3",
                fontUnderline: true,
                editable: false
            }, true);

            grid._gvo.setColumnProperty('SALES_TYPE_NM', 'renderer', {type:"shape", showTooltip: true});
            grid._gvo.setColumnProperty('SALES_TYPE_NM', 'dynamicStyles', [{
                criteria: "(value['SEL_CHK_YN'] = '1')",
                styles: {figureBackground: "#ff00aa00", figureName: 'ellipse', iconLocation: 'left', figureSize: "60%", paddingRight: 6}
            }, {
                criteria: "(value['SEL_CHK_YN'] = '0')",
                styles: {figureBackground: "#ffeeeeee", figureName: 'ellipse', iconLocation: 'left', figureSize: "60%", paddingRight: 6}
            }]);

            grid.freezeCol("TAX_NUM");

            doSearch();
        }

        function callbackGridSUSER_ID_ASP(data) {
            if("P" === data.SALES_TYPE) {
                grid.setCellValue(data.rowId, "SUSER_ID_ASP", data.TX_ASP_ID);
                grid.setCellValue(data.rowId, "SUSER_NM", data.TX_USER_NM);
                grid.setCellValue(data.rowId, "SUSER_DEPT_NM", data.TX_USER_DEPT_NM);
                grid.setCellValue(data.rowId, "SUSER_TEL_NO", data.TX_USER_TEL_NO);
                grid.setCellValue(data.rowId, "SUSER_EMAIL", data.TX_USER_EMAIL);
                grid.setCellValue(data.rowId, "SUSER_ID", "");
            } else if("S" === data.SALES_TYPE) {
                grid.setCellValue(data.rowId, "RUSER_ID_ASP", data.TX_ASP_ID);
                grid.setCellValue(data.rowId, "RUSER_NM", data.TX_USER_NM);
                grid.setCellValue(data.rowId, "RUSER_DEPT_NM", data.TX_USER_DEPT_NM);
                grid.setCellValue(data.rowId, "RUSER_TEL_NO", data.TX_USER_TEL_NO);
                grid.setCellValue(data.rowId, "RUSER_EMAIL", data.TX_USER_EMAIL);
                grid.setCellValue(data.rowId, "RUSER_ID", "");
            }
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "tx02020_doSearch", function () {
                EVF.V("TOT_AMT", "0 원");
                EVF.V("TOT_GR_AMT", "0 원");
                EVF.V("TOT_PO_AMT", "0 원");
                EVF.V("MARGIN_AMT", "0 원");
                EVF.V("MARGIN_RATE", "0 %");

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

                        if("" === rows[i].TAX_BILLSEQ) {
                            if("" === rows[i].TRANS_YN || "C" === rows[i].TRANS_YN) {
                                if("P" === rows[i].SALES_TYPE) {
                                    grid._gvo.setCellStyles(rowId, ["SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO", "SUSER_EMAIL", "E_BILL_ASP_TYPE"], "style02");
                                    grid._gvo.setCellStyles(rowId, ["RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL"], "style02");
                                } else if("S" === rows[i].SALES_TYPE) {
                                    grid._gvo.setCellStyles(rowId, ["SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO", "SUSER_EMAIL"], "style02");
                                    grid._gvo.setCellStyles(rowId, ["RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "E_BILL_ASP_TYPE"], "style02");
                                }

                                if("1" === rows[i].E_BILL_ASP_TYPE) {
                                    // grid._gvo.setCellStyles(rowId, ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style01");
                                   // grid._gvo.setCellStyles(rowId, ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style02");
                                } else if("0" === rows[i].E_BILL_ASP_TYPE) {
                                    // grid._gvo.setCellStyles(rowId, ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style02");
                                   // grid._gvo.setCellStyles(rowId, ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style01");
                                }
                            } else {
                                grid._gvo.setCellStyles(rowId, ["SUSER_ID_ASP", "SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO", "SUSER_EMAIL", "E_BILL_ASP_TYPE"], "style01");
                                grid._gvo.setCellStyles(rowId, ["RUSER_ID_ASP", "RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "TAX_SEND_TYPE"], "style01");
                            //    grid._gvo.setCellStyles(rowId, ["TAX_ASP_NM", "TAX_ASP_BILLSEQ", "ISSUE_DATE", "TAX_AMT"], "style01");
                            }

                        } else {
                            if("Y" === rows[i].BILL_RE_SEND_YN) {
                                if("P" === rows[i].SALES_TYPE) {
                                    grid._gvo.setCellStyles(rowId, ["SUSER_EMAIL"], "style02");
                                    grid._gvo.setCellStyles(rowId, ["SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO"], "style01");
                                    grid._gvo.setCellStyles(rowId, ["RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "TAX_SEND_TYPE", "E_BILL_ASP_TYPE"], "style01");
                                } else if("S" === rows[i].SALES_TYPE) {
                                    grid._gvo.setCellStyles(rowId, ["SUSER_EMAIL"], "style02");
                                    grid._gvo.setCellStyles(rowId, ["SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO"], "style01");
                                    grid._gvo.setCellStyles(rowId, ["RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "TAX_SEND_TYPE", "E_BILL_ASP_TYPE"], "style01");
                                }

                                if("1" === rows[i].E_BILL_ASP_TYPE) {
                                    // grid._gvo.setCellStyles(rowId, ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style01");
                                } else if("0" === rows[i].E_BILL_ASP_TYPE) {
                                    // grid._gvo.setCellStyles(rowId, ["SUSER_ID_ASP", "RUSER_ID_ASP"], "style02");
                                }
                            } else {
                                grid._gvo.setCellStyles(rowId, ["SUSER_EMAIL"], "style02");
                                grid._gvo.setCellStyles(rowId, ["SUSER_ID_ASP", "SUSER_NM", "SUSER_DEPT_NM", "SUSER_TEL_NO", "E_BILL_ASP_TYPE", "ISSUE_DATE"], "style01");
                                grid._gvo.setCellStyles(rowId, ["RUSER_ID_ASP", "RUSER_NM", "RUSER_DEPT_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "TAX_SEND_TYPE", "ISSUE_DATE", "TAX_AMT"], "style01");
                            }

                   //         grid._gvo.setCellStyles(rowId, ["TAX_ASP_NM", "TAX_ASP_BILLSEQ"], "style01");
                        }

                        grid._gvo.setCellStyles(rowId, ["PAYMENT_YN", "PAYMENT_DATE"], "style02");

                        if("R" === rows[i].BILL_STAT_TYPE || "DR" === rows[i].BILL_STAT_TYPE || "DY" === rows[i].BILL_STAT_TYPE) {
//							grid.setRowBgColor(rowId, "#dbf3ff");
                            grid._gvo.setCellStyles(rowId, ["BILL_STAT_NM"], "style03");
                        } else if("E" === rows[i].BILL_STAT_TYPE || "2" === rows[i].BILL_STAT_TYPE || "4" === rows[i].BILL_STAT_TYPE) {
                            grid._gvo.setCellStyles(rowId, ["BILL_STAT_NM"], "style03");
                        }

                        TOT_AMT = Number(rows[i].SUP_AMT) + Number(rows[i].TAX_AMT);
                        grid.setCellValue(rowId, "TOT_AMT", TOT_AMT, false);
                    }

                    EVF.V("TOT_AMT", comma(String(P_SUP_AMT)) + " 원");
                    EVF.V("TOT_GR_AMT", "0 원");
                    EVF.V("TOT_PO_AMT", "0 원");
                    EVF.V("MARGIN_AMT", "0 원");
                    EVF.V("MARGIN_RATE", "0 %");

                    grid._gvo.setCheckBar({
                        checkableExpression: "values['TAX_BILLSEQ_YN'] = 'N'"
                    });
                    grid._gvo.applyCheckables();

                    var selectedRows = grid._gvo.getSelectedRows();
                    doSearchTTID(grid.getCellValue(selectedRows, "TAX_NUM"));
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
            store.load(baseUrl + "tx02020_doSearchTTID", function () {
                if(grid_TTID.getRowCount() == 0) {

                } else {
                    var rows = grid_TTID.getAllRowValue();

                    if(rows[0].TAX_EDIT_YN === "Y") {
                        //grid_TTID.setColReadOnly('TAX_AMT', false);
                        //grid_TTID.setColRequired("TAX_AMT", true);
                        grid_TTID.setColReadOnly('TAX_AMT', true);
                        grid_TTID.setColRequired("TAX_AMT", false);
                    } else {
                        grid_TTID.setColReadOnly('TAX_AMT', true);
                        grid_TTID.setColRequired("TAX_AMT", false);
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
            store.load(baseUrl + "tx02020_doUpdateTTID", function() {
            });
        }

        function doSearchBILLSTAT(TAX_BILLSEQ, BILL_STAT_TYPE) {
            var store = new EVF.Store();

            EVF.V("TAX_NUM", TAX_BILLSEQ);
            EVF.V("BILL_STAT_TYPE", BILL_STAT_TYPE);

            store.setGrid([grid]);
            store.load(baseUrl + "tx02020_doSearchBILLSTAT", function () {
                if(grid_TTID.getRowCount() == 0) {
                } else {
                    alert(this.data.MSG);
                }
            });
        }

        function doSave() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].SLHD_YN === "Y") {
                    alert("${TX02_020_998}");
                    return;
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_013}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 삭제
        function doTaxCancel() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].SLHD_YN === "Y") {
//                    alert("${TX02_020_998}");
//                    return;
                }
            }

            if(!confirm("${TX02_020_002}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doTaxCancel", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 병합
        function doSaveMerge() {
            var store = new EVF.Store();

            if(grid.getSelRowCount() <= 1) {
                return alert("${TX02_020_057}");
            }

            var selRowValue = grid.getSelRowValue();

            for(var i in selRowValue) {
                var row = selRowValue[i];

                if((row.BILL_STAT_TYPE != "" && row.BILL_STAT_TYPE != "DR") || row.TRANS_YN == "Y" || row.TRANS_YN == "N" || row.TAX_ASP_BILLSEQ != "") {
                    return alert("${TX02_020_056}");
                }

                for(var j in selRowValue) {
                    var rowJ = selRowValue[j];

                    if(row.SIRS_NUM != rowJ.SIRS_NUM) {
                        return alert("${TX02_020_056}");
                    }
                }
            }

            if(!confirm("${TX02_020_054}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doSaveMerge", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        // 계산서 전송
        function doUniPostTrans() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];

                if(rows[i].E_BILL_ASP_TYPE != "0") {
                    alert("${TX02_020_020}");

                    var index = {
                        column: "E_BILL_ASP_TYPE",
                        dataRow: rowId
                    };
                    grid._gvo.setCurrent(index);

                    return;
                }

                if(rows[i].BILL_STAT_TYPE == "NN" || rows[i].BILL_STAT_TYPE == "YY" ||
                    rows[i].BILL_STAT_TYPE == "N" || rows[i].BILL_STAT_TYPE == "W" ||
                    rows[i].BILL_STAT_TYPE == "Y") {
                    alert("${TX02_020_004}");
                    return;
                }

                if(rows[i].E_BILL_ASP_TYPE === "0") {
                    <%--if(rows[i].SUSER_ID_ASP === "" || rows[i].RUSER_ID_ASP === "") {--%>
                    <%--    var column = "";--%>

                    <%--    alert("${TX02_020_014}");--%>

                    <%--    if(rows[i].SUSER_ID_ASP === "") {--%>
                    <%--        column = "SUSER_ID_ASP";--%>
                    <%--    } else {--%>
                    <%--        column = "RUSER_ID_ASP";--%>
                    <%--    }--%>

                    <%--    var index2 = {--%>
                    <%--        column: column,--%>
                    <%--        dataRow: rowId--%>
                    <%--    };--%>
                    <%--    grid._gvo.setCurrent(index2);--%>

                    <%--    return;--%>
                    <%--}--%>
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_019}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doUniPostTrans", function() {
                if(this.responseCode === "ERR") {
                    var msg = JSON.parse(this.data.ERR.RESULT);
                    var t;

                    if(msg[0] == undefined) {
                        t = msg;
                    } else {
                        t = msg[0];
                    }

                    if(t.success) {
                        alert("${TX02_020_023}");
                    } else {
                        alert("UNIPOST msg : " + t.message);
                    }
                } else if(this.responseCode === "023") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        // 계산서 전송
        function doSendBillTrans() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var rowIds = grid.getSelRowId();
            for( var i = 0; i < rows.length; i++ ) {
                var rowId = rowIds[i];

                if(rows[i].E_BILL_ASP_TYPE != "0") {
                    alert("${TX02_020_020}");

                    var index = {
                        column: "E_BILL_ASP_TYPE",
                        dataRow: rowId
                    };
                    grid._gvo.setCurrent(index);

                    return;
                }

                if(rows[i].TAX_BILLSEQ !== "" || rows[i].TRANS_YN !== "") {
                    alert("${TX02_020_004}");
                    return;
                }

                if(rows[i].E_BILL_ASP_TYPE === "0") {
                    if(rows[i].SUSER_ID_ASP === "" || rows[i].RUSER_ID_ASP === "") {
                        var column = "";

                        alert("${TX02_020_014}");

                        if(rows[i].SUSER_ID_ASP === "") {
                            column = "SUSER_ID_ASP";
                        } else {
                            column = "RUSER_ID_ASP";
                        }

                        var index2 = {
                            column: column,
                            dataRow: rowId
                        };
                        grid._gvo.setCurrent(index2);

                        return;
                    }
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_019}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doSendBillTrans", function() {
                if(this.responseCode === "ERR") {
                    alert(this.getResponseMessage() + "\n[${TX02_020_039}:" + this.data.ERR.TAX_NUM + "]");
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
                } else if(this.responseCode === "023") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        // 재전송
        function doUniPostReSend() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].E_BILL_ASP_TYPE != "0") {
                    alert("${TX02_020_020}");
                    return;
                }

                if(rows[i].BILL_RE_SEND_YN === "N") {
                    if(rows[i].BILL_STAT_TYPE === "") {
                        alert("${TX02_020_033}");
                        return;
                    } else {
                        alert(rows[i].BILL_STAT_NM + " ${TX02_020_031}");
                        return;
                    }
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_042}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doUniPostReSend", function() {
                if(this.responseCode === "ERR") {
                    var msg = JSON.parse(this.data.ERR.RESULT);
                    var t;

                    if(msg[0] == undefined) {
                        t = msg;
                    } else {
                        t = msg[0];
                    }

                    if(t.success) {
                        alert("${TX02_020_023}");
                    } else {
                        alert("UNIPOST msg : " + t.message);
                    }
                } else if(this.responseCode === "040") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        // 재전송
        function doSendBillReSend() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].E_BILL_ASP_TYPE != "0") {
                    alert("${TX02_020_020}");
                    return;
                }

                if(rows[i].BILL_RE_SEND_YN === "N") {
                    if(rows[i].BILL_STAT_TYPE === "") {
                        alert("${TX02_020_033}");
                        return;
                    } else {
                        alert(rows[i].BILL_STAT_NM + " ${TX02_020_031}");
                        return;
                    }
                } else {
                    if(rows[i].TRANS_YN === "Y" || rows[i].TRANS_YN === "N") {
                        alert("${TX02_020_044}");
                        return;
                    }
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_042}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doSendBillReSend", function() {
                if(this.responseCode === "ERR") {
                    alert(this.getResponseMessage() + "\n[${TX02_020_039}:" + this.data.ERR.TAX_NUM + "]");

                    var column = "BILL_STAT_NM";
                    var rowsAll = grid.getAllRowValue();
                    var rowIdsAll = grid.getAllRowId();

                    for( var j = 0; j < rowsAll.length; j++ ) {
                        var rowIdAll = rowIdsAll[j];

                        if(this.data.ERR.TAX_NUM === rowsAll[j].TAX_NUM) {
                            grid._gvo.setCurrent({column: column, dataRow: rowIdAll});
                            grid.setCellBgColor(rowIdAll, column, "#ffd8eb");
                        }
                    }
                } else if(this.responseCode === "040") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        // 세금계산서 취소
        function doUniPostCancel() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            var rowIdsAll = grid.getSelRowId();
            var accountYN = "N";

            for( var i = 0; i < rows.length; i++ ) {
                var rowIdAll = rowIdsAll[i];

                if(rows[i].E_BILL_ASP_TYPE != "0") {
                    alert("${TX02_020_020}");
                    return;
                }

                if(rows[i].BILL_DEL_YN === "N") {
                    if(rows[i].BILL_STAT_TYPE === "") {
                        alert("${TX02_020_033}");
                        return;
                    } else {
                        alert(rows[i].BILL_STAT_NM + " ${TX02_020_031}");
                        return;
                    }
                } else {
                    if(rows[i].TRANS_YN === "Y" || rows[i].TRANS_YN === "N") {
                        alert("${TX02_020_044}");
                        return;
                    } else {
                        if(rows[i].ACCOUNT_CHECK_YN == "1") {
                            accountYN = "Y";
                        }
                    }
                }
            }

            if(accountYN == "Y") {
                alert("${TX02_020_053}");
                return;
            }

            for( var j = 0; i < rows.length; i++ ) {
                var rowIdsAllIdx = rowIdsAll[i];

                if(rows[j].TAX_CANCEL_REASON === "") {
                    alert("${TX02_020_051}");
                    grid._gvo.setCurrent({column: "TAX_CANCEL_REASON", dataRow: rowIdsAllIdx});
                    return;
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_032}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doUniPostCancel", function() {
                if(this.responseCode === "ERR") {
                    var msg = JSON.parse(this.data.ERR.RESULT);
                    var t;

                    if(msg[0] == undefined) {
                        t = msg;
                    } else {
                        t = msg[0];
                    }

                    if(t.success) {
                        alert("${TX02_020_036}");
                    } else {
                        alert("UNIPOST msg : " + t.message);
                    }
                } else if(this.responseCode === "036") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        // 세금계산서 취소/삭제
        function doSendBillCancel() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].E_BILL_ASP_TYPE != "0") {
                    alert("${TX02_020_020}");
                    return;
                }

                if(rows[i].BILL_DEL_YN === "N") {
                    if(rows[i].BILL_STAT_TYPE === "") {
                        alert("${TX02_020_033}");
                        return;
                    } else {
                        alert(rows[i].BILL_STAT_NM + " ${TX02_020_031}");
                        return;
                    }
                } else {
                    if(rows[i].TRANS_YN === "Y" || rows[i].TRANS_YN === "N") {
                        alert("${TX02_020_044}");
                        return;
                    }
                }
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm("${TX02_020_032}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doSendBillCancel", function() {
                if(this.responseCode === "ERR") {
                    alert(this.getResponseMessage() + "\n[${TX02_020_039}:" + this.data.ERR.TAX_NUM + "]");

                    var column = "BILL_STAT_NM";
                    var rowsAll = grid.getAllRowValue();
                    var rowIdsAll = grid.getAllRowId();

                    for( var j = 0; j < rowsAll.length; j++ ) {
                        var rowIdAll = rowIdsAll[j];

                        if(this.data.ERR.TAX_NUM === rowsAll[j].TAX_NUM) {
                            grid._gvo.setCurrent({column: column, dataRow: rowIdAll});
                            grid.setCellBgColor(rowIdAll, column, "#ffd8eb");
                        }
                    }
                } else if(this.responseCode === "036") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        // 메일 재발송
        function doUniPostMailReSend() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rows = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].BILL_STAT_TYPE != "NN") {
                    <%--alert("${TX02_020_052}");--%>
                    <%--return;--%>
                }
            }

            if(!confirm("${TX02_020_049}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doUniPostMailReSend", function() {
                if(this.responseCode === "ERR") {
                    var msg = JSON.parse(this.data.ERR.RESULT);
                    var t;

                    if(msg[0] == undefined) {
                        t = msg;
                    } else {
                        t = msg[0];
                    }

                    if(t.success) {
                        alert("${TX02_020_050}");
                    } else {
                        alert("UNIPOST msg : " + t.message);
                    }

                } else if(this.responseCode === "050") {
                    alert(this.getResponseMessage());
                    doSearch();
                }
            });
        }

        function doSavePayment() {
            var store = new EVF.Store();
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                var rowIdx = selRowId[i];

                if(grid.getCellValue(rowIdx, "DEPOSIT_YN") == "") {
                    alert("${TX02_020_046}");
                    grid._gvo.setCurrent({column: "DEPOSIT_YN", dataRow: rowIdx});
                    return;
                } else if(grid.getCellValue(rowIdx, "DEPOSIT_DATA") == "") {
                    alert("${TX02_020_047}");
                    grid._gvo.setCurrent({column: "DEPOSIT_DATA", dataRow: rowIdx});
                    return;
                }
            }

            if(!confirm("${TX02_020_013}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "tx02020_doSavePayment", function() {
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

            if(custCd == "") {
                alert("${TX02_020_035}");
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
            var data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.ITEM_CLS2);
            EVF.C("DEPT_NM").setValue(data.ITEM_CLS_NM);
        }

        function searchCPO_USER_ID() {
            var custCd = EVF.V("CUST_CD");

            if(custCd == "") {
                alert("${TX02_020_035}");
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
                alert("${TX02_020_035}");
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

        function onIconClickVENDOR_CD() {
            var param = {
                callBackFunction : "callbackVENDOR_CD"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function callbackVENDOR_CD(data) {
            EVF.V("VENDOR_CD", data.VENDOR_CD);
            EVF.V("VENDOR_NM", data.VENDOR_NM);
        }



        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
		/* 	if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
				return alert("${msg.M0006}");
			} */

            var taxList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                taxList.push( grid.getCellValue(rowIds[i], 'TAX_NUM') );
            }

            // 중복 값 제거
            var pouniq = taxList.reduce(function(a,b){
                if (a.indexOf(b) < 0 ) a.push(b);
                return a;
            },[]);

            var param = {
            		TAX_LIST : JSON.stringify(pouniq) ,
            };
            everPopup.openPopupByScreenId("PRT_091", 976, 800, param);
        }

        function doSendMail() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!confirm('${TX02_020_054}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'doAlarmInvoiceDelay', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }
    </script>

    <e:window id="TX02_020" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="TAX_NUM" name="TAX_NUM" value="" />
            <e:inputHidden id="BILL_STAT_TYPE" name="BILL_STAT_TYPE" value="" />

            <e:row>
                <e:label for="CLOSE_YEAR" title="${form_CLOSE_YEAR_N}"/>
                <e:field>
                    <e:select id="CLOSE_YEAR" name="CLOSE_YEAR" value="${CLOSE_YEAR}" options="${closeYearOptions}" width="80" disabled="${form_CLOSE_YEAR_D}" readOnly="${form_CLOSE_YEAR_RO}" required="${form_CLOSE_YEAR_R}" placeHolder="" usePlaceHolder="false" />
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
                </e:field>




                <e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
                <e:field>
                    <e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
                </e:field>


				<c:if test="${ses.userType=='C'}">
	                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
	                <e:field>
	                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'onIconClickVENDOR_CD'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
	                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
	                </e:field>
				</c:if>
				<c:if test="${ses.userType!='C'}">
	                <e:field>

	                </e:field>
	                <e:field>
	                </e:field>
				</c:if>
            </e:row>
        </e:searchPanel>

        <e:panel width="50%" visible="false">
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
        	<e:text>&nbsp;</e:text>
        </e:panel>

        <e:panel width="50%">
            <e:buttonBar align="right" width="100%">

	                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
				<c:if test="${ses.userType=='C'}">
	                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
	                <e:button id="doTaxCancel" name="doTaxCancel" label="${doTaxCancel_N}" onClick="doTaxCancel" disabled="${doTaxCancel_D}" visible="${doTaxCancel_V}"/>
					<e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
                    <e:button id="doSendMail" name="doSendMail" label="${doSendMail_N}" onClick="doSendMail" disabled="${doSendMail_D}" visible="${doSendMail_V}"/>
                </c:if>

            </e:buttonBar>
        </e:panel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="300px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
        <e:panel height="fit" width="30%">
            <e:title title="${TX02_020_007 }" depth="1"/>
        </e:panel>
        <e:gridPanel gridType="${_gridType}" id="grid_TTID" name="grid_TTID" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid_TTID.gridColData}" />
    </e:window>
</e:ui>