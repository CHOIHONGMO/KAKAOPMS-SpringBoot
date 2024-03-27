<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BOD1/BOD102/";
        var ROWIDX;
		var Checkevent = 'N';
        function init() {
            grid = EVF.C("grid");
            userType = "${ses.userType}";

            /* grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            }); */

            grid.cellClickEvent(function(rowId, colId, value) {
                var param;

                ROWIDX = rowId;

                if(colId === "multiSelect") {
                    var ITEM_TOT_AMT = 0;
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        ITEM_TOT_AMT += Number(rows[i].CPO_ITEM_AMT);
                    }
                    EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                    EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));
                } else if(colId == "CUST_NM") {
                    // param = {
                    //     callBackFunction: "callbackGridCUST_NM",
                    //     rowId: rowId
                    // };
                    // everPopup.openCommonPopup(param, "SP0067");
                } else if(colId == "CPO_USER_NM") {
                    <%--if(CUST_CD == "" ) return alert("${BOD1_020_001}");--%>

                    <%--param = {--%>
                    <%--    callBackFunction: "callbackCGridCPO_USER_NM",--%>
                    <%--    custCd: CUST_CD,--%>
                    <%--    rowId: rowId--%>
                    <%--};--%>
                    <%--everPopup.openCommonPopup(param, "SP0083");--%>
                } else if(colId == "ITEM_CD") {

                    param = {
                        callBackFunction: "callbackGridITEM_CD",
                        PR_BUYER_CD : EVF.V("CUST_CD"),
                        PR_PLANT_CD : EVF.V("PLANT_CD"),
                        rowId: rowId,
                        multiFlag: false,
                        detailView: false,
                        popupFlag: true
                    };

                    everPopup.openPopupByScreenId("IM02_012", 1200, 600, param);
                } else if(colId == "VENDOR_CD") {
                    param = {
                        callBackFunction: "callbackGridVENDOR_CD",
                        rowId: rowId
                    };
                    everPopup.openCommonPopup(param, "SP0063");
                } else if(colId == "COST_CENTER_CD") {
                    param = {
                        callBackFunction: "callbackGridCOST_CENTER_CD",
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD")
                    };
                    everPopup.openCommonPopup(param, "SP0116");
                } else if(colId == "RECIPIENT_NM") {
                    param = {
                        callBackFunction: "callbackGridRECIPIENT_NM",
                        CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                        USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                        detailView: false
                    };
                    everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                } else if(colId == "DELY_ZIP_CD") {
                    param = {
                        callBackFunction: "callbackGridDELY_ZIP_CD",
                        modalYn: false
                    };
                    everPopup.jusoPop("/common/code/BADV_020/view", param);
                } else if(colId == "REQ_TEXT") {
                    param = {
                        title: "요청사항",
                        message: grid.getCellValue(rowId, "REQ_TEXT"),
                        callbackFunction: "callbackGridREQ_TEXT",
                        detailView: false,
                        rowId: rowId
                    };
                    everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
                } else if(colId == "ATTACH_FILE_CNT") {
                    param = {
                        attFileNum: grid.getCellValue(rowId, "ATTACH_FILE_NO"),
                        rowId: rowId,
                        callBackFunction: "callbackGridATTACH_FILE_CNT",
                        havePermission: true,
                        bizType: "OM",
                        fileExtension: "*"
                    };
                    everPopup.openPopupByScreenId("commonFileAttach", 650, 310, param);
                } else if(colId === "MAKER_NM") {

                	if (grid.getCellValue(rowId, "ITEM_CD")!='') {
						return;
                	}

                    var param = {
                            rowId: rowId,
                            callBackFunction: "callbackGridMAKER_NM"
                        };
                        everPopup.openCommonPopup(param, "SP0068");
                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

    			 if( colId == "CUST_ITEM_CD"
            	     || colId == "ITEM_DESC"
               	     || colId == "ITEM_SPEC"
              	     || colId == "MAKER_CD"
               	     || colId == "MAKER_PART_NO"
            		 || colId == "BRAND_CD"
            	     || colId == "ORIGIN_CD"
            	     || colId == "UNIT_CD"
            	     || colId == "CUR"
            	     || colId == "CPO_UNIT_PRICE"
				) {
					if (grid.getCellValue(rowId, "ITEM_CD")!='') {
						grid.setCellValue(rowId,colId, oldValue);
						return alert("${BOD1_020_017}");
					}
				}
                if(colId == "CPO_QTY" || colId == 'CPO_UNIT_PRICE') {
                    var CPO_ITEM_AMT = grid.getCellValue(rowId, "CPO_QTY") * grid.getCellValue(rowId, "CPO_UNIT_PRICE");
                    var PO_ITEM_AMT = value * grid.getCellValue(rowId, "PO_UNIT_PRICE");

                    grid.setCellValue(rowId, "CPO_ITEM_AMT", CPO_ITEM_AMT);
                    grid.setCellValue(rowId, "PO_ITEM_AMT", PO_ITEM_AMT);
                }
                if(colId == "IF_UNIT_PRICE") {
                    grid.setCellValue(rowId, "IF_ITEM_AMT",  grid.getCellValue(rowId, "IF_UNIT_PRICE") * grid.getCellValue(rowId, "CPO_QTY") );
                }
            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {
                if(checked) {
                    var ITEM_TOT_AMT = 0;
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        ITEM_TOT_AMT += Number(rows[i].CPO_ITEM_AMT);
                    }
                    EVF.V("ITEM_TOT_AMT", comma(String(ITEM_TOT_AMT)));
                    EVF.V("ITEM_TOT_CNT", comma(String(grid.getSelRowCount())));
                } else {
                    EVF.V("ITEM_TOT_AMT", "0");
                    EVF.V("ITEM_TOT_CNT", "0");
                }
            };

            grid.addRowEvent(function() {
                var store = new EVF.Store();
                if(!store.validate()) { return;}

                let addParam={
                    RESULT_CD: "New",
                    AUTO_PO_FLAG : EVF.V("AUTO_PO_FLAG"),
                    CUST_CD: EVF.V("CUST_CD"),
                    CUST_NM: EVF.V("CUST_NM"),
                    CPO_USER_ID: EVF.V("CPO_USER_ID"),
                    CPO_USER_NM: EVF.V("CPO_USER_NM"),
                    PLANT_CD : EVF.V("PLANT_CD"),
                    PLANT_NM : EVF.V("PLANT_NM"),
                    CPO_USER_DIVISION_CD : EVF.V("DIVISION_CD"),
                    CPO_USER_DEPT_CD : EVF.V("DEPT_CD"),
                    CPO_USER_DEPT_NM : '',
                    CPO_USER_PART_CD : EVF.V("PART_CD"),
                    PR_SUBJECT : EVF.V("PR_SUBJECT"),
                    PR_TYPE : EVF.V("PR_TYPE"),
                    CPO_DATE : EVF.V("CPO_DATE"),
                    HOPE_DUE_DATE : EVF.V("HOPE_DUE_DATE"),
                    CSDM_SEQ : EVF.V("CSDM_SEQ"),
                    DELY_NM : EVF.V("DELY_NM"),
                    PRIOR_GR_FLAG : EVF.V("PRIOR_GR_FLAG"),
                    RECIPIENT_NM : EVF.V("RECIPIENT_NM"),
                    DELY_ZIP_CD : EVF.V("DELY_ZIP_CD"),
                    DELY_ADDR_1 : EVF.V("DELY_ADDR_1"),
                    DELY_ADDR_2 : EVF.V("DELY_ADDR_2"),
                    ORIGIN_CD : "KR",
                    UNIT_CD : "EA",
                    CUR : "KRW",
                    TAX_CD : "T1",
                    MOQ_QTY : "1",
                    RV_QTY : "1",
					RECIPIENT_EMAIL : EVF.V("RECIPIENT_EMAIL"),
					RECIPIENT_CELL_NUM : EVF.V("RECIPIENT_CELL_NUM")
                };
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                grid.delRow();
            });

            grid.excelImportEvent({
                "append": false
            }, function (msg, code) {
            	var store = new EVF.Store();
                if(!store.validate()) { grid.delAllRow(); return;}

                if (code) {
                    grid.checkAll(true);

                    var store = new EVF.Store();
					store.setGrid([grid]);
					$.each(grid.getAllRowValue(),function(index, item){
						grid.setCellValue(index, 'RESULT_CD', "New", true);
						grid.setCellValue(index, 'AUTO_PO_FLAG', EVF.V('AUTO_PO_FLAG'), true);
						grid.setCellValue(index, 'PR_TYPE', EVF.V('PR_TYPE'), true);
						grid.setCellValue(index, 'CUST_CD', EVF.V('CUST_CD'), true);
						grid.setCellValue(index, 'CUST_NM', EVF.V('CUST_NM'), true);
						grid.setCellValue(index, 'PLANT_CD', EVF.V('PLANT_CD'), true);
						grid.setCellValue(index, 'PLANT_NM', EVF.V('PLANT_NM'), true);
						grid.setCellValue(index, 'CPO_USER_ID', EVF.V('CPO_USER_ID'), true);
						grid.setCellValue(index, 'CPO_USER_NM', EVF.V('CPO_USER_NM'), true);
						grid.setCellValue(index, 'CPO_USER_DIVISION_CD', EVF.V('DIVISION_CD'), true);
						grid.setCellValue(index, 'CPO_USER_DEPT_CD', EVF.V('DEPT_CD'), true);
						grid.setCellValue(index, 'CPO_USER_DEPT_NM', '', true);
						grid.setCellValue(index, 'CPO_USER_PART_CD', EVF.V('PART_CD'), true);
						grid.setCellValue(index, 'PR_SUBJECT', EVF.V('PR_SUBJECT'), true);
						grid.setCellValue(index, 'CPO_DATE', EVF.V('CPO_DATE'), true);
						grid.setCellValue(index, 'HOPE_DUE_DATE', EVF.V('HOPE_DUE_DATE'), true);
						grid.setCellValue(index, 'CSDM_SEQ', EVF.V('CSDM_SEQ'), true);
						grid.setCellValue(index, 'DELY_NM', EVF.V('DELY_NM'), true);
						grid.setCellValue(index, 'PRIOR_GR_FLAG', EVF.V('PRIOR_GR_FLAG'), true);
						grid.setCellValue(index, 'RECIPIENT_NM', EVF.V('RECIPIENT_NM'), true);
						grid.setCellValue(index, 'DELY_ZIP_CD', EVF.V('DELY_ZIP_CD'), true);
						grid.setCellValue(index, 'DELY_ADDR_1', EVF.V('DELY_ADDR_1'), true);
						grid.setCellValue(index, 'DELY_ADDR_2', EVF.V('DELY_ADDR_2'), true);
					});
					store.getGridData(grid, 'all')
					store.load(baseUrl + '/doSetExcelImportItemCpo', function () {

					});
                }
            });

            EVF.C("PR_TYPE").removeOption("R");
            if(userType == "B") {
                grid.hideCol("AUTO_PO_FLAG", true);
                grid.hideCol("PR_TYPE", true);
            }
        }

        function callbackGridCUST_NM(data) {
            grid.setCellValue(data.rowId, "CUST_CD", data.CUST_CD);
            grid.setCellValue(data.rowId, "CUST_NM", data.CUST_NM);


        }

        function callbackCGridCPO_USER_NM(data) {
            grid.setCellValue(data.rowId, "CPO_USER_ID", data.USER_ID);
            grid.setCellValue(data.rowId, "CPO_USER_NM", data.USER_NM);
        }

        function callbackGridITEM_CD(jsonData, rowIdx) {

        	if(jsonData[0].ITEM_STATUS !='10'){
        		return alert("${BOD1_020_024}")
        	}
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
            grid.setCellValue(rowIdx, "UNIT_CD", jsonData[idx].UNIT_CD);
            grid.setCellValue(rowIdx, "CUST_ITEM_CD", jsonData[idx].CUST_ITEM_CD);
            grid.setCellValue(rowIdx, "DELY_TYPE", jsonData[idx].DELY_TYPE);
            grid.setCellValue(rowIdx, "TAX_CD", jsonData[idx].VAT_CD);
            grid.setCellValue(rowIdx, "DEAL_CD", jsonData[idx].DEAL_CD);

            grid.setCellValue(rowIdx, "CONT_NO", jsonData[idx].CONT_NO);
            grid.setCellValue(rowIdx, "CONT_SEQ", jsonData[idx].CONT_SEQ);
            grid.setCellValue(rowIdx, "VENDOR_CD", jsonData[idx].VENDOR_CD);

            doGetPrice(rowIdx);
        }


        function doGetPrice(rowIdx) {
            var store = new EVF.Store();

            store.setParameter("BUYER_CD", grid.getCellValue(rowIdx, "CUST_CD"));
            store.setParameter("ITEM_CD", grid.getCellValue(rowIdx, "ITEM_CD"));
            store.setParameter("CONT_NO", grid.getCellValue(rowIdx, "CONT_NO"));
            store.setParameter("CONT_SEQ", grid.getCellValue(rowIdx, "CONT_SEQ"));

            store.load("/evermp/IM02/IM0201/im02011_doGetPrice", function() {
                grid.setCellValue(rowIdx, "PO_UNIT_PRICE", this.getParameter("CONT_UNIT_PRICE"));
                grid.setCellValue(rowIdx, "CPO_UNIT_PRICE", this.getParameter("UNIT_PRICE"));
                grid.setCellValue(rowIdx, "MOQ_QTY", this.getParameter("MOQ_QTY"));
                grid.setCellValue(rowIdx, "RV_QTY", this.getParameter("RV_QTY"));
                grid.setCellValue(rowIdx, "CUR", this.getParameter("CUR"));
                grid.setCellValue(rowIdx, "VENDOR_CD", this.getParameter("VENDOR_CD"));
                grid.setCellValue(rowIdx, "VENDOR_NM", this.getParameter("VENDOR_NM"));

                var CPO_ITEM_AMT = grid.getCellValue(rowIdx, "CPO_QTY") * grid.getCellValue(rowIdx, "CPO_UNIT_PRICE");
                var PO_ITEM_AMT = grid.getCellValue(rowIdx, "CPO_QTY") * grid.getCellValue(rowIdx, "PO_UNIT_PRICE");

                grid.setCellValue(rowIdx, "CPO_ITEM_AMT", CPO_ITEM_AMT);
                grid.setCellValue(rowIdx, "PO_ITEM_AMT", PO_ITEM_AMT);

                grid.setCellValue(rowIdx, "LEAD_TIME", this.getParameter("LEAD_TIME"));
                grid.setCellValue(rowIdx, "LEAD_TIME_DATE", this.getParameter("LEAD_TIME_DATE"));
                grid.setCellValue(rowIdx, "DEAL_CD", this.getParameter("DEAL_CD"));

            });
        }

        function callbackGridVENDOR_CD(data) {
            grid.setCellValue(data.rowId, "VENDOR_CD", data.VENDOR_CD);
            grid.setCellValue(data.rowId, "VENDOR_NM", data.VENDOR_NM);
        }

        function callbackGridCOST_CENTER_CD(data) {
            grid.setCellValue(ROWIDX, "COST_CENTER_CD", data.COST_CENTER_CD);
            grid.setCellValue(ROWIDX, "COST_CENTER_NM", data.COST_CENTER_NM_KOR);
        }

        function callbackGridRECIPIENT_NM(data) {
            grid.setCellValue(ROWIDX, "CSDM_SEQ", data.CSDM_SEQ);
            grid.setCellValue(ROWIDX, "DELY_NM", data.DELY_NM);
            grid.setCellValue(ROWIDX, "RECIPIENT_NM", data.HIDDEN_DELY_RECIPIENT_NM);
            grid.setCellValue(ROWIDX, "RECIPIENT_TEL_NUM", data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
            grid.setCellValue(ROWIDX, "RECIPIENT_CELL_NUM", data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
            grid.setCellValue(ROWIDX, "RECIPIENT_EMAIL", data.HIDDEN_DELY_RECIPIENT_EMAIL);
            grid.setCellValue(ROWIDX, "RECIPIENT_FAX_NUM", data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
            grid.setCellValue(ROWIDX, "RECIPIENT_DEPT_NM", data.DELY_RECIPIENT_DEPT_NM);
            grid.setCellValue(ROWIDX, "DELY_ZIP_CD", data.DELY_ZIP_CD);
            grid.setCellValue(ROWIDX, "DELY_ADDR_1", data.DELY_ADDR_1);
            grid.setCellValue(ROWIDX, "DELY_ADDR_2", data.DELY_ADDR_2);
            // grid.setCellValue(ROWIDX, "DELY_RMK", data.DELY_RMK);
        }

        function callbackGridDELY_ZIP_CD(data) {
            if (data.ZIP_CD != "") {
                grid.setCellValue(ROWIDX, "DELY_ZIP_CD", data.DELY_ZIP_CD);
                grid.setCellValue(ROWIDX, "DELY_ADDR_1", data.DELY_ADDR_1);
                grid.setCellValue(ROWIDX, "DELY_ADDR_2", data.DELY_ADDR_2);

                grid.setCellValue(ROWIDX, "CSDM_SEQ", data.CSDM_SEQ);
                grid.setCellValue(ROWIDX, "DELY_NM", data.DELY_NM);
            }
        }

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
        }

        function callbackGridATTACH_FILE_CNT(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, "ATTACH_FILE_NO", fileId);
            grid.setCellValue(rowId, "ATTACH_FILE_CNT", fileCnt);
        }

        function doSearch() {
            var store = new EVF.Store();
            if(!store.validate()) { return;}

//			if(EVF.V("CUST_CD") == '') {
//				return alert("${BOD1_020_019}");
//			}

			store.setGrid([grid]);
            store.load(baseUrl + "bod1020_doSearch", function() {
                var itemTotal = 0;
                if(grid.getRowCount() > 0){
                    var rowIds = grid.getAllRowId();
                    for( var i in rowIds ) {
                        if(Number(grid.getCellValue(rowIds[i], "CPO_ITEM_AMT")) > 0) {
                            grid.checkRow(rowIds[i], true);
                        }
                        itemTotal += Number(grid.getCellValue(rowIds[i], "CPO_ITEM_AMT"));
                    }
                }
                EVF.C("ITEM_TOT_AMT").setValue(comma(String(itemTotal)));
                EVF.C("ITEM_TOT_CNT").setValue(comma(String(grid.getSelRowCount())));
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            // 결재 및 예산검토여부가 y인 고객은 일괄주문할 수 없음
            if( /*EVF.V("APPROVE_FLAG") == "Y" ||*/ EVF.V("BUDGET_FLAG") == "Y" ){
                return alert("${BOD1_020_016}");
            }

            var rowIds  = grid.getSelRowId();
            for( var i in rowIds ) {
                // 저장 및 유효성 검증시 고객서 선택 필수
                if( grid.getCellValue(rowIds[i], "RESULT_CD") == "New" && EVF.C("CUST_CD").getValue() == "" ){
                    return alert("${BOD1_020_001}");
                }
                // 저장 및 유효성 검증시 주문자 선택 필수
                if( grid.getCellValue(rowIds[i], "RESULT_CD") == "New" && EVF.C("CPO_USER_ID").getValue() == "" ){
                    return alert("${BOD1_020_002}");
                }
                if( Number(grid.getCellValue(rowIds[i], "CPO_QTY")) <= 0 ) {
                    return alert("${BOD1_020_006}");
                }
                if( grid.getCellValue(rowIds[i], "PRIOR_GR_FLAG") != "0" && grid.getCellValue(rowIds[i], "PRIOR_GR_FLAG") != "1" ){
                    return alert("${BOD1_020_008}");
                }

				var prType = grid.getCellValue(rowIds[i], "PR_TYPE");
				var itemCd = grid.getCellValue(rowIds[i], "ITEM_CD");
				if(prType == 'G') { // 일반구매
					if(itemCd=='') {
						return alert("${BOD1_020_020}");
					}
				}
            }

            if(!confirm("${BOD1_020_012}")) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + 'bod1020_doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doOrder() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            // 결재 및 예산검토여부가 y인 고객은 일괄주문할 수 없음
            if( /*EVF.V("APPROVE_FLAG") == "Y" ||*/ EVF.V("BUDGET_FLAG") == "Y" ){
                return alert("${BOD1_020_016}");
            }

            var curDate = new Date().toString('yyyyMMdd');
            var rowIds  = grid.getSelRowId();

            var tempPrType = grid.getCellValue( 0 , 'PR_TYPE');

            for( var i in rowIds ) {

            	if(tempPrType != grid.getCellValue(rowIds[i], 'PR_TYPE')) {
                    return alert("${BOD1_020_021}");
            	}

                if( grid.getCellValue(rowIds[i], 'RESULT_CD') == 'New' ) {
                    return alert("${BOD1_020_007}"); // 유효성 검토결과=New:신규
                }
                if( grid.getCellValue(rowIds[i], 'RESULT_CD') != 'OK' ) {
                    return alert("${BOD1_020_014}"); // 유효성 검토결과=OK
                }
                if( grid.getCellValue(rowIds[0], 'CUST_CD') != grid.getCellValue(rowIds[i], 'CUST_CD') ) {
                    return alert("${BOD1_020_003}"); // 동일 고객사
                }
                if( grid.getCellValue(rowIds[0], 'CPO_DATE') != grid.getCellValue(rowIds[i], 'CPO_DATE') ) {
                    return alert("${BOD1_020_004}"); // 동일 주문일자
                }
                if( grid.getCellValue(rowIds[0], 'CPO_USER_ID') != grid.getCellValue(rowIds[i], 'CPO_USER_ID') ) {
                    return alert("${BOD1_020_003}"); // 동일 주문자
                }
                <%--if( grid.getCellValue(rowIds[0], 'PRIOR_GR_FLAG') != grid.getCellValue(rowIds[i], 'PRIOR_GR_FLAG') ) {--%>
                <%--    return alert("${BOD1_020_005}"); // 동일 선입고여부--%>
                <%--}--%>

                if( Number(grid.getCellValue(rowIds[i], 'CPO_QTY')) <= 0 ) {
                    return alert("${BOD1_020_006}");
                }
                if( grid.getCellValue(rowIds[i], 'PRIOR_GR_FLAG') != '0' && grid.getCellValue(rowIds[i], 'PRIOR_GR_FLAG') != '1' ){
                    return alert("${BOD1_020_008}");
                }
                if( grid.getCellValue(rowIds[i], 'PRIOR_GR_FLAG') == '1' && Number(grid.getCellValue(rowIds[i], 'CPO_DATE')) >= Number(curDate) ){
                    return alert("${BOD1_020_010}");
                }
                if( (grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE')).length != 8 ){
                    return alert("${BOD1_020_009}");
                }
                if( Number(grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE')) <= Number(grid.getCellValue(rowIds[i], 'CPO_DATE')) ){
                    return alert("${BOD1_020_009}");
                }
                if( Number(grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE')) < Number(curDate) ){
                    return alert("${BOD1_020_011}");
                }

                var mouQty = Number(grid.getCellValue(rowIds[i], "MOQ_QTY")); // 최소주문량
                var rvQty  = Number(grid.getCellValue(rowIds[i], "RV_QTY")); // 주문배수
                var cartQt = Number(grid.getCellValue(rowIds[i], "CPO_QTY")); // 주문수량
                // 주문수량 >= 최소주문량 and 주문수량 = 최소주문량 * 발주배수

                if(  !(cartQt >= mouQty && (cartQt === mouQty || (cartQt - mouQty) % rvQty === 0)   )  ) {
                	if(grid.getCellValue(rowIds[i], 'ITEM_CD') != '' && rvQty != 0){
                        return alert("${BOD1_020_006}");
					} else if(cartQt < mouQty) {
                    	return alert("${BOD1_030_011}");
					}
                }
            }

            if(!confirm('${BOD1_020_013}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'bod1020_doOrder', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var isNew  = false;
            var rowIds = grid.getSelRowId();
            if( grid.getCellValue(rowIds[0], 'RESULT_CD') == "New" ) {
                isNew = true;
            }

            if( isNew ){
                return alert("${BOD1_020_015}");
            } else {
                if (!confirm("${msg.M0013 }")) return;

                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl + 'bod1020_doDelete', function() {
                    alert(this.getResponseMessage());
                    doSearch();
                });
            }
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "callBackCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function callBackCustCd(data) {
        	if(EVF.V("CUST_CD_ORI") != data.CUST_CD ){
                if(grid.getRowCount()> 0 && !confirm("${BOD1_020_017}")) { return; }
                grid.delAllRow();
                EVF.V("CSDM_SEQ"     , "");
                EVF.V("DELY_NM"      , "");
                EVF.V("RECIPIENT_NM" , "");
                EVF.V("CUST_CD", data.CUST_CD);
                EVF.V("PR_BUYER_CD", data.CUST_CD);
                EVF.V("CUST_CD_ORI", data.CUST_CD);
                EVF.V("CUST_NM", data.CUST_NM);

                var allRowId = grid.getAllRowId();
                for(var i in allRowId) {
                    var rowId = allRowId[i];
                    grid.setCellValue(rowId, "CUST_CD", EVF.V("CUST_CD"));
                    grid.setCellValue(rowId, "CUST_NM", EVF.V("CUST_NM"));
                }

                if("1" == data.COST_CENTER_FLAG) {
                    grid.hideCol("COST_CENTER_CD", false);
                    grid.hideCol("COST_CENTER_NM", false);
                } else {
                    grid.hideCol("COST_CENTER_CD", true);
                    grid.hideCol("COST_CENTER_NM", true);
                }

                EVF.C("CPO_USER_ID").setValue('');
                EVF.C("CPO_USER_NM").setValue('');
        	}
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${BOD1_020_001}");
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
			EVF.C('DIVISION_CD').setOptions([]);
            EVF.C('DEPT_CD').setOptions([]);
			EVF.C('PART_CD').setOptions([]);
			chgPlantCd();
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

        // 첨부파일 양식 다운로드
        function dotempletDownload() {
            var store = new EVF.Store();
            store.setParameter('tmplNum', 'BOD1_020');
            store.load('/evermp/BS99/BS9901/bs99010_getTmplAttFileNum', function() {
                everPopup.readOnlyFileAttachPopup('tmplMng', this.getParameter('attFileNum'), null, null);

            }, false);
        }

        function getDelyAddr() {
        	if( EVF.V("CUST_CD")  == "" ) return alert("${BOD1_020_001}");
            if( EVF.V("PLANT_CD") == "" ) return alert("${BOD1_020_018}");

        	param = {
                    callBackFunction: "setDelyAddr",
                    CUST_CD: EVF.V("CUST_CD"),
                    USER_ID: EVF.V("CPO_USER_ID"),
                    detailView: false
                };
            everPopup.openPopupByScreenId("MY01_007", 1040, 600, param);
        }

        function setDelyAddr(data) {
        	if( data.RECIPIENT_EMAIL == "" || data.RECIPIENT_CELL_NUM == "" ) {
        		EVF.alert("${BOD1_020_023}");
        	}

            EVF.C("CSDM_SEQ").setValue(data.CSDM_SEQ);
            EVF.C("DELY_NM").setValue(data.DELY_NM);
            EVF.C("RECIPIENT_NM").setValue(data.RECIPIENT_NM);
			EVF.C("RECIPIENT_EMAIL").setValue(data.RECIPIENT_EMAIL);
			EVF.C("RECIPIENT_CELL_NUM").setValue(data.RECIPIENT_CELL_NUM);
            EVF.C("DELY_ZIP_CD").setValue(data.DELY_ZIP_CD);
            EVF.C("DELY_ADDR_1").setValue(data.DELY_ADDR_1);
            EVF.C("DELY_ADDR_2").setValue(data.DELY_ADDR_2);
        }

        function callbackGridMAKER_NM(data) {
            grid.setCellValue(data.rowId, "MAKER_CD", data.MKBR_CD);
            grid.setCellValue(data.rowId, "MAKER_NM", data.MKBR_NM);
        }

        function doDownloadExcel(){
			var attFileNum = '${TEMP_ATT_FILE_NUM}';
            if (attFileNum != '') {
                var param = {
                    havePermission: false,
                    attFileNum: attFileNum,
                    bizType: "BI",
                    fileExtension: '*'
                };
                everPopup.openPopupByScreenId('commonFileAttach', 650, 340, param);
            }
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
					EVF.C('CPO_USER_ID').setValue('');
					EVF.C('CPO_USER_NM').setValue('');
				}
			});
		}

		function chgDivisionCd() {
			if(Checkevent == 'Y'){
				return ;
			}
			EVF.C('DEPT_CD').setOptions([]);
			EVF.C('PART_CD').setOptions([]);
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
        	if(Checkevent == 'Y'){
        		return ;
			}
			var store = new EVF.Store;
			store.setParameter("DEPT_TYPE", "300");
			var baseUrl2 = "/evermp/SY01/SY0101/";
			store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
				if (this.getParameter("divisionDeptPartCd") != null) {
					EVF.C('PART_CD').setOptions(this.getParameter("divisionDeptPartCd"));
				}
			});
		}

		function searchCustUserId() {
			if( EVF.V("CUST_CD") == "" ) return alert("${BOD1_020_001}");
			var param = {
				callBackFunction : "callbackCustUserId",
				custCd: EVF.V("CUST_CD"),
				plantCd : EVF.V("PLANT_CD")
			};
			everPopup.openCommonPopup(param, 'SP0083');
			EVF.C('DEPT_CD').setOptions([]);
			EVF.C('PART_CD').setOptions([]);
		}


		function callbackCustUserId(data) {
			Checkevent = 'Y';
			EVF.C("CPO_USER_ID").setValue(data.USER_ID);
			EVF.C("CPO_USER_NM").setValue(data.USER_NM);
			//EVF.C("CPO_USER_DEPT_NM").setValue(data.DEPT_NM);
			EVF.C("DIVISION_CD").setValue(data.DIVISION_CD);

			var store = new EVF.Store;
			store.setParameter("DEPT_TYPE", "200");
			store.setParameter("DIVISION_CD", data.DIVISION_CD);
			var baseUrl2 = "/evermp/SY01/SY0101/";
			store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
				if (this.getParameter("divisionDeptPartCd") != null) {
						EVF.C('DEPT_CD').setOptions(this.getParameter("divisionDeptPartCd"));
						setTimeout(EVF.C('DEPT_CD').setValue(data.DEPT_CD,false),300);
					var store = new EVF.Store;
					store.setParameter("DEPT_TYPE", "300");
					store.setParameter("DIVISION_CD", data.DIVISION_CD);
					store.setParameter("DEPT_CD", data.DEPT_CD);
					var baseUrl2 = "/evermp/SY01/SY0101/";
					store.load(baseUrl2 + '/getDivisionDeptPartCd', function() {
						if (this.getParameter("divisionDeptPartCd") != null) {
								EVF.C('PART_CD').setOptions(this.getParameter("divisionDeptPartCd"));
								setTimeout(EVF.C('PART_CD').setValue(data.PART_CD,false),300);
						}
					});
				}
			});
			EVF.C("CPO_USER_TEL_NUM").setValue(data.TEL_NUM);
			EVF.C("CPO_USER_CELL_NUM").setValue(data.CELL_NUM);
			EVF.C("CPO_USER_EMAIL").setValue(data.EMAIL);

			// var allRowId = grid.getAllRowId();
			// for(var i in allRowId) {
			// 	var rowId = allRowId[i];
			// 	grid.setCellValue(rowId, "CPO_USER_ID", EVF.V("CPO_USER_ID"));
			// 	grid.setCellValue(rowId, "CPO_USER_NM", EVF.V("CPO_USER_NM"));
			// 	grid.setCellValue(rowId, "CPO_USER_DIVISION_CD", data.DIVISION_CD);
			// 	grid.setCellValue(rowId, "CPO_USER_DEPT_CD", data.DEPT_CD);
			// 	grid.setCellValue(rowId, "CPO_USER_PART_CD", data.PART_CD);
			// }
			Checkevent = 'N';
		}

		function onSearchPlantB() {
			if( EVF.V("CUST_CD") == "" ) return alert("${BOD1_020_001}");
			var param = {
				callBackFunction : "callBackPlantB",
				custCd: EVF.V("CUST_CD")
			};
			everPopup.openCommonPopup(param, 'SP0005');
		}

		function callBackPlantB(data) {
			jsondata = JSON.parse(JSON.stringify(data));
			EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
			EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
		}

		function searchCustUserIdB() {
			if( EVF.V("CUST_CD") == "" ) return alert("${BOD1_020_001}");
			var param = {
				callBackFunction : "callbackCustUserIdB",
				custCd: EVF.V("CUST_CD"),
				plantCd : EVF.V("PLANT_CD")
			};
			everPopup.openCommonPopup(param, 'SP0083');
		}

		function callbackCustUserIdB(data) {
			EVF.C("CPO_USER_ID").setValue(data.USER_ID);
			EVF.C("CPO_USER_NM").setValue(data.USER_NM);
			EVF.C("CPO_USER_DEPT_NM").setValue(data.DEPT_NM);
			EVF.C("CPO_USER_TEL_NUM").setValue(data.TEL_NUM);
			EVF.C("CPO_USER_CELL_NUM").setValue(data.CELL_NUM);
			EVF.C("CPO_USER_EMAIL").setValue(data.EMAIL);
		}

    </script>

    <e:window id="BOD1_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form1" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false">
            <e:inputHidden id="approvalFormData" name="approvalFormData" />
            <e:inputHidden id="approvalGridData" name="approvalGridData" />
            <e:inputHidden id="attachFileDatas"  name="attachFileDatas" />



            <e:inputHidden id="JOB_TYPE"  name="JOB_TYPE" value="X"/>

            <c:choose>
            	<%-- 고객사 화면에서 주문 일괄등록 --%>
                <c:when test="${ses.userType == 'B'}">
                    <e:row>
                    	<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
		                <e:field>
                            <e:inputHidden id="CUST_CD_ORI" name="CUST_CD_ORI" value="${ses.companyCd}"/>
                            <e:inputHidden id="PR_BUYER_CD" name="PR_BUYER_CD" value="${ses.companyCd}"/>
                            <e:inputHidden id="BUDGET_FLAG" name="BUDGET_FLAG"/>
                            <e:inputHidden id="AUTO_PO_FLAG" name="AUTO_PO_FLAG" value="0"/>
		                    <e:search id="CUST_CD" name="CUST_CD" value="${ses.companyCd}" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="true" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
		                    <e:inputText id="CUST_NM" name="CUST_NM" value="${ses.companyNm}" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
		                </e:field>
		                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		                <e:field>
		                    <e:search id="PLANT_CD" name="PLANT_CD" value="${ses.plantCd}" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlantB" disabled="true" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
		                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="${ses.plantNm}" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
		                </e:field>
		                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
		                <e:field>
                            <e:inputHidden id="CPO_USER_TEL_NUM" name="CPO_USER_TEL_NUM" value="${ses.telNum}"/>
                            <e:inputHidden id="CPO_USER_CELL_NUM" name="CPO_USER_CELL_NUM" value="${ses.cellNum}"/>
                            <e:inputHidden id="CPO_USER_EMAIL" name="CPO_USER_EMAIL" value="${ses.email}"/>
		                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="${ses.userId}" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserIdB" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
		                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="${ses.userNm}" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
		                </e:field>
                    </e:row>
                    <e:row>
						<e:label for="CPO_USER_DEPT_NM" title="${form_CPO_USER_DEPT_NM_N}" />
						<e:field>
	                        <e:inputHidden id="DIVISION_CD" name="DIVISION_CD" value="${ses.divisionCd}"/>	<!-- 사업부 -->
	                        <e:inputHidden id="DEPT_CD" name="DEPT_CD" value="${ses.deptCd}"/>	<!-- 부서 -->
	                        <e:inputHidden id="PART_CD" name="PART_CD" value="${ses.partCd}"/>	<!-- 파트(영업장) -->
							<e:inputText id="CPO_USER_DEPT_NM" name="CPO_USER_DEPT_NM" value="${ses.deptNm}" width="${form_CPO_USER_DEPT_NM_W}" maxLength="${form_CPO_USER_DEPT_NM_M}" disabled="${form_CPO_USER_DEPT_NM_D}" readOnly="${form_CPO_USER_DEPT_NM_RO}" required="${form_CPO_USER_DEPT_NM_R}" />
						</e:field>
						<e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}" />
						<e:field colSpan="3">
							<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="${form_PR_SUBJECT_W}" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
						</e:field>
                    </e:row>
                    <e:row>
						<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
						<e:field>
							<e:select id="PR_TYPE" name="PR_TYPE" value="G" options="${prTypeOptions}" width="40%" disabled="true" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
						</e:field>
						<e:label for="CPO_DATE" title="${form_CPO_DATE_N}"/>
						<e:field>
							<e:inputDate id="CPO_DATE" name="CPO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_CPO_DATE_R}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" />
						</e:field>
						<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
						<e:field>
							<e:inputDate id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" value="${hopeDueDate}" width="${inputDateWidth}" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
						</e:field>
                    </e:row>
                    <e:row>
						<e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}"/>
						<e:field>
							<e:search id="CSDM_SEQ" name="CSDM_SEQ" value="${ses.csdmSeq}" width="40%" maxLength="${form_CSDM_SEQ_M}" onIconClick="${form_CSDM_SEQ_RD ? 'everCommon.blank' : 'getDelyAddr'}" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
							<e:inputText id="DELY_NM" name="DELY_NM" value="${ses.delyNm}" width="60%" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="${form_DELY_NM_RO}" required="${form_DELY_NM_R}" />
	                        <e:inputHidden id="DELY_ZIP_CD"  name="DELY_ZIP_CD"  value="${delyInfo.DELY_ZIP_CD}"/>
	                        <e:inputHidden id="DELY_ADDR_1"  name="DELY_ADDR_1"  value="${delyInfo.DELY_ADDR_1}"/>
	                        <e:inputHidden id="DELY_ADDR_2"  name="DELY_ADDR_2"  value="${delyInfo.DELY_ADDR_2}"/>
	                        <e:inputHidden id="RECIPIENT_NM" name="RECIPIENT_NM" value="${delyInfo.RECIPIENT_NM}"/>
							<e:inputHidden id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${delyInfo.RECIPIENT_CELL_NUM}"/>
							<e:inputHidden id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" value="${delyInfo.RECIPIENT_EMAIL}"/>
						</e:field>
						<e:label for="PRIOR_GR_FLAG" title="${form_PRIOR_GR_FLAG_N}"/>
						<e:field>
							<e:select id="PRIOR_GR_FLAG" name="PRIOR_GR_FLAG" value="0" options="${priorGrFlagOptions}" width="40%" disabled="${form_PRIOR_GR_FLAG_D}" readOnly="${form_PRIOR_GR_FLAG_RO}" required="${form_PRIOR_GR_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
						</e:field>
						<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}" />
						<e:field>
							<e:inputText id="REG_USER_NM" name="REG_USER_NM" value="${ses.userNm }" width="40%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" />
	                        <e:inputHidden id="REG_USER_ID"  name="REG_USER_ID" value="${ses.userId }"/>
						</e:field>
					</e:row>
                </c:when>
                <%-- 운영사에서 주문 일괄등록 대행 --%>
                <c:otherwise>
                    <e:row>
                    	<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
		                <e:field>
                            <e:inputHidden id="CUST_CD_ORI"  name="CUST_CD_ORI" />
                            <e:inputHidden id="PR_BUYER_CD"  name="PR_BUYER_CD" />
                            <e:inputHidden id="BUDGET_FLAG"  name="BUDGET_FLAG" />
		                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
		                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
		                </e:field>
		                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		                <e:field>
		                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
		                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
		                </e:field>
		                <e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
		                <e:field>
                            <e:inputHidden id="CPO_USER_TEL_NUM" name="CPO_USER_TEL_NUM" />
                            <e:inputHidden id="CPO_USER_CELL_NUM" name="CPO_USER_CELL_NUM" />
                            <e:inputHidden id="CPO_USER_EMAIL" name="CPO_USER_EMAIL" />
		                    <e:search id="CPO_USER_ID" name="CPO_USER_ID" value="" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCustUserId" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
		                    <e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
		                </e:field>
                    </e:row>
                    <e:row>
						<%--
						<e:label for="CPO_USER_DEPT_NM" title="${form_CPO_USER_DEPT_NM_N}" />
						<e:field>
	                        <e:inputHidden id="CPO_USER_DIVISION_CD" name="CPO_USER_DIVISION_CD" value=""/>	<!-- 사업부 -->
	                        <e:inputHidden id="CPO_USER_DEPT_CD" name="CPO_USER_DEPT_CD" value=""/>	<!-- 부서 -->
	                        <e:inputHidden id="CPO_USER_PART_CD" name="CPO_USER_PART_CD" value=""/>	<!-- 파트(영업장) -->
							<e:inputText id="CPO_USER_DEPT_NM" name="CPO_USER_DEPT_NM" value="" width="${form_CPO_USER_DEPT_NM_W}" maxLength="${form_CPO_USER_DEPT_NM_M}" disabled="${form_CPO_USER_DEPT_NM_D}" readOnly="${form_CPO_USER_DEPT_NM_RO}" required="${form_CPO_USER_DEPT_NM_R}" />
						</e:field>
						--%>
						<e:label for="DIVISION_CD" title="${form_DIVISION_CD_N}"/>
						<e:field>
                            <e:select id="DIVISION_CD" name="DIVISION_CD" value="" onChange="chgDivisionCd" options="${divisionCdOptions}" width="33%" disabled="${form_DIVISION_CD_D}" readOnly="${form_DIVISION_CD_RO}" required="${form_DIVISION_CD_R}" placeHolder="" />
                            <e:select id="DEPT_CD" name="DEPT_CD" value="" onChange="chgDeptCd" options="${deptCdOptions}" width="33%" disabled="${form_DEPT_CD_D}" readOnly="${form_DEPT_CD_RO}" required="${form_DEPT_CD_R}" placeHolder="" />
                            <e:select id="PART_CD" name="PART_CD" value="" options="${partCdOptions}" width="34%" disabled="${form_PART_CD_D}" readOnly="${form_PART_CD_RO}" required="${form_PART_CD_R}" placeHolder="" />
						</e:field>
						<e:label for="PR_SUBJECT" title="${form_PR_SUBJECT_N}" />
						<e:field>
							<e:inputText id="PR_SUBJECT" name="PR_SUBJECT" value="" width="${form_PR_SUBJECT_W}" maxLength="${form_PR_SUBJECT_M}" disabled="${form_PR_SUBJECT_D}" readOnly="${form_PR_SUBJECT_RO}" required="${form_PR_SUBJECT_R}" />
						</e:field>
						<e:label for="AUTO_PO_FLAG" title="${form_AUTO_PO_FLAG_N}"/>
						<e:field>
							<e:select id="AUTO_PO_FLAG" name="AUTO_PO_FLAG" value="0" options="${autoPoFlagOptions}" width="40%" disabled="${form_AUTO_PO_FLAG_D}" readOnly="${form_AUTO_PO_FLAG_RO}" required="${form_AUTO_PO_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
						</e:field>
                    </e:row>
                    <e:row>
						<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
						<e:field>
							<e:select id="PR_TYPE" name="PR_TYPE" value="C" options="${prTypeOptions}" width="40%" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" usePlaceHolder="false"/>
						</e:field>
						<e:label for="CPO_DATE" title="${form_CPO_DATE_N}"/>
						<e:field>
							<e:inputDate id="CPO_DATE" name="CPO_DATE" value="${toDate}" width="${inputDateWidth}" toDate="HOPE_DUE_DATE" datePicker="true" required="${form_CPO_DATE_R}" disabled="${form_CPO_DATE_D}" readOnly="${form_CPO_DATE_RO}" />
						</e:field>
						<e:label for="HOPE_DUE_DATE" title="${form_HOPE_DUE_DATE_N}"/>
						<e:field>
							<e:inputDate id="HOPE_DUE_DATE" name="HOPE_DUE_DATE" fromDate="CPO_DATE" value="${hopeDueDate}" width="${inputDateWidth}" datePicker="true" required="${form_HOPE_DUE_DATE_R}" disabled="${form_HOPE_DUE_DATE_D}" readOnly="${form_HOPE_DUE_DATE_RO}" />
						</e:field>
                    </e:row>
                    <e:row>
						<e:label for="CSDM_SEQ" title="${form_CSDM_SEQ_N}"/>
						<e:field>
							<e:search id="CSDM_SEQ" name="CSDM_SEQ" value="${ses.csdmSeq}" width="40%" maxLength="${form_CSDM_SEQ_M}" onIconClick="${form_CSDM_SEQ_RD ? 'everCommon.blank' : 'getDelyAddr'}" disabled="${form_CSDM_SEQ_D}" readOnly="${form_CSDM_SEQ_RO}" required="${form_CSDM_SEQ_R}" />
							<e:inputText id="DELY_NM" name="DELY_NM" value="${ses.delyNm}" width="60%" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="${form_DELY_NM_RO}" required="${form_DELY_NM_R}" />
	                        <e:inputHidden id="DELY_ZIP_CD" name="DELY_ZIP_CD" />
	                        <e:inputHidden id="DELY_ADDR_1" name="DELY_ADDR_1" />
	                        <e:inputHidden id="DELY_ADDR_2" name="DELY_ADDR_2" />
	                        <e:inputHidden id="RECIPIENT_NM" name="RECIPIENT_NM" />
							<e:inputHidden id="RECIPIENT_CELL_NUM" name="RECIPIENT_CELL_NUM" value="${delyInfo.RECIPIENT_CELL_NUM}"/>
							<e:inputHidden id="RECIPIENT_EMAIL" name="RECIPIENT_EMAIL" value="${delyInfo.RECIPIENT_EMAIL}"/>
						</e:field>
						<e:label for="PRIOR_GR_FLAG" title="${form_PRIOR_GR_FLAG_N}"/>
						<e:field>
							<e:select id="PRIOR_GR_FLAG" name="PRIOR_GR_FLAG" value="0" options="${priorGrFlagOptions}" width="40%" disabled="${form_PRIOR_GR_FLAG_D}" readOnly="${form_PRIOR_GR_FLAG_RO}" required="${form_PRIOR_GR_FLAG_R}" placeHolder="" usePlaceHolder="false"/>
						</e:field>
						<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}" />
						<e:field>
							<e:inputText id="REG_USER_NM" name="REG_USER_NM" value="${ses.userNm }" width="40%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" />
	                        <e:inputHidden id="REG_USER_ID"  name="REG_USER_ID" value="${ses.userId }"/>
						</e:field>
					</e:row>
                </c:otherwise>
            </c:choose>
        </e:searchPanel>

        <e:panel id="leftPanel" height="fit" width="30%">
        	<div style="float: left; display: inline-block; margin-bottom: 2px;">
        		<e:buttonBar id="buttonBar1" align="right" width="100%">
					<e:button id="templetDownload" name="templetDownload" label="${templetDownload_N}" onClick="doDownloadExcel" disabled="${templetDownload_D}" visible="${templetDownload_V}"/>
				</e:buttonBar>
			</div>
			<e:text>&nbsp;&nbsp;</e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;">합 계 : </e:text>
            <e:text id="ITEM_TOT_AMT" name="ITEM_TOT_AMT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:gray;">(부가세별도)</e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;">, 선택건수 : </e:text>
            <e:text id="ITEM_TOT_CNT" name="ITEM_TOT_CNT" style="color:red;font-weight:bold;font-size:14px;"></e:text>
            <e:text style="color:red;font-weight:bold;font-size:14px;"> 건</e:text>
        </e:panel>

        <e:panel id="rightPanel" height="fit" width="70%">
            <e:buttonBar id="buttonBar" align="right" width="100%">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
                <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
                <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
                <e:button id="doOrder" name="doOrder" label="${doOrder_N}" onClick="doOrder" disabled="${doOrder_D}" visible="${doOrder_V}"/>
            </e:buttonBar>
        </e:panel>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>