<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : DH0580(품목-사급품매핑)
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
    var baseUrl = "/eversrm/master/bom/DH0580";
    var selRow;
	var currrow;

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
      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
    	  if (celname=='ITEM_CD') {
        	  currrow = rowid;
    	        var param = {
    	                callBackFunction: 'selectItemCd2'
    	              };
    	              everPopup.openCommonPopup(param, 'SP0018');
    	  }

    	  if (celname=='CM_ITEM_CD') {
        	  currrow = rowid;
  	        var param = {
	                callBackFunction: 'selectItemCd3'
	              };
	              everPopup.openCommonPopup(param, 'SP0018');
    	  }

    	  if (celname=='VENDOR_CD') {
    		  currrow = rowid;
    	    	everPopup.openCommonPopup({
    	            callBackFunction: "selectVendor"
    	        }, 'SP0013');
    	  }

    	  if (celname=='CM_VENDOR_CD') {
    		  currrow = rowid;
    	    	everPopup.openCommonPopup({
    	            callBackFunction: "selectVendor2"
    	        }, 'SP0013');
    	  }

      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
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
    }


    function selectVendor2(data) {
        grid.setCellValue(currrow,'CM_VENDOR_CD', data['VENDOR_CD'] );
        grid.setCellValue(currrow,'CM_VENDOR_NM', data['VENDOR_NM'] );
    }
    function selectVendor(data) {
        grid.setCellValue(currrow,'VENDOR_CD', data['VENDOR_CD'] );
        grid.setCellValue(currrow,'VENDOR_NM', data['VENDOR_NM'] );
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

    function searchITEM_CD() {
        var param = {
          callBackFunction: 'selectItemCd'
        };
        everPopup.openCommonPopup(param, 'SP0018');
      }

      function selectItemCd(data) {
        EVF.getComponent('ITEM_CD').setValue(data.ITEM_CD);
        EVF.getComponent('ITEM_NM').setValue(data.ITEM_DESC);
      }

      function selectItemCd2(data) {
  	  	if (grid.getCellValue(currrow,'CM_ITEM_CD') == data.ITEM_CD) {
			alert('${DH0580_001}');
	  		return;
	  	}
      	grid.setCellValue(currrow,'ITEM_CD',data.ITEM_CD);
      	grid.setCellValue(currrow,'ITEM_NM',data.ITEM_DESC);
      }

      function selectItemCd3(data) {

    	  	if (grid.getCellValue(currrow,'ITEM_CD') == data.ITEM_CD) {
				alert('${DH0580_002}');
    	  		return;
    	  	}

        	grid.setCellValue(currrow,'CM_ITEM_CD',data.ITEM_CD);
          	grid.setCellValue(currrow,'CM_ITEM_NM',data.ITEM_DESC);
      }


    </script>

  <e:window id="DH0580" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
        <e:field>
        <e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
        </e:field>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
		<e:text>&nbsp;</e:text>
		<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="${inputTextWidth}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
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