<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
	<style>
		.trafficLight {
			vertical-align: bottom;
			position: relative;
			top: -2px;
		}
	</style>
    <script>

    var baseUrl = "/evermp/MY03/";
    var grid;
	
    function init() {
    	grid = EVF.C("grid");

        grid.cellClickEvent(function(rowId, colId, value, iRow, iCol) {
        	/*if (colId === "BUYER_NAME") {
                var param = {
                        CUST_CD: grid.getCellValue(rowId, "BUYER_CODE"),
                        detailView: true,
                        popupFlag: true
                    };
                everPopup.openPopupByScreenId("BS01_002", 1200, 900, param);
            }*/
			if(colId === "CPO_NO") {
				var param = {
                        callbackFunction: "",
                        CPO_NO: grid.getCellValue(rowId, "CPO_NO"),
                        CPO_SEQ: grid.getCellValue(rowId, "CPO_SEQ")
                    };
                everPopup.openPopupByScreenId("BOD1_041", 1100, 700, param);
            }
			if(colId == "ITEM_CODE") {
                var param = {
                    'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CODE'),
                    'detailView': true,
                    'popupFlag': true
                };
                everPopup.im03_014open(param);
            }
			if (colId == "VENDOR_NAME") {
				var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CODE'),
                        'detailView': true,
                        'popupFlag': true
                    };
				everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
			}
			if(colId == 'MANAGE_NM') {
        		if( grid.getCellValue(rowId, 'MANAGE_ID') == '' ) return;
        		var param = {
	                     USER_ID : grid.getCellValue(rowId, 'MANAGE_ID'),
	                     detailView : true
	                 };
	            everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
        	}
		});

        grid.excelExportEvent({
			allItems : "${excelExport.allCol}",
			fileName : "${screenName }"
		});

        //doSearch();
		grid._gvo.setColumnProperty("LEAD_TIME", "renderer", {type:"shape", showTooltip: true});
		grid._gvo.setColumnProperty("LEAD_TIME", "dynamicStyles", [{
			criteria: "(value['LEAD_TIME'] > 7)",
			styles: {figureBackground: "#ff3133", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}, {
			criteria: "(value['LEAD_TIME'] > 5) and (value['LEAD_TIME'] < 8)",
			styles: {figureBackground: "#2b90ff", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}, {
			criteria: "(value['LEAD_TIME'] > 3) and (value['LEAD_TIME'] < 6)",
			styles: {figureBackground: "#34ff2e", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}, {
			criteria: "(value['LEAD_TIME'] < 4)",
			styles: {figureBackground: "#ffeeeeee", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}]);
    }

    function doSearch() {
        var store = new EVF.Store();    
        if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + 'my03030_doSearch', function() {
        	if(grid.getRowCount() == 0){
            	alert("${msg.M0002 }");
            }            
        });
    }

    function searchCust() {
        var param = {
            callBackFunction : "selectCust"
        };
        everPopup.openCommonPopup(param, 'SP0067');
    }

    function selectCust(dataJsonArray) {
        EVF.C("BUYER_CODE").setValue(dataJsonArray.CUST_CD);
        EVF.C("BUYER_NAME").setValue(dataJsonArray.CUST_NM);
    }

    function cleanCust() {
        EVF.C("BUYER_CODE").setValue("");
    }

    function searchVendor() {
    	var param = {
			callBackFunction : "selectVendor"
		};
        everPopup.openCommonPopup(param, 'SP0063');
    }

    function selectVendor(dataJsonArray) {
        EVF.C("VENDOR_CODE").setValue(dataJsonArray.VENDOR_CD);
        EVF.C("VENDOR_NAME").setValue(dataJsonArray.VENDOR_NM);
    }

    function cleanVendorCd() {
        EVF.C("VENDOR_CODE").setValue("");
    }

    </script>
    
    <e:window id="MY03_030" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="doSearch" useTitleBar="false">
            <e:row>
				<e:label for="CPO_FROM_DATE" title="${form_CPO_FROM_DATE_N}"/>
				<e:field>
					<e:inputDate id="CPO_FROM_DATE" name="CPO_FROM_DATE" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_CPO_FROM_DATE_R}" disabled="${form_CPO_FROM_DATE_D}" readOnly="${form_CPO_FROM_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="CPO_TO_DATE" name="CPO_TO_DATE" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_CPO_TO_DATE_R}" disabled="${form_CPO_TO_DATE_D}" readOnly="${form_CPO_TO_DATE_RO}" />
				</e:field>
				<e:label for="BUYER_CODE" title="${form_BUYER_CODE_N}"/>
				<e:field>
					<e:search id="BUYER_CODE" name="BUYER_CODE" value="" width="40%" maxLength="${form_BUYER_CODE_M}" onIconClick="searchCust" disabled="${form_BUYER_CODE_D}" readOnly="${form_BUYER_CODE_RO}" required="${form_BUYER_CODE_R}" />
					<e:inputText id="BUYER_NAME" name="BUYER_NAME" value="" width="60%" maxLength="${form_BUYER_NAME_M}" disabled="${form_BUYER_NAME_D}" readOnly="${form_BUYER_NAME_RO}" required="${form_BUYER_NAME_R}" onKeyDown="cleanCust" />
				</e:field>
				<e:label for="VENDOR_CODE" title="${form_VENDOR_CODE_N}"/>
				<e:field>
					<e:search id="VENDOR_CODE" name="VENDOR_CODE" value="" width="40%" maxLength="${form_VENDOR_CODE_M}" onIconClick="searchVendor" disabled="${form_VENDOR_CODE_D}" readOnly="${form_VENDOR_CODE_RO}" required="${form_VENDOR_CODE_R}" />
					<e:inputText id="VENDOR_NAME" name="VENDOR_NAME" value="" width="60%" maxLength="${form_VENDOR_NAME_M}" disabled="${form_VENDOR_NAME_D}" readOnly="${form_VENDOR_NAME_RO}" required="${form_VENDOR_NAME_R}" onKeyDown="cleanVendorCd" />
				</e:field>
			</e:row>
            <e:row>
				<e:label for="ITEM_CODE" title="${form_ITEM_CODE_N}" />
				<e:field>
					<e:inputText id="ITEM_CODE" name="ITEM_CODE" value="" width="${form_ITEM_CODE_W}" maxLength="${form_ITEM_CODE_M}" disabled="${form_ITEM_CODE_D}" readOnly="${form_ITEM_CODE_RO}" required="${form_ITEM_CODE_R}" />
				</e:field>
				<e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
				<e:field>
					<e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
				</e:field>
				<e:label for="AM_USER_ID" title="${form_AM_USER_ID_N}"/>
				<e:field>
					<e:select id="AM_USER_ID" name="AM_USER_ID" value="" options="${amUserIdOptions}" width="${form_AM_USER_ID_W}" disabled="${form_AM_USER_ID_D}" readOnly="${form_AM_USER_ID_RO}" required="${form_AM_USER_ID_R}" placeHolder="" />
				</e:field>
			</e:row>
        </e:searchPanel>

    	<e:buttonBar id="buttonBar" align="right" width="100%">
			<e:text>
				<%--0~3일 : 무색, 4~5일 : 녹색, 6~7일: 파란, 8일 이상: 붉은색--%>
				<img class="trafficLight" src="/images/icon/gray.png"> : 0~3일,
				<img class="trafficLight" src="/images/icon/green.png"> : 4~5일,
				<img class="trafficLight" src="/images/icon/blue.png"> : 6~7일,
				<img class="trafficLight" src="/images/icon/red.png"> : 8일 이상
			</e:text>
            <e:button id="doSearch" name="doSearch" label="${doSearch_N}" onClick="doSearch" disabled="${doSearch_D}" visible="${doSearch_V}"/>
        </e:buttonBar>
              
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>