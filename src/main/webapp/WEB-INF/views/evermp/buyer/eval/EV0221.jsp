<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

    var baseUrl = '/evermp/buyer/eval/EV0221';
    var grid;
    var selRow;

    function init() {
        grid = EVF.C('grid');

        grid.setProperty('panelVisible', ${panelVisible});
        doSearch();
    }

    <%-- 조회 --%>
    function doSearch() {
        var store = new EVF.Store();
        store.setGrid([grid]);
        store.load(baseUrl + '/doSearch', function() {
            if(grid.getRowCount() == 0) {
                EVF.alert("${msg.M0002 }");
            }
        });
    }
    <%-- 닫기 --%>
    function doClose() {
    	if( opener != null) {
    		opener.doSearch();
    	}
    	self.close();
    }



	function doSave() {
    	grid.checkAll(true);



		var vdIds = grid.getAllRowId();

    	for(var k =0; k < vdIds.length;k++){
			var esgFrom = grid.getCellValue(vdIds[k],'ESG_FROM');
			var esgTo = grid.getCellValue(vdIds[k],'ESG_TO');

			if(esgFrom > esgTo) {
                EVF.alert("${EV0221_0001}");
				return;
			}
    	}





		EVF.confirm('${msg.M0021 }', function () {
			var store = new EVF.Store();
			store.setGrid([grid]);
	        store.getGridData(grid,'sel');
	        store.load(baseUrl + '/doSave', function() {
	        	var msg = this.getResponseMessage();
		        	EVF.alert(msg);
	       });
        });


	}




    </script>
<e:window id="EV0221" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }">

    <e:searchPanel id="form" title="${msg.M9999}" columnCount="3" labelWidth="${labelWidth}" onEnter="doSearch" useTitleBar="false">
    	<e:inputHidden id="EV_NUM" name="EV_NUM" value="${param.EV_NUM}"/>
    </e:searchPanel>

    <e:buttonBar align="right">
		<e:button id="doSave" name="doSave" label="${doSave_N}" onClick="doSave" disabled="${doSave_D}" visible="${doSave_V}"/>
		<e:button id="doClose" name="doClose" label="${doClose_N}" onClick="doClose" disabled="${doClose_D}" visible="${doClose_V}"/>
    </e:buttonBar>

    <%-- 그리드 창 켜줌 --%>
    <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
</e:window>
</e:ui>
