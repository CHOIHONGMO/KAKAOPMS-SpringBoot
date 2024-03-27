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
			if(colId === "ITEM_REQ_NO") {
                var param = {
                    CUST_CD: grid.getCellValue(rowId, "BUYER_CODE"),
                    ITEM_REQ_NO: grid.getCellValue(rowId, "ITEM_REQ_NO"),
                    ITEM_REQ_SEQ: grid.getCellValue(rowId, "ITEM_REQ_SEQ"),
                    detailView: true,
                    popupFlag: true
                };
                everPopup.openPopupByScreenId("BNM1_011", 1100, 630, param);
            }
			if(colId == "ITEM_CODE") {
                var param = {
                    'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CODE'),
                    'detailView': true,
                    'popupFlag': true
                };
                everPopup.im03_014open(param);
            }
            if (colId == 'CMS_CTRL_USER_NAME') {
                if( grid.getCellValue(rowId, 'CMS_CTRL_USER_NAME') == '' ) return;
                var param = {
                    callbackFunction : "",
                    USER_ID : grid.getCellValue(rowId, 'CMS_CTRL_USER_ID'),
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
		grid._gvo.setColumnProperty("LT_DATE", "renderer", {type:"shape", showTooltip: true});
		grid._gvo.setColumnProperty("LT_DATE", "dynamicStyles", [{
			criteria: "(value['LT_DATE'] > 7)",
			styles: {figureBackground: "#ff3133", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}, {
			criteria: "(value['LT_DATE'] > 5) and (value['LT_DATE'] < 8)",
			styles: {figureBackground: "#2b90ff", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}, {
			criteria: "(value['LT_DATE'] > 3) and (value['LT_DATE'] < 6)",
			styles: {figureBackground: "#34ff2e", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}, {
			criteria: "(value['LT_DATE'] < 4)",
			styles: {figureBackground: "#ffeeeeee", figureName: "ellipse", iconLocation: "left", figureSize: "60%", paddingRight: 6}
		}]);
    }

    function doSearch() {
        var store = new EVF.Store();    
        if(!store.validate()) { return; }
        store.setGrid([grid]);
        store.load(baseUrl + 'my03020_doSearch', function() {
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

    function cleanBuyerCd() {
        EVF.C("BUYER_CODE").setValue("");
    }

    </script>
    
    <e:window id="MY03_020" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
		<e:searchPanel id="form" title="${msg.M9999}" labelWidth="${labelWidth}" width="100%" columnCount="3" onEnter="doSearch" useTitleBar="false">
            <e:row>
				<e:label for="REQUEST_START_DATE" title="${form_REQUEST_START_DATE_N}"/>
				<e:field>
					<e:inputDate id="REQUEST_START_DATE" name="REQUEST_START_DATE" value="${fromDate }" width="${inputDateWidth}" datePicker="true" required="${form_REQUEST_START_DATE_R}" disabled="${form_REQUEST_START_DATE_D}" readOnly="${form_REQUEST_START_DATE_RO}" />
					<e:text> ~ </e:text>
					<e:inputDate id="REQUEST_END_DATE" name="REQUEST_END_DATE" value="${toDate }" width="${inputDateWidth}" datePicker="true" required="${form_REQUEST_END_DATE_R}" disabled="${form_REQUEST_END_DATE_D}" readOnly="${form_REQUEST_END_DATE_RO}" />
				</e:field>
				<e:label for="BUYER_CODE" title="${form_BUYER_CODE_N}"/>
				<e:field>
					<e:search id="BUYER_CODE" name="BUYER_CODE" value="" width="40%" maxLength="${form_BUYER_CODE_M}" onIconClick="searchCust" disabled="${form_BUYER_CODE_D}" readOnly="${form_BUYER_CODE_RO}" required="${form_BUYER_CODE_R}" />
					<e:inputText id="BUYER_NAME" name="BUYER_NAME" value="" width="60%" maxLength="${form_BUYER_NAME_M}" disabled="${form_BUYER_NAME_D}" readOnly="${form_BUYER_NAME_RO}" required="${form_BUYER_NAME_R}" onKeyDown="cleanBuyerCd" />
				</e:field>
				<e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
				<e:field>
					<e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="" options="${sgCtrlUserIdOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
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