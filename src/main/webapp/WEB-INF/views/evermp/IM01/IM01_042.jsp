<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0303/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == 'ITEM_CD') {
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            grid.setProperty('multiSelect', false);
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "im01042_doSearch", function () {

                grid.setColMerge(['VALID_FROM_DATE']);
                grid.setColMerge(['VALID_TO_DATE']);
                grid.setColMerge(['CONT_NM']);
                grid.setColMerge(['VENDOR_NM']);
                grid.setColMerge(['VALID_FLAG']);

            }, false);
        }

    </script>

    <e:window id="IM01_042" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:inputHidden id="ITEM_CD" name="ITEM_CD" value="${param.ITEM_CD}" />
        <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}" />
        <e:inputHidden id="CONT_STATUS_CD" name="CONT_STATUS_CD" value="${param.CONT_STATUS_CD}" />
        <e:inputHidden id="VALID_FROM_DATE" name="VALID_FROM_DATE" value="${param.VALID_FROM_DATE}" />
        <e:inputHidden id="VALID_TO_DATE" name="VALID_TO_DATE" value="${param.VALID_TO_DATE}" />

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>