<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var gridR; var gridC; var gridV; var gridCU;
        var baseUrl = "/evermp/RQ01/RQ0102/";
        var signStatus;
        var eventRowId;

        function init() {

        	// 상세보기 팝업에서 파일첨부 버튼 inVisible 처리
        	if('${param.detailView}' == 'true') {
        		$('#upload-button-ATT_FILE_NUM').css('display','none');
        	}

            gridR = EVF.C("gridR");
            gridC = EVF.C("gridC");
            /**
             * 2022.09.22 고객사 최근 1년 실적 제외
            gridCU = EVF.C("gridCU");
            */

            gridR.setColGroup([{
                groupName: "최초",
                columns: [ "ITEM_SPEC", "MAKER_NM"]
            }, {
                groupName: "최종",
                columns: [ "ITEM_SPEC_AFTER", "MAKER_NM_AFTER"]
        	}], 45);


            // 동일 공급사 재계약
            if(EVF.C("RFQ_TYPE").getValue() == "200") { gridV = EVF.C("gridV"); }

            gridR.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                eventRowId = rowId;

                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': gridR.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'LEADTIME_RMK_IMG') {
                    if(!EVF.isEmpty(gridR.getCellValue(rowId, 'LEADTIME_RMK'))) {
                        var param = {
                            title: "표준납기사유",
                            message: gridR.getCellValue(rowId, 'LEADTIME_RMK'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'QTA_REMARK_IMG') {
                    if(!EVF.isEmpty(gridR.getCellValue(rowId, 'QTA_REMARK'))) {
                        var param = {
                            title: "공급사 특이사항",
                            message: gridR.getCellValue(rowId, 'QTA_REMARK'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == 'SETTLE_RMK_IMG') {
                    if(!EVF.isEmpty(gridR.getCellValue(rowId, 'SETTLE_RMK'))) {
                        var param = {
                            title: "공급사 선정사유",
                            message: gridR.getCellValue(rowId, 'SETTLE_RMK'),
                            callbackFunction: '',
                            rowId: rowId
                        };
                        var url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                /**
                 * 단가적용 고객사코드는 기존의 popup => Combo로 변경 (공통(*), 사업장(요청사업장))
                if(colId == 'APPLY_TARGET') {
                     var param = {
                        CUST_CD_LIST: gridR.getCellValue(rowId, 'APPLY_TARGET_CD'),
                        callBackFunction: 'setApplyInfo',
                        callType : 'Multi',
                        'detailView': ${param.detailView}
                    };
                    everPopup.im03_013open(param);
              	}*/
                if(colId == 'VENDOR_NM') {
                    var param = {
                        'VENDOR_CD': gridR.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
                if(colId == 'CUST_NM') {
                    var param = {
                        'CUST_CD': gridR.getCellValue(rowId, 'CUST_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
                if(colId == 'DEPT_NM') {

                    if(gridR.getCellValue(rowId, 'DEPT_PRICE_FLAG') == "0") {
                        return alert("${RQ01_023_015}");
                    }
                    var param = {
                        callBackFunction: "setGridDeptCd",
                        CUST_CD: gridR.getCellValue(rowId, 'CUST_CD')
                    };
                    everPopup.openCommonPopup(param, 'SP0084');
                }
                if(colId == 'QTA_FILE_CNT') {
                    if(Number(gridR.getCellValue(rowId, "QTA_FILE_CNT")) > 0) {
                        var param = {
                            havePermission: false,
                            attFileNum: gridR.getCellValue(rowId, 'QTA_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '',
                            bizType: 'QTA',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                }
                if(colId == "CUST_RQ_RMK") {
                    var param = {
                        title: "고객사 전달사항",
                        message: gridR.getCellValue(rowId, 'CUST_RQ_RMK'),
                        callbackFunction: 'setCustRoRmk',
                        detailView: ${param.detailView},
                        rowId: rowId
                    };

                    let url = "";
                    if (${param.detailView}) {
                        url = '/common/popup/common_text_view/view';
                        everPopup.openModalPopup(url, 500, 300, param);
                    } else {
                        url = '/common/popup/common_text_input/view';
                        everPopup.openModalPopup(url, 500, 320, param);
                    }
                }
                if(colId == "ITEM_CLS_PATH_NM") {
                	_getItemClsNmCust(rowId);
                }
            });

            gridR.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

                gridR.checkRow(rowId, true);
                <%-- SALES_UNIT_PRC [고객사 판매단가], SALES_PROFIT_RATE [이익율(%)] --%>

                var contUnitPrc = Number(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE'));
                var salesProfitRate = Number(gridR.getCellValue(rowId, 'SALES_PROFIT_RATE'));
                var qty = Number(gridR.getCellValue(rowId, 'QTY')); // 수량
                var truncType = Number(gridR.getCellValue(rowId, 'TRUNC_TYPE')); // 전사기준

                if (colId == "SALES_UNIT_PRC")
                {
                    var contUnitPrc = Number(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE')); // 계약단가
                    var salesUnitPrc = Number(gridR.getCellValue(rowId, 'SALES_UNIT_PRC')); // 고객사 판매단가
                    var qty = Number(gridR.getCellValue(rowId, 'QTY')); // 수량
                    if(!EVF.isEmpty(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE')) && contUnitPrc > 0) {
                        if(!EVF.isEmpty(gridR.getCellValue(rowId, 'SALES_UNIT_PRC')) && salesUnitPrc > 0) {
                            // 이익율 = ((매출-매입) / 매출) * 100
                            // var salesProfitRate = everMath.round_float(((salesUnitPrc - contUnitPrc) / contUnitPrc) * 100, 1);
                            var salesProfitRate = everMath.round_float(((salesUnitPrc - contUnitPrc) / salesUnitPrc) * 100, 1);
                            gridR.setCellValue(rowId, 'SALES_PROFIT_RATE', salesProfitRate);
                        }
                        gridR.setCellValue(rowId, 'SALES_AMT_PRC', truncValidate(salesUnitPrc*qty,truncType));
                    }
                }
                if (colId == "SALES_PROFIT_RATE")
                {
                    if(!EVF.isEmpty(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE')) && contUnitPrc > 0) {
                        if(!EVF.isEmpty(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE')) && contUnitPrc > 0) {
	                        if(!EVF.isEmpty(gridR.getCellValue(rowId, 'QTY')) && qty > 0) {
	                            //var salesUnitPrc = everMath.round_float((((salesProfitRate * 0.01) * contUnitPrc) + contUnitPrc) / 100) * 100;
	                            //var salesUnitPrc = everMath.round_float(contUnitPrc / (1 - (salesProfitRate / 100)) / 100) * 100;
	                            //gridR.setCellValue(rowId, 'SALES_UNIT_PRC', salesUnitPrc);

	                            var SALES_UNIT_PRC = contUnitPrc +  salesUnitPrc*salesProfitRate/100;
	                            gridR.setCellValue(rowId, 'SALES_UNIT_PRC', SALES_UNIT_PRC);
	                            gridR.setCellValue(rowId, 'SALES_AMT_PRC',  truncValidate(SALES_UNIT_PRC * qty ,truncType));
	                        }
                        }
                    }
                }
                <%-- 계약단가 --%>
                if (colId == "CONT_UNIT_PRICE")
                {
                    var contUnitPrc = Number(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE'));
                    var qty = Number(gridR.getCellValue(rowId, 'QTY')); // 수량
                    var profitRatio = Number(gridR.getCellValue(rowId, 'PROFIT_RATIO')); // 판가점율
                    if(!EVF.isEmpty(gridR.getCellValue(rowId, 'CONT_UNIT_PRICE')) && contUnitPrc > 0) {
                    	salesUnitPrc=contUnitPrc+(contUnitPrc*(profitRatio/100))
                        gridR.setCellValue(rowId, 'SALES_UNIT_PRC', salesUnitPrc);

                        if(!EVF.isEmpty(gridR.getCellValue(rowId, 'SALES_UNIT_PRC')) && salesUnitPrc > 0) {
                            var salesProfitRate = everMath.round_float(((salesUnitPrc - contUnitPrc) / salesUnitPrc) * 100, 1);
                            gridR.setCellValue(rowId, 'SALES_PROFIT_RATE', salesProfitRate);

                        }

                        gridR.setCellValue(rowId, 'CONT_AMT_PRICE', contUnitPrc * qty);
                    }
                }
            });

            gridC.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId === "ITEM_REQ_NO") {
                    var param = {
                        CUST_CD: gridC.getCellValue(rowId, "CUST_CD"),
                        ITEM_REQ_NO: gridC.getCellValue(rowId, "ITEM_REQ_NO"),
                        ITEM_REQ_SEQ: gridC.getCellValue(rowId, "ITEM_REQ_SEQ"),
                        detailView: true,
                        popupFlag: true
                    };
                    everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
                }
                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': gridC.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'CUST_NM') {
                    var param = {
                        'CUST_CD': gridC.getCellValue(rowId, 'CUST_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
                if(colId == 'REQUEST_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: gridC.getCellValue(rowId, 'REG_USER_ID'),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            // 기존 공급사 재계약(200)
            if(EVF.C("RFQ_TYPE").getValue() == "200") {
                gridV.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

                    if(colId == 'ITEM_CD') {
                        var param = {
                            'ITEM_CD': gridV.getCellValue(rowId, 'ITEM_CD'),
                            'detailView': true,
                            'popupYn': "Y"
                        };
                        everPopup.im03_009open(param);
                    }
                    if (colId == "VENDOR_NM") {
                        var param = {
                            'VENDOR_CD': gridV.getCellValue(rowId, 'VENDOR_CD'),
                            'detailView': false,
                            'popupFlag': true
                        };
                        everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                    }
                });
            }

            /**
             * 2022.09.22 고객사 최근 1년 실적 제외
			gridCU.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': gridCU.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'CUST_NM') {
                    var param = {
                        'CUST_CD': gridCU.getCellValue(rowId, 'CUST_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
                }
            });*/

            gridR.setProperty('multiSelect', false);
            gridC.setProperty('multiSelect', false);
            //gridCU.setProperty('multiSelect', false);
            if(EVF.C("RFQ_TYPE").getValue() == "200") { gridV.setProperty('multiSelect', false); }

            gridC.setProperty('shrinkToFit', true);
            //gridCU.setProperty('shrinkToFit', true);
            if(EVF.C("RFQ_TYPE").getValue() == "200") { gridV.setProperty('shrinkToFit', true/false); }

            gridR.setColIconify("LEADTIME_RMK_IMG", "LEADTIME_RMK", "comment", false);
            gridR.setColIconify("QTA_REMARK_IMG", "QTA_REMARK", "comment", false);
            gridR.setColIconify("SETTLE_RMK_IMG", "SETTLE_RMK", "comment", false);
            gridR.setColIconify("CUST_RQ_RMK", "CUST_RQ_RMK", "comment", false);

            gridR.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridC.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            /**
             * 2022.09.22 고객사 최근 1년 실적 제외
            gridCU.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });*/

         	// 기존 공급사 재계약(200)
            if(EVF.C("RFQ_TYPE").getValue() == "200") {
                gridV.excelExportEvent({
                    allItems : "${excelExport.allCol}",
                    fileName : "${screenName }"
                });
            }

            /**
             * 2022.09.22 고객사 최근 1년 실적 제외
            var valCU = {visible: true, count: 1, height: 30};
            var footerTxtCU = {
                styles: {
                    textAlignment: "center",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#000000",
                    fontBold: true
                },
                text: ["합 계"],
            };
            var footerSumCU = {
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
            gridCU.setProperty("footerVisible", valCU);
            gridCU.setRowFooter("DEPT_NM", footerTxtCU);
            gridCU.setRowFooter("SALES_QT", footerSumCU);
            gridCU.setRowFooter("SALES_AMT", footerSumCU);*/

            if(EVF.C("RFQ_TYPE").getValue() == "200") {
                var valV = {visible: true, count: 1, height: 30};
                var footerTxtV = {
                    styles: {
                        textAlignment: "center",
                        font: "굴림,12",
                        background: "#ffffff",
                        foreground: "#000000",
                        fontBold: true
                    },
                    text: ["합 계"],
                };
                var footerSumV = {
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
                gridV.setProperty("footerVisible", valV);
                gridV.setRowFooter("STD_INCREASING_RATE", footerTxtV);
                gridV.setRowFooter("BUY_QT", footerSumV);
                gridV.setRowFooter("BUY_AMT", footerSumV);
                gridV.setColMerge(['ITEM_CD']);
                gridV.setColMerge(['ITEM_DESC']);
                gridV.setColMerge(['VENDOR_NM']);
                gridV.setColMerge(['CONT_FROM_TO']);
            }

            // dgns와 통신하는 내부 관계사인 경우 관계사 분류체계 필수
            if ("${formData.DGNS_IF_CUST_FLAG }" == "1") {
            	gridR.hideCol("ITEM_CLS_PATH_NM", false);
            	gridR.setColRequired("ITEM_CLS_PATH_NM", true);
            } else {
            	gridR.hideCol("ITEM_CLS_PATH_NM", true);
            	gridR.setColRequired("ITEM_CLS_PATH_NM", false);
            }

            if(!${havePermission}) {
                EVF.C('Save').setVisible(false);
                EVF.C('Approval').setVisible(false);
                EVF.C('Delete').setVisible(false);
            } else {
                if("${formData.EXEC_NUM }" == null || "${formData.EXEC_NUM }" == "") {
                    EVF.C('Delete').setVisible(false);
                } else {
                    if("${formData.SIGN_STATUS }" == "E" || "${formData.SIGN_STATUS }" == "P") {
                        EVF.C('Save').setVisible(false);
                        EVF.C('Approval').setVisible(false);
                        EVF.C('Delete').setVisible(false);
                        gridR.setColReadOnly("CONT_UNIT_PRICE", true);
                        gridR.setColReadOnly("STD_UNIT_PRC", true);
                        gridR.setColReadOnly("STD_PROFIT_RATE", true);
                        gridR.setColReadOnly("SALES_UNIT_PRC", true);
                        gridR.setColReadOnly("SALES_PROFIT_RATE", true);
                    }
                    else if("${formData.SIGN_STATUS }" == "R") {
                    	EVF.C('Save').setVisible(false); // 반려인 경우 "저장" 삭제
                    }
                }
            }
            doSearch();
        }

        // 고객사 전달사항
        // 견적 합의시 등록
        function setCustRoRmk(data) {
            gridR.setCellValue(data.rowId, "CUST_RQ_RMK", data.message);
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([gridR]);
            store.setParameter("searchType", '${searchType}');
            store.load(baseUrl + "rq01023_doSearchGridR", function () {

                store = new EVF.Store();
                store.setGrid([gridC]);
                store.load(baseUrl + "rq01023_doSearchGridC", function () {

                    var rowIds = gridR.getAllRowId();
                    var itemCdStr = "'";
                    var vendorCdStr = "'";
                    for(var i in rowIds) {
                        itemCdStr = itemCdStr + gridR.getCellValue(rowIds[i], 'ITEM_CD') + "','";
                        vendorCdStr = vendorCdStr + gridR.getCellValue(rowIds[i], 'VENDOR_CD') + "','";
                    }
                    if(itemCdStr.length > 2) { itemCdStr = itemCdStr.substring(0, itemCdStr.length-2); }
                    if(vendorCdStr.length > 2) { vendorCdStr = vendorCdStr.substring(0, vendorCdStr.length-2); }

                    /**
                     * 2022.09.22 고객사 최근 1년 실적 제외
                    store = new EVF.Store();
                    store.setGrid([gridCU]);
                    store.setParameter("itemCdStr", itemCdStr);
                    store.load(baseUrl + "rq01023_doSearchGridCU", function () {

                        if(EVF.C("RFQ_TYPE").getValue() == "200") {
                            store = new EVF.Store();
                            store.setGrid([gridV]);
                            store.setParameter("itemCdStr", itemCdStr);
                            store.setParameter("vendorCdStr", vendorCdStr);
                            store.load(baseUrl + "rq01023_doSearchGridV", function () {
                                gridV.setColMerge(['ITEM_CD']);
                                gridV.setColMerge(['ITEM_DESC']);
                                gridV.setColMerge(['VENDOR_NM']);
                                gridV.setColMerge(['CONT_FROM_TO']);
                            }, false);
                        }
                    }, false);*/
                }, false);
            });
        }

        function doSave() {

            signStatus = this.getData();

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            if ("${today}" > EVF.C("CONT_DATE").getValue()) { return alert('${RQ01_023_001}'); }
            if (EVF.C("CONT_END_DATE").getValue() < EVF.C("CONT_START_DATE").getValue()) { return alert('${RQ01_023_002}'); }

            gridR.checkAll(true);

            var confirmMsg = (signStatus == "P" ? "${RQ01_023_004}" : "${RQ01_023_005}");
            var rowIds = gridR.getSelRowId();
            for(var i in rowIds) {

                if ("${formData.DGNS_IF_CUST_FLAG }" == "1"){
                    if(EVF.isEmpty(gridR.getCellValue(rowIds[i], 'ITEM_CLS_PATH_NM'))) {
                        return alert("${RQ01_023_017}"); // 관계사 분류체계명을 입력하세요.
                    }
                }
                if(EVF.isEmpty(gridR.getCellValue(rowIds[i], 'CONT_UNIT_PRICE')) || gridR.getCellValue(rowIds[i], 'CONT_UNIT_PRICE') == 0 || gridR.getCellValue(rowIds[i], 'CONT_UNIT_PRICE') == "0") {
                    return alert("'" + gridR.getCellValue(rowIds[i], 'ITEM_DESC') + "'의 " + "${RQ01_023_003}"); // 계약단가를 입력하세요.
                }
                if(Number(gridR.getCellValue(rowIds[i], 'QTA_UNIT_PRC')) > Number(gridR.getCellValue(rowIds[i], 'CONT_UNIT_PRICE'))) {
                    confirmMsg = "${RQ01_023_006}"; // 계약단가가 견적단가보다 낮습니다.\n진행하시겠습니까?
                }
                <%--
                if(Number(gridR.getCellValue(rowIds[i], 'CONT_UNIT_PRICE')) > Number(gridR.getCellValue(rowIds[i], 'STD_UNIT_PRC'))) {
                    confirmMsg = "${RQ01_023_009}"; // 운영표준단가가 계약단가보다 낮습니다.\n진행하시겠습니까?
                }
                if(EVF.isEmpty(gridR.getCellValue(rowIds[i], 'STD_PROFIT_RATE'))) {
                    return alert("'" + gridR.getCellValue(rowIds[i], 'ITEM_DESC') + "'의 " + "${RQ01_023_008}"); // 매출이익율을 입력하세요.
                }
                --%>
				if(Number(gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC')) == 0) {
                    return alert("${RQ01_023_010}"); // 고객사 판매단가를 입력하세요.
				}
                if(EVF.isEmpty(gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC')) || gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC') == 0 || gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC') == "0") {
                    if(Number(gridR.getCellValue(rowIds[i], 'CONT_UNIT_PRICE')) > Number(gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC'))) {
                        confirmMsg = "${RQ01_023_011}"; // 고객사 판매단가가 계약단가보다 낮습니다.\n진행하시겠습니까?
                    }
                }
                if(EVF.isEmpty(gridR.getCellValue(rowIds[i], 'APPLY_TARGET')) || gridR.getCellValue(rowIds[i], 'APPLY_TARGET') == "N") {
                    return alert("'" + gridR.getCellValue(rowIds[i], 'ITEM_DESC') + "'의 " + "${RQ01_023_013}"); // 단가적용대상을 선택하세요.
                }
				<%--
                if(gridR.getCellValue(rowIds[i], 'DEPT_PRICE_FLAG') == "1" && EVF.isEmpty(gridR.getCellValue(rowIds[i], 'DEPT_CD'))) {
                    return alert(gridR.getCellValue(rowIds[i], 'CUST_NM') + "의 ${RQ01_023_016}");
                }
                --%>
            }

            if(!confirm(confirmMsg)) { return; }

            if (signStatus === 'T') {
                goApproval();
            }
            else if (signStatus === 'P') {

                var rateAppFlag = "false";
                var bizRate = 0;
                var vendorOpenType = EVF.C("VENDOR_OPEN_TYPE").getValue();
                var bizCls3Val = (EVF.C("VENDOR_OPEN_TYPE").getValue() == "AB" ? "04" : "05");
                var rowIds = gridR.getAllRowId();
                var sumUnitPrc = 0;
                for(var i in rowIds) {
                    sumUnitPrc = sumUnitPrc + (gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC') == null || gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC') == 0) ? Number(gridR.getCellValue(rowIds[i], 'STD_UNIT_PRC')) : Number(gridR.getCellValue(rowIds[i], 'SALES_UNIT_PRC'));
                }
                var param = {
                    subject: EVF.C("EXEC_SUBJECT").getValue(),
                    docType: "EXEC",
                    signStatus: "P",
                    screenId: "RQ01_023",
                    approvalType: 'APPROVAL',
                    oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
                    attFileNum: "",
                    docNum: EVF.getComponent('EXEC_NUM').getValue(),
                    appDocNum: EVF.C('APP_DOC_NUM').getValue(),
                    callBackFunction: "goApproval",
                    bizCls1: "02",
                    bizCls2: "03",
                    bizCls3: "03",
                    bizAmt: sumUnitPrc,
                    bizRate: (rateAppFlag == "true" ? bizRate : null),
                    reqUserId: "${ses.userId}"
                };
                everPopup.openApprovalRequestIIPopup(param);
            }
        }

        function goApproval(formData, gridData, attachData) {

            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            var appFormData;
            var appSignStatus;
            if (signStatus == "P") { // 결재상신
                appFormData   = JSON.parse(formData);
                appSignStatus = EVF.isEmpty(appFormData.SIGN_STATUS) ? "P" : appFormData.SIGN_STATUS;
            } else if (signStatus == "T") {
                appSignStatus = "T"; // 임시저장
            } else {
                appSignStatus = "E"; // 결재상신 없이 전송
            }

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.doFileUpload(function() {
                store.setGrid([gridR]);
                store.getGridData(gridR, 'all');
                store.setParameter("signStatus", (appSignStatus == "E" ? appSignStatus : signStatus));
                store.load(baseUrl + 'rq01023_doSave', function () {
                	alert(this.getResponseMessage());
                    if (signStatus == "T") {
                        var param = {
                                'EXEC_NUM'  : this.getParameter("EXEC_NUM"),
                                'detailView': false,
                                'popupFlag' : true
                            };
                            window.location.href = '/evermp/RQ01/RQ0102/RQ01_023/view.so?' + $.param(param);
                    } else {
                    	opener['doSearch']();
                        EVF.closeWindow();
                    }
                });
            });
        }

        // 고객사 분류체계 팝업 Open
        function _getItemClsNmCust()  {
            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNmCust",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '21',  // 고객사코드or회사코드
                'custNm' : '고객사 분류체계(공통)'
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNmCust(data) {
            if(data!=null){
                data = JSON.parse(data);
                gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS1', data.ITEM_CLS1);
                gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS2', data.ITEM_CLS2);
	            gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS3', data.ITEM_CLS3);
    		    gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS4', data.ITEM_CLS4);
                gridR.setCellValue(eventRowId, 'ITEM_CLS_PATH_NM', data.ITEM_CLS_PATH_NM);
            } else {
                gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS1', "");
                gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS2', "");
                gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS3', "");
                gridR.setCellValue(eventRowId, 'CUST_ITEM_CLS4', "");
                gridR.setCellValue(eventRowId, 'ITEM_CLS_PATH_NM', "");
            }
        }

        function doDelete() {

        	if("${formData.SIGN_STATUS }" == "R") {
                if(!confirm("${RQ01_023_018}")) { return; }
        	} else {
                if(!confirm('${msg.M0013}')) { return; }
        	}

            var store = new EVF.Store();
            store.load(baseUrl + 'rq01023_doDelete', function () {
                alert(this.getResponseMessage());
                if(opener) {
                    opener.doSearch();
                }
                doClose();
            });
        }

        function doViewTable() {
            var param = {
                'RFQ_NUM': EVF.C("RFQ_NUM").getValue(),
                'RFQ_CNT': EVF.C("RFQ_CNT").getValue(),
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_024", 1300, 750, param);
        }

        /**
         * 2022.09.22 제외
		function setApplyInfo(data) {

            if(data.length != undefined) {

                var row = JSON.parse(data);
                var finalCustStr = "";

                for(var r in row) {
                    finalCustStr = finalCustStr + row[r].BUYER_CD + ",";
                }
                if(finalCustStr.length > 0) { finalCustStr = finalCustStr.substring(0, finalCustStr.length - 1); }

                var checkFlag = false;
                var finalArgs = finalCustStr.split(",");
                for(var i = 0; i < finalArgs.length; i++) {
                    if(finalArgs[i] == gridR.getCellValue(eventRowId, "CUST_CD") || finalArgs[i] == "${ses.manageCd}" || finalArgs[i].indexOf("BMG") > -1) {
                        checkFlag = true;
                    }
                }
                if(!checkFlag) {
                    alert("${RQ01_023_014}");
                    gridR.setCellValue(eventRowId, 'APPLY_TARGET_CD', "");
                    gridR.setCellValue(eventRowId, 'APPLY_TARGET', "N");
                } else {
                    gridR.setCellValue(eventRowId, 'APPLY_TARGET_CD', finalCustStr);
                    gridR.setCellValue(eventRowId, 'APPLY_TARGET', (finalCustStr.length > 0 ? "Y" : "N"));
                }
            }
        }*/

        function setGridDeptCd(data) {
            gridR.setCellValue(eventRowId, 'DEPT_CD', data.DEPT_CD);
            gridR.setCellValue(eventRowId, 'DEPT_NM', data.DEPT_NM);
        }

        function doClose() {
            if(opener) {
                window.open("", "_self");
                window.close();
            } else if(parent) {
                new EVF.ModalWindow().close(null);
            }
        }

        // 고객사별 매출이익율 반올림 구분
        function truncValidate(amt,truncType){
			if(truncType=="TC"){
				Math.round(amt)
			} else if(truncType=="RU"){
				Math.ceil(amt)
			} else if(truncType=="RD"){
				Math.floor(amt)
			} else{
				return amt;
			}
        }

    </script>

    <e:window id="RQ01_023" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:buttonBar id="btn" align="right" width="100%">
            <e:button id="ViewTable" name="ViewTable" label="${ViewTable_N}" disabled="${ViewTable_D}" visible="${ViewTable_V}" onClick="doViewTable" />
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" data="T" />
            <e:button id="Approval" name="Approval" label="${Approval_N}" disabled="${Approval_D}" visible="${Approval_V}" onClick="doSave" data="P" />
            <e:button id="Delete" name="Delete" label="${Delete_N}" disabled="${Delete_D}" visible="${Delete_V}" onClick="doDelete" />
            <e:button id="Close" name="Close" label="${Close_N}" onClick="doClose" disabled="${Close_D}" visible="${Close_V}"/>
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false">
            <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${formData.EXEC_NUM}" />
            <e:inputHidden id="RFQ_NUM" name="RFQ_NUM" value="${formData.RFQ_NUM}" />
            <e:inputHidden id="RFQ_CNT" name="RFQ_CNT" value="${formData.RFQ_CNT}" />
            <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${formData.APP_DOC_NUM}" />
            <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${formData.APP_DOC_CNT}" />
            <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS}" />
            <e:inputHidden id="OLD_SIGN_STATUS" name="OLD_SIGN_STATUS" value="${formData.SIGN_STATUS }" />
            <e:inputHidden id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${formData.VENDOR_OPEN_TYPE }" />
            <e:inputHidden id="RFQ_TYPE" name="RFQ_TYPE" value="${formData.RFQ_TYPE }" />
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${formData.CUST_CD}" />
            <e:inputHidden id="PLANT_CD" name="PLANT_CD" value="${formData.PLANT_CD}" />
            <e:inputHidden id="DGNS_IF_CUST_FLAG" name="DGNS_IF_CUST_FLAG" value="${formData.DGNS_IF_CUST_FLAG}" /> <!-- DGNS I/F 고객사 여부 -->
            <e:inputHidden id="approvalFormData" name="approvalFormData" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" />
            <e:inputHidden id="attachFileDatas"  name="attachFileDatas" />

            <e:row>
                <e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="EXEC_SUBJECT" name="EXEC_SUBJECT" value="${empty formData.EXEC_SUBJECT ? (empty param.RFQ_SUBJECT ? '' : param.RFQ_SUBJECT) : formData.EXEC_SUBJECT}" width="${form_EXEC_SUBJECT_W}" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="REG_INFO" title="${form_REG_INFO_N}"/>
                <e:field>
                    <e:text>${formData.REG_INFO}</e:text>
                </e:field>
                <e:label for="CONT_DATE" title="${form_CONT_DATE_N}"/>
                <e:field>
                    <e:inputDate id="CONT_DATE" name="CONT_DATE" value="${formData.CONT_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_CONT_DATE_R}" disabled="${form_CONT_DATE_D}" readOnly="${form_CONT_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CONT_START_DATE" title="${form_CONT_START_DATE_N}"/>
                <e:field>
                    <e:inputDate id="CONT_START_DATE" name="CONT_START_DATE" toDate="CONT_END_DATE" value="${formData.CONT_START_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_CONT_START_DATE_R}" disabled="${form_CONT_START_DATE_D}" readOnly="${form_CONT_START_DATE_RO}" />
                </e:field>
                <e:label for="CONT_END_DATE" title="${form_CONT_END_DATE_N}"/>
                <e:field>
                    <e:inputDate id="CONT_END_DATE" name="CONT_END_DATE" value="${formData.CONT_END_DATE }" width="${inputDateWidth}" datePicker="true" required="${form_CONT_END_DATE_R}" disabled="${form_CONT_END_DATE_D}" readOnly="${form_CONT_END_DATE_RO}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_OPEN_TYPE_LOC" title="${form_VENDOR_OPEN_TYPE_LOC_N}"/>
                <e:field>
                    <e:text>${formData.VENDOR_OPEN_TYPE_LOC}</e:text>
                </e:field>
                <e:label for="CUR" title="${form_CUR_N}" />
				<e:field>
					<e:text>${formData.CUR}</e:text>
				</e:field>
				<%--
                <e:label for="DEAL_TYPE_LOC" title="${form_DEAL_TYPE_LOC_N}"/>
                <e:field>
                    <e:text>${formData.DEAL_TYPE_LOC}</e:text>
                </e:field>
                --%>
            </e:row>
            <e:row>
                <e:label for="RMK_TEXT" title="${form_RMK_TEXT_N }" />
                <e:field colSpan="3">
                    <e:richTextEditor id="RMK_TEXT" name="RMK_TEXT" width="100%" height="200px" value="${formData.RMK_TEXT }" required="${form_RMK_TEXT_R }" readOnly="${form_RMK_TEXT_RO }" disabled="${form_RMK_TEXT_D }" useToolbar="${!param.detailView}" />
                    <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${formData.RMK_TEXT_NUM }" />
                </e:field>
            </e:row>
	        <c:choose>
		        <%-- 수의견적 사유 : 단독수의: QN, 지명경쟁: AB --%>
	        	<c:when test="${formData.VENDOR_OPEN_TYPE == 'QN'}">
		            <e:row>
		                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
		                <e:field>
		                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="EX" fileId="${formData.ATT_FILE_NUM}" readOnly="${param.detailView }" downloadable="true" width="100%" height="80px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATT_FILE_NUM_R }" />
		                </e:field>
		                <e:label for="OPTION_RFQ_REASON" title="${form_OPTION_RFQ_REASON_N}"/>
		                <e:field>
		                    <e:textArea id="OPTION_RFQ_REASON" name="OPTION_RFQ_REASON" value="${formData.OPTION_RFQ_REASON }" height="120px" width="100%" maxLength="${form_OPTION_RFQ_REASON_M}" disabled="${form_OPTION_RFQ_REASON_D}" readOnly="${form_OPTION_RFQ_REASON_RO}" required="${form_OPTION_RFQ_REASON_R}" />
		                </e:field>
		            </e:row>
	        	</c:when>
	        	<c:otherwise>
		            <e:row>
		                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N }" />
		                <e:field colSpan="3">
		                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="EX" fileId="${formData.ATT_FILE_NUM}" readOnly="${param.detailView }" downloadable="true" width="100%" height="80px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="${form_ATT_FILE_NUM_R }" />
		                </e:field>
		            </e:row>
	        	</c:otherwise>
	        </c:choose>
        </e:searchPanel>

		<!-- 견적 및 계약정보 -->
        <e:title title="${RQ01_023_CAPTION1 }" />
        <e:gridPanel id="gridR" name="gridR" width="100%" height="220px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />

		<!-- 요청 품목정보 -->
        <e:title title="${RQ01_023_CAPTION2 }" />
        <e:gridPanel id="gridC" name="gridC" width="100%" height="220px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridC.gridColData}" />

		<!-- RFQ_TYPE=200(재계약) => 공급사 계약이력정보 -->
        <c:if test="${formData.RFQ_TYPE == '200'}">
            <e:title title="${RQ01_023_CAPTION3 }" />
            <e:gridPanel id="gridV" name="gridV" width="100%" height="220px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridV.gridColData}" />
        </c:if>

		<%-- 고객사 실적정보 (최근 1년 기준)
        <e:title title="${RQ01_023_CAPTION4 }" />
        <e:gridPanel id="gridCU" name="gridCU" width="100%" height="300px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridCU.gridColData}" />
 		--%>

        <jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true">
            <jsp:param value="${formData.APP_DOC_NUM}" name="APP_DOC_NUM" />
            <jsp:param value="${formData.APP_DOC_CNT}" name="APP_DOC_CNT" />
        </jsp:include>

    </e:window>
</e:ui>