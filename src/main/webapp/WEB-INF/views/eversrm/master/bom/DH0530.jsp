<%--
  Date: 2015/11/10
  Time: 09:52:10
  Scrren ID : DH0530(미결현황)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/master/bom/DH0530";
    var selRow;

	var setRowId;
    function init() {

      grid = EVF.getComponent('grid');
      grid.setColEllipsis (['COST_REDU_RMK'], true);
      grid.setColEllipsis (['RMK'], true);
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
        // cell 1개만 클릭 시 사용 아니면 삭제
        if(selRow == undefined) selRow = rowid;

        if (celname == "COST_REDU_RMK") {

        	setRowId = rowid;
    	    var param = {
    				  callBackFunction : 'setTextContents'
    				, CHANGE_REASON_CD : grid.getCellValue(rowid, "COST_REDU_CD")
    				, detailView : false
    			};
        	everPopup.openPopupByScreenId('DH0600ChReaCd', 650, 350, param);




        }
        if (celname == "RMK") {
        	setRowId = rowid;
    	    var param = {
    				  havePermission : true
    				, callBackFunction : 'setTextContents2'
    				, TEXT_CONTENTS : grid.getCellValue(rowid, "RMK")
                    , detailView: false
    			};
  	  		everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
        }
    	if (celname == "G_EXEC_NUM") {
    		if (grid.getCellValue(rowid, "G_EXEC_NUM") != '') {
                var param = {
                        gateCd: grid.getCellValue(rowid, "GATE_CD"),
                        EXEC_NUM: grid.getCellValue(rowid, "G_EXEC_NUM"),
    					itemList: false,
                        popupFlag: true,
                        detailView: true
                    };
                    everPopup.openPopupByScreenId('BFAR_020', 1200, 800, param);
    		}
    	}
	  	if (celname == "S_EXEC_NUM") {
    		if (grid.getCellValue(rowid, "S_EXEC_NUM") != '') {
    	        var param = {
    		            gateCd: grid.getCellValue(rowid, "GATE_CD"),
    		            EXEC_NUM: grid.getCellValue(rowid, "S_EXEC_NUM"),
    					itemList: false,
    		            popupFlag: true,
    		            detailView: true
    		        };
    		        everPopup.openPopupByScreenId('DH0540', 1200, 800, param);
    		}
		}
	  	if (celname == "U_EXEC_NUM") {
    		if (grid.getCellValue(rowid, "U_EXEC_NUM") != '') {
    	        var param = {
    		            gateCd: grid.getCellValue(rowid, "GATE_CD"),
    		            EXEC_NUM: grid.getCellValue(rowid, "U_EXEC_NUM"),
    					itemList: false,
    		            popupFlag: true,
    		            detailView: true
    		        };
    		        everPopup.openPopupByScreenId('DH0550', 1200, 800, param);
    		}
		}
	  	if (celname == "VENDOR_NM") {
    		if (grid.getCellValue(rowid, "VENDOR_CD") != '') {
                var param = {
                        VENDOR_CD: grid.getCellValue(rowid, "VENDOR_CD"),
                        detailView: true
                    };
                    everPopup.openSupManagementPopup(param);
    		}
		}
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
			var estimate_prc = grid.getCellValue(rowid,'ESTIMATE_PRC');
			var gaunit_prc = grid.getCellValue(rowid,'GAUNIT_PRC');
			var dely_basic_qt = grid.getCellValue(rowid,'DELY_BASIC_QT');
		if (celname=='ESTIMATE_PRC' || celname=='DELY_BASIC_QT') {
			grid.setCellValue(rowid,'CHA_PRC', estimate_prc-gaunit_prc );
			grid.setCellValue(rowid,'RETRO_AMT', (estimate_prc-gaunit_prc)*dely_basic_qt );
		}
      });

      EVF.getComponent('USE_FLAG').setValue("1");
    }
	function setTextContents(codes,texts) {
		grid.setCellValue(setRowId, "COST_REDU_CD",codes);
		grid.setCellValue(setRowId, "COST_REDU_RMK",texts);
	}
	function setTextContents2(tests) {
		grid.setCellValue(setRowId, "RMK",tests);
	}

    // 조회
    function doSearch() {
      var store = new EVF.Store();

      // form validation Check
      if(!store.validate()) return;



      if (
    		  EVF.getComponent('PART_PROJ_NO').getValue() == ''
    		  && EVF.getComponent('PLANT_CD').getValue() == ''
      ) {
    	  alert('${DH0530_009}');
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
        EVF.getComponent('ITEM_DESC').setValue(data.ITEM_DESC);
      }

      function doSearchVendor() {
      	everPopup.openCommonPopup({
              callBackFunction: "selectVendor"
          }, 'SP0013');
      }
    function selectVendor(data) {
          EVF.getComponent("VENDOR_NM").setValue(data['VENDOR_NM']);
          EVF.getComponent("VENDOR_CD").setValue(data['VENDOR_CD']);
      }
    function doSave() {
          if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
          if (!grid.validate().flag) { return alert("${msg.M0014}"); }

          var selRows = grid.getSelRowValue();
		  for( var i = 0; i < selRows.length; i++ ) {
				if (selRows[i].PROGRESS_CD == 'NP') {
					alert('${DH0530_002}');
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

      function doChangeMode() {
          if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }


          var selRows = grid.getSelRowValue();
          for( var i = 0; i < selRows.length; i++ ) {
				if (selRows[i].PROGRESS_CD == 'NP') {
					alert('${DH0530_002}');
					return;
				}
				if (selRows[i].PROGRESS_CD == 'DP') {
					alert('${DH0530_005}');
					return;
				}
          }

          if(!confirm('${DH0530_001}')) { return; }
          var store = new EVF.Store();
          store.setGrid([grid]);
          store.getGridData(grid, 'sel');
          store.load(baseUrl+'/doChangeMode', function() {
            alert(this.getResponseMessage());
            doSearch();
          });
        }

      function doGa() {
          if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
          if (!grid.validate().flag) { return alert("${msg.M0014}"); }
          var selRows = grid.getSelRowValue();
		  for( var i = 0; i < selRows.length; i++ ) {
				if (selRows[i].PROGRESS_CD == 'NP') {
					alert('${DH0530_002}');
					return;
				}
				if (selRows[i].PROGRESS_CD == 'CP') {
					alert('${DH0530_003}');
					return;
				}

				if (selRows[i].EXEC_EXIST_YN == 'Y') {
					alert('${DH0530_008}');
					return;
				}


		  }

          var selectedRow = grid.getSelRowValue();
  		  var param = {
  			    itemList: JSON.stringify(selectedRow),
  	            popupFlag: true,
  	            detailView: false
  	      };
  	      everPopup.openPopupByScreenId('DH0540', 1200, 800, param);
      }

      function doJung() {
          if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
          if (!grid.validate().flag) { return alert("${msg.M0014}"); }
  		  var selRows = grid.getSelRowValue();
		  for( var i = 0; i < selRows.length; i++ ) {
  				if (selRows[i].PROGRESS_CD == 'NP') {
  					alert('${DH0530_002}');
  					return;
  				}
				if (selRows[i].EXEC_EXIST_YN == 'Y') {
					alert('${DH0530_008}');
					return;
				}

		  }
          var selectedRow = grid.getSelRowValue();
  		  var param = {
  			    itemList: JSON.stringify(selectedRow),
  	            popupFlag: true,
  	            detailView: false
  	      };
  	      everPopup.openPopupByScreenId('DH0550', 1200, 800, param);
      }

  </script>

  <e:window id="DH0530" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
      <e:row>
        <%--차종--%>
        <e:label for="PART_PROJ_NO" title="${form_PART_PROJ_NO_N}"/>
        <e:field>
          <e:select id="PART_PROJ_NO" name="PART_PROJ_NO" value="${form.PART_PROJ_NO}" options="${partProjNoOptions}" width="${inputTextWidth}" disabled="${form_PART_PROJ_NO_D}" readOnly="${form_PART_PROJ_NO_RO}" required="${form_PART_PROJ_NO_R}" placeHolder="" />
        </e:field>
		<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		<e:field>
		<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="${inputTextWidth}" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
		</e:field>
		<e:label for="BASE_DATE" title="${form_BASE_DATE_N}"/>
		<e:field>
		<e:inputDate id="BASE_DATE" name="BASE_DATE" value="${defaultBaseDate}" width="${inputTextDate}" datePicker="true" required="${form_BASE_DATE_R}" disabled="${form_BASE_DATE_D}" readOnly="${form_BASE_DATE_RO}" />
		</e:field>
      </e:row>
      <e:row>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:search id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="" width="40%" maxLength="${form_ITEM_CD_M}" onIconClick="${form_ITEM_CD_RO ? 'everCommon.blank' : 'searchITEM_CD'}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
		<e:text>&nbsp;</e:text>
		<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="55%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
		</e:field>

		<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
		<e:field>
		<e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'doSearchVendor'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
		<e:text>&nbsp;</e:text>
		<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="55%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
		</e:field>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
		</e:field>
      </e:row>
        <e:label for="USE_FLAG" title="${form_USE_FLAG_N}"/>
        <e:field colSpan="5">
          <e:select id="USE_FLAG" name="USE_FLAG" value="${form.USE_FLAG}" options="${useFlagOptions}" width="${inputTextWidth}" disabled="${form_USE_FLAG_D}" readOnly="${form_USE_FLAG_RO}" required="${form_USE_FLAG_R}" placeHolder="" />
        </e:field>
      <e:row>
      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
		<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
		<e:button id="doChangeMode" name="doChangeMode" label="${doChangeMode_N}" onClick="doChangeMode" disabled="${doChangeMode_D}" visible="${doChangeMode_V}"/>
		<e:button id="doGa" name="doGa" label="${doGa_N}" onClick="doGa" disabled="${doGa_D}" visible="${doGa_V}"/>
		<e:button id="doJung" name="doJung" label="${doJung_N}" onClick="doJung" disabled="${doJung_D}" visible="${doJung_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>