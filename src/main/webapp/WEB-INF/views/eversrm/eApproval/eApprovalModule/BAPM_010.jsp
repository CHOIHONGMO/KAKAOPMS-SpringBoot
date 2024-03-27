<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var grid;
    var saveKey;
    var baseUrl = "/eversrm/eApproval/eApprovalModule/";

    function init() {
        grid = EVF.C("grid");
        grid.setProperty('panelVisible', ${panelVisible});
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
        grid.setProperty('shrinkToFit', true);
		grid.cellClickEvent(function(rowId, cellName, value, iRow, iCol) {
			onCellClick( cellName, rowId );
		});

        doSearch();
    }

    function doSearch() {

        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + 'BAPM_010/selectPath', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {

				var rowIds = grid.getAllRowId();
    			for (var i in rowIds) {
    				if (grid.getCellValue(i, "PATH_NUM") == saveKey) {
        				grid.checkRow(i, true);
        				return;
    				}
    			}
            }
        });
    }

    function doRegister() {
        var popupUrl = baseUrl + "BAPM_020/view";
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
    	if( grid.isEmpty( grid.getSelRowId() ) ) {
            alert("${msg.M0004}");
            return;
        }

        if (!confirm("${msg.M0013 }")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
	    store.getGridData(grid, 'sel');
	    store.load(baseUrl + 'BAPM_010/deletePath', function(){
	    	alert(this.getResponseMessage());
	        doSearch();
	    });
    }

    function onCellClick(strColumnKey, nRow) {

        if (strColumnKey == "SIGN_PATH_NM") {

            saveKey = grid.getCellValue("PATH_NUM", nRow);
            var popupUrl = baseUrl + 'BAPM_020/view';
            var param = {
                'toolbar': 'no',
                'menubar': 'no',
                'status': 'yes',
                'scrollbars': 'auto',
                'resizable': 'no',
                '_title': 'Path Change',
                'VALUE': 'C',
                'GATECD': grid.getCellValue(nRow, 'GATE_CD'),
                'PATHNUM': grid.getCellValue(nRow, 'PATH_NUM'),
                'MAINPATHFLAG': grid.getCellValue(nRow, 'MAIN_PATH_FLAG'),
                'SIGNPATHNM': grid.getCellValue(nRow, 'SIGN_PATH_NM'),
                'SIGNRMK': grid.getCellValue(nRow, 'SIGN_RMK'),
                'popupFlag': true,
                'onClose': 'closePopup'
            };

            everPopup.openWindowPopup(popupUrl, 870, 600, param, 'pathRegister');

        }
    }

    function closePopup() {
        EVF.C('SIGN_PATH_NM').setValue("");
        doSearch();
    }

    </script>

    <e:window id="BAPM_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="SIGN_PATH_NM" title="${form_SIGN_PATH_NM_N}"></e:label>
                <e:field colSpan="3">
					<e:inputText id="SIGN_PATH_NM" name="SIGN_PATH_NM" width="100%" maxLength="${form_SIGN_PATH_NM_M }" required="${form_SIGN_PATH_NM_R }" readOnly="${form_SIGN_PATH_NM_RO }" disabled="${form_SIGN_PATH_NM_D}" visible="${form_SIGN_PATH_NM_V}" ></e:inputText>
                </e:field>
            </e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" onClick="doSearch" />
            <e:button id="doRegister" name="doRegister" label="${doRegister_N }" disabled="${doRegister_D }" onClick="doRegister" />
            <e:button id="doDelete" name="doDelete" label="${doDelete_N }" disabled="${doDelete_D }" onClick="doDelete" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
