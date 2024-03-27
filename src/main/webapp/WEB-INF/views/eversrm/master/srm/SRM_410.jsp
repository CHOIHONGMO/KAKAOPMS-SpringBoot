<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-09-21
  Time: 오후 1:44
  Scrren ID : SRM_410
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/srm/SRM_410";
    var selRow;

    function init() {

      grid = EVF.C('grid');
      grid.setProperty("shrinkToFit", true);
      grid.setProperty('panelVisible', ${panelVisible});
      //grid Column Head Merge
      grid.setProperty('multiselect', true);

      // Grid AddRow Event
      grid.addRowEvent(function() {
        addParam = [{'YEAR': '${defaultYear}'}];
        grid.addRow(addParam);
      });

      // Grid Excel Import
      grid.excelImportEvent({
        'append': false
      }, function (msg, code) {
        if (code) {
          grid.checkAll(true);
        }
      });

      // Grid Excel Export
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
        selRow = rowid;

        switch(celname) {

          case 'VENDOR_CD':
            var param = {
              callBackFunction : 'doSetVendorNmGrid'
            };

            everPopup.openCommonPopup(param, 'SP0013');

            break;
        }

      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});

      if(${_gridType eq "RG"}) {
        grid.setColGroup([{
          "groupName": '그룹분류점수',
          "columns": [ "GROUP_AMT", "ITEM_DESC", "DIFFICULTY_RATE" ]
        }]);
      } else {
        grid.setGroupCol(
              [
                {'colName': 'GROUP_AMT', 'colIndex': 3, 'titleText': '그룹분류점수'}
              ]
        );
      }
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

    // 저장
    function doSave() {
      var store = new EVF.Store();
      var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

      if(selRowIds.length == 0) {
        return alert("${msg.M0004}");
      }

      // Grid Validation Check
      if (!grid.validate().flag) { return alert(grid.validate().msg); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    // 삭제
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

    // 협력회사명 팝업(Form)
    function searchVendorNm() {
      var param = {
        callBackFunction : 'doSetVendorNmForm'
      };
      everPopup.openCommonPopup(param, 'SP0013');
    }

    // 협력회사명 팝업 셋팅(Form)
    function doSetVendorNmForm(data) {
      EVF.C("VENDOR_NM").setValue(data.VENDOR_NM);
    }

    // 협력회사명 팝업 셋팅(Grid)
    function doSetVendorNmGrid(data) {
      grid.setCellValue(selRow, "VENDOR_CD", data.VENDOR_CD);
      grid.setCellValue(selRow, "VENDOR_NM", data.VENDOR_NM);
    }

  </script>

  <e:window id="SRM_410" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <%--년도--%>
        <e:label for="YEAR" title="${form_YEAR_N}"/>
        <e:field>
          <e:select id="YEAR" name="YEAR" value="${defaultYear}" options="${refYear}" width="${inputTextWidth}" disabled="${form_YEAR_D}" readOnly="${form_YEAR_RO}" required="${form_YEAR_R}" placeHolder="" />
        </e:field>
        <%--협력회사명--%>
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
        <e:field>
          <e:search id="VENDOR_NM" style="ime-mode:auto" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="searchVendorNm" disabled="${form_USER_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
        </e:field>
        <%--그룹분류--%>
        <e:label for="GROUP_CD" title="${form_GROUP_CD_N}"/>
        <e:field>
          <e:select id="GROUP_CD" name="GROUP_CD" value="${form.GROUP_CD}" options="${refGroup}" width="${inputTextWidth}" disabled="${form_GROUP_CD_D}" readOnly="${form_GROUP_CD_RO}" required="${form_GROUP_CD_R}" placeHolder="" />
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