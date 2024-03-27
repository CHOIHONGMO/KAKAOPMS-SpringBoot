<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 공급사선택 화면 --%>
<%@ taglib uri="http://www.st-ones.com/eversrm" prefix="e"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var gridL;
        var gridR;
        var baseUrl = "/evermp/RQ01/RQ0101/";

        function init() {

            gridL = EVF.C("gridL");
            gridR = EVF.C("gridR");
			
            gridL.cellClickEvent(function(rowId, colId, value, iRow, iCol) {

                if(colId == 'VENDOR_NM') {
                    var param = {
                        'VENDOR_CD': gridL.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
            });

            gridL.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

            gridR.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
            
            <%-- 견적의뢰에서 품목의 S/G에 속한 공급사를 조회한다. 이때, 매출액이 높은 공급사순으로 보여준다.--%>
            //doSearchDefault();
        }

        function doSearchDefault() {

            var store = new EVF.Store();
            store.setParameter("ITEM_CD_STR", "${param.ITEM_CD_STR}");
            store.setGrid([gridL]);
            store.load(baseUrl + "rq01012_doSearchDefault", function() {
                if (gridL.getRowCount() == 1) {
                    gridL.checkAll(true);
                    doSendRight();
                }
            });
        }

        function doSearch() {

            var store = new EVF.Store();
            store.setGrid([gridL]);
            store.load(baseUrl + "rq01012_doSearch", function() {
                if (gridL.getRowCount() == 0) {
                    alert("${msg.M0002 }");
                }
                if (gridL.getRowCount() == 1) {
                    gridL.checkAll(true);
                    doSendRight();
                }
            });
        }

        function doChoice() {

            if(!gridR.isExistsSelRow()) { return alert('${msg.M0004}'); }

            var selRowDataR = gridR.getSelRowValue();
            opener.window['${param.callBackFunction}'](JSON.stringify(selRowDataR));
            doClose();
        }

        <%-- 소싱그룹 조회 --%>
        function _getSGClsNm(){
            var popupUrl = "/evermp/IM04/IM0402/IM04_006/view";
            var param = {
                callBackFunction: '_setSg',
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true
            };
            everPopup.openModalPopup(popupUrl, 500, 600, param, "sgSelectPopup");
        }

        function _setSg(data) {
            if(data != null){
                data = JSON.parse(data);
                EVF.C("SG_NUM1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("SG_NUM2").setValue("");}else{EVF.C("SG_NUM2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("SG_NUM3").setValue("");}else{EVF.C("SG_NUM3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("SG_NUM4").setValue("");}else{EVF.C("SG_NUM4").setValue(data.ITEM_CLS4);}
                EVF.C("SG_NUM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("SG_NUM1").setValue("");
                EVF.C("SG_NUM2").setValue("");
                EVF.C("SG_NUM3").setValue("");
                EVF.C("SG_NUM4").setValue("");
                EVF.C("SG_NUM").setValue("");
            }
        }

        function doSendLeft() {

            if( gridR.isEmpty( gridR.getSelRowId() ) ) {
                return alert("${msg.M0004}");
            }

            var selRowIdR = gridR.getSelRowId();
            for(var x = selRowIdR.length - 1; x >= 0; x--) {
                gridR.delRow(selRowIdR[x]);
            }
        }

        function doSendRight() {

            if( gridL.isEmpty( gridL.getSelRowId() ) ) {
                return alert("${msg.M0004}");
            }

            var rowIds = gridL.getSelRowId();
            for(var i in rowIds) {
                var addParam = [{
                    "VENDOR_CD" 	: gridL.getCellValue(rowIds[i], 'VENDOR_CD'),
                    "VENDOR_NM" 	: gridL.getCellValue(rowIds[i], 'VENDOR_NM'),
                    "CEO_USER_NM" 	: gridL.getCellValue(rowIds[i], 'CEO_USER_NM'),
                    "SG_NUM" 		: gridL.getCellValue(rowIds[i], 'SG_NUM'),
                    "SG_TXT" 		: gridL.getCellValue(rowIds[i], 'SG_TXT'),
                    "BUSINESS_TYPE" : gridL.getCellValue(rowIds[i], 'BUSINESS_TYPE'),
                    "INDUSTRY_TYPE" : gridL.getCellValue(rowIds[i], 'INDUSTRY_TYPE'),
                    "MAJOR_ITEM_NM" : gridL.getCellValue(rowIds[i], 'MAJOR_ITEM_NM'),
                    "MAKER_NM" 		: gridL.getCellValue(rowIds[i], 'MAKER_NM'),
                    "USER_ID" 		: gridL.getCellValue(rowIds[i], 'USER_ID'),
                    "USER_NM" 		: gridL.getCellValue(rowIds[i], 'USER_NM'),
                    "EMAIL" 		: gridL.getCellValue(rowIds[i], 'EMAIL'),
                    "CELL_NUM" 		: gridL.getCellValue(rowIds[i], 'CELL_NUM')
                }];
                var validData = valid.equalPopupValid(JSON.stringify(addParam), gridR, "VENDOR_CD");
                gridR.addRow(addParam);
            }
            for(var x = rowIds.length - 1; x >= 0; x--) {
                gridL.delRow(rowIds[x]);
            }
        }

        function doClose() {
            formUtil.close();
        }
        
     	// 화면 초기화
        function doReset() {
            location.href = baseUrl + 'RQ01_012/view';
        }

    </script>

    <e:window id="RQ01_012" onReady="init" initData="${initData}" title="${fullScreenName}">
        <e:searchPanel id="form1" title="${msg.M9999 }" columnCount="3" labelWidth="135" onEnter="doSearch" useTitleBar="false">
            <e:inputHidden id="SG_NUM1" name="SG_NUM1" value="" />
            <e:inputHidden id="SG_NUM2" name="SG_NUM2" value="" />
            <e:inputHidden id="SG_NUM3" name="SG_NUM3" value="" />
            <e:inputHidden id="SG_NUM4" name="SG_NUM4" value="" />

            <e:row>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="${form_VENDOR_NM_W}" maxLength="${form_VENDOR_NM_M}"  disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
				<e:label for="CEO_USER_NM" title="${form_CEO_USER_NM_N}" />
				<e:field>
					<e:inputText id="CEO_USER_NM" name="CEO_USER_NM" value="" width="${form_CEO_USER_NM_W}" maxLength="${form_CEO_USER_NM_M}" disabled="${form_CEO_USER_NM_D}" readOnly="${form_CEO_USER_NM_RO}" required="${form_CEO_USER_NM_R}" />
				</e:field>
                <e:label for="MAJOR_ITEM_NM" title="${form_MAJOR_ITEM_NM_N}" />
				<e:field >
					<e:inputText id="MAJOR_ITEM_NM" name="MAJOR_ITEM_NM" value="" width="${form_MAJOR_ITEM_NM_W}" maxLength="${form_MAJOR_ITEM_NM_M}" disabled="${form_MAJOR_ITEM_NM_D}" readOnly="${form_MAJOR_ITEM_NM_RO}" required="${form_MAJOR_ITEM_NM_R}" />
				</e:field>
            </e:row>
            <e:row>
                <e:label for="BUSINESS_INDUSTRY_TYPE" title="${form_BUSINESS_INDUSTRY_TYPE_N}"/>
                <e:field>
                    <e:inputText id="BUSINESS_INDUSTRY_TYPE" style="${imeMode}" name="BUSINESS_INDUSTRY_TYPE" value="" width="${form_BUSINESS_INDUSTRY_TYPE_W}" maxLength="${form_BUSINESS_INDUSTRY_TYPE_M}"  disabled="${form_BUSINESS_INDUSTRY_TYPE_D}" readOnly="${form_BUSINESS_INDUSTRY_TYPE_RO}" required="${form_BUSINESS_INDUSTRY_TYPE_R}"/>
                </e:field>
                <e:label for="MAKER_NM" title="${form_MAKER_NM_N}" />
				<e:field>
					<e:inputText id="MAKER_NM" name="MAKER_NM" value="" width="${form_MAKER_NM_W}" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}" />
				</e:field>
                <e:label for="SG_NUM" title="${form_SG_NUM_N}"/>
                <e:field>
                    <e:search id="SG_NUM" name="SG_NUM" value="" width="${form_SG_NUM_W}" maxLength="${form_SG_NUM_M}" onIconClick="_getSGClsNm" disabled="${form_SG_NUM_D}" readOnly="${form_SG_NUM_RO}" required="${form_SG_NUM_R}" onBlur="cleanSGClass" onChange="cleanSGClass" onClear="cleanSGClass" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right">
            <e:button label='${Search_N }' id='Search' disabled='${Search_D }' visible='${Search_V }' data='${Search_A }' onClick='doSearch' />
            <c:if test="${!param.detailView}">
                <e:button label='${Choice_N }' id='Choice' disabled='${Choice_D }' visible='${Choice_V }' data='${Choice_A }' onClick='doChoice' />
            </c:if>
            <e:button id="doReset" name="doReset" label="${doReset_N}" onClick="doReset" disabled="${doReset_D}" visible="${doReset_V}" />
        </e:buttonBar>

        <e:panel height="fit" width="100%">
            <e:panel width="49%">
                <e:title title="${RQ01_012_001 }" />
                <e:gridPanel id="gridL" name="gridL" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridL.gridColData}" />
            </e:panel>
            <e:panel width="2%" height="100%">
                <div style="width: 100%; margin-top: 200px; vertical-align: middle;" align="center">
                    <div id="doSendRight" style="background: url(/images/eversrm/button/thumb_next.png) no-repeat; width: 13px; height: 22px; display: inline-block; cursor: pointer;" onclick="doSendRight();">&nbsp;</div>
                    <br/><br/>
                    <div id="doSendLeft" style="background: url(/images/eversrm/button/thumb_prev.png) no-repeat; width: 13px; height: 22px; display: inline-block; margin-top: 10px; cursor: pointer;" onclick="doSendLeft();">&nbsp;</div>
                </div>
            </e:panel>
            <e:panel width="49%">
                <e:title title="${RQ01_012_002}" />
                <e:gridPanel id="gridR" name="gridR" height="fit" width="100%" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridR.gridColData}" />
            </e:panel>
        </e:panel>
    </e:window>
</e:ui>
