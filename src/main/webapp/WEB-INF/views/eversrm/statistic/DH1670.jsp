<%--
  Date: 2016/01/14
  Time: 14:47:17
  Scrren ID : DH1670
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid1;
    var grid2;
    var grid3;
    var baseUrl = '/eversrm/statistic/DH1670';
    var selRow;

    function init() {

      grid1 = EVF.getComponent('grid1');
      grid2 = EVF.getComponent('grid2');
      grid3 = EVF.getComponent('grid3');

      grid1.setProperty('panelVisible', ${panelVisible});
      grid2.setProperty('panelVisible', ${panelVisible});
      grid3.setProperty('panelVisible', ${panelVisible});



      grid1.setProperty('multiselect', true);
      grid2.setProperty('multiselect', true);
      grid3.setProperty('multiselect', true);

      // Grid AddRow Event
      grid2.addRowEvent(function() {
        grid2.addRow();
      });

      // Grid Excel Event
      grid1.excelExportEvent({
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
      grid2.excelExportEvent({
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
      grid3.excelExportEvent({
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

      grid1.cellClickEvent(function(rowId, celName, value, rowIdx, colIdx) {
        // cell one click
        if(selRow == undefined) selRow = rowId;

        if (celName == 'multiSelect') {
          if(selRow != rowId) {
            grid1.checkRow(selRow, false);
            selRow = rowId;
          }
        }
      });
      grid1.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});

      //탭3의 그리드 컬럼 그룹화
      if(${_gridType eq "RG"}) {
        grid3.setColGroup([{
          "groupName": '${form3_TEXT1_N}',
          "columns": [ "PRE_QTY", "PRE_AMT" ]
        }, {
          "groupName": '${form3_TEXT2_N}',
          "columns": [ "NOW_QTY", "NOW_AMT" ]
        }, {
          "groupName": '${form3_TEXT3_N}',
          "columns": [ "SUM_QTY", "SUM_AMT" ]
        }]);
      } else {
        grid3.setGroupCol(
                [
                  {'colName' : 'PRE_QTY',  'colIndex': 2, 'titleText' : '${form3_TEXT1_N}'},
                  {'colName' : 'NOW_QTY',  'colIndex': 2, 'titleText' : '${form3_TEXT2_N}'},
                  {'colName' : 'SUM_QTY',  'colIndex': 2, 'titleText' : '${form3_TEXT3_N}'},
                ]
        );
      }

    }//init END....
    $(document.body).ready(function() {

      <!-- body 로딩시 상위 탭 구분. -->
      $('#tab1670').height(($('.ui-layout-center').height() - 30)).tabs({
        activate : function(event, ui) {
          <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
          $(window).trigger('resize');
        }
      });
      $('#tab1670').tabs('option', 'active', 0);
      //getContentTab('2');

      $('#tabs1670').height(($('.ui-layout-center').height() - 30)).tabs({
        activate : function(event, ui) {
          <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
          $(window).trigger('resize');
        }
      });
      $('#tabs1670').tabs('option', 'active', 0);
    });


    <%-- 첫번째 Tab Search--------------------------------------------------------------- --%>
    function doSearch1() {
      var store = new EVF.Store();
      if(!store.validate()) return;

      if(!everDate.checkTermDate('FROM_DATE','TO_DATE','${msg.M0133}')) { return; }

      store.setGrid([grid1]);
      store.load(baseUrl+'/doSearch_1', function() {
        if(grid1.getRowCount() == 0) {
          return alert('${msg.M0002}');
        } else {

          //grid1.setCellMerge.call(grid1, ['PLANT_NM'], true);
          grid1.setColMerge(['PLANT_NM']);
        }
      });
    }

    <%-- 두번째 Tab Search--------------------------------------------------------------- --%>
    function doSearch2() {
      var store = new EVF.Store();
      if(!store.validate()) return;

      store.setGrid([grid2]);
      store.load(baseUrl+'/doSearch_2', function() {
        if(grid2.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }


    <%-- 세번째 Tab Search--------------------------------------------------------------- --%>
    function doSearch3() {
      var store = new EVF.Store();
      if(!store.validate()) return;

      if(!everDate.checkTermDate('FROM_DATE3','TO_DATE3','${msg.M0133}')) { return; }

      store.setGrid([grid3]);
      store.load(baseUrl+'/doSearch_3', function() {
        if(grid3.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }


    <%-- 두번째 Tab 저장/수정--------------------------------------------------------------- --%>
    function doSave() {

      var store = new EVF.Store();
      if (!grid2.isExistsSelRow()) { return alert('${msg.M0004}'); }

      store.setGrid([grid2]);
      store.getGridData(grid2, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch2();
      });

    }


    <%-- 두번째 Tab 그래프 버튼클릭--------------------------------------------------------------- --%>
    function doView() {
      var m1 ="['1월',", m2="['2월',", m3="['3월',",m4="['4월',",m5="['5월',",m6="['6월',";
      var m7 ="['7월',", m8="['8월',", m9="['9월',",m10="['10월',",m11="['11월',",m12="['12월',";
      var cavg ="['평균',";
      var cresult = "['실적',";

      var cstr = '';  //차트에서의 항목(컬럼)
      var title ='공장별 진행율';
      var totalData = grid2.getAllRowValue();
      var czline = totalData.length-1;
      var crline = totalData.length-2;

      for(var k=1;k<totalData.length;k++) {
          cstr+=  "'"+grid2.getCellValue(k, "PLANT_NM") +"',";
          m1+= grid2.getCellValue(k, "M1")+",";
          m2+= grid2.getCellValue(k, "M2")+",";
          m3+= grid2.getCellValue(k, "M3")+",";
          m4+= grid2.getCellValue(k, "M4")+",";
          m5+= grid2.getCellValue(k, "M5")+",";
          m6+= grid2.getCellValue(k, "M6")+",";
          m7+= grid2.getCellValue(k, "M7")+",";
          m8+= grid2.getCellValue(k, "M8")+",";
          m9+= grid2.getCellValue(k, "M9")+",";
          m10+= grid2.getCellValue(k, "M10")+",";
          m11+= grid2.getCellValue(k, "M11")+",";
          m12+= grid2.getCellValue(k, "M12")+",";
         cavg+= grid2.getCellValue(k, "PLANT_AGV")+",";
         cresult+= grid2.getCellValue(k, "RESULT_RATE")+",";
      }
      //첫번째 행(목표)은 마지막에 추가
      cstr+=  "'"+grid2.getCellValue(0, "PLANT_NM") +"'";
      m1+= grid2.getCellValue(0, "M1");
      m2+= grid2.getCellValue(0, "M2");
      m3+= grid2.getCellValue(0, "M3");
      m4+= grid2.getCellValue(0, "M4");
      m5+= grid2.getCellValue(0, "M5");
      m6+= grid2.getCellValue(0, "M6");
      m7+= grid2.getCellValue(0, "M7");
      m8+= grid2.getCellValue(0, "M8");
      m9+= grid2.getCellValue(0, "M9");
      m10+= grid2.getCellValue(0, "M10");
      m11+= grid2.getCellValue(0, "M11");
      m12+= grid2.getCellValue(0, "M12");
      cavg+= grid2.getCellValue(0, "PLANT_AGV");
      cresult+= grid2.getCellValue(0, "RESULT_RATE");

      var str =m1+"],\n"+m2+"],\n"+m3+"],\n"+m4+"],\n"+m5+"],\n"+m6+"],\n"+m7+"],\n"+m8+"],\n"+m9+"],\n"+m10+"],\n"+m11+"],\n"+m12+"],\n"+cavg+"],\n"+cresult+"]\n";

      var param = {
        TITLE : title
        ,CDATA : cstr
        ,DATA : str
        ,CZLINE : czline
        ,CRLINE : crline
        ,'detailView': true
      };

      everPopup.openPopupByScreenId('DH1670_chart', 1360, 730, param);
    }

    function getContentTab(uu) {
      if (uu == '1') {
        window.scrollbars = true;
      }
      if (uu == '2') {
        window.scrollbars = true;
      }
      if (uu == '3') {
        window.scrollbars = true;
      }
    }

  </script>

  <e:window id="DH1670" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

    <div id="tabs1670" class="tab1670" style="padding: 0 !important;">
    <ul>
      <li><a href="#tab_1" onclick="getContentTab('1');">${form_TEXT1_N}</a></li>
      <li><a href="#tab_2" onclick="getContentTab('2');">${form_TEXT2_N}</a></li>
      <li><a href="#tab_3" onclick="getContentTab('3');">${form_TEXT3_N}</a></li>
    </ul>

    <div id="tab_1">
      <e:searchPanel id="form" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch1">
        <e:row>
          <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
          <e:field>
            <e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}"/>
            <e:text> ~ </e:text>
            <e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}"/>
          </e:field>
          <e:label for="PLANT_CD" title="${form_PLANT_CD_N}" />
          <e:field>
            <e:select id="PLANT_CD" name="PLANT_CD"  useMultipleSelect="true" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
          </e:field>
        </e:row>
        <e:row>
          <e:label for="CONT_USER_NM" title="${form_CONT_USER_NM_N}" />
          <e:field>
            <e:inputText id="CONT_USER_NM" style='ime-mode:inactive' name="CONT_USER_NM" value="${form.CONT_USER_NM}" width="99%" maxLength="${form_CONT_USER_NM_M}" disabled="${form_CONT_USER_NM_D}" readOnly="${form_CONT_USER_NM_RO}" required="${form_CONT_USER_NM_R}" />
          </e:field>
          <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
          <e:field>
            <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
          </e:field>
        </e:row>
      </e:searchPanel>

      <e:buttonBar align="right">
        <e:button id="doSearch1" name="doSearch1" label="${doSearch1_N}" onClick="doSearch1" disabled="${doSearch1_D}" visible="${doSearch1_V}"/>
      </e:buttonBar>
      <e:gridPanel gridType="${_gridType}" id="grid1" name="grid1" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid1.gridColData}"/>


    </div>
    <div id="tab_2">
      <e:searchPanel id="form2" title="${msg.M9999}" columnCount="2" labelWidth="${labelWidth}" onEnter="doSearch2">
        <e:row>
          <e:label for="YEAR" title="${form2_YEAR_N}"/>
          <e:field>
            <e:select id="YEAR" name="YEAR" value="${YEAR}" options="${searchYear}" width="${inputTextWidth}" disabled="${form2_YEAR_D}" readOnly="${form2_YEAR_RO}" required="${form2_YEAR_R}" placeHolder="" />
          </e:field>

          <e:label for="PLANT_CD2" title="${form2_PLANT_CD_N}" />
          <e:field>
            <e:select id="PLANT_CD2" name="PLANT_CD2"  useMultipleSelect="true" value="${form2.PLANT_CD2}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form2_PLANT_CD2_D}" readOnly="${form2_PLANT_CD2_RO}" required="${form2_PLANT_CD2_R}" placeHolder="" />
          </e:field>
        </e:row>
      </e:searchPanel>

      <e:buttonBar align="right">
        <e:button id="doSearch2" name="doSearch2" label="${doSearch2_N}" onClick="doSearch2" disabled="${doSearch2_D}" visible="${doSearch2_V}"/>
        <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
        <e:button id="doView" name="doView" label="${doView_N}" onClick="doView" disabled="${doView_D}" visible="${doView_V}"/>
      </e:buttonBar>
      <e:gridPanel gridType="${_gridType}" id="grid2" name="grid2" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid2.gridColData}"/>
    </div>
    <div id="tab_3">

      <e:searchPanel id="form3" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch3">
        <e:row>
          <e:label for="FROM_DATE3" title="${form3_FROM_DATE3_N}"/>
          <e:field>
            <e:inputDate id="FROM_DATE3" toDate="TO_DATE3" name="FROM_DATE3" value="${fromDate3}" width="${inputDateWidth}" datePicker="true" required="${form3_FROM_DATE3_R}" disabled="${form3_FROM_DATE3_D}" readOnly="${form3_FROM_DATE3_RO}"/>
            <e:text> ~ </e:text>
            <e:inputDate id="TO_DATE3" fromDate="FROM_DATE3" name="TO_DATE3" value="${toDate3}" width="${inputDateWidth}" datePicker="true" required="${form3_TO_DATE3_R}" disabled="${form3_TO_DATE3_D}" readOnly="${form3_TO_DATE3_RO}"/>
          </e:field>
          <e:label for="PLANT_CD3" title="${form3_PLANT_CD3_N}" />
          <e:field>
            <e:select id="PLANT_CD3" name="PLANT_CD3"  useMultipleSelect="true" value="${form3.PLANT_CD3}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form3_PLANT_CD3_D}" readOnly="${form3_PLANT_CD3_RO}" required="${form3_PLANT_CD3_R}" placeHolder="" />
          </e:field>
          <e:label for="PURCHASE_TYPE3" title="${form3_PURCHASE_TYPE3_N}"/>
          <e:field>
            <e:select id="PURCHASE_TYPE3" name="PURCHASE_TYPE3" value="${form3.PURCHASE_TYPE3}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form3_PURCHASE_TYPE3_D}" readOnly="${form3_PURCHASE_TYPE3_RO}" required="${form3_PURCHASE_TYPE3_R}" placeHolder="" />
          </e:field>
        </e:row>
      </e:searchPanel>

      <e:buttonBar align="right">
        <e:button id="doSearch3" name="doSearch1" label="${doSearch3_N}" onClick="doSearch3" disabled="${doSearch3_D}" visible="${doSearch3_V}"/>
      </e:buttonBar>
      <e:gridPanel gridType="${_gridType}" id="grid3" name="grid3" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid3.gridColData}"/>

    </div>
  </e:window>
</e:ui>
