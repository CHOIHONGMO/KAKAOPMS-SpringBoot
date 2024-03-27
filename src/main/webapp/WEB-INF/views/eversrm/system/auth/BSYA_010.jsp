<!--
* BSYA_010 : 권한프로파일관리
* 시스템관리 > 권한 > 권한프로파일관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<script type="text/javascript">
    var baseUrl = "/eversrm/system/auth/BSYA_010/";
    var grid    = {};
    var searchRow;


    function init() {
        grid = EVF.C("grid");

		grid.addRowEvent(function() {
			doAddLine();
		});

		grid.cellClickEvent(function(rowId, colId, value) {
			onCellClick( colId, rowId );
		});
		grid.setProperty('panelVisible', ${panelVisible});
        grid.excelExportEvent({
            allItems : "${excelExport.allCol}",
            fileName : "${screenName }"
        });

		grid.setProperty('shrinkToFit', true);

    }

    function doSearch() {

		var store = new EVF.Store();
        store.setGrid([grid]);
    	store.load(baseUrl + 'doSearch', function() {
            if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }
        });
    }

    function doAddLine() {
		grid.addRow([{'INSERT_FLAG'     : 'I'
	 				, 'GATE_CD'         : '${ses.gateCd}'
    	}]);
    }

    function onCellClick(strColumnKey, nRow) {
        searchRow = nRow;

        if (strColumnKey == "MAIN_MODULE_TYPE2") {

        	var param = {
                    callBackFunction: "selectModuleType"
                };
            everPopup.openCommonPopup(param, 'SP0007');

        } else if (strColumnKey == "AUTH_NM" && grid.getCellValue(nRow, "INSERT_FLAG") != "I") {

        	var params = {
	                multi_cd: 'AU',
	                screen_id: '-',
	                "auth_cd": grid.getCellValue(nRow, "AUTH_CD"),
	                "choose_button_visibility": "true",
	                rowid: nRow
	            };
	        everPopup.openMultiLanguagePopup(params);

        }
    }

    function multiLanguagePopupCallBack(multiLanguagePopupReturn) {
        grid.setCellValue(multiLanguagePopupReturn.rowid, 'AUTH_NM', multiLanguagePopupReturn.multiNm);
        grid.setCellValue(multiLanguagePopupReturn.rowid, 'AUTH_DESC', multiLanguagePopupReturn.multi_Desc);
    }

    function selectModuleType(data) {

        var oldValue = grid.getCellValue(searchRow, "MAIN_MODULE_TYPE");
        var newValue = data.CODE;

        grid.setCellValue(searchRow, "MAIN_MODULE_TYPE", newValue);
        grid.setCellValue(searchRow, "MAIN_MODULE_TYPE2", newValue);
        grid.setCellValue(searchRow, "MODULE_TYPE_NM", data.TEXT1 ? data.TEXT1 : ' ');
    }

    function doInsert() {
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
    	var kkk = grid.getSelRowId();

        for (var i = 0; i < kkk.length; i++) {
            if (grid.getCellValue(kkk[i], 'INSERT_FLAG') == 'U') {
                alert("${msg.M0005}");
                return;
            }
        }

        if (!confirm("${msg.M0011}")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
		store.getGridData(grid, 'sel');
		store.load(baseUrl + 'doSave', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
    }

    function doUpdate() {
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        for (var i = 0; i < grid.getRowCount(); i++) {

            if (grid.getCellValue(i, 'INSERT_FLAG') == 'I') {
                alert("${msg.M0007}");
                return;
            }
        }

        if (!confirm("${msg.M0012}")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
		store.getGridData(grid, 'sel');
		store.load(baseUrl + 'doSave', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
    }

    function doDelete() {
        if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
        for (var i = 0; i < grid.getRowCount(); i++) {

            if (grid.getCellValue(i, 'INSERT_FLAG') == 'I') {
                alert("${msg.M0007}");
                return;
            }
        }

        if (!confirm("${msg.M0013}")) return;

		var store = new EVF.Store();
		store.setGrid([grid]);
		store.getGridData(grid, 'sel');
		store.load(baseUrl + 'doDelete', function(){
    		alert(this.getResponseMessage());
    		doSearch();
    	});
    }

    </script>

    <e:window id="BSYA_010" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">
         <e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="MODULE_TYPE_NM" title="${form_MODULE_TYPE_NM_N}"/>
				<e:field>
				<e:select id="MODULE_TYPE_NM" name="MODULE_TYPE_NM" value="${form.MODULE_TYPE_NM}" options="${moduleTypeNmOptions}" width="${form_MODULE_TYPE_NM_W}" disabled="${form_MODULE_TYPE_NM_D}" readOnly="${form_MODULE_TYPE_NM_RO}" required="${form_MODULE_TYPE_NM_R}" placeHolder="" />
				</e:field>
                <e:label for="AUTH_NM" title="${form_AUTH_NM_N}"></e:label>
                <e:field>
					<e:inputText id="AUTH_NM" style="${imeMode}" name="AUTH_NM" width='${form_AUTH_NM_W }' maxLength="${form_AUTH_NM_M }" required="${form_AUTH_NM_R }" readOnly="${form_AUTH_NM_RO }" disabled="${form_AUTH_NM_D}" visible="${form_AUTH_NM_V}" ></e:inputText>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="a" width="100%" align="right" >
            <e:button id="doSearch"        name="doSearch"               label="${doSearch_N }"        onClick="doSearch"        disabled="${doSearch_D }"         visible="${doSearch_V }"        />
            <e:button id="doInsert"        name="doInsert"               label="${doInsert_N }"        onClick="doInsert"        disabled="${doInsert_D }"         visible="${doInsert_V }"        />
            <e:button id="doUpdate"        name="doUpdate"               label="${doUpdate_N }"        onClick="doUpdate"        disabled="${doUpdate_D }"         visible="${doUpdate_V }"        />
            <e:button id="doDelete"        name="doDelete"               label="${doDelete_N }"        onClick="doDelete"        disabled="${doDelete_D }"         visible="${doDelete_V }"        />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="100%" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>
