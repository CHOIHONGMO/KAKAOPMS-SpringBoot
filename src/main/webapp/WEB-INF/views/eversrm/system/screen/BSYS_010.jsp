<!--
* BSYS_010 : 화면관리
* 시스템관리 > 화면 > 화면관리
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/eversrm/system/screen/";

		function init() {
			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});
			grid.cellClickEvent(function(rowid, colId, value) {

				var multi_cd;

				if(${havePermission}) {
                    switch (colId) {
                        case 'SCREEN_NM':
                            if (grid.getCellValue(rowid, 'SCREEN_ID') == null || grid.getCellValue(rowid, 'SCREEN_ID') == '') {
                                alert("${BSYS_010_MSG_0001 }");
                                return;
                            }
                            multi_cd = 'SC';
                            break;
                        case 'POPUP_NM_IMG':
                            if (grid.getCellValue(rowid, 'SCREEN_ID') == null || grid.getCellValue(rowid, 'SCREEN_ID') == '') {
                                alert("${BSYS_010_MSG_0001 }");
                                return;
                            }
                            multi_cd = 'SCP';
                            break;
                        case 'AUTH_IMG':
                            if (grid.getCellValue(rowid, 'SCREEN_ID') == null || grid.getCellValue(rowid, 'SCREEN_ID') == '') {
                                alert("${BSYS_010_MSG_0001 }");
                                return;
                            }
                            var param = {
                                "callbackFunction" : "setScreenAuth",
                                "screenId" : grid.getCellValue(rowid, 'SCREEN_ID'),
                                "rowId" : rowid
                            };
                            var url = '/eversrm/system/multiLang/BSYL_050/view';
                            return new EVF.ModalWindow(url, param, 700, 400).open();
                            break;
                        case 'HELP_INFO':
                            var param = {
                                PARAM_SCREEN_ID : grid.getCellValue(rowid, 'SCREEN_ID')
                                ,POPUPFLAG   : "Y"
                                ,detailView  : false
                            };
                            everPopup.openPopupByScreenId('BSYS_040', 950, 650, param);
                            return;
                        default:
                            return;
                    }
                } else {
                    switch (colId) {
                        case 'HELP_INFO':
                            var param = {
                                PARAM_SCREEN_ID: grid.getCellValue(rowid, 'SCREEN_ID')
                                , POPUPFLAG: "Y"
                                , detailView: false
                            };
                            everPopup.openPopupByScreenId('BSYS_040', 950, 650, param);
                            return;
                        default:
                            return;
                    }
                }

		        var screen_id = grid.getCellValue(rowid, "SCREEN_ID");
		        var params = {
		            multi_cd: multi_cd,
		            screen_id: screen_id,
		            rowid: rowid
		        };
		        everPopup.openMultiLanguagePopup(params);
			});

            if(${havePermission}) {
                grid.addRowEvent(function() {
                    addParam = [{"USE_FLAG": "1", "INSERT_FLAG": "I", "INSERT_FLAG": "I", "GATE_CD": "${ses.gateCd }"}];
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
            } else {
                var columns = grid.columns;
                for(var i in columns) {
                    if(columns[i].fieldName != 'HELP_INFO') {
                        grid.setColReadOnly(columns[i].fieldName, true)
                    }
                }
            }

        }

        function setScreenAccessibleCount(rowId, count) {
            var c = Number(count);
            grid.setCellValue(rowId, 'AUTH_IMG', (c > 0 ? 'Y' : ''));
        }

        function doSearch() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'screenManagement/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
                grid.setColIconify("HELP_INFO", "HELP_INFO", "comment", false);
            });
        }

        function doInsert() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	        var rowIds = grid.getSelRowId();
	        for (var i = 0; i < rowIds.length; i++) {
	            if (grid.getCellValue(rowIds[i], 'INSERT_FLAG') === 'U') {
	                alert("${msg.M0005}");
	                return;
	            }
	        }
	        if (!grid.validate().flag) {
				alert(grid.validate().msg);
			    return;
			}

			if (!confirm("${msg.M0011 }")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'screenManagement/doInsert', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doUpdate() {
            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

	        for (var i = 0; i < grid.getRowCount(); i++) {
		        if (grid.getCellValue(i, 'INSERT_FLAG') == 'I' || grid.getCellValue(i, 'SCREEN_ID') != grid.getCellValue(i, 'SCREEN_ID_ORG')) {
	                alert("${msg.M0007}");
	                return;
	            }
	        }

	        if (!grid.validate().flag) { return alert(grid.validate().msg); }

			if (!confirm("${msg.M0012}")) return;

	        var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'screenManagement/doUpdate', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
        }

		function doDelete() {

            if (grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

			for (var i = 0; i < grid.getRowCount(); i++) {
	            if (grid.getCellValue(i, 'INSERT_FLAG') == 'I' || grid.getCellValue(i, 'SCREEN_ID') != grid.getCellValue(i, 'SCREEN_ID_ORG')) {
	                alert("${msg.M0007}");
	                return;
	            }
	        }

			if (!confirm("${msg.M0013 }")) return;

			var store = new EVF.Store();
	        store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
        	store.load(baseUrl + 'screenManagement/doDelete', function(){
        		alert(this.getResponseMessage());
        		doSearch();
        	});
	    }

		function doCopy() {

            if (grid.getSelRowCount() == 0) { return alert("${BSYS_010_MSG_0002}"); }

            if (grid.getSelRowCount() > 1) { return alert("${msg.M0006}"); }

            if(!confirm("${BSYS_010_MSG_0004}")) { return; }

            var param = {
            	"COPY_SCREEN_ID" : EVF.C("COPY_SCREEN_ID").getValue(),
            	"COPY_SCREEN_NM" : EVF.C("COPY_SCREEN_NM").getValue(),
            	"COPY_SCREEN_URL" : EVF.C("COPY_SCREEN_URL").getValue(),
				callbackFunction: 'setURL',
				'detailView': false
			};
            everPopup.openPopupByScreenId("BSYS_050", 700, 120, param);
	    }

		function setURL(data) {

			EVF.C("COPY_SCREEN_ID").setValue(data.COPY_SCREEN_ID);
			EVF.C("COPY_SCREEN_NM").setValue(data.COPY_SCREEN_NM);
			EVF.C("COPY_SCREEN_URL").setValue(data.COPY_SCREEN_URL);

			var store = new EVF.Store();
			store.setGrid([grid]);
        	store.getGridData(grid, 'sel');
	        store.load(baseUrl + 'screenManagement/doCopy', function() {
	        	alert(this.getResponseMessage().replace("@@","\n"));
	        	EVF.C("SCREEN_ID").setValue(EVF.C("COPY_SCREEN_ID").getValue());
	        	doSearch();
	        });
		}

	    function multiLanguagePopupCallBack(multiLanguagePopupReturn) {
	    	if(multiLanguagePopupReturn.multiCd == "SCP") {
	    		grid.setCellValue(multiLanguagePopupReturn.rowid, "POPUP_NM_IMG", multiLanguagePopupReturn.multiNm);
	    	}else {
	           grid.setCellValue(multiLanguagePopupReturn.rowid, "SCREEN_NM", multiLanguagePopupReturn.multiNm);
	    	}
	    }

    </script>
    <e:window id="BSYS_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">
        	<e:row>
                <e:label for="MODULE_TYPE" title="${form_MODULE_TYPE_N }" />
                <e:field>
                    <e:select id="MODULE_TYPE" name="MODULE_TYPE" options="${moduleTypeOptions}" readOnly="${form_MODULE_TYPE_RO }" width="${form_MODULE_TYPE_W }" required="${form_MODULE_TYPE_R }" disabled="${form_MODULE_TYPE_D }" />
                </e:field>
                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
                <e:field>
                	<e:inputText id="SCREEN_ID" name="SCREEN_ID" width="${form_SCREEN_ID_W }" required="${form_SCREEN_ID_R }" disabled="${form_SCREEN_ID_D }" value="" readOnly="${form_SCREEN_ID_RO }" maxLength="${form_SCREEN_ID_M}" />
                </e:field>
                <e:label for="SCREEN_NM" title="${form_SCREEN_NM_N }" />
                <e:field>
	                <e:inputText id="SCREEN_NM" name="SCREEN_NM" width="${form_SCREEN_NM_W }" required="${form_SCREEN_NM_R }" disabled="${form_SCREEN_NM_D }"  readOnly="${form_SCREEN_NM_RO }" maxLength="${form_SCREEN_NM_M}"/>
                </e:field>
            </e:row>
			<e:row>
				<e:label for="SCREEN_URL" title="${form_SCREEN_URL_N }" />
                <e:field>
                	<e:inputText id="SCREEN_URL" name="SCREEN_URL" width="${form_SCREEN_URL_W }" required="${form_SCREEN_URL_R }" disabled="${form_SCREEN_URL_D }" readOnly="${form_SCREEN_URL_RO }" maxLength="${form_SCREEN_URL_M}" />
                </e:field>
				<e:label for="SCREEN_TYPE" title="${form_SCREEN_TYPE_N }" />
                <e:field>
                    <e:select id="SCREEN_TYPE" name="SCREEN_TYPE" options="${screenTypeOptions}" width="${form_SCREEN_TYPE_W }" required="${form_SCREEN_TYPE_R }" disabled="${form_SCREEN_TYPE_D }" readOnly="${form_SCREEN_TYPE_RO }"/>
                </e:field>
                <e:label for="DEVELOPER_CD" title="${form_DEVELOPER_CD_N }" />
                <e:field>
                    <e:select id="DEVELOPER_CD" name="DEVELOPER_CD" options="${developerCdOptions}" width="${form_DEVELOPER_CD_W }" required="${form_DEVELOPER_CD_R }" disabled="${form_DEVELOPER_CD_D }" readOnly="${form_DEVELOPER_CD_RO }"/>
                    <e:inputHidden id="COPY_SCREEN_ID" name="COPY_SCREEN_ID" value="" />
                    <e:inputHidden id="COPY_SCREEN_NM" name="COPY_SCREEN_NM" value="" />
                    <e:inputHidden id="COPY_SCREEN_URL" name="COPY_SCREEN_URL" value="" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <c:if test="${havePermission == true}">
                <e:button id="Copy" name="Copy" align="left" label="${Copy_N }" disabled="${Copy_D }" style="padding-left:3px" onClick="doCopy" />
                <e:text>(${BSYS_010_MSG_0003})</e:text>
                <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
                <e:button id="Insert" name="Insert" label="${Insert_N }" disabled="${Insert_D }" onClick="doInsert" />
                <e:button id="Update" name="Update" label="${Update_N }" disabled="${Update_D }" onClick="doUpdate" />
                <e:button id="Delete" name="Delete" label="${Delete_N }" disabled="${Delete_D }" onClick="doDelete" />
            </c:if>
            <c:if test="${havePermission != true}">
                <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
            </c:if>
        </e:buttonBar>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>