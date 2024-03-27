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
			EVF.V("DEL_FLAG","0");
			$("#ui-multiselect-DEL_FLAG-option-0").parent().parent().remove()
			grid.cellClickEvent(function (rowId, colId, value) {

				selRow = rowId;
				var contUserId = grid.getCellValue(rowId, 'CONT_USER_ID');
				//var ctrlUserId = grid.getCellValue(rowId, 'CTRL_USER_ID');
				var grantedAuthCd = "PF0110";
				if (colId == 'CONT_NUM') {
					var bundleNum = grid.getCellValue(rowId, 'BUNDLE_NUM');
					var searchType = grid.getCellValue(rowId, 'SEARCH_TYPE');
                    everPopup.openContractChangeInformation({
                        callBackFunction : 'doSearch',
                        contNum	  		 : grid.getCellValue(rowId, "CONT_NUM"),
                        contCnt	  		 : grid.getCellValue(rowId, "CONT_CNT"),
                        APAR_TYPE 		 : grid.getCellValue(rowId, "APAR_TYPE"),
                        contractFormType :  grid.getCellValue(rowId, "CONTRACT_FORM_TYPE"),
                        detailView : true
                    });

				} else if (colId == 'CANCEL_REASON') {
					if(value != '') {
						var param = {
							title			 : "${CT0520_0026}",
							message			 : grid.getCellValue(rowId, 'CANCEL_REASON'),
							callbackFunction : '',
							detailView		 : true
						};
						everPopup.commonTextInput(param);
                    }
				} else if(colId == 'CONT_COMMIT_FLAG' || colId == 'ADV_COMMIT_FLAG' || colId == 'WARR_COMMIT_FLAG'){
             		var param = {
             			rowId			 : rowId,
             			CONT_NUM 		 : grid.getCellValue(rowId, "CONT_NUM"),
             			CONT_CNT 		 : grid.getCellValue(rowId, "CONT_CNT"),
            			callBackFunction : "selectApply"
            		};
           			everPopup.openPopupByScreenId('CT0620P01', 1600, 530, param);
             	}else if(colId == 'CONT_ATT_FILE_CNT'){
             		var param = {
               			  detailView		: true
						, attFileNum		: grid.getCellValue(rowId, "CONT_ATT_FILE_NUM")
						, havePermission	: false
						, rowId				: rowId
						, callBackFunction	: "callback_setAttFile"
						, bizType			: "CT"
						, fileExtension		: "*"
               		};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
                 }else if(colId == 'ADV_ATT_FILE_CNT'){
              		var param = {
               			  detailView		: true
						, attFileNum		: grid.getCellValue(rowId, "ADV_ATT_FILE_NUM")
						, havePermission	: false
						, rowId				: rowId
						, callBackFunction	: "callback_setAttFile"
						, bizType			: "CT"
						, fileExtension		: "*"
              		};
           			everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
               }else if(colId == 'WARR_ATT_FILE_CNT'){
            		var param = {
              			  detailView		: true
						, attFileNum		: grid.getCellValue(rowId, "WARR_ATT_FILE_NUM")
						, havePermission	: false
						, rowId				: rowId
						, callBackFunction	: "callback_setAttFile"
						, bizType			: "CT"
						, fileExtension		: "*"
              		};
           			everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
               } else if(colId == 'ATT_FILE_CNT'){
					var param = {
						detailView		: true
						, attFileNum		: grid.getCellValue(rowId, "ATT_FILE_NUM")
						, havePermission	: false
						, rowId				: rowId
						, callBackFunction	: "callback_setAttFile"
						, bizType			: "CT"
						, fileExtension		: "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
			}
			});

			grid.excelExportEvent({
				allCol	 : "${excelExport.allCol}",
				selRow	 : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }"
			});


			// DashBoard 통해서 들어왔을 경우 파라미터 셋팅
			if ('${param.dashBoardFlag}' == 'Y') {
				EVF.V('REG_DATE_FROM' , '${param.FROM_DATE}');
				EVF.V('REG_DATE_TO'   , '${param.TO_DATE}');
			}
		    EVF.V('DATE_TYPE','03');

		 	// Column 그룹
		 	grid.setColGroup([{
                "groupName" : '계약보증증권',
                "columns"   : [ "CONT_GUAR_AMT","CONT_GUAR_PERCENT","CONT_INSU_BILL_FLAG","CONT_INSU_STATUS","CONT_INSU_NUM","CONT_COMMIT_FLAG","CONT_ATT_FILE_CNT","CONT_ATT_FILE_NUM" ]
            },{
                "groupName" : '선급보증증권',
                "columns"	: [ "ADV_GUAR_AMT","ADV_GUAR_PERCENT","ADV_INSU_BILL_FLAG","ADV_INSU_STATUS","ADV_INSU_NUM","ADV_COMMIT_FLAG","ADV_ATT_FILE_CNT","ADV_ATT_FILE_NUM" ]
            },{
                "groupName" : '하자보증증권',
                "columns"	: [ "WARR_GUAR_AMT","WARR_GUAR_PERCENT","WARR_INSU_BILL_FLAG","WARR_INSU_STATUS","WARR_INSU_NUM","WARR_COMMIT_FLAG","WARR_ATT_FILE_CNT","WARR_ATT_FILE_NUM" ]
            }],70);

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
				return EVF.alert("${CT0520_0014}");
			}

			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

			var rowIds = grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
				if (grid.getCellValue(rowIds[i], 'CONT_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
					return EVF.alert("${CT0520_0015}");
				}
			}

			EVF.confirm("${CT0520_0012 }", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.setParameter("CONT_USER_ID", EVF.V("NEW_CTRL_USER_ID"));
				store.load(baseUrl+'/CT0520/doChangeContUser', function() {
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
			store.load(baseUrl + '/CT0520/doSearch', function () {
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
				EVF.alert("${CT0520_0009}"); // Internet Explorer 에서 출력하시면 최적으로 출력이 됩니다.
			}
			everPopup.openPopupByScreenId('ECOA0070', 1000, 800, param);
			--%>
		}

		function doCopy() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

			EVF.confirm("${CT0520_0016 }", function () {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl+'/CT0520/doCopy', function() {

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
            var paramContNum;
            var paramContCnt;
            var paramBundleNum;
            for(var i in selRowId) {
                if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
                    return EVF.alert("${CT0520_0027}");
                }
                if (grid.getCellValue(selRowId[i], "DEL_FLAG") == "1") {
                    return EVF.alert("${CT0520_0034}");
                }
                if (grid.getCellValue(selRowId[i], "NEXT_CONT_CNT_FLAG") == "Y") {
                    return EVF.alert("${CT0520_0031}");
                }
                paramContNum 	= grid.getCellValue(selRowId[i], "CONT_NUM");
                paramContCnt 	= grid.getCellValue(selRowId[i], "CONT_CNT");
				paramBundleNum  = grid.getCellValue(selRowId[i], "BUNDLE_NUM");
            }

			if(EVF.isEmpty(paramBundleNum) || paramBundleNum == "") {
                everPopup.openContractChangeInformation({
                    callBackFunction : 'doSearch',
                    contNum			 : paramContNum,
                    contCnt			 : paramContCnt,
                    openFormType 	 : 'A', // 단가계약
                    resumeFlag		 : "true"
                });
            } else {
                var url = '/eversrm/econtract/ECOB0040/view';
                var params = {
                    callBackFunction : 'doSearch',
                    bundleNum		 : paramBundleNum,
                    contNum			 : paramContNum,
                    contCnt			 : paramContCnt,
					resumeFlag		 : "true"
                }
                everPopup.openWindowPopup(url, 1200, 950, params, 'openBundleContract');
            }
        }

		var cancelRowId;
		function doCancelCont() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

			var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];
			if (grid.getCellValue(rowId, "PROGRESS_CD") != "4300") {
				return EVF.alert("${CT0520_0018}");
			}
			if (grid.getCellValue(rowId, "DEL_FLAG") == "1") {
				return EVF.alert("${CT0520_0034}");
			}

			EVF.confirm("${CT0520_0020 }", function () {
				var param = {
		                 subject			: "[계약해지] "+grid.getCellValue(rowId, "CONT_DESC"),
		                 docType			: "CC",
		                 signStatus			: "P",
		                 screenId			: "CT0520",
		                 approvalType		: 'APPROVAL',
		                 oldApprovalFlag	: grid.getCellValue(rowId, "SIGN_STATUS2"),
		                 attFileNum			: "",
		                 docNum				: grid.getCellValue(rowId, "CONT_NUM"),
		                 appDocNum			: grid.getCellValue(rowId, "APP_DOC_NUM2"),
		                 callBackFunction	: "goApprovalExam"
					};
				everPopup.openApprovalRequestIIPopup(param);
			});
		}

	    function goApprovalExam(formData, gridData, attachData) {
			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

			var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];
			if (grid.getCellValue(rowId, "PROGRESS_CD") != "4300") {
				return EVF.alert("${CT0520_0018}");
			}
	       	EVF.V('approvalFormData', formData);
	        EVF.V('approvalGridData', gridData);
	        var store = new EVF.Store();
	        store.setGrid([grid]);
		    store.getGridData(grid, 'sel');
	        store.load(baseUrl + '/CT0520/doCancelCont', function() {
		        alert(this.getResponseMessage());
		        doSearch();
	        });
        }
// 		function doCancel(data) {

// 			if(EVF.isEmpty(data.message) || data == undefined || data == null) {
// 				return EVF.alert("${CT0520_0025}");
// 			}
// 			grid.setCellValue(cancelRowId, 'CANCEL_REASON', data.message);

// 			var store = new EVF.Store();
// 			store.setGrid([grid]);
// 			store.getGridData(grid, 'sel');
// 			store.load(baseUrl+'/CT0520/doCancelCont', function() {
// 				EVF.alert(this.getResponseMessage(), function() {
// 					doSearch();
// 				});
// 			});
// 		}

		function doRemoveCont() {

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			var selRowId = grid.getSelRowId();
			for(var i in selRowId) {
				if (grid.getCellValue(selRowId[i], "PROGRESS_CD") != "4300") {
					return EVF.alert("${CT0520_0019}");
				}
				cancelRowId = selRowId[i];
			}

			EVF.confirm("${CT0520_0021 }", function () {
				var param = {
					title			 : "${CT0520_0026}",
					message			 : grid.getCellValue(cancelRowId, 'CANCEL_REASON'),
					callbackFunction : 'doRemove',
					detailView		 : false
				};
				everPopup.commonTextInput(param);
			});
		}

		function doRemove(data) {

			if(EVF.isEmpty(data.message) || data == undefined || data == null) {
				return EVF.alert("${CT0520_0025}");
			}
			grid.setCellValue(cancelRowId, 'CANCEL_REASON', data.message);

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/CT0520/doRemoveCont', function() {
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
					return EVF.alert("${CT0520_0028}");
				}
			}

            EVF.confirm("${CT0520_0029 }", function () {
                var store = new EVF.Store();
                store.setGrid([grid]);
                store.getGridData(grid, 'sel');
                store.load(baseUrl+'/CT0520/doDelMapping', function() {
                    EVF.alert(this.getResponseMessage(), function() {
                        doSearch();
                    });
                });
            });
		}

		function doAddFileSave() {

			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }

			var store = new EVF.Store();

			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl+'/CT0520/doAddFileSave', function() {
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
				callBackFunction: "setContUser",
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
				callBackFunction : "setNewContUser",
				GATE_CD			 : '${ses.gateCd}',
				BUYER_CD		 : "${ses.companyCd}"
			};
			everPopup.openCommonPopup(param, 'SP0001');
		}

		function setNewContUser(data) {
			EVF.V("NEW_CTRL_USER_ID", data.USER_ID);
			EVF.V("NEW_CTRL_USER_NM", data.USER_NM);
		}

		function doModify() {

			if((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
	            return EVF.alert("${msg.M0004}");
	        }
	        if((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
	            return EVF.alert("${msg.M0006}");
	        }

	        var selRowId = grid.getSelRowId();
			var rowId = selRowId[0];
			if (grid.getCellValue(rowId, 'CONT_USER_ID') != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
            	return EVF.alert("${CT0520_0033}");
            }
			if (grid.getCellValue(rowId, 'DEL_FLAG') == "1") {
				return EVF.alert("${CT0520_0034}");
			}

			var stype = grid.getCellValue(rowId,'STYPE');
			var poNum = grid.getCellValue(rowId,'PO_NUM');
			var signStatus = grid.getCellValue(rowId,'SIGN_STATUS'); // 계약서
			var progressCd = grid.getCellValue(rowId,'PROGRESS_CD');
			var receiptYn  = grid.getCellValue(rowId,'RECEIPT_YN');

			if (signStatus == "P" || signStatus == "E") {
				if (progressCd!=4210 && progressCd!=4220 && (progressCd ==4200 && receiptYn == 1 )) {
					return EVF.alert("${msg.M0044}");

				}
			}
			var param = {
                     contNum		  : grid.getCellValue(rowId, "CONT_NUM")
                    ,contCnt	      : grid.getCellValue(rowId, "CONT_CNT")
                    ,APAR_TYPE		  : grid.getCellValue(rowId, "APAR_TYPE")
                    ,APAR_TYPE		  : grid.getCellValue(rowId, "APAR_TYPE")
                    ,CTRL_USER_ID	  : grid.getCellValue(rowId, "CTRL_USER_ID")
                    ,PR_BUYER_CD	  : grid.getCellValue(rowId, "PR_BUYER_CD")
                    ,PR_BUYER_NM	  : grid.getCellValue(rowId, "PR_BUYER_NM")
                    ,VENDOR_CD		  : grid.getCellValue(rowId, "VENDOR_CD")
                    ,VENDOR_NM		  : grid.getCellValue(rowId, "VENDOR_NM")
                    ,contractFormType : grid.getCellValue(rowId, "CONTRACT_FORM_TYPE")
                    ,detailView       : false
		    };
		    everPopup.openPopupByScreenId('CT0320', 1200, 1000, param);

		}

		//서명 버튼
		function doSign(){

			if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

			var selected = grid.getSelRowValue();
			for(var i in selected){
	            if (selected[i].CONT_USER_ID != '${ses.userId}' && '${ses.ctrlCd}'.indexOf('M100') < 0) {
	            	return EVF.alert("${CT0520_0033}");
	            }
				if (selected[i].PROGRESS_CD != "4220") {
					return EVF.alert("${CT0520_0032}");
				}
				if (selected[i].DEL_FLAG == "1") {
					return EVF.alert("${CT0520_0034}");
				}
			}
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid,'sel');
			store.setParameter("GUBN","CT0520");
			store.load('/evermp/buyer/cont/CT0320/doSign', function () {
                 EVF.alert(this.getResponseMessage(), function() {
                     doSearch();
                 });
             }, true);

		}

	</script>

	<e:window id="CT0520" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
			<e:inputHidden id="DEPT_CD" name="DEPT_CD" />
			<e:inputHidden id="CONTRACT_FORM_TYPE" name="CONTRACT_FORM_TYPE" />
			<e:inputHidden id="approvalFormData" name="approvalFormData"/>
			<e:inputHidden id="approvalGridData" name="approvalGridData"/>
			<e:row>
				<%--계약자(갑)--%>
				<e:label for="PR_BUYER_CD" title="${form_PR_BUYER_CD_N}"/>
				<e:field>
					<e:search id="PR_BUYER_CD" name="PR_BUYER_CD" width="40%" value=""  maxLength="${form_PR_BUYER_CD_M}" onIconClick="${form_PR_BUYER_CD_RO ? 'everCommon.blank' : 'selectBuyer'}" disabled="${form_PR_BUYER_CD_D}" readOnly="${form_PR_BUYER_CD_RO}" required="${form_PR_BUYER_CD_R}" />
					<e:inputText id="PR_BUYER_NM" name="PR_BUYER_NM" width="60%" value=""  maxLength="${form_PR_BUYER_NM_M}" disabled="${form_PR_BUYER_NM_D}" readOnly="${form_PR_BUYER_NM_RO}" required="${form_PR_BUYER_NM_R}" />
				</e:field>
				<%--계약자(을)--%>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'getVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<%--날짜검색--%>
				<e:label for="DATE_TYPE">
					<e:select id="DATE_TYPE" name="DATE_TYPE" value="" options="${dateTypeOptions}" readOnly="${form_DATE_TYPE_RO }" width="99" required="${form_DATE_TYPE_R }" disabled="${form_DATE_TYPE_D }"  usePlaceHolder="false">
						<e:option text="접수일자" value="01">접수일자</e:option>
						<e:option text="계약종료일자" value="02">계약종료일자</e:option>
						<e:option text="계약일자" value="03">계약일자</e:option>
					</e:select>
				</e:label>
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${not empty param.FROM_DATE ? param.FROM_DATE : fromDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${not empty param.TO_DATE ? param.TO_DATE : toDate}" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>

			</e:row>
			<e:row>
				<%--계약번호/명--%>
				<e:label for="CONT_NUM" title="${form_CONT_NUM_N}"/>
				<e:field>
					<e:inputText id="CONT_DESC" style="${imeMode}" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<%--결재상태--%>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
					<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N }" />
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" readOnly="${form_PROGRESS_CD_RO }" width="100%" required="${form_PROGRESS_CD_R }" disabled="${form_PROGRESS_CD_D }" useMultipleSelect="true" usePlaceHolder="false" placeHolder=""/>
				</e:field>
			</e:row>
			<e:row>
				<%--업체접수상태--%>
				<e:label for="RECEIPT_YN" title="${form_RECEIPT_YN_N}"/>
				<e:field>
				<e:select id="RECEIPT_YN" name="RECEIPT_YN" value="" options="${receiptYnOptions}" width="${form_RECEIPT_YN_W}" disabled="${form_RECEIPT_YN_D}" readOnly="${form_RECEIPT_YN_RO}" required="${form_RECEIPT_YN_R}" placeHolder="" />
				</e:field>
				<!-- 계약담당자 -->
				<e:label for="CONT_USER_ID" title="${form_CONT_USER_ID_N}"/>
				<e:field >
					<e:select id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId}" options="${contUserIdOptions}" width="${form_CONT_USER_ID_W}" disabled="${form_CONT_USER_ID_D}" readOnly="${form_CONT_USER_ID_RO}" required="${form_CONT_USER_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="DEL_FLAG" title="${form_DEL_FLAG_N}" />
				<e:field>
					<e:select id="DEL_FLAG" name="DEL_FLAG" value="" options="${delFlagOptions}" width="${form_DEL_FLAG_W}" disabled="${form_DEL_FLAG_D}" readOnly="${form_DEL_FLAG_RO}" required="${form_DEL_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}"/>
			<e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
			<e:button id="doResume" name="doResume" label="${doResume_N}" disabled="${doResume_D}" visible="${authFlag ? doResume_V : false}" onClick="doResume" />
			<e:button id="doCancelCont" name="doCancelCont" label="${doCancelCont_N}" disabled="${doCancelCont_D}" visible="${authFlag ? doCancelCont_V : false}" onClick="doCancelCont" />
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
