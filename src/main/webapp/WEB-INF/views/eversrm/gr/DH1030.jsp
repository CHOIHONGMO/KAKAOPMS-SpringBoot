<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var docGrid;
        var baseUrl = "/eversrm/gr/DH1030";
        var selRow;

        function init() {

            if(${not empty form.SL_NUM} && ${not param.detailView eq 'true'}) {
                alert('${DH1030_002}');
                formUtil.close();
            }

            grid = EVF.C('grid');
            docGrid = EVF.C('docGrid');
            docGrid.setProperty("shrinkToFit", true);
            grid.setProperty("shrinkToFit", true);
            grid.setProperty('panelVisible', ${panelVisible});
    		if (${empty form.DEAL_NUM}) {
        		EVF.C('SL_TYPE').removeOption('IN');
        		EVF.C('SL_TYPE').removeOption('ET');
        		EVF.C('SL_TYPE').removeOption('BU');
        		EVF.C('SL_TYPE').removeOption('IV');
        		EVF.C('GL_ACCOUNT_CD').setValue('21113101');
        		EVF.C('GL_ACCOUNT_NM').setValue('미지급금-국내');
        		EVF.C('VAT_GL_ACCOUNT_CD').setValue("11131101");
    		}

            //grid Column Head Merge
            grid.setProperty('multiselect', true);

            // Grid AddRow Event
            grid.addRowEvent(function () {
            	var plantCd = EVF.C('PLANT_CD').getValue();

            	var addParam = [{
                	'BIZ_AREA_CD' : plantCd
        		}];
                grid.addRow(addParam);
            });
            grid.delRowEvent(function () {
            	grid.delRow();
            });

            // Grid Excel Event
            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }",
                excelOptions: {
                    imgWidth: 0.12,
                    imgHeight: 0.26,
                    colWidth: 20,
                    rowSize: 500,
                    attachImgFlag: false
                }
            });

            grid.cellClickEvent(function (rowId, colId, value, rowIdx, colIdx) {

                if (colId == 'BTN_ACCOUNT_CD') {
                	selRow = rowId;

                    if ('${param.detailView}' != 'true') {

                        <%--var purc_type = EVF.C('PURCHASE_TYPE').getValue();--%>
                        <%--if(EVF.isEmpty(purc_type)) {--%>
                            <%--return alert('${DH1030_SELECT_PURCHASE_TYPE}');--%>
                        <%--}--%>

//                        // 구매유형이 "수선,제작,품의"는 계정 및 자재그룹을 함께 표시함
//                        if (purc_type == 'AS' || purc_type == 'NEW' || purc_type == 'DC') {
//                            var param = {
//                                'callBackFunction': 'setAccount',
//                                'detailView': false,
//                                'rowId': rowId
//                            };
//                            everPopup.openCommonPopup(param, "SP0035");
//                        } else {
//                            var param = {
//                                'callBackFunction': 'setAccount',
//                                'detailView': false,
//                                'rowId': rowId
//                            };
//                            everPopup.openCommonPopup(param, "SP0048");
//                        }

                        var param = {
                            'callBackFunction': 'setAccount',
                            'detailView': false,
                            'rowId': rowId
                        };
                        everPopup.openCommonPopup(param, "SP0024");
                    }
                }

                if (colId == 'COST_CD_IMAGE_TEXT') {
                	selRow = rowId;
                    if (EVF.isEmpty(EVF.C('PLANT_CD').getValue())) {
                        return alert('${DH1030_001}');
                    }

                    var param = {
                        "callBackFunction": '_setCostCd',
                        "PLANT_CD": EVF.C('PLANT_CD').getValue()
                    };
                    everPopup.openCommonPopup(param, "SP0036");
                }

            });

            grid.cellChangeEvent(function (rowId, colId, rowIdx, colIdx, value, oldValue) {

		        switch (colId) {
					case 'ACCOUNT_CD':
						var store = new EVF.Store();
						store.setParameter("ACCOUNT_NUM", value);
						store.load(baseUrl + "/doAccountSearch", function () {
							var accountMap = JSON.parse(this.getParameter("accountMap"));

							if(accountMap != undefined || accountMap != null) {
								grid.setCellValue(rowId, "ACCOUNT_NM", accountMap.ACCOUNT_NM);
							} else {
								alert("${DH1030_007}"); // 계정코드가 존재하지 않습니다.\n확인하여 주시기 바랍니다.
								grid.setCellValue(rowId, colId, "");
								grid.setCellValue(rowId, "ACCOUNT_NM", "");

							}
						});
					break;

					case 'COST_CD':
						if (EVF.C("PLANT_CD").getValue() == '') {
							alert("${DH1030_001}");

							grid.setCellValue(rowId, colId, "");
							grid.setCellValue(rowId, "COST_CD_NM", "");

							return;
						}

						var store = new EVF.Store();
						store.setParameter("PLANT_CD", EVF.C("PLANT_CD").getValue());
						store.setParameter("COST_CD", value);
						store.load(baseUrl + "/doCostSearch", function () {
							var costMap = JSON.parse(this.getParameter("costMap"));

							if(costMap != undefined || costMap != null) {
								grid.setCellValue(rowId, "COST_CD_NM", costMap.COST_NM);
							} else {
								alert("${DH1030_006}"); // 코스트센터코드가 존재하지 않습니다.\n확인하여 주시기 바랍니다.
								grid.setCellValue(rowId, colId, "");
								grid.setCellValue(rowId, "COST_CD_NM", "");

							}
						});
					break;
				}

            	if (colId == 'GR_QT' || colId == 'UNIT_PRC' || 'GR_AMT') {
					/*
                	if (EVF.C('CUR').getValue() === '') {
                        alert('${DH1030_CHOOSE_CUR}');
                        grid.setCellValue(rowId, colId, oldValue);
                        return;
                    }

                    if (Number(value) < 0) {
                        alert('${DH1030_NO_ZERO_ALLOWED}');
                        grid.setCellValue(rowId, colId, oldValue);
                        return;
                    }

                    var cur = EVF.C('CUR').getValue();
                    var qty = grid.getCellValue(rowId, "GR_QT");
                    var prc = grid.getCellValue(rowId, "UNIT_PRC");
                    grid.setCellValue(rowId, "GR_AMT", everCurrency.getAmount(cur, prc * qty));

                    var sum = 0;
                    for (var i = 0; i < grid.getRowCount(); i++) {

                        var qty = grid.getCellValue(i, "GR_QT");
                        var price = grid.getCellValue(i, "UNIT_PRC");
                        sum += everCurrency.getAmount(cur, price * qty);
                    }
					*/

					var sum = 0;

                    var allRowId = grid.getAllRowId();
                    for(var i in allRowId) {

                        sum += Number(grid.getCellValue(allRowId[i], "GR_AMT"));
                    }

					EVF.getComponent('SUP_AMT').setValue(sum);
                    setAmount();
                }
            });

            docGrid.addRowEvent(function () {
                docGrid.addRow();
            });

            docGrid.delRowEvent(function () {
                docGrid.delRow();
            });

            docGrid.cellClickEvent(function(rowId, celName, value, iRow, iCol) {
                var userwidth  = 810; // 고정(수정하지 말것)
    			var userheight = (screen.height - 2);
    			if (userheight < 780) userheight = 780; // 최소 780
    			var LeftPosition = (screen.width-userwidth)/2;
    			var TopPosition  = (screen.height-userheight)/2;
    			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

    			switch (celName) {
                    case 'APRV_URL':
    	            	if ('${param.detailView}' == 'true' && docGrid.getCellValue(rowId, celName) != '' && docGrid.getCellValue(rowId, celName).length > 200) {
        	            	window.open(docGrid.getCellValue(rowId, celName), "signwindow", gwParam);
            	        }
                	    break;
    				default:
    			}
    		});

            if (EVF.isNotEmpty('${param.dealNum}')) {
                doSearch();
            } else {
            	if (EVF.isEmpty(EVF.getComponent('REF_DOC_NUM').getValue()) && EVF.isNotEmpty(EVF.getComponent('PLANT_CD').getValue())) {
            		_selectCostCdOnChange();
            	}
            }
        }

        function setAccount(data) {
            grid.setCellValue(selRow, "ACCOUNT_CD", data['ACCOUNT_CD']);
            grid.setCellValue(selRow, "ACCOUNT_NM", data['ACCOUNT_NM']);
        }

        // Search
        function doSearch() {
            var store = new EVF.Store();

            store.setGrid([grid]);
            store.load(baseUrl + '/doSearch', function () {
                doSearchGroupwareDocs();
            });
        }

        function doSearchGroupwareDocs() {

            var store = new EVF.Store();
            store.setGrid([docGrid]);
            store.load(baseUrl + '/doSearchGroupwareDocs', function () {

            }, false);
        }

        // Save
        function doSave() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            grid.checkAll(true);

            if(EVF.C('DATA_CREATE_TYPE').getValue() != 'S') /* 매뉴얼생성일 경우만 아래의 조건을 체크한다. */ {
                if(Number(EVF.C("VAT_AMT").getValue()) > 0) {
                    EVF.C('VAT_GL_ACCOUNT_CD').setRequired(true);
                } else {
                    EVF.C('VAT_GL_ACCOUNT_CD').setRequired(false);
                }
            }

            var store = new EVF.Store();
            if (!store.validate()) {
                return;
            }

            var selRowsI = grid.getSelRowValue();
            if (EVF.C('SL_TYPE').getValue() == 'CA' || EVF.C('SL_TYPE').getValue() == 'GE')  {
	            if (!grid.isExistsSelRow()) {
	                return alert('${msg.M0004}');
	            }
	            if (!grid.validate().flag) {
	                return alert("${msg.M0014}");
	            }
            	for(var k =0;k<selRowsI.length;k++) {
            		if (selRowsI[k].COST_CD == '') {
            			alert('${DH1030_009}');
            			return;
            		}
            	}
            } else if (EVF.C('SL_TYPE').getValue() == 'SE' || EVF.C('SL_TYPE').getValue() == 'MA' || EVF.C('SL_TYPE').getValue() == 'EN' || EVF.C('SL_TYPE').getValue() == 'ST' || EVF.C('SL_TYPE').getValue() == 'GS')  {
	            if (!grid.isExistsSelRow()) {
	                return alert('${msg.M0004}');
	            }
	            if (!grid.validate().flag) {
	                return alert("${msg.M0014}");
	            }

            	for(var k =0;k<selRowsI.length;k++) {
            		if (selRowsI[k].SAP_ORDER_NUM == '') {
            			alert('${DH1030_010}');
            			return;
            		}
            	}
            }

            if (!confirm("${msg.M0021}")) {
                return;
            }

            store.setGrid([grid, docGrid]);
            store.getGridData(grid, 'all');
            store.getGridData(docGrid, 'all');
            store.doFileUpload(function () {
                store.load(baseUrl + '/doSave', function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    if (${not empty param.popupFlag}) {
                        var params = {
                                "dealNum": this.getParameter('dealNum')
                            };
                            location.href = baseUrl + '/view.so?' + $.param(params);
                    } else {
                        location.href = baseUrl + '/view.so?';
                    }
                });
            })
        }

        function doDelete() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            if(${empty form.DEAL_NUM}) {
                return alert("${msg.M0118}");
            }

            if (!confirm('${msg.M0013}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doDelete', function () {
            	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                alert(this.getResponseMessage());
                formUtil.close();
            });
        }

        function _getVendorNm() {
            var param = {
                callBackFunction: '_setVendorNm'
            };
            everPopup.openCommonPopup(param, "SP0025");
        }

        function _setVendorNm(data) {
            EVF.C('VENDOR_CD').setValue(data['VENDOR_CD']);
            EVF.C('VENDOR_NM').setValue(data['VENDOR_NM']);
            EVF.C('PAY_TERMS').setValue(data['PAY_TERMS']);
            EVF.C('PAY_TERMS_NM').setValue(data['PAY_TERMS_NM']);
        }

        function getPayTerms() {
            var param = {
                "callBackFunction": 'setPayTerms'
            };
            everPopup.openCommonPopup(param, "SP0055");
        }

        function setPayTerms(data) {
            EVF.C('PAY_TERMS').setValue(data['CODE']);
            EVF.C('PAY_TERMS_NM').setValue(data['CODE_DESC']);
        }

        function _getGlAccount() {

        	if (EVF.C('SL_TYPE').getValue() == 'CA') return;
            var param = {
                "callBackFunction": '_setGlAccount'
            };
            everPopup.openCommonPopup(param, "SP0024");
        }

        function _setGlAccount(data) {
            EVF.C('GL_ACCOUNT_CD').setValue(data['ACCOUNT_CD']);
            EVF.C('GL_ACCOUNT_NM').setValue(data['ACCOUNT_NM']);
        }

        function _getCostCd() {

            if (EVF.isEmpty(EVF.C('PLANT_CD').getValue())) {
                return alert('${DH1030_001}');
            }

            var param = {
                "callBackFunction": '_setCostCd',
                "PLANT_CD": EVF.C('PLANT_CD').getValue()
            };
            everPopup.openCommonPopup(param, "SP0036");
        }

        /*
        function _clearCostCdOnChange() {
        	return;
            EVF.C('COST_CD').setValue('');
            EVF.C('COST_NM').setValue('');
        }
        */

        function _selectCostCdOnChange() {
			var plantCd = EVF.getComponent('PLANT_CD').getValue();

			var store = new EVF.Store();
			store.setParameter("PLANT_CD", plantCd);
			store.load(baseUrl + "/doPlantCostSearch", function () {
				var plantCostMap = JSON.parse(this.getParameter("plantCostMap"));

				if(plantCostMap != undefined || plantCostMap != null) {
		            EVF.getComponent('REF_DOC_NUM').setValue(plantCostMap.PLANT_COST_CD);
				} else {
		            EVF.getComponent('REF_DOC_NUM').setValue('');
				}
			});
        }

        function _setCostCd(data) {

        	grid.setCellValue(selRow,'COST_CD',data['COST_CD']);
        	grid.setCellValue(selRow,'COST_CD_NM',data['COST_NM']);

        	return;
        	EVF.C('COST_CD').setValue(data['COST_CD']);
            EVF.C('COST_NM').setValue(data['COST_NM']);
        }

        function doClose() {
            formUtil.close();
        }

        function doDeleteItem() {

            if (!grid.isExistsSelRow()) {
                return alert('${msg.M0004}');
            }

            var selRowId = grid.getSelRowId();
            for(var ri in selRowId) {

                var rowId = selRowId[ri];
                if(EVF.isEmpty(grid.getCellValue(rowId, 'GR_NUM')) && EVF.isEmpty(grid.getCellValue(rowId, 'DEAL_NUM'))) {
                    grid.delRow(rowId);
                }
            }

            setAmount();

            if(!grid.isExistsSelRow()) {
                return;
            }

            if (!confirm('${msg.M8888}')) {
                return;
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + '/doDeleteItem', function () {
                doSearch();
                alert(this.getResponseMessage());
            });

        }

        function setAmount() {

            var cur = EVF.C('CUR').getValue();
            var taxCd = EVF.C('TAX_CD').getValue();
            var taxText = EVF.C('TAX_CD').getText();

            var supAmt = 0;
            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {

                var rowId = allRowId[i];
                var grAmt = everCurrency.getAmount(cur, grid.getCellValue(rowId, 'GR_AMT'));
                supAmt = supAmt + grAmt;
            }

            EVF.C('SUP_AMT').setValue(supAmt);

            if(EVF.isEmpty(cur) || EVF.isEmpty(taxCd) || EVF.isEmpty(supAmt)) {
                EVF.C('VAT_AMT').setValue(0);
                EVF.C('TOTAL_AMT').setValue(EVF.C('SUP_AMT').getValue());
                EVF.C('VAT_GL_ACCOUNT_CD').setValue('');
                EVF.C('VAT_GL_ACCOUNT_CD').setDisabled(true);
            } else {
                var pct = (taxText.indexOf('10%') > -1) ? 10 : taxCd.indexOf('0%') > -1 ? 0 : 0;
                if(pct === 10) {

                    var vatAmt = parseInt(supAmt * 0.1);
                    EVF.C('VAT_AMT').setValue(vatAmt);
                    EVF.C('VAT_AMT').setDisabled(false);
                    EVF.C('TOTAL_AMT').setValue(supAmt + vatAmt);
                    if (vatAmt > 0) {
                        EVF.C('VAT_GL_ACCOUNT_CD').setValue("11131101");
                    }
                    EVF.C('VAT_GL_ACCOUNT_CD').setDisabled(false);
                } else if(pct === 0) {
                    EVF.C('VAT_GL_ACCOUNT_CD').setValue('');
                    EVF.C('VAT_GL_ACCOUNT_CD').setDisabled(true);
                    EVF.C('VAT_AMT').setValue(0);
                    EVF.C('VAT_AMT').setDisabled(true);
                    EVF.C('TOTAL_AMT').setValue(EVF.C('SUP_AMT').getValue());
                }
            }
        }

        function setTotalAmount() {
            EVF.C('TOTAL_AMT').setValue(EVF.C('SUP_AMT').getValue() + EVF.C('VAT_AMT').getValue());
        }

        function _onChangePurchaseType() {

            var purchaseType = EVF.C('PURCHASE_TYPE').getValue();
            if(purchaseType == 'ISP') /* 투자품의의 경우 SAP오더번호를 필수입력받는다. */ {
                EVF.C('SAP_ORDER_NUM').setRequired(true);
            } else {
                EVF.C('SAP_ORDER_NUM').setRequired(false);
            }
        }

        function chSlType() {
        	if (EVF.C('SL_TYPE').getValue() == 'CA') {
                EVF.C('GL_ACCOUNT_CD').setValue('21113103');
                EVF.C('GL_ACCOUNT_NM').setValue('미지급금-법인카드');
                EVF.C('GL_ACCOUNT_CD').setReadOnly(true);
        	} else {
                EVF.C('GL_ACCOUNT_CD').setValue('21113101');
                EVF.C('GL_ACCOUNT_NM').setValue('미지급금-국내');
                EVF.C('GL_ACCOUNT_CD').setReadOnly(false);
        	}

        	if (EVF.C('SL_TYPE').getValue() == 'GS') {
                EVF.C('SL_DIV').setValue('GS'); //선급금
        	} else {
                EVF.C('SL_DIV').setValue('SB'); //일반마감전표
        	}
        }

    </script>

    <e:window id="DH1030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="DATA_CREATE_TYPE" name="DATA_CREATE_TYPE" value="${form.DATA_CREATE_TYPE}" />

        <e:buttonBar width="100%" align="right">
        	<!--
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            -->
            <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
            <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
            <c:if test="${not empty param.popupFlag}">
                <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
            </c:if>
        </e:buttonBar>

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="130" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
            <e:row>
                <e:label for="DEAL_NUM" title="${form_DEAL_NUM_N}"/>
                <e:field>
                    <e:inputText id="DEAL_NUM" style="ime-mode:inactive" name="DEAL_NUM" value="${form.DEAL_NUM}" width="${inputTextWidth}" maxLength="${form_DEAL_NUM_M}" disabled="${form_DEAL_NUM_D}" readOnly="${form_DEAL_NUM_RO}" required="${form_DEAL_NUM_R}"/>
                </e:field>

				<e:label for="SL_TYPE" title="${form_SL_TYPE_N}"/>
				<e:field>
				<e:select id="SL_TYPE" onChange="chSlType" name="SL_TYPE" value="${form.SL_TYPE}" options="${slTypeOptions}" width="${inputTextWidth}" disabled="${form_SL_TYPE_D}" readOnly="${form_SL_TYPE_RO}" required="${form_SL_TYPE_R}" placeHolder="" />
				</e:field>

                <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
                <e:field>
                    <e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${inputTextWidth}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
                </e:field>

			</e:row>
			<e:row>
                <e:label for="PROOF_DATE" title="${form_PROOF_DATE_N}"/>
                <e:field>
                    <e:inputDate id="PROOF_DATE" name="PROOF_DATE" value="${empty form.PROOF_DATE ? today : form.PROOF_DATE}" width="${inputTextDate}" datePicker="true" required="${form_PROOF_DATE_R}" disabled="${form_PROOF_DATE_D}" readOnly="${form_PROOF_DATE_RO}"/>
                </e:field>
                <e:label for="DEAL_DATE" title="${form_DEAL_DATE_N}"/>
                <e:field>
                    <e:inputDate id="DEAL_DATE" name="DEAL_DATE" value="${empty form.DEAL_DATE ? today : form.DEAL_DATE}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_DATE_R}" disabled="${form_DEAL_DATE_D}" readOnly="${form_DEAL_DATE_RO}"/>
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}/${form_REF_DOC_NUM_N}"/>
                <e:field>
                    <e:select id="PLANT_CD" name="PLANT_CD" value="${empty form.PLANT_CD ? ses.plantCd : form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth }" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" onChange="_selectCostCdOnChange"/>
                    <e:text>/</e:text>
                    <e:inputText id="REF_DOC_NUM" style="ime-mode:inactive" name="REF_DOC_NUM" value="${form.REF_DOC_NUM}" width="60" maxLength="${form_REF_DOC_NUM_M}" disabled="${form_REF_DOC_NUM_D}" readOnly="${form_REF_DOC_NUM_RO}" required="${form_REF_DOC_NUM_R}"/>
					<e:inputText id="REF_DOC_NUM_TEXT" style="${imeMode}" name="REF_DOC_NUM_TEXT" value="${form.REF_DOC_NUM_TEXT}" width="55" maxLength="${form_REF_DOC_NUM_TEXT_M}" disabled="${form_REF_DOC_NUM_TEXT_D}" readOnly="${form_REF_DOC_NUM_TEXT_RO}" required="${form_REF_DOC_NUM_TEXT_R}"/>
                </e:field>
            </e:row>

			<e:row>
				<e:label for="SL_DIV" title="${form_SL_DIV_N}"/>
				<e:field>
					<e:select id="SL_DIV" name="SL_DIV" value="${empty form.SL_DIV ? 'SB' : form.SL_DIV}" options="${slDivOptions}" width="${inputTextWidth}" disabled="${form_SL_DIV_D}" readOnly="${form_SL_DIV_RO}" required="${form_SL_DIV_R}" placeHolder="" />
				</e:field>                <e:label for="REMARK" title="${form_REMARK_N}"/>
                <e:field colSpan="3">
                    <e:inputText id="REMARK" style="ime-mode:auto" name="REMARK" value="${form.REMARK}" width="100%" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}"/>
                </e:field>
			</e:row>

			<e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${form.VENDOR_CD}" width="35%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : '_getVendorNm'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="VENDOR_NM" style="ime-mode:auto" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
                <e:label for="GL_ACCOUNT_CD" title="${form_GL_ACCOUNT_CD_N}"/>
                <e:field>
                    <e:search id="GL_ACCOUNT_CD" style="ime-mode:inactive" name="GL_ACCOUNT_CD" value="${form.GL_ACCOUNT_CD}" width="35%" maxLength="${form_GL_ACCOUNT_CD_M}" onIconClick="${form_GL_ACCOUNT_CD_RO ? 'everCommon.blank' : '_getGlAccount'}" disabled="${form_GL_ACCOUNT_CD_D}" readOnly="${form_GL_ACCOUNT_CD_RO}" required="${form_GL_ACCOUNT_CD_R}"/>
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="GL_ACCOUNT_NM" style="ime-mode:inactive" name="GL_ACCOUNT_NM" value="${form.GL_ACCOUNT_NM}" width="60%" maxLength="${form_GL_ACCOUNT_NM_M}" disabled="${form_GL_ACCOUNT_NM_D}" readOnly="${form_GL_ACCOUNT_NM_RO}" required="${form_GL_ACCOUNT_NM_R}"/>
                </e:field>
                <e:label for="TAX_CD" title="${form_TAX_CD_N}"/>
                <e:field>
                    <e:select id="TAX_CD" name="TAX_CD" value="${form.TAX_CD}" options="${taxCdOptions}" width="100%" disabled="${form_TAX_CD_D}" readOnly="${form_TAX_CD_RO}" required="${form_TAX_CD_R}" placeHolder="" onChange="setAmount" />
                    <e:inputHidden id="TAX_NM" name="TAX_NM" value="${form.TAX_NM}" />
                </e:field>
			</e:row>

            <e:row>
                <e:label for="SUP_AMT" title="${form_SUP_AMT_N}"/>
                <e:field>
                    <e:select id="CUR" name="CUR" value="${empty form.CUR ? 'KRW' : form.CUR}" options="${curOptions}" width="35%" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" onChange="setAmount" />
                    <e:text>&nbsp;</e:text>
                    <e:inputNumber id="SUP_AMT" name="SUP_AMT" value="${form.SUP_AMT}" width="60%"  maxValue="${form_SUP_AMT_M}" decimalPlace="${form_SUP_AMT_NF}" disabled="${form_SUP_AMT_D}" readOnly="${form_SUP_AMT_RO}" required="${form_SUP_AMT_R}" onChange="setAmount" />
                </e:field>
                <e:label for="VAT_AMT" title="${form_VAT_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="VAT_AMT" name="VAT_AMT" value="${form.VAT_AMT}" width="35%"  maxValue="${form_VAT_AMT_M}" decimalPlace="${form_VAT_AMT_NF}" disabled="${form_VAT_AMT_D}" readOnly="${form_VAT_AMT_RO}" required="${form_VAT_AMT_R}" onChange="setTotalAmount" />
                    <e:text>&nbsp;</e:text>
                    <e:select id="VAT_GL_ACCOUNT_CD" name="VAT_GL_ACCOUNT_CD" value="${form.VAT_GL_ACCOUNT_CD}" options="${vatGlAccountCdOptions}" width="60%" disabled="${form_VAT_GL_ACCOUNT_CD_D}" readOnly="${form_VAT_GL_ACCOUNT_CD_RO}" required="${form_VAT_GL_ACCOUNT_CD_R}" placeHolder="" />
                </e:field>
                <e:label for="TOTAL_AMT" title="${form_TOTAL_AMT_N}"/>
                <e:field>
                    <e:inputNumber id="TOTAL_AMT" name="TOTAL_AMT" value="${form.TOTAL_AMT}" width="${inputTextWidth}"  maxValue="${form_TOTAL_AMT_M}" decimalPlace="${form_TOTAL_AMT_NF}" disabled="${form_TOTAL_AMT_D}" readOnly="${form_TOTAL_AMT_RO}" required="${form_TOTAL_AMT_R}"/>
                </e:field>
            </e:row>

            <c:if test="${form.SL_TYPE != 'IN' }">
			<e:row>
                <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
                <e:field colSpan="5">
                    <e:search id="PAY_TERMS" style="ime-mode:inactive" name="PAY_TERMS" value="${form.PAY_TERMS}" width="100" maxLength="${form_PAY_TERMS_M}" onIconClick="${form_PAY_TERMS_RO ? 'everCommon.blank' : 'getPayTerms'}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="PAY_TERMS_NM" style="ime-mode:inactive" name="PAY_TERMS_NM" value="${form.PAY_TERMS_NM}" width="250" maxLength="${form_PAY_TERMS_NM_M}" disabled="${form_PAY_TERMS_NM_D}" readOnly="${form_PAY_TERMS_NM_RO}" required="${form_PAY_TERMS_NM_R}"/>
                </e:field>
				<e:inputHidden id="SAP_ORDER_NUM" name="SAP_ORDER_NUM" value="${form.SAP_ORDER_NUM}"/>
			</e:row>
            </c:if>

            <c:if test="${form.SL_TYPE == 'IN' }">
			<e:row>
                <e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
                <e:field colSpan="3">
                    <e:search id="PAY_TERMS" style="ime-mode:inactive" name="PAY_TERMS" value="${form.PAY_TERMS}" width="100" maxLength="${form_PAY_TERMS_M}" onIconClick="${form_PAY_TERMS_RO ? 'everCommon.blank' : 'getPayTerms'}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" />
                    <e:text>&nbsp;</e:text>
                    <e:inputText id="PAY_TERMS_NM" style="ime-mode:inactive" name="PAY_TERMS_NM" value="${form.PAY_TERMS_NM}" width="250" maxLength="${form_PAY_TERMS_NM_M}" disabled="${form_PAY_TERMS_NM_D}" readOnly="${form_PAY_TERMS_NM_RO}" required="${form_PAY_TERMS_NM_R}"/>
                </e:field>
                <e:label for="SAP_ORDER_NUM" title="${form_SAP_ORDER_NUM_N}"/>
                <e:field>
                    <e:inputText id="SAP_ORDER_NUM" style="${imeMode}" name="SAP_ORDER_NUM" value="${form.SAP_ORDER_NUM}" width="${inputTextWidth}" maxLength="${form_SAP_ORDER_NUM_M}" disabled="${form_SAP_ORDER_NUM_D}" readOnly="${form_SAP_ORDER_NUM_RO}" required="${form_SAP_ORDER_NUM_R}"/>
                </e:field>
			</e:row>
            </c:if>

            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
                <e:field colSpan="5">
                    <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" bizType="DL" fileId="${form.ATT_FILE_NUM}" width="100%" readOnly="${form_ATT_FILE_NUM_RO}" required="${form_ATT_FILE_NUM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="" title="${form_APRV_URL_N}"/>
                <e:field colSpan="5">
                    <e:gridPanel gridType="${_gridType}" id="docGrid" name="docGrid" height="150" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.docGrid.gridColData}"/>
                </e:field>
            </e:row>

			<e:inputHidden id="BIZ_AREA_CD" name="BIZ_AREA_CD" value="${form.BIZ_AREA_CD}"/>
			<e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}"/>
			<e:inputHidden id="COST_CD" name="COST_CD" value="${form.COST_CD}"/>
        </e:searchPanel>

        <e:buttonBar width="100%" align="right">
            <e:button id="doDeleteItem" name="doDeleteItem" label="${doDeleteItem_N}" onClick="doDeleteItem" disabled="${doDeleteItem_D}" visible="${doDeleteItem_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>
