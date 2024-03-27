<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/eversrm/srm/regEval/eval/";
    var gridSg;
    var gridUs;

    function init() {
    	if(opener === undefined || opener == null) {
    		EVF.C('doClose').setVisible(false);
    	} else {
    		EVF.C('doClose').setVisible(true);
    	}

    	if( '${param.detailView}' == 'true' ) {
    		EVF.getComponent('doImportSg').setVisible(false);
    		EVF.getComponent('doDelSg').setVisible(false);
    		EVF.getComponent('doImportUs').setVisible(false);
    		EVF.getComponent('doDelUs').setVisible(false);
    	} else {
    		EVF.getComponent('doImportSg').setVisible(true);
    		EVF.getComponent('doDelSg').setVisible(true);
    		EVF.getComponent('doImportUs').setVisible(true);
    		EVF.getComponent('doDelUs').setVisible(true);
    	}

    	var gbn = "";
    	if( "${form.EV_NUM}" == "" ) {
	    	EVF.getComponent('PURCHASE_TYPE').setValue('PPUR');
	    	EVF.getComponent('RESULT_ENTER_CD').setValue('EVALUSER');
	    	EVF.C('EV_CTRL_NM').setValue('${ses.userNm}');
	    	EVF.C('EV_CTRL_USER_ID').setValue('${ses.userId}');
	    	EVF.C('doSearch').setVisible(false);
	    	EVF.C('doDelete').setVisible(false);
	    	EVF.C('doRequest').setVisible(false);
	    	EVF.C('doCancel').setVisible(false);
	    	if( "${form.EV_TYPE}" == "" ) {
	    		EVF.getComponent('EV_TYPE').setValue('NEW');
	    	}
    	} else {
    		gbn = "E";

    		if('${ses.userId}' != EVF.C('EV_CTRL_USER_ID').getValue()) {
    	    	EVF.C('doSearch').setVisible(false);
    	    	EVF.C('doSave').setVisible(false);
    	    	EVF.C('doDelete').setVisible(false);
    	    	EVF.C('doRequest').setVisible(false);
    	    	EVF.C('doCancel').setVisible(false);
        		EVF.getComponent('doImportSg').setVisible(false);
        		EVF.getComponent('doDelSg').setVisible(false);
        		EVF.getComponent('doImportUs').setVisible(false);
        		EVF.getComponent('doDelUs').setVisible(false);
    		}
    	}

    	<%-- 재평가(RE)시 신규평가 표시되지 않게 함. --%>
    	if("${form.EV_TYPE}" == "RE") {
    		 $("#EV_TYPE option[value='NEW']").detach();
    	}

    	gridUs = EVF.C("gridUs");
    	gridSg = EVF.C("gridSg");


    	gridUs.setProperty('panelVisible', ${panelVisible});
    	gridSg.setProperty('panelVisible', ${panelVisible});


    	gridSg.setProperty('shrinkToFit', true);
    	gridUs.setProperty('shrinkToFit', true);

    	if( gbn == "" ) {
	    	doSearch();
    	} else {
    		doSearchSg();
            doSearchUs();
    	}

    }

    function doSearch(gbn) {

        var store = new EVF.Store();
        store.load(baseUrl + "SRM_045/doSearch", function() {

        	<%--// Map 형태의 Key 값을 받아서 --%>
            var formValue = JSON.parse(this.getParameter("form"));

            if( formValue != null && formValue.length > 0 ) {
            	//console.log(formValue);
            	var formKey = Object.keys(formValue);
	            <%--// 계약정보 셋팅  --%>
	            for (var i = 0; i < formKey.length; i++) {
	              if(formKey[i] != "ATT_FILE_NUM" ) {
	            	//console.log(">>>> "+formKey.EV_CTRL_USER_ID);
	            	//console.log(">>>> "+formValue[formKey[i]]);
		                EVF.getComponent(formKey[i]).setValue(formValue[formKey[i]]);
	                }
	             }
            }

            doSearchSg();
            doSearchUs();

        });

    }

    function doSearchSg() {

        var store = new EVF.Store();
        store.setGrid([gridSg]);
        store.load(baseUrl + "SRM_045/doSearchSg", function() {
        });

    }

    function doSearchUs() {

        var store = new EVF.Store();
        store.setGrid([gridUs]);
        store.load(baseUrl + "SRM_045/doSearchUs", function() {
        });

    }

	function searchVendorCd() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		everPopup.openCommonPopup(param, 'SP0013');
    }
    function selectVendorCd(data) {
		var existVendor = true;

    	if(data.VENDOR_CD == ''){
    		return;
    	}
	   	EVF.getComponent('VENDOR_NM').setValue(data.VENDOR_NM);
	   	EVF.getComponent('VENDOR_CD').setValue(data.VENDOR_CD);
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
        EVF.getComponent("EV_CTRL_NM").setValue(dataJsonArray.USER_NM);
        EVF.getComponent("EV_CTRL_USER_ID").setValue(dataJsonArray.USER_ID);
    }
    function doSearchScTempl() {
        var param = {
            callBackFunction: "selectScTempl",
            EV_TPL_TYPE_CD: "S"
        };
        everPopup.openCommonPopup(param, 'SP0033');
    }
    function selectScTempl(dataJsonArray) {
        EVF.getComponent("SCRE_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.getComponent("SITE_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.getComponent("EV_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);
    }
    function doSearchRaTempl() {
        var param = {
            callBackFunction: "selectRaTempl",
            EV_TPL_TYPE_CD: "SIRA"
        };
        everPopup.openCommonPopup(param, 'SP0033');
    }
    function selectRaTempl(dataJsonArray) {
        EVF.getComponent("RA_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.getComponent("RA_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);

    }
    <%-- 소싱그룹팝업 --%>
    function doImportSg() {
    	var param = {
                callBackFunction: "setSg",
                GATE_CD : "${ses.gateCd}"
         };
    	everPopup.openCommonPopup(param, 'SP0041');

    }

    function setSg(selectedData) {

    		addParam = [
   	            	{
   	        	    	 "CLS1" : selectedData.ITEM_CLS_NM1
   	        	    	,"CLS2" : selectedData.ITEM_CLS_NM2
   	        	    	,"CLS3" : selectedData.ITEM_CLS_NM3
   	        	    	,"CLS4" : selectedData.ITEM_CLS_NM4
   	        	    	,"SG_NUM" :   selectedData.SG_NUM
   	        	    	,"EV_NUM" :   ''
   	        	    	,"DEL_FLAG" :  ''
   	            	}
   	         ];
    		 gridSg.addRow(addParam);

    }

    function doDelSg() {
    	var selRowId = gridSg.jsonToArray(gridSg.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
        	gridSg.delRow(selRowId[i]);
        	//gridSg.setCellValue(selRowId[i], 'DEL_FLAG', '1');
        	//gridSg.setRowBackColor(selRowId[i], '100|100|100');
        }
    }

    <%-- 평가자팝업 --%>
    function doImportUs() {
    	var param = {
               GATE_CD:  '${ses.gateCd}'
               , callBackFunction: 'selectUserG'
           };
   		//everPopup.openCommonPopup(param,"SP0001");
   		everPopup.openCommonPopup(param,"SP0056");
    }

    function selectUserG(data) {
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

    }

    function doDelUs() {
    	var selRowId = gridUs.jsonToArray(gridUs.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
        	gridUs.delRow(selRowId[i]);
        	//gridUs.setCellValue(selRowId[i], 'DEL_FLAG', '1');
        	//gridUs.setRowBackColor(selRowId[i], '100|100|100');
        }
    }

/*     function clearGridA(){
    	gridUs.delAllRow();
    	gridSg.delAllRow();
    } */

    <%-- 저장 --%>
    function doSave() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		<%--// 날짜 체크--%>
        if(!everDate.checkTermDate('START_DATE','END_DATE','${msg.M0073}')) {
            return;
        }

		if('${_gridType}' == "RG") {
			gridSg.checkAll(true);
			gridUs.checkAll(true);
		} else {
			gridSg.allRowCheck(true);
			gridUs.allRowCheck(true);
		}

		if ((gridSg.jsonToArray(gridSg.getSelRowId()).value).length == 0) {
            alert("${SRM_045_0003}");//
            return;
        }

		if ((gridUs.jsonToArray(gridUs.getSelRowId()).value).length == 0) {
            alert("${SRM_045_0004}");
            return;
        }

    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}

    	store.setGrid([gridSg]);
		store.getGridData(gridSg, 'sel');

    	store.setGrid([gridUs]);
		store.getGridData(gridUs, 'sel');

    	store.doFileUpload(function() {
			store.load(baseUrl + '/SRM_045/doSave', function() {
				alert(this.getResponseMessage());
				EVF.getComponent("EV_NUM").setValue(this.getParameter('EV_NUM'));
				location.href='/eversrm/srm/regEval/eval/SRM_045/view.so?EV_NUM='+this.getParameter('EV_NUM');
			});
    	});

    }

    <%-- 평가요청 --%>
    function doRequest() {

		var store = new EVF.Store();
		if (!store.validate())
			return;

		if('${_gridType}' == "RG") {
			gridSg.checkAll(true);
			gridUs.checkAll(true);
		} else {
			gridSg.allRowCheck(true);
			gridUs.allRowCheck(true);
		}

		if ((gridSg.jsonToArray(gridSg.getSelRowId()).value).length == 0) {
            alert("${SRM_045_0010}");
            return;
        }

		if ((gridUs.jsonToArray(gridUs.getSelRowId()).value).length == 0) {
            alert("${SRM_045_0010}");
            return;
        }

    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}

    	store.setGrid([gridSg]);
		store.getGridData(gridSg, 'sel');

    	store.setGrid([gridUs]);
		store.getGridData(gridUs, 'sel');

    	store.doFileUpload(function() {
			store.load(baseUrl + '/SRM_045/doRequest', function() {
				alert(this.getResponseMessage());
				location.href='/eversrm/srm/regEval/eval/SRM_045/view.so?EV_NUM='+this.getParameter('EV_NUM');
			});
    	});

    }

    <%-- 삭제 --%>
    function doDelete() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		if('${_gridType}' == "RG") {
			gridSg.checkAll(true);
			gridUs.checkAll(true);
		} else {
			gridSg.allRowCheck(true);
			gridUs.allRowCheck(true);
		}

    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}

    	store.setGrid([gridSg]);
		store.getGridData(gridSg, 'sel');

    	store.setGrid([gridUs]);
		store.getGridData(gridUs, 'sel');

    	store.doFileUpload(function() {
			store.load(baseUrl + '/SRM_045/doDelete', function() {
				alert(this.getResponseMessage());

				location.href='/eversrm/srm/regEval/eval/SRM_045/view';
			});
    	});

    }

    <%-- 요청취소 --%>
    function doCancel() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

