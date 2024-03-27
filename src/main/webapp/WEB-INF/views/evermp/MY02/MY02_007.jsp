<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var saveKey;
    var baseUrl = "/evermp/MY02/";

    function init() {

    	grid = EVF.C("grid");

		grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

			if (colId == "SIGN_PATH_NM") {

	            saveKey = grid.getCellValue(rowId, "PATH_NUM");
	            var popupUrl = baseUrl + 'MY02_008/view';
	            var param = {
	                'toolbar': 'no',
	                'menubar': 'no',
	                'status': 'yes',
	                'scrollbars': 'auto',
	                'resizable': 'no',
	                '_title': 'Path Change',
	                'VALUE': 'C',
	                'GATECD': grid.getCellValue(rowId, 'GATE_CD'),
	                'PATHNUM': grid.getCellValue(rowId, 'PATH_NUM'),
	                'MAINPATHFLAG': grid.getCellValue(rowId, 'MAIN_PATH_FLAG'),
	                'SIGNPATHNM': grid.getCellValue(rowId, 'SIGN_PATH_NM'),
	                'SIGNRMK': grid.getCellValue(rowId, 'SIGN_RMK'),
	                'popupFlag': true,
	                'onClose': 'closePopup'
	            };
	            everPopup.openWindowPopup(popupUrl, 1000, 750, param, 'pathRegister');
	        }
		});

		grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});
        grid.setProperty('shrinkToFit', true);

        doSearch();
    }

    function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'my02007_doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
				var rowIds = grid.getAllRowId();
    			for (var i in rowIds) {
    				if (grid.getCellValue(rowIds[i], "PATH_NUM") == saveKey) {
        				grid.checkRow(i, true);
        				return;
    				}
    			}
            }
        });
    }

    function doRegister() {
        var popupUrl = baseUrl + "MY02_008/view";
        var param = {
            'VALUE': 'R',
            'onClose': 'closePopup',
            'toolbar': 'no',
            'menubar': 'no',
            'status': 'yes',
            'scrollbars': 'auto',
            'resizable': 'no'
        };
        everPopup.openWindowPopup(popupUrl, 1000, 600, param, "pathRegister");
    }

    function doDelete() {

    	if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

        if (!confirm("${msg.M0013 }")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
	    store.getGridData(grid, 'sel');
	    store.load(baseUrl + 'my02007_doDelete', function(){
	    	alert(this.getResponseMessage());
	        doSearch();
	    });
    }

    function closePopup() {
        EVF.C('SIGN_PATH_NM').setValue("");
        doSearch();
    }

    </script>

    <e:window id="MY02_007" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="SIGN_PATH_NM" title="${form_SIGN_PATH_NM_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="SIGN_PATH_NM" name="SIGN_PATH_NM" width="100%" maxLength="${form_SIGN_PATH_NM_M }" required="${form_SIGN_PATH_NM_R }" readOnly="${form_SIGN_PATH_NM_RO }" disabled="${form_SIGN_PATH_NM_D}" visible="${form_SIGN_PATH_NM_V}" ></e:inputText>
                </e:field>
            </e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Register" name="Register" label="${Register_N }" disabled="${Register_D }" onClick="doRegister" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
