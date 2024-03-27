<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-11-02
  Scrren ID : DH0523(구매BOM현황 -> 신규생성)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0523";
    var selRow;
    var excelUpFlag = false;

    function init() {
      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", false);

      //grid Column Head Merge
      grid.setProperty('multiselect', true);

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

          excelUpFlag = true;
        }
      });

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {});

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {});

      var itemCd = EVF.getComponent('ITEM_CD').getValue();
      if (itemCd != "") {
    	  doSearch();
      }

    }

    // 조회
	function doSearch() {

    	var store = new EVF.Store();

		// form validation Check
		if(!store.validate()) return;

		var itemCd = EVF.getComponent('ITEM_CD').getValue();
		if (itemCd == "") return;

    	store.setGrid([grid]);
		store.load(baseUrl+'/doSearch', function() {
	    	excelUpFlag = false;

	    	if(grid.getRowCount() == 0) {
	          return alert('${msg.M0002}');
	        }
		});
	}

    // 저장
    function doSave() {

		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

		if (excelUpFlag) {

			if(grid.getRowCount() != 0 && EVF.getComponent('ITEM_CD').getValue() == "") {
				var allRowId = grid.getAllRowId();
				for (var i in allRowId) {
					var ri = allRowId[i];
					if (grid.getCellValue(ri, 'A') != "") {
						EVF.getComponent('ITEM_CD').setValue(grid.getCellValue(ri, 'ITEM_CD'));
						break;
					}
				}
			}

			var store = new EVF.Store();
			if(!store.validate()) { return; }
	        var valid = grid.validate();
			if (!valid.flag) {
				alert(valid.msg);
			    return;
			}
			if(!confirm('${msg.M0021}')) { return; }

			store.setGrid([grid]);
			store.getGridData(grid, 'sel');
		       store.load(baseUrl+'/doExcelUpload', function() {
		         alert(this.getResponseMessage());
		         doSearch();
		       });

		} else {

	        var valid = grid.validate();
			if (!valid.flag) {
				alert(valid.msg);
			    return;
			}
			if(!confirm('${msg.M0021}')) { return; }

 			var store = new EVF.Store();
 		    store.setGrid([grid]);
 		    store.getGridData(grid, 'sel');
 		    store.load(baseUrl+'/doSave', function() {
 		    	alert(this.getResponseMessage());
 		        doSearch();
 		    });
 		}
    }

<%--
    function doSave() {

		if(excelUpFlag) {
            return alert('${DH0523_0002}'); // 엑셀 업로드 된 상태에서는 저장할 수 없습니다.
 		}

		if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

		if(!confirm('${msg.M0021}')) { return; }

		var store = new EVF.Store();
	    store.setGrid([grid]);
	    store.getGridData(grid, 'sel');
	    store.load(baseUrl+'/doSave', function() {
	    	alert(this.getResponseMessage());
	        doSearch();
	    });
    }

	function doExcelUpload() {

       if(grid.getRowCount() != 0 && EVF.getComponent('ITEM_CD').getValue() == "") {
    		var allRowId = grid.getAllRowId();
			for (var i in allRowId) {
				var ri = allRowId[i];
				if (grid.getCellValue(ri, 'A') != "") {
					EVF.getComponent('ITEM_CD').setValue(grid.getCellValue(ri, 'ITEM_CD'));
					break;
				}
			}

		}

       if(!excelUpFlag) {
           return alert('${DH0523_0001}'); // 엑셀 업로드 된 상태에서만 저장이 가능합니다.
		}

       if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

       var store = new EVF.Store();
       if(!store.validate()) { return; }
       if(!confirm('${msg.M0021}')) { return; }

       store.setGrid([grid]);
       store.getGridData(grid, 'sel');
       store.load(baseUrl+'/doExcelUpload', function() {
         alert(this.getResponseMessage());

         excelUpFlag = false;
         doSearch();
       });
    }
--%>

    // 삭제
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

  <e:window id="DH0523" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="1" useTitleBar="true" onEnter="doSearch">
      <e:inputHidden id="flag" name="flag" value="${param.flag}"/>
      <e:row>
        <%--품번--%>
        <e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
        <e:field>
          <e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${param.ITEM_CD}" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" onClick="onClickItemCd"/>
          <e:text>&nbsp;</e:text>
          <e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${param.ITEM_DESC}" width="50%" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
        </e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${param.flag eq 'U' ? true : false}"/>
      <%--<e:button id="doExcelUpload" name="doExcelUpload" label="${doExcelUpload_N}" onClick="doExcelUpload" disabled="${doExcelUpload_D}" visible="${doExcelUpload_V}"/> --%>
      <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="true"/>
      <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${param.flag eq 'U' ? true : false}"/>
      <e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>