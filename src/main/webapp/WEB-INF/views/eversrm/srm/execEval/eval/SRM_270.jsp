<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/execEval/eval/SRM_270';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');
        grid.setProperty('panelVisible', ${panelVisible});
        EVF.getComponent("EV_CTRL_USER_NM").setValue('${ses.userNm}');
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
        	if(selRow == undefined) selRow = rowId;

            if(colId == 'EV_NUM') {
            	var params = {
            		EV_NUM : grid.getCellValue(rowId, "EV_NUM")
               	   ,POPUPFLAG : 'Y'
   	               ,detailView    	: true
                   ,havePermission : false
               	};
               	everPopup.openPopupByScreenId('SRM_210', 950, 580, params);
            }
            if(colId == 'VENDOR_CD') {
            	var params = {
               		VENDOR_CD : grid.getCellValue(rowId, "VENDOR_CD")
               	   ,POPUPFLAG : 'Y'
   	               ,detailView    	: true
                   ,havePermission : false
               	};
               	everPopup.openPopupByScreenId('BBV_010', 950, 580, params);
            }
            if(colId == 'EV_USER_CNT') {//SRM_250 호출
            	var cnt = grid.getCellValue(rowId, "EV_USER_CNT");
            	var cntArray = grid.getCellValue(rowId, "EV_USER_CNT").toString().split('/');
				if(cntArray[1] == "0"){
					alert("${SRM_270_EV_USER}");
					return;
				}
            	var params = {
            		VENDOR_NM_L : grid.getCellValue(rowId, "VENDOR_NM")
            	   ,EV_NUM : grid.getCellValue(rowId, "EV_NUM")
               	   ,POPUPFLAG : 'Y'
   	               ,detailView    	: true
                   ,havePermission : false
               	};
               	everPopup.openPopupByScreenId('SRM_250', 1000, 1000, params);
            }
            if(colId == 'DETAIL') { //상세
				var params = {
					 EV_NUM			: grid.getCellValue(rowId, "EV_NUM")
					,VENDOR_CD 		: grid.getCellValue(rowId, "VENDOR_CD")
				};
				everPopup.openCommonPopup(params, 'SP0050');
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
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }

		});

    }

    <%-- 조회 --%>
    function doSearch() {

        var store = new EVF.Store();

        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
            //grid.setColMerge.call(['EV_NUM','EV_NM'], true);
			grid.setColMerge(['EV_NUM','EV_NM']);
        });
    }

    <%-- 평가완료  --%>
    function doComplete(){
    	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

    	for(var i = 0; i<selRowId.length; i++){
    		<%-- 첨수 및 등급이 미입력 되있습니다. --%>
    		var ev_score 		= grid.getCellValue(selRowId[i],'EV_SCORE');
    		var eval_grade_cls 	= grid.getCellValue(selRowId[i],'EVAL_GRADE_CLS');
    		var ev_type_cd 		= grid.getCellValue(selRowId[i],'EV_TYPE_CD');

    		<%--
    		if(ev_score == '' || (eval_grade_cls == '' && ev_type_cd == 'CLASS')){
    			alert('${SRM_270_SCORE}');
    			return;
    		}
    		--%>

    		<%-- 평가담당자만 처리가능합니다--%>
    		if(grid.getCellValue(selRowId[i],'EV_CTRL_USER_ID') != '${ses.userId}'){
    			alert('${SRM_270_EV_CTRL_USER}');
        		return;
    		}

    		<%-- 평가완료된 경우에는  처리불가능 --%>
    		if(grid.getCellValue(selRowId[i],'PROGRESS_CD') == '300'){
    			alert('${SRM_270_PROGRESS_C}');
        		return;
    		}
    	}

    	var store = new EVF.Store();

    	store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
        store.load(baseUrl + '/doComplete', function() {

            alert(this.getResponseMessage());
            doSearch();
        });

    }
    <%-- 완료취소  --%>
    function doCancel(){
    	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
    	for (var i = 0; i < selRowId.length; i++) {
    		<%-- 평가담당자만 처리가능합니다--%>
    		if(grid.getCellValue(selRowId[i],'EV_CTRL_USER_ID') != '${ses.userId}'){
    			alert('${SRM_270_EV_CTRL_USER}');
        		return;
    		}

    		<%-- 평가완료된 경우에만 처리가능 --%>
    		if(grid.getCellValue(selRowId[i],'PROGRESS_CD') != '300'){
    			alert('${SRM_270_PROGRESS_F}');
        		return;
    		}
    	}

    	var store = new EVF.Store();

        store.setGrid([grid]);
    	store.getGridData(grid, 'sel');
        store.load(baseUrl + '/doCancel', function() {
        	alert(this.getResponseMessage());
            doSearch();
        });
    }

    <%-- 등급수정  --%>
    function doEdit(){
    	if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
    	var selRowId = grid.jsonToArray(grid.getSelRowId()).value;
    	for (var i = 0; i < selRowId.length; i++) {
    		<%-- 평가담당자만 처리가능합니다--%>
    		if(grid.getCellValue(selRowId[i],'EV_CTRL_USER_ID') != '${ses.userId}'){
    			alert('${SRM_270_EV_CTRL_USER}');
        		return;
    		}

    		<%-- 평가완료된 경우에만 처리가능 --%>
    		if(grid.getCellValue(selRowId[i],'PROGRESS_CD') != '300'){
    			alert('${SRM_270_PROGRESS_F}');
        		return;
    		}

    		<%-- 그리드 필수항목을 확인하세요 --%>
    		var ev_score = grid.getCellValue(selRowId[i],'EV_SCORE');
    		var eval_grade_cls 	= grid.getCellValue(selRowId[i],'EVAL_GRADE_CLS');
    		var amend_reason 	= grid.getCellValue(selRowId[i],'AMEND_REASON');
    		var ev_type_cd 		= grid.getCellValue(selRowId[i],'EV_TYPE_CD');

    		if(ev_score == '')								 {alert('${SRM_270_TOTAL_SCORE}'); return;}
    		if(eval_grade_cls == '' && ev_type_cd == 'CLASS'){alert('${SRM_270_CLASS}'); return;}
    		if(amend_reason == '')							 {alert('${SRM_270_RMK}'); return;}

    		<%--
    		if(ev_score == '' || (eval_grade_cls == '' && ev_type_cd == 'CLASS') || amend_reason == ''){
    			alert('${SRM_270_GRID}');
    			return;
    		}--%>
    	}
    	var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl + '/doEdit', function() {
        	alert(this.getResponseMessage());
            doSearch();
        });
    }


    <%-- ///////////   Search   //////////// --%>
	<%-- 평가담당자 조회 --%>
    function EV_CTRL_USER(){

    }
    <%-- 평가 담당자 검색 --%>
    function EV_CTRL_USER(){
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }
    function selectEvCtrlUser(param){
    	EVF.getComponent("EV_CTRL_USER_NM").setValue(param.USER_NM);
    }


    <%-- 평가번호 검색 --%>
    function EV_NUM(){
    	var param = {
    			callBackFunction : "selectEvalNum"
    	};
    	everPopup.openCommonPopup(param, 'SP0046');
    }
    function selectEvalNum(param){
    	EVF.getComponent("EV_NUM").setValue(param.EV_NUM);
    }

    <%-- 협력회사명 조회 --%>
	function VENDOR(){
		var param = {
	    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0013');
	}
	function selectVendor(param){
    	EVF.getComponent("VENDOR_NM").setValue(param.VENDOR_NM);
    }

    </script>
<e:window id="SRM_270" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
    <e:row>
		<%-- 평가생성일 --%>
		<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
		<e:text>~&nbsp;</e:text>
		<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
		</e:field>
		<%-- 진행상태 --%>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
		</e:field>
		<%-- 거래구분 --%>
		<e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
		<e:field>
		<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
		</e:field>
	</e:row>

   	<e:row>
		<%-- 평가담당자 --%>
		<e:label for="EV_CTRL_USER_NM" title="${form_EV_CTRL_USER_NM_N}"/>
		<e:field>
		<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_EV_CTRL_USER_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'EV_CTRL_USER'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
		</e:field>
		<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>
		<%-- 평가번호 --%>
		<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
		<e:field>
		<e:search id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="" width="${inputTextWidth}" maxLength="${form_EV_NUM_M}" onIconClick="${form_EV_NUM_RO ? 'everCommon.blank' : 'EV_NUM'}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}" />
		</e:field>
		<%-- 협력회사명 --%>
		<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'VENDOR'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		</e:field>
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
    </e:row>
    <e:row>
		<%-- 평가명 --%>
		<e:label for="EV_NM" title="${form_EV_NM_N}"/>
		<e:field>
		<e:inputText id="EV_NM" style="${imeMode}" name="EV_NM" value="${form.EV_NM}" width="${inputTextWidth}" maxLength="${form_EV_NM_M}" disabled="${form_EV_NM_D}" readOnly="${form_EV_NM_RO}" required="${form_EV_NM_R}"/>
		</e:field>
		<%-- 평가구분 --%>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field colSpan="3">
		<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${inputTextWidth}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    <e:button id="doComplete" name="doComplete" label="${doComplete_N}" onClick="doComplete" disabled="${doComplete_D}" visible="${doComplete_V}"/>
    <e:button id="doCancel" name="doCancel" label="${doCancel_N}" onClick="doCancel" disabled="${doCancel_D}" visible="${doCancel_V}"/>
    <e:button id="doEdit" name="doEdit" label="${doEdit_N}" onClick="doEdit" disabled="${doEdit_D}" visible="${doEdit_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

</e:window>
</e:ui>
