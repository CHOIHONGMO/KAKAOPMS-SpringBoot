<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<e:ui>

	<script type="text/javascript">

		var grid = {};
		var baseUrl = "/evermp/buyer/cont/";
		var selRow;
		var gwUseFlag = 'N';   <%-- GW 결재여부--%>
		var pdfPath = "${pdfPath}";

		function init() {

			grid = EVF.C("grid");
			grid.setProperty('panelVisible', ${panelVisible});

			grid.cellClickEvent(function (rowId, colId, value) {

				selRow = rowId;
				var contUserId = grid.getCellValue(rowId, 'CONT_USER_ID');
				//var ctrlUserId = grid.getCellValue(rowId, 'CTRL_USER_ID');
				var grantedAuthCd = "PF0110";

				switch (colId) {
					case 'CONT_NUM':
					var bundleNum = grid.getCellValue(rowId, 'BUNDLE_NUM');
					var searchType = grid.getCellValue(rowId, 'SEARCH_TYPE');
                        var url = '/evermp/buyer/cont/CT0210/view';
                        var params = {
                            callBackFunction: 'doSearch',
							bundleNum: grid.getCellValue(rowId, "BUNDLE_NUM"),
//							contNum: (searchType == "EACH" ? grid.getCellValue(rowId, "CONT_NUM") : ''),
//							contCnt: (searchType == "EACH" ? grid.getCellValue(rowId, "CONT_CNT") : ''),


							contNum  : grid.getCellValue(rowId, "CONT_NUM"),
							contCnt  : grid.getCellValue(rowId, "CONT_CNT"),
                            vendorCd : grid.getCellValue(rowId, "VENDOR_CD")
						}
                        everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
					break;


					case 'CONT_NUM_OLD':
						var bundleNum = grid.getCellValue(rowId, 'BUNDLE_NUM');
						var searchType = grid.getCellValue(rowId, 'SEARCH_TYPE');
					    if(EVF.isEmpty(bundleNum) || bundleNum == "") {
                            everPopup.openContractChangeInformation({
                                callBackFunction: 'doSearch',
                                contNum: grid.getCellValue(rowId, "CONT_NUM"),
                                contCnt: grid.getCellValue(rowId, "CONT_CNT")
                            });
						} else {
//                            var url = '/eversrm/econtract/ECOB0040/view';
                            var url = '/evermp/buyer/cont/CT0210/view';
                            var params = {
                                callBackFunction: 'doSearch',
								bundleNum: grid.getCellValue(rowId, "BUNDLE_NUM"),
								contNum: (searchType == "EACH" ? grid.getCellValue(rowId, "CONT_NUM") : ''),
								contCnt: (searchType == "EACH" ? grid.getCellValue(rowId, "CONT_CNT") : ''),
                                vendorCd: (searchType == "EACH" ? grid.getCellValue(rowId, "VENDOR_CD") : '')
							}
                            everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
						}
						break;

					case 'VENDOR_CD':
					    if(value != '') {
					    	var param = {
			                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
			                        'detailView': true
			                    };
			                    everPopup.openPopupByScreenId("VD0120P01", 1100, 900, param); //협력업체 상세page
						}
						break;

                    case 'CANCEL_REASON':
                        if(value != '') {
							var param = {
								title: "${CT0220_0026}",
								message: grid.getCellValue(rowId, 'CANCEL_REASON'),
								callbackFunction: '',
								detailView: true
							};
							everPopup.commonTextInput(param);
                        }
                        break;

					default:
						return;
				}
			});

			grid.excelExportEvent({
				allCol: "${excelExport.allCol}",
				selRow: "${excelExport.selRow}",
				fileType: "${excelExport.fileType }",
				fileName: "${screenName }"
			});







            var values = $.map($('#PUR_ORG_CD option'), function(e) { return e.value; });
		    EVF.V('PUR_ORG_CD',values.join(','));

		    EVF.V('DATE_TYPE','02');




			doSearch();
		}

		function setContFileAttach(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'CONT_ATT_FILE_CNT', fileCnt);
			grid.setCellValue(rowId, 'CONT_ATT_FILE_NUM', fileId);

			doAddFileSave();
		}

		function setAdvFileAttach(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'ADV_ATT_FILE_CNT', fileCnt);
			grid.setCellValue(rowId, 'ADV_ATT_FILE_NUM', fileId);

			doAddFileSave();
		}

		function setWarrFileAttach(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'WARR_ATT_FILE_CNT', fileCnt);
			grid.setCellValue(rowId, 'WARR_ATT_FILE_NUM', fileId);

			doAddFileSave();
		}

        function setEtcFileAttach(rowId, fileId, fileCnt) {
            grid.setCellValue(rowId, 'ETC_ATT_FILE_CNT', fileCnt);
            grid.setCellValue(rowId, 'ETC_ATT_FILE_NUM', fileId);

			doAddFileSave();
        }

		function doChangeContUser() {

			if(EVF.isEmpty(EVF.V("NEW_CTRL_USER_ID"))) {
				return EVF.alert("${CT0220_0014}");
			}

			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

			var rowIds = grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
				if (grid.getCellValue(rowIds[i], 'CONT_USER_ID') != '${ses.userId}') {
					return EVF.alert("${CT0220_0015}");
				}
			}

			EVF.confirm("${CT0220_0012 }", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.setParameter("CONT_USER_ID", EVF.V("NEW_CTRL_USER_ID"));
				store.load(baseUrl+'/CT0220/doChangeContUser', function() {
					EVF.alert(this.getResponseMessage(), function() {
						doSearch();
					});
				});
			});
		}

		function doSearch() {

			var store = new EVF.Store();
			if (!store.validate()) { return; }

			if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }'))
				return EVF.alert('${msg.M0073}');

			store.setGrid([grid]);
			store.setParameter("authFlag", (${authFlag} ? "true" : "false"));
			store.load(baseUrl + '/CT0220/doSearch', function () {
				if (grid.getRowCount() == 0) {
					EVF.alert("${msg.M0002 }");
				}
			});
		}



		function getVendorCd() {
			everPopup.openCommonPopup({
				callBackFunction: "setVendorCd"
			}, 'SP0063');
		}

		function setVendorCd(data) {
			EVF.V("VENDOR_CD", data.VENDOR_CD);
			EVF.V("VENDOR_NM", data.VENDOR_NM);
		}

		function cleanVendorCd() {
			EVF.V("VENDOR_CD", "");
		}

		function getContUser() {
			var param = {
				callBackFunction: "setContUser",
				GATE_CD: '${ses.gateCd}',
				BUYER_CD: "${ses.companyCd}"
			};
			everPopup.openCommonPopup(param, 'SP0040');
		}

		function setContUser(data) {
			EVF.V("USER_ID", data.CTRL_USER_ID);
			EVF.V("USER_NM", data.CTRL_USER_NM);
		}

		function cleanUserInfo() {
			EVF.V("USER_ID", "");
		}

		function getNewCtrlUserId() {
			var param = {
				callBackFunction: "setNewContUser",
				GATE_CD: '${ses.gateCd}',
				BUYER_CD: "${ses.companyCd}"
			};
			everPopup.openCommonPopup(param, 'SP0001');
		}

		function setNewContUser(data) {
			EVF.V("NEW_CTRL_USER_ID", data.USER_ID);
			EVF.V("NEW_CTRL_USER_NM", data.USER_NM);
		}




		function doModify() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];


			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');
			var signStatus = grid.getCellValue(rowId,'SIGN_STATUS'); // 계약서
			if (signStatus == "P" || signStatus == "E") {
				if (progressCd!=4210) {
					return alert("${msg.M0044}");

				}
			}

			var bundleNum = grid.getCellValue(rowId, 'BUNDLE_NUM');
			var searchType = grid.getCellValue(rowId, 'SEARCH_TYPE');
                var url = '/evermp/buyer/cont/CT0210/view';
                var params = {
                    callBackFunction: 'doSearch',
					//bundleNum: grid.getCellValue(rowId, "BUNDLE_NUM"),
					contNum: grid.getCellValue(rowId, "CONT_NUM"),
					contCnt: grid.getCellValue(rowId, "CONT_CNT"),
                    vendorCd: grid.getCellValue(rowId, "VENDOR_CD"),
					detailView: false
				}
                everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');

		}



		function doModCont() {
	            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }
	            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

	            var selRowId = grid.getSelRowId();
	            var paramContNum; var paramContCnt;
	            var paramBundleNum;
	            for(var i in selRowId) {
	                if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
	                    return EVF.alert("${CT0220_0027}");
	                }
	                if (grid.getCellValue(selRowId[i], "NEXT_CONT_CNT_FLAG") == "Y") {
	                    return EVF.alert("${CT0220_0031}");
	                }
	                paramContNum = grid.getCellValue(selRowId[i], "CONT_NUM");
	                paramContCnt = grid.getCellValue(selRowId[i], "CONT_CNT");
					paramBundleNum = grid.getCellValue(selRowId[i], "BUNDLE_NUM");
					paramVendorCd = grid.getCellValue(selRowId[i], "VENDOR_CD");
	            }

				if(EVF.isEmpty(paramBundleNum) || paramBundleNum == "") {
	                var url = '/evermp/buyer/cont/CT0210/view';
	                var params = {
	                    callBackFunction: 'doSearch',
						//bundleNum: paramBundleNum,
						contNum: paramContNum,
						contCnt: paramContCnt,
	                    vendorCd: paramVendorCd,
	                    resumeFlag : true,
						detailView: false
					}
	                everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
	            } else {
	                var url = '/evermp/buyer/cont/CT0210/view';
	                var params = {
		                    callBackFunction: 'doSearch',
							bundleNum: paramBundleNum,
							contNum: paramContNum,
							contCnt: paramContCnt,
		                    vendorCd: paramVendorCd,
		                    resumeFlag : true,
							detailView: false
						}
	                everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');







	            	return;
	            	var url = '/eversrm/econtract/ECOB0040/view';
	                var params = {
	                    callBackFunction: 'doSearch',
	                    bundleNum: paramBundleNum,
	                    contNum: paramContNum,
	                    contCnt: paramContCnt,
						resumeFlag: "true"
	                }
	                everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
	            }
	        }

		function doVendorConsult() {
			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return alert("${msg.M0006}");
	        }
	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];
			var param = {
	        	BUYER_CD : grid.getCellValue(rowId,'BUYER_CD'),
				CONT_NUM : grid.getCellValue(rowId,'CONT_NUM'),
				PO_NUM : grid.getCellValue(rowId,'PO_NUM'),
				VENDOR_CD : grid.getCellValue(rowId,'VENDOR_CD'),
				VENDOR_NM : grid.getCellValue(rowId,'VENDOR_NM'),
				detailView : false
		    };
		    everPopup.openPopupByScreenId("PO0130P03", 1200, 750, param);

		}






	</script>

	<e:window id="CT0220" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id="DEPT_CD" name="DEPT_CD" />
			<e:inputHidden id="CONTRACT_FORM_TYPE" name="CONTRACT_FORM_TYPE" />

			<e:inputHidden id="USER_ID" name="USER_ID" />



			<e:row>
				<%--구매운영조직코드--%>
				<e:label for="PUR_ORG_CD" title="${form_PUR_ORG_CD_N}"/>
				<e:field>
				<e:select id="PUR_ORG_CD" name="PUR_ORG_CD" value="" options="${purOrgCdOptions}" width="${form_PUR_ORG_CD_W}" disabled="${form_PUR_ORG_CD_D}" readOnly="${form_PUR_ORG_CD_RO}" required="${form_PUR_ORG_CD_R}" useMultipleSelect="true" usePlaceHolder="false"/>
				</e:field>
				<e:label for="CONT_NUM" title="${form_CONT_NUM_N}"/>
				<e:field>
					<e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
					<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="getVendorCd" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onKeyDown="cleanVendorCd" />
					<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DATE_TYPE">
					<e:select id="DATE_TYPE" name="DATE_TYPE" value="" options="${dateTypeOptions}" readOnly="${form_DATE_TYPE_RO }" width="99" required="${form_DATE_TYPE_R }" disabled="${form_DATE_TYPE_D }"  usePlaceHolder="false">
						<e:option text="접수일자" value="01">접수일자</e:option>
						<e:option text="계약종료일자" value="02">계약종료일자</e:option>
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>
				<%--결재상태--%>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
				<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N }" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${PROGRESS_CD_Options}" readOnly="${form_PROGRESS_CD_RO }" width="100%" required="${form_PROGRESS_CD_R }" disabled="${form_PROGRESS_CD_D }" useMultipleSelect="true" />
				</e:field>
			</e:row>
			<e:row>
				<%--유효여부--%>
				<e:label for="EXPIRE_YN" title="${form_EXPIRE_YN_N}"/>
				<e:field>
				<e:select id="EXPIRE_YN" name="EXPIRE_YN" value="" options="${expireYnOptions}" width="${form_EXPIRE_YN_W}" disabled="${form_EXPIRE_YN_D}" readOnly="${form_EXPIRE_YN_RO}" required="${form_EXPIRE_YN_R}" placeHolder="" />
				</e:field>
				<%--업체접수상태--%>
				<e:label for="RECEIPT_YN" title="${form_RECEIPT_YN_N}"/>
				<e:field colSpan="3">
				<e:select id="RECEIPT_YN" name="RECEIPT_YN" value="" options="${receiptYnOptions}" width="${form_RECEIPT_YN_W}" disabled="${form_RECEIPT_YN_D}" readOnly="${form_RECEIPT_YN_RO}" required="${form_RECEIPT_YN_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N }" onClick="doSearch" disabled="${doSearch_D }" visible="${doSearch_V}"/>
			<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
			<e:button id="doModCont" name="doModCont" label="${doModCont_N}" onClick="doModCont" disabled="${doModCont_D}" visible="${doModCont_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
