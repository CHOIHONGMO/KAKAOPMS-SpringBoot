<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/OD01/OD0101/";
        var autoSearchFlag = '${form.autoSearchFlag}';
        var callType = '${form.callType}';
        var ROW_IDX;
        var footerSum_PO;
        var footerSum_CPO;
        var CONFIRM_POP_YN = "N";

        function init() {

        	EVF.C("PR_TYPE").removeOption("R");

            grid = EVF.C("grid");
            grid.setProperty('multiSelect', true);
            //grid.setProperty('sortable', false);

            // 관리자 권한
            /*
            if('${ses.superUserFlag}' == '0' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                EVF.V("AM_USER_ID",'${ses.userId}');
            }
            */

            if('${form.autoSearchFlag}' == 'Y') {

                if('${form.DELY_REJECT_CD}' == '1') {
                    EVF.V('DELY_REJECT_CD', '${form.DELY_REJECT_CD}');
                } else {
                    var chkName = "";
                    $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                        if (v.value == '30' || v.value == '36') {
                            chkName += v.title + ", ";
                            v.checked = true;
                        }
                    });

                    $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                }
                doSearch();
            }
            else if('${form.autoSearchFlag}' == 'Z30') {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '30') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                doSearch();
            }
            else if('${form.autoSearchFlag}' == 'Z36') {
                var chkName = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '36') {
                        chkName += v.title + ", ";
                        v.checked = true;
                    }
                });
                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName.substr(0, chkName.length - 2));
                doSearch();
            }
            else {
                var chkName2 = "";
                $('.ui-multiselect-checkboxes li input').each(function (k, v) {
                    if (v.value == '30' || v.value == '36') {
                        chkName2 += v.title + ", ";
                        v.checked = true;
                    }
                });

                $('#PROGRESS_CD').next().find('span, .e-select-text').text(chkName2.substr(0, chkName2.length - 2));
            }

            grid.cellClickEvent(function(rowId, colIdx, value) {
                var param;

                ROW_IDX = rowId;

                // 주문자
                if(colIdx == 'CPO_USER_NM') {
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
                else if (colIdx == "ITEM_CD") {
                    param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_009open(param);
                }
                else if (colIdx == "APP_DOC_NO") {
                	if(grid.getCellValue(rowId, "APP_DOC_NO")=='') return;
                    param = {
                    		APP_DOC_NUM : grid.getCellValue(rowId, "APP_DOC_NO"),
                    		APP_DOC_CNT : grid.getCellValue(rowId, "APP_DOC_CNT"),
                        	detailView: true
                    };
                    everPopup.openPopupByScreenId("PO0211", 1000, 500, param);
                }
                else if(colIdx === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BOD1_042", 1100, 800, param);
                    }
                }
                else if(colIdx == "CPO_SEQ") {
                    param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ"),
                        detailView: true

                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                }
                else if (colIdx == "VENDOR_NM") {
                    param = {
                        callBackFunction: "callbackGridVENDOR_CD",
                        rowId: rowId
                    };
                    everPopup.openCommonPopup(param, "SP0063");
                }
                else if(colIdx == "DELY_REJECT_NM") {
                    var rejectCd = grid.getCellValue(rowId, 'DELY_REJECT_CD');
                    if( rejectCd == "" ) return;
                    param = {
                        title: '납품거부사유',
                        CODE: grid.getCellValue(rowId, 'DELY_REJECT_CD'),
                        TEXT: grid.getCellValue(rowId, 'DELY_REJECT_REASON'),
                        detailView: 'true'
                    };
                    var url = '/evermp/SIV1/SIV101/SIV1_023/view';
                    everPopup.openModalPopup(url, 600, 360, param);
                }
                else if(colIdx == 'ATT_FILE_NUM_IMG') {
                    everPopup.readOnlyFileAttachPopup('CPO',grid.getCellValue(rowId, 'ATT_FILE_NUM'),'',rowId);
                }
                else if(colIdx == 'RECIPIENT_NM') {
                    if( grid.getCellValue(rowId, 'RECIPIENT_NM') == '' ) return;
                    param = {
                        CPO_NO: grid.getCellValue(rowId, 'CPO_NO'),
                        CPO_SEQ: grid.getCellValue(rowId, 'CPO_SEQ'),
                        detailView: 'true'
                    };
                    everPopup.openPopupByScreenId("SIV1_026", 700, 450, param);
                }
                else if(colIdx == 'CHANGE_REMARK') {
                    if( grid.getCellValue(rowId, 'CHANGE_REMARK') == '' ) return;
                    param = {
                        title: "주문변경사유",
                        message: grid.getCellValue(rowId, "CHANGE_REMARK"),
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 320, param);
                }
                else if(colIdx == 'PO_CHANGE_REASON') {
                    if( grid.getCellValue(rowId, 'PO_CHANGE_REASON') == '' ) return;
                    param = {
                        title: "발주변경사유",
                        message: grid.getCellValue(rowId, "PO_CHANGE_REASON"),
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 320, param);
                }
                else if(colIdx == "DELY_NM") {
                    param = {
                        callBackFunction: "callbackGridDELY_NM",
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        rowIdx: rowId,
                        detailView: false
                    };
                    everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                }
                else if(colIdx == "DELY_ZIP_CD") {
                    param = {
                        callBackFunction : "callbackGridDELY_ZIP_CD",
                        modalYn : false
                    };
                    everPopup.jusoPop("/common/code/BADV_020/view", param);
                }
                else if(colIdx == "AM_USER_CHANGE_RMK_IMG") {
                    var AM_USER_CHANGE_RMK = grid.getCellValue(rowId, "AM_USER_CHANGE_RMK");
                    if( AM_USER_CHANGE_RMK == "" ) return;
                    param = {
                        title: "이관사유",
                        message: AM_USER_CHANGE_RMK,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                }
                else if(colIdx == "CONFIRM_REQ_RMK") {
                    var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
                    var detailView = true;

                    if(PROGRESS_CD == "30") {
                        detailView = false;
                    }

                    param = {
                        title: "변경사유",
                        message: value,
                        callbackFunction: "callbackGridCONFIRM_REQ_RMK",
                        detailView: detailView,
                        rowId: rowId
                    };

                    if(detailView) {
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    } else {
                        everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
                    }
                }
                else if(colIdx == "PO_CONFIRM_REJECT_RMK_IMG") {
                    var PO_CONFIRM_REJECT_RMK = grid.getCellValue(rowId, "PO_CONFIRM_REJECT_RMK");
                    if( PO_CONFIRM_REJECT_RMK == "" ) return;
                    param = {
                        title: "승인반려사유",
                        message: PO_CONFIRM_REJECT_RMK,
                        detailView: true
                    };
                    everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                }
                else if(colIdx == "AGENT_MEMO") {
                    var AGENT_MEMO = grid.getCellValue(rowId, "AGENT_MEMO");
                    param = {
                        title: "운영사 메모",
                        message: AGENT_MEMO,
                        callbackFunction: "callbackGridAGENT_MEMO",
                        rowId: rowId,
                        detailView: false
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
                }
                else if(colIdx == "REQ_TEXT") {
                	return;
                    if(value != "") {
                        param = {
                            title: "요청사항",
                            message: grid.getCellValue(rowId, "REQ_TEXT"),
                            callbackFunction: "callbackGridREQ_TEXT",
                            detailView: true,
                            rowId: rowId
                        };
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    }
                }
                else if(colIdx == "AM_USER_CHANGE_RMK") {
                    if(value != "") {
                        param = {
                            title: "이관사유",
                            message: grid.getCellValue(rowId, "AM_USER_CHANGE_RMK"),
                            callbackFunction: "callbackGridREQ_TEXT",
                            detailView: true,
                            rowId: rowId
                        };
                        everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
                    }
                }
                else if(colIdx == "ATTACH_FILE_CNT") {
                    if(value > 0) {
                        param = {
                            attFileNum: grid.getCellValue(rowId, "ATTACH_FILE_NO"),
                            rowId: rowId,
                            callBackFunction: "callbackGridATTACH_FILE_CNT",
                            havePermission: false,
                            bizType: "OM",
                            fileExtension: "*"
                        };
                        everPopup.openPopupByScreenId("commonFileAttach", 650, 310, param);
                    }
                }
                else if(colIdx == "AGENT_ATTACH_FILE_CNT") {
                    param = {
                        attFileNum: grid.getCellValue(rowId, "AGENT_ATTACH_FILE_NO"),
                        rowId: rowId,
                        callBackFunction: "callbackGridAGENT_ATTACH_FILE_CNT",
                        havePermission: true,
                        bizType: "OM",
                        fileExtension: "*"
                    };
                    everPopup.openPopupByScreenId("commonFileAttach", 650, 310, param);
                }
                else if(colIdx == "ACCOUNT_CD") {
                    var param = {
                        callBackFunction: "setGridAccountCd",
                        custCd: grid.getCellValue(rowId, "CUST_CD"),
                        rowId: rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0085');
                }
            });

            grid.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {
                if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "PO_UNIT_PRICE" || colIdx == "CPO_ITEM_AMT" || colIdx == "PO_ITEM_AMT" || colIdx == "DEAL_CD") {
                    if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "CPO_ITEM_AMT" ) {
                        if(grid.getCellValue(rowIdx, "BUDGET_USE_FLAG") == "1") {
                            alert("${PO0210_0026}");
                            grid.setCellValue(rowIdx, colIdx, oldValue);
                            return;
                        }
                    }
                    EXEC(rowIdx, colIdx);
                }
            });

            grid.excelExportEvent({
                allItems: "${excelExport.allCol}",
                fileName: "${screenName }"
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
            footerSum_PO = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['PO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

            footerSum_CPO = {
                "styles": {
                    "textAlignment": "far",
                    "suffix": " ",
                    "numberFormat": "###,###.##",
                    "background":"#ffffff",
                    "foreground":"#FF0000",
                    "fontBold": true
                },
                "text": '0 ',
                "expression": ["sum['CPO_ITEM_AMT']"],
                "groupExpression": "sum"
            };

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

            grid.setProperty('footerVisible', val);
            grid.setRowFooter('CPO_UNIT_PRICE', footerTxt);
            grid.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);
            grid.setRowFooter('PROFIT_RATE', footerRateZero);
            */

            grid.setColIconify("AM_USER_CHANGE_RMK_IMG", "AM_USER_CHANGE_RMK", "comment", false);
            // grid.setColIconify("CONFIRM_REQ_RMK_IMG", "CONFIRM_REQ_RMK", "comment", false);
            grid.setColIconify("PO_CONFIRM_REJECT_RMK_IMG", "PO_CONFIRM_REJECT_RMK", "comment", false);
//            grid.setColIconify("REQ_TEXT", "REQ_TEXT", "comment", false);

            grid.setColIconify("AM_USER_CHANGE_RMK", "AM_USER_CHANGE_RMK", "comment", false);
            grid.setColIconify("PO_CHANGE_REASON", "PO_CHANGE_REASON", "comment", false);

            grid._gvo.setHeader({height:36});
            doSearch();
        }

        function setGridAccountCd(data) {
            grid.setCellValue(data.rowId, 'ACCOUNT_CD', data.ACCOUNT_CD);
            grid.setCellValue(data.rowId, 'ACCOUNT_NM', data.ACCOUNT_NM);
        }

        function EXEC(rowIdx, colIdx) {
        	  grid.setCellValue(rowIdx, "CHANGE_YN", "Y");
            if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "PO_UNIT_PRICE") {
                var CPO_QTY = grid.getCellValue(rowIdx, "CPO_QTY");
                var CPO_UNIT_PRICE = grid.getCellValue(rowIdx, "CPO_UNIT_PRICE");
                var PO_UNIT_PRICE = grid.getCellValue(rowIdx, "PO_UNIT_PRICE");

                grid.setCellValue(rowIdx, "CPO_ITEM_AMT", CPO_QTY * CPO_UNIT_PRICE);
                grid.setCellValue(rowIdx, "HDN_CPO_ITEM_AMT", CPO_QTY * CPO_UNIT_PRICE);

                grid.setCellValue(rowIdx, "PO_ITEM_AMT", CPO_QTY * PO_UNIT_PRICE);
                grid.setCellValue(rowIdx, "HDN_PO_ITEM_AMT", CPO_QTY * PO_UNIT_PRICE);
            }

            var CPO_ITEM_AMT = grid.getCellValue(rowIdx, "CPO_ITEM_AMT");
            var PO_ITEM_AMT = grid.getCellValue(rowIdx, "PO_ITEM_AMT");

            grid.setCellValue(rowIdx, "HDN_CPO_ITEM_AMT", CPO_ITEM_AMT);
            grid.setCellValue(rowIdx, "HDN_PO_ITEM_AMT", PO_ITEM_AMT);


            var PROFIT_RATE;
            if(CPO_ITEM_AMT == "0" || PO_ITEM_AMT == "0") {
                PROFIT_RATE = 0;
            } else {
                PROFIT_RATE = everMath.round_float(((CPO_ITEM_AMT - PO_ITEM_AMT) / CPO_ITEM_AMT) * 100, 1);
            }

            grid.setCellValue(rowIdx, "PROFIT_RATE", PROFIT_RATE);

            grid.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);

            var CPO_ITEM_AMT_SUM = Number(grid._gvo.getSummary("CPO_ITEM_AMT", "SUM"));
            var PO_ITEM_AMT_SUM = Number(grid._gvo.getSummary("PO_ITEM_AMT", "SUM"));

            if(!EVF.isEmpty(CPO_ITEM_AMT_SUM) && CPO_ITEM_AMT_SUM > 0) {
                if(!EVF.isEmpty(PO_ITEM_AMT_SUM) && PO_ITEM_AMT_SUM > 0) {
                    var salesRate = everMath.round_float(((CPO_ITEM_AMT_SUM - PO_ITEM_AMT_SUM) / CPO_ITEM_AMT_SUM) * 100, 1);
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
                    grid.setRowFooter('PROFIT_RATE', footerRate);
                }
            }

            if(grid.getCellValue(rowIdx, "ORG_CPO_ITEM_AMT") != grid.getCellValue(rowIdx, "CPO_ITEM_AMT") ||
                grid.getCellValue(rowIdx, "ORG_PO_ITEM_AMT") != grid.getCellValue(rowIdx, "PO_ITEM_AMT")) {
                grid.setCellValue(rowIdx, "CHANGE_YN", "Y");
//                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", true);
            } else {
                grid.setCellValue(rowIdx, "CHANGE_YN", "N");
            }

            if(grid.getCellValue(rowIdx, "CHANGE_YN") == "Y" || grid.getCellValue(rowIdx, "CHANGE2_YN") == "Y") {
//                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", true);
            } else {
                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", false);
            }



        }

        function callbackGridCONFIRM_REQ_RMK(data) {
            grid.setCellValue(data.rowId, "CONFIRM_REQ_RMK", data.message);
        }

        function callBackCPO_USER_NM(data) {

            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {
                var rowId = allRowId[i];

                if(grid.getCellValue(rowId, "CPO_NO") == grid.getCellValue(ROW_IDX, "CPO_NO")) {
                    grid.setCellValue(rowId, "CPO_USER_ID", data.USER_ID);
                    grid.setCellValue(rowId, "CPO_USER_NM", data.USER_NM);
                    grid.setCellValue(rowId, "DEPT_CD", data.DEPT_CD);
                    grid.setCellValue(rowId, "DEPT_NM", data.DEPT_NM);
                    grid.setCellValue(rowId, "CPO_USER_TEL_NUM", data.TEL_NUM);
                    grid.setCellValue(rowId, "CPO_USER_CELL_NUM", data.CELL_NUM);
                }
            }
        }

        function callbackGridDELY_NM(data) {
            grid.setCellValue(ROW_IDX, "CSDM_SEQ", data.CSDM_SEQ);
            grid.setCellValue(ROW_IDX, "DELY_NM", data.DELY_NM);
            grid.setCellValue(ROW_IDX, "RECIPIENT_NM", data.HIDDEN_DELY_RECIPIENT_NM);
            grid.setCellValue(ROW_IDX, "RECIPIENT_TEL_NUM", data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
            grid.setCellValue(ROW_IDX, "RECIPIENT_CELL_NUM", data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
            grid.setCellValue(ROW_IDX, "RECIPIENT_EMAIL", data.HIDDEN_DELY_RECIPIENT_EMAIL);
            grid.setCellValue(ROW_IDX, "RECIPIENT_FAX_NUM", data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
            grid.setCellValue(ROW_IDX, "RECIPIENT_DEPT_NM", data.DELY_RECIPIENT_DEPT_NM);
            grid.setCellValue(ROW_IDX, "DELY_ZIP_CD", data.DELY_ZIP_CD);
            grid.setCellValue(ROW_IDX, "DELY_ADDR_1", data.DELY_ADDR_1);
            grid.setCellValue(ROW_IDX, "DELY_ADDR_2", data.DELY_ADDR_2);
        }

        function callbackGridDELY_ZIP_CD(data) {
            if (data.ZIP_CD != "") {
                grid.setCellValue(ROW_IDX, "DELY_ZIP_CD", data.ZIP_CD_5);
                grid.setCellValue(ROW_IDX, "DELY_ADDR_1", data.ADDR1);
                grid.setCellValue(ROW_IDX, "DELY_ADDR_2", data.ADDR2);
            }
        }

        function callbackGridITEM_CD(jsonData, rowIdx) {
            var idx = 0;

            grid.setCellValue(rowIdx, "ITEM_CD", jsonData[idx].ITEM_CD);
            grid.setCellValue(rowIdx, "ITEM_DESC", jsonData[idx].ITEM_DESC);
            grid.setCellValue(rowIdx, "ITEM_SPEC", jsonData[idx].ITEM_SPEC);
            grid.setCellValue(rowIdx, "MAKER_CD", jsonData[idx].MAKER_CD);
            grid.setCellValue(rowIdx, "MAKER_NM", jsonData[idx].MAKER_NM);
            grid.setCellValue(rowIdx, "MAKER_PART_NO", jsonData[idx].MAKER_PART_NO);
            grid.setCellValue(rowIdx, "BRAND_CD", jsonData[idx].BRAND_CD);
            grid.setCellValue(rowIdx, "BRAND_NM", jsonData[idx].BRAND_NM);
            grid.setCellValue(rowIdx, "ORIGIN_CD", jsonData[idx].ORIGIN_CD);
            grid.setCellValue(rowIdx, "ORIGIN_NM", jsonData[idx].ORIGIN_NM);
            grid.setCellValue(rowIdx, "UNIT_CD", jsonData[idx].UNIT_CD);

            doGetPrice(rowIdx);

            if(grid.getCellValue(rowIdx, "ORG_ITEM_CD") != grid.getCellValue(rowIdx, "ITEM_CD")) {
                grid.setCellValue(rowIdx, "CHANGE2_YN", "Y");
                //grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", true);
            } else {
                grid.setCellValue(rowIdx, "CHANGE2_YN", "N");
            }

            if(grid.getCellValue(rowIdx, "CHANGE_YN") == "Y" || grid.getCellValue(rowIdx, "CHANGE2_YN") == "Y") {
                //grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", true);
            } else {
                grid.setCellRequired(rowIdx, "CONFIRM_REQ_RMK", false);
            }
        }

        function doGetPrice(rowIdx) {
            var store = new EVF.Store();

            store.setParameter("BUYER_CD", grid.getCellValue(rowIdx, "CUST_CD"));
            store.setParameter("ITEM_CD", grid.getCellValue(rowIdx, "ITEM_CD"));

            store.load("/evermp/IM02/IM0201/im02011_doGetPrice", function() {
                grid.setCellValue(rowIdx, "PO_UNIT_PRICE", this.getParameter("CONT_UNIT_PRICE"));
                grid.setCellValue(rowIdx, "CPO_UNIT_PRICE", this.getParameter("UNIT_PRICE"));
                grid.setCellValue(rowIdx, "CUR", this.getParameter("CUR"));
                grid.setCellValue(rowIdx, "VENDOR_CD", this.getParameter("VENDOR_CD"));
                grid.setCellValue(rowIdx, "VENDOR_NM", this.getParameter("VENDOR_NM"));
                grid.setCellValue(rowIdx, "APPLY_COM", this.getParameter("APPLY_COM"));
                grid.setCellValue(rowIdx, "CONT_NO", this.getParameter("CONT_NO"));
                grid.setCellValue(rowIdx, "CONT_SEQ", this.getParameter("CONT_SEQ"));
                grid.setCellValue(rowIdx, "DEAL_CD", this.getParameter("DEAL_CD"));
                grid.setCellValue(rowIdx, "VENDOR_ITEM_CD", this.getParameter("VENDOR_ITEM_CD"));

                EXEC(rowIdx, "PO_UNIT_PRICE");
            });
        }

        function callbackGridAGENT_MEMO(data) {
            grid.setCellValue(data.rowId, "AGENT_MEMO", data.message);

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "od01001_doSaveAGENT_MEMO", function() {
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
            if( EVF.V("CUST_CD") == "" ) return alert("${PO0210_001}");
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
                alert("${PO0210_001}");
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
            var data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function searchCustUserId() {
            var custCd = EVF.V("CUST_CD");
            if( custCd == "" ) {
                alert("${PO0210_001}");
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

        function callbackGridVENDOR_CD(data) {
            grid.setCellValue(data.rowId, "VENDOR_CD", data.VENDOR_CD);
            grid.setCellValue(data.rowId, "VENDOR_NM", data.VENDOR_NM);
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("autoSearchFlag", autoSearchFlag);
            store.setParameter("callType", callType);
            store.load(baseUrl + "PO0210/doSearch", function () {
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
                grid.setRowFooter('PROFIT_RATE', footerRateZero);

                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                grid.setColIconify("AM_USER_CHANGE_RMK_IMG", "AM_USER_CHANGE_RMK", "comment", false);
                // grid.setColIconify("CONFIRM_REQ_RMK_IMG", "CONFIRM_REQ_RMK", "comment", false);
                grid.setColIconify("PO_CONFIRM_REJECT_RMK_IMG", "PO_CONFIRM_REJECT_RMK", "comment", false);
                //grid.setColIconify("DELY_DELAY_REASON", "DELY_DELAY_REASON", "comment", false);
                //grid.setColIconify("DELY_REJECT_REASON", "DELY_REJECT_REASON", "comment", false);
                //grid.setColIconify("CHANGE_REMARK", "CHANGE_REMARK", "comment", false);

                /*grid.setColMerge(['CUST_NM','DEPT_NM','CPO_USER_NM','CPO_NO','CPO_SEQ','CHANGE_STATUS_NM','CHANGE_REMARK','PROGRESS_NM',
				  'DEAL_NM','REF_MNG_NO','ITEM_CD','CUST_ITEM_CD','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM',
                  'ORIGIN_NM','UNIT_CD','CPO_QTY','CUR','CPO_UNIT_PRICE','CPO_ITEM_AMT','PO_UNIT_PRICE','PO_ITEM_AMT','TAX_NM','LEAD_TIME','CPO_DATE',
                  'HOPE_DUE_DATE','LEAD_TIME_DATE','RECIPIENT_NM','RECIPIENT_DEPT_NM','RECIPIENT_TEL_NUM','RECIPIENT_CELL_NUM','DELY_ZIP_CD','DELY_ADDR_1','DELY_ADDR_2']);
                grid.setColMerge(['SUP_INV_QTY','SUP_NOT_INV_QTY','SUP_NOT_GR_QTY','PO_NO','VENDOR_NM']);
                grid.setColMerge(['IV_NO','IV_SEQ','INV_QTY','DELY_APP_DATE','DELY_COMPLETE_DATE','DELY_COMPLETE_USER_NM','DELY_COMPANY_NM','WAYBILL_NO','DELY_REJECT_CD','DELY_REJECT_NM','DELY_REJECT_REASON','DELY_REJECT_DATE','DELY_DELAY_CD','DELY_DELAY_NM','DELY_DELAY_REASON']);
                grid.setColMerge(['GR_NO','GR_DATE','GR_USER_NM']);*/

                //grid.setColMerge(['CUST_CD','CUST_NM','DEPT_NM','CPO_USER_NM','BD_DEPT_NM','CPO_NO','CPO_SEQ','CHANGE_STATUS_NM','CHANGE_REMARK']);
                //grid.setColMerge(['PO_NO','VENDOR_NM']);
                //grid.setColMerge(['PROGRESS_CD','PROGRESS_NM','DEAL_NM','CUST_ITEM_CD','ITEM_CD','REF_MNG_NO','ITEM_DESC','ITEM_SPEC','MAKER_NM','MAKER_PART_NO','BRAND_NM','ORIGIN_CD','UNIT_CD','CPO_QTY','CUR','CPO_UNIT_PRICE','CPO_ITEM_AMT','PO_UNIT_PRICE','PO_ITEM_AMT','TAX_NM','LEAD_TIME','LEAD_TIME_DATE','HOPE_DUE_DATE','RECIPIENT_NM','RECIPIENT_DEPT_NM','RECIPIENT_TEL_NUM','RECIPIENT_CELL_NUM','DELY_ZIP_CD','DELY_ADDR_1','DELY_ADDR_2','SUP_INV_QTY','SUP_NOT_INV_QTY','SUP_GR_QTY','SUP_NOT_GR_QTY','GR_DATE','DELY_REJECT_NM','DELY_REJECT_REASON','DELY_REJECT_DATE','MANAGE_NM']);

                var cpoItemAmt = Number(grid._gvo.getSummary('CPO_ITEM_AMT', 'SUM'));
                var poItemAmt = Number(grid._gvo.getSummary('PO_ITEM_AMT', 'SUM'));

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
                        grid.setRowFooter('PROFIT_RATE', footerRate);
                    }
                }
                autoSearchFlag = "";
                callType = "";

                var rowIds = grid.getAllRowId();
                for(var i = 0; i < rowIds.length; i++) {
                    var selectedData = grid.getRowValue(rowIds[i]);
                    if(selectedData.PROGRESS_CD == '10' || selectedData.PROGRESS_CD == '20') {
                        grid._gvo.setCheckable(rowIds[i], false);
                    }

                    if(selectedData.IF_CPO_NO != "") {
                        //grid.setCellRequired(rowIds[i], "REQ_USER_NM", true);
                        //grid.setCellRequired(rowIds[i], "REQ_USER_TEL_NUM", true);
                    }
                    //인터페이스 데이타 붉은색 표시
                    grid.setCellFontColor(rowIds[i], 'IF_CPO_NO_SEQ', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_CPO_NO_SEQ', true);
                    grid.setCellFontColor(rowIds[i], 'IF_ITEM_CD', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_ITEM_CD', true);
                    grid.setCellFontColor(rowIds[i], 'IF_ITEM_DESC', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_ITEM_DESC', true);
                    grid.setCellFontColor(rowIds[i], 'IF_ITEM_SPEC', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_ITEM_SPEC', true);
                    grid.setCellFontColor(rowIds[i], 'IF_DELY_ADDR_1', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_DELY_ADDR_1', true);
                    grid.setCellFontColor(rowIds[i], 'IF_UNIT_CD', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_UNIT_CD', true);
                    grid.setCellFontColor(rowIds[i], 'IF_CPO_UNIT_PRICE', "#ff4c29");
                    grid.setCellFontWeight(rowIds[i], 'IF_CPO_UNIT_PRICE', true);

                    if(grid.getCellValue(rowIds[i], "CONFIRM_REQ_RMK") != "") {
//                        grid.setCellRequired(rowIds[i], "CONFIRM_REQ_RMK", true);
                    } else {
                        grid.setCellRequired(rowIds[i], "CONFIRM_REQ_RMK", false);
                    }
                }
            });
        }

        function doReqConfirm() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            CONFIRM_POP_YN = "N";

            var confirmReqRmk = "";
            var rowIds = grid.getSelRowId();
            var vendorIFList = JSON.parse('${vendorIFList}');
            var checkYN = "N";

            for(var i in rowIds) {
                /*
                if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0210_0008}");
                }
                */
                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") != "30") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0210_006}");
                }

                if(grid.getCellValue(rowIds[i], "CPO_UNIT_PRICE") == 0 || grid.getCellValue(rowIds[i], "CPO_ITEM_AMT") == 0 ||
                    grid.getCellValue(rowIds[i], "PO_UNIT_PRICE") == 0 || grid.getCellValue(rowIds[i], "PO_ITEM_AMT") == 0) {
                    return alert("${PO0210_0025}");
                }

                for(var j in vendorIFList) {
                    if(grid.getCellValue(rowIds[i], "VENDOR_CD") == vendorIFList[j].value &&
                        grid.getCellValue(rowIds[i], "VENDOR_ITEM_CD") == "") {
                        checkYN = "Y";
                    }
                }
            }

            if(checkYN == "Y") {
                if(!confirm('${PO0210_0027}')) { return; }
            } else {
                if(!confirm('${PO0210_0013}')) { return; }
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.setParameter("PROGRESS_CD", "36");
            store.load(baseUrl + "od01001_doReqConfirm", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doPoConfirm() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                /*
                if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0210_0008}");
                }
                */
            	if(grid.getCellValue(rowIds[i], "CHANGE_YN") == 'Y'){
            		if(!confirm('${PO0210_0047}')) { return; };
                }

            	if(grid.getCellValue(rowIds[i], "PROGRESS_CD") != "5100") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0210_0029}");
                }

            	if(grid.getCellValue(rowIds[i], "SIGN_STATUS") == "P") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0210_0044}");
                }
            }

            if(!confirm('${PO0210_0031}')) { return; }
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", '6100'); // 협력사 전송
            store.load(baseUrl + 'PO0210_doPoConfirm', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doPoConfirmReject() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                /*
                if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0210_0008}");
                }
                */

                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "5100") { // 접수완료 상태일때만 이관 가능
                    return alert("${PO0210_0006}");
                }
            	if(grid.getCellValue(rowIds[i], "SIGN_STATUS") == "P") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0210_0045}");
                }
            }

            if(!confirm('${PO0210_0019}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", '2100'); // 접수대기로 돌림
            store.load(baseUrl + 'PO0210_doPoConfirm', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
			return;





            var confirmRejectRmk = "";
            for(var i in rowIds) {
                confirmRejectRmk = grid.getCellValue(rowIds[i], 'PO_CONFIRM_REJECT_RMK');
            }

            if(!confirm('${PO0210_0019}')) { return; }

            var param = {
                title: "${PO0210_0020}",
                message: confirmRejectRmk,
                callbackFunction: 'setConfirmRejectRMK',
                detailView: false,
                rowId: 0
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function setConfirmRejectRMK(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${PO0210_0021}");
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", '1200'); //구매반려
            store.setParameter("PO_CONFIRM_REJECT_RMK", data.message);
            store.load(baseUrl + 'od01001_doPoConfirmReject', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doSave() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var confirmReqRmk = "";
            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                if(grid.getCellValue(rowIdx, "PROGRESS_CD") != "30") {
                    return alert("${PO0210_006}");
                }
            }

            if(!confirm("${PO0210_0024}")) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + 'od01001_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doChangeOrder() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            var rowIds = grid.getSelRowId();
            for(var i = 0; i < rowIds.length; i++) {
                var selectedData = grid.getRowValue(rowIds[i]);
                if(selectedData.PROGRESS_CD == '10' || selectedData.PROGRESS_CD == '20' || selectedData.PROGRESS_CD == '35') {
                    return alert("${PO0210_0006}"); // 진행상태를 확인하여 주시기 바랍니다.
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

        function doCancle() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoNo = "";
            var rows  = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].PROGRESS_CD !== "30") {
                    return alert("${PO0210_006}");
                }
                if( cpoNo != "" && cpoNo != rows[i].CPO_NO ){
                    return alert("${PO0210_009}");
                }
                cpoNo = rows[i].CPO_NO;
            }

            if(!confirm("${PO0210_007}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load("/evermp/BOD1/BOD104/" + "bod1040_doCancel", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
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

        function doTransferCtrl() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(EVF.isEmpty(EVF.C("sAM_USER_ID").getValue())) { return alert("${PO0210_0007}"); }

            var changeRmk = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                /*
                if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0210_0008}");
                }
                */

                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "5100") { // 접수완료 상태일때만 이관 가능
                    return alert("${PO0210_0006}");
                }
                changeRmk = grid.getCellValue(rowIds[i], 'AM_USER_CHANGE_RMK');
            }

            if(!confirm('${PO0210_0009}')) { return; }

            var param = {
                title: "${PO0210_0010}",
                message: changeRmk,
                callbackFunction: 'setAmChangeRMK',
                rowId: 0
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        }

        function setAmChangeRMK(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${PO0210_0011}");
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("sAM_USER_ID", EVF.C("sAM_USER_ID").getValue());
            store.setParameter("AM_USER_CHANGE_RMK", data.message);
            store.load(baseUrl + 'od01001_doTransferCtrl', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doCopyAll() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var selRowId = grid.getSelRowId();

            for(var i in selRowId) {
                var rowIdx = selRowId[i];

                grid.setCellValue(rowIdx, "DELY_PLACE", EVF.V("S_DELY_PLACE"));
                grid.setCellValue(rowIdx, "DELY_TYPE", EVF.V("S_DELY_TYPE"));
            }

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

		function doUpoModify() {
            var store = new EVF.Store();
            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }
            if (!grid.validate().flag) {
                return alert(grid.validate().msg);
            }

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                var signStatus = grid.getCellValue(rowIdx,'SIGN_STATUS');
                if(signStatus=='P') {
                	return alert('${PO0210_0043}');
                }
            }

            if (!confirm("${PO0210_0042}")) return;




            var param = {
                    title: "발주변경사유",
                    message: '',
                    callbackFunction: 'setChangePoRMK'
                };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
		}

		function setChangePoRMK(data) {
            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                var rowIdx = selRowId[i];
                grid.setCellValue(rowIdx,'PO_CHANGE_REASON',data.message);
            }
            var param = {
                    subject: "발주정보 수정",
                    docType: "POCH",
                    signStatus: "P",
                    screenId: "PO0210",
                    approvalType: 'APPROVAL',
                    attFileNum: "",
                    docNum: '',
                    callBackFunction: "goApproval"
                };
            everPopup.openApprovalRequestIIPopup(param);
		}



        function goApproval(formData, gridData, attachData) {
            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("signStatus", 'P');
            store.load(baseUrl + 'PO0210_poItemChange', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="PO0210" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
	                <e:inputHidden id="approvalFormData" name="approvalFormData" />
	                <e:inputHidden id="approvalGridData" name="approvalGridData" />
	                <e:inputHidden id="attachFileDatas" name="attachFileDatas" />
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
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${PO0210_0001}" value="CPO_DATE"/>
                        <e:option text="${PO0210_0002}" value="HOPE_DUE_DATE"/>
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
					<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD"/>
                </e:field>
				<e:label for="DEAL_CD" title="${form_DEAL_CD_N}"/>
				<e:field>
					<e:select id="DEAL_CD" name="DEAL_CD" value="" options="${dealCdOptions}" width="${form_DEAL_CD_W}" disabled="${form_DEAL_CD_D}" readOnly="${form_DEAL_CD_RO}" required="${form_DEAL_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="S_DELY_TYPE" title="${form_S_DELY_TYPE_N}"/>
				<e:field>
					<e:select id="S_DELY_TYPE" name="S_DELY_TYPE" value="" options="${sDelyTypeOptions}" width="${form_S_DELY_TYPE_W}" disabled="${form_S_DELY_TYPE_D}" readOnly="${form_S_DELY_TYPE_RO}" required="${form_S_DELY_TYPE_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <%--
            <e:text style="font-weight: bold;">●&nbsp;${form_AM_USER_NM_N} &nbsp;:&nbsp; </e:text>
            <e:select id="sAM_USER_ID" name="sAM_USER_ID" value="" options="${amUserIdOptions }" width="120px" disabled="${form_sAM_USER_ID_D}" readOnly="${form_sAM_USER_ID_RO}" required="${form_sAM_USER_ID_R}" placeHolder="" />
            <e:button id="TransferCtrl" name="TransferCtrl" label="${TransferCtrl_N }" disabled="${TransferCtrl_D }" visible="${TransferCtrl_V}" style="padding-left:3px;" align="left" onClick="doTransferCtrl" width="100px"/>
            --%>

            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doUpoModify" name="doUpoModify" label="${doUpoModify_N}" onClick="doUpoModify" disabled="${doUpoModify_D}" visible="${doUpoModify_V}"/>



            <e:button id="doPoConfirm" name="doPoConfirm" label="${doPoConfirm_N}" onClick="doPoConfirm" disabled="${doPoConfirm_D}" visible="${doPoConfirm_V}"/>
            <e:button id="doPoConfirmReject" name="doPoConfirmReject" label="${doPoConfirmReject_N}" onClick="doPoConfirmReject" disabled="${doPoConfirmReject_D}" visible="${doPoConfirmReject_V}"/>

        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>