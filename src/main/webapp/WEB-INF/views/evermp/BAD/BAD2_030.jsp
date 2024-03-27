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
    var baseUrl = "/evermp/BAD/BAD1/";
    var grid;
	
    function init() {
    	grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
            if(colId === "ITEM_CD") {
                var param = {
                    ITEM_CD: grid.getCellValue(rowId, "ITEM_CD"),
                    popupFlag: true,
                    detailView: true
                };
                everPopup.im03_014open(param);
			}
         // 주문금액
        	if(colId == "CPO_ITEM_AMT") {
                param = {
                         MOVE_LINK_YN: "Y",
                         CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                         CUST_NM: grid.getCellValue(rowId, "CUST_NM"),
                         START_DATE_COMBO: "CPO_DATE",
                         START_DATE: EVF.C("CPO_START_DATE").getValue(),
                         END_DATE: EVF.C("CPO_END_DATE").getValue(),
                         DOC_NUM_COMBO: "CPO_NO",
                         ITEM_CD: grid.getCellValue(rowId, "ITEM_CD")
 					};
                     // var el = parent.parent.document.getElementById('mainIframe');
                     top.pageRedirectByScreenId("BOD1_050", param);
 			}
        	// 미입금액
             if(colId == "STD_ITEM_AMT") {
                 param = {
                         MOVE_LINK_YN: "Y",
                         CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
                         CUST_NM: grid.getCellValue(rowId, "CUST_NM"),
                         START_DATE_COMBO: "CPO_DATE",
                         START_DATE: EVF.C("CPO_START_DATE").getValue(),
                         END_DATE: EVF.C("CPO_END_DATE").getValue(),
                         DOC_NUM_COMBO: "CPO_NO",
                         ITEM_CD: grid.getCellValue(rowId, "ITEM_CD")
  					};
                      // var el = parent.parent.document.getElementById('mainIframe');
                      top.pageRedirectByScreenId("BOD1_050", param);
                      // top.pageRedirectByScreenId("PY02_010", param);
  			}
		});
        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        grid.showCheckBar(false);

        clickCPO_DATE_SEL("INIT");
        
        grid.setProperty('shrinkToFit', true);
    }

    function doSearch() {
        var store = new EVF.Store();    
        if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + 'bad2030_doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            } else {
            	var TOT_CPO_AMT = 0;
            	var TOT_STD_AMT = 0;
            	var rows = grid.getAllRowValue();
                for( var i = 0; i < rows.length; i++ ) {
                	TOT_CPO_AMT += Number(rows[i].ORG_CPO_ITEM_AMT);
                	TOT_STD_AMT += Number(rows[i].ORG_STD_ITEM_AMT);
                }
                
                var val = {visible: true, count: 1, height: 40};
                var footerTxt = {
                    styles: {
                        textAlignment: "center",
                        font: "굴림,12",
                        background:"#ffffff",
                        foreground:"#FF0000",
                        fontBold: true
                    },
                    text: ["합    계"],
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
                var footerCpoAmt = {
                        styles: {
                            textAlignment: "far",
                            font: "굴림,12",
                            background:"#ffffff",
                            foreground:"#FF0000",
                            numberFormat: "###,###.0",
                            fontBold: true
                        },
                        text: everString.commaSet(TOT_CPO_AMT+" "),
                    };
                var footerStdAmt = {
                        styles: {
                            textAlignment: "far",
                            font: "굴림,12",
                            background:"#ffffff",
                            foreground:"#FF0000",
                            numberFormat: "###,###.0",
                            fontBold: true
                        },
                        text: everString.commaSet(TOT_STD_AMT+" "),
                    };

                grid.setProperty("footerVisible", val);
                grid.setRowFooter("ITEM_SPEC", footerTxt);
                grid.setRowFooter("CPO_CNT", footerSum);
                grid.setRowFooter("CPO_QTY", footerSum);
                grid.setRowFooter("CPO_ITEM_AMT", footerCpoAmt);
                grid.setRowFooter("STD_ITEM_AMT", footerStdAmt);
            }
        });
    }

    function searchCUST_CD() {
        var param = {
            callBackFunction: "callbackCUST_CD"
        };
        everPopup.openCommonPopup(param, "SP0067");
    }

    function callbackCUST_CD(data) {
        EVF.V("CUST_CD", data.CUST_CD);
        EVF.V("CUST_NM", data.CUST_NM);
    }

    function clickCPO_DATE_SEL(s) {
        if("INIT" === s) {
            EVF.C("CPO_START_DATE").setReadOnly(true);
            EVF.C("CPO_END_DATE").setReadOnly(true);
		} else {
            var CPO_DATE_SEL =  EVF.V("CPO_DATE_SEL");
            var date_1 = "${date_1}";

            if("D" === CPO_DATE_SEL) {
                EVF.V("CPO_END_DATE", date_1);
                EVF.V("CPO_START_DATE", date_1);
            } else if("W" === CPO_DATE_SEL) {
                var date_7 = "${date_7}";
                EVF.V("CPO_END_DATE", date_1);
                EVF.V("CPO_START_DATE", date_7);
            } else if("B" === CPO_DATE_SEL) {
                var date_15 = "${date_15}";
                EVF.V("CPO_END_DATE", date_1);
                EVF.V("CPO_START_DATE", date_15);
            } else if("M" === CPO_DATE_SEL) {
                var date_30 = "${date_30}";
                EVF.V("CPO_END_DATE", date_1);
                EVF.V("CPO_START_DATE", date_30);
            }

			if("S" === CPO_DATE_SEL) {
                EVF.C("CPO_START_DATE").setReadOnly(false);
                EVF.C("CPO_END_DATE").setReadOnly(false);
            } else {
                EVF.C("CPO_START_DATE").setReadOnly(true);
                EVF.C("CPO_END_DATE").setReadOnly(true);
            }
		}
	}
