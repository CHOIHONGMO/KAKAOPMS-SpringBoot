<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid;
		var baseUrl = "/evermp/vendor/qt";

		function init() {
			grid = EVF.C("grid");
			gridT = EVF.C("gridT");
			grid.setProperty('shrinkToFit', false);                 // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty('multiSelect', ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${fullScreenName}"
			});

			grid.cellClickEvent(function(rowId, colId, value) {

				if (colId =="QTA_NUM" ) {
					var param = {
						 QTA_NUM     : grid.getCellValue(rowId,'QTA_NUM')
						,popupFlag : true
						,detailView : true
					};
					everPopup.openPopupByScreenId('QT0320', 1200, 800, param);
				}else if(colId == "GIVEUP_RMK"){
					var param = {
						  rowId: rowId
						, havePermission: false
						, screenName: '포기사유'
						, callBackFunction: ''
						, TEXT_CONTENTS: grid.getCellValue(rowId, "FORCE_CLOSE_RMK")
						, detailView: true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}else if(colId === 'RFX_SUBJECT'){
					grid.checkAll(false);
					grid.checkRow(rowId, true);
					
				   	var store = new EVF.Store();
                   	store.setParameter("RFX_NUM", grid.getCellValue(rowId, 'RFX_NUM'));
                   	store.setParameter("RFX_CNT", grid.getCellValue(rowId, 'RFX_CNT'));
                   	store.setParameter("BUYER_CD", grid.getCellValue(rowId, 'BUYER_CD'));
                   	store.setGrid([gridT]);
                   	store.load(baseUrl + "/QT0330/doSearchT", function () {
						
                   	}, false);
				 }

			});

			gridT.cellClickEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){
				if(colIdx === 'B_ATT_FILE_CNT') {
					param = {
						  detailView		: true
						, attFileNum		: gridT.getCellValue(rowIdx, "B_ATT_FILE_NUM")
						, rowId				: rowIdx
						, callBackFunction	: ""
						, bizType			: "RQ"
						, fileExtension		: "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'ATT_FILE_CNT'){
					param = {
						 detailView			: true
						,attFileNum			: gridT.getCellValue(rowIdx, "ATT_FILE_NUM")
						, havePermission	:true
						,rowId				: rowIdx
						,callBackFunction	: "callback_setAttFile"
						,bizType			: "QT"
						,fileExtension		: "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'RMK'){
					var param = {
						  rowId				: rowIdx
						, havePermission	: true
						, screenName		: '협력사 비고'
						, TEXT_CONTENTS		: gridT.getCellValue(rowIdx, "RMK")
						, detailView		: true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}

			});
			//grid.setColIconify('GIVEUP_RMK', 'GIVEUP_RMK', 'comment', true);
			//멀티셀렉트 박스에서 처음 조회시 전체값 가져오기
// 			var values = $.map($('#PR_BUYER_CD option'), function(e) { return e.value; });
// 			EVF.V('PR_BUYER_CD',values.join(','));

			doSearch();
		}

		function doSearch() {
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([grid]);
			store.load(baseUrl + '/QT0330/doSearch', function() {
				if(grid.getRowCount() == 0){
					EVF.alert("${msg.M0002 }");
				}
				gridT.delAllRow();
			});
		}

	</script>

	<e:window id="QT0330" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2" onEnter="doSearch">
			<e:row>
				<%--견적마감일--%>
				<e:label for="RFX_FROM_DATE_START" title="${form_RFX_FROM_DATE_START_N}"/>
				<e:field>
					<e:inputDate id="RFX_FROM_DATE_START" name="RFX_FROM_DATE_START" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_START_R}" disabled="${form_RFX_FROM_DATE_START_D}" readOnly="${form_RFX_FROM_DATE_START_RO}" />
					<e:text>&nbsp;~&nbsp;</e:text>
					<e:inputDate id="RFX_FROM_DATE_END" name="RFX_FROM_DATE_END" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_END_R}" disabled="${form_RFX_FROM_DATE_END_D}" readOnly="${form_RFX_FROM_DATE_END_RO}" />
				</e:field>
				<%--견적요청명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="40%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--선정여부
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				--%>
			</e:row>
		</e:searchPanel>

		<e:buttonBar width="100%" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="400px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
	    <e:buttonBar id="btnB" align="right" width="100%">
        </e:buttonBar>
		<e:gridPanel id="gridT" name="gridT" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}" />

	</e:window>
</e:ui>
