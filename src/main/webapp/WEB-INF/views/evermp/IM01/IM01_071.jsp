<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM01/IM0101/";

        function init() {
            grid = EVF.C("grid");
            grid.setProperty('multiselect', false);
            grid.setProperty("shrinkToFit", true);

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == "REG_USER_NM") {
                    if(value!=""){
                        var param = {
                            callbackFunction: "",
                            USER_ID: grid.getCellValue(rowId, 'REG_USER_ID'),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                    }
                }else if(colId == "DEL_REQ_USER_NM") {
                    if(value!=""){
                        var param = {
                            callbackFunction: "",
                            USER_ID: grid.getCellValue(rowId, 'DEL_REQ_USER_ID'),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                    }
                }else if(colId == "MOD_USER_NM") {
                    if(value!=""){
                        var param = {
                            callbackFunction: "",
                            USER_ID: grid.getCellValue(rowId, 'MOD_USER_ID'),
                            detailView: true
                        };
                        everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                    }
                }



            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearch();
        }

        function doSearch(){
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "im01071_doSearch", function () {
            });

        }


    </script>

    <e:window id="IM01_071" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${param.ITEM_CD}"/>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>