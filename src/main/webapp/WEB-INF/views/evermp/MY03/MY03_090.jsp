<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var baseUrl = "/evermp/MY03/";
		var grid;
		var custSeq=1;
		function init() {

			grid = EVF.C("grid");
			grid.setColMerge(['RELAT_YN','CUST_CD','CUST_NM','YEAR']);
			grid._gvo.setColumnProperty("PLANT_NM", "mergeRule", {criteria: "values['CUST_CD'] + values['PLANT_CD'] + value"})
			grid._gvo.setColumnProperty("RESULT_DEAL_CD", "mergeRule", {criteria: "values['CUST_CD'] + values['PLANT_CD'] + value"})

			grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

			});

			grid.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, value, oldValue) {

				 if(colIdx == 'CUST_NM'){
					for(var i in grid.getAllRowValue()){

						if(grid.getCellValue(rowIdx, 'NEW_CHECK_SEQ') == grid.getCellValue(i, 'NEW_CHECK_SEQ') ){

							grid.setCellValue(i, 'CUST_NM', value);
							grid.checkRow(i,false);
						}
					}
				}else if(colIdx == 'PLANT_NM'){
					for(var i in grid.getAllRowValue()){
						if(grid.getCellValue(rowIdx, 'NEW_CHECK_SEQ') == grid.getCellValue(i, 'NEW_CHECK_SEQ') ){

							grid.setCellValue(i, 'PLANT_NM', value);
							grid.checkRow(i,false);
						}
					}
				}else if(colIdx == 'YEAR'){
					for(var i in grid.getAllRowValue()){
						if(grid.getCellValue(rowIdx, 'NEW_CHECK_SEQ') == grid.getCellValue(i, 'NEW_CHECK_SEQ') ){

							grid.setCellValue(i, 'YEAR', value);
							grid.checkRow(i,false);
						}
					}
				}else if(colIdx == 'MANAGE_ID'){
					if(grid.getCellValue(rowIdx, 'CUST_CD') == 'NEW'){
						if(EVF.isEmpty(grid.getCellValue(rowIdx, 'CUST_NM')) || EVF.isEmpty(grid.getCellValue(rowIdx, 'PLANT_NM'))){
							grid.setCellValue(rowIdx, 'MANAGE_ID', '');
							return alert("신규 등록일시 먼저 고객사명 및 사업장명 기입 바랍니다.");
						}
					}
				}

			});
			grid.addRowEvent(function() {
				var comboList = ${comboResult};
				var aa = [];
				for (var i=0; i<comboList.length; i++){
					let addParam={
							 "RELAT_YN"  		      : "신규"
// 						   , "YEAR" 	 		      : EVF.V("YEAR")
						   , "MANAGE_ID" 		 	  : EVF.V("MANAGE_ID")
						   , "CUST_CD"   		 	  : "NEW"
						   , "PLANT_CD"  		 	  : "NEW"
						   , "NEW_CHECK_SEQ"  		  : custSeq
						   , "RESULT_DEAL_CD"    	  : comboList[i].RESULT_DEAL_CD
						   , "RESULT_ITEM_TYPE"  	  : comboList[i].RESULT_ITEM_TYPE
						   , "MONTH_1_SALE_PLAN_AMT"  : 0
						   , "MONTH_2_SALE_PLAN_AMT"  : 0
						   , "MONTH_3_SALE_PLAN_AMT"  : 0
						   , "MONTH_4_SALE_PLAN_AMT"  : 0
						   , "MONTH_5_SALE_PLAN_AMT"  : 0
						   , "MONTH_6_SALE_PLAN_AMT"  : 0
						   , "MONTH_7_SALE_PLAN_AMT"  : 0
						   , "MONTH_8_SALE_PLAN_AMT"  : 0
						   , "MONTH_9_SALE_PLAN_AMT"  : 0
						   , "MONTH_10_SALE_PLAN_AMT" : 0
						   , "MONTH_11_SALE_PLAN_AMT" : 0
						   , "MONTH_12_SALE_PLAN_AMT" : 0
			  			}

					grid.addRow(addParam);
					grid.setCellReadOnly(grid.getAllRowId().length-1, "CUST_NM", false);
					grid.setCellReadOnly(grid.getAllRowId().length-1, "YEAR", false);
					grid.setCellReadOnly(grid.getAllRowId().length-1, "PLANT_NM", false);
				}
				custSeq++;

			});
			grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});

			var lookupKeys = [];
			var lookupValues = [];
			var gridCustMngIdOptions = ${custMngId};
			for(var i in gridCustMngIdOptions) {
				lookupKeys.push(gridCustMngIdOptions[i].value);
				lookupValues.push(gridCustMngIdOptions[i].text);
			}

			grid._gvo.setLookups([{
				"id": "lookup",
				"levels": 1,
				"keys": lookupKeys,
				"values": lookupValues
			}]);

			var Col = grid._gvo.columnByField("MANAGE_ID");
			Col.lookupDisplay = true;
			Col.lookupSourceId = "lookup";
			Col.lookupKeyFields = ["MANAGE_ID"];
			grid._gvo.setColumn(Col);

			EVF.C("RELAT_YN").addOption("신규", "신규");
		}

		function doSearch() {

			var store = new EVF.Store();
			if(!store.validate()) { return; }
// 			store.setAsync(false);
			store.setGrid([grid]);
			store.setParameter("searchType", "F");
			store.setParameter("manageId", EVF.V("MANAGE_ID"));
			store.load(baseUrl + 'my03090_doSearch', function() {

				if(grid.getRowCount() == 0){
					alert("${msg.M0002 }");
				} else {

					var val = {visible: true, count: 1, height: 40};
					var footerTxt = {
						styles: {
							textAlignment: "center",
							font: "굴림,12",
							background:"#ffffff",
							foreground:"#FF0000",
							fontBold: true
						},
						text: ["합    계"]
					};
					var footerSum = {
						styles: {
							textAlignment: "far",
							suffix: " ",
							background:"#ffffff",
							foreground:"#FF0000",
							numberFormat: "###,###.##",
							fontBold: true
						},
						text: "0",
						expression: ["sum"],
						groupExpression: "sum"
					};

					grid.setProperty("footerVisible", val);
					grid.setRowFooter("PROGRESS_CD", footerTxt);
					grid.setRowFooter("MONTH_1_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_2_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_3_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_4_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_5_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_6_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_7_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_8_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_9_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_10_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_11_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_12_SALE_PLAN_AMT", footerSum);
					grid.setRowFooter("MONTH_TOT_SALE_PLAN_AMT", footerSum);


				}
			});
		}

		function doSave(data) {

			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
			var progressCd = this.getData();
			var confirmMsg = "";
			if(progressCd =='P'){
				confirmMsg="저장 하시겠습니까?"
			}else if(progressCd =='E'){
				confirmMsg="확정 하시겠습니까?"
			}else{
				confirmMsg="숨김 처리 하시겠습니까?"
			}
			if(progressCd !='C'){

				if (!grid.validate().flag) { return alert(grid.validate().msg); }


			}


			if(confirm(confirmMsg)) {
				var store = new EVF.Store();
				store.setGrid([grid]);
				store.getGridData(grid, 'sel');
				store.setParameter("progressCd", progressCd);
				store.load(baseUrl + 'my03090_doSave', function () {
					alert(this.getResponseMessage());
					doSearch();
				});
			}
		}

		function searchCustCd() {
			var param = {
				callBackFunction: "selectCustCd"
			};
			everPopup.openCommonPopup(param, 'SP0067');
		}

		function selectCustCd(dataJsonArray) {
			EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
			EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
		}

		function cleanCustCd() {
			EVF.C("CUST_CD").setValue("");
		}

	</script>

	<e:window id="MY03_090" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:inputHidden id="ROW_NUM" name="ROW_NUM"/>
            <e:row>
				<e:label for="YEAR" title="${form_YEAR_N}"/>
				<e:field>
					<e:select id="YEAR" name="YEAR" value="${thisYear}" options="${yearOptions}" width="${form_YEAR_W}" disabled="${form_YEAR_D}" readOnly="${form_YEAR_RO}" required="${form_YEAR_R}" placeHolder="" />
				</e:field>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onKeyDown="cleanCustCd" />
				</e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="RELAT_YN" title="${form_RELAT_YN_N}"/>
				<e:field>
					<e:select id="RELAT_YN" name="RELAT_YN" value="" options="${relatYnOptions}" width="${form_RELAT_YN_W}" disabled="${form_RELAT_YN_D}" readOnly="${form_RELAT_YN_RO}" required="${form_RELAT_YN_R}" placeHolder="" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field colSpan="3">
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="E" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" useMultipleSelect="true" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:text style="font-weight: bold;color: blue;">&nbsp;&nbsp;담당자&nbsp;&nbsp;</e:text>
			<e:select id="MANAGE_ID" name="MANAGE_ID" value="" options="${custMngId}" width="120px" disabled="${form_MANAGE_ID_D}" readOnly="${form_MANAGE_ID_RO}" required="${form_MANAGE_ID_R}" placeHolder="" onChange="doSearch" />
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N}" disabled="${Save_D}" visible="${Save_V}" onClick="doSave" data="T" />
            <e:button id="Request" name="Request" label="${Request_N}" disabled="${Request_D}" visible="${Request_V}" onClick="doSave" data="P" />
            <e:button id="Confirm" name="Confirm" label="${Confirm_N}" disabled="${Confirm_D}" visible="${Confirm_V}" onClick="doSave" data="E" />
        	<e:button id="Cancle" name="Cancle" label="${Cancle_N}" onClick="doSave" disabled="${Cancle_D}" visible="${Cancle_V}" data="C" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
