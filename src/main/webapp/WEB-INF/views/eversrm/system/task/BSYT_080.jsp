<!--
* BSYT_080 : 사용자별-직무매핑 이력
* 시스템관리 > 기본정보 > 사용자별-직무매핑 이력
-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script type="text/javascript">

        var grid = {};
        var addParam = [];
        var baseUrl = "/eversrm/system/task/bsyt080/";
        var currentRow;

        function init() {

            grid = EVF.C('grid');
            grid.showCheckBar(false);
            grid.setProperty('panelVisible', ${panelVisible});


            grid.cellClickEvent(function(rowid, colId, value) {

            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });


        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + 'doSelect', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }


        function doUserSearch(handler) {
            var param = {
                "BUYER_CD": EVF.C('buyerCd').getValue(),
                "callBackFunction": handler
            };
            everPopup.openCommonPopup(param, "SP0011");
            //everPopup.openUserInChargeSearch(param);
        }

        function selectUserIdPopupIntoGrid(data) {
//			grid.setCellValue(currentRow, 'CTRL_USER_ID', data.USER_ID.text);

            grid.setCellValue(currentRow, 'CTRL_USER_ID', data.USER_ID);
            grid.setCellValue(currentRow, 'CTRL_USER_ID_ORI', data.USER_ID);
            grid.setCellValue(currentRow, 'USER_NM', data.USER_NM);
            grid.setCellValue(currentRow, 'DEPT_NM', data.DEPT_NM);

            var selectedRow = grid.getSelRowValue();
            var selRowIds = grid.getSelRowId();
            if (selectedRow.length > 1) {
                if (confirm('${BSYT_020_001}')) {
                    for(var x in selRowIds) {
                        var rowId = selRowIds[x];


                        if('${_gridType}' == 'RG') {
                            grid.setCellValue(rowId, 'CTRL_USER_ID', data.USER_ID);
                        } else {
                            grid.setCellValue(rowId, 'CTRL_USER_ID', data.USER_ID.text);
                        }

                        grid.setCellValue(rowId, 'USER_NM', data.USER_NM);
                        grid.setCellValue(rowId, 'DEPT_NM', data.DEPT_NM);
                    }
                }
            }
        }

        function doTaskSearch(handler) {
            var param = {
                BUYER_CD: grid.getCellValue(currentRow, 'BUYER_CD'),
                callBackFunction: handler
            };
            everPopup.openCommonPopup(param, "SP0003");
        }

        function selectTaskIdPopupIntoGrid(data) {

            if('${_gridType}' == 'RG') {
                grid.setCellValue(currentRow, 'CTRL_CD', data.CTRL_CD);
            } else {
                grid.setCellValue(currentRow, 'CTRL_CD', data.CTRL_CD.text);
            }


            grid.setCellValue(currentRow, 'CTRL_NM', data.CTRL_NM);

            var selectedRow = grid.getSelRowValue();
            var selRowIds = grid.getSelRowId();
            if (selectedRow.length > 1) {
                if (confirm('${BSYT_020_001}')) {
                    for(var x in selRowIds) {
                        var rowId = selRowIds[x];

                        if('${_gridType}' == 'RG') {
                            grid.setCellValue(rowId, 'CTRL_CD', data.CTRL_CD);
                        } else {
                            grid.setCellValue(rowId, 'CTRL_CD', data.CTRL_CD.text);
                        }

                        grid.setCellValue(rowId, 'CTRL_NM', data.CTRL_NM);
                    }
                }
            }
        }


        function getRegUserId() {
            var param = {
                callBackFunction : "setRegUserId"
            };
            everPopup.openCommonPopup(param, 'SP0011');
        }
        function setRegUserId(dataJsonArray) {
            EVF.C("USER_ID").setValue(dataJsonArray.USER_ID);
            EVF.C("USER_NM").setValue(dataJsonArray.USER_NM);
        }


    </script>

    <e:window id="BSYT_080" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${form_CAPTION_N }" columnCount="3" labelWidth="${labelNarrowWidth }" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="buyerCd" title="${form_buyerCd_N}"/>
                <e:field>
                    <e:select id="buyerCd" name="buyerCd" value="${form.buyerCd}" options="${refBuyerCode}" width="100%" disabled="${form_buyerCd_D}" readOnly="${form_buyerCd_RO}" required="${form_buyerCd_R}" usePlaceHolder="false" />
                </e:field>
                <e:label for="CTRL_NM" title="${form_CTRL_NM_N}" />
                <e:field>
                    <e:inputText id="CTRL_NM" name="CTRL_NM" value="" width="${form_CTRL_NM_W}" maxLength="${form_CTRL_NM_M}" disabled="${form_CTRL_NM_D}" readOnly="${form_CTRL_NM_RO}" required="${form_CTRL_NM_R}" />
                </e:field>
                <e:label for="USER_NM" title="${form_USER_NM_N }" />
                <e:field>
                    <e:search id="USER_ID" name="USER_ID" value="" width="40%" maxLength="${form_USER_ID_M}" onIconClick="getRegUserId" disabled="${form_USER_ID_D}" readOnly="${form_USER_ID_RO}" required="${form_USER_ID_R}" />
                    <e:inputText id="USER_NM" name="USER_NM"  value="" width="60%" maxLength="${form_USER_NM_M}" disabled="${form_USER_NM_D}" readOnly="${form_USER_NM_RO}" required="${form_USER_NM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>
        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N }" disabled="${Search_D }" onClick="doSearch" />
        </e:buttonBar>
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}"/>
    </e:window>
</e:ui>