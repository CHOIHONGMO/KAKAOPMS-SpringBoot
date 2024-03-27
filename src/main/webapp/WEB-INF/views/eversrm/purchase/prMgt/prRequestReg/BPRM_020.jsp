<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : BPRM_020
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/purchase/prMgt/prRequestReg/BPRM_020";

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);

      //grid Column Head Merge
      grid.setProperty('multiselect', false);

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

      doSearch();
    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      store.setParameter('prItemList', '${param.prItemList}');
      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
    	if (this.getResponseCode() == "true") {
            if(grid.getRowCount() == 0) {
                return alert('${msg.M0002}');
              }
    	} else {
            return alert('${msg.M0003}');
    	}
      });
    }

    function doClose() {
      window.close();
    }
  </script>

  <e:window id="BPRM_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
    </e:buttonBar>
    <e:searchPanel id="form" title="${form_TITLE_N}" labelWidth="100" width="100%" useTitleBar="true" onEnter="doClose">
      <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:searchPanel>
  </e:window>
</e:ui>