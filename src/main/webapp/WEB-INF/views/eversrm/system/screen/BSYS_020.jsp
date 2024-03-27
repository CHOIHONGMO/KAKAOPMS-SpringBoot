<!--
* BSYS_020 : 화면액션관리
* 시스템관리 > 화면 > 화면액션관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/screen/";
    	var searchRow = "";

		function init() {

			grid = EVF.C('grid');


			grid.setProperty('panelVisible', ${panelVisible});

			grid.setColIconify("SCREEN_NM_IMG", "SCREEN_NM_IMG", "detail", true);

			if ('${param.screenId}' != '') {
	            EVF.C('SCREEN_ID').setValue('${param.screenId}');
	            doSearch();
	        }

			grid.cellClickEvent(function(rowid, colId, value) {

				searchRow = rowid;

		        if (colId == "SCREEN_ID") {
		            var popupUrl = "/eversrm/system/screen/BSYS_030/view";
		            everPopup.openWindowPopup(popupUrl, 1000, 500, {
		                onSelect: 'selectScreen'
		            }, 'screenIdPopup');
		        }
		        else if (colId == 'ACTION_NM') {

					if (grid.getCellValue(rowid, 'ACTION_CD') == null || grid.getCellValue(rowid, 'ACTION_CD') == "") {
						alert("${BSYS_020_MSG_0001}");
					    return;
					}
		            var params = {
		                multi_cd: 'SA',
		                screen_id: grid.getCellValue(rowid, "SCREEN_ID"),
		                action_cd: grid.getCellValue(rowid, "ACTION_CD"),
		                rowid: rowid
		            };

		            everPopup.openMultiLanguagePopup(params);

		        } else if (colId == 'BUTTON_ICON_NM') {
		            everPopup.openIconPopup();
		        } else if (colId == 'BUTTON_AUTH') {
                    if (grid.getCellValue(rowid, 'SCREEN_ID') == null || grid.getCellValue(rowid, 'SCREEN_ID') == '') {
                        alert("${BSYS_010_MSG_0001 }");
                        return;
                    }
                    var param = {
                        "callbackFunction" : "setScreenAuth",
                        "screenId" : grid.getCellValue(rowid, 'SCREEN_ID'),
                        "actionCd" : grid.getCellValue(rowid, 'ACTION_CD'),
                        "rowId" : rowid
                    };
                    var url = '/eversrm/system/multiLang/BSYL_050/view';
                    return new EVF.ModalWindow(url, param, 700, 400).open();
                }
			});
			grid.addRowEvent(function() {
				addParam = [{"INSERT_FLAG": "I", "GATE_CD": "${ses.gateCd }"}];
            	grid.addRow(addParam);
			});
			grid.delRowEvent(function() {
                if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

				grid.delRow();
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'screenActionManagement/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

        	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!isValidFPColumn()) {
	            return;
	        }
			if (!confirm("${msg.M0021 }")) return;
	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'screenActionManagement/doSave', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'screenActionManagement/doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

	    function doCopy() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			var rowIds = grid.getSelRowId();
			grid.checkAll(false);

			for(var i = 0; i < rowIds.length; i++) {
				var selectedData = [{
					"SCREEN_ID": grid.getRowValue(rowIds[i]).SCREEN_ID,
					"SCREEN_NM": grid.getRowValue(rowIds[i]).SCREEN_NM,
					"MODULE_TYPE": grid.getRowValue(rowIds[i]).MODULE_TYPE,
					"GATE_CD": grid.getRowValue(rowIds[i]).GATE_CD,
					"INSERT_FLAG": "I"
				}];
				grid.addRow(selectedData);
			}
	    }

	    function selectScreen(data) {
	        grid.setCellValue(searchRow, "SCREEN_ID", data.SCREEN_ID); //{src:'', text: data.SCREEN_ID});
	        grid.setCellValue(searchRow, "SCREEN_NM", data.SCREEN_NM);
	        grid.setCellValue(searchRow, "MODULE_TYPE", data.MODULE_TYPE);
        }
        /*
	    function setButtonIcon(val) {
	        grid.setCellValue('BUTTON_ICON_NAME', searchRow, val);
	    }
	    */

	    function isValidFPColumn() {

	    	var rowIds = grid.getSelRowId();
			for(var i = 0; i < rowIds.length; i++) {
                var selectedCount = 0;
                if (isFPSelected(rowIds[i], 'FP_EQ_FLAG')) {
                    selectedCount++;
                }
                if (isFPSelected(rowIds[i], 'FP_EO_FLAG')) {
                    selectedCount++;
                }
                if (isFPSelected(rowIds[i], 'FP_EI_FLAG')) {
                    selectedCount++;
                }
                if (isFPSelected(rowIds[i], 'FP_ETC_TEXT')) {
                    selectedCount++;
                }
                if (selectedCount == 0) {
                    alert('${BSYS_020_0001 }');
                    return false;
                }
                if (selectedCount != 1) {
                    alert('${BSYS_020_0001 }');
                    return false;
                }
            }
	        return true;
	    }

	    function isFPSelected(nRow, id) {
	        if (grid.getCellValue(nRow, id) == '1') {
	            return true;
	        }
	        return false;
	    }

		function multiLanguagePopupCallBack(multiLanguagePopupReturn) {
	        grid.setCellValue(multiLanguagePopupReturn.rowid, 'ACTION_NM', multiLanguagePopupReturn.multiNm);
	    }

		function setSearchTemplate(buttonType) {

			if(EVF.isEmpty(EVF.C('MODULE_TYPE').getValue())) {
				return alert('${BSYS_020_MSG_0007 }');
			}

			if(EVF.isEmpty(EVF.C('SCREEN_ID').getValue())) {
				return alert('${BSYS_020_MSG_0008 }');
			}

			var btnName, actionCode, screenId;
			switch(buttonType) {
				case 'search':
					btnName = '${BSYS_020_MSG_0003 }';
					actionCode = "Search";
					break;
				case 'save':
					btnName = '${BSYS_020_MSG_0004 }';
					actionCode = "Save";
					break;
				case 'delete':
					btnName = '${BSYS_020_MSG_0005 }';
					actionCode = "Delete";
					break;
				case 'close':
					btnName = '${BSYS_020_MSG_0006 }';
					actionCode = "Close";
					break;
			}
			var newRowId = grid.addRow([{
				"MODULE_TYPE":EVF.C('MODULE_TYPE').getValue(),
				"SCREEN_ID":EVF.C('SCREEN_ID').getValue(),
				"ACTION_CD": actionCode,
				"FP_EQ_FLAG": buttonType === 'search' ? '1' : '0',
				"FP_EI_FLAG": (buttonType === 'save' || buttonType === 'delete') ? '1' : '0',
				"FP_ETC_TEXT": buttonType === 'close' ? '1' : '0'
			}]);

			var params = {
				"multi_cd": 'SA',
				"screen_id": EVF.C('SCREEN_ID').getValue(),
				"action_cd": actionCode,
				"rowid": newRowId,
				"insertNew": true
			};

			everPopup.openMultiLanguagePopup(params);
		}

    </script>
    <e:window id="BSYS_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
        	<e:row>
                <e:label for="MODULE_TYPE" title="${form_MODULE_TYPE_N }" />
                <e:field>
                    <e:select id="MODULE_TYPE" name="MODULE_TYPE" options="${moduleTypeOptions}" width="${form_MODULE_TYPE_W }" required="${form_MODULE_TYPE_R }" readOnly="${form_MODULE_TYPE_RO }" disabled="${form_MODULE_TYPE_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
                <e:field>
                	<e:inputText id="SCREEN_ID" name="SCREEN_ID" width="${form_SCREEN_ID_W }" maxLength="${form_SCREEN_ID_M}" required="${form_SCREEN_ID_R }" readOnly="${form_SCREEN_ID_RO }" disabled="${form_SCREEN_ID_D }" value="${param.screenId}"/>
                </e:field>
                <e:label for="SCREEN_NM" title="${form_SCREEN_NM_N }" />
                <e:field>
	                <e:inputText id="SCREEN_NM" name="SCREEN_NM" maxLength="${form_SCREEN_NM_M}" width="${form_SCREEN_NM_W }" required="${form_SCREEN_NM_R }" readOnly="${form_SCREEN_NM_RO }" disabled="${form_SCREEN_NM_D }" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
			<div style="float: left; font-size: 12px; line-height: 22px;">${BSYS_020_MSG_0002}:</div>
			<a onclick="setSearchTemplate('search');" style="float: left; font-size: 12px; line-height: 22px; cursor: hand !important;">[${BSYS_020_MSG_0003}]</a>
			<a onclick="setSearchTemplate('save');" style="float: left; font-size: 12px; line-height: 22px; cursor: hand !important;">[${BSYS_020_MSG_0004}]</a>
			<a onclick="setSearchTemplate('delete');" style="float: left; font-size: 12px; line-height: 22px; cursor: hand !important;">[${BSYS_020_MSG_0005}]</a>
			<a onclick="setSearchTemplate('close');" style="float: left; font-size: 12px; line-height: 22px; cursor: hand !important;">[${BSYS_020_MSG_0006}]</a>
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Copy" name="Copy" label="${Copy_N }" disabled="${Copy_D }" onClick="doCopy" />
            <e:button id="Save" name="Save"  label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>