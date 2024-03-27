<%--
  Date: 2015/12/01
  Time: 11:18:20
  Scrren ID : DH1581
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/statistic/DH1581";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("sortable", false);

      grid.setProperty("shrinkToFit", true);

      grid.setProperty('panelVisible', ${panelVisible});

      <%-- 체크박스 해제 --%>
      grid.setProperty("multiselect", false);

      EVF.getComponent('PLANT_CD').setValue('1100');

      //grid Column Head Merge
      //grid.setProperty('multiselect', true);

      // Grid AddRow Event
      <%-- /*
      grid.addRowEvent(function() {
       grid.addRow();
      });
 	*/ --%>

 		//grid.setGroupColText(0, '${DH1580_GBN}');

      // Grid Excel Event
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
        // cell one click
        if(selRow == undefined) selRow = rowId;

        if (celName == 'multiSelect') {
          if(selRow != rowId) {
            grid.checkRow(selRow, false);
            selRow = rowId;
          }
        }

      });

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});
    }

    <%-- 조회 --%>
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }

        //grid.setCellMerge.call(['TEXT2'], true);
		grid.setColMerge(['TEXT2']);
      });
    }

  </script>

  <e:window id="DH1581" onReady="init" initData="${initData}" title="" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="true" onEnter="doSearch">
      <e:row>
		<e:label for="START_DATE" title="${form_START_DATE_N}"/>
		<e:field>
			<e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${START_DATE}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
			<e:text>~&nbsp;</e:text>
			<e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${END_DATE}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
		</e:field>

		<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		<e:field >
			<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" useMultipleSelect="true" width="30%" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
		</e:field>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
