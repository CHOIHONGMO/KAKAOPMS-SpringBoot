<%--
  Created by IntelliJ IDEA.
  User: JYP
  Date: 2015-05-18
  Time: 오후 1:44
  Scrren ID : DH1620(품목-사급품매핑)
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
    var baseUrl = "/eversrm/statistic/DH1620";
    var selRow;
	var currrow;

    function init() {

      grid = EVF.getComponent('grid');
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

      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {




      });
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

    	if(!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if(!grid.validate().flag) { return alert(grid.validate().msg); }

        var selectedRow = grid.getSelRowValue();
        for (var k = 0; k < selectedRow.length; k++) {
        	if(!isValidDate(selectedRow[k].SALES_YM +'01'  )   ) {
        		return;
        	}
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




    function isValidDate(dateStr) {

        var year = Number(dateStr.substr(0,4));
        var month = Number(dateStr.substr(4,2));
        var day = Number(dateStr.substr(6,2));
        if (month < 1 || month > 12) { // check month range
         alert("Month must be between 1 and 12.       ");
         return false;
        }

        if (day < 1 || day > 31) {
         alert("Day must be between 1 and 31.       ");
         return false;
        }

        if ((month==4 || month==6 || month==9 || month==11) && day==31) {
         alert("Month "+month+" doesn't have 31 days!       ");
         return false
        }

        if (month == 2) { // check for february 29th
         var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
         if (day>29 || (day==29 && !isleap)) {
          alert("February " + year + " doesn't have " + day + " days!       ");
          return false;
         }
        }

        return true;
       }



    </script>

  <e:window id="DH1620" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="true" onEnter="doSearch">
      <e:row>

		<e:label for="START_DATE" title="${form_START_DATE_N}"/>
		<e:field>
		<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
		</e:field>

        <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
        <e:field>
        <e:select id="PLANT_CD" name="PLANT_CD" useMultipleSelect="true" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
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