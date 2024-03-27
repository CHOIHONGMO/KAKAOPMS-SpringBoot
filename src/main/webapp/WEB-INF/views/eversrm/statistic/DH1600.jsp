<%--
  Date: 2015/12/01
  Time: 11:18:31
  Scrren ID : DH1600
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/statistic/DH1600";
    var selRow;
	var currRow;
    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", false);

      <%--grid Column Head Merge --%>
      grid.setProperty('multiselect', true);

      <%-- Grid AddRow Event--%>
      grid.addRowEvent(function() {
        grid.addRow();
      });

      <%-- Grid Excel Event--%>
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
        <%-- cell one click--%>
        currRow = rowId;
        if(selRow == undefined) selRow = rowId;

        switch (celName) {
        <%-- 20151207 품명 검색기능 삭제
		case "ITEM_DESC":
			everPopup.openCommonPopup({
	            callBackFunction: "selectItem"
	        }, 'SP0018');
			break;
		--%>
		case "VENDOR_NM":
			everPopup.openCommonPopup({
	            callBackFunction: "selectVendorGrid"
	        }, 'SP0013');
			break;
		default:
			break;
		}

      });

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});

      grid.excelExportEvent({
			allCol : "${excelExport.allCol}",
			selRow : "${excelExport.selRow}",
			fileType : "${excelExport.fileType }",
			fileName : "${screenName }",
		    excelOptions : {
				 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
				,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
				,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
				,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
		        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
		    }
		});



    }


    <%-- Search --%>
    function doSearch() {
      var store = new EVF.Store();

      <%-- form validation Check--%>
      <%--if(!store.validate()) return;--%>

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    <%-- Save--%>
    function doSave() {
      var store = new EVF.Store();

      <%-- form validation Check--%>
      if(!store.validate()) return;
      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!grid.validate().flag) { return alert(grid.validate().msg); }

      var selRowId = grid.jsonToArray(grid.getSelRowId()).value;

  	  for(var i = 0; i<selRowId.length; i++){
  		<%-- 유효성 검사 :: ORDER NO, NO,  --%>
  		var order_no	= grid.getCellValue(selRowId[i],'ORDER_NO');
  		var order_sq	= grid.getCellValue(selRowId[i],'ORDER_SQ');

  		if(order_no == '' 	|| order_no == null)	{alert("${DH1600_validateate}"); return;}
  		if(order_sq == '' 	|| order_sq == null)	{alert("${DH1600_validateate}"); return;}

  	    for(var j = 0; j<grid.getRowCount(); j++){
  		  if(order_no == grid.getCellValue(j, 'ORDER_NO') && order_sq == grid.getCellValue(j, 'ORDER_SQ') && selRowId[i] != j ){
  			  alert("${DH1600_sameSeq} :: ROW="+selRowId[i]+" ROW="+j);
  			  return;
  		  }
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


    <%-- Delete--%>
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

    <%-- 협력회사 명 검색 --%>
	function SEARCH_VENDOR(){
		var param = {
	    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0013');
	}
	function selectVendor(param){
    	EVF.getComponent("VENDOR_NM").setValue(param.VENDOR_NM);
    	EVF.getComponent("VENDOR_CD").setValue(param.VENDOR_CD);
    }
	function selectItem(param) {<%--20151207 품명 검색기능 삭제--%>
    	grid.setCellValue(currRow,'ITEM_DESC',param.ITEM_DESC);
    }
	function selectVendorGrid(param){
		grid.setCellValue(currRow, 'VENDOR_CD', param.VENDOR_CD);
		grid.setCellValue(currRow, 'VENDOR_NM', param.VENDOR_NM);
	}


  </script>

  <e:window id="DH1600" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
      <%-- 차종 --%>
      	<e:label for="ITEM_GROUP" title="${form_ITEM_GROUP_N}"/>
		<e:field>
		<e:select id="ITEM_GROUP" name="ITEM_GROUP" value="${form.ITEM_GROUP}" options="${itemGroupOptions}" width="${inputTextWidth}" disabled="${form_ITEM_GROUP_D}" readOnly="${form_ITEM_GROUP_RO}" required="${form_ITEM_GROUP_R}" placeHolder="" />
		</e:field>
      <%-- ITEM --%>
      	<e:label for="ORDER_NO" title="${form_ORDER_NO_N}"/>
		<e:field>
		<e:inputText id="ORDER_NO" style="ime-mode:inactive" name="ORDER_NO" value="${form.ORDER_NO}" width="${inputTextWidth}" maxLength="${form_ORDER_NO_M}" disabled="${form_ORDER_NO_D}" readOnly="${form_ORDER_NO_RO}" required="${form_ORDER_NO_R}"/>
		</e:field>
      <%-- 구분 --%>
        <e:label for="ITEM_DIV" title="${form_ITEM_DIV_N}"/>
		<e:field>
		<e:select id="ITEM_DIV" name="ITEM_DIV" value="${form.ITEM_DIV}" options="${itemDivOptions}" width="${inputTextWidth}" disabled="${form_ITEM_DIV_D}" readOnly="${form_ITEM_DIV_RO}" required="${form_ITEM_DIV_R}" placeHolder="" />
		</e:field>
      </e:row>
      <e:row>
      <%-- 품명 --%>
		<e:label for="ITEM_DETAIL_DESC" title="${form_ITEM_DETAIL_DESC_N}"/>
		<e:field>
		<e:inputText id="ITEM_DETAIL_DESC" style="${imeMode}" name="ITEM_DETAIL_DESC" value="${form.ITEM_DETAIL_DESC}" width="${inputTextWidth}" maxLength="${form_ITEM_DETAIL_DESC_M}" disabled="${form_ITEM_DETAIL_DESC_D}" readOnly="${form_ITEM_DETAIL_DESC_RO}" required="${form_ITEM_DETAIL_DESC_R}"/>
		</e:field>
      <%-- 협력회사 --%>
      	<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field colSpan="3">
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'SEARCH_VENDOR'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>
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
