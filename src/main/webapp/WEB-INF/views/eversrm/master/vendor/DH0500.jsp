<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : DH0500(협력회사 정보변경 이력)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/vendor/DH0500";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);

      //grid Column Head Merge
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
      // Grid AddRow Event
      grid.addRowEvent(function() {
        addParam = [{'INSERT_FLAG': 'I'}];
        grid.addRow(addParam);
      });

      // Grid Excel Event
      grid.excelExportEvent({
        allCol : "${excelExport.allCol}",
        selRow : "${excelExport.selRow}",
        fileType : "${excelExport.fileType }",
        fileName : "${screenName }",
        excelOptions : {
          imgWidth      : 0.12, 		// 이미지 너비
          imgHeight     : 0.26,		    // 이미지 높이
          colWidth      : 20,        	// 컬럼의 넓이
          rowSize       : 500,       	// 엑셀 행에 높이 사이즈
          attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
        }
      });

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
        switch(celname) {
          case 'VENDOR_CD':
                  var params = {
                    VENDOR_CD: grid.getCellValue(rowid, 'VENDOR_CD'),
                    paramPopupFlag: 'Y',
                    detailView : true
                  };
                  everPopup.openSupManagementPopup(params);
                break;
        }
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});
    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      // 날짜 체크
      if(!everDate.checkTermDate('REG_FROM_DATE','REG_TO_DATE','${msg.M0073}')) {
        return;
      }

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    </script>

  <e:window id="DH0500" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <%--변경일자--%>
        <e:label for="REG_FROM_DATE" title="${form_REG_FROM_DATE_N}"/>
        <e:field>
          <e:inputDate id="REG_FROM_DATE" toDate="REG_TO_DATE" name="REG_FROM_DATE" value="${defaultFromDate}" width="${inputTextDate}" datePicker="true" required="${form_REG_FROM_DATE_R}" disabled="${form_REG_FROM_DATE_D}" readOnly="${form_REG_FROM_DATE_RO}" />
          <e:text> ~ </e:text>
          <e:inputDate id="REG_TO_DATE" fromDate="REG_FROM_DATE" name="REG_TO_DATE" value="${defaultToDate}" width="${inputTextDate}" datePicker="true" required="${form_REG_TO_DATE_R}" disabled="${form_REG_TO_DATE_D}" readOnly="${form_REG_TO_DATE_RO}" />
        </e:field>
        <%--협력회사명--%>
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
        <e:field>
          <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
        </e:field>
        <%--변경자명--%>
        <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
        <e:field>
          <e:inputText id="REG_USER_NM" style="${imeMode}" name="REG_USER_NM" value="${form.REG_USER_NM}" width="100%" maxLength="${form_REG_USER_NM_M}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--사업자번호--%>
        <e:label for="IRS_NUM" title="${form_IRS_NUM_N}"/>
        <e:field colSpan="5">
          <e:inputText id="IRS_NUM" style="ime-mode:inactive" name="IRS_NUM" value="${form.IRS_NUM}" width="${inputTextWidth}" maxLength="${form_IRS_NUM_M}" disabled="${form_IRS_NUM_D}" readOnly="${form_IRS_NUM_RO}" required="${form_IRS_NUM_R}"/>
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>