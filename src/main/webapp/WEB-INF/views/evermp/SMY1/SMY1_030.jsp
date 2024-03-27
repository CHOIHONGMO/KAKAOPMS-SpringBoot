<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

	    var grid;
	    var baseUrl = "/evermp/SMY1/SMY101/";

	    function init() {

	        grid = EVF.C("grid");

	        grid.cellClickEvent(function(rowId, colId, value) {
	        	if(colId == "SUBJECT") {
	        		var param = {
	        			'NOTICE_NUM': grid.getCellValue(rowId, "NOTICE_NUM"),
           				'detailView': true,
           				'popupFlag' : true
        			};
	        		everPopup.openPopupByScreenId("MY01_004", 1000, 700, param);
				}
	        	if(colId == "ATT_FILE_NUM_ICON") {
	        		if( !EVF.isEmpty(grid.getCellValue(rowId, 'ATT_FILE_NUM_ICON')) ) {
		        		var uuid = grid.getCellValue(rowId, 'ATT_FILE_NUM');
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
				if(colId == 'REG_USER_NM') {
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
	        store.load(baseUrl + 'smy1030_doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	//alert("${msg.M0002 }");
	            }
	        });
	    }

    </script>
    
	<e:window id="SMY1_030" initData="${initData}" onReady="init" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}" />
				<e:field>
					<e:inputDate id="ADD_FROM_DATE" toDate="ADD_TO_DATE" name="ADD_FROM_DATE" value="${addFromDate }" width="${inputDateWidth }" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="ADD_TO_DATE" fromDate="ADD_FROM_DATE" name="ADD_TO_DATE" value="${addToDate }" width="${inputDateWidth }" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
				</e:field>
				<e:label for="SUBJECT" title="${form_SUBJECT_N}" />
				<e:field>
					<e:inputText id="SUBJECT" name="SUBJECT" value="" width="${form_SUBJECT_W}" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
				</e:field>
				<e:label for="BUYER_NM" title="${form_BUYER_NM_N}" />
				<e:field>
					<e:inputHidden id="BUYER_CD" name="BUYER_CD" value="" />
					<e:inputText id="BUYER_NM" name="BUYER_NM" value="" width="${form_BUYER_NM_W}" maxLength="${form_BUYER_NM_M}" disabled="${form_BUYER_NM_D}" readOnly="${form_BUYER_NM_RO}" required="${form_BUYER_NM_R}" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>