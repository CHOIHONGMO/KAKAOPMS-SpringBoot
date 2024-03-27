<%--
  Date: 2015/12/01
  Time: 11:09:11
  Scrren ID : DH1570
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/statistic/DH1570";
    var selRow;

    function init() {

      grid = EVF.getComponent('grid');
     // grid.setProperty("shrinkToFit", true);

     EVF.getComponent('PLANT_CD').setValue('1100');

      //grid Column Head Merge
      grid.setProperty('multiselect', true);

      // Grid AddRow Event
     // grid.addRowEvent(function() {
     //   grid.addRow();
     // });

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

        if (celName == 'ITEM_CD') {

            var param = {
              'gate_cd': '${ses.gateCd}',
              'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD')
            };k;

            everPopup.openPopupByScreenId('BBM_040', 1200, 600, param);
          }

      });

      if(${_gridType eq "RG"}) {
          grid.setColGroup([{
              "groupName": '<table style="position:relative;left:0px;top:0px;width:100%;" >'+
              '<tr><th  id="h0" colspan="24" style="border-bottom:1px solid #d3d3d3;">${DH1570_HEADER01}</th></tr>'+
              '<tr>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">01월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">02월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">03월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">04월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">05월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">06월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">07월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">08월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">09월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">10월</th>'+
              '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">11월</th>'+
              '<th  name="h01" colspan="2" style="border-right:0px solid #d3d3d3;">12월</th>'+
              '</tr>'+
              '</table>',
              "columns": [ "PLAN01_QT","RESULT01_QT","PLAN02_QT","RESULT02_QT","PLAN03_QT","RESULT03_QT",
                  "PLAN04_QT","RESULT04_QT","PLAN05_QT","RESULT05_QT","PLAN06_QT","RESULT06_QT",
                  "PLAN07_QT","RESULT07_QT","PLAN08_QT","RESULT08_QT","PLAN09_QT","RESULT09_QT",
                  "PLAN10_QT","RESULT10_QT","PLAN11_QT","RESULT11_QT","PLAN12_QT","RESULT12_QT" ]
          }, {
              "groupName": '${DH1570_HEADER02}',
              "columns": [ "PLAN_QT_SUM", "RESULT_QT_SUM" ]
          }])

      } else {
          grid.setGroupCol(
                  [
                      {'colName' : 'PLAN01_QT', 'colIndex' : 24, 'titleText' : '<table style="position:relative;left:0px;top:0px;width:100%;" >'+
                      '<tr><th  id="h0" colspan="24" style="border-bottom:1px solid #d3d3d3;">${DH1570_HEADER01}</th></tr>'+
                      '<tr>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">01월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">02월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">03월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">04월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">05월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">06월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">07월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">08월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">09월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">10월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:1px solid #d3d3d3;">11월</th>'+
                      '<th  name="h01" colspan="2" style="border-right:0px solid #d3d3d3;">12월</th>'+
                      '</tr>'+
                      '</table>'
                      }
                      ,{'colName' : 'PLAN_QT_SUM', 'colIndex' : 2, 'titleText' : '${DH1570_HEADER02}','merge':'true'}
                  ]
          );
      }

