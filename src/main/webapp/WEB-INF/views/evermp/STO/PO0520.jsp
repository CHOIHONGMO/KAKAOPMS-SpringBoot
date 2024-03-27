<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl ="/evermp/STO/PO0520/";
        var autoSearchFlag = '${form.autoSearchFlag}';
        var callType = '${form.callType}';
        var ROW_IDX;
        var footerSum_PO;
        var footerSum_CPO;
        var CONFIRM_POP_YN = "N";
        function init() {
            grid = EVF.C("grid");
            grid.setProperty('multiSelect', true);
            //grid.setProperty('sortable', false);
            grid.freezeCol("FORCE_CLOSE_DATE_FLAG");
            EVF.C('DEAL_CD').setValue("100");
            <c:if test = "${form.TYPE == 'A'}">
            EVF.C('DEAL_CD').setValue("400");
            </c:if>

            //W100 권한 가진 계정이 재고발주처리 눌렀을떄 버튼숨김 [관리자 제외]
            <c:if test = "${form.TYPE == null && havePermission == 'true' && ses.superUserFlag != '1'}">
	            formUtil.setVisible(['doPoConfirm'], false);
	            formUtil.setVisible(['doPoCancel'] , false);
	            formUtil.setVisible(['doPoClose']  , false);
            </c:if>
            EVF.C("PR_TYPE").removeOption("R");
            EVF.C('DEAL_CD').setDisabled(true);
        /*     EVF.C('AM_USER_ID').setDisabled(true); */


            grid.cellClickEvent(function(rowId, colIdx, value) {
                var param;

                ROW_IDX = rowId;

                // 주문자
                if(colIdx == 'CPO_USER_NM') {
                    if( grid.getCellValue(rowId, 'CPO_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_TYPE: grid.getCellValue(rowId, "USER_TYPE"),
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: true
                    };

                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }else if(colIdx == "ITEM_CD") {
                    var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'popupFlag': true,
                            'detailView': false
                        };
                             everPopup.im03_014open(param);
    		    }else if(colIdx === "CPO_NO") {
                    if(value !== ""){
                        param = {
                            callbackFunction: "",
                            CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                            CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                        };
                        everPopup.openPopupByScreenId("BOD1_041", 1100, 800, param);
                    }
                } else if (colIdx == "VENDOR_NM") {
                	var param = {
                            VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                            detailView: true,
                            popupFlag: true
                        };
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                } else if(colIdx == 'AM_USER_NM') {
                    if( grid.getCellValue(rowId, 'AM_USER_ID') == '' ) return;
                    param = {
                        callbackFunction: "",
                        USER_TYPE: 'C',  // C:운영사, B:고객사, S:공급사
                        USER_ID: grid.getCellValue(rowId, 'AM_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                } else if(colIdx == "RECIPIENT_NM") { // 인수자
                    if( grid.getCellValue(rowId, "RECIPIENT_NM") == "" ) return;
                    var param = {
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ"),
                        detailView: "true"
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param);
                } else if(colIdx == "REQ_TEXT") {
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
                   }else if(colIdx == "DELY_NM") {
                          param = {
                              callBackFunction: "callbackGridDELY_NM",
                              CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                              rowIdx: rowId,
                              detailView: false
                        };
                        everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                    }else if(colIdx == "AM_USER_CHANGE_RMK") {
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
            });

            grid.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {
                if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "PO_UNIT_PRICE" || colIdx == "CPO_ITEM_AMT" || colIdx == "PO_ITEM_AMT") {
                    if(colIdx == "CPO_QTY" || colIdx == "CPO_UNIT_PRICE" || colIdx == "CPO_ITEM_AMT") {
                        if(grid.getCellValue(rowIdx, "BUDGET_USE_FLAG") == "1") {
                            alert("${PO0520_0026}");
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
            var footerSum_QTY = {
                     "styles": {
                        "textAlignment": "far",
                        "suffix": " ",
                        "numberFormat": "###,###.##",
                        "background":"#ffffff",
                        "foreground":"#FF0000",
                        "fontBold": true
                    },
                    "text": '0 ',
                    "expression": ["sum['CPO_QTY']"],
                    "groupExpression": "sum"
                };
            var footerTxt2 = {
                    "styles": {
                        "textAlignment": "far",
                        "font": "굴림,12",
                        "background":"#ffffff",
                        "foreground":"#FF0000",
                        "fontBold": true
                    },
                    "text": ["수량 합계 "]
                };

            grid.setProperty('footerVisible', val);
            grid.setRowFooter('UNIT_CD', footerTxt2);
            grid.setRowFooter('CPO_QTY', footerSum_QTY);
            grid.setRowFooter('CPO_UNIT_PRICE', footerTxt);
            grid.setRowFooter("CPO_ITEM_AMT", footerSum_CPO);
            grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);
            grid.setRowFooter('PROFIT_RATE', footerRateZero);

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

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
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
            chgCustCd();
        }

        function searchCustDeptCd() {
            var custCd = EVF.V("CUST_CD");
            var custNm = EVF.V("CUST_NM");

            if( custCd == "" ) {
                alert("${PO0520_001}");
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
                alert("${PO0520_001}");
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
		//조회
        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.setParameter("autoSearchFlag", autoSearchFlag);
            store.setParameter("callType", callType);
            store.load(baseUrl + "PO0520_doSearch", function () {
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
                grid.setColIconify("PO_CONFIRM_REJECT_RMK_IMG", "PO_CONFIRM_REJECT_RMK", "comment", false);

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
                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6100") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#bae3ff");
                    }

                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6120") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#ffaed3");
                    }

                    if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6300") {
                        grid.setCellBgColor(rowIds[i], "PROGRESS_NM", "#abffaf");
                    }

                    if(selectedData.IF_CPO_NO != "") {
                        grid.setCellRequired(rowIds[i], "REQ_USER_NM", true);
                        grid.setCellRequired(rowIds[i], "REQ_USER_TEL_NUM", true);
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
		//발주확정
        function doPoConfirm() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if( grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE') == '' ) {
                   return alert("${PO0520_1111}");
                }
            /* 	if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0520_0008}");
                } */

            	if(grid.getCellValue(rowIds[i], "PROGRESS_CD") != "5100") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0520_0029}");
                }

            	if(grid.getCellValue(rowIds[i], "SIGN_STATUS") == "P") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0520_0044}");
                }
            }

            if(!confirm('${PO0520_0031}')) { return; }
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", '6100'); // 협력사 전송
            store.load(baseUrl + 'PO0520_doPoConfirm', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function setConfirmRejectRMK(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${PO0520_0021}");
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
		//발주취소
        function doPoCancel() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
         /*    	if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0520_0008}");
                }
 */
            	if(grid.getCellValue(rowIds[i], 'CPO_QTY') == grid.getCellValue(rowIds[i], 'INV_QTY')) {
	                return alert("${PO0240_0035}");
	            }

                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6100") {
                    return alert("${PO0520_0006}");
                }

                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6120") {
                    return alert("${PO0520_0006}");
                }

                if(grid.getCellValue(rowIds[i], "PROGRESS_CD") == "6300") {
                    return alert("${PO0520_0006}");
                }

            	if(grid.getCellValue(rowIds[i], "SIGN_STATUS") == "P") {
                    grid.checkRow(rowIds[i], false);
                    return alert("${PO0520_0045}");
                }
            }

            if(!confirm('${PO0520_0019}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("PROGRESS_CD", '2100'); // 접수대기로 돌림
            store.load(baseUrl + 'PO0520_doPoConfirm', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
			return;

            var confirmRejectRmk = "";
            for(var i in rowIds) {
                confirmRejectRmk = grid.getCellValue(rowIds[i], 'PO_CONFIRM_REJECT_RMK');
            }

            if(!confirm('${PO0520_0019}')) { return; }

            var param = {
                title: "${PO0520_0020}",
                message: confirmRejectRmk,
                callbackFunction: 'setConfirmRejectRMK',
                detailView: false,
                rowId: 0
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
		}
		//담당자이관
        function doTransferCtrl() {
            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if(EVF.isEmpty(EVF.C("sAM_USER_ID").getValue())) { return alert("${PO0520_0007}"); }

            var changeRmk = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {

            /* 	if(grid.getCellValue(rowIds[i], 'AM_USER_ID') !=''  && grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
                    return alert("${PO0520_0008}");
                } */

                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') != "5100") { // 접수완료 상태일때만 이관 가능
                    return alert("${PO0520_0006}");
                }
                changeRmk = grid.getCellValue(rowIds[i], 'AM_USER_CHANGE_RMK');
            }

            if(!confirm('${PO0520_0009}')) { return; }
            if(grid.getCellValue(rowIds[i], 'AM_USER_ID')=='') {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.setParameter("sAM_USER_ID", EVF.C("sAM_USER_ID").getValue());
                store.setParameter("AM_USER_CHANGE_RMK", data.message);
                store.load(baseUrl + 'po0520_doTransferCtrl', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
            }else {

            var param = {
                title: "${PO0520_0010}",
                message: changeRmk,
                callbackFunction: 'setAmChangeRMK',
                rowId: 0
            };
            var url = '/common/popup/common_text_input/view';
            everPopup.openModalPopup(url, 500, 320, param);
        	}
		}
        function setAmChangeRMK(data) {

            if(EVF.isEmpty(data.message)) {
                return alert("${PO0520_0011}");
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.setParameter("sAM_USER_ID", EVF.C("sAM_USER_ID").getValue());
            store.setParameter("AM_USER_CHANGE_RMK", data.message);
            store.load(baseUrl + 'po0520_doTransferCtrl', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }
        //발주종결
        function doPoClose() {
			 if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	            var rowIds = grid.getSelRowId();
	            for(var i in rowIds) {
	            	/* if(grid.getCellValue(rowIds[i], 'AM_USER_ID') != "${ses.userId}" && '${ses.ctrlCd}'.indexOf('M100') < 0) {
	                    return alert("${PO0520_0008}");
	                } */
	                if(grid.getCellValue(rowIds[i], 'PO_DATE') == null || grid.getCellValue(rowIds[i], 'PO_DATE') == '') {
	                    return alert("${PO0520_0047}");
	                }

	                if(grid.getCellValue(rowIds[i], 'FORCE_CLOSE_DATE') != "") {
	                    return alert("${PO0520_0046}");
	                }
	                if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') == "6100") {
	                    return alert("${PO0520_0050}");
	                }
	            }

	            if(!confirm("${PO0520_0049}")) { return; }
	            var store = new EVF.Store();
	            store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.load(baseUrl + 'po0520_doPoClose', function() {
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



    </script>

    <e:window id="PO0520" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="CPO_NO" title="${form_CPO_NO_N}" />
                <e:field>
                    <e:inputText id="CPO_NO" name="CPO_NO" value="${form.CPO_NO}" width="40%" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="50%" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
                </e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
                <e:label for="CPO_USER_NM" title="${form_CPO_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="${form_CPO_USER_NM_W}" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
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
                <e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
                <e:field>
                    <e:select id="AM_USER_ID" name="AM_USER_ID" value="${ses.userId}" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder=""/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${PO0520_0111}" value="CPO_DATE"/>
                        <e:option text="${PO0520_0048}" value="PO_DATE"/>
                        <e:option text="${PO0520_0222}" value="HOPE_DUE_DATE"/>
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
        	<%-- 담당자 --%>
            <e:text style="font-weight: bold;">●&nbsp;${form_AM_USER_NM_N} &nbsp;:&nbsp; </e:text>
            <e:select id="sAM_USER_ID" name="sAM_USER_ID" value="" options="${amUserIdOptions }" width="120px" disabled="${form_sAM_USER_ID_D}" readOnly="${form_sAM_USER_ID_RO}" required="${form_sAM_USER_ID_R}" placeHolder="" />
            <e:button id="TransferCtrl" name="TransferCtrl" label="${TransferCtrl_N }" disabled="${TransferCtrl_D }" visible="${TransferCtrl_V}" style="padding-left:3px;" align="left" onClick="doTransferCtrl" width="100px"/>
			<e:button id="doPoClose" name="doPoClose" label="${doPoClose_N}" onClick="doPoClose" disabled="${doPoClose_D}" visible="${doPoClose_V}" align="left"/>

            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            <e:button id="doPoConfirm" name="doPoConfirm" label="${doPoConfirm_N}" onClick="doPoConfirm" disabled="${doPoConfirm_D}" visible="${doPoConfirm_V}"/>
   			<e:button id="doPoCancel" name="doPoCancel" label="${doPoCancel_N}" onClick="doPoCancel" disabled="${doPoCancel_D}" visible="${doPoCancel_V}"/>

        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>