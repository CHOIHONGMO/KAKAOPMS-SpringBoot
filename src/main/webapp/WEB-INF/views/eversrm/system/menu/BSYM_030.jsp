<!--
* BSYM_030 : 메뉴그룹관리
* 시스템관리 > 메뉴 > 메뉴그룹관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/menu/menuRegistration/";

		function init() {

			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.cellClickEvent(function(rowid, colId, value) {

				if(colId == 'MENU_GROUP_CD') {
					if (grid.getCellValue(rowid, 'MENU_GROUP_CD') == '') {
                        alert('${BSYM_030_0001}');
		            } else {
		                var menuGroupCd = grid.getCellValue(rowid, 'MENU_GROUP_CD');
		                var tmplMenuGroupCd = grid.getCellValue(rowid, 'TMPL_MENU_GROUP_CD');
		                var gateCd = grid.getCellValue(rowid, 'GATE_CD');
		                var moduleType = grid.getCellValue(rowid, 'MODULE_TYPE');
		                var params = {
		                    MENU_GROUP_CD: menuGroupCd,
		                    TMPL_MENU_GROUP_CD: tmplMenuGroupCd,
		                    MODULE_TYPE: moduleType,
		                    callBackFunction: 'selectPlantRow'
		                };
		                //everPopup.openMenuGroupCodePopup(params);
						everPopup.openPopupByScreenId('BSYM_040_TREE', 1000, 700, params);
		            }
				}
				else if (colId == 'TMPL_MENU_GROUP_CD') {
		            var params = {
		                rowid: rowid,
		                callBackFunction: 'selectMenuTemplateGroupCd'
		            };
		            everPopup.openMenuTemplateGroupCodePopup(params);
		        }
		        else if (colId == 'MENU_GROUP_NM') {
		            var menu_group_cd = grid.getCellValue(rowid, 'MENU_GROUP_CD');
                    if(menu_group_cd==""){
                        alert('${BSYM_030_0001}');
                    }else{
                        var params = {
                            multi_cd: 'MG',
                            screen_id: '-',
                            menu_group_cd: menu_group_cd,
                            rowid: rowid
                        };
                        everPopup.openMultiLanguagePopup(params);
//                        var params = {
//                            multi_cd: 'MG',
//                            choose_button_visibility: false,
//                            screen_id: '-',
//                            menu_group_cd: menu_group_cd,
//                            rowid: rowid
//                        };
//                        everPopup.openMultiLanguagePopup(params);
                    }

		        }
			});

			grid.addRowEvent(function() {
				addParam = [{'USE_FLAG': '1', 'INSERT_FLAG': 'C', 'MODULE_TYPE': (EVF.V('MODULE_TYPE')).length == 0 ? 'MA' : EVF.V('MODULE_TYPE')}];
				grid.addRow(addParam);
			});

			grid.delRowEvent(function() {
                if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
				grid.delRow();
			});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

			grid.setProperty('shrinkToFit', true);
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'searchMenu', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doSaveMenu', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

        function doCopy() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            if(!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0021 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'doCopyMenu', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {

            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'deleteMenu', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }


        function multiLanguagePopupCallBack(multiLanguagePopupReturn) {
            grid.setCellValue(multiLanguagePopupReturn.rowid, 'MENU_GROUP_NM', multiLanguagePopupReturn.multiNm);
        }

//        function multiLanguagePopupCallBack(multiLanguagePopupReturn) {
//
//	    	if(! (multiLanguagePopupReturn == null || multiLanguagePopupReturn == '')) {
//	        	grid.setCellValue(multiLanguagePopupReturn.rowid, 'MENU_GROUP_NM', multiLanguagePopupReturn.multiNm);
//	    	}
//	    }

	    function selectMenuTemplateGroupCd(data) {
	    	grid.setCellValue(data.rowid, 'TMPL_MENU_GROUP_CD', data.TMPL_MENU_GROUP_CD);
	        grid.setCellValue(data.rowid, 'TMPL_MENU_GROUP_NM', data.TMPL_MENU_GROUP_NM);
	    }

    </script>
    <e:window id="BSYM_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${longLabelWidth }" useTitleBar="false" onEnter="doSearch">
        	<e:row>
                <e:label for="MODULE_TYPE" title="${form_MODULE_TYPE_N }" />
                <e:field>
                    <e:select id="MODULE_TYPE" name="MODULE_TYPE" value="" options="${moduleTypeOptions}" width="100%" readOnly="${form_MODULE_TYPE_RO }" required="${form_MODULE_TYPE_R }" disabled="${form_MODULE_TYPE_D }" />
                </e:field>
                <e:label for="MENU_GROUP_NM" title="${form_MENU_GROUP_NM_N }" />
                <e:field>
                	<e:inputText id="MENU_GROUP_NM" style="${imeMode}" name="MENU_GROUP_NM" width="100%" required="${form_MENU_GROUP_NM_R }" disabled="${form_MENU_GROUP_NM_D }" readOnly="${form_MENU_GROUP_NM_RO }" maxLength="${form_MENU_GROUP_NM_M}" />
                </e:field>
				<e:label for="TMPL_MENU_GROUP_NM" title="${form_TMPL_MENU_GROUP_NM_N }" />
                <e:field>
                	<e:inputText id="TMPL_MENU_GROUP_NM" style="${imeMode}" name="TMPL_MENU_GROUP_NM" width="100%" required="${form_TMPL_MENU_GROUP_NM_R }" disabled="${form_TMPL_MENU_GROUP_NM_D }" readOnly="${form_TMPL_MENU_GROUP_NM_RO }" maxLength="${form_TMPL_MENU_GROUP_NM_M}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            <e:button id="Save" name="Save" label="${Save_N }" disabled="${Save_D }" onClick="doSave" />
            <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            <e:button id="Copy" name="Copy" label="${Copy_N}" onClick="doCopy" disabled="${Copy_D}" visible="${Copy_V}" />
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>