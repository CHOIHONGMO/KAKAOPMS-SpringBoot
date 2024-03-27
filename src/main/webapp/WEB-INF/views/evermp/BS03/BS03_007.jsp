<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/BS03/BS0301/";

        function init() {
            grid = EVF.C("grid");
            grid.cellClickEvent(function(rowId, colId, value) {
                if (colId == "CH_REASON_YN") {
                    if(value!=""){
                        var param = {
                            title: "회사주소, 대표자명 변경사유",
                            message: grid.getCellValue(rowId, 'CH_REASON'),
                            detailView: 'true'
                        };
                        everPopup.commonTextInput(param);
                    }
                }
                if(colId === 'CH_USER_NM') {
                    var param = {
                        callbackFunction: "",
                        USER_ID: grid.getCellValue(rowId, "CH_USER_ID"),
                        detailView: true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.setColIconify("CH_REASON_YN", "CH_REASON_YN", "detail", false);

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            doSearch();
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "bs03007_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
            });
        }

    </script>

    <e:window id="BS03_007" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">

            <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="${param.VENDOR_CD}"></e:inputHidden>
            <e:row>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}" />
                <e:field>
                    <e:text>${param.VENDOR_CD }</e:text>
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:text>${param.VENDOR_NM }</e:text>
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>