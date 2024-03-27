<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var baseUrl = "/evermp/MY03/";
        var grid;

        function init() {

            grid = EVF.C("grid");
            grid.setProperty('panelVisible', true);
            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setProperty('multiSelect', false);
            grid.freezeCol("DATA_TYPE");
            // grid._gvo.orderBy(["DATA_SUM"],["ascending"]);
        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + 'my03094_doSearch', function() {
                if(grid.getRowCount() == 0){
                    return alert("${msg.M0002 }");
                }
                grid.setColMerge(['CUST_NM','RELAT_YN','MANAGE_NM','CPO_YEAR']);

                var val = {"visible": true, "count": 5, "height": 110};
                grid.setProperty('footerVisible', val);

                // 매출실적 달별 합계
                var style = {
                    textAlignment: "center",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                };

                var footerTxt = {
                    styles: style,
                    text: ["합 계"]
                };
                grid.setRowFooter("CUST_NM", footerTxt);

                var footerTxt2 = {
                    styles: style,
                    text: ["매출목표", "매출실적", "달성율", "매출이익", "매출이익률"]
                };
                grid.setRowFooter("DATA_TYPE", footerTxt2);

                var goalAmt = grid.getRowValue(grid.getRowCount() - 5);
                var goalKey = Object.keys(goalAmt);

                var salAmt = grid.getRowValue(grid.getRowCount() - 4);
                var salKey = Object.keys(salAmt);

                var attAmt = grid.getRowValue(grid.getRowCount() - 3);
                var attKey = Object.keys(attAmt);

                var profitAmt = grid.getRowValue(grid.getRowCount() - 2);
                var profitKey = Object.keys(profitAmt);

                var profitRateAmt = grid.getRowValue(grid.getRowCount() - 1);
                var profitRateKey = Object.keys(profitRateAmt);

                for(var i in salKey) {
                    if(!(salKey[i] == "CUST_NM" || salKey[i] == "RELAT_YN" || salKey[i] == "MANAGE_NM" ||
                            salKey[i] == "CPO_YEAR" || salKey[i] == "DATA_TYPE")) {

                        var footerSum = {
                            styles: {
                                textAlignment: "far",
                                suffix: " ",
                                background:"#ffffff",
                                foreground:"#FF0000",
                                fontBold: true
                            },
                            text: [goalAmt[goalKey[i]], salAmt[salKey[i]],
                                everString.isNanToZero(everMath.round_float(((everString.replaceAll(salAmt[salKey[i]], ",", "") / everString.replaceAll(goalAmt[goalKey[i]], ",", "")) * 100), 1)) + "%",
                                profitAmt[profitKey[i]],
                                everString.isNanToZero(everMath.round_float(((everString.replaceAll(profitAmt[profitKey[i]], ",", "") / everString.replaceAll(salAmt[salKey[i]], ",", "")) * 100), 1)) + "%"]
                        };

                        grid.setRowFooter(salKey[i], footerSum);
                    }
                }

                grid._gvo.setFooter({
		            'mergeCells' : ["CUST_NM", "RELAT_YN", "MANAGE_NM", "CPO_YEAR"]
	            });

                // 합계 그리드 삭제
                var delMaxCnt = grid.getRowCount() - 5;
                for(var i = grid.getRowCount() - 1; i >= delMaxCnt; i--) {
                    grid.delRow(i);
                }
            });
        }

    </script>

    <e:window id="MY03_094" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
                <e:label for="CPO_YEAR" title="${form_CPO_YEAR_N}" />
                <e:field colSpan="3">
                    <e:select id="CPO_YEAR" name="CPO_YEAR" value="${thisYear}" options="${cpoYearOptions}" width="110px" disabled="${form_CPO_YEAR_D}" readOnly="${form_CPO_YEAR_RO}" required="${form_CPO_YEAR_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>
        
    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
