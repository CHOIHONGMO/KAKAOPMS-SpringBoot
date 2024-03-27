<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui>
	<script type="text/javascript">

		var grid = {};
		var baseUrl = "/evermp/vendor/cont";
		var pdfPath = "${pdfPath}";

		function init() {


			grid = EVF.C("grid");
			grid.setProperty('panelVisible', ${panelVisible});

			grid.cellClickEvent(function(rowId, colId, value) {
				if (colId == 'CONT_NUM') {
					var param = {
							callBackFunction : 'doSearch',
							GATE_CD 		 : grid.getCellValue(rowId, "GATE_CD"),
							contNum 		 : grid.getCellValue(rowId, "CONT_NUM"),
							contCnt 		 : grid.getCellValue(rowId, "CONT_CNT"),
							baseDataType 	 : 'manualContract',
							contractEditable : false
						};
						if (grid.getCellValue(rowId, "CONT_NUM")=='') return;
						openContractDetail(param);
				} else if (colId == 'REJECT_RMK') {
					var param = {
							 rowId				: rowId
							,havePermission		: true
							,screenName			: '반려사유'
							,callBackFunction	: 'setRjectReason'
							,TEXT_CONTENTS		: grid.getCellValue(rowId, "REJECT_RMK")
							,detailView			: false
						};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
             	} else if (colId == 'PO_NUM') {
             		if(value != ''){
						var param = {
							GATE_CD 	: "${ses.gateCd}",
							PO_NUM 		: value,
							detailView 	: true
						};
						everPopup.openPopupByScreenId('PO0130', 1200, 900, param);
					}             	} else if(colId == 'CONT_COMMIT_FLAG' || colId == 'ADV_COMMIT_FLAG' || colId == 'WARR_COMMIT_FLAG'){
             		var param = {
             			rowId			 : rowId,
             			CONT_NUM 		 : grid.getCellValue(rowId, "CONT_NUM"),
             			CONT_CNT 		 : grid.getCellValue(rowId, "CONT_CNT"),
            			callBackFunction : "selectApply"


            			};

            			everPopup.openPopupByScreenId('CT0620P01', 1600, 500, param);
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
	              } else if(colId == 'ETC_ATT_FILE_CNT'){
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
			});

			grid.excelExportEvent({
				allCol   : "${excelExport.allCol}",
				selRow   : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }"
			});

			// DashBoard 통해서 들어왔을 경우 파라미터 셋팅
			if ('${dashBoardFlag}' == 'Y') {
				/*EVF.V('REG_DATE_FROM', '${param.FROM_DATE2}');
				EVF.V('REG_DATE_TO', '${param.TO_DATE}');*/
				EVF.V('PROGRESS_CD', '${PROGRESS_CD}');
			}

			// Column 그룹
		 	grid.setColGroup([{
                "groupName": '계약보증증권',
                "columns": [ "CONT_GUAR_AMT","CONT_GUAR_PERCENT","CONT_INSU_BILL_FLAG","CONT_INSU_STATUS","CONT_INSU_NUM","CONT_COMMIT_FLAG","CONT_ATT_FILE_CNT","CONT_ATT_FILE_NUM" ]
            },{
                "groupName": '선급보증증권',
                "columns": [ "ADV_GUAR_AMT","ADV_GUAR_PERCENT","ADV_INSU_BILL_FLAG","ADV_INSU_STATUS","ADV_INSU_NUM","ADV_COMMIT_FLAG","ADV_ATT_FILE_CNT","ADV_ATT_FILE_NUM" ]
            },{
                "groupName": '하자보증증권',
                "columns": [ "WARR_GUAR_AMT","WARR_GUAR_PERCENT","WARR_INSU_BILL_FLAG","WARR_INSU_STATUS","WARR_INSU_NUM","WARR_COMMIT_FLAG","WARR_ATT_FILE_CNT","WARR_ATT_FILE_NUM" ]
            }],70);

			doSearch();
		}
		function selectApply(){

		}
		function setRjectReason(context, rowId){
			grid.setCellValue(rowId, 'REJECT_RMK', context);
		}

		function doSearch() {

			var store = new EVF.Store();
			if (!store.validate()) { return; }

			store.setGrid([ grid ]);
			store.load(baseUrl + '/CT0620/doSearch', function() {
				if (grid.getRowCount() == 0) {
					EVF.alert("${msg.M0002 }");
				}
			});
		}

		function openContractDetail(params) {
            var url = '/evermp/vendor/cont/CT0611/view';
            everPopup.openWindowPopup(url, 1200, 900, params, 'openContractChangeInformation');
		}

	</script>

	<e:window id="CT0620" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="130" onEnter="doSearch" useTitleBar="false">
			<e:row>
				<e:inputHidden id="BELONG_DEPT_CD" name="BELONG_DEPT_CD" value="${ses.plantCd}"/>
				<%--날짜--%>
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
					<e:inputText id="CONT_DESC" name="CONT_DESC" width="60%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<%--계약구분--%>
				<e:label for="MANUAL_CONT_FLAG" title="${form_MANUAL_CONT_FLAG_N}"/>
				<e:field>
					<e:select id="MANUAL_CONT_FLAG" name="MANUAL_CONT_FLAG" value="" options="${manualContFlagOptions}" width="${form_MANUAL_CONT_FLAG_W}" disabled="${form_MANUAL_CONT_FLAG_D}" readOnly="${form_MANUAL_CONT_FLAG_RO}" required="${form_MANUAL_CONT_FLAG_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
		</e:buttonBar>
		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
