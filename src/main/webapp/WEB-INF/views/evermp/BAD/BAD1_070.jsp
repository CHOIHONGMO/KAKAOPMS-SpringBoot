<%-- 고객사 > Admin > 사용자관리 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">
<!--
		var gridD;
		var baseUrl = "/evermp/BAD/BAD1/";
		var eventRowId = 0;

		function init(){
		    gridD = EVF.C("gridD");

		    gridD.setProperty('shrinkToFit', false);

		    gridD.cellClickEvent(function(rowId, colName, value) {
		    	eventRowId = rowId;
		    	if (colName == "CUST_CD") {
		            var param = {
		                'CUST_CD': gridD.getCellValue(rowId, 'CUST_CD'),
		                'detailView': false,
		                'popupFlag': true
		            };
		            everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
		        }

		    	if (colName == "DELY_ZIP_CD") {
		    		var url = '/common/code/BADV_020/view';
		            var param = {
		                callBackFunction : "setGridZipCode",
		                modalYn : false
		            };
		            //everPopup.openWindowPopup(url, 700, 600, param);
		            everPopup.jusoPop(url, param);
		        }

		    	if (colName == "DELY_RMK") {
		    		var url = '/common/popup/common_text_input/view';
		    		var param = {
		      				title : '요청사항',
		      				message : gridD.getCellValue(rowId, 'DELY_RMK'),
		      				callbackFunction : 'setGridDelyText',
		          			detailView : false,
		      				rowId : rowId
		      			};
		    	    everPopup.openModalPopup(url, 500, 320, param);
		        }

		    });

		    //doSearch();

		    gridD.excelExportEvent({
		        allItems : "${excelExport.allCol}",
		        fileName : "${screenName }"
		    });

		    gridD.addRowEvent(function() {
		    	addParam = [{"CUST_CD": "${ses.companyCd}","CUST_NM": "${ses.companyNm}","USE_FLAG": '1'}];
		    	gridD.addRow(addParam);
		    });

		    gridD.delRowEvent(function() {

		        if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

		        var delCnt = 0;
		        var rowIds = gridD.getSelRowId();
		        for(var i = rowIds.length -1; i >= 0; i--) {
		            if(!EVF.isEmpty(gridD.getCellValue(rowIds[i], "SEQ"))) {
		                delCnt++;
		            } else {
		            	gridD.delRow(rowIds[i]);
		            }
		        }
		        if(delCnt > 0) {
		        	doDeleteDT();
		        }
		    });

		}

		function setGridZipCode(data) {
		    if (data.ZIP_CD != "") {
		    	gridD.setCellValue(eventRowId, "DELY_ZIP_CD", data.ZIP_CD_5);
		    	gridD.setCellValue(eventRowId, 'DELY_ADDR_1', data.ADDR1);
		    	gridD.setCellValue(eventRowId, 'DELY_ADDR_2', data.ADDR2);
		    	//grid.setCellValue(eventRowId, 'DELY_ADDR_2', '');
		    }
		}

		function setGridDelyText(data){
			gridD.setCellValue(data.rowId, 'DELY_RMK', data.message);
		}


		// 고객사 배송지조회
		function doSearch() {

		    var store = new EVF.Store();
		    if (!store.validate()) { return; }

		    store.setGrid([gridD]);
		    store.setParameter("DELY_NM", EVF.C('DELY_NM').getValue());
		    store.setParameter("RECIPIENT_NM", EVF.C('RECIPIENT_NM').getValue());
		    store.setParameter("USE_FLAG", EVF.C('USE_FLAG').getValue());
		    store.load(baseUrl + "bad1070_doSearchD", function () {
		        if(gridD.getRowCount() === 0) {
		           return alert('${msg.M0002}');
		        }
		    });
		}

		// 배송지 저장
		function doSaveDT() {
		    var store = new EVF.Store();

		    if (!store.validate()) { return; }
		    if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

		    if(!confirm("${BAD1_070_002}")) { return; }

		    store.setGrid([gridD]);
		    store.getGridData(gridD, "sel");
		    store.load(baseUrl + "bad1070_doSaveDT", function() {
		        alert(this.getResponseMessage());
		        doSearch();
		    });
		}

		// 고객사배송지삭제
		function doDeleteDT() {
		    var store = new EVF.Store();

		    if (!store.validate()) { return; }
		    if(!gridD.isExistsSelRow()) { return alert("${msg.M0004}"); }

		    if(!confirm("${msg.M0013}")) { return; }

		    store.setGrid([gridD]);
		    store.getGridData(gridD, "sel");
		    store.load(baseUrl + "bad1070_doDeleteDT", function() {
		        alert(this.getResponseMessage());
		        doSearch();
		    });
		}

// -->
</script>

    <e:window id="BAD1_070" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="DELY_NM" title="${form_DELY_NM_N}" />
				<e:field>
					<e:inputText id="DELY_NM" name="DELY_NM" value="" width="${form_DELY_NM_W}" maxLength="${form_DELY_NM_M}" disabled="${form_DELY_NM_D}" readOnly="${form_DELY_NM_RO}" required="${form_DELY_NM_R}" />
				</e:field>
				<e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}" />
				<e:field>
					<e:inputText id="RECIPIENT_NM" name="RECIPIENT_NM" value="" width="${form_RECIPIENT_NM_W}" maxLength="${form_RECIPIENT_NM_M}" disabled="${form_RECIPIENT_NM_D}" readOnly="${form_RECIPIENT_NM_RO}" required="${form_RECIPIENT_NM_R}" />
				</e:field>
				<e:label for="USE_FLAG" title="${form_USE_FLAG_N }" />
				<e:field>
					<e:select id="USE_FLAG" name="USE_FLAG" value="" options="${useFlagOptions }" readOnly="${form_USE_FLAG_RO }" width="${form_USE_FLAG_W }" required="${form_USE_FLAG_R }" disabled="${form_USE_FLAG_D }" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
			<e:button id="SaveDT" name="SaveDT" label="${SaveDT_N}" onClick="doSaveDT" disabled="${SaveDT_D}" visible="${SaveDT_V}"/>
			<e:button id="DeleteDT" name="DeleteDT" label="${DeleteDT_N}" onClick="doDeleteDT" disabled="${DeleteDT_D}" visible="${DeleteDT_V}"/>
        </e:buttonBar>

        <e:gridPanel id="gridD" name="gridD" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridD.gridColData}" />

    </e:window>
</e:ui>