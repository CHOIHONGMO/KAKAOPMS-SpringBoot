<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>

		var grid;
		var baseUrl = "/eversrm/vendor/qt";

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
				allCol : "${excelOption.allCol}",
				selRow : "${excelOption.selRow}",
				fileType : 'xls',
				fileName : "${fullScreenName}"
			});

			grid.cellClickEvent(function(rowIdx, colIdx, iRow, iCol, newValue, oldValue){
				if(colIdx == 'B_ATT_FILE_CNT') {
					param = {
						  detailView: true
						, attFileNum: grid.getCellValue(rowIdx, "B_ATT_FILE_NUM")
						, rowId: rowIdx
						, callBackFunction: ""
						, bizType: "RQ"
						, fileExtension: "*"
					};
					everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx == 'V_ATT_FILE_CNT'){
						param = {
							 detailView: false
							,attFileNum: grid.getCellValue(rowIdx, "V_ATT_FILE_NUM")
							,rowId: rowIdx
							,callBackFunction: "_V_setAttFile"
							,bizType: "QT"
							,fileExtension: "*"
						};
						everPopup.openPopupByScreenId("commonFileAttach", 650, 350, param);
				}else if(colIdx == 'B_RMK'){
					var param = {
						  rowId: rowIdx
						, havePermission: false
						, screenName: '구매사 비고'
						, callBackFunction: ''
						, TEXT_CONTENTS: grid.getCellValue(rowIdx, "B_RMK")
						, detailView: true
					};
					everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
				}else if(colIdx == 'V_RMK'){
					var param = {
						  rowId: rowIdx
						, havePermission: true
						, screenName: '협력사 비고'
						, callBackFunction: "_set_grid_VRMK"
						, TEXT_CONTENTS: grid.getCellValue(rowIdx, "V_RMK")
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
			showTotalSum();
		}

		function doSearch(){
			var store = new EVF.Store();
			store.setGrid([grid]);
			store.load(baseUrl + "/QT0120/doSearch", function(){
				if (!grid.isExistsRow()) {
					return alert("${msg.M0002}");
				}
				grid.checkAll(true);
			});
		}


		function _V_setAttFile(rowId, fileId, fileCount){
			grid.setCellValue(rowId, "V_ATT_FILE_CNT", fileCount);
			grid.setCellValue(rowId, "V_ATT_FILE_NUM", fileId);
		}

		function _set_grid_VRMK(data, rowId){
			grid.setCellValue(rowId, 'V_RMK', data);
		}

		function itemAmtSum(rowId){
			grid.setCellValue(rowId, 'QTA_AMT', grid.getCellValue(rowId, 'RFX_QT') * grid.getCellValue(rowId, 'UNIT_PRC'));
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

			var msg = '';

			grid.checkAll(true);
			if (!grid.validate().flag) {
				return alert(grid.validate().msg);
			}

			if(submitflag == 'T'){
				msg = '${msg.M0021}'; //저장 하시겠습니까?
				alertMsg = '${msg.M0031}'; //성공적으로 저장되었습니다.
			}else{
				msg = '${QT0120_0001}'; //제출하시겠습니까?
				alertMsg = '${QT0120_0002}'; //성공적으로 제출하였습니다.
			}

			if(!confirm(msg)) { return; }

			var store = new EVF.Store();
			store.setGrid([grid]);
			store.getGridData(grid,'sel');
			store.doFileUpload(function() {
				store.load(baseUrl + '/QT0120/doSave', function(){
					alert(alertMsg);

					if('${param.popupFlag}' == 'true') {
						doClose();
					} else {
						document.location.href = baseUrl + '/QT0120/view.so?' + $.param(param);
					}

				});
			});

		}

		function doClose(){
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
	<e:window id="QT0120" onReady="init" initData="${initData}" title="${fullScreenName}">
		<e:inputHidden id="RFX_TO_DATE" name="RFX_TO_DATE" value="${formData.RFX_TO_DATE}"/>
		<e:inputHidden id="SEND_FLAG" name="SEND_FLAG" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${empty formData.VENDOR_CD ? ses.companyCd : formData.VENDOR_CD}" />

		<e:buttonBar id="buttonL" align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}" data="T"/>
			<e:button id="doSubmit" name="doSubmit" label="${doSubmit_N}" onClick="doSave" disabled="${doSubmit_D}" visible="${doSubmit_V}" data="S"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>
		<e:searchPanel id="form1" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch" title="요청정보" useTitleBar="true">
			<e:row>
				<%--견적요청번호--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
					<e:inputText id="RFX_NUM" name="RFX_NUM" value="${formData.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
					<e:text> / </e:text>
					<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${formData.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<%--회사명--%>
				<e:label for="BUYER_CD" title="${form_BUYER_CD_N}" />
				<e:field>
					<e:select id="BUYER_CD" name="BUYER_CD" value="${formData.BUYER_CD}" options="${buyerCdOptions}" width="${form_BUYER_CD_W}" disabled="${form_BUYER_CD_D}" readOnly="${form_BUYER_CD_RO}" required="${form_BUYER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%--견적명--%>
				<e:label for="RFX_SUBJECT" title="${form_RFX_SUBJECT_N}" />
				<e:field colSpan="3">
					<e:inputText id="RFX_SUBJECT" name="RFX_SUBJECT" value="${formData.RFX_SUBJECT}" width="${form_RFX_SUBJECT_W}" maxLength="${form_RFX_SUBJECT_M}" disabled="${form_RFX_SUBJECT_D}" readOnly="${form_RFX_SUBJECT_RO}" required="${form_RFX_SUBJECT_R}" />
				</e:field>
			</e:row>
			<e:row>
				<%--구매담당자/부서--%>
				<e:label for="CTRL_USER_NM" title="${form_CTRL_USER_NM_N}" />
				<e:field>
					<e:inputText id="CTRL_USER_NM" name="CTRL_USER_NM" value="${formData.CTRL_USER_NM}" width="${form_CTRL_USER_NM_W}" maxLength="${form_CTRL_USER_NM_M}" disabled="${form_CTRL_USER_NM_D}" readOnly="${form_CTRL_USER_NM_RO}" required="${form_CTRL_USER_NM_R}" />
					<e:text> / </e:text>
					<e:inputText id="CTRL_DEPT_NM" name="CTRL_DEPT_NM" value="${formData.CTRL_DEPT_NM}" width="${form_CTRL_DEPT_NM_W}" maxLength="${form_CTRL_DEPT_NM_M}" disabled="${form_CTRL_DEPT_NM_D}" readOnly="${form_CTRL_DEPT_NM_RO}" required="${form_CTRL_DEPT_NM_R}" />
				</e:field>
				<%--견적기간--%>
				<e:label for="RFX_START_END_DATE" title="${form_RFX_START_END_DATE_N}" />
				<e:field>
					<e:inputText id="RFX_START_END_DATE" name="RFX_START_END_DATE" value="${formData.RFX_START_END_DATE}" width="${form_RFX_START_END_DATE_W}" maxLength="${form_RFX_START_END_DATE_M}" disabled="${form_RFX_START_END_DATE_D}" readOnly="${form_RFX_START_END_DATE_RO}" required="${form_RFX_START_END_DATE_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>
		<e:searchPanel id="form2" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch" title="견적서정보" useTitleBar="true">
			<e:row>
				<%--견적서번호--%>
				<e:label for="QTA_NUM" title="${form_QTA_NUM_N}" />
				<e:field>
					<e:inputText id="QTA_NUM" name="QTA_NUM" value="${formData.QTA_NUM}" width="${form_QTA_NUM_W}" maxLength="${form_QTA_NUM_M}" disabled="${form_QTA_NUM_D}" readOnly="${form_QTA_NUM_RO}" required="${form_QTA_NUM_R}" />
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
				<e:label for="QTA_AMT" title="${form_QTA_AMT_N}"/>
				<e:field>
					<e:inputText id="CUR" name="CUR" value="${formData.CUR}" width="${form_CUR_W}" maxLength="${form_CUR_M}" disabled="${form_CUR_D}" readOnly="${form_CUR_RO}" required="${form_CUR_R}" />
					<e:inputNumber id="QTA_AMT" name="QTA_AMT" value="${formData.QTA_AMT}" width="${form_QTA_AMT_W}" maxValue="${form_QTA_AMT_M}" decimalPlace="${form_QTA_AMT_NF}" disabled="${form_QTA_AMT_D}" readOnly="${form_QTA_AMT_RO}" required="${form_QTA_AMT_R}" />
				</e:field>
				<%--견적유효기간--%>
				<e:label for="VALID_TO_DATE" title="${form_VALID_TO_DATE_N}"/>
				<e:field>
					<e:inputDate id="VALID_TO_DATE" name="VALID_TO_DATE" value="${formData.VALID_TO_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_VALID_TO_DATE_R}" disabled="${form_VALID_TO_DATE_D}" readOnly="${form_VALID_TO_DATE_RO}" />
				</e:field>
			</e:row>
			<e:row>
				<%--특기사항--%>
				<e:label for="RMK_TEXT" title="${form_RMK_TEXT_N}" />
				<e:field colSpan="3">
					<e:textArea id="RMK_TEXT" name="RMK_TEXT" value="${formData.RMK_TEXT}" height="100px" width="${form_RMK_TEXT_W}" maxLength="${form_RMK_TEXT_M}" disabled="${form_RMK_TEXT_D}" readOnly="${form_RMK_TEXT_RO}" required="${form_RMK_TEXT_R}" />
					<e:inputHidden id="RMK" name="RMK" value="${formData.RMK}"/>
				</e:field>
			</e:row>
			<e:row>
				<%--구매사 첨부파일--%>
				<e:label for="B_ATT_FILE_NUM" title="${form_B_ATT_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="B_ATT_FILE_NUM" name="B_ATT_FILE_NUM" fileId="${formData.form_B_ATT_FILE_NUM_W}"  width="${form_B_ATT_FILE_NUM_W}" readOnly="${true}" required="${form_B_ATT_FILE_NUM_R}" bizType="QT" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess"  fileExtension="${fileExtension}" />				</e:field>
				<%--협력사 첨부파일--%>
				<e:label for="V_ATT_FILE_NUM" title="${form_V_ATT_FILE_NUM_N}" />
				<e:field>
					<e:fileManager id="V_ATT_FILE_NUM" name="V_ATT_FILE_NUM" fileId="${formData.V_ATT_FILE_NUM}" width="${form_V_ATT_FILE_NUM_W}" readOnly="${form_V_ATT_FILE_NUM_RO}" required="${form_V_ATT_FILE_NUM_R}" bizType="QT" height="100px" downloadable="true" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess"  fileExtension="${fileExtension}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

	</e:window>
</e:ui>