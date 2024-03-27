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
        		if(colId == "DELY_NM") {
        			var selectedData = grid.getRowValue(rowId);
					opener['${param.callBackFunction}'](selectedData);
					doClose();
				}
			});
        	grid.setProperty('multiSelect', false);
			doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.setParameter("CUST_CD", "${param.CUST_CD}");
            store.setParameter("USER_ID", "${param.USER_ID}");
            store.load(baseUrl + 'my01006_doSearch', function() {
                
            });
        }

        function doClose() {
            window.close();
        }

    </script>
    <e:window id="MY01_006" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2" onEnter="doSearch">
            <e:row>
                <e:label for="DELY_NM" title="${form_DELY_NM_N}"/>
                <e:field>
                    <e:inputText id='DELY_NM' name="DELY_NM" label='${form_DELY_NM_N }' value="" width='${form_DELY_NM_W }' maxLength='${form_DELY_NM_M }' required='${form_DELY_NM_R }' readOnly='${form_DELY_NM_RO }' disabled='${form_DELY_NM_D }' visible='${form_DELY_NM_V }'/>
                </e:field>
                <e:label for="RECIPIENT_NM" title="${form_RECIPIENT_NM_N}"/>
                <e:field>
                    <e:inputText id='RECIPIENT_NM' name="RECIPIENT_NM" label='${form_RECIPIENT_NM_N }' value="" width='${form_RECIPIENT_NM_W }' maxLength='${form_RECIPIENT_NM_M }' required='${form_RECIPIENT_NM_R }' readOnly='${form_RECIPIENT_NM_RO }' disabled='${form_RECIPIENT_NM_D }' visible='${form_RECIPIENT_NM_V }'/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar width="100%" align="right">
            <e:button id='Search' name='Search' label='${Search_N }' disabled='${Search_D }' visible='${Search_V }' onClick='doSearch' />
            <%-- <e:button id='Close' name='Close' label='${Close_N }' disabled='${Close_D }' visible='${Close_V }' onClick='doClose' /> --%>
        </e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
 