<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0304/";

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('shrinkToFit', true);

            if('${param.detailView}' == 'true') {

            }

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearch();

        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load("/evermp/IM04/IM0407/doSearch", function () {


                var beforeStr = '${param.AT_DATA}';
                var setAtList = beforeStr.split('@');

                var allRowId = grid.getAllRowId();
                for(var i in allRowId) {
                    var rowId = allRowId[i];
                    for(var i =0; i<setAtList.length; i++){
                        var setAtValue = setAtList[i].split('|');
                        if(grid.getCellValue(rowId, 'ATTR_CD')==setAtValue[0]){
                            grid.setCellValue(rowId, 'ATTR_VALUE', setAtValue[1]);
                        }
                    }
                }
            });
        }
        
        function doSelect() {

            if (!grid.isExistsSelRow()) { return alert('${msg.M0004}'); }
            var allRowId = grid.getAllRowId();
            for(var i in allRowId) {
                var rowId = allRowId[i];
                if(grid.getCellValue(rowId, 'REQUIRED_FLAG')=="1"){
                    if(grid.getCellValue(rowId, 'ATTR_VALUE')==""||grid.getCellValue(rowId, 'ATTR_VALUE')==null){
                        return alert('${IM03_011_001}');
                    }
                }
            }

            var selectedData = grid.getSelRowValue();

            parent['${param.callBackFunction}'](selectedData);

            new EVF.ModalWindow().close(null);
        }



    </script>

    <e:window id="IM03_011" onReady="init" initData="${initData}" title="${fullScreenName}">

        <c:if test="${param.detailView != 'true' }">
            <e:buttonBar align="right" width="100%">
                <e:button id="Select" name="Select" label="${Select_N}" onClick="doSelect" disabled="${Select_D}" visible="${Select_V}"/>
            </e:buttonBar>
        </c:if>

        <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" value="${param.ITEM_CLS1}"/>
        <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" value="${param.ITEM_CLS2}"/>
        <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" value="${param.ITEM_CLS3}"/>
        <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" value="${param.ITEM_CLS4}"/>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>