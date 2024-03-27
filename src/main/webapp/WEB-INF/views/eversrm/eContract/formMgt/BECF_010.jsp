<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%--
 - 계약서식의 콤보 수정하는 방법:
   econt_plugin.js 파일을 여신 후 기존의 소스에 하나씩 더 추가하거나 삭제하시면 됩니다.
--%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid = {};
		var delRows = [];
		var baseUrl = "/eversrm/eContract/formMgt/BECF_010/";

		function init() {
			grid = EVF.C("grid");
			grid.setProperty('singleSelect', true);
			grid.setProperty('panelVisible', ${panelVisible});

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {

		        if (celname != 'multiSelect') {
                    grid.checkRow(rowid, true, true, false);
		        }
			});

/* 			grid.delRowEvent(function() {
				if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}

				if (!confirm("${msg.M0009 }"))
					return;

				var rowData = grid.getSelRowId();
				for ( var nRow in rowData) {

					if (grid.getCellValue(rowData[nRow], 'INSERT_FLAG') == 'R') {
						grid.setCellValue(rowData[nRow], 'INSERT_FLAG', 'D');
						delRows.push(grid.getRowValue(nRow));
					}
				}

				grid.delRow();
			});
 */
			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth : 0.12, // 이미지의 너비.
					imgHeight : 0.26, // 이미지의 높이.
					colWidth : 20, // 컬럼의 넓이.
					rowSize : 500, // 엑셀 행에 높이 사이즈.
					attachImgFlag : false
				// 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부
				}
			});

		 	doSearch();
		}

		function doSearch() {
			var store = new EVF.Store();
			if (!store.validate()) {
				return;
			}


			if((EVF.C("REG_DATE_FROM").getValue()=='' && EVF.C("REG_DATE_TO").getValue()!='') ||
				(EVF.C("REG_DATE_FROM").getValue()!=''&& EVF.C("REG_DATE_TO").getValue()==''))
			 {
			    alert("${BECF_010_002 }");
			 return;
			}

			store.setGrid([ grid ]);
			store.load(baseUrl + 'doSearch', function() {
				if (grid.getRowCount() == 0) {
					alert("${msg.M0002 }");
				}
			});
		}

		function doDelete() {

            if(!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
			if (!confirm("${msg.M0013 }")) {
				return;
			}

			var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
			store.load(baseUrl + 'doDelete', function() {
				alert(this.getResponseMessage());
				doSearch();
				delRows = [];
			});
		}

		function doCreate() {
			everPopup.openPopupByScreenId('BECF_020', 1200, 800, {
				callBackFunction : callBackFunction,
				detailView : false
			});
		}

		function doCreateNew() {
			everPopup.openPopupByScreenId('BECF_040', 1000, 700, {
				callBackFunction : callBackFunction,
				detailView : false
			});
		}

		function doChange() {
			var gridData = grid.getSelRowValue();
			if (gridData.length > 0) {
				var valid = grid.validate();
				if (!valid.flag) {
					alert(valid.msg);
					return;
				}
			} else if (gridData.length == 0) {
				alert('${msg.M0004 }'); //${BECF_010_CHOOSE_DATA}
				return;
			} else if (gridData.length > 1) {
				alert("${msg.M0006}");
				return;
			}

			var formNum = gridData[0]['FORM_NUM'];
			var useFlag = gridData[0]['USE_FLAG'];
			/*
			 var rowData = grid.getSelRowId();
			 for (var nRow in rowData) {
			 formNum = grid.getCellValue(nRow, 'FORM_NUM');
			 }
			 */
		var param = {
					    callBackFunction : callBackFunction,
						formNum : formNum,
						useFlag :useFlag,
						detailView : false
					};

			 everPopup.openPopupByScreenId('BECF_040', 1200, 800, param );
		}

		function callBackFunction() {

		}
	</script>

	<e:window id="BECF_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
			<e:row>
			<e:label for="FORM_TYPE" title="${form_FORM_TYPE_N}"/>
			<e:field>
				<e:select id="FORM_TYPE" name="FORM_TYPE" value="" options="${formTypeOptions}" width="100%" disabled="${form_FORM_TYPE_D}" readOnly="${form_FORM_TYPE_RO}" required="${form_FORM_TYPE_R}" placeHolder="" />
			</e:field>
			<e:label for="FORM_GUBUN" title="${form_FORM_GUBUN_N}"/>
			<e:field>
				<e:select id="FORM_GUBUN" name="FORM_GUBUN" value="" options="${formGubunOptions}" width="100%" disabled="${form_FORM_GUBUN_D}" readOnly="${form_FORM_GUBUN_RO}" required="${form_FORM_GUBUN_R}" placeHolder="" />
			</e:field>
			<e:label for="FORM_NM" title="${form_FORM_NM_N }" />
			<e:field>
				<e:inputText id="FORM_NM" style="${imeMode}" name="FORM_NM" width="100%" required="${form_FORM_NM_R }" disabled="${form_FORM_NM_D }" value="" readOnly="${form_FORM_NM_RO }" maxLength="${form_FORM_NM_M}" />
			</e:field>
			</e:row>
			<e:row>
			<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N }" />
			<e:field>
				<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="" width="${inputDateWidth}" required="${form_REG_DATE_FROM_R }" readOnly="${form_REG_DATE_FROM_RO }" disabled="${form_REG_DATE_FROM_D }" datePicker="true" />
                <e:text>~</e:text>
				<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="" width="${inputDateWidth}" required="${form_REG_DATE_TO_R }" readOnly="${form_REG_DATE_TO_RO }" disabled="${form_REG_DATE_TO_D }" datePicker="true" />
			</e:field>
			<e:label for="FORM_USE_FLAG" title="${form_FORM_USE_FLAG_N}"/>
			<e:field colSpan="3">
				<e:select id="FORM_USE_FLAG" name="FORM_USE_FLAG" value="" options="${formUseFlagOptions}" width="${form_FORM_USE_FLAG_W}" disabled="${form_FORM_USE_FLAG_D}" readOnly="${form_FORM_USE_FLAG_RO}" required="${form_FORM_USE_FLAG_R}" placeHolder="" />
			</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
			<!--
			<e:button id="doCreate" name="doCreate" label="${doCreate_N }" disabled="${doCreate_D }" onClick="doCreate" />
			-->
			<e:button id="doCreateNew" name="doCreateNew" label="${doCreateNew_N}" onClick="doCreateNew" disabled="${doCreateNew_D}" visible="${doCreateNew_V}"/>
			<e:button id="doChange" name="doChange" label="${doChange_N }" disabled="${doChange_D }" onClick="doChange" />
			<%-- <e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="doDelete" />  --%>
		</e:buttonBar>

	   <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>

</e:ui>