/*
		gridSg.checkAll(true);
		gridUs.checkAll(true);

		if ((gridSg.jsonToArray(gridSg.getSelRowId()).value).length == 0) {
            alert("${SRM_045_0010}");
            return;
        }

		if ((gridUs.jsonToArray(gridUs.getSelRowId()).value).length == 0) {
            alert("${SRM_045_0010}");
            return;
        }
 */

    	if (!confirm("${msg.M8888}")) { //처리하시겠습니까?
			return;
		}

    	store.setGrid([gridSg]);
		store.getGridData(gridSg, 'sel');

    	store.setGrid([gridUs]);
		store.getGridData(gridUs, 'sel');

    	store.doFileUpload(function() {
			store.load(baseUrl + '/SRM_045/doCancel', function() {
				alert(this.getResponseMessage());
				location.href='/eversrm/srm/regEval/eval/SRM_045/view.so?EV_NUM='+this.getParameter('EV_NUM');
			});
    	});

    }

    function doClose() {
    	formUtil.close();
    }
    </script>

	<e:window id="SRM_045" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>


        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">

        	<e:inputHidden id="SG_NUM" name="SG_NUM" value="${form.SG_NUM }"/>


            <e:row>
				<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
				<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="${inputTextWidth}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:inputText id="PROGRESS_NM" style="ime-mode:inactive" name="PROGRESS_NM" value="${form.PROGRESS_NM}" width="${inputTextWidth}"  maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}"/>
				<e:inputHidden id="PROGRESS_CD" style="ime-mode:inactive" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="EV_NM" title="${form_EV_NM_N}"/>
				<e:field>
				<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
				</e:field>
				<e:label for="EV_CTRL_NM" title="${form_EV_CTRL_NM_N}"/>
				<e:field>
				<e:search id="EV_CTRL_NM" style="${imeMode}" name="EV_CTRL_NM" value="${form.EV_CTRL_NM }" width="${inputTextWidth}" maxLength="${form_EV_CTRL_NM_M}" onIconClick="${form_EV_CTRL_NM_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" />
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
				<e:field>
				<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
				<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${inputTextWidth}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>

            	<e:label for="EV_TPL_SUBJECT" title="${form_EV_TPL_SUBJECT_N}"/>
				<e:field>
				<e:search id="EV_TPL_SUBJECT" style="ime-mode:auto" name="EV_TPL_SUBJECT" value="${form.EV_TPL_SUBJECT }" width="100%" maxLength="${form_EV_TPL_SUBJECT_M}" onIconClick="${form_EV_TPL_SUBJECT_RO ? 'everCommon.blank' : 'doSearchScTempl'}" disabled="${form_EV_TPL_SUBJECT_D}" readOnly="${form_EV_TPL_SUBJECT_RO}" required="${form_EV_TPL_SUBJECT_R}" />
				<e:inputHidden id="SCRE_EV_TPL_NUM" name="SCRE_EV_TPL_NUM" value="${form.SCRE_EV_TPL_NUM }"/>
				<e:inputHidden id="SITE_EV_TPL_NUM" name="SITE_EV_TPL_NUM" value="${form.SITE_EV_TPL_NUM }"/>
				</e:field>

				<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
				<e:field>
				<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM }" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD }"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
				<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
				<e:text>~</e:text>
				<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${form.END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
				</e:field>

				<e:label for="RESULT_ENTER_CD" title="${form_RESULT_ENTER_CD_N}"/>
				<e:field>
				<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${form.RESULT_ENTER_CD}" options="${resultEnterCdOptions}" width="${inputTextWidth}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
				<e:field>
				<e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>


				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
				<e:field>
				<e:inputText id="REG_USER_NM" style="ime-mode:inactive" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${inputTextWidth}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
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
			        <e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" readOnly="${param.detailView ? true : false}"  fileId="${form.ATT_FILE_NUM}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
				</e:field>
			</e:row>
        </e:searchPanel>

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
        <td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="getContentTab('1');">${form_TAB_SG_N}</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="getContentTab('2');">${form_TAB_VU_N}</a></li>
          </ul>
          <div id="ui-tabs-1">
			<div style="height: auto;">

	        <e:buttonBar align="right">
				<e:button id="doImportSg" name="doImportSg" label="${doImportSg_N}" onClick="doImportSg" disabled="${doImportSg_D}" visible="${doImportSg_V}"/>
				<e:button id="doDelSg" name="doDelSg" label="${doDelSg_N}" onClick="doDelSg" disabled="${doDelSg_D}" visible="${doDelSg_V}"/>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridSg" name="gridSg" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridSg.gridColData}"/>
				</div>
          </div>

          <div id="ui-tabs-2">
			<div style="height: auto;">
	        <e:buttonBar align="right">
				<e:button id="doImportUs" name="doImportUs" label="${doImportUs_N}" onClick="doImportUs" disabled="${doImportUs_D}" visible="${doImportUs_V}"/>
				<e:button id="doDelUs" name="doDelUs" label="${doDelUs_N}" onClick="doDelUs" disabled="${doDelUs_D}" visible="${doDelUs_V}"/>
			</e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridUs.gridColData}"/>
			</div>
          </div>
		</div></td>
	</div>

</e:window>
</e:ui>