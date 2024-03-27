<%--
  Date: 2015/12/16
  Time: 09:44:16
  Scrren ID : SRM_430
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script>

    var grid;
    var baseUrl = "/eversrm/srm/execEval/eval/SRM_430";
    var selRow;
    var currRow;

    function init() {

      grid = EVF.getComponent('grid');
      grid.setProperty("shrinkToFit", true);

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
          imgWidth      : 0.12,
          imgHeight     : 0.26,
          colWidth      : 20,
          rowSize       : 500,
          attachImgFlag : false
        }
      });
      grid.excelImportEvent({
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




      grid.cellClickEvent(function(rowId, celName, value, rowIdx, colIdx) {
        // cell one click
        currRow = rowId;
        if(selRow == undefined) selRow = rowId;

        if (celName == 'multiSelect') {
          if(selRow != rowId) {
            grid.checkRow(selRow, false);
            selRow = rowId;
          }
        }
        if( celName == 'VENDOR_CD'){
        	everPopup.openCommonPopup({
	            callBackFunction: "selectVendorGrid"
	        }, 'SP0013');
        }

      });

      grid.cellChangeEvent(function(rowId, colId, rowIdx, colIdx, value, oldValue) {});

      if('${param.SHORTAGE_NUM}' > ' ') {
    	  doSearch();
      }
    }

    // Search
    function doSearch() {

      var store = new EVF.Store();

      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {

        if(grid.getRowCount() == 0) {
          //return alert('${msg.M0002}');
        }
      });
    }

    // Save
    function doSave() {
   	   <%-- 날짜 체크 --%>
       if(!everDate.checkTermDate('FROM_DATE','TO_DATE','${msg.M0073}')) {
           return;
       }
      var store = new EVF.Store();
      grid.checkAll(true);
      // form validation Check
      if(!store.validate()) return;
      if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
      if (!grid.validate().flag) { return alert(grid.validate().msg); }

      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      if (!confirm("${msg.M0021}")) return;

      store.doFileUpload(function(){
		store.load(baseUrl + '/doSave', function(){
			alert(this.getResponseMessage());
			EVF.C("SHORTAGE_NUM").setValue(this.getParameter('SHORTAGE_NUM'));
			doSearch();
		});
	  });

    }


    // Delete
    function doDelete() {
    /*
      if ((grid.jsonToArray(grid.getSelRowId()).value).length == 0) {
        alert("${msg.M0004}");
        return;
      }
 */
      if (!confirm("${msg.M0013 }")) return;
	  if(EVF.C("SHORTAGE_NUM").getValue() == null || EVF.C("SHORTAGE_NUM").getValue() == ""){
		  alert("삭제할 건덕지가 없다.");
		  return;
	  }
      var store = new EVF.Store();
      store.setGrid([grid]);
      store.getGridData(grid, 'sel');
      store.load(baseUrl + '/doDelete', function(){
        alert(this.getResponseMessage());
        document.location.href = baseUrl+"/view";
      });
    }

    <%-- 관리번호 검색 : 공통팦업 --%>
    function searchNum(){
    	var param = {
            	callBackFunction : 'searchNumForm'
          	};
          	everPopup.openCommonPopup(param, 'SP0053');
    }
    function searchNumForm(data){
    	EVF.getComponent("SHORTAGE_NUM").setValue(data.SHORTAGE_NUM);
    	document.location.href = baseUrl+"/view.so?SHORTAGE_NUM="+EVF.C("SHORTAGE_NUM").getValue();
    }

    <%-- 행추가 --%>
    function addRow(){
    	grid.addRow();
    	cellEdit();
    }

    <%-- 행삭제  --%>
    function delRow(){
    	grid.delRow();
    }

    <%-- Excel Upload --%>
	function ExcelUpload() {
		grid.importFromExcel({
			'append' : true
		}, excelUploadCallBack).call(grid);
	}
	function excelUploadCallBack( msg, code ) {
	 	grid.checkAll(true);
	 	alert('${msg.M0001}');
	 	cellEdit();
 	}

	<%-- 그리드 클릭 협력회사 검색 CALLBACKFUNCTION --%>
	function selectVendorGrid(param){
		grid.setCellValue(currRow, 'VENDOR_CD', param.VENDOR_CD);
		grid.setCellValue(currRow, 'VENDOR_NM', param.VENDOR_NM);
	}
	</script>

  <e:window id="SRM_430" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
  	 <e:buttonBar width="100%" align="right">
      <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
      <e:button id="doSave"   name="doSave"   label="${doSave_N}"   onClick="doSave"   disabled="${doSave_D}"   visible="${doSave_V}"/>
      <e:button id="doDelete" name="doDelete" label="${doDelete_N}" onClick="doDelete" disabled="${doDelete_D}" visible="${doDelete_V}"/>
    </e:buttonBar>
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="100" width="100%" columnCount="2" useTitleBar="true" onEnter="doSearch">
      <e:row>
      <%-- 관리번호 --%>
        <e:label for="SHORTAGE_NUM" title="${form_SHORTAGE_NUM_N}"/>
		<e:field colSpan="3">
		<e:search id="SHORTAGE_NUM" style="ime-mode:inactive" name="SHORTAGE_NUM" value="${form.SHORTAGE_NUM }" width="${inputTextWidth}" maxLength="${form_SHORTAGE_NUM_M}" onIconClick="${form_SHORTAGE_NUM_RO ? 'everCommon.blank' : 'searchNum'}" disabled="${form_SHORTAGE_NUM_D}" readOnly="${form_SHORTAGE_NUM_RO}" required="${form_SHORTAGE_NUM_R}" />
		</e:field>

      </e:row>
      <e:row>
      <%-- 제목 --%>
        <e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
		<e:field colSpan="3">
		<e:inputText id="SUBJECT" style="ime-mode:auto" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
		</e:field>

      </e:row>
      <e:row>
      <%-- 기간 --%>
        <e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
		<e:field colSpan="3">
		<e:inputDate id="FROM_DATE" toDate="TO_DATE" name="FROM_DATE" value="${form.FROM_DATE}" width="${inputTextDate}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="TO_DATE" fromDate="FROM_DATE" name="TO_DATE" value="${form.TO_DATE}" width="${inputTextDate}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
		</e:field>

      </e:row>
      <e:row>
      <%-- 비고 --%>
        <e:label for="REMARK" title="${form_REMARK_N}"/>
		<e:field colSpan="3">
		<e:textArea id="REMARK" style="ime-mode:auto" name="REMARK" height="100px" value="${form.REMARK}" width="100%" maxLength="${form_REMARK_M}" disabled="${form_REMARK_D}" readOnly="${form_REMARK_RO}" required="${form_REMARK_R}" />
		</e:field>

      </e:row>
      <e:row>
      <%-- 등록일자 --%>
      	<e:label for="REG_DATE" title="${form_REG_DATE_N}"/>
		<e:field>
		<e:inputDate id="REG_DATE" name="REG_DATE" value="${form.REG_DATE}" width="${inputTextDate}" datePicker="true" required="${form_REG_DATE_R}" disabled="${form_REG_DATE_D}" readOnly="${form_REG_DATE_RO}" />
		</e:field>

      <%-- 등록자 --%>
        <e:label for="REG_USER_ID" title="${form_REG_USER_ID_N}"/>
		<e:field>
		<e:inputText id="REG_USER_ID" style="ime-mode:inactive" name="REG_USER_ID" value="${form.REG_USER_ID}" width="${inputTextWidth}" maxLength="${form_REG_USER_ID_M}" disabled="${form_REG_USER_ID_D}" readOnly="${form_REG_USER_ID_RO}" required="${form_REG_USER_ID_R}"/>
		<e:inputHidden id="REG_USER_NM" style="ime-mode:inactive" name="REG_USER_NM" value="${form.REG_USER_NM}"/>
		</e:field>

      </e:row>
      <e:row>
      <%-- 첨부파일 --%>
		<e:label for="ATT_FILE_NUM" title="${form_ATT_FILE_NUM_N}"/>
		<e:field colSpan="3">
			<e:fileManager id="ATT_FILE_NUM" name="ATT_FILE_NUM" fileId="${form.ATT_FILE_NUM}" readOnly="${form_ATT_FILE_NUM_RO}" downloadable="true" width="100%" bizType="EV" height="120px" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" required="" />
		</e:field>

      </e:row>
    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
    	<e:button id="addRow" name="addRow" label="${addRow_N}" onClick="addRow" disabled="${addRow_D}" visible="${addRow_V}"/>
    	<e:button id="delRow" name="delRow" label="${delRow_N}" onClick="delRow" disabled="${delRow_D}" visible="${delRow_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>
