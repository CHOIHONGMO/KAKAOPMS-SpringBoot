<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
	String devFlag = PropertiesManager.getString("eversrm.system.developmentFlag");
	String gwUrl = "";
	String gwLinkUrl = "";
	if ("true".equals(devFlag)) {
		gwUrl = PropertiesManager.getString("gw.dev.url");
		gwLinkUrl = PropertiesManager.getString("gw.link.dev.url");
	} else {
		gwUrl = PropertiesManager.getString("gw.real.url");
		gwLinkUrl = PropertiesManager.getString("gw.link.real.url");
	}
	String gwParam = PropertiesManager.getString("gw.param");

%>

<c:set var="devFlag" value="<%=devFlag%>" />
<c:set var="gwUrl" value="<%=gwUrl%>" />
<c:set var="gwParam" value="<%=gwParam%>" />
<c:set var="gwLinkUrl" value="<%=gwLinkUrl%>" />


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript" src="/js/ever-math.js"></script>

	<script>

		var grid, docGrid;
		var baseUrl = "/eversrm/purchase/prMgt/prRequestReg/BPRM_010";

		function gwDocView() {

			var userwidth = 820;
			var userheight = (screen.height - 2);
			var LeftPosition = (screen.width-userwidth)/2;
			var TopPosition = (screen.height-userheight)/2;
			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

			if (EVF.getComponent("BLSM_MSG").getValue() != '') {
				var url = '${gwLinkUrl}'+EVF.getComponent("BLSM_MSG").getValue();
				window.open(url, "signwindow", gwParam);
			} else {
	    		alert('${BPRM_010_0024}');
			}
		}

		function init() {

			grid = EVF.C("grid");
			docGrid = EVF.C("docGrid");
			grid.setProperty('panelVisible', ${panelVisible});

			docGrid.setProperty("shrinkToFit", true);
			docGrid.setProperty('multiselect', true);
			grid.setProperty('panelVisible', ${panelVisible});

			// 구매유형에서 "수선,제작,품의" 제외하고 나머지 코드값은 Invisible
			EVF.C('PR_TYPE').removeOption('ISP'); // 투자품의
			EVF.C('PR_TYPE').removeOption('SMT'); // 부자재
			EVF.C('PR_TYPE').removeOption('NORMAL'); // 부품
			EVF.C('PR_TYPE').removeOption('DMRO'); // 국내MRO
			EVF.C('PR_TYPE').removeOption('OMRO'); // 해외MRO
			EVF.C('PR_TYPE').removeOption('DC'); // 품의

		    if ('${param.prNum}' !== '' || '${param.appDocNum}' !== '') {
		        doSearch();
		    } else {
		        //var approvalFlag = EVF.C('APPROVAL_FLAG').getValue();
		        //setButtonVisible(approvalFlag);
		    }

		    // 단위, 요청납기일자, 납품장소, 계정코드, 비용부서 일괄복사 기능 필요
		    grid.addRowEvent(function () {
				var param = [{
					'PLANT_CD': "${ses.plantCd}",
					'INSERT_FLAG' : 'I'
				}];
		        grid.addRow(param);

				grid.setCellReadOnly(grid.getRowCount()-1, 'ITEM_DESC', false);
		    });

			docGrid.addRowEvent(function () {
				docGrid.addRow();
			});

		    grid.delRowEvent(function() {
				var selRowIds = grid.getSelRowId();
				for(var x in selRowIds) {
					var rowId = selRowIds[x];
					if (grid.getCellValue(rowId, 'INSERT_FLAG') == 'I') {
						grid.delRow(rowId);
					} else {
						//var LINE_THROUGH = 'line-through';
						//grid.setRowStyle(rowId, "text-decoration", LINE_THROUGH);
						//grid.setCellFontDeco(rowId, 'ITEM_CD', LINE_THROUGH);
						//grid.setCellFontDeco(rowId, 'ITEM_DESC', LINE_THROUGH);
						//grid.setCellFontDeco(rowId, 'ITEM_SPEC', LINE_THROUGH);
						grid.setCellValue(rowId, 'INSERT_FLAG', 'D');
						grid.setRowBgColor(rowId, '#8C8C8C');
					}
				}
			});

			docGrid.delRowEvent(function() {
				var store = new EVF.Store();
				store.setGrid([docGrid]);
				store.getGridData(docGrid, 'sel');
				store.load(baseUrl + "/gwGridDelete", function() {});

				docGrid.delRow();

			});

		    grid.cellClickEvent(function (rowId, celName, value, iRow, iCol) {

		        if ('${param.detailView}' === 'true' && (celName === 'DELY_TO_CD_VALUE' || celName === 'ACCOUNT_NM' || celName === 'COST_DEPT_NM' || celName === 'REC_VENDOR_CD')) {
		            return;
		        }

		        if (celName === 'ITEM_CD_IMAGE') {
		            var itemCode = grid.getCellValue(rowId, 'ITEM_CD');
		            if (itemCode === '') {
		                return;
		            }
		            everPopup.openPopupByScreenId('BBM_040', 1200, 600, {
		                gate_cd: '${ses.gateCd}',
		                ITEM_CD : itemCode
		            });
		        } else if (celName === 'DELY_TO_CD_VALUE') {
		            everPopup.openCommonPopup({
		                callBackFunction: 'delyToCodeCallback',
		                rowid: rowId
		            }, 'SP0023');
		        } else if (celName === 'ACCOUNT_NM_IMG') {
					if (EVF.C('PR_TYPE').getValue() == '') {
						alert('${BPRM_010_0003}');
						return;
					}

		        	var prType = "";
		        	if (EVF.C('PR_TYPE').getValue() == 'AS') {
		        		prType = "S";
		        	} else {
		        		prType = "M";
		        	}

					var param = {
						'callBackFunction': 'setAccount',
						'detailView': false,
						'rowId': rowId,
						'PURC_FLAG' : prType

					};
					everPopup.openCommonPopup(param, "SP0035");

		        } else if (celName === 'COST_NM_IMG') {
					var param = {
						'callBackFunction': 'costDeptCodeCallback',
						'detailView': false,
						'rowId': rowId,
						'PLANT_CD': grid.getCellValue(rowId, "PLANT_CD")
					};
					everPopup.openCommonPopup(param, "SP0036");
		        } else if (celName === 'REC_VENDOR_NM') {
		            everPopup.openCommonPopup({
		                callBackFunction: 'recVendorCodeCallback',
		                rowid: rowId
		            }, 'SP0025');
		        } else if (celName === 'SUB_ITEM_COUNT') {
		            var gridStringData = grid.getCellValue(rowId, 'PRSI_DATA');
		            var param = {
		                screenIdForGrid: 'BPR_100',
		                nRow: rowId,
		                itemAmt: grid.getCellValue(rowId, 'ITEM_AMT'),
		                callbackFunction: 'subItemListCallBack',
		                gridStringData: gridStringData,
		                detailView: '${param.detailView}'
		            };
		            everPopup.openSubItemListPopup(param)
		        } else if (celName === 'ATT_FILE_CNT') {
		            var param = {
		                havePermission: '${!param.detailView}',
						attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
						rowId: rowId,
						callBackFunction: 'fileAttachPopupCallback',
						bizType: 'PR',
						fileExtension: '*'
		            };

		            everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
		        } else if (celName === 'CTRL_NM') {
					var param = {
						'callBackFunction': 'ctrlCodeCallback',
						'detailView': false,
						'rowId': rowId,
						'PLANT_CD': grid.getCellValue(rowId, "PLANT_CD"),
						'CTRL_TYPE' : 'NPUR'

					};
					everPopup.openCommonPopup(param, "SP0037");
				}

		    });

			docGrid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
                var userwidth  = 810; // 고정(수정하지 말것)
    			var userheight = (screen.height - 2);
    			if (userheight < 780) userheight = 780; // 최소 780
    			var LeftPosition = (screen.width-userwidth)/2;
    			var TopPosition  = (screen.height-userheight)/2;
    			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

				switch (celname) {
	                case 'APRV_URL':
    	            	if ('${param.detailView}' == 'true' && docGrid.getCellValue(rowid, celname) != '' && docGrid.getCellValue(rowid, celname).length > 200) {
        	            	window.open(docGrid.getCellValue(rowid, celname), "signwindow", gwParam);
            	        }
                	    break;
					default:
				}
			});

		    grid.cellChangeEvent(function (rowId, celName, iRow, iCol, newValue, oldValue) {

		        switch (celName) {
		            case 'UNIT_PRC':
		                if (EVF.C('CUR').getValue() == '') {
		                    alert('${BPRM_010_CUR_VALUE_NOT_SELECTED}');
		                    grid.setCellValue(rowId, celName, oldValue);
		                    return;
		                }

		                if (Number(newValue) < 0) {
		                    alert('${BPRM_010_INPUT_VALUE_LESS}');
		                    grid.setCellValue(rowId, celName, oldValue);
		                    return;
		                }

						grid.setCellValue(rowId, "PR_AMT", (grid.getCellValue(rowId, "PR_QT") * grid.getCellValue(rowId, celName)));

						break;
		            case 'ITEM_CD':
		                var store = new EVF.Store();
		                store.setParameter("itemCd", newValue);
		                store.load("/common/util/getItemSearchByCode", function () {
		                    if (this.getParameter('result') === null) {
		                        return alert('${BPRM_010_ITEM_CD_DOES_NOT_EXIST }');
		                    } else {
		                        var itemData = JSON.parse(this.getParameter('result'));
		                        grid.setCellValue(rowId, 'ITEM_DESC', itemData['ITEM_DESC']);
		                        grid.setCellValue(rowId, 'ITEM_SPEC', itemData['ITEM_SPEC']);
		                    }
		                });
		                break;
		            case 'PR_QT':
		                if (newValue < 0) {
		                    alert('${msg.INPUT_GREATER_THAN_ZERO}');
		                    grid.setCellValue(rowId, celName, oldValue);
		                    return;
		                }
		                break;

					case 'PLANT_CD':
						grid.setCellValue(rowId, 'CTRL_CD', '');
						grid.setCellValue(rowId, 'CTRL_NM', '');
						grid.setCellValue(rowId, 'COST_CD', '');
						grid.setCellValue(rowId, 'COST_NM', '');
						grid.setCellValue(rowId, 'ACCOUNT_CD', '');
						grid.setCellValue(rowId, 'ACCOUNT_NM', '');

						break;

					case 'ACCOUNT_CD':
						var store = new EVF.Store();
						store.setParameter("PLANT_CD", grid.getCellValue(rowId, "PLANT_CD"));
						store.setParameter("ACCOUNT_NUM", newValue);
						store.load(baseUrl + "/doAccountSearch", function () {
							var accountMap = JSON.parse(this.getParameter("accountMap"));

							if(accountMap != undefined || accountMap != null) {
								grid.setCellValue(rowId, "ACCOUNT_NM", accountMap.ACCOUNT_NM);
							} else {
								alert("${BPRM_010_0001}"); // 계정코드가 존재하지 않습니다.\n확인하여 주시기 바랍니다.
								grid.setCellValue(rowId, celName, "");
								grid.setCellValue(rowId, "ACCOUNT_NM", "");

							}
						});

						break;

					case 'COST_CD':
						var store = new EVF.Store();
						store.setParameter("PLANT_CD", grid.getCellValue(rowId, "PLANT_CD"));
						store.setParameter("COST_CD", newValue);
						store.load(baseUrl + "/doCostSearch", function () {
							var costMap = JSON.parse(this.getParameter("costMap"));

							if(costMap != undefined || costMap != null) {
								grid.setCellValue(rowId, "COST_NM", costMap.COST_NM);
							} else {
								alert("${BPRM_010_0002}"); // 코스트센터코드가 존재하지 않습니다.\n확인하여 주시기 바랍니다.
								grid.setCellValue(rowId, celName, "");
								grid.setCellValue(rowId, "COST_NM", "");

							}
						});

						break;
		        }

		        if (celName === 'ITEM_DESC' || celName === 'ITEM_SPEC') {
		            var itemCode = grid.getCellValue(rowId, 'ITEM_CD');
		            if (everString.isNotEmpty(itemCode)) {
		                alert('${msg.CAN_NOT_EDIT}');
		                grid.setCellValue(rowId, celName, oldValue);
		                return;
		            }
		        }

		        if (celName === 'UNIT_PRC' || celName === 'PR_QT') {
		            fillGridItem();
		        }
		    });

			// 구매요청진행현황 List
			var prList = JSON.stringify(${param.prList});
			if(prList != '') {
				EVF.getComponent('prList').setValue(prList);
				doSearch();
			}
		}

		function ctrlCodeCallback(data) {
			grid.setCellValue(data.rowid, "CTRL_CD", data.CTRL_CD);
			grid.setCellValue(data.rowid, "CTRL_NM", data.CTRL_NM);

	        var selectedRow = grid.getSelRowValue();
	        var selRowIds = grid.getSelRowId();
	        if (selectedRow.length > 1) {
	    		if (confirm('${BPRM_010_0004}')) {
	    	        for(var x in selRowIds) {
	    	            var rowId = selRowIds[x];
	    	            grid.setCellValue(rowId, 'CTRL_CD', data.CTRL_CD);
	    	            grid.setCellValue(rowId, 'CTRL_NM', data.CTRL_NM);
	    	        }
	    		}
	        }
		}

		function setAccount(data) {
			grid.setCellValue(data.rowid, "ACCOUNT_NM", data.ACCOUNT_NM);
			grid.setCellValue(data.rowid, "ACCOUNT_CD", data.ACCOUNT_NUM);
			grid.setCellValue(data.rowid, "MAT_GROUP", data.MAT_GROUP);
			grid.setCellValue(data.rowid, "MAT_GROUP_NM", data.MAT_GROUP_NM);

	        var selectedRow = grid.getSelRowValue();
	        var selRowIds = grid.getSelRowId();
	        if (selectedRow.length > 1) {
	    		if (confirm('${BPRM_010_0004}')) {
	    	        for(var x in selRowIds) {
	    	            var rowId = selRowIds[x];
	    	            grid.setCellValue(rowId, 'ACCOUNT_NM', data.ACCOUNT_NM);
	    	            grid.setCellValue(rowId, 'ACCOUNT_CD', data.ACCOUNT_NUM);
	    		        grid.setCellValue(rowId, 'MAT_GROUP', data.MAT_GROUP);
	    		        grid.setCellValue(rowId, 'MAT_GROUP_NM', data.MAT_GROUP_NM);
	    	        }
	    		}
	        }
		}

		function doSearchGwDocData() {

			var store = new EVF.Store();

			store.setGrid([docGrid]);
			store.load(baseUrl + "/doSearchGwDocData", function () {
			});

}
        function setButtonVisible(approvalFlag) {
		    if ('${param.detailView}' === 'true') {
		        EVF.C('approvalRequest').setVisible(false);
		        EVF.C('save').setVisible(false);
		        EVF.C('delete').setVisible(false);
		        EVF.C('catalog').setVisible(false);
		        EVF.C('budgetSearch').setVisible(false);
		        return;
		    }

		    if (opener === undefined) {
		        EVF.C('onClose').setVisible(false);
		    }

			/*
		    if (approvalFlag === '1') {
		        EVF.C('approvalRequest').setVisible(true);
		        EVF.C('purchaseRequest').setVisible(false);
		    } else if (approvalFlag === '0') {
		        EVF.C('approvalRequest').setVisible(false);
		        EVF.C('purchaseRequest').setVisible(true);
		    } else if (approvalFlag === '-1') {
		        EVF.C('approvalRequest').setVisible(false);
		        EVF.C('purchaseRequest').setVisible(false);
		    }
		    */
		}

		function onApprovalFlagChange() {
		    setButtonVisible(this.getValue());
		}

		function doSearch() {
		    var store = new EVF.Store();
		    store.setGrid([grid, docGrid]);
		    store.load(baseUrl + "/doSearch", function () {
		        fillGridItem();
		        docGrid.checkAll(true);
				// 결재 진행중 일 경우 버튼 히든
				signHiddenBtn();
		    });
		}

		function signHiddenBtn() {

			var sign_status = EVF.C("SIGN_STATUS").getValue();

			if( sign_status == 'P' ) {
				EVF.C('save').setVisible(false);
				EVF.C('approvalRequest').setVisible(false);
				EVF.C('purchaseRequest').setVisible(false);
			}
		}

		function fileAttachCallback(result) {
		    EVF.C('ATT_FILE_NUM').setValue(result.UUID);
		}

		function deletePR() {

			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				return alert('${msg.M0123}');
			}

		    if (!confirm("${msg.M0013}")) {
		        return;
		    }

		    var prNum = EVF.C('PR_NUM').getValue();
		    var store = new EVF.Store();
		    store.setParameter('PR_NUM', prNum);
		    store.load(baseUrl + '/doDelete', function () {

		    	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');
		        alert(this.getResponseMessage());

		        if (opener != null) {
					opener['doSearch']();
		            window.close();
		        } else {
					location.href=baseUrl+'/view';
		        }
		    });
		}

		function calculatePrAmount() {
		    var sum = 0;
		    var currency = EVF.C('CUR').getValue();
		    var gridData = grid.getAllRowValue();
		    for (var i in gridData) {
		        var rowData = gridData[i];
		        var price = everCurrency.getPrice(currency, rowData.UNIT_PRC);
		        var qty = everCurrency.getQty(currency, rowData.PR_QT);
		        sum += price * qty;
		    }
		    var amt = everCurrency.getAmount(currency, sum);
		    EVF.C('PR_AMT').setValue(amt);
		}

		function searchReqUser() {
		    everPopup.openCommonPopup({
		        callBackFunction: 'searchReqUserCallback'
		    }, 'SP0001');
		}

		function searchReqUserCallback(result) {
		    EVF.C('REQ_USER_NM').setValue(result.USER_NM);
		    EVF.C('REQ_USER_ID').setValue(result.USER_ID);
		    EVF.C('REQ_USER_DEPT').setValue(result.DEPT_NM);
		}

		function openItemPopup() {
			var param = {
				'callBackFunction': 'itemPopupCallback',
				'popupFlag': true,
				'detailView': false,
				'openerScreen': 'BPRM_010'
			};
			everPopup.openItemCatalogPopup(param);
		}

		function itemPopupCallback(data) {
			var validData = valid.equalPopupValid(data, grid, "ITEM_CD");
			var arrData = [];
			for(idx in validData) {
				arrData.push({
					'PLANT_CD': "${ses.plantCd}",
					'ITEM_CD': validData[idx].ITEM_CD,
					'ITEM_DESC': validData[idx].ITEM_DESC,
					'ITEM_SPEC': validData[idx].ITEM_SPEC,
					'MAKER': validData[idx].MAKER,
					'PR_QT': validData[idx].ITEM_QT,
					'UNIT_CD': validData[idx].UNIT_CD,
					'UNIT_PRC': validData[idx].UNIT_PRC,
					'PR_AMT': validData[idx].ITEM_QT * validData[idx].UNIT_PRC,
					'ADD_FLAG': 'Y',
					'INSERT_FLAG': 'I'
				});
			}

		    grid.addRow(arrData);

		    fillGridItem();
		}

		function doAddLine() {
		    grid.addRow();
		    fillGridItem();
		}

		function fillGridItem() {

		    var unitPrice;
		    var qty;

		    var allRowId = grid.getAllRowId();
		    for (var i in allRowId) {
		        var rowId = allRowId[i];

		        var currency = EVF.C('CUR').getValue();
		        unitPrice = everCurrency.getPrice(currency, grid.getCellValue(rowId, 'UNIT_PRC'));
		        qty = everCurrency.getQty(currency, grid.getCellValue(rowId, 'PR_QT'));
		        grid.setCellValue(rowId, 'PR_AMT', everCurrency.getAmount(currency, unitPrice * qty));

				// 품목선택 시 "품명/규격/제조사/단위" 수정 불가
				if(grid.getCellValue(rowId, 'ADD_FLAG') == "Y") {
					grid.setCellReadOnly(rowId, 'ITEM_DESC', true);
					grid.setCellReadOnly(rowId, 'ITEM_SPEC', true);
					grid.setCellReadOnly(rowId, 'MAKER', true);
					grid.setCellReadOnly(rowId, 'UNIT_CD', true);
				}
		    }
		    calculatePrAmount();
		}

		function fileAttachPopupCallback(gridRowId, fileId, fileCount) {
		    grid.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
		    grid.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
		}

		function subItemListCallBack(gridStringData, nRow) {
		    grid.setCellValue(nRow, 'PRSI_DATA', gridStringData);
		    fillGridItem();
		}

		function delyToCodeCallback(result) {
		    grid.setCellValue(result.rowid, 'DELY_TO_CD_VALUE', result.DELY_TO_NM);
		    grid.setCellValue(result.rowid, 'DELY_TO_CD', result.DELY_TO_CD);
		}

		function accountCodeCallback(result) {
		    grid.setCellValue(result.rowid, 'ACCOUNT_CD', result.ACCOUNT_CD);
		    grid.setCellValue(result.rowid, 'ACCOUNT_NM', result.ACCOUNT_NM);
		}

		function costDeptCodeCallback(result) {
		    grid.setCellValue(result.rowid, 'COST_CD', result.COST_CD);
		    grid.setCellValue(result.rowid, 'COST_NM', result.COST_NM);

	        var selectedRow = grid.getSelRowValue();
	        var selRowIds = grid.getSelRowId();
	        if (selectedRow.length > 1) {
	    		if (confirm('${BPRM_010_0004}')) {
	    	        for(var x in selRowIds) {
	    	            var rowId = selRowIds[x];
	    	            grid.setCellValue(rowId, 'COST_CD', result.COST_CD);
	    	            grid.setCellValue(rowId, 'COST_NM', result.COST_NM);
	    	        }
	    		}
	        }
		}

		function recVendorCodeCallback(result) {
		    grid.setCellValue(result.rowid, 'REC_VENDOR_NM', result.VENDOR_NM);
		    grid.setCellValue(result.rowid, 'REC_VENDOR_CD', result.VENDOR_CD);
		}

		function openPreSourcingList() {
		    everPopup.openPopupByScreenId('BPRM_030', 1000, 600, {
		        callBackFunction: 'preSourcingListCallBack',
		        detailView: 'false'
		    });
		}

		function preSourcingListCallBack(selectedData) {

		    var rfiNum = selectedData['RFI_NUM'];
		    EVF.C('RFI_NUM').setValue(rfiNum);
		    var store = new EVF.Store();
		    store.setGrid([grid]);
		    store.setParameter('RFI_NUM', rfiNum);
		    store.load(baseUrl + '/getGridDataByRFINo', function () {
		        fillGridItem();
		    });
		}

		function validationAndSave(signStatus) {

			if (!grid.validate().flag) { return alert(grid.validate().msg); }
			if (!docGrid.validate().flag) { return alert(docGrid.validate().msg); }

			var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

		    if (selRowIds.length == 0) {
		        return alert("${BPRM_010_ITEM_DATA_NOT_EXIST}");
		    }

		    var store = new EVF.Store();

			var subject;
			var allRowIds = grid.jsonToArray(grid.getAllRowId()).value;
			var rowCnt = 0;

			for(var idx in allRowIds) {
				if(grid.getCellValue(allRowIds[idx], "INSERT_FLAG") != "D") {
					rowCnt++;
				}
			}

			// [xxx외 3건] 수선 요청의 건
			if(allRowIds.length > 1) {
				subject = "[" + grid.getCellValue(allRowIds[0], "ITEM_DESC");
				if(grid.getCellValue(allRowIds[0], "ITEM_SPEC") != "")
					subject += "/";

				subject += grid.getCellValue(allRowIds[0], "ITEM_SPEC") +"외 " + (rowCnt-1).toString() + "건] "+ EVF.C('PR_TYPE').getText() + " 요청의 件";
			} else {
				subject = "[" + grid.getCellValue(allRowIds[0], "ITEM_DESC");
				if(grid.getCellValue(allRowIds[0], "ITEM_SPEC") != "")
					subject += "/";

				subject += grid.getCellValue(allRowIds[0], "ITEM_SPEC") + "] "+ EVF.C('PR_TYPE').getText() + " 요청의 件";
			}

		 	EVF.C('SUBJECT').setValue(subject);

		    if (!store.validate()) {
		        return;
		    }

		    var minDate = null;
		    var selRowId = grid.getSelRowId();
		    for (var i in selRowId) {
		        var rowId = selRowId[i];
		        var date = Number(grid.getCellValue(rowId, 'DUE_DATE'));
		        if (minDate === null || date < minDate) {
		            minDate = date;
		        }
		    }

		    everDate.diffWithServerDate(String(minDate), function (status, message) {
		        if (status === '-1') {
		            alert('${BPRM_010_INPUT_DATE_LESS}');
		        } else {
		            afterValidation(signStatus);
		        }
		    }, true);
		}

		function afterValidation(signStatus) {

		    var oldSignStatus = EVF.C('SIGN_STATUS').getValue();

		    var confirmMessage;
		    switch (signStatus) {
		        case 'T':
		            confirmMessage = '${msg.M0021}';
		            break;
		        case 'E':
		            confirmMessage = '${msg.M0053}';
		            break;
		        case 'P':
		            confirmMessage = '${msg.M0053}';
		            break;
		    }

		    if (oldSignStatus === 'E') {
		        confirmMessage = '${msg.M0056}';
		    }

		    if (!confirm(confirmMessage)) {
		        return;
		    }

		    if (signStatus === 'T' || signStatus === 'E') {
		        EVF.C('SIGN_STATUS').setValue(signStatus);
		        getApproval();
		    } else if (signStatus === 'P') {

				if ('${appType}' == 'II') {

					var param = {
						subject: EVF.C('SUBJECT').getValue(),
						docType: "PR",
						signStatus: "P",
						screenId: "BPRM_010",
						approvalType: 'APPROVAL',
						oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
						attFileNum: "",
						docNum: EVF.getComponent('PR_NUM').getValue(),
						appDocNum: EVF.C('APP_DOC_NUM').getValue(),
						callBackFunction: "goApproval"
					};

					everPopup.openApprovalRequestIIPopup(param);

				} else { // appType == 'I' <-- default
					var param = {
						subject: EVF.C('SUBJECT').getValue(),
						oldApprovalFlag: EVF.C('SIGN_STATUS').getValue(),
						gateCd: '${param.gateCd}',
						docNo: EVF.C('APP_DOC_NUM').getValue()
					};

					everPopup.openApprovalRequestPopup(param);
				}
			}
		}

		function save() {

			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

			var Rcou=0;

		    var allRowIds = grid.getAllRowId();
		    for (var i in allRowIds) {
		        var rowData = grid.getRowValue(allRowIds[i]);
		        if (EVF.C('CUR').getValue() === '' && (rowData['UNIT_PRC'] !== '')) {
		            alert('${BPRM_010_CHOOSE_CURRENCY_VALUE}');
		            return;
		        }

		        if (EVF.isEmpty(rowData['PR_QT'])) {
		        	alert('수량을 넣어주세요.');
		            return;
		        }

		        if (rowData['INSERT_FLAG'] !='D') {
		        	Rcou++;
		        }
		    }

			if (Rcou == 0) {
		        return alert("${BPRM_010_ITEM_DATA_NOT_EXIST}");
		    }

			// 결재요청 시 구매신청품의서에 보여줄 구매유형 텍스트 입력
			EVF.getComponent("PR_NM").setValue(EVF.getComponent('PR_TYPE').getText());

		    var signStatus = this.getData();

		    // 구매요청 제목 자동 세팅
		    validationAndSave(signStatus);
		}

		// appType == 'I' <-- default
		function approvalCallBack(approvalData) {
		    var approvalData = JSON.parse(approvalData);
		    EVF.C('approvalFormData').setValue(approvalData.formData);
		    EVF.C('approvalGridData').setValue(approvalData.gridData);
		    EVF.C('SIGN_STATUS').setValue('P');
		}

		function getApproval() {

			var store = new EVF.Store();
			EVF.C('SUBJECT').setValue(EVF.C('SUBJECT').getValue() + ' ');
			EVF.C('SUBJECT').setValue(EVF.C('SUBJECT').getValue().trim());

			store.doFileUpload(function() {
				store.setGrid([grid,docGrid]);
				store.getGridData(grid, 'sel');
				store.getGridData(docGrid, 'sel');
				store.load(baseUrl + '/doSave', function () {
					alert(this.getResponseMessage());
					if (this.getParameter('isSuccess') === 'true') {
						if (opener != null && opener !== undefined && opener['doSearch'] !== undefined) {
							opener['doSearch']();
							window.close();
						} else {
							var prNum = this.getParameter('PR_NUM');
							location.href=baseUrl+'/view.so?prNum='+prNum;
						}
					}
				});
			});
		}

		// appType == 'II'
		function goApproval(formData, gridData, attachData) {

			EVF.getComponent('approvalFormData').setValue(formData);
			EVF.getComponent('approvalGridData').setValue(gridData);
			EVF.getComponent('attachFileDatas').setValue(attachData);

			var store = new EVF.Store();
			if(!store.validate()) return;

			EVF.C('SIGN_STATUS').setValue('P');

			store.doFileUpload(function() {
				store.setGrid([grid,docGrid]);
				store.getGridData(grid, 'sel');
				store.getGridData(docGrid, 'sel');
				store.load(baseUrl + '/doSave', function () {
					alert(this.getResponseMessage());
					if (this.getParameter('isSuccess') === 'true') {
						if (opener != null && opener !== undefined && opener['doSearch'] !== undefined) {
							opener['doSearch']();
							window.close();
						} else {
							var prNum = this.getParameter('PR_NUM');
							location.href=baseUrl+'/view.so?prNum='+prNum;
						}
					}
				});
			});
		}

		function onClose() {
		    if(opener) {
		        window.close();
		    } else {
		        new EVF.ModalWindow().close(null);
		    }
		}

		function onCurChange() {
		    fillGridItem();
		}

		// 예산조회
		function budgetSearch() {
	        var gridDatas = grid.getSelRowValue();
	        if (gridDatas.length == 0) return alert("${msg.M0004}");

	        var selectedRows = JSON.stringify(gridDatas);

			var param = {
		        prItemList : selectedRows,
				detailView : true,
				popupFlag : true
			};

			everPopup.openPopupByScreenId('BPRM_020', 1200, 600, param);
		}

		// 화면 초기화
		function doReset() {
			location.href = baseUrl+'/view';
		}

		// 구매유형 변경시 계정코드 및 자재그룹코드 초기화
		function prTypeChange () {
            var selRowId = grid.getSelRowId();
            for(var x in selRowId) {
                var rowId = selRowId[x];
                grid.setCellValue(rowId, 'ACCOUNT_CD', '');
                grid.setCellValue(rowId, 'ACCOUNT_NM', '');
                grid.setCellValue(rowId, 'MAT_GROUP', '');
                grid.setCellValue(rowId, 'MAT_GROUP_NM', '');
		    }
		}

	</script>

	<e:window id="BPRM_010" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>
	    <e:inputHidden id='BUYER_REQ_CD' name="BUYER_REQ_CD" value="${form.BUYER_REQ_CD}" />
   		<e:inputHidden id='APP_DOC_NUM' name="APP_DOC_NUM" value="${empty param.appDocNum ? form.APP_DOC_NUM : param.appDocNum}" />
    	<e:inputHidden id='APP_DOC_CNT' name="APP_DOC_CNT" value="${form.APP_DOC_CNT}" />
    	<e:inputHidden id='SIGN_STATUS' name="SIGN_STATUS" value="${form.SIGN_STATUS}" />
    	<e:inputHidden id="RMK_TEXT_NUM" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}" />
    	<e:inputHidden id="approvalFormData" name="approvalFormData"/>
    	<e:inputHidden id="approvalGridData" name="approvalGridData"/>
	    <e:inputHidden id="attachFileDatas" name="attachFileDatas" visible="false" />
		<e:inputHidden id="prList" name="prList" />
		<e:inputHidden id="BLSM_MSG" name="BLSM_MSG" value="${form.BLSM_MSG}"/>

    	<e:buttonBar align="right">
			<e:button label='${save_N }' id='save' onClick='save' disabled='${save_D }' visible='${save_V }' data='T'/>
			<e:button label='${approvalRequest_N }' id='approvalRequest' onClick='save' disabled='${approvalRequest_D }' visible='${approvalRequest_V }' data='P'/>
			<e:button label="${purchaseRequest_N}" id="purchaseRequest" onClick="save" disabled="${purchaseRequest_D}" visible="${devFlag == 'true' ? true : false}" data='E'/>
			<!-- 삭제는 "작성중"인 경우에만 가능함 -->
			<c:if test="${form.SIGN_STATUS == 'T'}">
				<e:button label='${delete_N }' id='delete' onClick='deletePR' disabled='${delete_D }' visible='${delete_V }' data='${delete_A }'/>
			</c:if>
			<c:if test="${form.BLSM_MSG ne '' and form.BLSM_MSG ne null}">
				<e:button id="gwDocView" name="gwDocView" label="${gwDocView_N}" onClick="gwDocView" disabled="${gwDocView_D}" visible="${gwDocView_V}"/>
			</c:if>
			<!-- 닫기는 "팝업"에서만 보이도록 함 -->
			<c:if test="${param.popupFlag eq true}">
				<e:button label='${onClose_N }' id='onClose' onClick='onClose' disabled='${onClose_D }' visible='${onClose_V }' data='${onClose_A }'/>
			</c:if>
	    </e:buttonBar>

    	<e:searchPanel id="form" title="${BPRM_010_GENERAL_INFO}" labelWidth="135" labelAlign="${labelAlign}" columnCount="2" onEnter="doSearch">
        <e:row>
			<%--구매요청번호--%>
            <e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
            <e:field>
                <e:inputText id='PR_NUM' name="PR_NUM" value="${empty form.PR_NUM ? param.prNum : form.PR_NUM}" label='${form_PR_NUM_N }' width='${inputTextWidth }' maxLength='${form_PR_NUM_M }' required='${form_PR_NUM_R }' readOnly='${form_PR_NUM_RO }' disabled='${form_PR_NUM_D }' visible='${form_PR_NUM_V }'/>
            </e:field>
			<%--구매유형--%>
			<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
			<e:field>
				<e:select id="PR_TYPE" name="PR_TYPE" value="${empty form.PR_TYPE ? param.PR_TYPE : form.PR_TYPE}" onChange="prTypeChange" options="${prTypeOptions}" width="${inputTextWidth}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				<e:inputHidden id="PR_NM" name="PR_NM" />
			</e:field>
        </e:row>
        <e:row>
			<%--구매요청명--%>
            <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
            <e:field colSpan="3">
                <e:inputText id='SUBJECT' name="SUBJECT" value="${form.SUBJECT}" label='${form_SUBJECT_N }' width="100%" maxLength='${form_SUBJECT_M }' required='${form_SUBJECT_R }' readOnly='${form_SUBJECT_RO }' disabled='${form_SUBJECT_D }' visible='${form_SUBJECT_V }'/>
            </e:field>
        </e:row>
		<e:row>
			<%--구매요청일자--%>
			<e:label for="REQ_DATE" title="${form_REQ_DATE_N}"/>
			<e:field>
				<e:inputDate id='REQ_DATE' name="REQ_DATE" value="${form.REQ_DATE}" label='${form_REQ_DATE_N }' format='yy/mm/dd' width='${inputDateWidth }' required='${form_REQ_DATE_R }' readOnly='${form_REQ_DATE_RO }' disabled='${form_REQ_DATE_D }' visible='${form_REQ_DATE_V }' datePicker='true'/>
			</e:field>
			<%--요청자--%>
			<e:label for="REQ_USER_NM" title="${form_REQ_USER_NM_N}"/>
			<e:field>
				<e:inputText id="REQ_USER_NM" style="${imeMode}" name="REQ_USER_NM" value="${empty form.REQ_USER_NM ? ses.userNm : form.REQ_USER_NM}" width='${inputTextWidth}' maxLength="${form_REQ_USER_NM_M}" disabled="${form_REQ_USER_NM_D}" readOnly="${form_REQ_USER_NM_RO}" required="${form_REQ_USER_NM_R}"/>
				<e:inputHidden id="REQ_USER_ID" name="REQ_USER_ID" value="${empty form.REQ_USER_ID ? ses.userId : form.REQ_USER_ID}"/>
				<e:text> / </e:text>
				<e:inputText id="REQ_DEPT_NM" style="${imeMode}" name="REQ_DEPT_NM" value="${empty form.REQ_DEPT_NM ? ses.deptNm : form.REQ_DEPT_NM}" width="${inputTextWidth}" maxLength="${form_REQ_DEPT_NM_M}" disabled="${form_REQ_DEPT_NM_D}" readOnly="${form_REQ_DEPT_NM_RO}" required="${form_REQ_DEPT_NM_R}"/>
			</e:field>
		</e:row>
        <e:row>
			<%--통화(사용자가 속한 회사의 cur 자동으로 뿌려주기)--%>
			<e:label for="CUR" title="${form_CUR_N}"/>
			<e:field colSpan="3">
				<e:select id='CUR' name="CUR" width="100" value="${empty form.CUR ? ses.cur : form.CUR}" options="${currency}" required='${form_CUR_R }' readOnly='${form_CUR_RO }' disabled='${form_CUR_D }' visible='${form_CUR_V }' placeHolder='${placeHolder }' onChange="onCurChange"/>
			</e:field>
			<e:inputHidden id="PR_AMT" name="PR_AMT" value="${form.PR_AMT}" />
		</e:row>
		<%--특기사항--%>
        <e:row>
            <e:label for="RMK" title="${form_RMK_TEXT_NUM_N}"/>
            <e:field colSpan="3">
                <e:richTextEditor id="RMK" name="RMK" value="${form.RMK}" height="150" width='100%' disabled='${form_RMK_TEXT_NUM_D }' visible='${form_RMK_TEXT_NUM_V }' readOnly="${form_RMK_TEXT_NUM_RO}" required="${form_RMK_TEXT_NUM_R}"/>
            </e:field>
        </e:row>
		<%--파일첨부--%>
		<e:row>
			<e:label for="" title="${form_ATT_FILE_NUM_N}"/>
			<e:field colSpan="3">
				<e:fileManager id="ATT_FILE_NUM" height="150" width="100%" fileId="${form.ATT_FILE_NUM}" readOnly="${form_ATT_FILE_NUM_RO}" bizType="PR" required="${form_ATT_FILE_NUM_R}"/>
			</e:field>
		</e:row>
		<!-- G/W 관련문서 -->
		<e:row>
			<e:label for="" title="${BPRM_010_GW_RELATED_DOC}"/>
			<e:field colSpan="3">
				<e:gridPanel gridType="${_gridType}" id="docGrid" name="docGrid" height="150" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.docGrid.gridColData}"/>
			</e:field>
		</e:row>
	    </e:searchPanel>

		<jsp:include page="/WEB-INF/views/eversrm/eApproval/approvalSignUserList.jsp" flush="true" >
			<jsp:param value="${form.APP_DOC_NUM}" name="APP_DOC_NUM"/>
			<jsp:param value="${form.APP_DOC_CNT}" name="APP_DOC_CNT"/>
		</jsp:include>

		<!-- 버튼(품목선택, 예산조회) -->
		<c:if test="${param.detailView != true}">
    	<e:buttonBar align="right">
			<!--
			<e:button id="gridApply" name="gridApply" label="${gridApply_N}" onClick="gridApply" disabled="${gridApply_D}" visible="${gridApply_V}"/>
			-->
	        <e:button label='${catalog_N }' id='catalog' onClick='openItemPopup' disabled='${catalog_D }' visible='${catalog_V }' data='BPR_040'/>
			<e:button label="${budgetSearch_N}" id="budgetSearch" name="budgetSearch" onClick="budgetSearch" disabled="${budgetSearch_D}" visible="${budgetSearch_V}"/>
   	 	</e:buttonBar>
		</c:if>
		<e:searchPanel id="gridForm" title="${BPRM_010_ITEM_INFO}" labelWidth="${labelWidth}" labelAlign="${labelAlign}">
		<e:row>
			<e:field>
    			<e:gridPanel gridType="${_gridType}" id="grid" name="grid" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    		</e:field>
    	</e:row>
    	</e:searchPanel>
	</e:window>
</e:ui>

