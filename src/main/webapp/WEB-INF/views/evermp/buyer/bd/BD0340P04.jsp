<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script>
	    var baseUrl = "/evermp/buyer/bd/BD0340P04";
	    var gridVendor;
	    var gridUs;


	    function init() {
		    gridVendor = EVF.getComponent("gridVendor");
		    gridVendor.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
		    gridVendor.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
		    gridVendor.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
		    gridVendor.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
		    gridVendor.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
		    gridVendor.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
		    gridVendor.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

		    gridVendor.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

		    });




		    gridUs = EVF.getComponent("gridUs");
		    gridUs.setProperty("shrinkToFit", ${shrinkToFit});        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
		    gridUs.setProperty("rowNumbers", ${rowNumbers});          // 로우의 번호 표시 여부를 지정한다. [true/false]
		    gridUs.setProperty("sortable", ${sortable});              // 컬럼 정렬기능 사용여부를 지정한다. [true/false]
		    gridUs.setProperty("panelVisible", ${panelVisible});      // 그리드 상단에 컬럼그룹핑 패널의 표시 여부를 지정한다. [true/false]
		    gridUs.setProperty("enterToNextRow", ${enterToNextRow});  // 셀에서 엔터입력 시 포커스의 이동방향을 지정한다. [true/false]
		    gridUs.setProperty("acceptZero", ${acceptZero});          // 그리드의 셀이 숫자형일 때 0인 데이터에 대한 필수입력처리 여부를 지정한다. [true/false]
		    gridUs.setProperty("multiSelect", ${multiSelect});        // [선택] 컬럼의 사용여부를 지정한다. [true/false]

		    gridUs.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

		    });

		    doSearch();
		    doSearch_gridUs();
	    }

	    <%-- 템플릿 팝업 --%>
	    function doSearchTempl() {
		    var param = {
			    callBackFunction: "selectTemplAfter"
			    ,EV_TYPE: "R"
		    };
		    everPopup.openCommonPopup(param, 'SP0034');
	    }

	    <%-- 템플릿 세팅 --%>
	    function selectTemplAfter(dataJsonArray) {
		    EVF.C("EXEC_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
		    EVF.C("EV_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);
	    }

	    <%-- 평가자 추가 --%>
	    function doAddUs() {
	    	var popupUrl = "/eversrm/master/user/BADU_050/view.so?";
		    var param = {
			      detailView: false
				, multiYN: true
			    , callBackFunction: 'selectUs'
		    };
		    everPopup.openModalPopup(popupUrl, 800, 700, param);
	    }

	    <%-- 평가자 세팅 --%>
	    function selectUs(userList) {
		    var existUser = true;

		    $(userList).each(function(idx, data){

			    if(data.USER_ID == ''){
				    return;
			    }

			    for (var i = 0, length = gridUs.getRowCount(); i < length; i++) {
				    if (gridUs.getCellValue(i,"EV_USER_ID") == data.USER_ID) {
					    existUser = false;
				    }
			    }

			    if(existUser){
				    addParam = [
					    {
						     EV_USER_ID : data.USER_ID
						    ,USER_NM    : data.USER_NM
						    ,DEPT_NM    : data.DEPT_NM
						    ,REP_FLAG   : data.REP_FLAG != undefined ? data.REP_FLAG : ''
					    }
				    ];

				    var rowIdx = gridUs.addRow(addParam);

				    var resultEnterCd = EVF.V("RESULT_ENTER_CD");
				    var allRowId = gridUs.getAllRowId();

				    for(var i in allRowId) {
					    var rowIdx = allRowId[i];
					    if(resultEnterCd == 'REPUSER') {
						    gridUs.setCellReadOnly(rowIdx, "REP_FLAG", false);
					    }else {
						    gridUs.setCellReadOnly(rowIdx, "REP_FLAG", true);
					    }
				    }
			    }else{
				    EVF.alert("동일한 평가자가 존재합니다.");
			    }
		    });

	    }

	    function USER_COPY(rowIdx) {
		    var allRowValue = gridUs.getAllRowValue();
		    gridVendor._gdp.setValue(rowIdx, "USER_INFO", JSON.stringify(allRowValue));
	    }

	    <%-- 평가자 삭제 --%>
	    function doDelUs() {
		    var selRowId = gridUs.jsonToArray(gridUs.getSelRowId()).value;
		    for (var i = 0; i < selRowId.length; i++) {
			    gridUs.delRow(selRowId[i]);
		    }
	    }
	    function selectCtrlUser(){
			var param = {
				custCd           : "${formData.BUYER_CD}",
				callBackFunction : "callBack_selectCtrlUser",
			};
			everPopup.openCommonPopup(param, "SP0040");
		}

		function callBack_selectCtrlUser(data){
			EVF.V('EV_CTRL_NM', data.USER_NM);
			EVF.V('EV_CTRL_USER_ID', data.USER_ID);
		}

	    function doSearch() {
	        var store = new EVF.Store();
	        store.setGrid([gridVendor]);
	        store.load(baseUrl + "/doSearch", function() {
		        //doSearch_gridUs();
	        });
        }

        function doSearch_gridUs(){
	        var store = new EVF.Store();
	        store.setGrid([gridUs]);
	        store.load(baseUrl + "/doSearch_gridUs", function() {

	        });
		}

	    function doClose() {
		    if(opener != null) {
			    window.close();
		    } else {
			    new EVF.ModalWindow().close(null);
		    }
	    }


        function doClose2() {
     		if(opener != null) {
		        if(opener.doSearch !== undefined) {
			        opener.doSearch();
		        }
     			window.close();
     		} else {
		        if(parent.doSearch !== undefined) {
			        parent.doSearch();
		        }
     			new EVF.ModalWindow().close(null);
     		}
        }


		function doReqEV(){
			var store = new EVF.Store();
			gridVendor.checkAll(true);
			gridUs.checkAll(true);
			if (!store.validate()){
				return;
			}

			if (!gridUs.isExistsSelRow()) {
				EVF.alert("${BD0340P04_0001}");
				return;
			}


			EVF.confirm("${BD0340P04_0002}", function () {
				store.setGrid([gridUs, gridVendor]);
				store.getGridData(gridUs, 'sel');
				store.getGridData(gridVendor, 'sel');
				store.doFileUpload(function() {
					store.load(baseUrl + '/doReqEV', function() {
						EVF.alert(this.getResponseMessage(), function() {
							doClose2();
						});
					});
				});
			});
		}


	</script>

	<e:window id="BD0340P04" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
		<e:buttonBar align="right" title="평가요청">
			<e:button id="doReqEV" name="doReqEV" label="${doReqEV_N}" onClick="doReqEV" disabled="${doReqEV_D}" visible="${doReqEV_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
		</e:buttonBar>

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2" useTitleBar="false" onEnter="doSearch">
        	<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_CD}"/>
            <e:row>
				<%--입찰요청 번호 / 차수--%>
				<e:label for="RFX_NUM" title="${form_RFX_NUM_N}" />
				<e:field>
				<e:inputText id="RFX_NUM" name="RFX_NUM" value="${form.RFX_NUM}" width="${form_RFX_NUM_W}" maxLength="${form_RFX_NUM_M}" disabled="${form_RFX_NUM_D}" readOnly="${form_RFX_NUM_RO}" required="${form_RFX_NUM_R}" />
				<e:text>&nbsp;&nbsp;&nbsp;/ </e:text>
				<e:inputNumber id="RFX_CNT" name="RFX_CNT" value="${form.RFX_CNT}" width="${form_RFX_CNT_W}" maxValue="${form_RFX_CNT_M}" decimalPlace="${form_RFX_CNT_NF}" disabled="${form_RFX_CNT_D}" readOnly="${form_RFX_CNT_RO}" required="${form_RFX_CNT_R}" />
				</e:field>
				<%--가격/기술 평가비율--%>
				<e:label for="PRC_PERCENT" title="${form_PRC_PERCENT_N}"/>
				<e:field>
					<e:inputNumber id="PRC_PERCENT" name="PRC_PERCENT" value="${form.PRC_PERCENT}" width="${form_PRC_PERCENT_W}" maxValue="${form_PRC_PERCENT_M}" decimalPlace="${form_PRC_PERCENT_NF}" disabled="${form_PRC_PERCENT_D}" readOnly="${form_PRC_PERCENT_RO}" required="${form_PRC_PERCENT_R}" />
					<e:text>%&nbsp;/</e:text>
					<e:inputNumber id="NPRC_PERCENT" name="NPRC_PERCENT" value="${form.NPRC_PERCENT}" width="${form_NPRC_PERCENT_W}" maxValue="${form_NPRC_PERCENT_M}" decimalPlace="${form_NPRC_PERCENT_NF}" disabled="${form_NPRC_PERCENT_D}" readOnly="${form_NPRC_PERCENT_RO}" required="${form_NPRC_PERCENT_R}" />
					<e:text>%&nbsp;</e:text>
				</e:field>
            </e:row>
			<e:row>
				<%-- 평가번호 --%>
				<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
					<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="${form_EV_NUM_W}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				</e:field>
				<%-- 진행상태 --%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
					<e:inputText id="PROGRESS_NM" style="ime-mode:inactive" name="PROGRESS_NM" value="${form.PROGRESS_NM}" width="${form_PROGRESS_NM_W}"  maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}"/>
					<e:inputHidden id="PROGRESS_CD" style="ime-mode:inactive" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
				</e:field>
			</e:row>
			<e:row>
				<%-- 평가명 --%>
				<e:label for="EV_NM" title="${form_EV_NM_N}"/>
				<e:field>
					<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${empty form.EV_NM ? param.RFX_SUBJECT : form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
				</e:field>
				<%-- 파트너사 담당자 --%>
				<e:label for="EV_CTRL_NM" title="${form_EV_CTRL_NM_N}"/>
				<e:field>
					<e:search id="EV_CTRL_NM" style="${imeMode}" name="EV_CTRL_NM" value="${empty form.EV_CTRL_USER_NM ? ses.userNm :  form.EV_CTRL_USER_NM}" width="${form_EV_CTRL_NM_W}" maxLength="${form_EV_CTRL_NM_M}" onIconClick="${form_EV_CTRL_NM_RO ? 'everCommon.blank' : 'selectCtrlUser'}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" />
					<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${empty form.EV_CTRL_USER_ID ? ses.userId : form.EV_CTRL_USER_ID}"/>
				</e:field>
			</e:row>
			<e:row>
				<%-- 거래구분 --%>
				<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
				<e:field>
					<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${empty form.PURCHASE_TYPE ? 'NPUR' : form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${form_PURCHASE_TYPE_W}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>
				<%-- 평가구분 --%>
				<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
					<e:select id="EV_TYPE" name="EV_TYPE" value="R" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%-- 템플릿 --%>
				<e:label for="EV_TPL_SUBJECT" title="${form_EV_TPL_SUBJECT_N}"/>
				<e:field colSpan="3">
					<e:search id="EV_TPL_SUBJECT" style="ime-mode:auto" name="EV_TPL_SUBJECT" value="${form.EV_TPL_SUBJECT }" width="20%" maxLength="${form_EV_TPL_SUBJECT_M}" onIconClick="doSearchTempl" disabled="${form_EV_TPL_SUBJECT_D}" readOnly="${form_EV_TPL_SUBJECT_RO}" required="${form_EV_TPL_SUBJECT_R}" />
					<e:inputHidden id="EXEC_EV_TPL_NUM" name="EXEC_EV_TPL_NUM" value="${form.EXEC_EV_TPL_NUM }"/>
				</e:field>
			</e:row>
			<e:row>
				<%-- 평가기간 --%>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="START_DATE" toDate="CLOSE_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="CLOSE_DATE" fromDate="START_DATE" name="CLOSE_DATE" value="${form.CLOSE_DATE}" width="${inputTextDate}" datePicker="true" required="${form_CLOSE_DATE_R}" disabled="${form_CLOSE_DATE_D}" readOnly="${form_CLOSE_DATE_RO}" />
				</e:field>
				<%-- 결과입력 --%>
				<e:label for="RESULT_ENTER_CD" title="${form_RESULT_ENTER_CD_N}"/>
				<e:field>
					<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${empty form.RESULT_ENTER_CD ? 'PERUSER' : form.RESULT_ENTER_CD}" onChange="chgResult" options="${resultEnterCdOptions }" width="${form_RESULT_ENTER_CD_W}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
			<e:row>
				<%-- 평가생성일 --%>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
				<e:field>
					<e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="false" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>

				<%-- 평가생성자 --%>
				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
				<e:field>
					<e:inputText id="REG_USER_NM" style="ime-mode:auto" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${form_REG_USER_NM_W}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
				</e:field>

			</e:row>
			<e:row>
				<%-- 평가요청일 --%>
				<e:label for="REQUEST_DATE" title="${form_REQUEST_DATE_N}"/>
				<e:field>
					<e:inputDate id="REQUEST_DATE" name="REQUEST_DATE" value="${form.REQUEST_DATE}" width="${inputTextDate}" datePicker="false" required="${form_REQUEST_DATE_R}" disabled="${form_REQUEST_DATE_D}" readOnly="${form_REQUEST_DATE_RO}" />
				</e:field>
				<%-- 평가완료일 --%>
				<e:label for="COMPLETE_DATE" title="${form_COMPLETE_DATE_N}"/>
				<e:field>
					<e:inputDate id="COMPLETE_DATE" name="COMPLETE_DATE" value="${form.COMPLETE_DATE}" width="${inputTextDate}" datePicker="false" required="${form_COMPLETE_DATE_R}" disabled="${form_COMPLETE_DATE_D}" readOnly="${form_COMPLETE_DATE_RO}" />
				</e:field>
			</e:row>
			<e:row>
				<%-- 첨부파일 --%>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
				<e:field colSpan="3">
					<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView ? true : false}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
        </e:searchPanel>

        <e:buttonBar align="right" style="position:absolute;z-index:1;">
			<e:button id="doAddUs" name="doAddUs" label="${doAddUs_N}" onClick="doAddUs" disabled="${doAddUs_D}" visible="${doAddUs_V}"/>
			<e:button id="doDelUs" name="doDelUs" label="${doDelUs_N}" onClick="doDelUs" disabled="${doDelUs_D}" visible="${doDelUs_V}"/>
		</e:buttonBar>

		<div style="padding-top:6px;">
			<e:panel id="panelLeft" width="47%" height="fit">
				<e:searchPanel id="gridVendorTitle" title="협력사" />
				<e:gridPanel gridType="${_gridType}" id="gridVendor" name="gridVendor" width="100%" height="400" readOnly="${param.detailView}" columnDef="${gridInfos.gridVendor.gridColData}"/>
			</e:panel>

			<e:panel id="blank_pn" width="5%">&nbsp;
				<div style="width: 100%; margin-top: 200px; vertical-align: middle;" align="center">
				</div>
			</e:panel>

			<e:panel id="panelRight" width="47%" height="fit" >
				<e:searchPanel id="gridUsTitle" title="평가자" />
				<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" width="100%" height="400" readOnly="${param.detailView}" columnDef="${gridInfos.gridUs.gridColData}"/>
			</e:panel>
		</div>

	</e:window>
</e:ui>