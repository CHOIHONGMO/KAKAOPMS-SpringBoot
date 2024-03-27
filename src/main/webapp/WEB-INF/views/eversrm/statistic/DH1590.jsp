<%--
  Date: 2015/12/01
  Time: 11:18:25
  Scrren ID : DH1590
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/statistic/DH1590";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", false);

      <%--grid Column Head Merge --%>
      grid.setProperty('multiselect', false);
      grid.setProperty('panelVisible', ${panelVisible});

      <%-- Grid Excel Event --%>
      grid.excelExportEvent({
        allCol : "${excelExport.allCol}",
        selRow : "${excelExport.selRow}",
        fileType : "${excelExport.fileType }",
        fileName : "${screenName }",
        excelOptions : {
          imgWidth      : 0.12,
          imgHeight     : 0.26,
          colWidth      : 20,
          rowSize       : 500,
          attachImgFlag : false
        }
      });

      grid.cellClickEvent(function(rowId, celName, value, rowIdx, colIdx) {
        <%-- cell one click --%>
        if(selRow == undefined) selRow = rowId;

        if (celName == 'multiSelect') {
          if(selRow != rowId) {
            grid.checkRow(selRow, false);
            selRow = rowId;
          }
        }
        if(celName == 'VENDOR_CD') {
        	var params = {
           		VENDOR_CD : grid.getCellValue(rowId, "VENDOR_CD")
           	   ,POPUPFLAG : 'Y'
	               ,detailView    	: true
               ,havePermission : false
           	};
           	everPopup.openPopupByScreenId('BBV_010', 950, 580, params);
        }

      });

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});
    }

    <%-- Search --%>
    function doSearch() {
      var store = new EVF.Store();

      <%-- form validation Check --%>
      if(!store.validate()) return;

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    <%-- 협력회사 명 검색 --%>
	function SEARCH_VENDOR(){
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

  <e:window id="DH1590" onReady="init" initData="${initData}" title="" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
      <%-- 기간 --%>
        <e:label for="DEAL_DATE_FROM" title="${form_DEAL_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="DEAL_DATE_FROM" toDate="DEAL_DATE_TO" name="DEAL_DATE_FROM" value="${form.DEAL_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_DATE_FROM_R}" disabled="${form_DEAL_DATE_FROM_D}" readOnly="${form_DEAL_DATE_FROM_RO}" />
		<e:text>~</e:text>
		<e:inputDate id="DEAL_DATE_TO" fromDate="DEAL_DATE_FROM" name="DEAL_DATE_TO" value="${form.DEAL_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_DEAL_DATE_TO_R}" disabled="${form_DEAL_DATE_TO_D}" readOnly="${form_DEAL_DATE_TO_RO}" />
		</e:field>
      <%-- 플랜트 --%>
      	<e:label for="PLANT_NM" title="${form_PLANT_NM_N}"/>
		<e:field>
		<e:select id="PLANT_NM" name="PLANT_NM" value="${form.PLANT_NM}" options="${plantNmOptions}" width="${inputTextWidth}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" placeHolder="" useMultipleSelect="true"/>
		</e:field>
      <%-- 마감유형 --%>
        <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
		<e:field>
		<e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
		</e:field>
      </e:row>
      <e:row>
      <%-- 지급조건 --%>
      	<e:label for="PAY_TERMS" title="${form_PAY_TERMS_N}"/>
		<e:field>
		<e:select id="PAY_TERMS" name="PAY_TERMS" value="${form.PAY_TERMS}" options="${payTermsOptions}" width="${inputTextWidth}" disabled="${form_PAY_TERMS_D}" readOnly="${form_PAY_TERMS_RO}" required="${form_PAY_TERMS_R}" placeHolder="" useMultipleSelect="true"/>
		</e:field>
      <%-- 내/외자 --%>
      	<e:label for="SHIPPER_TYPE" title="${form_SHIPPER_TYPE_N}"/>
		<e:field>
		<e:select id="SHIPPER_TYPE" name="SHIPPER_TYPE" value="${form.SHIPPER_TYPE}" options="${shipperTypeOptions}" width="${inputTextWidth}" disabled="${form_SHIPPER_TYPE_D}" readOnly="${form_SHIPPER_TYPE_RO}" required="${form_SHIPPER_TYPE_R}" placeHolder="" />
		</e:field>
      <%-- 협력회사명 --%>
      	<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'SEARCH_VENDOR'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
		</e:field>
      </e:row>
      <e:row>
      <%-- 송장번호 --%>
      	<e:label for="DEAL_NUM" title="${form_DEAL_NUM_N}"/>
		<e:field>
		<e:inputText id="DEAL_NUM" style="ime-mode:inactive" name="DEAL_NUM" value="${form.DEAL_NUM}" width="${inputTextWidth}" maxLength="${form_DEAL_NUM_M}" disabled="${form_DEAL_NUM_D}" readOnly="${form_DEAL_NUM_RO}" required="${form_DEAL_NUM_R}"/>
		</e:field>
      <%-- 회계문서번호 --%>
      	<e:label for="SL_NUM" title="${form_SL_NUM_N}"/>
		<e:field colSpan="3">
		<e:inputText id="SL_NUM" style="ime-mode:inactive" name="SL_NUM" value="${form.SL_NUM}" width="${inputTextWidth}" maxLength="${form_SL_NUM_M}" disabled="${form_SL_NUM_D}" readOnly="${form_SL_NUM_RO}" required="${form_SL_NUM_R}"/>
		</e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
