<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script>

		var grid;
		var baseUrl = "/evermp/vendor/bq";

		function init(){

			grid = EVF.getComponent("grid");
			grid.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${fullScreenName}"
			});

			grid.cellClickEvent(function(rowIdx, colIdx, value, iRow, iCol){
				if(colIdx === 'RFX_NUM' && value !== '') {
					param = {
						  BUYER_CD	: grid.getCellValue(rowIdx, 'BUYER_CD')
						, RFX_NUM	: grid.getCellValue(rowIdx, 'RFX_NUM')
						, RFX_CNT	: grid.getCellValue(rowIdx, 'RFX_CNT')
						, detailView: true
					}
					everPopup.openPopupByScreenId('BQ0310P01', 1200, 800, param);
				} else if(colIdx === 'QTA_NUM' && value !== ''){
					param = {
						 BUYER_CD	: grid.getCellValue(rowIdx, 'BUYER_CD')
						,RFX_NUM 	: grid.getCellValue(rowIdx, 'RFX_NUM')
						,RFX_CNT 	: grid.getCellValue(rowIdx, 'RFX_CNT')
						,QTA_NUM 	: grid.getCellValue(rowIdx, 'QTA_NUM')
						,QTA_CNT 	: grid.getCellValue(rowIdx, 'QTA_CNT')
						,VENDOR_CD 	: "${ses.companyCd}"
						,detailView : true
					}
					everPopup.openPopupByScreenId('BQ0320', 1200, 900, param);
				}else if(colIdx === 'GIVEUP_RMK' && value !== ''){
					var param = {
						  rowId				: rowIdx
						, havePermission	: false
						, screenName		: '포기 사유'
						, callBackFunction	: ''
						, TEXT_CONTENTS		: grid.getCellValue(rowIdx, "GIVEUP_RMK")
						, detailView		: true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}
			});

			// DashBoard(WorkList) 통해서 들어왔을 경우 파라미터 셋팅
			if ('${dashBoardFlag}' === 'Y') {
				/*EVF.V('RFX_FROM_DATE', '${param.FROM_DATE}');
				EVF.V('RFX_TO_DATE', '${param.TO_DATE}');*/
				EVF.V('PROGRESS_CD', '${PROGRESS_CD}');
			}

			doSearch();
		}

		function doSearch(){
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + "/BQ0310/doSearch",function(){
				if (!grid.isExistsRow()) {
					return alert("${msg.M0002}");
				}
			});
		}

		//접수
		function doReceipt(){
			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

			var selected = grid.getSelRowValue();
			for(var i in selected){
				if(selected[i].ANN_ATTEND_FLAG == 'Y'){
					if(selected[i].ANN_PASS_FLAG != 'Y'){
					 	return alert("${BQ0310_012}"); //참석필수여부 Y 일때 참석여부가 Y 이여만 진행가능.
					}
				}
				if(selected[i].PROGRESS_CD !== '100' ){
					return alert('${BQ0310_0001}'); //미접수 상태만 접수 가능
				}
				if(!checkEndTime(selected[i].RFX_TO_DATE2)){
					return alert("${msg.M0049}"); //마감 시간이 지났습니다.
				}
				if(!checkStartTime(selected[i].RFX_FROM_DATE2)){
					return alert("${BQ0310_0011}"); //입찰시작일 이후 접수가 가능하다.
				}

			}

			if (!confirm("${msg.M0066}")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid,'sel');
			store.load(baseUrl + '/BQ0310/doReceipt', function(){
				if(confirm('${BQ0310_0007}')){
					var selected = grid.getSelRowId();
					for(var i in selected){
						grid.setCellValue(selected[i],'PROGRESS_CD','200');
					}
					doQuote();
				} else {
					doSearch();
				}

			});
		}

		//견적서 작성
		function doQuote(){

			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

			if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
				return alert("${msg.M0006}"); //하나 이상 선택할 수 없습니다.
			}

			var selectedRow = grid.getSelRowValue()[0];

			if(selectedRow.PROGRESS_CD === '100'){
				return alert('${BQ0310_0006}');
			}

			if((selectedRow.PROGRESS_CD != '200' && selectedRow.PROGRESS_CD != '250') ||( selectedRow.PROGRESS_CD_RQ != '2650' && selectedRow.PROGRESS_CD_RQ != '2850')){
				return alert('${msg.M0044}'); //처리할 수 없는 진행상태입니다.
			}

			if(!checkEndTime(selectedRow.RFX_TO_DATE2)){
				return alert("${msg.M0049}"); //마감 시간이 지났습니다.
			}

			var param = {
				 "BUYER_CD"			: selectedRow.BUYER_CD
				,"RFX_NUM"			: selectedRow.RFX_NUM
				,"RFX_CNT"			: selectedRow.RFX_CNT
				,"PROGRESS_CD"		: selectedRow.PROGRESS_CD
				,"QTA_NUM" 			: selectedRow.QTA_NUM
				,"QTA_CNT" 			: selectedRow.QTA_CNT
				,"HIDDEN_QTA_CNT" 	: selectedRow.HIDDEN_QTA_CNT
				,"VENDOR_CD" 		: "${ses.companyCd}"
				,popupFlag			: true
				,detailView			: false
			};
			everPopup.openPopupByScreenId("BQ0320", 1600, 900, param);
		}

		function checkStartTime(datetime){
			var rfxFromDate = Date.parse(datetime);
			var nowtime = new Date();
			//견적이 끝나는 날짜가 현재보다 이전이여야 함
			if (datetime != null || datetime != '') {
				if (nowtime < rfxFromDate) {return false;}
			}
			return true;
		}

		function checkEndTime(datetime) {
			console.log(new Date());
			var rfxToDate = Date.parse(datetime);
			var nowtime = new Date();
			//견적이 끝나는 날짜가 현재보다 이전이여야 함
			if (datetime != null || datetime != '') {
				console.log(nowtime);
				console.log(datetime);
				if (nowtime > rfxToDate) {return false;}
			}
			return true;
		}

		//입찰 포기
		function doWaive(){

			if (!grid.isExistsSelRow()) {
				return EVF.alert("${msg.M0004}");
			}

			var selected = grid.getSelRowValue();
			for(var i in selected){
				if(selected[i].PROGRESS_CD == '300'
					|| selected[i].PROGRESS_CD == '400'
					|| selected[i].PROGRESS_CD_RQ == '2355'){
					return EVF.alert("${BQ0310_0004}");//제출상태가 포기,제출,마감일 경우에는 견적포기를 하실수 없습니다.
				}
				if(!checkEndTime(selected[i].RFX_TO_DATE2)){
					return EVF.alert("${msg.M0049}"); //마감 시간이 지났습니다.
				}

				if(selected[i].PROGRESS_CD === '100' && selected[i].VENDOR_OPEN_TYPE === 'OB'){
					return EVF.alert("${BQ0310_0010}");
				}

			}

			if (!confirm("${msg.M0030}")) return;

			var param = {
				  havePermission	: true
				, screenName		: '입찰포기 사유'
				, callBackFunction	: "callback_setGiveupRMK"
				, TEXT_CONTENTS		: ''
				, detailView		: "${param.detailView}"
			};
			everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);

		}

		function callback_setGiveupRMK(data){
			if(data.trim() == ''){
				return alert("${BQ0310_0005}");
			}

			var selected = grid.getSelRowId();
			for(var i in selected){
				grid.setCellValue(selected[i], 'GIVEUP_RMK', data);
			}

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + '/BQ0310/doWaive', function(){
				alert(this.getResponseMessage());
				doSearch();
			});

		}

	</script>
	<e:window id="BQ0310" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:searchPanel id="form" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--견적시작일--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" toDate="RFX_TO_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
					<e:text>&nbsp; ~ &nbsp;</e:text>
					<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" fromDate="RFX_FROM_DATE" value="${today}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
				</e:field>
				<%--구매담당자--%>
				<e:label for="CTRL_USER_ID" title="${form_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="CTRL_USER_ID" name="CTRL_USER_ID" value="${ses.userId}" options="${ctrlUserNmOptions}" width="${form_CTRL_USER_ID_W}" disabled="${form_CTRL_USER_ID_D}" readOnly="${form_CTRL_USER_ID_RO}" required="${form_CTRL_USER_ID_R}" placeHolder="" />
				</e:field>
				<%--견적요청번호--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="40%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--제출상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
				<%--업체선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form_VENDOR_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1"/>

			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doReceipt" name="doReceipt" label="${doReceipt_N}" onClick="doReceipt" disabled="${doReceipt_D}" visible="${doReceipt_V}"/>
			<e:button id="doQuote" name="doQuote" label="${doQuote_N}" onClick="doQuote" disabled="${doQuote_D}" visible="${doQuote_V}"/>
			<e:button id="doWaive" name="doWaive" label="${doWaive_N}" onClick="doWaive" disabled="${doWaive_D}" visible="${doWaive_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>