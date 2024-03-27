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

			grid.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${screenName }"
			});

			grid.cellClickEvent(function (rowId, colId, value) {

				selRow = rowId;
				var contUserId = grid.getCellValue(rowId, 'CONT_USER_ID');
				//var ctrlUserId = grid.getCellValue(rowId, 'CTRL_USER_ID');
				var grantedAuthCd = "PF0110";

				switch (colId) {
					case 'CONT_NUM':
						var bundleNum = grid.getCellValue(rowId, 'BUNDLE_NUM');
						var searchType = grid.getCellValue(rowId, 'SEARCH_TYPE');
					    if(EVF.isEmpty(bundleNum) || bundleNum == "") {
                            everPopup.openContractChangeInformation({
                                callBackFunction: 'doSearch',
                                contNum: grid.getCellValue(rowId, "CONT_NUM"),
                                contCnt: grid.getCellValue(rowId, "CONT_CNT")
                            });
						} else {
                            var url = '/eversrm/econtract/ECOB0040/view';
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
								title: "${CT0330_0026}",
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







            var values = $.map($('#BUYER_CD option'), function(e) { return e.value; });
		    EVF.V('BUYER_CD',values.join(','));

			// DashBoard 통해서 들어왔을 경우 파라미터 셋팅
			if ('${param.dashBoardFlag}' == 'Y') {
				EVF.V('REG_DATE_FROM', '${param.FROM_DATE}');
				EVF.V('REG_DATE_TO', '${param.TO_DATE}');
			}
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
				return EVF.alert("${CT0330_0014}");
			}

			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

			var rowIds = grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
				if (grid.getCellValue(rowIds[i], 'CONT_USER_ID') != '${ses.userId}') {
					return EVF.alert("${CT0330_0015}");
				}
			}

			EVF.confirm("${CT0330_0012 }", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.setParameter("CONT_USER_ID", EVF.V("NEW_CTRL_USER_ID"));
				store.load(baseUrl+'/CT0330/doChangeContUser', function() {
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
			store.load(baseUrl + '/CT0330/doSearch', function () {
				if (grid.getRowCount() == 0) {
					EVF.alert("${msg.M0002 }");
				}
				grid.setColIconify("CANCEL_REASON", "CANCEL_REASON", "comment", false);
			});
		}

		function doPrint() {

			var gridData = grid.getSelRowValue();
			if (gridData.length == 0) { return EVF.alert('${msg.M0004 }'); }
			if (gridData.length > 1) { return EVF.alert("${msg.M0006}"); }

			var url = pdfPath + gridData[0]['CONT_NUM'] + "@" + gridData[0]['CONT_CNT'] + ".pdf";
			everPopup.createWindowPopup(url, "800", "1132", null, "viewPDF", true);

			<%--
			var param = {
				contNum: gridData[0]['CONT_NUM'],
				contCnt: gridData[0]['CONT_CNT'],
				callBackFunction: ''
			};

			var ie_flag = (navigator.appName == 'Microsoft Internet Explorer') || ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null));
			if (!ie_flag) {
				EVF.alert("${CT0330_0009}"); // Internet Explorer 에서 출력하시면 최적으로 출력이 됩니다.
			}
			everPopup.openPopupByScreenId('ECOA0070', 1000, 800, param);
			--%>
		}

		function doCopy() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

			EVF.confirm("${CT0330_0016 }", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl+'/CT0330/doCopy', function() {

					var contNum = this.getParameter("newContNum");
					var contCnt = this.getParameter("newContCnt");

					EVF.alert(this.getResponseMessage(), function() {
						doSearch();
						everPopup.openContractChangeInformation({
							callBackFunction: 'doSearch',
							contNum: contNum,
							contCnt: contCnt
						});
					});
				});
			});
		}

        function doResume() {

            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

            var selRowId = grid.getSelRowId();
            var paramContNum; var paramContCnt;
            var paramBundleNum;
            for(var i in selRowId) {
                if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
                    return EVF.alert("${CT0330_0027}");
                }
                if (grid.getCellValue(selRowId[i], "NEXT_CONT_CNT_FLAG") == "Y") {
                    return EVF.alert("${CT0330_0031}");
                }
                paramContNum = grid.getCellValue(selRowId[i], "CONT_NUM");
                paramContCnt = grid.getCellValue(selRowId[i], "CONT_CNT");
				paramBundleNum = grid.getCellValue(selRowId[i], "BUNDLE_NUM");
            }

			if(EVF.isEmpty(paramBundleNum) || paramBundleNum == "") {
                everPopup.openContractChangeInformation({
                    callBackFunction: 'doSearch',
                    contNum: paramContNum,
                    contCnt: paramContCnt,
                    openFormType : 'A', // 단가계약
                    resumeFlag: "true"
                });
            } else {
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

		var cancelRowId;
		function doCancelCont() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

			var selRowId = grid.getSelRowId();
			for(var i in selRowId) {
				if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
					return EVF.alert("${CT0330_0018}");
				}
				cancelRowId = selRowId[i];
			}

			EVF.confirm("${CT0330_0020 }", function () {
				var param = {
					title: "${CT0330_0026}",
					message: grid.getCellValue(cancelRowId, 'CANCEL_REASON'),
					callbackFunction: 'doCancel',
					detailView: false
				};
				everPopup.commonTextInput(param);
			});
		}

		function doCancel(data) {

			if(EVF.isEmpty(data.message) || data == undefined || data == null) {
				return EVF.alert("${CT0330_0025}");
			}
			grid.setCellValue(cancelRowId, 'CANCEL_REASON', data.message);

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/CT0330/doCancelCont', function() {
				EVF.alert(this.getResponseMessage(), function() {
					doSearch();
				});
			});
		}

		function doRemoveCont() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			var selRowId = grid.getSelRowId();
			for(var i in selRowId) {
				if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
					return EVF.alert("${CT0330_0019}");
				}
				cancelRowId = selRowId[i];
			}

			EVF.confirm("${CT0330_0021 }", function () {
				var param = {
					title: "${CT0330_0026}",
					message: grid.getCellValue(cancelRowId, 'CANCEL_REASON'),
					callbackFunction: 'doRemove',
					detailView: false
				};
				everPopup.commonTextInput(param);
			});
		}

		function doRemove(data) {

			if(EVF.isEmpty(data.message) || data == undefined || data == null) {
				return EVF.alert("${CT0330_0025}");
			}
			grid.setCellValue(cancelRowId, 'CANCEL_REASON', data.message);

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/CT0330/doRemoveCont', function() {
				EVF.alert(this.getResponseMessage(), function() {
					doSearch();
				});
			});
		}

		function doDelMapping() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			var selRowId = grid.getSelRowId();
			for(var i in selRowId) {
				if (EVF.isEmpty(grid.getCellValue(selRowId[i], "PURC_CONT_NUM"))) {
					return EVF.alert("${CT0330_0028}");
				}
			}

            EVF.confirm("${CT0330_0029 }", function () {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl+'/CT0330/doDelMapping', function() {
                    EVF.alert(this.getResponseMessage(), function() {
                        doSearch();
                    });
                });
            });
		}

		function doSave() {

			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

			<%--if(valid.notEqualColValid(grid, "CONT_USER_ID", '${ses.userId}') && valid.notEqualColValid(grid, "CTRL_USER_ID", '${ses.userId}')) {--%>
				<%--return EVF.alert("${msg.M0008 }");--%>
			<%--}--%>

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                var rowId = selRowId[i];
                if (grid.getCellValue(rowId, "GUR_CNT") =="0" && grid.getCellValue(rowId, "GUR_FIN_CNT") =="0") {
                    return EVF.alert("${CT0330_0010}");
                }
            }

			var store = new EVF.Store();
			if(!confirm('${msg.M0021}')) { return; }

			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/CT0330/doSave', function() {
				EVF.alert(this.getResponseMessage(), function() {
					doSearch();
				});
			});
		}

        function doAttSave() {

            if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

            <%--if(valid.notEqualColValid(grid, "CONT_USER_ID", '${ses.userId}') && valid.notEqualColValid(grid, "CTRL_USER_ID", '${ses.userId}')) {--%>
                <%--return EVF.alert("${msg.M0008 }");--%>
            <%--}--%>

            var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                var rowId = selRowId[i];
                if (grid.getCellValue(rowId, "ETC_ATT_FILE_CNT") =="0" ) {
                    return EVF.alert("${CT0330_0011}");
                }
            }

            var store = new EVF.Store();
            if(!confirm('${msg.M0021}')) { return; }

            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl+'/CT0330/doAttSave', function() {
				EVF.alert(this.getResponseMessage(), function() {
					doSearch();
				});
            });
        }

		function doAddFileSave() {

			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

			var store = new EVF.Store();

			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/CT0330/doAddFileSave', function() {
				EVF.alert(this.getResponseMessage(), function() {
					//doSearch();
				});
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
				callBackFunction: "setContUser"
			};
			everPopup.openCommonPopup(param, 'SP0508');
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

			var stype = grid.getCellValue(rowId,'STYPE');
			var poNum = grid.getCellValue(rowId,'PO_NUM');
			var signStatus = grid.getCellValue(rowId,'SIGN_STATUS'); // 계약서

			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');


			if (signStatus == "P" || signStatus == "E") {
				if (progressCd!=4210) {
					return alert("${msg.M0044}");

				}
			}
			var param = {
                     contNum: grid.getCellValue(rowId, "CONT_NUM")
                    ,contCnt: grid.getCellValue(rowId, "CONT_CNT")
                    ,detailView : false
		    };
		    everPopup.openPopupByScreenId('CT0320', 1200, 1000, param);

		}




	</script>

	<e:window id="CT0330" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id="DEPT_CD" name="DEPT_CD" />
			<e:inputHidden id="CONTRACT_FORM_TYPE" name="CONTRACT_FORM_TYPE" />
			<e:row>

				<%--구매요청회사--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
				<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" usePlaceHolder="false" useMultipleSelect="true"/>
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
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${not empty param.FROM_DATE ? param.FROM_DATE : fromDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${not empty param.TO_DATE ? param.TO_DATE : toDate}" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
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
				<%--업체접수상태--%>
				<e:label for="RECEIPT_YN" title="${form_RECEIPT_YN_N}"/>
				<e:field>
				<e:select id="RECEIPT_YN" name="RECEIPT_YN" value="" options="${receiptYnOptions}" width="${form_RECEIPT_YN_W}" disabled="${form_RECEIPT_YN_D}" readOnly="${form_RECEIPT_YN_RO}" required="${form_RECEIPT_YN_R}" placeHolder="" />
				</e:field>
				<%--유효여부--%>
				<e:label for="EXPIRE_YN" title="${form_EXPIRE_YN_N}"/>
				<e:field>
				<e:select id="EXPIRE_YN" name="EXPIRE_YN" value="" options="${expireYnOptions}" width="${form_EXPIRE_YN_W}" disabled="${form_EXPIRE_YN_D}" readOnly="${form_EXPIRE_YN_RO}" required="${form_EXPIRE_YN_R}" placeHolder="" />
				</e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N }" />
				<e:field>
					<e:search id="USER_NM" style="ime-mode:active;" name="USER_NM" width="100%" maxLength="${form_USER_NM_M }" required="${form_USER_NM_R }" disabled="${form_USER_NM_D }" readOnly="${form_USER_NM_RO }" value="${!authFlag ? ses.userNm : null}" onIconClick="getContUser" onKeyDown="cleanUserInfo" />
					<e:inputHidden id="USER_ID" name="USER_ID" value="${!authFlag ? ses.userId : null}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
			<e:button id="doResume" name="doResume" label="${doResume_N}" disabled="${doResume_D}" visible="${authFlag ? doResume_V : false}" onClick="doResume" />
			<e:button id="doCancelCont" name="doCancelCont" label="${doCancelCont_N}" disabled="${doCancelCont_D}" visible="${authFlag ? doCancelCont_V : false}" onClick="doCancelCont" />
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
