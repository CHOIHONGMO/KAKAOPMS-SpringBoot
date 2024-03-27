<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">

		var grid = {};
		var baseUrl = "/eversrm/system/task/";
		var currentRow;

		function init() {

			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				currentRow = rowid;
				if (celname === "CTRL_CD") {
					doTaskSearch("selectTaskId");
				}
				<%--
                if (celname === "ITEM_CLS1_NM") {
                    var param = {
                        COMMON_ID: "SP0015",
                        callBackFunction: "setItemClassGrid"
                    }
                    everPopup.openCommonPopup(param, "SP0015");
                }
                --%>
			});

			grid.addRowEvent(function() {
				var buyerCd = EVF.C('BUYER_CD').getValue();
				grid.addRow([{
					'BUYER_CD' : buyerCd
				}]);
			});

			grid.delRowEvent(function() {
				if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
					alert("${msg.M0004}");
					return;
				}
				grid.delRow();
			});

			grid.excelExportEvent({
				allCol : "${excelExport.allCol}",
				selRow : "${excelExport.selRow}",
				fileType : "${excelExport.fileType }",
				fileName : "${screenName }",
				excelOptions : {
					imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
					,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
					,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
					,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
					,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
				}
			});

			grid.setProperty('shrinkToFit', true);

			doSearch();
		}

		function doSearch() {

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + 'taskItemMapping/selectTaskItemMapping', function() {
				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				}
			});
		}

		function doSave() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}
			if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'taskItemMapping/saveTaskItemMapping', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function doDelete() {

			if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
				alert("${msg.M0004}");
				return;
			}

			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + 'taskItemMapping/deleteTaskItemMapping', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}

		function setItemClassGrid(data) {
			grid.setCellValue(currentRow, 'ITEM_CLS1', data.ITEM_CLS1);
			grid.setCellValue(currentRow, 'ITEM_CLS1_NM', data.ITEM_CLSN1);
			grid.setCellValue(currentRow, 'ITEM_CLS2', data.ITEM_CLS2);
			grid.setCellValue(currentRow, 'ITEM_CLS2_NM', data.ITEM_CLSN2);
			grid.setCellValue(currentRow, 'ITEM_CLS3', data.ITEM_CLS3);
			grid.setCellValue(currentRow, 'ITEM_CLS3_NM', data.ITEM_CLSN3);
		}

		function doTaskSearchByForm() {
			doTaskSearch("selectTaskIdForm");
		}

		function doTaskSearch(handler) {
			var buyerCd = grid.getCellValue(currentRow, 'BUYER_CD');

			var param = {
				BUYER_CD: buyerCd,
				callBackFunction: handler
			};
			everPopup.openCommonPopup(param, "SP0003");
		}

		function selectTaskId(data) {

			if('${_gridType}' == 'RG') {
				grid.setCellValue(currentRow, 'CTRL_CD', data['CTRL_CD']);
				grid.setCellValue(currentRow, 'CTRL_NM', data['CTRL_NM']);
				grid.setCellValue(currentRow, 'BUYER_CD', data['BUYER_CD']);
			} else {
				grid.setCellValue(currentRow, 'CTRL_CD', data['CTRL_CD']['text']);
				grid.setCellValue(currentRow, 'CTRL_NM', data['CTRL_NM']);
				grid.setCellValue(currentRow, 'BUYER_CD', data['BUYER_CD']);
			}
		}

		function selectTaskIdForm(data) {
			EVF.C("CTRL_NM").setValue(data.CTRL_NM);
		}

		function onChangeItemClass() {

			var id = this.getID();
			var store = new EVF.Store();

			switch(id) {
				case 'ITEM_CLS1':
					EVF.C('ITEM_CLS3').resetOption();
					EVF.C('ITEM_CLS3').appendOption('-----------------', '');
					store.setParameter('type', '2');
					store.load(baseUrl+'BSYT_030/getItemClassList', function() {
						EVF.C('ITEM_CLS2').setOptions(this.getParameter('itemClassList'));
					}, false);
					break;
				case 'ITEM_CLS2':
					store.setParameter('type', '3');
					store.load(baseUrl+'BSYT_030/getItemClassList', function() {
						EVF.C('ITEM_CLS3').setOptions(this.getParameter('itemClassList'));
					}, false);
					break;
			}

		}

	</script>
	<e:window id="BSYT_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" width="100%" useTitleBar="false" labelWidth="${labelNarrowWidth }" onEnter="doSearch">
			<e:row>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N }" />
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" options="${refBuyerCode}" usePlaceHolder="false" width="${inputTextWidth }" required="${form_BUYER_CD_R }" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" />
				</e:field>
				<e:label for="CTRL_NM" title="${form_CTRL_NM_N }" />
				<e:field>
					<e:search id="CTRL_NM" name="CTRL_NM" width="${inputTextWidth }" required="${form_CTRL_NM_R }" disabled="${form_CTRL_NM_D }" onIconClick="doTaskSearchByForm" readOnly="${form_CTRL_NM_RO }" maxLength="${form_CTRL_NM_M}"/>
				</e:field>
				<e:label for="ITEM_CLS1" title="${form_ITEM_CLS1_N }"></e:label>
				<e:field>
					<e:select id="ITEM_CLS1" name="ITEM_CLS1" options="${itemClass1List}" label="${form_ITEM_CLS1_N }" width="${inputTextWidth }" required="${form_ITEM_CLS1_R }" readOnly="${form_ITEM_CLS1_RO }" disabled="${form_ITEM_CLS1_D }" />
				</e:field>
				<e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
				<e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />

			</e:row>
			<%--
            <e:row>
                <e:label for="ITEM_CLS2" title="${form_ITEM_CLS2_N }"></e:label>
                <e:field>
                    <e:select id="ITEM_CLS2" name="ITEM_CLS2" label="${form_ITEM_CLS2_N }" width="${inputTextWidth }" required="${form_ITEM_CLS2_R }" readOnly="${form_ITEM_CLS2_RO }" disabled="${form_ITEM_CLS2_D }" onChange="onChangeItemClass" />
                </e:field>
                <e:label for="ITEM_CLS3" title="${form_ITEM_CLS3_N }"></e:label>
                <e:field>
                    <e:select id="ITEM_CLS3" name="ITEM_CLS3" label="${form_ITEM_CLS3_N }" width="${inputTextWidth }" required="${form_ITEM_CLS3_R }" readOnly="${form_ITEM_CLS3_RO }" disabled="${form_ITEM_CLS3_D }" onChange="onChangeItemClass" />
                </e:field>
            </e:row>
             --%>
		</e:searchPanel>
		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
			<e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
			<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
		</e:buttonBar>
		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	</e:window>
</e:ui>