<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

		var grid;
        var baseUrl = "/eversrm/buyer/bmy";

        function init() {

        	grid = EVF.C("grid");

        	grid.cellClickEvent(function(rowId, colId, value) {
        		if(colId == "CUBL_NM") {
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
            store.load(baseUrl + '/BMY01_040_doSearch', function() {
                
            });
        }

        function doClose() {
            window.close();
        }

    </script>
    <e:window id="BMY01_040" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" useTitleBar="false" width="100%" columnCount="2" onEnter="doSearch">
            <e:row>
                <e:label for="CUBL_NM" title="${form_CUBL_NM_N}"/>
                <e:field>
                    <e:inputText id='CUBL_NM' name="CUBL_NM" label='${form_CUBL_NM_N }' value="${param.CUBL_NM}" width='${form_CUBL_NM_W }' maxLength='${form_CUBL_NM_M }' required='${form_CUBL_NM_R }' readOnly='${form_CUBL_NM_RO }' disabled='${form_CUBL_NM_D }' visible='${form_CUBL_NM_V }'/>
                </e:field>
                <e:label for="CUBL_COMPANY_NM" title="${form_CUBL_COMPANY_NM_N}"/>
                <e:field>
                    <e:inputText id='CUBL_COMPANY_NM' name="CUBL_COMPANY_NM" label='${form_CUBL_COMPANY_NM_N }' value="" width='${form_CUBL_COMPANY_NM_W }' maxLength='${form_CUBL_COMPANY_NM_M }' required='${form_CUBL_COMPANY_NM_R }' readOnly='${form_CUBL_COMPANY_NM_RO }' disabled='${form_CUBL_COMPANY_NM_D }' visible='${form_CUBL_COMPANY_NM_V }'/>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar width="100%" align="right">
            <e:button id='Search' name='Search' label='${Search_N }' disabled='${Search_D }' visible='${Search_V }' onClick='doSearch' />
            <e:button id='Close' name='Close' label='${Close_N }' disabled='${Close_D }' visible='${Close_V }' onClick='doClose' />
        </e:buttonBar>

		<e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
 