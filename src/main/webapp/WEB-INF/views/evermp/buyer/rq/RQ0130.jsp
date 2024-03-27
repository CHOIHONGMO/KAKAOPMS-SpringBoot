<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
		var grid;
		var baseUrl = "/evermp/buyer/rq";

		function init() {
			grid = EVF.C("grid");

			grid.setProperty('shrinkToFit', true);                 // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty('rowNumbers', ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty('sortable', ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty('panelVisible', ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty('enterToNextRow', ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty('acceptZero', ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty('multiSelect', ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			EVF.C('PROGRESS_CD').removeOption('2300');
			EVF.C('PROGRESS_CD').removeOption('2350');
			EVF.C('PROGRESS_CD').removeOption('2355');

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
					case "VENODR_CD":
						if(value!="") {
							var param = {


								detailView: true
							};
						}
						break;
					case "QTA_NUM":
						if(value!="") {
							var param = {
								QTA_NUM: value,
								RFX_NUM: grid.getCellValue(rowId, "RFX_NUM"),
								RFX_CNT: grid.getCellValue(rowId, "RFX_CNT"),
								BUYER_CD: grid.getCellValue(rowId, "BUYER_CD"),
								VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
								detailView: true
							};
							everPopup.openPopupByScreenId("QT0120", 1100, 900, param);
						}
						break;
				}
			});

			doSearch();
		}

		function doSearch() {
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([grid]);
			store.load(baseUrl + '/RQ0130/doSearch', function() {
				if(grid.getRowCount() == 0){
					EVF.alert("${msg.M0002 }");
				}
			});
		}


	</script>

	<e:window id="RQ0130" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="3" onEnter="doSearch">
			<e:row>
				<e:label for="" title="">
					<select class="custom-select" id="SEL_DATE" name="SEL_DATE">
						<option value="REQ" selected>${RQ0130_001}</option>
						<option value="END">${RQ0130_002}</option>
						<option value="STR">${RQ0130_003}</option>
					</select>
				</e:label>
				<e:field>
					<e:inputDate id="FROM_DATE" name="FROM_DATE" toDate="TO_DATE" value="${FROM_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="TO_DATE" name="TO_DATE" fromDate="FROM_DATE" value="${TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
				</e:field>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" value="" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="36%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" placeHolder="${RQ0130_004}"/>
					<e:text>  /  </e:text>
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" placeHolder="${RQ0130_005}" />
				</e:field>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}" />
				<e:field>
					<e:search id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" width="40%" maxLength="${form_CTRL_USER_ID_M}" onIconClick="${form_CTRL_USER_ID_D ? 'everCommon.blank' : 'openCtrlUser'}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="${RQ0130_006}"/>
					<e:inputText id="CTRL_USER_NM" name="CTRL_USER_NM" value="${ses.userNm}" width="60%" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" placeHolder="${RQ0130_007}"/>
				</e:field>
				<e:label for="RFX_TYPE" title="${form_RFX_TYPE_N}"/>
				<e:field>
					<e:select id="RFX_TYPE" name="RFX_TYPE" value="" options="${rfxTypeOptions}" width="${form_RFX_TYPE_W}" disabled="${form_RFX_TYPE_D}" readOnly="${form_RFX_TYPE_RO}" required="${form_RFX_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${PROGRESS_CD_Options}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar width="100%" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
	</e:window>
</e:ui>
