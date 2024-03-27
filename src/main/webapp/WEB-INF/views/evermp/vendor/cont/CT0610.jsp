<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui>
	<script type="text/javascript">

		var grid = {};
		var baseUrl = "/evermp/vendor/cont";
		var pdfPath = "${pdfPath}";

		function init() {

			EVF.C('PROGRESS_CD').removeOption('4100');	// 계약대기
			EVF.C('PROGRESS_CD').removeOption('4110');	// 계약작성중
			EVF.C('PROGRESS_CD').removeOption('4300');	// 계약완료

			<c:if test="${ses.userType =='B'}">
			  $("#doReceipt").hide();
			  $("#doReject").hide();
			</c:if>

			grid = EVF.C("grid");
			grid.setProperty('panelVisible', ${panelVisible});

			grid.cellClickEvent(function(rowId, colId, value) {
				switch (colId) {
					case 'CONT_NUM':
						var param = {
							callBackFunction : 'doSearch',
							GATE_CD : grid.getCellValue(rowId, "GATE_CD"),
							contNum : grid.getCellValue(rowId, "CONT_NUM"),
							contCnt : grid.getCellValue(rowId, "CONT_CNT"),
							baseDataType : 'manualContract',
							contractEditable : false,
							detailView : false
						};
						if (grid.getCellValue(rowId, "CONT_NUM")=='') return;
						openContractDetail(param);
						break;

					case 'REJECT_RMK':
						var param = {
							 rowId: rowId
							,havePermission: true
							,screenName: '반려사유'
							,callBackFunction: 'setRjectReason'
							,TEXT_CONTENTS: grid.getCellValue(rowId, "REJECT_RMK")
							,detailView: false
						};
						everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
						break;

					case "PO_NUM" :
						if(value != ''){
							var param = {
								GATE_CD : "${ses.gateCd}",
								PO_NUM : value,
								detailView : true
							};
							everPopup.openPopupByScreenId('PO0130', 1200, 900, param);
						}
						break;

					case "ETC_ATT_FILE_CNT" :
							if(value !=''){
								var param = {
									detailView		: true
									, attFileNum		: grid.getCellValue(rowId, "ETC_ATT_FILE_NUM")
									, havePermission	: false
									, rowId				: rowId
									, callBackFunction	: "callback_setAttFile"
									, bizType			: "CT"
									, fileExtension		: "*"
								};
								everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
							}
							break;

						default:
							return;
				}
			});

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }"
			});

			// DashBoard 통해서 들어왔을 경우 파라미터 셋팅
			if ('${dashBoardFlag}' == 'Y') {
				/*EVF.V('REG_DATE_FROM', '${param.FROM_DATE2}');
				EVF.V('REG_DATE_TO', '${param.TO_DATE}');*/
				EVF.V('PROGRESS_CD', '${PROGRESS_CD}');
			}

			doSearch();
		}



		function setRjectReason(context, rowId){
			grid.setCellValue(rowId, 'REJECT_RMK', context);
		}




		function doSearch() {

			var store = new EVF.Store();
			if (!store.validate()) { return; }

			store.setGrid([ grid ]);
			store.load(baseUrl + '/CT0610/doSearch', function() {
				if (grid.getRowCount() == 0) {
					EVF.alert("${msg.M0002 }");
				}
			});
		}

		function openContractDetail(params) {
            var url = '/evermp/vendor/cont/CT0611/view';
            everPopup.openWindowPopup(url, 1200, 900, params, 'openContractChangeInformation');
		}

	    function doReceipt() {
			var selRowId = grid.getSelRowId();

	    	var store = new EVF.Store();
			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
			if(!grid.validate().flag) {
				return EVF.alert("${msg.M0014}");
			}


            for(var i in selRowId) {
                var rowId = selRowId[i];
                if(grid.getCellValue(rowId, 'RECEIPT_YN') != '0') {
                	return EVF.alert('${CT0610_0007}');
                }
            }



			EVF.confirm("${CT0610_0001}", function () {
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.setAsync(false);
				store.load(baseUrl + '/CT0610/doReceipt', function() {
					EVF.alert(this.getResponseMessage(), function() {

						return;
						if(selRowId.length == 1) {
							var contNum = grid.getCellValue(selRowId[0], 'CONT_NUM');
							var poNum = grid.getCellValue(selRowId[0], 'PO_NUM');
							if(contNum!='' && poNum=='') {
								var param = {
										callBackFunction : 'doSearch',
										GATE_CD : grid.getCellValue(selRowId[0], "GATE_CD"),
										contNum : grid.getCellValue(selRowId[0], "CONT_NUM"),
										contCnt : grid.getCellValue(selRowId[0], "CONT_CNT"),
										baseDataType : 'manualContract',
										contractEditable : false
								};
								if (grid.getCellValue(selRowId[0], "CONT_NUM")=='') return;
								openContractDetail(param);
							}

						}

					});
				});
				doSearch();
			});
	    }






	    function doReject() {
			var store = new EVF.Store();
			store.setAsync(false);
			if (!grid.isExistsSelRow()) { return EVF.alert('${msg.M0004}'); }
			if(!grid.validate().flag) {
				return EVF.alert("${msg.M0014}");
			}



			var selRowId = grid.getSelRowId();
            for(var i in selRowId) {
                var rowId = selRowId[i];


                if(grid.getCellValue(rowId, 'RECEIPT_YN') != '0') {
                	return EVF.alert('${CT0610_0007}');
                }

                if(grid.getCellValue(rowId, 'REJECT_RMK') == '') {
                	return EVF.alert('${CT0610_0006}');
                }
            }


			EVF.confirm("${CT0610_0002}", function () {
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.load(baseUrl + '/CT0610/doReject', function() {
					EVF.alert(this.getResponseMessage());

				});
				doSearch();
			});
	    }

	    function doConsult() {
			/*var selRow = grid.getSelRowValue();
		    var list = [];

		    for(var i in selRow){
			    if(selRow[i].PO_NUM == "" ){ return alert("${CT0610_0008}");}
			    list.push(selRow[i].PO_NUM);
		    }*/

		    var value = grid.getSelRowValue()[0];
		    if (!grid.isExistsSelRow()) { return EVF.alert("${msg.M0004}"); }
			if(value.CONSULT_YN == '0'){ return EVF.alert("${CT0610_0009}")}
		    if (grid.getSelRowCount() > 1) { return EVF.alert("${CT0610_0010}"); }
		    if(value.PO_NUM == '') {return EVF.alert("${CT0610_0008}")}

			var param = {
				/*PO_NUM : list.join().trim()*/
				PO_NUM : value.PO_NUM
			};
			everPopup.openPopupByScreenId('PO0610P01', 1200, 800, param);
	    }

	</script>

	<e:window id="CT0610" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
			<e:row>
				<%--계약구분--%>
				<e:label for="REG_DATE" title="${form_REG_DATE_N }" />
				<e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate }" width="${inputTextDate }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>
				<%--계약번호/명--%>
				<e:label for="CONT_DESC" title="${form_CONT_DESC_N }" />
				<e:field>
					<e:inputText id="CONT_NUM" name="CONT_NUM" value="" width="40%" maxLength="${form_CONT_NUM_M}" disabled="${form_CONT_NUM_D}" readOnly="${form_CONT_NUM_RO}" required="${form_CONT_NUM_R}" />
					<e:inputText id="CONT_DESC" name="CONT_DESC" value="" width="60%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<%--진행상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
			   <%--계약구분--%>
				<e:label for="MANUAL_CONT_FLAG" title="${form_MANUAL_CONT_FLAG_N}"/>
				<e:field>
					<e:select id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="" options="${manualContFlagOptions}" width="${form_MANUAL_CONT_FLAG_W}" disabled="${form_MANUAL_CONT_FLAG_D}" readOnly="${form_MANUAL_CONT_FLAG_RO}" required="${form_MANUAL_CONT_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
				<e:label for="dummy" />
				<e:field colSpan="1" />
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<e:button id="doReceipt" name="doReceipt" label="${doReceipt_N}" onClick="doReceipt" disabled="${doReceipt_D}" visible="${doReceipt_V}"/>
			<e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
		</e:buttonBar>
		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
