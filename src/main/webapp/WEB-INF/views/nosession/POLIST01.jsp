<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

    	var grid = {};
    	var addParam = [];
    	var baseUrl = "/";

		function init() {
			grid = EVF.C('grid');
			grid.setProperty('panelVisible', ${panelVisible});

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function doSearch() {
        	var store = new EVF.Store();
        	store.setGrid([grid]);
            store.load(baseUrl + 'poList01', function() {
            });
        }

		function doClose() {
			window.close();
		}



    </script>
    <e:window id="POLIST01" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" onEnter="doSearch" useTitleBar="false">

        	<e:inputHidden id="TXTNO" name="TXTNO" value="${param.TXTNO}"/>
        	<e:row>
        		<e:inputHidden id="" name=""/>
				<e:label for="FROM_DATE" title="${form_FROM_DATE_N}"/>
				<e:field>
				<e:inputDate id="FROM_DATE" name="FROM_DATE" value="${addFromDate}" width="${inputDateWidth}" datePicker="true" required="${form_FROM_DATE_R}" disabled="${form_FROM_DATE_D}" readOnly="${form_FROM_DATE_RO}" />
				<e:text>~</e:text>
				<e:inputDate id="TO_DATE" name="TO_DATE" value="${addToDate}" width="${inputDateWidth}" datePicker="true" required="${form_TO_DATE_R}" disabled="${form_TO_DATE_D}" readOnly="${form_TO_DATE_RO}" />
				</e:field>
				<e:label for="TXTUSEREMAIL" title="${form_TXTUSEREMAIL_N}" />
				<e:field>
				<e:inputText id="TXTUSEREMAIL" name="TXTUSEREMAIL" value="${param.TXTUSEREMAIL}" width="${form_TXTUSEREMAIL_W}" maxLength="${form_TXTUSEREMAIL_M}" disabled="${form_TXTUSEREMAIL_D}" readOnly="${form_TXTUSEREMAIL_RO}" required="${form_TXTUSEREMAIL_R}" />
				</e:field>
            </e:row>
            <e:row>
				<e:label for="JOSIK_NAME1" title="${form_JOSIK_NAME1_N}" />
				<e:field>
				<e:inputText id="JOSIK_NAME1" name="JOSIK_NAME1" value="" width="${form_JOSIK_NAME1_W}" maxLength="${form_JOSIK_NAME1_M}" disabled="${form_JOSIK_NAME1_D}" readOnly="${form_JOSIK_NAME1_RO}" required="${form_JOSIK_NAME1_R}" />
				</e:field>
				<e:label for="JOSIK_NAME2" title="${form_JOSIK_NAME2_N}" />
				<e:field>
				<e:inputText id="JOSIK_NAME2" name="JOSIK_NAME2" value="" width="${form_JOSIK_NAME2_W}" maxLength="${form_JOSIK_NAME2_M}" disabled="${form_JOSIK_NAME2_D}" readOnly="${form_JOSIK_NAME2_RO}" required="${form_JOSIK_NAME2_R}" />
				</e:field>

            </e:row>
            <e:row>
				<e:label for="JOSIK_NAME3" title="${form_JOSIK_NAME3_N}" />
				<e:field>
				<e:inputText id="JOSIK_NAME3" name="JOSIK_NAME3" value="" width="${form_JOSIK_NAME3_W}" maxLength="${form_JOSIK_NAME3_M}" disabled="${form_JOSIK_NAME3_D}" readOnly="${form_JOSIK_NAME3_RO}" required="${form_JOSIK_NAME3_R}" />
				</e:field>
				<e:label for="JOSIK_NAME4" title="${form_JOSIK_NAME4_N}" />
				<e:field>
				<e:inputText id="JOSIK_NAME4" name="JOSIK_NAME4" value="" width="${form_JOSIK_NAME4_W}" maxLength="${form_JOSIK_NAME4_M}" disabled="${form_JOSIK_NAME4_D}" readOnly="${form_JOSIK_NAME4_RO}" required="${form_JOSIK_NAME4_R}" />
				</e:field>

            </e:row>
            <e:row>
				<e:label for="JOSIK_NAME5" title="${form_JOSIK_NAME5_N}" />
				<e:field colSpan="3">
				<e:inputText id="JOSIK_NAME5" name="JOSIK_NAME5" value="" width="${form_JOSIK_NAME5_W}" maxLength="${form_JOSIK_NAME5_M}" disabled="${form_JOSIK_NAME5_D}" readOnly="${form_JOSIK_NAME5_RO}" required="${form_JOSIK_NAME5_R}" />
				</e:field>


            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
			<e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
			<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>