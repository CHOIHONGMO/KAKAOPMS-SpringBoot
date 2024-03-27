<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<%
	String date_1 = EverDate.getShortDateString();
	String date_7 = EverDate.addDateDay(date_1, -7);
	String date_15 = EverDate.addDateDay(date_1, -15);
	String date_30 = EverDate.addDateMonth(date_1, -1);
%>
<c:set var="date_1" value="<%=date_1%>" />
<c:set var="date_7" value="<%=date_7%>" />
<c:set var="date_15" value="<%=date_15%>" />
<c:set var="date_30" value="<%=date_30%>" />

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script>
    var baseUrl = "/evermp/MY03/";
    var grid;
	
    function init() {
    	grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
        	var param;

        	if (colId === "VENDOR_NM") {
                param = {
					VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
					detailView: true,
					popupFlag: true
                    };
                everPopup.openPopupByScreenId("BS03_002", 1000, 700, param);
            } else if (colId === "AM_USER_NM") {
                if( grid.getCellValue(rowId, "AM_USER_ID") == "" ) return;
                param = {
                    callbackFunction : "",
                    USER_ID : grid.getCellValue(rowId, "AM_USER_ID"),
                    detailView : true
                };
                everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
            } else if (colId === "PO_ITEM_AMT") {
				var START_DATE = "";
				var END_DATE = "";

				if("D" == EVF.V("DATE_SEL")) {
					var s = new Date(EVF.V("MYEAR"), EVF.V("MONTH") - 1, 1);
					var e = new Date(EVF.V("MYEAR"), EVF.V("MONTH"), 0);
					START_DATE = s.getFullYear() + "" + (s.getMonth() + 1) + "01";
					END_DATE = e.getFullYear() + "" + (e.getMonth() + 1) + "" + e.getDate();
				} else if("W" == EVF.V("DATE_SEL")) {

					if("Q1" == EVF.V("QUARTER")) {
						START_DATE = EVF.V("QYEAR") + "0101";
						END_DATE = EVF.V("QYEAR") + "0331";
					} else if("Q2" == EVF.V("QUARTER")) {
						START_DATE = EVF.V("QYEAR") + "0401";
						END_DATE = EVF.V("QYEAR") + "0631";
					} else if("Q3" == EVF.V("QUARTER")) {
						START_DATE = EVF.V("QYEAR") + "0701";
						END_DATE = EVF.V("QYEAR") + "0931";
					} else if("Q4" == EVF.V("QUARTER")) {
						START_DATE = EVF.V("QYEAR") + "1001";
						END_DATE = EVF.V("QYEAR") + "1231";
					}
				} else if("B" == EVF.V("DATE_SEL")) {
					if("H1" == EVF.V("HALF_YEAR")) {
						START_DATE = EVF.V("HYEAR") + "0101";
						END_DATE = EVF.V("HYEAR") + "0631";
					} else if("H2" == EVF.V("HALF_YEAR")) {
						START_DATE = EVF.V("HYEAR") + "0701";
						END_DATE = EVF.V("HYEAR") + "1231";
					}
				} else if("M" == EVF.V("DATE_SEL")) {
					START_DATE = EVF.V("YEAR") + "0101";
					END_DATE = EVF.V("YEAR") + "1231";
				}

                param = {
                    LINK_ID: "MY03_060",
                    VENDOR_CD: grid.getCellValue(rowId, "VENDOR_CD"),
                    VENDOR_NM: grid.getCellValue(rowId, "VENDOR_NM"),
                    START_DATE: START_DATE,
                    END_DATE: END_DATE,
                    CLOSE_YN: "N"
                };

                var el = parent.parent.document.getElementById("mainIframe");
                top.pageRedirectByScreenId("OD01_010", param);
            }
		});
        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.setColGroup([{
            groupName: "${MY03_060_007}",
            columns: [ "PO_ITEM_AMT", "CPO_CNT", "ITEM_CNT"]
        }, {
            groupName: "${MY03_060_008}",
            columns: [ "RQ_CNT", "IV_CNT", "A_AVG_LT_DAY", "C_AVG_LT_DAY", "STD_DELY_RATE", "VOC_CNT"]
        }], 45);

        grid.showCheckBar(false);

        clickCPO_DATE_SEL("INIT");
    }

    function doSearch() {
        var store = new EVF.Store();    
        if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + 'my03060_doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
                var val = {visible: true, count: 1, height: 40};
                var footerTxt = {
                    styles: {
                        textAlignment: "center",
                        font: "굴림,12",
                        background:"#ffffff",
                        foreground:"#FF0000",
                        fontBold: true
                    },
                    text: ["합    계"]
                };
                var footerSum = {
                    styles: {
                        textAlignment: "far",
                        suffix: " ",
                        background:"#ffffff",
                        foreground:"#FF0000",
                        numberFormat: "###,###.##",
                        fontBold: true
                    },
                    text: "0",
                    expression: ["sum"],
                    groupExpression: "sum"
                };

                var footerSum_PO = {
                    styles: {
                        textAlignment: "far",
                        suffix: " ",
                        background:"#ffffff",
                        foreground:"#FF0000",
                        numberFormat: "###,###.##",
                        fontBold: true
                    },
                    text: "0",
                    expression: ["sum['S_PO_ITEM_AMT']"],
                    groupExpression: "sum"
                };

                grid.setProperty("footerVisible", val);
                grid.setRowFooter("VENDOR_NM", footerTxt);
                grid.setRowFooter("PO_ITEM_AMT", footerSum_PO);
                grid.setRowFooter("CPO_CNT", footerSum);
                grid.setRowFooter("RQ_CNT", footerSum);
                grid.setRowFooter("IV_CNT", footerSum);
                grid.setRowFooter("A_AVG_LT_DAY", footerSum);
                grid.setRowFooter("C_AVG_LT_DAY", footerSum);
                grid.setRowFooter("VOC_CNT", footerSum);
            }
        });
    }

    function searchVENDOR_CD() {
        var param = {
            callBackFunction: "callbackVENDOR_CD"
        };
        everPopup.openCommonPopup(param, "SP0063");
    }

    function callbackVENDOR_CD(data) {
        EVF.V("VENDOR_CD", data.VENDOR_CD);
        EVF.V("VENDOR_NM", data.VENDOR_NM);
    }

    function clickCPO_DATE_SEL(s) {
		if("INIT" === s) {
			EVF.C("START_DATE").setReadOnly(true);
			EVF.C("END_DATE").setReadOnly(true);
			EVF.C('START_DATE').setRequired(false);
			EVF.C('END_DATE').setRequired(false);
			EVF.C('MONTH').setRequired(false);
			EVF.C('QUARTER').setRequired(false);
			EVF.C('HALF_YEAR').setRequired(false);
			EVF.V("YEAR", "${thisYear}");
			//EVF.C('YEAR').setRequired(true);
			EVF.C('MYEAR').setRequired(false);
			EVF.C('QYEAR').setRequired(false);
			EVF.C('HYEAR').setRequired(false);
			$('#D').css('display', 'none');
			$('#W').css('display', 'none');
			$('#B').css('display', 'none');
			$('#M').css('display', 'block');
			$('#S').css('display', 'none');
		}
		else {

			var DATE_SEL = EVF.V("DATE_SEL");

			<%-- 1달 --%>
			if("D" === DATE_SEL) {
				EVF.C("START_DATE").setReadOnly(true);
				EVF.C("END_DATE").setReadOnly(true);
				EVF.C('START_DATE').setRequired(false);
				EVF.C('END_DATE').setRequired(false);
				//EVF.C('MONTH').setRequired(true);
				EVF.C('QUARTER').setRequired(false);
				EVF.C('HALF_YEAR').setRequired(false);
				EVF.V("MYEAR", "${thisYear}");
				EVF.V("MONTH", "${thisMonth}");
				EVF.C('YEAR').setRequired(false);
				//EVF.C('MYEAR').setRequired(true);
				EVF.C('QYEAR').setRequired(false);
				EVF.C('HYEAR').setRequired(false);
				$('#D').css('display', 'block');
				$('#W').css('display', 'none');
				$('#B').css('display', 'none');
				$('#M').css('display', 'none');
				$('#S').css('display', 'none');
			}
					<%-- 분기 --%>
			else if("W" === DATE_SEL) {
				EVF.C("START_DATE").setReadOnly(true);
				EVF.C("END_DATE").setReadOnly(true);
				EVF.C('START_DATE').setRequired(false);
				EVF.C('END_DATE').setRequired(false);
				EVF.C('MONTH').setRequired(false);
				//EVF.C('QUARTER').setRequired(true);
				EVF.C('HALF_YEAR').setRequired(false);
				EVF.V('QUARTER', "${thisQuarter}");
				EVF.V("QYEAR", "${thisYear}");
				EVF.C('YEAR').setRequired(false);
				EVF.C('MYEAR').setRequired(false);
				//EVF.C('QYEAR').setRequired(true);
				EVF.C('HYEAR').setRequired(false);
				$('#D').css('display', 'none');
				$('#W').css('display', 'block');
				$('#B').css('display', 'none');
				$('#M').css('display', 'none');
				$('#S').css('display', 'none');
			}
					<%-- 반기 --%>
			else if("B" === DATE_SEL) {
				EVF.C("START_DATE").setReadOnly(true);
				EVF.C("END_DATE").setReadOnly(true);
				EVF.C('START_DATE').setRequired(false);
				EVF.C('END_DATE').setRequired(false);
				EVF.C('MONTH').setRequired(false);
				EVF.C('QUARTER').setRequired(false);
				//EVF.C('HALF_YEAR').setRequired(true);
				EVF.V('HALF_YEAR', "${thisHalfYear}");
				EVF.V("HYEAR", "${thisYear}");
				EVF.C('YEAR').setRequired(false);
				EVF.C('MYEAR').setRequired(false);
				EVF.C('QYEAR').setRequired(false);
				//EVF.C('HYEAR').setRequired(true);
				$('#D').css('display', 'none');
				$('#W').css('display', 'none');
				$('#B').css('display', 'block');
				$('#M').css('display', 'none');
				$('#S').css('display', 'none');
			}
					<%-- 년 --%>
			else if("M" === DATE_SEL) {
				EVF.C("START_DATE").setReadOnly(true);
				EVF.C("END_DATE").setReadOnly(true);
				EVF.C('START_DATE').setRequired(false);
				EVF.C('END_DATE').setRequired(false);
				EVF.C('MONTH').setRequired(false);
				EVF.C('QUARTER').setRequired(false);
				EVF.C('HALF_YEAR').setRequired(false);
				EVF.V("YEAR", "${thisYear}");
				//EVF.C('YEAR').setRequired(true);
				EVF.C('MYEAR').setRequired(false);
				EVF.C('QYEAR').setRequired(false);
				EVF.C('HYEAR').setRequired(false);
				$('#D').css('display', 'none');
				$('#W').css('display', 'none');
				$('#B').css('display', 'none');
				$('#M').css('display', 'block');
				$('#S').css('display', 'none');
			}
					<%-- 기간선택 --%>
			else if("S" === DATE_SEL) {
				EVF.C("START_DATE").setReadOnly(false);
				EVF.C("END_DATE").setReadOnly(false);
				//EVF.C('START_DATE').setRequired(true);
				//EVF.C('END_DATE').setRequired(true);
				EVF.C('MONTH').setRequired(false);
				EVF.C('QUARTER').setRequired(false);
				EVF.C('HALF_YEAR').setRequired(false);
				EVF.V("START_DATE", "${START_DATE}");
				EVF.V("END_DATE", "${END_DATE}");
				EVF.C('YEAR').setRequired(false);
				EVF.C('MYEAR').setRequired(false);
				EVF.C('QYEAR').setRequired(false);
				EVF.C('HYEAR').setRequired(false);
				$('#D').css('display', 'none');
				$('#W').css('display', 'none');
				$('#B').css('display', 'none');
				$('#M').css('display', 'none');
				$('#S').css('display', 'block');
			}
		}
	}
