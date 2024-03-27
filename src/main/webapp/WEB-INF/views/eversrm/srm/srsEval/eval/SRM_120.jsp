<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/eversrm/srm/srsEval/eval/";
    var gridUs;
    var gridSG;

    function init() {
    	gridUs = EVF.C("gridUs");
    	gridSG = EVF.C("gridSG");



    	gridSG.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
		});

    	gridUs.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
		});
    }



    function getContentTab(uu) {
        if (uu == '1') {
        }
        if (uu == '2') {
        }
      }

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                  activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                  }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        //getContentTab('1');
      });
    function doSelectUser() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }
    function selectUser(dataJsonArray) {
        EVF.C("EV_CTRL_NM").setValue(dataJsonArray.USER_NM);
        EVF.C("EV_CTRL_USER_ID").setValue(dataJsonArray.USER_ID);
    }
    function doSearchSiTempl() {
        var param = {
            callBackFunction: "selectSiTempl",
            EV_TPL_TYPE_CD: "SIRA"
        };
        everPopup.openCommonPopup(param, 'SP0033');
    }
    function selectSiTempl(dataJsonArray) {
        EVF.C("SI_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.C("EV_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);
    }
    function doSearchRaTempl() {
        var param = {
            callBackFunction: "selectRaTempl",
            EV_TPL_TYPE_CD: "SIRA"
        };
        everPopup.openCommonPopup(param, 'SP0033');
    }
    function selectRaTempl(dataJsonArray) {
        EVF.C("RA_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.C("RA_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);

    }
    function doImportUs() {
        var store = new EVF.Store();
        store.setGrid([gridSG]);
        store.load(baseUrl + "SRM_120/doImportSg", function() {
        });
    }

    function doImportUs() {
        var store = new EVF.Store();
        store.setGrid([gridUs]);
        store.load(baseUrl + "SRM_120/doImportUs", function() {
        });
    }


    function selectUser(data) {
    	var existUser = true;

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
    	            		,USER_NM :    data.USER_NM
    	            		,DEPT_NM :    data.DEPT_NM
    	            		,REP_FLAG :   data.REP_FLAG != undefined ? data.REP_FLAG : ''


    	            	}
    	            ];
	    	gridUs.addRow(addParam);
	    }

	    doCountUs();
    }

    function doCountUs() {
    	var cnt = 0;
		for(var i = 0; i < gridUs.getRowCount(); i++){
	   		cnt = cnt + 1;
	   	}

	   	EVF.C('EVUS_CNT').setValue(cnt);
    }

    </script>

