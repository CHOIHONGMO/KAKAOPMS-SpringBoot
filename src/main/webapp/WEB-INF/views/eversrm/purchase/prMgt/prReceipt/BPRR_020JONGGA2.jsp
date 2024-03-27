<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
  <script src="/js/nicednb/aes.js"></script>
  <script src="/js/nicednb/AesUtil.js"></script>
  <script src="/js/nicednb/pbkdf2.js"></script>
  <script>

    var grid;
	var baseUrl = "/eversrm/purchase/prMgt/prReceipt/BPRR_020JONGGA2";
    var selRow;
	var currrow;

    function init() {
      grid = EVF.getComponent('grid');
      grid.addRowEvent(function() {
        grid.addRow();
      });

      grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
    	  if (celname == "multiSelect") {
              grid.checkAll(false);
              grid.checkRow(rowid, true);
          }
      });

      grid.cellChangeEvent(function(rowid, celname, iRow, iCol, value, oldValue) {
      });

	grid.excelExportEvent({
		allCol : "${excelExport.allCol}",
		selRow : "${excelExport.selRow}",
		fileType : "${excelExport.fileType }",
		fileName : "${screenName }",
	    excelOptions : {
			 imgWidth      : 0.12       <%-- // 이미지의 너비. --%>
			,imgHeight     : 0.26      <%-- // 이미지의 높이. --%>
			,colWidth      : 20        <%-- // 컬럼의 넓이. --%>
			,rowSize       : 500       <%-- // 엑셀 행에 높이 사이즈. --%>
	        ,attachImgFlag : false      <%-- // 엑셀에 이미지를 첨부할지에 대한 여부. true : 이미지 첨부, false : 이미지 미첨부 --%>
	    }
	});

    }

    // 조회
    function doSearch() {
      var store = new EVF.Store();
      if(!store.validate()) return;
      store.setGrid([grid]);
      store.load(baseUrl+'/doSearch', function() {
        if(grid.getRowCount() == 0) {
          return alert('${msg.M0002}');
        }
      });
    }

    function doSave() {
        if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
        if (!grid.validate().flag) { return alert(grid.validate().msg); }

		if ((grid.jsonToArray(grid.getSelRowId()).value).length > 1) {
			alert("${msg.M0006}");
			return;
		}

        if(!confirm('${msg.M0021}')) { return; }
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.getGridData(grid, 'sel');
        store.load(baseUrl+'/doSave', function() {
          alert(this.getResponseMessage());
          opener.doSearch();
          window.close();
        });
    }
	function doSearchVendor() {
		var param = {
			BUYER_CD : "${ses.companyCd}",
			callBackFunction : "_setVendor"
		};
		everPopup.openCommonPopup(param, 'SP0013');
    }
    function _setVendor(data) {
		EVF.getComponent("VENDOR_CD").setValue(data.VENDOR_CD);
		EVF.getComponent("VENDOR_NM").setValue(data.VENDOR_NM);
    }
    function getPurOrgCd() {
		alert(EVF.getComponent("BUYER_CD").getValue());
		var param = {
				'callBackFunction': 'purOrgCodeCallback',
				'detailView': false,
				BUYER_CD: EVF.getComponent("BUYER_CD").getValue(),
				PLANT_CD: EVF.getComponent("PLANT_CD").getValue()
			};
			everPopup.openCommonPopup(param, "SP0042");
	}
	function purOrgCodeCallback(data) {
		EVF.getComponent("PUR_ORG_CD").setValue(data.PUR_ORG_CD);
		EVF.getComponent("PUR_ORG_NM").setValue(data.PUR_ORG_NM);
	}
    </script>

  <e:window id="BPRR_020JONGGA2" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
    <e:searchPanel id="form" title="${msg.M9999}" labelWidth="90" width="100%" columnCount="3" useTitleBar="true" onEnter="doSearch">
      <e:row>
		<e:label for="PR_NUM" title="${form_PR_NUM_N}"/>
		<e:field>
		<e:inputText id="PR_NUM" style="ime-mode:inactive" name="PR_NUM" value="${form.PR_NUM}" width="100%" maxLength="${form_PR_NUM_M}" disabled="${form_PR_NUM_D}" readOnly="${form_PR_NUM_RO}" required="${form_PR_NUM_R}"/>
		</e:field>
		<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
		<e:field>
		<e:inputText id="SUBJECT" style="${imeMode}" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}"/>
		</e:field>
		<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
		<e:field>
		<e:select id="PLANT_CD" name="PLANT_CD" value="${form.PLANT_CD}" options="${plantCdOptions}" width="100%" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" placeHolder="" />
		<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="${form.BUYER_REQ_CD}"/>
		<e:inputHidden id="PR_SQ" name="PR_SQ" value="${form.PR_SQ}"/>
		<e:inputHidden id="PR_QT" name="PR_QT" value="${form.PR_QT}"/>
		</e:field>
      </e:row>
      <e:row>
		<e:label for="ITEM_CD" title="${form_ITEM_CD_N}"/>
		<e:field>
		<e:inputText id="ITEM_CD" style="ime-mode:inactive" name="ITEM_CD" value="${form.ITEM_CD}" width="100%" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}"/>
		</e:field>
		<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}"/>
		<e:field>
		<e:inputText id="ITEM_DESC" style="${imeMode}" name="ITEM_DESC" value="${form.ITEM_DESC}" width="100%" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}"/>
		</e:field>
		<e:label for="ITEM_SPEC" title="${form_ITEM_SPEC_N}"/>
		<e:field>
		<e:inputText id="ITEM_SPEC" style="${imeMode}" name="ITEM_SPEC" value="${form.ITEM_SPEC}" width="100%" maxLength="${form_ITEM_SPEC_M}" disabled="${form_ITEM_SPEC_D}" readOnly="${form_ITEM_SPEC_RO}" required="${form_ITEM_SPEC_R}"/>
		</e:field>
      </e:row>
      <e:row>
		<e:label for="START_DATE" title="${form_START_DATE_N}"/>
		<e:field>
		<e:inputDate id="START_DATE" name="START_DATE" value="${fromDate}" width="${inputTextDate}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
		<e:text> ~ </e:text>
		<e:inputDate id="END_DATE" name="END_DATE" value="${toDate}" width="${inputTextDate}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
		</e:field>

		<e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
		<e:field>
			<e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="100%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
		</e:field>
		<e:label for="PO_TYPE" title="${form_PO_TYPE_N}"/>
		<e:field>
		<e:select id="PO_TYPE" name="PO_TYPE" value="${form.PO_TYPE}" options="${poTypeOptions}" width="100%" disabled="${form_PO_TYPE_D}" readOnly="${form_PO_TYPE_RO}" required="${form_PO_TYPE_R}" placeHolder="" />
		</e:field>
      </e:row>
      <e:row>
      	<e:label for="PLAN_NUM" title="${form_PLAN_NUM_N}"/>
		<e:field colSpan="5">
		<e:inputText id="PLAN_NUM" style="ime-mode:inactive" name="PLAN_NUM" value="${form.PLAN_NUM}" width="${inputTextWidth}" maxLength="${form_PLAN_NUM_M}" disabled="${form_PLAN_NUM_D}" readOnly="${form_PLAN_NUM_RO}" required="${form_PLAN_NUM_R}"/>
		</e:field>
      </e:row>

    </e:searchPanel>
    <e:buttonBar width="100%" align="right">
        <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
    </e:buttonBar>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
  </e:window>
</e:ui>