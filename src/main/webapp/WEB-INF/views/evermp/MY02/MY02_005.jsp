<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

	    var baseUrl = "/evermp/MY02/";
	    var grid;

	    function init() {

	    	grid = EVF.C("grid");

	        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

	        	if(colId === 'APP_DOC_NUM'){

		            var params = {
		                gateCd : grid.getCellValue(rowId, "GATE_CD"),
		                appDocNum : grid.getCellValue(rowId, "APP_DOC_NUM"),
		                appDocCnt : grid.getCellValue(rowId, "APP_DOC_CNT"),
		                docType : grid.getCellValue(rowId, "DOC_TYPE"),
		                signStatus : grid.getCellValue(rowId, "SIGN_STATUS"),
		                sendBox : true,
						fCnt : grid.getCellValue(rowId, "F_CNT") > 0 ? true : false
		            };
		            everPopup.openApprovalOrRejectPopup(params);

		       	} else if(colId == "CNT"){

		       		var param = {
		       			GATE_CD : grid.getCellValue(rowId, "GATE_CD"),
		       			APP_DOC_NUM : grid.getCellValue(rowId, "APP_DOC_NUM"),
	                    APP_DOC_CNT : grid.getCellValue(rowId, "APP_DOC_CNT")
	                };
	                everPopup.approvalPathSearchPopup(param);
				}
			});

	        grid.setProperty('shrinkToFit', true);
	        grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});
            if("${ses.userType}" == "C") { grid.setColWidth('APP_AMT', 0); }

	        doSearch();
	    }

	    function doSearch() {

	        var store = new EVF.Store();
	        if(!store.validate()) { return; }
	        store.setGrid([grid]);
	        store.load(baseUrl + 'my02005_doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	alert("${msg.M0002 }");
	            }
	        });
	    }

	    function doCancel() {

	    	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	    	var rowIds = grid.getSelRowId();
	    	for(var i in rowIds) {
	    		if(grid.getCellValue(rowIds[i], "SIGN_STATUS") != "P") {
	                return alert("${MY02_005_0002}");
	            }
	    		noticeNum = grid.getCellValue(rowIds[i], "NOTICE_NUM");
    		}

	    	if(confirm("${msg.M0024 }")) {
				var store = new EVF.Store();
				store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.load(baseUrl + 'my02005_doCancel', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	    	}
	    }

    </script>

    <e:window id="MY02_005" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="START_DATE" title="${form_START_DATE_N}"></e:label>
                <e:field>
                    <e:inputDate id="START_DATE" toDate="END_DATE" name="START_DATE" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                	<e:text>~</e:text>
                    <e:inputDate id="END_DATE" fromDate="START_DATE" name="END_DATE" value="${toDate}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
				<e:label for="SIGN_STATUS" title="${form_SIGN_STATUS_N}"/>
				<e:field>
					<e:select id="SIGN_STATUS" name="SIGN_STATUS" value="" options="${signStatusOptions}" width="${form_SIGN_STATUS_W}" disabled="${form_SIGN_STATUS_D}" readOnly="${form_SIGN_STATUS_RO}" required="${form_SIGN_STATUS_R}" placeHolder="" />
				</e:field>
			</e:row>
            <e:row>
            	<e:label for="DOC_TYPE" title="${form_DOC_TYPE_N}"/>
				<e:field>
					<e:select id="DOC_TYPE" name="DOC_TYPE" value="" options="${docTypeOptions}" width="${form_DOC_TYPE_W}" disabled="${form_DOC_TYPE_D}" readOnly="${form_DOC_TYPE_RO}" required="${form_DOC_TYPE_R}" placeHolder="" />
				</e:field>
            	<e:label for="SUBJECT" title="${form_SUBJECT_N}"></e:label>
                <e:field>
					<e:inputText id="SUBJECT" name="SUBJECT" width="${form_SUBJECT_W }" maxLength="${form_SUBJECT_M }" required="${form_SUBJECT_R }" readOnly="${form_SUBJECT_RO }" disabled="${form_SUBJECT_D}" visible="${form_SUBJECT_V}" ></e:inputText>
                </e:field>
			</e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
<%--             <e:button id="Cancel" name="Cancel" label="${Cancel_N }" disabled="${Cancel_D }" onClick="doCancel" /> --%>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>