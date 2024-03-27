<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : DH0570(재질단가관리)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script src="/js/nicednb/aes.js"></script>
  <script src="/js/nicednb/AesUtil.js"></script>
  <script src="/js/nicednb/pbkdf2.js"></script>
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0570";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);
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
          imgWidth      : 0.12, 		// 이미지 너비
          imgHeight     : 0.26,		    // 이미지 높이
          colWidth      : 20,        	// 컬럼의 넓이
          rowSize       : 500,       	// 엑셀 행에 높이 사이즈
          attachImgFlag : false      	// 엑셀에 이미지를 첨부할지에 대한 여부 true : 이미지 첨부, false : 이미지 미첨부
        }
      });


      grid.excelImportEvent({
          'append': false
      }, function (msg, code) {

          if (code) {
              grid.checkAll(true);

              var allRowId = grid.getAllRowId();
              for(var i in allRowId) {

                  var rowId = allRowId[i];

//                  grid.setCellValue(rowId, 'PURCHASE_TYPE', 'DMRO');
//                  grid.setCellValue(rowId, 'REG_USER_ID', '${ses.userId}');
//                  grid.setCellValue(rowId, 'REG_USER_NM', '${ses.userNm}');
              }
          }
      });




      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});
    }

    // 조회
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
    function doDelete() {

        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

        if(!confirm('${msg.M0013}')) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doDelete', function() {
          alert(this.getResponseMessage());
          doSearch();
        });
      }


    function doSave() {
        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if (!grid.validate().flag) { return alert("${msg.M0014}"); }
        if(!confirm('${msg.M0021}')) { return; }
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSave', function() {
          alert(this.getResponseMessage());
          doSearch();
        });
      }


    </script>

  <e:window id="DH0570" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
		<e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
		<e:field>
		<e:inputText id="MAT_CD" style="ime-mode:inactive" name="MAT_CD" value="${form.MAT_CD}" width="${inputTextWidth}" maxLength="${form_MAT_CD_M}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}"/>
		</e:field>
		<e:label for="MAT_NM" title="${form_MAT_NM_N}"/>
		<e:field>
		<e:inputText id="MAT_NM" style="${imeMode}" name="MAT_NM" value="${form.MAT_NM}" width="${inputTextWidth}" maxLength="${form_MAT_NM_M}" disabled="${form_MAT_NM_D}" readOnly="${form_MAT_NM_RO}" required="${form_MAT_NM_R}"/>
		</e:field>
		<e:label for="MAT_KIND" title="${form_MAT_KIND_N}"/>
		<e:field>
		<e:inputText id="MAT_KIND" style="ime-mode:inactive" name="MAT_KIND" value="${form.MAT_KIND}" width="${inputTextWidth}" maxLength="${form_MAT_KIND_M}" disabled="${form_MAT_KIND_D}" readOnly="${form_MAT_KIND_RO}" required="${form_MAT_KIND_R}"/>
		</e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>