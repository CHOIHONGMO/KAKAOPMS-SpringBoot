<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.st_ones.common.util.clazz.EverDate"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

    var baseUrl = "/evermp/MY03/";
    var grid;

    function init() {

    	grid = EVF.C("grid");
		grid.setProperty('shrinkToFit', false);

        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

        	if (colId === "CUST_NM") {
                var param = {
					CUST_CD: grid.getCellValue(rowId, "CUST_CD"),
					detailView: true,
					popupFlag: true
				};
                everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
            }
		});

        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

		grid.setProperty('multiSelect', false);

        clickDateSel("INIT");
    }

    function doSearch() {

        var store = new EVF.Store();
        if(!store.validate()) { return; }

        store.setGrid([grid]);
        store.load(baseUrl + 'my03096_doSearch', function() {
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
                    text: ["합 계"],
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

				var AFTER_PROFIT_RATE = {
					styles: {
						textAlignment: "far",
						suffix: " ",
						numberFormat: "###,###.#",
						background:"#ffffff",
						foreground:"#FF0000",
						fontBold: true
					},
					text: "0",
					expression: ["(sum['AFTER_CPO_AMT'] - sum['AFTER_PO_AMT']) / sum['AFTER_CPO_AMT'] * 100"],
					groupExpression: "sum"
				};

				var BEFORE_PROFIT_RATE = {
					styles: {
						textAlignment: "far",
						suffix: " ",
						numberFormat: "###,###.#",
						background:"#ffffff",
						foreground:"#FF0000",
						fontBold: true
					},
					text: "0",
					expression: ["(sum['BEFORE_CPO_AMT'] - sum['BEFORE_PO_AMT']) / sum['BEFORE_CPO_AMT'] * 100"],
					groupExpression: "sum"
				};

				var SUM_SALE_PLAN_RATE = {
					styles: {
						textAlignment: "far",
						suffix: " ",
						numberFormat: "###,###.#",
						background:"#ffffff",
						foreground:"#FF0000",
						fontBold: true
					},
					text: "0",
					expression: ["sum['AFTER_CPO_AMT'] / sum['SUM_SALE_PLAN_AMT'] * 100"],
					groupExpression: "sum"
				};

				grid.setColMerge(['RELAT_YN','CUST_CD','CUST_NM']);
				grid._gvo.setColumnProperty("PLANT_NM", "mergeRule", {criteria: "values['CUST_CD'] + values['PLANT_CD'] + value"})
				grid._gvo.setColumnProperty("RESULT_DEAL_CD", "mergeRule", {criteria: "values['CUST_CD'] + values['PLANT_CD'] + value"})
                grid.setProperty("footerVisible", val);
                grid.setRowFooter("CUST_NM", footerTxt);
				grid.setRowFooter("BEFORE_CPO_AMT", footerSum);
                grid.setRowFooter("AFTER_CPO_AMT", footerSum);
				grid.setRowFooter("BEFORE_PO_AMT", footerSum);
                grid.setRowFooter("AFTER_PO_AMT", footerSum);
				grid.setRowFooter("BEFORE_PROFIT_AMT", footerSum);
                grid.setRowFooter("AFTER_PROFIT_AMT", footerSum);
                grid.setRowFooter("SUM_SALE_PLAN_AMT", footerSum);
				grid.setRowFooter('BEFORE_PROFIT_RATE', BEFORE_PROFIT_RATE);
				grid.setRowFooter('AFTER_PROFIT_RATE', AFTER_PROFIT_RATE);
				grid.setRowFooter('SUM_SALE_PLAN_RATE', SUM_SALE_PLAN_RATE);
            }
        });
    }

	/*
    function clickDateSel(s) {

        if("INIT" === s) {
			EVF.C("START_DATE").setReadOnly(true);
			EVF.C("END_DATE").setReadOnly(true);
			EVF.C('START_DATE').setRequired(false);
			EVF.C('END_DATE').setRequired(false);
			EVF.C('MONTH').setRequired(false);
			EVF.C('QUARTER').setRequired(false);
			EVF.C('HALF_YEAR').setRequired(false);
			EVF.V("YEAR", "${thisYear}");
			EVF.C('YEAR').setRequired(true);
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
				EVF.C('MONTH').setRequired(true);
				EVF.C('QUARTER').setRequired(false);
				EVF.C('HALF_YEAR').setRequired(false);
				EVF.V("MYEAR", "${thisYear}");
				EVF.V("MONTH", "${thisMonth}");
				EVF.C('YEAR').setRequired(false);
				EVF.C('MYEAR').setRequired(true);
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
				EVF.C('QUARTER').setRequired(true);
				EVF.C('HALF_YEAR').setRequired(false);
				EVF.V('QUARTER', "${thisQuarter}");
				EVF.V("QYEAR", "${thisYear}");
				EVF.C('YEAR').setRequired(false);
				EVF.C('MYEAR').setRequired(false);
				EVF.C('QYEAR').setRequired(true);
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
				EVF.C('HALF_YEAR').setRequired(true);
				EVF.V('HALF_YEAR', "${thisHalfYear}");
				EVF.V("HYEAR", "${thisYear}");
				EVF.C('YEAR').setRequired(false);
				EVF.C('MYEAR').setRequired(false);
				EVF.C('QYEAR').setRequired(false);
				EVF.C('HYEAR').setRequired(true);
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
				EVF.C('YEAR').setRequired(true);
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
				EVF.C('START_DATE').setRequired(true);
				EVF.C('END_DATE').setRequired(true);
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
    */

	function searchCustInfo() {
		var param = {
			callBackFunction: "setCustInfo"
		};
		everPopup.openCommonPopup(param, "SP0067");
	}

	function setCustInfo(data) {
		EVF.V("CUST_CD", data.CUST_CD);
		EVF.V("CUST_NM", data.CUST_NM);
		EVF.V("PLANT_NM", "");
		EVF.V("PLANT_CD", "");
	}
	//사업장 팝업
	function selectPlant(){
		<%-- 고객사를 먼저 선택해주세요 --%>
		if(EVF.V('CUST_CD') === '') {
			return EVF.alert('${MY03_096_007}');
		}

		var param = {
			 custCd : EVF.V("CUST_CD")
			,callBackFunction : 'callback_setPlant'
		}
		everPopup.openCommonPopup(param, 'SP0005');
	}
	function callback_setPlant(data){
		EVF.V("PLANT_NM", data.PLANT_NM);
		EVF.V("PLANT_CD", data.PLANT_CD);
		//공급사 제안상품 및 마스터상품조회 페이지 에서 들어올시 고객사/사업장 선택시 자동매핑

	}
	function cleanCustCd() {
		EVF.V("CUST_CD", "");
	}

    </script>

    <e:window id="MY03_096" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" onEnter="doSearch" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="2" useTitleBar="false">
            <e:row>
				<e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
				<e:field>
					<e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustInfo" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
					<e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" onKeyDown="cleanCustCd" />
				</e:field>
				<e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
				<e:field>
					<e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="selectPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
					<e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
				</e:field>
