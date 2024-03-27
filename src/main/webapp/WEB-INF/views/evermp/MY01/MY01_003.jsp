<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script type="text/javascript">

	    var grid;
	    var baseUrl = "/evermp/MY01/";

	    function init() {

	        grid = EVF.C("grid");

	        grid.cellClickEvent(function(rowId, colId, value) {
	        	if(colId == "SUBJECT") {
	        		var param = {
	        			'NOTICE_NUM': grid.getCellValue(rowId, "NOTICE_NUM"),
           				'detailView': ("${ses.userId }" == grid.getCellValue(rowId, "REG_USER_ID") ? false : true),
           				'popupFlag': true
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
                if(colId == "REG_USER_NM") {
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
	        store.load(baseUrl + 'my01003_doSearch', function() {
	        	if(grid.getRowCount() == 0){
	            	alert("${msg.M0002 }");
	            }
	        });
	    }

	    function doCreate(){
	    	var param = {
    			'NOTICE_NUM': "",
    			'detailView': false,
    			'popupFlag': true
	    	};
	    	everPopup.openPopupByScreenId("MY01_004", 1000, 700, param);
	    }

	    function doChange() {

			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

			var noticeNum = "";
			var rowIds = grid.getSelRowId();
	    	for(var i in rowIds) {
	    		if("${ses.userId }" != grid.getCellValue(rowIds[i], "REG_USER_ID")) {
	                return alert("${MY01_003_001}");
	            }
	    		noticeNum = grid.getCellValue(rowIds[i], "NOTICE_NUM");
    		}

	    	var param = {
    			'NOTICE_NUM': noticeNum,
    			'detailView': false,
    			'popupFlag': true
	    	};
	    	everPopup.openPopupByScreenId("MY01_004", 1000, 700, param);
		}

	    function doDelete() {

			if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	    	if(confirm("${msg.M0013 }")) {
				var store = new EVF.Store();
				store.setGrid([grid]);
	            store.getGridData(grid, 'sel');
	            store.load(baseUrl + 'my01003_doDelete', function(){
	        		alert(this.getResponseMessage());
	        		doSearch();
	        	});
	    	}
		}

	    function doUserSearch() {
	    	everPopup.userSearchPopup('selectUser');
	    }

	    function selectUser(data) {
	    	EVF.C("REG_USER_ID").setValue(data.USER_ID);
	    	EVF.C("REG_USER_NM").setValue(data.HIDDEN_USER_NM);
	    }

	    function clearUser() {
	    	EVF.C("REG_USER_ID").setValue("");
		}


        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.C("VENDOR_CD").setValue(dataJsonArray.VENDOR_CD);
            EVF.C("VENDOR_NM").setValue(dataJsonArray.VENDOR_NM);
        }


    </script>

	<e:window id="MY01_003" initData="${initData}" onReady="init" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%" columnCount="3" useTitleBar="false" onEnter="doSearch">
			<e:row>
				<e:label for="ADD_FROM_DATE" title="${form_ADD_FROM_DATE_N}" />
				<e:field>
					<e:inputDate id="ADD_FROM_DATE" toDate="ADD_TO_DATE" name="ADD_FROM_DATE" value="${addFromDate }" width="${inputDateWidth }" datePicker="true" required="${form_ADD_FROM_DATE_R}" disabled="${form_ADD_FROM_DATE_D}" readOnly="${form_ADD_FROM_DATE_RO}" />
					<e:text>~&nbsp;</e:text>
					<e:inputDate id="ADD_TO_DATE" fromDate="ADD_FROM_DATE" name="ADD_TO_DATE" value="${addToDate }" width="${inputDateWidth }" datePicker="true" required="${form_ADD_TO_DATE_R}" disabled="${form_ADD_TO_DATE_D}" readOnly="${form_ADD_TO_DATE_RO}" />
				</e:field>

                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>



				<e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
				<e:field>
					<e:search id="REG_USER_NM" name="REG_USER_NM" value="" width="${form_REG_USER_NM_W}" maxLength="${form_REG_USER_NM_M}" onIconClick="doUserSearch" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" onChange="clearUser" />
					<e:inputHidden id="REG_USER_ID" name="REG_USER_ID" value="" />
				</e:field>
			</e:row>
		</e:searchPanel>

		<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
			<e:button id="Create" name="Create" label="${Create_N }" disabled="${Create_D }" visible="${Create_V}" onClick="doCreate" />
			<e:button id="Change" name="Change" label="${Change_N }" disabled="${Change_D }" visible="${Change_V}" onClick="doChange" />
			<e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" visible="${Delete_V}" onClick="doDelete" />
		</e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

	</e:window>
</e:ui>