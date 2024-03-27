<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>

        var grid;
        var baseUrl = "/evermp/IM03/IM0303/";

        function init() {

            grid = EVF.C("grid");
            // grid.setColIconify("CHANGE_REASON", "CHANGE_REASON", "comment", false);
            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == 'ITEM_CD') {
                	if( value == '' ) return;
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'detailView': true,
                        'popupYn': "Y"
                    };
                    everPopup.im03_009open(param);
                }
                if(colId == 'VENDOR_NM') {
                	if( value == '' ) return;
                    var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
                /*
                if(colId == 'CHANGE_REASON') {
                	if( value == '' ) return;
                    var param = {
                        title: "변경사유",
                        message: grid.getCellValue(rowId, 'CHANGE_REASON'),
                        detailView: 'true',
                        rowId: rowId
                    };
                    var url = '/common/popup/common_text_input/view';
                    everPopup.openModalPopup(url, 500, 320, param);
                }
                */
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });
        }

        function doSearch() {
            var store = new EVF.Store();
            store.setGrid([grid]);
            store.load(baseUrl + "im01040_doSearch", function () {
                if(grid.getRowCount() == 0) {
                    return alert('${msg.M0002}');
                }
/*                grid.setColMerge(['CONT_NO']);
                grid.setColMerge(['ITEM_CD']);
                grid.setColMerge(['ITEM_DESC']);
                grid.setColMerge(['ITEM_SPEC']);
                grid.setColMerge(['MAKER_NM']);
                grid.setColMerge(['MAKER_PART_NO']);
                grid.setColMerge(['BRAND_NM']);
                grid.setColMerge(['ORIGIN_NM']);
                grid.setColMerge(['CONT_START_DATE']);
                grid.setColMerge(['CONT_END_DATE']);
                grid.setColMerge(['CONT_DATE']);
                grid.setColMerge(['CTRL_USER_NM']);
                grid.setColMerge(['DEAL_TYPE_LOC']);*/
            });
        }

        function doConf() {

            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }

            var itemCd = "";
            var itemCdStr = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {

                itemCd = grid.getCellValue(rowIds[i], 'ITEM_CD');

                if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}") {
                    return alert("${IM01_040_007}");
                }
                if(grid.getCellValue(rowIds[i], 'CONT_STATUS_CD') != "0" && grid.getCellValue(rowIds[i], 'CONT_STATUS_CD') != "1") {
                    return alert("${IM01_040_008}");
                }
                for(var g in grid.getSelRowId()) {
                    if (grid.getCellValue(rowIds[g], 'ITEM_CD') == itemCd && rowIds[i] != rowIds[g]) {
                        return alert("${IM01_040_010}");
                    }
                }
                itemCdStr = itemCdStr + grid.getCellValue(rowIds[i], 'ITEM_CD') + ",";
            }
            if(itemCdStr.length > 0) { itemCdStr = itemCdStr.substring(0, itemCdStr.length - 1); }

            var param = {
                ITEM_CD_STR : itemCdStr,
                'RFQ_TYPE' : "200",
                'sendType' : "F",
                'callBackFunction' : "doSendRFQ",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("RQ01_011", 1000, 850, param);
        }
		
        // 기존 단가를 기준으로 새로운 견적요청서 작성 [미사용]
        function doSendRFQ(dataJsonStr) {

            var rfqData = JSON.parse(dataJsonStr);
            for(idx in rfqData) {
                EVF.C("pVENDOR_LIST").setValue(rfqData[idx].VENDOR_LIST);
                EVF.C("pRFQ_SUBJECT").setValue(rfqData[idx].RFQ_SUBJECT);
                EVF.C("pVENDOR_OPEN_TYPE").setValue(rfqData[idx].VENDOR_OPEN_TYPE);
                EVF.C("pRFQ_CLOSE_DATE").setValue(rfqData[idx].RFQ_CLOSE_DATE);
                EVF.C("pRFQ_CLOSE_HOUR").setValue(rfqData[idx].RFQ_CLOSE_HOUR);
                EVF.C("pRFQ_CLOSE_MIN").setValue(rfqData[idx].RFQ_CLOSE_MIN);
                EVF.C("pDEAL_TYPE").setValue(rfqData[idx].DEAL_TYPE);
                EVF.C("pCONT_START_DATE").setValue(rfqData[idx].CONT_START_DATE);
                EVF.C("pCONT_END_DATE").setValue(rfqData[idx].CONT_END_DATE);
                EVF.C("pRMK_TEXT").setValue(rfqData[idx].RMK_TEXT);
                EVF.C("pATT_FILE_NUM").setValue(rfqData[idx].ATT_FILE_NUM);
                EVF.C("pOPTION_RFQ_REASON").setValue(rfqData[idx].OPTION_RFQ_REASON);
                EVF.C("pRFQ_TYPE").setValue(rfqData[idx].RFQ_TYPE);
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'im01040_doSendRFQ', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function doChangeVendorOpenPop() {

            if(grid.getSelRowCount() == 0) { return alert("${msg.M0004}"); }
            if (grid.getSelRowCount() > 1) { return alert('${msg.M0006}'); }

            var validFromDate = ""; var validToDate = "";
            var vendorCd = ""; var vendorNm = "";
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if(grid.getCellValue(rowIds[i], 'CTRL_USER_ID') != "${ses.userId}") {
                    return alert("${IM01_040_007}");
                }
                validFromDate = grid.getCellValue(rowIds[i], 'CONT_START_DATE');
                validToDate = grid.getCellValue(rowIds[i], 'CONT_END_DATE');
                vendorCd = grid.getCellValue(rowIds[i], 'VENDOR_CD');
                vendorNm = grid.getCellValue(rowIds[i], 'VENDOR_NM');
            }

            var param = {
                'VALID_FROM_DATE' : validFromDate,
                'VALID_TO_DATE' : validToDate,
                'VENDOR_CD' : vendorCd,
                'VENDOR_NM' : vendorNm,
                'callBackFunction' : "doChangeVendor",
                'detailView': false,
                'popupFlag': true
            };
            everPopup.openPopupByScreenId("IM01_041", 800, 400, param);
        }

        function doChangeVendor(dataJsonStr) {

            var data = JSON.parse(dataJsonStr);
            for(idx in data) {
                EVF.C("pVENDOR_CD").setValue(data[idx].VENDOR_CD);
                EVF.C("pVALID_FROM_DATE").setValue(data[idx].VALID_FROM_DATE);
                EVF.C("pVALID_TO_DATE").setValue(data[idx].VALID_TO_DATE);
                EVF.C("pPRICE_CHANGE_REASON").setValue(data[idx].PRICE_CHANGE_REASON);
            }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'im01041_doChangeVendor', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
        }

        function searchCust() {
            var param = {
                callBackFunction : "selectCust"
            };
            everPopup.openCommonPopup(param, 'SP0067');
        }

        function selectCust(data) {
            EVF.V('APPLY_COM', data.CUST_CD);
            EVF.V('APPLY_NM', data.CUST_NM);
        }

        function cleanCustCd() {
            EVF.V('APPLY_COM', "");
        }

        function searchVendorCd() {
            var param = {
                callBackFunction : "selectVendorCd"
            };
            everPopup.openCommonPopup(param, 'SP0063');
        }

        function selectVendorCd(dataJsonArray) {
            EVF.V("VENDOR_CD",dataJsonArray.VENDOR_CD);
            EVF.V("VENDOR_NM",dataJsonArray.VENDOR_NM);
        }

        function cleanVendorCd() {
            EVF.V('VENDOR_CD', "");
        }


        function chgCustCd() {
            var store = new EVF.Store;
            store.load('/evermp/SY01/SY0101/getPlantCd', function() {
            	if (this.getParameter("plantCds") != null) {
                    EVF.C('PLANT_CD').setOptions(this.getParameter("plantCds"));
            	}
            });
        }

        function searchCustCd() {
            var param = {
                callBackFunction : "selectCustCd"
            };
            everPopup.openCommonPopup(param, 'SP0902');
        }

        function selectCustCd(dataJsonArray) {
            EVF.C("CUST_CD").setValue(dataJsonArray.CUST_CD);
            EVF.C("CUST_NM").setValue(dataJsonArray.CUST_NM);
            //chgCustCd();
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${IM01_040_013}");
            var param = {
                callBackFunction : "callBackPlant",
                custCd: EVF.V("CUST_CD")
            };
            everPopup.openCommonPopup(param, 'SP0005');
        }

        function callBackPlant(data) {
            jsondata = JSON.parse(JSON.stringify(data));
            EVF.C("PLANT_CD").setValue(jsondata.PLANT_CD);
            EVF.C("PLANT_NM").setValue(jsondata.PLANT_NM);
        }

        function _getItemClsNm()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNm",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '${ses.companyCd}',  // 고객사코드or회사코드
                'custNm' : '${ses.companyNm}'  // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _getItemClsNmCust()  {

            var popupUrl = "/evermp/IM04/IM0402/IM04_005/view";
            var param = {
                callBackFunction : "_setItemClassNmCust",
                'detailView': false,
                'multiYN' : false,
                'ModalPopup' : true,
                'searchYN' : true,
                'custCd' : '21',  // 고객사코드or회사코드
                'custNm' : '㈜소노인터내셔널' // 고객사코드or회사코드
            };
            everPopup.openModalPopup(popupUrl, 500, 650, param, "itemClassNmPopup");
        }

        function _setItemClassNmCust(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1_CUST").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2_CUST").setValue("");}else{EVF.C("ITEM_CLS2_CUST").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3_CUST").setValue("");}else{EVF.C("ITEM_CLS3_CUST").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4_CUST").setValue("");}else{EVF.C("ITEM_CLS4_CUST").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM_CUST").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1_CUST").setValue("");
                EVF.C("ITEM_CLS2_CUST").setValue("");
                EVF.C("ITEM_CLS3_CUST").setValue("");
                EVF.C("ITEM_CLS4_CUST").setValue("");
                EVF.C("ITEM_CLS_NM_CUST").setValue("");
            }
        }
        function _setItemClassNm(data) {
            if(data!=null){
                data = JSON.parse(data);
                EVF.C("ITEM_CLS1").setValue(data.ITEM_CLS1);
                if(data.ITEM_CLS2=="*"){EVF.C("ITEM_CLS2").setValue("");}else{EVF.C("ITEM_CLS2").setValue(data.ITEM_CLS2);}
                if(data.ITEM_CLS3=="*"){EVF.C("ITEM_CLS3").setValue("");}else{EVF.C("ITEM_CLS3").setValue(data.ITEM_CLS3);}
                if(data.ITEM_CLS4=="*"){EVF.C("ITEM_CLS4").setValue("");}else{EVF.C("ITEM_CLS4").setValue(data.ITEM_CLS4);}
                EVF.C("ITEM_CLS_NM").setValue(data.ITEM_CLS_PATH_NM);
            } else {
                EVF.C("ITEM_CLS1").setValue("");
                EVF.C("ITEM_CLS2").setValue("");
                EVF.C("ITEM_CLS3").setValue("");
                EVF.C("ITEM_CLS4").setValue("");
                EVF.C("ITEM_CLS_NM").setValue("");
            }
        }
    </script>

    <e:window id="IM01_040" onReady="init" initData="${initData}" title="${fullScreenName}">

        <e:searchPanel id="form" title="${form_CAPTION_N}" labelWidth="${labelWidth}" labelAlign="${labelAlign}" columnCount="3" useTitleBar="false" onEnter="doSearch">
            <e:row>
				<e:label for="REG_DATE_FROM" title="${form_REG_DATE_FROM_N}"/>
				<e:field>
				<e:inputDate id="REG_DATE_FROM" name="REG_DATE_FROM" toDate="REG_DATE_TO" value="${fromDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_FROM_R}" disabled="${form_REG_DATE_FROM_D}" readOnly="${form_REG_DATE_FROM_RO}" />
				<e:text>~</e:text>
				<e:inputDate id="REG_DATE_TO" name="REG_DATE_TO" fromDate="REG_DATE_FROM" value="${nowDate}" width="${inputDateWidth}" datePicker="true" required="${form_REG_DATE_TO_R}" disabled="${form_REG_DATE_TO_D}" readOnly="${form_REG_DATE_TO_RO}" />
				</e:field>
                <e:label for="CUST_CD" title="${form_CUST_CD_N}"/>
                <e:field>
                    <e:search id="CUST_CD" name="CUST_CD" value="" width="40%" maxLength="${form_CUST_CD_M}" onIconClick="searchCustCd" disabled="${form_CUST_CD_D}" readOnly="${form_CUST_CD_RO}" required="${form_CUST_CD_R}" />
                    <e:inputText id="CUST_NM" name="CUST_NM" value="" width="60%" maxLength="${form_CUST_NM_M}" disabled="${form_CUST_NM_D}" readOnly="${form_CUST_NM_RO}" required="${form_CUST_NM_R}" />
                </e:field>
                <e:label for="PLANT_CD" title="${form_PLANT_CD_N}"/>
                <e:field>
                    <e:search id="PLANT_CD" name="PLANT_CD" value="" width="40%" maxLength="${form_PLANT_CD_M}" onIconClick="onSearchPlant" disabled="${form_PLANT_CD_D}" readOnly="${form_PLANT_CD_RO}" required="${form_PLANT_CD_R}" />
                    <e:inputText id="PLANT_NM" name="PLANT_NM" value="" width="60%" maxLength="${form_PLANT_NM_M}" disabled="${form_PLANT_NM_D}" readOnly="${form_PLANT_NM_RO}" required="${form_PLANT_NM_R}" />
                </e:field>
            </e:row>
            <e:row>
				<e:label for="ITEM_CD" title="${form_ITEM_CD_N}" />
				<e:field>
				<e:inputText id="ITEM_CD" name="ITEM_CD" value="" width="${form_ITEM_CD_W}" maxLength="${form_ITEM_CD_M}" disabled="${form_ITEM_CD_D}" readOnly="${form_ITEM_CD_RO}" required="${form_ITEM_CD_R}" />
				</e:field>
				<e:label for="ITEM_DESC_SPEC" title="${form_ITEM_DESC_SPEC_N}" />
				<e:field>
				<e:inputText id="ITEM_DESC_SPEC" name="ITEM_DESC_SPEC" value="" width="${form_ITEM_DESC_SPEC_W}" maxLength="${form_ITEM_DESC_SPEC_M}" disabled="${form_ITEM_DESC_SPEC_D}" readOnly="${form_ITEM_DESC_SPEC_RO}" required="${form_ITEM_DESC_SPEC_R}" />
				</e:field>
                <e:label for="VENDOR_NM" title="${form_VENDOR_NM_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="searchVendorCd" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}" onChange="cleanVendorCd" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="ITEM_CLS_NM" title="${form_ITEM_CLS_NM_N}"/>
                <e:field>
                    <e:search id="ITEM_CLS_NM" name="ITEM_CLS_NM" value="" width="${form_ITEM_CLS_NM_W}" maxLength="${form_ITEM_CLS_NM_M}" onIconClick="_getItemClsNm" disabled="${form_ITEM_CLS_NM_D}" readOnly="${form_ITEM_CLS_NM_RO}" required="${form_ITEM_CLS_NM_R}" />
                    <e:inputHidden id="ITEM_CLS1" name="ITEM_CLS1" />
                    <e:inputHidden id="ITEM_CLS2" name="ITEM_CLS2" />
                    <e:inputHidden id="ITEM_CLS3" name="ITEM_CLS3" />
                    <e:inputHidden id="ITEM_CLS4" name="ITEM_CLS4" />
                </e:field>

				<e:label for="ITEM_CLS_NM_CUST" title="${form_ITEM_CLS_NM_CUST_N}"/>
				<e:field>
				<e:search id="ITEM_CLS_NM_CUST" name="ITEM_CLS_NM_CUST" value="" width="${form_ITEM_CLS_NM_CUST_W}" maxLength="${form_ITEM_CLS_NM_CUST_M}" onIconClick="_getItemClsNmCust" disabled="${form_ITEM_CLS_NM_CUST_D}" readOnly="${form_ITEM_CLS_NM_CUST_RO}" required="${form_ITEM_CLS_NM_CUST_R}" />
                    <e:inputHidden id="ITEM_CLS1_CUST" name="ITEM_CLS1_CUST" />
                    <e:inputHidden id="ITEM_CLS2_CUST" name="ITEM_CLS2_CUST" />
                    <e:inputHidden id="ITEM_CLS3_CUST" name="ITEM_CLS3_CUST" />
                    <e:inputHidden id="ITEM_CLS4_CUST" name="ITEM_CLS4_CUST" />
				</e:field>
                <e:label for="SG_CTRL_USER_ID" title="${form_SG_CTRL_USER_ID_N}"/>
                <e:field>
                    <e:select id="SG_CTRL_USER_ID" name="SG_CTRL_USER_ID" value="${formData.SG_CTRL_USER_ID}" options="${itemUserOptions}" width="${form_SG_CTRL_USER_ID_W}" disabled="${form_SG_CTRL_USER_ID_D}" readOnly="${form_SG_CTRL_USER_ID_RO}" required="${form_SG_CTRL_USER_ID_R}" placeHolder="" />
                </e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" width="100%">
            <e:button id="Search" name="Search" label="${Search_N}" onClick="doSearch" disabled="${Search_D}" visible="${Search_V}"/>
        </e:buttonBar>

        <e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="fit" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>