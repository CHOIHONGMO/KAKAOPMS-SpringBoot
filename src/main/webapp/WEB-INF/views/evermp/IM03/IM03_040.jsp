<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

 <script type="text/javascript">

	var grid;
	var baseUrl = "/evermp/IM03/IM0304/";

	function init(){
        grid = EVF.C("grid");
		
        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });
        
        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
        	if(colId == 'ITEM_REQ_NO') {
            	var param = {
    	    		CUST_CD : grid.getCellValue(rowId, 'CUST_CD'),
    	    		ITEM_REQ_NO : grid.getCellValue(rowId, 'ITEM_REQ_NO'),
    	    		ITEM_REQ_SEQ : grid.getCellValue(rowId, 'ITEM_REQ_SEQ'),
    	    		'detailView': true,
    	    		'popupFlag': true
    			};
                everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
            }
        	if(colId == "RE_REQ_REJECT_RMK") {
				var param = {
          				title : '반려사유',
          				message : grid.getCellValue(rowId, 'RE_REQ_REJECT_RMK'),
          				callbackFunction : 'setRejectText',
              			detailView : false,
          				rowId : rowId
          			};
        		var url = '/common/popup/common_text_input/view';
        	    everPopup.openModalPopup(url, 500, 320, param);
			}
            if(colId == 'ATTACH_FILE_NO_IMG') {
            	if( Number(grid.getCellValue(rowId, 'ATTACH_FILE_NO_IMG')) == 0 ) return;
        		everPopup.readOnlyFileAttachPopup('RE',grid.getCellValue(rowId, 'ATTACH_FILE_NO'),'',rowId);
        	}
            if(colId == "RE_REQ_REASON") {
				if( grid.getCellValue(rowId, 'RE_REQ_REASON') == '' ) return;
				var param = {
          				title : '재요청사유',
          				message : grid.getCellValue(rowId, 'RE_REQ_REASON'),
          				detailView : true
          			};
        		var url = '/common/popup/common_text_view/view';
        	    everPopup.openModalPopup(url, 500, 320, param);
			}
            if(colId == "REQ_TXT") {
				if( grid.getCellValue(rowId, 'REQ_TXT') == '' ) return;
				var param = {
          				title : '고객사 요청내용',
          				message : grid.getCellValue(rowId, 'REQ_TXT'),
          				detailView : true
          			};
        		var url = '/common/popup/common_text_view/view';
        	    everPopup.openModalPopup(url, 500, 320, param);
			}
         	// 요청자
        	if(colId == 'REQ_USER_MSK_NM') {
        		if( grid.getCellValue(rowId, 'REQ_USER_ID') == '' ) return;
        		var param = {
	                     callbackFunction : "",
	                     USER_ID : grid.getCellValue(rowId, 'REQ_USER_ID'),
	                     detailView : true
	                 };
	                 everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
        	}
        	// 대행등록자
        	if(colId == 'AGENT_USER_NM') {
        		if( grid.getCellValue(rowId, 'AGENT_USER_ID') == '' ) return;
        		var param = {
	                     callbackFunction : "",
	                     USER_ID : grid.getCellValue(rowId, 'AGENT_USER_ID'),
	                     detailView : true
	                 };
	                 everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
        	}
            // 표준화담당자
        	if(colId == 'CMS_CTRL_USER_NM') {
        		if( grid.getCellValue(rowId, 'CMS_CTRL_USER_ID') == '' ) return;
        		var param = {
	                     callbackFunction : "",
	                     USER_ID : grid.getCellValue(rowId, 'CMS_CTRL_USER_ID'),
	                     detailView : true
	                 };
	                 everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
        	}
        });
	}

	function doSearch() {
		var store = new EVF.Store();
		if (!store.validate()) { return; }

        store.setGrid([grid]);
		store.load(baseUrl + "IM03_040/doSearch", function () {
			if(grid.getRowCount() === 0) {
				return alert('${msg.M0002}');
			}
		});
	}
	
	function doConfirm() {
    	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

        if(!confirm("${msg.M0025}")) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
		store.getGridData(grid, 'sel');
        store.load(baseUrl + 'IM03_040/doConfirm', function(){
       		alert(this.getResponseMessage());
       		doSearch();
       	});
    }
    
    function doReject() {
    	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

        var rowIds = grid.getSelRowId();
        for(var i in rowIds) {
            if(grid.getCellValue(rowIds[i], 'RE_REQ_REJECT_RMK') == "") {
            	grid.setCellBgColor(rowIds[i], "RE_REQ_REJECT_RMK", '#fdd');
            	return alert("${IM03_040_001 }");
            }
        }

        if(!confirm("${msg.M0022}")) { return; }

        var store = new EVF.Store();
        store.setGrid([grid]);
		store.getGridData(grid, 'sel');
        store.load(baseUrl + 'IM03_040/doReject', function(){
       		alert(this.getResponseMessage());
       		doSearch();
       	});
    }
    
    function searchCUST_CD() {
        var param = {
            callBackFunction : "callbackCUST_CD"
        };
        everPopup.openCommonPopup(param, 'SP0067');
    }

    function callbackCUST_CD(data) {
        EVF.C("CUST_CD").setValue(data.CUST_CD);
        EVF.C("CUST_NM").setValue(data.CUST_NM);
    }

	function searchADD_USER_ID() {
		var custCd = EVF.V("CUST_CD");
		if( custCd == "" ) {
			return alert("${IM03_040_002}");
		}
        var param = {
            callBackFunction: "callbackADD_USER_ID",
            custCd: custCd
        };
        everPopup.openCommonPopup(param, 'SP0083');
	}

    function callbackADD_USER_ID(data) {
        EVF.C("ADD_USER_ID").setValue(data.USER_ID);
        EVF.C("ADD_USER_NM").setValue(data.USER_NM);
    }
    
    function setRejectText(data){
    	grid.setCellValue(data.rowId, 'RE_REQ_REJECT_RMK', data.message);
    }

 </script>
	<e:window id="IM03_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="150px" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="ADD_FROM_DATE" name="ADD_FROM_DATE" toDate="ADD_TO_DATE" value="${oneMonthAgo}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="ADD_TO_DATE" name="ADD_TO_DATE" fromDate="ADD_FROM_DATE" value="${today}" width="${inputDateWidth}" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
				</e:field>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCUST_CD'}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
				<e:label for="ADD_USER_ID" title="${form_ADD_USER_ID_N}"/>
				<e:field>
					<e:search id="ADD_USER_ID" name="ADD_USER_ID" value="" width="40%" maxLength="${form_ADD_USER_ID_M}" onIconClick="${form_ADD_USER_ID_RO ? 'everCommon.blank' : 'searchADD_USER_ID'}" disabled="${form_ADD_USER_ID_D}" readOnly="${form_ADD_USER_ID_RO}" required="${form_ADD_USER_ID_R}" />
					<e:inputText id="ADD_USER_NM" name="ADD_USER_NM" value="" width="60%" maxLength="${form_ADD_USER_NM_M}" disabled="${form_ADD_USER_NM_D}" readOnly="${form_ADD_USER_NM_RO}" required="${form_ADD_USER_NM_R}" />
				</e:field>
			</e:row>
            <e:row>
                <e:label for="CMS_CTRL_USER_ID" title="${form_CMS_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="CMS_CTRL_USER_ID" name="CMS_CTRL_USER_ID" value="" options="${cmsUserOptions}" width="${form_CMS_CTRL_USER_ID_W}" disabled="${form_CMS_CTRL_USER_ID_D}" readOnly="${form_CMS_CTRL_USER_ID_RO}" required="${form_CMS_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
				<e:label for="RE_REQ_CODE" title="${form_RE_REQ_CODE_N}"/>
				<e:field>
					<e:select id="RE_REQ_CODE" name="RE_REQ_CODE" value="" options="${reReqCodeOptions}" width="${form_RE_REQ_CODE_W}" disabled="${form_RE_REQ_CODE_D}" readOnly="${form_RE_REQ_CODE_RO}" required="${form_RE_REQ_CODE_R}" placeHolder="" />
				</e:field>
                <e:label for="ITEM_NM" title="${form_ITEM_NM_N}" />
                <e:field>
                    <e:inputText id="ITEM_NM" name="ITEM_NM" value="" width="${form_ITEM_NM_W}" maxLength="${form_ITEM_NM_M}" disabled="${form_ITEM_NM_D}" readOnly="${form_ITEM_NM_RO}" required="${form_ITEM_NM_R}" />
                </e:field>
            </e:row>
		</e:searchPanel>

		<e:buttonBar align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<e:button id="doConfirm" name="doConfirm" label="${doConfirm_N}" onClick="doConfirm" disabled="${doConfirm_D}" visible="${doConfirm_V}"/>
			<e:button id="doReject" name="doReject" label="${doReject_N}" onClick="doReject" disabled="${doReject_D}" visible="${doReject_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>