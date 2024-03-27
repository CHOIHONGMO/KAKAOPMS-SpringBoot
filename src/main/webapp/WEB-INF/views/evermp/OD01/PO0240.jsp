<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid; var gridEx;
        var baseUrl = "/evermp/OD01/OD0101/";
        var autoSearchFlag = '${form.autoSearchFlag}';
        var callType = '${form.callType}';
        var gridJsonData;

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('multiSelect', true);
            //grid.setProperty('sortable', false);
            gridEx = EVF.C("gridEx");
            gridEx.setProperty('multiSelect', false);
            //gridEx.setProperty('sortable', false);

            EVF.C("PR_TYPE").removeOption("R");


            if('${form.autoSearchFlag}' == 'Y') {

                if('${form.DELY_REJECT_CD}' == '1') {
                    EVF.V('DELY_REJECT_CD', '${form.DELY_REJECT_CD}');
                } else {
                    var chkName = "";
                    $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                        if (v.value == '30' || v.value == '38' || v.value == '40' || v.value == '50' || v.value == '60' || v.value == '65' || v.value == '70') {
                            chkName += v.title + ", ";
                            v.checked = true;
                        }
                    });

                    $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                }

                doSearch();
            }
            else if("${form.LINK_ID}" === "MY03_050" || "${form.LINK_ID}" === "MY03_060") {

                EVF.V("CUST_CD", "${form.CUST_CD}");
                EVF.V("CUST_NM", "${form.CUST_NM}");
                EVF.V("VENDOR_CD", "${form.VENDOR_CD}");
                EVF.V("VENDOR_NM", "${form.VENDOR_NM}");
                EVF.V("START_DATE", "${form.START_DATE}");
                EVF.V("END_DATE", "${form.END_DATE}");

                if("${form.CLOSE_YN}" === "Y") {
                    var chkName = "";
                    $(".ui-multiselect-checkboxes li input").each(function (k, v) {
                        if (v.value == '70') {
                            chkName += v.title + ", ";
                            v.checked = true;
                        }
                    });
                } else {
                    var chkName = "";
                    $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                        if (v.value == '30' || v.value == '38' || v.value == '40' || v.value == '50' || v.value == '60' || v.value == '65' || v.value == '70') {
                            chkName += v.title + ", ";
                            v.checked = true;
                        }
                    });
                }
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));

                doSearch();
            }
            else {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '30' || v.value == '38' || v.value == '40' || v.value == '50' || v.value == '60' || v.value == '65' || v.value == '70') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });

                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
            }

            grid.cellClickEvent(function(rowIdx, colIdx, value, iRow, iCol) {
                var param;

                if(colIdx == "multiSelect") {
                    var GR_ITEM_AMT = 0;
                    var PO_ITEM_AMT = 0;
                    var MARGIN_RATE = 0;

                    var rows = grid.getSelRowValue();
                    var CPO_NO_SEQ = "";
                    for( var i = 0; i < rows.length; i++ ) {
                        if(CPO_NO_SEQ != rows[i].CPO_NO_SEQ) {
                            GR_ITEM_AMT += Number(rows[i].CPO_ITEM_AMT);
                            PO_ITEM_AMT += Number(rows[i].PO_ITEM_AMT);
                        }

                        CPO_NO_SEQ = rows[i].CPO_NO_SEQ;
                    }

                    if(PO_ITEM_AMT > 0) {
                        MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
                    }

                    EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT.toFixed(2))) + " 원");
                    EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT.toFixed(2))) + " 원");
                    EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT.toFixed(2) - PO_ITEM_AMT.toFixed(2))) + " 원");
                    EVF.V("MARGIN_RATE", String(MARGIN_RATE.toFixed(2)) + " %");
                } else if(colIdx == 'CPO_USER_NM') {
                    if( grid.getCellValue(rowIdx, 'CPO_USER_ID') == '' ) return;
                    param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowIdx, 'CPO_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if (colIdx == "ITEM_CD") {
                    param = {
                        ITEM_CD: grid.getCellValue(rowIdx, 'ITEM_CD'),
                        popupFlag: true,
                        detailView: false
                    };
                    everPopup.im03_014open(param);
                } else if(colIdx === "CPO_NO") { // 주문번호
                    param = {
                        callbackFunction: "",
                        "CPO_NO" : grid.getCellValue(rowIdx, "CPO_NO")
                    };
                    everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
                } else if (colIdx == "CPO_SEQ") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowIdx, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowIdx, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if (colIdx == "VENDOR_NM") {
                    param = {
                        VENDOR_CD: grid.getCellValue(rowIdx, 'VENDOR_CD'),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if(colIdx == "DELY_DELAY_NM") { // 납품지연상세사유
                    var delyCd = grid.getCellValue(rowIdx, 'DELY_DELAY_CD');
                    if( delyCd == "" ) return;
                    param = {
                        title: '납품지연사유',
                        CODE: grid.getCellValue(rowIdx, 'DELY_DELAY_CD'),
                        TEXT: grid.getCellValue(rowIdx, 'DELY_DELAY_REASON'),
                        rowId: rowIdx,
                        detailView: true
                    };
                    var url = '/evermp/SIV1/SIV101/SIV1_022/view';
                    everPopup.openModalPopup(url, 600, 360, param);
                } else if(colIdx == "DELY_REJECT_NM") { // 납품거부상세사유
                    var rejectCd = grid.getCellValue(rowIdx, 'DELY_REJECT_CD');
                    if( rejectCd == "" ) return;
                    param = {
                        title: '납품거부사유',
                        CODE: grid.getCellValue(rowIdx, 'DELY_REJECT_CD'),
                        TEXT: grid.getCellValue(rowIdx, 'DELY_REJECT_REASON'),
                        detailView: true
                    };
                    var url = '/evermp/SIV1/SIV101/SIV1_023/view';
                    everPopup.openModalPopup(url, 600, 360, param);
                } else if(colIdx == 'AM_USER_NM') { // 구매담당자
                    if( grid.getCellValue(rowIdx, 'AM_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowIdx, 'AM_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colIdx == 'DELY_COMPLETE_USER_NM') { // 납품완료자
                    if( grid.getCellValue(rowIdx, 'DELY_COMPLETE_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowIdx, 'DELY_COMPLETE_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colIdx == 'GR_USER_NM') { // 입고자
                    if( grid.getCellValue(rowIdx, 'GR_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowIdx, 'GR_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colIdx == 'RECIPIENT_NM') { // 인수자
                    if( grid.getCellValue(rowIdx, 'RECIPIENT_NM') == '' ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowIdx, 'CPO_NO'),
                        CPO_SEQ: grid.getCellValue(rowIdx, 'CPO_SEQ'),
                        detailView: 'true'
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colIdx == 'CHANGE_REMARK') { // 주문변경사유
                    if( grid.getCellValue(rowIdx, 'CHANGE_REMARK') == '' ) return;
                    param = {
                        title: "주문변경사유"
                        ,message: grid.getCellValue(rowIdx, "CHANGE_REMARK")
                        ,detailView: true
                    };
                    var url = '/common/popup/common_text_view/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                } else if(colIdx == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowIdx, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        callbackFunction: "callbackGridAGENT_MEMO",
                        rowId: rowIdx,
                        detailView: false
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
                } else if(colIdx == "REQ_TEXT") {
                	return;
                    if(value != "") {
                        param = {
                            title: "요청사항",
                            message: grid.getCellValue(rowIdx, "REQ_TEXT"),
                            callbackFunction: "callbackGridREQ_TEXT",
                            detailView: true,
                            rowId: rowIdx
                        };
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    }
                } else if(colIdx == "ATTACH_FILE_CNT") {
                    if(value > 0) {
                        param = {
                            attFileNum: grid.getCellValue(rowIdx, "ATTACH_FILE_NO"),
                            rowId: rowIdx,
                            callBackFunction: "callbackGridATTACH_FILE_CNT",
                            havePermission: false,
                            bizType: "OM",
                            fileExtension: "*"
                        };
                        everPopup.openPopupByScreenId("commonFileAttach", 650, 310, param);
                    }
                } else if(colIdx == "AGENT_ATTACH_FILE_CNT") {
                    param = {
                        attFileNum: grid.getCellValue(rowIdx, "AGENT_ATTACH_FILE_NO"),
                        rowId: rowIdx,
                        callBackFunction: "callbackGridAGENT_ATTACH_FILE_CNT",
                        havePermission: true,
                        bizType: "OM",
                        fileExtension: "*"
                    };
                    everPopup.openPopupByScreenId("commonFileAttach", 650, 310, param);
                } else if(colIdx == "WAYBILL_NO") { // 운송장번호
                	if(value=='') return;
                    var param = {
                       		'code': grid.getCellValue(rowIdx,'DELY_COMPANY_NM'),	// 택배사코드
                       		'value': value	// 송장번호
                        };
                        everPopup.CourierPop(param);
                }
            });

            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {
                var GR_ITEM_AMT = 0;
                var PO_ITEM_AMT = 0;
                var MARGIN_RATE = 0;

                if(checked) {
                    var rows = grid.getSelRowValue();
                    var CPO_NO_SEQ = "";
                    for( var i = 0; i < rows.length; i++ ) {
                        if(CPO_NO_SEQ != rows[i].CPO_NO_SEQ) {
                            GR_ITEM_AMT += Number(rows[i].CPO_ITEM_AMT);
                            PO_ITEM_AMT += Number(rows[i].PO_ITEM_AMT);
                        }

                        CPO_NO_SEQ = rows[i].CPO_NO_SEQ;
                    }

                    if(GR_ITEM_AMT > 0) {
                        MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
                    }

                    EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT.toFixed(2))) + " 원");
                    EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT.toFixed(2))) + " 원");
                    EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT.toFixed(2) - PO_ITEM_AMT.toFixed(2))) + " 원");
                    EVF.V("MARGIN_RATE", String(MARGIN_RATE.toFixed(2)) + " %");
                } else {
                    EVF.V("TOT_GR_AMT", "0 원");
                    EVF.V("TOT_PO_AMT", "0 원");
                    EVF.V("MARGIN_AMT", "0 원");
                    EVF.V("MARGIN_RATE", "0 %");
                }
            };

            gridEx.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            /*
            var val = {"visible": true, "count": 1, "height": 40};
            var footerTxt = {
                "styles": {
                    "textAlignment": "far",
                    "font": "굴림,12",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": ["합 계 "]
            };
            var footerSum_PO = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['HDN_PO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

            var footerSum_CPO = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['HDN_CPO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

            var footerSum_RATE = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.#",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["(sum['HDN_CPO_ITEM_AMT'] - sum['HDN_PO_ITEM_AMT'])/sum['HDN_CPO_ITEM_AMT']*100"],
                "groupExpression": "sum"
            };

            var MARGIN_AMT = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['HDN_CPO_ITEM_AMT'] - sum['HDN_PO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

            grid.setProperty('footerVisible', val);
            grid.setRowFooter('CPO_UNIT_PRICE', footerTxt);
            grid.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);
            grid.setRowFooter("MARGIN_AMT", MARGIN_AMT);
            grid.setRowFooter("ITEM_AMT_RATE", footerSum_RATE);
//            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);
             */

            grid._gvo.setHeader({height:36});
            //grid._gvo.setFixedOptions({colCount: 2});
            //grid.freezeCol("PROGRESS_NM");

            grid._gvo.onScrollToBottom = function() {
                doSearchLazy();
            }

            gridEx.setProperty('footerVisible', val);
            gridEx.setRowFooter('CPO_UNIT_PRICE', footerTxt);
            gridEx.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            gridEx.setRowFooter("PO_ITEM_AMT", footerSum_PO);
            gridEx.setRowFooter("MARGIN_AMT", MARGIN_AMT);
            gridEx.setRowFooter("ITEM_AMT_RATE", footerSum_RATE);
            gridEx.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);

            gridEx._gvo.setHeader({height:36});
            gridEx.freezeCol("PROGRESS_NM");
            doSearch();

        }

        function callbackGridAGENT_MEMO(data) {
            grid.setCellValue(data.rowId, "AGENT_MEMO", data.message);

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "od01010_doSaveAGENT_MEMO", function() {
            });
        }

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
        }

        function callbackGridATTACH_FILE_CNT(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, "ATTACH_FILE_NO", fileId);
            grid.setCellValue(rowId, "ATTACH_FILE_CNT", fileCnt);
        }

        function callbackGridAGENT_ATTACH_FILE_CNT(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, "AGENT_ATTACH_FILE_NO", fileId);
            grid.setCellValue(rowId, "AGENT_ATTACH_FILE_CNT", fileCnt);
        }

        var excelData;
        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid,gridEx]);
            store.load(baseUrl + "PO0240/doSearch", function () {


                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                } else {

                    var TOT_PO_AMT = 0;
                    var TOT_AMT = 0;
                    var rowIds = grid.getAllRowId();
                    var CPO_NO_SEQ = "";
                    for(var i = 0; i < rowIds.length; i++) {
                        var selectedData = grid.getRowValue(rowIds[i]);
//                        if(selectedData.PROGRESS_CD == '10' || selectedData.PROGRESS_CD == '20') {
//                            grid._gvo.setCheckable(rowIds[i], false);
//                        }
                        if(CPO_NO_SEQ != selectedData.CPO_NO_SEQ) {
                            TOT_PO_AMT += Number(selectedData.PO_ITEM_AMT);
                            TOT_AMT += Number(selectedData.CPO_ITEM_AMT);
                        }

                        CPO_NO_SEQ = selectedData.CPO_NO_SEQ;

                        if(grid.getCellValue(rowIds[i], "DELY_REJECT_NM") != "") {
                            grid.setRowBgColor(rowIds[i], "#ffaade");
                        }

                        if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "5100") {
                            grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#bae3ff");
                        }

                        if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6100") {
                            grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#ffaed3");
                        }

                        if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6300") {
                            grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#abffaf");
                        }
                    }

                    EVF.V("TOT_AMT", comma(String(TOT_AMT.toFixed(2))) + " 원");




                }




            });


        }

        function doExcelDown() {
            gridEx.delAllRow();
            gridEx.addRow(excelData);
            gridEx.addRow();
            gridEx.delRow(gridEx.getRowCount() - 1);

            var cpoItemAmt = Number(gridEx._gvo.getSummary('CPO_ITEM_AMT', 'SUM'));
            var poItemAmt = Number(gridEx._gvo.getSummary('PO_ITEM_AMT', 'SUM'));

            if(!EVF.isEmpty(cpoItemAmt) && cpoItemAmt > 0) {
                if(!EVF.isEmpty(poItemAmt) && poItemAmt > 0) {
                    var salesRate = everMath.round_float(((cpoItemAmt - poItemAmt) / cpoItemAmt) * 100, 1);
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
                    // gridEx.setRowFooter('ITEM_AMT_RATE', footerRate);
                }
            }

            $(".btn-download:eq(0)").trigger("click");
        }

        function doExcelDownView() {

            var footerRateZero = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": ["0%"]
            };
            // gridEx.setRowFooter('ITEM_AMT_RATE', footerRateZero);

            gridEx.setColIconify("CHANGE_REMARK", "CHANGE_REMARK", "comment", false);

            gridEx.setColMerge(['CPO_NO_SEQ', 'CUST_NM', 'DEPT_NM', 'CPO_USER_NM', 'CPO_USER_ID', 'BD_DEPT_NM', "ACCOUNT_CD", 'ACCOUNT_NM', 'COST_CENTER_CD', 'COST_CENTER_NM', 'PLANT_CD', 'IF_CPO_NO_SEQ', 'CPO_NO','CPO_SEQ', 'PRIOR_GR_FLAG_NM',
                'REF_MNG_NO', 'CUST_ITEM_CD','ITEM_CD','NAP_FLAG','ITEM_DESC','ITEM_SPEC', 'MAKER_NM', 'MAKER_PART_NO', 'BRAND_NM', 'ORIGIN_NM', 'UNIT_CD', 'CPO_QTY', 'U_GR_QTY', 'PRE_GR_QTY', 'CUR', 'CPO_UNIT_PRICE', 'CPO_ITEM_AMT',
                'PO_UNIT_PRICE', 'PO_ITEM_AMT', 'MARGIN_AMT', 'ITEM_AMT_RATE', 'LEAD_TIME', 'CPO_DATE', 'YPO_REG_DATE', 'HOPE_DUE_DATE', 'LEAD_TIME_DATE', 'DELY_PLACE', 'DELY_TYPE', 'REQ_USER_NM', 'REQ_USER_TEL_NUM', 'RECIPIENT_NM',
                'CSDM_SEQ', 'DELY_NM', 'RECIPIENT_DEPT_NM', 'RECIPIENT_TEL_NUM', 'RECIPIENT_FAX_NUM', 'RECIPIENT_CELL_NUM', 'RECIPIENT_EMAIL','DELY_ZIP_CD', 'DELY_ADDR_1', 'DELY_ADDR_2', 'SUP_INV_QTY',
                'SUP_NOT_INV_QTY', 'SUP_NOT_GR_QTY','PO_NO', 'PO_SEQ', 'VENDOR_NM', 'REQ_TEXT', 'ATTACH_FILE_CNT','AGENT_ATTACH_FILE_CNT','AGENT_MEMO']);
            gridEx.setColMerge(['VENDOR_NM','IV_NO', 'IV_SEQ', 'IF_INVC_CD', 'INV_QTY', 'DELY_APP_DATE', 'DELY_COMPLETE_DATE', 'DELY_COMPLETE_USER_NM', 'MANAGE_NM', 'DELY_COMPANY_NM', 'WAYBILL_NO', 'DELY_REJECT_NM', 'DELY_REJECT_REASON', 'DELY_REJECT_DATE',
                'DELY_DELAY_NM', 'DELY_DELAY_REASON']);
        }

        function doSearchLazy() {
            var newStart = grid.getRowCount();
            grid._gdp.fillJsonData(gridJsonData, {fillMode: "append", start: newStart, count: 30});

            var cpoItemAmt = Number(grid._gvo.getSummary('CPO_ITEM_AMT', 'SUM'));
            var poItemAmt = Number(grid._gvo.getSummary('PO_ITEM_AMT', 'SUM'));

            var TOT_AMT = 0;
            var rowIds = grid.getAllRowId();
            var CPO_NO_SEQ = "";
            for(var i = 0; i < rowIds.length; i++) {
                var selectedData = grid.getRowValue(rowIds[i]);

                if(CPO_NO_SEQ != selectedData.CPO_NO_SEQ) {
                    TOT_AMT += Number(selectedData.CPO_ITEM_AMT);
                }

                CPO_NO_SEQ = selectedData.CPO_NO_SEQ;

                if(grid.getCellValue(rowIds[i], "DELY_REJECT_NM") != "") {
                    grid.setRowBgColor(rowIds[i], "#ffaade");
                }

                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "38") {
                    grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#bae3ff");
                }

                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "40" || grid.getCellValue(rowIds[i], "PROGRESS_CD") == "50") {
                    grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#ffaed3");
                }

                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "60" || grid.getCellValue(rowIds[i], "PROGRESS_CD") == "65") {
                    grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#abffaf");
                }
            }

            EVF.V("TOT_AMT", comma(String(TOT_AMT.toFixed(2))) + " 원");

            if(!EVF.isEmpty(cpoItemAmt) && cpoItemAmt > 0) {
                if(!EVF.isEmpty(poItemAmt) && poItemAmt > 0) {
                    var salesRate = everMath.round_float(((cpoItemAmt - poItemAmt) / cpoItemAmt) * 100, 1);
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
                    // grid.setRowFooter('ITEM_AMT_RATE', footerRate);
                    // alert(cpoItemAmt + "[]" + poItemAmt);
                }
            }
        }

        function doChangeOrder() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            var rowIds = grid.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                var selectedData = grid.getRowValue(rowIds[i]);
                if(!(selectedData.PROGRESS_CD == '38' || selectedData.PROGRESS_CD == '40')) {
                    return alert("${PO0240_0006}"); // 진행상태를 확인하여 주시기 바랍니다.
                }
            }

            var param = {
                callbackFunction : "doSearch",
                'CPO_NO' : grid.getCellValue(rowIds[0], "CPO_NO"),
                'CPO_SEQ' : grid.getCellValue(rowIds[0], "CPO_SEQ"),
                'PO_NO' : grid.getCellValue(rowIds[0], "PO_NO"),
                'PO_SEQ' : grid.getCellValue(rowIds[0], "PO_SEQ"),
                'detailView' : false,
                'popupFlag' : true
            };
            everPopup.openPopupByScreenId("OD01_011", 1100, 700, param);
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
            //chgCustCd();
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${PO0240_001}");
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

        function searchCustDeptCd() {
            var custCd = EVF.V("CUST_CD");
            var custNm = EVF.V("CUST_NM");
            if( custCd == "" ) {
                alert("${PO0240_001}");
                return;
            }

            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "selectCustDeptCd",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : custCd,
                'custNm' : custNm
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchDeptPopup");
        }

        function selectCustDeptCd(dataJsonArray) {
            data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function searchCustUserId() {
            var custCd = EVF.V("CUST_CD");
            if( custCd == "" ) {
                alert("${PO0240_001}");
                return;
            }

            var param = {
                callBackFunction: "selectCustUserId",
                custCd: custCd
            };
            everPopup.openCommonPopup(param, "SP0083");
        }

        function selectCustUserId(dataJsonArray) {
            EVF.C("CPO_USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("CPO_USER_NM").setValue(dataJsonArray.USER_NM);
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        function doPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                cpoList.push( grid.getCellValue(rowIds[i], 'CPO_NO') );
            }

            // 중복 값 제거
            var cpouniq = cpoList.reduce(function(a,b){
                if (a.indexOf(b) < 0 ) a.push(b);
                return a;
            },[]);

            var param = {
                CPO_LIST : JSON.stringify(cpouniq)
            };
            everPopup.openPopupByScreenId("PRT_030", 976, 800, param);
        }

        function doCancle() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoNo = "";
            var rows  = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].PROGRESS_CD !== "30") {
                    return alert("${PO0240_006}");
                }
                if( cpoNo != "" && cpoNo != rows[i].CPO_NO ){
                    return alert("${PO0240_009}");
                }
                cpoNo = rows[i].CPO_NO;
            }

            if(!confirm("${PO0240_007}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");

            store.load("/evermp/BOD1/BOD104/" + "bod1040_doCancel", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doPoPrint() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var poList = [];
            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {
                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "35") {
                    alert("${PO0240_010}");
                    grid.checkRow(rowIds[i],false);
                    return;
                }
                poList.push( grid.getCellValue(rowIds[i], 'PO_NO') );
            }

            // 중복 값 제거
            var pouniq = poList.reduce(function(a,b){
                if (a.indexOf(b) < 0 ) a.push(b);
                return a;
            },[]);

            var param = {
                PO_LIST : JSON.stringify(pouniq)
            };
            everPopup.openPopupByScreenId("PRT_031", 976, 800, param);
        }

        function doCanclePO() {
            var store = new EVF.Store();

            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoNo = "";
            var rows  = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].PROGRESS_CD !== "38") {
                    return alert("${PO0240_005}");
                }
            }

            if(!confirm("${PO0240_008}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");

            store.load(baseUrl + "od01010_doCancelPO", function() {
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

		function doPoCancel() {

			 if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	            var rowIds = grid.getSelRowId();
	            for(var i in rowIds) {
	                /*
	                if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
	                    return alert("${PO0240_0008}");
	                }
	                */

	            	if(grid.getCellValue(rowIds[i], "PROGRESS_CD") != "6100") {
	                    grid.checkRow(rowIds[i], false);
	                    return alert("${PO0240_0029}");
	                }

	                if(grid.getCellValue(rowIds[i], 'FORCE_CLOSE_DATE') != "") {
	                    return alert("${PO0240_0034}");
	                }


	            }

	            if(!confirm('${PO0240_0031}')) { return; }
	            var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.setParameter("PROGRESS_CD", '5100'); // 확정대기
	            store.load(baseUrl + 'PO0240_doPoCancel', function() {
	                alert(this.getResponseMessage());
	                doSearch();
	            });

		}

		function doPoClose() {
			 if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	            var rowIds = grid.getSelRowId();
	            for(var i in rowIds) {
	                /*
	                if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
	                    return alert("${PO0240_0008}");
	                }
	                */

	                if(grid.getCellValue(rowIds[i], 'FORCE_CLOSE_DATE') != "") {
	                    return alert("${PO0240_0034}");
	                }

	                if(grid.getCellValue(rowIds[i], 'CPO_QTY') == grid.getCellValue(rowIds[i], 'INV_QTY')) {
	                    return alert("${PO0240_0035}");
	                }


	                if(grid.getCellValue(rowIds[i], 'PROGRESS_NM') == "납품대기") {
	                    return alert("${PO0240_0036}");
	                }


	            }

	            if(!confirm('${PO0240_0032}')) { return; }
	            var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.load(baseUrl + 'PO0240_doPoClose', function() {
	                alert(this.getResponseMessage());
	                doSearch();
	            });
		}



    </script>

    <e:window id="PO0240" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
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
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
				<e:inputText id="CPO_NO" name="CPO_NO" value="" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
				<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="60%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
				</e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="G" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
                <e:field>
                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${ses.userId}" options="${sgCtrlUserIdOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false"/>
                </e:field>

                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${PO0240_0001}" value="CPO_DATE"/>
                        <e:option text="${PO0240_0002}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${empty param.yesterday ? addFromDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${empty param.yesterday ? addToDate : param.yesterday}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
					<e:inputHidden id="ITEM_CD" name="ITEM_CD"/>
					<e:inputHidden id="MAKER_CD" name="MAKER_CD"/>
					<e:inputHidden id="DELY_REJECT_CD" name="DELY_REJECT_CD"/>
					<e:inputHidden id="DOC_NUM_COMBO" name="DOC_NUM_COMBO"/>
					<e:inputHidden id="DOC_NUM" name="DOC_NUM"/>
                </e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
				<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:panel width="60%" visible="false">
            <div style="float: left;margin-top: 3px;">
            <!-- e:button id="doCanclePO" name="doCanclePO"  align="left" label="${doCanclePO_N}" onClick="doCanclePO" disabled="${doCanclePO_D}" visible="${doCanclePO_V}"/-->
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
            </div>
        </e:panel>

        <e:panel width="40%">
        </e:panel>
            <e:buttonBar width="100%" align="right">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doPoCancel" name="doPoCancel" label="${doPoCancel_N}" onClick="doPoCancel" disabled="${doPoCancel_D}" visible="${doPoCancel_V}"/>
			<e:button id="doPoClose" name="doPoClose" label="${doPoClose_N}" onClick="doPoClose" disabled="${doPoClose_D}" visible="${doPoClose_V}"/>
            </e:buttonBar>

        <div style="display: none;">
            <e:gridPanel id="gridEx" name="gridEx" width="0" height="0" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridEx.gridColData}" />
        </div>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>