</script>

    <e:window id="BAD2_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="${ses.companyCd}" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="${form_CUST_CD_RO ? 'everCommon.blank' : 'searchCUST_CD'}" disabled="true" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="${ses.companyNm}" width="60%" maxLength="${form_CUST_NM_M}" disabled="true" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
				</e:field>
				<e:label for="CPO_DATE_SEL" title="${BAD2_030_001}" />
				<e:field>
					<e:radioGroup id="CPO_DATE_SEL" name="CPO_DATE_SEL" value="" onClick="clickCPO_DATE_SEL" width="${form_CUST_CONFIRM_YN_W}" disabled="false" readOnly="false" required="false">
						<e:radio id="CPO_DATE_SEL_D" name="CPO_DATE_SEL_D" value="D" label="${BAD2_030_002}" disabled="false" readOnly="false" />
						<e:radio id="CPO_DATE_SEL_W" name="CPO_DATE_SEL_W" value="W" label="${BAD2_030_003}" disabled="false" readOnly="false" />
						<e:radio id="CPO_DATE_SEL_B" name="CPO_DATE_SEL_B" value="B" label="${BAD2_030_004}" disabled="false" readOnly="false" />
						<e:radio id="CPO_DATE_SEL_M" name="CPO_DATE_SEL_M" value="M" label="${BAD2_030_005}" disabled="false" readOnly="false" checked="true" />
						<e:radio id="CPO_DATE_SEL_S" name="CPO_DATE_SEL_S" value="S" label="${BAD2_030_006}" disabled="false" readOnly="false" />
					</e:radioGroup>
				</e:field>
			</e:row>
            <e:row>
            	<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
					<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="CPO_START_DATE" title="${form_CPO_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="CPO_START_DATE" name="CPO_START_DATE" value="${CPO_START_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_CPO_START_DATE_R}" disabled="${form_CPO_START_DATE_D}" readOnly="${form_CPO_START_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="CPO_END_DATE" name="CPO_END_DATE" value="${CPO_END_DATE}" width="${inputDateWidth}" datePicker="true" required="${form_CPO_END_DATE_R}" disabled="${form_CPO_END_DATE_D}" readOnly="${form_CPO_END_DATE_RO}" />
				</e:field>

			</e:row>
        </e:searchPanel>
        
    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
