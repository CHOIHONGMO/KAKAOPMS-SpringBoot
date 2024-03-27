<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var baseUrl = "/evermp/IM02/IM0201/";
        var grid = {};
        var selRow;
        var newMode = false;

        function init() {

        	grid = EVF.C('grid');
            grid.setProperty('shrinkToFit', true);


            grid.cellClickEvent(function(rowId, colId, value) {

            	if(colId == "ITEM_CD") {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_014open(param);
				}
            });
            doSearch();
        }


        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'im02013_doSearch', function() {
            });
        }

	</script>

    <e:window id="IM02_013" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
   
		<e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${param.ITEM_CD}"/>
		<e:inputHidden id="CUST_CD" name="CUST_CD" value="${param.CUST_CD}"/>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>