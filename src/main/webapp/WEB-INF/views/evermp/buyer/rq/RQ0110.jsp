<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var gridL;
		var gridR;
		var baseUrl = "/evermp/buyer/rq";

		function init(){
			gridL = EVF.getComponent("gridL");
			gridL.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			gridL.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			gridL.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			gridL.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			gridL.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			gridL.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			gridL.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			gridL.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${screenName }"
			});



			gridL.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){

				switch(colIdx){
					case 'RFX_QT' :
					case 'UNIT_PRC' :
						itemAmtSum(rowIdx);
						break;
				}
				showTotalSum();
			});

			gridL.itemAllCheckedEvent(function(){
				showTotalSum();
			});

			gridL.cellClickEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){
				if(colIdx == 'VENDOR_S') {
					doSearchVendorByItem(rowIdx);
				}else if(colIdx == 'ATT_FILE_CNT'){
					param = {
						detailView: "${param.detailView}",
						attFileNum: gridL.getCellValue(rowIdx, "ATT_FILE_NUM"),
						rowId: rowIdx,
						callBackFunction: "_setAttFile",
						bizType: "RQ",
						fileExtension: "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx == 'RMK'){
					var param = {
						  rowId: rowIdx
						, havePermission: false
						, screenName: '비고'
						, callBackFunction: "_set_gridL_RMK"
						, TEXT_CONTENTS: gridL.getCellValue(rowIdx, "RMK")
						, detailView: "${param.detailView}"
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}
				showTotalSum();
			});



			gridR = EVF.getComponent("gridR");
			gridR.setProperty("shrinkToFit", true);        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			gridR.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			gridR.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			gridR.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			gridR.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			gridR.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			gridR.setProperty("multiSelect", false);        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			gridR.excelExportEvent({
				allItems: "${excelExport.allCol}",
				fileName: "${screenName }"
			});

			if(EVF.V('VENDOR_OPEN_TYPE') != 'QN'){
				$('#doSelectPrivate').css('display','none');
			}



			if('${param.detailView}' != 'true'){

				//구매요청접수에서 넘어온 경우
				if('${param.baseDataType}' == 'PR'){

					if('${prList}' != ''){
						var prList = JSON.parse(${prList});
						for(var i in prList){
							var addParam = {
								ITEM_CD : prList[i].ITEM_CD
								, ITEM_DESC : prList[i].ITEM_DESC
								, ITEM_SPEC : prList[i].ITEM_SPEC
								, UNIT_CD : prList[i].UNIT_CD
								, RFX_QT : prList[i].PR_QT
								, UNIT_PRC : prList[i].UNIT_PRC
								, RFX_AMT : prList[i].PR_AMT
								, DELY_DATE : prList[i].DELY_DATE
								, PR_NUM : prList[i].PR_NUM
								, PR_SQ : prList[i].PR_SQ
								, INSERT_FLAG : 'I'
							}
							gridL.addRow(addParam);
							gridL.setCellReadOnly(i,'UNIT_CD',true);
							gridL.setCellReadOnly(i,'RFX_QT',true);
						}
					}
					formUtil.setVisible(['doSelectItem'], false);
					EVF.getComponent('PR_TYPE').setReadOnly(true);
					EVF.getComponent('PR_REQ_TYPE').setReadOnly(true);
					EVF.getComponent('CUR').setReadOnly(true);
					showTotalSum();
				}else if(EVF.V('SIGN_STATUS') == 'T' || EVF.V('SIGN_STATUS') == 'R'){
					gridL.addRowEvent(function() {
						gridL.addRow({GATE_CD: '${ses.gateCd}', INSERT_FLAG : 'I'});
					});

					gridL.delRowEvent(function() {
						if(!gridL.isExistsSelRow()) { return alert("${msg.M0004}"); }

						var selId = gridL.getSelRowId();
						for(var i in selId){
							var flag = gridL.getCellValue(selId[i], 'INSERT_FLAG');
							if(flag == 'I'){
								gridL.delRow();
							}else{
								gridL.setCellValue(selId[i], 'INSERT_FLAG', 'D');
								gridL.setRowBgColor(selId[i], '#8C8C8C');
							}
						}

					});

				}

			}else {
				//detailView true

			}

			if("${ses.userType }" == 'S'){
				//gridL.hideCol('VENDOR_S',true);
				gridL.hideCol('UNIT_PRC',true);
				gridL.hideCol('RFX_AMT',true);
			}

			if('${param.baseDataType}' != 'PR'){
				doSearch();
			}

			/*헤더 이미지 클릭시 그리드 SEL 에 전체 복사 해봄*/
			/*var headerImgColumn = ["RMK"];
			for (var i in headerImgColumn) {
				var column = headerImgColumn[i];
				gridL._gvo.setColumnProperty(column, "header", {imageLocation: "right", imageUrl: "/images/everuxf/icons/comment.png"});
			}

			gridL._gvo.onColumnHeaderImageClicked = function(obj, column) {
				var selRow = gridL._gvo.getCurrent().itemIndex;
				var selValue = gridL.getCellValue(selRow, column.name);
				var selIds = gridL.getSelRowId();

				for (var i in selIds) {
					var selId = selIds[i];
					if (selRow != selId) {
						gridL.setCellValue(selId, column.name, selValue);

						if (column.name == "RMK") {
							gridL.setCellValue(selId, "RMK", gridL.getCellValue(selRow, "RMK"));
						}

					}
				}
			}*/




		} // init 여기서 끝

		function doSearch(){
			var store = new EVF.Store();
			store.setGrid([gridL]);
			store.load(baseUrl + "/RQ0110/doSearch", function(){
				gridL.checkAll(true);

				//구매요청접수에서 넘어온 경우 아이템 추가 불가
				if(gridL.getRowCount() != 0 &&  gridL.getCellValue(0,'PR_NUM') != ''){
					formUtil.setVisible(['doSelectItem'], false);
				}

			})
		}

		function _setAttFile(rowId, fileId, fileCount) {
			gridL.setCellValue(rowId, "ATT_FILE_CNT", fileCount);
			gridL.setCellValue(rowId, "ATT_FILE_NUM", fileId);
		}

		function _set_gridL_RMK(context, rowId){
			gridL.setCellValue(rowId, 'RMK', context);
		}

		function doSearchVendorByItem(rowIdx){
			gridR.delAllRow();
			var vendorList = JSON.parse(gridL.getCellValue(rowIdx, 'VENDOR_CD_JSON'));
			for(var i in vendorList){
				var param = {
					  ITEM_CD : gridL.getCellValue(rowIdx, 'ITEM_CD')
					, ITEM_DESC : gridL.getCellValue(rowIdx, 'ITEM_DESC')
					, VENDOR_CD : vendorList[i].VENDOR_CD
					, VENDOR_NM : vendorList[i].VENDOR_NM
					, CEO_NM : vendorList[i].CEO_USER_NM
					, IRS_NUM : vendorList[i].IRS_NO
					, VENDOR_USER : ""
					, VENDOR_TEL : ""
					, VENDOR_EMAIL : ""
				}
				gridR.addRow(param);
			}
		}

		//수의계약 사유 입력
		function doSelectPrivate(){

			var param = {
				callBackFunction : "_setPrivateRMK"
			};

			var url = baseUrl + '/RQ0110P01/view';
			var width = 700;
			var height = 400;
			new EVF.ModalWindow(url, param, width, height).open();
		}

		function _setPrivateRMK(privateRmk){
			EVF.V('PRIVATE_RMK', privateRmk);
		}

		//수의계약사유 버튼 보이기
		function doShowBtnPrivateRMK(){

			if(EVF.V('VENDOR_OPEN_TYPE') == 'QN'){
				$('#doSelectPrivate').css("display","block");
			}else{
				$('#doSelectPrivate').css("display","none");
				EVF.V('PRIVATE_RMK','');
			}
		}

		function itemAmtSum(rowId){
			gridL.setCellValue(rowId, 'RFX_AMT', gridL.getCellValue(rowId, 'RFX_QT') * gridL.getCellValue(rowId, 'UNIT_PRC'));
		}

		function showTotalSum(){
			var totalSum = 0;
			var gridSelected = gridL.getSelRowValue();
			for(var i in gridSelected){
				var eachSum = gridSelected[i].RFX_AMT;
				totalSum += eachSum;
			}
			EVF.V('CUR_AMT_SHOW', totalSum);
		}

		//협력사 선택
		function doSelectVendor(){

			if (!gridL.isExistsSelRow()) {
				alert("${msg.M0004}");
				return;
			}

			var vendorSltType = EVF.V('VENDOR_SLT_TYPE');
			var vendorOpenType = EVF.V('VENDOR_OPEN_TYPE');

			<%--지명방식을 먼저 선택해 주십시오.--%>
			if(vendorOpenType == ''){
				return alert("${RQ0110_0003}");
			}

			<%--업체 선정방식을 먼저 선택해 주십시오.--%>
			if(vendorSltType == ''){
				return alert("${RQ0110_0002}");
			}

			if(vendorSltType === 'DOC') {
				gridL.checkAll(true);
			}

			<%-- 선택된 행들의 업체코드를 읽어서 JSON 문자열로 만든다. --%>
			var rowData = gridL.getSelRowId();
			var vendorArray = [];
			var vendorCdArray = [];

			for(var row in rowData){
				var vendorJson = gridL.getCellValue(rowData[row], 'VENDOR_CD_JSON');

				if(vendorJson == '') continue;

				var vendorJsonParse = JSON.parse(vendorJson);
				var vendorCd;


				for(var k=0; k<vendorJsonParse.length; k++) {
					vendorCd = vendorJsonParse[k].VENDOR_CD;

					if (!arrayContains(vendorCdArray, vendorCd)) {
						var addParam = {
							 "VENDOR_CD" : vendorCd
							,"VENDOR_NM" : vendorJsonParse[k].VENDOR_NM
							,"CEO_USER_NM" : vendorJsonParse[k].CEO_USER_NM
							,"IRS_NO" : vendorJsonParse[k].IRS_NO
						}
						var vendorParam = JSON.stringify(addParam);
						vendorArray.push(vendorParam);
						vendorCdArray.push(vendorCd);
					}
				}
			}
			param = {
				 callBackFunction : '_selectVendor'
				,VENDOR_OPEN_TYPE: EVF.V('VENDOR_OPEN_TYPE')
				,vendorArray : '['+vendorArray+']'
				,CUST_CD: '${ses.companyCd}'
			}
			everPopup.openPopupByScreenId('RQ0110P02', 1000, 700, param);
		}

		function arrayContains(array, obj){
			var i = array.length;
			while(i-- > 0){
				if(array[i] == obj){
					return true;
				}
			}
			return false;
		}

		function _selectVendor(vendors){
			gridR.delAllRow();
			var selRowIds = gridL.getSelRowId();
			for(var i in selRowIds){
				gridL.setCellValue(selRowIds[i], 'VENDOR_S', JSON.parse(vendors).length);
				gridL.setCellValue(selRowIds[i], 'VENDOR_CD_JSON', vendors);
			}

			var vendorList = JSON.parse(vendors)
			for(var i in vendorList){
				var addParam = [{
					VENDOR_CD : vendorList[i].VENDOR_CD
					,VENDOR_NM : vendorList[i].VENDOR_NM
				}]
				var validData = valid.equalPopupValid(JSON.stringify(addParam), gridR, "VENDOR_CD");
				gridR.addRow(validData);
			}
		}


		function goTemplate(){
			var param = {
				callBackFunction : "_setRemark"
			}
			everPopup.openCommonPopup(param, "MP0003")
		}

		function _setRemark(data){
			var strStr = '';
			for(var k=0; k<data.length; k++) {
				strStr += data[k].CODE_DESC + '<BR>';
			}
			EVF.V('RMK_TEXT', strStr);
		}


		//저장
		function doSave(){

			var signStatus = EVF.V("SIGN_STATUS");
			var progressCd = EVF.V('PROGRESS_CD');

			var checkTime = checkTimeToServer(EVF.V("RFX_TO_DATE"), EVF.V("RFX_TO_HOUR"), EVF.V("RFX_TO_MIN"));

			if(checkTime == "RQ0110_0001"){
				return alert("${RQ0110_0001}");
			}else if(checkTime == "RQ0110_0004"){
				return alert("${RQ0110_0004}");
			}

			if (!gridL.validate().flag) { return EVF.alert(gridL.validate().msg); }

			var confirmMessage;
			switch (progressCd) {
				case "1200": //구매반려
				case "2300": //작성중
					confirmMessage = "${msg.M0021}"; //저장 하시겠습니까?
					break;
			}

			var store = new EVF.Store();
			if(!store.validate()) {
				return;
			}

			if (!confirm(confirmMessage)) {
				return;
			}

			goSaveRQ();

		}

		//결재상신
		function doSign(){

			var checkTime = checkTimeToServer(EVF.V("RFX_TO_DATE"), EVF.V("RFX_TO_HOUR"), EVF.V("RFX_TO_MIN"));

			if(checkTime == "RQ0110_0001"){
				return alert("${RQ0110_0001}");
			}else if(checkTime == "RQ0110_0004"){
				return alert("${RQ0110_0004}");
			}

			var store = new EVF.Store();
			if(!store.validate()) return;
			if(!gridL.isExistsSelRow()) { return alert("${msg.M0004}"); }
			if(!gridL.validate().flag) { return alert(gridL.validate().msg); }

			//if (!confirm("${msg.M0100}")) return;

			EVF.V("SIGN_STATUS", "P");

			param = {
				subject: EVF.V("RFX_SUBJECT"),
				docType: "RQ",
				signStatus: "P",
				screenId: "RQ0110",
				approvalType: 'APPROVAL',
				oldApprovalFlag: EVF.V("SIGN_STATUS"),
				attFileNum: "",
				docNum: EVF.V("RFX_NUM"),
				appDocNum: EVF.V("APP_DOC_NUM"),
				callBackFunction: "goSaveRQ"
			};
			everPopup.openApprovalRequestIIPopup(param);
		}

		//협력업체 전송
		function doSend(){

			var store = new EVF.Store();
			store.setGrid([gridL]);
			store.getGridData(gridL,'sel');
			store.load(baseUrl + "/RQ0110/doSend",function(){
				alert(this.getResponseMessage());
			});

		}

		function goSaveRQ(formData, gridData, attachData){

			EVF.V("approvalFormData", formData);
			EVF.V("approvalGridData", gridData);
			//EVF.V("attachFileDatas", attachData);

			gridL.checkAll(true);

			var store = new EVF.Store();
			store.doFileUpload(function() {
				store.setGrid([gridL]);
				store.getGridData(gridL,'sel');
				store.load(baseUrl + "/RQ0110/doSave", function(){
					alert(this.getResponseMessage());

					if('${param.popupFlag}' == 'true'){
						doClose();
					}else{
						var gateCd  = this.getParameter('gateCd');
						var buyerCd = this.getParameter('buyerCd');
						var rfxNum  = this.getParameter('rfxNum');
						var rfxCnt  = this.getParameter('rfxCnt');
						var param = {
							 GATE_CD: gateCd
							,BUYER_CD : buyerCd
							,RFX_NUM: rfxNum
							,RFX_CNT: rfxCnt
						};

						location.href=baseUrl+'/RQ0110/view.so?' + $.param(param);

					}

				});
			});

		}



		function checkTimeToServer(date, time, min) {

			//시작날짜가 오늘 날짜와 지금 시각보다 커야 함.
			if (!EVF.isEmpty(EVF.V("RFX_FROM_DATE")) && !EVF.isEmpty(EVF.V("RFX_FROM_HOUR")) && !EVF.isEmpty(EVF.V("RFX_FROM_MIN"))) {
				let validStartDate = Number(EVF.V("RFX_FROM_DATE")) + EVF.V("RFX_FROM_HOUR") + EVF.V("RFX_FROM_MIN") + "00";
				//console.log("${formData.today}" + "${formData.todayTime}");
				//console.log(validStartDate);
				if ("${formData.today}" + "${formData.todayTime}" > validStartDate) {
					return "RQ0110_0004";
				}
			}

			//견적이 끝나는 날짜가 시작날짜보다 커야 함
			if (!EVF.isEmpty(date) && !EVF.isEmpty(time) && !EVF.isEmpty(min)) {
				let validStartDate = Number(date) + time + min;
				if (EVF.V("RFX_FROM_DATE") + EVF.V("RFX_FROM_HOUR") + EVF.V("RFX_FROM_MIN") > validStartDate) {
					return "RQ0110_0001";
				}
			}
			return true;
		}


		function doSelectItem(){
			var param = {
				CUST_CD: EVF.V("BUYER_CD"),
				callBackFunction: "_setSelectedItem",
				multiFlag: true,
				detailView: false,
				returnType:"M",
				popupFlag: true
			};
			everPopup.openPopupByScreenId("BIT01_045", 1200, 800, param);
		}

		function _setSelectedItem(data){
			var validData = valid.equalPopupValid(JSON.stringify(data), gridL, "ITEM_CD");
			var list = JSON.parse(validData);
			var arrData = [];

			for(var idx in list) {
				var UNIT_CD = list[idx].UNIT_CD;
				var ORD_UNIT_CD = list[idx].ORD_UNIT_CD;

				if(everString.isNotEmpty(list[idx].VENDOR_UNIT_CD)) {
					UNIT_CD = list[idx].VENDOR_UNIT_CD;
				}

				if(everString.isNotEmpty(list[idx].VENDOR_ORDER_UNIT_CD)) {
					ORD_UNIT_CD = list[idx].VENDOR_ORDER_UNIT_CD;
				}

				arrData.push({
					  ITEM_CD: list[idx].ITEM_CD
					, ITEM_DESC: list[idx].ITEM_DESC
					, ITEM_SPEC: list[idx].ITEM_SPEC
					, MAKER_CD: list[idx].MAKER_CD
					, MAKER_NM: list[idx].MAKER_NM
					, UNIT_CD: UNIT_CD
					, CUR: list[idx].CUR==undefined?"KRW":list[idx].CUR
					, INSERT_FLAG : "I"
					//, VENDOR_CD:list[idx].VENDOR_CD
					//, VENDOR_NM:list[idx].VENDOR_NM
				});
			}

			gridL.addRow(arrData);
		}

		function doDelete(){
			if (!confirm("${msg.M0013}")) return;

			var store = new EVF.Store();
			store.load(baseUrl + "/RQ0110/doDelete", function(){
				alert(this.getResponseMessage());
				doClose();
			});
		}

		function doClose() {
			if(opener != null) {

				<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
					opener.doSearch();
				</c:if>


				window.close();
			} else {

				<c:if test="${param.APP_DOC_NUM == '' || param.APP_DOC_NUM == null}">
					parent.doSearch();
				</c:if>

				new EVF.ModalWindow().close(null);
			}
		}

	</script>

	<e:window id="RQ0110" onReady="init" initData="${initData}" title="${fullScreenName}">

		<e:inputHidden id="GATE_CD" name="GATE_CD" value="${empty formData.GATE_CD ? param.gateCd : formData.GATE_CD}" />
		<e:inputHidden id="baseDataType" name="baseDataType" value="${param.baseDataType}" />
		<e:inputHidden id="RFX_TYPE" name="RFX_TYPE" value="RFQ"  width="${form_RFX_TYPE_W}" disabled="${form_RFX_TYPE_D}" readOnly="${form_RFX_TYPE_RO}" required="${form_RFX_TYPE_R}" placeHolder="" />
		<e:inputHidden id="PROGRESS_CD" name="PROGRESS_CD" value="${formData.PROGRESS_CD}"/>
		<e:inputHidden id="PRIVATE_RMK" name="PRIVATE_RMK" />  <%-- 수의계약 사유--%>
		<e:inputHidden id="SIGN_STATUS" name="SIGN_STATUS" value="${formData.SIGN_STATUS}"/>

		<e:inputHidden id='APP_DOC_NUM' name="APP_DOC_NUM" value="${empty param.appDocNum ? formData.APP_DOC_NUM : param.appDocNum}" />
		<e:inputHidden id='APP_DOC_CNT' name="APP_DOC_CNT" value="${formData.APP_DOC_CNT}" />
		<e:inputHidden id="approvalFormData" name="approvalFormData"/>
		<e:inputHidden id="approvalGridData" name="approvalGridData"/>

		<e:buttonBar id="buttonBar" align="right">
			<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R'}">
				<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" />
				<e:button id="doSign" name="doSign" label="${doSign_N}" onClick="doSign" disabled="${doSign_D}" visible="${doSign_V}" />
			</c:if>
			<c:if test="${(not empty formData.RFX_NUM && formData.SIGN_STATUS == 'T') || formData.SIGN_STATUS == 'R'}">
				<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			</c:if>
			<c:if test="${param.popupFlag == true}">
				<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
			</c:if>
		</e:buttonBar>
		
		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--견적요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${empty param.RFX_NUM ? formData.RFX_NUM : param.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text>/</e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${empty param.RFX_CNT ? formData.RFX_CNT : param.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<%--회사명(코드)--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}"/>
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" value="${empty formData.BUYER_CD ? ses.companyCd : formData.BUYER_CD}" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--견적요청명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${formData.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--견적요청일자--%>
				<e:label for="RFX_DATE" title="${form_RFX_DATE_N}"/>
				<e:field>
					<e:inputDate id="RFX_DATE" name="RFX_DATE" value="${empty formData.today ? formData.RFX_DATE : formData.today}" width="${inputDateWidth}" datePicker="true" required="${form_RFX_DATE_R}" disabled="${form_RFX_DATE_D}" readOnly="${form_RFX_DATE_RO}" />
				</e:field>
				<%--구매유형--%>
				<e:label for="PR_TYPE" title="${form_PR_TYPE_N}"/>
				<e:field>
					<e:select id="PR_TYPE" name="PR_TYPE" value="${formData.PR_TYPE}" options="${prTypeOptions}" width="${form_PR_TYPE_W}" disabled="${form_PR_TYPE_D}" readOnly="${form_PR_TYPE_RO}" required="${form_PR_TYPE_R}" placeHolder="" />
					<e:text>/</e:text>
					<e:select id="PR_REQ_TYPE" name="PR_REQ_TYPE" value="${formData.PR_REQ_TYPE}" options="${prReqTypeOptions}" width="${form_PR_REQ_TYPE_W}" disabled="${form_PR_REQ_TYPE_D}" readOnly="${form_PR_REQ_TYPE_RO}" required="${form_PR_REQ_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--구매담당자 / 부서--%>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
				<e:field>
					<e:search id="CTRL_USER_NM" name="CTRL_USER_NM" value="${formData.CTRL_USER_NM}" width="${form_CTRL_USER_NM_W}" maxLength="${form_CTRL_USER_NM_M}" onIconClick="${form_CTRL_USER_NM_RO ? 'everCommon.blank' : 'selectCtrlUser'}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
					<e:text>/</e:text>
					<e:inputText id="CTRL_USER_DEPT" name="CTRL_USER_DEPT" value="${formData.CTRL_USER_DEPT}" width="${form_CTRL_USER_DEPT_W}" maxLength="${form_CTRL_USER_DEPT_M}" disabled="${form_CTRL_USER_DEPT_D}" readOnly="${form_CTRL_USER_DEPT_RO}" required="${form_CTRL_USER_DEPT_R}" />
					<e:inputHidden id="CTRL_USER_ID" name="CTRL_USER_ID" value="${formData.CTRL_USER_ID}" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
			</e:row>
		</e:searchPanel>
		
		<e:searchPanel id="form2" title="견적요청정보" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="true" onEnter="doSearch">
			<e:row>
				<%--지명방식--%>
				<e:label for="VENDOR_OPEN_TYPE" title="${form_VENDOR_OPEN_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_OPEN_TYPE" name="VENDOR_OPEN_TYPE" value="${formData.VENDOR_OPEN_TYPE}" onChange="doShowBtnPrivateRMK" options="${vendorOpenTypeOptions}" width="${form_VENDOR_OPEN_TYPE_W}" disabled="${form_VENDOR_OPEN_TYPE_D}" readOnly="${form_VENDOR_OPEN_TYPE_RO}" required="${form_VENDOR_OPEN_TYPE_R}" placeHolder="" />
					<e:text>&nbsp;</e:text>
					<e:button id="doSelectPrivate" name="doSelectPrivate" label="${doSelectPrivate_N}" onClick="doSelectPrivate" disabled="${doSelectPrivate_D}" visible="${doSelectPrivate_V}"/>
				</e:field>
				<%--업체선정방식--%>
				<e:label for="VENDOR_SLT_TYPE" title="${form_VENDOR_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="VENDOR_SLT_TYPE" name="VENDOR_SLT_TYPE" value="${formData.VENDOR_SLT_TYPE}" options="${vendorSltTypeOptions}" width="${form_VENDOR_SLT_TYPE_W}" disabled="${form_VENDOR_SLT_TYPE_D}" readOnly="${form_VENDOR_SLT_TYPE_RO}" required="${form_VENDOR_SLT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--견적일시--%>
				<e:label for="RFX_FROM_DATE" title="${form_RFX_FROM_DATE_N}"/>
				<e:field colSpan="3">
					<e:inputDate id="RFX_FROM_DATE" name="RFX_FROM_DATE" value="${formData.RFX_FROM_DATE}" toDate="RFX_TO_DATE"  width="${inputDateWidth}" datePicker="true" required="${form_RFX_FROM_DATE_R}" disabled="${form_RFX_FROM_DATE_D}" readOnly="${form_RFX_FROM_DATE_RO}" />
					<e:text>&nbsp;&nbsp;</e:text>
					<%--시--%>
					<e:select id="RFX_FROM_HOUR" name="RFX_FROM_HOUR" value="${formData.RFX_FROM_HOUR}" options="${rfxFromHourOptions}" width="${form_RFX_FROM_HOUR_W}" disabled="${form_RFX_FROM_HOUR_D}" readOnly="${form_RFX_FROM_HOUR_RO}" required="${form_RFX_FROM_HOUR_R}" placeHolder="" />
					<e:text>${form_RFX_FROM_HOUR_N}&nbsp;&nbsp;</e:text>
					<%--분--%>
					<e:select id="RFX_FROM_MIN" name="RFX_FROM_MIN" value="${formData.RFX_FROM_MIN}" options="${rfxFromMinOptions}" width="${form_RFX_FROM_MIN_W}" disabled="${form_RFX_FROM_MIN_D}" readOnly="${form_RFX_FROM_MIN_RO}" required="${form_RFX_FROM_MIN_R}" placeHolder="" />
					<e:text>${form_RFX_FROM_MIN_N}&nbsp;</e:text>
					<e:text>&nbsp;~&nbsp;&nbsp;</e:text>
					<e:inputDate id="RFX_TO_DATE" name="RFX_TO_DATE" value="${formData.RFX_TO_DATE}" fromDate="RFX_FROM_DATE" width="${inputDateWidth}" datePicker="true" required="${form_RFX_TO_DATE_R}" disabled="${form_RFX_TO_DATE_D}" readOnly="${form_RFX_TO_DATE_RO}" />
					<e:text>&nbsp;&nbsp;</e:text>
					<e:select id="RFX_TO_HOUR" name="RFX_TO_HOUR" value="${formData.RFX_TO_HOUR}" options="${rfxToHourOptions}" width="${form_RFX_TO_HOUR_W}" disabled="${form_RFX_TO_HOUR_D}" readOnly="${form_RFX_TO_HOUR_RO}" required="${form_RFX_TO_HOUR_R}" placeHolder="" />
					<e:text>${form_RFX_TO_HOUR_N}&nbsp;&nbsp;</e:text>
					<e:select id="RFX_TO_MIN" name="RFX_TO_MIN" value="${formData.RFX_TO_MIN}" options="${rfxToMinOptions}" width="${form_RFX_TO_MIN_W}" disabled="${form_RFX_TO_MIN_D}" readOnly="${form_RFX_TO_MIN_RO}" required="${form_RFX_TO_MIN_R}" placeHolder="" />
					<e:text>${form_RFX_TO_MIN_N}&nbsp;&nbsp;</e:text>
				</e:field>
			</e:row>

			<e:row>
				<%--견적마감안내--%>
				<e:label for="RFX_BF_DAY" title="${form_RFX_BF_DAY_N}"/>
				<e:field>
					<e:text>마감일시 기준 (</e:text>
					<e:inputNumber id="RFX_BF_DAY" name="RFX_BF_DAY" value="${formData.RFX_BF_DAY}" width="${form_RFX_BF_DAY_W}" maxValue="${form_RFX_BF_DAY_M}" decimalPlace="${form_RFX_BF_DAY_NF}" disabled="${form_RFX_BF_DAY_D}" readOnly="${form_RFX_BF_DAY_RO}" required="${form_RFX_BF_DAY_R}" />
					<e:text>)일 전 알림</e:text>
				</e:field>
				<%--가격선정방식--%>
				<e:label for="PRC_SLT_TYPE" title="${form_PRC_SLT_TYPE_N}"/>
				<e:field>
					<e:select id="PRC_SLT_TYPE" name="PRC_SLT_TYPE" value="${formData.PRC_SLT_TYPE}" options="${prcSltTypeOptions}" width="${form_PRC_SLT_TYPE_W}" disabled="${form_PRC_SLT_TYPE_D}" readOnly="${form_PRC_SLT_TYPE_RO}" required="${form_PRC_SLT_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--견적요청금액--%>
				<e:label for="CUR" title="${form_CUR_N}"/>
				<e:field>
					<e:select id="CUR" name="CUR" value="${formData.CUR}" options="${curOptions}" width="${form_CUR_W}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" placeHolder="" />
					<e:text>&nbsp</e:text>
					<e:inputNumber id="CUR_AMT_SHOW" name="CUR_AMT_SHOW" value="" width="${form_CUR_AMT_SHOW_W}" maxValue="${form_CUR_AMT_SHOW_M}" decimalPlace="${form_CUR_AMT_SHOW_NF}" disabled="${form_CUR_AMT_SHOW_D}" readOnly="${form_CUR_AMT_SHOW_RO}" required="${form_CUR_AMT_SHOW_R}" />
				</e:field>
				<%--내/외자--%>
				<e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
				<e:field>
					<e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="${formData.SHIPPER_TYPE}" options="${shipperTypeOptions}" width="${form_SHIPPER_TYPE_W}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--인도조건--%>
				<e:label for="DELY_TERMS" title="${form_DELY_TERMS_N}"/>
				<e:field>
					<e:select id="DELY_TERMS" name="DELY_TERMS" value="${formData.DELY_TERMS}" options="${delyTermsOptions}" width="${form_DELY_TERMS_W}" disabled="${form_DELY_TERMS_D}" readOnly="${form_DELY_TERMS_RO}" required="${form_DELY_TERMS_R}" placeHolder="" />
				</e:field>
				<%--지불조건--%>
				<e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
				<e:field>
					<e:select id="PAY_TERMS" name="PAY_TERMS" value="${formData.PAY_TERMS}" options="${payTermsOptions}" width="${form_PAY_TERMS_W}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--견적내용(특기사항)--%>
				<e:label for="RMK_TEXT" title="${form_RMK_TEXT_N}" >
					<e:button id="goTemplate" name="goTemplate" label="${goTemplate_N}" onClick="goTemplate" disabled="${goTemplate_D}" visible="${goTemplate_V}"/>
				</e:label>
				<%--견적내용(특기사항)--%>
				<e:field colSpan="3">
					<e:richTextEditor id="RMK_TEXT" name="RMK_TEXT" value="${formData.RMK_TEXT}" width="${form_RMK_TEXT_W}" maxLength="${form_RMK_TEXT_M}" disabled="${form_RMK_TEXT_D}" readOnly="${form_RMK_TEXT_RO}" required="${form_RMK_TEXT_R}" />
					<e:inputHidden id="RMK" name="RMK" value="${formData.RMK}" />
				</e:field>
			</e:row>
			<e:row>
				<%--첨부파일--%>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" width="${form_ATT_FILE_NUM_W}"  readOnly="${param.detailView}" bizType="RQ" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
				</e:field>
				<c:if test="${ses.userType eq 'C'}">
					<%--내부 첨부파일--%>
					<e:label for="ATT_FILE_NUM_IN" title="${form_ATT_FILE_NUM_IN_N}" />
					<e:field>
						<e:fileManager id="ATT_FILE_NUM_IN" name="ATT_FILE_NUM_IN" fileId="${formData.ATT_FILE_NUM_IN}" bizType="RQ"  width="${form_ATT_FILE_NUM_IN_W}" height="100px" readOnly="${param.detailView}" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
					</e:field>
				</c:if>
			</e:row>
		</e:searchPanel>

		<e:panel id="panelLeft" width="83%" height="fit">
			<e:buttonBar id="buttonL" align="right">
				<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R'}">
					<e:button id="doSelectItem" name="doSelectItem" label="${doSelectItem_N}" onClick="doSelectItem" disabled="${doSelectItem_D}" visible="${doSelectItem_V}"/>
				</c:if>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridL" name="gridL" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}"/>
		</e:panel>

		<e:panel id="blank_pn" height="100%" width="1%">&nbsp;</e:panel>

		<e:panel id="panelRight" width="16%" height="fit">
			<e:buttonBar id="buttonR" align="right">
				<c:if test="${formData.SIGN_STATUS == 'T' || formData.SIGN_STATUS == 'R'}">
					<e:button id="doSelectVendor" name="doSelectVendor" label="${doSelectVendor_N}" onClick="doSelectVendor" disabled="${doSelectVendor_D}" visible="${doSelectVendor_V}"/>
				</c:if>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridR" name="gridR" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}"/>
		</e:panel>

	</e:window>

</e:ui>