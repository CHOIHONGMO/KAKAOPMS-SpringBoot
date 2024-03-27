<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var grid;
        var baseUrl = "/evermp/OD01/OD0101/";

        function init() {

            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
                if(colId == "multiSelect") {
                    var GR_ITEM_AMT = 0;
                    var PO_ITEM_AMT = 0;
                    var MARGIN_RATE = 0;

                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        GR_ITEM_AMT += Number(rows[i].UNIT_AMT);
                        PO_ITEM_AMT += Number(rows[i].LIST_AMT);
                    }

                    if(PO_ITEM_AMT > 0) {
                        MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
                    }

                    EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT)) + " 원");
                    EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT)) + " 원");
                    EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT - PO_ITEM_AMT)) + " 원");
                    EVF.V("MARGIN_RATE", String(MARGIN_RATE) + " %");
                } else if(colId == "AP_TAX_NUM" || colId == "AR_TAX_NUM") {
                    EVF.V("TAX_NUM", value);
                    doSearch();
                }
            });

            grid._gvo.onItemAllChecked = function(gridView, checked) {
                var GR_ITEM_AMT = 0;
                var PO_ITEM_AMT = 0;
                var MARGIN_RATE = 0;

                if(checked) {
                    var rows = grid.getSelRowValue();
                    for( var i = 0; i < rows.length; i++ ) {
                        GR_ITEM_AMT += Number(rows[i].UNIT_AMT);
                        PO_ITEM_AMT += Number(rows[i].LIST_AMT);
                    }

                    if(GR_ITEM_AMT > 0) {
                        MARGIN_RATE = everMath.round_float(((GR_ITEM_AMT - PO_ITEM_AMT)/ GR_ITEM_AMT) * 100, 1);
                    }

                    EVF.V("TOT_GR_AMT", comma(String(GR_ITEM_AMT)) + " 원");
                    EVF.V("TOT_PO_AMT", comma(String(PO_ITEM_AMT)) + " 원");
                    EVF.V("MARGIN_AMT", comma(String(GR_ITEM_AMT - PO_ITEM_AMT)) + " 원");
                    EVF.V("MARGIN_RATE", String(MARGIN_RATE) + " %");
                } else {
                    EVF.V("TOT_GR_AMT", "0 원");
                    EVF.V("TOT_PO_AMT", "0 원");
                    EVF.V("MARGIN_AMT", "0 원");
                    EVF.V("MARGIN_RATE", "0 %");
                }
            };

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            grid.setColGroup([{
                    groupName: "고객사",
                    columns: [ "RCOM_NM", "RIRS_NUM", "RCEO_NM", "RBUSINESS_TYPE", "RINDUSTRY_TYPE", "RADDR",
                            "RUSER_NM", "RUSER_TEL_NO", "RUSER_EMAIL", "RTAX_TYPE", "RSUP_AMT", "RTAX_AMT", "RTAX_SUM", "RSUBJECT_ITEM_NM"]
                }, {
                    groupName: "공급사",
                    columns: [ "SCOM_NM", "SIRS_NUM", "SCEO_NM", "SBUSINESS_TYPE", "SINDUSTRY_TYPE", "SADDR",
                            "SUSER_NM", "SUSER_TEL_NO", "SUSER_EMAIL", "STAX_TYPE", "SSUP_AMT", "STAX_AMT", "STAX_SUM", "SSUBJECT_ITEM_NM"]
            }], 45);

            var val = {"visible": true, "count": 1, "height": 40};

            var footerTxt = {
                styles: {
                    textAlignment: "far",
                    font: "굴림,12",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: ["합 계 "]
            };

            var footerSum_UNIT_AMT = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    numberFormat: "###,###.##",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: "0 ",
                expression: ["sum['UNIT_AMT']"],
                groupExpression: "sum"
            };

            var footerSum_LIST_AMT = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    numberFormat: "###,###.##",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: "0 ",
                expression: ["sum['LIST_AMT']"],
                groupExpression: "sum"
            };

            var footerSum_MARGIN_AMT = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    numberFormat: "###,###.##",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: "0 ",
                expression: ["sum['MARGIN_AMT']"],
                groupExpression: "sum"
            };

            var footerSum_RATE = {
                styles: {
                    textAlignment: "far",
                    suffix: " ",
                    numberFormat: "###,###.##",
                    background:"#ffffff",
                    foreground:"#FF0000",
                    fontBold: true
                },
                text: "0 ",
                expression: ["(sum['UNIT_AMT'] - sum['LIST_AMT'])/sum['UNIT_AMT']*100"],
                groupExpression: "sum"
            };

            grid.setProperty("footerVisible", val);
            grid.setRowFooter("UNIT_PRICE", footerTxt);
            grid.setRowFooter("UNIT_AMT", footerSum_UNIT_AMT);
            grid.setRowFooter("LIST_AMT", footerSum_LIST_AMT);
            grid.setRowFooter("MARGIN_AMT", footerSum_MARGIN_AMT);
            grid.setRowFooter("ITEM_AMT_RATE", footerSum_RATE);
        }

        function doSearch() {
            var store = new EVF.Store();
            if (!store.validate()) { return; }
            store.setGrid([grid]);
            store.load(baseUrl + "OD01040_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }

                var TOT_AMT = Number(grid._gvo.getSummary("UNIT_AMT", "SUM"));
                EVF.V("TOT_AMT", comma(String(TOT_AMT)) + " 원");
            });
        }

        function comma(obj) {
            var regx = new RegExp(/(-?\d+)(\d{3})/);
            var bExists = obj.indexOf(".", 0);//0번째부터 .을 찾는다.
            var strArr = obj.split('.');
            while (regx.test(strArr[0])) {//문자열에 정규식 특수문자가 포함되어 있는지 체크
                //정수 부분에만 콤마 달기
                strArr[0] = strArr[0].replace(regx, "$1,$2");//콤마추가하기
            }
            if (bExists > -1) {
                //. 소수점 문자열이 발견되지 않을 경우 -1 반환
                obj = strArr[0] + "." + strArr[1];
            } else { //정수만 있을경우 //소수점 문자열 존재하면 양수 반환
                obj = strArr[0];
            }
            return obj;//문자열 반환
        }
    </script>

    <e:window id="OD01_040" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${inputNumberWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
                <e:label for="START_DATE">
                    <e:select id="START_DATE_COMBO" name="START_DATE_COMBO" width="99" disabled="false" readOnly="false" required="false" usePlaceHolder="false">
                        <e:option text="${OD01_040_002}" value="AR_DATE"/>
                        <e:option text="${OD01_040_003}" value="AP_DATE"/>
                        <e:option text="${OD01_040_004}" value="CPO_DATE"/>
                        <e:option text="${OD01_040_005}" value="GR_DATE"/>
                    </e:select>
                </e:label>
                <e:field>
                    <e:inputDate id="START_DATE" name="START_DATE" toDate="END_DATE" value="${START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
                    <e:text>~</e:text>
                    <e:inputDate id="END_DATE" name="END_DATE" fromDate="START_DATE" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
                </e:field>
                <e:label for="CUST_NM" title="${form_CUST_NM_N}" />
                <e:field>
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="${form_CUST_NM_W}" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="CPO_USER_ID_NM" title="${form_CPO_USER_ID_NM_N}" />
                <e:field>
                    <e:inputText id="CPO_USER_ID_NM" name="CPO_USER_ID_NM" value="" width="${form_CPO_USER_ID_NM_W}" maxLength="${form_CPO_USER_ID_NM_M}" disabled="${form_CPO_USER_ID_NM_D}" readOnly="${form_CPO_USER_ID_NM_RO}" required="${form_CPO_USER_ID_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
                <e:field>
                    <e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
                </e:field>
                <e:label for="ITEM_KEY" title="${form_ITEM_KEY_N}" />
                <e:field>
                    <e:inputText id="ITEM_KEY" name="ITEM_KEY" value="" width="${form_ITEM_KEY_W}" maxLength="${form_ITEM_KEY_M}" disabled="${form_ITEM_KEY_D}" readOnly="${form_ITEM_KEY_RO}" required="${form_ITEM_KEY_R}" />
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}" />
                <e:field>
                    <e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="PROGRESS_CD" title="${form_PROGRESS_CD_N}"/>
                <e:field>
                    <e:select id="PROGRESS_CD" name="PROGRESS_CD" value="" options="${progressCdOptions}" width="${form_PROGRESS_CD_W}" disabled="${form_PROGRESS_CD_D}" readOnly="${form_PROGRESS_CD_RO}" required="${form_PROGRESS_CD_R}" placeHolder="">
                        <e:option text="매출매입마감" value="매출매입마감"/>
                        <e:option text="매입마감" value="매입마감"/>
                        <e:option text="매출마감" value="매출마감"/>
                    </e:select>
                </e:field>
                <e:label for="TAX_NUM" title="${form_TAX_NUM_N}" />
                <e:field>
                    <e:inputText id="TAX_NUM" name="TAX_NUM" value="" width="${form_TAX_NUM_W}" maxLength="${form_TAX_NUM_M}" disabled="${form_TAX_NUM_D}" readOnly="${form_TAX_NUM_RO}" required="${form_TAX_NUM_R}" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:panel width="60%">
            <div style="float: left;margin-top: 3px;">
                <e:button id="doCanclePO" name="doCanclePO"  align="left" label="${doCanclePO_N}" onClick="doCanclePO" disabled="${doCanclePO_D}" visible="${doCanclePO_V}"/>
                <e:text style="color:blue;font-weight:bold;">[ 총금액 : </e:text>
                <e:text id="TOT_AMT" name="TOT_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
                <e:text style="color:blue;font-weight:bold;">][ 매출금액: </e:text>
                <e:text id="TOT_GR_AMT" name="TOT_GR_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
                <e:text style="color:blue;font-weight:bold;">][ 매입금액: </e:text>
                <e:text id="TOT_PO_AMT" name="TOT_PO_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
                <e:text style="color:blue;font-weight:bold;">][ 매출이익금: </e:text>
                <e:text id="MARGIN_AMT" name="MARGIN_AMT" style="color:blue;font-weight:bold;">0 원</e:text>
                <e:text style="color:blue;font-weight:bold;">][ 매출이익율: </e:text>
                <e:text id="MARGIN_RATE" name="MARGIN_RATE" style="color:blue;font-weight:bold;">0 %</e:text>
                <e:text style="color:blue;font-weight:bold;">]</e:text>
            </div>
        </e:panel>
        <e:panel width="40%">
            <e:buttonBar width="100%" align="right">
                <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
            </e:buttonBar>
        </e:panel>
        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />
    </e:window>
</e:ui>