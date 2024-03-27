<%--
  Date: 2015/12/17
  Time: 10:41:09
  Scrren ID : SRM_440
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/srm/execEval/eval/SRM_440";
    var selRow;
    var currRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", false);
      grid.setProperty('panelVisible', ${panelVisible});
      <%-- grid Column Head Merge --%>
      grid.setProperty('multiselect', true);

      <%--  Grid Excel Event --%>
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
        <%--  cell one click --%>
        currRow = rowId;
        if(selRow == undefined) selRow = rowId;

        if(celName == 'VENDOR_CD') {
        	var params = {
           		VENDOR_CD      : grid.getCellValue(rowId, "VENDOR_CD")
           	   ,POPUPFLAG 	   : 'Y'
	           ,detailView     : true
               ,havePermission : false
           	};
           	everPopup.openPopupByScreenId('BBV_010', 950, 580, params);
        }
        if( celName == 'EV_PLAN_USER_NM'){
        	everPopup.openCommonPopup({
	            callBackFunction: "selectPlanUser"
	        }, 'SP0001');
        }
        if( celName == 'ATT_FILE_CNT'){
        	var param = {
					havePermission: '${!param.detailView}',
					attFileNum: grid.getCellValue(rowId, 'ATT_FILE_NUM'),
					rowId: rowId,
					callBackFunction: 'fileAttachPopupCallback',
					bizType: 'EV',
					fileExtension: '*'
				};

				everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
        }

      });

      if(${_gridType eq "RG"}) {
        grid.setColGroup([{
          "groupName": '${SRM_440_IMP_ACCPT}',
          "columns": [ "IMP_POINT", "IMP_MEASURE" ]
        }, {
          "groupName": '${SRM_440_IMP_COMPLETE}',
          "columns": [ "IMP_COMPLETE", "IMP_COMPLETE_RATE" ]
        }, {
          "groupName": '${SRM_440_VAL}',
          "columns": [ "VAL_COMPLETE", "VAL_COMPLETE_RATE", "VAL_RE_EVAL_SCORE" ]
        }]);
      } else {
        grid.setGroupCol(
          [
            {'colName' : 'IMP_POINT',       'colIndex': 2, 'titleText' : '${SRM_440_IMP_ACCPT}'},
            {'colName' : 'IMP_COMPLETE',   'colIndex': 2, 'titleText' : '${SRM_440_IMP_COMPLETE}'},
            {'colName' : 'VAL_COMPLETE',  'colIndex': 3, 'titleText' : '${SRM_440_VAL}'}
          ]
        );
      }

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});
    }


    <%--  Search --%>
    function doSearch() {
      var store = new EVF.Store();

      <%--  form validation Check --%>
      if(!store.validate()) return;

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    <%--  Save --%>
    function doSave() {
      var store = new EVF.Store();

      <%--  form validation Check --%>
      if(!store.validate()) return;
      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!grid.validate().flag) { return alert(grid.validate().msg); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;
      store.load(baseUrl + '/doSave', function() {
        alert(this.getResponseMessage());
        doSearch();
      });
    }

    <%-- 협력회사 명 검색 --%>
	function VENDOR_NM(){
		var param = {
	    		callBackFunction : 'selectVendor'
    	};
    	everPopup.openCommonPopup(param, 'SP0013');
	}
	function selectVendor(param){
    	EVF.getComponent("VENDOR_NM").setValue(param.VENDOR_NM);
    	EVF.getComponent("VENDOR_CD").setValue(param.VENDOR_CD);
    }

	<%-- 그리드 클릭 평가예정자 검색 CALLBACKFUNCTION --%>
	function selectPlanUser(param){
		grid.setCellValue(currRow, 'EV_PLAN_USER_ID', param.USER_ID);
		grid.setCellValue(currRow, 'EV_PLAN_USER_NM', param.USER_NM);
	}

	<%-- 팝업 파일첨부 --%>
	function fileAttachPopupCallback(gridRowId, fileId, fileCount) {
		grid.setCellValue(gridRowId, 'ATT_FILE_CNT', fileCount);
		grid.setCellValue(gridRowId, 'ATT_FILE_NUM', fileId);
	}

  </script>

  <e:window id="SRM_440" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
      <%-- 년도 --%>
        <e:label for="YEAR" title="${form_YEAR_N}"/>
		<e:field>
		<e:select id="YEAR" name="YEAR" value="${currYear}" options="${yearList}" width="${inputTextWidth}" disabled="${form_YEAR_D}" readOnly="${form_YEAR_RO}" required="${form_YEAR_R}" placeHolder="" />
		</e:field>

	  <%-- 협력회사명 --%>
		<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
		<e:search id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${inputTextWidth}" maxLength="${form_VENDOR_NM_M}" onIconClick="${form_VENDOR_NM_RO ? 'everCommon.blank' : 'VENDOR_NM'}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
		</e:field>
		<e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${form.VENDOR_CD}"/>

	  <%-- 진행상태 --%>
		<e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
		<e:field>
		<e:select id="PROGRESS_CD" name="PROGRESS_CD" value="${form.PROGRESS_CD}" options="${progressCdOptions}" width="${inputTextWidth}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="" />
		</e:field>

      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
