<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/eversrm/srm/execEval/eval/";
    var gridSg;
    var gridVendor;
    var gridUs;
	var tplFlag = true;

    function init() {

    	gridUs = EVF.C("gridUs");
    	gridSg = EVF.C("gridSg");
    	gridVendor = EVF.C("gridVendor");


    	gridUs.setProperty('panelVisible', ${panelVisible});
    	gridSg.setProperty('panelVisible', ${panelVisible});
    	gridVendor.setProperty('panelVisible', ${panelVisible});




    	if( "${form.EV_NUM}" == "" ||  "${param.detailView}" == "true" || "${param.detailView}" == "" ) {
	    	<%-- 평가구분 입찰[RFX] 표시되지 않도록 함. --%>
	    	 $("#EV_TYPE option[value='RFX']").detach();
    	} else {
	      	if( "${form.EV_TYPE}" == "RFX" ) {
	       		$('#EV_TYPE').attr('disabled', 'true');
	       		tplFlag = false;
	       	} else {
		    	<%-- 평가구분 입찰[RFX] 표시되지 않도록 함. --%>
	  	  	 	$("#EV_TYPE option[value='RFX']").detach();
	       		$('#EV_TYPE').removeAttr('disabled');
	       		tplFlag = true;
	       	}
    	}


    	if( opener  === undefined || opener == null) {
    		//EVF.C('doSearch').setVisible(true);
    		EVF.C('doClose').setVisible(false);
    		EVF.getComponent('doAddSg').setVisible(true);
    		EVF.getComponent('doDelSg').setVisible(true);
    		EVF.getComponent('doAddVendor').setVisible(true);
    		EVF.getComponent('doDelVendor').setVisible(true);
    		EVF.getComponent('doAddUs').setVisible(true);
    		EVF.getComponent('doDelUs').setVisible(true);

    		EVF.getComponent('doRequest').setVisible(false);
    		EVF.getComponent('doCancel').setVisible(false);

    	} else {
    		if( '${param.detailView}' == 'true') {
	    		EVF.C('doClose').setVisible(true);
	    		//EVF.C('doSearch').setVisible(false);
	    		EVF.getComponent('doAddSg').setVisible(false);
	    		EVF.getComponent('doDelSg').setVisible(false);
	    		EVF.getComponent('doAddVendor').setVisible(false);
	    		EVF.getComponent('doDelVendor').setVisible(false);
	    		EVF.getComponent('doAddUs').setVisible(false);
	    		EVF.getComponent('doDelUs').setVisible(false);
    		}
    	}

    	if( "${form.EV_NUM}" == "" ) {
	    	EVF.C('PURCHASE_TYPE').setValue('PPUR');
	    	EVF.C('EV_TYPE').setValue('ROUTINE');
	    	EVF.C('RESULT_ENTER_CD').setValue('EVALUSER');
	    	EVF.C('EV_CTRL_NM').setValue('${ses.userNm}');
	    	EVF.C('EV_CTRL_USER_ID').setValue('${ses.userId}');
    	} else {
    		EVF.getComponent('doRequest').setVisible(true);
    		EVF.getComponent('doCancel').setVisible(true);
    	}

    	gridSg.setProperty('shrinkToFit', true);
    	gridUs.setProperty('shrinkToFit', true);
    	gridVendor.setProperty('shrinkToFit', true);


    	doSearchEVSG(); <%--소싱그룹조회 --%>
    	doSearchEVES(); <%--협력회사조회--%>
    	doSearchEVEU(); <%--평가자조회--%>

    }

	<%-- 평가대상 S/G 조회 --%>
    function doSearchEVSG() {
        var store = new EVF.Store();
        store.setGrid([gridSg]);
        store.load(baseUrl + "SRM_210/doSearchEVSG", function() {
        });
    }
	<%-- 협력회사 조회 --%>
    function doSearchEVES() {
        var store = new EVF.Store();
        store.setGrid([gridVendor]);
        store.load(baseUrl + "SRM_210/doSearchEVES", function() {
        });
    }
	<%-- 평가자 조회 --%>
    function doSearchEVEU() {
        var store = new EVF.Store();
        store.setGrid([gridUs]);
        store.load(baseUrl + "SRM_210/doSearchEVEU", function() {
        });
    }

    $(document.body).ready(function() {


     	var winHeight=document.all?document.body.clientHeight:window.innerHeight; //브라우저 세로폭 사이즈 가져오기
    	if( winHeight <= 768 ) {
    		 var fHeight = $("#file_container_ATT_FILE_NUM").parent().parent().parent().parent().height();
    		 $("#file_container_ATT_FILE_NUM").parent().parent().height(fHeight-30);
    		 $("#file_container_ATT_FILE_NUM").parent().height(fHeight-30);
    		 $("#file_container_ATT_FILE_NUM").height(fHeight-30);
    		 $("#file_container_ATT_FILE_NUM").parent().parent().parent().parent().height(fHeight-30);
    	}

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


    <%-- 평가담당자 선택 팝업 --%>
    function doSelectUser() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }
    <%-- 평가담당자 세팅 --%>
    function selectUser(dataJsonArray) {
        EVF.getComponent("EV_CTRL_NM").setValue(dataJsonArray.USER_NM);
        EVF.getComponent("EV_CTRL_USER_ID").setValue(dataJsonArray.USER_ID);
    }
    <%-- 템플릿 팝업 --%>
    function doSearchTempl() {

    	<%-- 입찰평가일 경우 템플릿 팝업창이 열리지 않음 --%>
    	if( !tplFlag ) return;

    	var ev_tpl_type_cd = EVF.getComponent("EV_TYPE").getValue()=="ROUTINE"?"E":"V";
        var param = {
            callBackFunction: "selectTemplAfter",
            EV_TPL_TYPE_CD: ev_tpl_type_cd
        };
        everPopup.openCommonPopup(param, 'SP0033');
    }
    <%-- 템플릿 세팅 --%>
    function selectTemplAfter(dataJsonArray) {
        EVF.getComponent("EXEC_EV_TPL_NUM").setValue(dataJsonArray.EV_TPL_NUM);
        EVF.getComponent("EV_TPL_SUBJECT").setValue(dataJsonArray.EV_TPL_SUBJECT);
    }
    <%-- 소싱그룹 추가 --%>
    function doAddSg() {

    	var param = {
                callBackFunction: "setSg",
                GATE_CD : "${ses.gateCd}"
         };
//    	everPopup.openCommonPopup(param, 'SP0041');
    	everPopup.openCommonPopup(param, 'SP0051');

    }

    <%-- 소싱그룹 세팅 --%>
    function setSg(selectedData) {
    	var existSg = true;
    	$(selectedData).each(function(idx, data){

    		for (var i = 0, length = gridSg.getRowCount(); i < length; i++) {
                if (gridSg.getCellValue(i,"SG_NUM") == data.SG_NUM) {
                	existSg = false;
                }
    	    }
    	    if(existSg){
			  row  = [
			          		{
			          			"CLS1" : data.ITEM_CLS_NM1
			        	    	,"CLS2" : data.ITEM_CLS_NM2
			        	    	,"CLS3" : data.ITEM_CLS_NM3
			        	    	,"CLS4" : data.ITEM_CLS_NM4
			        	    	,"SG_NUM" :   data.SG_NUM
			        	    	,"EV_NUM" :   ''
			        	    	,"DEL_FLAG" :  ''
			 				  }
			          	 ];
			  gridSg.addRow(row);
    	    }

		 });

    	/*
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
		*/
	}

    <%-- 소싱그룹 삭제 --%>
    function doDelSg() {
    	var selRowId = gridSg.jsonToArray(gridSg.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
        	gridSg.delRow(selRowId[i]);
        }
    }

    <%-- 평가자 추가 --%>
    function doAddUs() {
	    var param = {
		    GATE_CD:  '${ses.gateCd}'
		    , callBackFunction: 'selectUs'
	    };

		var purchaseType = EVF.C('PURCHASE_TYPE').getValue();

		if(purchaseType == 'PPUR') { <%-- 부품구매 --%>
			everPopup.openCommonPopup(param,"SP0056");
		} else {
			everPopup.openCommonPopup(param,"SP0001");
		}

    }
     <%-- 평가자 세팅 --%>
     function selectUs(data) {

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
    <%-- 평가자 삭제 --%>
     function doDelUs() {
     	var selRowId = gridUs.jsonToArray(gridUs.getSelRowId()).value;
         for (var i = 0; i < selRowId.length; i++) {
         	gridUs.delRow(selRowId[i]);
         }
     }

    <%-- 협력회사 가져오기 --%>
    function doImportVendor() {

    	if ((gridSg.jsonToArray(gridSg.getSelRowId()).value).length == 0) {
            alert("${SRM_210_0014}");//
            return;
        }

    	var store = new EVF.Store();

    	store.setGrid([gridSg]);
        store.getGridData(gridSg,'sel');

        store.setGrid([gridVendor]);
        store.load(baseUrl + "SRM_210/doImportVendor", function() {

        	var vendorList = JSON.parse(this.getParameter("vendorList"));
        	 if( vendorList != null && vendorList.length > 0 ) {
        		 //gridVendor.allDellRow();
        		 $(vendorList).each(function(idx, data){

        			  row  = [
        			          		{
        				 				   "CLS1": data.CLASS1
        				 				,  "CLS2": data.CLASS2
        				 				,  "CLS3": data.CLASS3
        				 				,  "CLS4": data.CLASS4
        				 				,  "VENDOR_CD": data.VENDOR_CD
        				 			    ,  "VENDOR_NM": data.VENDOR_NM
        				 				,  "SG_NUM": ' '
        				 				,  "DEL_FLAG": '0'
        			 				  }
        			          	 ];
        			 gridVendor.addRow(row);
        		 });
        	 }

        });

    }

    <%--협력회사 추가 --%>
	function doAddVendor() {
		var param = {
			callBackFunction : "selectVendorCd"
		};
		//everPopup.openCommonPopup(param, 'SP0013');
		everPopup.openCommonPopup(param, 'SP0052');
    }
    <%--협력회사 세팅 --%>
	function selectVendorCd(vendorList) {
		var existVendor = true;

     	$(vendorList).each(function(idx, data){

     		if(data.VENDOR_CD == ''){
	     		return;
	     	}
	 		for (var i = 0, length = gridVendor.getRowCount(); i < length; i++) {
	             if (gridVendor.getCellValue(i,"VENDOR_CD") == data.VENDOR_CD) {
	            	 existVendor = false;
	             }
	 	    }
	 	    if(existVendor){
	 	    	addParam = [
	     	            	{
	     	            		VENDOR_CD : data.VENDOR_CD
	     	            		,VENDOR_NM :    data.VENDOR_NM
	     	            	}
	     	            ];
	 	    	gridVendor.addRow(addParam);
	 	    }
     	});
    }
    <%--협력회사 삭제 --%>
    function doDelVendor() {
    	var selRowId = gridVendor.jsonToArray(gridVendor.getSelRowId()).value;
        for (var i = 0; i < selRowId.length; i++) {
        	gridVendor.delRow(selRowId[i]);
        }
    }


    function clearGridA(){
    	gridUs.delAllRow();
    	gridSg.delAllRow();
    	gridVendor.delAllRow();
    }

    <%-- 조회 --%>
    function doSearch() {
		var ev_num = EVF.getComponent("EV_NUM").getValue();
		if( ev_num == "" ) {
			return;
		}
		location.href="/eversrm/srm/execEval/eval/SRM_210/view.so?EV_NUM="+ev_num;
    }

    <%-- 저장 --%>
    function doSave() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		gridSg.checkAll(true);
		gridUs.checkAll(true);
		gridVendor.checkAll(true);

		<%--/*
		if ((gridSg.jsonToArray(gridSg.getSelRowId()).value).length == 0) {
            alert("${SRM_210_0008}");//
            return;
        }
    	 */--%>

		if ((gridUs.jsonToArray(gridUs.getSelRowId()).value).length == 0) {
            alert("${SRM_210_0010}");
            return;
        }
		if ((gridVendor.jsonToArray(gridVendor.getSelRowId()).value).length == 0) {
            alert("${SRM_210_0009}");
            return;
        }

    	if (!confirm("${msg.M8888}")) {  <%--처리하시겠습니까?--%>
			return;
		}

		store.setGrid([gridSg, gridUs, gridVendor]);
		store.getGridData(gridSg, 'sel');
		store.getGridData(gridUs, 'sel');
		store.getGridData(gridVendor, 'sel');

    	store.doFileUpload(function() {
			store.load(baseUrl + 'SRM_210/doSave', function() {
				alert(this.getResponseMessage());
				EVF.getComponent("EV_NUM").setValue(this.getParameter('ev_num'));
				doSearch();
				//location.href='/eversrm/srm/execEval/eval/SRM_210/view.so?EV_NUM='+this.getParameter('ev_num');
			});
    	});

    }

    <%-- 삭제 --%>
    function doDelete() {
		var store = new EVF.Store();
		if (!store.validate())
			return;

		gridSg.checkAll(true);
		gridUs.checkAll(true);
		gridVendor.checkAll(true);

    	if (!confirm("${msg.M8888}")) {  <%--처리하시겠습니까?--%>
			return;
		}

		store.setGrid([gridSg, gridUs, gridVendor]);
		store.getGridData(gridSg, 'sel');
		store.getGridData(gridUs, 'sel');
		store.getGridData(gridVendor, 'sel');

    	store.doFileUpload(function() {
			store.load(baseUrl + 'SRM_210/doDelete', function() {
				alert(this.getResponseMessage());
				//EVF.getComponent("EV_NUM").setValue(this.getParameter('ev_num'));
				//location.href='/eversrm/srm/execEval/eval/SRM_210/view';
				doSearch();
			});
    	});

    }

    <%-- 평가요청 --%>
    function doRequest() {

		var store = new EVF.Store();
		if (!store.validate())
			return;

    	if (!confirm("${msg.M8888}")) {  <%--처리하시겠습니까?--%>
			return;
		}

		store.load(baseUrl + 'SRM_210/doRequest', function() {
			alert(this.getResponseMessage());
			doSearch();
		});

    }

    <%-- 요청취소 --%>
    function doCancel() {

		var store = new EVF.Store();
		if (!store.validate())
			return;

    	if (!confirm("${msg.M8888}")) { <%--처리하시겠습니까?--%>
			return;
		}

		store.load(baseUrl + 'SRM_210/doCancel', function() {
			alert(this.getResponseMessage());
			doSearch();
		});

    }

    <%-- 닫기 --%>
    function doClose() {
    	if( opener != null) {
    		opener.doSearch();
    	}
    	self.close();
    }
    </script>

	<e:window id="SRM_210" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:buttonBar align="right">
        	<%-- <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/> --%>
			<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
			<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
			<e:button id="doRequest" name="doRequest" label="${doRequest_N}" onClick="doRequest" disabled="${doRequest_D}" visible="${doRequest_V}"/>
			<e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>


        <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="2">
            <e:row>
            	<%-- 평가번호 --%>
				<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
				<e:field>
				<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${form.EV_NUM}" width="${inputTextWidth}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
				</e:field>
            	<%-- 진행상태 --%>
				<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
				<e:field>
				<e:inputText id="PROGRESS_NM" style="ime-mode:inactive" name="PROGRESS_NM" value="${form.PROGRESS_NM}" width="${inputTextWidth}"  maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}"/>
				<e:inputHidden id="PROGRESS_CD" style="ime-mode:inactive" name="PROGRESS_CD" value="${form.PROGRESS_CD}" />
				</e:field>
            </e:row>
            <e:row>
            	<%-- 평가명 --%>
				<e:label for="EV_NM" title="${form_EV_NM_N}"/>
				<e:field>
				<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="100%" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
				</e:field>
            	<%-- 평가담당자 --%>
				<e:label for="EV_CTRL_NM" title="${form_EV_CTRL_NM_N}"/>
				<e:field>
				<e:search id="EV_CTRL_NM" style="${imeMode}" name="EV_CTRL_NM" value="${form.EV_CTRL_USER_NM }" width="${inputTextWidth}" maxLength="${form_EV_CTRL_NM_M}" onIconClick="${form_EV_CTRL_NM_RO ? 'everCommon.blank' : 'doSelectUser'}" disabled="${form_EV_CTRL_NM_D}" readOnly="${form_EV_CTRL_NM_RO}" required="${form_EV_CTRL_NM_R}" />
				<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID }"/>
				</e:field>
			</e:row>
            <e:row>
            	<%-- 거래구분 --%>
				<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
				<e:field>
				<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
				</e:field>
            	<%-- 평가구분 --%>
				<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
				<e:field>
				<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${inputTextWidth}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
            	<%-- 템플릿 --%>
				<e:label for="EV_TPL_SUBJECT" title="${form_EV_TPL_SUBJECT_N}"/>
				<e:field colSpan="3">
				<e:search id="EV_TPL_SUBJECT" style="ime-mode:auto" name="EV_TPL_SUBJECT" value="${form.EV_TPL_SUBJECT }" width="40%" maxLength="${form_EV_TPL_SUBJECT_M}" onIconClick="${form_EV_TPL_SUBJECT_RO ? 'everCommon.blank' : 'doSearchTempl'}" disabled="${form_EV_TPL_SUBJECT_D}" readOnly="${form_EV_TPL_SUBJECT_RO}" required="${form_EV_TPL_SUBJECT_R}" />
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
				<e:select id="RESULT_ENTER_CD" name="RESULT_ENTER_CD" value="${form.RESULT_ENTER_CD}" options="${resultEnterCdOptions }" width="${inputTextWidth}" disabled="${form_RESULT_ENTER_CD_D}" readOnly="${form_RESULT_ENTER_CD_RO}" required="${form_RESULT_ENTER_CD_R}" placeHolder="" />
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
				<e:inputText id="REG_USER_NM" style="ime-mode:auto" name="REG_USER_NM" value="${form.REG_USER_NM}" width="${inputTextWidth}" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
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

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="">${SRM_210_0002}</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="">${SRM_210_0007}</a></li>
            <li id="tab3"><a href="#ui-tabs-3" onclick="">${SRM_210_0003}</a></li>
          </ul>
          <div id="ui-tabs-1">
			<div id="divSg" style="height: auto;">

	        <e:buttonBar align="right">
				<e:button id="doAddSg" name="doAddSg" label="${doAddSg_N}" onClick="doAddSg" disabled="${doAddSg_D}" visible="${doAddSg_V}"/>
				<e:button id="doDelSg" name="doDelSg" label="${doDelSg_N}" onClick="doDelSg" disabled="${doDelSg_D}" visible="${doDelSg_V}"/>
			</e:buttonBar>
			<e:gridPanel gridType="${_gridType}" id="gridSg" name="gridSg" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.gridSg.gridColData}"/>
				</div>
          </div>

          <div id="ui-tabs-2">
			<div id="divVendor" style="height: auto;">
	        <e:buttonBar align="right">
	        	<e:button id="doImportVendor" name="doImportVendor" label="${doImportVendor_N}" onClick="doImportVendor" disabled="${doImportVendor_D}" visible="${doImportVendor_V}"/>
				<e:button id="doAddVendor" name="doAddVendor" label="${doAddVendor_N}" onClick="doAddVendor" disabled="${doAddVendor_D}" visible="${doAddVendor_V}"/>
				<e:button id="doDelVendor" name="doDelVendor" label="${doDelVendor_N}" onClick="doDelVendor" disabled="${doDelVendor_D}" visible="${doDelVendor_V}"/>
			</e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridVendor" name="gridVendor" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.gridVendor.gridColData}"/>
			</div>
          </div>

          <div id="ui-tabs-3">
			<div id="divUs" >
	        <e:buttonBar align="right">
				<e:button id="doAddUs" name="doAddUs" label="${doAddUs_N}" onClick="doAddUs" disabled="${doAddUs_D}" visible="${doAddUs_V}"/>
				<e:button id="doDelUs" name="doDelUs" label="${doDelUs_N}" onClick="doDelUs" disabled="${doDelUs_D}" visible="${doDelUs_V}"/>
			</e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridUs" name="gridUs" height="300" readOnly="${param.detailView}" columnDef="${gridInfos.gridUs.gridColData}"/>
			</div>
          </div>
		</div></td></tr>
	</div>

</e:window>
</e:ui>