<%--				<e:label for="DATE_SEL" title="${MY03_096_001}" />--%>
<%--				<e:field>--%>
<%--					<e:radioGroup id="DATE_SEL" name="DATE_SEL" value="" onClick="clickDateSel" width="130px" disabled="false" readOnly="false" required="false">--%>
<%--						<e:radio id="DATE_SEL_D" name="DATE_SEL_D" value="D" label="${MY03_096_002}" disabled="false" readOnly="false" />--%>
<%--						<e:radio id="DATE_SEL_W" name="DATE_SEL_W" value="W" label="${MY03_096_003}" disabled="false" readOnly="false" />--%>
<%--						<e:radio id="DATE_SEL_B" name="DATE_SEL_B" value="B" label="${MY03_096_004}" disabled="false" readOnly="false" />--%>
<%--						<e:radio id="DATE_SEL_M" name="DATE_SEL_M" value="M" label="${MY03_096_005}" disabled="false" readOnly="false" checked="true" />--%>
<%--&lt;%&ndash;						<e:radio id="DATE_SEL_S" name="DATE_SEL_S" value="S" label="${MY03_096_006}" disabled="false" readOnly="false" />&ndash;%&gt;--%>
<%--					</e:radioGroup>--%>
<%--				</e:field>--%>
			</e:row>
            <e:row>
				<e:label for="RELAT_YN" title="${form_RELAT_YN_N}"/>
				<e:field>
					<e:select id="RELAT_YN" name="RELAT_YN" value="" options="${relatYnOptions}" width="${form_RELAT_YN_W}" disabled="${form_RELAT_YN_D}" readOnly="${form_RELAT_YN_RO}" required="${form_RELAT_YN_R}" placeHolder="" />
				</e:field>
				<e:label for="START_DATE" title="${form_START_DATE_N}"/>
				<e:field>
					<e:select id="MYEAR_FROM" name="MYEAR_FROM" value="${thisYear}" options="${yearOptions}" width="100px" disabled="${form_MYEAR_FROM_D}" readOnly="${form_MYEAR_FROM_RO}" required="${form_MYEAR_FROM_R}" placeHolder="" />
					<e:select id="MONTH_FROM" name="MONTH_FROM" value="${thisMonth}" options="${monthFromOptions}" width="80px" disabled="${form_MONTH_FROM_D}" readOnly="${form_MONTH_FROM_RO}" required="${form_MONTH_FROM_R}" placeHolder="" />
					<e:text>&nbsp;~ </e:text>
					<e:select id="MYEAR_TO" name="MYEAR_TO" value="${thisYear}" options="${yearOptions}" width="100px" disabled="${form_MYEAR_TO_D}" readOnly="${form_MYEAR_TO_RO}" required="${form_MYEAR_TO_R}" placeHolder="" />
					<e:select id="MONTH_TO" name="MONTH_TO" value="${thisMonth}" options="${monthToOptions}" width="80px" disabled="${form_MONTH_TO_D}" readOnly="${form_MONTH_TO_RO}" required="${form_MONTH_TO_R}" placeHolder="" />
					<%--
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
				--%>
				</e:field>
			</e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
		</e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>
