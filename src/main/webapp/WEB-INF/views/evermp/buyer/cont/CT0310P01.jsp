<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<e:ui>
    <script type="text/javascript">

        var grid;
        var baseUrl 		= "/evermp/buyer/cont/";
        var selVendorCd 	= "${param.selVendorCd}";
        var selVendorNm 	= "${param.selVendorNm}";
        var selPurcContNum 	= "${param.selPurcContNum}";
        var openType 		= "${param.openType}";
        var popupFlag 		= ('${param.popupFlag}' === 'true' ? true : false);


        var shipperType 	=  "${param.shipperType}";
//         var locBuyerCd  	= "${param.locBuyerCd}";
        var execNum     	= "${param.execNum}";
        var execCnt     	= "${param.execCnt}";

        function init() {

            grid = EVF.C("grid");

            grid.setProperty('shrinkToFit', true);

            grid.cellClickEvent(function(rowIdx, colIdx, value) {

                if(colIdx == "CONT_NUM") {
                    if(value.indexOf('EC') > -1) {
                        everPopup.openContractChangeInformation({
                            callBackFunction: 'doSearch',
                            contNum: grid.getCellValue(rowIdx, "CONT_NUM"),
                            contCnt: grid.getCellValue(rowIdx, "CONT_CNT")
                        });
                    } else if(value.indexOf('BC') > -1) {
                        var url = '/evermp/econtract/ECOB0040/view';
                        var params = {
                            callBackFunction: 'doSearch',
                            bundleNum: grid.getCellValue(rowIdx, "CONT_NUM")
                        }
                        everPopup.openWindowPopup(url, 1200, 900, params, 'openBundleContract');
                    }
                }

            });

            grid.excelExportEvent({
                allCol: "${excelExport.allCol}",
                selRow: "${excelExport.selRow}",
                fileType: "${excelExport.fileType }",
                fileName: "${screenName }"
            });

            if(EVF.isNotEmpty(selVendorCd)) {
                EVF.V("VENDOR_CD", selVendorCd);
                EVF.V("VENDOR_NM", selVendorNm);
                EVF.C("VENDOR_NM").setReadOnly(true);
                doSearch();
            }
        }

        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) { return; }

            store.setGrid([grid]);
            store.load(baseUrl + '/CT0310P01/doSearch', function () {
                if (grid.getRowCount() == 0) {
                    EVF.alert("${msg.M0002 }");
                }
            });
        }

        function doChoice() {
                doRegModCont();
        }

        function doRegModCont() {

            if (grid.getSelRowCount() == 0) { return EVF.alert("${msg.M0004}"); }

            if (grid.getSelRowCount() > 1) { return EVF.alert("${msg.M0006}"); }

            var contNum = ""; var contCnt = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                contNum = grid.getCellValue(rowIds[i], 'CONT_NUM');
                contCnt = grid.getCellValue(rowIds[i], 'CONT_CNT');
            }

   		    var BUYER_CD    = '${param.selBuyerCd}';
	        var RFX_NUM     = '${param.selRfxNum}';
	 		var RFX_CNT     = '${param.selRfxCnt}';
	        var QTA_NUM     = '${param.selQtaNum}';
	        var VENDOR_CD   = '${param.selVendorCd}';
	        var VENDOR_NM   = '${param.selVendorNm}';

            var url = '/evermp/buyer/cont/CT0320/view';
            var params = {
                selPurcContNum	: "${param.selPurcContNum}",
                contNum			: contNum,
                contCnt			: contCnt,

                BUYER_CD		: BUYER_CD,
                RFX_NUM			: RFX_NUM,
                RFX_CNT			: RFX_CNT,
                QTA_NUM			: QTA_NUM,
                VENDOR_CD		: VENDOR_CD,
                VENDOR_NM		: VENDOR_NM,
                SHIPPER_TYPE    : shipperType,
                EXEC_NUM     	: execNum,
                EXEC_CNT     	: execCnt,

                openType: 'modCont',
                popupFlag: 'true'
            }
            //everPopup.openWindowPopup(url, 1200, 900, params, 'openCreateCont');

			opener.openModCont(params)

            doClose();
        }

        function getContUserInfo() {
            everPopup.openCommonPopup({
                callBackFunction: "setContUserInfo"
            }, 'SP0001');
        }

        function setContUserInfo(data) {
            EVF.V("CONT_USER_ID", data.USER_ID);
            EVF.V("CONT_USER_NM", data.USER_NM);
        }

        function cleanContUserInfo() {
            EVF.V("CONT_USER_ID", '');
        }

        function getVendorCd() {
            if(EVF.isEmpty(selVendorCd)) {
                everPopup.openCommonPopup({
                    callBackFunction: "setVendorCd"
                }, 'SP0065');
            }
        }

        function setVendorCd(data) {
            EVF.V("VENDOR_CD", data.VENDOR_CD);
            EVF.V("VENDOR_NM", data.VENDOR_NM);
        }

        function cleanVendorCd() {
            EVF.V("VENDOR_CD", '');
        }

        function doClose() {
            EVF.closeWindow();
        }

    </script>

    <e:window id="CT0310P01" onReady="init" initData="${initData}" title="${fullScreenName }" breadCrumbs="${breadCrumb }" margin="0 4px">

        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="2" labelWidth="110" onEnter="doSearch" useTitleBar="false">
            <e:row>
                <e:label for="CONT_FROM_DATE" title="${form_CONT_FROM_DATE_N }" />
                <e:field>
                    <e:inputDate id="CONT_FROM_DATE" name="CONT_FROM_DATE" toDate="CONT_TO_DATE" value="${fromDate }" width="${inputTextDate }" required="${form_CONT_FROM_DATE_R }" readOnly="${form_CONT_FROM_DATE_RO }" disabled="${form_CONT_FROM_DATE_D }" datePicker="true" />
                    <e:text>~</e:text>
                    <e:inputDate id="CONT_TO_DATE" name="CONT_TO_DATE" fromDate="CONT_FROM_DATE" value="${toDate }" width="${inputTextDate }" required="${form_CONT_TO_DATE_R }" readOnly="${form_CONT_TO_DATE_RO }" disabled="${form_CONT_TO_DATE_D }" datePicker="true" />
                </e:field>
                <e:label for="CONT_NUM_DESC" title="${form_CONT_NUM_DESC_N}"/>
                <e:field>
                    <e:inputText id="CONT_NUM_DESC" style="${imeMode}" name="CONT_NUM_DESC" width="100%" required="${form_CONT_NUM_DESC_R }" disabled="${form_CONT_NUM_DESC_D }" value="" readOnly="${form_CONT_NUM_DESC_RO }" maxLength="${form_CONT_NUM_DESC_M}" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="CONT_USER_NM" title="${form_CONT_USER_NM_N}"/>
                <e:field>
                    <e:search id="CONT_USER_NM" name="CONT_USER_NM" value="${ses.userNm}" width="100%" maxLength="${form_CONT_USER_NM_M}" onIconClick="getContUserInfo" disabled="${form_CONT_USER_NM_D}" readOnly="${form_CONT_USER_NM_RO}" required="${form_CONT_USER_NM_R}" onKeyDown="cleanContUserInfo" />
                    <e:inputHidden id="CONT_USER_ID" name="CONT_USER_ID" value="${ses.userId}" />
                </e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:search id="VENDOR_NM" name="VENDOR_NM" value="" width="100%" maxLength="${form_VENDOR_NM_M}" onIconClick="getVendorCd" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onChange="cleanVendorCd" />
                    <e:inputHidden id="VENDOR_CD" name="VENDOR_CD" value="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar id="buttonBar" align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" disabled="${Search_D}" visible="${Search_V}" onClick="doSearch" />
            <e:button id="Choice" name="Choice" label="${Choice_N}" disabled="${Choice_D}" visible="${Choice_V}" onClick="doChoice" />
            <e:button id="Close" name="Close" label="${Close_N}" disabled="${Close_D}" visible="${Close_V}" onClick="doClose" />
        </e:buttonBar>

        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>

</e:ui>