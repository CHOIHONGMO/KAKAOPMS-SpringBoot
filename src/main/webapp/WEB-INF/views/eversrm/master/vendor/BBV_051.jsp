<%@ page import="com.st_ones.everf.serverside.config.PropertiesManager" %>
<%--
  Date: 2016/01/05
  Time: 11:19:13
  Scrren ID : BBV_051
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
  String domainName = PropertiesManager.getString("eversrm.system.domainName");
  String domainPort = PropertiesManager.getString("eversrm.system.domainPort");
%>
<c:set var="domainName" value="<%=domainName%>" />
<c:set var="domainPort" value="<%=domainPort%>" />
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = '/eversrm/master/vendor/BBV_051';
    var selRow;

    function init() {
      $('.e-panel-titlebar').css('display', 'none');

      // 그리드 컬럼 정의(거래공장 동적구현)
      //grid = new EVF.GridPanel('grid');
      grid = new EVF.C('grid');
      grid.setProperty('panelVisible', ${panelVisible});
      grid.createColumn('VENDOR_CD', '${BBV_051_VENDOR_CD}', 80, 'center', 'text', 10, false,'');
      grid.createColumn('VENDOR_NM', '${BBV_051_VENDOR_NM}', 150, 'left', 'text', 200, false,'');
      grid.createColumn('DEAL_SQ_CD', '${BBV_051_DEAL_SQ_CD}', 60, 'center', 'text', 20, false,'');
      grid.createColumn('VAATZ_VENDOR_CD', '${BBV_051_VAATZ_VENDOR_CD}', 80, 'center', 'text', 10, false,'');

      grid.createColumn('DEAL_TYPE1', '${BBV_051_DEAL_TYPE1}', 80, 'center', 'text', 100, false,'');
      grid.createColumn('DEAL_TYPE2', '${BBV_051_DEAL_TYPE2}', 80, 'center', 'text', 100, false,'');
      grid.createColumn('DEAL_TYPE3', '${BBV_051_DEAL_TYPE3}', 80, 'center', 'text', 100, false,'');
      grid.createColumn('MAJOR_ITEM_TEXT', '${BBV_051_MAJOR_ITEM_TEXT}', 150, 'left', 'text', 2000, false,'');
      grid.createColumn('CEO_USER_NM', '${BBV_051_CEO_USER_NM}', 100, 'center', 'text', 50, false,'');
      grid.createColumn('IRS_NUM', '${BBV_051_IRS_NUM}', 100, 'center', 'text', 10, false,'');
      grid.createColumn('REP_EMAIL', '${BBV_051_REP_EMAIL}', 150, 'center', 'text', 50, false,'');
      grid.createColumn('REP_TEL_NUM', '${BBV_051_REP_TEL_NUM}', 100, 'center', 'text', 20, false,'');
      grid.createColumn('ADDR', '${BBV_051_ADDR}', 200, 'center', 'text', 200, false,'');

      <c:forEach varStatus="idx" begin="1" step="1" end="3">
        <c:if test="${idx.count eq '1'}">grid.createColumn('SQ_DEAL_TYPE1', '${BBV_051_SQ_DEAL_TYPE1}', 60, 'center', 'text', 100, false,'');</c:if>
        <c:if test="${idx.count eq '2'}">grid.createColumn('SQ_DEAL_TYPE2', '${BBV_051_SQ_DEAL_TYPE2}', 60, 'center', 'text', 100, false,'');</c:if>
        <c:if test="${idx.count eq '3'}">grid.createColumn('SQ_DEAL_TYPE3', '${BBV_051_SQ_DEAL_TYPE3}', 60, 'center', 'text', 100, false,'');</c:if>

        grid.createColumn('SQ_GRADE_CD'+${idx.count}, '${BBV_051_SQ_GRADE_CD}', 60, 'center', 'text', 100, false,'');
        grid.createColumn('EV_SCORE'+${idx.count}, '${BBV_051_EV_SCORE}', 60, 'center', 'text', 100, false,'');
        grid.createColumn('CERT_NUM'+${idx.count}, '${BBV_051_CERT_NUM}', 60, 'center', 'text', 100, false,'');
        grid.createColumn('MAIN_EV_INS_NM'+${idx.count}, '${BBV_051_MAIN_EV_INS_NM}', 60, 'center', 'text', 100, false,'');
      </c:forEach>

      grid.createColumn('DEAL_START_DATE', '${BBV_051_DEAL_START_DATE}', 95, 'center', 'date', 8, false, true, '');
      grid.createColumn('REMARK', '${BBV_051_REMARK}', 80, 'left', 'text', 2000, false, true, '');

      var regLen = 0;
      var col = [];
      <c:forEach varStatus="idx" var="region" items="${regionList}">
        grid.createColumn('REGION_'+'${idx.count}', '${region.PLANT_NM}', 40, 'center', 'text', 1, false, '');
        col.push('REGION_'+'${idx.count}');
        regLen++;
      </c:forEach>

      if(${_gridType eq "RG"}) {
        grid.setColGroup([{
          "groupName": '${BBV_051_REGION_TYPE}',
          "columns": col
        }])
      } else {
        grid.setGroupCol([{'colName': 'REGION_1', 'colIndex': regLen, 'titleText': '${BBV_051_REGION_TYPE}'}]);
      }

      //grid.boundColumns();

      grid.setProperty("shrinkToFit", false);

      //grid Column Head Merge
      grid.setProperty('multiselect', true);

      // Grid Excel Event
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
        // cell one click
        if(selRow == undefined) selRow = rowId;

        switch(celName) {
          case 'multiSelect':
            /*
             if(selRow != rowId) {
             grid.checkRow(selRow, false);
             selRow = rowId;
             }
             */
            break;

          case 'VENDOR_CD':
            var params = {
              VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
              paramPopupFlag: "Y",
              detailView : true
            };
            everPopup.openSupManagementPopup(params);
            break;
        }
      });

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});

    }

    // Search
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      // 날짜 체크
      if(!everDate.checkTermDate('START_DATE','END_DATE','${msg.M0133}')) { return; }

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    // Save
    function doSave() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;
      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!grid.validate().flag) { return alert(grid.validate().msg); }

      var selRowValue = grid.getSelRowValue();
      for(var idx in selRowValue) {
        if(selRowValue[idx].DEAL_START_DATE == "") {
          alert("${BBV_051_0001}"); // 거래개시일자를 입력하여 주시기 바랍니다.
          return;
        }

        if(selRowValue[idx].REMARK == "") {
          alert("${BBV_051_0002}"); // 비고를 입력하여 주시기 바랍니다.
          return;
        }
      }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    // Modify
    function doModify() {

      var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

      if (selRowIds.length == 0) { return alert("${msg.M0004}"); }
      if (selRowIds.length > 1) { return alert("${msg.M0006}"); }

      var params = {
        VENDOR_CD: grid.getCellValue(selRowIds[0], "VENDOR_CD"),
        paramPopupFlag: "Y",
        detailView : false
      };
      everPopup.openSupManagementPopup(params);
    }

    // Print
    function doPrint() {
      var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

      if(selRowIds.length == 0) { return alert("${msg.M0004}"); }
      if(selRowIds.length > 1) { return alert('${msg.M0006}'); }

      var urlPath = document.location.protocol + "//" + document.location.host;
      var url = urlPath + "/ClipReport4/JavaOOFGenerator_Popup.jsp";

      var param = {
        'crfName': 'vendor_info.crf',
        'crfDbName': 'sql',
        'crfParams': "GATE_CD:"+'${ses.gateCd}'+"^VENDOR_CD:"+grid.getCellValue(selRowIds[0], "VENDOR_CD")+"^DOMAINNAME:"+'${domainName}'+"^DOMAINPORT:"+'${domainPort}' // 샘플확인 번호 : 110088
      };

      everPopup.openWindowPopup(url, 1000, 700, param, "reportPopup");
    }

    // 협력회사코드/명 팝업
    function searchVendorCd() {
      var param = {
        callBackFunction : "selectVendorCd"
      };
      everPopup.openCommonPopup(param, 'SP0013');
    }

    function selectVendorCd(data) {
      EVF.C("VENDOR_CD").setValue(data.VENDOR_CD);
      EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
    }

  </script>

  <e:window id="BBV_051" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="110" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
        <%--협력회사코드 / 명--%>
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
        <e:field>
          <e:inputText id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="${form.VENDOR_CD}" width="${inputTextWidth}" maxLength="${form_VENDOR_CD_M}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}"/>
          <e:text> / </e:text>
          <e:search id="VENDOR_NM" name="VENDOR_NM" value="${form.VENDOR_NM}" width="50%" maxLength="${form_VENDOR_NM_M}" onIconClick="${param.detailView ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" style="${imeMode}"/>
        </e:field>
        <%--대표자명--%>
        <e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}"/>
        <e:field>
          <e:inputText id="CEO_USER_NM" style="${imeMode}" name="CEO_USER_NM" value="${form.CEO_USER_NM}" width="${inputTextWidth}" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}"/>
        </e:field>
        <%--사업자등록번호--%>
        <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"/>
        <e:field>
          <e:inputText id="IRS_NUM" style="ime-mode:inactive" name="IRS_NUM" value="${form.IRS_NUM}" width="${inputTextWidth}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--지역--%>
        <e:label for="REGION_CD" title="${form_REGION_CD_N}"/>
        <e:field>
          <e:select id="REGION_CD" name="REGION_CD" value="${form.REGION_CD}" options="${regionCdOptions}" width="${inputTextWidth}" disabled="${form_REGION_CD_D}" readOnly="${form_REGION_CD_RO}" required="${form_REGION_CD_R}" placeHolder="" />
        </e:field>
        <%--거래업종--%>
        <e:label for="DEAL_TYPE_CD" title="${form_DEAL_TYPE_CD_N}"/>
        <e:field>
          <e:select id="DEAL_TYPE_CD" name="DEAL_TYPE_CD" value="${form.DEAL_TYPE_CD}" options="${dealTypeCdOptions}" width="${inputTextWidth}" disabled="${form_DEAL_TYPE_CD_D}" readOnly="${form_DEAL_TYPE_CD_RO}" required="${form_DEAL_TYPE_CD_R}" placeHolder="" />
        </e:field>
        <%--등록일자--%>
        <e:label for="START_DATE" title="${form_START_DATE_N}"/>
        <e:field>
          <e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${form.START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
          <e:text> ~ </e:text>
          <e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${form.END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
        </e:field>
      </e:row>
      <e:row>
        <%--등록형태--%>
        <e:label for="REG_TYPE" title="${form_REG_TYPE_N}"/>
        <e:field>
          <e:select id="REG_TYPE" name="REG_TYPE" value="${form.REG_TYPE}" options="${regTypeOptions}" width="${inputTextWidth}" disabled="${form_REG_TYPE_D}" readOnly="${form_REG_TYPE_RO}" required="${form_REG_TYPE_R}" placeHolder="" />
        </e:field>
        <%--주생산품--%>
        <e:label for="MAJOR_ITEM_TEXT" title="${form_MAJOR_ITEM_TEXT_N}"/>
        <e:field>
          <e:inputText id="MAJOR_ITEM_TEXT" style="${imeMode}" name="MAJOR_ITEM_TEXT" value="${form.MAJOR_ITEM_TEXT}" width="${inputTextWidth}" maxLength="${form_MAJOR_ITEM_TEXT_M}" disabled="${form_MAJOR_ITEM_TEXT_D}" readOnly="${form_MAJOR_ITEM_TEXT_RO}" required="${form_MAJOR_ITEM_TEXT_R}"/>
        </e:field>
        <%--거래챠수--%>
        <e:label for="DEAL_SQ_CD" title="${form_DEAL_SQ_CD_N}"/>
        <e:field>
          <e:select id="DEAL_SQ_CD" name="DEAL_SQ_CD" value="${form.DEAL_SQ_CD}" options="${dealSqCdOptions}" width="${inputTextWidth}" disabled="${form_DEAL_SQ_CD_D}" readOnly="${form_DEAL_SQ_CD_RO}" required="${form_DEAL_SQ_CD_R}" placeHolder="" />
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
      <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
      <e:button id="doPrint"  name="doPrint"  label="${doPrint_N}"  onClick="doPrint"  disabled="${doPrint_D}"  visible="${doPrint_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
