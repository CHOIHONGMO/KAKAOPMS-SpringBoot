<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    var baseUrl = '/eversrm/srm/execEval/eval/SRM_260';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');
        grid.setProperty('panelVisible', ${panelVisible});
        EVF.getComponent("EV_CTRL_USER_NM").setValue('${ses.userNm}');
        grid.cellClickEvent(function (rowId, colId, value, iRow, iCol) {
        	if(selRow == undefined) selRow = rowId;
            if(colId == 'VENDOR_CD') {<%--  협력회사 정보 상세 --%>
            	var params = {
            		VENDOR_CD : grid.getCellValue(rowId, "VENDOR_CD")
            	   ,POPUPFLAG : 'Y'
	               ,detailView    	: true
                   ,havePermission : false
            	};
            	everPopup.openPopupByScreenId('BBV_010', 950, 580, params);
            }
            if(colId == 'EV_NUM'){<%-- 평가생성페이지 --%>
            	var params = {
            		EV_NUM : grid.getCellValue(rowId, "EV_NUM")
            	   ,POPUPFLAG : 'Y'
            	   ,detailView : true
            	   ,havePermission : false
            	};
            	everPopup.openPopupByScreenId('SRM_210' ,950, 580, params);
            }
        });

        grid.cellChangeEvent(function (rowId, colId, iRow, iCol, newValue, oldValue) {
            switch(colId) {
            case 'FINAL_SCORE':
					// WEIGHT  FINAL_SCORE
				  var weight = grid.getCellValue(rowId, "WEIGHT");
				  if(newValue > weight){
					  alert("${SRM_260_BigInput}"); // 입력값이 가중치보다 큽니다.
					  grid.setCellValue(rowId, "FINAL_SCORE", weight);
				  }
				  break;
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
      	if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                alert("${msg.M0002 }");
            }
			//grid.setColMerge.call(['EV_NUM','EV_NM','VENDOR_CD','VENDOR_NM'], true);
			grid.setColMerge(['EV_NUM','EV_NM','VENDOR_CD','VENDOR_NM']);
        });
    }

    <%-- 저장 --%>
    function doSave() {

		var gridDatas = grid.getSelRowValue();
        if (gridDatas.length == 0) return alert("${msg.M0004}");

        for(var idx in gridDatas) {
            var rowData = gridDatas[idx];
            <%-- 평가담당자만 처리가능 --%>
            if (rowData['EV_CTRL_USER_ID'] != "${ses.userId }") return alert("${SRM_260_EV_CTRL_USER}");
            <%-- 진행중인 상태만 처리가능--%>
            if (rowData['EM_PROGRESS'] != "200")           return alert("${SRM_260_EM_PROGRESS}");

            if (rowData['REMARK'] == null || "" == rowData['REMARK'])	return alert("${SRM_260_REMARK}")
        }

        var store = new EVF.Store();

        if(!confirm('${msg.M0021}')) { return; }

        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSave', function() {
            alert(this.getResponseMessage());
            doSearch();
        });
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

    <%-- 평가 담당자 검색 --%>
    function EV_CTRL_USER_NM(){
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }
    function selectEvCtrlUser(param){
    	EVF.getComponent("EV_CTRL_USER_NM").setValue(param.USER_NM);
    	EVF.getComponent("EV_CTRL_USER_ID").setValue(param.USER_ID);
    }


    <%-- 협력회사 명 검색 --%>
	function VENDOR_NM(){
		var param = {
	    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0013');
	}
	function selectVendor(param){
    	EVF.getComponent("VENDOR_NM").setValue(param.VENDOR_NM);
    	EVF.getComponent("VENDOR_CD").setValue(param.VENDOR_CD);
    }

    </script>
<e:window id="SRM_260" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" useTitleBar="false" onEnter="doSearch">
    <e:row>
	    <%-- 평가생성일 --%>
		<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE_FROM" toDate="REG_DATE_TO" name="REG_DATE_FROM" value="${form.REG_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
		<e:text>~&nbsp;</e:text>
		<e:inputDate id="REG_DATE_TO" fromDate="REG_DATE_FROM" name="REG_DATE_TO" value="${form.REG_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
		</e:field>
	    <%-- 평가번호 --%>
		<e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
		<e:field>
		<e:search id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="" width="${inputTextWidth}" maxLength="${form_EV_NUM_M}" onIconClick="${form_EV_NUM_RO ? 'everCommon.blank' : 'EV_NUM'}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}" />
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
		<e:search id="EV_CTRL_USER_NM" style="${imeMode}" name="EV_CTRL_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_EV_CTRL_USER_NM_M}" onIconClick="${form_EV_CTRL_USER_NM_RO ? 'everCommon.blank' : 'EV_CTRL_USER_NM'}" disabled="${form_EV_CTRL_USER_NM_D}" readOnly="${form_EV_CTRL_USER_NM_RO}" required="${form_EV_CTRL_USER_NM_R}" />
		</e:field>
		<e:inputHidden id="EV_CTRL_USER_ID" name="EV_CTRL_USER_ID" value="${form.EV_CTRL_USER_ID}"/>
	    <%-- 협력회사명 --%>
	    <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'VENDOR_NM'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		</e:field>
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
	    <%-- 평가구분--%>
		<e:label for="EV_TYPE" title="${form_EV_TYPE_N}"/>
		<e:field>
		<e:select id="EV_TYPE" name="EV_TYPE" value="${form.EV_TYPE}" options="${evTypeOptions}" width="${inputTextWidth}" disabled="${form_EV_TYPE_D}" readOnly="${form_EV_TYPE_RO}" required="${form_EV_TYPE_R}" placeHolder="" />
		</e:field>
    </e:row>
    </e:searchPanel>

    <e:buttonBar align="right">
    	<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    	<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

</e:window>
</e:ui>
