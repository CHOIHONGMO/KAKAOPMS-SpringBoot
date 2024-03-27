<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid;
		var baseUrl = "/eversrm/vendor/qt";

		function init() {
			grid = EVF.C("grid");

			grid.setProperty('shrinkToFit', true);                 // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty('multiSelect', ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			//Cell Click Event
			grid.cellClickEvent(function(rowId, colId, value) {

				switch (colId) {
					case "RFX_NUM":
						if(value!="") {
							var param = {
								RFX_NUM: value,
								RFX_CNT: grid.getCellValue(rowId, "RFX_CNT"),
								BUYER_CD: grid.getCellValue(rowId, "BUYER_CD"),
								detailView: true
							};
							everPopup.openPopupByScreenId("RQ0110", 1100, 900, param);
						}
						break;
					case "QTA_NUM":
						if(value!="") {
							var param = {


								detailView: true
							};
							everPopup.openPopupByScreenId("QT0120", 1100, 900, param);
						}
						break;
					case "GIVEUP_RMK":
						if(value!="") {
							var param = {
								title: "포기사유",
								message: value,
								detailView: true
							};
							everPopup.commonTextInput(param);
						}
						break;
				}
			});

			grid.setColIconify('GIVEUP_RMK', 'GIVEUP_RMK', 'comment', true);

			//---------------------------TEST DATA-----------------------------------
			grid.addRow({"RFX_NUM": "TEST-DATA", "RFX_CNT": 0, "QTA_NUM" : "TEST-DATA", "GIVEUP_RMK" : "test text test text", "BUYER_CD" : "1000"});
			//---------------------------TEST DATA-----------------------------------


			//doSearch();

		}

		function doSearch() {
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([grid]);
			store.load(baseUrl + '/QT0130/doSearch', function() {
				if(grid.getRowCount() == 0){
					EVF.alert("${msg.M0002 }");
				}
			});
		}


	</script>

	<e:window id="QT0130" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="3" onEnter="doSearch">
			<e:row>
				<e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="FROM_DATE" name="FROM_DATE" toDate="TO_DATE" value="${FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="TO_DATE" name="TO_DATE" fromDate="FROM_DATE" value="${TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>

			</e:row>
			<e:row>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				</e:field>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field>
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" placeHolder="${QT0220_004}"/>
				</e:field>
				<e:label for="SLT_FLAG" title="${form_SLT_FLAG_N}"/>
				<e:field>
					<e:select id="SLT_FLAG" name="SLT_FLAG" value="" options="${sltFlagOptions}" width="${form_SLT_FLAG_W}" disabled="${form_SLT_FLAG_D}" readOnly="${form_SLT_FLAG_RO}" required="${form_SLT_FLAG_R}" placeHolder="" />
				</e:field>

			</e:row>
		</e:searchPanel>

		<e:buttonBar width="100%" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>
