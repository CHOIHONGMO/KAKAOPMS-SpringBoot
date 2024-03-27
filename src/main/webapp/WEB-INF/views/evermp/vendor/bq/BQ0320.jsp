<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <!-- KTNET 공인인증서 모듈 연결(SCORE_PKI_for_OpenWeb_v1.0.1.5_2.0.7.8) -->
    <script src="/toolkit/tradesign/js/nxts/nxts.min.js"></script>
    <script src="/toolkit/tradesign/js/nxts/nxtspki_config.js"></script>
    <script src="/toolkit/tradesign/js/nxts/nxtspki.js"></script>
    <script src="/toolkit/tradesign/js/demo.js"></script>
	<script>

		var grid;
		var baseUrl = "/evermp/vendor/bq";

		function init(){

			<%-- TradeSign 공인인증서 --%>
	        nxTSPKI.onInit(function () {});
            nxTSPKI.init(true);

			<c:if test="${param.detailView}">
				$('.qq-upload-button').css('display','none');
			</c:if>
			/*$('#upload-button-B_ATT_FILE_NUM').css('display','none');
			$('#file_container_B_ATT_FILE_NUM').css('height','150px');*/

			grid = EVF.getComponent("grid");
			grid.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
			grid.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
			grid.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
			grid.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
			grid.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
			grid.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
			grid.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

			grid.excelExportEvent({
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${fullScreenName}"
			});

			grid.cellClickEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){
				if(colIdx === 'B_ATT_FILE_CNT') {
					param = {
						  detailView: true
						, attFileNum: grid.getCellValue(rowIdx, "B_ATT_FILE_NUM")
						, rowId: rowIdx
						, callBackFunction: ""
						, bizType: "RQ"
						, fileExtension: "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'ATT_FILE_CNT'){
						param = {
							 detailView: ${param.detailView}
							,attFileNum: grid.getCellValue(rowIdx, "ATT_FILE_NUM")
							,havePermission: true
							,rowId: rowIdx
							,callBackFunction: "callback_setAttFile"
							,bizType: "QT"
							,fileExtension: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx === 'B_RMK'){
					var param = {
						  rowId: rowIdx
						, havePermission: false
						, screenName: '구매사 비고'
						, callBackFunction: ''
						, TEXT_CONTENTS: grid.getCellValue(rowIdx, "B_RMK")
						, detailView: true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}else if(colIdx === 'RMK'){
					var param = {
						  rowId: rowIdx
						, havePermission: true
						, screenName: '협력사 비고'
						, callBackFunction: "callback_set_grid_SRMK"
						, TEXT_CONTENTS: grid.getCellValue(rowIdx, "RMK")
						, detailView: "${param.detailView}"
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}
				showTotalSum();
			});

			grid.cellChangeEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){
				switch(colIdx){
					case 'RFX_QT' :
					case 'UNIT_PRC' :
						itemAmtSum(rowIdx);
						break;
				}
				showTotalSum();
			});

			grid.itemAllCheckedEvent(function(){
				showTotalSum();
			});

			doSearch();
		}

		function doSearch(){
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + "/BQ0320/doSearch", function(){
				if (!grid.isExistsRow()) {
					return alert("${msg.M0002}");
				}
				grid.checkAll(true);

				if('${param.detailView}' !== 'true'){
					setTimeout(function(){
						$('#cke_1_toolbar_collapser').click();
					},500);
				}
			});
		}

		function callback_setAttFile(rowId, fileId, fileCount){
			grid.setCellValue(rowId, "ATT_FILE_CNT", fileCount);
			grid.setCellValue(rowId, "ATT_FILE_NUM", fileId);
		}

		function callback_set_grid_SRMK(data, rowId){
			grid.setCellValue(rowId, 'RMK', data);
		}

		function itemAmtSum(rowId){

			var amt = 0;
			var qt = Number(grid.getCellValue(rowId, "RFX_QT"));
			var unitPrc = Number(grid.getCellValue(rowId, "UNIT_PRC"));

			var primNum = decimalFits(qt) + decimalFits(unitPrc);

			if(primNum > 0){
				amt = parseFloat(qt * unitPrc).toFixed(primNum);
			}else{
				amt = qt * unitPrc;
			}

			grid.setCellValue(rowId, "QTA_AMT", amt);

		}

		Number.isInteger = Number.isInteger || function(value) {
			return typeof value === "number" &&
				isFinite(value) &&
				Math.floor(value) === value;
		};

		function decimalFits(n){
			var decimalN = 0;
			if(!Number.isInteger(n)){ //소수
				var d = String(n).split('.')[1].length;
				if(decimalN < d)decimalN = d;
			}
			return decimalN;
		}

		function showTotalSum(){
			var totalSum = 0;
			var gridSelected = grid.getSelRowValue();
			for(var i in gridSelected){
				var eachSum = gridSelected[i].QTA_AMT;
				totalSum += eachSum;
			}
			EVF.V('QTA_AMT', totalSum);
		}

		function doSave(){

			var submitflag = this.data;
			EVF.V("SEND_FLAG", submitflag);

			if(submitflag === 'T'){
				signCompleteCallback()
			} else {
				var ssn;
				if ('${ses.isDev}' == 'true') {
					ssn = '1234567890'; // 개발서버인 경우 사업자번호
				} else {
					ssn = '${ses.irsNum}';
				}

				// 사업자번호 없음 오류
				if(EVF.isEmpty(ssn)) {
					return EVF.alert("사업자번호 오류로 입찰서를 제출할 수 없습니다. 관리자에게 문의하세요.");
				}

				// 암호화 데이터 (입찰번호, 입찰차수, 담당자ID, 입찰금액)
			    var data = EVF.V("RFX_NUM")+","+EVF.V("RFX_CNT")+","+EVF.V("VENDOR_USER_NM")+","+EVF.V("QTA_AMT");
                var options = {
                     ssn: ssn
                }
                nxTSPKI.signData(data, options, signCompleteCallback);
			}
		}

		function signCompleteCallback(res){
			console.log(EVF.V("SEND_FLAG"))

			var store = new EVF.Store();
			if(!store.validate()) return;

			var msg 	 = "";
			var alertMsg = "";
			if (res == null) {
				msg 	 = '${msg.M0021}' 	//저장 하시겠습니까?
				alertMsg = '${msg.M0031}' 	//성공적으로 저장되었습니다.
			} else if(res.code == 0){
				//입찰서 제출일시
				msg 	 = '${BQ0320_0001}' //제출하시겠습니까?
				alertMsg = '${BQ0320_0002}' //해당 입찰서가 제출되었습니다.
				EVF.V('SIGN_VALUE', res.data.signedData);
			} else {
				return EVF.alert(res.errorMessage);
            }

			//마감일시 확인
			var rfxToDate = Date.parse(EVF.V('RFX_TO_DATE'));
			var now = new Date();
			if(now > rfxToDate){
				return alert('${msg.M0049}');
			}



			grid.checkAll(true);
			if (!grid.validate().flag) {
				return alert(grid.validate().msg);
			}

			var allgrid = grid.getAllRowValue();
			for(var i in allgrid){
				var unitPrc = Number(allgrid[i].UNIT_PRC);
				if(unitPrc === 0) {return alert('${BQ0320_0003}');}
			}

			if(!confirm(msg)) { return; }

			store.doFileUpload(function() {
				store.setGrid([grid]);
				store.getGridData(grid,'all');
				store.load(baseUrl + '/BQ0320/doSave', function(){
					alert(alertMsg);
					if('${param.popupFlag}' == 'true') {
						doClose2();
					} else {
						document.location.href = baseUrl + '/BQ0320/view.so?' + $.param(param);
					}
				});
			});
		}

		function doClose2(){
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

		function doClose(){
			if(opener != null) {
				window.close();
			} else {
				new EVF.ModalWindow().close(null);
			}
		}

	</script>

	<e:window id="BQ0320" onReady="init" initData="${initData}" title="${fullScreenName}">

		<e:inputHidden id="RFX_TO_DATE" name="RFX_TO_DATE" value="${formData.RFX_TO_DATE}"/>
		<e:inputHidden id="SEND_FLAG" name="SEND_FLAG" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${empty formData.VENDOR_CD ? ses.companyCd : formData.VENDOR_CD}" />
		<e:inputHidden id="BUYER_CD" name="BUYER_CD"  value="${formData.BUYER_CD}" />
		<e:inputHidden id="BDHD_PROGRESS_CD" name="BDHD_PROGRESS_CD" value="${formData.BDHD_PROGRESS_CD}" />
		<e:inputHidden id="SIGN_VALUE" name="SIGN_VALUE"  />

		<e:buttonBar id="buttonL" align="right" title="입찰요청정보">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data="T"/>
			<e:button id="doSubmit" name="doSubmit" label="${doSubmit_N}" onClick="doSave" disabled="${doSubmit_D}" visible="${doSubmit_V}" data="S"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:searchPanel id="form1" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<%--입찰요청번호--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${formData.RFX_NUM}" width="30%" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text> / </e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${formData.RFX_CNT}" width="10%" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
			</e:row>
			<e:row>
				<%--입찰명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${formData.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--구매담당자/부서--%>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
				<e:field>
					<e:inputText id="CTRL_USER_NM" name="CTRL_USER_NM" value="${formData.CTRL_USER_NM}" width="30%" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
					<e:text> / </e:text>
					<e:inputText id="CTRL_DEPT_NM" name="CTRL_DEPT_NM" value="${formData.CTRL_DEPT_NM}" width="45%" maxLength="${form_CTRL_DEPT_NM_M}" disabled="${form_CTRL_DEPT_NM_D}" readOnly="${form_CTRL_DEPT_NM_RO}" required="${form_CTRL_DEPT_NM_R}" />
				</e:field>
				<%--입찰기간--%>
				<e:label for="RFX_START_END_DATE" title="${form_RFX_START_END_DATE_N}" />
				<e:field>
					<e:inputText id="RFX_START_END_DATE" name="RFX_START_END_DATE" value="${formData.RFX_START_END_DATE}" width="${form_RFX_START_END_DATE_W}" maxLength="${form_RFX_START_END_DATE_M}" disabled="${form_RFX_START_END_DATE_D}" readOnly="${form_RFX_START_END_DATE_RO}" required="${form_RFX_START_END_DATE_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:searchPanel id="form2" title="입찰서정보" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="true" onEnter="doSearch">
			<e:row>
				<%--입찰서번호--%>
				<e:label for="QTA_NUM" title="${form_QTA_NUM_N}" />
				<e:field>
					<e:inputText id="QTA_NUM" name="QTA_NUM" value="${formData.QTA_NUM}" width="${form_QTA_NUM_W}" maxLength="${form_QTA_NUM_M}" disabled="${form_QTA_NUM_D}" readOnly="${form_QTA_NUM_RO}" required="${form_QTA_NUM_R}" />
					<e:inputHidden id="HIDDEN_QTA_NUM" name="HIDDEN_QTA_NUM" value="${formData.HIDDEN_QTA_NUM}" />
					<e:text>/</e:text>
					<e:inputNumber id="QTA_CNT" name="QTA_CNT" value="${formData.QTA_CNT}" width="${form_QTA_CNT_W}" maxValue="${form_QTA_CNT_M}" decimalPlace="${form_QTA_CNT_NF}" disabled="${form_QTA_CNT_D}" readOnly="${form_QTA_CNT_RO}" required="${form_QTA_CNT_R}" />
					<e:inputHidden id="HIDDEN_QTA_CNT" name="HIDDEN_QTA_CNT" value="${formData.HIDDEN_QTA_CNT}" />
				</e:field>
				<e:label for="dummy"/>
				<e:field colSpan="1" />
			</e:row>
			<e:row>
				<%--협력업체 담당자--%>
				<e:label for="VENDOR_USER_NM" title="${form_VENDOR_USER_NM_N}" />
				<e:field>
					<e:inputText id="VENDOR_USER_NM" name="VENDOR_USER_NM" value="${empty formData.VENDOR_USER_NM ? ses.userNm : formData.VENDOR_USER_NM}" width="${form_VENDOR_USER_NM_W}" maxLength="${form_VENDOR_USER_NM_M}" disabled="${form_VENDOR_USER_NM_D}" readOnly="${form_VENDOR_USER_NM_RO}" required="${form_VENDOR_USER_NM_R}" />
				</e:field>
				<%--담당자 연락처--%>
				<e:label for="VENDOR_USER_TEL_NUM" title="${form_VENDOR_USER_TEL_NUM_N}" />
				<e:field>
					<e:inputText id="VENDOR_USER_TEL_NUM" name="VENDOR_USER_TEL_NUM" value="${empty formData.VENDOR_USER_TEL_NUM ? ses.telNum : formData.VENDOR_USER_TEL_NUM}" width="${form_VENDOR_USER_TEL_NUM_W}" maxLength="${form_VENDOR_USER_TEL_NUM_M}" disabled="${form_VENDOR_USER_TEL_NUM_D}" readOnly="${form_VENDOR_USER_TEL_NUM_RO}" required="${form_VENDOR_USER_TEL_NUM_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--총금액--%>
				<e:label for="CUR" title="${form_CUR_N}" />
				<e:field>
					<e:inputText id="CUR" name="CUR" value="${formData.CUR}" width="${form_CUR_W}" maxLength="${form_CUR_M}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" />
					<e:text> / </e:text>
					<e:inputNumber id="QTA_AMT" name="QTA_AMT" value="${formData.QTA_AMT}" width="${form_QTA_AMT_W}" maxValue="${form_QTA_AMT_M}" decimalPlace="${form_QTA_AMT_NF}" disabled="${form_QTA_AMT_D}" readOnly="${form_QTA_AMT_RO}" required="${form_QTA_AMT_R}" />
				</e:field>
				<e:label for="dummy" />
				<e:field colSpan="1" />
			</e:row>
			<e:row>
				<%--구매사 특기사항--%>
				<e:label for="B_RMK" title="${form_B_RMK_N}"/>
				<e:field>
					<e:textArea id="B_RMK" name="B_RMK" value="${formData.B_RMK}" height="100px" width="${form_B_RMK_W}" maxLength="${form_B_RMK_M}" disabled="${form_B_RMK_D}" readOnly="${form_B_RMK_RO}" required="${form_B_RMK_R}" />
				</e:field>
				<%--특기사항--%>
				<e:label for="RMK" title="${form_RMK_N}"/>
				<e:field>
					<e:textArea id="RMK" name="RMK" value="${formData.RMK}" height="100px" width="${form_RMK_W}" maxLength="${form_RMK_M}" disabled="${form_RMK_D}" readOnly="${form_RMK_RO}" required="${form_RMK_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--구매사 첨부파일--%>
				<e:label for="B_ATT_FILE_NUM" title="${form_B_ATT_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="B_ATT_FILE_NUM" name="B_ATT_FILE_NUM" fileId="${formData.B_ATT_FILE_NUM}"  width="${form_B_ATT_FILE_NUM_W}" readOnly="${true}" required="${form_B_ATT_FILE_NUM_R}" bizType="QT" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess"  fileExtension="${fileExtension}" />				</e:field>
				<%--입찰서 첨부파일--%>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${formData.ATT_FILE_NUM}" width="${form_ATT_FILE_NUM_W}"  readOnly="${param.detailView}" bizType="RQ" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" fileExtension="${fileExtension}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>