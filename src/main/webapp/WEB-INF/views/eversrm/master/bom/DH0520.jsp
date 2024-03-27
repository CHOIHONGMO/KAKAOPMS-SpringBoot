<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-11-02
  Scrren ID : DH0520
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0520";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);
      grid.setProperty('panelVisible', ${panelVisible});
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

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
        // cell 1개만 클릭 시 사용 아니면 삭제
        if(selRow == undefined) selRow = rowid;

        if(celname == "ITEM_CD") {
          var param = {
            'gate_cd': '${ses.gateCd}',
            'ITEM_CD': value
          };

          everPopup.openPopupByScreenId('BBM_040', 1200, 600, param);
        }

        if (celname == 'multiSelect') {
          if(selRow != rowid) {
            grid.checkRow(selRow, false);
            selRow = rowid;
          }
        }
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});
    }

    // 조회
    function doSearch() {
      // 품번/차종 필수입력
      if(EVF.getComponent('ITEM_CD').getValue() == '' && EVF.getComponent('MAT_CD').getValue() == '') {
        alert("${DH0520_0001}"); // 품번/차종 중 하나는 필수입력 입니다.

        var ids = {
          '품번': 'ITEM_CD',
          '차종': 'MAT_CD'
        };

        formUtil.animateFor(ids, 'form');

        return;
      }

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

      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      // Grid Validation Check
      if(!grid.validate().flag) { return alert("${msg.M0014}"); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    // 수정
    function doUpdate() {
      var store = new EVF.Store();

      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

      // Grid Validation Check
      if(!grid.validate().flag) {
        return alert("${msg.M0014}");
      }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0012}")) return;
      store.load(baseUrl + '/doModify', function() {
        alert(this.getResponseMessage());
        doSearch();
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
      EVF.getComponent("ITEM_CD").setValue(data.ITEM_CD);
      EVF.getComponent("ITEM_NM").setValue(data.ITEM_DESC);
    }

    function doEBOMSearch() {
      var param = {
        'ITEM_CD': EVF.getComponent('ITEM_CD').getValue(),
        'ITEM_NM': EVF.getComponent('ITEM_NM').getValue(),
        'detailView': false
      };

      everPopup.openPopupByScreenId('DH0522', 1000, 550, param);
    }

    function onClickItemCd() {
      EVF.getComponent("ITEM_NM").setValue("");
    }

    function doCreate() {
      doDH0523Pop('I')
    }

    function doModify() {

	  if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

      doDH0523Pop('U')
    }

    // 신규생성, 수정 팝업
    function doDH0523Pop(flag) {

      var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

      var param = {
        'detailView': false,
        'flag': flag,
        'ITEM_CD': flag == "U" ? grid.getCellValue(selRowId[0], "ITEM_CD") : "",
        'ITEM_DESC': flag == "U" ? grid.getCellValue(selRowId[0], "ITEM_DESC") : ""
      };

      everPopup.openPopupByScreenId('DH0523', 1200, 550, param);
    }

    function doTreeModify() {

        var gridData = grid.getSelRowValue();
        if (gridData.length > 1) {
        	return alert("${msg.M0006}");
        }

        if(!grid.isExistsSelRow()) {
        	return alert("${msg.M0004}");
        }

        var selectedRow = grid.getSelRowValue()[0];

        if (selectedRow.A!='●') {
    		alert("${DH0520_0002}");
    		return;
        }

        var param = {
                'detailView': false
                ,'BOM_ID' : selectedRow.BOM_ID
                ,'BOM_REV' : selectedRow.BOM_REV
              };
              everPopup.openPopupByScreenId('DH0520TREE', 1200, 800, param);
    }



  </script>

  <e:window id="DH0520" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="130" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <%--차종--%>
        <e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
        <e:field>
          <e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${matCdOptions}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
        </e:field>
        <%--구분--%>
        <e:label for="DIV" title="${form_DIV_N}"/>
        <e:field>
        <e:radioGroup id="radio" name="radio" disabled="" readOnly="" required="">
          <e:text>&nbsp;&nbsp;</e:text>
          <e:radio id="FRONT" name="FRONT" label="${form_FRONT_N}" value="F" checked="true"/>
          <e:text>&nbsp;&nbsp;</e:text>
          <e:radio id="BACK" name="BACK" label="${form_BACK_N}" value="B"/>
        </e:radioGroup>
        </e:field>
      </e:row>
      <e:row>
        <%--품번--%>
        <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
        <e:field>
          <e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onClick="onClickItemCd"/>
          <e:text>&nbsp;</e:text>
          <e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="50%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
        </e:field>
        <%--Revision--%>
        <e:label for="BOM_REV" title="${form_BOM_REV_N}"/>
        <e:field>
          <e:inputText id="BOM_REV" style="ime-mode:inactive" name="BOM_REV" value="${form.BOM_REV}" width="${inputTextWidth}" maxLength="${form_BOM_REV_M}" disabled="${form_BOM_REV_D}" readOnly="${form_BOM_REV_RO}" required="${form_BOM_REV_R}"/>
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doEBOMSearch" name="doEBOMSearch" label="${doEBOMSearch_N}" onClick="doEBOMSearch" disabled="${doEBOMSearch_D}" visible="${doEBOMSearch_V}"/>
      <e:button id="doCreate" name="doCreate" label="${doCreate_N}" onClick="doCreate" disabled="${doCreate_D}" visible="${doCreate_V}"/>
      <e:button id="doModify" name="doModify" label="${doModify_N}" onClick="doModify" disabled="${doModify_D}" visible="${doModify_V}"/>
      <e:button id="doTreeModify" name="doTreeModify" label="${doTreeModify_N}" onClick="doTreeModify" disabled="${doTreeModify_D}" visible="${doTreeModify_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>