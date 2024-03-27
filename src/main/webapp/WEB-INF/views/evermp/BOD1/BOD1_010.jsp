<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

        var grid;
        var gridImg;
        var baseUrl = "/evermp/BOD1/BOD101/";
        var gridType;
		var gridJsonData;

        function init() {
            grid = EVF.C("grid");
            gridImg = EVF.C("gridImg");
            gridImg.setRowHeightAll(80);
            gridImg._gvo.setHeader({height:40});

            gridType = "I";

            $('#List_Div').css('display', 'none');
            $('#ImgArea_Div').css('display', 'block');
            gridImg.resize();

            gridImg._gvo.setColumnProperty('ITEM_DESC_SPEC', 'header', {'text': "상품명\n규격"});
            gridImg._gvo.setColumnProperty('MAKER_NMS', 'header', {'text': "제조사\n모델번호"});
            gridImg._gvo.setColumnProperty('BRAND_NMS', 'header', {'text': "브랜드\n원산지"});
            gridImg._gvo.setColumnProperty('VAT_REG_NM', 'header', {'text': "과세구분\n납품지역"});
            gridImg._gvo.setColumnProperty('MVIEW_QTY', 'header', {'text': "최소주문수량\n주문배수"});
            gridImg._gvo.setColumnProperty('MVIEW_UNIT', 'header', {'text': "단위\n표준납기(일)"});
            
            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "ITEM_CD") {
                    var param = {
                        ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                        CUST_CD : grid.getCellValue(rowId, "CUST_CD"),
                        APPLY_COM : grid.getCellValue(rowId, "APPLY_COM"),
                        CONT_NO : grid.getCellValue(rowId, "CONT_NO"),
                        CONT_SEQ : grid.getCellValue(rowId, "CONT_SEQ"),
                        CART_YN : true,
                        popupFlag: true,
                        detailView: false
                    };
                    everPopup.im03_014open(param);
                } else if(colId == 'ATT_FILE_CNT') {
                    if(value>0){
                        var param = {
                            attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
                            rowId: rowId,
                            detailView: true,
                            bizType: 'IT',
                            fileExtension: '*'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                    }
                } else if(colId == 'IMG_FILE_CNT') {
                    if(value>0){
                        var param = {
                            'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                            'IMG_ATT_FILE_NUM': grid.getCellValue(rowId, 'IMG_ATT_FILE_NUM'),
                            'MAIN_IMG_SQ': grid.getCellValue(rowId, 'MAIN_IMG_SQ'),
                            'popupFlag': true,
                            'detailView': true
                        };
                        everPopup.imgReadOnlyView(param);
                    }
                } else if(colId == 'SG_CTRL_USER_NM') {
					if( grid.getCellValue(rowId, 'SG_CTRL_USER_ID') == '' ) return;
					var param = {
						 callbackFunction : "",
						 USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
						 detailView : true
					 };
					 everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
    	        }
            });

			gridImg.cellClickEvent(function(rowId, colId, value) {
                if(colId == "ITEM_CD") {
                    var param = {
                        ITEM_CD: gridImg.getCellValue(rowId, "ITEM_CD"),
                        CUST_CD : gridImg.getCellValue(rowId, "CUST_CD"),
                        APPLY_COM : gridImg.getCellValue(rowId, "APPLY_COM"),
                        CONT_NO : gridImg.getCellValue(rowId, "CONT_NO"),
                        CONT_SEQ : gridImg.getCellValue(rowId, "CONT_SEQ"),
                        CART_YN : true,
                        popupFlag: true,
                        detailView: false
                    };
                    everPopup.im03_014open(param);
                } else if(colId == 'MAIN_IMG') {
                    if(gridImg.getCellValue(rowId, 'IMG_FILE_CNT')>0){
                        var param = {
                            'ITEM_CD': gridImg.getCellValue(rowId, 'ITEM_CD'),
                            'IMG_ATT_FILE_NUM': gridImg.getCellValue(rowId, 'IMG_ATT_FILE_NUM'),
                            'MAIN_IMG_SQ': gridImg.getCellValue(rowId, 'MAIN_IMG_SQ'),
                            'popupFlag': true,
                            'detailView': true
                        };
                        everPopup.imgReadOnlyView(param);
                    }
                } else if(colId == 'SG_CTRL_USER_NM') {
                    if( grid.getCellValue(rowId, 'SG_CTRL_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : gridImg.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                if(colId === "CART_QT"){
                    var mouQty = Number(grid.getCellValue(rowId, 'MOQ_QTY')); // 최소주문량
                    var rvQty = Number(grid.getCellValue(rowId, 'RV_QTY')); // 주문배수
                    var cartQt = Number(grid.getCellValue(rowId, 'CART_QT')); // 주문수량
                    var itemtotAmt = 0;
                    //if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0) && rvQty ==0) {
                    if(cartQt >= mouQty && (cartQt == mouQty || rvQty == 0 || cartQt % rvQty == 0)) {
                        itemtotAmt = parseInt(grid.getCellValue(rowId, 'CART_QT')) * parseInt(grid.getCellValue(rowId, 'UNIT_PRICE'));
                        grid.setCellValue(rowId, "CART_PRICE", itemtotAmt);
                    } else {
						if(mouQty <= rvQty) {
	                    	gridImg.setCellValue(rowId, "CART_QT", gridImg.getCellValue(rowId, 'RV_QTY'));
						} else {
	                    	gridImg.setCellValue(rowId, "CART_QT", gridImg.getCellValue(rowId, 'MOQ_QTY'));
						}
                        itemtotAmt = parseInt(grid.getCellValue(rowId, 'CART_QT')) * parseInt(grid.getCellValue(rowId, 'UNIT_PRICE'));
                        grid.setCellValue(rowId, "CART_PRICE", itemtotAmt);
                        return alert("${BOD1_010_011}");
                    }
				}
            });

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
				var cartQt = Number(grid.getCellValue(rowId, 'CART_QT')); // 주문수량
				if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0)) {
					/* if(cartQt >= mouQty && (cartQt === mouQty || (cartQt - mouQty) % rvQty === 0)) { */
					itemtotAmt = parseInt(grid.getCellValue(rowId, 'CART_QT')) * parseInt(grid.getCellValue(rowId, 'UNIT_PRICE'));
					grid.setCellValue(rowId, "CART_PRICE", itemtotAmt);
				} else {
					grid.setCellValue(rowId, "CART_QT", grid.getCellValue(rowId, 'MOQ_QTY'));
					itemtotAmt = parseInt(grid.getCellValue(rowId, 'CART_QT')) * parseInt(grid.getCellValue(rowId, 'UNIT_PRICE'));
					grid.setCellValue(rowId, "CART_PRICE", itemtotAmt);
					return alert("${BOD1_010_011}");
				}
            };

            gridImg.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                if(colId==="CART_QT"){
                    var mouQty = Number(gridImg.getCellValue(rowId, 'MOQ_QTY')); // 최소주문량
                    var rvQty = Number(gridImg.getCellValue(rowId, 'RV_QTY')); // 주문배수
                    var cartQt = Number(gridImg.getCellValue(rowId, 'CART_QT')); // 주문수량
                    var itemtotAmt = 0;
                    //if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0)) {
                    if(cartQt >= mouQty && (cartQt == mouQty || rvQty == 0 || cartQt % rvQty == 0) ) {
                        itemtotAmt = parseInt(gridImg.getCellValue(rowId, 'CART_QT')) * parseInt(gridImg.getCellValue(rowId, 'UNIT_PRICE'));
                        gridImg.setCellValue(rowId, "CART_PRICE", itemtotAmt);
                    } else {
						if(mouQty <= rvQty) {
	                    	gridImg.setCellValue(rowId, "CART_QT", gridImg.getCellValue(rowId, 'RV_QTY'));
						} else {
	                    	gridImg.setCellValue(rowId, "CART_QT", gridImg.getCellValue(rowId, 'MOQ_QTY'));
						}
                        itemtotAmt = parseInt(gridImg.getCellValue(rowId, 'CART_QT')) * parseInt(gridImg.getCellValue(rowId, 'UNIT_PRICE'));
                        gridImg.setCellValue(rowId, "CART_PRICE", itemtotAmt);
                        return alert("${BOD1_010_011}");
                    }
                }
            });

			gridImg._gvo.onImageButtonClicked = function (gridObj, rowId, column, buttonIdx, name) {

				var value;
				var mouQty = Number(gridImg.getCellValue(rowId, 'MOQ_QTY')); // 최소주문량
				switch (name) {
					case "upButton":
						value = gridImg.getCellValue(rowId, column.name);
						gridImg.setCellValue(rowId, column.name, Number(value) + mouQty);
					break;

					case "downButton":
						value = gridImg.getCellValue(rowId, column.name);
						if(Number(value) > mouQty) {
							gridImg.setCellValue(rowId, column.name, Number(value) <= 0 ? 0 : Number(value) - mouQty);
						}
					break;
				}

				var itemtotAmt = 0;
				var cartQt = Number(gridImg.getCellValue(rowId, 'CART_QT')); // 주문수량
				if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0)) {
					itemtotAmt = parseInt(gridImg.getCellValue(rowId, 'CART_QT')) * parseInt(gridImg.getCellValue(rowId, 'UNIT_PRICE'));
					gridImg.setCellValue(rowId, "CART_PRICE", itemtotAmt);
				} else {
					gridImg.setCellValue(rowId, "CART_QT", gridImg.getCellValue(rowId, 'MOQ_QTY'));
					itemtotAmt = parseInt(gridImg.getCellValue(rowId, 'CART_QT')) * parseInt(gridImg.getCellValue(rowId, 'UNIT_PRICE'));
					gridImg.setCellValue(rowId, "CART_PRICE", itemtotAmt);
					return alert("${BOD1_010_011}");
				}
			};

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridImg.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			gridImg._gvo.onShowTooltip = function (grid, index, value) {
				var column = index.column;
				var itemIndex = index.itemIndex;

				var tooltip = "";
				if (column == 'MAIN_IMG') {
					tooltip = gridImg.getCellValue(itemIndex, 'MAIN_IMG_TOOLTIP');
				}
				return tooltip;
			};

	        gridImg._gvo.onScrollToBottom = function() {

		        return;
		        doSearchLazy();
	        }

            if('${param.autoSearch}' == 'true'){
            	if(!EVF.isEmpty('${param.ITEM_DESC}') && "${param.ITEM_DESC}" != "") {
					doSearch();
				}
            	if(!EVF.isEmpty('${param.ITEM_CLS1}') && "${param.ITEM_CLS1}" != "") {
					_getItemClsNm();
				}
			};



        }

        function doSearch(){

            var flag = true;
            $('input').each(function (k, v) {
                if (!(v.type == 'hidden' || v.type == 'radio' || v.id == 'gridImg_line' || v.id == 'gridImg-search' || v.id == 'grid_line' || v.id == 'grid-search')) {
                    if (v.value != '') {
                        flag = false;
                    }
                }
            });

            /*
            if(flag) {
                return alert("${BOD1_010_004}"); // 검색조건을 한개 이상 입력하여 주시기 바랍니다.
            }
            */

            if(EVF.C("ITEM_CD").getValue().length > 0) {
				if(EVF.C("ITEM_CD").getValue().length < 4) {
					return alert("${BOD1_010_005}"); // 품목코드는 4자리 이상 입력해주세요.
				}
			}

            var store = new EVF.Store();
            store.setParameter("gridType", gridType);
            if(gridType == "I") {

                store.setGrid([gridImg]);
                store.load(baseUrl + "bod1010_doSearch", function () {
                    if(gridImg.getRowCount() == 0) {
                        alert('${msg.M0002}');
                    } else {
                    	var rowIds = gridImg.getAllRowId();
                        for (var i in rowIds) {
	                        var itemtotAmt = parseInt(gridImg.getCellValue(rowIds[i], 'CART_QT')) * parseInt(gridImg.getCellValue(rowIds[i], 'UNIT_PRICE'));
	                        gridImg.setCellValue(rowIds[i], "CART_PRICE", itemtotAmt);
                        }
                        gridImg.checkAll(false);
                    }
                });
                return;
	            new EVF.Mask().mask();
	            $.ajax({
		            url: baseUrl + "bod1010_doSearch",
					data: $('#form').find('input').serialize() + "&gridType=I",
		            success: function(data) {
			            var rowCount = JSON.parse(data).length;
			            if (rowCount == 0) {
			            	gridImg.delAllRow();
				            new EVF.Mask().unMask();
				            alert('${msg.M0002}');
			            } else {
				            gridJsonData = data;
				            gridImg._gdp.fillJsonData(data);
				            //화면에 뿌려지는 갯수 조절
				            //gridImg._gdp.fillJsonData(data, {count: 50});

				            var rowIds = gridImg.getAllRowId();
				            for (var i in rowIds) {
					            var itemtotAmt = parseInt(gridImg.getCellValue(rowIds[i], 'CART_QT')) * parseInt(gridImg.getCellValue(rowIds[i], 'UNIT_PRICE'));
					            gridImg.setCellValue(rowIds[i], "CART_PRICE", itemtotAmt);

					            qtyChange(rowIds[i], gridImg);
				            }
				            gridImg.checkAll(false);
				            new EVF.Mask().unMask();
			            }
			            //$("#ITEM_CD").val('')
		            }
	            });
            } else {
                store.setGrid([grid]);
                store.load(baseUrl + "bod1010_doSearch", function () {
                    if(grid.getRowCount() == 0) {
                        alert('${msg.M0002}');
                    }else {
                    	var rowIds = grid.getAllRowId();
                        for (var i in rowIds) {
	                        var itemtotAmt = parseInt(grid.getCellValue(rowIds[i], 'CART_QT')) * parseInt(grid.getCellValue(rowIds[i], 'UNIT_PRICE'));
	                        grid.setCellValue(rowIds[i], "CART_PRICE", itemtotAmt);

	                        qtyChange(rowIds[i], grid);
                        }
                        grid.checkAll(false);
                    }
                });
            }
        }

        function qtyChange(rowId, grid) {
			var mouQty = Number(grid.getCellValue(rowId, 'MOQ_QTY')); // 최소주문량
			var rvQty = Number(grid.getCellValue(rowId, 'RV_QTY')); // 주문배수
			var cartQt = Number(grid.getCellValue(rowId, 'CART_QT')); // 주문수량
			var itemtotAmt = 0;
			if(cartQt >= mouQty && (cartQt === mouQty || cartQt % mouQty === 0)) {
				/* if(cartQt >= mouQty && (cartQt === mouQty || cartQt % rvQty === 0)) { */
				itemtotAmt = parseInt(grid.getCellValue(rowId, 'CART_QT')) * parseInt(grid.getCellValue(rowId, 'UNIT_PRICE'));
				grid.setCellValue(rowId, "CART_PRICE", itemtotAmt);
			} else {
				grid.setCellValue(rowId, "CART_QT", grid.getCellValue(rowId, 'MOQ_QTY'));
				itemtotAmt = parseInt(grid.getCellValue(rowId, 'CART_QT')) * parseInt(grid.getCellValue(rowId, 'UNIT_PRICE'));
				grid.setCellValue(rowId, "CART_PRICE", itemtotAmt);
			}
		}

        function doSearchLazy(){
	        var newStart = gridImg.getRowCount();
			gridImg._gdp.fillJsonData(gridJsonData, {fillMode: "append", start: newStart, count: 50});

			var rowIds = gridImg.getAllRowId();
			for (var i in rowIds) {
				var itemtotAmt = parseInt(gridImg.getCellValue(rowIds[i], 'CART_QT')) * parseInt(gridImg.getCellValue(rowIds[i], 'UNIT_PRICE'));
				gridImg.setCellValue(rowIds[i], "CART_PRICE", itemtotAmt);
			}
			gridImg.checkAll(false);
        }

        function doCart(){

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            if(gridType == "I"){

                if(!gridImg.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var rowIds = gridImg.getSelRowId();
                for (var i in rowIds) {
                    if(gridImg.getCellValue(rowIds[i], "CART_QT") == "" || EVF.isEmpty(gridImg.getCellValue(rowIds[i], "CART_QT"))){
                        return alert("${BOD1_010_003}")
					}
                }
                store.setGrid([gridImg]);
                store.getGridData(gridImg, "sel");
                if(!confirm("${BOD1_010_001}")) { return; }

                store.load(baseUrl + "bod1010_IMG_doCart", function () {
                    alert(this.getResponseMessage());
                });
            }
            else {

                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var rowIds = grid.getSelRowId();
                for (var i in rowIds) {
                    if(grid.getCellValue(rowIds[i], "CART_QT") == "" || EVF.isEmpty(grid.getCellValue(rowIds[i], "CART_QT"))){
                        return alert("${BOD1_010_003}")
                    }
                }
                store.setGrid([grid]);
                store.getGridData(grid, "sel");
                if(!confirm("${BOD1_010_001}")) { return; }

                store.load(baseUrl + "bod1010_doCart", function () {
                    alert(this.getResponseMessage());
                });
			}
		}

		function doSearchCart(){
            var param = {
                MOVE_LINK_YN: "Y"
            };
            // var el = parent.parent.document.getElementById('mainIframe');
            top.pageRedirectByScreenId("BOD1_030", param);
		}

		function openConCart() {

            var itemInfo = "";

            if(gridType=="I"){
                if(!gridImg.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var rowIds = gridImg.getSelRowId();
                for( var i in rowIds ) {
                    itemCd     = gridImg.getCellValue(rowIds[i], 'ITEM_CD');
                    applyCom   = gridImg.getCellValue(rowIds[i], 'APPLY_COM');
                    contNum    = gridImg.getCellValue(rowIds[i], 'CONT_NO');
                    contSeq    = gridImg.getCellValue(rowIds[i], 'CONT_SEQ');
                    applyPlant = gridImg.getCellValue(rowIds[i], 'APPLY_COM');

                    itemInfo = itemInfo + itemCd + ":" + applyCom + ":" + contNum + ":" + contSeq + ":" + applyPlant + ",";
                }

            } else {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

                var rowIds = grid.getSelRowId();
                for( var i in rowIds ) {
                	itemCd     = gridImg.getCellValue(rowIds[i], 'ITEM_CD');
                    applyCom   = gridImg.getCellValue(rowIds[i], 'APPLY_COM');
                    contNum    = gridImg.getCellValue(rowIds[i], 'CONT_NO');
                    contSeq    = gridImg.getCellValue(rowIds[i], 'CONT_SEQ');
                    applyPlant = gridImg.getCellValue(rowIds[i], 'APPLY_COM');

                    itemInfo = itemInfo + itemCd + ":" + applyCom + ":" + contNum + ":" + contSeq + ":" + applyPlant + ",";
                }
            }

            var param = {
                itemInfo : itemInfo,
                detailView : false
            };
            everPopup.openPopupByScreenId('BOD1_032', 600, 400, param);
        }

        function doCheckBudget(){

            var param = {
                itemInfo : "",
                callBackFunction : 'setCheckBudget',
                detailView : false
            };
            everPopup.openPopupByScreenId('BOD1_031', 840, 400, param);
        }

//         function newItem(){
//             var moduleType = "RI";

//             parent.$(".e-topmenu-wrapper").removeClass("e-topmenu-selected");
//             parent.$("#"+moduleType).addClass("e-topmenu-selected");
//             parent.EVF.C("leftMenuTree").setProperty("expandAllNode", true);
//             parent.EVF.C("leftMenuTree").loadTreeForModuleType(moduleType).then(function() {
//                 var menuName = "신규품목요청";
//                 parent.$("#leftMenuTree .e-treepanel-contents").find("div[title=\""+menuName+"\"]").trigger("click");
//             }, function() {
//             });
// 		}

        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param;
            if ("${ses.buyerMySiteFlag }"=="1"){
                param = {
                    callBackFunction : "_setItemClassNm",
                    'detailView': false,
                    'multiYN' : false,
                    'ModalPopup' : true,
                    'searchYN' : true,
                    'custCd' : '${ses.companyCd}',  // 고객사코드
                    'custNm' : '${ses.companyNm}',
					'ITEM_CLS1' : EVF.V("ITEM_CLS1")
                };
			}else{
                param = {
                    callBackFunction : "_setItemClassNm",
                    'detailView': false,
                    'multiYN' : false,
                    'ModalPopup' : true,
                    'searchYN' : true,
                    'custCd' : '${ses.manageCd}',
                    'custNm' : '${BOD1_010_manaceNm}',
	                'ITEM_CLS1' : EVF.V("ITEM_CLS1")
                };
			}

            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
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

        function searchBrandCd(){
            var param = {
                callBackFunction : "selectBrandCd"
            };
            everPopup.openCommonPopup(param, 'SP0088');
        }

        function selectBrandCd(dataJsonArray) {
            EVF.V("BRAND_CD",dataJsonArray.MKBR_CD);
            EVF.V("BRAND_NM",dataJsonArray.MKBR_NM);
        }

        function doChangeGrid(){

			// Img일경우 > List로 전환
			if(gridType == "I"){
				gridType = "L";
				EVF.C('ChangeGrid').setLabel('${BOD1_010_btn2}');
				$('#List_Div').css('display', 'block');
				$('#ImgArea_Div').css('display', 'none');
				grid.resize();
				gridImg.delAllRow();
			} else {
				gridType = "I";
				EVF.C('ChangeGrid').setLabel('${BOD1_010_btn1}');
				$('#List_Div').css('display', 'none');
				$('#ImgArea_Div').css('display', 'block');
				gridImg.resize();
				grid.delAllRow();
			}
			doSearch();
		}

	</script>

	<e:window id="BOD1_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="${param.ITEM_DESC}" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
					<e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${param.ITEM_CLS1}" />
					<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
					<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
					<e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
					<e:inputHidden id="ITEM_CLS_NM" name="ITEM_CLS_NM" />
				</e:field>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="CUST_ITEM_CD" title="${form_CUST_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="CUST_ITEM_CD" name="CUST_ITEM_CD" value="" width="${form_CUST_ITEM_CD_W}" maxLength="${form_CUST_ITEM_CD_M}" disabled="${form_CUST_ITEM_CD_D}" readOnly="${form_CUST_ITEM_CD_RO}" required="${form_CUST_ITEM_CD_R}" />
				</e:field>

			</e:row>
			<e:row>
				<e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
				<e:field>
					<e:search id="MAKER_CD" style="ime-mode:inactive" name="MAKER_CD"  value="" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="${form_MAKER_CD_RO ? 'everCommon.blank' : 'searchMakerCd'}" disabled="${form_MAKER_CD_D}" readOnly="${form_MAKER_CD_RO}" required="${form_MAKER_CD_R}" />
					<e:inputText id="MAKER_NM" style="${imeMode}" name="MAKER_NM" value="" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}"/>
				</e:field>
				<e:label for="MAKER_PART_NO" title="${form_MAKER_PART_NO_N}" />
				<e:field>
					<e:inputText id="MAKER_PART_NO" name="MAKER_PART_NO" value="" width="${form_MAKER_PART_NO_W}" maxLength="${form_MAKER_PART_NO_M}" disabled="${form_MAKER_PART_NO_D}" readOnly="${form_MAKER_PART_NO_RO}" required="${form_MAKER_PART_NO_R}" />
				</e:field>
				<e:label for="BRAND_CD" title="${form_BRAND_CD_N}"/>
				<e:field>
					<e:search id="BRAND_CD" style="ime-mode:inactive" name="BRAND_CD"  value="" width="40%" maxLength="${form_BRAND_CD_M}" onIconClick="${form_BRAND_CD_RO ? 'everCommon.blank' : 'searchBrandCd'}" disabled="${form_BRAND_CD_D}" readOnly="${form_BRAND_CD_RO}" required="${form_BRAND_CD_R}" />
					<e:inputText id="BRAND_NM" style="${imeMode}" name="BRAND_NM" value="" width="60%" maxLength="${form_BRAND_NM_M}" disabled="${form_BRAND_NM_D}" readOnly="${form_BRAND_NM_RO}" required="${form_BRAND_NM_R}"/>
				</e:field>
			</e:row>
			<e:row>
                <e:label for="SEARCH_COUNT_CD" title="${form_SEARCH_COUNT_CD_N}"/>
				<e:field>
					<e:select id="SEARCH_PAGE_NO" name="SEARCH_PAGE_NO" value="1" options="${searchPageNoOptions}" width="40%" disabled="${form_SEARCH_PAGE_NO_D}" readOnly="${form_SEARCH_PAGE_NO_RO}" required="${form_SEARCH_PAGE_NO_R}" placeHolder="" usePlaceHolder="false"/>
					<e:select id="SEARCH_COUNT_CD" name="SEARCH_COUNT_CD" value="500" options="${searchCountCdOptions}" width="60%" disabled="${form_SEARCH_COUNT_CD_D}" readOnly="${form_SEARCH_COUNT_CD_RO}" required="${form_SEARCH_COUNT_CD_R}" placeHolder="" />
				</e:field>
				<e:field>
				</e:field>
				<e:field>
				</e:field>
				<e:field>
				</e:field>
				<e:field>
				</e:field>


			</e:row>


		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
			<e:text style="color:black;font-weight:bold;">${BOD1_010_TITLE1}</e:text>
			<e:button id="ChangeGrid" name="ChangeGrid" label="${ChangeGrid_N}" onClick="doChangeGrid" disabled="${ChangeGrid_D}" visible="${ChangeGrid_V}"/>
			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<e:button id="doCart" name="doCart" label="${doCart_N}" onClick="doCart" disabled="${doCart_D}" visible="${doCart_V}"/>
			<e:button id="SearchCart" name="SearchCart" label="${SearchCart_N}" onClick="doSearchCart" disabled="${SearchCart_D}" visible="${SearchCart_V}"/>
			<e:button id="openConCart" name="openConCart" label="${openConCart_N}" onClick="openConCart" disabled="${openConCart_D}" visible="${openConCart_V}"/>
<%-- 			<e:button id="newItem" name="newItem" label="${newItem_N}" onClick="newItem" disabled="${newItem_D}" visible="${newItem_V}"/> --%>
		</e:buttonBar>

		<div id="List_Div" style="width: 100%;">
			<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
		</div>
		<div id="ImgArea_Div" style="width: 100%;">
			<e:gridPanel gridType="${_gridType}" id="gridImg" name="gridImg" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridImg.gridColData}" />
		</div>

	</e:window>
</e:ui>