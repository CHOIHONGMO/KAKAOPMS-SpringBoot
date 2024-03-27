<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	 <script type="text/javascript">

	    var grid;
	    var baseUrl = "/evermp/BNM1/BNM101/";

	    function init() {

	        grid = EVF.C("grid");

			grid.cellClickEvent(function(rowId, colId, value) {

	        	if(colId == "ITEM_RMK") {
	        		var param = {
	        			title: "품목상세설명",
						message: grid.getCellValue(rowId, 'ITEM_RMK'),
						callbackFunction: 'setItemRmk',
						rowId: rowId
					};
					var url = '/common/popup/common_text_input/view';
					everPopup.openModalPopup(url, 500, 310, param);

				}
	        	if(colId == "REQ_TXT") {
	        		var param = {
	        			title: "요청사항",
						message: grid.getCellValue(rowId, 'REQ_TXT'),
						callbackFunction: 'setRfqReqTxt',
						rowId: rowId
					};
					var url = '/common/popup/common_text_input/view';
					everPopup.openModalPopup(url, 500, 310, param);
	        	}
	        	if(colId == 'IMAGE_UUID_IMG') {
	        		everPopup.fileAttachPopup('IMAGE', grid.getCellValue(rowId, 'IMAGE_UUID'), 'setImageUuid', rowId, false);
	        	}
	        	if(colId == 'ATTACH_FILE_NO_IMG') {
	        		everPopup.fileAttachPopup('RE', grid.getCellValue(rowId, 'ATTACH_FILE_NO'), 'setAttachFileNo', rowId, false);
	        	}
	        	if(colId == 'AUTO_PO_FLAG_Z') {

                    if("${ses.buyerApproveUseFlag}" != "1" && "${ses.buyerBudgetUseFlag}" != "1") {
                        var param = {
                            rowId: rowId,
                            screenName: "주문정보",
                            BUDGET_DEPT_CD: grid.getCellValue(rowId, 'BUDGET_DEPT_CD'),
                            BUDGET_DEPT_NM: grid.getCellValue(rowId, 'BUDGET_DEPT_NM'),
                            ACCOUNT_CD: grid.getCellValue(rowId, 'ACCOUNT_CD'),
                            ACCOUNT_NM: grid.getCellValue(rowId, 'ACCOUNT_NM'),
                            RECIPIENT_NM: grid.getCellValue(rowId, 'RECIPIENT_NM'),
                            RECIPIENT_DEPT_NM: grid.getCellValue(rowId, 'RECIPIENT_DEPT_NM'),
                            RECIPIENT_TEL_NO: grid.getCellValue(rowId, 'RECIPIENT_TEL_NO'),
                            RECIPIENT_CELL_NO: grid.getCellValue(rowId, 'RECIPIENT_CELL_NO'),
                            DELY_ZIP_CD: grid.getCellValue(rowId, 'DELY_ZIP_CD'),
                            DELY_ADDR_1: grid.getCellValue(rowId, 'DELY_ADDR_1'),
                            DELY_ADDR_2: grid.getCellValue(rowId, 'DELY_ADDR_2'),
                            REQ_TXT: grid.getCellValue(rowId, 'REQ_TXT'),
                            callBackFunction: "setPoInfo",
                            detailView: false
                        };
                        everPopup.openModalPopup("/evermp/BNM1/BNM101/BNM1_020/view", 800, 450, param);
                    }
	        	}
			});

			grid.cellChangeEvent(function(rowid, colId, iRow, iCol, value, oldValue) {

		        if (colId == 'EST_YEAR_QT' || colId == 'PREV_UNIT_PRICE' || colId == 'EST_PO_QT') {
					if(value < 0) {
					    alert('${ BNM1_010_ALERT3 }');
						grid.setCellValue(rowid, colId, oldValue);
						return;
					}
		    	}
		    	if (colId == 'EST_PO_DATE' || colId == 'HOPE_DUE_DATE') {
		    		if (value == '') return;
		    		if ('${today}' > value) {
		    			alert('${BNM1_010_ALERT4 }');
		    			grid.setCellValue(rowid, colId, oldValue);
		    		}
		    		if (grid.getCellValue(rowid,'EST_PO_DATE') != '' && grid.getCellValue(rowid,'HOPE_DUE_DATE') !='') {
						if (grid.getCellValue(rowid,'EST_PO_DATE') > grid.getCellValue(rowid,'HOPE_DUE_DATE')) {
			    			alert('${BNM1_010_ALERT5 }');
			    			grid.setCellValue(rowid, colId, oldValue);
						}
					}
		    	}

		    	if(colId == 'AUTO_PO_FLAG' && value == "1") {
		    		var param = {
                        rowId: rowid,
                        screenName: "주문정보",
                        BUDGET_DEPT_CD: grid.getCellValue(rowid, 'BUDGET_DEPT_CD'),
                        BUDGET_DEPT_NM: grid.getCellValue(rowid, 'BUDGET_DEPT_NM'),
                        ACCOUNT_CD: grid.getCellValue(rowid, 'ACCOUNT_CD'),
                        ACCOUNT_NM: grid.getCellValue(rowid, 'ACCOUNT_NM'),
                        RECIPIENT_NM: grid.getCellValue(rowid, 'RECIPIENT_NM'),
                        RECIPIENT_DEPT_NM: grid.getCellValue(rowid, 'RECIPIENT_DEPT_NM'),
                        RECIPIENT_TEL_NO: grid.getCellValue(rowid, 'RECIPIENT_TEL_NO'),
                        RECIPIENT_CELL_NO: grid.getCellValue(rowid, 'RECIPIENT_CELL_NO'),
                        DELY_ZIP_CD: grid.getCellValue(rowid, 'DELY_ZIP_CD'),
                        DELY_ADDR_1: grid.getCellValue(rowid, 'DELY_ADDR_1'),
                        DELY_ADDR_2: grid.getCellValue(rowid, 'DELY_ADDR_2'),
                        REQ_TXT: grid.getCellValue(rowid, 'REQ_TXT'),
                        callBackFunction: "setPoInfo",
                        detailView: false
                    };
                    everPopup.openModalPopup("/evermp/BNM1/BNM101/BNM1_020/view", 800, 450, param);
		    	}
            });

			grid.addRowEvent(function() {
                var rowId = grid.addRow([{
                	UNIT_CD: "EA",
                	CUR: "KRW",
                	AUTO_PO_FLAG: "0"
                }]);
            });

			grid.delRowEvent(function() {
				if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
				grid.delRow();
			});

			grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			grid.excelImportEvent({
                'append': false
            }, function (msg, code) {
                if (code) {
                    grid.checkAll(true);
                }
            });

			if("${ses.buyerApproveUseFlag}" == "1" || "${ses.buyerBudgetUseFlag}" == "1") {
                grid.setColReadOnly('AUTO_PO_FLAG', true);
            }
	    }

	    function setPoInfo(data) {
	    	grid.setCellValue(data.rowId, 'BUDGET_DEPT_CD', data.BUDGET_DEPT_CD);
	    	grid.setCellValue(data.rowId, 'BUDGET_DEPT_NM', data.BUDGET_DEPT_NM);
	    	grid.setCellValue(data.rowId, 'ACCOUNT_CD', data.ACCOUNT_CD);
	    	grid.setCellValue(data.rowId, 'ACCOUNT_NM', data.ACCOUNT_NM);
	    	grid.setCellValue(data.rowId, 'RECIPIENT_NM', data.RECIPIENT_NM);
	    	grid.setCellValue(data.rowId, 'RECIPIENT_DEPT_NM', data.RECIPIENT_DEPT_NM);
	    	grid.setCellValue(data.rowId, 'RECIPIENT_TEL_NO', data.RECIPIENT_TEL_NO);
	    	grid.setCellValue(data.rowId, 'RECIPIENT_CELL_NO', data.RECIPIENT_CELL_NO);
	    	grid.setCellValue(data.rowId, 'DELY_ZIP_CD', data.DELY_ZIP_CD);
	    	grid.setCellValue(data.rowId, 'DELY_ADDR_1', data.DELY_ADDR_1);
	    	grid.setCellValue(data.rowId, 'DELY_ADDR_2', data.DELY_ADDR_2);
	    	grid.setCellValue(data.rowId, 'REQ_TXT', data.REQ_TXT);
		}

	    function setItemRmk(data) {
	    	if(!EVF.isEmpty(data.message)) {
				grid.setCellValue(data.rowId, 'ITEM_RMK', data.message);
	    	}
		}

	    function setRfqReqTxt(data) {
	    	if(!EVF.isEmpty(data.message)) {
				grid.setCellValue(data.rowId, 'REQ_TXT', data.message);
	    	}
		}

	    function setImageUuid(rowId, uuid, fileCount) {
	    	if(fileCount > 0) {
				grid.setCellValue(rowId, 'IMAGE_UUID', uuid);
	            grid.setCellValue(rowId, 'IMAGE_UUID_IMG', 'Y');
	    	}
		}

	    function setAttachFileNo(rowId, uuid, fileCount) {
	    	if(fileCount > 0) {
				grid.setCellValue(rowId, 'ATTACH_FILE_NO', uuid);
	            grid.setCellValue(rowId, 'ATTACH_FILE_NO_IMG', 'Y');
	    	}
		}

	    function doRequest() {

	    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var store = new EVF.Store();

            if(!store.validate()) { return;}
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {

				if (grid.getCellValue(rowIds[i], 'AUTO_PO_FLAG') == '1') {
					if (grid.getCellValue(rowIds[i], 'HOPE_DUE_DATE') == ''||grid.getCellValue(rowIds[i],'EST_PO_QTY') == 0
					) {
						return alert('${BNM1_010_ALERT1 }');
					}
					if (
						grid.getCellValue(rowIds[i],'RECIPIENT_NM') == ''
						||grid.getCellValue(rowIds[i],'RECIPIENT_DEPT_NM') == ''
						||grid.getCellValue(rowIds[i],'RECIPIENT_TEL_NO') == ''
						||grid.getCellValue(rowIds[i],'RECIPIENT_CELL_NO') == ''
						||grid.getCellValue(rowIds[i],'DELY_ZIP_CD') == ''
						||grid.getCellValue(rowIds[i],'EST_PO_QT') == ''
					) {
						return alert('${BNM1_010_ALERT2 }');
					}
				}
			}

            if(!confirm('${BNM1_010_CONFIRM1}')) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.doFileUpload(function() {
                store.load(baseUrl + 'bnm1010_doSave', function() {
                    alert(this.getResponseMessage());
                        location.href=baseUrl+'BNM1_010/view';
                });
			});
	    }

	    function doCopy() {

	    	if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

	    	if (grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

			if (!confirm("${BNM1_010_CONFIRM2}")) return;

			var budgetDeptCd = "";
			var budgetDeptNm = "";
			var accountCd = "";
			var accountNm = "";
			var recipientNm = "";
			var recipientDeptNm = "";
			var recipientTelNo = "";
			var recipientCellNo = "";
			var delyZipCd = "";
			var delyAddr1 = "";
			var delyAddr2 = "";
			var reqTxt = "";
			var autoPoFlag = "";
			var autoPoFlagZ = "";

			var rowIds = grid.getSelRowId();
	    	for(var i in rowIds) {
	    		budgetDeptCd = grid.getCellValue(rowIds[i], 'BUDGET_DEPT_CD');
	    		budgetDeptNm = grid.getCellValue(rowIds[i], 'BUDGET_DEPT_NM');
	    		accountCd = grid.getCellValue(rowIds[i], 'ACCOUNT_CD');
	    		accountNm = grid.getCellValue(rowIds[i], 'ACCOUNT_NM');
	    		recipientNm = grid.getCellValue(rowIds[i], 'RECIPIENT_NM');
	    		recipientDeptNm = grid.getCellValue(rowIds[i], 'RECIPIENT_DEPT_NM');
	    		recipientTelNo = grid.getCellValue(rowIds[i], 'RECIPIENT_TEL_NO');
	    		recipientCellNo = grid.getCellValue(rowIds[i], 'RECIPIENT_CELL_NO');
	    		delyZipCd = grid.getCellValue(rowIds[i], 'DELY_ZIP_CD');
	    		delyAddr1 = grid.getCellValue(rowIds[i], 'DELY_ADDR_1');
	    		delyAddr2 = grid.getCellValue(rowIds[i], 'DELY_ADDR_2');
	    		reqTxt = grid.getCellValue(rowIds[i], 'REQ_TXT');
	    		autoPoFlag = grid.getCellValue(rowIds[i], 'AUTO_PO_FLAG');
	    		autoPoFlagZ = grid.getCellValue(rowIds[i], 'AUTO_PO_FLAG_Z');
    		}
	    	var aRowIds = grid.getAllRowId();
	    	for(var i in aRowIds) {
	    		grid.setCellValue(aRowIds[i], 'BUDGET_DEPT_CD', budgetDeptCd);
	    		grid.setCellValue(aRowIds[i], 'BUDGET_DEPT_NM', budgetDeptNm);
	    		grid.setCellValue(aRowIds[i], 'ACCOUNT_CD', accountCd);
	    		grid.setCellValue(aRowIds[i], 'ACCOUNT_NM', accountNm);
	    		grid.setCellValue(aRowIds[i], 'RECIPIENT_NM', recipientNm);
	    		grid.setCellValue(aRowIds[i], 'RECIPIENT_DEPT_NM', recipientDeptNm);
	    		grid.setCellValue(aRowIds[i], 'RECIPIENT_TEL_NO', recipientTelNo);
	    		grid.setCellValue(aRowIds[i], 'RECIPIENT_CELL_NO', recipientCellNo);
	    		grid.setCellValue(aRowIds[i], 'DELY_ZIP_CD', delyZipCd);
	    		grid.setCellValue(aRowIds[i], 'DELY_ADDR_1', delyAddr1);
	    		grid.setCellValue(aRowIds[i], 'DELY_ADDR_2', delyAddr2);
	    		grid.setCellValue(aRowIds[i], 'REQ_TXT', reqTxt);
	    		grid.setCellValue(aRowIds[i], 'AUTO_PO_FLAG', autoPoFlag);
	    		grid.setCellValue(aRowIds[i], 'AUTO_PO_FLAG_Z', autoPoFlagZ);
    		}
	    }

	    function doRegistration() {

	    	var param = {
	    		CUST_CD : "${ses.companyCd}",
	    		ITEM_REQ_NO : "",
	    		ITEM_REQ_SEQ : "",
	    		'detailView': false,
	    		'popupFlag': true
			};
            everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
	    }

		<%--
	    function doRequest() {

	    	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
	    	if (!grid.validate().flag) { return alert(grid.validate().msg); }

            var store = new EVF.Store();
            if(store.validate()) {

                var param = {
                    subject: '${E99_007_0005}',
                    docType: "PCS",
                    signStatus: "P",
                    screenId: "E99_007",
                    approvalType: 'APPROVAL',
                    oldApprovalFlag: EVF.V('SIGN_STATUS'),
                    attFileNum: EVF.C('ATT_FILE_NUM'),
                    docNum: EVF.V('PP_NO'),
                    appDocNum: EVF.V('APP_DOC_NUM'),
                    /* 신세계 전용 : 미리 지정한 전결라인에서 결재라인을 가져오기 위해 값을 셋팅한다.
                    bizCls1: "",
                    bizCls2: "",
                    bizCls3: "",
                    bizAmt: EVF.V('EX_AMT'), */
                    callBackFunction: "goApproval"
                };
                everPopup.openApprovalRequestIIPopup(param);
            }
        }

        function goApproval(formData, gridData, attachData) {

            EVF.C('approvalFormData').setValue(formData);
            EVF.C('approvalGridData').setValue(gridData);
            EVF.C('attachFileDatas').setValue(attachData);

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.doFileUpload(function() {
                store.load(baseUrl + 'e99007_doApproval', function(){
                    alert(this.getResponseMessage());
                    if(opener) {
                        opener['doSearch']();
                        EVF.closeWindow();
                    } else {
                        location.href='/siis/E99/E99_006/view';
					}
                });
            });
        }
		--%>

    </script>
	<e:window id="BNM1_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:buttonBar align="right" width="100%">
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
			<%-- e:button id="doCopy" name="doCopy" label="${doCopy_N}" onClick="doCopy" disabled="${doCopy_D}" visible="${doCopy_V}"/ --%>
			<e:button id="doRegistration" name="doRegistration" label="${doRegistration_N}" onClick="doRegistration" disabled="${doRegistration_D}" visible="${doRegistration_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>