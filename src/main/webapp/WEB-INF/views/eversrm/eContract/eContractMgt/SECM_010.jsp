<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid = {};
		var baseUrl = "/eversrm/eContract/eContractMgt/";

		function init() {
			grid = EVF.C("grid");
			grid.setProperty('panelVisible', ${panelVisible});
	        grid.setProperty('singleSelect', true);
			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				switch (celname) {
				case 'CONT_NUM':
					/*
					everPopup.openContractChangeInformation({
						callBackFunction : 'doSearch',
						CONT_NUM         : grid.getCellValue(rowid, "CONT_NUM"),
						CONT_CNT         : grid.getCellValue(rowid, "CONT_CNT"),
						baseDataType     : grid.getCellValue(rowid, "BASEDATATYPE"),
						contractEditable : false
					});
					*/
					break;

				case 'GUR_CNT':
					if(grid.getCellValue(rowid, "ADV_GUAR_FLAG")=='1'){
			            var param = {
			              havePermission: "${param.detailView}" == 'true' ? 'false' : 'true',
			              attFileNum: grid.getCellValue(rowid, 'GUAR_ATT_FILE_NUM'),
			              rowId: rowid,
			              callBackFunction: 'setFileAttachCnt1',
			              bizType: 'CT',
			              fileExtension: '*'
			            };

		           		everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					}else{
						alert('${SECM_010_0001}');
					}
		            break;

				case 'GUR_PER_CNT':
					if(grid.getCellValue(rowid, "WARR_GUAR_FLAG")=='1'){
						var param = {
							havePermission: "${param.detailView}" == 'true' ? 'false' : 'true',
							attFileNum: grid.getCellValue(rowid, 'GUAR_PERFORM_ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'setFileAttachCnt2',
							bizType: 'CT',
							fileExtension: '*'
						};
						everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					}else{
						alert('${SECM_010_0001}');
					}
					break;

				case 'GUR_PAY_CNT':
					var param = {
							havePermission: "${param.detailView}" == 'true' ? 'false' : 'true',
							attFileNum: grid.getCellValue(rowid, 'GUAR_PAY_ATT_FILE_NUM'),
							rowId: rowid,
							callBackFunction: 'setFileAttachCnt3',
							bizType: 'CT',
							fileExtension: '*'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);

					break;

				case 'GUR_FIN_CNT':
					if(grid.getCellValue(rowid, "CONT_GUAR_FLAG")=='1'){
						var param = {
			              havePermission: "${param.detailView}" == 'true' ? 'false' : 'true',
			              attFileNum: grid.getCellValue(rowid, 'GUAR_FINISH_ATT_FILE_NUM'),
			              rowId: rowid,
			              callBackFunction: 'setFileAttachCnt4',
			              bizType: 'CT',
			              fileExtension: '*'
			            };
			            everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					}else{
						alert('${SECM_010_0001}');
					}
		            break;

					<%-- VENDOR ATT --%>
				case 'VENDOR_ATT_FILE_CNT':
					var param = {
						havePermission: "${param.detailView}" == 'true' ? 'false' : 'true',
						attFileNum: grid.getCellValue(rowid, 'VENDOR_ATT_FILE_NUM'),
						rowId: rowid,
						callBackFunction: 'setFileAttachCnt5',
						bizType: 'CT',
						fileExtension: '*'
					};
					everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
					break;


				default:
					return;
				}
			});

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth : 0.12,    // image width
					imgHeight : 0.26,   // image height
					colWidth : 20,      // column width.
					rowSize : 500,      // excel row hight size.
					attachImgFlag : false
					// excel imange attach flag : true/false
				}
			});

			//SUMMARY화면에서 넘어올 경우 자동조회
	        if ('${param.summary}' == 'Y') {
	            doSearch();
	        }
		}


	    function setFileAttachCnt1(rowId, uuid, count) {
	      grid.setCellValue(rowId, 'GUR_CNT', count);
	      grid.setCellValue(rowId, 'GUAR_ATT_FILE_NUM', uuid);
	      doGurSave()

	    }

		function setFileAttachCnt2(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'GUR_PER_CNT', fileCnt);
			grid.setCellValue(rowId, 'GUAR_PERFORM_ATT_FILE_NUM', fileId);
			doGurSave()
		}

		function setFileAttachCnt3(rowId, fileId, fileCnt) {
			grid.setCellValue(rowId, 'GUR_PAY_CNT', fileCnt);
			grid.setCellValue(rowId, 'GUAR_PAY_ATT_FILE_NUM', fileId);
			doGurSave()
		}


	    function setFileAttachCnt4(rowId, uuid, count) {
	      grid.setCellValue(rowId, 'GUR_FIN_CNT', count);
	      grid.setCellValue(rowId, 'GUAR_FINISH_ATT_FILE_NUM', uuid);
	      doGurSave()
	    }

	    function setFileAttachCnt5(rowId, uuid, count) {
			grid.setCellValue(rowId, 'VENDOR_ATT_FILE_CNT', count);
			grid.setCellValue(rowId, 'VENDOR_ATT_FILE_NUM', uuid);
			doGurSave()
		}

		function doSearch() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}

			if (!everDate.fromTodateValid('REG_DATE_FROM', 'REG_DATE_TO', '${ses.dateFormat }'))
				return alert('${msg.M0073}');

			store.setGrid([ grid ]);
			store.load(baseUrl + '/SECM_010/doSearch', function() {
				if (grid.getRowCount() == 0) {
					alert("${msg.M0002 }");
				}
			});
		}

		function doContractDetail() {
			var gridData = grid.getSelRowValue();
			if (gridData.length > 0) {
				var valid = grid.validate();
				if (!valid.flag) {
					alert(valid.msg);
					return;
				}
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			} else if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			}

			everPopup.openContractChangeInformation({
				callBackFunction : 'doSearch',
				CONT_NUM         : gridData[0]['CONT_NUM'],
				CONT_CNT         : gridData[0]['CONT_CNT'],
				baseDataType     : gridData[0]['BASEDATATYPE'],
				detailView : false,
				contractEditable : true
			});
		}

		function doPrint() {
			var gridData = grid.getSelRowValue();
			if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }');
				return;
			}

			var param = {
					CONT_NUM : gridData[0]['CONT_NUM'],
					CONT_CNT : gridData[0]['CONT_CNT'],
					progressCd : gridData[0]['PROGRESS_CD'],
					CONTRACT_TEXT_NUM : gridData[0]['CONTRACT_TEXT_NUM'],
                	contents: '', //gridData[0]['CONTENTS'],
                	callBackFunction: ''
                };
                everPopup.openPopupByScreenId('BECM_060', 1000, 800, param);
		}


	    function doGurSave() {
	      var store = new EVF.Store();
	      var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

	      if(selRowIds.length == 0) {
	        return alert("${msg.M0004}");
	      }

	      // Grid Validation Check
	      if (!grid.validate().flag) { return alert(grid.validate().msg); }

	      store.setGrid([grid]);

	      store.getGridData(grid, 'sel');
	      if (!confirm("${msg.M0021}")) return;
	      store.load(baseUrl + 'SECM_010/doGurSave', function() {
	        alert(this.getResponseMessage());
	        doSearch();
	      });
	    }


	</script>

	<e:window id="SECM_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">

		<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
		<e:inputHidden id="CLOSING_PROGRESS_CD" name="CLOSING_PROGRESS_CD" value="" />
		<e:inputHidden id="CLOSING_REQ_USER_TYPE" name="CLOSING_REQ_USER_TYPE" value="" />
		<e:inputHidden id="summary" name="summary" value="${summary}" />

			<e:row>
				<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N }" />
				 <e:field>
					<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${fromDate }" width="${inputDateWidth }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
					<e:text>~</e:text>
					<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${toDate }" width="${inputDateWidth }" required="${form_REG_DATE_R }" readOnly="${form_REG_DATE_RO }" disabled="${form_REG_DATE_D }" datePicker="true" />
				</e:field>
				<e:label for="USER_NM" title="${form_USER_NM_N }" />
				<e:field>
					<e:inputText id="USER_NM" name="USER_NM" width="100%" required="${form_USER_NM_R }" disabled="${form_USER_NM_D }" value="" readOnly="${form_USER_NM_RO }" maxLength="${form_USER_NM_M}" />
				</e:field>
				<e:label for="CONT_REQ_CD" title="${form_CONT_REQ_CD_N}"/>
				<e:field>
					<e:select id="CONT_REQ_CD" name="CONT_REQ_CD" value="${form.CONT_REQ_CD}" options="${contReqCd}" width="${inputTextWidth}" disabled="${form_CONT_REQ_CD_D}" readOnly="${form_CONT_REQ_CD_RO}" required="${form_CONT_REQ_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="CONT_DESC" title="${form_CONT_DESC_N }" />
				<e:field>
					<e:inputText id="CONT_DESC" name="CONT_DESC" width="100%" required="${form_CONT_DESC_R }" disabled="${form_CONT_DESC_D }" value="" readOnly="${form_CONT_DESC_RO }" maxLength="${form_CONT_DESC_M}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N }" />
				<e:field colSpan="3">
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" readOnly="${form_PROGRESS_CD_RO }" width="${inputTextWidth}" required="${form_PROGRESS_CD_R }" disabled="${form_PROGRESS_CD_D }" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<e:button id="doContractDetail" name="doContractDetail" label="${doContractDetail_N }" disabled="${doContractDetail_D }" onClick="doContractDetail" />
			<e:button id="doPrint" name="doPrint" label="${doPrint_N}" onClick="doPrint" disabled="${doPrint_D}" visible="${doPrint_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