<e:window id="SRM_120" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
			<e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
			<e:button id="doCancelCom" name="doCancelCom" label="${doCancelCom_N}" onClick="doCancelCom" disabled="${doCancelCom_D}" visible="${doCancelCom_V}"/>
        </e:buttonBar>


        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
				<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
				<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="100%" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:inputText id="PROGRESS_CD" style="ime-mode:inactive" name="PROGRESS_CD" value="${form.PROGRESS_CD}" width="100%" maxLength="${form_PROGRESS_CD_M}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}"/>
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EV_NM" title="${form_EV_NM_N}"/>
				<e:field>
				<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
				</e:field>
				<e:label for="EV_CTRL_NM" title="${form_EV_CTRL_NM_N}"/>
				<e:field>
				<e:search id="EV_CTRL_NM" style="${imeMode}" name="EV_CTRL_NM" value="" width="${inputTextWidth}" maxLength="${form_EV_CTRL_NM_M}" onIconClick="${form_EV_CTRL_NM_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" />
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="EV_TPL_SUBJECT" title="${form_EV_TPL_SUBJECT_N}"/>
				<e:field>
				<e:search id="EV_TPL_SUBJECT" style="ime-mode:auto" name="EV_TPL_SUBJECT" value="" width="${inputTextWidth}" maxLength="${form_EV_TPL_SUBJECT_M}" onIconClick="${form_EV_TPL_SUBJECT_RO ? 'everCommon.blank' : 'doSearchSiTempl'}" disabled="${form_EV_TPL_SUBJECT_D}" readOnly="${form_EV_TPL_SUBJECT_RO}" required="${form_EV_TPL_SUBJECT_R}" />
				<e:inputHidden id="SI_EV_TPL_NUM" name="SI_EV_TPL_NUM" value="${form.SI_EV_TPL_NUM }"/>
				</e:field>
				<e:label for="RA_TPL_SUBJECT" title="${form_RA_TPL_SUBJECT_N}"/>
				<e:field>
				<e:search id="RA_TPL_SUBJECT" style="ime-mode:auto" name="RA_TPL_SUBJECT" value="" width="${inputTextWidth}" maxLength="${form_RA_TPL_SUBJECT_M}" onIconClick="${form_RA_TPL_SUBJECT_RO ? 'everCommon.blank' : 'doSearchRaTempl'}" disabled="${form_RA_TPL_SUBJECT_D}" readOnly="${form_RA_TPL_SUBJECT_RO}" required="${form_RA_TPL_SUBJECT_R}" />
				<e:inputHidden id="RA_EV_TPL_NUM" name="RA_EV_TPL_NUM" value="${form.RA_EV_TPL_NUM }"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
				<e:inputDate id="START_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
				<e:text>~</e:text>
				<e:inputDate id="END_DATE" name="END_DATE" value="${form.END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>
				<e:label for="EG_NUM" title="${form_EG_NUM_N}"/>
				<e:field>
				<e:select id="EG_NUM" name="EG_NUM" value="${form.EG_NUM}" options="${egmtList}" width="${inputTextWidth}" disabled="${form_EG_NUM_D}" readOnly="${form_EG_NUM_RO}" required="${form_EG_NUM_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="RESULT_ENTER_CD" title="${form_RESULT_ENTER_CD_N}"/>
				<e:field colSpan="3">
				<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${form.RESULT_ENTER_CD}" options="${result_enter_cd }" width="${inputTextWidth}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="EVUS_CNT" title="${form_EVUS_CNT_N}"/>
				<e:field>
				<e:inputNumber id="EVUS_CNT" name="EVUS_CNT" value="${form.EVUS_CNT}" maxValue="${form_EVUS_CNT_M}" decimalPlace="${form_EVUS_CNT_NF}" disabled="${form_EVUS_CNT_D}" readOnly="${form_EVUS_CNT_RO}" required="${form_EVUS_CNT_R}" />
				</e:field>
				<e:label for="EVSG_CNT" title="${form_EVSG_CNT_N}"/>
				<e:field>
				<e:inputNumber id="EVSG_CNT" name="EVSG_CNT" value="${form.EVSG_CNT}" maxValue="${form_EVSG_CNT_M}" decimalPlace="${form_EVSG_CNT_NF}" disabled="${form_EVSG_CNT_D}" readOnly="${form_EVSG_CNT_RO}" required="${form_EVSG_CNT_R}" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
				<e:field>
				<e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>
				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
				<e:field>
				<e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${form.REG_USER_NM}" width="100%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="REQUEST_DATE" title="${form_REQUEST_DATE_N}"/>
				<e:field>
				<e:inputDate id="REQUEST_DATE" name="REQUEST_DATE" value="${form.REQUEST_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REQUEST_DATE_R}" disabled="${form_REQUEST_DATE_D}" readOnly="${form_REQUEST_DATE_RO}" />
				</e:field>
				<e:label for="COMPLETE_DATE" title="${form_COMPLETE_DATE_N}"/>
				<e:field>
				<e:inputDate id="COMPLETE_DATE" name="COMPLETE_DATE" value="${form.COMPLETE_DATE}" width="${inputTextDate}" datePicker="true" required="${form_COMPLETE_DATE_R}" disabled="${form_COMPLETE_DATE_D}" readOnly="${form_COMPLETE_DATE_RO}" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
				<e:field colSpan="3">
			        <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView ? true : false}"  fileId="${formData.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
        </e:searchPanel>

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">소싱그룹</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">평가자</a></li>
          </ul>
          <div id="ui-tabs-1">
			<div style="height: auto;">

	        <e:buttonBar align="right">
				<e:button id="doImportSg" name="doImportSg" label="${doImportSg_N}" onClick="doImportSg" disabled="${doImportSg_D}" visible="${doImportSg_V}"/>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridSG" name="gridSG" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridSG.gridColData}"/>
				</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
	        <e:buttonBar align="right">
				<e:button id="doImportUs" name="doImportUs" label="${doImportUs_N}" onClick="doImportUs" disabled="${doImportUs_D}" visible="${doImportUs_V}"/>
			</e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridUs.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
	</div>

</e:window>
</e:ui>