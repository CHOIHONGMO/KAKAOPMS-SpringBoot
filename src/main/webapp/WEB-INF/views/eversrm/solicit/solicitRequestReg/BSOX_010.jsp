<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
        var itemInfoGrid;
        var gwdoc;
        var rfxType = '${rfxType}';
        var userType = '${ses.userType}';
        var baseUrl = "/eversrm/solicit/solicitRequestReg/";
        var itemInfoGrid;
        var baseDataType = '${param.baseDataType}'; // Refer SolicitRequestRegController.java in order to check base data types.
        var isRFQ = (rfxType === 'RFQ' ? true : false);
        var isPopup = ('${param.popupFlag}' === 'true' ? true : false);
        var isDetailView = ('${param.detailView}' === 'true' ? true : false);
        var isApproval;
        var isApprovalRfxNext =  ${empty isApprovalRfxNext ? "''" : isApprovalRfxNext}; // check for two-step bidding approval.
        var isEditable = !isDetailView;
		var rfq_create_type = '${form.RFQ_CREATE_TYPE}';
		function chPurchaseType() {
			if (EVF.C('PURCHASE_TYPE').getValue() != 'NORMAL') {
		        itemInfoGrid.hideCol('INVEST_CD',true);
		        itemInfoGrid.hideCol('DPRC_QT',true);
		        itemInfoGrid.hideCol('BUY_STND_PRC',true);
		        itemInfoGrid.hideCol('PLAN_STND_PRC',true);

                EVF.C("EV_TPL_CD").setValue('');
                EVF.C("EV_TPL_NM").setValue('');
                EVF.C("EV_TPL_NUM").setValue('');
                EVF.C("SCND_EV_TPL_CD").setValue('');
                EVF.C("SCND_EV_TPL_NM").setValue('');
                EVF.C("SCND_EV_TPL_NUM").setValue('');

	        	EVF.C('MOLD_YN').setChecked(false); // 금형견적여부 => 부품인 경우만 활성화
	        	EVF.C('MOLD_YN').setDisabled(true);
			} else {
		        itemInfoGrid.hideCol('INVEST_CD',false);
		        itemInfoGrid.hideCol('DPRC_QT',false);
		        itemInfoGrid.hideCol('BUY_STND_PRC',false);
		        itemInfoGrid.hideCol('PLAN_STND_PRC',false);

		        EVF.C('PRICE_DECISION_BASE_TEXT').setValue('');
	        	EVF.C('PRICE_DECISION_BASE_CODE_LIST').setValue('');

	        	if (EVF.C("PREV_MOLD_YN").getValue() == '1') {
	        		EVF.C("MOLD_YN").setChecked(true);
	        	}
	        	EVF.C('MOLD_YN').setDisabled(false); // 금형견적여부 => 부품인 경우만 활성화
			}

	        //itemInfoGrid.delAllRow();
	        clearTplNum();
		}

        function init() {

        <c:if test="${ses.userType == 'B'}">
        	EVF.C('PURCHASE_TYPE').removeOption('DMRO'); // 국내MRO
			EVF.C('PURCHASE_TYPE').removeOption('OMRO'); // 해외MRO
        </c:if>

			// initialize grid variables.
            itemInfoGrid = EVF.C("itemInfoGrid");
    		itemInfoGrid.setProperty('panelVisible', ${panelVisible});

			if ('${ses.userType}' == 'S') {
		        itemInfoGrid.hideCol('COST_IMG',true);
			}
			//baseDataType
			if ('${form.RFQ_CREATE_TYPE}' != "PR") {
				itemInfoGrid.addRowEvent(function() {

					var arrData = [];
	                arrData.push({
	                     'BUYER_REQ_CD' : '${ses.companyCd}'
	                    ,'PLANT_CD'     : '${ses.plantCd}'
	                    ,'CTRL_CD'      : '${ses.ctrlCd}'
	                    ,'COST_ITEM_NEED_FLAG' : '0'
	                    ,'VALID_FROM_DATE'     : '${fromDate}'
	                    ,'VALID_TO_DATE'       : '99991231'
		                ,'RFX_QT'       : '0'
		                ,'LIMIT_PRC'       : '0'
		                ,'TRGT_PRC'       : '0'

		                ,'UNIT_PRC'       : '0'
		                ,'BUY_STND_PRC'       : '0'
		                ,'ITEM_AMT'       : '0'
		                ,'LIMIT_PRC'       : '0'
		                ,'PLAN_STND_PRC'       : '0'

		                ,'TRGT_PRC'       : '0'
		                ,'DPRC_QT'       : '0'

		                ,'ITEM_USAGE'       : '0'
		                ,'ORIGIN_RFX_CNT'       : '0'
		                ,'ORIGIN_RFX_SQ'       : '0'
	                });

					var rowidm = itemInfoGrid.addRow(arrData);

                   // itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowCount() , 'UNIT_CD',  true);    // 단위

                   itemInfoGrid.setCellReadOnly(rowidm, 'UNIT_CD', false)

				});
			}

        	// PR기준 입찰/견적인 경우 "구매유형, 통화"는 변경할 수 없다.
			if (baseDataType == 'PR') {
                // form 셋팅
                EVF.getComponent('PURCHASE_TYPE').setValue('${param.purcharseType}');

                // screenFlag = 1 : 업무진행관리
                if ('${param.screenFlag}' == "1") {
                    EVF.C('CUR').setDisabled(false);
                    EVF.C('CTRL_USER_ID').setValue('${param.ctrlUserId}');
                } else {
                    EVF.C('CUR').setDisabled(true);
                    EVF.getComponent('CUR').setValue('${param.cur}');
                }
                formUtil.setVisible(['openCatalog','getBom'], false);

				// 구매요청(STOCPRHD, STOCPRDT) 데이터 검색
				doSearchPrInformation();
			} else {
		        //itemInfoGrid.hideCol('PR_NUM',true);
			}

			// 재견적일 경우 입찰마감일시만 변경 가능함
			if (baseDataType == 'RERFX') {
	        	EVF.C("RFX_TYPE").setDisabled(true);
	        	//EVF.C("VENDOR_OPEN_TYPE").setDisabled(true);
	        	EVF.C("SUBMIT_TYPE").setDisabled(true);
	        	EVF.C("PRC_STL_TYPE").setDisabled(true);
	        	EVF.C("SETTLE_TYPE").setDisabled(true);
	        	EVF.C("SHIPPER_TYPE").setDisabled(true);
	        	EVF.C("CUR").setDisabled(true);

	            <c:if test="${ses.userType == 'B'}">
		        	EVF.C("PRC_PERCENT").setDisabled(true);
		        	EVF.C("NOT_PRC_PERCENT").setDisabled(true);
		        	EVF.C("SCND_PRC_PERCENT").setDisabled(true);
		        	EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
		        	EVF.C("CUR").setDisabled(true);
	        	</c:if>
			}

            // 구매유형이 "부품"인 경우에만 Grid의 투자구분, 상각수량, 구매DCCS, 설계DCCS 보이도록 함
	        <c:if test="${form.PURCHASE_TYPE != 'NORMAL' }">
		        itemInfoGrid.hideCol('INVEST_CD',true);
		        itemInfoGrid.hideCol('DPRC_QT',true);
		        itemInfoGrid.hideCol('BUY_STND_PRC',true);
		        itemInfoGrid.hideCol('PLAN_STND_PRC',true);
			</c:if>

			// 낙찰하한가제한인 경우에만 Grid의 낙찰하한가 표시함
   			if (EVF.C('PRC_STL_TYPE').getValue() != 'LMT') {
   	            itemInfoGrid.hideCol('LIMIT_PRC', true);
   			} else {
   	            itemInfoGrid.hideCol('LIMIT_PRC', false);
   			}

            itemInfoGrid.delRowEvent(function() {
                var selRowId = itemInfoGrid.getSelRowId();
                for(var x in selRowId) {
                    var rowId = selRowId[x];
                    if( EVF.isEmpty(itemInfoGrid.getCellValue(rowId, 'DEL_FLAG')) ) {
                        itemInfoGrid.delRow(rowId);
                    } else {
                    	if('${_gridType}' == "RG") {
	                        itemInfoGrid.setCellValue(rowId, 'DEL_FLAG', '1');
	                        itemInfoGrid.setRowBgColor(selRowId[rowId], '#8C8C8C');
                    	} else {
	                        itemInfoGrid.setCellValue(rowId, 'DEL_FLAG', '1');
	                        itemInfoGrid.setCellFontDeco(rowId, 'ITEM_CD', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'ITEM_DESC', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'ITEM_SPEC', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'UNIT_CD', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'COST_ITEM_NEED_FLAG', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'UNIT_PRC', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'ITEM_AMT', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'DUE_DATE', 'line-through');
	                        itemInfoGrid.setCellFontDeco(rowId, 'DELY_TO_CD_NM', 'line-through');
                    	}
                    }
                }
            });

            itemInfoGrid.cellClickEvent(function(rowId, colKey, value, iRow, iCol) {
                switch (colKey) {
                    case 'ITEM_CD':
                        if (itemInfoGrid.getCellValue(rowId, colKey) != '') {
                            var param = {
                                gate_cd: '${ses.gateCd}',
                                item_cd: itemInfoGrid.getCellValue(rowId, colKey)
                            };
                            everPopup.openItemDetailInformation(param);
                        }
                        break;
                    case 'REC_VENDOR_CD':
                        var param = {
                            callBackFunction: "_setRecVendor",
                            rowid: rowId
                        };
                        everPopup.openCommonPopup(param, 'SP0025');
                        break;
                    case 'SELECT_CANDIDATE':
                        var settleType = EVF.C('SETTLE_TYPE').getValue();

                        if(settleType == '') {
                            return alert('${BSOX_010_0018}');
                        }

                        if(settleType == 'DOC') {
                            <%--선정방식이 ＂총액＂인 경우에는 품목별로 협력회사를 지정할 수 없습니다.--%>
                            return alert('${BSOX_010_INVALID_DOC_TYPE_GRID}');
                        }
                        everPopup.openSearchCandidatePopup({
                            callBackFunction: '_setSelectCandidate',
                            candidateJson: itemInfoGrid.getCellValue(rowId, 'SELECT_CANDIDATE_JSON'),
                            rowid: rowId,
                            detailView: (isDetailView == true ? true : false)
                        });
                        break;
                    case 'SUB_ITEM_LIST':
                        var subItemAsJson = itemInfoGrid.getCellValue(rowId, 'SUB_ITEM_LIST_JSON');
                        var param = {
                            screenIdForGrid: 'BPR_100',
                            callbackFunction: '_setSubItemList',
                            itemAmt: itemInfoGrid.getCellValue(rowId, 'ITEM_AMT'),
                            nRow: rowId,
                            gridStringData: subItemAsJson,
                            detailView: (isDetailView == true ? true : false)
                        };
                        everPopup.openSubItemListPopup(param);
                        break;
                    case 'DELY_TO_CD_NM':
                        var param = {
                            callBackFunction: "_setDelyToCode",
                            rowid: rowId
                        };
                        everPopup.openCommonPopup(param, 'SP0023');
                        break;
                    case 'ATT_FILE_CNT':
                        var uuid = itemInfoGrid.getCellValue('ATT_FILE_NUM', rowId);
                        var param = {
                            havePermission: '${!param.detailView}',
                            attFileNum: itemInfoGrid.getCellValue(rowId, 'ATT_FILE_NUM'),
                            rowId: rowId,
                            callBackFunction: '_setFileUuidItemGrid',
                            bizType: 'RFQ'
                        };
                        everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
                        break;
                    case 'PLANT_NM':
                        // Can't change plant if item is based on PR.
                        if (itemInfoGrid.getCellValue(rowId, 'PLANT_NM') == '') {
                            var param = {
                                callBackFunction: "_setPlant",
                                rowid: rowId,
                                custCd: itemInfoGrid.getCellValue(rowId, 'BUYER_REQ_CD')
                            };
                            everPopup.openCommonPopup(param, 'SP0005');
                        }
                        break;
                    case 'PR_NUM':
                        // Can't change plant if item is based on PR.
                        if (itemInfoGrid.getCellValue(rowId, 'PR_NUM') != '') {
                        	everPopup.openPRDetailInformation(itemInfoGrid.getCellValue(rowId, "PR_NUM"));
                        }
                        break;
                    case 'COST_IMG':
                        if (itemInfoGrid.getCellValue(rowId, 'COST_ITEM_NEED_FLAG') == '1'
                        && EVF.C('MOLD_YN').getValue() != '1'
                        ) {
                            var param = {
                            		detailView: '${param.detailView}',
                                    COST_TEXT : itemInfoGrid.getCellValue(rowId, 'COST_TEXT'),
                                    rowid: rowId,
                                    callBackFunction: 'setCostBuyer'
                                };
                                everPopup.openPopupByScreenId('BSOX_COST_BUYER', 650, 350, param);

                        }
                        break;
                    default:
                }
            });

            itemInfoGrid.cellChangeEvent(function(rowId, colKey, iRow, iCol, newVal, oldVal) {
                switch (colKey) {
                    case 'VALID_FROM_DATE':
                        var validFromDate = Number(itemInfoGrid.getCellValue(rowId, 'VALID_FROM_DATE'));
                        if (${today2} > validFromDate;) {
                        	alert('${BSOX_010_9005}');
                            itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                        }
                    	break;
                    case 'VALID_TO_DATE':
                        var validFromDate = Number(itemInfoGrid.getCellValue(rowId, 'VALID_FROM_DATE'));
                        var validToDate = Number(itemInfoGrid.getCellValue(rowId, 'VALID_TO_DATE'));
                        if(validFromDate != '' && validToDate != ''){
                            if (!(validFromDate <= validToDate)) {
                                itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                                return alert('${BSOX_010_0003}');
                            }
                        }
                        break;
                    case 'DUE_DATE':
                        var today = '${today}';

                        if (everDate.compareDateWithSign(today, '>', newVal, '${ses.dateFormat }', '${gridDateFormat}')) {
                            itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                            return alert("${BSOX_010_0004}");
                        }
                        break;
                    case 'RFX_QT':
                        if (newVal < 0) {
                            itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                            return alert('${msg.INPUT_GREATER_THAN_ZERO}');
                        }
                        var currency = EVF.C('CUR').getValue();
                        if (currency == '') {
                            itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                            return alert("${BSOX_010_0005}");
                        } else {
                            var unitPrice = Number(itemInfoGrid.getCellValue(rowId, 'UNIT_PRC'));
                            var rfxQty = Number(itemInfoGrid.getCellValue(rowId, 'RFX_QT'));
                            itemInfoGrid.setCellValue(rowId, 'ITEM_AMT', everCurrency.getAmount(currency, (unitPrice * rfxQty)));
                        }
                        break;

                    case 'UNIT_PRC':
                        if (newVal < 0) {
                            itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                            return alert('${msg.INPUT_GREATER_THAN_ZERO}');
                        }
                        var currency = EVF.C('CUR').getValue();
                        if (currency == '') {
                            itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                            return alert("${BSOX_010_0005}");
                        } else {
                            var unitPrice = Number(itemInfoGrid.getCellValue(rowId, 'UNIT_PRC'));
                            var rfxQty = Number(itemInfoGrid.getCellValue(rowId, 'RFX_QT'));
                            itemInfoGrid.setCellValue(rowId, 'ITEM_AMT', everCurrency.getAmount(currency, (unitPrice * rfxQty)));
                        }
                        break;


                    case 'BUYER_REQ_CD':
                        itemInfoGrid.setCellValue(rowId, 'PLANT_CD', '');
                        itemInfoGrid.setCellValue(rowId, 'PLANT_NM', '');
                        break;
                    default:
                }

                if (colKey === 'ITEM_DESC' || colKey === 'ITEM_SPEC') {
                    var itemCode = itemInfoGrid.getCellValue(rowId, 'ITEM_CD');
                    if (everString.isNotEmpty(itemCode)) {
                        itemInfoGrid.setCellValue(rowId, colKey, oldVal);
                        return alert('${msg.CAN_NOT_EDIT}');
                    }
                }
            });

			// 협력회사에서는 G/W 관련문서 보이지 않도록 함
            <c:if test="${ses.userType == 'B'}">
	            gwdoc =  EVF.C("gwdoc");
	            gwdoc.addRowEvent(function() {
	                gwdoc.addRow();
	            });

	            gwdoc.delRowEvent(function() {
	                gwdoc.delRow();
	            });

	            gwdoc.cellClickEvent(function(rowId, colKey, value, iRow, iCol) {
	                var userwidth  = 810; // 고정(수정하지 말것)
	    			var userheight = (screen.height - 2);
	    			if (userheight < 780) userheight = 780; // 최소 780
	    			var LeftPosition = (screen.width-userwidth)/2;
	    			var TopPosition  = (screen.height-userheight)/2;
	    			var gwParam = 'scrollbars=yes,toolbar=no,location=yes,status=no,menubar=no,resizable=no,width='+userwidth+',height='+userheight+',left='+LeftPosition+',top='+TopPosition;

	            	switch (colKey) {
	                    case 'APRV_URL':
	                    	if (isDetailView && gwdoc.getCellValue(rowId, colKey) != '' && gwdoc.getCellValue(rowId, colKey).length > 200) {
	                        	window.open(gwdoc.getCellValue(rowId, colKey), "signwindow", gwParam);
	                        }
	                        break;
						default:
	            	}
	            });
            </c:if>

            //현장설명회 form 제어
            setDisplayBiddersConferencePanel();

            //품목 그리드 조회
            if ('${form.RFX_NUM}' != '') {
	            doSearchAllGridData();

	            //gwDoc 조회
	            <c:if test="${ses.userType == 'B'}">
    	        	doSearchGwDocData();
	            </c:if>
            }

            //상태별 Button 제어
            setButtonsAfterLoad(baseDataType);
            toggleApprovalButton();

            //개봉방식 셋팅
            //setFormAfterLoad();

            //협력회사일 경우 그리드 활성화
            //setGridAfterLoad();

            <c:if test="${ses.userType == 'S'}">
	            itemInfoGrid.hideCol('COST_ITEM_NEED_FLAG', true);
	            itemInfoGrid.hideCol('UNIT_PRC', true);
	            itemInfoGrid.hideCol('ITEM_AMT', true);
	            itemInfoGrid.hideCol('SELECT_CANDIDATE', true);
	            itemInfoGrid.hideCol('LIMIT_PRC', true);
	            itemInfoGrid.hideCol('PR_NUM', true);
	            itemInfoGrid.hideCol('ITEM_AMT', true);
	            itemInfoGrid.hideCol('PLAN_STND_PRC', true);
	            itemInfoGrid.hideCol('TRGT_PRC', true);
	            itemInfoGrid.hideCol('BUY_STND_PRC', true);
            </c:if>

            <c:if test="${param.detailView}">
            	formUtil.setVisible(['doSave', 'doTransfer', 'requestApp', 'doDelete', 'openCatalog', 'openCandidate','getBom'], false);
            </c:if>


            <c:if test="${form.SIGN_STATUS == 'E'}">
        	formUtil.setVisible(['doSave','doDelete'], false);
        	</c:if>

            if (isPopup) {
                formUtil.setVisible(['doClose'], true);
            } else {
            	formUtil.setVisible(['doClose'], false);
            }

            <c:if test="${param.baseDataType == 'RERFX'}">
	            formUtil.setVisible(['doSave', 'doTransfer', 'openCatalog', 'openCandidate'], true);
	            formUtil.setVisible(['requestApp', 'doDelete','getBom','openCatalog','doSave'], false);

	            EVF.C('RFQ_START_DATE').setValue('');
	            EVF.C('RFQ_START_HOUR').setValue('');
	            EVF.C('RFQ_START_MIN').setValue('');
	            EVF.C('RFQ_CLOSE_DATE').setValue('');
	            EVF.C('RFQ_CLOSE_HOUR').setValue('');
	            EVF.C('RFQ_CLOSE_MIN').setValue('');
            </c:if>

            if (EVF.C('CUR').getValue()=='KRW') {
                var xx = document.getElementById("CURR");
            }

         	// 금형견적여부 => 부품인 경우만 활성화
         	if ('${ses.userType}' == 'B') {
             	if (EVF.C('PURCHASE_TYPE').getValue() == 'NORMAL') {
            		EVF.C('MOLD_YN').setDisabled(false);
             	} else {
            		EVF.C('MOLD_YN').setChecked(false);
            		EVF.C('MOLD_YN').setDisabled(true);
             	}
         	} else {
        		EVF.C('MOLD_YN').setDisabled(true);
         	}
            <c:if test="${ses.userType == 'B'}">
            if (EVF.C("SUBMIT_TYPE").getValue() != 'RO') {
            	EVF.C("PRC_PERCENT").setDisabled(true);
            	EVF.C("NOT_PRC_PERCENT").setDisabled(true);
                EVF.C("SCND_PRC_PERCENT").setDisabled(true);
                EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
            } else {
                if (EVF.C('PURCHASE_TYPE').getValue()=='NORMAL') {
                	EVF.C("PRC_PERCENT").setDisabled(true);
                	EVF.C("NOT_PRC_PERCENT").setDisabled(true);
                    EVF.C("SCND_PRC_PERCENT").setDisabled(true);
                    EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
                } else {
                	EVF.C("PRC_PERCENT").setDisabled(false);
                	EVF.C("NOT_PRC_PERCENT").setDisabled(false);
                    EVF.C("SCND_PRC_PERCENT").setDisabled(true);
                    EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
                }
            }
            </c:if>
        }

        function setCostBuyer(data,rowid) {
        	itemInfoGrid.setCellValue(rowid,'COST_TEXT',data);
        }

        function chCur() {
            if (EVF.C('CUR').getValue()=='KRW') {
                var xx = document.getElementById("CURR");
            } else {
            	var xx = document.getElementById("CURR");
            }
        }

        function chVendorOpenType() {
            if (EVF.C("VENDOR_OPEN_TYPE").getValue() == 'QN' ) {
            	EVF.C("PRC_STL_TYPE").setValue('NON');
            	//EVF.C("PRC_STL_TYPE").setDisabled(true);
            } else {
            	EVF.C("PRC_STL_TYPE").setValue('PRI');
            	//EVF.C("PRC_STL_TYPE").setDisabled(false);
            }
        }

        function chPrcStlType() {
   			if (EVF.C('PRC_STL_TYPE').getValue() != 'LMT') {
   	            itemInfoGrid.hideCol('LIMIT_PRC', true);
   			} else {
   	            itemInfoGrid.hideCol('LIMIT_PRC', false);
   			}
        }

        function getBom() {
        	if (EVF.C("PURCHASE_TYPE").getValue()=='') {
        		alert('${BSOX_010_9013}');
        		return;
        	}
        	if (EVF.C("PURCHASE_TYPE").getValue()!='NORMAL') {
        		alert('${BSOX_010_9012}');
        		return;
        	}
            var param = {
                 detailView    : false
                ,havePermission : false
                ,callBackFunction: 'setBom'
            };
            everPopup.openPopupByScreenId('DH1251', 1000, 550, param);
        }

        function setBom(datas) {
            var dataaa = valid.equalPopupValid(datas, itemInfoGrid, "ITEM_CD");
            var arrData = [];
            for (var k = 0; k < dataaa.length; k++) {
                var data = dataaa[k];
                arrData.push({
                     'ITEM_CD'      : data.ITEM_CD
                    ,'ITEM_DESC'    : data.ITEM_DESC
                    ,'ITEM_SPEC'    : data.MATERIAL_SPEC
                    //,'RFX_QT'       : data.ITEM_QT
                    ,'UNIT_CD'      : data.UNIT_CD
                    ,'EO_NO'        : data.EO_NO
                    ,'TOP_ITEM_CD'  : data.TOP_ITEM_CD
                    ,'ITEM_REVSION' : data.ITEM_REVSION
                    ,'ITEM_USAGE'   : data.ITEM_QT
                    ,'BUYER_REQ_CD' : '${ses.companyCd}'
                    ,'PLANT_CD'     : '${ses.plantCd}'
                    ,'CTRL_CD'      : '${ses.ctrlCd}'
                    ,'COST_ITEM_NEED_FLAG' : '0'
                    ,'VALID_FROM_DATE'     : '${fromDate}'
                    ,'VALID_TO_DATE'       : '99991231'
                    ,'MAT_GROUP'  :  data.MAT_GROUP


	                ,'RFX_QT'       : '0'
	                ,'LIMIT_PRC'       : '0'
	                ,'TRGT_PRC'       : '0'

	                ,'UNIT_PRC'       : '0'
	                ,'BUY_STND_PRC'       : '0'
	                ,'ITEM_AMT'       : '0'
	                ,'LIMIT_PRC'       : '0'
	                ,'PLAN_STND_PRC'       : '0'

	                ,'TRGT_PRC'       : '0'
	                ,'DPRC_QT'       : '0'

	                ,'ITEM_USAGE'       : '0'
	                ,'ORIGIN_RFX_CNT'       : '0'
	                ,'ORIGIN_RFX_SQ'       : '0'
                });
            }
            itemInfoGrid.addRow(arrData);
        }

        function setButtonsAfterLoad(baseDataType) {
            if (!isDetailView) {
                switch (baseDataType) {
                    case 'RERFX':
                        formUtil.setVisible(['doTransfer', 'doSave'], true); // Main Buttons.
                        break;
                    case 'AWARD_FOR_PRC_BID':
                        formUtil.setVisible(['doTransfer'], true);
                        break;
                }

                // set visible/invisible buttons for eApproval.
                var presentSignStatus = '${signStatus}'; // '', 'T', 'P', 'R', 'E'
                var isApproval = (EVF.C('APPROVAL_FLAG').getValue() == '1' ? true : false);
                switch (presentSignStatus) {
                    case '':
                    case 'T':
                    case 'R':
                        if (isApproval) {
                            formUtil.setVisible('requestApp', true);
                        } else {
                            formUtil.setVisible('doTransfer', true);
                        }

                        formUtil.setVisible(['doSave', 'openCatalog', 'openCandidate'], true);
                        break;
                    case 'E':
                        if (baseDataType != 'RFP' && baseDataType != 'AWARD_FOR_PRC_BID') {
                            formUtil.setVisible(['doSave', 'openCatalog', 'openCandidate'], true);
                        }
                        break;
                }
            } else {
                formUtil.setVisible('requestApp', false);
                formUtil.setVisible(['getBom', 'openCatalog', 'openCandidate'], false);
            }

            if (isPopup) {
                formUtil.setVisible(['doClose'], true);
            }
        }
        function setFormAfterLoad() {
            if (isDetailView) {
                if (userType == 'B') {
                    setRfxOpenType();
                }
            }
        }
        function doSearchPrInformation() {

            var store = new EVF.Store();
        	store.setGrid([itemInfoGrid]);

        <c:if test="${param.prList != null && param.prList != ''}">
        var data = ${param.prList};
        </c:if>

            store.setParameter('newPrList',JSON.stringify(data));



            store.setParameter('screenFlag', '${param.screenFlag}');
            store.load(baseUrl + "doSearchPrInformation", function () {
                itemInfoGrid.checkAll(true);

                for (var k = 0; k < itemInfoGrid.getRowCount(); k++) {
                    // 구매요청접수에서 넘어온 건
                	if ('${param.screenFlag}' == "0") {
                        itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'PLANT_CD', true);    // 플랜트
                        itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'UNIT_CD',  true);    // 단위

                        if (itemInfoGrid.getCellValue(itemInfoGrid.getRowId(k),'ITEM_CD') == '' ) {
                        	itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'UNIT_CD', false);
                        }
                    } // 투자품의(업무진행관리)에서 넘어온 건
                    else {
                        itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'PLANT_CD', true);    // 플랜트
                        itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'UNIT_CD',  false);   // 단위
                    }

                    if(itemInfoGrid.getRowCount() > 0 && itemInfoGrid.getCellValue(0,'PR_NUM') != ''){
                    	formUtil.setVisible(['openCatalog','getBom'], false);
                    }
                }
            });
        }
        function doSearchAllGridData() {

            var store = new EVF.Store();

            store.setGrid([itemInfoGrid]);
            store.load(baseUrl + "doSearchRfqItemData", function () {

                for (var k = 0; k < itemInfoGrid.getRowCount(); k++) {
	            	if ('${form.RFQ_CREATE_TYPE}' == "PR" && '${form.PURCHASE_TYPE}' == "ISP") {
	                    itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'PLANT_CD', true);    // 플랜트
	                    itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'UNIT_CD',  true);    // 단위

                    	if (itemInfoGrid.getCellValue(itemInfoGrid.getRowId(k),'ITEM_CD') == '' ) {
                    		itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'UNIT_CD', false);
	                    }
	                }
	                else {
	                    itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'PLANT_CD', true);    // 플랜트
	                    itemInfoGrid.setCellReadOnly(itemInfoGrid.getRowId(k), 'UNIT_CD',  false);   // 단위
	                }
                }

                if(itemInfoGrid.getRowCount() > 0 && itemInfoGrid.getCellValue(0,'PR_NUM') != ''){
                	formUtil.setVisible(['openCatalog','getBom'], false);
                }
            });
        }
        function doSearchGwDocData() {

            var store = new EVF.Store();

            store.setGrid([gwdoc]);
            store.load(baseUrl + "doSearchGwDocData", function () {
            	gwdoc.checkAll(true);

            });
        }
        function doSearchBuyer() {
        	return;
            var param = {
                callBackFunction: "_setBuyer"
            };
            everPopup.openCommonPopup(param, 'SP0040');
        }
        function _setBuyer(data) {
            EVF.C("CTRL_USER_ID").setValue(data['CTRL_USER_ID']);
            EVF.C("CTRL_USER_NM").setValue(data.CTRL_USER_NM);
        }
        // 1차 협력회사 종합평가표
        function openTplNum() {
            if (EVF.C("SUBMIT_TYPE").getValue() != 'RO') {
                alert('${BSOX_010_1000}');
                return;
            }

            var param = {
                EV_TYPE : "R"
                ,callBackFunction: "setTplNum"
            };
            everPopup.openCommonPopup(param, 'SP0034');
        }

        function setTplNum(data) {
            EVF.C("EV_TPL_CD").setValue(data.EV_ITEM_METHOD_CD);
            EVF.C("EV_TPL_NM").setValue(data.EV_TPL_SUBJECT);
            EVF.C("EV_TPL_NUM").setValue(data.EV_TPL_NUM);
        }

        // 2차 협력회사 종합평가표(부품인 경우에만 선택 가능)
        function openTplNumScnd() {
        	if (EVF.C("PURCHASE_TYPE").getValue() != 'NORMAL') {
        		return;
        	}

            if (EVF.C("SUBMIT_TYPE").getValue() != 'RO') {
                alert('${BSOX_010_1000}');
                return;
            }

            var param = {
                EV_TYPE : "R"
                ,callBackFunction: "setTplNumScnd"
            };
            everPopup.openCommonPopup(param, 'SP0034');
        }

        function setTplNumScnd(data) {
            EVF.C("SCND_EV_TPL_CD").setValue(data.EV_ITEM_METHOD_CD);
            EVF.C("SCND_EV_TPL_NM").setValue(data.EV_TPL_SUBJECT);
            EVF.C("SCND_EV_TPL_NUM").setValue(data.EV_TPL_NUM);
        }

        function clearTplNum() {
            if (EVF.C("SUBMIT_TYPE").getValue() != 'RO') {
                EVF.C("EV_TPL_CD").setValue('');
                EVF.C("EV_TPL_NM").setValue('');
                EVF.C("EV_TPL_NUM").setValue('');
                EVF.C("SCND_EV_TPL_CD").setValue('');
                EVF.C("SCND_EV_TPL_NM").setValue('');
                EVF.C("SCND_EV_TPL_NUM").setValue('');

                EVF.C("PRC_PERCENT").setValue('100');
                EVF.C("NOT_PRC_PERCENT").setValue('0');
                EVF.C("SCND_PRC_PERCENT").setValue('100');
                EVF.C("SCND_NOT_PRC_PERCENT").setValue('0');

            	EVF.C("PRC_PERCENT").setDisabled(true);
            	EVF.C("NOT_PRC_PERCENT").setDisabled(true);
                EVF.C("SCND_PRC_PERCENT").setDisabled(true);
                EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
            } else {
                if (EVF.C('PURCHASE_TYPE').getValue()=='NORMAL') {
                    EVF.C("PRC_PERCENT").setValue('60');
                    EVF.C("NOT_PRC_PERCENT").setValue('40');
                    EVF.C("SCND_PRC_PERCENT").setValue('50');
                    EVF.C("SCND_NOT_PRC_PERCENT").setValue('50');

                	EVF.C("PRC_PERCENT").setDisabled(true);
                	EVF.C("NOT_PRC_PERCENT").setDisabled(true);
                    EVF.C("SCND_PRC_PERCENT").setDisabled(true);
                    EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
                } else {
                    EVF.C("PRC_PERCENT").setValue('60');
                    EVF.C("NOT_PRC_PERCENT").setValue('40');
                    EVF.C("SCND_PRC_PERCENT").setValue('0');
                    EVF.C("SCND_NOT_PRC_PERCENT").setValue('0');

                	EVF.C("PRC_PERCENT").setDisabled(false);
                	EVF.C("NOT_PRC_PERCENT").setDisabled(false);
                    EVF.C("SCND_PRC_PERCENT").setDisabled(true);
                    EVF.C("SCND_NOT_PRC_PERCENT").setDisabled(true);
                }
            }
        }

        function doSearchOpener() {
            var param = {
                callBackFunction: "_setOpener"
            };
            everPopup.openCommonPopup(param, 'SP0001');
        }
        function _setOpener(data) {
            EVF.C("OPEN_USER_NM").setValue(data.USER_NM);
            EVF.C("OPEN_USER_ID").setValue(data['USER_ID']);
        }
        function setDisplayBiddersConferencePanel() {
            if (!isDetailView) {
                EVF.C('bcPanel').iterator(function() {
                    var isChecked = EVF.C('ANN_FLAG').isChecked();
                    this.setDisabled(!isChecked);
                    this.setReadOnly(!isChecked);
                    this.setRequired(isChecked);
                });
            }
        }

        function _onChangeForm(pid) {

            var id = this.getID();
            var today = '${today}';
            switch (id) {
                case 'CUR':
                    var cur = EVF.C('CUR').getValue();
                    var allRowIds = itemInfoGrid.getAllRowId();
                    for(var x in allRowIds) {
                        var rowId = allRowIds[x];
                        var unitPrice = Number(itemInfoGrid.getCellValue(rowId, 'UNIT_PRC'));
                        var rfxQty = Number(itemInfoGrid.getCellValue(rowId, 'RFX_QT'));
                        itemInfoGrid.setCellValue(rowId, 'ITEM_AMT', everCurrency.getAmount(cur, (unitPrice * rfxQty)));
                    }
                    break;
                case 'APPROVAL_FLAG':
                    toggleApprovalButton();
                    break;
                case 'RFX_OPEN_TYPE':
                    setRfxOpenType();
                    break;
            }
        }

        function onChangeDate() {
            var id = this.getID();

            switch (id) {
                case 'RFQ_START_DATE':
                    EVF.C('RFQ_START_HOUR').setValue('08');
                    EVF.C('RFQ_START_MIN').setValue('00');

                    if(EVF.getComponent('RFQ_CLOSE_DATE').getValue() == '') {
                        var date = EVF.getComponent('RFQ_START_DATE').getValue();
                        date = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6,8);
                        date = new Date(date).addDays(7).toString('yyyyMMdd');

                        EVF.C('RFQ_CLOSE_DATE').setValue(date);
                        EVF.C('RFQ_CLOSE_HOUR').setValue('00');
                        EVF.C('RFQ_CLOSE_MIN').setValue('00');
                    }
                    break;
            }
        }

        function setRfxOpenType() {
            var openType = EVF.C('RFX_OPEN_TYPE').getValue();
            if (openType == 'SEL') {
                EVF.C('OPEN_USER_ID').setRequired(true);
                EVF.C('OPEN_USER_NM').setRequired(true);
            } else {
                EVF.C('OPEN_USER_ID').setRequired(false);
                EVF.C('OPEN_USER_NM').setRequired(false);
            }
        }

        function toggleApprovalButton() {

            popupFlag = '${param.popupFlag}';
            var tCtrlCd = '${ses.ctrlCd}';
            //alert("tCtrlCd ================"+tCtrlCd);

            var approvalFlag = EVF.C('APPROVAL_FLAG').getValue();
            var qtaFlag = EVF.C('QTA_FLAG').getValue();
            //alert("approvalFlag ================"+approvalFlag);
            var requestApp = EVF.C('requestApp');
            var bSave = EVF.C('doSave');
            var bDelete = EVF.C('doDelete');
            var bTransfer = EVF.C('doTransfer');
            var bClose = EVF.C('doClose');

            var bopenCatalog = EVF.C('openCatalog');
            var bopenCandidate = EVF.C('openCandidate');

            if (qtaFlag == '1') { // true
                bSave.setVisible(false);
                bDelete.setVisible(false);
                bTransfer.setVisible(false);
                bClose.setVisible(false);

                bopenCatalog.setVisible(false);
                bopenCandidate.setVisible(false);
            } else {
                if (tCtrlCd == '' || tCtrlCd == null){
                    bSave.setVisible(false);
                    bDelete.setVisible(false);
                    bTransfer.setVisible(false);
                }else{
                    bSave.setVisible(true);
                    bDelete.setVisible(true);
                    bTransfer.setVisible(true);
                }
                bClose.setVisible(true);

                if(baseDataType == 'PR') {
                    bopenCatalog.setVisible(false);
                } else {
                    bopenCatalog.setVisible(true);
                }
                bopenCandidate.setVisible(true);
            }

            requestApp.setVisible(false);
            if (isDetailView) {
                formUtil.setVisible('requestApp', false);
            }

        }

        function openCatalog() {

            var params = {
                'callBackFunction': '_setCatalog'
                , 'SCREEN_OPEN_TYPE' : 'RFQ'
                , 'detailView' : false
            };
            everPopup.openPopupByScreenId('BPR_041', 1000, 700, params);
        }


        function _setCatalog(selectedData) {
            var store = new EVF.Store();
            store.setGrid([itemInfoGrid]);

            store.getGridData( itemInfoGrid, 'all');

            store.setParameter('items',selectedData);
            store.load(baseUrl + "doSearchCatalog", function() {
            },false);


        }

        function openMyCatalog() {
            var param = {
                callBackFunction: '_setMyCatalog'
                , SCREEN_OPEN_TYPE : 'RFQ'
            };
            everPopup.openMyCatalogPopup(param);
        }

        function _setMyCatalog(selectedData) {

            var store = new EVF.Store();
            store.setGrid([itemInfoGrid]);
            store.getGridData( itemInfoGrid, 'all');
            store.setParameter('items',selectedData);
            store.load(baseUrl + "doSearchCatalog", function() {
            },false);


            <%--
            var resultData = [];
            selectedData = JSON.parse(selectedData);
            for(var x in selectedData) {
                var data = {};
                data['ITEM_CD'] = selectedData[x]['ITEM_CD'];
                data['ITEM_DESC'] = selectedData[x]['ITEM_DESC'];
                data['ITEM_SPEC'] = selectedData[x]['ITEM_SPEC'];
                data['UNIT_CD'] = selectedData[x]['UNIT_CD'];
                data['COST_ITEM_NEED_FLAG'] = selectedData[x]['COST_ITEM_NEED_FLAG'];
                data['UNIT_PRC'] = selectedData[x]['UNIT_PRC'];
                data['ITEM_AMT'] = selectedData[x]['AMOUNT'];
                data['RFX_QT'] = selectedData[x]['ITEM_QT'];
                data['CTRL_CD'] = '${ses.ctrlCd}';
                data['BUYER_REQ_CD'] = '${ses.companyCd}';
                resultData.push(data);
            }
            itemInfoGrid.addRow(resultData);
            --%>

        }
        function copyLastRFQ() {
            var param = {
                rfxType: 'RFQ',
                callBackFunction: '_setLastRFX'
            };
            everPopup.openPreviousReqInfo(param);
        }

        function _setLastRFX(previousRfqInfo) {

            var store = new EVF.Store();
            store.setParameter("previousRfqInfo", previousRfqInfo);
            store.setGrid([itemInfoGrid]);
            store.load(baseUrl + "doSelectPreviousRfqItems", function () {
            });
        }

        function openTemplate() {
            var param = {
                callBackFunction: '_setTemplate'
            };
            everPopup.catalogTemplateManagement(param);
        }

        function _setTemplate(selectedData) {
            var resultData = [];
            selectedData = JSON.parse(selectedData);
            for(var x in selectedData) {
                var data = {};
                data['ITEM_CD'] = selectedData[x]['ITEM_CD'];
                data['ITEM_DESC'] = selectedData[x]['ITEM_DESC'];
                data['ITEM_SPEC'] = selectedData[x]['ITEM_SPEC'];
                data['UNIT_CD'] = selectedData[x]['UNIT_CD'];
                data['COST_ITEM_NEED_FLAG'] = 0;
                data['UNIT_PRC'] = selectedData[x]['UNIT_PRC'];
                data['ITEM_AMT'] = selectedData[x]['AMOUNT'];
                data['RFX_QT'] = selectedData[x]['ITEM_QT'];
                data['CTRL_CD'] = '${ses.ctrlCd}';
                data['BUYER_REQ_CD'] = '${ses.companyCd}';
                data['PLANT_CD'] = '${ses.plantCd}';
                resultData.push(data);
            }
            itemInfoGrid.addRow(resultData);
        }

        <%-- 협력회사선택 --%>
        function openCandidate() {
            var settleType = EVF.C('SETTLE_TYPE').getValue();
            var vendorOpenType = EVF.C('VENDOR_OPEN_TYPE').getValue();

            if(settleType === '') {
                <%--선정방식을 선택해 주십시오.--%>
                return alert('${BSOX_010_INPUT_SETTLE_TYPE}');
            }

            if(settleType === 'DOC') {
                itemInfoGrid.checkAll(true);
            }

            if ((itemInfoGrid.jsonToArray(itemInfoGrid.getSelRowId()).value).length == 0) {
                alert("${msg.M0004}");
                return;
            }

            var vendorOpenType = EVF.C('VENDOR_OPEN_TYPE').getValue();
            if(!itemInfoGrid.isExistsSelRow()) {
                return alert('${BSOX_010_0013}');
            }

            if (vendorOpenType === '') {
                return alert('${BSOX_010_0016}');
            } else if (vendorOpenType === 'OB' && settleType !== 'DOC') {
                return alert('${BSOX_010_0015}');
            }

            <%-- 선택된 행들의 업체코드를 읽어서 JSON 문자열로 만든다. --%>
            var rowData = itemInfoGrid.getSelRowId();
            var vendorArray = [];
            var vendorCdArray = [];

            for (var row in rowData) {
                var vendorJson = itemInfoGrid.getCellValue(rowData[row], 'SELECT_CANDIDATE_JSON');

                if(vendorJson === '') continue;

                var vendorJsonParse = JSON.parse(vendorJson);
                var vendorCd;

                for (var k = 0; k < vendorJsonParse.length; k++) {
                    vendorCd = vendorJsonParse[k].VENDOR_CD;

                    if(! arrayContains(vendorCdArray, vendorCd)) {
                        var addParam = {"VENDOR_CD" : vendorCd};
                        vendorArray.push(addParam);
                        vendorCdArray.push(vendorCd);
                    }
                }
            }
			var vendorSelType='';
            if (baseDataType == 'RERFX') {
            	vendorSelType = 'NOTSEL';
            }


            everPopup.openSearchCandidatePopup({
                 callBackFunction : '_setCandidates'
                ,VENDORSELTYPE : vendorSelType
                ,candidateJson : JSON.stringify(vendorArray)
            });
        }

        function arrayContains(a, obj) {
            var i = a.length;
            while (i--) {
                if (a[i] === obj) {
                    return true;
                }
            }
            return false;
        }

        <%-- 업체선택 버튼으로 업체를 선택하면 선택된 행들의 업체 선택 컬럼에 일괄설정한다. --%>
        function _setCandidates(vendors) {
            var selRowIds = itemInfoGrid.getSelRowId();
            for(var x in selRowIds) {
                var rowId = selRowIds[x];
                itemInfoGrid.setCellValue(rowId, 'SELECT_CANDIDATE', JSON.parse(vendors).length);
                itemInfoGrid.setCellValue(rowId, 'SELECT_CANDIDATE_JSON', vendors);
            }
        }

        function requestApp() {
            if (validateForm()) {
                var oldSignStatus = EVF.C('SIGN_STATUS').getValue();
                if (oldSignStatus === 'P') {
                    alert('${BPR_020_APPROVAL_IS_PROCESSING}');
                    return;
                } else if (oldSignStatus === 'E') {
                    if (!confirm('${msg.M0056}')) {
                        return;
                    }
                }

                if (signStatus === 'T' || signStatus === 'E') {
                    EVF.C('SIGN_STATUS').setValue(signStatus);
                    getApproval();
                } else if (signStatus === 'P') {
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

        function getApproval() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var store = new EVF.Store();
            store.doFileUpload(function() {
                store.setGrid([itemInfoGrid]);
                store.getGridData(itemInfoGrid, 'all');
                store.load(baseUrl + "doSave", function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());
                    if (isPopup) {
                        doClose();
                        if ('${param.callBackFunction}' !== '') {
                            opener.window['${param.callBackFunction}']();
                        }
                    } else {
                        location.reload();
                    }
                });
            });
        }

        function doSave() {

			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            var confirmMessage = '${msg.M0021}';
            var signStatus = this.getData();

            itemInfoGrid.checkAll(true);

            switch (signStatus) {
                case 'T':
                    EVF.C('saveButtonType').setValue('SAVE');
                    break;
                case 'P':
                    EVF.C('saveButtonType').setValue('APPROVAL');
                    confirmMessage = '${msg.M0053}';
                    break;
                case 'E':
                    EVF.C('saveButtonType').setValue('TRANSFER');
                    if (EVF.C('ANN_FLAG').getValue()=='1') {
                        confirmMessage = '${msg.M0060}'+'\n${BSOX_010_9011}';
                    } else {
                        confirmMessage = '${msg.M0060}';
                    }
                    break;
                case 'R':
                    EVF.C('saveButtonType').setValue('SAVE');
                    break;
            }

            if (signStatus == 'E') {   //협력회사전송

                if (validateForm()) {
                    if (!confirm(confirmMessage)) {
                        return;
                    }

                    //협력회사-담당자 리스트 팝업오픈--------------------------------------------------------------
                    var rowData = itemInfoGrid.getSelRowId();
                    var vendorArray = [];
                    var vendorCdArray = [];

                    for (var row in rowData) {
                        var vendorJson = itemInfoGrid.getCellValue(rowData[row], 'SELECT_CANDIDATE_JSON');

                        if(vendorJson === '') continue;

                        var vendorJsonParse = JSON.parse(vendorJson);
                        var vendorCd;

                        for (var k = 0; k < vendorJsonParse.length; k++) {
                            vendorCd = vendorJsonParse[k].VENDOR_CD;

                            if(! arrayContains(vendorCdArray, vendorCd)) {
                                var addParam = {"VENDOR_CD" : vendorCd};
                                vendorArray.push(addParam);
                                vendorCdArray.push(vendorCd);
                            }
                        }
                    }

                    var popupUrl = "/eversrm/master/vendor/BBV_060/view";
                    var param = {
                        'callBackFunction': '_setvendormaster',
                        'onClose': 'closePopup',
                        'detailView' : false,
                        'vendorCdParams': vendorCdArray
                    };

                    everPopup.openPopupByScreenId('BBV_060', 1100, 380, param);
                    //everPopup.openWindowPopup(popupUrl, 1100, 380, param, '');
                    //협력회사-담당자 선택팝업창 선택후 저장로직 진행.. doSaveE();
                }
            } else {
                if (EVF.C('RFX_SUBJECT').getValue() == '' || EVF.C('RFX_TYPE').getValue() == '' || EVF.C('PURCHASE_TYPE').getValue() == '' ) {
                	alert('${BSOX_010_9017}');
                	return;
                }

            	if (!confirm(confirmMessage)) {
            		return;
            	}

				var store = new EVF.Store();
				store.doFileUpload(function() {
	            	store.setGrid([itemInfoGrid,gwdoc]);
	            	store.getGridData(itemInfoGrid, 'all');
	                store.getGridData(gwdoc, 'all');

	                store.load(baseUrl + "doSave", function () {
	                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

						alert(this.getResponseMessage());

	                    if ('${param.popupFlag}' == 'true') {
	                    	opener.doSearch();
						}

                        var gateCd  = this.getParameter('gateCd');
                        var rfxNum  = this.getParameter('rfxNum');
                        var rfxCnt  = this.getParameter('rfxCnt');
                        var rfxType = this.getParameter('rfxType');
                        var param = {
	                             gateCd: gateCd,
	                             rfxNum: rfxNum,
	                             rfxCnt: rfxCnt,
	                             rfxType: rfxType,
	                             baseDataType: 'RFX',
	                             popupFlag : '${param.popupFlag}'
	                         };

	                    location.href=baseUrl+'BSOX_010/view.so?' + $.param(param);
					});
				});
			}
        }

        function doSaveE(){

            var store = new EVF.Store();
            store.doFileUpload(function() {
                store.setGrid([itemInfoGrid,gwdoc]);
                store.getGridData(itemInfoGrid, 'all');
                store.getGridData(gwdoc, 'all');

                store.load(baseUrl + "doSave", function () {
                    EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    <c:if test="${param.baseDataType == 'RERFX'}">
                    window.close();
                    </c:if>

                    if ('${param.popupFlag}' == 'true') {
                        opener.doSearch();
                        window.close();
                    } else {
                        location.href=baseUrl+'BSOX_010/view';
                    }
                });
            });
        }

        function _setvendormaster(selectedData) {

            EVF.C('vendorMasterList').setValue(selectedData);
            doSaveE();
        }

        function validateForm() {

            var store = new EVF.Store();
            if(!store.validate()) return;

            try {
                var today = '${today} 0000';
                var rfqStartDate = EVF.C('RFQ_START_DATE').getValue() + ' ' + EVF.C('RFQ_START_HOUR').getValue() + EVF.C('RFQ_START_MIN').getValue();
                var rfqCloseDate = EVF.C('RFQ_CLOSE_DATE').getValue() + ' ' + EVF.C('RFQ_CLOSE_HOUR').getValue() + EVF.C('RFQ_CLOSE_MIN').getValue();
                var itemClassCd = EVF.C('ITEM_CLASS_CD').getValue();

                var rfxNum = EVF.C('RFX_NUM').getValue();

                //if (EVF.C("VENDOR_OPEN_TYPE").getValue() == 'AB' && EVF.C("PRC_STL_TYPE").getValue() == 'NON' ) {
				//	alert('${BSOX_010_9003}')
                //	return;
                //}

                // 종합평가인 경우 평가표 필수 세팅
                // 부품인 경우 1차, 2차 세팅
                // 부품 이외의 경우 1차만 세팅
                if (EVF.C("SUBMIT_TYPE").getValue() == 'RO') {
                	if (EVF.C('PURCHASE_TYPE').getValue() == 'NORMAL' && (EVF.C("EV_TPL_CD").getValue() == '' || EVF.C("SCND_EV_TPL_CD").getValue() == '')) {
                    	alert('${BSOX_010_0023}');
                		return;
                	}
                	if (EVF.C('PURCHASE_TYPE').getValue() != 'NORMAL' && EVF.C("EV_TPL_CD").getValue() == '') {
                    	alert('${BSOX_010_0023}');
                		return;
                	}
                }

                if (EVF.C("SUBMIT_TYPE").getValue() == 'ETC' && EVF.C("PURCHASE_TYPE").getValue() == 'NORMAL') {
                	alert('${BSOX_010_9020}');
                	return;
                }

                if (EVF.C("ANN_FLAG").getValue() == '1' &&  ( EVF.C("ANN_DATE").getValue() == '' || EVF.C("ANN_DATE").getValue() >= EVF.C('RFQ_START_DATE').getValue())) {
                	alert('${BSOX_010_9007}');
            		return;
                }

                var firstB = Number(EVF.C('NOT_PRC_PERCENT').getValue()) + Number(EVF.C('PRC_PERCENT').getValue());
				if (firstB != 100) {
					alert('${BSOX_010_9001}');
					return;
				}

				// 2차협력회사 비가격 평가비율 : 부품인 경우에만 적용
                var secondB = Number(EVF.C('SCND_NOT_PRC_PERCENT').getValue()) + Number(EVF.C('SCND_PRC_PERCENT').getValue());
				if (EVF.C('PURCHASE_TYPE').getValue() == 'NORMAL' && secondB != 100) {
					alert('${BSOX_010_9002}');
					return;
				}

                if(rfxNum == '' || baseDataType === 'RERFX') {
                    //if(!everDate.compareDateWithSign(today, '<=', rfqStartDate, '${ses.dateFormat } HHmi', '${ses.dateFormat } HHmi')) {
                    //    return alert('${BSOX_010_0012}');
                    //}
                    if(!everDate.compareDateWithSign(rfqStartDate, '<=', rfqCloseDate, '${ses.dateFormat } HHmi', '${ses.dateFormat } HHmi')) {
                        return alert('${BSOX_010_0022}');
                    }
                }
                if(!everDate.compareDateWithSign(rfqStartDate, '<=', rfqCloseDate, '${ses.dateFormat } HHmi', '${ses.dateFormat } HHmi')) {
                    return alert('${BSOX_010_0022}');
                }

                if(itemInfoGrid.getRowCount() === 0) {
                    alert('${BSOX_010_0013}');
                    return false;
                } else {
                    var gridData = itemInfoGrid.getAllRowValue();
                    for(var x in gridData) {
                        var rowData = gridData[x];
//                        var qty = Number(rowData['RFX_QT']);
//                        if(qty == 0) {
                        if(everString.isEmptyNum(rowData['RFX_QT'])) {
                        	alert('${BSOX_010_0007}');
                            return false;
                        }

                        if (EVF.C('PRC_STL_TYPE').getValue() == 'LMT'  && everString.isEmptyNum(rowData['LIMIT_PRC'])  ) {
                        	alert('${BSOX_010_9014}');
                        	return false;
                        }

                        <%-- 부품인 경우 "목표가" 필수 입력 --%>
                        if (EVF.C('PURCHASE_TYPE').getValue() == 'NORMAL'  &&  everString.isEmptyNum(rowData['TRGT_PRC'])  ) {
                        	alert('${BSOX_010_9015}');
                        	return false;
                        }

                        <%-- 품목구분이 일반일 경우 원가계산서 필요 없음. --%>
                        /*if(rowData['COST_ITEM_NEED_FLAG'] == '1' && itemClassCd == 'NORMAL') {
                            alert('${BSOX_010_COST_ITEM_FLAG_1}');
                            return false;
                        }*/

						if (EVF.C('PURCHASE_TYPE').getValue() == 'NORMAL') {
	                        if (!everString.isEmpty(rowData.INVEST_CD) && rowData.INVEST_CD != 'LS' && everString.isEmptyNum(rowData['DPRC_QT']) ) {
	                        	alert('${BSOX_010_9004}');
	                        	return false;
	                        }
						}

                        // 금형 견적/입찰일 경우 원가계산서 필수
                        if (EVF.C('MOLD_YN').getValue() == '1' && rowData['COST_ITEM_NEED_FLAG'] != '1') {
//                        	alert('${BSOX_010_0025}');
//                        	return false;
                        }

 						/*if ('${today2}' > rowData.VALID_FROM_DATE) {
                        	alert('${BSOX_010_9005}');
                        	return false;
						}*/

                        if (rowData.VALID_FROM_DATE >  rowData.VALID_TO_DATE ) {
                        	alert('${BSOX_010_9006}');
                        	return false;
                        }

                        if (rowData.SELECT_CANDIDATE == '0' ) {
                        	alert('${BSOX_010_0026}');
                        	return false;
                        }
                    }

                    var vendorOpenType = EVF.C('VENDOR_OPEN_TYPE').getValue();
                    // 공개경쟁일 경우 업체선택을 체크하지 않는다.
                    if (vendorOpenType === 'OB') {
                        if(!itemInfoGrid.validateExcept(['SELECT_CANDIDATE']).flag) {
                            alert('${msg.M0014}');
                            return false;
                        }
                    } else {
                    	if (!itemInfoGrid.validate().flag) {
                    		alert(itemInfoGrid.validate().msg);
                    		return false;
                    	}
                    }

                    if(gwdoc.getRowCount() !=0 && !gwdoc.validate().flag) {
                    	alert(gwdoc.validate().msg);
                        return false;
                    }
                }
                return true;
            } catch (e) {
                console.error(e);
                alert(e);
                return false;
            }
        }

        function approvalCallBack(approvalData) {
            approvalData = JSON.parse(approvalData);
            EVF.C('approvalFormData').setValue(approvalData.formData);
            EVF.C('approvalGridData').setValue(approvalData.gridData);
            EVF.C('SIGN_STATUS').setValue('P');
        }

        function doDelete() {
			if (EVF.getComponent('TRANSACTION_FLAG').getValue() == 'Y') {
				alert('${msg.M0123}');
				return;
			}

            if (EVF.C("RFX_NUM").getValue() === "") return;

            if (itemInfoGrid.getRowCount() > 0) {
                itemInfoGrid.checkAll(true);
            }

            if (confirm('${msg.M0013}')) {
                var store = new EVF.Store();
                store.setGrid([itemInfoGrid]);
                store.getGridData(itemInfoGrid, 'sel');
                store.load(baseUrl + "doDelete", function () {
                	EVF.getComponent('TRANSACTION_FLAG').setValue('Y');

                    alert(this.getResponseMessage());

                    doClose();
                });
            }
        }

        function openPreSourcingPopup() {
            everPopup.openPopupByScreenId('BPRM_030', 1000, 600, {
                callBackFunction: 'preSourcingListCallBack',
                detailView: 'false'
            });
        }

        function preSourcingListCallBack(selectedData) {
            EVF.C('RFI_NUM').setValue(selectedData['RFI_NUM']);
        }

        function doClose() {
            if (isPopup) {
                if ('${param.callbackFunction}' != '') {
                    if (opener !== undefined) {
                        try {
                            opener['${empty param.callbackFunction ? '_' : param.callbackFunction}']();
                            this.close();
                        } catch (e) {
                        }
                    }
                }
                formUtil.close();
            } else {
                new EVF.ModalWindow().close(null);
                <%-- $(location).attr('href', baseUrl + "BSOX_010/view"); --%>
                window.close();
            }
        }

        function _setRecVendor(vendorInfo) {
            itemInfoGrid.setCellValue(vendorInfo.rowid, 'REC_VENDOR_CD', vendorInfo['VENDOR_CD']);
            itemInfoGrid.setCellValue(vendorInfo.rowid, 'REC_VENDOR_NM', vendorInfo['VENDOR_NM']);
        }

        function _setSelectCandidate(vendorInfo, rowId) {
            itemInfoGrid.setCellValue(rowId, 'SELECT_CANDIDATE', JSON.parse(vendorInfo).length);
            itemInfoGrid.setCellValue(rowId, 'SELECT_CANDIDATE_JSON', vendorInfo);
        }

        function _setSubItemList(subItem, rowId) {
            itemInfoGrid.setCellValue(rowId, 'SUB_ITEM_LIST', JSON.parse(subItem).length);
            itemInfoGrid.setCellValue(rowId, 'SUB_ITEM_LIST_JSON', subItem);
        }

        function _setDelyToCode(delyToCode) {
            itemInfoGrid.setCellValue(delyToCode.rowid, 'DELY_TO_CD', delyToCode['DELY_TO_CD']);
            itemInfoGrid.setCellValue(delyToCode.rowid, 'DELY_TO_CD_NM', delyToCode['DELY_TO_NM']);
        }

        function _setFileUuidItemGrid(gridRowId, fileId, fileCount) {
            itemInfoGrid.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
            itemInfoGrid.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
        }

        function _setPlant(plantInfo) {
            itemInfoGrid.setCellValue(plantInfo.rowid, 'PLANT_CD', plantInfo['PLANT_CD']);
            itemInfoGrid.setCellValue(plantInfo.rowid, 'PLANT_NM', plantInfo['PLANT_NM']);
        }

        var tabBaseUrl = "/eversrm/solicit/solicitItem/detailInfoPerItemTab/";
        function getDetailItemInformation() {
            var store = new EVF.Store();
            store.setParameter("GATE_CD", '${ses.gateCd}');
            store.setParameter("RFX_NUM", '${param.rfxNo}');
            store.setParameter("RFX_CNT", "${param.rfxCnt  == undefined ? param.rfxCNT : param.rfxCnt}");
            store.setParameter("RFX_TYPE", "RFQ");
            store.setParameter("RFX_SEQ", this.getValue());

            store.load(tabBaseUrl + "getDetailItemInformation", function () {
            });
        }

        function onChangeValueNumericPercent() {

            this.setValue(everMath.round_float(this.getValue(), 2));

            <%-- 제안/기술비중을 지우거나 0으로 바꾸면 평가자, 평가항목 그리드는 초기화 시킨다. --%>
            if(this.getID() == 'NOT_PRC_PERCENT') {
                if(EVF.isEmpty(this.getValue()) || this.getValue() == 0) {
                    var evaluatorAllRowId = evaluatorGrid.getAllRowId();
                    for(var x in evaluatorAllRowId) {
                        evaluatorAllRowId[x]
                    }
                }
            }
        }

        function markGridDataToDelete(gridObject) {
            var selRowId = gridObject.getSelRowId();
            for(var x in selRowId) {
                var rowId = selRowId[x];
                if(gridObject.getCellValue(rowId, 'DEL_FLAG') === '') {
                    gridObject.delRow(rowId);
                } else {
                    gridObject.setCellValue(rowId, 'DEL_FLAG', '1');
                    gridObject.setCellFontDeco(rowId, 'ITEM_CD', 'line-through');
                }
            }
        }

        $(document.body).ready(function() {
            $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                    {
                        activate: function(event, ui) {
                            <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                            $(window).trigger('resize');
                        }
                    }
            );
            $('#e-tabs').tabs('option', 'active', 0);
            getContentTab('1');

        });

        function getContentTab(uu) {
            if (uu == '1') {
                window.scrollbars = true;
            }
            if (uu == '2') {
                window.scrollbars = true;
            }
        }

        function EXCELDOWN() {

            itemInfoGrid.hideCol('IMAGE', true);

            var store = new EVF.Store();
            store.setGrid([itemInfoGrid]);
            itemInfoGrid.excelExport({
                allCol : "${excelExport.allCol}",
                selRow : "${excelExport.selRow}",
                fileType : "${excelExport.fileType }",
                fileName : "${screenName }",
                excelOptions : {
                    imgWidth      : 0.12,       <%-- // 이미지의 너비. --%>
                    imgHeight     : 0.26,      <%-- // 이미지의 높이. --%>
                    colWidth      : 20,        <%-- // 컬럼의 넓이. --%>
                    rowSize       : 500,       <%-- // 엑셀 행에 높이 사이즈. --%>
                    attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
                }
            }).call();
            //});
        }


        function getPriceDesc() {
        	var purchase_type = EVF.C('PURCHASE_TYPE').getValue();
        	if (purchase_type=='NORMAL' || purchase_type=='') {
        		alert('${BSOX_010_9918}');
        		return;
        	}
    		var params = {
    				PRICE_DECISION_BASE_CODE_LIST : EVF.C('PRICE_DECISION_BASE_CODE_LIST').getValue()
    				,detailView : '${param.detailView}'
    				,callBackFunction : 'setPriceBaseCd'
        		};
    		    everPopup.openPopupByScreenId('BSOX_011', 800, 460, params);
        }

        function setPriceBaseCd(text,data) {
        	EVF.C('PRICE_DECISION_BASE_TEXT').setValue(text);
        	EVF.C('PRICE_DECISION_BASE_CODE_LIST').setValue(data);
        }



        function goTemplete() {
            var param = {
                    "callBackFunction": 'setReamrk'
                };
                everPopup.openCommonPopup(param, "MP0003");
        }

		function setReamrk(data) {
			//EVF.C('RMK_CONTENTS').setValue('');
			var strStr = '';
			for(var k = 0;k < data.length;k++) {
				strStr += data[k].CODE_DESC+'<BR>';
			}
			//alert(strStr)
			EVF.C('RMK_CONTENTS').setValue(strStr);
		}

   </script>
    <e:window id="BSOX_010" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:inputHidden id="TRANSACTION_FLAG" name="TRANSACTION_FLAG" value="N"/>

        <e:inputHidden id="APP_DOC_NUM" name="APP_DOC_NUM" value="${param.appDocNo}" />
        <e:inputHidden id="APP_DOC_CNT" name="APP_DOC_CNT" value="${param.appDocCnt}" />
        <e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${ses.companyCd}" />
        <e:inputHidden id="PUR_ORG_CD" name="PUR_ORG_CD" value="${ses.companyCd}" />
		<e:inputHidden id="PREV_MOLD_YN" name="PREV_MOLD_YN" value="${form.MOLD_YN}" />

        <e:inputHidden id="RFP_START_DATE" name="RFP_START_DATE" />
        <e:inputHidden id="RFP_START_HOUR" name="RFP_START_HOUR" />
        <e:inputHidden id="RFP_START_MIN" name="RFP_START_MIN" />
        <e:inputHidden id="RFP_CLOSE_DATE" name="RFP_CLOSE_DATE" />
        <e:inputHidden id="RFP_CLOSE_HOUR" name="RFP_CLOSE_HOUR" />
        <e:inputHidden id="RFP_CLOSE_MIN" name="RFP_CLOSE_MIN" />
        <e:inputHidden id="PAY_TERMS" name="PAY_TERMS" />
        <e:inputHidden id="DELY_TERMS" name="DELY_TERMS" />
        <e:inputHidden id="SHIPPING_CD" name="SHIPPING_CD" />
        <e:inputHidden id="RFX_OPEN_TYPE" name="RFX_OPEN_TYPE" value="SEL"/>
        <e:inputHidden id="RFI_NUM" name="RFI_NUM" />
        <e:inputHidden id="ITEM_CLASS_CD" name="ITEM_CLASS_CD"/>

        <e:inputHidden id="APPROVAL_FLAG" name="APPROVAL_FLAG" value="${form.APPROVAL_FLAG}" /> <!-- 결재여부 : 미사용 -->
        <e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
        <e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${form.SIGN_STATUS}" />
        <e:inputHidden id="QTA_FLAG" name="QTA_FLAG" value="${form.QTA_FLAG}" /> <!-- 업체견적서 생성 COUNT : 업체견적서 생성시 저장 및 전송불가 -->

        <e:inputHidden id="prItemList" name="prItemList" value="${param.prList}" />
        <e:inputHidden id="saveButtonType" name="saveButtonType" />
        <e:inputHidden id="baseDataType" name="baseDataType" value="${param.baseDataType}" />
        <e:inputHidden id="settleType" name="settleType" value="${param.settleType}" />
        <e:inputHidden id="preferredBidder" name="preferredBidder" value="${param.preferredBidder}" />
        <e:inputHidden id="passedVendors" name="passedVendors" value="${param.passedVendors}" />
        <e:inputHidden id="approvalFormData" name="approvalFormData" />
        <e:inputHidden id="approvalGridData" name="approvalGridData" />
        <e:inputHidden id="vendorMasterList" name="vendorMasterList" />

        <e:buttonBar align="right">
            <e:button label='${doSave_N }' id='doSave' onClick='doSave' disabled='${doSave_D }' visible='${doSave_V }' data='T' />
            <e:button label='${doTransfer_N }' id='doTransfer' onClick='doSave' disabled='${doTransfer_D }' visible='${doTransfer_V }' data='E' />
            <e:button label='${doDelete_N }' id='doDelete' onClick='doDelete' disabled='${doDelete_D }' visible='${doDelete_V }' data='${doDelete_A }' />
   	        <e:button label='${doClose_N }' id='doClose' onClick='doClose' disabled='${doClose_D }' visible='${doClose_V }' data='${doClose_A }' />
			<!--
            <e:button label='${requestApp_N }' id='requestApp' onClick='doSave' disabled='${requestApp_D }' visible='${requestApp_V }' data='P' />
            -->
        </e:buttonBar>

        <e:searchPanel id="form1" title="${form_GENERAL_INFORMATION_N }" columnCount="2" labelWidth="135">

            <c:if test="${ses.userType == 'B'}">
            <e:row>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
                <e:field>
                    <e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty form.GATE_CD ? param.gateCd : form.GATE_CD}" />
                    <e:inputText id='RFX_NUM' name="RFX_NUM" value='${empty form.RFX_NUM ? param.rfxNum : form.RFX_NUM}' width='130' maxLength='${form_RFX_NUM_M }' required='${form_RFX_NUM_R }' readOnly='true' disabled='true' visible='${form_RFX_NUM_V }' />
                    <e:text>/</e:text>
                    <e:inputText id='RFX_CNT' name="RFX_CNT" align='right' value='${empty form.RFX_CNT ? param.rfxCnt : form.RFX_CNT}' width='40' required='${form_RFX_CNT_R }' readOnly='true' disabled='${form_RFX_CNT_D }' maxLength="${form_RFX_CNT_M}" />
                </e:field>
                <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
                <e:field>
                    <e:select id="PURCHASE_TYPE"  onChange="chPurchaseType"  name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseType }" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
			</c:if>
            <c:if test="${ses.userType == 'S'}">
					<e:inputHidden id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}"/>
			</c:if>



            <c:if test="${ses.userType == 'B'}">
            <e:row>
                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
                <e:field>
                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='${form_RFX_TYPE_D }' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
                    </e:select>
                </e:field>
				<e:label for="PRICE_DECISION_BASE_TEXT" title="${form_PRICE_DECISION_BASE_TEXT_N}"/>
				<e:field>
				<e:search id="PRICE_DECISION_BASE_TEXT" style="${imeMode}" name="PRICE_DECISION_BASE_TEXT" value="${form.PRICE_DECISION_BASE_TEXT}" width="300" maxLength="${form_PRICE_DECISION_BASE_TEXT_M}" onIconClick="${form_PRICE_DECISION_BASE_TEXT_RO ? 'everCommon.blank' : 'getPriceDesc'}" disabled="${form_PRICE_DECISION_BASE_TEXT_D}" readOnly="${form_PRICE_DECISION_BASE_TEXT_RO}" required="${form_PRICE_DECISION_BASE_TEXT_R}" />
				<e:inputHidden id="PRICE_DECISION_BASE_CODE_LIST" name="PRICE_DECISION_BASE_CODE_LIST" value="${form.PRICE_DECISION_BASE_CODE_LIST}"/>
				</e:field>
            </e:row>
			</c:if>
            <c:if test="${ses.userType == 'S'}">

            <e:row>
                <e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
                <e:field>
                    <e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty form.GATE_CD ? param.gateCd : form.GATE_CD}" />
                    <e:inputText id='RFX_NUM' name="RFX_NUM" value='${empty form.RFX_NUM ? param.rfxNum : form.RFX_NUM}' width='130' maxLength='${form_RFX_NUM_M }' required='${form_RFX_NUM_R }' readOnly='true' disabled='true' visible='${form_RFX_NUM_V }' />
                    <e:text>/</e:text>
                    <e:inputText id='RFX_CNT' name="RFX_CNT" align='right' value='${empty form.RFX_CNT ? param.rfxCnt : form.RFX_CNT}' width='40' required='${form_RFX_CNT_R }' readOnly='true' disabled='${form_RFX_CNT_D }' maxLength="${form_RFX_CNT_M}" />
                </e:field>

                <e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}" />
                <e:field>
                    <e:select id="RFX_TYPE" name="RFX_TYPE" options="${rfxtype}"  value="${form.RFX_TYPE}" label='${form_RFX_TYPE_N }' width='${inputTextWidth }' required='${form_RFX_TYPE_R }' readOnly='${form_RFX_TYPE_RO }' disabled='${form_RFX_TYPE_D }' visible='${form_RFX_TYPE_V }' placeHolder='${placeHolder }' >
                    </e:select>
                </e:field>
            </e:row>


			</c:if>

            <e:row>
                <e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
                <e:field>
                    <e:inputText id='RFX_SUBJECT' style="${imeMode}" name="RFX_SUBJECT" value="${form.RFX_SUBJECT}" width='100%' maxLength='${form_RFX_SUBJECT_M }' required='${form_RFX_SUBJECT_R }' readOnly='${form_RFX_SUBJECT_RO }' disabled='${form_RFX_SUBJECT_D }' visible='${form_RFX_SUBJECT_V }' />
                </e:field>
				<e:label for="MOLD_YN" title="${form_MOLD_YN_N}"/>
				<e:field>
                    <e:check id='MOLD_YN' name="MOLD_YN" value="1" checked="${form.MOLD_YN eq '1' ? 'true' : 'false'}" label='${BSOX_010_MOLD_YN_DESC}' width='${inputTextWidth }' required='${form_MOLD_YN_R }' disabled='${form_MOLD_YN_D }' visible='${form_MOLD_YN_V }' />
				</e:field>
            </e:row>

            <c:if test="${ses.userType == 'B'}">
            <e:row>
                <e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
                <e:field>
                    <e:select id="VENDOR_OPEN_TYPE" onChange="chVendorOpenType" name="VENDOR_OPEN_TYPE" value="${form.VENDOR_OPEN_TYPE}" options="${vendorOpenType }" width="${inputTextWidth}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
                </e:field>

                <e:label for="SUBMIT_TYPE" title="${form_SUBMIT_TYPE_N}"/>
                <e:field>
                    <e:select id="SUBMIT_TYPE" onChange="clearTplNum" name="SUBMIT_TYPE" value="${form.SUBMIT_TYPE}" options="${submitType }" width="${inputTextWidth}" disabled="${form_SUBMIT_TYPE_D}" readOnly="${form_SUBMIT_TYPE_RO}" required="${form_SUBMIT_TYPE_R}" placeHolder="" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="PRC_STL_TYPE" title="${form_PRC_STL_TYPE_N}"/>
                <e:field>
                    <e:select id="PRC_STL_TYPE" onChange="chPrcStlType" name="PRC_STL_TYPE" value="${form.PRC_STL_TYPE}" options="${prcStlType }" width="${inputTextWidth}" disabled="${form_PRC_STL_TYPE_D}" readOnly="${form_PRC_STL_TYPE_RO}" required="${form_PRC_STL_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="SETTLE_TYPE" title="${form_SETTLE_TYPE_N}" />
                <e:field>
                    <e:select id="SETTLE_TYPE"  name="SETTLE_TYPE" value="${form.SETTLE_TYPE}" options="${settleType}" label='${form_SETTLE_TYPE_N }' width='${inputTextWidth }' required='${form_SETTLE_TYPE_R }' readOnly='${form_SETTLE_TYPE_RO }' disabled='${form_SETTLE_TYPE_D }' visible='${form_SETTLE_TYPE_V }' placeHolder='${placeHolder }' />
                </e:field>
            </e:row>
			</c:if>
            <c:if test="${ses.userType == 'S'}">
			<e:inputHidden id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE"/>
			<e:inputHidden id="SUBMIT_TYPE" name="SUBMIT_TYPE"/>
			<e:inputHidden id="PRC_STL_TYPE" name="PRC_STL_TYPE"/>
			<e:inputHidden id="SETTLE_TYPE" name="SETTLE_TYPE"/>

			</c:if>

            <e:row>
                <e:label for="RFQ_START_DATE" title="${form_RFQ_START_DATE_N}" />
                <e:field>
                    <e:inputDate id='RFQ_START_DATE' toDate="RFQ_CLOSE_DATE" name="RFQ_START_DATE" value='${form.RFQ_START_DATE}' width='${inputDateWidth }' required='${form_RFQ_START_DATE_R }' readOnly='${form_RFQ_START_DATE_RO }' disabled='${form_RFQ_START_DATE_D }' visible='${form_RFQ_START_DATE_V }' datePicker='true' onSelectDate="onChangeDate"/>
                    <e:select id='RFQ_START_HOUR' name="RFQ_START_HOUR" value="${form.RFQ_START_HOUR}" options="${refHours}" width='60' required='${form_RFQ_START_HOUR_R }' readOnly='${form_RFQ_START_HOUR_RO }' disabled='${form_RFQ_START_HOUR_D }' visible='${form_RFQ_START_HOUR_V }' onChange="_onChangeForm" />
                    <e:text>${form_RFQ_START_HOUR_N }</e:text>
                    <e:select id='RFQ_START_MIN' name="RFQ_START_MIN" value="${form.RFQ_START_MIN}" options="${refMinutes}" width='60' required='${form_RFQ_START_MIN_R }' readOnly='${form_RFQ_START_MIN_RO }' disabled='${form_RFQ_START_MIN_D }' visible='${form_RFQ_START_MIN_V }' onChange="_onChangeForm" />
                    <e:text>${form_RFQ_START_MIN_N }</e:text>
                </e:field>
                <e:label for="RFQ_CLOSE_DATE" title="${form_RFQ_CLOSE_DATE_N}" />
                <e:field>
                    <e:inputDate id='RFQ_CLOSE_DATE' fromDate="RFQ_START_DATE" name="RFQ_CLOSE_DATE" value='${form.RFQ_CLOSE_DATE}' width='${inputDateWidth }' required='${form_RFQ_CLOSE_DATE_R }' readOnly='${form_RFQ_CLOSE_DATE_RO }' disabled='${form_RFQ_CLOSE_DATE_D }' visible='${form_RFQ_CLOSE_DATE_V }' datePicker='true' />
                    <e:select id='RFQ_CLOSE_HOUR' name="RFQ_CLOSE_HOUR" value="${form.RFQ_CLOSE_HOUR}" options="${refHours}" width='60' required='${form_RFQ_CLOSE_HOUR_R }' readOnly='${form_RFQ_CLOSE_HOUR_RO }' disabled='${form_RFQ_CLOSE_HOUR_D }' visible='${form_RFQ_CLOSE_HOUR_V }' onChange="_onChangeForm" />
                    <e:text>${form_RFQ_CLOSE_HOUR_N }</e:text>
                    <e:select id='RFQ_CLOSE_MIN' name="RFQ_CLOSE_MIN" value="${form.RFQ_CLOSE_MIN}" options="${refMinutes}" width='60' required='${form_RFQ_CLOSE_MIN_R }' readOnly='${form_RFQ_CLOSE_MIN_RO }' disabled='${form_RFQ_CLOSE_MIN_D }' visible='${form_RFQ_CLOSE_MIN_V }' onChange="_onChangeForm" />
                    <e:text>${form_RFQ_CLOSE_MIN_N }</e:text>
                </e:field>
            </e:row>

            <e:row>
                <e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
                <e:field>
                    <e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" usePlaceHolder="false" value="${form.SHIPPER_TYPE}" options="${shipperType }" width="${inputTextWidth}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" />
                </e:field>
                <e:label for="CUR" title="${form_CUR_N}"/>
                <e:field>
                    <e:select id="CUR" onChange="chCur" name="CUR" value="${empty form.CUR ? ses.cur : form.CUR}" options="${cur}" width="${inputTextWidth}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" />
                    <e:text>&nbsp;</e:text>
					<e:select id="VAT_TYPE" name="VAT_TYPE" usePlaceHolder="false" value="${form.VAT_TYPE}" options="${vatTypeOptions}" width="${inputTextWidth}" disabled="${form_VAT_TYPE_D}" readOnly="${form_VAT_TYPE_RO}" required="${form_VAT_TYPE_R}" placeHolder="" />
					<div id="CURR"></div>

                </e:field>
            </e:row>
            <c:if test="${ses.userType == 'B'}">
		            <e:row>
		                <e:label for="EV_TPL_NM" title="${form_EV_TPL_NM_N}"/>
		                <e:field>
		                    <e:text>${BSOX_010_9009}</e:text>
		                    <e:select id="EV_TPL_CD" name="EV_TPL_CD" value="${form.EV_TPL_CD}" options="${evTplCd}" width="${inputTextWidth}" disabled="${form_EV_TPL_CD_D}" readOnly="${form_EV_TPL_CD_RO}" required="${form_EV_TPL_CD_R}" placeHolder="" />
		                    <e:text>&nbsp;</e:text>
		                    <e:search id="EV_TPL_NM" style="${imeMode}" name="EV_TPL_NM" value="${form.EV_TPL_NM}" width="${inputTextWidth}" maxLength="${form_EV_TPL_NM_M}" onIconClick="${form_EV_TPL_NM_RO ? 'everCommon.blank' : 'openTplNum'}" disabled="${form_EV_TPL_NM_D}" readOnly="${form_EV_TPL_NM_RO}" required="${form_EV_TPL_NM_R}" />
		                    <e:inputHidden id="EV_TPL_NUM" name="EV_TPL_NUM" value="${form.EV_TPL_NUM}"/>
		                    <e:br/>
		                    <e:text>${BSOX_010_9010}</e:text>
							<e:select id="SCND_EV_TPL_CD" name="SCND_EV_TPL_CD" value="${form.SCND_EV_TPL_CD}" options="${evTplCd}" width="${inputTextWidth}" disabled="${from_SCND_EV_TPL_CD_D}" readOnly="${from_SCND_EV_TPL_CD_RO}" required="${from_SCND_EV_TPL_CD_R}" placeHolder="" />
		                    <e:text>&nbsp;</e:text>
							<e:search id="SCND_EV_TPL_NM" style="${imeMode}" name="SCND_EV_TPL_NM" value="${form.SCND_EV_TPL_NM}" width="${inputTextWidth}" maxLength="${from_SCND_EV_TPL_NM_M}" onIconClick="${from_SCND_EV_TPL_NM_RO ? 'everCommon.blank' : 'openTplNumScnd'}" disabled="${from_SCND_EV_TPL_NM_D}" readOnly="${from_SCND_EV_TPL_NM_RO}" required="${from_SCND_EV_TPL_NM_R}" />
		                    <e:inputHidden id="SCND_EV_TPL_NUM" name="SCND_EV_TPL_NUM" value="${form.SCND_EV_TPL_NUM}"/>
		                </e:field>
		                <e:label for="PRC_PERCENT" title="${form_PRC_PERCENT_N}"/>
		                <e:field>
		                    <e:text>${BSOX_010_9009}</e:text>
		                    <e:inputNumber id="PRC_PERCENT"  width="50"  name="PRC_PERCENT" value="${form.PRC_PERCENT}" maxValue="${form_PRC_PERCENT_M}" decimalPlace="${form_PRC_PERCENT_NF}" disabled="${form_PRC_PERCENT_D}" readOnly="${form_PRC_PERCENT_RO}" required="${form_PRC_PERCENT_R}" />
		                    <e:text>% /</e:text>
		                    <e:inputNumber id="NOT_PRC_PERCENT"  width="50"  name="NOT_PRC_PERCENT" value="${form.NOT_PRC_PERCENT}" maxValue="${form_NOT_PRC_PERCENT_M}" decimalPlace="${form_NOT_PRC_PERCENT_NF}" disabled="${form_NOT_PRC_PERCENT_D}" readOnly="${form_NOT_PRC_PERCENT_RO}" required="${form_NOT_PRC_PERCENT_R}" />
		                    <e:text>%</e:text>
		                    <e:br/>
		                    <e:text>${BSOX_010_9010}</e:text>
		                    <e:inputNumber id="SCND_PRC_PERCENT"  width="50"  name="SCND_PRC_PERCENT" value="${form.SCND_PRC_PERCENT}" maxValue="${form_SCND_PRC_PERCENT_M}" decimalPlace="${form_SCND_PRC_PERCENT_NF}" disabled="${form_SCND_PRC_PERCENT_D}" readOnly="${form_SCND_PRC_PERCENT_RO}" required="${form_SCND_PRC_PERCENT_R}" />
		                    <e:text>% /</e:text>
		                    <e:inputNumber id="SCND_NOT_PRC_PERCENT"  width="50"  name="SCND_NOT_PRC_PERCENT" value="${form.SCND_NOT_PRC_PERCENT}" maxValue="${form_SCND_NOT_PRC_PERCENT_M}" decimalPlace="${form_SCND_NOT_PRC_PERCENT_NF}" disabled="${form_SCND_NOT_PRC_PERCENT_D}" readOnly="${form_SCND_NOT_PRC_PERCENT_RO}" required="${form_SCND_NOT_PRC_PERCENT_R}" />
		                    <e:text>%</e:text>
		                </e:field>
            </e:row>
            </c:if>

                <c:if test="${ses.userType == 'B'}">
            <e:row>
                <e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
                    <e:field>
	                    <e:inputText id="CTRL_USER_ID" name="CTRL_USER_ID" value="${empty form.CTRL_USER_ID ? ses.userId : form.CTRL_USER_ID}" width="${inputTextWidth }" maxLength="${form_CTRL_USER_ID_M}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}"/>
    	                <e:text>&nbsp;</e:text>
						<e:inputText id="CTRL_USER_NM" style="${imeMode}" name="CTRL_USER_NM" value="${empty form.CTRL_USER_NM ? ses.userNm : form.CTRL_USER_NM}" width="${inputTextWidth}" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}"/>
                    </e:field>

                    <e:label for="OPEN_USER_NM" title="${form_OPEN_USER_ID_N}" />
                    <e:field>
						<e:inputText id="OPEN_USER_ID" style="ime-mode:inactive" name="OPEN_USER_ID" value="${empty form.OPEN_USER_ID ? ses.userId : form.OPEN_USER_ID}" width="${inputTextWidth}" maxLength="${form_OPEN_USER_ID_M}" disabled="${form_OPEN_USER_ID_D}" readOnly="${form_OPEN_USER_ID_RO}" required="${form_OPEN_USER_ID_R}"/>
    	                <e:text>&nbsp;</e:text>
                        <e:search id='OPEN_USER_NM' name="OPEN_USER_NM" value='${empty form.OPEN_USER_NM ? ses.userNm : form.OPEN_USER_NM}' maxLength="${form_OPEN_USER_NM_M}" width='${inputTextWidth }' required='${form_OPEN_USER_NM_R }' readOnly='true' disabled='${form_OPEN_USER_NM_D }' visible='${form_OPEN_USER_NM_V }' onIconClick="doSearchOpener" />
                    </e:field>
            </e:row>
                </c:if>

                <c:if test="${ses.userType == 'S'}">
                        <e:inputHidden id='CTRL_USER_NM' name="CTRL_USER_NM" value='${empty form.CTRL_USER_ID ? ses.userId : form.CTRL_USER_NM}' />
                        <e:inputHidden id='CTRL_USER_ID' name="CTRL_USER_ID" value='${empty form.CTRL_USER_ID ? ses.userId : form.CTRL_USER_ID}' />
                        <e:inputHidden id='OPEN_USER_ID' name="OPEN_USER_ID" value='${empty form.OPEN_USER_ID ? ses.userId : form.OPEN_USER_ID}' />
				</c:if>


            <e:row>
                <e:label for="RMK_CONTENTS" title="${form_RMK_TEXT_NUM_N}" >
                <e:button id="goTemplete" name="goTemplete" label="${goTemplete_N}" onClick="goTemplete" disabled="${goTemplete_D}" visible="${goTemplete_V}"/>
                </e:label>
                <e:field colSpan="3">
                    <e:richTextEditor id='RMK_CONTENTS' name="RMK_CONTENTS" value="${form.RMK_CONTENTS}" height="150" width='100%' disabled='${form_RMK_TEXT_NUM_D }' visible='${form_RMK_TEXT_NUM_V }' readOnly="${form_RMK_TEXT_NUM_RO}" required="${form_RMK_TEXT_NUM_R}" />
                    <e:inputHidden id='RMK_TEXT_NUM' style="${imeMode}" name="RMK_TEXT_NUM" value="${form.RMK_TEXT_NUM}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
                <e:field colSpan="3">
                    <e:fileManager id="ATT_FILE_NUM" readOnly="${form_ATT_FILE_NUM_RO}" fileId="${form.ATT_FILE_NUM}" bizType="RFQ" required="${form_ATT_FILE_NUM_R}" width="100%" height="120px" />
                </e:field>
            </e:row>

            <c:if test="${ses.userType == 'B'}">
	            <e:row>
	                <e:label for="XXXXXXXXX" title="${BSOX_010_GW_RELATED_DOC}" />
	                <e:field colSpan="3">
	                    <e:gridPanel gridType="${_gridType}" id="gwdoc" name="gwdoc" height="150" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.gwdoc.gridColData}" />
	                </e:field>
	            </e:row>
			</c:if>
            <e:row>
                <e:label for="ANN_FLAG" title="${form_ANN_FLAG_N}" />
                <e:field colSpan="3">
                    <e:check id='ANN_FLAG' name="ANN_FLAG" value="1" checked="${form.ANN_FLAG eq '1' ? 'true' : 'false'}" label='${BSOX_010_ANN_FLAG_DESC}' width='${inputTextWidth }' required='${form_ANN_FLAG_R }' disabled='${form_ANN_FLAG_D }' visible='${form_ANN_FLAG_V }' onClick="setDisplayBiddersConferencePanel" />
                </e:field>
            </e:row>

        </e:searchPanel>

        <e:searchPanel id="bcPanel" title="${form_BC_INFO_CAPTION_N }" labelWidth="135" columnCount="2">
            <e:row>
                <e:label for="ANN_DATE" title="${form_ANN_DATE_N}"/>
                <e:field>
                    <e:inputDate id='ANN_DATE' name='ANN_DATE' label='${form_ANN_DATE_N }' value='${form.ANN_DATE}' width='${inputDateWidth }' required='${form_ANN_DATE_R }' readOnly='${form_ANN_DATE_RO }' disabled='${form_ANN_DATE_D }' visible='${form_ANN_DATE_V }' datePicker='true' onChange="_onChangeForm" />
                    <e:select id='ANN_START_HOUR' name="ANN_START_HOUR" value="${form.ANN_START_HOUR}" options="${refHours}" width='60' required='${form_ANN_DATE_R }' readOnly='${form_ANN_DATE_RO }' disabled='${form_ANN_DATE_D }' visible='${form_ANN_DATE_V }' onChange="_onChangeForm" />
                    <e:text>${form_RFQ_START_HOUR_N }</e:text>
                    <e:select id='ANN_START_MIN' name="ANN_START_MIN" value="${form.ANN_START_MIN}" options="${refMinutes}" width='60' required='${form_ANN_DATE_R }' readOnly='${form_ANN_DATE_RO }' disabled='${form_ANN_DATE_D }' visible='${form_ANN_DATE_V }' onChange="_onChangeForm" />
                    <e:text>${form_RFQ_START_MIN_N }</e:text>
                </e:field>
                <e:label for="ANN_PLACE_NM" title="${form_ANN_PLACE_NM_N}"/>
                <e:field>
                    <e:inputText id='ANN_PLACE_NM' style="${imeMode}" name='ANN_PLACE_NM' value="${form.ANN_PLACE_NM}" label='${form_ANN_PLACE_NM_N }' width='100%' maxLength='${form_ANN_PLACE_NM_M }' required='${form_ANN_PLACE_NM_R }' readOnly='${form_ANN_PLACE_NM_RO }' disabled='${form_ANN_PLACE_NM_D }' visible='${form_ANN_PLACE_NM_V }' onChange="_onChangeForm" />
                </e:field>
            </e:row>
            <e:row>

                <e:label for="ANN_USER_NM" title="${form_ANN_USER_NM_N}" />
                <e:field>
                    <e:inputText id='ANN_USER_NM' style="${imeMode}" name="ANN_USER_NM" value="${form.ANN_USER_NM}" width='${inputTextWidth }'  maxLength='${form_ANN_USER_NM_M }' required='${form_ANN_USER_NM_R }' readOnly='${form_ANN_USER_NM_RO }' disabled='${form_ANN_USER_NM_D }' visible='${form_ANN_USER_NM_V }' />
                </e:field>

                <e:label for="ANN_USER_TEL_NUM" title="${form_ANN_USER_TEL_NUM_N}"/>
                <e:field>
                    <e:inputText id='ANN_USER_TEL_NUM' name='ANN_USER_TEL_NUM' value="${form.ANN_USER_TEL_NUM}" label='${form_ANN_USER_TEL_NUM_N }' width='${inputTextWidth }' maxLength='${form_ANN_USER_TEL_NUM_M }' required='${form_ANN_USER_TEL_NUM_R }' readOnly='${form_ANN_USER_TEL_NUM_RO }' disabled='${form_ANN_USER_TEL_NUM_D }' visible='${form_ANN_USER_TEL_NUM_V }' onChange="_onChangeForm" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:searchPanel useTitleBar="false" id="formItemInfo" title="${form_ITEM_INFO_CAPTION_N }">
            <e:row>
                <e:field>
                    <e:buttonBar align="right">
                        <e:button id="getBom" name="getBom" label="${getBom_N}" onClick="getBom" disabled="${getBom_D}" visible="${getBom_V}"/>
                        <e:button label='${openCatalog_N }' id='openCatalog' onClick='openCatalog' disabled='${openCatalog_D }' visible='${openCatalog_V }' data='${openCatalog_A }' />
						<e:button label='${openCandidate_N }' id='openCandidate' onClick='openCandidate' disabled='${openCandidate_D }' visible='${openCandidate_V }' data='${openCandidate_A }' />
					</e:buttonBar>
                </e:field>
            </e:row>


            <e:row>
                <e:field>
                    <e:gridPanel gridType="${_gridType}" id="itemInfoGrid" name="itemInfoGrid" height="300" width="100%" readOnly="${param.detailView}" columnDef="${gridInfos.itemInfoGrid.gridColData}" />
                </e:field>
            </e:row>

        </e:searchPanel>

    </e:window>
</e:ui>