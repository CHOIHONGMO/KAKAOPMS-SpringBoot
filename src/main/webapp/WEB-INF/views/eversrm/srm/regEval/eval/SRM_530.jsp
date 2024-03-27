<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">
    var baseUrl = '/eversrm/srm/regEval/eval/SRM_530';
    var grid;

    function init() {

    	if(opener === undefined || opener == null) {
    		EVF.C('doClose').setVisible(false);
    	} else {
    		EVF.C('doClose').setVisible(true);
    	}

        grid = EVF.C('grid');
        grid.setProperty('shrinkToFit', true);
        grid.setProperty('panelVisible', ${panelVisible});
        if('${form.RH_NUM}' !=''){
        	doSearchGrid();
        } else {
        	<%-- doSearch(); --%>
        	EVF.C('doSearch').setVisible(false);
        	EVF.C('doDelete').setVisible(false);
        	EVF.C('doSend').setVisible(false);
        	EVF.C('RH_USER_NM').setValue('${ses.userNm}');
        	EVF.C('RH_USER_ID').setValue('${ses.userId}');
        }
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
            if(colId == '') {

            }

        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case '':

            default:
            }
        });

        grid.excelExportEvent({
        	allCol : "${excelExport.allCol}",
            selRow : "${excelExport.selRow}",
            fileType : "${excelExport.fileType }",
            fileName : "${screenName }",
            "excelOptions": {
                 "imgWidth": 0.12
                ,"imgHeight": 0.26
                ,"colWidth": 20
                ,"rowSize": 500
                ,"attachImgFlag": false
            }
        });

    }

    function EXCELUP() {
	   grid.importFromExcel(
				{ 'append' : true }
				, excelUploadCallBack
			).call( grid );

	}

	function excelUploadCallBack( msg, code ) {
	 	grid.checkAll(true);
	 	alert('${msg.M0001}');
	 	cellEdit();
 	}

	function cellEdit(){
		grid.checkAll(true);
		<%-- 그리드 편집 불가 설정 --%>
        if('${ses.userType}' == 'B'){<%-- 내부 --%>
        	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
            for(var i = 0;i < selRowId.length;i++) {
            	grid.setCellReadOnly(grid.getRowId(i), 'RESULT_NM', true);
            	grid.setCellReadOnly(grid.getRowId(i), 'PIC_USER_NM', true);
            	grid.setCellReadOnly(grid.getRowId(i), 'FINISH_DATE', true);
            	grid.setCellReadOnly(grid.getRowId(i), 'RMK', true);
        	}
        }else if('${ses.userType}' == 'S'){<%-- 외부 --%>
        	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
            for(var i = 0;i < selRowId.length;i++) {
            	grid.setCellReadOnly(grid.getRowId(i), 'RH_NM', true);
            	grid.setCellReadOnly(grid.getRowId(i), 'ISSUE_NM', true);
        	}
        }
	}


    function ADDROW(){
    	grid.addRow();
    	cellEdit();
    }
    function DELROW(){
    	grid.delRow();
    }

    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {

        	var formValue = JSON.parse(this.getParameter("form"));
        	if( formValue != null && formValue.lenght > 0 ) {
	        	alert(JSON.stringify(formValue));
	      		var formKey = Object.keys(formValue);
	        	for(var i = 0; i <formKey.length; i++){
	        			EVF.getComponent(formKey[i]).setValue(formValue[formKey[i]]);
	        	}
        	}
        });
    }

    function doSearchGrid() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearchGrid', function() {

        });
    }
    function doSave() {

    	<%-- 평가담당자만 처리가능 --%>
		var rh_userId = EVF.getComponent('RH_USER_ID').getValue();
		if('${ses.userType}' == 'B' &&  rh_userId != '${ses.userId}'){
			alert('${SRM_530_rh_user}');
			return;
		}

		<%-- 전송된 상태면 처리불가 --%>
		var progress_cd = EVF.getComponent('PROGRESS_CD').getValue();
		if('${ses.userType}' == 'B' &&  (progress_cd == '200' || progress_cd == '300' || progress_cd == '400')){
			alert('${SRM_530_progress_cd}');
			return;
		}

		<%-- 조치완료된 건이면 처리불가 --%>
		if('${ses.userType}' == 'S' && (progress_cd == '300' || progress_cd == '400')){
			alert('${SRM_530_progress_cd_a}');
			return;
		}

        grid.checkAll(true);

        <%-- 협력회사일때 유효성 체크 --%>
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        if('${ses.userType}' == 'S'){
        	for(var i = 0;i < selRowId.length;i++) {
    			var result_nm = grid.getCellValue(selRowId[i], 'RESULT_NM');
    			var pic_user_nm = grid.getCellValue(selRowId[i], 'PIC_USER_NM');
    			var finish_date = grid.getCellValue(selRowId[i], 'FINISH_DATE');

    		    if(result_nm == '') {
    				alert('${SRM_530_GRID_CHECK}');
    				return;
    		    }else if(pic_user_nm == ''){
    		    	alert('${SRM_530_GRID_CHECK}');
    		    	return;
    		    }else if(finish_date == ''){
    		    	alert('${SRM_530_GRID_CHECK}');
    		    	return;
    		    }
    		}
        }else if('${ses.userType}' == 'B'){
        	for(var i = 0;i < selRowId.length;i++) {
    			var rh_nm = grid.getCellValue(selRowId[i], 'RH_NM');
    			var issue_nm = grid.getCellValue(selRowId[i], 'ISSUE_NM');
    		    if(rh_nm == '') {
    				alert('${SRM_530_GRID_CHECK}');
    				return;
    		    }else if(issue_nm == ''){
    		    	alert('${SRM_530_GRID_CHECK}');
    		    	return;
    		    }
    		}
        }


        if (!grid.validate().flag) {
			alert(grid.validate().msg);
		    return;
		}

        var store = new EVF.Store();
        if(!store.validate()) { return; }
        if(!confirm('${msg.M0021}')) { return; } <%-- 저장하시겠습니까 --%>

        store.setGrid([grid]);
        store.getGridData(grid, 'sel');


        store.doFileUpload(function() {
	        store.load(baseUrl+'/doSave', function() {
	            var rh_num = this.getParameter("RH_NUM");
	            location.href = baseUrl + '/view.so?RH_NUM='+rh_num;
	        });
        });
    }


	<%-- 삭제버튼 이벤트 --%>
    function doDelete() {

    	<%-- 평가담당자만 처리가능 --%>
		var rh_userId = EVF.getComponent('RH_USER_ID').getValue();
		if(rh_userId != '${ses.userId}'){
			alert('${SRM_530_rh_user}');
			return;
		}

		<%-- 전송된 상태면 처리불가 --%>
		var progress_cd = EVF.getComponent('PROGRESS_CD').getValue();
		if(progress_cd != '100'){
			alert('${SRM_530_progress_cd}');
			return;
		}


        if(!confirm('${msg.M0013}')) { return; } <%-- 삭제하시겠습니까? --%>

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doDelete', function() {
        	location.href = baseUrl + '/view';
        });
    }

	<%-- 전송 버튼 이벤트  : 협력회사 요청내용 전송 --%>
    function doSend(){
    	<%--저장 후 전송--%>
		var rh_num = EVF.getComponent('RH_NUM').getValue();
		if(rh_num == null || rh_num == ''){
			alert('${SRM_530_beforeSave}');
		}

    	<%-- 평가담당자만 처리가능 (고객사일시) --%>
		var rh_userId = EVF.getComponent('RH_USER_ID').getValue();
		if('${ses.userType}' == 'B' &&  rh_userId != '${ses.userId}'){
			alert('${SRM_530_rh_user}');
			return;
		}

		<%-- 전송된 상태면  처리불가 - 고객사 --%>
		var progress_cd = EVF.getComponent('PROGRESS_CD').getValue();
		if('${ses.userType}' == 'B' &&  progress_cd != '100'){
			alert('${SRM_530_progress_cd}');
			return;
		}

		<%-- 조치완료된 건이면 처리불가 - 협력회사 --%>
		if('${ses.userType}' == 'S' && (progress_cd == '300' || progress_cd == '400')){
			alert('${SRM_530_progress_cd_a}');
			return;
		}

		<%-- 협력회사일때 및 고객사일때 그리드 유효성 체크 --%>
		grid.checkAll(true);
        var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
        if('${ses.userType}' == 'S'){
        	for(var i = 0;i < selRowId.length;i++) {
    			var result_nm = grid.getCellValue(selRowId[i], 'RESULT_NM');
    			var pic_user_nm = grid.getCellValue(selRowId[i], 'PIC_USER_NM');
    			var finish_date = grid.getCellValue(selRowId[i], 'FINISH_DATE');

    		    if(result_nm == '') {
    				alert('${SRM_530_GRID_CHECK}');
    				return;
    		    }else if(pic_user_nm == ''){
    		    	alert('${SRM_530_GRID_CHECK}');
    		    	return;
    		    }else if(finish_date == ''){
    		    	alert('${SRM_530_GRID_CHECK}');
    		    	return;
    		    }
    		}
        }else if('${ses.userType}' == 'B'){
        	for(var i = 0;i < selRowId.length;i++) {
    			var rh_nm = grid.getCellValue(selRowId[i], 'RH_NM');
    			var issue_nm = grid.getCellValue(selRowId[i], 'ISSUE_NM');

    		    if(rh_nm == '') {
    				alert('${SRM_530_GRID_CHECK}');
    				return;
    		    }else if(issue_nm == ''){
    		    	alert('${SRM_530_GRID_CHECK}');
    		    	return;
    		    }
    		}
        }

    	if(!confirm('${SRM_530_doSend}')) { return; } <%-- 전송하시겠습니까? --%>

    	var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSend', function() {
            var rh_num = EVF.getComponent('RH_NUM').getValue();
            location.href = baseUrl + '/view.so?RH_NUM='+rh_num;
        });
    }

    <%-- 평가자 검색 --%>
    function searchRhUserId(){
    	if('${ses.userType}'=='S'){return;}
    	var param = {
				callBackFunction : "selectRhUserId"
			};
			everPopup.openCommonPopup(param, 'SP0027');
    }
    function selectRhUserId(param){
    	EVF.getComponent("RH_USER_ID").setValue(param.USER_ID);
    	EVF.getComponent("RH_USER_NM").setValue(param.USER_NM);
    }


	<%-- 협력회사 조회 --%>
	function searchVendorNm() {
		if('${ses.userType}'=='S'){return;}
    	var param = {
        	callBackFunction : 'doSetVendorNmForm'
      	};
      	everPopup.openCommonPopup(param, 'SP0013');
    }

    <%-- 협력회사명 팝업 셋팅(Form) --%>
    function doSetVendorNmForm(data) {
    	EVF.getComponent("VENDOR_NM").setValue(data.VENDOR_NM);
    	EVF.getComponent("VENDOR_CD").setValue(data.VENDOR_CD);
    }

    function doClose(){
    	self.close();
    }




    </script>
