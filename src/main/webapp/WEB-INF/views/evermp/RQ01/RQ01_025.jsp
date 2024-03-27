<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/RQ01/RQ0102/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'VENDOR_NM') {
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
                if(colId == 'GIVEUP_REASON') {
                    if(!EVF.isEmpty(grid.getCellValue(rowId, "GIVEUP_REASON"))) {
                        var param = {
                            title: "${RQ01_025_001}",
                            message: grid.getCellValue(rowId, 'GIVEUP_REASON')
                        };
                        everPopup.openModalPopup('/common/popup/common_text_view/view', 500, 300, param);
                    }
                }
            });

            grid.setColIconify("GIVEUP_REASON", "GIVEUP_REASON", "comment", false);

            grid.setProperty('shrinkToFit', true);
            grid.setProperty('multiSelect', false);
            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.setParameter("RFQ_NUM", "${param.RFQ_NUM}");
            store.setParameter("RFQ_CNT", "${param.RFQ_CNT}");
            store.load(baseUrl + "rq01025_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
                var rowIds = grid.getAllRowId();
                for(var i in rowIds) {
                    if(grid.getCellValue(rowIds[i], 'SEND_FLAG_CD') == "150") {
                        grid.setCellFontColor(rowIds[i], 'SEND_FLAG_NM', "#ff6928");
                        grid.setCellFontWeight(rowIds[i], "SEND_FLAG_NM", true);
                    }
                }
            });
        }

        function doClose() {
            formUtil.close();
        }

    </script>

    <e:window id="RQ01_025" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>