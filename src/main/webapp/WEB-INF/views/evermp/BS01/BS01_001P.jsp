<%--기준정보 > 고객사정보관리 > 고객사관리--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/BS01/BS0101/";

        function init() {
            grid = EVF.C("grid");
            grid.showCheckBar(false);

            grid.cellClickEvent(function(rowId, colId, value) {
            	if (colId == "CH_REASON") {
            		if( grid.getCellValue(rowId, 'CH_REASON') != "" ) {
                		var param = {
                  				title : '변경사유',
                  				message : grid.getCellValue(rowId, 'CH_REASON'),
                  				detailView : true
                  			};
                		var url = '/common/popup/common_text_view/view';
                	    everPopup.openModalPopup(url, 500, 320, param);
            		}
                }
            });
            
            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            
            doSearch();
        }

        function doSearch() {
            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'bs01001p_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

    </script>
    
    <e:window id="BS01_001P" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}" />
				<e:field>
					<e:inputText id="CUST_CD" name="CUST_CD" value="${param.CUST_CD }" width="${form_CUST_CD_W}" maxLength="${form_CUST_CD_M}" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
				</e:field>
				<e:label for="CUST_NM" title="${form_CUST_NM_N}" />
				<e:field>
					<e:inputText id="CUST_NM" name="CUST_NM" value="${param.CUST_NM }" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
            </e:row>
        </e:searchPanel>
<%-- 
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" visible="${Search_V}" onClick="doSearch" />
        </e:buttonBar>
 --%>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>