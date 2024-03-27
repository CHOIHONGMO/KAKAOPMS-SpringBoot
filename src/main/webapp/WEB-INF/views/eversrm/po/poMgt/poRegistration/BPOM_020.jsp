<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var gridItem, docGrid;
        var baseUrl = "/eversrm/po/poMgt/poRegistration/";

        function init() {

            gridItem = EVF.C("gridItem");
            gridItem.setProperty('panelVisible', ${panelVisible});
    		EVF.C('PO_TYPE').removeOption('DMRO'); // 국내MRO

            <c:if test="${ses.userType != 'S'}">
            	docGrid = EVF.C("docGrid");
            </c:if>

            <%-- 매뉴얼 발주일 때만 + 버튼을 노출시킨다. --%>
            if('${empty param.poWaitingList}' && EVF.C('PO_CREATE_TYPE').getValue() != 'DRAFT' && EVF.C('PO_CREATE_TYPE').getValue() != 'PR') {
                gridItem.addRowEvent(function () {
                	<%-- 부자재가 아닌 경우 행추가 가능 -(변경됨)-> 부자재인 경우도 행추가할 수 있는데 품번은 필수입력, 단가는 수정불가로 처리한다. --%>
//                    if(EVF.C('PO_TYPE').getValue() != 'SMT') {
                        if (EVF.C("PUR_ORG_CD").getValue() == '') {
                            alert('${BPOM_020_018}');
                            return;
                        }

                        <%-- 매뉴얼 발주 시 아래의 컬럼은 수정 가능하다. --%>
                        var rowId = gridItem.addRow();
                        gridItem.setCellValue(rowId, 'PLANT_CD', EVF.C('PLANT_CD').getValue());

                        if(EVF.C('PO_TYPE').getValue() == 'SMT') /* 부자재인 경우 단가수정 등을 못하도록 막는다. */ {
                            gridItem.setCellReadOnly(rowId, 'PLANT_CD', false);
                            gridItem.setCellReadOnly(rowId, 'ITEM_CD', false);
                            gridItem.setCellReadOnly(rowId, 'UNIT_PRC', true);
                            gridItem.setCellReadOnly(rowId, 'ITEM_DESC', true);
                            gridItem.setCellReadOnly(rowId, 'ITEM_SPEC', true);
                            gridItem.setCellReadOnly(rowId, 'MAKER', true);
                            gridItem.setCellReadOnly(rowId, 'ORDER_UNIT_CD', true);
                            gridItem.setColRequired('ITEM_CD', true);
                        } else {
                            gridItem.setCellReadOnly(rowId, 'PLANT_CD', false);
                            gridItem.setCellReadOnly(rowId, 'ITEM_DESC', false);
                            gridItem.setCellReadOnly(rowId, 'ITEM_SPEC', false);
                            gridItem.setCellReadOnly(rowId, 'MAKER', false);
                            gridItem.setCellReadOnly(rowId, 'ORDER_UNIT_CD', false);
                        }


//                    } else {
                        <%--return alert('${BPOM_020_024}')--%>
//                    }

                    poTypeRequired();
                });
            }

            gridItem.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12      <%-- // 이미지의 너비. --%>
                    , imgHeight: 0.26      <%-- // 이미지의 높이. --%>
                    , colWidth: 20        <%-- // 컬럼의 넓이. --%>
                    , rowSize: 500       <%-- // 엑셀 행에 높이 사이즈. --%>
                    , attachImgFlag: false     <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            });

            gridItem.cellClickEvent(function (rowId, colId, value, iRow, iCol) {

                if ('${param.detailView}' === 'true' && (colId === 'DELY_TO_CD_NM' || colId === 'ACCOUNT_NM' || colId === 'COST_DEPT_NM' || colId === 'PLANT_NM')) {
                    return;
                }

                switch (colId) {

                    case 'ITEM_CD':

                        if(EVF.C('PO_TYPE').getValue() == 'SMT' && '${param.detailView}' != 'true') /* 부자재이고, 수정가능한 상태일 때는 품번을 직접입력할 수 있도록 한다. */ {
                            return;
                        }

                        if ("${ses.userType}" != 'S') {
                            var itemCd = gridItem.getCellValue(rowId, 'ITEM_CD');

                            var gateCd = '${ses.gateCd}';
                            if (itemCd === '') {
                                return;
                            }
                            everPopup.openPopupByScreenId('BBM_040', 1200, 600, {GATE_CD: gateCd, ITEM_CD: itemCd});
                        }
                        break;

                    case 'DELY_TO_CD_NM':
                        if ('${param.detailView}' != 'true') {
                            everPopup.openCommonPopup({callBackFunction: 'delyToCodeCallback', nRow: nRow}, 'SP0023');
                        }
                        break;

                    case 'EXEC_NUM':

                        var param = {
                            gateCd: '${ses.gateCd}',
                            EXEC_NUM: gridItem.getCellValue(rowId, "EXEC_NUM"),
                            popupFlag: true,
                            detailView: true
                        };

                        var exec_type = gridItem.getCellValue(rowId,'EXEC_TYPE');

                        var screenId='';
                        if(exec_type == "G") {
                            screenId='BFAR_020';
                        } else if(exec_type == "C") {
                            screenId='DH0630';
                        } else if(exec_type == "O") {
                            screenId='DH0600';
                        } else if(exec_type == "S") {
                            screenId='DH0540';
                        } else if(exec_type == "U") {
                            screenId='DH0550';
                        }

                        everPopup.openPopupByScreenId(screenId, 1200, 800, param);

                        break;

                    case 'ACCOUNT_NM':
                        if ('${param.detailView}' != 'true') {
        					if (EVF.C('PO_TYPE').getValue() == '') {
        						alert('${BPOM_020_013}');
        						return;
        					}

                            var purc_type = EVF.C('PO_TYPE').getValue();
                            // 구매유형이 "수선,제작"는 계정 및 자재그룹을 함께 표시함
							if (purc_type == 'AS' || purc_type == 'NEW') {
								var flag = "";
								if (purc_type == 'AS') flag = 'S';
								else flag = 'M';

	                        	var param = {
	                                    'callBackFunction': 'setAccount',
	                                    'detailView': false,
	                                    'rowId': rowId,
	                                    'PURC_FLAG' : flag
	                                };
	                                everPopup.openCommonPopup(param, "SP0035");
							} else {
	                        	var param = {
	                                    'callBackFunction': 'setAccount1',
	                                    'detailView': false,
	                                    'rowId': rowId
	                                };
	                                everPopup.openCommonPopup(param, "SP0048");
							}
                        }
                        break;

                    case 'COST_NM':
                        if ('${param.detailView}' != 'true') {
                            if (EVF.isEmpty(gridItem.getCellValue(rowId, "PLANT_CD"))) {
                                return alert('${BPOM_020_002}');
                            }
                            var param = {
                                'callBackFunction': 'setCost',
                                'detailView': false,
                                'rowId': rowId,
                                'PLANT_CD': gridItem.getCellValue(rowId, "PLANT_CD")
                            };
                            everPopup.openCommonPopup(param, "SP0036");
                        }
                        break;

                    case 'PR_NUM':
                        var prNum = gridItem.getCellValue(rowId, 'PR_NUM');
                        if (prNum === '') {
                            return;
                        }
                        var param = {
                            gate_cd: '${ses.gateCd}',
                            prNum: prNum,
                            detailView: true
                        };
                        everPopup.openPRDetailInformation(prNum);
                        break;

                    case 'QTA_NUM':

                        if (gridItem.getCellValue(rowId,'QTA_NUM') == '') return;
                        var param = {
                            gateCd: '${ses.gateCd}',
                            qtaNum : gridItem.getCellValue(rowId,'QTA_NUM'),
                            vendorCd: gridItem.getCellValue(rowId,'VENDOR_CD'),
                            "popupFlag": true,
                            detailView: true,
                            "isPrefferedBidder": false
                        };
                        everPopup.openPopupByScreenId('DH2140', 1000, 800, param);

                        break;

                    case 'RFX_NUM':
        				if (gridItem.getCellValue(rowId, "RFX_NUM") == '') {
        					return;
        				}
                        var param = {
                            gateCd: gridItem.getCellValue(rowId, "GATE_CD"),
                            rfxNum: gridItem.getCellValue(rowId, "RFX_NUM"),
                            rfxCnt: gridItem.getCellValue(rowId, "RFX_CNT"),
                            rfxType: gridItem.getCellValue(rowId, "RFX_TYPE"),
                            popupFlag: true,
                            detailView: true
                        };
                        everPopup.openRfxDetailInformation(param);
                        break;

                    default:
                        return;
                }
            });

			docGrid.cellClickEvent(function(rowId, celname, value, iRow, iCol) {
                var userwidth  = 810; // 고정(수정하지 말것)
    			var userheight = (screen.height - 2);
    			if (userheight < 780) userheight = 780; // 최소 780
    			var LeftPosition = (screen.width-userwidth)/2;
    			var TopPosition  = (screen.height-userheight)/2;
    			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

				switch (celname) {
	                case 'APRV_URL':
    	            	if ('${param.detailView}' == 'true' && docGrid.getCellValue(rowId, celname) != '' && docGrid.getCellValue(rowId, celname).length > 200) {
        	            	window.open(docGrid.getCellValue(rowId, celname), "signwindow", gwParam);
            	        }
                	    break;
					default:
				}
			});

            gridItem.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
                switch (colId) {

                    case 'ITEM_CD':

                        if(EVF.C('PO_TYPE').getValue() == 'SMT') /* 부자재일 경우 품번 입력 시 존재하는 품목의 경우 데이터를 가져와 자동셋팅한다. */ {

                            if(EVF.isEmpty(newValue)) { return; }
                            if(EVF.isEmpty(EVF.C('PUR_ORG_CD').getValue())) {
                                gridItem.setCellValue(rowId, 'ITEM_CD', oldValue);
                                return alert('${BPOM_020_018}');
                            }
                            if(EVF.isEmpty(EVF.C('VENDOR_CD').getValue())) {
                                gridItem.setCellValue(rowId, 'ITEM_CD', oldValue);
                                return alert('${BPOM_020_014}');
                            }
                            if(EVF.isEmpty(gridItem.getCellValue(rowId, 'PLANT_CD'))) {
                                gridItem.setCellValue(rowId, 'ITEM_CD', oldValue);
                                return alert('${BPOM_020_002}');
                            }

                            var store = new EVF.Store();
                            store.setParameter('PUR_ORG_CD', EVF.C('PUR_ORG_CD').getValue());
                            store.setParameter('VENDOR_CD', EVF.C('VENDOR_CD').getValue());
                            store.setParameter('PLANT_CD', gridItem.getCellValue(rowId, 'PLANT_CD'));
                            store.setParameter('ITEM_CD', newValue);
                            store.load(baseUrl+'BPOM_020/getItemInfo', function() {
                                var itemInfo = JSON.parse(this.getParameter('itemInfo'));

                                if(!itemInfo) {
                                    gridItem.setCellValue(rowId, 'ITEM_CD', oldValue);
                                    return alert('${BPOM_020_029}');
                                }

                                gridItem.setCellValue(rowId, 'ITEM_DESC', itemInfo.ITEM_DESC);
                                gridItem.setCellValue(rowId, 'ITEM_SPEC', itemInfo.ITEM_SPEC);
                                gridItem.setCellValue(rowId, 'MAKER', itemInfo.MAKER);
                                gridItem.setCellValue(rowId, 'ORDER_UNIT_CD', itemInfo.UNIT_CD);
                                gridItem.setCellValue(rowId, 'UNIT_PRC', itemInfo.UNIT_PRC);
                                gridItem.setCellValue(rowId, 'TOP_ITEM_CD', itemInfo.TOP_ITEM_CD);
                                gridItem.setCellValue(rowId, 'EO_NO', itemInfo.EO_NO);
                                gridItem.setCellValue(rowId, 'ITEM_REVISION', itemInfo.ITEM_REVISION);
                                gridItem.setCellValue(rowId, 'ITEM_USAGE', itemInfo.ITEM_USAGE);
                                gridItem.setCellValue(rowId, 'BUYER_REQ_CD', '${ses.companyCd}');
                                gridItem.setCellValue(rowId, 'BUYER_CD', itemInfo.BUYER_CD);
                                gridItem.setCellValue(rowId, 'CTRL_CD', '${ses.ctrlCd}');
                                gridItem.setCellValue(rowId, 'INFO_YN', (EVF.isEmpty(itemInfo.UNIT_PRC) || itemInfo.UNIT_PRC == 0) ? '0' : '1');
                                gridItem.setCellValue(rowId, 'ITEM_AMT', ( Number(gridItem.getCellValue(rowId, 'PO_QT')) * Number(itemInfo.UNIT_PRC)) );

                            });
                        }


                        break;
                    case 'PLANT_CD':
                        gridItem.setCellValue(rowId, 'ACCOUNT_CD', '');
                        gridItem.setCellValue(rowId, 'ACCOUNT_NM', '');
                        gridItem.setCellValue(rowId, 'COST_CD', '');
                        gridItem.setCellValue(rowId, 'COST_NM', '');
                        gridItem.setCellValue(rowId, 'MAT_GROUP', '');
                        gridItem.setCellValue(rowId, 'MAT_GROUP_NM', '');

                        if(EVF.C('PO_TYPE').getValue() == 'SMT') /* 부자재일 경우 플랜트 변경 시 아래의 필드 초기화시킨다. */ {
                            gridItem.setCellValue(rowId, 'PO_QT', 0);
                            gridItem.setCellValue(rowId, 'ITEM_CD', '');
                            gridItem.setCellValue(rowId, 'ITEM_DESC', '');
                            gridItem.setCellValue(rowId, 'ITEM_SPEC', '');
                            gridItem.setCellValue(rowId, 'MAKER', '');
                            gridItem.setCellValue(rowId, 'ORDER_UNIT_CD', '');
                            gridItem.setCellValue(rowId, 'UNIT_PRC', 0);
                            gridItem.setCellValue(rowId, 'TOP_ITEM_CD', '');
                            gridItem.setCellValue(rowId, 'EO_NO', '');
                            gridItem.setCellValue(rowId, 'ITEM_REVISION', '');
                            gridItem.setCellValue(rowId, 'ITEM_USAGE', '');
                            gridItem.setCellValue(rowId, 'BUYER_REQ_CD', '');
                            gridItem.setCellValue(rowId, 'BUYER_CD', '');
                            gridItem.setCellValue(rowId, 'CTRL_CD', '');
                            gridItem.setCellValue(rowId, 'INFO_YN', '');
                            gridItem.setCellValue(rowId, 'ITEM_AMT', 0);
                        }

                        break;
                    case 'UNIT_PRC':
                    case 'PO_QT':
                        if (EVF.getComponent('CUR').getValue() === '') {
                            alert('${BPOM_020_CHOOSE_CUR}');
                            gridItem.setCellValue(rowId, colId, oldValue);
                            return;
                        }
                        if (Number(newValue) < 0) {
                            alert('${BPOM_020_INPUT_VALUE_LESS}');
                            gridItem.setCellValue(rowId, colId, oldValue);
                            return;
                        }
                        var currency = EVF.getComponent('CUR').getValue();
                        var price = gridItem.getCellValue(rowId, "UNIT_PRC");
                        var qty = gridItem.getCellValue(rowId, "PO_QT");
                        gridItem.setCellValue(rowId, "ITEM_AMT", everCurrency.getAmount(currency, price * qty));

                        calculateSum();
                        break;

                    case 'TAX_CD':
                    case 'INVEST_CD':
                    case 'CAR_GROUP_CD':

                            var rowCnt = gridItem.getRowCount();
                            if(rowCnt > 1) {
                                if(confirm('${BPOM_020_028}')) {

                                    var allRowId = gridItem.getAllRowId();
                                    for(var i in allRowId) {

                                        var ri = allRowId[i];
                                        gridItem.setCellValue(ri, colId, newValue);
                                    }
                                }
                            }

                        break;

                    default:
                        return;
                }
            });

            // 협력회사에서 조회하는 경우 컬럼 hidden처리함
            if (${ses.userType == 'S'}) {
                gridItem.hideCol('ACCOUNT_NM', true);
                gridItem.hideCol('COST_NM', true);
                gridItem.hideCol('MAT_GROUP_NM', true);
                gridItem.hideCol('TAX_CD', true);
                gridItem.hideCol('INVEST_CD', true);
                gridItem.hideCol('CAR_GROUP_CD', true);
                gridItem.hideCol('EXEC_NUM', true);
                gridItem.hideCol('QTA_NUM', true);
            } else {
                docGrid.setProperty('shrinkToFit', true);
                docGrid.addRowEvent(function () {
                    docGrid.addRow();
                });

                docGrid.delRowEvent(function () {
                    docGrid.delRow();
                });
            }

            chPurchaseType();

            var poCreateTypeObj = EVF.C('PO_CREATE_TYPE');
            if (EVF.isEmpty(poCreateTypeObj.getValue())) {
                if (${not empty param.poWaitingList}) {
                    poCreateTypeObj.setValue('DRAFT'); // 품의발주
                } else {
                    poCreateTypeObj.setValue('MANUAL'); // 매뉴얼발주
                }
            }

        	if (poCreateTypeObj.getValue() == 'DRAFT' || poCreateTypeObj.getValue() == 'PR') /* 품의발주일 때 */ {
                EVF.C('PO_TYPE').setDisabled(true);
                EVF.C('SHIPPER_TYPE').setDisabled(true);
                EVF.C('CUR').setDisabled(true);
        	} else {
    		    // 메뉴얼 발주인 경우 품목추가(+) 가능
    		    /*
    		    grid.addRowEvent(function () {
    				var param = [{
    					'PLANT_CD': "${ses.plantCd}",
    					'INSERT_FLAG' : 'I'
    				}];
    		        grid.addRow(param);
    				grid.setCellReadOnly(grid.getRowCount()-1, 'ITEM_DESC', false);
    		    });
				*/
        		gridItem.hideCol('EXEC_NUM', true);
                gridItem.hideCol('QTA_NUM', true);

				// 발주변경 화면에서 진행상태가 확정요청(200), 협력회사전송(300)인 경우에는 "구매유형" 수정할 수 없도록 함
				if ('${param.progressCode}' == '200' || '${param.progressCode}' == '300') {
		            EVF.C('PO_TYPE').setDisabled(true);
				}
        	}

            if (${not empty param.poWaitingList} || ${not empty param.poNum}) {
                doSearch();
            }

            EVF.C('payListJsonData').setValue(JSON.stringify(${payListJsonData}));
        }

        function setCellEditStatus() {

            if('${param.detailView}' != 'true') {

                var poCreateType = EVF.C('PO_CREATE_TYPE').getValue();
                var allRowId = gridItem.getAllRowId();
                for(var i in allRowId) {

                    var rowId = allRowId[i];
                    if(EVF.isNotEmpty(gridItem.getCellValue(rowId, 'PO_NUM'))) {

                        gridItem.setCellReadOnly(rowId, 'PO_QT', true);
                    } else {
                        gridItem.setCellReadOnly(rowId, 'PO_QT', false);
                    }

                    /* 품의발주는 플랜트, 단가 수정 불가, 매뉴얼발주는 단가계약없을 시에만 수정 가능 */
                    if(poCreateType == 'DRAFT' || poCreateType == 'PR') {

                        gridItem.setCellReadOnly(rowId, 'PLANT_CD', true);
                        gridItem.setCellReadOnly(rowId, 'UNIT_PRC', true);
                    } else {

                        var infoYn = gridItem.getCellValue(rowId, 'INFO_YN');
                        if(infoYn == '1') {
                            gridItem.setCellReadOnly(rowId, 'PLANT_CD', true);
                            gridItem.setCellReadOnly(rowId, 'UNIT_PRC', true);
                        } else {
                            gridItem.setCellReadOnly(rowId, 'PLANT_CD', false);
                            gridItem.setCellReadOnly(rowId, 'UNIT_PRC', false);

                            gridItem.setCellReadOnly(rowId, 'ITEM_DESC', false);
                            gridItem.setCellReadOnly(rowId, 'ITEM_SPEC', false);
                            gridItem.setCellReadOnly(rowId, 'MAKER', false);
                            gridItem.setCellReadOnly(rowId, 'PO_QT', false);
                            gridItem.setCellReadOnly(rowId, 'ORDER_UNIT_CD', false);
                        }
                    }
                }

                var purchaseType = EVF.C('PO_TYPE').getValue();
                /* 부품은 계정코드, 코스트센터, 세금코드 필수입력 아님: 그리드에 데이터 없을 때 setColRequired가 적용되지 않아 setItem 시 적용되도록 코드 중복화됨 -> 계정, 코스트센터의 필수입력을 제외하라고 해서 주석처리('15.12.17) */
//                gridItem.setColRequired("ACCOUNT_CD", purchaseType == 'NORMAL' ? false : true);
//                gridItem.setColRequired("ACCOUNT_NM", purchaseType == 'NORMAL' ? false : true);
//                gridItem.setColRequired("COST_CD", purchaseType == 'NORMAL' ? false : true);
//                gridItem.setColRequired("COST_NM", purchaseType == 'NORMAL' ? false : true);
                gridItem.setColRequired("TAX_CD", purchaseType == 'NORMAL' ? false : true);
            }
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([gridItem]);
            store.setParameter('poWaitingList', '${param.poWaitingList}');
            store.load(baseUrl + 'BPOM_020/doSearch', function () {

                calculateSum();
                doSearchGroupwareDocs();
                setCellEditStatus();
            });
        }

        function doSearchGroupwareDocs() {

            var store = new EVF.Store();
            store.setGrid([docGrid]);
            store.setParameter('poWaitingList', '${param.poWaitingList}');
            store.load(baseUrl + 'BPOM_020/doSearchGroupwareDocs', function () {

            }, false);
        }

        function _checkSaveCondition() {

            gridItem.checkAll(true);
            docGrid.checkAll(true);

            /* 납품유형이 검수(PI)이고, (대금지불조건)PAY_TYPE==''이면 필수체크 */
            if (EVF.C('DELIVERY_TYPE').getValue() == 'PI') {

                var popyParam = EVF.C('PAY_TYPE').getValue();
                if (EVF.isEmpty(popyParam)) {
                    alert('${BPOM_020_008}');
                    return false;
                }

                var payTypeAmt = Number(EVF.C('PAY_TYPE_AMT').getValue());
                var poAmt = Number(EVF.C('PO_AMT').getValue());
                if(payTypeAmt != poAmt) {
                    alert('${BPOM_020_015}');
                    return false;
                }
            }





            var validateation = gridItem.validate();
            if (!validateation.flag) {
                alert(validateation.msg);
                return;
            }

            var baseData = gridItem.getRowValue(0);
            var allRowId = gridItem.getAllRowId();
            var poType = EVF.C('PO_TYPE').getValue();
            for(var i in allRowId) {
                var rowId = allRowId[i];

            	// 구매유형이 "수선, 제작"인 경우 계정 및 코스트센터 필수
				if ((poType == 'AS' || poType == 'NEW') && (gridItem.getCellValue(rowId, 'ACCOUNT_CD') == '' || gridItem.getCellValue(rowId, 'COST_CD') == '')) {
                    alert('${BPOM_020_030}');
                    return false;
				}
                if(baseData['PLANT_CD'] != gridItem.getCellValue(rowId, 'PLANT_CD')) {
                    alert('${BPOM_020_019}');
                    return false;
                }

                var purchaseType = EVF.C('PO_TYPE').getValue();
                if (purchaseType == 'NORMAL') /* 부품은 계정코드, 코스트센터, 세금코드 필수입력 */ {
                } else {
                    if(EVF.isEmpty(gridItem.getCellValue(rowId, 'TAX_CD'))  ) {
                        alert('${BPOM_020_0031}');
                        return false;
                    }
                }
            }
            return true;
        }

        function doSave() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if(!_checkSaveCondition()) {
                return;
            }

            if (!confirm('${msg.M0021}')) return;

            store.setGrid([gridItem, docGrid]);
            store.getGridData(gridItem, 'all');
            store.getGridData(docGrid, 'all');

            store.doFileUpload(function () {
                store.load(baseUrl + 'BPOM_020/doSave', function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    if(opener) {
                        if ('${param.callBackFunction}' !== '') {
                            opener.window['${param.callBackFunction}']();
                        }
                    }
                    document.location.href = baseUrl + "BPOM_020/view.so?poNum=" + this.getParameter('poNum') + '&popupFlag=${param.popupFlag}';
                });
            });
        }

        function doRequestConfirm() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if(!_checkSaveCondition()) {
                return;
            }

            if (!confirm('${BPOM_020_010}')) return;

            store.setGrid([gridItem, docGrid]);
            store.getGridData(gridItem, 'all');
            store.getGridData(docGrid, 'all');

            store.doFileUpload(function () {
                store.load(baseUrl + 'BPOM_020/doRequestConfirm', function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                	alert(this.getResponseMessage());

                    if(opener) {
                        doClose();
                    } else {
                        document.location.href = baseUrl + "BPOM_020/view";
                    }
                });
            });
        }

        function doRejectConfirm() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if(!confirm('${BPOM_020_023}')) {
                return;
            }

            store.doFileUpload(function () {
                store.load(baseUrl + 'BPOM_020/doRejectConfirm', function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    if(opener) {
                        doClose();
                    } else {
                        document.location.href = baseUrl + "BPOM_020/view";
                    }
                });
            });

        }

        function doSend() {

			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            if(!_checkSaveCondition()) {
                return;
            }

            // 일반구매의 협력회사전송은 발주확정자만 가능함
            if(EVF.C('PO_TYPE').getValue() != 'NORMAL') {
                if ('${ses.userId}' != EVF.C('PO_APRV_ID').getValue()) {
                    alert('${BPOM_020_005}');
                    return false;
                }
            }

            if (!confirm('${BPOM_020_011}')) return;

            var popupUrl = "/eversrm/master/vendor/BBV_060/view";
            var param = {
                'callBackFunction': '_setvendormaster',
                'onClose': 'closePopup',
                'detailView' : false,
                'vendorCdParams': EVF.C("VENDOR_CD").getValue()

            };

            everPopup.openPopupByScreenId('BBV_060', 1100, 380, param);
            //everPopup.openWindowPopup(popupUrl, 1100, 380, param, '');
        }

        //협력회사전송
        function doSaveE(){

            var store = new EVF.Store();

            store.setGrid([gridItem, docGrid]);
            store.getGridData(gridItem, 'all');
            store.getGridData(docGrid, 'all');

            store.doFileUpload(function () {
                store.load(baseUrl + 'BPOM_020/doSend', function () {
                    EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    var respCode = this.getResponseCode();
                    if(respCode === 'SAVE_ERROR') {

                    } else if(respCode === 'SEND_ERROR') {

                        var poNum = this.getParameter('poNum');
                        if(EVF.isNotEmpty(poNum)) {
                            document.location.href = baseUrl + "BPOM_020/view.so?poNum="+poNum;
                        }

                    } else {

                        if(opener) {
                            doClose();
                        } else {
                            document.location.href = baseUrl + "BPOM_020/view";
                        }
                    }
                });
            });
        }

        function _setvendormaster(selectedData) {
            EVF.C('vendorMasterList').setValue(selectedData);
            doSaveE();
        }

        function doDelete() {

            if (everString.isEmpty(EVF.getComponent('PO_NUM').getValue())) {
                alert("${msg.M0118}");
                return;
            }

            var confirmMsg = '${msg.M0013}';

            if (!confirm(confirmMsg)) return;

            gridItem.checkAll(true);

            var store = new EVF.Store();
            store.setGrid([gridItem]);
            store.getGridData(gridItem, 'all');
            store.load(baseUrl + 'BPOM_020/doDelete', function () {
                alert(this.getResponseMessage());

                EVF.getComponent('PO_NUM').setValue('');
                if(opener) {
                    doClose();
                } else {
                    document.location.href = baseUrl + "BPOM_020/view";
                }
            });
        }

        function doClose() {

            if (opener && opener['doSearch']) {
                opener['doSearch']();
            }
            formUtil.close();
        }

        function doSearchVendor() {
            var param = {
                callBackFunction: "selectVendor",
                BUYER_CD: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0025');
        }

        function selectVendor(dataJsonArray) {
            EVF.getComponent('VENDOR_CD').setValue(dataJsonArray['VENDOR_CD']);
            EVF.getComponent('VENDOR_NM').setValue(dataJsonArray['VENDOR_NM']);
            EVF.C('PAY_TERMS').setValue(dataJsonArray['PAY_TERMS']);
        }

        function doSearchBuyer() {
        	// 구매조직 선택 후 검수자 조회
        	if (EVF.C('PUR_ORG_CD').getValue() == '') {
                alert('${BPOM_020_018}');
                return;
        	}
            var param = {
                "title": "구매담당자 조회[플랜트]",
                "callBackFunction": "selectBuyer",
                "PLANT_CD" : EVF.C('PLANT_CD').getValue()
            };
            everPopup.openCommonPopup(param, 'SP0040');
            //everPopup.openCommonPopup(param, 'SP0040');
        }

        function selectBuyer(data) {
            EVF.getComponent("CTRL_USER_ID").setValue(data['CTRL_USER_ID']);
            EVF.getComponent("CTRL_USER_NM").setValue(data['CTRL_USER_NM']);
        }

        function doSearchInspectUser() {
        	// 구매조직 선택 후 검수자 조회
        	if (EVF.C('PUR_ORG_CD').getValue() == '') {
                alert('${BPOM_020_018}');
                return;
        	}
            var param = {
                "title": "검수자 조회[플랜트]",
                "callBackFunction": "setInspectUser",
                "PLANT_CD" : EVF.C('PLANT_CD').getValue()
            };
            everPopup.openCommonPopup(param, 'SP0040');
            //everPopup.openCommonPopup(param, 'SP0040');
        }

        function setInspectUser(data) {
            EVF.getComponent("INSPECT_USER_ID").setValue(data['CTRL_USER_ID']);
            EVF.getComponent("INSPECT_USER_NM").setValue(data['CTRL_USER_NM']);
        }

        function doSearchPoAprvUser() {
            if(EVF.C('PO_TYPE').getValue() == 'NORMAL') {
                return;
            }
        	// 구매조직 선택 후 검수자 조회
        	if (EVF.C('PUR_ORG_CD').getValue() == '') {
                alert('${BPOM_020_018}');
                return;
        	}

            var param = {
                "title": "발주확정자 조회[플랜트]",
                "callBackFunction": "setPoAprvUser",
                "PLANT_CD" : EVF.C('PLANT_CD').getValue()
            };
            everPopup.openCommonPopup(param, 'SP0040');
            //everPopup.openCommonPopup(param, 'SP0040');
        }

        function setPoAprvUser(data) {
            EVF.getComponent("PO_APRV_ID").setValue(data['CTRL_USER_ID']);
            EVF.getComponent("PO_APRV_NM").setValue(data['CTRL_USER_NM']);

            if('${ses.userId}' != data['CTRL_USER_ID']) {
                formUtil.setVisible(['doSend'], false);
            } else {
                formUtil.setVisible(['doSend'], true);
            }

        }

        function getBomItem() {

        	if (EVF.C("PO_TYPE").getValue() == '') {
        		alert('${BPOM_020_013}');
        		return;
        	}
        	if (EVF.C("PO_TYPE").getValue() != 'NORMAL') {
        		alert('${BPOM_020_012}');
        		return;
        	}

            if (EVF.C("PUR_ORG_CD").getValue() == '') {
                alert('${BPOM_020_018}');
                return;
            }

        	if (EVF.C("VENDOR_CD").getValue() == '') {
        		alert('${BPOM_020_014}');
        		return;
        	}

            var param = {
                "SCREEN_OPEN_TYPE": "PO"
                , "detailView": false
                , "PURCHASE_TYPE": EVF.C("PO_TYPE").getValue()
                , "VENDOR_CD": EVF.C("VENDOR_CD").getValue()
                , "PUR_ORG_CD": EVF.C("PUR_ORG_CD").getValue()
                , "havePermission": false
                , "callBackFunction": 'setBomItem'
            };
            everPopup.openPopupByScreenId('DH1251', 1000, 550, param);
        }

        function setBomItem(paramData) {

            var data = valid.equalPopupValid(paramData, gridItem, "ITEM_CD");
            var arrData = [];
            for (var k = 0; k < data.length; k++) {

                var datum = data[k];
                var plantCd = datum.PLANT_CD;

                if (datum.PLANT_CD == '' || datum.PLANT_CD == null) {
                	//plantCd = '${ses.plantCd}';
                	plantCd = EVF.C("PLANT_CD").getValue();
                }

                arrData.push({
                     'ITEM_CD'       : datum.ITEM_CD
                    ,'ITEM_DESC'     : datum.ITEM_DESC
                    ,'ITEM_SPEC'     : datum.MATERIAL_SPEC
                    ,'MAKER'         : datum.MAKER
                    ,'ORDER_UNIT_CD' : datum.UNIT_CD
                    ,'UNIT_PRC'      : datum.UNIT_PRC
                    ,'TOP_ITEM_CD'   : datum.TOP_ITEM_CD
                    ,'EO_NO'         : datum.EO_NO
                    ,'ITEM_REVISION' : datum.ITEM_REVISION
                    ,'ITEM_USAGE'    : datum.ITEM_QT
                    ,'BUYER_REQ_CD'  : '${ses.companyCd}'
                    ,'PLANT_CD'      : plantCd
                    ,'BUYER_CD'      : datum.BUYER_CD
                    ,'CTRL_CD'       : '${ses.ctrlCd}'
                    ,'INFO_YN'       : (EVF.isEmpty(datum.UNIT_PRC) || datum.UNIT_PRC == 0) ? '0' : '1'
                });
            }
            gridItem.addRow(arrData);

            setCellEditStatus();
        }

        function getItem() {

            if (EVF.C("PO_TYPE").getValue() == '') {
                alert('${BPOM_020_013}');
                return;
            }

        	if (EVF.C("PUR_ORG_CD").getValue() == '') {
        		alert('${BPOM_020_018}');
        		return;
        	}

        	if (EVF.C("VENDOR_CD").getValue() == '') {
        		alert('${BPOM_020_014}');
        		return;
        	}

            var param = {
                "callBackFunction": "setItem",
                "SCREEN_OPEN_TYPE": "PO",
                "PURCHASE_TYPE": EVF.C("PO_TYPE").getValue(),
                "VENDOR_CD": EVF.C("VENDOR_CD").getValue(),
                "PUR_ORG_CD": EVF.C("PUR_ORG_CD").getValue(),
                "popupFlag": true,
                "detailView": false,
                "openerScreen": "BPOM_020"
            };

            everPopup.openItemCatalogPopup(param);
        }

        function setItem(paramData) {

            var data = valid.equalPopupValid(paramData, gridItem, "ITEM_CD");
            var arrData = [];
            for (var k = 0; k < data.length; k++) {

                var datum = data[k];
                var plant_cd = datum.PLANT_CD;

                if (datum.PLANT_CD == '' || datum.PLANT_CD == null) {
                	//plant_cd = '${ses.plantCd}';
                	plant_cd = EVF.C("PLANT_CD").getValue();
                }

                arrData.push({
                     'ITEM_CD'       : datum.ITEM_CD
                    ,'ITEM_DESC'     : datum.ITEM_DESC
                    ,'ITEM_SPEC'     : datum.ITEM_SPEC
                    ,'MAKER'         : datum.MAKER
                    ,'ORDER_UNIT_CD' : datum.UNIT_CD
                    ,'UNIT_PRC'      : datum.UNIT_PRC
                    ,'TOP_ITEM_CD'   : datum.TOP_ITEM_CD
                    ,'EO_NO'         : datum.EO_NO
                    ,'ITEM_REVISION' : datum.ITEM_REVISION
                    ,'ITEM_USAGE'    : datum.ITEM_QT
                    ,'BUYER_REQ_CD'  : '${ses.companyCd}'
                    ,'PLANT_CD'      : plant_cd
                    ,'BUYER_CD'      : datum.BUYER_CD
                    ,'CTRL_CD'       : '${ses.ctrlCd}'
                    ,'INFO_YN'       : (EVF.isEmpty(datum.UNIT_PRC) || datum.UNIT_PRC == 0) ? '0' : '1'
                });
            }
            gridItem.addRow(arrData);

            poTypeRequired();

            setCellEditStatus();
        }

        function calculateSum() {

            var sum = 0;
            var currency = EVF.getComponent('CUR').getValue();

            for (var i = 0; i < gridItem.getRowCount(); i++) {
                var price = gridItem.getCellValue(i, "UNIT_PRC");
                var qty = gridItem.getCellValue(i, "PO_QT");
                sum += everCurrency.getAmount(currency, price * qty);
            }
            EVF.getComponent('PO_AMT').setValue(sum);
        }

        function delyToCodeCallback(result) {
            gridItem.setCellValue(result.nRow, 'DELY_TO_CD_NM', result.DELY_TO_NM);
            gridItem.setCellValue(result.nRow, 'DELY_TO_CD', result.DELY_TO_CD);
        }

        // 수선,제작,품의의 계정조회
        function setAccount(data) {
            gridItem.setCellValue(data.rowId, "ACCOUNT_NM", data.ACCOUNT_NM);
            gridItem.setCellValue(data.rowId, "ACCOUNT_CD", data.ACCOUNT_NUM);
            gridItem.setCellValue(data.rowId, "MAT_GROUP", data.MAT_GROUP);
            gridItem.setCellValue(data.rowId, "MAT_GROUP_NM", data.MAT_GROUP_NM);

            var rowCnt = gridItem.getRowCount();
            if(rowCnt > 1) {
                if(confirm('${BPOM_020_028}')) {

                    var allRowId = gridItem.getAllRowId();
                    for(var i in allRowId) {

                        var ri = allRowId[i];
                        gridItem.setCellValue(ri, 'ACCOUNT_NM', data.ACCOUNT_NM);
                        gridItem.setCellValue(ri, 'ACCOUNT_CD', data.ACCOUNT_NUM);
                        gridItem.setCellValue(ri, 'MAT_GROUP', data.MAT_GROUP);
                        gridItem.setCellValue(ri, 'MAT_GROUP_NM', data.MAT_GROUP_NM);
                    }
                }
            }
        }

		// 수선,제작,품의 이외의 계정조회
        function setAccount1(data) {
            gridItem.setCellValue(data.rowId, "ACCOUNT_CD", data.ACCOUNT_NUM);
            gridItem.setCellValue(data.rowId, "ACCOUNT_NM", data.ACCOUNT_NM);

            var rowCnt = gridItem.getRowCount();
            if(rowCnt > 1) {
                if(confirm('${BPOM_020_028}')) {

                    var allRowId = gridItem.getAllRowId();
                    for(var i in allRowId) {

                        var ri = allRowId[i];
                        gridItem.setCellValue(ri, 'ACCOUNT_CD', data.ACCOUNT_NUM);
                        gridItem.setCellValue(ri, 'ACCOUNT_NM', data.ACCOUNT_NM);
                    }
                }
            }
        }

        function setCost(data) {
            gridItem.setCellValue(data.rowId, 'COST_CD', data.COST_CD);
            gridItem.setCellValue(data.rowId, 'COST_NM', data.COST_NM);

            var rowCnt = gridItem.getRowCount();
            if(rowCnt > 1) {
                if(confirm('${BPOM_020_028}')) {

                    var allRowId = gridItem.getAllRowId();
                    for(var i in allRowId) {

                        var ri = allRowId[i];
                        gridItem.setCellValue(ri, 'COST_CD', data.COST_CD);
                        gridItem.setCellValue(ri, 'COST_NM', data.COST_NM);
                    }
                }
            }
        }

        function openInstalments() {

    		// 납품유형이 "검수"인 경우에만 대금지불방식을 등록함
    		var deliveryType = EVF.C('DELIVERY_TYPE').getValue();
    		if (deliveryType == null || deliveryType != 'PI') {
    			alert('${BPOM_020_008}');
    			return;
    		}

    		var po_amt = EVF.C('PO_AMT').getValue();
    		if (po_amt == null || po_amt == '' || po_amt == '0') {
    			alert('${BPOM_020_009}');
    			return;
    		}

    		var params = {
                PO_NUM     : EVF.C('PO_NUM').getValue(),
                PO_AMT     : EVF.C('PO_AMT').getValue(),
                EXEC_NUM   : EVF.C('EXEC_NUM').getValue(),
                VENDOR_CD  : EVF.C('VENDOR_CD').getValue(),
                CUR        : EVF.C('CUR').getValue(),
                PAY_TYPE   : EVF.C('PAY_TYPE').getValue(),
                PAY_TYPE_CN: EVF.C('PAY_TYPE_CN').getValue(),
                PURCHASE_TYPE : EVF.C('PO_TYPE').getValue(),
                payListJsonData   : JSON.stringify(EVF.C('payListJsonData').getValue()),
                detailView : '${param.detailView}',
                callBackFunction: "setPayTypes"
    		};
            everPopup.openPopupByScreenId('BPOM_040', 800, 400, params);
        }

        // 대금지불방식 세팅
        function setPayTypes(payType, gridData, payAmt) {
            EVF.getComponent('PAY_TYPE').setValue(payType);
            EVF.getComponent('PAY_TYPE_AMT').setValue(payAmt);
            EVF.getComponent('payListJsonData').setValue(gridData);
        }

        function doDeleteItem() {

            if (!gridItem.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var selRowId = gridItem.getSelRowId();
            for(var ri in selRowId) {
                if(EVF.isEmpty(gridItem.getCellValue(selRowId[ri], 'PO_NUM'))) {
                    gridItem.delRow(selRowId[ri]);
                }
            }

            if(gridItem.getSelRowValue().length == 0) {
                return;
            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([gridItem]);
            store.getGridData(gridItem, 'sel');
            store.load(baseUrl + 'BPOM_020/doDeleteItem', function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

		function chPurchaseType(obj, newVal, oldVal) {

            var purchaseType = EVF.C('PO_TYPE').getValue();
            /* 구매유형이 변경되면 유저 확인 후 품목 초기화한다. */
            if(gridItem.getRowCount() > 0) {
                if(confirm('${BPOM_020_022}')) {
                    gridItem.delAllRow();
                } else {
                    return EVF.C('PO_TYPE').setValue(oldVal, false);
                }
            }

//            for (var i = 0; i < gridItem.getRowCount(); i++) /* 구매유형이 변경되면 회계계정 및 자재그룹 초기화함 */ {
//                gridItem.setCellValue(i, 'ACCOUNT_CD', '');
//                gridItem.setCellValue(i, 'ACCOUNT_NM', '');
//                gridItem.setCellValue(i, 'MAT_GROUP', '');
//                gridItem.setCellValue(i, 'MAT_GROUP_NM', '');

                <%-- 2015.12.17 daguri --<< hmchoi 가 시켜서 적용함.
                if(purchaseType == 'OMRO') {
                    gridItem.setCellReadOnly(i, 'PLANT_CD', false);
                    gridItem.setCellReadOnly(i, 'UNIT_PRC', false);
                } else {
                    gridItem.setCellReadOnly(i, 'PLANT_CD', true);
                    gridItem.setCellReadOnly(i, 'UNIT_PRC', true);
                }
                --%>
//            }

            var sesUserId = '${ses.userId}';
            var isCtrlUserId = (sesUserId == EVF.C('CTRL_USER_ID').getValue());  // 구매담당자인지: 저장, 확정요청
            var isPoAprvId = (sesUserId == EVF.C('PO_APRV_ID').getValue());      // 발주확정자인지: 발주확정, 확정반려

            // 구매유형이 "투자품의"인 경우에만 "설비구분, 적용차종" 활성화함
            if (purchaseType != 'ISP') {
                gridItem.hideCol('INVEST_CD', true);
                gridItem.hideCol('CAR_GROUP_CD', true);
            } else {
                gridItem.hideCol('INVEST_CD', false);
                gridItem.hideCol('CAR_GROUP_CD', false);
            }

            var btnSaveVisible = false;     /* 저장 */
            var btnReqVisible = false;      /* 확정요청 */
            var btnSendVisible = false;     /* 협력회사전송 */
            var btnRejectVisible = false;   /* 확장반려 */
            var isPoTypeNormal = (EVF.C('PO_TYPE').getValue() == 'NORMAL'); /* 구매유형: 부품 */

            if(${param.detailView == 'true'}) {

            } else if(${empty form.PO_NUM}) {

                if(isCtrlUserId) {
                    btnSaveVisible = true;
                    if(!isPoTypeNormal) {
                        btnReqVisible = true;
                    }
                } else {
                    btnSaveVisible = false;
                    btnReqVisible = false;
                }

                if(isPoAprvId) {
                    btnSendVisible = true;
                } else {
                    btnSendVisible = false;
                }

            } else if(${not empty form.PO_NUM}) /* 발주가 저장된 상태일 때 */ {

                /* 저장, 확정요청은 구매담당자 */
                /* 협력회사전송, 확정반려는 발주확정자 */

                if(isCtrlUserId) {

                    if(${empty form.PROGRESS_CD or form.PROGRESS_CD == '100' or form.PROGRESS_CD == '400' or form.VENDOR_RECEIPT_STATUS == '100'}) /* 작성(100), 확정반려(400), 협력회사반려(100) */ {

                        btnSaveVisible = true;
                        btnReqVisible = true;

                        if (EVF.C('PO_TYPE').getValue() == 'NORMAL') /* 부품(NORMAL) 일때는 요청없이 협력회사전송 */ {
                            btnReqVisible = false;
                            btnSendVisible = true;
                        }

                    } else {
                        btnSaveVisible = false;
                        btnReqVisible = false;
                    }
                }

                if(isPoAprvId) {

                    if(${empty form.PROGRESS_CD or form.PROGRESS_CD == '100' or form.PROGRESS_CD == '200' or form.PROGRESS_CD == '300'}) /* 작성중,확정요청,협력회사전송 시 */ {
                        btnSendVisible = true;
                    } else {
                        btnSendVisible = false;
                    }

                    if(${form.PROGRESS_CD == '200'}) /* 확정요청상태일 때 */ {
                        btnRejectVisible = true;
                    } else {
                        btnRejectVisible = false;
                    }
                }
            }

            formUtil.setVisible(['doSave'], btnSaveVisible);
            formUtil.setVisible(['doRequestConfirm'], btnReqVisible);
            formUtil.setVisible(['doSend'], btnSendVisible);
            formUtil.setVisible(['doRejectConfirm'], btnRejectVisible);

            if (purchaseType == 'NORMAL') /* 부품은 계정코드, 코스트센터, 세금코드 필수입력 */ {

				EVF.C("PO_APRV_ID").setRequired(false);
				EVF.C("PAY_TERMS").setRequired(false);
                //gridItem.setColRequired("TAX_CD", false);

                if('${_gridType}' != "RG") {
                    gridItem.acceptZero(true);
                }

            } else {

				EVF.C("PO_APRV_ID").setRequired(true);
                EVF.C("PAY_TERMS").setRequired(true);
               // gridItem.setColRequired("TAX_CD", true);
                if('${_gridType}' != "RG") {
                    gridItem.acceptZero(false);
                }

                if(purchaseType == 'SMT') /* 부자재인 경우 품번을 직접입력해서 데이터를 추가할 수 있도록 한다. */ {
                    gridItem.setColRequired("ITEM_CD", true);
                } else {
                    gridItem.setColRequired("ITEM_CD", false);
                }
            }
		}

        function _onChangeShipperType(oldValue, newValue) {

            EVF.C('DELY_TERMS').setDisabled(true);

            var store = new EVF.Store();
            store.setParameter('SHIPPER_TYPE', newValue);
            store.load(baseUrl+'BPOM_020/getDelyTermsOptions', function() {
                EVF.C('DELY_TERMS').setOptions(this.getParameter('delyTermsOptions'));
                EVF.C('DELY_TERMS').setDisabled(false);
            }, false);
        }

        function getPurOrgCd() {
            var param = {
                'callBackFunction': 'setPurOrgCd',
                'detailView': false,
				BUYER_CD : '${ses.companyCd}',
				PLANT_CD : "${ctrlUserPlantCd}"
            };
            everPopup.openCommonPopup(param, "SP0042");
        }

        function setPurOrgCd(data) {

            EVF.C('PUR_ORG_CD').setValue(data['PUR_ORG_CD']);
            EVF.C('PUR_ORG_NM').setValue(data['PUR_ORG_NM']);
            EVF.C('PLANT_CD').setValue(data['PLANT_CD']);

        }

        function poTypeRequired() {

            var purchaseType = EVF.C('PO_TYPE').getValue();

            // 구매유형이 "투자품의"인 경우에만 "설비구분, 적용차종" 활성화함
            if (purchaseType != 'ISP') {
                gridItem.hideCol('INVEST_CD', true);
                gridItem.hideCol('CAR_GROUP_CD', true);

                gridItem.setColRequired("INVEST_CD", false);
                gridItem.setColRequired("CAR_GROUP_CD", false);
            } else {
                gridItem.hideCol('INVEST_CD', false);
                gridItem.hideCol('CAR_GROUP_CD', false);

                gridItem.setColRequired("INVEST_CD", true);
                gridItem.setColRequired("CAR_GROUP_CD", true);
            }
        }

        function doCopy() {

            var selRowData = gridItem.getSelRowValue();
            for(var i in selRowData) {

                delete selRowData[i]['PO_SQ'];
                delete selRowData[i]['PR_SQ'];
                delete selRowData[i]['QTA_SQ'];
                delete selRowData[i]['INSERT_FLAG'];
            }

            gridItem.addRow(selRowData);
            setCellEditStatus();
        }

    </script>

    <e:window id="BPOM_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="GATE_CD" name="GATE_CD" value="${ses.gateCd}"/>
        <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
        <e:inputHidden id="ATT_FILE_NUM" name="ATT_FILE_NUM" value=""/>
        <e:inputHidden id="PO_CREATE_TYPE" name="PO_CREATE_TYPE" value="${form.PO_CREATE_TYPE}"/>
        <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="E"/>
        <e:inputHidden id="validSignStatus" name="validSignStatus" value=""/>
        <e:inputHidden id="approvalFormData" name="approvalFormData" value=""/>
        <e:inputHidden id="approvalGridData" name="approvalGridData" value=""/>
        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value=""/>
        <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value=""/>
        <e:inputHidden id="poghParam" name="poghParam" value=""/>
        <e:inputHidden id="PO_SQ" name="PO_SQ" value="${param.poSq}"/>
        <e:inputHidden id="poWaitingList" name="poWaitingList" value="${param.poWaitingList }"/>
        <e:inputHidden id="EXEC_NUM" name="EXEC_NUM" value="${form.EXEC_NUM}"/> <!-- 품의번호 -->
        <e:inputHidden id="PAY_TYPE_CN" name="PAY_TYPE_CN" value="${form.PAY_TYPE_CN}"/> <!-- 품의서의 납품유형 -->
        <e:inputHidden id="PAY_TYPE_AMT" name="PAY_TYPE_AMT" value="${form.PAY_TYPE_AMT}"/>
        <e:inputHidden id="payListJsonData" name="payListJsonData" value=""/> <!-- 대금지불방식 LIST ARRAY -->
        <e:inputHidden id="PROGRESS_CODE" name="PROGRESS_CODE" value="${form.PROGRESS_CD}"/>
        <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}"/>
        <e:inputHidden id="VENDOR_RECEIPT_STATUS" name="VENDOR_RECEIPT_STATUS" value="${form.VENDOR_RECEIPT_STATUS}"/>
		<e:inputHidden id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}"/>
        <e:inputHidden id="vendorMasterList" name="vendorMasterList" />

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="false"/>
            <e:button id="doRequestConfirm" name="doRequestConfirm" label="${doRequestConfirm_N}" onClick="doRequestConfirm" disabled="${doRequestConfirm_D}" visible="false"/>
            <e:button id="doRejectConfirm" name="doRejectConfirm" label="${doRejectConfirm_N}" onClick="doRejectConfirm" disabled="${doRejectConfirm_D}" visible="false"/>
            <e:button id="doSend" name="doSend" label="${doSend_N}" onClick="doSend" disabled="${doSend_D}" visible="false"/>
            <c:if test="${not empty form.PO_NUM and form.PROGRESS_CD != '200' and form.PROGRESS_CD != '300' and ses.userId == form.CTRL_USER_ID}">
                <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            </c:if>
            <c:if test="${not empty param.popupFlag}">
                <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
            </c:if>
        </e:buttonBar>

        <e:searchPanel id="form" title="${msg.M7777 }" columnCount="3" labelWidth="100" onEnter="doSearch">
            <e:row>
                <e:label for="PO_NUM" title="${form_PO_NUM_N}"/>
                <e:field>
                    <e:inputText id="PO_NUM" name="PO_NUM" value="${param.poNum}" width="${inputTextWidth }" maxLength="${form_PO_NUM_M}" disabled="${form_PO_NUM_D}" readOnly="${form_PO_NUM_RO}" required="${form_PO_NUM_R}"/>
                </e:field>
                <e:label for="PO_TYPE" title="${form_PO_TYPE_N}"/>
                <e:field>
                    <e:select id="PO_TYPE" name="PO_TYPE" onChange="chPurchaseType" value="${form.PO_TYPE}" options="${poTypeOptions}" width="${inputTextWidth}" disabled="${form_PO_TYPE_D}" readOnly="${form_PO_TYPE_RO}" required="${form_PO_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PUR_ORG_CD" title="${form_PUR_ORG_CD_N}"/>
                <e:field>
                    <e:search id="PUR_ORG_CD" style="ime-mode:inactive" name="PUR_ORG_CD" value="${form.PUR_ORG_CD}" width="${inputTextWidth}" maxLength="${form_PUR_ORG_CD_M}" onIconClick="${form.PO_CREATE_TYPE == 'DRAFT' ? 'everCommon.blank' : 'getPurOrgCd'}" disabled="${form_PUR_ORG_CD_D}" readOnly="${form_PUR_ORG_CD_RO}" required="${form_PUR_ORG_CD_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="PUR_ORG_NM" name="PUR_ORG_NM" value="${form.PUR_ORG_NM}" width="${inputTextWidth }" maxLength="${form_PUR_ORG_NM_M}" disabled="${form_PUR_ORG_NM_D}" readOnly="${form_PUR_ORG_NM_RO}" required="${form_PUR_ORG_NM_R}"/>
                </e:field>

            </e:row>
            <e:row>
                <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
                <e:field colSpan="5">
                    <e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${inputTextWidth }" maxLength="${form_VENDOR_CD_M}" onIconClick="${form.PO_CREATE_TYPE == 'DRAFT' ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth }" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="PO_CREATE_DATE" title="${form_PO_CREATE_DATE_N}"/>
                <e:field>
                    <e:inputDate id="PO_CREATE_DATE" name="PO_CREATE_DATE" value="${form.PO_CREATE_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_PO_CREATE_DATE_R}" disabled="${form_PO_CREATE_DATE_D}" readOnly="${form_PO_CREATE_DATE_RO}"/>
                </e:field>
                <e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
                <e:field>
                    <e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="${form.SHIPPER_TYPE}" options="${shipperTypeOptions}" width="${inputTextWidth}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" onChange="_onChangeShipperType" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PO_AMT" title="${form_PO_AMT_N}"/>
                <e:field>
                    <e:inputNumber id='PO_AMT' name="PO_AMT" value='' align='right' width='${inputTextWidth }' required='${form_PO_AMT_R }' readOnly='${form_PO_AMT_RO }' disabled='${form_PO_AMT_D }' visible='${form_PO_AMT_V }' decimalPlace="2"/>
                    <e:text>&nbsp;</e:text>
                    <e:select id="CUR" name="CUR" value="${form.CUR}" options="${curOptions}" width="${inputTextWidth }" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder=""/>
                </e:field>
                <c:choose>
                    <c:when test="${ses.userType != 'S'}">
                        <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
                        <e:field>
                            <e:select id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" options="${payTermsOptions}" width="100%" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder=""/>
                        </e:field>
                        <e:label for="DELY_TERMS" title="${form_DELY_TERMS_N}"/>
                        <e:field>
                            <e:select id="DELY_TERMS" name="DELY_TERMS" value="${form.DELY_TERMS}" options="${delyTermsOptions}" width="${inputTextWidth}" disabled="${form_DELY_TERMS_D}" readOnly="${form_DELY_TERMS_RO}" required="${form_DELY_TERMS_R}" placeHolder=""/>
                        </e:field>
                    </c:when>
                    <c:otherwise>
                        <e:label for="DELY_TERMS" title="${form_DELY_TERMS_N}"/>
                        <e:field colSpan="3">
                            <e:inputHidden id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" />
                            <e:select id="DELY_TERMS" name="DELY_TERMS" value="${form.DELY_TERMS}" options="${delyTermsOptions}" width="${inputTextWidth}" disabled="${form_DELY_TERMS_D}" readOnly="${form_DELY_TERMS_RO}" required="${form_DELY_TERMS_R}" placeHolder=""/>
                        </e:field>
                    </c:otherwise>
                </c:choose>
            </e:row>
            <e:row>
                <e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:inputText id="CTRL_USER_ID" name="CTRL_USER_ID" value="${form.CTRL_USER_ID}" width="${inputTextWidth }" maxLength="${form_CTRL_USER_ID_M}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="CTRL_USER_NM" name="CTRL_USER_NM" value="${form.CTRL_USER_NM}" width="${inputTextWidth }" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
                </e:field>
                <e:label for="DELIVERY_TYPE" title="${form_DELIVERY_TYPE_N}"/>
                <e:field>
                    <e:select id="DELIVERY_TYPE" name="DELIVERY_TYPE" value="${form.DELIVERY_TYPE}" options="${deliveryTypeOptions}" width="${inputTextWidth}" disabled="${not empty form.PO_NUM and form.PO_CREATE_TYPE eq 'DRAFT' ? 'true' : form_DELIVERY_TYPE_D}" readOnly="${form_DELIVERY_TYPE_RO}" required="${form_DELIVERY_TYPE_R}" placeHolder=""/>
                </e:field>
                <e:label for="PAY_TYPE" title="${form_PAY_TYPE_N}"/>
                <e:field>
                    <e:select id="PAY_TYPE" name="PAY_TYPE" value="${not empty param.poWaitingList ? form.PAY_TYPE_CN : form.PAY_TYPE}" options="${payTypeOptions}" width="${inputTextWidth}" disabled="${form_PAY_TYPE_D}" readOnly="${form_PAY_TYPE_RO}" required="${form_PAY_TYPE_R}" placeHolder=""/>
                    <div id="instalments" style="position: relative; float: left; left: 21px;">
                        <div class="e-search-icon" style="float:left;" onclick="openInstalments();"></div>
                    </div>
                </e:field>
            </e:row>
            <e:row>
                <c:choose>
                    <c:when test="${ses.userType != 'S'}">
                        <e:label for="INSPECT_USER_ID" title="${form_INSPECT_USER_ID_N}"/>
                        <e:field>
                            <e:search id="INSPECT_USER_ID" name="INSPECT_USER_ID" value="${form.INSPECT_USER_ID}" width="${inputTextWidth }" maxLength="${form_INSPECT_USER_ID_M}" onIconClick="${form_INSPECT_USER_ID_RO ? 'everCommon.blank' : 'doSearchInspectUser'}" disabled="${form_INSPECT_USER_ID_D}" readOnly="${form_INSPECT_USER_ID_RO}" required="${form_INSPECT_USER_ID_R}"/>
		                    <e:text>&nbsp;</e:text>
                            <e:inputText id="INSPECT_USER_NM" name="INSPECT_USER_NM" value="${form.INSPECT_USER_NM}" width="${inputTextWidth }" maxLength="${form_INSPECT_USER_NM_M}" disabled="${form_INSPECT_USER_NM_D}" readOnly="${form_INSPECT_USER_NM_RO}" required="${form_INSPECT_USER_NM_R}"/>
                        </e:field>
                        <e:label for="PO_APRV_ID" title="${form_PO_APRV_ID_N}"/>
                        <e:field colSpan="3">
                            <e:search id="PO_APRV_ID" style="ime-mode:inactive" name="PO_APRV_ID" value="${form.PO_APRV_ID}" width="${inputTextWidth }" maxLength="${form_PO_APRV_ID_M}" onIconClick="${empty form.PROGRESS_CD or form.PROGRESS_CD == '100' ? 'doSearchPoAprvUser' : 'everCommon.blank'}" disabled="${form_PO_APRV_ID_D}" readOnly="${form_PO_APRV_ID_RO}" required="${form_PO_APRV_ID_R}"/>
		                    <e:text>&nbsp;</e:text>
                            <e:inputText id="PO_APRV_NM" name="PO_APRV_NM" value="${form.PO_APRV_NM}" width="${inputTextWidth }" maxLength="${form_PO_APRV_ID_M}" disabled="${form_PO_APRV_ID_D}" readOnly="${form_PO_APRV_ID_RO}" required="${form_PO_APRV_ID_R}"/>
                        </e:field>
                    </c:when>
                    <c:otherwise>
                        <e:label for="INSPECT_USER_ID" title="${form_INSPECT_USER_ID_N}"/>
                        <e:field colSpan="5">
                            <e:search id="INSPECT_USER_ID" name="INSPECT_USER_ID" value="${form.INSPECT_USER_ID}" width="80" maxLength="${form_INSPECT_USER_ID_M}" onIconClick="${form_INSPECT_USER_ID_RO ? 'everCommon.blank' : 'doSearchInspectUser'}" disabled="${form_INSPECT_USER_ID_D}" readOnly="${form_INSPECT_USER_ID_RO}" required="${form_INSPECT_USER_ID_R}"/>
		                    <e:text>&nbsp;</e:text>
                            <e:inputText id="INSPECT_USER_NM" name="INSPECT_USER_NM" value="${form.INSPECT_USER_NM}" width="120" maxLength="${form_INSPECT_USER_NM_M}" disabled="${form_INSPECT_USER_NM_D}" readOnly="${form_INSPECT_USER_NM_RO}" required="${form_INSPECT_USER_NM_R}"/>

                            <e:inputHidden id="PO_APRV_ID" name="PO_APRV_ID" value="${form.PO_APRV_ID}" />
                            <e:inputHidden id="PO_APRV_NM" name="PO_APRV_NM" value="${form.PO_APRV_NM}" />
                        </e:field>
                    </c:otherwise>
                </c:choose>
            </e:row>
            <e:row>
                <e:label for="RMK_TEXT_NUM" title="${form_RMK_TEXT_NUM_N}"></e:label>
                <e:field colSpan="5">
                    <e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}"/>
                    <e:textArea id="SPECIAL_CONTENTS" width="100%" name="SPECIAL_CONTENTS" value="${form.SPECIAL_CONTENTS}" label="${RMK_TEXT_NUM_N }" height="150" disabled="${form_RMK_TEXT_NUM_D }" visible="${form_RMK_TEXT_NUM_V }" readOnly="${form_RMK_TEXT_NUM_RO }" required="${form_RMK_TEXT_NUM_R }" maxLength="${form_RMK_TEXT_NUM_M }" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PO_ATT_FILE_NUM" title="${form_PO_ATT_FILE_NUM_N}"/>
                <e:field colSpan="5">
                    <e:fileManager id="PO_ATT_FILE_NUM" height="120" width="100%" fileId="${form.PO_ATT_FILE_NUM}" readOnly="${form_PO_ATT_FILE_NUM_RO}" bizType="PO" required="${form_PO_ATT_FILE_NUM_R}"/>
                </e:field>
            </e:row>
            <c:if test="${ses.userType != 'S'}">
                <e:row>
                    <e:label for="" title="${BPOM_020_GW_RELATED_DOC}"/>
                    <e:field colSpan="5">
                        <e:gridPanel gridType="${_gridType}" id="docGrid" name="docGrid" height="150" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.docGrid.gridColData}"/>
                    </e:field>
                </e:row>
            </c:if>
        </e:searchPanel>
        <c:if test="${form.PO_CREATE_TYPE != 'DRAFT' and form.PO_CREATE_TYPE != 'PR'}">
            <e:buttonBar align="right">
                <e:button id="doCopy" name="doCopy" label="${doCopy_N}" onClick="doCopy" disabled="${doCopy_D}" visible="${doCopy_V}" align="left" />
                <e:button id="doSearchItemBOM" name="doSearchItemBOM" label="${doSearchItemBOM_N}" onClick="getBomItem" disabled="${doSearchItemBOM_D}" visible="${doSearchItemBOM_V}"/>
                <e:button id="doSearchItem" name="doSearchItem" label="${doSearchItem_N}" onClick="getItem" disabled="${doSearchItem_D}" visible="${doSearchItem_V}"/>
                <e:button id="doDeleteItem" name="doDeleteItem" label="${doDeleteItem_N}" onClick="doDeleteItem" disabled="${doDeleteItem_D}" visible="${doDeleteItem_V}"/>
            </e:buttonBar>
        </c:if>

        <e:gridPanel gridType="${_gridType}" id="gridItem" height="300" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gridItem.gridColData}" />

    </e:window>
</e:ui>
