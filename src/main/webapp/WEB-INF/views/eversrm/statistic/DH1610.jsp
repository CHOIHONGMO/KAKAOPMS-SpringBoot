<%--
  Date: 2015/12/01
  Time: 11:18:34
  Scrren ID : DH1610
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/statistic/DH1610";
    var selRow;
    var currRow;
    var count = 0;
    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);

      <%--grid Column Head Merge --%>
      grid.setProperty('multiselect', true);

      <%-- Grid AddRow Event--%>
      grid.addRowEvent(function() {
        grid.addRow();
      });
      grid.setProperty('panelVisible', ${panelVisible});
      <%-- Grid Excel Event--%>
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
        <%-- cell one click--%>
        currRow = rowId;
        if(selRow == undefined) selRow = rowId;
        //alert("rowId :: "+rowId+" celName :: "+celName+" value :: "+value+" rowIdx :: "+rowIdx+" colIdx :: "+colIdx+" count ::"+count);
		if(celName == "VENDOR_NM" && rowIdx != count){
			everPopup.openCommonPopup({
	            callBackFunction: "selectVendorGrid"
	        }, 'SP0013');
		}

      });

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});
    }

    <%-- Search--%>
    function doSearch() {
      var store = new EVF.Store();

      <%-- form validation Check--%>
      if(!store.validate()) return;

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
        <%--addSumGrid();--%>
        count = grid.getRowCount();
        //grid.setProperty('footerrow', true);
		//grid.setRowFooter('TOTAL_AMT', 'sum', 'Total', 'CHARGE_FLAG');
		//grid.setRowFooter('CONSIGN_AMT', 'sum', '', '');
		//grid.setRowFooter('CUSTOMER_AMT', 'sum', '', '');
		//grid.setRowFooter('UNCONFIRM_AMT', 'sum', '', '');

        grid.setProperty('footerVisible', true);
        var footer = {
          "text": "Total",
          "styles": {
            "fontBold": true
          }
        };
        grid._gvo.setColumnProperty("CHARGE_FLAG", "footer", footer);

        footer = {
          "expression": "sum",
          "styles": {
            "numberFormat": "0,000",
            "fontBold": true
          }
        };
        grid._gvo.setColumnProperty('TOTAL_AMT', 'footer', footer);
        grid._gvo.setColumnProperty("CONSIGN_AMT", "footer", footer);
        grid._gvo.setColumnProperty("CUSTOMER_AMT", "footer", footer);
        grid._gvo.setColumnProperty("UNCONFIRM_AMT", "footer", footer);
      });
    }

    <%-- Save--%>
    function doSave() {
      var store = new EVF.Store();
	  grid.checkRow(count-1, false); <%-- 합계행 선택해지 :: 총 그리드열 갯수 count-1 번째 행 선택해지 --%>
      <%-- form validation Check--%>
      <%--if(!store.validate()) return;--%>
      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!grid.validate().flag) { return alert(grid.validate().msg); }


      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    <%-- Delete--%>
    function doDelete() {
      if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
        alert("${msg.M0004}");
        return;
      }

      if (!confirm("${msg.M0013 }")) return;

      var store = new EVF.Store();
      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      store.load(baseUrl + '/doDelete', function(){
        alert(this.getResponseMessage());
        doSearch();
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

    function selectVendorGrid(param){
		grid.setCellValue(currRow, 'VENDOR_CD', param.VENDOR_CD);
		grid.setCellValue(currRow, 'VENDOR_NM', param.VENDOR_NM);
	}

</script>

  <e:window id="DH1610" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
      <%-- 품의일자 --%>
      	<e:label for="EXEC_DATE_FROM" title="${form_EXEC_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="EXEC_DATE_FROM" toDate="EXEC_DATE_TO" name="EXEC_DATE_FROM" value="${form.EXEC_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_FROM_R}" disabled="${form_EXEC_DATE_FROM_D}" readOnly="${form_EXEC_DATE_FROM_RO}" />
		<e:text>~</e:text>
		<e:inputDate id="EXEC_DATE_TO" fromDate="EXEC_DATE_FROM" name="EXEC_DATE_TO" value="${form.EXEC_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_EXEC_DATE_TO_R}" disabled="${form_EXEC_DATE_TO_D}" readOnly="${form_EXEC_DATE_TO_RO}" />
		</e:field>
      <%-- 관련근거품의 --%>
      	<e:label for="EXEC_SUBJECT" title="${form_EXEC_SUBJECT_N}"/>
		<e:field>
		<e:inputText id="EXEC_SUBJECT" style="ime-mode:auto" name="EXEC_SUBJECT" value="${form.EXEC_SUBJECT}" width="${inputTextWidth}" maxLength="${form_EXEC_SUBJECT_M}" disabled="${form_EXEC_SUBJECT_D}" readOnly="${form_EXEC_SUBJECT_RO}" required="${form_EXEC_SUBJECT_R}"/>
		</e:field>
      <%-- 각사명 --%>
       	<e:label for="COMPANY_NM" title="${form_COMPANY_NM_N}"/>
		<e:field>
		<e:inputText id="COMPANY_NM" style="${imeMode}" name="COMPANY_NM" value="${form.COMPANY_NM}" width="${inputTextWidth}" maxLength="${form_COMPANY_NM_M}" disabled="${form_COMPANY_NM_D}" readOnly="${form_COMPANY_NM_RO}" required="${form_COMPANY_NM_R}"/>
		</e:field>
      </e:row>

       <e:row>
      <%-- 협력회사명 --%>
      	<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'SEARCH_VENDOR'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
		</e:field>
      <%-- 유무상 --%>
        <e:label for="CHARGE_FLAG" title="${form_CHARGE_FLAG_N}"/>
		<e:field colSpan="3">
		<e:select id="CHARGE_FLAG" name="CHARGE_FLAG" value="${form.CHARGE_FLAG}" options="${chargeFlagOptions}" width="${inputTextWidth}" disabled="${form_CHARGE_FLAG_D}" readOnly="${form_CHARGE_FLAG_RO}" required="${form_CHARGE_FLAG_R}" placeHolder="" />
		</e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
      <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