<e:window id="SRM_530" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
	<%-- top Action --%>
	<e:buttonBar align="right" width="100%">
		<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
		<c:if test="${ses.userType == 'B'}">
		<e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
		</c:if>
		<e:button id="doSend" name="doSend" label="${doSend_N}" onClick="doSend" disabled="${doSend_D}" visible="${doSend_V}"/>
		<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
	</e:buttonBar>

	<%-- form --%>
<e:searchPanel id="form" title="${msg.M7777}" columnCount="2" labelWidth="${labelWidth}" width="100%" onEnter="doSearch" useTitleBar="true">

    <e:row>
    <%-- 관리번호  --%>
		<e:label for="RH_NUM" title="${form_RH_NUM_N}"/>
		<e:field>
		<e:inputText id="RH_NUM" style="ime-mode:inactive" name="RH_NUM" value="${form.RH_NUM}" width="${inputTextDate}" maxLength="${form_RH_NUM_M}" disabled="${form_RH_NUM_D}" readOnly="${form_RH_NUM_RO}" required="${form_RH_NUM_R}"/>
		</e:field>


    <%-- 진행상태 --%>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:inputText id="PROGRESS_NM" style="${imeMode}" name="PROGRESS_NM" value="${form.PROGRESS_NM}" width="${inputTextWidth}" maxLength="${form_PROGRESS_NM_M}" disabled="${form_PROGRESS_NM_D}" readOnly="${form_PROGRESS_NM_RO}" required="${form_PROGRESS_NM_R}"/>
		<e:inputHidden id="PROGRESS_CD" style="ime-mode:inactive" name="PROGRESS_CD" value="${form.PROGRESS_CD}"/>
		</e:field>
    </e:row>

    <e:row>
    <%-- 제목 --%>
		<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
		<e:field>
		<e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_SUBJECT_R}"/>
		</e:field>
	<%-- 평가 담당자 --%>
		<e:label for="RH_USER_NM" title="${form_RH_USER_NM_N}"/>
		<e:field>
		<e:search id="RH_USER_NM" style="${imeMode}" name="RH_USER_NM" value="${form.RH_USER_NM }" width="${inputTextWidth}" maxLength="${form_RH_USER_NM_M}" onIconClick="${form_RH_USER_NM_RO ? 'everCommon.blank' : 'searchRhUserId'}" disabled="${form_RH_USER_NM_D}" readOnly="true" required="${form_RH_USER_NM_R}" />
		</e:field>
		<e:inputHidden id="RH_USER_ID" name="RH_USER_ID" value="${form.RH_USER_ID}"/>

    </e:row>

    <e:row>
    <%-- 협력회사 SP0013 --%>
	   <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM }" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'searchVendorNm'}" disabled="${form_VENDOR_NM_D}" readOnly="true" required="${form_VENDOR_NM_R}" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
		</e:field>

	<%-- 평가일자 --%>
		<e:label for="RH_DATE" title="${form_RH_DATE_N}"/>
		<e:field>
		<e:inputDate id="RH_DATE" name="RH_DATE" value="${form.RH_DATE}" width="${inputTextDate}" datePicker="true" required="${form_RH_DATE_R}" disabled="${form_RH_DATE_D}" readOnly="${ses.userType eq 'B' ? false : true}" />
		</e:field>

    </e:row>

    <e:row>
    <%-- 차종 --%>
	    <e:label for="MAT_GROUP" title="${form_MAT_GROUP_N}"/>
		<e:field>
		<e:inputText id="MAT_GROUP" style="ime-mode:inactive" name="MAT_GROUP" value="${form.MAT_GROUP}" width="100%" maxLength="${form_MAT_GROUP_M}" disabled="${form_MAT_GROUP_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_MAT_GROUP_R}"/>
		</e:field>

    <%-- 품번 --%>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_ITEM_CD_R}"/>
		</e:field>
    </e:row>

    <e:row>
	<%-- 품명 --%>
	    <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
		<e:field colSpan="3">
		<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_ITEM_DESC_R}"/>
		</e:field>
    </e:row>

    <e:row>
	<%-- 참석자 동희  --%>
	    <e:label for="ATTENDEES_BUYER" title="${form_ATTENDEES_BUYER_N}"/>
		<e:field>
		<e:inputText id="ATTENDEES_BUYER" style="ime-mode:auto" name="ATTENDEES_BUYER" value="${form.ATTENDEES_BUYER}" width="100%" maxLength="${form_ATTENDEES_BUYER_M}" disabled="${form_ATTENDEES_BUYER_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_ATTENDEES_BUYER_R}"/>
	</e:field>

    <%-- 참석자 협력회사 --%>
	    <e:label for="ATTENDEES_VENDOR" title="${form_ATTENDEES_VENDOR_N}"/>
		<e:field>
		<e:inputText id="ATTENDEES_VENDOR" style="ime-mode:auto" name="ATTENDEES_VENDOR" value="${form.ATTENDEES_VENDOR}" width="100%" maxLength="${form_ATTENDEES_VENDOR_M}" disabled="${form_ATTENDEES_VENDOR_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_ATTENDEES_VENDOR_R}"/>
	</e:field>

    </e:row>

    <e:row>
	<%-- 비고 동희 --%>
		<e:label for="RMK_BUYER" title="${form_RMK_BUYER_N}"/>
		<e:field colSpan="3">
		<e:textArea id="RMK_BUYER" style="ime-mode:auto" name="RMK_BUYER" height="100px" value="${form.RMK_BUYER}" width="100%" maxLength="${form_RMK_BUYER_M}" disabled="${form_RMK_BUYER_D}" readOnly="${ses.userType eq 'B' ? false : true}" required="${form_RMK_BUYER_R}" />
		</e:field>

    </e:row>

    <e:row>
	<%-- 첨부파일 동희 --%>
	    <e:label for="ATT_FILE_NUM_BUYER" title="${form_ATT_FILE_NUM_BUYER_N}"/>
		<e:field colSpan="3">
			<e:fileManager id="ATT_FILE_NUM_BUYER" name="ATT_FILE_NUM_BUYER" fileId="${form.ATT_FILE_NUM_BUYER}" readOnly="${ses.userType eq 'B' ? false : true}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
		</e:field>

    </e:row>

    <e:row>
    <%-- 비고 협력회사 --%>
	    <e:label for="RMK_VENDOR" title="${form_RMK_VENDOR_N}"/>
		<e:field colSpan="3">
		<e:textArea id="RMK_VENDOR" style="ime-mode:auto" name="RMK_VENDOR" height="100px" value="${form.RMK_VENDOR}" width="100%" maxLength="${form_RMK_VENDOR_M}" disabled="${form_RMK_VENDOR_D}" readOnly="${ses.userType eq 'S' ? false : true}" required="${form_RMK_VENDOR_R}" />
		</e:field>

    </e:row>

    <e:row>
	<%-- 첨부파일 협력회사 --%>
	    <e:label for="ATT_FILE_NUM_VENDOR" title="${form_ATT_FILE_NUM_VENDOR_N}"/>
		<e:field colSpan="3">
			<e:fileManager id="ATT_FILE_NUM_VENDOR" name="ATT_FILE_NUM_VENDOR" fileId="${form.ATT_FILE_NUM_VENDOR}" readOnly="${ses.userType eq 'S' ? false : true}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
		</e:field>
    </e:row>

    <e:inputHidden id="EV_NUM" name="EV_NUM" value="${form.EV_NUM}"/>
</e:searchPanel>

	<%-- bottom action --%>
    <e:buttonBar align="right">
    	<c:if test="${ses.userType == 'B'}">
    	<e:button id="EXECELUP" name="EXECELUP" label="${EXECELUP_N}" onClick="EXCELUP" disabled="${EXECELUP_D}" visible="${EXECELUP_V}"/>
    	<e:button id="ADDROW" name="ADDROW" label="${ADDROW_N}" onClick="ADDROW" disabled="${ADDROW_D}" visible="${ADDROW_V}"/>
    	<e:button id="DELROW" name="DELROW" label="${DELROW_N}" onClick="DELROW" disabled="${DELROW_D}" visible="${DELROW_V}"/>
    	</c:if>
    </e:buttonBar>

    <%-- grid --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="200px" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

</e:window>
</e:ui>
