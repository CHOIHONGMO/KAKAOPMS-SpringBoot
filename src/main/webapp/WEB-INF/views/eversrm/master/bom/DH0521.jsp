<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-11-02
  Scrren ID : DH0521(구매BOM현황 -> 품번 조회 팝업)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0521";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);

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
        if(selRow == undefined) selRow = rowid;

        if (celname == 'multiSelect') {
          // cell 1개만 클릭
          if(selRow != rowid) {
            grid.checkRow(selRow, false);
            selRow = rowid;
          }
        }

        if (celname == 'ITEM_CD') {

          var param = {
            'gate_cd': '${ses.gateCd}',
            'ITEM_CD': grid.getCellValue(rowid, 'ITEM_CD')
          };

          everPopup.openPopupByScreenId('BBM_040', 1200, 600, param);
        }
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});

      // PF0055 인 경우 대분류를 부품구매로 세팅
      if("${ses.grantedAuthCd}" == 'PF0055'|| "${ses.grantedAuthCd}" == 'PF0051') {
        EVF.getComponent('ITEM_CLS1').setValue('01');
      }
    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      // 품번/품명/차종 필수입력
      if(EVF.getComponent('ITEM_CD').getValue() == '' && EVF.getComponent('ITEM_DESC').getValue() == '' && EVF.getComponent('MAT_CD').getValue() == '') {
        alert("${DH0521_0001}"); // 품번/품명/차종 중 하나는 필수입력 입니다.

        var ids = {
          '품번': 'ITEM_CD',
          '품명': 'ITEM_DESC',
          '차종': 'MAT_CD'
        };

        formUtil.animateFor(ids, 'form');

        return;
      }

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    function searchITEM_CD() {
      var param = {
        callBackFunction: 'selectItemCd'
      };
      everPopup.openCommonPopup(param, 'SP0018');
    }

    function selectItemCd(data) {
      EVF.getComponent('ITEM_CD').setValue(data.ITEM_CD);
    }

    function doSelect() {
      var selIdx = grid.jsonToArray(grid.getSelRowId()).value;

      var data = {
        'ITEM_CD': grid.getCellValue(selIdx[0], "ITEM_CD"),
        'ITEM_DESC': grid.getCellValue(selIdx[0], "ITEM_DESC")
      };

      opener.window['${param.callBackFunction}'](data);

      doClose();
    }

    function doClose() {
      window.close();
    }

    function getitem_cls() {
      var store = new EVF.Store();

      var cls_type = this.getData();
      var item_cls = '';
      if (cls_type=='2') {
        item_cls= EVF.getComponent("ITEM_CLS1").getValue();
        clearX('3');
//        clearX('4');
      }
      if (cls_type=='3') {
        item_cls= EVF.getComponent("ITEM_CLS2").getValue();
//        clearX('4');
      }

      if (cls_type=='4') {
        item_cls= EVF.getComponent("ITEM_CLS3").getValue();
      }

      store.load(baseUrl + '/getItem_Cls.so?CLS_TYPE='+cls_type+'&ITEM_CLS='+item_cls, function() {
        EVF.C('ITEM_CLS'+ cls_type ).setOptions(this.getParameter("item_cls"));
      });
    }

    function clearX( cls_typef ) {
      EVF.C('ITEM_CLS'+ cls_typef ).setOptions( JSON.parse('[]') );
    }

  </script>

  <e:window id="DH0521" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
        <%--차종--%>
        <e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
        <e:field>
          <e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${matCdOptions}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
        </e:field>
        <%--품번--%>
        <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
        <e:field>
          <e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
        </e:field>
        <%--품명--%>
        <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
        <e:field>
          <e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
        </e:field>
      </e:row>
      <e:row>
        <%--품목분류--%>
        <e:label for="ITEM_CLS" title="${form_ITEM_CLS_N}" />
        <e:field colSpan="3">
          <e:select id="ITEM_CLS1" name="ITEM_CLS1" data="2" onChange="getitem_cls" value="${form.ITEM_CLS}" options="${refITEM_CLASS1 }" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
          <e:text>&nbsp;</e:text>
          <e:select id="ITEM_CLS2" name="ITEM_CLS2" data="3" onChange="getitem_cls" value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
          <e:text>&nbsp;</e:text>
          <e:select id="ITEM_CLS3" name="ITEM_CLS3" data="4" value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
<%--
          <e:text>&nbsp;</e:text>
          <e:select id="ITEM_CLS4" name="ITEM_CLS4" value="${form.ITEM_CLS}" options="" width="${inputTextWidth}" disabled="${form_ITEM_CLS_D}" readOnly="${form_ITEM_CLS_RO}" required="${form_ITEM_CLS_R}" placeHolder="" />
 --%>
        </e:field>

        <e:field colSpan="2" />
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doSelect" name="doSelect" label="${doSelect_N}" onClick="doSelect" disabled="${doSelect_D}" visible="${doSelect_V}"/>
      <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>