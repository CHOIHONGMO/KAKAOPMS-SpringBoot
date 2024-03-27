<!--
* BSYT_010 : 직무관리
* 시스템관리 > 기본정보 > 직무관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid; var gridDT;
		var addParam = [];
		var baseUrl = "/eversrm/system/task/";
		var selRow;

		function init() {
			grid = EVF.C('grid');
            grid.setProperty('shrinkToFit', true);
			grid.setProperty('panelVisible', ${panelVisible});

            gridDT = EVF.C('gridDT');
            gridDT.setProperty('shrinkToFit', true);
			
            // 운영사인 경우에만 직무권한 추가
            // 고객사는 직무별 사용자만 추가 가능
            if ("${ses.operator }" == "true") {
    			grid.addRowEvent(function() {
    				addParam = [{"BUYER_CD": EVF.V("BUYER_CD"), "USE_FLAG": "1", "GATE_CD": "${ses.gateCd}", "INSERT_FLAG": "I", "CTRL_TYPE": ""}];
    				grid.addRow(addParam);
    			});

    			grid.delRowEvent(function() {
                    if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
    				grid.delRow();
    			});
            } else {
            	EVF.C('Save').setVisible(false);
            	EVF.C('Delete').setVisible(false);
            }

			grid.cellClickEvent(function(rowid, colId, value) {
				if(selRow == undefined) selRow = rowid;
                if(colId == "CTRL_CD") {
                    if(grid.getCellValue(rowid, "INSERT_FLAG")=="U"){

						EVF.V("CTRL_CD_S",grid.getCellValue(rowid, "CTRL_CD"));
                        EVF.V("BUYER_CD_S",grid.getCellValue(rowid, "BUYER_CD"));
                        doSearchDT();
					}
				}
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			grid.setProperty('shrinkToFit', true);
			doSearch();
		}

		function doSearch() {
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + 'selectTaskCode', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doSearchDT() {
            var store = new EVF.Store();
            store.setGrid([gridDT]);
            store.load(baseUrl + 'selectMappingUser_add', function() {
                if(gridDT.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

		function doSave() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');

			store.load(baseUrl + 'taskCodeList/saveTaskCode', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}


		function doDelete() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'taskCodeList/deleteTaskCode', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}

        function doUserSave() {
            if(!gridDT.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(EVF.V('CTRL_CD_S')==""){ return alert("${BSYT_010_M001}"); }
            if (!confirm("${msg.M0021}")) return;

            var store = new EVF.Store();
            store.setGrid([gridDT]);
            store.getGridData(gridDT, 'sel');
            store.load(baseUrl + 'taskCodeList/doSaveTaskUser', function() {
                alert(this.getResponseMessage());
                doSearchDT();
            });
        }

        function doUserDelete(){
            if(!gridDT.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if (!confirm("${msg.M0013 }")) return;
            var store = new EVF.Store();
            store.setGrid([gridDT]);
            store.getGridData(gridDT, 'sel');
            store.load(baseUrl + 'taskCodeList/doDeleteTaskUser', function() {
                alert(this.getResponseMessage());
                doSearchDT();
            });
        }

		function doEnvironmentPopup(handler) {
			var popupUrl = "/eversrm/system/env/BSYE_020/view";
			var param = {
				"BUYER_CD": EVF.C('BUYER_CD').getValue(),
				"callBackFunction": 'setPurCd'
			};
			everPopup.openWindowPopup(popupUrl, 900, 500, param, 'setPurCd', false);
		}

		function setPurCd(data) {
			grid.setCellValue(currentRow, "PUR_ORG_NM", data.PUR_ORG_NM);
			grid.setCellValue(currentRow, "PUR_ORG_CD", data.PUR_ORG_CD);
			grid.setCellValue(currentRow, "BUYER_CD", data.BUYER_CD);
			grid.checkRow(currentRow, true);
		}

		function doTaskSearch() {
			var BUYER_CD = EVF.C('BUYER_CD').getValue();

			if (BUYER_CD == "") {
				alert("${BSYT_010_0001 }");
				return;
			}

			var param = {
				BUYER_CD: EVF.C('BUYER_CD').getValue(),
				callBackFunction: "setTaskId"
			};
			everPopup.openCommonPopup(param, "SP0003");
		}

		function setTaskId(data) {
            EVF.C("CTRL_CD").setValue(data.CTRL_CD);
			EVF.C("CTRL_NM").setValue(data.CTRL_NM);
		}

        function doUserSearch() {
            var param = {
            	custCd : EVF.V("BUYER_CD"),
                callBackFunction : "setUserCdMulti"
            };
            everPopup.openCommonPopup(param, 'MP0007');
        }
        
        function setUserCdMulti(data) {
            if(data.length != undefined) {
                var dataArr = [];
                for(idx in data) {
                    var arr = {
                        'USER_ID': data[idx].USER_ID,
                        'USER_ID_V': data[idx].USER_ID,
                        'USER_NM': data[idx].USER_NM,
                        'EMPLOYEE_NUM': data[idx].EMPLOYEE_NUM,
                        'DEPT_NM': data[idx].DEPT_NM,
						'USE_FLAG': '1'
                    };
                    dataArr.push(arr);
                }
                var validData = valid.equalPopupValid(JSON.stringify(dataArr), gridDT, "USER_ID");
                gridDT.addRow(validData);
            }
        }

	</script>

	<e:window id="BSYT_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
			<e:inputHidden id="CTRL_CD_S" name="CTRL_CD_S" value="" />
			<e:inputHidden id="BUYER_CD_S" name="BUYER_CD_S" value="" />
			<e:row>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N }" />
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" usePlaceHolder="false" value="${ses.companyCd}" readOnly="${form_BUYER_CD_RO }" options="${buyerCdOptions }" width="${form_BUYER_CD_W }" required="${form_BUYER_CD_R }" disabled="${form_BUYER_CD_D }" />
				</e:field>
				<e:label for="CTRL_TYPE" title="${form_CTRL_TYPE_N }" />
				<e:field>
					<e:select id="CTRL_TYPE" name="CTRL_TYPE" value="" options="${ctrlTypeOptions }" readOnly="${form_CTRL_TYPE_RO }" width="${form_CTRL_TYPE_W }" required="${form_CTRL_TYPE_R }" disabled="${form_CTRL_TYPE_D }" />
				</e:field>
				<e:label for="CTRL_NM" title="${form_CTRL_NM_N }" />
				<e:field>
					<e:search id="CTRL_CD" style="ime-mode:inactive" name="CTRL_CD" value="" width="40%" maxLength="${form_CTRL_CD_M}" onIconClick="doTaskSearch" disabled="${form_CTRL_CD_D}" readOnly="${form_CTRL_CD_RO}" required="${form_CTRL_CD_R}" />
					<e:inputText id="CTRL_NM" style="${imeMode}" name="CTRL_NM" value="${formData.CTRL_NM }" width="60%" maxLength="${form_CTRL_NM_M}" disabled="${form_CTRL_NM_D}" readOnly="${form_CTRL_NM_RO}" required="${form_CTRL_NM_R}" onKeyDown="cleanBsCd" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:panel id="Panel1" height="fit" width="49%">
			<e:buttonBar id="buttonBar1" align="right" width="100%" title="${BSYT_010_TITLE1}">
				<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
				<e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
				<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
			</e:buttonBar>
			<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
		</e:panel>

		<e:panel id="Panel2" height="fit" width="1%">&nbsp;</e:panel>

		<e:panel id="Panel3" height="fit" width="50%">
			<e:buttonBar id="buttonBar2" align="right" width="100%" title="${BSYT_010_TITLE2}">
				<e:button id="UserSearch" name="UserSearch" label="${UserSearch_N }" disabled="${UserSearch_D }" visible="${UserSearch_V}" onClick="doUserSearch" />
				<e:button id="UserSave" name="UserSave" label="${UserSave_N }" disabled="${UserSave_D }" visible="${UserSave_V}" onClick="doUserSave" />
				<e:button id="UserDelete" name="UserDelete" label="${UserDelete_N }" disabled="${UserDelete_D }" visible="${UserDelete_V}" onClick="doUserDelete" />
			</e:buttonBar>
			<e:gridPanel id="gridDT" name="gridDT" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridDT.gridColData}"/>
		</e:panel>

	</e:window>
</e:ui>

