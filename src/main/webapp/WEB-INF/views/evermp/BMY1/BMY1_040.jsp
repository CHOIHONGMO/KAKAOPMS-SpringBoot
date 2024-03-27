<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

        var grid; var gridDp;
        var baseUrl = "/evermp/BMY1/";
        var eventRowId;

        function init() {

            grid = EVF.C("grid");
			gridDp = EVF.C("gridDp");

            grid.cellClickEvent(function(rowId, colId, value) {
                if(colId == "ITEM_CD") {

                    if( grid.getCellValue(rowId, "CUST_CD")==""){
                        return alert("${BMY1_040_004}");
                    }

                    var param = {
                        callBackFunction : "setItemInfo"
                        ,rowId : rowId
                        ,contractYn :'Y'
                        ,multiFlag : true
                        ,detailView : false
                        ,popupFlag : true
                    };
                    everPopup.openPopupByScreenId("IM02_012", 1200, 600, param);
                }
                else if(colId =="CUST_CD") {
                    var param = {
                        callBackFunction : "selectgridCust",
                        rowId : rowId
                    };
                    everPopup.openCommonPopup(param, 'SP0069');
                }
                else if (colId == 'ITEM_CLS_NM') {

                    var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
                    var param = {
                        callBackFunction: "_setItemClassNm_Grid",
                        detailView: false,
                        multiYN: false,
                        ModalPopup: true,
                        searchYN: true,
                        rowId: rowId,
                        'custCd': grid.getCellValue(rowId, "CUST_CD"),
                        'custNm': grid.getCellValue(rowId, "CUST_NM")
                    };
                    everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");

                }
                else if (colId == 'SG_CTRL_USER_NM') {
                    // 유저정보 조회
                    if( grid.getCellValue(rowId, 'SG_CTRL_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

			gridDp.cellClickEvent(function(rowId, colId, value) {

				eventRowId = rowId;

				if (colId == 'DEPT_NM') {

					if(EVF.isEmpty(EVF.V("CUST_CD"))) {
						return alert("${BMY1_040_003}");
					}
					var param = {
						rowId : rowId,
						callBackFunction: "setGridDeptCd",
						CUST_CD: EVF.V("CUST_CD")
					};
					everPopup.openCommonPopup(param, 'SP0071');
				}
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			gridDp.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.addRowEvent(function() {
                var addParam = [{"CUST_CD" : '${ses.companyCd}',"CUST_NM" : '${ses.companyNm}'}];
                grid.addRow(addParam);
            });

            grid.delRowEvent(function() {

                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
                var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
                for (var i = 0; i < selRowId.length; i++) {
                    if(grid.getCellValue(selRowId[i],'INSERT_FLAG') =="Y"){
                        return alert("${msg.M0145}");
                    }
                }
                grid.delRow();
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load("/evermp/IM03/IM0302/im01050_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                } else {
                	if(!EVF.isEmpty(EVF.V("DEPT_CD"))) {
						var store = new EVF.Store();
						store.setGrid([gridDp]);
						store.load("/evermp/IM03/IM0302/im01050_doSearchDp", function () {

						});
					}
				}
            });
        }

        function doSave() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if (!grid.validate().flag) { return alert(grid.validate().msg); }

            if(!confirm('${msg.M0021}')) { return; }
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load("/evermp/IM03/IM0302/im01050_doSave", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doDelete() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if( grid.getCellValue(rowIds[i], 'SOLE_ITEM_STATUS')=="1"){
                    return alert("${BMY1_040_001}");
                }
            }
            if (!confirm("${msg.M0013}")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load("/evermp/IM03/IM0302/im01050_doDelete", function () {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doAddDept() {

			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			var rowIds = grid.getSelRowId();
			for(var i in rowIds) {
				var selectedData = grid.getRowValue(rowIds[i]);
				if(selectedData.SOLE_ITEM_STATUS != "0") {
					return alert("${BMY1_040_005}");
				}
				var addParam = [{
					CUST_CD: selectedData.CUST_CD,
					ITEM_CD: selectedData.ITEM_CD,
					ITEM_DESC: selectedData.ITEM_DESC,
					ITEM_SPEC: selectedData.ITEM_SPEC,
					MAKER_NM: selectedData.MAKER_NM,
					MAKER_PART_NO: selectedData.MAKER_PART_NO,
					BRAND_NM: selectedData.BRAND_NM,
					ORIGIN_CD: selectedData.ORIGIN_CD,
					UNIT_CD: selectedData.UNIT_CD,
					SG_CTRL_USER_ID: selectedData.SG_CTRL_USER_ID,
					SG_CTRL_USER_NM: selectedData.SG_CTRL_USER_NM,
					UNIT_PRICE: selectedData.UNIT_PRICE
				}];
				gridDp.addRow(addParam);
			}
		}

		function doSaveDp() {

			if (gridDp.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!gridDp.validate().flag) { return alert(gridDp.validate().msg); }

			var rowIds = gridDp.getSelRowId();
			for(var i in rowIds) {
				if(EVF.isEmpty(gridDp.getCellValue(rowIds[i], 'DEPT_CD'))) {
					return alert("${BMY1_040_006}");
				}
			}

			if(!confirm('${msg.M0021}')) { return; }
			var store = new EVF.Store();
			store.setGrid([gridDp]);
			store.getGridData(gridDp, 'sel');
			store.load("/evermp/IM03/IM0302/im01050_doSaveDp", function () {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doDeleteDp() {

			if (gridDp.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!confirm("${msg.M0013}")) return;
			var store = new EVF.Store();
			store.setGrid([gridDp]);
			store.getGridData(gridDp, 'sel');
			store.load("/evermp/IM03/IM0302/im01050_doDeleteDp", function () {
				alert(this.getResponseMessage());
				doSearch();
			});
		}

        function _setItemClassNm_Grid(data) {
            if (data != null) {
                data = JSON.parse(data);
                grid.setCellValue(data.rowId, 'ITEM_CLS1', data.ITEM_CLS1);
                grid.setCellValue(data.rowId, 'ITEM_CLS2', data.ITEM_CLS2);
                grid.setCellValue(data.rowId, 'ITEM_CLS3', data.ITEM_CLS3);
                grid.setCellValue(data.rowId, 'ITEM_CLS4', data.ITEM_CLS4);
                grid.setCellValue(data.rowId, 'ITEM_CLS_NM', data.ITEM_CLS_PATH_NM);

            } else {
                grid.setCellValue(data.rowId, 'ITEM_CLS1', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS2', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS3', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS4', '');
                grid.setCellValue(data.rowId, 'ITEM_CLS_NM', '');
            }
        }

        function selectGridUser(data) {
            grid.setCellValue(data.rowId, 'DEL_REQ_USER_ID', data.USER_ID);
            grid.setCellValue(data.rowId, 'DEL_REQ_USER_NM', data.USER_NM);
        }

        function searchCust() {
			var param = {
				callBackFunction : "selectFormCust",
				rowId : null
			};
			everPopup.openCommonPopup(param, 'SP0069');
        }

		function selectFormCust(data) {
        	EVF.V("CUST_CD", data.CUST_CD);
        	EVF.V("CUST_NM", data.CUST_NM);
		}

        function selectgridCust(data) {
            grid.setCellValue(data.rowId, 'CUST_CD', data.CUST_CD);
            grid.setCellValue(data.rowId, 'CUST_NM', data.CUST_NM);
        }

		function searchDept() {
			var param = {
				rowId : null,
				callBackFunction: "selectFormDept",
				CUST_CD: EVF.V("CUST_CD")
			};
			everPopup.openCommonPopup(param, 'SP0071');
		}

		function selectFormDept(data) {
			EVF.V("DEPT_CD", data.DEPT_CD);
			EVF.V("DEPT_NM", data.DEPT_NM);
		}

		function setGridDeptCd(data) {

			if(confirm("${BMY1_040_004}")) {
				var rowIds = gridDp.getSelRowId();
				for(var i in rowIds) {
					gridDp.setCellValue(rowIds[i], "DEPT_CD", data.DEPT_CD);
					gridDp.setCellValue(rowIds[i], "DEPT_NM", data.DEPT_NM);
				}
			} else {
				gridDp.setCellValue(eventRowId, "DEPT_CD", data.DEPT_CD);
				gridDp.setCellValue(eventRowId, "DEPT_NM", data.DEPT_NM);
			}
		}

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function setItemInfo(jsonData, rowId) {

            var setRow = rowId;

            for(idx in jsonData) {
                if(idx > 0) {
                    var addParam = [{"CUST_CD" : grid.getCellValue(rowId, "CUST_CD"),"CUST_NM" : grid.getCellValue(rowId, "CUST_NM")}];
                    setRow = grid.addRow(addParam);
                }
                console.log(jsonData);
                grid.setCellValue(setRow, 'ITEM_CD', jsonData[idx].ITEM_CD);
                grid.setCellValue(setRow, 'ITEM_DESC', jsonData[idx].ITEM_DESC);
                grid.setCellValue(setRow, 'ITEM_SPEC', jsonData[idx].ITEM_SPEC);
                grid.setCellValue(setRow, 'MAKER_NM', jsonData[idx].MAKER_NM);
                grid.setCellValue(setRow, 'MAKER_PART_NO', jsonData[idx].MAKER_PART_NO);
                grid.setCellValue(setRow, 'BRAND_NM', jsonData[idx].BRAND_NM);
                grid.setCellValue(setRow, 'ORIGIN_CD', jsonData[idx].ORIGIN_CD);
                grid.setCellValue(setRow, 'UNIT_CD', jsonData[idx].UNIT_CD);
                grid.setCellValue(setRow, 'SG_CTRL_USER_ID', jsonData[idx].SG_CTRL_USER_ID);
                grid.setCellValue(setRow, 'SG_CTRL_USER_NM', jsonData[idx].SG_CTRL_USER_NM);

                doGetPrice(setRow);
            }

        }

        function doGetPrice(nRow) {

            if(EVF.isEmpty(grid.getCellValue(nRow, 'CUST_CD')) || EVF.isEmpty(grid.getCellValue(nRow, 'ITEM_CD'))) return;

            var store = new EVF.Store();
            store.setParameter("BUYER_CD", grid.getCellValue(nRow, 'CUST_CD'));
            store.setParameter("ITEM_CD", grid.getCellValue(nRow, 'ITEM_CD'));
            store.load('/evermp/IM02/IM0201/im02011_doGetPrice', function() {
                grid.setCellValue(nRow, "CONT_UNIT_PRC", this.getParameter("CONT_UNIT_PRICE"));
                grid.setCellValue(nRow, "UNIT_PRICE", this.getParameter("UNIT_PRICE"));
                grid.setCellValue(nRow, "CUR", this.getParameter("CUR"));
            }, false);
        }

        function searchMAKER_CD(){
            var param = {
                callBackFunction : "callbackMAKER_CD"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function callbackMAKER_CD(data) {
            EVF.V("MAKER_CD",data.MKBR_CD);
            EVF.V("MAKER_NM",data.MKBR_NM);
        }

	</script>

	<e:window id="BMY1_040" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" style="ime-mode:inactive" name="CUST_CD" value="${ses.companyCd}" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCust'}" disabled="${form_CUST_CD_D}" readOnly="true" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" style="${imeMode}" name="CUST_NM" value="${ses.companyNm}" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="true" required="${form_CUST_NM_R}"/>
				</e:field>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<%--<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>--%>
				<%--<e:field>--%>
					<%--<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />--%>
					<%--<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>--%>
				<%--</e:field>--%>
			</e:row>
			<e:row>
				<e:label for="DEPT_CD" title="${form_DEPT_CD_N}"/>
				<e:field>
					<e:search id="DEPT_CD" style="ime-mode:inactive" name="DEPT_CD" value="" width="40%" maxLength="${form_DEPT_CD_M}" onIconClick="${form_DEPT_CD_RO ? 'everCommon.blank' : 'searchDept'}" disabled="${form_DEPT_CD_D}" readOnly="true" required="${form_DEPT_CD_R}" />
					<e:inputText id="DEPT_NM" style="${imeMode}" name="DEPT_NM" value="" width="60%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="true" required="${form_DEPT_NM_R}"/>
				</e:field>
				<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}" />
				<e:field>
					<e:inputText id="ITEM_SPEC" name="ITEM_SPEC" value="" width="${form_ITEM_SPEC_W}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}" />
				</e:field>
				<e:label for="ITEM_STATUS" title="${form_ITEM_STATUS_N}"/>
				<e:field>
					<e:select id="ITEM_STATUS" name="ITEM_STATUS" value="" options="${itemStatusOptions}" width="${form_ITEM_STATUS_W}" disabled="${form_ITEM_STATUS_D}" readOnly="${form_ITEM_STATUS_RO}" required="${form_ITEM_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>

		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
			<e:button id="addDept" name="addDept" label="${addDept_N}" disabled="${addDept_D}" visible="${addDept_V}" align="left" onClick="doAddDept" />
			<e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
			<e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" />
			<e:button id="Delete" name="Delete" label="${Delete_N}" disabled="${Delete_D}" visible="${Delete_V}" onClick="doDelete" />
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="350px" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

		<e:buttonBar id="btnDp" align="right" width="100%">
			<e:text style="font-weight:bold;">[${BMY1_040_002 }]&nbsp;&nbsp;</e:text>
			<e:button id="SaveDp" name="SaveDp" label="${SaveDp_N}" disabled="${SaveDp_D}" visible="${SaveDp_V}" onClick="doSaveDp" />
			<e:button id="DeleteDp" name="DeleteDp" label="${DeleteDp_N}" disabled="${DeleteDp_D}" visible="${DeleteDp_V}" onClick="doDeleteDp" />
		</e:buttonBar>

		<e:gridPanel id="gridDp" name="gridDp" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridDp.gridColData}" />

	</e:window>
</e:ui>