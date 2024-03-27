<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BOD1/BOD104/";
		var ROW_ID;
		var mngYn = "${ses.mngYn}";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
				ROW_ID = rowId;

	        	if(colId === "CPO_USER_NM") {
	        		if(grid.getCellValue(rowId, "CPO_USER_ID") == "") {

					} else {
                        var param = {
                            callbackFunction: "",
                            USER_ID: grid.getCellValue(rowId, "CPO_USER_ID"),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
					}
	        	} else if(colId === "CPO_NO") {
                    var param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                    everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
                } else if(colId === "ITEM_CD") {
	                if(value !== ""){
	                    var param = {
	                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
	                        popupFlag: true,
	                        detailView: true
	                    };
	                    everPopup.im03_014open(param);
	                }
	            } else if (colId === "DELY_ZIP_CD") {
                    if(PROGRESS_CD !== "20") {
                        alert("${BOD1_040_002}");

                    } else {
                        var url = '/common/code/BADV_020/view';
                        var param = {
                            callBackFunction: "callbackGridDELY_ZIP_CD",
                            modalYn: false
                        };
                        //everPopup.openWindowPopup(url, 700, 600, param);
                        everPopup.jusoPop(url, param);
                    }

                } else if(colId === "REQ_TEXT_YN") {
	        	    var detailView = false;

	        	    if(PROGRESS_CD !== "20") {
                        detailView = true;
                    }

                    if(value !== "" || PROGRESS_CD === "20") {
                        var param = {
                            title: "${BOD1_040_001}",
                            callbackFunction: "callbackGridREQ_TEXT",
                            message: grid.getCellValue(rowId, "REQ_TEXT"),
                            detailView: detailView,
                            rowId : rowId
                        };

                        if(value == "Y") {
							if(detailView) {
								everPopup.openModalPopup("/common/popup/common_text_view/view", 500, 300, param);
							} else {
								everPopup.openModalPopup("/common/popup/common_text_input/view", 500, 320, param);
							}
						}
                    }
                } else if(colId === "ATTACH_FILE_NO_IMG") {
                    var attFileNum = grid.getCellValue(rowId, "ATTACH_FILE_NO");
                    var detailView = false;

                    if(PROGRESS_CD !== "20") {
                        detailView = true;
                    }

                    if(value > 0 || PROGRESS_CD === "20") {
                        var param = {
                            havePermission: !detailView,
                            attFileNum: attFileNum,
                            rowId: rowId,
                            callBackFunction: "callbackGridATTACH_FILE_NO",
                            bizType: "OM",
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                } else if(colId === "RECIPIENT_NM") {
                    /* var param = {
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ"),
                        detailView :true
                    };
                    everPopup.openPopupByScreenId("SIV1_024", 700, 450, param); */
                    if(PROGRESS_CD !== "20") {
                        alert("${BOD1_040_002}");
                    } else {
                    	var param = {
                                callBackFunction : "setGridDelyInfo",
                                CUST_CD : EVF.V("CUST_CD"),
                                detailView : false
                            };
                		everPopup.openPopupByScreenId("MY01_007", 900, 600, param);
                    }

                } else if (colId === "DELY_ZIP_CD") {
                    if(PROGRESS_CD !== "20") {
                        alert("${BOD1_040_002}");

                    } else {
                        var url = '/common/code/BADV_020/view';
                        var param = {
                            callBackFunction : "callbackGridDELY_ZIP_CD",
                            modalYn : false
                        };
                        //everPopup.openWindowPopup(url, 700, 600, param);
                        everPopup.jusoPop(url, param);
                    }
                } else if (colId == "COST_CENTER_CD") {
                	if(PROGRESS_CD !== "20") {
                        alert("${BOD1_040_002}");
                    } else {
	                    var param = {
	                        	callBackFunction: "setGridCostCenterCd",
	                        	CUST_CD: EVF.V('CUST_CD')
	                    	};
	                    everPopup.openCommonPopup(param, 'SP0116');
                    }
                }
            });

            grid.cellChangeEvent(function(rowId, colId, iRow, iCol, value, oldValue) {

                var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
                if(PROGRESS_CD !== "20") {
                    grid.setCellValue(rowId, colId, oldValue);
                    grid.checkRow(rowId, false);
                    return alert("${BOD1_040_002}");
				}

				if(colId === "CPO_QTY" && value !== oldValue) {
                    if(oldValue > 0) {
                        if(Number(oldValue) < Number(value)) {
                            alert("${BOD1_040_003}");
                            grid.setCellValue(rowId, "CPO_QTY", oldValue);
                            grid.checkRow(rowId, false);

                        } else {
                            var MOQ_QTY = Number(grid.getCellValue(rowId, "MOQ_QTY"));
                            var RV_QTY = Number(grid.getCellValue(rowId, "RV_QTY"));
                            var CPO_UNIT_PRICE = Number(grid.getCellValue(rowId, "CPO_UNIT_PRICE"));

                            if(Number(value) >= MOQ_QTY && (Number(value) === MOQ_QTY || (Number(value) - MOQ_QTY) % RV_QTY === 0)) {
                                grid.setCellValue(rowId, "CPO_ITEM_AMT", CPO_UNIT_PRICE * Number(value));
                            } else {
                                alert("${BOD1_040_005}");
                                grid.setCellValue(rowId, "CPO_QTY", Number(oldValue));
                                grid.checkRow(rowId, false);
                            }
                        }
                    } else {
                        if(value >= 0) {
                            alert("${BOD1_040_010}");
                            grid.setCellValue(rowId, "CPO_QTY", Number(oldValue));
                            grid.checkRow(rowId, false);
                        } else {
                            var CPO_UNIT_PRICE = Number(grid.getCellValue(rowId, "CPO_UNIT_PRICE"));
                            grid.setCellValue(rowId, "CPO_ITEM_AMT", CPO_UNIT_PRICE * Number(value));
                        }
                    }
				}
            });

			grid._gvo.onImageButtonClicked = function (gridObj, rowId, column, buttonIdx, name) {

                var PROGRESS_CD = grid.getCellValue(rowId, "PROGRESS_CD");
                if(PROGRESS_CD !== "20") {
                    return alert("${BOD1_040_002}");
                }

				var value;
				var mouQty = Number(grid.getCellValue(rowId, 'MOQ_QTY')); // 최소주문량
				switch (name) {
					case "downButton":
						value = grid.getCellValue(rowId, column.name);
						if(Number(value) > mouQty) {
							grid.setCellValue(rowId, column.name, Number(value) <= 0 ? 0 : Number(value) - mouQty);
						}
						break;
				}

				var itemtotAmt = 0;
				var cpoQty = Number(grid.getCellValue(rowId, "CPO_QTY")); // 주문수량
				if(cpoQty >= mouQty && (cpoQty === mouQty || cpoQty % mouQty === 0)) {
					/* if(cartQt >= mouQty && (cartQt === mouQty || (cartQt - mouQty) % rvQty === 0)) { */
					itemtotAmt = parseInt(grid.getCellValue(rowId, 'CPO_QTY')) * parseInt(grid.getCellValue(rowId, 'CPO_UNIT_PRICE'));
					grid.setCellValue(rowId, "CPO_ITEM_AMT", itemtotAmt);
				} else {
					grid.setCellValue(rowId, "CART_QT", grid.getCellValue(rowId, 'MOQ_QTY'));
					itemtotAmt = parseInt(grid.getCellValue(rowId, 'CPO_QTY')) * parseInt(grid.getCellValue(rowId, 'CPO_UNIT_PRICE'));
					grid.setCellValue(rowId, "CPO_ITEM_AMT", itemtotAmt);
					return alert("${BOD1_040_005}");
				}
			};

            grid.setColIconify("REQ_TEXT_YN", "REQ_TEXT", "comment", false);

            grid.excelExportEvent({
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
                text: "",
                expression: ["sum"],
                groupExpression: "sum"
            };
            grid.setProperty("footerVisible", val);
            grid.setRowFooter("CPO_UNIT_PRICE", footerTxt);
            grid.setRowFooter("CPO_ITEM_AMT", footerSum);

            //========================================================//
            //1. 시스템관리자 : 전체 권한
            //2. 직무의 관리자, 구매담당자 : 자신이 속한 사업장 업무만 처리할 수 있음
            //3. 나머지 : 자신이 요청한 건만 처리 가능
            if( '${superUserFlag}' != 'true' ) {
            	EVF.C('PLANT_CD').setDisabled(true);
				EVF.C('PLANT_NM').setDisabled(true);
                if( '${havePermission}' == 'true' ) {
                	EVF.C('DDP_CD').setDisabled(false);// 사업부

                	EVF.C("CPO_USER_ID").setDisabled(false);// 주문자ID
                	EVF.C("CPO_USER_NM").setDisabled(false);// 주문자명
                } else {
                	EVF.C('DDP_CD').setDisabled(true);	// 사업부

                	EVF.C("CPO_USER_ID").setDisabled(true);
                	EVF.C("CPO_USER_NM").setDisabled(true);
                }
            }
          	//========================================================//

          	grid.freezeCol("PR_SUBJECT");
			doSearch();
        }
    	//사업장 팝업
		function selectPlant(){

			var param = {
					 custCd			  : "${ses.companyCd }"
					,callBackFunction : 'callback_setPlant'
				}
			everPopup.openCommonPopup(param, 'SP0005');
		}
		function callback_setPlant(data){
			EVF.V("PLANT_NM", data.PLANT_NM);
			EVF.V("PLANT_CD", data.PLANT_CD);

		}
		//사업부 팝업
		function selectDiv(){
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PLANT_CD') === '') {
				return EVF.alert('${BOD1_040_025}');
			}
			var param = {
					 custCd			  : "${ses.companyCd }"
					,plantCd          : EVF.V('PLANT_CD')
					,callBackFunction : 'callback_setDiv'
				}
			everPopup.openCommonPopup(param, 'SP0020');
		}
		function callback_setDiv(data){
			EVF.V("DIVISION_CD", data.DIVISION_CD);
			EVF.V("DIVISION_NM", data.DIVISION_NM);

		}
		//부서 팝업
		function searchDEPT_CD() {
			<%-- 고객사를 먼저 선택해주세요 --%>
			if(EVF.V('PLANT_CD') === '') {
				return EVF.alert('${BOD1_040_025}');
			}
			<%-- 사업부를 먼저 선택해주세요 --%>
			if(EVF.V('DIVISION_CD') === '') {
				return EVF.alert('${BOD1_040_026}');
			}
			var param = {
					 custCd			  : "${ses.companyCd }"
					,plantCd          : EVF.V('PLANT_CD')
					,divisionCd       : EVF.V('DIVISION_CD')
					,callBackFunction : 'callback_setDiv'
				}
			everPopup.openCommonPopup(param, 'SP0071');
        }

        function callbackDEPT_CD(dataJsonArray) {
        	data = JSON.parse(dataJsonArray);
            EVF.C("DEPT_CD").setValue(data.DEPT_CD);
            EVF.C("DEPT_NM").setValue(data.DEPT_NM);
        }

        function callbackGridREQ_TEXT(data) {
            grid.setCellValue(data.rowId, "REQ_TEXT", data.message);
            grid.checkRow(data.rowId, true);
		}

        function callbackGridATTACH_FILE_NO(rowId, uuid, fileCount) {
			grid.setCellValue(rowId, 'ATTACH_FILE_NO', uuid);
			grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', fileCount);
        }

        function callbackGridDELY_ZIP_CD(data) {
            if (data.ZIP_CD != "") {
                grid.setCellValue(ROW_ID, "DELY_ZIP_CD", data.ZIP_CD_5);
                grid.setCellValue(ROW_ID, "DELY_ADDR_1", data.ADDR1);
                grid.setCellValue(ROW_ID, "DELY_ADDR_2", data.ADDR2);
                //grid.setCellValue(ROW_ID, "DELY_ADDR_2", "");
            }
		}

        function setGridDelyInfo(data) {
        	grid.setCellValue(ROW_ID, "CSDM_SEQ", data.CSDM_SEQ);
        	grid.setCellValue(ROW_ID, "DELY_NM", data.DELY_NM);
        	grid.setCellValue(ROW_ID, "RECIPIENT_NM", data.HIDDEN_DELY_RECIPIENT_NM);
        	grid.setCellValue(ROW_ID, "RECIPIENT_TEL_NUM", data.HIDDEN_DELY_RECIPIENT_TEL_NUM);
        	grid.setCellValue(ROW_ID, "RECIPIENT_CELL_NUM", data.HIDDEN_DELY_RECIPIENT_CELL_NUM);
        	grid.setCellValue(ROW_ID, "RECIPIENT_EMAIL", data.HIDDEN_DELY_RECIPIENT_EMAIL);
        	grid.setCellValue(ROW_ID, "RECIPIENT_FAX_NUM", data.HIDDEN_DELY_RECIPIENT_FAX_NUM);
        	grid.setCellValue(ROW_ID, "RECIPIENT_DEPT_NM", data.DELY_RECIPIENT_DEPT_NM);
        	grid.setCellValue(ROW_ID, "DELY_ZIP_CD", data.DELY_ZIP_CD);
        	grid.setCellValue(ROW_ID, "DELY_ADDR_1", data.DELY_ADDR_1);
        	grid.setCellValue(ROW_ID, "DELY_ADDR_2", data.DELY_ADDR_2);
        	grid.setCellValue(ROW_ID, "DELY_RMK", data.DELY_RMK);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + "bod1040_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                if('${ses.costCenterFlag}' == '1') {
                	grid.setColRequired("COST_CENTER_CD",true);
                }else {
                	grid.hideCol("COST_CENTER_CD",true);
                	grid.hideCol("COST_CENTER_NM",true);
                }
                /* if('${ses.plantFlag}' == '1') {
                	grid.setColRequired("PLANT_CD",true);
                }else {
                	grid.hideCol("PLANT_CD",true);
                } */
            });
        }

        function doSave() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            var cpoNo = "";
            var rows  = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].PROGRESS_CD != "20") {
                	return alert("${BOD1_040_002}");
                }
                if( cpoNo != "" && cpoNo != rows[i].CPO_NO ){
                	return alert("${BOD1_040_009}");
                }
                cpoNo = rows[i].CPO_NO;
            }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }
            if(!confirm("${BOD1_040_004}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "bod1040_doSave", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
		}

        function doCancel() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var cpoNo = "";
            var rows  = grid.getSelRowValue();
            for( var i = 0; i < rows.length; i++ ) {
                if(rows[i].PROGRESS_CD !== "20") {
                	return alert("${BOD1_040_006}");
                }
                if( cpoNo != "" && cpoNo != rows[i].CPO_NO ){
                	return alert("${BOD1_040_009}");
                }
                cpoNo = rows[i].CPO_NO;
            }

			var rowIds = grid.getSelRowId();
			for(var i in rowIds) {
				if(grid.getCellValue(rowIds[i], 'PROGRESS_CD') !== "20") {
					return alert("${BOD1_040_006}");
				}
				if( cpoNo != "" && cpoNo != grid.getCellValue(rowIds[i], 'CPO_NO') ){
					return alert("${BOD1_040_009}");
				}
				cpoNo = grid.getCellValue(rowIds[i], 'CPO_NO');
				grid.setCellValue(rowIds[i], 'O_CPO_ITEM_AMT', 0);
			}

            if(!confirm("${BOD1_040_007}")) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, "sel");
            store.load(baseUrl + "bod1040_doCancel", function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function searchCPO_USER_ID() {
        	var custCd = EVF.V("CUST_CD");

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

		function onSearchPlant() {
			if( EVF.V("CUST_CD") == "" ) return alert("${BGA2_010_0011}");
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

        function setGridCostCenterCd(data) {
            grid.setCellValue(ROW_ID, 'COST_CENTER_CD', data.COST_CENTER_CD);
            grid.setCellValue(ROW_ID, 'COST_CENTER_NM', data.COST_CENTER_NM_KOR);
        }

        function callbackMAKER_CD(data) {
            EVF.V("MAKER_CD",data.MKBR_CD);
            EVF.V("MAKER_NM",data.MKBR_NM);
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


    </script>

    <e:window id="BOD1_040" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="CUST_CD" name="CUST_CD" value="${ses.companyCd }" />
            <e:inputHidden id="FIRST_GR_FLAG" name="FIRST_GR_FLAG" value="" />
            <e:inputHidden id="MAKER_CD" name="MAKER_CD" value="" />
            <e:inputHidden id="MAKER_NM" name="MAKER_NM" value="" />

            <e:row>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
				<e:label for="DDP_CD" title="${form_DDP_CD_N}" />
				<e:field>
					<e:inputText id="DDP_CD" name="DDP_CD" value="" width="${form_DDP_CD_W}" maxLength="${form_DDP_CD_M}" disabled="${form_DDP_CD_D}" readOnly="${form_DDP_CD_RO}" required="${form_DDP_CD_R}" />
				</e:field>
				<e:label for="CPO_USER_ID" title="${form_CPO_USER_ID_N}"/>
				<e:field>
					<e:search id="CPO_USER_ID" name="CPO_USER_ID" value="${ses.userId}" width="40%" maxLength="${form_CPO_USER_ID_M}" onIconClick="searchCPO_USER_ID" disabled="${form_CPO_USER_ID_D}" readOnly="${form_CPO_USER_ID_RO}" required="${form_CPO_USER_ID_R}" />
					<e:inputText id="CPO_USER_NM" name="CPO_USER_NM" value="${ses.userNm}" width="60%" maxLength="${form_CPO_USER_NM_M}" disabled="${form_CPO_USER_NM_D}" readOnly="${form_CPO_USER_NM_RO}" required="${form_CPO_USER_NM_R}" />
				</e:field>
			</e:row>

            <e:row>
				<e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${BOD1_040_020}" value="CPO_DATE"/>
                        <e:option text="${BOD1_040_021}" value="HOPE_DUE_DATE"/>
                    </e:select>
                </e:label>
				<e:field>
					<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE }" toDate="END_DATE" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE }" fromDate="START_DATE" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="CPO_NO" title="${form_CPO_NO_N}" />
				<e:field>
					<e:inputText id="CPO_NO" name="CPO_NO" value="" width="${form_CPO_NO_W}" maxLength="${form_CPO_NO_M}" disabled="${form_CPO_NO_D}" readOnly="${form_CPO_NO_RO}" required="${form_CPO_NO_R}" />
					<e:inputHidden id="PR_SUBJECT" name="PR_SUBJECT"/>
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" useMultipleSelect="true" usePlaceHolder="false"/>
				</e:field>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field colSpan="3">
					<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
		</e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>