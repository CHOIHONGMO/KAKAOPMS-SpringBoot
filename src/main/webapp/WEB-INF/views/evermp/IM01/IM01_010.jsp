<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

    <script type="text/javascript">

        var grid;
        var baseUrl = "/evermp/IM02/IM0201/";

        function init() {
            grid = EVF.C("grid");

            grid.cellClickEvent(function(rowId, colId, value) {

                if(colId == "ITEM_CD") {
                	if( value == '' ) return;
                    var param = {
                        'ITEM_CD': grid.getCellValue(rowId, 'ITEM_CD'),
                        'popupFlag': true,
                        'detailView': true
                    };
                    everPopup.im03_014open(param);
                }
                if (colId == "VENDOR_NM") {
                	if( value == '' ) return;
                	var param = {
                        'VENDOR_CD': grid.getCellValue(rowId, 'VENDOR_CD'),
                        'detailView': true,
                        'popupFlag': true
                    };
                    everPopup.openPopupByScreenId("BS03_002", 1200, 700, param);
                }
                if (colId == "SG_CTRL_USER_NM") {
                	if( value == '' ) return;
                    var param = {
                        callbackFunction : "",
                        USER_ID : grid.getCellValue(rowId, 'SG_CTRL_USER_ID'),
                        detailView : true
                    };
                    everPopup.openPopupByScreenId("BYM1_062", 680, 210, param);
                }
            });

            grid.excelExportEvent({
                allItems : "${excelExport.allCol}",
                fileName : "${screenName }"
            });

        }

        function doSearch() {

            var store = new EVF.Store();
            if(!store.validate()) { return;}
            store.setGrid([grid]);
            store.load(baseUrl + 'im01010_doSearch', function() {
                if(grid.getRowCount() == 0){
                    alert("${msg.M0002 }");
                }
            });
        }

        function doSave() {
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }

            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                if( everString.lrTrim(grid.getCellValue(rowIds[i], 'NEW_LEAD_TIME')) == "" ){
                    grid.setCellValue(rowIds[i], 'NEW_LEAD_TIME', grid.getCellValue(rowIds[i], 'LEAD_TIME'));
                }
                if( everString.lrTrim(grid.getCellValue(rowIds[i], 'NEW_MOQ_QTY')) == "" ){
                    grid.setCellValue(rowIds[i], 'NEW_MOQ_QTY', grid.getCellValue(rowIds[i], 'MOQ_QTY'));
                }
                if( everString.lrTrim(grid.getCellValue(rowIds[i], 'NEW_RV_QTY')) == "" ){
                    grid.setCellValue(rowIds[i], 'NEW_RV_QTY', grid.getCellValue(rowIds[i], 'RV_QTY'));
                }
                if( everString.lrTrim(grid.getCellValue(rowIds[i], 'NEW_VALID_TO_DATE')) == "" ){
                    grid.setCellValue(rowIds[i], 'NEW_VALID_TO_DATE', grid.getCellValue(rowIds[i], 'VALID_TO_DATE'));
                }
                if( everString.lrTrim(grid.getCellValue(rowIds[i], 'LEAD_TIME_RMK')) == "" ){
                    return alert('${IM01_010_001}');
                }
            }

            if (!grid.validate().flag) { return alert(grid.validate().msg); }
            if (!confirm('${msg.M0021}')) { return; }

            var store = new EVF.Store();
            store.setGrid([grid]);
            store.getGridData(grid, 'sel');
            store.load(baseUrl + 'im01010_doUpdate', function() {
                alert(this.getResponseMessage());
                doSearch();
            });
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
        
        function setMakerF(datum) {
            EVF.V('MAKER_CD', datum.MKBR_CD);
            EVF.V('MAKER_NM', datum.MKBR_NM);
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

        function doAllSetting(){
            if(!grid.isExistsSelRow()) { return alert("${msg.M0004}"); }
            var rowIds = grid.getSelRowId();
            for(var i in rowIds) {
                    grid.setCellValue(rowIds[i], 'NEW_LEAD_TIME', EVF.V("LEAD_TIME"));
            }
        }

        function searchMakerCd(){
            var param = {
                callBackFunction : "selectMakerCd"
            };
            everPopup.openCommonPopup(param, 'SP0068');
        }

        function selectMakerCd(dataJsonArray) {
            EVF.V("MAKER_CD",dataJsonArray.MKBR_CD);
            EVF.V("MAKER_NM",dataJsonArray.MKBR_NM);
        }

        function onSearchPlant() {
            if( EVF.V("CUST_CD") == "" ) return alert("${IM01_010_002}");
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

    </script>
    
    <e:window id="IM01_010" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">
        <e:searchPanel id="form" title="${msg.M9999 }" columnCount="3" labelWidth="${labelWidth }" useTitleBar="false" onEnter="doSearch">
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
                <e:label for="ITEM_DESC" title="${form_ITEM_DESC_N}" />
                <e:field>
                    <e:inputText id="ITEM_DESC" name="ITEM_DESC" value="" width="${form_ITEM_DESC_W}" maxLength="${form_ITEM_DESC_M}" disabled="${form_ITEM_DESC_D}" readOnly="${form_ITEM_DESC_RO}" required="${form_ITEM_DESC_R}" />
                </e:field>
                <e:label for="VENDOR_CD" title="${form_VENDOR_CD_N}"/>
                <e:field>
                    <e:search id="VENDOR_CD" style="ime-mode:inactive" name="VENDOR_CD" value="" width="40%" maxLength="${form_VENDOR_CD_M}" onIconClick="${form_VENDOR_CD_RO ? 'everCommon.blank' : 'searchVendorCd'}" disabled="${form_VENDOR_CD_D}" readOnly="${form_VENDOR_CD_RO}" required="${form_VENDOR_CD_R}" />
                    <e:inputText id="VENDOR_NM" style="${imeMode}" name="VENDOR_NM" value="${form.VENDOR_NM}" width="60%" maxLength="${form_VENDOR_NM_M}" disabled="${form_VENDOR_NM_D}" readOnly="${form_VENDOR_NM_RO}" required="${form_VENDOR_NM_R}"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="S_LEAD_TIME" title="${form_S_LEAD_TIME_N}"/>
                <e:field>
                    <e:select id="S_LEAD_TIME" name="S_LEAD_TIME" value="" options="${sLeadTimeOptions}" width="${form_S_LEAD_TIME_W}" disabled="${form_S_LEAD_TIME_D}" readOnly="${form_S_LEAD_TIME_RO}" required="${form_S_LEAD_TIME_R}" placeHolder="" />
					<e:inputHidden id="S_LEAD_TIME_CD" name="S_LEAD_TIME_CD"/>
                </e:field>
                <%--
                <e:label for="MAKER_CD" title="${form_MAKER_CD_N}"/>
                <e:field>
                    <e:search id="MAKER_CD" style="ime-mode:inactive" name="MAKER_CD"  value="${formData.MAKER_CD}" width="40%" maxLength="${form_MAKER_CD_M}" onIconClick="${form_MAKER_CD_RO ? 'everCommon.blank' : 'searchMakerCd'}" disabled="${form_MAKER_CD_D}" readOnly="${form_MAKER_CD_RO}" required="${form_MAKER_CD_R}" />
                    <e:inputText id="MAKER_NM" style="${imeMode}" name="MAKER_NM" value="${formData.MAKER_NM}" width="60%" maxLength="${form_MAKER_NM_M}" disabled="${form_MAKER_NM_D}" readOnly="${form_MAKER_NM_RO}" required="${form_MAKER_NM_R}"/>
                </e:field>
                --%>
                <e:label for="UNIT_PRC_VALID_YN" title="${form_UNIT_PRC_VALID_YN_N}"/>
				<e:field>
					<e:select id="UNIT_PRC_VALID_YN" name="UNIT_PRC_VALID_YN" value="1" options="${unitPrcValidYnOptions}" width="40%" disabled="${form_UNIT_PRC_VALID_YN_D}" readOnly="${form_UNIT_PRC_VALID_YN_RO}" required="${form_UNIT_PRC_VALID_YN_R}" placeHolder="" />
					<e:select id="TEMP_CD_FLAG" name="TEMP_CD_FLAG" value="0" options="${tempCdFlagOptions}" width="60%" disabled="${form_TEMP_CD_FLAG_D}" readOnly="${form_TEMP_CD_FLAG_RO}" required="${form_TEMP_CD_FLAG_R}" placeHolder="" />
				</e:field>
				<e:label for="SEARCH_COUNT_CD" title="${form_SEARCH_COUNT_CD_N}"/>
				<e:field>
					<e:select id="SEARCH_PAGE_NO" name="SEARCH_PAGE_NO" value="1" options="${searchPageNoOptions}" width="40%" disabled="${form_SEARCH_PAGE_NO_D}" readOnly="${form_SEARCH_PAGE_NO_RO}" required="${form_SEARCH_PAGE_NO_R}" placeHolder="" usePlaceHolder="false"/>
					<e:select id="SEARCH_COUNT_CD" name="SEARCH_COUNT_CD" value="500" options="${searchCountCdOptions}" width="60%" disabled="${form_SEARCH_COUNT_CD_D}" readOnly="${form_SEARCH_COUNT_CD_RO}" required="${form_SEARCH_COUNT_CD_R}" placeHolder="" />
				</e:field>
            </e:row>
        </e:searchPanel>

        <e:buttonBar align="right" id="buttonBar">
        	<%-- 표준납기(L/T) --%>
            <e:text style="font-weight: bold;">●&nbsp;${form_S_LEAD_TIME_N} &nbsp;:&nbsp; </e:text>
            <e:inputNumber id="LEAD_TIME" name="LEAD_TIME" value="" width="100" maxValue="${form_LEAD_TIME_M}" decimalPlace="${form_LEAD_TIME_NF}" disabled="${form_LEAD_TIME_D}" readOnly="${form_LEAD_TIME_RO}" required="${form_LEAD_TIME_R}"  />
            <e:text>&nbsp;&nbsp;</e:text>
            <e:button id="doAllSetting" name="doAllSetting" label="${doAllSetting_N }" disabled="${doAllSetting_D }" align="left" visible="${doAllSetting_V}" onClick="doAllSetting" />
            
            <e:button id="doSearch" name="doSearch" label="${doSearch_N }" disabled="${doSearch_D }" visible="${doSearch_V}" onClick="doSearch"/>
            <e:button id="doSave" name="doSave" label="${doSave_N }" disabled="${doSave_D }" visible="${doSave_V}" onClick="doSave"/>
        </e:buttonBar>
        
        <e:gridPanel id="grid" name="grid" width="100%" height="fit" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.grid.gridColData}" />

    </e:window>
</e:ui>