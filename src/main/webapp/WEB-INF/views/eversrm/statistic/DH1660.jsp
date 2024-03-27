<%--
  Date: 2016/01/13
  Time: 15:10:52
  Scrren ID : DH1660
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = '/eversrm/statistic/DH1660';
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty('multiselect', true);
      grid.setProperty('panelVisible', ${panelVisible});
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

      grid.cellClickEvent(function (rowid, celname, value, iRow, iCol) {
        selRow = rowid;

        switch (celname) {
          case 'CONT_NUM':  //계약번호
            everPopup.openContractChangeInformation({
              callBackFunction: 'doSearch',
              GATE_CD: grid.getCellValue(rowid, "GATE_CD"),
              contNum: grid.getCellValue(rowid, "CONT_NUM"),
              contCnt: grid.getCellValue(rowid, "CONT_CNT"),
              baseDataType: 'manualContract',
              detailView: true,
              contractEditable: false
            });
            break;

          case 'EXEC_NUM':  //품의번호
            var param = {
              gateCd: '${ses.gateCd}',
              EXEC_NUM: grid.getCellValue(rowid, "EXEC_NUM"),
              popupFlag: true,
              detailView: true
            };
            var exec_type = grid.getCellValue(rowid,'EXEC_TYPE');
            var screenId='';
            if(exec_type == "G") {
              screenId='BFAR_020';
            } else if(exec_type == "C") {
              screenId='DH0630';
            } else if(exec_type == "O") {
              screenId='DH0600';
            } else if(exec_type == "S") {
              screenId='DH0540';
            } else if(exec_type == "U") {
              screenId='DH0550';
            }
            everPopup.openPopupByScreenId(screenId, 1200, 800, param);
            break;

          case 'VENDOR_CD':  //협력회사코드
            var params = {
              VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
              paramPopupFlag: "Y",
              detailView : true
            };
            everPopup.openSupManagementPopup(params);
            break;

          default:
            return;
        }
      });

      if(${_gridType eq "RG"}) {
        grid.setColGroup([{
          "groupName": '${form_TEXT1_N}',
          "columns": [ "1C_AMT", "1C_DATE" ]
        }, {
          "groupName": '${form_TEXT2_N}',
          "columns": [ "2C_AMT", "2C_DATE" ]
        }, {
          "groupName": '${form_TEXT3_N}',
          "columns": [ "3C_AMT", "3C_DATE" ]
        }, {
          "groupName": '${form_TEXT4_N}',
          "columns": [ "4C_AMT", "4C_DATE" ]
        }, {
          "groupName": '${form_TEXT5_N}',
          "columns": [ "5C_AMT", "5C_DATE" ]
        }, {
          "groupName": '${form_TEXT6_N}',
          "columns": [ "6C_AMT", "6C_DATE" ]
        }]);
      } else {
        grid.setGroupCol(
                [
                  {'colName' : '1C_AMT',  'colIndex': 2, 'titleText' : '${form_TEXT1_N}'},
                  {'colName' : '2C_AMT',  'colIndex': 2, 'titleText' : '${form_TEXT2_N}'},
                  {'colName' : '3C_AMT',  'colIndex': 2, 'titleText' : '${form_TEXT3_N}'},
                  {'colName' : '4C_AMT',  'colIndex': 2, 'titleText' : '${form_TEXT4_N}'},
                  {'colName' : '5C_AMT',  'colIndex': 2, 'titleText' : '${form_TEXT5_N}'},
                  {'colName' : '6C_AMT',  'colIndex': 2, 'titleText' : '${form_TEXT6_N}'}
                ]
        );
      }
    }

    // Search
    function doSearch() {

      var store = new EVF.Store();
      // form validation Check
      if(!store.validate()) return;

      if(!everDate.checkTermDate('FROM_DATE','TO_DATE','${msg.M0026}')) { return; }

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });

    }

    // Save
    function doSave() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;
      if(!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if(!grid.validate().flag) { return alert(grid.validate().msg); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    // Insert
    function doInsert() {
      var store = new EVF.Store();

      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

      // Grid Validation Check
      if(!grid.validate().flag) { return alert(grid.validate().msg); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0011}")) return;
      store.load(baseUrl + '/doInsert', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    // Update
    function doUpdate() {
      var store = new EVF.Store();
      var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;

      if(selRowIds.length == 0) {
        return alert("${msg.M0004}");
      }

      // Grid Validation Check
      if(!grid.validate().flag) { return alert(grid.validate().msg); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0012}")) return;
      store.load(baseUrl + '/doUpdate', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    // Delete
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

  </script>

  <e:window id="DH1660" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch">
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
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
        <e:field>
          <e:inputText id="VENDOR_NM" style='ime-mode:active' name="VENDOR_NM" value="${form.VENDOR_NM}" width="99%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
        </e:field>
      </e:row>
      <e:row>
        <e:label for="CONT_USER_NM" title="${form_CONT_USER_NM_N}" />
        <e:field>
          <e:inputText id="CONT_USER_NM" style='ime-mode:active' name="CONT_USER_NM" value="${form.CONT_USER_NM}" width="99%" maxLength="${form_CONT_USER_NM_M}" disabled="${form_CONT_USER_NM_D}" readOnly="${form_CONT_USER_NM_RO}" required="${form_CONT_USER_NM_R}" />
        </e:field>
        <e:label for="CONT_DESC" title="${form_CONT_DESC_N}" />
        <e:field>
          <e:inputText id="CONT_DESC" style='ime-mode:active' name="CONT_DESC" value="${form.CONT_DESC}" width="99%" maxLength="${form_CONT_DESC_M}" disabled="${form_CONT_DESC_D}" readOnly="${form_CONT_DESC_RO}" required="${form_CONT_DESC_R}" />
        </e:field>
        <e:label for="PURCHASE_TYPE" title="${form_PURCHASE_TYPE_N}"/>
        <e:field>
          <e:select id="PURCHASE_TYPE" name="PURCHASE_TYPE"  useMultipleSelect="true" value="${form.PURCHASE_TYPE}" options="${purchaseTypeOptions}" width="${inputTextWidth}" disabled="${form_PURCHASE_TYPE_D}" readOnly="${form_PURCHASE_TYPE_RO}" required="${form_PURCHASE_TYPE_R}" placeHolder="" />
        </e:field>
      </e:row>
    </e:searchPanel>


    <e:buttonBar align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
    </e:buttonBar>

    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

  </e:window>
</e:ui>
