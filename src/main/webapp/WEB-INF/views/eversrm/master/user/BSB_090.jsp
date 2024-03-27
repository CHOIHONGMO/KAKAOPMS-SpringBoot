<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var grid;
        var baseUrl = "/eversrm/master/user/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                var param;
                if(colId === "CUST_NO") {

                	if (grid.getCellValue(rowId,'CUST') != '') return;

                    var param = {
                            rowId: rowId,
                            callBackFunction : "setCustNo"
                    };
                    everPopup.openCommonPopup(param, 'SP0905');
                }
            });


			grid.addRowEvent(function() {
				addParam = [{"PO_YN": "Y", "PO_GUBUN": "1"}];
            	grid.addRow(addParam);
			});

			grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

				grid.delRow();
			});

            doSearch();
        }

        function setCustNo(data) {
            grid.setCellValue(data.rowId, "CUST_NO", data.CUST_CD+data.PLANT_CD);

            grid.setCellValue(data.rowId, "COMPANY_CODE", data.CUST_CD);
            grid.setCellValue(data.rowId, "COMPANY_NAME", data.CUST_NM);

            grid.setCellValue(data.rowId, "DIVISION_CODE", data.PLANT_CD);
            grid.setCellValue(data.rowId, "DIVISION_NAME", data.PLANT_NM);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "BSB_090/doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            if(!grid.validate().flag) { return alert(grid.validate().msg); }

            var rowIds = grid.getSelRowId();
            for( var i in rowIds ) {


			}

            if (!confirm("${msg.M0021 }")) return;

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'BSB_090/doSave', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

    </script>

    <e:window id="BSB_090" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="CUST_NO" title="${form_CUST_NO_N}" />
				<e:field>
				<e:inputText id="CUST_NO" name="CUST_NO" value="284649" width="${form_CUST_NO_W}" maxLength="${form_CUST_NO_M}" disabled="${form_CUST_NO_D}" readOnly="${form_CUST_NO_RO}" required="${form_CUST_NO_R}" />
				</e:field>
				<e:label for="CUST_NAME" title="${form_CUST_NAME_N}" />
				<e:field>
				<e:inputText id="CUST_NAME" name="CUST_NAME" value="" width="${form_CUST_NAME_W}" maxLength="${form_CUST_NAME_M}" disabled="${form_CUST_NAME_D}" readOnly="${form_CUST_NAME_RO}" required="${form_CUST_NAME_R}" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="DAMDANG_NAME" title="${form_DAMDANG_NAME_N}" />
				<e:field>
				<e:inputText id="DAMDANG_NAME" name="DAMDANG_NAME" value="" width="${form_DAMDANG_NAME_W}" maxLength="${form_DAMDANG_NAME_M}" disabled="${form_DAMDANG_NAME_D}" readOnly="${form_DAMDANG_NAME_RO}" required="${form_DAMDANG_NAME_R}" />
				</e:field>
				<e:label for="PO_GUBUN" title="${form_PO_GUBUN_N}"/>
				<e:field>
				<e:select id="PO_GUBUN" name="PO_GUBUN" value="" options="${poGubunOptions}" width="${form_PO_GUBUN_W}" disabled="${form_PO_GUBUN_D}" readOnly="${form_PO_GUBUN_RO}" required="${form_PO_GUBUN_R}" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        </e:buttonBar>


        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>