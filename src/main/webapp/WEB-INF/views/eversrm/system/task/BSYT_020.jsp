<!--
* BSYT_020 : 직무-담당자 Mapping
* 시스템관리 > 기본정보 > 직무-담당자 Mapping
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid = {};
		var addParam = [];
		var baseUrl = "/eversrm/system/task/taskPersonInCharge/";
		var currentRow;

		function init() {

			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.addRowEvent(function() {
				addParam = [{
					"BUYER_NM": EVF.C('buyerCd').getValue()
					, "BUYER_CD_ORI": EVF.C('buyerCd').getValue()
					, "BUYER_CD": EVF.C('buyerCd').getValue()
					, "INSERT_FLAG": "I"
					, "USE_FLAG": "1"
					, "GATE_CD": "${ses.gateCd}"
				}];
				grid.addRow(addParam);
			});

			grid.delRowEvent(function() {

                if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
				grid.delRow();
			});

			grid.cellClickEvent(function(rowid, colId, value) {

				currentRow = rowid;

				if(colId == "USER_NM") {
					doUserSearch("selectUserIdPopupIntoGrid");
				} else if(colId == "CTRL_NM") {
					doTaskSearch("selectTaskIdPopupIntoGrid");
				} else if(colId == "CTRL_DEPT_IMG") {
					var gateCd = grid.getCellValue(rowid, "GATE_CD");
					var buyerCd = grid.getCellValue(rowid, "BUYER_CD");
					var ctrlUserId = grid.getCellValue(rowid, "CTRL_USER_ID");
					var params = {
						GATE_CD : gateCd,
						BUYER_CD : buyerCd,
						CTRL_USER_ID : ctrlUserId,
						callBackFunction: 'setCtrlDeptImg'
					};
					everPopup.openCtrlDeptImgPopup(params);
				}
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			grid.setProperty('shrinkToFit', true);
			//doSearch();
		}

		function doSearch() {

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + 'selectTaskPersonInCharge', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doSave() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if('${_gridType}' == 'RG') {
				if (!grid.validate().flag) { return alert(grid.validate().msg); }
			} else {
				if (!grid.validate().flag) { return alert(grid.validate().msg); }
			}

			if (!confirm("${msg.M0021 }")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'saveTaskPersonInCharge', function(){
				alert(this.getResponseMessage());
				if(this.getResponseCode() == "0001") {
					doSearch();
				}
			});
		}

		function doDelete() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'deleteTaskPersonInCharge', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doUserSearch(handler) {
			var param = {
				"BUYER_CD": EVF.C('buyerCd').getValue(),
				"callBackFunction": handler
			};
			everPopup.openCommonPopup(param, "SP0011");
			//everPopup.openUserInChargeSearch(param);
		}

		function selectUserIdPopupIntoGrid(data) {
			grid.setCellValue(currentRow, 'CTRL_USER_ID', data.USER_ID.text);


			if('${_gridType}' == 'RG') {
				grid.setCellValue(currentRow, 'CTRL_USER_ID', data.USER_ID);
			} else {
				grid.setCellValue(currentRow, 'CTRL_USER_ID', data.USER_ID.text);
			}


			grid.setCellValue(currentRow, 'USER_NM', data.USER_NM);
			grid.setCellValue(currentRow, 'DEPT_NM', data.DEPT_NM);

			var selectedRow = grid.getSelRowValue();
			var selRowIds = grid.getSelRowId();
			if (selectedRow.length > 1) {
				if (confirm('${BSYT_020_001}')) {
					for(var x in selRowIds) {
						var rowId = selRowIds[x];


						if('${_gridType}' == 'RG') {
							grid.setCellValue(rowId, 'CTRL_USER_ID', data.USER_ID);
						} else {
							grid.setCellValue(rowId, 'CTRL_USER_ID', data.USER_ID.text);
						}

						grid.setCellValue(rowId, 'USER_NM', data.USER_NM);
						grid.setCellValue(rowId, 'DEPT_NM', data.DEPT_NM);
					}
				}
			}
		}

		function doTaskSearch(handler) {
			var param = {
				BUYER_CD: grid.getCellValue(currentRow, 'BUYER_CD'),
				callBackFunction: handler
			};
			everPopup.openCommonPopup(param, "SP0003");
		}

		function selectTaskIdPopupIntoGrid(data) {

			if('${_gridType}' == 'RG') {
				grid.setCellValue(currentRow, 'CTRL_CD', data.CTRL_CD);
			} else {
				grid.setCellValue(currentRow, 'CTRL_CD', data.CTRL_CD.text);
			}


			grid.setCellValue(currentRow, 'CTRL_NM', data.CTRL_NM);

			var selectedRow = grid.getSelRowValue();
			var selRowIds = grid.getSelRowId();
			if (selectedRow.length > 1) {
				if (confirm('${BSYT_020_001}')) {
					for(var x in selRowIds) {
						var rowId = selRowIds[x];

						if('${_gridType}' == 'RG') {
							grid.setCellValue(rowId, 'CTRL_CD', data.CTRL_CD);
						} else {
							grid.setCellValue(rowId, 'CTRL_CD', data.CTRL_CD.text);
						}

						grid.setCellValue(rowId, 'CTRL_NM', data.CTRL_NM);
					}
				}
			}
		}

        function getRegUserId() {
            var param = {
                callBackFunction : "setRegUserId"
            };
            everPopup.openCommonPopup(param, 'SP0011');
        }
        function setRegUserId(dataJsonArray) {
            EVF.C("USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("USER_NM").setValue(dataJsonArray.USER_NM);
        }


        function onIconClickDEPT_CD() {


            var popupUrl = "/evermp/SY01/SY0101/SY01_003/view";
            var param = {
                callBackFunction: "setDeptCd_s",
                'AllSelectYN': true,
                'detailView': false,
                'multiYN': false,
                'ModalPopup': true,
                'custCd' : EVF.V("buyerCd"),
                'custNm' : EVF.C("buyerCd").getText()
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "SearchTeamPopup");
        }

        function setDeptCd_s(data) {
            data = JSON.parse(data);
            EVF.V('DEPT_CD', data.DEPT_CD);
            EVF.V('DEPT_NM', data.DEPT_NM);
        }

	</script>

	<e:window id="BSYT_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="buyerCd" title="${form_buyerCd_N}"/>
				<e:field>
					<e:select id="buyerCd" name="buyerCd" value="${form.buyerCd}" options="${refBuyerCode}" width="${form_buyerCd_W}" disabled="${form_buyerCd_D}" readOnly="${form_buyerCd_RO}" required="${form_buyerCd_R}" usePlaceHolder="false" />
				</e:field>
				<e:label for="ctrlType" title="${form_ctrlType_N }" />
				<e:field>
					<e:select id="ctrlType" name="ctrlType" value="" options="${refCtrlType }" readOnly="${form_ctrlType_RO }" width="${form_ctrlType_W }" required="${form_ctrlType_R }" disabled="${form_ctrlType_D }" />
				</e:field>
				<e:label for="CTRL_NM" title="${form_CTRL_NM_N }" />
				<e:field>
					<e:inputText id="CTRL_NM" style="${imeMode}" name="CTRL_NM" width="${form_CTRL_NM_W }" required="${form_CTRL_NM_R }" disabled="${form_CTRL_NM_D }" readOnly="${form_CTRL_NM_RO }" maxLength="${form_CTRL_NM_M}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="USER_NM" title="${form_USER_NM_N }" />
				<e:field>
					<e:search id="USER_ID" name="USER_ID" value="" width="40%" maxLength="${form_USER_ID_M}" onIconClick="getRegUserId" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
					<e:inputText id="USER_NM" name="USER_NM"  value="" width="60%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
				</e:field>
				<e:label for="DEPT_CD" title="${form_DEPT_CD_N}"/>
				<e:field>
					<e:search id="DEPT_CD" name="DEPT_CD" value="${data.DEPT_CD}" width="40%" maxLength="${form_DEPT_CD_M}" onIconClick="${form_DEPT_CD_RO ? 'everCommon.blank' : 'onIconClickDEPT_CD'}" disabled="${form_DEPT_CD_D}" readOnly="${form_DEPT_CD_RO}" required="${form_DEPT_CD_R}" />
					<e:inputText id="DEPT_NM" name="DEPT_NM" value="${data.DEPT_NM}" width="60%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_PO_DEPT_NM_R}" />
				</e:field>
				<e:field colSpan="2">
				</e:field >
			</e:row>
		</e:searchPanel>
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
			<e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
			<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
		</e:buttonBar>
		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>