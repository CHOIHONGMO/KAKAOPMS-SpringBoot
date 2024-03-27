<%--
  Date: 2015/12/18
  Time: 10:36:54
  Scrren ID : SRM_251
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <style type="text/css">

        #gridTpl div label, #gridTpl div div, #gridQua div label, #gridQua div div {
            font-size: 12px !important;
        }

    </style>
  <script>

    var grid;
    var baseUrl = "/eversrm/srm/execEval/eval/SRM_251";
    var selRow;

    function init() {

      gridTpl 		= EVF.getComponent('gridTpl');
      gridQuaH 	    = EVF.getComponent('gridQuaH');
      gridQua 		= EVF.getComponent('gridQua');




      gridTpl.excelImportEvent({
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

      gridQua.excelImportEvent({
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


      gridTpl.setProperty('panelVisible', ${panelVisible});
      gridQuaH.setProperty('panelVisible', ${panelVisible});
      gridQua.setProperty('panelVisible', ${panelVisible});

      gridTpl.setProperty("shrinkToFit", true);
      gridQuaH.setProperty("shrinkToFit", true);
      gridQua.setProperty("shrinkToFit", true);

      //grid Column Head Merge
      gridTpl.setProperty('multiselect', true);
      gridQuaH.setProperty('multiselect', true);
      gridQua.setProperty('multiselect', true);

      // Grid AddRow Event
      //grid.addRowEvent(function() {
      //  grid.addRow();
      //});

      // Grid Excel Event

      gridTpl.excelExportEvent({
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

      gridQuaH.excelExportEvent({
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

      gridQua.excelExportEvent({
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

/*
      gridQua.excelExportEvent({
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
*/


      gridQuaH.cellClickEvent(function(rowId, celName, value, rowIdx, colIdx) {
        // cell one click
        if(selRow == undefined) selRow = rowId;

        if (celName == 'multiSelect') {
          if(selRow != rowId) {
            gridQuaH.checkRow(selRow, false);
            selRow = rowId;
          }

          var vendor 	= gridQuaH.getCellValue(rowId, "VENDOR_CD");
	      var ev_user 	= gridQuaH.getCellValue(rowId, "EV_USER_ID");
	      doQuaSearch(vendor, ev_user);
       }

        if( celName == 'ATT_FILE'){
        	var param = {
					havePermission: '${!param.detailView}',
					attFileNum: gridQuaH.getCellValue(rowId, 'ATT_FILE_NUM'),
					rowId: rowId,
					callBackFunction: 'fileAttachPopupCallback',
					bizType: 'EV',
					fileExtension: '*'
				};

				everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
        }

        if( celName == 'VENDOR_CD'){

        	if(selRow != rowId) {
                gridQuaH.checkRow(selRow, false);
                selRow = rowId;
              }

	        var vendor 	= gridQuaH.getCellValue(rowId, "VENDOR_CD");
	        var ev_user 	= gridQuaH.getCellValue(rowId, "EV_USER_ID");
	        doQuaSearch(vendor, ev_user);

	        gridQuaH.checkRow(rowId, true);

        }

      });


      //grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});
    }


    <%-- Save --%>
    function doTplSave() {
      var store = new EVF.Store();

      var evNum = EVF.C("EV_NUM").getValue();
      if( evNum == null || evNum == "" ) {
    	  alert("${SRM_251_EV_NUM}");<%-- 평가 번호를 입력하세요. --%>
    	  EVF.C("EV_NUM").setFocus();
    	  return;
      }
      // form validation Check
      if(!store.validate()) return;
      if (!gridTpl.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!gridTpl.validate().flag) { return alert(gridTpl.validate().msg); }

      store.setGrid([gridTpl]);
      store.getGridData(gridTpl, 'sel');

      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doTplSave', function() {
        alert(this.getResponseMessage());
        //doSearch();
      });
    }

    <%-- Excel Upload --%>
	function doExcelUpload() {
		gridTpl.importFromExcel({
			'append' : true
		}, excelUploadCallBack).call(gridTpl);
	}
	function excelUploadCallBack( msg, code ) {
	 	gridTpl.checkAll(true);
	 	alert('${msg.M0001}');
 	}

    <%-- Search --%>
    function doQuaSearchH() {
      var store = new EVF.Store();

      var evNum = EVF.C("EV_NUM").getValue();
      if( evNum == null || evNum == "" ) {
    	  alert("${SRM_251_EV_NUM}");<%-- 평가 번호를 입력하세요. --%>
    	  EVF.C("EV_NUM").setFocus();
    	  return;
      }

      // form validation Check
      if(!store.validate()) return;

      gridQua.checkAll(true);
	  gridQua.delRow();

      store.setGrid([gridQuaH]);
      store.load(baseUrl+'/doSearchQuaH', function() {
        if(gridQuaH.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    <%-- Search --%>
    function doQuaSearch(vendor, evUser) {
      var store = new EVF.Store();

      var evNum = EVF.C("EV_NUM").getValue();
      if( evNum == null || evNum == "" ) {
    	  alert("${SRM_251_EV_NUM}");<%-- 평가 번호를 입력하세요. --%>
    	  EVF.C("EV_NUM").setFocus();
    	  return;
      }

      EVF.C("VENDOR_CD").setValue(vendor);
      EVF.C("EV_USER_ID").setValue(evUser);

      // form validation Check
      if(!store.validate()) return;

      store.setGrid([gridQua]);
      store.load(baseUrl+'/doSearchQua', function() {
        if(gridQua.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    <%-- Excel Download Qua --%>
    function doExcelDownloadQua() {

    	gridQua.checkAll(true);
    	if (!gridQua.isExistsSelRow()) {
	    	  return alert('${SRM_251_EV_RESULT} ${msg.M0004}');
	      }

        	gridQua.exportFromExcel({
					allCol : false,
					excelOptions : {
						imgWidth 		: 0.1,
						imgHeight 		: 0.4,
						colWidth 		: 20,
						rowSize 		: 500,
						attachImgFlag 	: true
					}
				}).call(gridQua);
    }

    <%-- Excel Upload Qua --%>
    function doExcelUploadQua() {
    	gridQua.checkAll(true);
		gridQua.delRow();
    	gridQua.importFromExcel({
			'append' : true
		}, excelUploadQuaCallBack).call(gridTpl);
	}
	function excelUploadQuaCallBack( msg, code ) {
	 	gridQua.checkAll(true);
	 	alert('${msg.M0001}');
 	}

	<%-- 팝업 파일첨부 --%>
	function fileAttachPopupCallback(gridRowId, fileId, fileCount) {
		gridQuaH.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
		gridQuaH.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
	}

	<%-- Save Qua --%>
	function doQuaSave() {
		var store = new EVF.Store();

	      var evNum = EVF.C("EV_NUM").getValue();
	      if( evNum == null || evNum == "" ) {
	    	  alert("${SRM_251_EV_NUM}");<%-- 평가 번호를 입력하세요. --%>
	    	  EVF.C("EV_NUM").setFocus();
	    	  return;
	      }
	      // form validation Check
	      if(!store.validate()) return;

	      if (!gridQuaH.isExistsSelRow()) { return alert('${SRM_251_VENDOR} ${msg.M0004}'); }

	      var selRowId = gridQuaH.jsonToArray(gridQuaH.getSelRowId()).value;
	      for (var i = 0; i < selRowId.length; i++) {
	        	var remark	= gridQuaH.getCellValue(selRowId[i], "RMK");
	        	var att			= gridQuaH.getCellValue(selRowId[i], "ATT_FILE_CNT");

	        	if( remark == "" ) {
	        		alert("${SRM_251_MSG008}");<%--평가의견을 입력하세요.--%>
	        		return;
	        	}
	        	if( att == 0 ) {
	        		alert("${SRM_251_MSG009}");<%--파일을 첨부 하세요.--%>
	        		return;
	        	}
	      }

	      if (!gridQua.isExistsSelRow()) {
	    	  return alert('${SRM_251_EV_RESULT} ${msg.M0004}');
	      }

	      if (!gridQua.validate().flag) { return alert(gridQua.validate().msg); }

	      store.setGrid([gridQuaH,gridQua]);
	      store.getGridData(gridQuaH, 'sel');
	      store.getGridData(gridQua, 'sel');

	      if (!confirm("${msg.M0021}")) return;
	      store.load(baseUrl + '/doQuaSave', function() {
	        alert(this.getResponseMessage());

	      });
	}

    $(document.body).ready(function() {
        $('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
                {
                  activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                  }
                }
        );
        $('#e-tabs').tabs('option', 'active', 0);
        //getContentTab('1');
      });


  </script>

  <e:window id="SRM_251" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="1" useTitleBar="true" onEnter="doSearch">
      <e:row>
        <e:label for="EV_NUM" title="${form_EV_NUM_N}"/>
		<e:field>
		<e:inputText id="EV_NUM" style="ime-mode:inactive" name="EV_NUM" value="${EV_NUM}" width="${inputTextWidth}" maxLength="${form_EV_NUM_M}" disabled="${form_EV_NUM_D}" readOnly="${form_EV_NUM_RO}" required="${form_EV_NUM_R}"/>
		</e:field>
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD"/>
		<e:inputHidden id="EV_USER_ID" name="EV_USER_ID"/>
      </e:row>
    </e:searchPanel>

    <div id="e-tabs" class="e-tabs" style="padding: 0 !important;">
        <tr><td><div>
          <ul>
            <li id="tab1"><a href="#ui-tabs-1" onclick="">${SRM_251_TEMPLATE}</a></li>
            <li id="tab2"><a href="#ui-tabs-2" onclick="">${SRM_251_QUALITATIVE}</a></li>
          </ul>
		 <div id="ui-tabs-1">
			<div id="divTp" style="height: auto;">
				<e:buttonBar align="right">
				<e:button id="doTplSave" name="doTplSave" label="${doTplSave_N}" onClick="doTplSave" disabled="${doTplSave_D}" visible="${doTplSave_V}"/>
				</e:buttonBar>
				<e:gridPanel gridType="${_gridType}" id="gridTpl" name="gridTpl" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridTpl.gridColData}"/>
			</div>
		</div>
		 <div id="ui-tabs-2">
			<div id="divQua" style="height: auto;">
			    <e:br/>
				<e:buttonBar align="right">
				<e:button id="doQuaSearchH" name="doQuaSearchH" label="${doQuaSearchH_N}" onClick="doQuaSearchH" disabled="${doQuaSearchH_D}" visible="${doQuaSearchH_V}"/>
				<e:button id="doQuaSave" name="doQuaSave" label="${doQuaSave_N}" onClick="doQuaSave" disabled="${doQuaSave_D}" visible="${doQuaSave_V}"/>
				</e:buttonBar>

                <e:title title="${SRM_251_VENDOR }" />
				<e:gridPanel gridType="${_gridType}" id="gridQuaH" name="gridQuaH" height="150px" readOnly="${param.detailView}" columnDef="${gridInfos.gridQuaH.gridColData}" />

                <e:title title="${SRM_251_EV_RESULT }" />
				<e:gridPanel gridType="${_gridType}" id="gridQua" name="gridQua" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.gridQua.gridColData}"/>
			</div>
		</div>

 	</div></td></tr>
	</div>

  </e:window>
</e:ui>
