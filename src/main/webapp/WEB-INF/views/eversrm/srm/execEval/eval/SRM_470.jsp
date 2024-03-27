<%--
  Date: 2016/01/07
  Time: 16:56:49
  Scrren ID : SRM_470
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = '/eversrm/srm/execEval/eval/SRM_470';
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);

      //grid Column Head Merge
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
      // Grid AddRow Event
      grid.addRowEvent(function() {
        grid.addRow();
      });

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
            if(selRow != rowId) {
              grid.checkRow(selRow, false);
              selRow = rowId;
            }

            break;

          case 'TH_NUM':
              var param = {
                'detailView': true,
                'popupFlag': true,
                'TH_NUM': value
              };

              everPopup.openPopupByScreenId('SRM_460', 950, 480, param);
            break;

          case 'VENDOR_CD':
              var params = {
                'detailView': true,
                'popupFlag': true,
                'VENDOR_CD': value
              };
              everPopup.openPopupByScreenId('BBV_010', 950, 580, params);
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

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    // Modify
    function doModify() {
      var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

      if(grid.getCellValue(selRowId[0], 'EV_USER_ID') != '${ses.userId}') {
        alert("${SRM_470_0001}"); // 구매담당자만 처리하실 수 있습니다.
        return;
      }

      var param = {
        'detailView': false,
        'popupFlag': true,
        'TH_NUM': grid.getCellValue(selRowId[0], 'TH_NUM'),
        'EV_USER_ID': grid.getCellValue(selRowId[0], 'EV_USER_ID')
      };

      everPopup.openPopupByScreenId('SRM_460', 950, 480, param);
    }

  </script>

  <e:window id="SRM_470" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
        <%--평가일자--%>
        <e:label for="START_DATE" title="${form_START_DATE_N}"/>
        <e:field>
          <e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${defaultFromDate}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
          <e:text> ~ </e:text>
          <e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${defaultToDate}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
        </e:field>
        <%--협력회사명--%>
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
        <e:field>
          <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
        </e:field>
        <%--제목--%>
        <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
        <e:field>
          <e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--구매담당자--%>
        <e:label for="EV_USER_NM" title="${form_EV_USER_NM_N}"/>
        <e:field>
          <e:inputText id="EV_USER_NM" style="${imeMode}" name="EV_USER_NM" value="${form.EV_USER_NM}" width="${inputTextWidth}" maxLength="${form_EV_USER_NM_M}" disabled="${form_EV_USER_NM_D}" readOnly="${form_EV_USER_NM_RO}" required="${form_EV_USER_NM_R}"/>
        </e:field>
        <%--거래업종--%>
        <e:label for="DEAL_TYPE_CD" title="${form_DEAL_TYPE_CD_N}"/>
        <e:field colSpan="3">
          <e:select id="DEAL_TYPE_CD" name="DEAL_TYPE_CD" value="${form.DEAL_TYPE_CD}" options="${dealTypeCdOptions}" width="${inputTextWidth}" disabled="${form_DEAL_TYPE_CD_D}" readOnly="${form_DEAL_TYPE_CD_RO}" required="${form_DEAL_TYPE_CD_R}" placeHolder="" />
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
