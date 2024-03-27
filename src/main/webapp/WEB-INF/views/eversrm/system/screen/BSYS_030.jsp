<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var baseUrl = "/eversrm/system/screen/";

		function init() {

			grid = EVF.C('grid');

			if ('${param.screenId}' != '') {
	            EVF.C('SCREEN_ID').setValue('${param.screenId}');
	            doSearch();
	        }

			grid.cellClickEvent(function(rowid, celname, value, iRow, iCol) {
				if (celname == "SCREEN_ID") {
					var selectedData = grid.getRowValue(rowid);
		       		opener.selectScreen(selectedData);
		       		window.close();
		        }
			});

			grid.setProperty('shrinkToFit', false);
        }

        function search() {

        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'screenIdPopup/doSearch', function() {
                if(grid.getRowCount() == 0){
                	alert("${msg.M0002 }");
                }
            });
        }

	    function close2() {
	        window.close();
	    }

    </script>
    <e:window id="BSYS_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelNarrowWidth }" onEnter="search" useTitleBar="false">
        	<e:row>
                <e:label for="MODULE_TYPE" title="${form_MODULE_TYPE_N }" />
                <e:field>
                    <e:select id="MODULE_TYPE" name="MODULE_TYPE" options="${refModuleType}" readOnly="${form_MODULE_TYPE_RO }" width="${form_MODULE_TYPE_W }" required="${form_MODULE_TYPE_R }" disabled="${form_MODULE_TYPE_D }" onFocus="onFocus" />
                </e:field>
                <e:label for="SCREEN_ID" title="${form_SCREEN_ID_N }" />
                <e:field>
                	<e:inputText id="SCREEN_ID" name="SCREEN_ID" width="${form_SCREEN_ID_W }" required="${form_SCREEN_ID_R }" disabled="${form_SCREEN_ID_D }" value="" style="${imeMode }" readOnly="${form_SCREEN_ID_RO }" maxLength="${form_SCREEN_ID_M}" />
                </e:field>
                <e:label for="SCREEN_NM" title="${form_SCREEN_NM_N }" />
                <e:field>
	                <e:inputText id="SCREEN_NM" name="SCREEN_NM" width="${form_SCREEN_NM_W }" required="${form_SCREEN_NM_R }" disabled="${form_SCREEN_NM_D }" style="${imeMode }" readOnly="${form_SCREEN_NM_RO }" maxLength="${form_SCREEN_NM_M}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="search" />
            <%-- <e:button id="Close" name="Close" label="${Close_N }" disabled="${Close_D }" onClick="close2" /> --%>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>

    </e:window>
</e:ui>