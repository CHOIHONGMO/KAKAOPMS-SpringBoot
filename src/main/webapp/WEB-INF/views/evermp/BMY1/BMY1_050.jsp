<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

	    var grid;
	    var baseUrl = "/evermp/BMY1/";

	    function init() {

	        grid = EVF.C("grid");

	        grid.cellClickEvent(function(rowId, colId, value) {
	        	if(colId == "SUBJECT") {
	        		var param = {
	        			'NOTICE_NUM': grid.getCellValue(rowId, "NOTICE_NUM"),
           				'detailView': true,
           				'popupFlag' : true
        			};
	        		everPopup.openPopupByScreenId("MY01_002", 1000, 700, param);
				}
	        	if(colId == "ATTACH_FILE_NO_DISPLAY") {
	        		if( !EVF.isEmpty(grid.getCellValue(rowId, 'ATTACH_FILE_NO_DISPLAY')) ) {
		        		var uuid = grid.getCellValue(rowId, 'ATTACH_FILE_NO');
						var param = {
								havePermission : false,
								attFileNum     : uuid,
								rowId          : rowId,
								callBackFunction: '',
								bizType: 'NT'
							};
							everPopup.openPopupByScreenId('commonFileAttach', 650, 310, param);
	        		}
				}
				if(colId == 'REG_USER_NAME') {
                    // 유저정보 조회
                    if( grid.getCellValue(rowId, 'REG_USER_ID') == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'REG_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
				}
			});

	        grid.excelExportEvent({
				allItems : "${excelExport.allCol}",
				fileName : "${screenName }"
			});
	        grid.setProperty('multiSelect', true);
	        grid.setProperty('shrinkToFit', true);

	        doSearch();
	    }

	    function doSearch() {

	    	var store = new EVF.Store();
			if(!store.validate()) { return; }
	        store.setGrid([grid]);
	        store.load(baseUrl + 'bmy1050_doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	//alert("${msg.M0002 }");
	            }
	        });
	    }

    </script>

	<e:window id="BMY1_050" initData="${initData}" onReady="init" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}" />
				<e:field>
					<e:inputDate id="ADD_FROM_DATE" toDate="ADD_TO_DATE" name="ADD_FROM_DATE" value="${addFromDate }" width="${inputDateWidth }" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
					<e:text>~</e:text>
					<e:inputDate id="ADD_TO_DATE" fromDate="ADD_FROM_DATE" name="ADD_TO_DATE" value="${addToDate }" width="${inputDateWidth }" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
				</e:field>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field>
					<e:inputText id="SUBJECT" name="SUBJECT" value="" width="${form_SUBJECT_W}" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				</e:field>
				<e:label for="ADD_USER_NAME" title="${form_ADD_USER_NAME_N}" />
				<e:field>
					<e:inputHidden id="ADD_USER_ID" name="ADD_USER_ID" value="" />
					<e:inputText id="ADD_USER_NAME" name="ADD_USER_NAME" value="" width="${form_ADD_USER_NAME_W}" maxLength="${form_ADD_USER_NAME_M}" disabled="${form_ADD_USER_NAME_D}" readOnly="${form_ADD_USER_NAME_RO}" required="${form_ADD_USER_NAME_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>