/*       $("#h0").css({
          borderBottomWidth: "1px",
          borderBottomColor: "#c5dbec", // the color from jQuery UI which you use
          borderBottomStyle: "solid",
          padding: "0px 0 0px 0"
      });
      $("th[name=h01]").css({
          borderRightWidth: "1px",
          borderRightColor: "#c5dbec", // the color from jQuery UI which you use
          borderRightStyle: "solid",
          padding: "0px 0 0px 0"
      }); */



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
      });
    }

    <%-- 저장 --%>
    function doSave() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;
      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!grid.validate().flag) { return alert(grid.validate().msg); }

      grid.checkAll(true);

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }


    <%-- 삭제 --%>
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

    <%-- 품번검색 --%>
    function onItemNoPop() {
    	var param = {
                ITEM_CD: EVF.C("ITEM_CD").getValue()
                , callBackFunction: 'selectItemF'
            };
    		everPopup.openCommonPopup(param,"SP0018");
    }
    function selectItemF(dataJsonArray) {
    	EVF.getComponent("ITEM_CD").setValue(dataJsonArray.ITEM_CD);
        EVF.getComponent("ITEM_NM").setValue(dataJsonArray.ITEM_DESC);
        EVF.getComponent("ITEM_SPEC").setValue(dataJsonArray.SPEC);
    }


    <%-- 품목 가져오기 --%>
    function onItemPop() {
    	if( EVF.C("PLANT_CD").getValue()=="") {
			alert("${DH1570_SELECT_PLANT}");
			EVF.C("PLANT_CD").setFocus();
			return;
		}
    	var param = {
                  callBackFunction: 'selectItemG'
                , SCREEN_OPEN_TYPE : 'RFQ'
            };
    	everPopup.openItemCatalogPopup(param);
    }
    function selectItemG(dataJsonArray) {
    	var existUser = true;
    	var resultData = [];
        selectedData = JSON.parse(dataJsonArray);
        for(var x in selectedData) {
        	var msg = "";
        	for (var i = 0, length = grid.getRowCount(); i < length; i++) {
                if ( grid.getCellValue(i,"PLAN_YEAR") == EVF.getComponent("PLAN_YEAR").getValue()  && grid.getCellValue(i,"PLANT_CD") == selectedData[x]['PLANT_CD']  && grid.getCellValue(i,"ITEM_CD") == selectedData[x]['ITEM_CD'] ) {
    				existUser = false;
                }
    	    }
            var data = {};
	    	data['PLAN_YEAR']	= EVF.getComponent("PLAN_YEAR").getValue();
 	    	data['PLANT_CD']		= EVF.getComponent("PLANT_CD").getValue();
            data['ITEM_CD'] 			= selectedData[x]['ITEM_CD'];
            data['ITEM_NM'] 		= selectedData[x]['ITEM_DESC'];
            data['ITEM_SPEC'] 		= selectedData[x]['ITEM_SPEC'];
            data['UNIT'] 					= selectedData[x]['UNIT_CD'];
            data['DEL_FLAG']		= '0';
            data['BUYER_CD']		= '${ses.companyCd}';
            data['CHANGE_PERIOD']			= '';
            data['YEAR_CHANGE_QT']		= '';
            data['PLAN01_QT']				= '';
            data['RESULT01_QT']		= '';
            data['PLAN02_QT']				= '';
            data['RESULT02_QT']		= '';
            data['PLAN03_QT']				= '';
            data['RESULT03_QT']		= '';
            data['PLAN04_QT']				= '';
            data['RESULT04_QT']		= '';
            data['PLAN05_QT']				= '';
            data['RESULT05_QT']		= '';
            data['PLAN06_QT']				= '';
            data['RESULT06_QT']		= '';
            data['PLAN07_QT']			= '';
            data['RESULT07_QT']		= '';
            data['PLAN08_QT']				= '';
            data['RESULT08_QT']		= '';
            data['PLAN09_QT']				= '';
            data['RESULT09_QT']		= '';
            data['PLAN10_QT']				= '';
            data['RESULT10_QT']		= '';
            data['PLAN11_QT']				= '';
            data['RESULT11_QT']			= '';
            data['PLAN12_QT']				= '';
            data['RESULT12_QT']			= '';
            data['PLAN_QT_SUM']		= '';
            data['RESULT_QT_SUM']	= '';
            data['REG_USER_NM']		= '';
            data['REG_DATE']				= '';

            if(existUser) {
            	resultData.push(data);
            }
        }

        grid.addRow(resultData);

    }

    function doSelectItem() {
    	onItemPop('grid');
    }

    <%-- 등록자 --%>
    function onRegUserPop() {
        var param = {
            GATE_CD:  '${ses.gateCd}'
            , callBackFunction: 'selectUser'
        };
		everPopup.openCommonPopup(param,"SP0001");
    }
    function selectUser(dataJsonArray) {
        EVF.getComponent("REG_USER_ID").setValue(dataJsonArray.USER_NM);
    }

  </script>

  <e:window id="DH1570" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>

		<%-- 년도 --%>
        <e:label for="PLAN_YEAR" title="${form_PLAN_YEAR_N}"/>
		<e:field>
		<e:select id="PLAN_YEAR" name="PLAN_YEAR" value="${PLAN_YEAR}" options="${planYearOptions}" width="${inputTextWidth}" disabled="${form_PLAN_YEAR_D}" readOnly="${form_PLAN_YEAR_RO}" required="${form_PLAN_YEAR_R}" placeHolder="" />
		</e:field>

		<%-- 플랜트 --%>
		<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		<e:field>
		<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
		</e:field>

		<%-- 품번 --%>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:search id="ITEM_CD" style="${imeMode}" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'onItemNoPop'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
		</e:field>

      </e:row>
      <e:row>

		<%-- 품명 --%>
		<e:label for="ITEM_NM" title="${form_ITEM_NM_N}"/>
		<e:field>
		<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="${inputTextWidth}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
		</e:field>

		<%-- 규격 --%>
		<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
		<e:field>
		<e:inputText id="ITEM_SPEC" style="${imeMode}" name="ITEM_SPEC" value="${form.ITEM_SPEC}" width="${inputTextWidth}" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}"/>
		</e:field>

		<%-- 등록자 --%>
		<e:label for="REG_USER_ID" title="${form_REG_USER_ID_N}"/>
		<e:field>
		<e:search id="REG_USER_ID" style="ime-mode:inactive" name="REG_USER_ID" value="" width="${inputTextWidth}" maxLength="${form_REG_USER_ID_M}" onIconClick="${form_REG_USER_ID_RO ? 'everCommon.blank' : 'onRegUserPop'}" disabled="${form_REG_USER_ID_D}" readOnly="${form_REG_USER_ID_RO}" required="${form_REG_USER_ID_R}" />
		</e:field>

      </e:row>
    </e:searchPanel>

    <e:buttonBar width="100%" align="right">

      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doSelectItem" name="doSelectItem" label="${doSelectItem_N}" onClick="doSelectItem" disabled="${doSelectItem_D}" visible="${doSelectItem_V}"/>
      <e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
      <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>

    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
