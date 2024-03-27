<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui>
<script>
	var baseUrl = "/evermp/buyer/eval/";
    var gridUs;
	var detailView = "${param.detailView}"=="true"?true:false;
	var popupFlag = "${param.popupFlag}"=="true"?true:false;

    function init() {
    	if(popupFlag) {
    		EVF.C("doClose").setVisible(true);
    	} else {
    		EVF.C("doClose").setVisible(false);
    	}

    	if(detailView) {
    		EVF.C("doImportUs").setVisible(false);
    		EVF.C("doDelUs").setVisible(false);
    	} else {
    		EVF.C("doImportUs").setVisible(true);
    		EVF.C("doDelUs").setVisible(true);
    	}

    	var gbn = "";
    	if( "${form.EV_NUM}" == "" ) {
	    	EVF.C('RESULT_ENTER_CD').setValue('PERUSER');
	    	EVF.C('EV_CTRL_NM').setValue('${ses.userNm}');
	    	EVF.C('EV_CTRL_USER_ID').setValue('${ses.userId}');
	    	EVF.C('doSearch').setVisible(false);
	    	EVF.C('doDelete').setVisible(false);
	    	EVF.C('doRequest').setVisible(false);
	    	EVF.C('doCancel').setVisible(false);
	    	if( "${form.EV_TYPE}" == "" ) {
	    		EVF.C('EV_TYPE').setValue('NEW');
	    	}
    	} else {
    		gbn = "E";

    		if('${ses.userId}' != EVF.C('EV_CTRL_USER_ID').getValue()) {
    	    	EVF.C('doSearch').setVisible(false);
    	    	EVF.C('doSave').setVisible(false);
    	    	EVF.C('doDelete').setVisible(false);
    	    	EVF.C('doRequest').setVisible(false);
    	    	EVF.C('doCancel').setVisible(false);
        		EVF.C('doImportUs').setVisible(false);
        		EVF.C('doDelUs').setVisible(false);
    		} else {
                if("100" != EVF.V("PROGRESS_CD")) {
                    EVF.C("doSave").setVisible(false);
                    EVF.C("doDelete").setVisible(false);
                    EVF.C("doRequest").setVisible(false);
                    EVF.C("doImportUs").setVisible(false);
                    EVF.C("doDelUs").setVisible(false);
                } else {
					EVF.C("doCancel").setVisible(false);
				}
            }
    	}

    	<%-- 재평가(RE)시 신규평가 표시되지 않게 함. --%>
    	if("${form.EV_TYPE}" == "RE") {
    		 $("#EV_TYPE option[value='NEW']").detach();
    	}

    	gridUs = EVF.C("gridUs");

    	gridUs.setProperty('panelVisible', ${panelVisible});
    	gridUs.setProperty('shrinkToFit', true);

    	if( gbn == "" ) {
	    	//doSearch();
    	} else {
            doSearchUs();
    	}

    }

    function doSearch(gbn) {

        var store = new EVF.Store();
        store.load(baseUrl + "EV0045/doSearch", function() {

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
		                EVF.C(formKey[i]).setValue(formValue[formKey[i]]);
	                }
	             }
            }

            doSearchUs();

        });

    }

    function doSearchUs() {

        var store = new EVF.Store();
        store.setGrid([gridUs]);
        store.load(baseUrl + "EV0045/doSearchUs", function() {
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
	   	EVF.C('VENDOR_NM').setValue(data.VENDOR_NM);
	   	EVF.C('VENDOR_CD').setValue(data.VENDOR_CD);
    }

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

    function doSearchScTempl() {
        var param = {
            callBackFunction: "selectScTempl",
            EV_TPL_TYPE_CD: "S"
        };
        everPopup.openCommonPopup(param, 'SP0034');
    }

    function selectScTempl(dataJsonArray) {
        EVF.C("SCRE_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.C("SITE_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.C("EV_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);
    }

    function doSearchRaTempl() {
        var param = {
            callBackFunction: "selectRaTempl",
            EV_TPL_TYPE_CD: "SIRA"
        };
        everPopup.openCommonPopup(param, 'SP0034');
    }

    function selectRaTempl(dataJsonArray) {
        EVF.C("RA_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.C("RA_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);

    }

    <%-- 평가자팝업 --%>
    function doImportUs() {
    	var param = {
               GATE_CD:  '${ses.gateCd}'
               , callBackFunction: 'selectUserG'
           };
   		everPopup.openCommonPopup(param,"MP0007");
    }

    function selectUserG(userList) {
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
				var addParam = [{
					EV_USER_ID: data.USER_ID
					, USER_NM: data.USER_NM
					, DEPT_NM: data.DEPT_NM
					, POSITION_NM: data.POSITION_NM
					, REP_FLAG: data.REP_FLAG != undefined ? data.REP_FLAG : ''
				}];
	    		gridUs.addRow(addParam);
	    	}
		});
    }

    function doDelUs() {
    	var selRowId = gridUs.jsonToArray(gridUs.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
        	gridUs.delRow(selRowId[i]);
        	//gridUs.setCellValue(selRowId[i], 'DEL_FLAG', '1');
        	//gridUs.setRowBackColor(selRowId[i], '100|100|100');
        }
    }

    <%-- 저장 --%>
    function doSave() {
		var store = new EVF.Store();
		if (!store.validate()) return;
		if (gridUs.getRowCount() == 0) { return EVF.alert("${EV0045_0004}"); }

		<%--// 날짜 체크--%>
        if(!everDate.checkTermDate("START_DATE", "END_DATE", "${msg.M0073}")) {
            return;
        }

        var cnt = 0;
        if(EVF.V("RESULT_ENTER_CD") == "REPUSER") {
        	var value = gridUs.getAllRowValue();
        	for(var i in value) {
        		var row = value[i];

        		if(row.REP_FLAG == "1") {
        			cnt++;
				}
			}

			if(cnt != 1) {
				return EVF.alert("${EV0045_0008}");
			}
		}

        EVF.confirm("${msg.M8888 }", function () {
        	store.setGrid([gridUs]);
    		store.getGridData(gridUs, "all");
    		store.doFileUpload(function() {
    			store.load(baseUrl + '/srm045_doSave', function() {
    				var ev_num = this.getParameter("EV_NUM");
					opener["doSearch"]();
	                EVF.alert(this.getResponseMessage(), function() {
						location.href="/evermp/buyer/eval/EV0045/view.so?EV_NUM=" + ev_num;
	                });
	            });
    		});
        });
    }

    <%-- 평가요청 --%>
    function doRequest() {

		var store = new EVF.Store();
		if (!store.validate()) return;

        if (gridUs.getRowCount() == 0) { return EVF.alert("${EV0045_0006}"); }

		if(!everDate.checkTermDate("START_DATE", "END_DATE", "${msg.M0073}")) {
			return;
		}

		var cnt = 0;
		if(EVF.V("RESULT_ENTER_CD") == "REPUSER") {
			var value = gridUs.getAllRowValue();
			for(var i in value) {
				var row = value[i];

				if(row.REP_FLAG == "1") {
					cnt++;
				}
			}

			if(cnt != 1) {
				return EVF.alert("${EV0045_0008}");
			}
		}

        EVF.confirm("${msg.M8888 }", function () {
        	store.setGrid([gridUs]);
    		store.getGridData(gridUs, "all");
    		store.doFileUpload(function() {
    			store.load(baseUrl + "/srm045_doRequest", function() {
					opener["doSearch"]();
	                EVF.alert(this.getResponseMessage(), function() {
	                    doClose();
	                });
	            });
    		});
        });
    }

    <%-- 삭제 --%>
    function doDelete() {
		var store = new EVF.Store();
		if (!store.validate()) return;

		EVF.confirm("${msg.M8888 }", function () {
        	store.setGrid([gridUs]);
    		store.getGridData(gridUs, "all");
    		store.doFileUpload(function() {
    			store.load(baseUrl + '/EV0045/doDelete', function() {
					opener["doSearch"]();
	                EVF.alert(this.getResponseMessage(), function() {
	                	doClose();
	                });
	            });
    		});
        });
    }

    <%-- 요청취소 --%>
    function doCancel() {
		var store = new EVF.Store();
		if (!store.validate()) return;

    	EVF.confirm("${msg.M8888 }", function () {
        	store.setGrid([gridUs]);
    		store.getGridData(gridUs, "all");
    		store.doFileUpload(function() {
    			store.load(baseUrl + '/srm045_doCancel', function() {
    				opener["doSearch"]();
	                EVF.alert(this.getResponseMessage(), function() {
	                	doClose();
	                });
	            });
    		});
        });
    }

    function doClose() {
    	EVF.closeWindow();
    }
    </script>

	<e:window id="EV0045" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
        	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>


        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
				<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
				<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="${form_EV_NUM_W}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				</e:field>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:inputText id="PROGRESS_NM" style="ime-mode:inactive" name="PROGRESS_NM" value="${form.PROGRESS_NM}" width="${form_PROGRESS_NM_W}"  maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}"/>
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
				<e:search id="EV_CTRL_NM" style="${imeMode}" name="EV_CTRL_NM" value="${form.EV_CTRL_NM }" width="${form_EV_CTRL_NM_W}" maxLength="${form_EV_CTRL_NM_M}" onIconClick="${form_EV_CTRL_NM_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" />
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
				<e:field>
				<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${form_PURCHASE_TYPE_W}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>

				<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
				<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${form_EV_TYPE_W}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
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
				<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${form.RESULT_ENTER_CD}" options="${resultEnterCdOptions}" width="${form_RESULT_ENTER_CD_W}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
				<e:field>
				<e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
				</e:field>


				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
				<e:field>
				<e:inputText id="REG_USER_NM" style="ime-mode:inactive" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${form_REG_USER_NM_W}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
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


	    <e:buttonBar align="right" title="평가자">
			<e:button id="doImportUs" name="doImportUs" label="${doImportUs_N}" onClick="doImportUs" disabled="${doImportUs_D}" visible="${doImportUs_V}"/>
			<e:button id="doDelUs" name="doDelUs" label="${doDelUs_N}" onClick="doDelUs" disabled="${doDelUs_D}" visible="${doDelUs_V}"/>
		</e:buttonBar>
		<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" height="fit"/>
</e:window>
</e:ui>