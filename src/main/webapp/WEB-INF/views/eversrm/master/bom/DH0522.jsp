<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-11-02
  Scrren ID : DH0522(구매BOM현황 -> E-BOM조회)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0522";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", false);

      //grid Column Head Merge
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
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

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {});

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});
    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      return alert("테이블이 존재하지 않습니다.");

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    function searchITEM_CD() {
      var param = {
        'callBackFunction': 'selectItemCd',
        'detailView': false
      };

      everPopup.openPopupByScreenId('DH0521', 1000, 550, param);
    }

    function selectItemCd(data) {
      EVF.getComponent('ITEM_CD').setValue(data.ITEM_CD);
      EVF.getComponent('ITEM_NM').setValue(data.ITEM_DESC);
    }

    function doClose() {
      window.close();
    }

    function onClickItemCd() {
      EVF.getComponent('ITEM_NM').setValue('');
    }

  </script>

  <e:window id="DH0522" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="true" onEnter="doSearch">
      <e:row>
        <%--품번--%>
        <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
        <e:field>
          <e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${param.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onClick="onClickItemCd"/>
          <e:text>&nbsp;</e:text>
          <e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${param.ITEM_NM}" width="200" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
        </e:field>
        <%--Case Number--%>
        <e:label for="CASE_NUMBER" title="${form_CASE_NUMBER_N}"/>
        <e:field>
          <e:inputText id="CASE_NUMBER" style="ime-mode:inactive" name="CASE_NUMBER" value="${form.CASE_NUMBER}" width="${inputTextWidth}" maxLength="${form_CASE_NUMBER_M}" disabled="${form_CASE_NUMBER_D}" readOnly="${form_CASE_NUMBER_RO}" required="${form_CASE_NUMBER_R}"/>
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>