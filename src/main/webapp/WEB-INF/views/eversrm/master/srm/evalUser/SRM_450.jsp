<%--
  Date: 2015/12/21
  Time: 13:53:25
  Scrren ID : SRM_450
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/srm/evalUser/SRM_450";
    var selRow;
    var currRow;

    function init() {

      grid = EVF.C('grid');
      grid.setProperty("shrinkToFit", true);

      <%--grid Column Head Merge --%>
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
      <%-- Grid AddRow Event --%>
      grid.addRowEvent(function() {
        grid.addRow();
      });

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
        currRow = rowId;
        if(selRow == undefined) selRow = rowId;

        if (celName == 'EV_USER_NM') {
        	everPopup.openCommonPopup({
	            callBackFunction: "selectEvUser"
	        }, 'SP0001');
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

    <%-- Save --%>
    function doSave() {
      var store = new EVF.Store();

      <%-- form validation Check --%>
      if(!store.validate()) return;
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

    <%-- Delete --%>
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

    <%-- 성명 조회 --%>
    function serachUser(){
    	var param = {
    			callBackFunction : "selectEvCtrlUser"
    	};
    	everPopup.openCommonPopup(param, 'SP0027');
    }
    function selectEvCtrlUser(param){
    	EVF.C("EV_USER_NM").setValue(param.USER_NM);
    }

    <%-- 성명 조회 : 그리드 --%>
    function selectEvUser(param){
    	grid.setCellValue(currRow, 'EV_USER_ID', param.USER_ID);
		grid.setCellValue(currRow, 'EV_USER_NM', param.USER_NM);
    }

  </script>

  <e:window id="SRM_450" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="true" onEnter="doSearch">
      <e:row>
      <%-- 성명  --%>
      	<e:label for="EV_USER_NM" title="${form_EV_USER_NM_N}"/>
		<e:field>
		<e:search id="EV_USER_NM" style="${imeMode}" name="EV_USER_NM" value="" width="${inputTextWidth}" maxLength="${form_EV_USER_NM_M}" onIconClick="${form_EV_USER_NM_RO ? 'everCommon.blank' : 'serachUser'}" disabled="${form_EV_USER_NM_D}" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}" />
		</e:field>

      <%-- 자격인증일 --%>
        <e:label for="CERT_DATE_FROM" title="${form_CERT_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="CERT_DATE_FROM" toDate="CERT_DATE_TO" name="CERT_DATE_FROM" value="${form.CERT_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_CERT_DATE_FROM_R}" disabled="${form_CERT_DATE_FROM_D}" readOnly="${form_CERT_DATE_FROM_RO}" />
		<e:text>~</e:text>
		<e:inputDate id="CERT_DATE_TO" fromDate="CERT_DATE_FROM" name="CERT_DATE_TO" value="${form.CERT_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_CERT_DATE_TO_R}" disabled="${form_CERT_DATE_TO_D}" readOnly="${form_CERT_DATE_TO_RO}" />
		</e:field>

      </e:row>
      <e:row>
      <%-- 유효기간 --%>
     	<e:label for="VALID_TO_DATE_FROM" title="${form_VALID_TO_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="VALID_TO_DATE_FROM" toDate="VALID_TO_DATE_TO" name="VALID_TO_DATE_FROM" value="${form.VALID_TO_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_VALID_TO_DATE_FROM_R}" disabled="${form_VALID_TO_DATE_FROM_D}" readOnly="${form_VALID_TO_DATE_FROM_RO}" />
		<e:text>~</e:text>
		<e:inputDate id="VALID_TO_DATE_TO" fromDate="VALID_TO_DATE_FROM" name="VALID_TO_DATE_TO" value="${form.VALID_TO_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_VALID_TO_DATE_TO_R}" disabled="${form_VALID_TO_DATE_TO_D}" readOnly="${form_VALID_TO_DATE_TO_RO}" />
		</e:field>

      <%-- 적격성평가일 --%>
        <e:label for="ELIGIBLE_DATE_FROM" title="${form_ELIGIBLE_DATE_FROM_N}"/>
		<e:field>
		<e:inputDate id="ELIGIBLE_DATE_FROM" toDate="ELIGIBLE_DATE_TO" name="ELIGIBLE_DATE_FROM" value="${form.ELIGIBLE_DATE_FROM}" width="${inputTextDate}" datePicker="true" required="${form_ELIGIBLE_DATE_FROM_R}" disabled="${form_ELIGIBLE_DATE_FROM_D}" readOnly="${form_ELIGIBLE_DATE_FROM_RO}" />
		<e:text>~</e:text>
		<e:inputDate id="ELIGIBLE_DATE_TO" fromDate="ELIGIBLE_DATE_FROM" name="ELIGIBLE_DATE_TO" value="${form.ELIGIBLE_DATE_TO}" width="${inputTextDate}" datePicker="true" required="${form_ELIGIBLE_DATE_TO_R}" disabled="${form_ELIGIBLE_DATE_TO_D}" readOnly="${form_ELIGIBLE_DATE_TO_RO}" />
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
