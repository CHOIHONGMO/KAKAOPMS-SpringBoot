<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var grid;
		var baseUrl = "/evermp/vendor/qt";
        var progressCd;
        var progressCdHd;
        var rfxEndDate;
		var selRow;

		function init(){
			grid =  EVF.getComponent("grid");
			gridT = EVF.C("gridT");
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
				/*if(colIdx == 'RFX_NUM') {
					param = {
						BUYER_CD: grid.getCellValue(rowIdx, 'BUYER_CD')
						, RFX_NUM: grid.getCellValue(rowIdx, 'RFX_NUM')
						, RFX_CNT: grid.getCellValue(rowIdx, 'RFX_CNT')
						, detailView: true
					}
					everPopup.openPopupByScreenId('RQ0310', 1200, 800, param);
				}else */

				if(colIdx == 'multiSelect' && value =='1'){
					if(selRow != rowIdx) {
						grid.checkRow(selRow, false);
						selRow = rowIdx;
					}
					grid.checkRow(rowIdx, true);

					progressCd   = grid.getCellValue(rowIdx, 'PROGRESS_CD');
					progressCdHd = grid.getCellValue(rowIdx, 'PROGRESS_CD_RQ');
					rfxEndDate   = grid.getCellValue(rowIdx, 'RFX_TO_DATE');

					var store = new EVF.Store();
					store.setParameter("RFX_NUM", grid.getCellValue(rowIdx, 'RFX_NUM'));
					store.setParameter("RFX_CNT", grid.getCellValue(rowIdx, 'RFX_CNT'));
					store.setParameter("BUYER_CD", grid.getCellValue(rowIdx, 'BUYER_CD'));
					store.setGrid([gridT]);
					store.load(baseUrl + "/QT0310/doSearchT", function () {

					}, false);
				} else if(colIdx === 'QTA_NUM' && value !== ''){
					param = {
						 BUYER_CD : grid.getCellValue(rowIdx, 'BUYER_CD')
						,RFX_NUM : grid.getCellValue(rowIdx, 'RFX_NUM')
						,RFX_CNT : grid.getCellValue(rowIdx, 'RFX_CNT')
						,QTA_NUM : grid.getCellValue(rowIdx, 'QTA_NUM')
						,VENDOR_CD : "${ses.companyCd}"
						,detailView : true
					}
					everPopup.openPopupByScreenId('QT0320', 1200, 900, param);
				}else if(colIdx === 'GIVEUP_RMK' && value !== ''){
					var param = {
						rowId: rowIdx
						, havePermission: false
						, screenName: '견적포기 사유'
						, callBackFunction: ''
						, TEXT_CONTENTS: grid.getCellValue(rowIdx, "GIVEUP_RMK")
						, detailView: true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}else if(colIdx === 'RFX_SUBJECT'){
					grid.checkAll(false);
					grid.checkRow(rowIdx, true);

		            progressCd   = grid.getCellValue(rowIdx, 'PROGRESS_CD');
		            progressCdHd = grid.getCellValue(rowIdx, 'PROGRESS_CD_RQ');
		            rfxEndDate   = grid.getCellValue(rowIdx, 'RFX_TO_DATE');

				   	var store = new EVF.Store();
                   	store.setParameter("RFX_NUM", grid.getCellValue(rowIdx, 'RFX_NUM'));
                   	store.setParameter("RFX_CNT", grid.getCellValue(rowIdx, 'RFX_CNT'));
                   	store.setParameter("BUYER_CD", grid.getCellValue(rowIdx, 'BUYER_CD'));
                   	store.setGrid([gridT]);
                   	store.load(baseUrl + "/QT0310/doSearchT", function () {

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
				}else if(colIdx === 'GIVEUP_RMK' && value != ''){
					var param = {
							rowId: rowIdx
							, havePermission: false
							, screenName: '견적포기 사유'
							, callBackFunction: ''
							, TEXT_CONTENTS: grid.getCellValue(rowIdx, "GIVEUP_RMK")
							, detailView: true
						};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}
			});

			// DashBoard 통해서 들어왔을 경우 파라미터 셋팅
			/*if ('${param.dashBoardFlag}' === 'Y') {
				EVF.V('RFX_FROM_DATE', '${param.FROM_DATE}');
				EVF.V('RFX_TO_DATE', '${param.TO_DATE}');
				EVF.V('PROGRESS_CD', '${param.PROGRESS_CD}');
			}*/

			//멀티셀렉트 박스에서 처음 조회시 전체값 가져오기
// 			var values = $.map($('#PR_BUYER_CD option'), function(e) { return e.value; });
// 			EVF.V('PR_BUYER_CD',values.join(','));

			doSearch();
		}

		function doSearch(){
			var store = new EVF.Store();
			if(!store.validate()) { return;}
			store.setGrid([grid]);
			store.load(baseUrl + "/QT0310/doSearch",function(){
				if (!grid.isExistsRow()) {
					return alert("${msg.M0002}");
				}
				gridT.delAllRow();
			});
		}

		//접수
		function doReceipt(){
			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

			var selected = grid.getSelRowValue();
			for(var i in selected){
				if(selected[i].PROGRESS_CD !== '100' ){
					return alert('${QT0310_0001}'); //미접수 상태만 접수 가능
				}
				if(!checkEndTime(selected[i].RFX_TO_DATE)){
					return alert("${msg.M0049}"); //마감 시간이 지났습니다.
				}
			}

			if (!confirm("${msg.M0066}")) return;

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid,'sel');
			store.load(baseUrl + '/QT0310/doReceipt', function(){
				if(confirm('${QT0310_0007}')){
					var selected = grid.getSelRowId();
					for(var i in selected){
						grid.setCellValue(selected[i],'PROGRESS_CD','200');
					}
					doQuote();
				}else{
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
				return alert('${QT0310_0006}');
			}

			if(selectedRow.PROGRESS_CD === '150'){
				return alert('${QT0310_0009}');
			}

			if((selectedRow.PROGRESS_CD != '200' && selectedRow.PROGRESS_CD != '250') || selectedRow.PROGRESS_CD_RQ != '2350'){
				return alert('${msg.M0044}'); //처리할 수 없는 진행상태입니다.
			}

			if(!checkEndTime(selectedRow.RFX_TO_DATE)){
				return alert("${msg.M0049}"); //마감 시간이 지났습니다.
			}

			var param = {
				 "BUYER_CD": selectedRow.BUYER_CD
				,"RFX_NUM": selectedRow.RFX_NUM
				,"RFX_CNT": selectedRow.RFX_CNT
				,"PROGRESS_CD": selectedRow.PROGRESS_CD
				,"QTA_NUM" : selectedRow.QTA_NUM
				,"VENDOR_CD" : "${ses.companyCd}"
				,popupFlag: true
				,detailView: false
			};
			everPopup.openPopupByScreenId("QT0320", 1200, 900, param);
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

			var rfxToDate = Date.parse(datetime);
			var nowtime = new Date();
			//견적이 끝나는 날짜가 현재보다 이전이여야 함
			if (datetime != null || datetime != '') {
				if (nowtime > rfxToDate) {return false;}
			}
			return true;
		}

		//견적 포기
		function doWaive(){
			if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

			var selected = grid.getSelRowValue();
			for(var i in selected){
				if (progressCd == '300' || progressCd == '400' || progressCd == '150' || progressCdHd == '2355')
				{
					return alert("${QT0310_0004}");//제출상태가 제출(300),마감(400),포기(150)일 경우에는 견적포기를 하실수 없습니다.
				}
				if(!checkEndTime(selected[i].RFX_TO_DATE)){
					return alert("${msg.M0049}"); //마감 시간이 지났습니다.
				}
				if (selected[i].GIVEUP_FLAG == "1") {
					cnt++;
				}
			}

			if (!confirm("${msg.M0030}")) return;

			var param = {
					  havePermission: true
					, screenName: '견적포기 사유'
					, callBackFunction: "callback_setGiveupRMK"
					, TEXT_CONTENTS: ''
					, detailView: "${param.detailView}"
				};
			everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
		}

		function callback_setGiveupRMK(data){

			if(data.trim() == ''){
				return alert("${QT0310_0005}");
			}

			var selected = grid.getSelRowId();
			for(var i in selected){
				grid.setCellValue(selected[i], 'GIVEUP_RMK', data);
			}

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
			store.load(baseUrl + '/QT0310/doWaive', function(){
				alert(this.getResponseMessage());
				doSearch();
			});
		}

	</script>
	<e:window id="QT0310" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:searchPanel id="form" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--견적시작일--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" toDate="RFX_TO_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
					<e:text>&nbsp; ~ &nbsp;</e:text>
					<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" fromDate="RFX_FROM_DATE" value="${today}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
				</e:field>
				<%--견적요청번호--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="" width="40%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="" width="60%" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
				<%--제출상태--%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doReceipt" name="doReceipt" label="${doReceipt_N}" onClick="doReceipt" disabled="${doReceipt_D}" visible="${doReceipt_V}"/>
			<e:button id="doQuote" name="doQuote" label="${doQuote_N}" onClick="doQuote" disabled="${doQuote_D}" visible="${doQuote_V}"/>
			<e:button id="doWaive" name="doWaive" label="${doWaive_N}" onClick="doWaive" disabled="${doWaive_D}" visible="${doWaive_V}"/>
		</e:buttonBar>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="400px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	    <e:buttonBar id="btnB" align="right" width="100%" title="품목정보">
        </e:buttonBar>
		<e:gridPanel id="gridT" name="gridT" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridT.gridColData}" />

	</e:window>
</e:ui>