</script>

    <e:window id="MY03_060" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
				<e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
				<e:field>
					<e:search id="VENDOR_CD" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVENDOR_CD'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
					<e:inputText id="VENDOR_NM" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" />
				</e:field>
				<e:label for="DATE_SEL" title="${MY03_060_001}" />
				<e:field>
					<e:radioGroup id="DATE_SEL" name="DATE_SEL" value="" onClick="clickCPO_DATE_SEL" width="${form_CUST_CONFIRM_YN_W}" disabled="false" readOnly="false" required="false">
						<e:radio id="DATE_SEL_D" name="DATE_SEL_D" value="D" label="${MY03_060_002}" disabled="false" readOnly="false" />
						<e:radio id="DATE_SEL_W" name="DATE_SEL_W" value="W" label="${MY03_060_003}" disabled="false" readOnly="false" />
						<e:radio id="DATE_SEL_B" name="DATE_SEL_B" value="B" label="${MY03_060_004}" disabled="false" readOnly="false" />
						<e:radio id="DATE_SEL_M" name="DATE_SEL_M" value="M" label="${MY03_060_005}" disabled="false" readOnly="false" checked="true" />
<%--						<e:radio id="DATE_SEL_S" name="DATE_SEL_S" value="S" label="${MY03_060_006}" disabled="false" readOnly="false" />--%>
					</e:radioGroup>
				</e:field>
			</e:row>
            <e:row>
				<e:label for="MANAGE_ID" title="${form_MANAGE_ID_N}"/>
				<e:field>
					<e:select id="MANAGE_ID" name="MANAGE_ID" value="" options="${MANAGE_ID_OPTIONS}" width="${form_MANAGE_ID_W}" disabled="${form_MANAGE_ID_D}" readOnly="${form_MANAGE_ID_RO}" required="${form_MANAGE_ID_R}" placeHolder="" />
				</e:field>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<div id="D" style="width: 100%;">
						<e:select id="MYEAR" name="MYEAR" value="${thisYear}" options="${yearOptions}" width="100px" disabled="${form_MYEAR_D}" readOnly="${form_MYEAR_RO}" required="${form_MYEAR_R}" placeHolder="" />
						<e:select id="MONTH" name="MONTH" value="${thisMonth}" options="${monthOptions}" width="80px" disabled="${form_MONTH_D}" readOnly="${form_MONTH_RO}" required="${form_MONTH_R}" placeHolder="" />
					</div>
					<div id="W" style="width: 100%;">
						<e:select id="QYEAR" name="QYEAR" value="${thisYear}" options="${yearOptions}" width="100px" disabled="${form_QYEAR_D}" readOnly="${form_QYEAR_RO}" required="${form_QYEAR_R}" placeHolder="" />
						<e:select id="QUARTER" name="QUARTER" value="${thisQuarter}" options="${quarterOptions}" width="100px" disabled="${form_QUARTER_D}" readOnly="${form_QUARTER_RO}" required="${form_QUARTER_R}" placeHolder="" />
					</div>
					<div id="B" style="width: 100%;">
						<e:select id="HYEAR" name="HYEAR" value="${thisYear}" options="${yearOptions}" width="100px" disabled="${form_HYEAR_D}" readOnly="${form_HYEAR_RO}" required="${form_HYEAR_R}" placeHolder="" />
						<e:select id="HALF_YEAR" name="HALF_YEAR" value="${thisHalfYear}" options="${halfYearOptions}" width="100px" disabled="${form_HALF_YEAR_D}" readOnly="${form_HALF_YEAR_RO}" required="${form_HALF_YEAR_R}" placeHolder="" />
					</div>
					<div id="M" style="width: 100%;">
						<e:select id="YEAR" name="YEAR" value="${thisYear}" options="${yearOptions}" width="100px" disabled="${form_YEAR_D}" readOnly="${form_YEAR_RO}" required="${form_YEAR_R}" placeHolder="" />
					</div>
					<div id="S" style="width: 100%;">
						<e:inputDate id="START_DATE" name="START_DATE" value="${START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_START_DATE_R}" disabled="${form_START_DATE_D}" readOnly="${form_START_DATE_RO}" />
						<e:text id="TXT1"> ~ </e:text>
						<e:inputDate id="END_DATE" name="END_DATE" value="${END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_END_DATE_R}" disabled="${form_END_DATE_D}" readOnly="${form_END_DATE_RO}" />
					</div>
				</e:field>
			</e:row>
        </e:searchPanel>
        
    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
