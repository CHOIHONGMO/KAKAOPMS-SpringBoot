<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script src="/js/nicednb/aes.js"></script>
  <script src="/js/nicednb/AesUtil.js"></script>
  <script src="/js/nicednb/pbkdf2.js"></script>
  <script>
	  var grid;
	  var gridT;
	  var baseUrl = "/eversrm/master/bom/DH0590";
	  var selRow;

	  function init() {
		  gridT = EVF.getComponent('gridT');
		  grid = EVF.getComponent('grid');
		  gridT.setProperty('panelVisible', ${panelVisible});
		  grid.setProperty('panelVisible', ${panelVisible});
		  // Grid Excel Event
		  gridT.excelExportEvent({
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
      grid.setProperty('panelVisible', ${panelVisible});
      gridT.setProperty('panelVisible', ${panelVisible});
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

		  gridT.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
			  if (celname == "VENDOR_NM") {
				  if (gridT.getCellValue(rowid, "VENDOR_CD") != '') {
					  var param = {
						  VENDOR_CD: gridT.getCellValue(rowid, "VENDOR_CD"),
						  detailView: true
					  };
					  everPopup.openSupManagementPopup(param);
				  }
			  }
		  });

		  grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
			  if (celname=='AFTER_SCRAP_PRC') {
				  changeScr(rowid)
			  }
		  });

		  if(${_gridType eq "RG"}) {
			  grid.setColGroup([{
				  "groupName": '${form_TEXT1_N}',
				  "columns": [ "MAT_NM", "SPEC", "MAT_KIND", "WEIGHT", "THICK", "WIDTH", "HEIGHT" ]
			  }, {
				  "groupName": '${form_TEXT2_N}',
				  "columns": [ "BL_WIDTH", "BL_HEIGHT" ]
			  }, {
				  "groupName": '${form_TEXT3_N}',
				  "columns": [ "PREV_MAT_PRC", "AFTER_MAT_PRC" ]
			  }, {
				  "groupName": '${form_TEXT4_N}',
				  "columns": [ "PREV_SCRAP_PRC", "AFTER_SCRAP_PRC" ]
			  }, {
				  "groupName": '${form_TEXT5_N}',
				  "columns": [ "BEFORE_JERUBI", "AFTER_JERUBI" ]
			  }, {
				  "groupName": '${form_TEXT6_N}',
				  "columns": [ "PRE_CM_PRC", "CM_PRC" ]
			  }]);
		  } else {
			  grid.setGroupCol(
					  [
						  {'colName' : 'MAT_NM', 'colIndex' : 7, 'titleText' : '${form_TEXT1_N}'}
						  ,{'colName' : 'BL_WIDTH', 'colIndex' : 2, 'titleText' : '${form_TEXT2_N}'}
						  ,{'colName' : 'PREV_MAT_PRC', 'colIndex' : 2, 'titleText' : '${form_TEXT3_N}'}
						  ,{'colName' : 'PREV_SCRAP_PRC', 'colIndex' : 2, 'titleText' : '${form_TEXT4_N}'}
						  ,{'colName' : 'BEFORE_JERUBI', 'colIndex' : 2, 'titleText' : '${form_TEXT5_N}'}
						  ,{'colName' : 'PRE_CM_PRC', 'colIndex' : 2, 'titleText' : '${form_TEXT6_N}'}
					  ]
			  );
		  }
	  }

	  function changeScr(iRow) {
		  var input_wgt   = grid.getCellValue(iRow,'INPUT_WGT');
		  var net_wgt     = grid.getCellValue(iRow,'NET_WGT');
		  var item_qt     = grid.getCellValue(iRow,'ITEM_QT');

		  var prev_mat_prc  = grid.getCellValue(iRow,'PREV_MAT_PRC');
		  var after_mat_prc = grid.getCellValue(iRow,'AFTER_MAT_PRC');

		  var prev_scrap_prc  = grid.getCellValue(iRow,'PREV_SCRAP_PRC');
		  var after_scrap_prc  = grid.getCellValue(iRow,'AFTER_SCRAP_PRC');

		  var unit_prc  = grid.getCellValue(iRow,'UNIT_PRC');

		  var pre_cm_prc  = grid.getCellValue(iRow,'PRE_CM_PRC');
		  var cm_prc = grid.getCellValue(iRow,'CM_PRC');

		  var before_jerubi = ((input_wgt * prev_mat_prc) - ((input_wgt - net_wgt) * prev_scrap_prc * 0.99   )) * item_qt;

		  var after_jerubi  = ((input_wgt * after_mat_prc) - ((input_wgt - net_wgt) * after_scrap_prc * 0.99   )) * item_qt;

		  grid.setCellValue(iRow,'BEFORE_JERUBI',  before_jerubi); //이전 재료비
		  grid.setCellValue(iRow,'AFTER_JERUBI',   after_jerubi);  // 변경 재료비

		  grid.setCellValue(iRow,'CONFIRM_PRC',  Number(unit_prc) + Math.round((after_jerubi - before_jerubi)*1.02) + Math.round((after_mat_prc - prev_mat_prc)*1.01)     ); // 결정단가


		  grid.setCellValue(iRow,'CHI_AMT',   Math.round((after_jerubi - before_jerubi)*1.02)  ); //차액 1.02
		  grid.setCellValue(iRow,'CHI_AMT2',  Math.round((cm_prc - pre_cm_prc)*1.01)  ); // 차액 1.01

		  var item_cd = grid.getCellValue(iRow,'ITEM_CD');
		  var plant_cd = grid.getCellValue(iRow,'PLANT_CD');

		  var type = grid.getCellValue(iRow,'TYPE');
		  var sumChi_amt =0;
		  var sumChi_amt2 =0;
		  var confirm_prc = 0;
		  for(var k=0;k<grid.getRowCount();k++) {
			  if (item_cd==grid.getCellValue(grid.getRowId(k),'ITEM_CD')
					  && type == grid.getCellValue(grid.getRowId(k),'TYPE')
					  && '2'==grid.getCellValue(grid.getRowId(k),'LEV')
			  ) {
				  sumChi_amt +=  Number(grid.getCellValue(grid.getRowId(k),'CHI_AMT'));
				  sumChi_amt2 +=  Number(grid.getCellValue(grid.getRowId(k),'CHI_AMT2'));
				  confirm_prc +=   Number(grid.getCellValue(grid.getRowId(k),'CONFIRM_PRC'));
			  }
		  }

		  for(var k=0;k<gridT.getRowCount();k++) {
			  if (item_cd==gridT.getCellValue(gridT.getRowId(k),'ITEM_CD')
					  && plant_cd==gridT.getCellValue(gridT.getRowId(k),'PLANT_CD')
			  ) {
				  gridT.setCellValue(gridT.getRowId(k),'CHI_AMT', sumChi_amt   );
				  gridT.setCellValue(gridT.getRowId(k),'CHI_AMT2', sumChi_amt2   );
				  gridT.setCellValue(gridT.getRowId(k),'CONFIRM_PRC',  Number(gridT.getCellValue(gridT.getRowId(k),'UNIT_PRC')) + sumChi_amt + sumChi_amt2    ); // 결정단가
			  }
		  }
	  }


	  // 조회
	  function doSearch() {
		  var store = new EVF.Store();

		  if(!store.validate()) return;
		  store.setGrid([grid,gridT]);
		  store.load(baseUrl+'/doSearch', function() {
			  //setCellMerge.call(grid, ['PLANT_CD','ITEM_CD'], true);
		  });
	  }

	  <%--
    function setCellMerge ( column, cellFlag ) {
        var colModel = this.jqgridObj.getColModel()
                , gridCol = this.getColId()
                , colLen = column.length
                , gridColLen = gridCol.length
                , colCnt = 0
                , cellmerge = {}
                , cellMergeCol = { 'colInfo' : [], 'cellFlag' : false }
                , that = this;

        cellFlag = this.isBoolean(cellFlag);
        if( this.isEmpty( cellFlag ) ) { alert('두번째 매개변수 값은 true 혹은 false여야 합니다.'); return; }
        if( colLen > gridColLen ) { alert('존재하는 컬럼보다 매개변수의 컬럼 갯수가 더 많습니다.'); return; }

        if( colModel.multiselect ) { colCnt++; }
        if( colModel.rownumbers ) { colCnt++; }
        while( colLen-- ) {
            gridColLen = gridCol.length;
            while( gridColLen-- ) {
                if( column[colLen] == gridCol[gridColLen] ) {
                    if( colModel.colModel[ colCnt + gridColLen ].hidden ) {
                        alert(gridCol[gridColLen] + ' 컬럼의 상태가 hidden 입니다.');
                        cellMergeCol['colInfo'] = [];
                        cellMergeCol['cellFlag'] = false;
                        return;
                    }

                    cellMergeCol['colInfo'].push( gridColLen ); break;
                }
            }
        }

        cellMergeCol['cellFlag'] = cellFlag;
        if( cellMergeCol.length == 0 ) { alert('컬럼이 존재하질 않습니다.'); return; }

        cellmerge = function( columnIdx ) {
            var gridTableObj = that.jqgridObj.getColModel()
                    , rows = $('#' + that.gridID + '_table tr[role="row"]').not(':eq(0)')
                    , frozeFlag = $('#' + that.gridID + ' #' + that.gridID + '_table_frozen tr[role="row"]').not(':eq(0)').length > 0 ? true : false
                    , tmpRow = {}
                    , tmpCell = {}
                    , rowsCnt = 0
                    , rowsLen = rows.length
                    , colLen = 0
                    , gridColLen = 0;

            if( !columnIdx['cellFlag'] ) {
                gridColLen = that.getColId();
                colLen = columnIdx['colInfo'].length;

                while( colLen-- ) {
                    $('#' + that.gridID + '_table td[aria-describedby="'+ that.gridID + '_table_' + gridColLen[columnIdx['colInfo'][colLen]] +'"]')
                            .css('display', '')
                            .attr('rowspan', '');
                }

                return;
            }

            columnIdx = that.getJsonObject(columnIdx)['colInfo'];
            gridColLen = 0;
            colLen = columnIdx.length;
            while( colLen-- ) {
                if( gridTableObj.multiselect ) { columnIdx[colLen]++; }
                if( gridTableObj.rownumbers ) { columnIdx[colLen]++; }
            }

            colLen = columnIdx.length;
            while( gridColLen < colLen ) {
                rowsCnt = 0;
                while( rowsCnt < rowsLen ) {
                    tmpRow = rows[rowsCnt];
                    tmpCell = $( $('td[role="gridcell"]', tmpRow)[ columnIdx[gridColLen] ] );

                    var nextRowCnt = rowsCnt + 1
                            , rowSpanCnt = 2;
                    while( nextRowCnt < rowsLen ) {
                        var nextRow = rows[nextRowCnt]
                                , nextCell = $( $('td[role="gridcell"]', nextRow)[ columnIdx[gridColLen] ] );

                        if( tmpCell().text() == nextCell().text() ) {
                            rowsCnt = nextRowCnt;
                            tmpCell.attr('rowspan', rowSpanCnt);
                            nextCell.css('display', 'none');

                            if( frozeFlag ) {
                                $('#' + that.gridID + ' #' + that.gridID + '_table_frozen tr[role="row"]#' + tmpRow.id).find(' td[aria-describedby=' + $(tmpCell).attr('aria-describedby') +']')
                                        .attr('rowspan', rowSpanCnt);
                                $('#' + that.gridID + ' #' + that.gridID + '_table_frozen tr[role="row"]#' + nextRow.id).find(' td[aria-describedby=' + $(nextCell).attr('aria-describedby') +']')
                                        .css('display', 'none');
                            }

                            ++rowSpanCnt;
                            nextRowCnt++;
                        } else {
                            rowsCnt = nextRowCnt - 1;
                            break;
                        }
                    }

                    rowsCnt++;
                }
                gridColLen++;
            }
        };
        cellmerge( cellMergeCol );
    }
    --%>

	  function doSearchVendor() {
		  everPopup.openCommonPopup({
			  callBackFunction: "selectVendor"
		  }, 'SP0013');
      }
      function selectVendor(data) {
		  EVF.getComponent("VENDOR_NM").setValue(data['VENDOR_NM']);
		  EVF.getComponent("VENDOR_CD").setValue(data['VENDOR_CD']);
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

	  function doApply() {
		  //if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }

		  var p_unit_price = EVF.getComponent('P_UNIT_PRICE').getValue();
		  if (p_unit_price == 0) return;

		  var selRowIds = grid.jsonToArray(grid.getSelRowId()).value;
		  for (var k = 0; k < selRowIds.length; k++) {
			  grid.setCellValue(selRowIds[k],'AFTER_SCRAP_PRC',p_unit_price);
			  changeScr(selRowIds[k])
		  }
	  }

	  function doApply2() {
		  var datea = EVF.getComponent('APPLY_DATE').getValue();
		  if(datea=='') return;
		  var selRowIds = gridT.jsonToArray(gridT.getSelRowId()).value;
		  for (var k = 0; k < selRowIds.length; k++) {
			  gridT.setCellValue(selRowIds[k],'APPLY_DATE',datea);

		  }
	  }


	  function doApply3() {
		  var datea = Number(EVF.getComponent('SALE_PER').getValue());
		  if(datea == '0' ) return;
		  var selRowIds = gridT.jsonToArray(gridT.getSelRowId()).value;
		  for (var k = 0; k < selRowIds.length; k++) {
			  var tamt  = Number(gridT.getCellValue(selRowIds[k],'UNIT_PRC'));
			  var tamtper = tamt * datea / 100;
//    		alert( tamtper)
			  gridT.setCellValue(selRowIds[k],'CONFIRM_PRC', Math.round ( tamt - tamtper )  );
		  }
	  }


	  function doExec() {
		  if(!gridT.isExistsSelRow()) { return alert("${msg.M0004}"); }
		  if(!gridT.validate().flag) {
			  alert('${msg.M0014}');
			  return false;
		  }
		  var selectedRow = gridT.getSelRowValue();
		  for(var k=0;k<selectedRow.length;k++) {
			  if (Number(selectedRow[k].CONFIRM_PRC) == 0 ) {
				  alert('${DH0590_0001}');
				  return;
			  }

		  }



		  var param = {
			  itemList: JSON.stringify(selectedRow),
			  popupFlag: true,
			  detailView: false
		  };
		  everPopup.openPopupByScreenId('DH0600', 1200, 800, param);
	  }
  </script>

  <e:window id="DH0590" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
		<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		<e:field>
		<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
		</e:field>
        <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD"/>
		</e:field>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="${inputTextWidth}" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
		<e:text>&nbsp;</e:text>
		<e:inputText id="ITEM_NM" style="${imeMode}" name="ITEM_NM" value="${form.ITEM_NM}" width="${inputTextWidth}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}"/>
		</e:field>
      </e:row>
      <e:row>
		<e:label for="MAT_CD" title="${form_MAT_CD_N}"/>
		<e:field>
		<e:select id="MAT_CD" name="MAT_CD" value="${form.MAT_CD}" options="${matCdOptions}" width="${inputTextWidth}" disabled="${form_MAT_CD_D}" readOnly="${form_MAT_CD_RO}" required="${form_MAT_CD_R}" placeHolder="" />
		</e:field>

        <e:label for="DIV" title="${form_DIV_N}"/>
        <e:field colSpan="3">
        <e:radioGroup id="radio" name="radio" disabled="" readOnly="" required="">
          <e:text>&nbsp;&nbsp;</e:text>
          <e:radio id="FRONT" name="FRONT" label="${form_FRONT_N}" value="F" checked="true"/>
          <e:text>&nbsp;&nbsp;</e:text>
          <e:radio id="BACK" name="BACK" label="${form_BACK_N}" value="B"/>
        </e:radioGroup>
        </e:field>


      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="left">
        <e:text>&nbsp;&nbsp;${form_TEXT4_N } : &nbsp;</e:text>
		<e:inputNumber id="P_UNIT_PRICE" name="P_UNIT_PRICE" value="${form.P_UNIT_PRICE}" maxValue="${form_P_UNIT_PRICE_M}" decimalPlace="${form_P_UNIT_PRICE_NF}" disabled="${form_P_UNIT_PRICE_D}" readOnly="${form_P_UNIT_PRICE_RO}" required="${form_P_UNIT_PRICE_R}" />
		<e:text>&nbsp;</e:text>
		<e:button id="doApply" name="doApply" label="${doApply_N}" onClick="doApply" disabled="${doApply_D}" visible="${doApply_V}" align="left"/>

		<e:text>&nbsp;&nbsp;${form_SALE_PER_N } : &nbsp;</e:text>
		<e:inputNumber id="SALE_PER" name="SALE_PER" value="${form.SALE_PER}" width="50" maxValue="${form_SALE_PER_M}" decimalPlace="${form_SALE_PER_NF}" disabled="${form_SALE_PER_D}" readOnly="${form_SALE_PER_RO}" required="${form_SALE_PER_R}" />
		<e:text>&nbsp;</e:text>
		<e:button id="doApply3" name="doApply3" label="${doApply3_N}" onClick="doApply3" disabled="${doApply3_D}" visible="${doApply3_V}" align="left"/>


       <e:text>&nbsp;&nbsp;${form_APPLY_DATE_N } : &nbsp;</e:text>
		<e:inputDate id="APPLY_DATE" name="APPLY_DATE" value="${form.APPLY_DATE}" width="${inputTextDate}" datePicker="true" required="${form_APPLY_DATE_R}" disabled="${form_APPLY_DATE_D}" readOnly="${form_APPLY_DATE_RO}" />
		<e:text>&nbsp;</e:text>
		<e:button id="doApply2" name="doApply2" label="${doApply2_N}" onClick="doApply2" disabled="${doApply2_D}" visible="${doApply2_V}" align="left"/>

		<e:button id="doExec" name="doExec" label="${doExec_N}" onClick="doExec" disabled="${doExec_D}" visible="${doExec_V}" align="right"/>
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}" align="right"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="gridT" name="gridT" width="100%" height="300" columnDef="${gridInfos.gridT.gridColData}"/>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="350" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>